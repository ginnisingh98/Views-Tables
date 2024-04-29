--------------------------------------------------------
--  DDL for Package Body ECX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_UTILS" as
-- $Header: ECXUTILB.pls 120.11.12010000.2 2009/08/14 11:14:49 nandral ship $
l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;
DELETE_DOCTYPE_PROC_NAME CONSTANT	varchar2(50)	:=  'ECX_ACTIONS.DELETE_DOCTYPE';
/**
Prepares the Select statement for the ec_views on the base Applications tables.
**/
procedure select_clause
	(
        i_level       	IN 		pls_integer,
        i_Where_string  OUT	NOCOPY 	VARCHAR2
	) IS

i_method_name   varchar2(2000) := 'ecx_utils.select_clause';
cSelect_stmt    VARCHAR2(32000) := 'SELECT ';
cFrom_stmt      VARCHAR2(100) := ' FROM ';
cWhere_stmt	VARCHAR2(80) := ' WHERE 1=1 ';

cTO_CHAR	VARCHAR2(20) := 'TO_CHAR(';
cDATE		VARCHAR2(40) := ',''YYYYMMDD HH24MISS'')';
cWord1		VARCHAR2(20) := ' ';
cWord2		VARCHAR2(40) := ' ';

iRow_count	pls_integer := ecx_utils.g_source.COUNT;
i           	pls_integer;
BEGIN
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'i_level',i_level,i_method_name);
end if;

i := ecx_utils.g_source_levels(i_level).file_start_pos;
loop
   if (ecx_utils.g_source(i).external_level = i_level) then
      	-- **************************************
      	-- apply appropriate data conversion
      	-- convert everything to VARCHAR2
      	-- **************************************

      		if 12 = ecx_utils.g_source(i).data_type Then
         		cWord1 := cTO_CHAR;
         		cWord2 := cDATE;

      		elsif 2 = ecx_utils.g_source(i).data_type Then
         		cWord1 := cTO_CHAR;
         		cWord2 := ')';
      		else
         		cWord1 := NULL;
         		cWord2 := NULL;
      		END if;

      	-- build SELECT statement
       		cSelect_stmt :=  cSelect_stmt || ' ' || cWord1 ||
			nvl(ecx_utils.g_source(i).base_column_Name,'NULL') || cWord2 || ',';
   end if;
   exit when i= ecx_utils.g_source_levels(i_level).file_end_pos;
   i := ecx_utils.g_source.next(i);
End Loop;

   -- build FROM, WHERE statements

cFrom_stmt  := cFrom_Stmt||' '||ecx_utils.g_source_levels(i_level).base_table_name;

cSelect_stmt := RTRIM(cSelect_stmt, ',');
i_Where_string := cSelect_stmt||' '||cFrom_stmt||' '||cWhere_Stmt;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_Where_String',i_Where_String,i_method_name);
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when others then
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	                'PROGRESS_LEVEL','ECX_UTILS.SELect_CLAUSE');
	   ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	               'ERROR_MESSAGE',SQLERRM);
	end if;
        ecx_utils.error_type := 30;
	ecx_utils.i_ret_code :=2;
        raise ecx_utils.PROGRAM_EXIT;
END select_clause;

/**
Loads the Objects required by the Outbound transaction. This includes
1. Select statement on the ec_views.
3. Parses and loads Custom Procedures into memory table.
4. Loads mappings required by these procedures into memory tables.
**/
procedure load_objects
	(
	i_map_id	in	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_utils.load_objects';
i_counter	pls_integer :=0;
k               pls_integer;
i_root_element	ecx_objects.root_element%TYPE;
i_fullpath	ecx_objects.fullpath%TYPE;
i_dtd_path	varchar2(200);
l_clob          clob;

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if (ecx_utils.g_source_levels.COUNT >0) then
for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
LOOP
       if (i <> 0)
       then
	select_clause
		(
		i,
		ecx_utils.g_source_levels(i).sql_stmt
		);


	/** Call Append clause for all the levels **/
	ecx_actions.append_clause_for_view(10,i);

	/** No Need to clause. Is getting called in the Push and Pop of the level **/
        /* Execute Pre Processing STage
	ecx_actions.execute_stage_data
		(
		10,
		i,
		'S'
		);
	**/


        if(l_statementEnabled) then
            ecx_debug.log(l_statement,ecx_utils.g_source_levels(i).sql_stmt,i_method_name);
	end if;

	-- Open Cursor For Each level and store the handles in the PL/SQL table.
	ecx_utils.g_source_levels(i).Cursor_handle := dbms_sql.open_cursor;

        if(l_statementEnabled) then
                ecx_debug.log(l_statement,'Cursor handle',
		             ecx_utils.g_source_levels(i).Cursor_handle,i_method_name);
	end if;

	-- Parse the Select Statement for Each level
	BEGIN
		dbms_sql.parse	(
				ecx_utils.g_source_levels(i).cursor_handle,
				ecx_utils.g_source_levels(i).sql_stmt,
				dbms_sql.native
				);
	EXCEPTION
	WHEN OTHERS THEN
		ecx_error_handling_pvt.print_parse_error
				(
				dbms_sql.last_error_position,
				ecx_utils.g_source_levels(i).sql_stmt
				);


                if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'ECX','ECX_PROGRAM_ERROR',i_method_name,
		                 'PROGRESS_LEVEL','ECX_UTILS.LOAD_OBJECTS');
		    ecx_debug.log(l_statement,'ECX','ECX_PARSE_VIEW_ERROR',i_method_name,'LEVEL',i);
		    ecx_debug.log(l_statement, 'ECX', SQLERRM || ' - ECX_UTILS.LOAD_OBJECTS',i_method_name);
		end if;
                ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_UTILS.LOAD_OBJECTS');
		raise ecx_utils.PROGRAM_EXIT;
	END;

	i_counter :=0;
	-- Define Columns for Each Level
        k := ecx_utils.g_source_levels(i).file_start_pos;
	LOOP
             if (ecx_utils.g_source(k).external_level = i) then
			i_counter := i_counter + 1;
                /** Change required for Clob Support -- 2263729 ***/
                if ecx_utils.g_source(k).data_type <> 112 Then
			dbms_sql.define_column
				(
				ecx_utils.g_source_levels(i).Cursor_Handle,
				i_counter,
				ecx_utils.g_source_levels(i).sql_stmt,
				ecx_utils.G_VARCHAR_LEN
				);
                else
                       dbms_sql.define_column
                                (
                                ecx_utils.g_source_levels(i).Cursor_Handle,
                                i_counter,
                                l_clob
                                );
               end if;
           end if;
             exit when k = ecx_utils.g_source_levels(i).file_end_pos;
             k := ecx_utils.g_source.next(k);
	END LOOP;
       end if;

END LOOP;
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
EXCEPTION
WHEN ecx_utils.PROGRAM_EXIT then
        raise ecx_utils.program_exit;
WHEN OTHERS THEN
        if(l_unexpectedEnabled) then
                 ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
		              'PROGRESS_LEVEL',
		              'ECX_UTILS.LOAD_OBJECTS');
                 ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
		              'ERROR_MESSAGE',SQLERRM);
                 ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' -  ECX_UTILS.LOAD_OBJECTS',i_method_name);
        end if;
        ecx_debug.setErrorInfo(2, 30, SQLERRM || ' -  ECX_UTILS.LOAD_OBJECTS');
        raise ecx_utils.PROGRAM_EXIT;
end load_objects;

procedure load_procedure_mappings (
   i_map_id        IN     pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_utils.load_procedure_mappings';
   cursor proc_mapping (
          p_map_id  pls_integer) IS
   select epm.transtage_id                  transtage_id,
          upper(etsd.custom_procedure_name) procedure_name,
          upper(epm.parameter_name)         parameter_name,
          epm.action_type                   action_type,
          epm.variable_level                variable_level,
          epm.variable_name          variable_name,
          epm.variable_pos                  variable_pos,
          epm.data_type                     data_type,
	  nvl(epm.variable_direction,'S')   variable_direction,
	  epm.variable_value		variable_constant
   from   ecx_proc_mappings epm,
          ecx_tran_stage_data etsd
   where  etsd.transtage_id = epm.transtage_id
   and    etsd.map_id = p_map_id
   and	  epm.map_id = p_map_id
   order  by epm.transtage_id,procmap_id;

   i      pls_integer := 0;

BEGIN
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_map_id',i_map_id,i_method_name);
   end if;
   ecx_utils.g_procedure_mappings.DELETE;

   for proc_map in proc_mapping (i_map_id) loop
      i := i + 1;
      ecx_utils.g_procedure_mappings(i).transtage_id := proc_map.transtage_id;
      ecx_utils.g_procedure_mappings(i).procedure_name := proc_map.procedure_name;
      ecx_utils.g_procedure_mappings(i).parameter_name := proc_map.parameter_name;
      ecx_utils.g_procedure_mappings(i).action_type := proc_map.action_type;
      ecx_utils.g_procedure_mappings(i).variable_level := proc_map.variable_level;
      ecx_utils.g_procedure_mappings(i).variable_name := proc_map.variable_name;
      ecx_utils.g_procedure_mappings(i).variable_pos := proc_map.variable_pos;
      ecx_utils.g_procedure_mappings(i).variable_direction := proc_map.variable_direction;
      ecx_utils.g_procedure_mappings(i).data_type := proc_map.data_type;
      ecx_utils.g_procedure_mappings(i).variable_constant := proc_map.variable_constant;

      if(l_statementEnabled) then
        ecx_debug.log(l_statement, ecx_utils.g_procedure_mappings(i).tranStage_id ||'|'||
                      ecx_utils.g_procedure_mappings(i).procedure_name||'|'||
                      ecx_utils.g_procedure_mappings(i).parameter_name||'|'||
                      ecx_utils.g_procedure_mappings(i).action_type||'|'||
                      ecx_utils.g_procedure_mappings(i).variable_level||'|'||
                      ecx_utils.g_procedure_mappings(i).variable_name||'|'||
                      ecx_utils.g_procedure_mappings(i).variable_pos ||'|'||
                      ecx_utils.g_procedure_mappings(i).variable_direction ||'|'||
                      ecx_utils.g_procedure_mappings(i).data_type||'|'||
                      ecx_utils.g_procedure_mappings(i).variable_constant,i_method_name);
      end if;
   end loop;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

EXCEPTION
   WHEN PROGRAM_EXIT then

      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR','PROGRESS_LEVEL',i_method_name,
                  'ecx_utils.LOAD_PROCEDURE_MAPPINGS');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
        ecx_debug.log(l_unexpected, 'ECX',
	             ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.LOAD_PROCEDURE_MAPPINGS: ',
		     i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM ||
                             ' - ecx_utils.LOAD_PROCEDURE_MAPPINGS: ');
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;
end load_procedure_mappings;

procedure load_procedure_definitions (
   i_map_id        IN    pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_utils.load_procedure_definitions';
   cursor proc_definition is
   select transtage_id,
          custom_procedure_name
   from   ecx_tran_stage_data etsd
   where  etsd.map_id = i_map_id
   and action_type = 1050;

   l_transtage_id      pls_integer;
   l_proc_name         Varchar2(80);

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   ecx_utils.g_procedure_list.DELETE;
   -- load all the procedure definitions and build the cursor
   for get_proc_def in proc_definition loop
      l_transtage_id := get_proc_def.transtage_id;
      l_proc_name := upper(get_proc_def.custom_procedure_name);

      ecx_utils.g_procedure_list(l_transtage_id).procedure_name := l_proc_name;
      build_procedure_call (l_transtage_id, l_proc_name,
                            ecx_utils.g_procedure_list(l_transtage_id).cursor_handle);
   end loop;

   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
                    'PROGRESS_LEVEL',
                  'ecx_utils.LOAD_PROCEDURE_DEFINITIONS');
       ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
       ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' -  ecx_utils.LOAD_PROCEDURE_DEFINITIONS:',
                   i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM ||
                             ' -  ecx_utils.LOAD_PROCEDURE_DEFINITIONS: ');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;

END;


procedure build_procedure_call (
   p_transtage_id     IN         pls_integer,
   p_procedure_name   IN         Varchar2,
   x_proc_cursor      OUT NOCOPY pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_utils.build_procedure_call';
   error_position     pls_integer;
   l_proc_call        Varchar2(32000);
   l_first_param      Boolean := True;
   parse_error        EXCEPTION;

BEGIN
   if (l_procedureEnabled) then
    ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
    ecx_debug.log(l_statement,'p_transtage_id',p_transtage_id,i_method_name);
    ecx_debug.log(l_statement,'p_procedure_name',p_procedure_name,i_method_name);
   end if;
   l_proc_call := 'BEGIN ' || p_procedure_name || '(';

   if (ecx_utils.g_procedure_mappings.count <> 0)
   then
      for i in ecx_utils.g_procedure_mappings.first..ecx_utils.g_procedure_mappings.last
      loop
         if (ecx_utils.g_procedure_mappings(i).transtage_id = p_transtage_id) and
	    (ecx_utils.g_procedure_mappings(i).procedure_name = p_procedure_name) then

	    if not (l_first_param) then
	       l_proc_call := l_proc_call || ', ';
	    else
	       l_first_param := false;
            end if;

	    l_proc_call := l_proc_call || ecx_utils.g_procedure_mappings(i).parameter_name ||
                        ' => :'  || ecx_utils.g_procedure_mappings(i).parameter_name;
	 end if;
      end loop;
  end if;

   l_proc_call := l_proc_call || '); END;';
   ecx_utils.g_procedure_list(p_transtage_id).procedure_call := l_proc_call;

   for i in ecx_utils.g_procedure_list.first..ecx_utils.g_procedure_list.last-1
   loop
   if(ecx_utils.g_procedure_list.EXISTS(i) and ecx_utils.g_procedure_list(i).procedure_call = l_proc_call) then
     x_proc_cursor := ecx_utils.g_procedure_list(i).cursor_handle;
     if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'proc_call', l_proc_call,i_method_name);
       ecx_debug.log(l_statement,'x_proc_cursor',x_proc_cursor,i_method_name);
     end if;
     if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
     end if;
     return;
   end if;
   end loop;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement, 'proc_call', l_proc_call,i_method_name);
   end if;
   x_proc_cursor := dbms_sql.open_cursor;
   BEGIN
      dbms_sql.parse (x_proc_cursor, l_proc_call, dbms_sql.native);
   EXCEPTION
      when others then
         raise parse_error;
   END;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'x_proc_cursor',x_proc_cursor,i_method_name);
   end if;
   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;
EXCEPTION
   WHEN PARSE_ERROR then
      error_position := dbms_sql.last_error_position;
      ecx_error_handling_pvt.print_parse_error (error_position, l_proc_call);
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ecx_utils.BUILD_PROCEDURE_CALL');
        ecx_debug.log(l_unexpected, 'ECX', 'ECX_PARSE_ERROR', i_method_name);
      end if;
      ecx_debug.setErrorInfo(1, 25, 'ECX_PARSE_ERROR');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise program_exit;

   WHEN PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_statementEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ecx_utils.BUILD_PROCEDURE_CALL');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	             'ERROR_MESSAGE',SQLERRM);
        ecx_debug.log(l_unexpected, 'ECX',
	             ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.BUILD_PROCEDURE_CALL: ',
	             i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.BUILD_PROCEDURE_CALL: ');

      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;

END build_procedure_call;

procedure print_nodes
	(
	i		in		pls_integer,
	g_source	IN		dtd_node_tbl
	)
is
i_method_name   varchar2(2000) := 'ecx_utils.print_nodes';
begin
	if (g_source.EXISTS(i))
	then

           if(l_statementEnabled) then
                   ecx_debug.log(l_statement, i || '|'||
                   g_source(i).attribute_id || '|' ||
                   g_source(i).parent_attribute_id || '|' ||
                   g_source(i).external_level || '|' ||
                   g_source(i).attribute_name || '|' ||
                   g_source(i).occurrence || '|' ||
                   g_source(i).map_attribute_id || '|' ||
                   g_source(i).attribute_type || '|' ||
                   g_source(i).default_value || '|' ||
                   g_source(i).data_type || '|' ||
                   g_source(i).cond_node || '|' ||
                   g_source(i).cond_node_type || '|' ||
                   g_source(i).cond_value || '|' ||
                   g_source(i).parent_node_map_id || '|' ||
                   g_source(i).has_attributes || '|' ||
                   g_source(i).leaf_node,i_method_name);
            end if;
	end if;
end print_nodes;

procedure load_attributes
	(
   	i_map_id        	IN    		pls_integer,
   	i_level_id	   	IN		pls_integer,
   	i_object_level  	IN		pls_integer,
	g_tbl			IN OUT NOCOPY 	dtd_node_tbl,
	g_level			IN OUT NOCOPY	level_tbl
	) is
i_method_name   varchar2(2000) := 'ecx_utils.load_attributes';

/*	TYPE object_record is RECORD
	(
	attribute_id                    ecx_object_attributes.attribute_id%TYPE,
	attribute_name                  ecx_object_attributes.attribute_name%TYPE,
	parent_attribute_id             ecx_object_attributes.parent_attribute_id%TYPE,
	base_column_name                varchar2(500),--ecx_object_attributes.object_column_flag%TYPE,
	xref_category_id                ecx_object_attributes.xref_category_id%TYPE,
	attribute_type                  ecx_object_attributes.attribute_type%TYPE,
	default_value                   ecx_object_attributes.default_value%TYPE,
	data_type                       ecx_object_attributes.data_type%TYPE,
	has_attributes                  ecx_object_attributes.has_attributes%TYPE,
	leaf_node                       ecx_object_attributes.leaf_node%TYPE,
	occurrence                      ecx_object_attributes.occurrence%TYPE,
	cond_value                      ecx_object_attributes.cond_value%TYPE,
	cond_node                       ecx_object_attributes.cond_node%TYPE,
	cond_node_type                  ecx_object_attributes.cond_node_type%TYPE,
	source_attribute_id             ecx_attribute_mappings.SOURCE_ATTRIBUTE_ID%TYPE
	);


	TYPE object_rec_table is TABLE of object_record index by BINARY_INTEGER;
	obj_rec_table object_rec_table;
*/

	TYPE t_attribute_id is TABLE of ecx_object_attributes.attribute_id%TYPE;
	TYPE t_attribute_name is TABLE of ecx_object_attributes.attribute_name%TYPE;
	TYPE t_parent_attribute_id is TABLE of ecx_object_attributes.parent_attribute_id%TYPE;
	TYPE t_base_column_name is TABLE of varchar2(500);--ecx_object_attributes.object_column_flag%TYPE,
	TYPE t_xref_category_id is TABLE of ecx_object_attributes.xref_category_id%TYPE;
	TYPE t_attribute_type is TABLE of ecx_object_attributes.attribute_type%TYPE;
	TYPE t_default_value is TABLE of ecx_object_attributes.default_value%TYPE;
	TYPE t_data_type is TABLE of ecx_object_attributes.data_type%TYPE;
	TYPE t_has_attributes is TABLE of ecx_object_attributes.has_attributes%TYPE;
	TYPE t_leaf_node is TABLE of ecx_object_attributes.leaf_node%TYPE;
	TYPE t_occurrence is TABLE of ecx_object_attributes.occurrence%TYPE;
	TYPE t_cond_value is TABLE of ecx_object_attributes.cond_value%TYPE;
	TYPE t_cond_node is TABLE of ecx_object_attributes.cond_node%TYPE;
	TYPE t_cond_node_type is TABLE of ecx_object_attributes.cond_node_type%TYPE;
	TYPE t_source_attribute_id is TABLE of ecx_attribute_mappings.SOURCE_ATTRIBUTE_ID%TYPE;
	TYPE t_required_flag is TABLE of ecx_object_attributes.required_flag%TYPE;

	v_attribute_id t_attribute_id;
	v_attribute_name t_attribute_name;
	v_parent_attribute_id t_parent_attribute_id;
	v_base_column_name t_base_column_name;
	v_xref_category_id t_xref_category_id;
	v_attribute_type t_attribute_type;
	v_default_value t_default_value;
	v_data_type t_data_type;
	v_has_attributes t_has_attributes;
	v_leaf_node t_leaf_node;
	v_occurrence t_occurrence;
	v_cond_value t_cond_value;
	v_cond_node t_cond_node;
	v_cond_node_type t_cond_node_type;
	v_source_attribute_id t_source_attribute_id;
	v_required_flag t_required_flag;

	TYPE dtd_map is RECORD
	(
	source_attribute_id                    ecx_attribute_mappings.source_attribute_id%TYPE
	);


	TYPE dtd_map_table is TABLE of dtd_map index by BINARY_INTEGER;

	dtd_map_tbl dtd_map_table;


/** Cursor for Loading Attributes **/
/*
cursor object_rec
	(
        p_map_id 	IN 	pls_integer,
	p_level_id	IN	pls_integer
	) IS
   select attribute_id,
          attribute_name,
          parent_attribute_id,
          decode(object_column_flag,'Y',attribute_name,null) base_column_name,
          xref_category_id,
          attribute_type,
          default_value,
          data_type,
          has_attributes,
          leaf_node,
          occurrence,
          cond_value,
          cond_node,
          cond_node_type
   from   ecx_object_attributes eoa
   where  eoa.map_id = p_map_id
   and    eoa.objectlevel_id = p_level_id
   order by attribute_id;

   cursor dtd_map (
          p_map_id  		IN pls_integer,
          p_attribute_id 	IN pls_integer ) IS
   select source_attribute_id
   from   ecx_attribute_mappings eam
   where  eam.target_attribute_id = p_attribute_id
   and 	  eam.map_id = p_map_id;
*/
   l_dtd_id           pls_integer;
   l_map_type         Varchar2(20);
   i                  pls_integer := 0;
   j                  pls_integer;
   k                  pls_integer := 1;
   no_seed_data       EXCEPTION;

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_map_id', i_map_id,i_method_name);
  ecx_debug.log(l_statement,'i_level_id',i_level_id,i_method_name);
  ecx_debug.log(l_statement,'i_object_level',i_object_level,i_method_name);
end if;
	select
	    a.attribute_id,
	    a.attribute_name,
	    a.parent_attribute_id,
	    decode(a.object_column_flag,'Y',attribute_name,null) base_column_name,
	    a.xref_category_id,
	    a.attribute_type,
	    a.default_value,
	    a.data_type,
	    a.has_attributes,
	    a.leaf_node,
            a.required_flag,
	    a.occurrence,
	    a.cond_value,
	    a.cond_node,
	    a.cond_node_type,
		m.SOURCE_ATTRIBUTE_ID source_attribute_id

	bulk collect into
--	obj_rec_table

	v_attribute_id,
	v_attribute_name,
	v_parent_attribute_id,
	v_base_column_name,
	v_xref_category_id ,
	v_attribute_type,
	v_default_value,
	v_data_type,
	v_has_attributes,
	v_leaf_node,
        v_required_flag,
	v_occurrence,
	v_cond_value,
	v_cond_node,
	v_cond_node_type,
	v_source_attribute_id

	from   ecx_object_attributes a,
		   ecx_attribute_mappings m
	where  a.map_id = i_map_id
	and    a.objectlevel_id = i_level_id
	and	   m.map_id (+) = i_map_id
	and	   m.TARGET_ATTRIBUTE_ID (+) = a.ATTRIBUTE_ID
	order by a.attribute_id;


--	if obj_rec_table.COUNT > 0	then
	if v_attribute_id.COUNT > 0	then
	for c1 in v_attribute_id.FIRST..v_attribute_id.LAST
--	      for c1 in object_rec(i_map_id,i_level_id)
      loop
          i := v_attribute_id(c1);
          g_tbl(i).attribute_id := v_attribute_id(c1);
          g_tbl(i).attribute_name := v_attribute_name(c1);
          g_tbl(i).parent_attribute_id := v_parent_attribute_id(c1);
          g_tbl(i).attribute_type := v_attribute_type(c1);
          g_tbl(i).default_value := v_default_value(c1);
          g_tbl(i).data_type := v_data_type(c1);
          g_tbl(i).external_level := i_object_level;
          g_tbl(i).internal_level := i_object_level;
          g_tbl(i).has_attributes := v_has_attributes(c1);
          g_tbl(i).leaf_node := v_leaf_node(c1);
          g_tbl(i).base_column_name := v_base_column_name(c1);
          g_tbl(i).xref_category_id := v_xref_category_id(c1);
          g_tbl(i).cond_node_type := v_cond_node_type(c1);
          g_tbl(i).cond_node := v_cond_node(c1);
          g_tbl(i).cond_value := v_cond_value(c1);
          g_tbl(i).occurrence := v_occurrence(c1);
	  g_tbl(i).map_attribute_id := v_source_attribute_id(c1);
          g_tbl(i).required_flag := v_required_flag(c1);

	/** Find the Start element for this Level **/
	--if i_object_level <> 0
	--then
          --if (g_tbl(i).attribute_name = g_level(i_object_level).start_element) then
             --g_level(i_object_level).dtd_node_index := i;
             --ecx_debug.log(3, 'dtd_node_index', g_level(i_object_level).dtd_node_index || ' at level' || i_object_level);
          --end if;

-- 		  select source_attribute_id
-- 		  bulk collect into dtd_map_tbl
-- 		   from   ecx_attribute_mappings eam
-- 		   where  eam.target_attribute_id = obj_rec_table(c1).attribute_id
-- 		   and 	  eam.map_id = i_map_id;
-- 			if dtd_map_tbl.COUNT > 1 then
-- 			dbms_output.put_line('dtd_map_tbl.COUNT=' || dtd_map_tbl.COUNT);
-- 			end if;
--
-- 			if dtd_map_tbl.COUNT > 0	then
-- 	          	for c2 in dtd_map_tbl.FIRST..dtd_map_tbl.LAST
-- 			  	loop
-- 	             		g_tbl(i).map_attribute_id := dtd_map_tbl(c2).source_attribute_id;
-- 	          	end loop;
-- 			end if;
--           	for c2 in dtd_map (
-- 			i_map_id,
-- 			obj_rec_table(c1).attribute_id
-- 			)
-- 	  	loop
--              		g_tbl(i).map_attribute_id := c2.source_attribute_id;
--           	end loop;

		if i_object_level = 0
                then
                   g_level(i_object_level).file_start_pos := 0;
                else
       		   if (g_level(i_object_level).file_start_pos = 0) then
          		g_level(i_object_level).file_start_pos := i;
       		   end if;
                end if;
      end loop;
	  end if;

      if (g_tbl.COUNT <> 0)
      then
   	 g_level(i_object_level).file_end_pos := i;
--       	 for i in g_level(i_object_level).file_start_pos..g_level(i_object_level).file_end_pos
-- 	 loop
-- 	 	print_nodes(i,g_tbl);
--          end loop;
      end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
   WHEN PROGRAM_EXIT then
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	               'PROGRESS_LEVEL',
                  'ECX_UTILS.LOAD_ATTRIBUTES');
           ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
           ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.LOAD_ATTRIBUTES: ',
	                i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.LOAD_ATTRIBUTES: ');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;
end LOAD_ATTRIBUTES;

/* This procedure is called by the Inbound/Outbound Engine to Load Source and the Target */
procedure load_dtd_nodes(
   i_map_id        IN    pls_integer,
   i_level_id	   IN	pls_integer,
   i_object_level  IN	pls_integer,
   i_source	   IN	boolean) IS

   i_method_name   varchar2(2000) := 'ecx_utils.load_dtd_nodes';
   l_dtd_id           pls_integer;
   l_map_type         Varchar2(20);
   i                  pls_integer := 0;
   j                  pls_integer;
   k                  pls_integer := 1;
   no_seed_data       EXCEPTION;

BEGIN
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
       ecx_debug.log(l_statement,'i_map_id', i_map_id,i_method_name);
       ecx_debug.log(l_statement,'i_level_id',i_level_id,i_method_name);
       ecx_debug.log(l_statement,'i_object_level',i_object_level,i_method_name);
       ecx_debug.log(l_statement,'i_source',i_source,i_method_name);
   end if;

   	if ( i_source )
   	then
		load_attributes(i_map_id,i_level_id,i_object_level,ecx_utils.g_source,ecx_utils.g_source_levels);
	else
		load_attributes(i_map_id,i_level_id,i_object_level,ecx_utils.g_target,ecx_utils.g_target_levels);
	end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN NO_SEED_DATA then
      ecx_debug.setErrorInfo(1, 30, 'ECX_SEED_DATA_NOT_FOUND', 'MAP_ID', i_map_id);

      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_SEED_DATA_FOUND',i_method_name,'MAP_ID', i_map_id);
      end if;
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;

   WHEN PROGRAM_EXIT then
      ecx_debug.pop('ECX_UTILS.LOAD_DTD_NODES');
      raise;
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	              'PROGRESS_LEVEL',
                  'ECX_UTILS.LOAD_DTD_NODES');
         ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.LOAD_DTD_NODES',
	              i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.LOAD_DTD_NODES');

      if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;
END LOAD_DTD_NODES;

procedure createDummyData(
	root_level_found	IN OUT	NOCOPY Boolean)
is


   /* Source Level 0 cursor */
   cursor get_level_zero (
          p_map_id               IN     pls_integer) IS
   select objectlevel_id,
          object_level,
          object_level_name,
	  parent_level
   from   ecx_object_levels eol,
	  ecx_mappings em
   where  eol.map_id = p_map_id
   and	  eol.map_id = em.map_id
   and	  eol.object_id = 1
   and    eol.object_level = 0
   order by objectlevel_id;

begin

   -- we need load dummy data for g_source, g_target, g_source_levels
   --dummy data for g_source_levels can be gotten from ecx_object_levels
   for c_level_zero in get_level_zero(p_map_id=>g_map_id)
   loop
      -- should return only one match
      ecx_utils.g_source_levels(0).level := c_level_zero.object_level;
      ecx_utils.g_source_levels(0).parent_level := c_level_zero.parent_level;
      ecx_utils.g_source_levels(0).start_element := c_level_zero.object_level_name;
      ecx_utils.g_source_levels(0).base_table_name := c_level_zero.object_level_name;
      ecx_utils.g_source_levels(0).sql_stmt := NULL;
      ecx_utils.g_source_levels(0).cursor_handle := null;
      ecx_utils.g_source_levels(0).file_start_pos := 0;
      ecx_utils.g_source_levels(0).file_end_pos := 0;
      ecx_utils.g_source_levels(0).dtd_node_index := 0;
   end loop;

   ecx_utils.g_source(0).attribute_id := 0;
   ecx_utils.g_source(0).attribute_name := ecx_utils.g_source_levels(0).start_element;
   ecx_utils.g_source(0).parent_attribute_id := 0;
   ecx_utils.g_source(0).attribute_type := 1;
   ecx_utils.g_source(0).default_value := null;
   ecx_utils.g_source(0).data_type := null;
   ecx_utils.g_source(0).external_level := 0;
   ecx_utils.g_source(0).internal_level := 0;
   ecx_utils.g_source(0).has_attributes := 0;
   ecx_utils.g_source(0).leaf_node := 0;

   -- load all level 0 attributes
   load_dtd_nodes( g_map_id,0, 0,true);

   ecx_utils.g_target(0).attribute_id := 0;
   ecx_utils.g_target(0).attribute_name := ecx_utils.g_target_levels(0).start_element;
   ecx_utils.g_target(0).parent_attribute_id := 0;
   ecx_utils.g_target(0).attribute_type := 1;
   ecx_utils.g_target(0).default_value := null;
   ecx_utils.g_target(0).data_type := null;
   ecx_utils.g_target(0).external_level := 0;
   ecx_utils.g_target(0).internal_level := 0;
   ecx_utils.g_target(0).has_attributes := 0;
   ecx_utils.g_target(0).leaf_node := 0;

   ecx_utils.g_target_source_levels(0).source_level := 0;
   ecx_utils.g_target_source_levels(0).target_level := 0;

   root_level_found := TRUE;
end createDummyData;


procedure load_mappings (
   i_map_id               in     pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_utils.load_mappings';

/*   	TYPE target_record
	 is RECORD (target_level_id ecx_object_levels.objectlevel_id%TYPE,
         	   target_level ecx_object_levels.object_level%TYPE,
         	   target_level_name ecx_object_levels.object_level_name%TYPE,
	 		   parent_level ecx_object_levels.parent_level%TYPE);

	TYPE target_record_table is TABLE of target_record index by BINARY_INTEGER;
	targ_rec_table target_record_table;
*/
   	TYPE t_target_level_id  is TABLE of ecx_object_levels.objectlevel_id%TYPE;
   	TYPE t_target_level  is TABLE of ecx_object_levels.object_level%TYPE;
   	TYPE t_target_level_name  is TABLE of ecx_object_levels.object_level_name%TYPE;
   	TYPE t_parent_level  is TABLE of ecx_object_levels.parent_level%TYPE;

	v_target_level_id t_target_level_id;
	v_target_level t_target_level;
	v_target_level_name t_target_level_name;
	v_parent_level t_parent_level;


   /*
   **  This cursor loads the details of the Target level
   */
/*   cursor target_rec (
          p_map_id               IN     pls_integer) IS
   select objectlevel_id target_level_id,
          object_level target_level,
          object_level_name target_level_name,
	  parent_level
   from   ecx_object_levels eol,
	  ecx_mappings em
   where  eol.map_id = p_map_id
   and	  eol.map_id = em.map_id
   and	  eol.object_id = em.object_id_target
   order by target_level;
*/
/*

   	TYPE target_source_record
	 is RECORD (source_level ecx_object_levels.object_level%TYPE,
         	   level_mapping_id ecx_level_mappings.level_mapping_id%TYPE,
         	   source_level_id ecx_object_levels.objectlevel_id%TYPE,
	 		   source_element_id ecx_level_mappings.source_element_id%TYPE,
			   target_element_id ecx_level_mappings.target_element_id%TYPE
			   );

	TYPE target_source_record_table is TABLE of target_source_record index by BINARY_INTEGER;
	targ_src_rec_table target_source_record_table;
*/
	TYPE t_source_level is TABLE of ecx_object_levels.object_level%TYPE;
	TYPE t_level_mapping_id  is TABLE of ecx_level_mappings.level_mapping_id%TYPE;
	TYPE t_source_level_id  is TABLE of ecx_object_levels.objectlevel_id%TYPE;
	TYPE t_source_element_id  is TABLE of ecx_level_mappings.source_element_id%TYPE;
	TYPE t_target_element_id  is TABLE of ecx_level_mappings.target_element_id%TYPE;


	v_source_level t_source_level;
    v_level_mapping_id t_level_mapping_id;
    v_source_level_id t_source_level_id;
    v_source_element_id t_source_element_id;
    v_target_element_id t_target_element_id;

   /*
   ** This cursor loads the details of the relationship between
   ** target and source level
   */
   /*
   cursor target_source_rec (
          p_map_id               IN     pls_integer,
          p_target_id          IN     pls_integer) IS
   select object_level source_level,
          level_mapping_id ,
          objectlevel_id source_level_id,
	  source_element_id,
	  target_element_id
   from   ecx_level_mappings   elm,
          ecx_object_levels eol
   where  elm.target_level_id  = p_target_id
   and    elm.map_id = p_map_id
   and    elm.map_id = eol.map_id
   and    elm.source_level_id  = eol.objectlevel_id;
   */
   /* Source Level Details Cursor */
   cursor source_rec (
          p_map_id               IN     pls_integer,
          p_source_level_id   IN     pls_integer) IS
   select object_level source_level,
          object_level_name source_level_name,
          parent_level,
          objectlevel_id
   from   ecx_object_levels
   where  objectlevel_id = p_source_level_id
   and    map_id  = p_map_id;


   j_count              pls_integer := 0;
   int_loaded           Boolean := False;
   int_ext_loaded       Boolean := False;
   cur_ext_level        pls_integer := 0;
   pre_int_level        pls_integer := 0;
   cur_int_level        pls_integer := 0;
   l_level_mapping_id   pls_integer := 0;
   i_object_id_source	pls_integer;
   i_object_id_target	pls_integer;
   first_time		Boolean	     := true;
   root_level_found	Boolean	     := false;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_map_id',i_map_id,i_method_name);
   end if;

   ecx_utils.g_source_levels.DELETE;
   ecx_utils.g_target_levels.DELETE;
   ecx_utils.g_target_source_levels.DELETE;
   ecx_utils.g_target.DELETE;
   ecx_utils.g_source.DELETE;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'ECX','ECX_LOADING_LEVELS',i_method_name,
                  'LEVEL','Loading Target levels');
   end if;
   -- Loading Target level information.

	select objectlevel_id target_level_id,
	    object_level target_level,
	    object_level_name target_level_name,
		parent_level
	bulk collect into
--	targ_rec_table

	v_target_level_id,
	v_target_level,
	v_target_level_name,
	v_parent_level

	from   ecx_object_levels eol,
	ecx_mappings em
	where  eol.map_id = i_map_id
	and	  eol.map_id = em.map_id
	and	  eol.object_id = em.object_id_target
	order by target_level;

--   if targ_rec_table.COUNT > 0 then
--   for j in targ_rec_table.FIRST..targ_rec_table.LAST
   if v_target_level_id.COUNT > 0 then
   for j in v_target_level_id.FIRST..v_target_level_id.LAST
--   for c1 in target_rec ( p_map_id => i_map_id )
   loop
--      ecx_debug.log(3,'Target Level Id',targ_rec_table(j).target_level_id||' Target Level =>'||targ_rec_table(j).target_level);
      cur_ext_level := v_target_level(j);
      ecx_utils.g_target_levels(cur_ext_level).level := cur_ext_level;
      ecx_utils.g_target_levels(cur_ext_level).level := v_parent_level(j);
      ecx_utils.g_target_levels(cur_ext_level).start_element   := v_target_level_name(j);
      ecx_utils.g_target_levels(cur_ext_level).base_table_name := v_target_level_name(j);
      ecx_utils.g_target_levels(cur_ext_level).sql_stmt := NULL;
      ecx_utils.g_target_levels(cur_ext_level).cursor_handle := null;
      ecx_utils.g_target_levels(cur_ext_level).file_start_pos := 0;
      ecx_utils.g_target_levels(cur_ext_level).file_end_pos := 0;
      ecx_utils.g_target_levels(cur_ext_level).dtd_node_index := 0;
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'External Level ('|| cur_ext_level||')',
                  ecx_utils.g_target_levels(cur_ext_level).level,i_method_name);
         ecx_debug.log(l_statement, 'External Level ('||cur_ext_level||') Object Name: '
                      || 'start_element: ' || ecx_utils.g_target_levels (cur_ext_level).start_element,
		      i_method_name);
      end if;

      /** Load the Target Object Attributes **/
      load_dtd_nodes( i_map_id,v_target_level_id(j),v_target_level(j),false);

--      ecx_debug.log(3,'ECX','ECX_LOADING_LEVELS','LEVEL','Loading Levels Matrices');
      int_ext_loaded := False;

      -- Loading target and source information.
--      ecx_debug.log(3, 'Target Level Id', targ_rec_table(j).target_level_id );
if(l_statementEnabled) then
	      ecx_debug.log(l_statement,'ECX','ECX_LOADING_LEVELS','LEVEL','Loading Levels Matrices', i_method_name);
	      ecx_debug.log(l_statement, 'Target Level Id', v_target_level_id(j) , i_method_name);
end if;

	   select object_level source_level,
	          level_mapping_id ,
	          objectlevel_id source_level_id,
		  source_element_id,
		  target_element_id
	   bulk collect into
--	   targ_src_rec_table
	   	v_source_level,
	    v_level_mapping_id,
	    v_source_level_id,
	    v_source_element_id,
	    v_target_element_id

	   from   ecx_level_mappings   elm,
	          ecx_object_levels eol
	   where  elm.target_level_id  = v_target_level_id(j)
	   and    elm.map_id = i_map_id
	   and    elm.map_id = eol.map_id
	   and    elm.source_level_id  = eol.objectlevel_id;

--	  if targ_src_rec_table.COUNT > 0 then
--	  for k in targ_src_rec_table.FIRST..targ_src_rec_table.LAST
	  if v_source_level.COUNT > 0 then
	  for k in v_source_level.FIRST..v_source_level.LAST
--      for c2 in target_source_rec (
--          p_map_id => i_map_id,
--          p_target_id => targ_rec_table(j).target_level_id)
		 loop

         int_ext_loaded := True;
         cur_int_level := v_source_level(k);

         -- check if Zero level mapping is present in the map. If not, then we need to
	 -- load the dummy data for this
	 if (cur_ext_level = 0 AND cur_int_level = 0)
         then
            --set the boolean for the root element
	    root_level_found := TRUE;
         end if;

         -- get the correct index for level_mapping
	 -- if the map has level 0 mapping information then startthe index from 0
	 -- else start the index from 1
         if(v_target_level(j) = 0 AND (first_time))
         then
            --this is the new 0 level mapping, so start j_count from 0
            j_count := 0;
         elsif(v_target_level(j) = 1 AND (first_time))
         then
            --this is the old 1 level mapping, so start j_count from 1
            j_count := 1;
         end if;
         ecx_utils.g_target_source_levels(j_count).source_level := cur_int_level;
         ecx_utils.g_target_source_levels(j_count).target_level := cur_ext_level;
if(l_statementEnabled) then
	 ecx_debug.log(l_statement,'Source and target Node Index ',v_source_element_id(k)||' '||v_target_element_id(k), i_method_name);
end if;
	 j_count := j_count + 1;

	 /** Update the Target Node Index **/
	 ecx_utils.g_target_levels(cur_ext_level).dtd_node_index := v_target_element_id(k);
     if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'Target Node_index', g_target_levels(cur_ext_level).dtd_node_index ||
		' at level' || cur_ext_level, i_method_name);
         ecx_debug.log(l_statement, 'Internal Level '|| cur_int_level||' External Level '
                     || cur_ext_level, i_method_name);

	         ecx_debug.log(l_statement,'Source Level Id ' ,v_source_level_id(k), i_method_name);
         -- Loading Internal Level information.
            ecx_debug.log(l_statement, 'ECX', 'ECX_LOADING_LEVELS', i_method_name,
	                 'LEVEL', 'Loading Source Levels');
        end if;
         -- If the current interface level is the same as previous one,
         -- then the interface info for the current level has been loaded.
         -- The only exception for this is the root element loading, so check
	 -- the flag for root element
         if ((first_time) OR (cur_int_level <> pre_int_level)) then
            int_loaded := False;
            /* Load the Internal Level */
            for c3 in source_rec ( i_map_id, v_source_level_id(k))
	    loop
                int_loaded := True;
                ecx_utils.g_source_levels(cur_int_level).level := cur_int_level;
                ecx_utils.g_source_levels(cur_int_level).base_table_name := c3.source_level_name;
                ecx_utils.g_source_levels(cur_int_level).start_element := c3.source_level_name;
                ecx_utils.g_source_levels(cur_int_level).parent_level := c3.parent_level;
                ecx_utils.g_source_levels(cur_int_level).sql_stmt := null;
                ecx_utils.g_source_levels(cur_int_level).cursor_handle := null;
                ecx_utils.g_source_levels(cur_int_level).rows_processed := 0;
                ecx_utils.g_source_levels(cur_int_level).file_start_pos := 0;
                ecx_utils.g_source_levels(cur_int_level).file_end_pos := 0;
	 	ecx_utils.g_source_levels(cur_int_level).dtd_node_index := v_source_element_id(k);
if(l_statementEnabled) then
         	ecx_debug.log(l_statement, 'Source Node_index', g_source_levels(cur_int_level).dtd_node_index ||
		' at level' || cur_int_level,i_method_name);

                ecx_debug.log(l_statement, 'Internal Level ('||cur_int_level||') Object Name: '
                                || ecx_utils.g_source_levels (cur_int_level).base_table_name
                                || ' Parent Level '
                                || ecx_utils.g_source_levels(cur_int_level).parent_level,i_method_name);
end if;

		--END IF;
      		/** Load the Source Object Attributes **/
		load_dtd_nodes( i_map_id,c3.objectlevel_id,cur_int_level,true);
            end loop;  -- interface_rec

            if not (int_loaded) then
               raise no_seed_data;
            end if;
            pre_int_level := cur_int_level;
            first_time := false;
         end if;

      end loop; -- interface_external_rec
      end if;
      -- call the appropriate function to do the initialization of dummy
      -- data for maps that don't have level 0 mapping information
      if (not root_level_found)
      then
	 createDummyData(root_level_found);
      end if;

      if(l_statementEnabled) then
         if not (int_ext_loaded) then
                      ecx_debug.log(l_statement, 'Seed Data is missing for map_id', i_map_id,i_method_name);
         end if;
      end if;

   end loop;  -- external_rec
   end if;
   -- This is only to print out the file_start/end_pos.
   if(l_statementEnabled) then
	      if (ecx_utils.g_source_levels.count <> 0)
	      then
			 for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
			 loop
			      ecx_debug.log(l_statement, 'ECX', 'ECX_INT_FILE_START',i_method_name, 'LEVEL', i,
				  'POSITION', ecx_utils.g_source_levels(i).file_start_pos);
			      ecx_debug.log(l_statement, 'ECX', 'ECX_INT_FILE_END',i_method_name, 'LEVEL', i,
				 'POSITION', ecx_utils.g_source_levels(i).file_end_pos);
			 end loop;
	      end if;
	      if (ecx_utils.g_target_levels.count <> 0)
	      then
			 for i in ecx_utils.g_target_levels.first..ecx_utils.g_target_levels.last
			 loop
			      ecx_debug.log(l_statement, 'ECX', 'ECX_EXT_FILE_START',i_method_name, 'LEVEL', i,
					'POSITION', ecx_utils.g_target_levels(i).file_start_pos);
			      ecx_debug.log(l_statement, 'ECX', 'ECX_EXT_FILE_END',i_method_name, 'LEVEL', i,
					'POSITION', ecx_utils.g_target_levels(i).file_end_pos);
			 end loop;
	      end if;
   end if;

if (ecx_utils.g_source_levels.count <> 0 )
then
   for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
   loop
	/** Reset all of the range variables. **/
	/** These assume that there are fewer than a million levels. **/
        -- This is the beginning of a potential expansion range
	g_source_levels(i).first_target_level := 1000000;

	-- The end of a potential expansion range.  If mapping is 1:1,
	-- same as first_target_level.
	g_source_levels(i).last_target_level := -1;

	-- The beginning of a potential collapsing range
	g_source_levels(i).first_source_level:= 1000000;

	-- The end of a potential collapsing range.  If mapping is 1:1,
	-- same as first_source_level and i.
	g_source_levels(i).last_source_level := -1;

	/** Retrieve the mapping ranges. **/
        if (ecx_utils.g_target_source_levels.count <> 0)
	then
           for k in ecx_utils.g_target_source_levels.first..ecx_utils.g_target_source_levels.last
	   loop
		if ecx_utils.g_target_source_levels(k).source_level = i
		then
			/** These don't assume that the table is in order **/
			if ecx_utils.g_target_source_levels(k).target_level <
			   g_source_levels(i).first_target_level
			then
				g_source_levels(i).first_target_level := ecx_utils.g_target_source_levels(k).target_level;
				/** The source_level could be wrong if this is a collapsing, but if so,
				    it will be fixed in the next loop. **/
				g_source_levels(i).first_source_level := ecx_utils.g_target_source_levels(k).source_level;
			end if;
			if ecx_utils.g_target_source_levels(k).target_level > g_source_levels(i).last_target_level
			then
				g_source_levels(i).last_target_level := ecx_utils.g_target_source_levels(k).target_level;
				g_source_levels(i).last_source_level := ecx_utils.g_target_source_levels(k).source_level;
			end if;
		end if;
	   end loop;
        end if;

	/** Now that we've checked for expansion, check for collapsing. **/
	if g_source_levels(i).first_target_level = g_source_levels(i).last_target_level
	then
		if (ecx_utils.g_target_source_levels.count <> 0)
		then
     		   for k in ecx_utils.g_target_source_levels.first..ecx_utils.g_target_source_levels.last
		   loop
			if ecx_utils.g_target_source_levels(k).target_level = g_source_levels(i).first_target_level
			then
				if ecx_utils.g_target_source_levels(k).source_level < g_source_levels(i).first_source_level
				then
					g_source_levels(i).first_source_level := ecx_utils.g_target_source_levels(k).source_level;
				end if;
				if ecx_utils.g_target_source_levels(k).source_level > g_source_levels(i).last_source_level
				then
					g_source_levels(i).last_source_level := ecx_utils.g_target_source_levels(k).source_level;
				end if;
			end if;
		   end loop;
               end if;
	end if;

	if(l_statementEnabled) then
                ecx_debug.log(l_statement,'Source '||i,	'SOURCE FIRST:'||g_source_levels(i).first_source_level||
					'SOURCE LAST:'||g_source_levels(i).last_source_level||
					'TARGET FIRST:'||g_source_levels(i).first_target_level||
					'TARGET LAST:'||g_source_levels(i).last_target_level,
					 i_method_name
					);
        end if;
   end loop; --- end of source and target first and last level
end if;

   load_procedure_mappings (i_map_id);
   load_procedure_definitions (i_map_id);

 if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
 end if;

EXCEPTION
   WHEN NO_SEED_DATA then
      ecx_debug.setErrorInfo(1, 30, 'ECX_SEED_DATA_NOT_FOUND', 'MAP_ID', i_map_id);
      if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, 'ECX', 'ECX_SEED_DATA_NOT_FOUND',i_method_name, 'MAP_ID', i_map_id);
      end if;
       if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
       end if;
      raise PROGRAM_EXIT;

   WHEN PROGRAM_EXIT then
      if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
       end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                  'ecx_utils.LOAD_MAPPINGS');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
         ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.LOAD_MAPPINGS: ',
	              i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.LOAD_MAPPINGS: ');
      if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;

end load_mappings;


/*
** This procedure gets the major and minor version defined in the map
** and verifies it against the database ECX_VERSION. If these versions
** are not compatible it returns false.
*/
procedure check_version (
   i_map_id               IN         pls_integer,
   i_result               OUT NOCOPY boolean,
   i_ret_msg              OUT NOCOPY varchar2 ) IS

   i_method_name   varchar2(2000) := 'ecx_utils.check_version';
   i_major_version      pls_integer;
   i_minor_version      pls_integer;
   i_eng_major_version  pls_integer;
   i_eng_minor_version  pls_integer;
   i_eng_version        varchar2(2000);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   -- get the version from the map
   begin
      select em.ecx_major_version,
             em.ecx_minor_version
      into   i_major_version,
             i_minor_version
      from   ecx_mappings em
      where  em.map_id = i_map_id;
   exception
   when others then
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, SQLERRM,i_method_name);
      end if;
      i_ret_msg := SQLERRM;
      i_result := false;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      return;
   end;

   if (i_major_version is null AND i_minor_version is null)
   then
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'ECX', 'ECX_MAJOR_MINOR_VERSION_NULL',i_method_name);
      end if;
      i_major_version := 2;
      i_minor_version := 6;
   end if;

   if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'i_major_version', i_major_version,i_method_name);
         ecx_debug.log(l_statement, 'i_minor_version', i_minor_version,i_method_name);
   end if;

   -- get the engine version
   begin
      select text
      into   i_eng_version
      from   wf_resources
      where  name = 'ECX_VERSION'
      and    type = 'WFTKN'
      and    language = 'US';
   exception
   when no_data_found then
      ecx_debug.setErrorInfo(1, 30, 'ECX_WF_RESCRS_VER_NOT_FOUND');
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_WF_RESCRS_VER_NOT_FOUND', i_method_name);
      end if;
      i_result := false;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      return;
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM);
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'ECX', SQLERRM,i_method_name);
      end if;
      i_result := false;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      return;
   end;

if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'i_eng_version', i_eng_version,i_method_name);
end if;

   -- compare the map_version against the engine version
   i_eng_major_version := to_number(substr(i_eng_version, 1, 1));
   i_eng_minor_version := to_number(substr(i_eng_version, 3, 1));

   if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'i_eng_major_version', i_eng_major_version,i_method_name);
         ecx_debug.log(l_statement, 'i_eng_minor_version', i_eng_minor_version,i_method_name);
   end if;
   if (i_major_version = i_eng_major_version)
   then
      if (i_minor_version <= i_eng_minor_version)
      then
         i_ret_msg := null;
         i_result := true;
         if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
         end if;
         return;
      else
         ecx_debug.setErrorInfo(1, 30, 'ECX_VERSION_MISMATCH',
                                'i_version', i_major_version || '.' || i_minor_version,
                                'i_eng_version', i_eng_version);
         if(l_statementEnabled) then
            ecx_debug.log(l_statement,  'ECX', 'ECX_VERSION_MISMATCH',i_method_name,
                                'i_version', i_major_version || '.' || i_minor_version,
                                'i_eng_version', i_eng_version);
	end if;
         i_result := false;
         if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
         end if;
         return;
      end if;
   else
      ecx_debug.setErrorInfo(1, 30, 'ECX_VERSION_MISMATCH',
                            'i_version', i_major_version || '.' || i_minor_version,
                            'i_eng_version', i_eng_version);
      if(l_statementEnabled) then
            ecx_debug.log(l_statement, 'ECX', 'ECX_VERSION_MISMATCH', i_method_name,
                  'i_version', i_major_version || '.' || i_minor_version,
                  'i_eng_version', i_eng_version);
      end if;
      i_result := false;
      if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
      end if;
      return;
   end if;
exception
when others then
   if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
               'ecx_utils.CHECK_VERSION');
         ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
         ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.CHECK_VERSION',i_method_name);
   end if;
   ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.CHECK_VERSION');
   if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
   end if;
   raise ecx_utils.program_exit;
end check_version;


/*
**   This procedure is called the Inbound and the Outbound Execution Engine
**   It initializes and loads the info necessary for the engines
*/
procedure initialize (
   i_map_id               IN         pls_integer,
   x_same_map             OUT NOCOPY Boolean) IS

i_method_name   varchar2(2000) := 'ecx_utils.initialize';
/* Cursor to get the Root Element and Path to the DTD */
cursor get_dtd (
       p_map_id       IN   pls_integer ,
       p_object_id    IN   pls_integer) IS
select eobj.root_element,
       eobj.fullpath,
       eobj.runtime_location
from   ecx_objects eobj
where  eobj.object_id = p_object_id
and    eobj.map_id = p_map_id;

cursor getDtdClob
	(
	p_root_element	in	varchar2,
	p_filename	in	varchar2,
	p_location	in	varchar2
	)
	is
select	payload
from	ecx_dtds
where	root_element = p_root_element
and	filename = p_filename
and	( version = p_location or p_location is null );

i_dtdpayload		CLOB;
l_dtd_path              Varchar2(200);
l_fullpath              ecx_objects.fullpath%TYPE;
l_root_element          ecx_objects.root_element%TYPE;
l_doctype               xmlDOM.DOMDocumentType;
l_runtime_location	varchar2(200);

t_dtdpayload		CLOB;
t_fullpath              ecx_objects.fullpath%TYPE;
t_root_element		ecx_objects.root_element%TYPE;
t_doctype		xmlDOM.DOMDocumentType;
t_runtime_location	varchar2(200);
i_tar_obj_type		varchar2(200);

no_dtd_exception        EXCEPTION;
l_direction             varchar2(5);
l_object_id             number;
i_string		varchar2(2000);
i_result                boolean;
i_ret_msg               varchar2(2000);

i_map_code		varchar2(32);

BEGIN

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

   if (l_procedureEnabled) then
        ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
      ecx_debug.log(l_statement,'i_map_id ',i_map_id,i_method_name);
   end if;

   i_ret_code := 0;
   i_errbuf := null;
   ecx_utils.i_errparams := null;
   ecx_utils.g_total_records := 0;
   ecx_utils.g_current_level := 0;
   ecx_utils.g_previous_level := 0;
   g_source_object_id := null;
   g_target_object_id := null;
   ecx_print_local.last_printed := -1;

   -- check the version
   ecx_utils.check_version(i_map_id, i_result, i_ret_msg);
   if (not i_result)
   then
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'ECX', 'ECX_PROGRAM_ERROR', i_method_name, 'PROGRESS_LEVEL',
                  'ecx_utils.INITIALIZE');
         ecx_debug.log(l_statement, 'ECX','ECX_ERROR_MESSAGE', i_method_name,'ERROR_MESSAGE', i_ret_msg);
      end if;
      raise ecx_utils.program_exit;
   end if;
   /* Find the map code for bug 1939677 */
   select map_code into i_map_code from ecx_mappings where map_id=i_map_id;

   /* Try to find if it is an Inbound or Outbound Txn */
   begin
   	SELECT 		object_id_source,
			object_id_target
   	INTO   		g_source_object_id,
			g_target_object_id
   	FROM   		ecx_mappings em
   	WHERE  		em.map_id = i_map_id;
	exception
	when others then
                ecx_debug.setErrorInfo(1, 30, 'ECX_MAPPINGS_NOT_FOUND', 'MAP_ID', i_map_id);
		if(l_unexpectedEnabled) then
                    ecx_debug.log(l_unexpected,'ECX', 'ECX_MAPPINGS_NOT_FOUND',i_method_name,
		                 'MAP_ID', i_map_id);
		end if;
		raise ecx_utils.program_exit;
	end;

      -- needed for root element support
      ecx_print_local.first_time_printing := TRUE;
      ecx_utils.g_xml_frag.DELETE;
--for bug 5609625
   --if (nvl(ecx_utils.g_map_id,0) <> i_map_id) then

      ecx_utils.structure_printing := FALSE;
      ecx_utils.dom_printing       := FALSE;

     -- if ( ecx_utils.g_parser.id = -1 )
     -- then
      	ecx_utils.g_parser := xmlParser.NewParser;
      --else
	--xmlParser.freeParser(ecx_utils.g_parser);
      	--ecx_utils.g_parser := xmlParser.NewParser;
     -- end if;

      --if ( ecx_utils.g_inb_parser.id not in (-1) )
     -- then
      --   xmlParser.freeParser(ecx_utils.g_inb_parser);
     -- end if;
---end of 5609625
      ecx_utils.getLogDirectory;

      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'ecx_UTL_DTD_DIR', ecx_utils.g_logdir,i_method_name);
      end if;
--      xmlparser.setbaseDir (ecx_utils.g_parser, l_dtd_path);

      if ( g_direction = 'IN' )
      then
         -- get the source details
         open get_dtd ( i_map_id,g_source_object_id);
         fetch get_dtd into l_root_element, l_fullpath,l_runtime_location;
         if get_dtd%NOTFOUND then
            close get_dtd;
            raise no_dtd_exception;
         end if;
         close get_dtd;

         if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'l_root_element', l_root_element,i_method_name);
          ecx_debug.log(l_statement, 'l_fullpath', l_fullpath,i_method_name);
          ecx_debug.log(l_statement, 'l_runtime_location', l_runtime_location,i_method_name);
         end if;
         -- check if it is a pure Inbound case
         SELECT object_type
         INTO   i_tar_obj_type
         FROM   ecx_objects
         WHERE  map_id = i_map_id
         AND    object_id = 2;

         if (i_tar_obj_type not in ('DB'))
         then
            if(l_statementEnabled) then
              ecx_debug.log(l_statement, 'DTD/XML on Target',i_method_name);
            end if;
            -- get the target details
            open get_dtd ( i_map_id,g_target_object_id);
            fetch get_dtd into t_root_element, t_fullpath,t_runtime_location;
            if get_dtd%NOTFOUND then
               close get_dtd;
               raise no_dtd_exception;
            end if;
            close get_dtd;
            if(l_statementEnabled) then
               ecx_debug.log(l_statement, 't_root_element', t_root_element,i_method_name);
               ecx_debug.log(l_statement, 't_fullpath', t_fullpath,i_method_name);
               ecx_debug.log(l_statement, 't_runtime_location', t_runtime_location,i_method_name);
            end if;
            -- check if data transformation or structure transformation
            if ((t_fullpath = l_fullpath) AND
		(t_root_element = l_root_element))
            then
               if(l_statementEnabled) then
                ecx_debug.log(l_statement,  'Source and Target DTDs are same',i_method_name);
	       end if;
               ecx_utils.dom_printing := FALSE;
               ecx_utils.structure_printing := FALSE;

               -- check for routing information
               if ((ecx_utils.g_routing_id not in (0)) AND
	      	   (ecx_utils.g_rec_tp_id is not null))
               then
                  -- this is a pass through transaction. Need to update
                  -- the DOM
                  ecx_utils.dom_printing := TRUE;
                  ecx_utils.structure_printing := FALSE;
		--for 5609625
		  -- initialize the DS needed for this
		  --ecx_utils.g_node_tbl.DELETE;
		--end of 5609625
               end if;
            else
               -- DTDs are different, so this is structure transformation
             if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Source and Target DTDs are different',i_method_name);
             end if;
              -- initialize the target parser
              ecx_utils.g_inb_parser := xmlparser.NewParser;

              ecx_utils.dom_printing := FALSE;
              ecx_utils.structure_printing := TRUE;
            end if;
         end if;
      else
         open get_dtd (i_map_id,g_target_object_id);
         fetch get_dtd into l_root_element, l_fullpath,l_runtime_location;

         if get_dtd%NOTFOUND then
            raise no_dtd_exception;
         end if;

         if(l_statementEnabled) then
           ecx_debug.log(l_statement, 'l_root_element', l_root_element,i_method_name);
           ecx_debug.log(l_statement, 'l_fullpath', l_fullpath,i_method_name);
           ecx_debug.log(l_statement, 'l_runtime_location', l_runtime_location,i_method_name);
	 end if;
      end if;
      if(l_statementEnabled) then
           ecx_debug.log(l_statement, 'Direction', g_direction,i_method_name);
           ecx_debug.log(l_statement, 'SOurce Object', to_char(g_source_object_id),i_method_name);
           ecx_debug.log(l_statement, 'Taregt Object', to_char(g_target_object_id),i_method_name);
           ecx_debug.log(l_statement, 'dom_printing', dom_printing,i_method_name);
           ecx_debug.log(l_statement, 'structure_printing', structure_printing,i_method_name);
      end if;

      -- Get the DTD Clob . If not Found , continue .
      if ( l_root_element is not null and l_fullpath is not null)
      then
         -- DTD was specified on the Map to be used. We will check and
         -- make sure it is required.
	 -- if not found , abort the process.
      	 open getDtdClob(l_root_element,l_fullpath,l_runtime_location);
      	 fetch getDtdClob	into i_dtdpayload;
      	 if getDtdCLOB%NOTFOUND
      	 then
	    close getDtdClob;
	    raise no_dtd_exception;
      	 end if;
	 close getDtdClob;

      	 xmlparser.parseDTDCLOB(ecx_utils.g_parser,i_dtdpayload,l_root_element);

      	 xmlparser.setValidationMode (ecx_utils.g_parser,true);
      	 l_doctype := xmlparser.getDocType (ecx_utils.g_parser);
      	 xmlparser.setDocType (ecx_utils.g_parser, l_doctype);

      else
         --- DTD not specified in the Map. Optional. let us proceed without the DTD.
      	 xmlparser.setValidationMode (ecx_utils.g_parser, false);
      end if;

      -- check if we need to load the target's clob
      if (i_tar_obj_type not in ('DB') AND (structure_printing))
      then
         -- Get the target DTD Clob . If not Found , continue .
         if ( t_root_element is not null and t_fullpath is not null)
         then
            -- DTD was specified on the Map to be used. We will check and
            -- make sure it is required.
	    -- if not found , abort the process.
      	    open getDtdClob(t_root_element,t_fullpath,t_runtime_location);
      	    fetch getDtdClob	into t_dtdpayload;
      	    if getDtdCLOB%NOTFOUND
      	    then
	       close getDtdClob;
	       raise no_dtd_exception;
      	    end if;
	    close getDtdClob;

      	    xmlparser.parseDTDCLOB(ecx_utils.g_inb_parser,t_dtdpayload,t_root_element);
      	    xmlparser.setValidationMode (ecx_utils.g_inb_parser, true);
      	    t_doctype := xmlparser.getDocType (ecx_utils.g_inb_parser);
      	    xmlparser.setDocType (ecx_utils.g_inb_parser, t_doctype);
         else
            --- DTD not specified in the Map. Optional. let us proceed without the DTD.
      	    xmlparser.setValidationMode (ecx_utils.g_inb_parser, false);
         end if;
      end if;
--for bug 5609625
       if (nvl(ecx_utils.g_map_id,0) <> i_map_id) then
        x_same_map := False;
        ecx_utils.g_map_id := i_map_id;
      if(ecx_utils.dom_printing = TRUE and
          ecx_utils.structure_printing = FALSE)
        then
          -- initialize the DS needed for this
          ecx_utils.g_node_tbl.DELETE;
        end if;
--end of 5609625
ecx_utils.close_process;
	 x_same_map := False;
        ecx_utils.g_map_id := i_map_id;


      /**
       Get all the Dynamic Inbound Staging data. The data is retrieved from the
       table ( ecx_tran_stage_data ) and kept in the Local Pl/SQL table. Since the
       data is in PL/SQL memory , no further lookups in the table are required.
       This helps in improving the perfromance , as un-necessary selects are saved.
      **/
      get_tran_stage_data (i_map_id);

      load_mappings (i_map_id);

      /**
       Execute the Dynamic Stage data for Stage = 10.
       This builds the stack table.
       **/
      /* Pre Processing for Document */
       ecx_actions.execute_stage_data (10,0,'S');
       ecx_actions.execute_stage_data (10,0,'T');

      /**
       Save the PL/SQL table with default values. This will be used
       by all the documents.
       **/
      ecx_utils.g_empty_source := ecx_utils.g_source;
      ecx_utils.g_empty_target := ecx_utils.g_target;

   else

      x_same_map := True;
      ecx_actions.execute_stage_data (10,0,'S');
      ecx_actions.execute_stage_data (10,0,'T');
      ecx_utils.g_source := ecx_utils.g_empty_source;
      ecx_utils.g_target := ecx_utils.g_empty_target;
   end if;

   	--- Gets the Company name for the XML Gateway Server.

	--- Check for the Installation Type ( Standalone or Embedded );
	ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');

	if ecx_utils.g_install_mode = 'EMBEDDED'
	then
		i_string := 'begin
		fnd_profile.get('||'''ECX_OAG_LOGICALID'''||',ecx_utils.g_company_name);
		end;';
		execute immediate i_string ;
	else
		ecx_utils.g_company_name := wf_core.translate('ECX_OAG_LOGICALID');
	end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

EXCEPTION
   WHEN NO_DTD_EXCEPTION then
      ecx_debug.setErrorInfo(1, 30, 'ECX_DTD_NOT_FOUND', 'MAP_CODE', i_map_code);
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', 'ECX_DTD_NOT_FOUND', i_method_name,'MAP_CODE', i_map_code);
      end if;
      if get_dtd%ISOPEN
      then
         close get_dtd;
      end if;
      ecx_utils.g_map_id := -1;
      ecx_utils.g_node_tbl.DELETE;
      raise program_exit;

   WHEN PROGRAM_EXIT then
      ecx_utils.g_map_id := -1;
      ecx_utils.g_node_tbl.DELETE;
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
-- bug 8718549, free parser before program exit
      if (ecx_utils.g_parser.id is not null ) then
          xmlparser.freeparser(ecx_utils.g_parser);
           if(ecx_utils.dom_printing = false and ecx_utils.structure_printing = true
                            and ecx_utils.g_inb_parser.id is not null) then
               xmlparser.freeparser(ecx_utils.g_inb_parser);
          end if;
      end if;
-- bug 8718549
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name, 'PROGRESS_LEVEL',
                  'ecx_utils.INITIALIZE');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
          ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.INITIALIZE: ',
	               i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.INITIALIZE: ');
      ecx_utils.g_map_id := -1;
      ecx_utils.g_node_tbl.DELETE;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise PROGRAM_EXIT;

end initialize;

procedure close_process IS

   i_method_name   varchar2(2000) := 'ecx_utils.close_process';
   i      pls_integer;
   j      pls_integer;

   -- bug 6922998
   -- to store the cursor handles already closed. Storing in the index column for better performance.
   type tclosed_cursors is table of number index by pls_integer;
   closed_cursors tclosed_cursors;

BEGIN
  if (l_procedureEnabled) then
    ecx_debug.push(i_method_name);
  end if;

   -- close all open cursors.
   if (g_source_levels.count <> 0)
      then
      for i in g_source_levels.first..g_source_levels.last
      loop
         if (g_source_levels(i).cursor_handle is not null ) and
            (not closed_cursors.EXISTS( g_source_levels(i).cursor_handle) )
         then
            closed_cursors(  g_source_levels(i).cursor_handle ) := -1 ;
            dbms_sql.close_cursor(g_source_levels(i).cursor_handle);
         end if;
      end loop;
   end if;

   if(g_target_levels.count <> 0)
      then
      for i in g_target_levels.first..g_target_levels.last
      loop
         if (g_target_levels(i).cursor_handle is not null ) and
            (not closed_cursors.EXISTS (g_target_levels(i).cursor_handle) )
         then
            closed_cursors(  g_target_levels(i).cursor_handle ) := -1;
            dbms_sql.close_cursor(g_target_levels(i).cursor_handle);
         end if;
      end loop;
   end if;

   IF (ecx_utils.g_procedure_list.count > 0) THEN
      j := ecx_utils.g_procedure_list.first;
      WHILE j IS NOT NULL LOOP
	 if (ecx_utils.g_procedure_list(j).cursor_handle > 0) and
            (ecx_utils.g_procedure_list(j).cursor_handle is not null) and
	    (not closed_cursors.EXISTS (ecx_utils.g_procedure_list(j).cursor_handle) )
	 then
               closed_cursors( ecx_utils.g_procedure_list(j).cursor_handle ) := -1;
               dbms_sql.close_cursor(ecx_utils.g_procedure_list(j).cursor_handle);
         end if;
         j := ecx_utils.g_procedure_list.NEXT(j);
      end loop;
   END IF;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

EXCEPTION
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                  'ecx_utils.CLOSE_PROCESS');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
         ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.CLOSE_PROCESS: ',
	              i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ecx_utils.CLOSE_PROCESS: ');
      raise PROGRAM_EXIT;

end close_process;

/**
Retrieves the Data from the ecx_TRAN_STAGE_DATA for a given Stage and Level.
This will retrieve all the actions both on the source and the target
**/
procedure get_tran_stage_data (
   i_map_id               IN     pls_integer)
IS

   i_method_name   varchar2(2000) := 'ecx_utils.get_tran_stage_data';

/*	TYPE stage_data_record is RECORD (
	   transtage_id ecx_tran_stage_data.transtage_id%TYPE,
	   object_level ecx_object_levels.object_level%TYPE,
	   objectlevel_id ecx_tran_stage_data.objectlevel_id%TYPE,
	   stage ecx_tran_stage_data.stage%TYPE,
	   object_direction ecx_tran_stage_data.object_direction%TYPE,
	   seq_number ecx_tran_stage_data.seq_number%TYPE,
	   action_type ecx_tran_stage_data.action_type%TYPE,
	   variable_level ecx_tran_stage_data.variable_level%TYPE,
	   variable_name ecx_tran_stage_data.variable_name%TYPE,
	   variable_direction ecx_tran_stage_data.variable_direction%TYPE,
	   variable_value ecx_tran_stage_data.variable_value%TYPE,
	   default_value ecx_tran_stage_data.default_value%TYPE,
	   sequence_name ecx_tran_stage_data.sequence_name%TYPE,
	   custom_procedure_name ecx_tran_stage_data.custom_procedure_name%TYPE,
	   data_type ecx_tran_stage_data.data_type%TYPE,
	   function_name ecx_tran_stage_data.function_name%TYPE,
	   where_clause ecx_tran_stage_data.where_clause%TYPE,
	   variable_pos ecx_tran_stage_data.variable_pos%TYPE,
	   cond_logical_operator ecx_tran_stage_data.cond_logical_operator%TYPE,
	   cond_operator1 ecx_tran_stage_data.cond_operator1%TYPE,
	   cond_var1_level ecx_tran_stage_data.cond_var1_level%TYPE,
	   cond_var1_name ecx_tran_stage_data.cond_var1_name%TYPE,
	   cond_var1_pos ecx_tran_stage_data.cond_var1_pos%TYPE,
	   cond_var1_direction ecx_tran_stage_data.cond_var1_direction%TYPE,
	   cond_var1_constant ecx_tran_stage_data.cond_var1_constant%TYPE,
	   cond_val1_level ecx_tran_stage_data.cond_val1_level%TYPE,
	   cond_val1_name ecx_tran_stage_data.cond_val1_name%TYPE,
	   cond_val1_pos ecx_tran_stage_data.cond_val1_pos%TYPE,
	   cond_val1_direction ecx_tran_stage_data.cond_val1_direction%TYPE,
	   cond_val1_constant ecx_tran_stage_data.cond_val1_constant%TYPE,
	   cond_operator2 ecx_tran_stage_data.cond_operator2%TYPE,
	   cond_var2_level ecx_tran_stage_data.cond_var2_level%TYPE,
	   cond_var2_name ecx_tran_stage_data.cond_var2_name%TYPE,
	   cond_var2_pos ecx_tran_stage_data.cond_var2_pos%TYPE,
	   cond_var2_direction ecx_tran_stage_data.cond_var2_direction%TYPE,
	   cond_var2_constant ecx_tran_stage_data.cond_var2_constant%TYPE,
	   cond_val2_level ecx_tran_stage_data.cond_val2_level%TYPE,
	   cond_val2_name ecx_tran_stage_data.cond_val2_name%TYPE,
	   cond_val2_pos ecx_tran_stage_data.cond_val2_pos%TYPE,
	   cond_val2_direction ecx_tran_stage_data.cond_val2_direction%TYPE,
	   cond_val2_constant ecx_tran_stage_data.cond_val2_constant%TYPE,
	   operand1_level ecx_tran_stage_data.operand1_level%TYPE,
	   operand1_name ecx_tran_stage_data.operand1_name%TYPE,
	   operand1_pos ecx_tran_stage_data.operand1_pos%TYPE,
	   operand1_direction ecx_tran_stage_data.operand1_direction%TYPE,
	   operand1_constant ecx_tran_stage_data.operand1_constant%TYPE,
	   operand1_len ecx_tran_stage_data.operand1_len%TYPE,
	   operand1_start_pos ecx_tran_stage_data.operand1_start_pos%TYPE,
	   operand2_level ecx_tran_stage_data.operand2_level%TYPE,
	   operand2_name ecx_tran_stage_data.operand2_name%TYPE,
	   operand2_pos ecx_tran_stage_data.operand2_pos%TYPE,
	   operand2_direction ecx_tran_stage_data.operand2_direction%TYPE,
	   operand2_constant ecx_tran_stage_data.operand2_constant%TYPE,
	   operand3_level ecx_tran_stage_data.operand3_level%TYPE,
	   operand3_name ecx_tran_stage_data.operand3_name%TYPE,
	   operand3_pos ecx_tran_stage_data.operand3_pos%TYPE,
	   operand3_direction ecx_tran_stage_data.operand3_direction%TYPE,
	   operand3_constant ecx_tran_stage_data.operand3_constant%TYPE,
	   operand4_level ecx_tran_stage_data.operand4_level%TYPE,
	   operand4_name ecx_tran_stage_data.operand4_name%TYPE,
	   operand4_pos ecx_tran_stage_data.operand4_pos%TYPE,
	   operand4_direction ecx_tran_stage_data.operand4_direction%TYPE,
	   operand4_constant ecx_tran_stage_data.operand4_constant%TYPE,
	   operand5_level ecx_tran_stage_data.operand5_level%TYPE,
	   operand5_name ecx_tran_stage_data.operand5_name%TYPE,
	   operand5_pos ecx_tran_stage_data.operand5_pos%TYPE,
	   operand5_direction ecx_tran_stage_data.operand5_direction%TYPE,
	   operand5_constant ecx_tran_stage_data.operand5_constant%TYPE,
	   operand6_level ecx_tran_stage_data.operand6_level%TYPE,
	   operand6_name ecx_tran_stage_data.operand6_name%TYPE,
	   operand6_pos ecx_tran_stage_data.operand6_pos%TYPE,
	   operand6_direction ecx_tran_stage_data.operand6_direction%TYPE,
	   operand6_constant ecx_tran_stage_data.operand6_constant%TYPE);

	TYPE stage_data_table is TABLE of stage_data_record index by BINARY_INTEGER;
	i_stage_data stage_data_table;
*/
	TYPE t_transtage_id is TABLE of ecx_tran_stage_data.transtage_id%TYPE;
	TYPE t_object_level is TABLE of ecx_object_levels.object_level%TYPE;
	TYPE t_objectlevel_id is TABLE of ecx_tran_stage_data.objectlevel_id%TYPE;
	TYPE t_stage is TABLE of ecx_tran_stage_data.stage%TYPE;
	TYPE t_object_direction  is TABLE of ecx_tran_stage_data.object_direction%TYPE;
	TYPE t_seq_number  is TABLE of ecx_tran_stage_data.seq_number%TYPE;
	TYPE t_action_type  is TABLE of ecx_tran_stage_data.action_type%TYPE;
	TYPE t_variable_level is TABLE of  ecx_tran_stage_data.variable_level%TYPE;
	TYPE t_variable_name is TABLE of  ecx_tran_stage_data.variable_name%TYPE;
	TYPE t_variable_direction is TABLE of  ecx_tran_stage_data.variable_direction%TYPE;
	TYPE t_variable_value  is TABLE of ecx_tran_stage_data.variable_value%TYPE;
	TYPE t_default_value  is TABLE of ecx_tran_stage_data.default_value%TYPE;
	TYPE t_sequence_name  is TABLE of ecx_tran_stage_data.sequence_name%TYPE;
	TYPE t_custom_procedure_name  is TABLE of ecx_tran_stage_data.custom_procedure_name%TYPE;
	TYPE t_data_type  is TABLE of ecx_tran_stage_data.data_type%TYPE;
	TYPE t_function_name  is TABLE of ecx_tran_stage_data.function_name%TYPE;
	TYPE t_where_clause is TABLE of  ecx_tran_stage_data.where_clause%TYPE;
	TYPE t_variable_pos  is TABLE of ecx_tran_stage_data.variable_pos%TYPE;
	TYPE t_cond_logical_operator is TABLE of  ecx_tran_stage_data.cond_logical_operator%TYPE;
	TYPE t_cond_operator1 is TABLE of  ecx_tran_stage_data.cond_operator1%TYPE;
	TYPE t_cond_var1_level  is TABLE of ecx_tran_stage_data.cond_var1_level%TYPE;
	TYPE t_cond_var1_name  is TABLE of ecx_tran_stage_data.cond_var1_name%TYPE;
	TYPE t_cond_var1_pos  is TABLE of ecx_tran_stage_data.cond_var1_pos%TYPE;
	TYPE t_cond_var1_direction  is TABLE of ecx_tran_stage_data.cond_var1_direction%TYPE;
	TYPE t_cond_var1_constant is TABLE of  ecx_tran_stage_data.cond_var1_constant%TYPE;
	TYPE t_cond_val1_level is TABLE of  ecx_tran_stage_data.cond_val1_level%TYPE;
	TYPE t_cond_val1_name  is TABLE of ecx_tran_stage_data.cond_val1_name%TYPE;
	TYPE t_cond_val1_pos is TABLE of  ecx_tran_stage_data.cond_val1_pos%TYPE;
	TYPE t_cond_val1_direction  is TABLE of ecx_tran_stage_data.cond_val1_direction%TYPE;
	TYPE t_cond_val1_constant is TABLE of  ecx_tran_stage_data.cond_val1_constant%TYPE;
	TYPE t_cond_operator2  is TABLE of ecx_tran_stage_data.cond_operator2%TYPE;
	TYPE t_cond_var2_level  is TABLE of ecx_tran_stage_data.cond_var2_level%TYPE;
	TYPE t_cond_var2_name  is TABLE of ecx_tran_stage_data.cond_var2_name%TYPE;
	TYPE t_cond_var2_pos  is TABLE of ecx_tran_stage_data.cond_var2_pos%TYPE;
	TYPE t_cond_var2_direction  is TABLE of ecx_tran_stage_data.cond_var2_direction%TYPE;
	TYPE t_cond_var2_constant is TABLE of  ecx_tran_stage_data.cond_var2_constant%TYPE;
	TYPE t_cond_val2_level is TABLE of  ecx_tran_stage_data.cond_val2_level%TYPE;
	TYPE t_cond_val2_name is TABLE of  ecx_tran_stage_data.cond_val2_name%TYPE;
	TYPE t_cond_val2_pos is TABLE of  ecx_tran_stage_data.cond_val2_pos%TYPE;
	TYPE t_cond_val2_direction  is TABLE of ecx_tran_stage_data.cond_val2_direction%TYPE;
	TYPE t_cond_val2_constant is TABLE of  ecx_tran_stage_data.cond_val2_constant%TYPE;
	TYPE t_operand1_level is TABLE of  ecx_tran_stage_data.operand1_level%TYPE;
	TYPE t_operand1_name is TABLE of  ecx_tran_stage_data.operand1_name%TYPE;
	TYPE t_operand1_pos  is TABLE of ecx_tran_stage_data.operand1_pos%TYPE;
	TYPE t_operand1_direction  is TABLE of ecx_tran_stage_data.operand1_direction%TYPE;
	TYPE t_operand1_constant is TABLE of  ecx_tran_stage_data.operand1_constant%TYPE;
	TYPE t_operand1_len  is TABLE of ecx_tran_stage_data.operand1_len%TYPE;
	TYPE t_operand1_start_pos  is TABLE of ecx_tran_stage_data.operand1_start_pos%TYPE;
	TYPE t_operand2_level  is TABLE of ecx_tran_stage_data.operand2_level%TYPE;
	TYPE t_operand2_name  is TABLE of ecx_tran_stage_data.operand2_name%TYPE;
	TYPE t_operand2_pos is TABLE of  ecx_tran_stage_data.operand2_pos%TYPE;
	TYPE t_operand2_direction is TABLE of  ecx_tran_stage_data.operand2_direction%TYPE;
	TYPE t_operand2_constant is TABLE of  ecx_tran_stage_data.operand2_constant%TYPE;
	TYPE t_operand3_level is TABLE of  ecx_tran_stage_data.operand3_level%TYPE;
	TYPE t_operand3_name  is TABLE of ecx_tran_stage_data.operand3_name%TYPE;
	TYPE t_operand3_pos  is TABLE of ecx_tran_stage_data.operand3_pos%TYPE;
	TYPE t_operand3_direction is TABLE of  ecx_tran_stage_data.operand3_direction%TYPE;
	TYPE t_operand3_constant  is TABLE of ecx_tran_stage_data.operand3_constant%TYPE;
	TYPE t_operand4_level is TABLE of  ecx_tran_stage_data.operand4_level%TYPE;
	TYPE t_operand4_name  is TABLE of ecx_tran_stage_data.operand4_name%TYPE;
	TYPE t_operand4_pos  is TABLE of ecx_tran_stage_data.operand4_pos%TYPE;
	TYPE t_operand4_direction is TABLE of  ecx_tran_stage_data.operand4_direction%TYPE;
	TYPE t_operand4_constant  is TABLE of ecx_tran_stage_data.operand4_constant%TYPE;
	TYPE t_operand5_level  is TABLE of ecx_tran_stage_data.operand5_level%TYPE;
	TYPE t_operand5_name is TABLE of  ecx_tran_stage_data.operand5_name%TYPE;
	TYPE t_operand5_pos  is TABLE of ecx_tran_stage_data.operand5_pos%TYPE;
	TYPE t_operand5_direction is TABLE of  ecx_tran_stage_data.operand5_direction%TYPE;
	TYPE t_operand5_constant is TABLE of  ecx_tran_stage_data.operand5_constant%TYPE;
	TYPE t_operand6_level is TABLE of  ecx_tran_stage_data.operand6_level%TYPE;
	TYPE t_operand6_name is TABLE of  ecx_tran_stage_data.operand6_name%TYPE;
	TYPE t_operand6_pos  is TABLE of ecx_tran_stage_data.operand6_pos%TYPE;
	TYPE t_operand6_direction  is TABLE of ecx_tran_stage_data.operand6_direction%TYPE;
	TYPE t_operand6_constant is TABLE of  ecx_tran_stage_data.operand6_constant%TYPE;


--  temp_stage_rec stage_data_record;
  temp_util_rec ecx_utils.stage_rec;

	v_transtage_id t_transtage_id;
	v_object_level t_object_level;
	v_objectlevel_id t_objectlevel_id;
	v_stage t_stage;
	v_object_direction t_object_direction;
	v_seq_number t_seq_number;
	v_action_type t_action_type;
	v_variable_level t_variable_level;
	v_variable_name t_variable_name;
	v_variable_direction t_variable_direction;
	v_variable_value t_variable_value;
	v_default_value t_default_value;
	v_sequence_name t_sequence_name;
	v_custom_procedure_name t_custom_procedure_name;
	v_data_type t_data_type;
	v_function_name t_function_name;
	v_where_clause t_where_clause;
	v_variable_pos t_variable_pos;
	v_cond_logical_operator t_cond_logical_operator;
	v_cond_operator1 t_cond_operator1;
	v_cond_var1_level t_cond_var1_level;
	v_cond_var1_name t_cond_var1_name;
	v_cond_var1_pos t_cond_var1_pos;
	v_cond_var1_direction t_cond_var1_direction;
	v_cond_var1_constant t_cond_var1_constant;
	v_cond_val1_level t_cond_val1_level;
	v_cond_val1_name t_cond_val1_name;
	v_cond_val1_pos t_cond_val1_pos;
	v_cond_val1_direction t_cond_val1_direction;
	v_cond_val1_constant t_cond_val1_constant;
	v_cond_operator2 t_cond_operator2;
	v_cond_var2_level t_cond_var2_level;
	v_cond_var2_name t_cond_var2_name;
	v_cond_var2_pos t_cond_var2_pos;
	v_cond_var2_direction t_cond_var2_direction;
	v_cond_var2_constant t_cond_var2_constant;
	v_cond_val2_level t_cond_val2_level;
	v_cond_val2_name t_cond_val2_name;
	v_cond_val2_pos t_cond_val2_pos;
	v_cond_val2_direction t_cond_val2_direction;
	v_cond_val2_constant t_cond_val2_constant;
	v_operand1_level t_operand1_level;
	v_operand1_name t_operand1_name;
	v_operand1_pos t_operand1_pos;
	v_operand1_direction t_operand1_direction;
	v_operand1_constant t_operand1_constant;
	v_operand1_len t_operand1_len;
	v_operand1_start_pos t_operand1_start_pos;
	v_operand2_level t_operand2_level;
	v_operand2_name t_operand2_name;
	v_operand2_pos t_operand2_pos;
	v_operand2_direction t_operand2_direction;
	v_operand2_constant t_operand2_constant;
	v_operand3_level t_operand3_level;
	v_operand3_name t_operand3_name;
	v_operand3_pos t_operand3_pos;
	v_operand3_direction t_operand3_direction;
	v_operand3_constant t_operand3_constant;
	v_operand4_level t_operand4_level;
	v_operand4_name t_operand4_name;
	v_operand4_pos t_operand4_pos;
	v_operand4_direction t_operand4_direction;
	v_operand4_constant t_operand4_constant;
	v_operand5_level t_operand5_level;
	v_operand5_name t_operand5_name;
	v_operand5_pos t_operand5_pos;
	v_operand5_direction t_operand5_direction;
	v_operand5_constant t_operand5_constant;
	v_operand6_level t_operand6_level;
	v_operand6_name t_operand6_name;
	v_operand6_pos t_operand6_pos;
	v_operand6_direction t_operand6_direction;
	v_operand6_constant t_operand6_constant;



  /* cursor  stage_data (
           p_map_id             IN   pls_integer) IS
   select  transtage_id,
           object_level ,
           a.objectlevel_id,
           stage,
	   nvl(object_direction,'S') object_direction,
           seq_number,
           action_type,
           variable_level,
           variable_name,
           nvl(variable_direction,'S') variable_direction,
           variable_value,
           default_value,
           upper(sequence_name) sequence_name,
           upper(custom_procedure_name) custom_procedure_name,
           data_type,
           upper(function_name) function_name,
           where_clause,
           variable_pos,
	   upper(cond_logical_operator) cond_logical_operator,
	   upper(cond_operator1) cond_operator1,
	   cond_var1_level,
	   cond_var1_name,
	   cond_var1_pos,
	   upper(cond_var1_direction) cond_var1_direction,
	   cond_var1_constant,
	   cond_val1_level,
	   cond_val1_name,
	   cond_val1_pos,
	   upper(cond_val1_direction) cond_val1_direction,
	   cond_val1_constant,
	   upper(cond_operator2) cond_operator2,
	   cond_var2_level,
	   cond_var2_name,
	   cond_var2_pos,
	   upper(cond_var2_direction) cond_var2_direction,
	   cond_var2_constant,
	   cond_val2_level,
	   cond_val2_name,
	   cond_val2_pos,
	   upper(cond_val2_direction) cond_val2_direction,
	   cond_val2_constant,
	   operand1_level,
	   operand1_name,
	   operand1_pos,
	   operand1_direction,
	   operand1_constant,
	   operand1_len,
	   operand1_start_pos,
	   operand2_level,
	   operand2_name,
	   operand2_pos,
	   operand2_direction,
	   operand2_constant,
	   operand3_level,
	   operand3_name,
	   operand3_pos,
	   operand3_direction,
	   operand3_constant,
	   operand4_level,
	   operand4_name,
	   operand4_pos,
	   operand4_direction,
	   operand4_constant,
	   operand5_level,
	   operand5_name,
	   operand5_pos,
	   operand5_direction,
	   operand5_constant,
	   operand6_level,
	   operand6_name,
	   operand6_pos,
	   operand6_direction,
	   operand6_constant
   from    ecx_tran_stage_data a,
           ecx_object_levels b
   where   a.map_id = p_map_id
   and     a.map_id = b.map_id
   and     a.objectlevel_id = b.objectlevel_id
   and     action_type <> 10
   order by stage,object_level,action_pos,seq_number;
*/

   i_counter    pls_integer := 0;
BEGIN
   ecx_utils.g_delete_doctype := false;
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   ecx_utils.g_stage_data.DELETE;

	select
	    transtage_id,
	    object_level ,
	    a.objectlevel_id,
	    stage,
	    nvl(object_direction,'S') object_direction,
	    seq_number,
	    action_type,
	    variable_level,
	    variable_name,
	    nvl(variable_direction,'S') variable_direction,
	    variable_value,
	    default_value,
	    upper(sequence_name) sequence_name,
	    upper(custom_procedure_name) custom_procedure_name,
	    data_type,
	    upper(function_name) function_name,
	    where_clause,
	    variable_pos,
	    upper(cond_logical_operator) cond_logical_operator,
	    upper(cond_operator1) cond_operator1,
	    cond_var1_level,
	    cond_var1_name,
	    cond_var1_pos,
	    upper(cond_var1_direction) cond_var1_direction,
	    cond_var1_constant,
	    cond_val1_level,
	    cond_val1_name,
	    cond_val1_pos,
	    upper(cond_val1_direction) cond_val1_direction,
	    cond_val1_constant,
	    upper(cond_operator2) cond_operator2,
	    cond_var2_level,
	    cond_var2_name,
	    cond_var2_pos,
	    upper(cond_var2_direction) cond_var2_direction,
	    cond_var2_constant,
	    cond_val2_level,
	    cond_val2_name,
	    cond_val2_pos,
	    upper(cond_val2_direction) cond_val2_direction,
	    cond_val2_constant,
	    operand1_level,
	    operand1_name,
	    operand1_pos,
	    operand1_direction,
	    operand1_constant,
	    operand1_len,
	    operand1_start_pos,
	    operand2_level,
	    operand2_name,
	    operand2_pos,
	    operand2_direction,
	    operand2_constant,
	    operand3_level,
	    operand3_name,
	    operand3_pos,
	    operand3_direction,
	    operand3_constant,
	    operand4_level,
	    operand4_name,
	    operand4_pos,
	    operand4_direction,
	    operand4_constant,
	    operand5_level,
	    operand5_name,
	    operand5_pos,
	    operand5_direction,
	    operand5_constant,
	    operand6_level,
	    operand6_name,
	    operand6_pos,
	    operand6_direction,
	    operand6_constant
--	bulk collect into ecx_utils.g_stage_data
	bulk collect into
--	i_stage_data
	v_transtage_id,
	v_object_level,
	v_objectlevel_id,
	v_stage,
	v_object_direction,
	v_seq_number,
	v_action_type,
	v_variable_level,
	v_variable_name,
	v_variable_direction,
	v_variable_value,
	v_default_value,
	v_sequence_name,
	v_custom_procedure_name,
	v_data_type,
	v_function_name,
	v_where_clause,
	v_variable_pos,
	v_cond_logical_operator,
	v_cond_operator1,
	v_cond_var1_level,
	v_cond_var1_name,
	v_cond_var1_pos,
	v_cond_var1_direction,
	v_cond_var1_constant,
	v_cond_val1_level,
	v_cond_val1_name,
	v_cond_val1_pos,
	v_cond_val1_direction,
	v_cond_val1_constant,
	v_cond_operator2,
	v_cond_var2_level,
	v_cond_var2_name,
	v_cond_var2_pos,
	v_cond_var2_direction,
	v_cond_var2_constant,
	v_cond_val2_level,
	v_cond_val2_name,
	v_cond_val2_pos,
	v_cond_val2_direction,
	v_cond_val2_constant,
	v_operand1_level,
	v_operand1_name,
	v_operand1_pos,
	v_operand1_direction,
	v_operand1_constant,
	v_operand1_len,
	v_operand1_start_pos,
	v_operand2_level,
	v_operand2_name,
	v_operand2_pos,
	v_operand2_direction,
	v_operand2_constant,
	v_operand3_level,
	v_operand3_name,
	v_operand3_pos,
	v_operand3_direction,
	v_operand3_constant,
	v_operand4_level,
	v_operand4_name,
	v_operand4_pos,
	v_operand4_direction,
	v_operand4_constant,
	v_operand5_level,
	v_operand5_name,
	v_operand5_pos,
	v_operand5_direction,
	v_operand5_constant,
	v_operand6_level,
	v_operand6_name,
	v_operand6_pos,
	v_operand6_direction,
	v_operand6_constant


	from    ecx_tran_stage_data a,
	ecx_object_levels b
	where   a.map_id = i_map_id
	and     a.map_id = b.map_id
	and     a.objectlevel_id = b.objectlevel_id
	and     action_type <> 10
	order by stage,object_level,action_pos,seq_number;


   if (v_transtage_id.COUNT > 0) then
   for i in v_transtage_id.FIRST..v_transtage_id.LAST
   loop
--      temp_stage_rec := i_stage_data(i);
      temp_util_rec.transtage_id := v_transtage_id(i);
      temp_util_rec.level := v_object_level(i);
      temp_util_rec.stage := v_stage(i);
      temp_util_rec.object_direction := v_object_direction(i);
      temp_util_rec.seq_number := v_seq_number(i);
      temp_util_rec.action_type := v_action_type(i);
      temp_util_rec.variable_level := v_variable_level(i);
      temp_util_rec.variable_name := v_variable_name(i);
      temp_util_rec.variable_pos := v_variable_pos(i);
      temp_util_rec.variable_direction := v_variable_direction(i);
      temp_util_rec.variable_value := v_variable_value(i);
      temp_util_rec.default_value := v_default_value(i);
      temp_util_rec.sequence_name := v_sequence_name(i);
      temp_util_rec.custom_procedure_name := v_custom_procedure_name(i);
      temp_util_rec.data_type := v_data_type(i);
      temp_util_rec.function_name := v_function_name(i);
      temp_util_rec.clause := v_where_clause(i);
      temp_util_rec.cond_logical_operator := v_cond_logical_operator(i);
      temp_util_rec.cond_operator1 := v_cond_operator1(i);
      temp_util_rec.cond_var1_level := v_cond_var1_level(i);
      temp_util_rec.cond_var1_name := v_cond_var1_name(i);
      temp_util_rec.cond_var1_pos := v_cond_var1_pos(i);
      temp_util_rec.cond_var1_direction := v_cond_var1_direction(i);
      temp_util_rec.cond_var1_constant := v_cond_var1_constant(i);
      temp_util_rec.cond_val1_level := v_cond_val1_level(i);
      temp_util_rec.cond_val1_name := v_cond_val1_name(i);
      temp_util_rec.cond_val1_pos := v_cond_val1_pos(i);
      temp_util_rec.cond_val1_direction := v_cond_val1_direction(i);
      temp_util_rec.cond_val1_constant := v_cond_val1_constant(i);
      temp_util_rec.cond_operator2 := v_cond_operator2(i);
      temp_util_rec.cond_var2_level := v_cond_var2_level(i);
      temp_util_rec.cond_var2_name := v_cond_var2_name(i);
      temp_util_rec.cond_var2_pos := v_cond_var2_pos(i);
      temp_util_rec.cond_var2_direction := v_cond_var2_direction(i);
      temp_util_rec.cond_var2_constant := v_cond_var2_constant(i);
      temp_util_rec.cond_val2_level := v_cond_val2_level(i);
      temp_util_rec.cond_val2_name := v_cond_val2_name(i);
      temp_util_rec.cond_val2_pos := v_cond_val2_pos(i);
      temp_util_rec.cond_val2_direction := v_cond_val2_direction(i);
      temp_util_rec.cond_val2_constant := v_cond_val2_constant(i);
      temp_util_rec.operand1_level := v_operand1_level(i);
      temp_util_rec.operand1_name := v_operand1_name(i);
      temp_util_rec.operand1_pos := v_operand1_pos(i);
      temp_util_rec.operand1_direction := v_operand1_direction(i);
      temp_util_rec.operand1_constant := v_operand1_constant(i);
      temp_util_rec.operand1_len := v_operand1_len(i);
      temp_util_rec.operand1_start_pos := v_operand1_start_pos(i);
      temp_util_rec.operand2_level := v_operand2_level(i);
      temp_util_rec.operand2_name := v_operand2_name(i);
      temp_util_rec.operand2_pos := v_operand2_pos(i);
      temp_util_rec.operand2_direction := v_operand2_direction(i);
      temp_util_rec.operand2_constant := v_operand2_constant(i);
      temp_util_rec.operand3_level := v_operand3_level(i);
      temp_util_rec.operand3_name := v_operand3_name(i);
      temp_util_rec.operand3_pos := v_operand3_pos(i);
      temp_util_rec.operand3_direction := v_operand3_direction(i);
      temp_util_rec.operand3_constant := v_operand3_constant(i);
      temp_util_rec.operand4_level := v_operand4_level(i);
      temp_util_rec.operand4_name := v_operand4_name(i);
      temp_util_rec.operand4_pos := v_operand4_pos(i);
      temp_util_rec.operand4_direction := v_operand4_direction(i);
      temp_util_rec.operand4_constant := v_operand4_constant(i);
      temp_util_rec.operand5_level := v_operand5_level(i);
      temp_util_rec.operand5_name := v_operand5_name(i);
      temp_util_rec.operand5_pos := v_operand5_pos(i);
      temp_util_rec.operand5_direction := v_operand5_direction(i);
      temp_util_rec.operand5_constant := v_operand5_constant(i);
      temp_util_rec.operand6_level := v_operand6_level(i);
      temp_util_rec.operand6_name := v_operand6_name(i);
      temp_util_rec.operand6_pos := v_operand6_pos(i);
      temp_util_rec.operand6_direction := v_operand6_direction(i);
      temp_util_rec.operand6_constant := v_operand6_constant(i);

      IF (instr(temp_util_rec.custom_procedure_name, DELETE_DOCTYPE_PROC_NAME) > 0) THEN
      		g_delete_doctype := true;
		if(l_statementEnabled) then
		        ecx_debug.log(l_statement, 'g_delete_doctype = true',i_method_name);
		end if;
      END IF;


if(l_statementEnabled) then
      ecx_debug.log(l_statement,temp_util_rec.transtage_id||'|'||
                    temp_util_rec.level||'|'||
                    temp_util_rec.stage||'|'||
                    temp_util_rec.object_direction||'|'||
                    temp_util_rec.seq_number||'|'||
                    temp_util_rec.action_type||'|'||
                    temp_util_rec.variable_level||'|'||
                    temp_util_rec.variable_name||'|'||
                    temp_util_rec.variable_pos||'|'||
                    temp_util_rec.variable_direction||'|'||
                    temp_util_rec.variable_value||'|'||
                    temp_util_rec.default_value||'|'||
                    temp_util_rec.custom_procedure_name||'|'||
                    temp_util_rec.data_type||'|'||
                    temp_util_rec.function_name||'|'||
                    temp_util_rec.clause||'|'||
                    temp_util_rec.cond_logical_operator||'|'||
                    temp_util_rec.cond_operator1||'|'||
                    temp_util_rec.cond_var1_level||'|'||
                    temp_util_rec.cond_var1_name||'|'||
                    temp_util_rec.cond_var1_pos||'|'||
                    temp_util_rec.cond_var1_direction||'|'||
                    temp_util_rec.cond_var1_constant||'|'||
                    temp_util_rec.cond_val1_level||'|'||
                    temp_util_rec.cond_val1_name||'|'||
                    temp_util_rec.cond_val1_pos||'|'||
                    temp_util_rec.cond_val1_direction||'|'||
                    temp_util_rec.cond_val1_constant||'|'||
                    temp_util_rec.cond_operator2||'|'||
                    temp_util_rec.cond_var2_level||'|'||
                    temp_util_rec.cond_var2_name||'|'||
                    temp_util_rec.cond_var2_pos||'|'||
                    temp_util_rec.cond_var2_direction||'|'||
                    temp_util_rec.cond_var2_constant||'|'||
                    temp_util_rec.cond_val2_level||'|'||
                    temp_util_rec.cond_val2_name||'|'||
                    temp_util_rec.cond_val2_pos||'|'||
                    temp_util_rec.cond_val2_direction||'|'||
                    temp_util_rec.cond_val2_constant||'|'||
                    temp_util_rec.operand1_level||'|'||
                    temp_util_rec.operand1_name||'|'||
                    temp_util_rec.operand1_pos||'|'||
                    temp_util_rec.operand1_direction||'|'||
                    temp_util_rec.operand1_constant||'|'||
                    temp_util_rec.operand1_start_pos||'|'||
                    temp_util_rec.operand1_len||'|'||
                    temp_util_rec.operand2_level||'|'||
                    temp_util_rec.operand2_name||'|'||
                    temp_util_rec.operand2_pos||'|'||
                    temp_util_rec.operand2_direction||'|'||
                    temp_util_rec.operand2_constant||'|'||
                    temp_util_rec.operand3_level||'|'||
                    temp_util_rec.operand3_name||'|'||
                    temp_util_rec.operand3_pos||'|'||
                    temp_util_rec.operand3_direction||'|'||
                    temp_util_rec.operand3_constant||'|'||
                    temp_util_rec.operand4_level||'|'||
                    temp_util_rec.operand4_name||'|'||
                    temp_util_rec.operand4_pos||'|'||
                    temp_util_rec.operand4_direction||'|'||
                    temp_util_rec.operand4_constant||'|'||
                    temp_util_rec.operand5_level||'|'||
                    temp_util_rec.operand5_name||'|'||
                    temp_util_rec.operand5_pos||'|'||
                    temp_util_rec.operand5_direction||'|'||
                    temp_util_rec.operand5_constant||'|'||
                    temp_util_rec.operand6_level||'|'||
                    temp_util_rec.operand6_name||'|'||
                    temp_util_rec.operand6_pos||'|'||
                    temp_util_rec.operand6_direction||'|'||
                    temp_util_rec.operand6_constant, i_method_name
		    );
end if;
	  ecx_utils.g_stage_data(i_counter) := temp_util_rec;

	i_counter := i_counter + 1;
   end loop;
   end if;


/*   for get_stage_data in stage_data (
      p_map_id => i_map_id) loop

      ecx_utils.g_stage_data(i_counter).transtage_id := get_stage_data.transtage_id;
      ecx_utils.g_stage_data(i_counter).level := get_stage_data.object_level;
      ecx_utils.g_stage_data(i_counter).stage := get_stage_data.stage;
      ecx_utils.g_stage_data(i_counter).object_direction := get_stage_data.object_direction;
      ecx_utils.g_stage_data(i_counter).seq_number := get_stage_data.seq_number;
      ecx_utils.g_stage_data(i_counter).action_type := get_stage_data.action_type;
      ecx_utils.g_stage_data(i_counter).variable_level := get_stage_data.variable_level;
      ecx_utils.g_stage_data(i_counter).variable_name := get_stage_data.variable_name;
      ecx_utils.g_stage_data(i_counter).variable_pos := get_stage_data.variable_pos;
      ecx_utils.g_stage_data(i_counter).variable_direction := get_stage_data.variable_direction;
      ecx_utils.g_stage_data(i_counter).variable_value := get_stage_data.variable_value;
      ecx_utils.g_stage_data(i_counter).default_value := get_stage_data.default_value;
      ecx_utils.g_stage_data(i_counter).sequence_name := get_stage_data.sequence_name;
      ecx_utils.g_stage_data(i_counter).custom_procedure_name := get_stage_data.custom_procedure_name;
      ecx_utils.g_stage_data(i_counter).data_type := get_stage_data.data_type;
      ecx_utils.g_stage_data(i_counter).function_name := get_stage_data.function_name;
      ecx_utils.g_stage_data(i_counter).clause := get_stage_data.where_clause;
      ecx_utils.g_stage_data(i_counter).cond_logical_operator := get_stage_data.cond_logical_operator;
      ecx_utils.g_stage_data(i_counter).cond_operator1 := get_stage_data.cond_operator1;
      ecx_utils.g_stage_data(i_counter).cond_var1_level := get_stage_data.cond_var1_level;
      ecx_utils.g_stage_data(i_counter).cond_var1_name := get_stage_data.cond_var1_name;
      ecx_utils.g_stage_data(i_counter).cond_var1_pos := get_stage_data.cond_var1_pos;
      ecx_utils.g_stage_data(i_counter).cond_var1_direction := get_stage_data.cond_var1_direction;
      ecx_utils.g_stage_data(i_counter).cond_var1_constant := get_stage_data.cond_var1_constant;
      ecx_utils.g_stage_data(i_counter).cond_val1_level := get_stage_data.cond_val1_level;
      ecx_utils.g_stage_data(i_counter).cond_val1_name := get_stage_data.cond_val1_name;
      ecx_utils.g_stage_data(i_counter).cond_val1_pos := get_stage_data.cond_val1_pos;
      ecx_utils.g_stage_data(i_counter).cond_val1_direction := get_stage_data.cond_val1_direction;
      ecx_utils.g_stage_data(i_counter).cond_val1_constant := get_stage_data.cond_val1_constant;
      ecx_utils.g_stage_data(i_counter).cond_operator2 := get_stage_data.cond_operator2;
      ecx_utils.g_stage_data(i_counter).cond_var2_level := get_stage_data.cond_var2_level;
      ecx_utils.g_stage_data(i_counter).cond_var2_name := get_stage_data.cond_var2_name;
      ecx_utils.g_stage_data(i_counter).cond_var2_pos := get_stage_data.cond_var2_pos;
      ecx_utils.g_stage_data(i_counter).cond_var2_direction := get_stage_data.cond_var2_direction;
      ecx_utils.g_stage_data(i_counter).cond_var2_constant := get_stage_data.cond_var2_constant;
      ecx_utils.g_stage_data(i_counter).cond_val2_level := get_stage_data.cond_val2_level;
      ecx_utils.g_stage_data(i_counter).cond_val2_name := get_stage_data.cond_val2_name;
      ecx_utils.g_stage_data(i_counter).cond_val2_pos := get_stage_data.cond_val2_pos;
      ecx_utils.g_stage_data(i_counter).cond_val2_direction := get_stage_data.cond_val2_direction;
      ecx_utils.g_stage_data(i_counter).cond_val2_constant := get_stage_data.cond_val2_constant;
      ecx_utils.g_stage_data(i_counter).operand1_level := get_stage_data.operand1_level;
      ecx_utils.g_stage_data(i_counter).operand1_name := get_stage_data.operand1_name;
      ecx_utils.g_stage_data(i_counter).operand1_pos := get_stage_data.operand1_pos;
      ecx_utils.g_stage_data(i_counter).operand1_direction := get_stage_data.operand1_direction;
      ecx_utils.g_stage_data(i_counter).operand1_constant := get_stage_data.operand1_constant;
      ecx_utils.g_stage_data(i_counter).operand1_len := get_stage_data.operand1_len;
      ecx_utils.g_stage_data(i_counter).operand1_start_pos := get_stage_data.operand1_start_pos;
      ecx_utils.g_stage_data(i_counter).operand2_level := get_stage_data.operand2_level;
      ecx_utils.g_stage_data(i_counter).operand2_name := get_stage_data.operand2_name;
      ecx_utils.g_stage_data(i_counter).operand2_pos := get_stage_data.operand2_pos;
      ecx_utils.g_stage_data(i_counter).operand2_direction := get_stage_data.operand2_direction;
      ecx_utils.g_stage_data(i_counter).operand2_constant := get_stage_data.operand2_constant;
      ecx_utils.g_stage_data(i_counter).operand3_level := get_stage_data.operand3_level;
      ecx_utils.g_stage_data(i_counter).operand3_name := get_stage_data.operand3_name;
      ecx_utils.g_stage_data(i_counter).operand3_pos := get_stage_data.operand3_pos;
      ecx_utils.g_stage_data(i_counter).operand3_direction := get_stage_data.operand3_direction;
      ecx_utils.g_stage_data(i_counter).operand3_constant := get_stage_data.operand3_constant;
      ecx_utils.g_stage_data(i_counter).operand4_level := get_stage_data.operand4_level;
      ecx_utils.g_stage_data(i_counter).operand4_name := get_stage_data.operand4_name;
      ecx_utils.g_stage_data(i_counter).operand4_pos := get_stage_data.operand4_pos;
      ecx_utils.g_stage_data(i_counter).operand4_direction := get_stage_data.operand4_direction;
      ecx_utils.g_stage_data(i_counter).operand4_constant := get_stage_data.operand4_constant;
      ecx_utils.g_stage_data(i_counter).operand5_level := get_stage_data.operand5_level;
      ecx_utils.g_stage_data(i_counter).operand5_name := get_stage_data.operand5_name;
      ecx_utils.g_stage_data(i_counter).operand5_pos := get_stage_data.operand5_pos;
      ecx_utils.g_stage_data(i_counter).operand5_direction := get_stage_data.operand5_direction;
      ecx_utils.g_stage_data(i_counter).operand5_constant := get_stage_data.operand5_constant;
      ecx_utils.g_stage_data(i_counter).operand6_level := get_stage_data.operand6_level;
      ecx_utils.g_stage_data(i_counter).operand6_name := get_stage_data.operand6_name;
      ecx_utils.g_stage_data(i_counter).operand6_pos := get_stage_data.operand6_pos;
      ecx_utils.g_stage_data(i_counter).operand6_direction := get_stage_data.operand6_direction;
      ecx_utils.g_stage_data(i_counter).operand6_constant := get_stage_data.operand6_constant;

      if(l_statementEnabled) then
           ecx_debug.log(l_statement,
                    ecx_utils.g_stage_data(i_counter).transtage_id||'|'||
                    ecx_utils.g_stage_data(i_counter).level||'|'||
                    ecx_utils.g_stage_data(i_counter).stage||'|'||
                    ecx_utils.g_stage_data(i_counter).object_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).seq_number||'|'||
                    ecx_utils.g_stage_data(i_counter).action_type||'|'||
                    ecx_utils.g_stage_data(i_counter).variable_level||'|'||
                    ecx_utils.g_stage_data(i_counter).variable_name||'|'||
                    ecx_utils.g_stage_data(i_counter).variable_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).variable_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).variable_value||'|'||
                    ecx_utils.g_stage_data(i_counter).default_value||'|'||
                    ecx_utils.g_stage_data(i_counter).custom_procedure_name||'|'||
                    ecx_utils.g_stage_data(i_counter).data_type||'|'||
                    ecx_utils.g_stage_data(i_counter).function_name||'|'||
                    ecx_utils.g_stage_data(i_counter).clause||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_logical_operator||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_operator1||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var1_level||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var1_name||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var1_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var1_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var1_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val1_level||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val1_name||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val1_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val1_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val1_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_operator2||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var2_level||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var2_name||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var2_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var2_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_var2_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val2_level||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val2_name||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val2_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val2_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).cond_val2_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_start_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand1_len||'|'||
                    ecx_utils.g_stage_data(i_counter).operand2_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand2_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand2_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand2_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand2_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand3_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand3_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand3_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand3_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand3_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand4_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand4_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand4_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand4_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand4_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand5_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand5_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand5_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand5_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand5_constant||'|'||
                    ecx_utils.g_stage_data(i_counter).operand6_level||'|'||
                    ecx_utils.g_stage_data(i_counter).operand6_name||'|'||
                    ecx_utils.g_stage_data(i_counter).operand6_pos||'|'||
                    ecx_utils.g_stage_data(i_counter).operand6_direction||'|'||
                    ecx_utils.g_stage_data(i_counter).operand6_constant,
		    i_method_name
		    );
	end if;
	i_counter := i_counter + 1;
   end loop;
*/
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN ecx_utils.PROGRAM_EXIT then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name, 'PROGRESS_LEVEL',
                  'ecx_UTILS.GET_TRAN_STAGE_DATA');
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name,'ERROR_MESSAGE', SQLERRM);
          ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.GET_TRAN_STAGE_DATA: ',
	               i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.GET_TRAN_STAGE_DATA: ');
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
      raise ecx_utils.PROGRAM_EXIT;

END get_tran_stage_data;

procedure getLogDirectory
is
i_method_name   varchar2(2000) := 'ecx_utils.getLogDirectory';
i_string	varchar2(2000);
begin
	--- Check for the Installation Type ( Standalone or Embedded );
	ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');

	if ecx_utils.g_install_mode = 'EMBEDDED'
	then
		i_string := 'begin
			fnd_profile.get('||'''ECX_UTL_LOG_DIR'''||',ecx_utils.g_logdir);
	     	end;';
		execute immediate i_string ;
	else
		ecx_utils.g_logdir := wf_core.translate('ECX_UTL_LOG_DIR');
	end if;


        /* Remove the additional '/' at the end of the profile option if present
           or else it will cause error in the ecx_debug.print_log */

        If (ecx_utils.g_logdir is not null) then
             if (substr(ecx_utils.g_logdir,-1,1) = '/') then
                 ecx_utils.g_logdir := substr(ecx_utils.g_logdir,1,
                                              length(ecx_utils.g_logdir)-1);
             end if;
       End If;
       if(l_statementEnabled) then
            ecx_debug.log(l_statement, 'ecx_utils.g_logdir',ecx_utils.g_logdir,i_method_name);
       end if;

exception
when others then
	raise ecx_utils.program_exit;
end getLogDirectory;

/*
  Gets the file separator from the SystemProperty class
*/
Function GetFileSeparator
return varchar2
is language java name 'oracle.apps.ecx.util.SystemProperty.getFileSeparator() returns java.lang.String';


/*
  Gets the line separator from the SystemProperty class
*/
Function GetLineSeparator
return varchar2
is language java name 'oracle.apps.ecx.util.SystemProperty.getLineSeparator() returns java.lang.String';

Procedure set_error(
   p_error_type in pls_integer,
   p_error_code in pls_integer,
   p_error_msg  in varchar2,
   p_token1     in varchar2,
   p_value1     in varchar2,
   p_token2     in varchar2,
   p_value2     in varchar2,
   p_token3     in varchar2,
   p_value3     in varchar2,
   p_token4     in varchar2,
   p_value4     in varchar2,
   p_token5     in varchar2,
   p_value5     in varchar2,
   p_token6     in varchar2,
   p_value6     in varchar2,
   p_token7     in varchar2,
   p_value7     in varchar2,
   p_token8     in varchar2,
   p_value8     in varchar2,
   p_token9     in varchar2,
   p_value9     in varchar2,
   p_token10    in varchar2,
   p_value10    in varchar2
)
is
i_method_name   varchar2(2000) := 'ecx_utils.set_error';
begin

if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;
ecx_debug.setErrorInfo(p_error_code => p_error_code,
                       p_error_type => p_error_type,
                       p_errmsg_name=> p_error_msg,
                       p_token1     => p_token1,
                       p_value1     => p_value1,
                       p_token2     => p_token2,
                       p_value2     => p_value2,
                       p_token3     => p_token3,
                       p_value3     => p_value3,
                       p_token4     => p_token4,
                       p_value4     => p_value4,
                       p_token5     => p_token5,
                       p_value5     => p_value5,
                       p_token6     => p_token6,
                       p_value6     => p_value6,
                       p_token7     => p_token7,
                       p_value7     => p_value7,
                       p_token8     => p_token8,
                       p_value8     => p_value8,
                       p_token9     => p_token9,
                       p_value9     => p_value9,
                       p_token10    => p_token10,
                       p_value10    => p_value10);

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
  when others then
     if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_PROGRAM_ERROR', i_method_name, 'PROGRESS_LEVEL',
                  'ECX_UTILS.SET_ERROR',i_method_name);
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', 'ERROR_MESSAGE', SQLERRM,i_method_name);
         ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.SET_ERROR: ',
	              i_method_name);
     end if;
     ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_UTILS.SET_ERROR: ');
     if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.PROGRAM_EXIT;
end set_error;

procedure convertPartyTypeToCode(
   p_party_type    IN         Varchar2,
   x_party_type    OUT NOCOPY Varchar2) is
i_method_name   varchar2(2000) := 'ecx_utils.convertPartyTypeToCode';
begin
   if (p_party_type is not null) then
       x_party_type := UPPER(p_party_type);
       if (x_party_type = 'BANK' or x_party_type = 'B') then
           x_party_type := 'B';
       elsif (x_party_type = 'CUSTOMER' or x_party_type = 'C') then
           x_party_type := 'C';
       elsif (x_party_type = 'INTERNAL' or x_party_type = 'I') then
           x_party_type := 'I';
       elsif (x_party_type = 'SUPPLIER' or x_party_type = 'S') then
           x_party_type := 'S';
       elsif (x_party_type = 'EXCHANGE' or x_party_type = 'E') then
           x_party_type := 'E';
       elsif (x_party_type = 'CARRIER') then
           x_party_type := 'CARRIER';
       else
           x_party_type := p_party_type;
       end if;
   else
      x_party_type := null;
   end if;
exception
   when others then
     ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_UTILS.ConvertPartyTypeToCode: ');
     if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
     end if;
     if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.PROGRAM_EXIT;
end convertPartyTypeToCode;

/* Return the node path of given attribute, from root till it's parent attribute*/
function getNodePath
	   (v_map_id IN NUMBER,
	   	v_attribute_id IN NUMBER) return varchar2
IS
  i_method_name   varchar2(2000) := 'ecx_utils.getNodePath';
  l_attribute_name	ecx_object_attributes.attribute_name%type;
  l_attribute_id	ecx_object_attributes.attribute_id%type;
  l_node_path		varchar2(32767);
  l_parent_name		ecx_object_attributes.attribute_name%type;
  l_parent_id		ecx_object_attributes.attribute_id%type;
  l_root_node		ecx_object_attributes.attribute_name%type;

begin
	if (l_procedureEnabled) then
           ecx_debug.push(i_method_name);
        end if;
	SELECT object_level_name INTO l_root_node
	FROM ecx_object_levels
	WHERE map_id=v_map_id and object_level=0 and object_id=1;

	IF (v_attribute_id = 0) THEN
		return l_root_node;
	END IF;

	SELECT  attribute_name,attribute_id,parent_attribute_id
		INTO l_attribute_name,l_attribute_id,l_parent_id
	FROM ecx_object_attributes
	WHERE map_id = v_map_id and objectlevel_id in(
		select objectlevel_id from ecx_object_levels
	        WHERE map_id=v_map_id and object_id = 1) AND attribute_id=v_attribute_id;

	l_node_path := NULL;

	   Loop
		   EXIT WHEN l_parent_id=0;
		   SELECT  attribute_name,attribute_id,parent_attribute_id
			INTO l_attribute_name,l_attribute_id,l_parent_id
		   FROM ecx_object_attributes
		   WHERE map_id = v_map_id and objectlevel_id in(
			select objectlevel_id from ecx_object_levels
		        WHERE map_id=v_map_id and object_id = 1) AND attribute_id=l_parent_id;

		   IF (l_node_path IS NULL ) THEN
			   l_node_path := l_attribute_name;
		   ELSE
			   l_node_path := l_attribute_name||'<'||l_node_path;
		   END IF;


	END LOOP;
	IF (l_node_path IS NULL ) THEN
		l_node_path := l_root_node;
	ELSE
		l_node_path := l_root_node||'<'||l_node_path;
	END IF;
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	return l_node_path;
	exception
   when others then
     ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_UTILS.getNodePath ');
     if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
     end if;
     if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.PROGRAM_EXIT;
End getNodePath;

/*get XML Parser version*/

Function XMLVersion
return varchar2
is language java name 'oracle.xml.parser.v2.XMLParser.getReleaseVersion() returns java.lang.String';


end ecx_utils;

/
