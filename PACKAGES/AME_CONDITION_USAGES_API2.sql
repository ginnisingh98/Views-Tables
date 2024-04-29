--------------------------------------------------------
--  DDL for Package AME_CONDITION_USAGES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_USAGES_API2" AUTHID CURRENT_USER AS
/* $Header: amecgapi.pkh 120.0 2005/07/26 05:54 mbocutt noship $ */

procedure INSERT_ROW (
  X_RULE_ID                         in NUMBER,
  X_CONDITION_ID                    in NUMBER,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure DELETE_ROW (
  X_RULE_ID                         in NUMBER,
  X_CONDITION_ID                    in NUMBER);

procedure LOAD_ROW (
  X_RULE_KEY                        in VARCHAR2,
  X_RULE_ID                         in VARCHAR2,
  X_CONDITION_KEY                   in VARCHAR2,
  X_CONDITION_ID                    in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);
END AME_CONDITION_USAGES_API2;

 

/
