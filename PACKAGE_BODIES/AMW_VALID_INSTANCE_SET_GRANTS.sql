--------------------------------------------------------
--  DDL for Package Body AMW_VALID_INSTANCE_SET_GRANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_VALID_INSTANCE_SET_GRANTS" as
/*$Header: amwisgrb.pls 120.3 2006/05/30 12:35:30 dpatel noship $*/

PROCEDURE GET_VALID_INSTANCE_SETS(p_obj_name IN VARCHAR2,
				  p_grantee_type IN VARCHAR2,
				  p_parent_obj_sql IN VARCHAR2,
				  p_bind1 IN VARCHAR2,
				  p_bind2 IN VARCHAR2,
				  p_bind3 IN VARCHAR2,
				  p_bind4 IN VARCHAR2,
				  p_bind5 IN VARCHAR2,
				  p_obj_ids IN VARCHAR2,
				  x_guids OUT NOCOPY varchar2) IS
CURSOR inst_set_preds IS
	select grants.GRANT_GUID grant_guid,
	obj.database_object_name database_object_name,
	grants.parameter1 parameter1,
	grants.parameter2 parameter2,
	grants.parameter3 parameter3,
	grants.parameter4 parameter4,
	grants.parameter5 parameter5,
	grants.parameter6 parameter6,
	grants.parameter7 parameter7,
	grants.parameter8 parameter8,
	grants.parameter9 parameter9,
	grants.parameter10 parameter10,
	sets.instance_set_id instance_set_id,
	sets.predicate predicate
	from
	fnd_grants grants,
	fnd_object_instance_sets sets,
	fnd_objects obj
	where obj.obj_name = p_obj_name
	AND grants.object_id = obj.object_id
	AND grants.instance_type='SET'
	AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)
	AND grants.grantee_type = p_grantee_type
	AND sets.instance_set_id = grants.instance_set_id;

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
guids		VARCHAR2(32767);
mod_pred	VARCHAR2(32767);
cursor_select	INTEGER;
cursor_execute	INTEGER;
BEGIN
OPEN obj_meta_data;
FETCH obj_meta_data INTO obj_meta_data_rec;
	obj_std_pkq := '(SELECT ' || obj_meta_data_rec.PK1_COLUMN_NAME;
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
	obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME;
CLOSE obj_meta_data;

FOR inst_set_preds_rec IN inst_set_preds
LOOP
	mod_pred := pred_aft_token_subst(inst_set_preds_rec.predicate,
					inst_set_preds_rec.database_object_name,
					inst_set_preds_rec.parameter1,
					inst_set_preds_rec.parameter2,
					inst_set_preds_rec.parameter3,
					inst_set_preds_rec.parameter4,
					inst_set_preds_rec.parameter5,
					inst_set_preds_rec.parameter6,
					inst_set_preds_rec.parameter7,
					inst_set_preds_rec.parameter8,
					inst_set_preds_rec.parameter9,
					inst_set_preds_rec.parameter10);

	IF p_obj_ids IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
		query_to_exec := query_to_exec || ' WHERE ' || mod_pred || ' ))';
	ELSIF p_parent_obj_sql IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
		query_to_exec := query_to_exec || inst_set_preds_rec.predicate || ' AND (';
		query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
	END IF;

	cursor_select := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
	IF INSTR(mod_pred, ':parameter1') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter1', inst_set_preds_rec.parameter1);
	END IF;
	IF INSTR(mod_pred, ':parameter2') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter2', inst_set_preds_rec.parameter2);
	END IF;
	IF INSTR(mod_pred, ':parameter3') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter3', inst_set_preds_rec.parameter3);
	END IF;
	IF INSTR(mod_pred, ':parameter4') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter4', inst_set_preds_rec.parameter4);
	END IF;
	IF INSTR(mod_pred, ':parameter5') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter5', inst_set_preds_rec.parameter5);
	END IF;
	IF INSTR(mod_pred, ':parameter6') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter6', inst_set_preds_rec.parameter6);
	END IF;
	IF INSTR(mod_pred, ':parameter7') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter7', inst_set_preds_rec.parameter7);
	END IF;
	IF INSTR(mod_pred, ':parameter8') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter8', inst_set_preds_rec.parameter8);
	END IF;
	IF INSTR(mod_pred, ':parameter9') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter9', inst_set_preds_rec.parameter9);
	END IF;
	IF INSTR(mod_pred, ':parameterX') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameterX', inst_set_preds_rec.parameter10);
	END IF;


	cursor_execute := DBMS_SQL.EXECUTE(cursor_select);
	IF DBMS_SQL.FETCH_ROWS(cursor_select) > 0 THEN
		IF i = 1 THEN
			guids := to_char(inst_set_preds_rec.grant_guid);
			i := 2;
		ELSE
			guids := guids || ',' || inst_set_preds_rec.grant_guid;
		END IF;
	END IF;
	DBMS_SQL.CLOSE_CURSOR(cursor_select);
END LOOP;
	IF guids IS NOT NULL THEN
		x_guids := guids; /**** list of valid guids ****/
	ELSE
		x_guids := '-1';
	END IF;
END;

/*
function pred_aft_token_subst(p_int_set_id in number,
                             p_obj_name IN VARCHAR2,
                             p_grantee_type IN VARCHAR2) return varchar2 is
l_chg_pred varchar2(4000);
l_pred varchar2(4000);
l_datobj_name varchar2(30);
l_param1 VARCHAR2(256);
l_param2 VARCHAR2(256);
l_param3 VARCHAR2(256);
l_param4 VARCHAR2(256);
l_param5 VARCHAR2(256);
l_param6 VARCHAR2(256);
l_param7 VARCHAR2(256);
l_param8 VARCHAR2(256);
l_param9 VARCHAR2(256);
l_param10 VARCHAR2(256);

begin
	select sets.predicate,
    obj.database_object_name,
	grants.parameter1,
    grants.parameter2,
    grants.parameter3,
    grants.parameter4,
    grants.parameter5,
	grants.parameter6,
    grants.parameter7,
    grants.parameter8,
    grants.parameter9,
    grants.parameter10
    into l_pred,
    l_datobj_name,
    l_param1,
    l_param2,
    l_param3,
    l_param4,
    l_param5,
    l_param6,
    l_param7,
    l_param8,
    l_param9,
    l_param10
	from
	fnd_grants grants,
	fnd_object_instance_sets sets,
	fnd_objects obj
	where obj.obj_name = p_obj_name
	AND grants.object_id = obj.object_id
	AND grants.instance_type='SET'
	AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)
	AND grants.grantee_type = p_grantee_type
	AND sets.instance_set_id = grants.instance_set_id
	and sets.instance_set_id = p_int_set_id;

	l_chg_pred := l_pred;

	if INSTR(l_chg_pred, '&TABLE_ALIAS') <> 0 then
    	select replace (l_chg_pred, '&TABLE_ALIAS', l_datobj_name) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER1') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER1', l_param1) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER2') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER2', l_param2) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER3') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER3', l_param3) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER4') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER4', l_param4) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER5') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER5', l_param5) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER6') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER6', l_param6) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER7') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER7', l_param7) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER8') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER8', l_param8) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER9') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER9', l_param9) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER10') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER10', l_param10) into l_chg_pred from dual;
	end if;
	return l_chg_pred;
end ;
*/


function pred_aft_token_subst(l_pred in VARCHAR2,
			l_datobj_name in VARCHAR2,
			l_param1 in VARCHAR2,
			l_param2 in VARCHAR2,
			l_param3 in VARCHAR2,
			l_param4 in VARCHAR2,
			l_param5 in VARCHAR2,
			l_param6 in VARCHAR2,
			l_param7 in VARCHAR2,
			l_param8 in VARCHAR2,
			l_param9 in VARCHAR2,
			l_param10 in VARCHAR2) return varchar2 is
l_chg_pred varchar2(32767);
begin

l_chg_pred := upper(l_pred);

	if INSTR(l_chg_pred, '&TABLE_ALIAS') <> 0 then
    	select replace (l_chg_pred, '&TABLE_ALIAS', l_datobj_name) into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER1') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER1', ':parameter1') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER2') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER2', ':parameter2') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER3') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER3', ':parameter3') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER4') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER4', ':parameter4') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER5') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER5', ':parameter5') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER6') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER6', ':parameter6') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER7') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER7', ':parameter7') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER8') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER8', ':parameter8') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER9') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER9', ':parameter9') into l_chg_pred from dual;
	end if;
	if INSTR(l_chg_pred, '&GRANT_ALIAS.PARAMETER10') <> 0 then
    	select replace (l_chg_pred, '&GRANT_ALIAS.PARAMETER10', ':parameterX') into l_chg_pred from dual;
	end if;

	return l_chg_pred;

end pred_aft_token_subst;


function check_grant_validity (p_guid in varchar2,
                               p_pk1 in varchar2,
                               p_pk2 in varchar2,
                               p_pk3 in varchar2,
                               p_pk4 in varchar2,
                               p_pk5 in varchar2,
                               p_object_name in varchar2
                               ) return number is

CURSOR obj_meta_data IS
	select DATABASE_OBJECT_NAME,
	PK1_COLUMN_NAME,PK2_COLUMN_NAME,
	PK3_COLUMN_NAME,PK4_COLUMN_NAME,
	PK5_COLUMN_NAME from fnd_objects where OBJ_NAME = p_object_name;

obj_meta_data_rec obj_meta_data%ROWTYPE;
i		NUMBER := 1;
j		NUMBER := 1;
p_obj_ids varchar2(2000);
inst_id number;
query_to_exec	VARCHAR2(32767);
obj_std_pkq	VARCHAR2(32767);
prim_key_str	VARCHAR2(32767);
guids		VARCHAR2(32767);
mod_pred	VARCHAR2(32767);
pred VARCHAR2(32767);
db_obj_name varchar2(240);
param1     varchar2(256);
param2     varchar2(256);
param3     varchar2(256);
param4     varchar2(256);
param5     varchar2(256);
param6     varchar2(256);
param7     varchar2(256);
param8     varchar2(256);
param9     varchar2(256);
param10     varchar2(256);
cursor_select	INTEGER;
cursor_execute	INTEGER;
ret_value number := 2;
BEGIN

p_obj_ids := null;
if p_pk1 <> '*NULL*' then
    p_obj_ids := p_pk1;
end if;
if p_pk2 <> '*NULL*' then
    p_obj_ids := p_obj_ids || ',' || p_pk2;
end if;
if p_pk3 <> '*NULL*' then
    p_obj_ids := p_obj_ids || ',' || p_pk3;
end if;
if p_pk4 <> '*NULL*' then
    p_obj_ids := p_obj_ids || ',' || p_pk4;
end if;
if p_pk5 <> '*NULL*' then
    p_obj_ids := p_obj_ids || ',' || p_pk5;
end if;

	select grants.parameter1,
	grants.parameter2,
	grants.parameter3,
	grants.parameter4,
	grants.parameter5,
	grants.parameter6,
	grants.parameter7,
	grants.parameter8,
	grants.parameter9,
	grants.parameter10,
	sets.instance_set_id,
	sets.predicate,
	obj.database_object_name
	into
	param1,
	param2,
	param3,
	param4,
	param5,
	param6,
	param7,
	param8,
	param9,
	param10,
    inst_id,
    pred,
    db_obj_name
	from
	fnd_grants grants,
	fnd_object_instance_sets sets,
	fnd_objects obj
	where grants.grant_guid = p_guid
	AND sets.instance_set_id = grants.instance_set_id
	and obj.obj_name = p_object_name;

OPEN obj_meta_data;
FETCH obj_meta_data INTO obj_meta_data_rec;
	obj_std_pkq := '(SELECT ' || obj_meta_data_rec.PK1_COLUMN_NAME;
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
	obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME;
CLOSE obj_meta_data;

	mod_pred := pred_aft_token_subst(pred,
					db_obj_name,
					param1,
					param2,
					param3,
					param4,
					param5,
					param6,
					param7,
					param8,
					param9,
					param10);

	IF p_obj_ids IS NOT NULL THEN
		query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
		query_to_exec := query_to_exec || ' WHERE ' || mod_pred || ' ))';
	END IF;
	cursor_select := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);

	IF INSTR(mod_pred, ':parameter1') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter1', param1);
	END IF;
	IF INSTR(mod_pred, ':parameter2') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter2', param2);
	END IF;
	IF INSTR(mod_pred, ':parameter3') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter3', param3);
	END IF;
	IF INSTR(mod_pred, ':parameter4') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter4', param4);
	END IF;
	IF INSTR(mod_pred, ':parameter5') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter5', param5);
	END IF;
	IF INSTR(mod_pred, ':parameter6') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter6', param6);
	END IF;
	IF INSTR(mod_pred, ':parameter7') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter7', param7);
	END IF;
	IF INSTR(mod_pred, ':parameter8') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter8', param8);
	END IF;
	IF INSTR(mod_pred, ':parameter9') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameter9', param9);
	END IF;
	IF INSTR(mod_pred, ':parameterX') <> 0 THEN
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':parameterX', param10);
	END IF;

	cursor_execute := DBMS_SQL.EXECUTE(cursor_select);
	IF DBMS_SQL.FETCH_ROWS(cursor_select) > 0 THEN
		ret_value := 1;
	else
		ret_value := 2;
	END IF;
	DBMS_SQL.CLOSE_CURSOR(cursor_select);

	return ret_value;

exception
    when others then
        return 2;

END;

function     get_amw_grantees (p_pk1 in varchar2,
                               p_pk2 in varchar2,
                               p_pk3 in varchar2,
                               p_pk4 in varchar2,
                               p_pk5 in varchar2,
                               p_object_name in varchar2
                               ) return varchar2 is
sql_string varchar(32767);
lp_pk1  varchar2(256);
lp_pk2  varchar2(256);
lp_pk3  varchar2(256);
lp_pk4  varchar2(256);
lp_pk5  varchar2(256);

begin

if p_pk1 is null then
    lp_pk1 :='''*NULL*''';
else
    lp_pk1 := p_pk1;
end if;
if p_pk2 is null then
    lp_pk2 :='''*NULL*''';
else
    lp_pk2 := p_pk2;
end if;
if p_pk3 is null then
    lp_pk3 :='''*NULL*''';
else
    lp_pk3 := p_pk3;
end if;
if p_pk4 is null then
    lp_pk4 :='''*NULL*''';
else
    lp_pk4 := p_pk4;
end if;
if p_pk5 is null then
    lp_pk5 :='''*NULL*''';
else
    lp_pk5 := p_pk5;
end if;

sql_string :=
' select '||''''''||' PERSON_NAME, to_number(ltrim(gr.grantee_key, '||''''||'HZ_PARTY:'||''''||')) PERSON_ID, '||''''''||' COMPANY_NAME, gr.menu_id ROLE_ID ' ||
/**05.03.2006 npanandi: appending below in the SELECT clause for PLM's R12 SQL change**/
',gr.object_id '||
/**05.03.2006 npanandi: ends**/
' from fnd_grants gr, fnd_object_instance_sets inst, fnd_objects fo ' ||
' where gr.object_id = fo.object_id ' ||
' and fo.obj_name = ' || ''''||p_object_name ||''''||
' and gr.instance_type = '||''''||'SET'||'''' ||
' and grantee_type = '||''''||'USER'||'''' ||
' and nvl(end_date, sysdate+1) >= trunc(sysdate) ' ||
' and gr.instance_set_id = inst.instance_set_id ' ||
' and 1 = AMW_VALID_INSTANCE_SET_GRANTS.check_grant_validity' ||
'(gr.grant_guid, ' ||lp_pk1||', '||lp_pk2||', '||lp_pk3||', '||lp_pk4||', '||lp_pk5||','||
' fo.obj_name) ';

return sql_string;

end;

end AMW_VALID_INSTANCE_SET_GRANTS;

/
