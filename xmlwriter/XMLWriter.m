//
//  XMLWriter.m
//
#import "XMLWriter.h"
#define PREFIX_STRING_FOR_ELEMENT @"@" //From XMLReader
@implementation XMLWriter
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        xml = [[NSString alloc]initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
        nodes = [[NSMutableArray alloc] init]; 
        treeNodes = [[NSMutableArray alloc] init]; 
        isRoot = YES;
        [self serialize:dictionary];
    }
    
    return self;
}
-(void)dealloc
{
    [xml release],nodes =nil;
    [nodes release], nodes = nil ;
    [treeNodes release], treeNodes = nil;
    [super dealloc];
}

-(void)serialize:(id)root
{    
    if([root isKindOfClass:[NSArray class]])
        {
            int mula = (int)[root count];
            mula--;
            [nodes addObject:[NSString stringWithFormat:@"%i",(int)mula]];

            for(id objects in root)
            {
                if ([[nodes lastObject] isEqualToString:@"0"] || [nodes lastObject] == NULL || ![nodes count])
                {
                    [nodes removeLastObject];
                    [self serialize:objects];
                }
                else
                {
                    [self serialize:objects];
                    if(!isRoot)
                        xml = [xml stringByAppendingFormat:@"</%@><%@>",[treeNodes lastObject],[treeNodes lastObject]];
                    else
                        isRoot = FALSE;
                    int value = [[nodes lastObject] intValue];
                    [nodes removeLastObject];
                    value--;
                    [nodes addObject:[NSString stringWithFormat:@"%i",(int)value]];
                }
            }
        }
        else if ([root isKindOfClass:[NSDictionary class]])
        {
            for (NSString* key in root)
            {
                isRoot = FALSE;
                [treeNodes addObject:key];
                xml = [xml stringByAppendingFormat:@"<%@>",key];
                [self serialize:[root objectForKey:key]];
                xml =[xml stringByAppendingFormat:@"</%@>",key];
                [treeNodes removeLastObject];
            }
        }
        else if ([root isKindOfClass:[NSString class]] || [root isKindOfClass:[NSNumber class]] || [root isKindOfClass:[NSURL class]])
        {
//            if ([root hasPrefix:"PREFIX_STRING_FOR_ELEMENT"])
//            is element
//            else
            xml = [xml stringByAppendingFormat:@"%@",root];
        }
}
-(NSString *)getXML
{
    return xml;
}



+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[[XMLWriter alloc]initWithDictionary:dictionary]autorelease];
    return [fromDictionary getXML];
}
+(BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary toStringPath:(NSString *) path  Error:(NSError **)error
{
    
    XMLWriter* fromDictionary = [[[XMLWriter alloc]initWithDictionary:dictionary]autorelease];
    [[fromDictionary getXML] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
    if (error)
        return FALSE;
    else
        return TRUE;
    
}
@end