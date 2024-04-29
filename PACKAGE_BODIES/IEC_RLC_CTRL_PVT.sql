--------------------------------------------------------
--  DDL for Package Body IEC_RLC_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RLC_CTRL_PVT" AS
/* $Header: IECVRLCB.pls 115.19 2002/02/21 13:11:45 pkm ship    $ */


PROCEDURE RELEASE_CONTROL
   (P_LIST_ENTRY_ID_TAB         IEC_CPN_RLSE_STTGY_PVT.LIST_ENTRY_ID
   ,P_LIST_HEADER_ID            NUMBER
   ,P_RLSE_CTRL_ID		NUMBER
   ,P_VIEW_NAME			VARCHAR2
   ,X_LIST_ENTRY_ID_TAB     OUT IEC_CPN_RLSE_STTGY_PVT.LIST_ENTRY_ID
   )
AS
l_where_clause VARCHAR2(4000) := null;
l_list_entry_id_list VARCHAR2(4000) := null;
l_list_entry_id_count NUMBER(10) := 0;
l_rlse_stmt	VARCHAR2(4000) := null;
l_dyn_cursor_id	INTEGER;
l_dummy		INTEGER;
l_use_count     NUMBER :=1;
l_list_entry_id_col NUMBER(15);
BEGIN
      if(P_RLSE_CTRL_ID > 0 ) then
      IEC_WHERECLAUSE_PVT.getWhereClause(P_RLSE_CTRL_ID,'RLC',l_where_clause);
      if(l_where_clause IS NOT NULL) then
        if(P_LIST_ENTRY_ID_TAB.count > 0) then
          l_list_entry_id_list := '(';
          for k in 1..P_LIST_ENTRY_ID_TAB.count
	  loop
	  if(k >1)
	  then
	      l_list_entry_id_list := l_list_entry_id_list || ',';
          end if;
	  l_list_entry_id_list := l_list_entry_id_list || ' '|| P_LIST_ENTRY_ID_TAB(K);
	  l_list_entry_id_count := l_list_entry_id_count + 1;
          end loop;

          l_list_entry_id_list := l_list_entry_id_list ||')';
          l_rlse_stmt := 'select list_entry_id from '|| P_VIEW_NAME
		|| ' where list_entry_id in '|| l_list_entry_id_list
		|| ' and list_header_id = '|| P_LIST_HEADER_ID || ' and ('||
		l_where_clause || ' )';
 --         DBMS_OUTPUT.PUT_LINE('after insert stmt');
          l_dyn_cursor_id := DBMS_SQL.OPEN_CURSOR;
          DBMS_SQL.PARSE(l_dyn_cursor_id,l_rlse_stmt,DBMS_SQL.V7);
          DBMS_SQL.DEFINE_COLUMN(l_dyn_cursor_id,1,l_list_entry_id_col);
          l_dummy := DBMS_SQL.EXECUTE(l_dyn_cursor_id);

          loop
          if DBMS_SQL.FETCH_ROWs(l_dyn_cursor_id) = 0
          then
            l_use_count := -1;
	    exit;
          end if;

	  DBMS_SQL.column_value(l_dyn_cursor_id,1,l_list_entry_id_col);
	  X_LIST_ENTRY_ID_TAB(l_use_count) := l_list_entry_id_col;
	  l_use_count := l_use_count + 1;
          end loop;

          DBMS_SQL.CLOSE_CURSOR(l_dyn_cursor_id);

        end if;
      end if;
      end if;
      Exception
	when NO_DATA_FOUND then
	  if DBMS_SQL.IS_OPEN(l_dyn_cursor_id)
          then
            DBMS_SQL.CLOSE_CURSOR(l_dyn_cursor_id);
          end if;
        when OTHERS then
	  if DBMS_SQL.IS_OPEN(l_dyn_cursor_id)
          then
            DBMS_SQL.CLOSE_CURSOR(l_dyn_cursor_id);
          end if;
          raise;
END;

PROCEDURE RELEASE_CONTROL_REASSIGNALL
   (P_LIST_HEADER_ID		NUMBER
	 ,P_DO_NOT_USE_REASON NUMBER
   )
AS
BEGIN
	UPDATE AMS_LIST_ENTRIES
	set DO_NOT_USE_FLAG='N',DO_NOT_USE_REASON=null where LIST_HEADER_ID= P_LIST_HEADER_ID and DO_NOT_USE_FLAG='Y' and DO_NOT_USE_REASON=P_DO_NOT_USE_REASON;
commit;
END;


PROCEDURE RELEASE_CONTROL_REASSIGN
   (P_LIST_HEADER_ID		NUMBER
   )
AS
BEGIN
  RELEASE_CONTROL_REASSIGNALL(P_LIST_HEADER_ID,8);
END;

PROCEDURE RELEASE_CONTROL_MODIFY
   (P_RLSE_CTRL_ID		NUMBER
   )
AS
	cursor c_list_rlse is
	select list_header_id from ams_list_headers_all where release_control_alg_id = P_RLSE_CTRL_ID;
BEGIN
	FOR v_list_rlse IN c_list_rlse LOOP
		RELEASE_CONTROL_REASSIGN(v_list_rlse.list_header_id);
  END LOOP;
END;

END IEC_RLC_CTRL_PVT;


/
