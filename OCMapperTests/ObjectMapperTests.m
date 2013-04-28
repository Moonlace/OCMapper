//
//  ObjectMapperTests.m
//  ObjectMapperTests
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ObjectMapperTests.h"
#import "ObjectMapper.h"
#import "User.h"

@implementation ObjectMapperTests
@synthesize mapper;
@synthesize instanceProvider;
@synthesize mappingProvider;

#pragma mark - Setup & Teardown -

- (void)setUp
{
    [super setUp];
	
	self.mappingProvider = [[InCodeMappingProvider alloc] init];
	self.instanceProvider = [[ObjectInstanceProvider alloc] init];
	
	self.mapper = [[ObjectMapper alloc] init];
	self.mapper.mappingProvider = self.mappingProvider;
	self.mapper.instanceProvider = self.instanceProvider;
}

- (void)tearDown
{
	self.mapper = nil;
	self.mappingProvider =  nil;
	
    [super tearDown];
}

#pragma mark - Tests -

- (void)testOneToOneSimpleMapping
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"firstName"];
	[userDictionary setObject:age forKey:@"age"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	STAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testOneToOneSimpleNestedMappingWithSmallCaseNestedKey
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:@"city"];
	[addressDictionary setObject:country forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneSimpleNestedMapping
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:@"city"];
	[addressDictionary setObject:country forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneCustomNestedMapping
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	NSString *CITY_KEY = @"SOME_CITY_KEY";
	NSString *COUNTRY_KEY = @"SOME_COUNTRY_KEY";
	NSString *ADDRESS_KEY = @"SOME_ADDRESS_KEY";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:CITY_KEY];
	[addressDictionary setObject:country forKey:COUNTRY_KEY];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:ADDRESS_KEY];
	
	[self.mappingProvider mapFromDictionaryKey:ADDRESS_KEY toPropertyKey:@"address" withObjectType:[Address class] forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:CITY_KEY toPropertyKey:@"city" forClass:[Address class]];
	[self.mappingProvider mapFromDictionaryKey:COUNTRY_KEY toPropertyKey:@"country" forClass:[Address class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneCustomMapping
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSString *SOME_FIRST_NAME_KEY = @"SOME_FIRST_NAME";
	NSString *SOME_AGE_KEY = @"A_RANDOM_AGE_FIELD";
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:SOME_FIRST_NAME_KEY];
	[userDictionary setObject:age forKey:SOME_AGE_KEY];
	
	[self.mappingProvider mapFromDictionaryKey:SOME_FIRST_NAME_KEY toPropertyKey:@"firstName" forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:SOME_AGE_KEY toPropertyKey:@"age" forClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	STAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testAutomaticDateConversion
{
	NSString *dateString = @"06/21/2013";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSDate *expectedDate = [dateFormatter dateFromString:dateString];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:dateString forKey:@"dateOfBirth"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertTrue([user.dateOfBirth isEqual:expectedDate], @"date did not populate correctly");
}

- (void)testAutomaticDMappingWithArrayOnRootLevel
{
	NSMutableDictionary *user1Dictionary = [NSMutableDictionary dictionary];
	[user1Dictionary setObject:@"Aryan" forKey:@"firstName"];
	
	NSMutableDictionary *user2Dictionary = [NSMutableDictionary dictionary];
	[user2Dictionary setObject:@"Chuck" forKey:@"firstName"];
	
	NSArray *users = [self.mapper objectFromSource:@[user1Dictionary, user2Dictionary] toInstanceOfClass:[User class]];
	STAssertTrue(users.count == 2, @"Did not populate correct number of items");
	STAssertTrue([[[users objectAtIndex:0] firstName] isEqual:
				  [user1Dictionary objectForKey:@"firstName"]], @"Did not populate correct attributes");
	STAssertTrue([[[users objectAtIndex:1] firstName] isEqual:
				  [user2Dictionary objectForKey:@"firstName"]], @"Did not populate correct attributes");
}

- (void)testCustomDateConversion
{
	NSString *dateOfBirthString = @"01-21/2005";
	NSDateFormatter *dateOfBirthFormatter = [[NSDateFormatter alloc] init];
	[dateOfBirthFormatter setDateFormat:@"MM-dd/yyyy"];
	
	NSString *accountCreationDateString = @"01(2005(21";
	NSDateFormatter *accountCreationFormatter = [[NSDateFormatter alloc] init];
	[accountCreationFormatter setDateFormat:@"MM(yyyy(dd"];
	
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	[userDict setObject:dateOfBirthString forKey:@"dateOfBirth"];
	[userDict setObject:accountCreationDateString forKey:@"accountCreationDate"];
	
	[self.mappingProvider setDateFormatter:dateOfBirthFormatter forProperty:@"dateOfBirth" andClass:[User class]];
	[self.mappingProvider setDateFormatter:accountCreationFormatter forProperty:@"accountCreationDate" andClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDict toInstanceOfClass:[User class]];
	STAssertNotNil(user.accountCreationDate, @"Did nor populate date");
	STAssertNotNil(user.dateOfBirth, @"Did nor populate date");
	STAssertTrue([user.accountCreationDate isEqualToDate:user.dateOfBirth], @"Did not populate dates correctly");
}

- (void)testAutoMappingShouldNotBeCaseSensitive
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"FirstNAmE"];
	[userDictionary setObject:age forKey:@"aGe"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	STAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testPerformance
{
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@"SAN DIEGO" forKey:@"city"];
	[addressDictionary setObject:@"US" forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"Ghassemi" forKey:@"lastName"];
	[userDictionary setObject:@26 forKey:@"age"];
	[userDictionary setObject:@"01-21/2005" forKey:@"dateOfBirth"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	NSDate *methodStart = [NSDate date];
	
	NSArray *users = [self.mapper objectFromSource:@[userDictionary, userDictionary, userDictionary, userDictionary,
					  userDictionary, userDictionary, userDictionary, userDictionary, userDictionary, userDictionary,
					  userDictionary, userDictionary, userDictionary, userDictionary, userDictionary, userDictionary]
								 toInstanceOfClass:[User class]];
	
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	NSLog(@"\n\n\n\nExecution Time:%f objectCount:%d\n\n\n\n", executionTime, users.count);
}

- (void)testDictionaryFromObject
{
	Address *address = [[Address alloc] init];
	address.city = @"San Diego";
	address.country = @"US";
	
	User *user = [[User alloc] init];
	user.firstName = @"Aryan";
	user.lastName = @"Ghassmei";
	user.address = address;
	user.age = @26;
	user.dateOfBirth = [NSDate date];
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
}

- (void)testXmlMapping
{
	XMLMappingProvider *provider = [[XMLMappingProvider alloc] initWithXmlFile:@"ObjectMappingConfig"];
	self.mapper.mappingProvider = provider;
}

- (void)testPlistMapping
{
	PLISTMappingProvider *provider = [[PLISTMappingProvider alloc] initWithFileName:@"ObjectMappingConfig"];
	self.mapper.mappingProvider = provider;
}

@end
