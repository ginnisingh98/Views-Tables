--------------------------------------------------------
--  DDL for Package Body EGO_VALID_INSTANCE_SET_GRANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_VALID_INSTANCE_SET_GRANTS" AS
/* $Header: EGOISGRB.pls 120.3 2007/04/25 08:49:03 pfarkade ship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOISGRB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_VALID_INSTANCE_SET_GRANTS
--
--  NOTES
--
--  HISTORY
--
--  31-MAR-03 Deepak Jebar      Initial Creation
--  09-APR-07 pfarkade          R12C Security Related Changes
**************************************************************************/

PROCEDURE GET_VALID_INSTANCE_SETS(p_obj_name IN VARCHAR2,
				  p_grantee_type IN VARCHAR2,
				  p_parent_obj_sql IN VARCHAR2,
				  p_bind1 IN VARCHAR2,
				  p_bind2 IN VARCHAR2,
				  p_bind3 IN VARCHAR2,
				  p_bind4 IN VARCHAR2,
				  p_bind5 IN VARCHAR2,
				  p_obj_ids IN VARCHAR2,
				  x_inst_set_ids OUT NOCOPY VARCHAR2) IS
CURSOR inst_set_preds IS
	select DISTINCT sets.instance_set_id instance_set_id , sets.instance_set_name instance_set_name,
	sets.predicate predicate
	from
	fnd_grants grants,
	fnd_object_instance_sets sets,
	fnd_objects obj
	where obj.obj_name = p_obj_name
	AND grants.object_id = obj.object_id
	AND grants.instance_type='SET'
	AND grants.parameter1 is null
	AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)
	AND grants.grantee_type = p_grantee_type
	AND sets.instance_set_id = grants.instance_set_id
	order by instance_set_name;
CURSOR obj_meta_data IS
	select DATABASE_OBJECT_NAME,
	PK1_COLUMN_NAME,PK2_COLUMN_NAME,
	PK3_COLUMN_NAME,PK4_COLUMN_NAME,
	PK5_COLUMN_NAME from fnd_objects where OBJ_NAME = p_obj_name;
obj_meta_data_rec obj_meta_data%ROWTYPE;
i		NUMBER := 1;
-- bug 3748547 setting varchar2 fields to maximum size
query_to_exec	VARCHAR2(32767);
obj_std_pkq	VARCHAR2(32767);
prim_key_str	VARCHAR2(32767);
inst_set_ids	VARCHAR2(32767);
cursor_select	INTEGER;
cursor_execute	INTEGER;
BEGIN
OPEN obj_meta_data;
FETCH obj_meta_data INTO obj_meta_data_rec;
	obj_std_pkq := 'SELECT ' || obj_meta_data_rec.PK1_COLUMN_NAME;
	prim_key_str := obj_meta_data_rec.PK1_COLUMN_NAME;
	IF obj_meta_data_rec.PK2_COLUMN_NAME IS NOT NULL THEN
		obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK2_COLUMN_NAME;
		prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK2_COLUMN_NAME;
	END IF;
	IF obj_meta_data_rec.PK3_COLUMN_NAME IS NOT NULL THEN
		obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK3_COLUMN_NAME;
		prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK3_COLUMN_NAME;
	END IF;
	IF obj_meta_data_rec.PK4_COLUMN_NAME IS NOT NULL THEN
		obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK4_COLUMN_NAME;
		prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK4_COLUMN_NAME;
	END IF;
	IF obj_meta_data_rec.PK5_COLUMN_NAME IS NOT NULL THEN
		obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK5_COLUMN_NAME;
		prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK5_COLUMN_NAME;
	END IF;
	-- R12C Security Changes
	/*obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME;*/
	IF (p_obj_name = 'EGO_ITEM') THEN
	    obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME ||', ego_item_cat_denorm_hier cathier';
        ELSE
	    obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME;
	END IF;
	-- R12C Security Changes
CLOSE obj_meta_data;

FOR inst_set_preds_rec IN inst_set_preds
LOOP
	-- R12C Security Changes
	/*IF p_obj_ids IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
		query_to_exec := query_to_exec || ' WHERE ' || inst_set_preds_rec.predicate || ' )';
	ELSIF p_parent_obj_sql IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
		query_to_exec := query_to_exec || inst_set_preds_rec.predicate || ' AND (';
		query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
	END IF;*/
	IF (p_obj_name = 'EGO_ITEM') THEN
	    IF p_obj_ids IS NOT NULL THEN
			query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
			query_to_exec := query_to_exec || ' WHERE ' || inst_set_preds_rec.predicate || 'AND item_catalog_group_id = cathier.child_catalog_group_id )';
	     ELSIF p_parent_obj_sql IS NOT NULL THEN
			query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
			query_to_exec := query_to_exec || inst_set_preds_rec.predicate || 'AND item_catalog_group_id = cathier.child_catalog_group_id AND (';
			query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
	     END IF;
	 ELSE
	    IF p_obj_ids IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
		query_to_exec := query_to_exec || ' WHERE ' || inst_set_preds_rec.predicate || ' )';
	   ELSIF p_parent_obj_sql IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
		query_to_exec := query_to_exec || inst_set_preds_rec.predicate || ' AND (';
		query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
	    END IF;
	 END IF;
        -- R12C Security Changes
	cursor_select := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
	IF p_bind1 IS NOT NULL THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':id1', p_bind1);
	END IF;
	IF p_bind2 IS NOT NULL THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':id2', p_bind2);
	END IF;
	IF p_bind3 IS NOT NULL THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':id3', p_bind3);
	END IF;
	IF p_bind4 IS NOT NULL THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':id4', p_bind4);
	END IF;
	IF p_bind5 IS NOT NULL THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':id5', p_bind5);
	END IF;
	cursor_execute := DBMS_SQL.EXECUTE(cursor_select);
	IF DBMS_SQL.FETCH_ROWS(cursor_select) > 0 THEN
		IF i = 1 THEN
			inst_set_ids := to_char(inst_set_preds_rec.instance_set_id);
			i := 2;
		ELSE
			inst_set_ids := inst_set_ids || ',' || inst_set_preds_rec.instance_set_id;
		END IF;
	END IF;
	DBMS_SQL.CLOSE_CURSOR(cursor_select);
END LOOP;
	IF inst_set_ids IS NOT NULL THEN
		x_inst_set_ids := inst_set_ids; /**** list of valid inst_set_ids ****/
	ELSE
		x_inst_set_ids := '-1';
	END IF;
END;
END;

/
