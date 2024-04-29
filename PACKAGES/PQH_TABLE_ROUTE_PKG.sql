--------------------------------------------------------
--  DDL for Package PQH_TABLE_ROUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TABLE_ROUTE_PKG" AUTHID CURRENT_USER as
  /* $Header: pqtrtpkg.pkh 120.2 2005/10/12 20:20:34 srajakum noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_MAP_REQUIRED_FLAG in VARCHAR2,
  X_SELECT_ALLOWED_FLAG in VARCHAR2,
  X_HIDE_TABLE_FOR_VIEW_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_TABLE_ROUTE_ID in NUMBER,
  X_SHADOW_TABLE_ROUTE_ID in NUMBER,
  X_FROM_CLAUSE in VARCHAR2,
  X_TABLE_ALIAS in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_MAP_REQUIRED_FLAG in VARCHAR2,
  X_SELECT_ALLOWED_FLAG in VARCHAR2,
  X_HIDE_TABLE_FOR_VIEW_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_TABLE_ROUTE_ID in NUMBER
);

procedure ADD_LANGUAGE;


procedure LOAD_ROW (
  p_table_alias              IN VARCHAR2,
  p_shadow_table             IN VARCHAR2,
  p_from_clause              IN VARCHAR2,
  p_where_clause             IN VARCHAR2,
  p_display_name             IN VARCHAR2,
  p_map_required_flag        IN VARCHAR2,
  p_select_allowed_flag      IN VARCHAR2,
  p_hide_table_for_view_flag IN VARCHAR2,
  p_display_order            IN NUMBER,
  p_last_update_date         IN VARCHAR2,
  p_owner                    IN VARCHAR2
);


procedure TRANSLATE_ROW (
    p_table_alias               in varchar2,
    p_display_name              in varchar2,
    p_owner                     in varchar2);
--

procedure LOAD_SEED_ROW (
  p_upload_mode              IN VARCHAR2,
  p_table_alias              IN VARCHAR2,
  p_shadow_table             IN VARCHAR2,
  p_from_clause              IN VARCHAR2,
  p_where_clause             IN VARCHAR2,
  p_display_name             IN VARCHAR2,
  p_map_required_flag        IN VARCHAR2,
  p_select_allowed_flag      IN VARCHAR2,
  p_hide_table_for_view_flag IN VARCHAR2,
  p_display_order            IN NUMBER,
  p_last_update_date         IN VARCHAR2,
  p_owner                    IN VARCHAR2
);

end PQH_TABLE_ROUTE_PKG;


 

/
