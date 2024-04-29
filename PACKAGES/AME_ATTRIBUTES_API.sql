--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTES_API" AUTHID CURRENT_USER as
/* $Header: ameatapi.pkh 120.1.12010000.1 2008/07/28 06:17:12 appldev ship $ */
  procedure INSERT_ROW
    (X_ATTRIBUTE_NAME        in varchar2
    ,X_ATTRIBUTE_TYPE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_LINE_ITEM             in varchar2
    ,X_ITEM_CLASS_ID         in number
    ,X_APPROVER_TYPE_ID      in number
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
    (X_ATTRIBUTE_ID          in number
    ,X_ATTRIBUTE_NAME        in varchar2
    ,X_ATTRIBUTE_TYPE        in varchar2
    ,X_DESCRIPTION           in varchar2
    ,X_LINE_ITEM             in varchar2
    ,X_ITEM_CLASS_ID         in number
    ,X_APPROVER_TYPE_ID      in number
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
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_ATTRIBUTE_TYPE         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_LINE_ITEM              in varchar2
    ,X_ORIG_SYSTEM            in varchar2
    ,X_ITEM_CLASS_NAME        in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );

  procedure TRANSLATE_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    );

  procedure LOAD_SEED_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    ,X_ATTRIBUTE_TYPE         in varchar2
    ,X_DESCRIPTION            in varchar2
    ,X_LINE_ITEM              in varchar2
    ,X_ORIG_SYSTEM            in varchar2
    ,X_ITEM_CLASS_NAME        in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_UPLOAD_MODE            in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );

  procedure DELETE_ROW
    (X_ATTRIBUTE_NAME         in varchar2
    );

end AME_ATTRIBUTES_API;

/
