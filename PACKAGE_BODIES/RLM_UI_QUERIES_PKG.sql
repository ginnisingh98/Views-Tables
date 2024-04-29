--------------------------------------------------------
--  DDL for Package Body RLM_UI_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_UI_QUERIES_PKG" as
/* $Header: RLMQRYB.pls 115.5 2002/11/09 02:02:21 rlanka ship $ */


procedure  INSERT_ROW (
		x_query_id in out NOCOPY number,
 		x_rowid out NOCOPY rowid,
                query_tab  IN query_tab_type

)  is

CURSOR c1 is Select rowid from  RLM_UI_QUERIES
WHERE  QUERY_ID = x_QUERY_ID ;
v_counter number;
BEGIN
IF  (x_QUERY_ID   is NULL) THEN
   SELECT  RLM_UI_QUERIES_S.nextval
   INTO  x_QUERY_ID
   FROM dual;
END IF;
FOR v_counter in query_tab.FIRST..query_tab.LAST LOOP
INSERT  into RLM_UI_QUERY_COLUMNS(
   QUERY_ID
  ,COLUMN_NAME
  ,COLUMN_TYPE
  ,COLUMN_VALUE
  ,CREATION_DATE
  ,CREATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
)
VALUES (
   x_QUERY_ID
  ,query_tab(v_counter).column_name
  ,query_tab(v_counter).column_type
  ,query_tab(v_counter).column_value
  ,sysdate
  ,fnd_global.user_id
  ,sysdate
  ,fnd_global.user_id
  ,fnd_global.user_id
);
END LOOP;

OPEN c1;
FETCH c1  INTO x_rowid;
IF (c1%NOTFOUND)  THEN
   raise no_data_found;
END IF;
CLOSE C1;

EXCEPTION
WHEN Others then null;

END INSERT_ROW;



procedure  SELECT_ROW (x_query_id in out NOCOPY  number,
		      query_tab  OUT NOCOPY query_tab_type) is
v_index number := 0;
cursor c1 is select * from rlm_ui_query_columns where query_id = x_query_id;
begin
for c1_rec in c1 loop
  query_tab(v_index).column_name :=c1_rec.column_name;
  query_tab(v_index).column_type :=c1_rec.column_type;
  query_tab(v_index).column_value :=c1_rec.column_value;
  v_index := v_index+1;
end loop;
exception
when others then null;
end SELECT_ROW;



procedure  UPDATE_ROW (x_query_id in out NOCOPY  number,
		      query_tab  IN query_tab_type) is
v_index number :=0;
v_rowid rowid;
begin
DELETE_ROW(x_query_id);
insert_row(x_query_id,
	   v_rowid,
	   query_tab);
end;

procedure DELETE_ROW (x_query_id in out NOCOPY  number) is
begin
delete from rlm_ui_query_columns
where query_id = x_query_id;
end;

end RLM_UI_QUERIES_PKG ;

/
