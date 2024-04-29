--------------------------------------------------------
--  DDL for Package AK_CUSTOMIZATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_CUSTOMIZATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: AKDCUSTS.pls 120.2 2005/09/29 13:59:38 tshort noship $ */

procedure INSERT_ROW (
X_ROWID                        in out NOCOPY VARCHAR2,
X_CUSTOMIZATION_APPLICATION_ID in     NUMBER,
X_CUSTOMIZATION_CODE           in     VARCHAR2,
X_REGION_APPLICATION_ID        in     NUMBER,
X_REGION_CODE                  in     VARCHAR2,
X_NAME                         in     VARCHAR2,
X_DESCRIPTION                  in     VARCHAR2,
X_VERTICALIZATION_ID           in     VARCHAR2,
X_LOCALIZATION_CODE            in     VARCHAR2,
X_ORG_ID                       in     NUMBER,
X_SITE_ID                      in     NUMBER,
X_RESPONSIBILITY_ID            in     NUMBER,
X_WEB_USER_ID                  in     NUMBER,
X_DEFAULT_CUSTOMIZATION_FLAG   in     VARCHAR2,
X_CUSTOMIZATION_LEVEL_ID       in     NUMBER,
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
X_NAME                         in     VARCHAR2,
X_DESCRIPTION                  in     VARCHAR2,
X_VERTICALIZATION_ID           in     VARCHAR2,
X_LOCALIZATION_CODE            in     VARCHAR2,
X_ORG_ID                       in     NUMBER,
X_SITE_ID                      in     NUMBER,
X_RESPONSIBILITY_ID            in     NUMBER,
X_WEB_USER_ID                  in     NUMBER,
X_DEFAULT_CUSTOMIZATION_FLAG   in     VARCHAR2,
X_CUSTOMIZATION_LEVEL_ID       in     NUMBER,
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
X_NAME                         in VARCHAR2,
X_DESCRIPTION                  in VARCHAR2,
X_VERTICALIZATION_ID           in VARCHAR2,
X_LOCALIZATION_CODE            in VARCHAR2,
X_ORG_ID                       in NUMBER,
X_SITE_ID                      in NUMBER,
X_RESPONSIBILITY_ID            in NUMBER,
X_WEB_USER_ID                  in NUMBER,
X_DEFAULT_CUSTOMIZATION_FLAG   in VARCHAR2,
X_CUSTOMIZATION_LEVEL_ID       in NUMBER,
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
X_REGION_CODE                  in VARCHAR2
);

procedure ADD_LANGUAGE;

end AK_CUSTOMIZATIONS_PKG;

 

/
