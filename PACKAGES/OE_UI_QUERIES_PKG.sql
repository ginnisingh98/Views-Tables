--------------------------------------------------------
--  DDL for Package OE_UI_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UI_QUERIES_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVUIQS.pls 120.1 2005/09/06 14:44:43 jvicenti noship $ */
procedure INSERT_ROW (
  X_QUERY_ID in NUMBER,
  X_PUBLIC_FLAG in VARCHAR2,
  X_LINES_WHERE_CLAUSE in VARCHAR2,
  X_HEADERS_WHERE_CLAUSE in VARCHAR2,
  X_ADV_HDR_WHERE_CLAUSE in VARCHAR2,
  X_ADV_LIN_WHERE_CLAUSE in VARCHAR2,
  X_HOLDS_WHERE_CLAUSE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ACCESS_TYPE in VARCHAR2 default NULL,
  X_ORG_ID in NUMBER default NULL);
procedure LOCK_ROW (
  X_QUERY_ID in NUMBER,
  X_PUBLIC_FLAG in VARCHAR2 DEFAULT NULL,
  X_NAME in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_QUERY_ID in NUMBER,
  X_DELETE_FLAG in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_QUERY_ID in NUMBER
);
TYPE UI_TREE_REC  IS RECORD
  (
   COLUMN_NAME     VARCHAR2(4000),
   COLUMN_VALUE    VARCHAR2(4000),
   COLUMN_TYPE     VARCHAR2(4000),
   COLUMN_INDEX_ID NUMBER
   );

TYPE UI_TREE_TBL IS TABLE OF UI_TREE_REC
INDEX BY BINARY_INTEGER;

G_MISS_UI_TREE_TBL UI_TREE_TBL;

procedure INSERT_COLUMNS(
  p_header_column_tbl IN UI_TREE_TBL,
  p_query_id          IN Number
);
procedure INSERT_ROW_COLUMNS(
  p_column_name IN varchar2,
  p_column_value  IN varchar2,
  p_column_data_type   IN varchar2,
  p_column_index_id   IN  number ,
  p_query_id   IN  number
);
procedure ADD_LANGUAGE;
end OE_UI_QUERIES_PKG;

 

/
