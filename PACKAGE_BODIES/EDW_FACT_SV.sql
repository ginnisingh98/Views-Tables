--------------------------------------------------------
--  DDL for Package Body EDW_FACT_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_FACT_SV" AS
/* $Header: EDWVFCTB.pls 120.0 2005/06/01 15:01:55 appldev noship $ */
l_directory Varchar2(30) := '/sqlcom/log';
g_flex_view_name varchar2(300) := null;
g_collection_view_name varchar2(300) := null;
g_generated_view_name varchar2(300) := null;
g_acct_flex_exists boolean := false;

newline varchar2(10) := '
';
tabb varchar2(40) := '	';

cid number;

TYPE t_view_text_table is table of varchar2(32760) index by binary_integer;
g_view_text_table t_view_text_table;
g_view_table_num number:=1;
g_long_stmt_flag boolean:=false;
/* ------------------------------------------------------------------------

     given a fact, return the source view name

------------------------------------------------------------------------  */

Procedure getViewNameForFact(fact_name in varchar2) IS
viewname 	VARCHAR2(300);

CURSOR  c_getViewNamesForFact(p_fact_name in varchar2) IS
	SELECT flex_view_name, generated_view_name, collection_view_name
	FROM edw_source_views
	WHERE upper(object_name) = p_fact_name
	AND version =edw_gen_view.g_version;

BEGIN
	IF (g_log) THEN
		edw_gen_view.indentBegin;
		edw_gen_view.writelog(newline);
		edw_gen_view.writelog('Inside getViewNameForFact');
	END IF;

	OPEN c_getViewNamesForFact(fact_name);
	FETCH c_getViewNamesForFact into g_flex_view_name,
		g_generated_view_name, g_collection_view_name;
	CLOSE c_getViewNamesForFact ;

	IF (g_generated_view_name IS NULL OR g_flex_view_name IS NULL OR
			g_collection_view_name IS NULL) THEN
		edw_gen_view.g_success := false;
		edw_gen_view.g_error := 'View Names not seeded for ' ||fact_name;
		raise edw_gen_view.viewgen_exception;

	END IF;

	IF (g_log) THEN
		edw_gen_view.writelog('   Flex view is:'||g_flex_view_name);
		edw_gen_view.writelog('   Generated view is:'||g_generated_view_name);
		edw_gen_view.writelog('   Collection view is:'||g_collection_view_name);
		edw_gen_view.writelog('Completed getViewNameForFact');
		edw_gen_view.indentEnd;

	END IF;


END;


Procedure generateViewForFact(fact_name IN VARCHAR2) IS

srcview 	VARCHAR2(32760);
l_temp_stmt     VARCHAR2(32760);
l_write_view_counter INTEGER:=0;
l_build_stmt_counter integer:=0;
v_col 		DBMS_SQL.VARCHAR2_TABLE;
v_colType 	DBMS_SQL.VARCHAR2_TABLE;
v_retCode 	INTEGER;
nColCount 	INTEGER := 0;
nOuterLoopCount INTEGER := 0;
nInnerLoopCount INTEGER := 0;
attColumns 	edw_gen_view.tab_att_maps;
multiAttList	edw_gen_view.tab_multi_att_list;
flexColumns 	edw_gen_view.tab_flex_att_maps;
fkColumns   	edw_gen_view.tab_fact_flex_fk_maps;
bColumnMapped 	BOOLEAN := false;
curColumn 	VARCHAR2(300) := NULL;
curColType 	VARCHAR2(300) := NULL;
stmt 		VARCHAR2(10000) := NULL;
decodeClause 	VARCHAR2(30000) := NULL;

nLoopCounter 	INTEGER := 0;

Cursor C_Skip_Columns(p_object_short_name VARCHAR2) IS
  select attribute_name, attribute_type
  from edw_attribute_properties
  where skip_flag = 'Y'
    and object_short_name = p_object_short_name;

Skip_Columns C_Skip_Columns%ROWTYPE;

Type T_skip_columns_table is table  of
C_Skip_Columns%rowtype
index by binary_integer;

skip_columns_table T_skip_columns_table;
l_count INTEGER := 0;

BEGIN

	g_flex_view_name := null;
	g_collection_view_name := null;
	g_generated_view_name := null;
	g_acct_flex_exists := false;
	g_view_table_num :=1;
	--alter session set global_names=false;
	edw_misc_util.globalNamesOff;



	IF (g_log) THEN
		edw_gen_view.indentBegin;
		edw_gen_view.writelog('Inside generateViewForFact');
	END IF;


	getViewNameForFact(upper(fact_name));


	/* figure out which attributes are mapped */
	srcview := 'CREATE OR REPLACE FORCE VIEW '||g_collection_view_name||' AS SELECT ';

	nColCount := edw_gen_view.getColumnCountForView(g_collection_view_name);


	IF (NOT edw_gen_view.g_success) THEN
		return;
	END IF;

	IF (nColCount = 0 ) THEN
		edw_gen_view.g_success := false;
		edw_gen_view.g_error := 'Error! No. of columns for ' ||g_collection_view_name||
			'@'||edw_gen_view.g_source_db_link||' is zero!!!';

		IF (g_log) THEN
			edw_gen_view.writelog('ERROR...'||edw_gen_view.g_error);
		END IF;

		raise edw_gen_view.viewgen_exception;
		RETURN;
	END IF;


	stmt := ' SELECT distinct column_name , data_type FROM all_tab_columns@'||edw_gen_view.g_source_db_link;
	stmt := stmt||' WHERE table_name = upper('''||g_collection_view_name
		||''') AND owner = '''||edw_gen_view.g_apps_schema||'''';


BEGIN
	cid := DBMS_SQL.open_cursor;

	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.DEFINE_ARRAY(cid, 1, v_col, nColCount, 1);
  	DBMS_SQL.DEFINE_ARRAY(cid, 2, v_colType, nColCount, 1);
	v_retCode := DBMS_SQL.EXECUTE_AND_FETCH(cid);
	DBMS_SQL.COLUMN_VALUE(cid, 1, v_col);
    DBMS_SQL.COLUMN_VALUE(cid, 2, v_colType);
	DBMS_SQL.CLOSE_CURSOR(cid);



	edw_gen_view.getColumnMaps(fact_name, attColumns, multiAttList,
					flexColumns, fkColumns);

	IF (NOT edw_gen_view.g_success) THEN
		return;
	END IF;


-- build skip_columns_table here
    l_count := 1;
    open C_Skip_Columns(fact_name);
    loop
        fetch C_Skip_Columns into skip_columns;
        exit when C_Skip_Columns%NOTFOUND;
        skip_columns_table (l_count).attribute_name := skip_columns.attribute_name;
        skip_columns_table (l_count).attribute_type := skip_columns.attribute_type;
        l_count := l_count + 1;
    end loop;

	WHILE nOuterLoopCount < nColCount LOOP
        nOuterLoopCount := nOuterLoopCount + 1;
    	curColumn    := v_col(nOuterLoopCount);
        curColType   := v_colType(nOuterLoopCount);

        /* check if current column is a skipped column */
	  IF (curColumn LIKE 'USER_ATTRIBUTE%' OR curColumn LIKE 'USER_FK%'
		OR curColumn like 'USER_MEASURE%' OR curColumn LIKE 'GL_ACCT%_FK%') THEN
	      null;
	  ELSE
	      nInnerLoopCount := 1;
	      IF (skip_columns_table.count > 0) THEN

    		LOOP
	   	  IF (skip_columns_table(nInnerLoopCount).attribute_name = curColumn
	             AND skip_columns_table(nInnerLoopCount).attribute_type = 'A'
        	     )
               	  OR (skip_columns_table(nInnerLoopCount).attribute_name = curColumn || '_KEY'
                     AND skip_columns_table(nInnerLoopCount).attribute_type = 'F'
                     ) THEN

                    if (skip_columns_table(nInnerLoopCount).attribute_type = 'F') then

                      l_temp_stmt :=  ',' || newline || ' ''NA_EDW'' ' || curColumn ;
                    elsif (curColType = 'NUMBER') then
                      l_temp_stmt :=  ',' || newline || ' to_number(null) ' || curColumn;

                    elsif (skip_columns_table(nInnerLoopCount).attribute_type = 'A') then
                      l_temp_stmt :=  ',' || newline || ' null ' || curColumn;

                    end if;

                if (length(srcview)+length(l_temp_stmt)> 32760) then
                    g_view_text_table(g_view_table_num):= srcview;
                    srcview:=null;
		    if g_log then
                        edw_gen_view.writelog('View text is longer than 32760.');
                        edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                    end if;
                    g_view_table_num:= g_view_table_num+1;
                    g_long_stmt_flag:=true;
                end if;
                srcview := srcview || l_temp_stmt;

                bColumnMapped := true;  -- to skip the part after nomatch
                goto nomatch;
              end if;
	      EXIT WHEN  nInnerLoopCount = skip_columns_table.last;
	      nInnerLoopCount := nInnerLoopCount + 1;
            end loop;
           end if;
          end if;

		IF nOuterLoopCount >1 THEN
                        l_temp_stmt:= ', '||newline;

                        if (length(srcview)+length(l_temp_stmt)> 32760) then
                           g_view_text_table(g_view_table_num):= srcview;
                           srcview:=null;
		           if g_log then
                              edw_gen_view.writelog('View text is longer than 32760.');
                              edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                           end if;
                           g_view_table_num:= g_view_table_num+1;
                           g_long_stmt_flag:=true;
                       end if;
                       srcview := srcview || l_temp_stmt;
		END IF;
		IF (g_log) THEN
		edw_gen_view.writelog('Processing column ' || curColumn);
		END IF;
		/* need to process only if its a user attribute or user fk */

		IF (curColumn LIKE 'USER_ATTRIBUTE%' OR curColumn LIKE 'USER_FK%'
			OR curColumn like 'USER_MEASURE%' OR curColumn LIKE 'GL_ACCT%_FK%') THEN
			null;
		ELSE

			goto nomatch;
		END IF;

		/* see if columns have been mapped to a source attribute */
		nInnerLoopCount := 1;
		IF (attColumns.count > 0) THEN


		  LOOP

			IF (attColumns(nInnerLoopCount).attribute_name = curColumn) THEN
			 	bColumnMapped := true;
				IF (g_log) THEN
				        edw_gen_view.writelog('	Attributes mapped to a single attribute exist');
					edw_gen_view.writelog('	'||curColumn||' is of datatype '||attColumns(nInnerLoopCount).datatype);
				END IF;
				IF (attColumns(nInnerLoopCount).datatype <> 'DATE') THEN
				   IF (g_log) THEN
				   	edw_gen_view.writelog('	not a date column ');
				   END IF;


                                   l_temp_stmt:=  'a.'||attColumns(nInnerLoopCount).source_attribute||' '||curColumn ;
				  IF (g_log) THEN
				   edw_gen_view.writelog('	'||attColumns(nInnerLoopCount).source_attribute||' '||curColumn ||newline||newline);
				  END IF;
                                   if (length(srcview)+length(l_temp_stmt)> 32760) then
                                     g_view_text_table(g_view_table_num):= srcview;
                                     srcview:=null;
		                     if g_log then
                                        edw_gen_view.writelog('View text is longer than 32760.');
                                        edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                     end if;
                                     g_view_table_num:= g_view_table_num+1;
                                     g_long_stmt_flag:=true;
                                   end if;
                                   srcview := srcview || l_temp_stmt;
				ELSE
				   IF (g_log) THEN
				   	edw_gen_view.writelog( 'and so doing a to_char');
				   END IF;
				   l_temp_stmt :=' to_char(a.'||attColumns(nInnerLoopCount).source_attribute||' , ''mm/dd/yyyy hh24:mi:ss'') '||' '||curColumn ;
                                   if (length(srcview)+length(l_temp_stmt)> 32760) then
                                     g_view_text_table(g_view_table_num):= srcview;
                                     srcview:=null;
		                     if g_log then
                                        edw_gen_view.writelog('View text is longer than 32760.');
                                        edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                     end if;
                                     g_view_table_num:= g_view_table_num+1;
                                     g_long_stmt_flag:=true;
                                   end if;
                                   srcview := srcview || l_temp_stmt;
				END IF;
				goto nomatch;

			END IF;
			EXIT WHEN  nInnerLoopCount = attColumns.last;
			nInnerLoopCount := nInnerLoopCount + 1;
		  END LOOP;
		END IF;

        nInnerLoopCount := 1;
		IF (multiAttList.count > 0) THEN
			LOOP

			 	IF (multiAttList(nInnerLoopCount).attribute_name = curColumn) THEN
			 		bColumnMapped := true;
					l_temp_stmt := edw_gen_view.getNvlClause(fact_name, null,
						       edw_gen_view.g_instance , curColumn)||' '||curColumn ;
			IF (g_log) THEN
                    edw_gen_view.writelog('getNvlClause returned : '||l_temp_stmt);
			END IF;
                                        if (length(srcview)+length(l_temp_stmt)> 32760) then
                                          g_view_text_table(g_view_table_num):= srcview;
                                          srcview:=null;
		                          if g_log then
                                            edw_gen_view.writelog('View text is longer than 32760.');
                                            edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                          end if;
                                           g_view_table_num:= g_view_table_num+1;
                                           g_long_stmt_flag:=true;
                                        end if;
                                        srcview := srcview || l_temp_stmt;
					goto nomatch;
			 	END IF;
				IF (NOT edw_gen_view.g_success) THEN
				return;
				END IF;

			 	EXIT WHEN  nInnerLoopCount = multiAttList.last;
				nInnerLoopCount := nInnerLoopCount + 1;
			END LOOP;
		END IF;

		/* see if columns have been mapped to a source flex field */

		nInnerLoopCount := 1;
		IF (flexColumns.count > 0) THEN

		  LOOP

 			IF (flexColumns(nInnerLoopCount).attribute_name = curColumn) THEN
			 	bColumnMapped := true;
			 	-- decode flex
			 	decodeClause := edw_gen_view.getDecodeClauseForFlexCol(
					g_flex_view_name, curColumn,
					flexColumns(nInnerLoopCount).id_flex_code,
					flexColumns(nInnerLoopCount).flex_field_type);
			 	l_temp_stmt :=  decodeClause||' '||curColumn;
                                if (length(srcview)+length(l_temp_stmt)> 32760) then
                                    g_view_text_table(g_view_table_num):= srcview;
                                    srcview:=null;
		                    if g_log then
                                       edw_gen_view.writelog('View text is longer than 32760.');
                                       edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                    end if;
                                    g_view_table_num:= g_view_table_num+1;
                                    g_long_stmt_flag:=true;
                                end if;
                                srcview := srcview || l_temp_stmt;
			 	goto nomatch;
			END IF;
			IF (NOT edw_gen_view.g_success) THEN
				return;
			END IF;

			EXIT WHEN  nInnerLoopCount= flexColumns.last;
			nInnerLoopCount := nInnerLoopCount + 1;
 		   END LOOP;
		END IF;

		/* see if fk columns have been mapped to a flex dimension */

		nInnerLoopCount := 1;
		IF (fkColumns.count > 0) THEN

		  LOOP
		 	IF (fkColumns(nInnerLoopCount).fk_physical_name = curColumn OR fkColumns(nInnerLoopCount).fk_physical_name = curColumn||'_KEY') THEN
			    bColumnMapped := true;
			    decodeClause := getDecodeClauseForFlexFK(fact_name, curColumn);
			    l_temp_stmt:= decodeClause||' '||curColumn;
                            if (length(srcview)+length(l_temp_stmt)> 32760) then
                                g_view_text_table(g_view_table_num):= srcview;
                                srcview:=null;
                                if g_log then
                                   edw_gen_view.writelog('View text is longer than 32760.');
                                   edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                end if;
                                g_view_table_num:= g_view_table_num+1;
                                g_long_stmt_flag:=true;
                            end if;
                            srcview := srcview || l_temp_stmt;
			    goto nomatch;
			END IF;

			IF (NOT edw_gen_view.g_success) THEN
				return;
			END IF;

			 EXIT WHEN  nInnerLoopCount= fkColumns.last;
			 nInnerLoopCount := nInnerLoopCount + 1;
 		  END LOOP;
		END IF;
<<nomatch>>
		IF (bColumnMapped = false) THEN
			IF (curColumn like 'USER_FK%' or curColumn like 'GL_ACCT%FK%') THEN
        		    l_temp_stmt:='''NA_EDW'''||' '||v_col(nOuterLoopCount);
                            if (length(srcview)+length(l_temp_stmt)> 32760) then
                                g_view_text_table(g_view_table_num):= srcview;
                                srcview:=null;
                                if g_log then
                                   edw_gen_view.writelog('View text is longer than 32760.');
                                   edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                end if;
                                g_view_table_num:= g_view_table_num+1;
                                g_long_stmt_flag:=true;
                            end if;
                            srcview := srcview || l_temp_stmt;
			END IF;
			IF (curColumn like 'USER_ATTRIBUTE%' or curColumn like 'USER_MEASURE%') THEN
		    	    l_temp_stmt:='null '||v_col(nOuterLoopCount);
                            if (length(srcview)+length(l_temp_stmt)> 32760) then
                                g_view_text_table(g_view_table_num):= srcview;
                                srcview:=null;
                                if g_log then
                                   edw_gen_view.writelog('View text is longer than 32760.');
                                   edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                end if;
                                g_view_table_num:= g_view_table_num+1;
                                g_long_stmt_flag:=true;
                            end if;
                            srcview := srcview || l_temp_stmt;
                        END IF;

			IF (curColumn NOT like 'USER_ATTRIBUTE%' AND curColumn NOT like 'GL_ACCT%FK%' AND curColumn NOT like 'USER_MEASURE%' AND curColumn NOT like 'USER_FK%' ) THEN
	  		    l_temp_stmt:=' a.'||v_col(nOuterLoopCount);
                            if (length(srcview)+length(l_temp_stmt)> 32760) then
                                g_view_text_table(g_view_table_num):= srcview;
                                srcview:=null;
                                if g_log then
                                   edw_gen_view.writelog('View text is longer than 32760.');
                                   edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                                end if;
                                g_view_table_num:= g_view_table_num+1;
                                g_long_stmt_flag:=true;
                            end if;
                            srcview := srcview || l_temp_stmt;
			END IF;
		END IF;
		bColumnMapped := false;
	null;
	END LOOP;


        l_temp_stmt:= newline||' FROM '||g_generated_view_name||' a';
        if (length(srcview)+length(l_temp_stmt)> 32760) then
            g_view_text_table(g_view_table_num):= srcview;
            srcview:=null;
            if g_log then
               edw_gen_view.writelog('View text is longer than 32760.');
               edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
            end if;
            g_view_table_num:= g_view_table_num+1;
            g_long_stmt_flag:=true;
        end if;
        srcview := srcview || l_temp_stmt;


	IF (g_acct_flex_exists) THEN

		l_temp_stmt:= ', '||newline||' edw_local_set_of_books b,  edw_local_equi_set_of_books c, edw_local_set_of_books d '|| newline||
		' where a.set_of_books_id = b.set_of_books_id (+) '||newline||
		/*' and b.instance(+) = '||''''|| edw_gen_view.g_instance ||''''||newline||*/
		' and b.edw_set_of_books_id = c.edw_set_of_books_id (+) '||
		' and c.equi_set_of_books_id = d.edw_set_of_books_id (+)';

                 if (length(srcview)+length(l_temp_stmt)> 32760) then
                     g_view_text_table(g_view_table_num):= srcview;
                     srcview:=null;
                     if g_log then
                        edw_gen_view.writelog('View text is longer than 32760.');
                        edw_gen_view.writelog('View Text stored in the '|| g_view_table_num||'th element of the view text table.');
                     end if;
                     g_long_stmt_flag:=true;
                 end if;
                 srcview := srcview || l_temp_stmt;

	END IF;

        if g_log then

          if (g_long_stmt_flag) then
            for l_write_view_counter in 1 .. g_view_text_table.count loop
		IF(g_log) THEN
		edw_gen_view.writelog( g_view_text_table(l_write_view_counter));
		edw_gen_view.writeoutline('/* Writing Part  '||l_write_view_counter||' of the view */');
                edw_gen_view.writeout( g_view_text_table(l_write_view_counter));
		END IF;
            end loop;
          end if;

	  IF (g_log) THEN
	  edw_gen_view.writeoutline('/* Writing remaining piece of view */');
	  edw_gen_view.writeOutline(srcview);
	  edw_gen_view.writelog(newline||newline);
	  edw_gen_view.writelog('View formation complete.');
          --edw_gen_view.writelog(srcview);
          edw_gen_view.writeOutLine('/');
          edw_gen_view.writeOutLine('EXIT;');
	 END IF;
       end if;



	IF (NOT edw_gen_view.g_success) THEN
		return;
	END IF;

        if (not g_long_stmt_flag) then
      	   IF (g_log) THEN
		edw_gen_view.writelog('Short text. Call edw_gen_view.createView');
	   END IF;
  	   edw_gen_view.createView(srcview, g_collection_view_name);
        else
     	   IF (g_log) THEN
		edw_gen_view.writelog('Long text. Call edw_gen_view.createLongView');
	   END IF;

           /*---------------------------------------------------------------------------
             cut the view text into 256 chars chunks and call edw_gen_view.buildViewStmt
            ----------------------------------------------------------------------------*/
           l_build_stmt_counter:=0;
           for l_write_view_counter in 1 .. g_view_text_table.count loop
               l_temp_stmt:= g_view_text_table(l_write_view_counter);

 	       while (length(l_temp_stmt) >256 ) loop
                 l_build_stmt_counter:= l_build_stmt_counter +1;
                 edw_gen_view.BuildViewStmt(substr(l_temp_stmt,1,256), l_build_stmt_counter);
                 l_temp_stmt:= substr(l_temp_stmt,257);
               end loop;
               l_build_stmt_counter:= l_build_stmt_counter +1;
               edw_gen_view.BuildViewStmt(l_temp_stmt, l_build_stmt_counter);
           end loop;
           l_temp_stmt := srcview;
 	   while (length(l_temp_stmt) >256 ) loop
              l_build_stmt_counter:= l_build_stmt_counter +1;
              edw_gen_view.BuildViewStmt(substr(l_temp_stmt,1,256), l_build_stmt_counter);
              l_temp_stmt:= substr(l_temp_stmt,257);
           end loop;
           l_build_stmt_counter:= l_build_stmt_counter +1;
           edw_gen_view.BuildViewStmt(l_temp_stmt, l_build_stmt_counter);

   	   edw_gen_view.createLongView(g_collection_view_name, 1, l_build_stmt_counter);
        end if;

	IF (NOT edw_gen_view.g_success) THEN

		return;
	END IF;

	IF (g_log) THEN
		edw_gen_view.writelog('Completed generateViewForFact');
		edw_gen_view.indentEnd;
	END IF;
END;

END;


/* ------------------------------------------------------------------------

     given a fact FK that is mapped, return the decode clause for this fk

------------------------------------------------------------------------  */

FUNCTION getDecodeClauseForFlexFK( pFactName IN VARCHAR2, pAttributeName IN VARCHAR2) RETURN  VARCHAR2 IS
sPrefix 	        VARCHAR2(100) := NULL;
sDecodeClause 	    VARCHAR2(30000) := NULL;
nCount 		        NUMBER := 1;
l_gen_seg_name 	    VARCHAR2(30):= NULL;
l_parent_seg_name 	VARCHAR2(30):= NULL;
l_parent_struct_num NUMBER := 0;
l_parent_struct_name  VARCHAR2(30):= NULL;
cid 		        NUMBER := 0;
l_dummy 	        NUMBER := 0;

CURSOR 		c   IS SELECT  fk_physical_name, b.dimension_short_name dimension_short_name,
       		a.value_set_id value_set_id, segment_name, flex_field_type,
	        structure_num , value_set_type, instance_code, id_flex_code, structure_name, parent_value_set_id
	        FROM edw_flex_seg_mappings a, edw_fact_flex_fk_maps b
	        WHERE b.fact_short_name = pFactName
	        AND b.enabled_flag = 'Y'
	        AND b.dimension_short_name = a.dimension_short_name
		AND a.instance_code = edw_gen_view.g_instance
		        AND (b.fk_physical_name = pAttributeName
			or b.fk_physical_name = pAttributeName||'_KEY')
		AND NOT EXISTS( select 1 from edw_flex_seg_mappings c
				where c.parent_value_set_id = a.value_set_id
				and a.instance_code = c.instance_code
				and a.dimension_short_name = c.dimension_short_name
				and a.structure_num = c.structure_num);
cRec		c%ROWTYPE;
stmt        varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

l_structure_col varchar2(100) := null;
dependantVSExists boolean := false;
sDecodePrefix varchar2(100) := null;
tempvar varchar2(300);
BEGIN

	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside getDecodeClauseForFlexFK');
	edw_gen_view.writelog('     Parameter pFactname:'||pFactName);
	edw_gen_view.writelog('     Parameter pAttributeName:'||pAttributeName);
	END IF;

	OPEN c;
	FETCH c  INTO cRec;

	sPrefix := edw_gen_view.getFlexPrefix(g_flex_view_name, cRec.id_flex_code);
    sDecodePrefix := ' DECODE('||sPrefix||'_CONTEXT, '||newline||'        ';
	--sDecodeClause := ' DECODE('||sPrefix||'_CONTEXT, '||newline||'        ';

	LOOP

		EXIT WHEN c%NOTFOUND;
		IF(nCount > 1) THEN
			sDecodeClause := sDecodeClause ||','||newline||'	';
		END IF;

		------------------------------------------------
		l_gen_seg_name := cRec.segment_name;

		IF (g_log) THEN
			edw_gen_view.writelog('l_gen_seg_name is :'|| l_gen_seg_name);
			edw_gen_view.writelog('calling formSegmentName');
		END IF;

		l_gen_seg_name := edw_gen_view.formSegmentName(sPrefix, cRec.segment_name, cRec.structure_num, pFactName, cRec.flex_field_type);

        IF (upper(cRec.value_set_type) = 'D' ) THEN /* Dependant Value Set, need parent segment name also */
                stmt := ' SELECT segment_name, structure_num FROM edw_flex_seg_mappings'||
                        ' WHERE value_set_id = :s1 AND ';

                IF (cRec.flex_field_type = 'D') THEN /* Descr Flex */
                    stmt := stmt ||' structure_name = :s2 ';
                    open cv for stmt using cRec.parent_value_set_id, cRec.structure_name ;
                    fetch cv into l_parent_seg_name, l_parent_struct_name ;
                    close cv;
                ELSIF   /* we need to consider accounting flex field as well (bug 2245373)*/
                   (cRec.flex_field_type = 'K' OR cRec.flex_field_type = 'A') THEN /* Key Flex */
                    stmt := stmt ||' structure_num = :s2 ';
                    open cv for stmt using cRec.parent_value_set_id, cRec.structure_num;
                    fetch cv into l_parent_seg_name, l_parent_struct_num ;
                    close cv;
                END IF;
                l_parent_seg_name := edw_gen_view.formSegmentName(sPrefix, l_parent_seg_name, cRec.structure_num, pFactName, cRec.flex_field_type);

		IF (g_log) THEN
	                edw_gen_view.writelog('Parent segment is :'|| l_parent_seg_name);
		END IF;
        END IF;

		-------------------------------------------------
	IF (g_log) THEN
	        edw_gen_view.writelog('dimension name is :'|| cRec.dimension_short_name);
	END IF;


		IF (cRec.dimension_short_name LIKE 'EDW_GL_ACCT%_M' ) THEN /* A/c Flex dim */
			/* Different FK format, to support Phase 1 */

			 g_acct_flex_exists := true;
			sDecodeClause :=sDecodeClause ||''''||cRec.structure_num||''','||
			 newline||'    DECODE(b.set_of_books_id, null, ''NA_EDW'', '||
		    	 newline||' 	 DECODE(c.edw_set_of_books_id, null, '||
			 newline||'	   DECODE("'||l_gen_seg_name||'", null, ''NA_EDW'','||
			 newline||'	 	"'||l_gen_seg_name||'"';
			sDecodeClause := sDecodeClause||'||'||
				''''||'-'||''''||'|| a.set_of_books_id ';
			sDecodeClause := sDecodeClause||'||'||''''||'-'||''''||'||'
			||''''||edw_gen_view.g_instance||''''||'),';

			sDecodeClause := sDecodeClause||
			newline||'	   DECODE("'||l_gen_seg_name||'", null, ''NA_EDW'','||
			 newline||'	 	"'||l_gen_seg_name||'"';
			sDecodeClause := sDecodeClause||'||'||
				''''||'-'||''''||'|| d.set_of_books_id ';

			sDecodeClause := sDecodeClause||'||'||''''||'-'||''''||'||'
			||'d.instance)'||newline||
			'	)'||
			'     )';


		ELSE
			IF (g_log) THEN
			edw_gen_view.writelog('Mapped to a non a/c flex dimension ');
			edw_gen_view.writelog('Structure name is : '||cRec.structure_name);
			END IF;

			IF (cRec.flex_field_type = 'D') THEN /* Descr Flex */
			IF (g_log) THEN
			  edw_gen_view.writelog('struct is : '||cRec.structure_name);
			END IF;
			tempvar := replace(cRec.structure_name, '''', '''''');
			IF (g_Log) THEN
		  	  edw_gen_view.writelog('struct after replace is : '||tempvar);
			END IF;

                IF (cRec.value_set_type = 'D') THEN /* Dependant VS, so different FK Structure */
                    sDecodeClause := sDecodeClause||'''';

			sDecodeClause := sDecodeClause||tempvar||''''||
    				', DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
        	   		||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
		          	'"'||l_parent_seg_name||'"'||'||'':''||"'||l_gen_seg_name||'"'||')';
                    dependantVSExists := true;
                ELSE
				    sDecodeClause := sDecodeClause||''''||tempvar||''''||
    				', DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
	           		||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
        			'"'||l_gen_seg_name||'"'||')';
                END IF; /*  value_set_type = 'D' */
			ELSE
                IF (cRec.value_set_type = 'D') THEN /* Dependant VS, so different FK Structure */
                    sDecodeClause := sDecodeClause||''''||cRec.structure_num||''''||
			     	', DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
        			||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
		          	'"'||l_parent_seg_name||'"'||'||'':''||"'||l_gen_seg_name||'"'||')';
                    dependantVSExists := true;
                ELSE
		      		sDecodeClause := sDecodeClause||''''||cRec.structure_num||''''||
			     	', DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
        			||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
		          	'"'||l_gen_seg_name||'"'||')';
                END IF; /*  value_set_type = 'D' */
			END IF; /* cRec.flex_field_type = 'D' */
		END IF; /* cRec.dimension_short_name LIKE 'EDW_GL_ACCT%_M'  */
		nCount := nCount + 1;
		FETCH c INTO cRec;
	END LOOP;
	CLOSE c;

    sDecodeClause := sDecodePrefix ||sDecodeClause||', ''NA_EDW'')';

	IF (g_log) THEN
		edw_gen_view.writelog('decode clause is : '||sDecodeClause);
	END IF;

	IF (cRec.flex_field_type = 'D') THEN
        l_structure_col := edw_gen_view.getContextColForFlex(cRec.id_flex_code, 'D');
	IF (g_log) THEN
	        edw_gen_view.writelog('Descr. flexfield structure column is : '||l_structure_col);
	END IF;
	l_structure_col:= replace(l_structure_col, '''', '''''') ;
	IF (g_log) THEN
		edw_gen_view.writelog('structure is : '||l_structure_col);
	END IF;

		IF ( upper(cRec.structure_name)='GLOBAL DATA ELEMENTS' OR l_structure_col IS NULL) THEN
           IF (dependantVSExists ) THEN
            sDecodeClause :='DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
        	   		||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
		          	'"'||l_parent_seg_name||'"'||'||'':''||"'||l_gen_seg_name||'"'||')';
           ELSE
			sDecodeClause := 'DECODE("'||l_gen_seg_name||'", null, ''NA_EDW'', '||
			''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
			'"'||l_gen_seg_name||'")';
           END IF;
        END IF;
    ELSE  /* Key Flex */
        l_structure_col := edw_gen_view.getContextColForFlex(cRec.id_flex_code, 'K');
	IF (g_log) THEN
        edw_gen_view.writelog('Key flexfield structure column is : '||l_structure_col);
	END IF;

        IF (l_structure_col IS NULL) THEN
            IF (dependantVSExists ) THEN
               sDecodeClause := 'DECODE("'||l_gen_seg_name||'",null, ''NA_EDW'','
        	   		||''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
		          	'"'||l_parent_seg_name||'"'||'||'':''||"'||l_gen_seg_name||'"'||')';
           ELSE
               sDecodeClause := 'DECODE("'||l_gen_seg_name||'", null, ''NA_EDW'', '||
			''''||cRec.instance_code||''''||'||'||''':'||cRec.value_set_id||':'''||'||'||
			'"'||l_gen_seg_name||'")';
          END IF;
        END IF;
	END IF;

	/* DBMS_SQL.CLOSE_CURSOR(cid); */

	IF (g_log) THEN
		edw_gen_view.writelog('Completed getdecodeclauseforflexfk, returning '||sDecodeClause||newline||newline);
		edw_gen_view.indentEnd;

	END IF;

	RETURN sDecodeClause;

END;




END EDW_FACT_SV;

/
