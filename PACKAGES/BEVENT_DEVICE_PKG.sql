--------------------------------------------------------
--  DDL for Package BEVENT_DEVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEVENT_DEVICE_PKG" AUTHID CURRENT_USER as
/* $Header: WMSDEVBS.pls 120.0 2005/05/24 18:34:32 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID 			        in out nocopy VARCHAR2,
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_CREATION_DATE 			in DATE,
  X_CREATED_BY 				in NUMBER,
  X_LAST_UPDATE_DATE 			in DATE,
  X_LAST_UPDATED_BY 			in NUMBER,
  X_LAST_UPDATE_LOGIN 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2  );

procedure LOCK_ROW (
  X_ROWID 			        in out nocopy VARCHAR2,
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2  );


procedure UPDATE_ROW (
  X_BUSINESS_EVENT_ID  			in NUMBER,
  X_DEVICE_ID	 			in NUMBER,
  X_LEVEL_TYPE		 		in NUMBER,
  X_LEVEL_VALUE			 	in NUMBER,
  X_ORGANIZATION_ID 			in NUMBER,
  X_SUBINVENTORY_CODE			in VARCHAR2,
  X_AUTO_ENABLED_FLAG                   in VARCHAR2,
  X_COMMENTS                            in VARCHAR2,
  X_ENABLED_FLAG                        in VARCHAR2,
  X_LAST_UPDATE_DATE 			in DATE,
  X_LAST_UPDATED_BY 			in NUMBER,
  X_LAST_UPDATE_LOGIN 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2,
  x_verification_required               IN VARCHAR2);


procedure DELETE_ROW (
 X_BUSINESS_EVENT_ID 			in NUMBER,
 X_DEVICE_ID 				in NUMBER,
 X_ORGANIZATION_ID 			in NUMBER,
 X_LEVEL_TYPE				in number,
 X_LEVEL_VALUE				in number,
 X_SUBINVENTORY_CODE			in varchar);

end BEVENT_DEVICE_PKG ;
 

/
