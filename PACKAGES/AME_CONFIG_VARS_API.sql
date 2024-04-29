--------------------------------------------------------
--  DDL for Package AME_CONFIG_VARS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONFIG_VARS_API" AUTHID CURRENT_USER as
/* $Header: amecvapi.pkh 120.1 2005/08/08 12:33 ubhat noship $ */
  procedure INSERT_ROW
    (X_VARIABLE_NAME         in varchar2
    ,X_USER_CONFIG_VAR_NAME  in varchar2
    ,X_APPLICATION_ID        in number
    ,X_VARIABLE_VALUE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    );

  procedure UPDATE_ROW
    (X_VARIABLE_NAME         in varchar2
    ,X_USER_CONFIG_VAR_NAME  in varchar2
    ,X_APPLICATION_ID        in number
    ,X_VARIABLE_VALUE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    );

  procedure LOAD_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_VARIABLE_VALUE         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );

  procedure TRANSLATE_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    );

  procedure LOAD_SEED_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_SHORT_NAME in varchar2
    ,X_TRANSACTION_TYPE_ID    in varchar2
    ,X_USER_CONFIG_VAR_NAME   in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_VARIABLE_VALUE         in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );

  procedure DELETE_ROW
    (X_VARIABLE_NAME          in varchar2
    ,X_APPLICATION_ID         in number
    );
end AME_CONFIG_VARS_API;

 

/
