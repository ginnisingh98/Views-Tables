--------------------------------------------------------
--  DDL for Package AME_APPROVAL_GROUPS_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVAL_GROUPS_LOAD_API" AUTHID CURRENT_USER AS
/* $Header: ameagapi.pkh 120.0 2005/07/26 05:52:58 mbocutt noship $ */

procedure INSERT_ROW (X_NAME                    in     VARCHAR2
                     ,X_QUERY_STRING            in     VARCHAR2
                     ,X_IS_STATIC               in     VARCHAR2
                     ,X_DESCRIPTION             in     VARCHAR2
                     ,X_CREATED_BY              in     NUMBER
                     ,X_CREATION_DATE           in     DATE
                     ,X_LAST_UPDATED_BY         in     NUMBER
                     ,X_LAST_UPDATE_DATE        in     DATE
                     ,X_LAST_UPDATE_LOGIN       in     NUMBER
                     ,X_START_DATE              in     DATE
                     ,X_OBJECT_VERSION_NUMBER   in     NUMBER
                     ,X_APPROVAL_GROUP_ID       in out nocopy NUMBER
                     );

procedure UPDATE_ROW (X_APPROVAL_GROUP_ROWID in VARCHAR2
                     ,X_END_DATE             in DATE
                     ,X_APPROVAL_GROUP_ID    in NUMBER
                     ,X_NAME                 in VARCHAR2
                     ,X_QUERY_STRING         in VARCHAR2
                     ,X_IS_STATIC            in VARCHAR2
                     ,X_CREATED_BY           in NUMBER
                     ,X_CREATION_DATE        in DATE
                     ,X_LAST_UPDATED_BY      in NUMBER
                     ,X_LAST_UPDATE_DATE     in DATE
                     ,X_LAST_UPDATE_LOGIN    in NUMBER
                     ,X_START_DATE           in DATE
                     ,X_DESCRIPTION          in VARCHAR2
                     ,X_OBJECT_VERSION_NUMBER in NUMBER
                     );

procedure DELETE_ROW (X_APPROVAL_GROUP_ID in NUMBER
                     );

procedure LOAD_ROW(X_APPROVAL_GROUP_NAME  in VARCHAR2
                  ,X_USER_APPROVAL_GROUP_NAME in VARCHAR2
                  ,X_DESCRIPTION          in VARCHAR2
                  ,X_QUERY_STRING         in VARCHAR2
                  ,X_IS_STATIC            in VARCHAR2
                  ,X_OWNER                in VARCHAR2
                  ,X_LAST_UPDATE_DATE     in VARCHAR2
                  ,X_CUSTOM_MODE          in VARCHAR2
                  );

  procedure TRANSLATE_ROW
    (X_APPROVAL_GROUP_NAME      in VARCHAR2
    ,X_USER_APPROVAL_GROUP_NAME in VARCHAR2
    ,X_DESCRIPTION              in VARCHAR2
    ,X_OWNER                    in varchar2
    ,X_LAST_UPDATE_DATE         in varchar2
    ,X_CUSTOM_MODE              in varchar2
    );

END AME_APPROVAL_GROUPS_LOAD_API;

 

/
