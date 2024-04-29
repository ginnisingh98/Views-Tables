--------------------------------------------------------
--  DDL for Package FEM_APPLICATION_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_APPLICATION_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: fem_appgrp_pkh.pls 120.0 2005/06/15 18:23:38 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_GROUP_ID in NUMBER,
  X_APPLICATION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_GROUP_ID in NUMBER,
  X_APPLICATION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_GROUP_ID in NUMBER,
  X_APPLICATION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_GROUP_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_APPLICATION_GROUP_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_APPLICATION_GROUP_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2);


end FEM_APPLICATION_GROUPS_PKG;

 

/
