--------------------------------------------------------
--  DDL for Package AME_APPROVAL_GROUP_CONFIG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVAL_GROUP_CONFIG_API" AUTHID CURRENT_USER AS
/* $Header: amegcapi.pkh 120.0 2005/09/02 03:57 mbocutt noship $ */

procedure INSERT_ROW (
 X_APPLICATION_ID                  in NUMBER,
 X_APPROVAL_GROUP_ID               in NUMBER,
 X_VOTING_REGIME                   in VARCHAR2,
 X_ORDER_NUMBER                    in NUMBER,
 X_CREATED_BY                      in NUMBER,
 X_CREATION_DATE                   in DATE,
 X_LAST_UPDATED_BY                 in NUMBER,
 X_LAST_UPDATE_DATE                in DATE,
 X_LAST_UPDATE_LOGIN               in NUMBER,
 X_START_DATE                      in DATE,
 X_OBJECT_VERSION_NUMBER           in NUMBER);

procedure UPDATE_ROW (
 X_CONFIG_ROWID                    in VARCHAR2,
 X_END_DATE                        in DATE);

procedure DELETE_ROW (
  X_APPLICATION_ID                 in NUMBER,
  X_APPROVAL_GROUP_ID              in NUMBER);

procedure LOAD_ROW (
  X_APPLICATION_NAME               in VARCHAR2,
  X_APPROVAL_GROUP_NAME            in VARCHAR2,
  X_VOTING_REGIME                  in VARCHAR2,
  X_ORDER_NUMBER                   in VARCHAR2,
  X_OWNER                          in VARCHAR2,
  X_LAST_UPDATE_DATE               in VARCHAR2,
  X_CUSTOM_MODE                    in VARCHAR2);

END AME_APPROVAL_GROUP_CONFIG_API;

 

/
