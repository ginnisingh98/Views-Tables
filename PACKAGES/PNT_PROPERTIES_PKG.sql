--------------------------------------------------------
--  DDL for Package PNT_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_PROPERTIES_PKG" AUTHID CURRENT_USER as
/* $Header: PNTPROPS.pls 120.1 2005/07/26 06:27:35 appldev ship $ */


PROCEDURE check_unique_property_code (
                            x_return_status            IN OUT NOCOPY VARCHAR2,
                            x_property_id                     NUMBER,
                            x_property_code                   VARCHAR2,
                            x_org_id                          NUMBER
                            );


procedure INSERT_ROW (
                       X_ORG_ID                                NUMBER DEFAULT NULL,
                       X_ROWID                       in out NOCOPY    VARCHAR2,
                       X_PROPERTY_ID                 in out NOCOPY    NUMBER,
                       X_LAST_UPDATE_DATE                      DATE,
                       X_LAST_UPDATED_BY                       NUMBER,
                       X_CREATION_DATE                         DATE,
                       X_CREATED_BY                            NUMBER,
                       X_LAST_UPDATE_LOGIN                     NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
);



procedure LOCK_ROW (
                       X_PROPERTY_ID                           NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
);

procedure UPDATE_ROW (
                       X_PROPERTY_ID                           NUMBER,
                       X_LAST_UPDATE_DATE                      DATE,
                       X_LAST_UPDATED_BY                       NUMBER,
                       X_LAST_UPDATE_LOGIN                     NUMBER,
                       X_PROPERTY_NAME                         VARCHAR2,
                       X_PROPERTY_CODE                         VARCHAR2,
                       X_LOCATION_PARK_ID                      NUMBER,
                       X_ZONE                                  VARCHAR2,
                       X_DISTRICT                              VARCHAR2,
                       X_COUNTRY                               VARCHAR2,
                       X_DESCRIPTION                           VARCHAR2,
                       X_PORTFOLIO                             VARCHAR2,
                       X_TENURE                                VARCHAR2,
                       X_CLASS                                 VARCHAR2,
                       X_PROPERTY_STATUS                       VARCHAR2,
                       X_CONDITION                             VARCHAR2,
                       X_ACTIVE_PROPERTY                       VARCHAR2,
                       X_ATTRIBUTE_CATEGORY                    VARCHAR2,
                       X_ATTRIBUTE1                            VARCHAR2,
                       X_ATTRIBUTE2                            VARCHAR2,
                       X_ATTRIBUTE3                            VARCHAR2,
                       X_ATTRIBUTE4                            VARCHAR2,
                       X_ATTRIBUTE5                            VARCHAR2,
                       X_ATTRIBUTE6                            VARCHAR2,
                       X_ATTRIBUTE7                            VARCHAR2,
                       X_ATTRIBUTE8                            VARCHAR2,
                       X_ATTRIBUTE9                            VARCHAR2,
                       X_ATTRIBUTE10                           VARCHAR2,
                       X_ATTRIBUTE11                           VARCHAR2,
                       X_ATTRIBUTE12                           VARCHAR2,
                       X_ATTRIBUTE13                           VARCHAR2,
                       X_ATTRIBUTE14                           VARCHAR2,
                       X_ATTRIBUTE15                           VARCHAR2
);

end PNT_PROPERTIES_PKG;

 

/
