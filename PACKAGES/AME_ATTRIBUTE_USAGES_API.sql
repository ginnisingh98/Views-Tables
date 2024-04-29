--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_USAGES_API" AUTHID CURRENT_USER AS
/* $Header: ameauapi.pkh 120.0 2005/07/26 05:54:01 mbocutt noship $ */

procedure INSERT_ROW (
 X_ATTRIBUTE_ID                    in NUMBER,
 X_APPLICATION_ID                  in NUMBER,
 X_QUERY_STRING                    in VARCHAR2,
 X_USE_COUNT                       in NUMBER,
 X_IS_STATIC                       in VARCHAR2,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_USER_EDITABLE                   in VARCHAR2,
 X_VALUE_SET_ID                    in NUMBER,
 X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
  X_USAGES_ROWID                    in VARCHAR2,
  X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_ATTRIBUTE_ID                    in NUMBER,
  X_APPLICATION_ID                  in NUMBER);

procedure LOAD_ROW (
  X_ATTRIBUTE_NAME                  in VARCHAR2,
  X_APPLICATION_NAME                in VARCHAR2,
  X_QUERY_STRING                    in VARCHAR2,
  X_USER_EDITABLE                   in VARCHAR2,
  X_IS_STATIC                       in VARCHAR2,
  X_USE_COUNT                       in VARCHAR2,
  X_VALUE_SET_NAME                  in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

  procedure LOAD_SEED_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_APPLICATION_NAME       in varchar2
    ,X_QUERY_STRING           in varchar2
    ,X_USER_EDITABLE          in varchar2
    ,X_IS_STATIC              in varchar2
    ,X_USE_COUNT              in varchar2
    ,X_VALUE_SET_NAME         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );
END AME_ATTRIBUTE_USAGES_API;

 

/
