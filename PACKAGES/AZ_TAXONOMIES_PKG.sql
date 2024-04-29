--------------------------------------------------------
--  DDL for Package AZ_TAXONOMIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_TAXONOMIES_PKG" AUTHID CURRENT_USER as
/* $Header: azttaxonomys.pls 120.2 2008/03/26 11:31:19 hboda noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TAXONOMY_NAME in VARCHAR2,
  X_TAXONOMY_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);


procedure UPDATE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_TAXONOMY_NAME in VARCHAR2,
  X_TAXONOMY_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_TAXONOMY_CODE in VARCHAR2,
  X_USER_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
        X_TAXONOMY_CODE    in   VARCHAR2,
        X_USER_ID               in   NUMBER,
        X_OWNER                 in   VARCHAR2,
        X_TAXONOMY_NAME    in   VARCHAR2,
        X_TAXONOMY_DESC    in   VARCHAR2
);

procedure LOAD_ROW (
        X_TAXONOMY_CODE    in   VARCHAR2,
        X_USER_ID               in   NUMBER,
        X_OWNER                 in   VARCHAR2,
        X_ENABLED_FLAG        in   VARCHAR2,
        X_TAXONOMY_NAME    in   VARCHAR2,
        X_TAXONOMY_DESC    in   VARCHAR2
);


end AZ_TAXONOMIES_PKG;

/
