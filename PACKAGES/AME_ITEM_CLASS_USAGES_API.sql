--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_USAGES_API" AUTHID CURRENT_USER AS
/* $Header: ameiuapi.pkh 120.0 2005/07/26 06:00 mbocutt noship $ */

procedure INSERT_ROW (
  X_ITEM_CLASS_ID                   in NUMBER,
  X_APPLICATION_ID                  in NUMBER,
  X_ITEM_ID_QUERY                   in VARCHAR2,
  X_ITEM_CLASS_ORDER_NUMBER         in NUMBER,
  X_ITEM_CLASS_PAR_MODE             in VARCHAR2,
  X_ITEM_CLASS_SUBLIST_MODE         in VARCHAR2,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
  X_USAGES_ROWID                    in VARCHAR2,
  X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_ITEM_CLASS_ID                   in NUMBER,
  X_APPLICATION_ID                  in NUMBER);

procedure LOAD_ROW (
  X_ITEM_CLASS_NAME                 in VARCHAR2,
  X_APPLICATION_NAME                in VARCHAR2,
  X_ITEM_ID_QUERY                   in VARCHAR2,
  X_ITEM_CLASS_ORDER_NUMBER         in VARCHAR2,
  X_ITEM_CLASS_PAR_MODE             in VARCHAR2,
  X_ITEM_CLASS_SUBLIST_MODE         in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

END AME_ITEM_CLASS_USAGES_API;

 

/
