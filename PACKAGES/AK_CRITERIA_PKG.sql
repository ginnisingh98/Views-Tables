--------------------------------------------------------
--  DDL for Package AK_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CRITERIA_PKG" AUTHID CURRENT_USER as
/* $Header: AKCRTRAS.pls 120.2 2005/09/29 13:59:30 tshort noship $ */
procedure INSERT_ROW (
X_ROWID                        in out NOCOPY VARCHAR2,
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in     NUMBER,
X_ATTRIBUTE_CODE               in     VARCHAR2,
X_SEQUENCE_NUMBER              in     NUMBER,
X_OPERATION                    in     VARCHAR2,
X_VALUE_VARCHAR2               in     VARCHAR2,
X_VALUE_NUMBER                 in     NUMBER,
X_VALUE_DATE                   in     DATE,
X_CREATED_BY                   in     NUMBER,
X_CREATION_DATE                in     DATE,
X_LAST_UPDATED_BY              in     NUMBER,
X_LAST_UPDATE_DATE             in     DATE,
X_LAST_UPDATE_LOGIN            in     NUMBER,
X_START_DATE_ACTIVE            in     DATE,
X_END_DATE_ACTIVE              in     DATE
);

procedure LOCK_ROW (
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in     NUMBER,
X_ATTRIBUTE_CODE               in     VARCHAR2,
X_SEQUENCE_NUMBER              in     NUMBER,
X_OPERATION                    in     VARCHAR2,
X_VALUE_VARCHAR2               in     VARCHAR2,
X_VALUE_NUMBER                 in     NUMBER,
X_VALUE_DATE                   in     DATE,
X_CREATED_BY                   in     NUMBER,
X_CREATION_DATE                in     DATE,
X_LAST_UPDATED_BY              in     NUMBER,
X_LAST_UPDATE_DATE             in     DATE,
X_LAST_UPDATE_LOGIN            in     NUMBER,
X_START_DATE_ACTIVE            in     DATE,
X_END_DATE_ACTIVE              in     DATE
);

procedure UPDATE_ROW (
X_CUSTOMIZATION_APPLICATION_ID in NUMBER,
X_CUSTOMIZATION_CODE           in VARCHAR2,
X_REGION_APPLICATION_ID        in NUMBER,
X_REGION_CODE                  in VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in NUMBER,
X_ATTRIBUTE_CODE               in VARCHAR2,
X_SEQUENCE_NUMBER              in NUMBER,
X_OPERATION                    in VARCHAR2,
X_VALUE_VARCHAR2               in VARCHAR2,
X_VALUE_NUMBER                 in NUMBER,
X_VALUE_DATE                   in DATE,
X_LAST_UPDATED_BY              in NUMBER,
X_LAST_UPDATE_DATE             in DATE,
X_LAST_UPDATE_LOGIN            in NUMBER,
X_START_DATE_ACTIVE            in DATE,
X_END_DATE_ACTIVE              in DATE
);

procedure DELETE_ROW (
X_CUSTOMIZATION_APPLICATION_ID in NUMBER,
X_CUSTOMIZATION_CODE           in VARCHAR2,
X_REGION_APPLICATION_ID        in NUMBER,
X_REGION_CODE                  in VARCHAR2,
X_ATTRIBUTE_APPLICATION_ID     in NUMBER,
X_ATTRIBUTE_CODE               in VARCHAR2,
X_SEQUENCE_NUMBER              in NUMBER
);

end AK_CRITERIA_PKG;

 

/
