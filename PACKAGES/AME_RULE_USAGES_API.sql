--------------------------------------------------------
--  DDL for Package AME_RULE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_USAGES_API" AUTHID CURRENT_USER AS
/* $Header: ameruapi.pkh 120.0 2005/07/26 06:06:39 mbocutt noship $ */

procedure INSERT_ROW (
  X_ITEM_ID                         in NUMBER,
  X_RULE_ID                         in NUMBER,
  X_APPROVER_CATEGORY               in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure DELETE_ROW (
  X_ITEM_ID                         in NUMBER,
  X_RULE_ID                         in NUMBER
);

procedure LOAD_ROW (
  X_RULE_ID                         in VARCHAR2,
  X_APPLICATION_SHORT_NAME          in VARCHAR2,
  X_TRANSACTION_TYPE_ID             in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2);

END AME_RULE_USAGES_API;

 

/
