--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASSES_API" AUTHID CURRENT_USER AS
/* $Header: ameicapi.pkh 120.0 2005/07/26 06:00 mbocutt noship $ */

procedure INSERT_ROW (
  X_ITEM_CLASS_ID                   in NUMBER,
  X_ITEM_CLASS_NAME                 in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
  X_ITEM_CLASS_ROWID                in VARCHAR2,
  X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_ITEM_CLASS_ID                   in NUMBER);

procedure LOAD_ROW (
  X_ITEM_CLASS_NAME                 in VARCHAR2,
  X_USER_ITEM_CLASS_NAME            in VARCHAR2,
  X_ITEM_CLASS_ID                   in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

  procedure TRANSLATE_ROW
    (X_ITEM_CLASS_NAME        in varchar2
    ,X_USER_ITEM_CLASS_NAME   in varchar2
    ,X_OWNER                  in varchar2
    ,X_LAST_UPDATE_DATE       in varchar2
    ,X_CUSTOM_MODE            in varchar2
    );

END AME_ITEM_CLASSES_API;

 

/
