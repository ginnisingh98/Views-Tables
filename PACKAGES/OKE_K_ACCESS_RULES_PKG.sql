--------------------------------------------------------
--  DDL for Package OKE_K_ACCESS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_ACCESS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: OKEKACRS.pls 120.1 2005/06/02 12:01:12 appldev  $ */
procedure INSERT_ROW (
  X_ROWID                   IN OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
  X_ACCESS_RULE_ID          IN OUT NOCOPY /* file.sql.39 change */    NUMBER,
  X_CREATION_DATE           in        DATE,
  X_CREATED_BY              in        NUMBER,
  X_LAST_UPDATE_DATE        in        DATE,
  X_LAST_UPDATED_BY         in        NUMBER,
  X_LAST_UPDATE_LOGIN       in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
);

procedure LOCK_ROW (
  X_ACCESS_RULE_ID          in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
);

procedure UPDATE_ROW (
  X_ACCESS_RULE_ID          in        NUMBER,
  X_LAST_UPDATE_DATE        in        DATE,
  X_LAST_UPDATED_BY         in        NUMBER,
  X_LAST_UPDATE_LOGIN       in        NUMBER,
  X_ROLE_ID                 in        NUMBER,
  X_SECURED_OBJECT_NAME     in        VARCHAR2,
  X_ATTRIBUTE_GROUP_TYPE    in        VARCHAR2,
  X_ATTRIBUTE_GROUP_CODE    in        VARCHAR2,
  X_ATTRIBUTE_CODE          in        VARCHAR2,
  X_ACCESS_LEVEL            in        VARCHAR2
);

procedure DELETE_ROW (
  X_ACCESS_RULE_ID          in        NUMBER
);

procedure DELETE_ALL (
  X_ROLE_ID                 in        NUMBER
);

end OKE_K_ACCESS_RULES_PKG;

 

/
