--------------------------------------------------------
--  DDL for Package AME_CALLING_APPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CALLING_APPS_API" AUTHID CURRENT_USER AS
/* $Header: amecaapi.pkh 120.5 2006/05/26 06:59:07 pvelugul noship $ */

procedure INSERT_ROW (
  X_FND_APPLICATION_ID                in NUMBER,
  X_APPLICATION_NAME                  in VARCHAR2,
  X_TRANSACTION_TYPE_ID               in VARCHAR2,
  X_APPLICATION_ID                    in NUMBER,
  X_CREATED_BY                        in NUMBER,
  X_CREATION_DATE                     in DATE,
  X_LAST_UPDATED_BY                   in NUMBER,
  X_LAST_UPDATE_DATE                  in DATE,
  X_LAST_UPDATE_LOGIN                 in NUMBER,
  X_START_DATE                        in DATE,
  X_LINE_ITEM_ID_QUERY                in VARCHAR2,
  X_OBJECT_VERSION_NUMBER             in NUMBER);

procedure UPDATE_ROW (
  X_CALLING_APPS_ROWID                in VARCHAR2,
  X_END_DATE                          in DATE);

procedure DELETE_ROW (
  X_FND_APPLICATION_ID                in NUMBER,
  X_TRANSACTION_TYPE_ID               in VARCHAR2,
  X_APPLICATION_ID                    in NUMBER);

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME            in VARCHAR2,
  X_TRANSACTION_TYPE_ID               in VARCHAR2,
  X_APPLICATION_NAME                  in VARCHAR2,
  X_BASE_APPLICATION_NAME             in VARCHAR2,
  X_LINE_ITEM_ID_QUERY                in VARCHAR2,
  X_OWNER                             in VARCHAR2,
  X_LAST_UPDATE_DATE                  in VARCHAR2,
  X_CUSTOM_MODE                       in VARCHAR2);

procedure TRANSLATE_ROW
  (X_APPLICATION_SHORT_NAME in varchar2
  ,X_TRANSACTION_TYPE_ID    in varchar2
  ,X_APPLICATION_NAME       in varchar2
  ,X_OWNER                  in varchar2
  ,X_LAST_UPDATE_DATE       in varchar2
  ,X_CUSTOM_MODE            in varchar2
  );

procedure LOAD_SEED_ROW
  (X_APPLICATION_SHORT_NAME in varchar2
  ,X_TRANSACTION_TYPE_ID    in varchar2
  ,X_APPLICATION_NAME       in varchar2
  ,X_BASE_APPLICATION_NAME  in varchar2
  ,X_LINE_ITEM_ID_QUERY     in varchar2
  ,X_OWNER                  in varchar2
  ,X_LAST_UPDATE_DATE       in varchar2
  ,X_UPLOAD_MODE            in varchar2
  ,X_CUSTOM_MODE            in varchar2
  );

END AME_CALLING_APPS_API;

 

/
