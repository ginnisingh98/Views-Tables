--------------------------------------------------------
--  DDL for Package AME_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTIONS_API" AUTHID CURRENT_USER AS
/* $Header: ameanapi.pkh 120.0.12000000.1 2007/01/17 23:44:19 appldev noship $ */
procedure INSERT_ROW (
  X_ACTION_ID                 in NUMBER,
  X_ACTION_TYPE_ID            in NUMBER,
  X_PARAMETER                 in VARCHAR2,
  X_PARAMETER_TWO             in VARCHAR2,
  X_CREATED_BY                in NUMBER,
  X_CREATION_DATE             in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATE_LOGIN         in NUMBER,
  X_START_DATE                in DATE,
  X_DESCRIPTION               in VARCHAR2,
  X_OBJECT_VERSION_NUMBER     in NUMBER);

procedure UPDATE_ROW (
  X_ACTION_ROWID              in VARCHAR2,
  X_END_DATE                  in DATE);

procedure DELETE_ROW (
  X_ACTION_ID                 in NUMBER);

procedure LOAD_ROW (
  X_ACTION_TYPE_NAME          in VARCHAR2,
  X_PARAMETER                 in VARCHAR2,
  X_PARAMETER_TWO             in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_LAST_UPDATE_DATE          in VARCHAR2,
  X_CUSTOM_MODE               in VARCHAR2);

procedure LOAD_ROW (
  X_ACTION_TYPE_NAME          in VARCHAR2,
  X_PARAMETER                 in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_LAST_UPDATE_DATE          in VARCHAR2,
  X_CUSTOM_MODE               in VARCHAR2);

procedure TRANSLATE_ROW (
  X_ACTION_TYPE_NAME          in VARCHAR2,
  X_PARAMETER                 in VARCHAR2,
  X_PARAMETER_TWO             in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_LAST_UPDATE_DATE          in VARCHAR2,
  X_CUSTOM_MODE               in VARCHAR2);

END AME_ACTIONS_API;

 

/
