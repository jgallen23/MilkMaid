/*
 
 The MIT License
 
 Copyright (c) 2009 Konstantin Kudryashov <ever.zet@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "EVRZRtmApi.h"

static EVRZRtmApi* LTRtmApiInstance;

NSString* md5(NSString *str)
{
  const char *cStr = [str UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(cStr, strlen(cStr), result);
  return [[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
           ] lowercaseString];
}

NSComparisonResult sortParameterKeysByChars(NSString* string1, NSString* string2, NSInteger charNum)
{
  if ([string1 length] == (charNum + 1) || [string2 length] == (charNum + 1))
  {
    return NSOrderedSame;
  }
  
  char v1 = [string1 characterAtIndex:charNum];
  char v2 = [string2 characterAtIndex:charNum];
  
  if (v1 < v2)
  {
    return NSOrderedAscending;
  }
  else if (v1 > v2)
  {
    return NSOrderedDescending;
  }
  else
  {
    return sortParameterKeysByChars(string1, string2, charNum + 1);
  }
}

NSComparisonResult sortParameterKeys(NSString* string1, NSString* string2, void *context)
{
  return sortParameterKeysByChars(string1, string2, 0);
}

@implementation EVRZRtmApi

@synthesize apiKey;
@synthesize apiSecret;
@synthesize token;
@synthesize lastApiCall;

+ (EVRZRtmApi*)instance
{
  return LTRtmApiInstance;
}

- (id)init
{
  return [self initWithApiKey:@"" andApiSecret:@""];
}

- (id)initWithApiKey:(NSString*)anApiKey andApiSecret:(NSString*)anApiSecret
{
  if (!(self = [super init]))
  {
    return nil;
  }

  [self setApiKey:anApiKey];
  [self setApiSecret:anApiSecret];

  LTRtmApiInstance = self;

  return self;
}

- (void)dealloc
{
  [apiKey release];
  [apiSecret release];
  [token release];
  [lastApiCall release];

  [super dealloc];
}

+ (NSString*)rtmDateFromDate:(NSDate*)aDate
{
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
  NSString* dateString = [dateFormatter stringFromDate:aDate];
  [dateFormatter release];
  
  return dateString;
}

+ (NSDate*)dateFromRtmDate:(NSString*)anSqlDate
{
  NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
  NSDate* date = [dateFormatter dateFromString:anSqlDate];
  [dateFormatter release];
  
  return date;
}

- (NSString*)timeline
{
  NSDictionary* response = [self dataByCallingMethod:@"rtm.timelines.create" andParameters:[NSDictionary dictionary] withToken:YES];

  if ([self noErrorsInResponse:response])
  {
    return [response objectForKey:@"timeline"];
  }
  else
  {
    return [self errorWithResponse:response];
  }
}

- (NSString*)frob
{
  NSDictionary* response = [self dataByCallingMethod:@"rtm.auth.getFrob" andParameters:[NSDictionary dictionary]];

  if ([self noErrorsInResponse:response])
  {
    return [response objectForKey:@"frob"];
  }
  else
  {
    return [self errorWithResponse:response];
  }
}

- (NSString*)authUrlForPerms:(NSString*)aPerms withFrob:(NSString*)aFrob
{
  NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              apiKey, @"api_key",
                              aPerms, @"perms",
                              aFrob, @"frob", nil];
  NSString* parametersString = [self urlParametersWithDictionary:parameters];

  return [NSString stringWithFormat:@"http://www.rememberthemilk.com/services/auth/?%@api_sig=%@",
          parametersString, [self apiSigFromParameters:parameters]];
}

- (NSString*)tokenWithFrob:(NSString*)aFrob
{
  NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:aFrob, @"frob", nil];
  NSDictionary* response = [self dataByCallingMethod:@"rtm.auth.getToken" andParameters:parameters];

  if ([self noErrorsInResponse:response])
  {
    return [[response objectForKey:@"auth"] objectForKey:@"token"];
  }
  else
  {
    return [self errorWithResponse:response];
  }
}

- (BOOL)noErrorsInResponse:(NSDictionary*)anResponse
{
  return ([[anResponse objectForKey:@"stat"] compare:@"ok"] == NSOrderedSame);
}

- (NSString*)errorMsgInResponse:(NSDictionary*)anResponse
{
  return [[anResponse objectForKey:@"err"] objectForKey:@"msg"];
}

- (id)errorWithResponse:(NSDictionary*)anResponse
{
  NSLog(@"error: %@", [self errorMsgInResponse:anResponse]);

  return nil;
}

- (NSDictionary*)dataByCallingMethod:(NSString*)aMethod andParameters:(NSDictionary*)aParameters
{
  return [self dataByCallingMethod:aMethod andParameters:aParameters withToken:NO];
}

- (NSDictionary*)dataByCallingMethod:(NSString*)aMethod andParameters:(NSDictionary*)aParameters withToken:(BOOL)useToken
{
  // Checking that last API call was made more than a second ago & if not - waiting for a second (RTM recomendations)
  if (lastApiCall && (([lastApiCall timeIntervalSinceNow] * -1.0) < 1.0))
  {
	  NSLog(@"delay");
    [NSThread sleepForTimeInterval:1.0 - ([lastApiCall timeIntervalSinceNow] * -1)];
  }

  NSURL* url = [NSURL URLWithString:[self urlStringWithMethod:aMethod andParameters:aParameters withToken:useToken]];
  NSString* response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
  [self setLastApiCall:[NSDate date]];

  return [[response JSONValue] objectForKey:@"rsp"];
}

- (NSString*)urlParametersWithDictionary:(NSDictionary*)aParameters
{
  NSMutableString* parametersString = [NSMutableString string];
  NSArray* keys = [aParameters allKeys];

  for (int i = 0; i < [keys count]; i++)
  {
    NSString* key = [NSString stringWithString:[keys objectAtIndex:i]];
    [parametersString appendFormat:@"%@=%@&", key, [aParameters objectForKey:key]];
  }

  return [NSString stringWithString:parametersString];
}

- (NSString*)urlStringWithMethod:(NSString*)aMethod andParameters:(NSDictionary*)aParameters
{
  return [self urlStringWithMethod:aMethod andParameters:aParameters withToken:NO];
}

- (NSString*)urlStringWithMethod:(NSString*)aMethod andParameters:(NSDictionary*)aParameters withToken:(BOOL)useToken
{
  NSMutableDictionary* parameters = [[aParameters mutableCopy] autorelease];
  [parameters setObject:apiKey forKey:@"api_key"];
  [parameters setObject:aMethod forKey:@"method"];
  [parameters setObject:@"json" forKey:@"format"];
  [parameters setObject:[NSString stringWithFormat:@"%d", random()] forKey:@"nocache"];
  if (useToken)
  {
    [parameters setObject:token forKey:@"auth_token"];
  }
  NSString* parametersString = [self urlParametersWithDictionary:parameters];
  NSString* signedParameters = [self apiSigFromParameters:parameters];
  NSString* url = [[NSString stringWithFormat:@"http://api.rememberthemilk.com/services/rest/?%@api_sig=%@",
                    parametersString, signedParameters] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSLog(@"%@", url);

  return url;
}

- (NSString*)apiSigFromParameters:(NSDictionary*)aParameters
{
  NSArray* sortedKeys = [[aParameters allKeys] sortedArrayUsingFunction:sortParameterKeys context:nil];
  NSMutableString* parametersString = [NSMutableString stringWithString:apiSecret];

  for (int i = 0; i < [sortedKeys count]; i++)
  {
    NSString* key = [NSString stringWithString:[sortedKeys objectAtIndex:i]];
    [parametersString appendFormat:@"%@%@", key, [aParameters objectForKey:key]];
  }

  return [md5(parametersString) lowercaseString];
}

@end
