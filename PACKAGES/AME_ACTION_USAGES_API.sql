--------------------------------------------------------
--  DDL for Package AME_ACTION_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_USAGES_API" AUTHID CURRENT_USER AS
/* $Header: ameusapi.pkh 120.1 2005/07/27 12:23 mbocutt noship $ */

procedure INSERT_ROW (
  X_RULE_ID                         in NUMBER,
  X_ACTION_ID                       in NUMBER,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
  X_ACTION_USAGE_ROWID              in VARCHAR2,
  X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_RULE_ID                         in NUMBER,
  X_ACTION_ID                       in NUMBER
  );

procedure LOAD_ROW (
  X_RULE_KEY                        in VARCHAR2,
  X_ACTION_TYPE_NAME                in VARCHAR2,
  X_PARAMETER                       in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

END AME_ACTION_USAGES_API;

 

/
