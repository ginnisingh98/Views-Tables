--------------------------------------------------------
--  DDL for Package AME_ACTION_USAGES_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_USAGES_API2" AUTHID CURRENT_USER as
/* $Header: ameasapi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
  procedure INSERT_ROW
    (X_ACTION_ID             in number
    ,X_RULE_ID               in number
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
    (X_ACTION_ID             in number
    ,X_RULE_ID               in number
    ,X_START_DATE            in date
    ,X_END_DATE              in date
    ,X_CREATED_BY            in number
    ,X_CREATION_DATE         in date
    ,X_LAST_UPDATE_DATE      in date
    ,X_LAST_UPDATED_BY       in number
    ,X_LAST_UPDATE_LOGIN     in number
    ,X_OBJECT_VERSION_NUMBER in number
    );

  procedure LOAD_ROW
    (X_RULE_KEY           in varchar2
    ,X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_CUSTOM_MODE        in varchar2
    );

  procedure LOAD_SEED_ROW
    (X_RULE_KEY           in varchar2
    ,X_ACTION_TYPE_NAME   in varchar2
    ,X_PARAMETER          in varchar2
    ,X_PARAMETER_TWO      in varchar2
    ,X_OWNER              in varchar2
    ,X_LAST_UPDATE_DATE   in varchar2
    ,X_UPLOAD_MODE        in varchar2
    ,X_CUSTOM_MODE        in varchar2
    );

end AME_ACTION_USAGES_API2;

 

/
