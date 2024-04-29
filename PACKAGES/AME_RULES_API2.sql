--------------------------------------------------------
--  DDL for Package AME_RULES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULES_API2" AUTHID CURRENT_USER AS
/* $Header: amereapi.pkh 120.0 2005/07/26 06:06 mbocutt noship $ */
procedure INSERT_ROW (
  X_RULE_KEY                        in VARCHAR2,
  X_RULE_TYPE                       in NUMBER,
  X_ACTION_ID                       in NUMBER,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_DESCRIPTION                     in VARCHAR2,
  X_ITEM_CLASS_ID                   in NUMBER,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure INSERT_ROW_2 (
 X_RULE_ID                         in NUMBER,
 X_RULE_KEY                        in VARCHAR2,
 X_RULE_TYPE                       in NUMBER,
 X_ACTION_ID                       in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_DESCRIPTION                     in VARCHAR2,
 X_ITEM_CLASS_ID                   in NUMBER,
 X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure DELETE_ROW (
  X_RULE_KEY                        in VARCHAR2);

procedure LOAD_ROW (
  X_RULE_KEY         in VARCHAR2,
  X_RULE_ID          in VARCHAR2,
  X_ACTION_TYPE_NAME in VARCHAR2,
  X_PARAMETER        in VARCHAR2,
  X_RULE_TYPE        in VARCHAR2,
  X_DESCRIPTION      in VARCHAR2,
  X_ITEM_CLASS_NAME  in VARCHAR2,
  X_OWNER            in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE      in VARCHAR2);

procedure TRANSLATE_ROW (
  X_RULE_KEY         in VARCHAR2,
  X_DESCRIPTION      in VARCHAR2,
  X_OWNER            in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE      in VARCHAR2);

END AME_RULES_API2;

 

/
