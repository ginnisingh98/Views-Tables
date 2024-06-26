--------------------------------------------------------
--  DDL for Package PA_STATUS_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_STATUS_LISTS_PKG" AUTHID CURRENT_USER as
/* $Header: PACISLTS.pls 120.0 2005/05/29 10:54:10 appldev noship $ */
procedure INSERT_ROW (
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_LIST_ID in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE DEFAULT SYSDATE,
  X_CREATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_global.login_id);
procedure LOCK_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
  );
procedure UPDATE_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_STATUS_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_global.user_id,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_global.login_id
);
procedure DELETE_ROW (
  X_STATUS_LIST_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER
);
end PA_STATUS_LISTS_PKG;

 

/
