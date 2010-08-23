//
//  DistrictMapObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/21/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DistrictOfficeObj;
@class LegislatorObj;

@interface DistrictMapObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * chamber;
@property (nonatomic, retain) NSNumber * centerLon;
@property (nonatomic, retain) NSNumber * spanLat;
@property (nonatomic, retain) NSNumber * lineWidth;
@property (nonatomic, retain) NSData * coordinatesData;
@property (nonatomic, retain) NSNumber * numberOfCoords;
@property (nonatomic, retain) NSNumber * maxLat;
@property (nonatomic, retain) NSNumber * minLat;
@property (nonatomic, retain) NSNumber * spanLon;
@property (nonatomic, retain) NSNumber * maxLon;
@property (nonatomic, retain) NSNumber * district;
@property (nonatomic, retain) id lineColor;
@property (nonatomic, retain) NSNumber * minLon;
@property (nonatomic, retain) NSNumber * centerLat;
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) DistrictOfficeObj * districtOffice;

@end


