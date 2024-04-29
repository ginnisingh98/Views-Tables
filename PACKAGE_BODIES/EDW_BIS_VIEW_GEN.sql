--------------------------------------------------------
--  DDL for Package Body EDW_BIS_VIEW_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_BIS_VIEW_GEN" AS
/* $Header: EDWBISVB.pls 115.10 2003/04/15 21:45:49 arsantha ship $ */

Procedure generateOneView(p_view_name in varchar2) IS
 temp    varchar2(1000);
 ret     number;
 l_count number;
 l_missing_view EXCEPTION;
BEGIN

-- for bug 2378092: check if the view exists and is valid
   select count(*) into l_count
     from user_objects
    where OBJECT_NAME = upper(p_view_name)
      and OBJECT_TYPE = 'VIEW'
      and STATUS = 'VALID';

   if l_count = 0 then
     raise l_missing_view;
   end if;
------------------------------------

	bis_view_generator_pvt.set_mode(2);
        bis_view_generator_pvt.generate_views(
                x_error_buf             => temp,
                x_ret_code              => ret,
                p_all_flag              => NULL,
                p_App_Short_Name        => NULL,
                p_kf_appl_short_name    => NULL,
                p_key_flex_code         => NULL,
                p_df_appl_short_name    => NULL,
                p_desc_flex_name        => NULL,
                p_lookup_table_name     => NULL,
                p_lookup_type           => NULL,
                p_view_name             => p_view_name);

-- for bug 2391331: need to commit due to autonomous transaction and DBlinks
        commit;
----------

EXCEPTION
  WHEN l_missing_view THEN
     fnd_file.put_line(fnd_file.log, 'Source view ' || p_view_name || ' is missing or invalid');
     raise;

  WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, 'Error in calling generate_views for '
                       || p_view_name || ': ' || temp);
     raise;

END;

Procedure generateAllViews(Errbuf       in out NOCOPY Varchar2,
   	                   Retcode      in out NOCOPY Varchar2,
			   p_object_long_name in   varchar2 )
IS
stmt		varchar2(300);
v_col 		DBMS_SQL.VARCHAR2_TABLE;
l_viewname 	VARCHAR2(100);
cid		NUMBER;
l_dummy		NUMBER;
nViewCount	NUMBER := 0;
nCount		NUMBER := 0;
l_version       varchar2(10):='11i';
l_obj_short_name varchar2(30);
l_dir varchar2(400);
l_newline VARCHAR2(10):='
';
l_generate_status varchar2(60);
l_error_message varchar2(3000);
l_source_link		VARCHAR2(128);
l_target_link		VARCHAR2(128);

BEGIN

	stmt := 'alter session set global_names=false';
	execute immediate stmt;

	-- get databaselink
	EDW_COLLECTION_UTIL.get_dblink_names(l_source_link, l_target_link);

	IF (p_object_long_name is not null) THEN
        	stmt:= 'SELECT relation_name from EDW_RELATIONS_MD_V@' || l_target_link ||
  	       ' where relation_long_name = :longname and relation_type in (:fact, :dimension)';
	        cid := DBMS_SQL.OPEN_CURSOR;
	        DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	        DBMS_SQL.BIND_VARIABLE(cid, ':longname', p_object_long_name);
		DBMS_SQL.BIND_VARIABLE(cid, ':fact', 'CMPWBCube');
		DBMS_SQL.BIND_VARIABLE(cid, ':dimension', 'CMPWBDimension');
	        DBMS_SQL.DEFINE_COLUMN(cid, 1, l_obj_short_name, 100);
	        l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);
	        DBMS_SQL.COLUMN_VALUE(cid, 1, l_obj_short_name);
	        DBMS_SQL.close_cursor(cid);
	END IF;

       l_dir:=fnd_profile.value('UTL_FILE_DIR');

       IF l_dir is null THEN
         l_dir:='/sqlcom/log';
       END IF;

       fnd_file.put_names(l_obj_short_name||'gen_bg.log',l_obj_short_name||'gen_bg.out',l_dir);


       fnd_file.put_line(fnd_file.log,'Object physical name is '||l_obj_short_name);
       stmt := 'SELECT count(distinct FLEX_VIEW_NAME) FROM edw_source_views@' || l_target_link ||
		' where version = :version and GENERATED_VIEW_NAME <>''NULL'' ';

        IF l_obj_short_name is not null THEN
          stmt := stmt ||' and object_name = :b_object_name';
 	END IF;

        fnd_file.put_line(fnd_file.log,l_newline||'Going to Execute : '||stmt);
	cid := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.BIND_VARIABLE(cid, ':version', l_version);

	IF l_obj_short_name is not null THEN
  	  DBMS_SQL.BIND_VARIABLE(cid, ':b_object_name', l_obj_short_name);
        END IF;

	DBMS_SQL.DEFINE_COLUMN(cid, 1, nViewCount);
	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);
	DBMS_SQL.COLUMN_VALUE(cid, 1, nViewCount);
	DBMS_SQL.close_cursor(cid);

        fnd_file.put_line(fnd_file.log,l_newline||'Number of source views found :'|| nViewCount);

	stmt := 'SELECT distinct FLEX_VIEW_NAME FROM edw_source_views@' || l_target_link ||
		' where version = :version and GENERATED_VIEW_NAME <>''NULL'' ';

        IF l_obj_short_name is not null THEN
	        stmt := stmt ||' and object_name = :b_object_name ';
	END IF;

        cid := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.BIND_VARIABLE(cid, ':version', l_version);

        IF l_obj_short_name is not null THEN
          DBMS_SQL.BIND_VARIABLE(cid, ':b_object_name', l_obj_short_name);
        END IF;
	DBMS_SQL.DEFINE_ARRAY(cid, 1, v_col, nViewCount, 1);
	l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);
	DBMS_SQL.COLUMN_VALUE(cid, 1, v_col);
	DBMS_SQL.close_cursor(cid);

	WHILE (nCount < nViewCount )LOOP
		nCount := nCount + 1;
		fnd_file.put_line(fnd_file.log, nCount||'. Going to generate '||v_col(nCount));
		generateOneView(v_col(nCount));

		BEGIN

		SELECT generate_status, error_message into l_generate_status, l_error_message
		FROM EDW_LOCAL_GENERATION_STATUS
		WHERE flex_view_name = v_col(nCount);

		IF l_generate_status = 'GENERATED_ALL' THEN

                  fnd_file.put_line(fnd_file.log,v_col(nCount)|| ' Generated.'||l_newline);
		ELSE
		  fnd_file.put_line(fnd_file.log,v_col(nCount)|| ' Generation failed.');
		  fnd_file.put_line(fnd_file.log, '	Error Message is : '||l_error_message||l_newline);
		END IF;

		EXCEPTION WHEN no_data_found THEN
			null;
		WHEN OTHERS THEN
			RAISE;
		END;

	END LOOP;

	exception when others then
		fnd_file.put_line(fnd_file.log,sqlerrm);
		raise;

END;
END EDW_BIS_VIEW_GEN;

/
