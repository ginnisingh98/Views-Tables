--------------------------------------------------------
--  DDL for Package Body EDW_APPS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_APPS_INT" AS
/* $Header: EDWAPPSB.pls 115.7 2002/12/05 01:12:22 arsantha ship $ */


PROCEDURE registerSourceViews
(p_flex_view_name         IN VARCHAR2,
p_generated_view_name     IN VARCHAR2,
p_collection_view_name    IN VARCHAR2,
p_Interface_table_name    IN VARCHAR2,
p_object_name             IN VARCHAR2,
p_level_name              IN VARCHAR2,
p_version		  IN VARCHAR2) IS

v_cursor_id NUMBER;
v_ret_code NUMBER;
v_sql_stmt VARCHAR2(1000);
v_source_lang VARCHAR2(40);
cid NUMBER;
l_count NUMBER;
BEGIN

 IF (p_version is null) then
	return;
 END IF;

 IF (upper(p_version) <> 'ALL') THEN
  select count(*) into l_count from edw_source_views
  where upper(object_name) = upper(p_object_name) and
	nvl(upper(level_name), '000') = nvl(upper(p_level_name), '000') and
	upper(version) = upper(p_version) ;

  IF (l_count <> 0 ) THEN
	RETURN;
  END IF;
 ELSIF (upper(p_version) = 'ALL') THEN /* insert all versions */
	registerSourceViews(p_flex_view_name, p_generated_view_name, p_collection_view_name,
		p_Interface_table_name, p_object_name, p_level_name, '10.7');
	registerSourceViews(p_flex_view_name, p_generated_view_name, p_collection_view_name,
                p_Interface_table_name, p_object_name, p_level_name, '11.0');
        registerSourceViews(p_flex_view_name, p_generated_view_name, p_collection_view_name,
                p_Interface_table_name, p_object_name, p_level_name, '11i');
 END IF;


  v_sql_stmt := 'INSERT INTO EDW_SOURCE_VIEWS ' ||
    '(flex_view_name, generated_view_name, collection_view_name,
	Interface_table_name, object_name, level_name, version,
	last_update_date, last_updated_by, last_update_login,
	created_by, creation_date)
    values (:xflex, :xgen, :xcoll, :xit, :xobj, :xlvl, :xver, sysdate,
	0, 1, 1, sysdate) ';
  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  dbms_sql.bind_variable(v_cursor_id, ':xflex', upper(p_flex_view_name));
  dbms_sql.bind_variable(v_cursor_id, ':xgen', upper(p_generated_view_name));
  dbms_sql.bind_variable(v_cursor_id, ':xcoll', upper(p_collection_view_name));
  dbms_sql.bind_variable(v_cursor_id, ':xit', upper(p_Interface_table_name));
  dbms_sql.bind_variable(v_cursor_id, ':xobj', upper(p_object_name));
  dbms_sql.bind_variable(v_cursor_id, ':xlvl', upper(p_level_name));
  dbms_sql.bind_variable(v_cursor_id, ':xver', p_version);

  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);


EXCEPTION
  WHEN others THEN
		raise;
END registerSourceViews;

Procedure removeSourceViews(p_object_name IN VARCHAR2, p_version IN VARCHAR2) IS
BEGIN

IF (p_version <> 'ALL') THEN
	DELETE FROM edw_source_views
	WHERE upper(object_name) = upper(p_object_name)
	AND upper(version) = upper(p_version);
ELSE
	DELETE FROM edw_source_views
        WHERE upper(object_name) = upper(p_object_name);
END IF;

EXCEPTION
  WHEN no_data_found THEN
	null;
  WHEN others then
                raise;
END removeSourceViews;

Procedure removeFlexAssignments(p_object_name IN VARCHAR2, p_version IN VARCHAR2) IS
BEGIN

IF (p_version <> 'ALL') THEN
	delete from edw_sv_flex_assignments
	where upper(object_name) = upper(p_object_name)
	and upper(version) = upper(p_version);
ELSE
	delete from edw_sv_flex_assignments
        where upper(object_name) = upper(p_object_name);
END IF;
EXCEPTION
  WHEN no_data_found THEN
        null;

  WHEN others THEN
                raise;
END removeFlexAssignments;


PROCEDURE registerFlexAssignments
(
p_object_name             IN VARCHAR2,
p_flex_view_name          IN VARCHAR2,
p_flex_field_code         IN VARCHAR2,
p_flex_field_prefix       IN VARCHAR2,
p_application_id          IN NUMBER,
p_application_short_name  IN VARCHAR2,
p_flex_field_type         IN VARCHAR2,
p_flex_field_name         IN VARCHAR2,
p_version		  IN VARCHAR2)
IS
v_cursor_id NUMBER;
v_ret_code NUMBER;
v_sql_stmt VARCHAR2(1000);
v_source_lang VARCHAR2(40);
cid NUMBER;
l_count NUMBER;
BEGIN

  IF (p_version is null) then
        return;
 END IF;

 IF (upper(p_version) <> 'ALL') THEN
  select count(*) into l_count from edw_sv_flex_assignments
  where upper(object_name) = upper(p_object_name) and
        version = p_version and upper(flex_field_code)=upper(p_flex_field_code)
	and upper(flex_field_prefix) = upper(p_flex_field_prefix)
	and upper(flex_view_name) = upper(p_flex_view_name);

  IF (l_count <> 0 ) THEN
        RETURN;
  END IF;
 ELSIF (upper(p_version) = 'ALL') THEN /* insert all versions */
	registerFlexAssignments ( p_object_name, p_flex_view_name, p_flex_field_code,
		p_flex_field_prefix, p_application_id, p_application_short_name ,
		p_flex_field_type, p_flex_field_name, '10.7' );
	registerFlexAssignments ( p_object_name, p_flex_view_name, p_flex_field_code,
                p_flex_field_prefix, p_application_id, p_application_short_name ,
                p_flex_field_type, p_flex_field_name, '11.0' );
	registerFlexAssignments ( p_object_name, p_flex_view_name, p_flex_field_code,
                p_flex_field_prefix, p_application_id, p_application_short_name ,
                p_flex_field_type, p_flex_field_name, '11i' );
 END IF;

  v_sql_stmt := 'INSERT INTO EDW_SV_FLEX_ASSIGNMENTS ' ||
    '(object_name, flex_view_name, flex_field_code, flex_field_prefix,
	application_id, application_short_name, flex_field_type, flex_field_name,version,
        last_update_date, last_updated_by, last_update_login, created_by, creation_date)
    values (:xobject, :xflexview, :xflexcode, :xprefix,
	:xappid, :xappname, :xflextype, :xflexname, :xversion,
	sysdate, 1, 1, 1, sysdate) ';
  v_cursor_id := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor_id, v_sql_stmt, DBMS_SQL.V7);
  dbms_sql.bind_variable(v_cursor_id, ':xobject', upper(p_object_name));
  dbms_sql.bind_variable(v_cursor_id, ':xflexview', upper(p_flex_view_name));
  dbms_sql.bind_variable(v_cursor_id, ':xflexcode', p_flex_field_code);
  dbms_sql.bind_variable(v_cursor_id, ':xprefix', p_flex_field_prefix);
  dbms_sql.bind_variable(v_cursor_id, ':xappid', p_application_id);
  dbms_sql.bind_variable(v_cursor_id, ':xappname', p_application_short_name);
  dbms_sql.bind_variable(v_cursor_id, ':xflextype', p_flex_field_type);
  dbms_sql.bind_variable(v_cursor_id, ':xflexname', p_flex_field_name);
  dbms_sql.bind_variable(v_cursor_id, ':xversion', p_version);


  v_ret_code := dbms_sql.execute(v_cursor_id);
  dbms_sql.close_cursor(v_cursor_id);

EXCEPTION
  WHEN others THEN
                raise;
END registerFlexAssignments;

END EDW_APPS_INT;

/
