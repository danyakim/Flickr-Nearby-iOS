//
//  FKFlickrFavoritesGetList.m
//  FlickrKit
//
//  Generated by FKAPIBuilder.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrFavoritesGetList.h" 

@implementation FKFlickrFavoritesGetList



- (BOOL) needsLogin {
    return NO;
}

- (BOOL) needsSigning {
    return NO;
}

- (FKPermission) requiredPerms {
    return -1;
}

- (NSString *) name {
    return @"flickr.favorites.getList";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.user_id) {
		[args setValue:self.user_id forKey:@"user_id"];
	}
	if(self.min_fave_date) {
		[args setValue:self.min_fave_date forKey:@"min_fave_date"];
	}
	if(self.max_fave_date) {
		[args setValue:self.max_fave_date forKey:@"max_fave_date"];
	}
	if(self.extras) {
		[args setValue:self.extras forKey:@"extras"];
	}
	if(self.per_page) {
		[args setValue:self.per_page forKey:@"per_page"];
	}
	if(self.page) {
		[args setValue:self.page forKey:@"page"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrFavoritesGetListError_UserNotFound:
			return @"User not found";
		case FKFlickrFavoritesGetListError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrFavoritesGetListError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrFavoritesGetListError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrFavoritesGetListError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrFavoritesGetListError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrFavoritesGetListError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrFavoritesGetListError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrFavoritesGetListError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
