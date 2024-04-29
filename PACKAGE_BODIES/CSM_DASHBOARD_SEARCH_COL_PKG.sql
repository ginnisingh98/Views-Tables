--------------------------------------------------------
--  DDL for Package Body CSM_DASHBOARD_SEARCH_COL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_DASHBOARD_SEARCH_COL_PKG" as
/* $Header: csmldscb.pls 120.2 2005/12/05 23:15:38 utekumal noship $ */


--HISTORY
--   Jul 10, 2005  yazhang created.
--   Dec 6 , 2005  SARADHAK updated as table definition is modified.

procedure insert_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2 )
IS

begin

  insert into csm_dashboard_search_cols(
                            column_name,
                            name,
                            lov_vo_name,
                            input_type,
                            display,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY)
                          values (
                            X_column_name,
                            X_name,
                            decode(x_lov_vo_name,FND_API.G_MISS_CHAR, NULL,x_lov_vo_name),
                            decode(x_input_type,FND_API.G_MISS_CHAR, NULL, x_input_type),
                            decode(x_display,FND_API.G_MISS_CHAR, NULL, x_display),
                            SYSDATE,
                            1,
                            SYSDATE,
                            1 );

end insert_row;

procedure update_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2)
IS
begin

  update csm_dashboard_search_cols set
    INPUT_TYPE = x_input_type,
    display = x_display,
    name = x_name,
    lov_vo_name = x_lov_vo_name,
    LAST_UPDATE_DATE=SYSDATE,
    LAST_UPDATED_BY=1
   where COLUMN_NAME = X_COLUMN_NAME;

END UPDATE_ROW;


procedure load_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2,
  x_owner in VARCHAR2)
IS
CURSOR c_exists IS
 SELECT 1
 FROM  CSM_DASHBOARD_SEARCH_COLS
 WHERE COLUMN_NAME=X_COLUMN_NAME;

l_exists NUMBER;

BEGIN

 OPEN c_exists;
 FETCH c_exists INTO l_exists;
 CLOSE c_exists;

 IF l_exists IS NULL THEN
   insert_row (
    x_column_NAME =>x_column_NAME,
    x_name =>x_name,
    x_lov_vo_name =>x_lov_vo_name,
    x_input_type =>x_input_type,
    x_display =>x_display
   );

 ELSE
  UPDATE_ROW (
    x_column_NAME =>x_column_NAME,
    x_name =>x_name,
    x_lov_vo_name =>x_lov_vo_name,
    x_input_type =>x_input_type,
    x_display =>x_display
  );
 END IF;

END load_row;

END csm_dashboard_search_col_pkg;

/
