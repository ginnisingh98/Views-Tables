--------------------------------------------------------
--  DDL for Package FEM_FUNC_DIM_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_FUNC_DIM_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: fem_funcds_pkh.pls 120.0 2006/05/08 11:54:20 rflippo noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_FUNC_DIM_SET_ID in NUMBER,
  X_FUNC_DIM_SET_OBJ_DEF_ID in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FUNC_DIM_SET_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_FUNC_DIM_SET_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_FUNC_DIM_SET_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_FUNC_DIM_SET_NAME in varchar2,
        x_custom_mode in varchar2);


end FEM_FUNC_DIM_SETS_PKG;

 

/
