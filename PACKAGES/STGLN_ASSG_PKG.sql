--------------------------------------------------------
--  DDL for Package STGLN_ASSG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."STGLN_ASSG_PKG" AUTHID CURRENT_USER as
/* $Header: WMSDSLNS.pls 120.1 2005/06/20 05:40:39 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID 			        IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID 			in NUMBER,
  X_STAGE_LANE_ID 			in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID 		in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID 	in NUMBER,
  X_ENTRY_SEQUENCE 			in NUMBER,
  X_ENABLED 				in VARCHAR2,
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
  X_ATTRIBUTE15 			in VARCHAR2);

procedure LOCK_ROW (
  X_ROWID                               IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID                        in NUMBER,
  X_STAGE_LANE_ID                       in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID           in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID        in NUMBER,
  X_ENTRY_SEQUENCE                      in NUMBER,
  X_ENABLED                             in VARCHAR2,
  X_CREATION_DATE                       in DATE,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2);

procedure UPDATE_ROW (
  X_ROWID                               IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_DOCK_DOOR_ID                        in NUMBER,
  X_STAGE_LANE_ID                       in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID           in NUMBER,
  X_STAGING_LANE_ORGANIZATION_ID        in NUMBER,
  X_ENTRY_SEQUENCE                      in NUMBER,
  X_ENABLED                             in VARCHAR2,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2);

procedure DELETE_ROW (
  X_DOCK_DOOR_ID 			in NUMBER,
  X_DOCK_DOOR_ORGANIZATION_ID 		in NUMBER,
  X_ENTRY_SEQUENCE 			in NUMBER );

end STGLN_ASSG_PKG ;
 

/
