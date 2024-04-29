--------------------------------------------------------
--  DDL for Package AME_CONDITIONS_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITIONS_API2" AUTHID CURRENT_USER AS
/* $Header: amecnapi.pkh 120.0 2005/07/26 05:54 mbocutt noship $ */

procedure INSERT_ROW (
  X_CONDITION_KEY                   in VARCHAR2,
  X_CONDITION_TYPE                  in VARCHAR2,
  X_ATTRIBUTE_ID                    in NUMBER,
  X_PARAMETER_ONE                   in VARCHAR2,
  X_PARAMETER_TWO                   in VARCHAR2,
  X_PARAMETER_THREE                 in VARCHAR2,
  X_INCLUDE_UPPER_LIMIT             in VARCHAR2,
  X_INCLUDE_LOWER_LIMIT             in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure INSERT_ROW_2 (
  X_CONDITION_ID                    in NUMBER,
  X_CONDITION_KEY                   in VARCHAR2,
  X_CONDITION_TYPE                  in VARCHAR2,
  X_ATTRIBUTE_ID                    in NUMBER,
  X_PARAMETER_ONE                   in VARCHAR2,
  X_PARAMETER_TWO                   in VARCHAR2,
  X_PARAMETER_THREE                 in VARCHAR2,
  X_INCLUDE_UPPER_LIMIT             in VARCHAR2,
  X_INCLUDE_LOWER_LIMIT             in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);
procedure DELETE_ROW (
  X_CONDITION_KEY                   in VARCHAR2);
procedure LOAD_ROW (
  X_CONDITION_KEY                   in VARCHAR2,
  X_CONDITION_ID                    in VARCHAR2,
  X_CONDITION_TYPE                  in VARCHAR2,
  X_ATTRIBUTE_NAME                  in VARCHAR2,
  X_PARAMETER_ONE                   in VARCHAR2,
  X_PARAMETER_TWO                   in VARCHAR2,
  X_PARAMETER_THREE                 in VARCHAR2,
  X_INCLUDE_UPPER_LIMIT             in VARCHAR2,
  X_INCLUDE_LOWER_LIMIT             in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

END AME_CONDITIONS_API2;

 

/
