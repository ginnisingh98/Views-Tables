--------------------------------------------------------
--  DDL for Package BNE_SIMPLE_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_SIMPLE_QUERY_PKG" AUTHID CURRENT_USER as
/* $Header: bnesimplequerys.pls 120.2 2005/06/29 03:41:02 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2
);

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ID_COL in VARCHAR2,
  X_ID_COL_ALIAS in VARCHAR2,
  X_MEANING_COL in VARCHAR2,
  X_MEANING_COL_ALIAS in VARCHAR2,
  X_DESCRIPTION_COL in VARCHAR2,
  X_DESCRIPTION_COL_ALIAS in VARCHAR2,
  X_ADDITIONAL_COLS in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_ORDER_BY_CLAUSE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_QUERY_CODE in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  x_query_asn             IN VARCHAR2,
  x_query_code            IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_id_col                IN VARCHAR2,
  x_id_col_alias          IN VARCHAR2,
  x_meaning_col           IN VARCHAR2,
  x_meaning_col_alias     IN VARCHAR2,
  x_description_col       IN VARCHAR2,
  x_description_col_alias IN VARCHAR2,
  x_additional_cols       IN VARCHAR2,
  x_object_name           IN VARCHAR2,
  x_additional_where_clause IN VARCHAR2,
  x_order_by_clause       IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);

end BNE_SIMPLE_QUERY_PKG;

 

/