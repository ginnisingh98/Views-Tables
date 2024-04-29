--------------------------------------------------------
--  DDL for Package AME_STRING_VALUES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_STRING_VALUES_API2" AUTHID CURRENT_USER AS
/* $Header: amesaapi.pkh 120.0 2005/07/26 06:06 mbocutt noship $ */

procedure INSERT_ROW (
  X_CONDITION_ID                    in NUMBER,
  X_STRING_VALUE                    in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure DELETE_ROW (
  X_CONDITION_ID                    in NUMBER);

procedure LOAD_ROW (
  X_CONDITION_KEY                   in VARCHAR2,
  X_CONDITION_ID                    in VARCHAR2,
  X_STRING_VALUE                    in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

END AME_STRING_VALUES_API2;

 

/
