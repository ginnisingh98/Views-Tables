--------------------------------------------------------
--  DDL for Package CSD_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: csdtrles.pls 120.0.12010000.1 2008/12/11 01:06:09 swai noship $ */

procedure INSERT_ROW (
  PX_ROWID            in out nocopy VARCHAR2,
  PX_RULE_ID          in out nocopy NUMBER,
  P_OBJECT_VERSION_NUMBER        in NUMBER,
  P_CREATION_DATE                in DATE,
  P_CREATED_BY                   in NUMBER,
  P_LAST_UPDATE_DATE             in DATE,
  P_LAST_UPDATED_BY              in NUMBER,
  P_LAST_UPDATE_LOGIN            in NUMBER,
  P_NAME                         in VARCHAR2,
  P_DESCRIPTION                  in VARCHAR2,
  P_RULE_TYPE_CODE               in VARCHAR2,
  P_PRECEDENCE                   in NUMBER,
  P_ENTITY_ATTRIBUTE_TYPE        in VARCHAR2,
  P_ENTITY_ATTRIBUTE_CODE        in VARCHAR2,
  P_VALUE_TYPE_CODE              in VARCHAR2,
  P_ATTRIBUTE_CATEGORY           in VARCHAR2,
  P_ATTRIBUTE1                   in VARCHAR2,
  P_ATTRIBUTE2                   in VARCHAR2,
  P_ATTRIBUTE3                   in VARCHAR2,
  P_ATTRIBUTE4                   in VARCHAR2,
  P_ATTRIBUTE5                   in VARCHAR2,
  P_ATTRIBUTE6                   in VARCHAR2,
  P_ATTRIBUTE7                   in VARCHAR2,
  P_ATTRIBUTE8                   in VARCHAR2,
  P_ATTRIBUTE9                   in VARCHAR2,
  P_ATTRIBUTE10                  in VARCHAR2,
  P_ATTRIBUTE11                  in VARCHAR2,
  P_ATTRIBUTE12                  in VARCHAR2,
  P_ATTRIBUTE13                  in VARCHAR2,
  P_ATTRIBUTE14                  in VARCHAR2,
  P_ATTRIBUTE15                  in VARCHAR2
);



procedure LOCK_ROW (
  P_RULE_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  P_RULE_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER        in NUMBER,
  P_CREATION_DATE                in DATE,
  P_CREATED_BY                   in NUMBER,
  P_LAST_UPDATE_DATE             in DATE,
  P_LAST_UPDATED_BY              in NUMBER,
  P_LAST_UPDATE_LOGIN            in NUMBER,
  P_NAME                         in VARCHAR2,
  P_DESCRIPTION                  in VARCHAR2,
  P_RULE_TYPE_CODE               in VARCHAR2,
  P_PRECEDENCE                   in NUMBER,
  P_ENTITY_ATTRIBUTE_TYPE        in VARCHAR2,
  P_ENTITY_ATTRIBUTE_CODE        in VARCHAR2,
  P_VALUE_TYPE_CODE              in VARCHAR2,
  P_ATTRIBUTE_CATEGORY           in VARCHAR2,
  P_ATTRIBUTE1                   in VARCHAR2,
  P_ATTRIBUTE2                   in VARCHAR2,
  P_ATTRIBUTE3                   in VARCHAR2,
  P_ATTRIBUTE4                   in VARCHAR2,
  P_ATTRIBUTE5                   in VARCHAR2,
  P_ATTRIBUTE6                   in VARCHAR2,
  P_ATTRIBUTE7                   in VARCHAR2,
  P_ATTRIBUTE8                   in VARCHAR2,
  P_ATTRIBUTE9                   in VARCHAR2,
  P_ATTRIBUTE10                  in VARCHAR2,
  P_ATTRIBUTE11                  in VARCHAR2,
  P_ATTRIBUTE12                  in VARCHAR2,
  P_ATTRIBUTE13                  in VARCHAR2,
  P_ATTRIBUTE14                  in VARCHAR2,
  P_ATTRIBUTE15                  in VARCHAR2
);

procedure DELETE_ROW (
  P_RULE_ID in NUMBER
);

procedure ADD_LANGUAGE;

end CSD_RULES_PKG;

/
