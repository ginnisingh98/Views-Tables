--------------------------------------------------------
--  DDL for Package Body EDW_DIM_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DIM_SV" AS
/* $Header: EDWVDIMB.pls 120.1 2006/03/28 01:43:30 rkumar noship $ */
l_directory Varchar2(30) := '/sqlcom/log';


g_std_flex_view_name varchar2(40) := null;
g_std_collection_view_name varchar2(40) := null;
g_std_generated_view_name varchar2(40) := null;

g_creation_date_exists boolean := false;
g_description_exists boolean := false;
g_last_update_date_exists boolean := false;

newline varchar2(10) := '
';
tabb varchar2(10) := '	';


cid number;
flexdim_viewname1 varchar2(40);
flexdim_viewname2 varchar2(40);
g_noOfMappings number := 1;
g_noOfTableVS	NUMBER := 0;
g_noOfDepVS	NUMBER := 0;
g_noOfIndepVS	NUMBER := 0;
g_noOfNoneVS	NUMBER := 0;

Procedure getCountForVSTypes(dim_name in VARCHAR2) IS
CURSOR c_getCount IS
	SELECT value_set_type type, count(*) count
	FROM	edw_flex_seg_mappings
	WHERE	dimension_short_name = dim_name
	AND	instance_code = edw_gen_view.g_instance
	GROUP BY value_set_type;

BEGIN
	IF (g_log) THEN
		edw_gen_view.writelog('Inside getCountForVSTypes');
		edw_gen_view.writelog('Parameter dim_name:'||dim_name);
	END IF;

	FOR r1 IN c_getCount LOOP
		IF (r1.type = 'F') THEN
			g_noOfTableVS := r1.count;
		ELSIF (r1.type = 'D') THEN
			g_noOfDepVS := r1.count;
		ELSIF (r1.type = 'I') THEN
			g_noOfIndepVS :=  r1.count;
		ELSIF  (r1.type = 'N') THEN
			g_noOfNoneVS :=  r1.count;
		END IF;
	END LOOP;


	IF (g_log) THEN
		edw_gen_view.writelog('No. of table validated VS :'||g_noOfTableVS);
		edw_gen_view.writelog('No. of dependant VS :'||g_noOfDepVS);
		edw_gen_view.writelog('No. of independant VS :'||g_noOfIndepVS);
		edw_gen_view.writelog('No. of none VS :'||g_noOfNoneVS);
	END IF;

	g_noOfMappings := g_noOfTableVS + g_noOfDepVS + g_noOfIndepVS + g_noOfNoneVS;
	g_noOfIndepVS := g_noOfIndepVS - g_noOfDepVS;
	IF (g_log) THEN
		edw_gen_view.writelog('Completed getCountForVSTypes');
		edw_gen_view.indentEnd;
	END IF;

END;

Procedure getViewnameForFlexdim(dim_name in varchar2) IS

cursor c_viewForFlexdim(obj_short_name varchar2 ) is
	select collection_view_name from edw_source_views
	where object_name = obj_short_name
	order by level_name;

BEGIN

	IF (g_log) THEN
	edw_gen_view.indentBegin;
	edw_gen_view.writelog(newline);
	edw_gen_view.writelog('Inside getViewnameForFlexdim');
	edw_gen_view.writelog('Parameter dim_name:'||dim_name);
	END IF;

	open c_viewForFlexdim(dim_name);
	/* there are only 2 levels that are supported. */

	fetch c_viewForFlexdim into flexdim_viewname1;
	fetch c_viewForFlexdim into flexdim_viewname2;

	close c_viewForFlexdim;

	IF (g_log) THEN
	edw_gen_view.writelog('flexdim_viewname1 is '||flexdim_viewname1);
	edw_gen_view.writelog('flexdim_viewname2 is '||flexdim_viewname2);

	edw_gen_view.writelog('Completed getViewnameForFlexdim');

	edw_gen_view.indentEnd;
	END IF;

	Exception when no_data_found then
                edw_gen_view.g_success := false;
                edw_gen_view.g_error := 'View Names not seeded for ' ||dim_name;
                raise edw_gen_view.viewgen_exception;


END;

procedure checkColumnsPresent(p_table IN varchar2)  IS

l_cursor_id number :=0;
l_column varchar2(40);
l_count number:=0;
stmt varchar2(3000);
l_table varchar2(100);
l_table_alias varchar2(100);

l_object_type varchar2(100);

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;

BEGIN

IF (g_log) THEN
	edw_gen_view.indentBegin;
	edw_gen_view.writelog('Inside checkColumnsPresent for table :'||p_table||':');
END IF;

g_last_update_date_exists := false;
g_creation_date_exists := false;
g_description_exists := false;

l_table := p_table;

/* Check if Object is a synonym, eg. mtl_system_items is a synonym
   pointing to mtl_system_items_b  */

   Open cv for 'select object_type from user_objects where object_name=:s1' using l_table;
   Fetch cv into l_object_type;
   Close cv;

   IF (l_object_type = 'SYNONYM') THEN

	edw_gen_view.writelog(l_table||' is a synonym!!! Getting actual table name... ');
	Open cv for 'select table_name from user_synonyms where synonym_name=:s1' using l_table;
	Fetch cv into l_table;
	Close cv;
   END IF;

   IF (l_table is null) THEN
	IF (g_log) THEN
		edw_gen_view.writelog('Completed checkColumnsPresent');
		edw_gen_view.indentEnd;
	END IF;
	return;
   END IF;

   edw_gen_view.writelog('Table name is :'||l_table||':');



stmt := 'SELECT distinct column_name FROM all_tab_columns@'||edw_gen_view.g_source_db_link
	 ||' WHERE column_name in( ''LAST_UPDATE_DATE'', ''CREATION_DATE'', ''DESCRIPTION'' )'
     ||' and table_name  = :table_name ';


edw_gen_view.writelog('Querying for columns : '||stmt);

 l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
 DBMS_SQL.parse(l_cursor_id, stmt, DBMS_SQL.V7);
	DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':table_name', l_table, 50);

 DBMS_SQL.define_column(l_cursor_id, 1, l_column, 40);
 l_count :=DBMS_SQL.execute(l_cursor_id);

 loop
         if DBMS_SQL.fetch_rows(l_cursor_id)=0 then
            exit;
         end if;

         DBMS_SQL.column_value (l_cursor_id, 1, l_column);
         IF (l_column = 'LAST_UPDATE_DATE') THEN
            g_last_update_date_exists := true;
         ELSIF (l_column = 'CREATION_DATE') THEN
            g_creation_date_exists := true;
         ELSIF (l_column = 'DESCRIPTION') THEN
            g_description_exists := true;
         END IF;
 end loop;

 DBMS_SQL.close_cursor(l_cursor_id);

IF (g_log) THEN
	edw_gen_view.writelog('Completed checkColumnsPresent');
	edw_gen_view.indentEnd;
END IF;

END;

procedure parseTable(p_tables in varchar2, p_value_column in varchar2,
p_alias OUT NOCOPY varchar2, p_final_tab OUT NOCOPY varchar2)  IS

l_table varchar2(1000);

bAliasExists boolean := false;
bSingleTable boolean := false;

TYPE table_and_alias IS RECORD (
  name varchar2(100),
  alias varchar2(100));

TYPE t_table_alias IS TABLE OF table_and_alias
index by binary_integer;


l_row t_table_alias;
l_counter number := 0;
l_buffer varchar2(200);

bMatched boolean := false;

BEGIN

  l_table := trim(p_tables);

  IF (g_log) THEN
	edw_gen_view.indentBegin;
	edw_gen_view.writelog('Inside parseTable for '||p_tables||','||p_value_column);
  END IF;



  IF (instr(l_table, ',') = 0 ) THEN
	bSingleTable := true;
  ELSE
      loop -- remove unnecessary spaces
	 l_table := replace (l_table, ' ,', ',');
	 l_table := replace (l_table, '  ', ' ');
	 exit when instr(l_table, ' ,')=0 AND instr(l_table, '  ')=0  ;
      end loop;
  END IF;

  edw_gen_view.writelog('l_table is '||l_table);

  IF (instr(p_value_column, '.') >0) THEN
	bAliasExists := true;
	p_alias := substr(p_value_column, 0, instr(p_value_column, '.')-1);
	edw_gen_view.writelog('Alias is :'||p_alias||':');
  ELSE
	bAliasExists := false;
  END IF;

  edw_gen_view.writelog('l_table is :'||l_table||':');

   /* Put Table/Alias combinations in a PL/SQL table */

   loop
	IF (bSingleTable) THEN
		l_row(l_counter).name := substr(l_table, 0, instr(l_table, ' '));

		IF (l_row(l_counter).name is NULL) THEN
		  l_row(l_counter).name := l_table;
		ELSE
		  l_row(l_counter).alias := substr(l_table, instr(l_table, ' ')+1, length (l_table));
		END IF;
		p_final_tab := l_row(l_counter).name;
	exit;
	END IF;

	/* Multiple Tables */
	edw_gen_view.writelog('Multiple Tables... ');


	-- Get Next table into buffer
	IF (instr(l_table, ',') > 0) THEN
		l_buffer := trim(substr (l_table, 0, instr(l_table, ',')-1));
	ELSE
		l_buffer := l_table;
		l_table := null;
	END IF;

	edw_gen_view.writelog('l_buffer is :'||l_buffer||':');

	-- Removed processed table from l_table
	l_table := substr(l_table, instr(l_table, ',')+1, length(l_table));
	edw_gen_view.writelog('l_table is :'||l_table||':');

	IF (instr(l_buffer, ' ')>0) THEN -- alias exists
		 edw_gen_view.writelog('Alias exists');

		l_row(l_counter).name := trim(substr(l_buffer, 0, instr(l_buffer, ' ')));
		l_row(l_counter).alias := trim(substr(l_buffer, instr(l_buffer,' '), length(l_buffer)));

		edw_gen_view.writelog('Name  :'||l_row(l_counter).name||':');
		edw_gen_view.writelog('Alias :'||l_row(l_counter).alias||':');

	ELSE
		edw_gen_view.writelog('No alias for the table');
		l_row(l_counter).name := trim(l_buffer);
		edw_gen_view.writelog('Name :'||l_row(l_counter).name||':');
	END IF;

	IF (bAliasExists) THEN
		IF (l_row(l_counter).alias = p_alias ) THEN
			p_final_tab := l_row(l_counter).name;
			edw_gen_view.writelog('Alias matched...so table is '||p_final_tab);

			bMatched := true;
		END IF;
	ELSE
		p_final_tab := l_row(l_counter).name;
		edw_gen_view.writelog('No value alias, returning first table '||p_final_tab);

		bMatched := true;
	END IF;

	l_counter := l_counter + 1;
	exit when trim(l_table) is null or bMatched or (l_counter > 100);

   end loop;


   edw_gen_view.writelog('Trimmed p_tab is :'||p_final_tab||':');

   IF (g_log) THEN
	edw_gen_view.writelog('Completed parseTable 2');
	edw_gen_view.indentEnd;
   END IF;

END;


Function getTableValClause(dim_name in varchar2) RETURN varchar2 IS
clause varchar2(32000) := null;
stmt1 varchar2(2000);
stmt2 varchar2(2000);
valueCol DBMS_SQL.VARCHAR2_TABLE;

l_singleClause varchar2(2000);
l_dummy_int number;
l_count number := 1;

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
cvTable CurTyp;
l_table varchar2(240);
l_comma_begin number:=0 ;
l_CURSOR_id number :=0;
l_column varchar2(40);
l_columnlist varchar2(500);
l_temp varchar2(100);
l_unionFlag boolean := FALSE;

l_vsid number :=0;
where_Clause varchar2(30000);
l_WHERE_count number := 0;

l_final_table varchar2(100);
l_table_alias varchar2(100);

l_value_column_name varchar2(100);
l_meaning_column_name varchar2(100);
l_id_column_name varchar2(100);

l_flex_table varchar2(1000);

l_value_set_name varchar2(300);
l_segment_name   varchar2(300);
l_structure_name varchar2(300);

BEGIN


    IF (g_log) THEN
    	edw_gen_view.indentBegin;
    	edw_gen_view.writelog('Inside getTableValClause');
    END IF;


    stmt1 := 'SELECT distinct APPLICATION_TABLE_NAME, value_set_id, value_column_name, meaning_column_name,
        id_column_name, value_set_name FROM edw_flex_seg_mappings a,'||
     '  fnd_flex_validation_tables@' ||edw_gen_view.g_source_db_link
	 ||' b WHERE a.value_set_id = b.flex_value_set_id '
	 ||' AND a.dimension_short_name = :d1 AND A.VALUE_SET_TYPE = :d2';

    edw_gen_view.writelog('Querying table name : '||stmt1||' with :d1='||dim_name);

    OPEN cv for stmt1 using dim_name, 'F';
    LOOP -- write this for debugging
        FETCH cv into l_flex_table, l_vsid, l_value_column_name, l_meaning_column_name,
        l_id_column_name, l_value_set_name;
        edw_gen_view.writelog('Table name IS :' ||l_flex_table||' Value Set ID : '||l_vsid||' Value column = '||l_value_column_name||
        ' Meaning column = '||l_meaning_column_name||' ID column = '||l_id_column_name);
        EXIT WHEN cv%NOTFOUND;
    END LOOP;
    CLOSE Cv;


    OPEN cv for stmt1 using dim_name, 'F';
    l_count := 1;
    LOOP

        FETCH cv into l_flex_table, l_vsid, l_value_column_name, l_meaning_column_name,
            l_id_column_name, l_value_set_name;
        exit when cv%notfound;
    	l_table := l_flex_table;

        edw_gen_view.writelog('Table name IS :' ||l_table||' Value Set ID : '||l_vsid||' Value column = '||l_value_column_name||' Meaning column = '||l_meaning_column_name||' ID column = '||l_id_column_name);
        l_table := rtrim(ltrim(l_table));
        parseTable(lower(l_table), lower(l_value_column_name), l_table_alias,l_final_table);
        checkColumnsPresent(upper(l_final_table));

    	l_comma_begin := INSTR(l_table, ',') - 1;
        IF (l_comma_begin = 0) THEN
    		l_table := substr(l_table, 1, l_comma_begin-1);
        END IF;

        IF (l_id_column_name IS NULL) THEN
                    stmt2 := 'SELECT DISTINCT ''SELECT ''||''''''''|| a.instance_code ||'':''||a.value_set_id||'':''''''||''||''|| value_column_name ||'' L2_PK,
                    ''|| VALUE_COLUMN_NAME|| ''  actual_value,
                    '' ||''''''';
        ELSE
	           IF (l_value_column_name IS null) then
                	stmt2 := 'SELECT DISTINCT ''SELECT ''||''''''''|| a.instance_code ||'':''||a.value_set_id||'':''''''||''||''|| id_column_name ||'' L2_PK,
                    ''|| id_COLUMN_NAME|| ''  actual_value,'' ||''''''';
               ELSE
    		        stmt2 := 'SELECT DISTINCT ''SELECT ''||''''''''|| a.instance_code ||'':''||a.value_set_id||'':''''''||''||''|| id_column_name ||'' L2_PK,
                    ''|| value_COLUMN_NAME|| ''  actual_value,
                    '' ||''''''';
    	       END IF;
        END IF;

        stmt2:= stmt2||edw_gen_view.g_instance||'''''''||'' instance,         ';


       IF (g_last_update_date_exists) THEN
        	edw_gen_view.writelog('Last Update date exists');

	       IF (l_table_alias IS NOT NULL) then
        		stmt2 := stmt2||' '||l_table_alias||'.last_update_date ';
    	   ELSE
        		stmt2 := stmt2||' '||l_final_table||'.last_update_date ';
    	   END IF;
           stmt2 := stmt2 || ' last_update_date, ';
      ELSE
            stmt2 := stmt2 || '  to_date(null, ''''mm/dd/yyyy hh24:mi:ss'''') last_update_date, ';
      END IF;

      IF (g_creation_date_exists) THEN
    	   edw_gen_view.writelog('Creation date exists');
	       IF (l_table_alias IS NOT NULL) then
    		  stmt2 := stmt2||' '||l_table_alias||'.creation_date ';
    	   ELSE
    		  stmt2 := stmt2||' '||l_final_table||'.creation_date ';
    	   END IF;
           stmt2 := stmt2 || '  creation_date, ';
      ELSE
            stmt2 := stmt2 || '  to_date(null, ''''mm/dd/yyyy hh24:mi:ss'''') creation_date, ';
      END IF;



      IF (l_meaning_column_name IS not null) THEN
            stmt2 := stmt2 || l_meaning_column_name||'  description, ';
      ELSE
	       IF (g_description_exists) THEN
		      edw_gen_view.writelog('Description exists');
		      IF (l_table_alias IS NOT NULL) then
			    stmt2 := stmt2||' '||l_table_alias||'.description ';
		      ELSE
			    stmt2 := stmt2||' '||l_final_table||'.description ';
		      END IF;
	       ELSE
		        stmt2 := stmt2||' null ';
	       END IF;
           stmt2 := stmt2 || '  description, ';

      END IF;

        stmt2 := stmt2||'  ''''NA_EDW'''' l2_fk '',  '||' APPLICATION_TABLE_NAME FROM edw_flex_seg_mappings a,';
        stmt2 := stmt2|| '  fnd_flex_validation_tables@' ||edw_gen_view.g_source_db_link	||
        ' b WHERE a.value_set_id = b.flex_value_set_id AND a.dimension_short_name = :d1 ';
        stmt2 := stmt2||' AND application_table_name = :d2';

        IF (g_log) THEN
    		edw_gen_view.writelog( ' Query IS : '||stmt2);
        END IF;

        OPEN cvTable for stmt2 using  dim_name, l_flex_table;


        LOOP
            edw_gen_view.writelog( ' l_Count IS : '||l_count);
            FETCH cvTable into l_singleClause, l_table ;
            exit when cvTable%notfound;

            IF (clause IS NOT NULL) THEN
                clause := clause||' UNION ALL '||newline;
            END IF;
            clause := clause|| l_singleClause ;
    		clause := clause ||newline|| ' FROM '|| l_table|| ' ';

            IF (g_log) THEN
    	   	   edw_gen_view.writelog( ' View clause IS : '||clause);
            END IF;


    	    edw_gen_view.g_where_clause.delete;

    	   IF (not edw_gen_view.checkWhereClause(l_vsid, edw_gen_view.g_source_db_link)) THEN
    		  edw_gen_view.g_success := FALSE;
    		  fnd_message.set_name('BIS', 'EDW_BIND_VARIABLES_FOUND');
    		  fnd_message.set_token('OBJ', dim_name);
    		  fnd_message.set_token('TAB', l_value_set_name);
    		  fnd_message.set_token('STRUCT', l_structure_name);
    		  fnd_message.set_token('SEGMENT', l_segment_name);
              edw_gen_view.g_error := fnd_message.get;
              raise edw_gen_view.viewgen_exception;
    	   END IF;


    	   IF (edw_gen_view.g_where_clause.count > 0) THEN
	           clause := clause ||newline;
    	       LOOP
    		      edw_gen_view.writelog('Count IS : '||l_where_count);
    		      clause := clause || edw_gen_view.g_where_clause(l_where_count);
    		      edw_gen_view.writelog('Select Clause IS : '|| clause);
    		      exit when l_where_count = edw_gen_view.g_where_clause.last;
    		      l_where_count := l_where_count + 1;
    	       END LOOP;
    	   END IF;

	       l_count := l_count + 1;
        END LOOP;
        CLOSE cvTable;
    END LOOP;
    CLOSE cv;


	IF (g_log) then
        edw_gen_view.writelog('Completed getTableValClause');
	edw_gen_view.indentEnd;
	END IF;
	RETURN clause;
END;



FUNCTION getIndepVSClause( p_dim_name in VARCHAR2, p_level in VARCHAR2) RETURN VARCHAR2 IS
	src_view 	VARCHAR2(30000)	:= null;
    singleClause varchar2(3000) := null;
	l_count 	NUMBER 		:= 0;

	CURSOR c_getLowerLevelIndepValueSets IS
	SELECT distinct a.value_set_type, a.value_set_id, a.parent_value_set_id
	FROM edw_flex_seg_mappings a
	WHERE
	dimension_short_name = p_dim_name
	and instance_code = edw_gen_view.g_instance
	AND ( value_set_type = 'I' /* OR value_set_type = 'N' OR
		value_set_type = 'F' */)
	AND NOT EXISTS
	(SELECT 1 FROM edw_flex_seg_mappings  b
	where b.parent_value_set_id = a.value_set_id
	AND b.dimension_short_name = a.dimension_short_name
	AND b.structure_num = a.structure_num);

	CURSOR c_getHigherLevelIndepValueSets IS
	SELECT parent.value_set_type, parent.value_set_id, parent.parent_value_set_id , parent.structure_num
	FROM edw_flex_seg_mappings parent, edw_flex_seg_mappings child
	WHERE
	parent.dimension_short_name = child.dimension_short_name
	AND parent.dimension_short_name = p_dim_name
	AND parent.instance_code =  edw_gen_view.g_instance
	AND child.instance_code =  edw_gen_view.g_instance
	AND parent.value_set_type = 'I'
	AND child.value_set_type = 'D'
	AND child.parent_value_set_id = parent.value_set_id
    	AND parent.structure_num = child.structure_num;

BEGIN

	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside getIndepVSClause for '||p_level);
	END IF;
    l_count := 0;
	IF (p_level = 'LOWER') THEN

	   src_view :=  	'SELECT  '||''''||edw_gen_view.g_instance||':''||'||'flex_value_set_id||'':''||flex_value L2_PK, flex_value actual_value,  ' ||newline||
				' '''||edw_gen_view.g_instance||''''||' instance,  last_update_date, '||
				newline||'  creation_date, description,  ''NA_EDW'' L2_FK '||
				newline||' FROM  fnd_flex_values_vl '||
				newline||' WHERE  flex_value_set_id IN ( ';

	   FOR r1 IN  c_getLowerLevelIndepValueSets LOOP

		IF (l_count >= 1) THEN
			src_view := src_view||', ';
		END IF;


		src_view:=src_view||r1.value_set_id;
		l_count := l_count + 1;
	   END LOOP;
	ELSE
        src_view :=  	'SELECT  '||''''||edw_gen_view.g_instance||':''||'||'a.flex_value_set_id||'':''||a.flex_value L1_PK,  ' ||newline||
					' flex_value actual_value, '||
					''''||edw_gen_view.g_instance||''''||' instance,    '||newline||
					' a.last_update_date,  a.creation_date, a.description,  ''NA_EDW'' L1_FK '||
					newline||' FROM  fnd_flex_values_vl a ' ||
					' WHERE a.flex_value_set_id IN ( ';
	   FOR r1 IN  c_getHigherLevelIndepValueSets LOOP

		IF (l_count >= 1) THEN
			src_view:=src_view||', ';
		END IF;
		src_view:=src_view||r1.value_set_id;
		l_count := l_count + 1;
	   END LOOP;
	END IF;
    src_view := src_view || ')';

	IF (g_log) THEN
    edw_gen_view.writelog('Independant Value Set Clause is : '||src_view);
	edw_gen_view.writelog('Completed getIndepVSClause');
	edw_gen_view.indentEnd;
	END IF;

	return src_view;
END;

FUNCTION getDepVSClause(p_dim_name in varchar2) RETURN VARCHAR2 IS

	src_view varchar2(30000) := null;
	l_count number := 0;
    final_view varchar2(32000) := null;
	CURSOR c_getLowerLevelVSets IS
	SELECT distinct a.value_set_type, a.value_set_id, a.parent_value_set_id
	FROM edw_flex_seg_mappings a WHERE
	dimension_short_name = p_dim_name
	and a.instance_code =  edw_gen_view.g_instance
	AND a.parent_value_set_id <> 0 ; /* dependant value sets */

BEGIN

	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside getDepVSClause ');
	edw_gen_view.writelog('Parameter p_dim_name:'||p_dim_name);
	END IF;

	l_count := 0;
  	src_view :=   '  SELECT '||''''||edw_gen_view.g_instance||':''||'||' childvl.flex_value_set_id||'':''||parentvl.flex_value|| '':''|| childvl.flex_value L2_PK,  parentvl.flex_value||'':''||childvl.flex_value actual_value,';
  	src_view := src_view||''''||edw_gen_view.g_instance||''''||' instance, '||
    	newline||' childvl.last_update_date, childvl.creation_date, '||
		newline||' childvl.description, '||''''||edw_gen_view.g_instance||':''||'||' parentvl.flex_value_set_id  '|| '||'':''||'||' parentvl.flex_value  L2_FK ';
	src_view := src_view|| newline||' from fnd_flex_values_vl childvl, fnd_flex_value_sets child,  fnd_flex_values_vl parentvl , fnd_flex_value_sets parent ';
	src_view := src_view|| newline||' WHERE  child.flex_value_set_id = childvl.flex_value_set_id
                and child.parent_flex_value_set_id = parent.flex_value_set_id
                and parent.flex_value_set_id = parentvl.flex_value_set_id
                and childvl.parent_flex_value_low = parentvl.flex_value and child.flex_value_set_id in (';

    final_view := src_View;

	FOR r1 IN  c_getLowerLevelVSets LOOP
		IF (l_count >= 1) THEN
			final_view := final_view ||', ';
		END IF;

        final_view := final_view||r1.value_set_id;
		l_count := l_count + 1;

	END LOOP;

    final_view := final_view||') ';
	IF (g_log) THEN

	edw_gen_view.writelog('Dependant VS clause is :' ||final_view);
	edw_gen_view.writelog('Completed getDepVSClause'||newline);

	edw_gen_view.indentEnd;
	END IF;

	return final_view;

END;

FUNCTION getNoneVSClause(p_dim_name in varchar2) RETURN VARCHAR2 IS


finalClause varchar2(32000);
select1 varchar2(1000);
select2 varchar2(1000);
select3 varchar2(1000);
select4 varchar2(1000);
whereKeyFlex varchar2(1000);
whereDescFlex varchar2(1000);
finalStmt varchar2(10000);

singleClause varchar2(1000);
l_dummy_int number;
l_count number := 1;
l_table varchar2(100);
l_structure_col varchar2(100);

l_table_alias varchar2(100);
l_structure_id number;

l_flex_type varchar2(1);
l_struct_name VARCHAR2(30);

TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
cTable  CurTyp;


BEGIN



IF (g_log) THEN
	edw_gen_view.indentBegin;
	edw_gen_view.writelog( 'inside getNoneVSClause');
END IF;

select1 := 'SELECT b.APPLICATION_TABLE_NAME , a.structure_num, a.STRUCTURE_NAME,'||newline;

whereKeyFlex := ' b.SET_DEFINING_COLUMN_NAME,''K'' FROM edw_flex_seg_mappings a, fnd_id_flexs@'||edw_gen_view.g_source_db_link||' b WHERE ( a.id_flex_code = b.id_flex_code ) and a.value_set_type =''N'' and a.application_id=b.application_id '||
' and a.instance_code = :d1 '||
' AND a.dimension_short_name = :d2 ';

whereDescFlex :=  ' b.CONTEXT_COLUMN_NAME, ''D'' FROM edw_flex_seg_mappings a, fnd_descriptive_flexs_vl@'||edw_gen_view.g_source_db_link||
' b WHERE ( a.id_flex_code = b.descriptive_flexfield_name ) and a.value_set_type = ''N'' and a.application_id=b.application_id '||
' and a.instance_code = :d3 '||
' AND a.dimension_short_name = :d4 ' ;

finalStmt := select1||whereKeyFlex||'UNION ALL ' ||newline||select1 ||whereDescFlex;

--execute immediate finalStmt;
open cv for finalStmt using  edw_gen_view.g_instance, p_dim_name,
			edw_gen_view.g_instance, p_dim_name;

l_count := 1;
LOOP
    fetch cv into l_table, l_structure_id , l_struct_name, l_structure_col,l_flex_type ;
    exit when cv%notfound;

    checkColumnsPresent(rtrim(ltrim(upper(l_table))));

    select1 := 'SELECT ''SELECT DISTINCT ''||''''''''|| a.instance_code ||'':''||a.value_set_id||'':''''||''||application_column_name ||'' L2_PK, '''||newline;
    select2 := '|| application_COLUMN_NAME ||'' ACTUAL_VALUE,'' ||''''''''||a.instance_code||''''''''||';
    select3 := ''' INSTANCE, ';

    IF (g_last_update_date_exists) THEN
        select3 := select3 || newline||'  LAST_UPDATE_DATE, ';
    ELSE
        select3 := select3 || newline||'  to_date(null, ''''mm/dd/yyyy hh24:mi:ss'''') last_update_date, ';
    END IF;
    IF (g_creation_date_exists) THEN
        select3 := select3 || newline||'  CREATION_DATE, ';
    ELSE
        select3 := select3 || newline||'  to_date(null, ''''mm/dd/yyyy hh24:mi:ss'''') creation_date, ';
    END IF;
    IF (g_description_exists) THEN
        select3 := select3 || newline||'  DESCRIPTION, ';
    ELSE
        select3 := select3 || newline||'  null DESCRIPTION, ';
    END IF;

    select3 := select3 ||'''''NA_EDW'''' L2_FK FROM ''';
    select4 := '  || b.APPLICATION_TABLE_NAME||'' WHERE ''||application_column_name ||'' is not null ';

    --for bug 3373544
    /*    IF (l_structure_col is not null AND l_structure_id <> -1) THEN
        select4 := select4 ||' AND '||l_structure_col  || ' = '''''||l_structure_id ||'''''';
    END IF;*/

    IF( l_flex_type = 'K') then
	IF (l_structure_col is not null AND l_structure_id <> -1) THEN
		 select4 := select4 ||' AND '||l_structure_col  || ' = '''''||l_structure_id ||'''''';
	 END IF;
     END IF;

   IF( l_flex_type = 'D') then
	IF (l_structure_col is not null AND l_struct_name is not null) THEN
		  select4 := select4 ||' AND '||l_structure_col  || ' = '''''|| l_struct_name ||'''''';
	 END IF;
   END IF;

    select4 := select4||''' FROM edw_flex_seg_mappings a, '||newline;

    whereKeyFlex := 'fnd_id_flexs@'||edw_gen_view.g_source_db_link||' b WHERE ( a.id_flex_code = b.id_flex_code ) and a.value_set_type =''N'' and a.application_id=b.application_id '||
    ' AND a.instance_code = :d1 '||
    ' AND a.dimension_short_name = :d2 ' ||
    ' AND b.application_table_name = :d3 AND a.structure_num = :d7'; -- 4905343- changed l_structure_id into bind variable d7

    whereDescFlex :=  'fnd_descriptive_flexs_vl@'||edw_gen_view.g_source_db_link||' b WHERE ( a.id_flex_code = b.descriptive_flexfield_name ) and a.value_set_type = ''N'' and a.application_id=b.application_id '||
    ' AND a.instance_code = :d4 '||
    ' AND a.dimension_short_name = :d5 ' ||
    ' AND b.application_table_name = :d6 '|| ' AND a.structure_num = :d8';  -- 4905343- changed l_structure_id into bind variable d8

    finalStmt := select1||select2||select3||select4||whereKeyFlex||'  UNION  ALL ' ||newline||
                 select1||select2||select3||select4||whereDescFlex;


	IF (g_log) THEN
    	edw_gen_view.writelog( newline||'Final SQL to query on None Value Set : '||newline);
	   edw_gen_view.writelog(finalStmt);
	END IF;


    open ctable for finalStmt using edw_gen_view.g_instance, p_dim_name, l_table,
				edw_gen_view.g_instance, p_dim_name, l_table, l_structure_id,l_structure_id;


    loop
        fetch ctable into singleClause;
        exit when ctable%notfound;
        singleClause :=  replace (singleClause, 'FROM', newline||'FROM');
        singleClause :=  replace (singleClause, 'WHERE', newline||'WHERE');
        finalClause := finalClause||singleClause;
		if (l_count = g_noOfNoneVS) then
			null;
		else
			finalClause:= finalClause||newline||'UNION ALL '||newline;
		end if;
		l_count := l_count + 1;

    end loop;
    close ctable;
END LOOP;
close cv;
	IF (g_log) THEN
		edw_gen_view.indentEnd;
		edw_gen_view.writelog('Completed getNoneVSClause');
	END IF;

	return finalClause;

END;

PROCEDURE getViewnamesForStdDim(dim_name IN VARCHAR2, level IN VARCHAR2) IS

view_name VARCHAR2(50) := null;

BEGIN
	IF (g_log) THEN

		edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside getViewnameForStdDim');
	END IF;

	SELECT flex_view_name, generated_view_name, collection_view_name
	INTO g_std_flex_view_name, g_std_generated_view_name, g_std_collection_view_name
	FROM edw_source_views
	WHERE object_name = dim_name AND level_name = level AND version =edw_gen_view.g_version;

	IF (g_log) THEN


		edw_gen_view.writelog( 'Flex View Name is :'||g_std_flex_view_name   );
		edw_gen_view.writelog( 'Gen View Name is :'||g_std_generated_view_name   );
		edw_gen_view.writelog( 'Coll Name is :'||g_std_collection_view_name   );
		edw_gen_view.writelog( 'Completed getViewnameForStdDim');
		edw_gen_view.indentEnd;
	END IF;


	EXCEPTION WHEN no_data_found THEN
		edw_gen_view.g_success := false;
                edw_gen_view.g_error := 'View Names not seeded for ' ||dim_name;
                raise edw_gen_view.viewgen_exception;
END;

FUNCTION getGeneratedViewnameForStdDim(dim_name IN VARCHAR2, level IN VARCHAR2) RETURN VARCHAR2 IS

view_name VARCHAR2(50) := null;

BEGIN
	IF (g_log) THEN
	edw_gen_view.indentBegin;


	edw_gen_view.writelog('Inside getGeneratedViewnameForStdDim');
	edw_gen_view.writelog('Parameter dim_name:'||dim_name);
	edw_gen_view.writelog('Parameter level:'||level);
	END IF;

	SELECT generated_view_name INTO view_name
	FROM edw_source_views
	WHERE object_name = dim_name AND level_name = level AND version =edw_gen_view.g_version;

	IF (g_log) THEN
	edw_gen_view.writelog('View name for standard dimension '||dim_name || ':'||view_name);
	edw_gen_view.writelog('Completed getGeneratedViewnameForStdDim');

	edw_gen_view.indentEnd;
	END IF;

	return view_name;

	EXCEPTION WHEN no_data_found THEN
			RETURN null;
END;

Procedure generateStdLevel(dim_name IN VARCHAR2, level_name IN VARCHAR2) IS

attColumns 	edw_gen_view.tab_att_maps;
multiAttList	edw_gen_view.tab_multi_att_list;
flexColumns 	edw_gen_view.tab_flex_att_maps;
fkColumns   	edw_gen_view.tab_fact_flex_fk_maps;
view_name	VARCHAR2(50);
v_retCode 	INTEGER;
bColumnMapped 	BOOLEAN := false;
curColumn 	VARCHAR2(100) := NULL;
curColType 	VARCHAR2(300) := NULL;
stmt 		VARCHAR2(30000) := NULL;

nColCount 	INTEGER := 0;
nOuterLoopCount INTEGER := 0;
nInnerLoopCount INTEGER := 0;
srcview	VARCHAR2(32000) := null;
l_temp_stmt     VARCHAR2(32000) := null;
v_col 		DBMS_SQL.VARCHAR2_TABLE;
v_colType 	DBMS_SQL.VARCHAR2_TABLE;
decodeClause	VARCHAR2(3000);

Cursor C_Skip_Columns(p_object_short_name VARCHAR2, p_level_name VARCHAR2) IS
  select attribute_name, attribute_type
  from edw_attribute_properties
  where skip_flag = 'Y'
    and object_short_name = p_object_short_name
    and level_name = p_level_name;

Skip_Columns C_Skip_Columns%ROWTYPE;

Type T_skip_columns_table is table of
C_Skip_Columns%rowtype
index by binary_integer;

skip_columns_table T_skip_columns_table;
l_count INTEGER := 0;

BEGIN
	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside generateStdLevel');
	edw_gen_view.writelog('Parameter dim_name:'||dim_name);
	edw_gen_view.writelog('Parameter level_name:'||level_name);
	END IF;


	getViewnamesForStdDim(dim_name, level_name);

	view_name := g_std_collection_view_name;

	nColCount := edw_gen_view.getColumnCountForView(view_name);

	IF (nColCount = 0 ) THEN
		RETURN;
	END IF;

	stmt := 'SELECT distinct column_name, data_type FROM all_tab_columns@'||edw_gen_view.g_source_db_link;
	stmt := stmt||' WHERE table_name = :view_name and owner = :owner';

	cid := DBMS_SQL.open_cursor;

	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	DBMS_SQL.BIND_VARIABLE(cid, ':view_name', upper(view_name), 50);
	DBMS_SQL.BIND_VARIABLE(cid, ':owner', edw_gen_view.g_apps_schema, 50);

	DBMS_SQL.DEFINE_ARRAY(cid, 1, v_col, nColCount, 1);
  	DBMS_SQL.DEFINE_ARRAY(cid, 2, v_colType, nColCount, 1);
	v_retCode := DBMS_SQL.EXECUTE(cid);
	v_retCode := DBMS_SQL.FETCH_ROWS(cid);
	DBMS_SQL.COLUMN_VALUE(cid, 1, v_col);
    DBMS_SQL.COLUMN_VALUE(cid, 2, v_colType);
	DBMS_SQL.close_cursor(cid);

	edw_gen_view.getColumnMaps(dim_name, attColumns, multiAttList,
		flexColumns, fkColumns, level_name);

    /*  build skip_columns_table */
    l_count := 1;
    open C_Skip_Columns(dim_name, level_name);
    loop
        fetch C_Skip_Columns into skip_columns;
        exit when C_Skip_Columns%NOTFOUND;
        skip_columns_table (l_count).attribute_name := skip_columns.attribute_name;
        skip_columns_table (l_count).attribute_type := skip_columns.attribute_type;
        l_count := l_count + 1;
    end loop;


	srcview := ' CREATE OR REPLACE FORCE VIEW ' ||view_name || ' AS '||newline|| 'SELECT ';

	WHILE nOuterLoopCount < nColCount LOOP
		nOuterLoopCount := nOuterLoopCount + 1;

		curColumn := v_col(nOuterLoopCount);
        curColType   := v_colType(nOuterLoopCount);

        /* check if current column is a skipped column */
		IF (curColumn LIKE 'USER_ATTRIBUTE%' OR curColumn like 'USER_MEASURE%') THEN
	      null;
	    ELSE
	      nInnerLoopCount := 1;
	      IF (skip_columns_table.count > 0) THEN

    		LOOP
	   	       IF (skip_columns_table(nInnerLoopCount).attribute_name = curColumn) then
                  if (curColType = 'NUMBER') then
                      l_temp_stmt :=  ',' || newline || 'to_number(null) ' || curColumn;
                  --   edw_gen_view.writelog('Number Column. Adding to_number');
                  else
                      l_temp_stmt :=  ',' || newline || 'null ' || curColumn;
                  --  edw_gen_view.writelog('Skipped column, adding null');
                  end if;
                  srcview := srcview ||l_temp_stmt;
                  bColumnMapped := true;  -- to skip the part after nomatch
                  goto nomatch;
              end if;
    	      EXIT WHEN  nInnerLoopCount = skip_columns_table.last;
	         nInnerLoopCount := nInnerLoopCount + 1;
           end loop;
         end if;
       END IF;


		IF nOuterLoopCount >1 THEN
			srcview := srcview || ', '||newline;
		END IF;

		/* need to process only if its a user attribute */

		IF (curColumn LIKE 'USER_ATTRIBUTE%' OR curColumn like 'USER_MEASURE%') THEN
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
						edw_gen_view.writelog('attr mapped to attr: '||curColumn);
					END IF;

					IF (attColumns(nInnerLoopCount).datatype <> 'DATE') THEN
			 			srcview := srcview ||  attColumns(nInnerLoopCount).source_attribute
						 ||' '||curColumn ;
					ELSE
						 srcview := srcview ||  ' to_char('||attColumns(nInnerLoopCount).source_attribute||' , ''mm/dd/yyyy hh24:mi:ss'') '
                                                 ||' '||curColumn ;

					END IF;
					goto nomatch;
			 	END IF;

			 	EXIT WHEN  nInnerLoopCount = attColumns.last;
				nInnerLoopCount := nInnerLoopCount + 1;
			END LOOP;
		END IF;

		/* see if columns have been mapped to a source flex field */
		nInnerLoopCount := 1;
		IF (flexColumns.count > 0) THEN
		LOOP
				IF (g_log) THEN
					edw_gen_view.writelog('Checking column '||curColumn||' for flex mapping');
				END IF;

 			 	IF (flexColumns(nInnerLoopCount).attribute_name = curColumn) THEN
			 		bColumnMapped := true;

					IF (g_log) THEN
						edw_gen_view.writelog('attr mapped to flex: '||curColumn);
					END IF;
			 		-- decode flex

			 		decodeClause := edw_gen_view.getDecodeClauseForFlexCol( g_std_flex_view_name, curColumn, flexColumns(nInnerLoopCount).id_flex_code, flexColumns(nInnerLoopCount).flex_field_type);
			 		srcview := srcview || decodeClause||' '||curColumn;
			 		goto nomatch;
			 	 END IF;
			 	EXIT WHEN  nInnerLoopCount= flexColumns.last;
			 	nInnerLoopCount := nInnerLoopCount + 1;
 			END LOOP;
		END IF;

<<nomatch>>

		IF (bColumnMapped = false) THEN

			IF (curColumn like 'USER_ATTRIBUTE%' or curColumn like 'USER_MEASURE%') THEN
				srcview := srcview||'null ';
                        END IF;

			srcview := srcview || v_col(nOuterLoopCount);

		END IF;
		bColumnMapped := false;



	null;
	END LOOP;
	srcview := srcview|| ' FROM '||getGeneratedViewnameForStdDim(dim_name, level_name);

    srcview := replace (srcview, 'SELECT ', 'SELECT '||newline);

	IF (g_log) THEN

	edw_gen_view.writelog( srcview);
	edw_gen_view.writelog('Standard level view is : '||newline||srcview);
        edw_gen_view.writeout(srcview|| newline);
        edw_gen_view.writeOutLine('/');
        edw_gen_view.writeOutLine('EXIT;');

	END IF;

	edw_gen_view.createView(srcview, view_name);
	IF (g_log) THEN
	edw_gen_view.writelog('Completed generateStdLevel');
	edw_gen_view.indentEnd;

	END IF;

END;

Procedure generateStdDimension(dim_name IN VARCHAR2) IS


CURSOR dimLevels IS
	SELECT DISTINCT level_name FROM edw_attribute_mappings
	WHERE object_short_name = dim_name;

BEGIN
	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog('Inside generateStdDimension');
	END IF;

	FOR r1 in dimLevels LOOP
		generateStdLevel(dim_name, r1.level_name);
	END LOOP;

	IF (g_log) THEN
	edw_gen_view.writelog('Completed generateStdDimension');
	edw_gen_view.indentEnd;
	END IF;

END;


Procedure generateViewForDimension(dim_name in varchar2) IS

src_view varchar2(32000) := '';
l_count number := 1;

l_unionFlag boolean := false;
selectClause VARCHAR2(32000) := null;

l_buffer Varchar2(10000);
l_applsys_schema Varchar2(32);
dummy1 Varchar2(32);
dummy2 Varchar2(32);
l_retval Boolean;
l_dummy INTEGER;

stmt1 varchar2(250);
stmt2 varchar2(250);
stmt3 varchar2(250);

apiClause VARCHAR2(32000);

cursor c_getMappingsForDim(obj_name varchar2) is
	select value_set_type, value_set_id, parent_value_set_id
	from edw_flex_seg_mappings where
	dimension_short_name = obj_name
	and instance_code = edw_gen_view.g_instance
	order by value_set_type;


BEGIN

	edw_misc_util.globalNamesOff;


	IF (g_log) THEN
	edw_gen_view.indentBegin;

	edw_gen_view.writelog( 'Inside generateViewForDimension');
	edw_gen_view.writelog( 'Parameter dim_name:'||dim_name);
	END IF;

	IF (dim_name LIKE 'EDW_FLEX_DIM%' OR dim_name LIKE 'EDW_GL_ACCT%') THEN
		null;
	ELSE
		generateStdDimension(dim_name);
		RETURN;
	END IF;

	getViewnameForFlexdim(dim_name);

g_noOfMappings  := 0;
g_noOfTableVS   := 0;
g_noOfDepVS     := 0;
g_noOfIndepVS   := 0;
g_noOfNoneVS    := 0;

	getCountForVSTypes(dim_name);

	IF (g_noOfMappings = 0 ) THEN
		IF (g_log) THEN
            edw_gen_view.writelog(newline);
			edw_gen_view.Writelog('!!!!! No Mappings !!!! returning...');
		END IF;
		RETURN;
	END IF;

	 src_view := ' CREATE OR REPLACE FORCE VIEW '|| flexdim_viewname2 ||' AS '||newline;


	IF (g_noOfDepVS > 0) THEN
		selectClause := getDepVSClause(dim_name);
		l_unionFlag := true;
		IF (g_log) THEN
		edw_gen_view.writelog(newline);
		END IF;

	END IF;



	IF (g_noOfTableVS > 0) THEN
		IF (g_log) THEN
			edw_gen_view.writelog('table validated vs exists');
		END IF;

		IF (l_unionFlag = true) THEN
			selectClause := selectClause || newline||'UNION ALL '||newline;
		END IF;
		l_unionFlag := true;
		selectClause := selectClause || getTableValClause(dim_name);
		IF (g_log) THEN
			edw_gen_view.writelog(newline);

		END IF;
	END IF;

	IF (g_noOfIndepVS > 0) THEN
		IF (g_log) THEN
		  edw_gen_view.writelog('Independant value set type exists');
		END IF;
		IF (l_unionFlag = true) THEN
			selectClause := selectClause || newline||'UNION ALL '||newline;
		END IF;
		l_unionFlag := true;
		selectClause := selectClause||getIndepVSClause(dim_name, 'LOWER');

		IF (g_log) THEN
			edw_gen_view.writelog(newline);
		END IF;

	END IF;

	IF (g_noOfNoneVS > 0) THEN
		IF (g_log) THEN
		  edw_gen_view.writelog('None value set type exists');
		END IF;
		IF (l_unionFlag = true) THEN
			selectClause := selectClause ||newline|| 'UNION ALL '||newline;
		END IF;
		l_unionFlag := true;
		selectClause := selectClause||getNoneVSClause(dim_name);
		IF (g_log) THEN
			edw_gen_view.writelog(newline);
		END IF;

	END IF;

	src_view := src_view || selectClause;

	IF (g_log) THEN
	edw_gen_view.writelog( newline);
        edw_gen_view.writeout(src_view|| newline);
        edw_gen_view.writeOutLine('/');

	END IF;

    src_view := replace (src_view, 'SELECT ', 'SELECT '||newline);
    src_view := replace (src_view, ' FROM ', ' FROM '||newline );
    src_view := replace (src_view, ' WHERE ', ' WHERE '||newline );
	edw_gen_view.createView(src_view, flexdim_viewname2);


	IF (g_noOfDepVS > 0) THEN
		src_view := ' CREATE OR REPLACE FORCE VIEW '|| flexdim_viewname1 ||' AS ';
		src_view := src_view||newline||getIndepVSClause(dim_name, 'HIGHER');
	ELSE /* Create a default Upper level view */

	 src_view :=  	'CREATE OR REPLACE FORCE VIEW '||flexdim_viewname1 || ' as '||newline||'SELECT ''NA_EDW'' L1_PK, ''NA_EDW'' L1_FK, '||
		''''||edw_gen_view.g_instance||''''||' instance, null actual_value, '||newline||
		' null last_update_date, null description, null creation_date from dual where 1=2';

	END IF;

        edw_gen_view.createView(src_view, flexdim_viewname1);

	IF (g_log) THEN

                edw_gen_view.writeout(src_view|| newline);
                edw_gen_view.writeOutLine('/');
	edw_gen_view.writelog(newline);
	edw_gen_view.writelog( 'Completed generateViewForDimension!');
	edw_gen_view.writelog( '------------------------------------------------------------');
	edw_gen_view.indentEnd;

	END IF;
        edw_gen_view.writeOutLine('EXIT;');

END;
END EDW_DIM_SV;

/
