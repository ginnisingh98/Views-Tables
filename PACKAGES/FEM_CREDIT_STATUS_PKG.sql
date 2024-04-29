--------------------------------------------------------
--  DDL for Package FEM_CREDIT_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_CREDIT_STATUS_PKG" AUTHID CURRENT_USER as
/* $Header: fem_crdstat_pkh.pls 120.0 2005/06/06 19:03:00 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CREDIT_STATUS_ID in NUMBER,
  X_CREDIT_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREDIT_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_CREDIT_STATUS_ID in NUMBER,
  X_CREDIT_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREDIT_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_CREDIT_STATUS_ID in NUMBER,
  X_CREDIT_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREDIT_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CREDIT_STATUS_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_CREDIT_STATUS_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_CREDIT_STATUS_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2);


end FEM_CREDIT_STATUS_PKG;

 

/
