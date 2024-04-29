--------------------------------------------------------
--  DDL for Package AME_MAN_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MAN_ATTRIBUTES_API" AUTHID CURRENT_USER AS
/* $Header: amemaapi.pkh 120.0 2005/07/26 06:03:42 mbocutt noship $ */

procedure INSERT_ROW (
  X_ATTRIBUTE_ID                    in NUMBER,
  X_ACTION_TYPE_ID                  in NUMBER,
  X_CREATED_BY                      in NUMBER,
  X_CREATION_DATE                   in DATE,
  X_LAST_UPDATED_BY                 in NUMBER,
  X_LAST_UPDATE_DATE                in DATE,
  X_LAST_UPDATE_LOGIN               in NUMBER,
  X_START_DATE                      in DATE,
  X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
  X_MAN_ATTRIBUTE_ROWID             in VARCHAR2,
  X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_ATTRIBUTE_ID                    in NUMBER,
  X_ACTION_TYPE_ID                  in NUMBER
);

procedure LOAD_ROW (
  X_ATTRIBUTE_NAME                  in VARCHAR2,
  X_ACTION_TYPE_NAME                in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);

procedure LOAD_SEED_ROW (
  X_ATTRIBUTE_NAME                  in VARCHAR2,
  X_ACTION_TYPE_NAME                in VARCHAR2,
  X_OWNER                           in VARCHAR2,
  X_LAST_UPDATE_DATE                in VARCHAR2,
  X_UPLOAD_MODE                     in VARCHAR2,
  X_CUSTOM_MODE                     in VARCHAR2);
END AME_MAN_ATTRIBUTES_API;

 

/
