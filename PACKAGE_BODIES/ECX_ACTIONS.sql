--------------------------------------------------------
--  DDL for Package Body ECX_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_ACTIONS" as
-- $Header: ECXACTNB.pls 120.12 2006/07/07 10:00:09 gsingh ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

ASSIGN_DEFAULT			CONSTANT	pls_integer 	:=20;
ASSIGN_PRE_DEFINED		CONSTANT	pls_integer	:=30;
ASSIGN_NEXTVALUE		CONSTANT	pls_integer	:=40;
ASSIGN_FUNCVAL			CONSTANT	pls_integer	:=100;
APPEND_WHERECLAUSE              CONSTANT        pls_integer  	:= 1000;
EXEC_PROCEDURES                 CONSTANT        pls_integer  	:= 1050;
SEND_ERROR                      CONSTANT        pls_integer     := 1120;
API_RETURN_CODE                 CONSTANT        pls_integer     := 1130;
DOC_ID				CONSTANT	pls_integer	:= 1140;
CONV_TO_OAGDATE                 CONSTANT        pls_integer     := 2000;
CONV_TO_OAGOPERAMT              CONSTANT        pls_integer     := 2010;
CONV_TO_OAGQUANT                CONSTANT        pls_integer     := 2020;
CONV_FROM_OAGDATE               CONSTANT        pls_integer     := 2030;
CONV_FROM_OAGOPERAMT            CONSTANT        pls_integer     := 2040;
CONV_FROM_OAGQUANT              CONSTANT        pls_integer     := 2050;
CONV_TO_OAGAMT                  CONSTANT        pls_integer     := 2100;
CONV_FROM_OAGAMT                CONSTANT        pls_integer     := 2110;
INSERT_INTO_OPEN_INTERFACE      CONSTANT        pls_integer     := 3000;
EXITPROGRAM            		CONSTANT        pls_integer     := 3020;
SUBSTR_VAR                      CONSTANT        pls_integer     := 3030;
CONCAT_VAR                      CONSTANT        pls_integer     := 3040;
ADD                		CONSTANT        pls_integer     := 4000;
SUB                		CONSTANT        pls_integer     := 4010;
MUL                		CONSTANT        pls_integer     := 4020;
DIV                		CONSTANT        pls_integer     := 4030;
XSLT_TRANSFORM			CONSTANT	pls_integer	:= 5000;
GET_ADDRESS_ID			CONSTANT	pls_integer	:= 6000;

procedure get_var_attr (
   i_variable_level       IN    pls_integer,
   i_variable_name        IN    Varchar2,
   i_variable_direction   IN    VARCHAR2,
   i_variable_pos         IN    pls_integer,
   x_value                OUT   NOCOPY Varchar2,
   x_stack_var            OUT   NOCOPY Boolean,
   x_stack_pos            OUT   NOCOPY pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.get_var_attr';
   l_var_present          Boolean := FALSE;
   l_dummy                pls_integer;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level', i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name', i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos', i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction', i_variable_direction,i_method_name);
   end if;

   --if (i_variable_level = 0 ) then
   if ( i_variable_direction = 'G' )
   then
      l_var_present := find_stack_variable (i_variable_name,
                                    x_stack_pos);
      if (l_var_present) then
         x_stack_var := TRUE;
         x_value := ecx_utils.g_stack(x_stack_pos).variable_value;
      else
         if(l_statementEnabled) then
          ecx_debug.log(l_statement,'ECX', 'ECX_VARIABLE_NOT_ON_STACK', i_method_name,
	              'VARIABLE_NAME',i_variable_name);
         end if;
         ecx_debug.setErrorInfo(2,30,'ECX_STACKVAR_NOT_FOUND');
         raise ecx_utils.PROGRAM_EXIT;
      end if;
   else
         /* Get the Value based on the direction */
      	 if ( i_variable_direction = 'S' )
      	 then
            x_value := ecx_utils.g_source(i_variable_pos).value;
      	 else
            x_value := ecx_utils.g_target(i_variable_pos).value;
      	 end if;
      	 x_stack_var := FALSE;
   end if;

   if(l_statementEnabled) then
    ecx_debug.log(l_statement,'x_value', x_value,i_method_name);
    ecx_debug.log(l_statement,'x_stack_var', x_stack_var,i_method_name);
    ecx_debug.log(l_statement,'x_stack_pos', x_stack_pos,i_method_name);
   end if;

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
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                   'ECX_ACTIONS.GET_VAR_ATTR');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_VAR_ATTR');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END get_var_attr;

procedure assign_value (
   i_stack_var      IN    Boolean,
   i_stack_pos      IN    pls_integer,
   i_plsql_pos      IN    pls_integer,
   i_direction      IN    varchar2,
   i_value          IN    Varchar2) IS
i_method_name   varchar2(2000) := 'ecx_actions.assign_value';
BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_stack_var', i_stack_var,i_method_name);
     ecx_debug.log(l_statement,'i_stack_pos', i_stack_pos,i_method_name);
     ecx_debug.log(l_statement,'i_plsql_pos', i_plsql_pos,i_method_name);
     ecx_debug.log(l_statement,'i_value', i_value,i_method_name);
     ecx_debug.log(l_statement,'i_direction', i_direction,i_method_name);
   end if;

   if (i_stack_var) then
      ecx_utils.g_stack(i_stack_pos).variable_value := i_value;
   else
      /* Based on the direction look into either Source or Target Struct */
      if ( i_direction = 'S' )
      then
         ecx_utils.g_source(i_plsql_pos).value := i_value;
      else
         ecx_utils.g_target(i_plsql_pos).value := i_value;
      end if;
   end if;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                   'ECX_ACTIONS.ASSIGN_VALUE');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_VALUE');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;

      raise ecx_utils.PROGRAM_EXIT;

END assign_value;


---This is overloaded procedure to handle clob value

procedure assign_value (
   i_stack_var      IN    Boolean,
   i_stack_pos      IN    pls_integer,
   i_plsql_pos      IN    pls_integer,
   i_direction      IN    varchar2,
   i_c_value        IN    Clob) IS

i_method_name   varchar2(2000) := 'ecx_actions.assign_value';

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_stack_var', i_stack_var,i_method_name);
     ecx_debug.log(l_statement,'i_stack_pos', i_stack_pos,i_method_name);
     ecx_debug.log(l_statement,'i_plsql_pos', i_plsql_pos,i_method_name);
     ecx_debug.log(l_statement,'i_c_value', i_c_value,i_method_name);
     ecx_debug.log(l_statement,'i_direction', i_direction,i_method_name);
   end if;

   if (i_stack_var) then
      /** Change required for Clob Support -- 2263729 ***/
      /*** Change  Storing CLOB as a varchar2***/
      ecx_utils.g_stack(i_stack_pos).variable_value := dbms_lob.substr(i_c_value,
                                                       ecx_utils.G_VARCHAR_LEN ,1);
   else
      /* Based on the direction look into either Source or Target Struct */
      if ( i_direction = 'S' )
      then
         ecx_utils.g_source(i_plsql_pos).clob_value := i_c_value;
         ecx_utils.g_source(i_plsql_pos).is_clob := 'N';
      else
         ecx_utils.g_target(i_plsql_pos).clob_value := i_c_value;
         ecx_utils.g_target(i_plsql_pos).is_clob := 'N';
      end if;
   end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name, 'PROGRESS_LEVEL',
                   'ECX_ACTIONS.ASSIGN_VALUE');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE', i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_VALUE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;

      raise ecx_utils.PROGRAM_EXIT;

END assign_value;

function find_stack_variable (
   i_variable_name      IN     Varchar2,
   i_stack_pos          OUT    NOCOPY pls_integer) return Boolean IS

   i_method_name   varchar2(2000) := 'ecx_actions.find_stack_variable';
   bFound          Boolean := FALSE;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
   end if;

   for k in 1..ecx_utils.g_stack.count loop
      if UPPER(ecx_utils.g_stack(k).VARIABLE_NAME) = UPPER(i_variable_name)
      then
         i_stack_pos := k;
         bFound := TRUE;
         exit;
      end if;
   end loop;

   if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_stack_pos',i_stack_pos,i_method_name);
    ecx_debug.log(l_statement,'bFound',bFound,i_method_name);
   end if;
   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

   return bFound;

EXCEPTION
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                   'ECX_ACTIONS.FIND_STACK_VARIABLE');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.FIND_STACK_VARIABLE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END find_stack_variable;


procedure build_insert_stmt (
   p_insert_cursor IN OUT  NOCOPY pls_integer,
   p_level         IN      pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.build_insert_stmt';

   cInsert_stmt            varchar2(32000) := 'INSERT INTO ';
   cValue_stmt             varchar2(32000) := 'VALUES ( ';
   i                       pls_integer;
   l_error_position        pls_integer;
   l_parse_error           EXCEPTION;

BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   cInsert_stmt := cInsert_stmt || ' ' ||
                   ecx_utils.g_target_levels(p_level).base_table_name || ' (';


   i := ecx_utils.g_target_levels(p_level).file_start_pos;
   loop
      if (ecx_utils.g_target(i).internal_level = p_level) and
         (ecx_utils.g_target(i).base_column_name is not null) then
         cInsert_stmt := cInsert_stmt || ' ' ||
                         ecx_utils.g_target(i).base_column_name || ',';

         cValue_stmt := cValue_stmt || ':f' || i || ',';
      end if;
      exit when i = ecx_utils.g_target_levels(p_level).file_end_pos;
      i := ecx_utils.g_target.next(i);

   end loop;

   cInsert_stmt := RTRIM(cInsert_stmt, ',') || ')';
   cValue_stmt := RTRIM(cValue_stmt, ',') || ')';
   cInsert_stmt := cInsert_stmt || cValue_stmt;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'Insert_statement ', cInsert_stmt,i_method_name);
   end if;
   p_insert_cursor := dbms_sql.open_cursor;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'p_insert_cursor', p_insert_cursor,i_method_name);
   end if;

   begin
      dbms_sql.parse (p_insert_cursor, cInsert_stmt, dbms_sql.native);
   exception
      when others then
         l_error_position := dbms_sql.last_error_position;
         raise l_parse_error;
   end;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN l_parse_error then
      ecx_error_handling_pvt.print_parse_error (l_error_position, cInsert_stmt);
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', 'PROGRESS_LEVEL',i_method_name);
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE', i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BUILD_INSERT_STMT');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN others then
       if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', 'PROGRESS_LEVEL', 'ECX_ACTIONS.BUILD_INSERT_STMT');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE', i_method_name, 'ERROR_MESSAGE', SQLERRM);
       end if;
       ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BUILD_INSERT_STMT');

      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END build_insert_stmt;


procedure insert_level_into_table (
   p_level                    IN     pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.insert_level_into_table';

   l_dummy                    pls_integer;
   k                          pls_integer;
   l_date                     DATE;
   l_number                   number;
   l_insert_cursor            pls_integer;
   l_insert_failed            EXCEPTION;
   l_data_conversion_failed   EXCEPTION;
   l_clob_value               CLOB;
   l_value                    varchar2(32767);

BEGIN

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'p_level', p_level,i_method_name);
   end if;

   if (ecx_utils.g_target_levels(p_level).cursor_handle = 0 or
       ecx_utils.g_target_levels(p_level).cursor_handle is null) then
      build_insert_stmt (ecx_utils.g_target_levels(p_level).cursor_handle, p_level);
   end if;

   l_insert_cursor := ecx_utils.g_target_levels(p_level).cursor_handle;

   -- bind insert_statement

   k := ecx_utils.g_target_levels(p_level).file_start_pos;
   loop
      if (ecx_utils.g_target(k).internal_level = p_level) and
         (ecx_utils.g_target(k).base_column_name is not null) then

      BEGIN

         if ecx_utils.g_target(k).data_type = 12 then
            if ecx_utils.g_target(k).value is null then
               l_date := null;
            else
               l_date := to_date(ecx_utils.g_target(k).value,
                                    'YYYYMMDD HH24MISS');
            end if;
            if(l_statementEnabled) then
              ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name, l_date,i_method_name);
	    end if;
            dbms_sql.bind_variable (l_insert_cursor, 'f' || k, l_date);

         elsif ecx_utils.g_target(k).data_type = 2 then
            if ecx_utils.g_target(k).value is null then
               l_number := null;
            else
               l_number := to_number(ecx_utils.g_target(k).value);
            end if;
            if(l_statementEnabled) then
              ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name, l_number,i_method_name);
	    end if;
            dbms_sql.bind_variable (l_insert_cursor, 'f' || k, l_number);

        -- Target is a CLOB datatype
        elsif ecx_utils.g_target(k).data_type = 112 then

           get_clob (ecx_utils.g_target(k).clob_value ,
                     ecx_utils.g_target(k).value,
                     l_clob_value);

           dbms_sql.bind_variable (l_insert_cursor, 'f' || k,l_clob_value );

          if ecx_utils.g_target(k).clob_value is not null Then
                 if(l_statementEnabled) then
                         ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name,
			              ecx_utils.g_target(k).clob_value,
		                      i_method_name);
	         end if;
          else
	         if(l_statementEnabled) then
                   ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name, ecx_utils.g_target(k).value,
		                i_method_name);
		 end if;
          end if;

         -- Target data type is VARCHAR2
         else
             get_varchar(ecx_utils.g_target(k).clob_value ,
                         ecx_utils.g_target(k).value,
                         l_value);

             dbms_sql.bind_variable (l_insert_cursor, 'f' || k,l_value);


             if ecx_utils.g_target(k).clob_value is not null Then
		  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name,
		                 ecx_utils.g_target(k).clob_value,i_method_name);
		  end if;
             else
                 if(l_statementEnabled) then
                   ecx_debug.log(l_statement,ecx_utils.g_target(k).base_column_name, ecx_utils.g_target(k).value,
		                i_method_name);
		 end if;
             end if;

         end if;

      EXCEPTION
         WHEN others then
            if dbms_lob.istemporary(l_clob_value) = 1 Then
                dbms_lob.freetemporary(l_clob_value);
            end if;

            raise l_data_conversion_failed;
      END;

      end if;
      exit when k = ecx_utils.g_target_levels(p_level).file_end_pos;
      k := ecx_utils.g_target.next(k);
      if dbms_lob.istemporary(l_clob_value) = 1 Then
                dbms_lob.freetemporary(l_clob_value);
      end if;

   end loop;

   l_dummy := dbms_sql.execute(l_insert_cursor);
   if (l_dummy <> 1) then
      raise l_insert_failed;
   end if;

   if dbms_lob.istemporary(l_clob_value) = 1 Then
      dbms_lob.freetemporary(l_clob_value);
   end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN l_data_conversion_failed then
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected , 'ECX', 'ECX_DATATYPE_CONVERSION_FAILED',i_method_name, 'DATATYPE',
                  ecx_utils.g_target(k).data_type);
        ecx_debug.log(l_unexpected, ecx_utils.g_target(k).base_column_name,
                  'yy'||ecx_utils.g_target(k).value||'xx',i_method_name);
      end if;
      ecx_debug.setErrorInfo(2,30,'ECX_DATATYPE_CONV_FAILED');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN l_insert_failed then
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected ,'ECX', 'ECX_STAGE_INSERT_FAILED',i_method_name, 'LEVEL', p_level);
        ecx_debug.log(l_unexpected, 'ECX', 'ECX_PROGRAM_ERROR',i_method_name, 'PROGRESS_LEVEL', 'ECX_ACTIONS.INSERT_LEVEL_INTO_TABLE');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.INSERT_LEVEL_INTO_TABLE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN others then
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name, 'PROGRESS_LEVEL', 'ECX_ACTIONS.INSERT_LEVEL_INTO_TABLE');
        ecx_debug.log(l_unexpected,'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' -  ECX_ACTIONS.INSERT_LEVEL_INTO_TABLE');

      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END insert_level_into_table;


/**
Executes a select string and returns the First Column from the select
clause as OUT parameter.
**/
procedure execute_string (
   cString         IN     Varchar2,
   o_value         OUT    NOCOPY Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.execute_string';

   cursor_handle   pls_integer;
   ret_query       pls_integer;
   m_value         Varchar2(20000);
   m_success       Boolean;
   error_position  pls_integer;
   parse_error     EXCEPTION;

BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'cString',cString,i_method_name);
   end if;

   cursor_handle := dbms_sql.open_cursor;

   BEGIN
      dbms_sql.parse(cursor_handle,cString,dbms_sql.native);

   EXCEPTION
      WHEN OTHERS THEN
         raise parse_error;
   END;

   dbms_sql.define_column(cursor_handle,1,m_value,20000);
   ret_query := dbms_sql.execute_and_fetch(cursor_handle,m_success);
   dbms_sql.column_value(cursor_handle,1,m_value);
   dbms_sql.close_cursor(cursor_handle);
   o_value := m_value;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'o_value',o_value,i_method_name);
   end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN PARSE_ERROR then
      error_position := dbms_sql.last_error_position;
      ecx_error_handling_pvt.print_parse_error (error_position,cString);
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_PROGRAM_ERROR', i_method_name, 'PROGRESS_LEVEL', 'ECX_ACTIONS.EXECUTE_STRING');
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      if dbms_sql.is_open(cursor_handle) then
         dbms_sql.close_cursor(cursor_handle);
      end if;
      ecx_debug.seTErrorInfo(2,30,SQLERRM||' - ECX_UTILS.EXECUTE_STRING');
      raise ecx_utils.PROGRAM_EXIT;

   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS then
      if DBMS_SQL.IS_OPEN(cursor_handle) then
         dbms_sql.close_cursor(cursor_handle);
      end if;
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                  'ECX_ACTIONS.EXECUTE_STRING');
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name, 'ERROR_MESSAGE', SQLERRM);
     end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.EXECUTE_STRING');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END execute_string;


procedure get_nextval_seq (
   i_seq_name     IN     Varchar2,
   o_value        OUT    NOCOPY Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.get_nextval_seq';
   cString        Varchar2(2000);

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   cString := 'select  '||i_seq_name||'.NEXTVAL  from dual';
   execute_string ( cString, o_value);

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;


EXCEPTION
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS then
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_PROGRAM_ERROR',i_method_name, 'PROGRESS_LEVEL',
                  'ECX_ACTIONS.GET_NEXTVAL_SEQ');
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_NEXTVAL_SEQ');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END get_nextval_seq;


/**
Returns the Function Value by building a select Clause for the
Function name.
**/
procedure get_function_value (
   i_function_name     IN     Varchar2,
   o_value             OUT    NOCOPY Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.get_function_value';
   cString             Varchar2(2000);

BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if i_function_name = 'SYSDATE' then
      select to_char(SYSDATE,'YYYYMMDD HH24MISS') into o_value from dual;

   else
      cString := i_function_name;
      cString := 'select  '||cString||'  from dual';
      execute_string (cString, o_value);
   end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS then
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                  'ECX_ACTIONS.GET_FUNCTION_VALUE');
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_FUNCTION_VALUE');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
     end if;
      raise ecx_utils.PROGRAM_EXIT;

END get_function_value;


procedure dump_stack IS

   i_method_name   varchar2(2000) := 'ecx_actions.dump_stack';
   m_count     pls_integer := ecx_utils.g_stack.COUNT;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'ECX','ECX_STACK_DUMP',i_method_name,null);
   end if;


   for i in 1..m_count loop
   --for i in m_count.first..m_count.last loop
     if(l_statementEnabled) then
       ecx_debug.log(l_statement,ecx_utils.g_stack(i).variable_name||' ' ||
                       ecx_utils.g_stack(i).variable_value||' '||
                       ecx_utils.g_stack(i).data_type,i_method_name);
     end if;
   end loop;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN OTHERS then
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL', 'ECX_ACTIONS.DUMP_STACK');
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name,'ERROR_MESSAGE',SQLERRM);
     end if;
     ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.DUMP_STACK');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END dump_stack;

PROCEDURE concat_variables
(
   i_variable_level           	IN     pls_integer,
   i_variable_name            	IN     Varchar2,
   i_variable_direction       	IN     Varchar2,
   i_variable_pos             	IN     pls_integer,
   i_previous_variable_level  	IN     pls_integer,
   i_previous_variable_name   	IN     Varchar2,
   i_previous_variable_direction   IN     Varchar2,
   i_previous_variable_pos    	IN     pls_integer,
   i_previous_default_value   	IN     varchar2,
   i_next_variable_level      	IN     pls_integer,
   i_next_variable_name   	IN     Varchar2,
   i_next_variable_direction    IN     varchar2,
   i_next_variable_pos   	IN     pls_integer,
   i_next_default_value    	IN     varchar2
)
IS

   i_method_name   varchar2(2000) := 'ecx_actions.concat_variables';

   var_value                  Varchar2(4000);
   var_on_stack               Boolean := FALSE;
   var_stack_pos              pls_integer;
   pre_var_value              Varchar2(4000);
   pre_var_on_stack           Boolean := FALSE;
   pre_var_stack_pos          pls_integer;
   nxt_var_value              Varchar2(4000);
   nxt_var_on_stack           Boolean := FALSE;
   nxt_var_stack_pos          pls_integer;
   concat_val                 varchar2(4000);
BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   get_var_attr(
               i_variable_level,
	       i_variable_name,
               i_variable_direction,
               i_variable_pos,
	       var_value,
	       var_on_stack,
               var_stack_pos
	       );

   pre_var_value := i_previous_default_value;
   if pre_var_value is null
   then
      get_var_attr(
		  i_previous_variable_level, i_previous_variable_name,
                  i_previous_variable_direction,
                  i_previous_variable_pos, pre_var_value, pre_var_on_stack,
                  pre_var_stack_pos
		  );
   end if;
   if pre_var_value = 'NULL'
   then
      pre_var_value :=null;
   end if;

   nxt_var_value := i_next_default_value;

   if nxt_var_value is null
   then
      get_var_attr(
	           i_next_variable_level, i_next_variable_name,
                   i_next_variable_direction,
                   i_next_variable_pos, nxt_var_value, nxt_var_on_stack,
                   nxt_var_stack_pos
		  );
   end if;
   if nxt_var_value = 'NULL'
   then
      nxt_var_value :=null;
   end if;

   concat_val := pre_var_value || nxt_var_value;

    assign_value(
		 var_on_stack,
		 var_stack_pos,
		 i_variable_pos,
		 i_variable_direction,
		 concat_val
		 );

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN VALUE_ERROR then
      ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	              'PROGRESS_LEVEL', 'ECX_ACTIONS.CONCAT_VAR');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONCAT_VAR');
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END concat_variables;

PROCEDURE substr_variables
(
   i_variable_level           	IN     pls_integer,
   i_variable_name            	IN     Varchar2,
   i_variable_direction            IN     Varchar2,
   i_variable_pos             	IN     pls_integer,
   i_previous_variable_level  	IN     pls_integer,
   i_previous_variable_name   	IN     Varchar2,
   i_previous_variable_direction   IN     Varchar2,
   i_previous_variable_pos    	IN     pls_integer,
   i_previous_variable_constant    IN     varchar2,
   i_operand2_level    		IN     pls_integer,
   i_operand2_name    		IN     varchar2,
   i_operand2_direction    	IN     varchar2,
   i_operand2_pos    		IN     pls_integer,
   i_operand2_constant    	IN     varchar2,
   i_operand3_level    		IN     pls_integer,
   i_operand3_name    		IN     varchar2,
   i_operand3_direction    	IN     varchar2,
   i_operand3_pos    		IN     pls_integer,
   i_operand3_constant    	IN     varchar2
)
IS

   i_method_name   varchar2(2000) := 'ecx_actions.substr_variables';
   var_value                  	Varchar2(4000);
   var_on_stack               	Boolean := FALSE;
   var_stack_pos              	pls_integer;
   pre_var_value              	Varchar2(4000);
   pre_var_on_stack           	Boolean := FALSE;
   pre_var_stack_pos          	pls_integer;
   substr_val                 	varchar2(4000);
   i_length			varchar2(200);
   i_operand2_stack		boolean := false;
   i_operand2_stack_pos		pls_integer;
   i_operand3_stack		boolean := false;
   i_operand3_stack_pos		pls_integer;
   i_start_pos			varchar2(200);
BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   get_var_attr (i_variable_level, i_variable_name,i_variable_direction,
                 i_variable_pos,
                 var_value, var_on_stack, var_stack_pos);

   pre_var_value := i_previous_variable_constant;
   if pre_var_value is null
   then
      get_var_attr (i_previous_variable_level, i_previous_variable_name,
                    i_previous_variable_direction,
                    i_previous_variable_pos, pre_var_value, pre_var_on_stack,
                    pre_var_stack_pos);
   end if;

   if pre_var_value = 'NULL'
   then
      pre_var_value :=null;
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_operand2_constant',i_operand2_constant,i_method_name);
   end if;
   i_start_pos := i_operand2_constant;
   if i_start_pos is null
   then
      get_var_attr (i_operand2_level, i_operand2_name,
                    i_operand2_direction,
                    i_operand2_pos, i_start_pos, i_operand2_stack,
                    i_operand2_stack_pos);
   end if;

   if i_start_pos = 'NULL'
   then
      i_start_pos :=null;
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_operand3_constant',i_operand3_constant,i_method_name);
   end if;
   i_length := i_operand3_constant;
   if i_length is null
   then
      get_var_attr (i_operand3_level, i_operand3_name,
                    i_operand3_direction,
                    i_operand3_pos, i_length, i_operand3_stack,
                    i_operand3_stack_pos);
   end if;

   if i_length = 'NULL'
   then
      i_length :=null;
   end if;

  substr_val := substr(pre_var_value,i_start_pos,
                        i_length);
  assign_value (var_on_stack, var_stack_pos,
                    i_variable_pos,i_variable_direction, substr_val);
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
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL', 'ECX_ACTIONS.SUBSTR_VAR');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	              'ERROR_MESSAGE',SQLERRM);
      end if;
       ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.SUBSTR_VAR');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END substr_variables;


/**
Assigns the Value from a Previously Defined Variable
i.e. 	i := j;
**/
procedure assign_pre_defined_variables (
   i_variable_level           IN    pls_integer,
   i_variable_name            IN    Varchar2,
   i_variable_direction            IN    Varchar2,
   i_variable_pos             IN    pls_integer,
   i_previous_variable_level  IN    pls_integer,
   i_previous_variable_name   IN    Varchar2,
   i_previous_variable_direction   IN    Varchar2,
   i_previous_variable_pos    IN    pls_integer,
   i_previous_variable_constant	IN	varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.assign_pre_defined_variables';

   var_value                  Varchar2(4000);
   var_on_stack               Boolean := FALSE;
   var_stack_pos              pls_integer;
   pre_var_value              Varchar2(4000);
   pre_var_on_stack           Boolean := FALSE;
   pre_var_stack_pos          pls_integer;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   get_var_attr (i_variable_level, i_variable_name,
                 i_variable_direction,i_variable_pos,
                 var_value, var_on_stack, var_stack_pos);

   pre_var_value := i_previous_variable_constant;

   if pre_var_value is null
   then
      get_var_attr (i_previous_variable_level, i_previous_variable_name,
                    i_previous_variable_direction,
                    i_previous_variable_pos, pre_var_value, pre_var_on_stack,
                   pre_var_stack_pos);
   end if;

   if pre_var_value = 'NULL'
   then
      pre_var_value :=null;
   end if;

   assign_value (var_on_stack, var_stack_pos,
                 i_variable_pos, i_variable_direction,pre_var_value);

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
         ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,
	             'PROGRESS_LEVEL',
                  'ECX_ACTIONS.ASSIGN_PRE_DEFINED_VARIABLES');
         ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name,
	              'ERROR_MESSAGE', SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_PRE_DEFINED_VARIABLES');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END assign_pre_defined_variables;


/**
Assign the Nextvalue from a sequence.
e.g.	x := document.NEXTVAL;
**/
procedure assign_nextval_from_sequence (
   i_variable_level       IN      pls_integer,
   i_variable_name        IN      Varchar2,
   i_variable_direction        IN      Varchar2,
   i_variable_pos         IN      pls_integer,
   i_sequence_name        IN      Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.assign_nextval_from_sequence';

   var_value              Varchar2(4000);
   var_on_stack           Boolean := FALSE;
   var_stack_pos          pls_integer;
   seq_value              pls_integer;

BEGIN

    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;


   get_var_attr (i_variable_level, i_variable_name,
                 i_variable_direction,i_variable_pos,
                 var_value, var_on_stack, var_stack_pos);

   get_nextval_seq (i_sequence_name, seq_value);

   assign_value (var_on_stack, var_stack_pos,
                    i_variable_pos,i_variable_direction, seq_value);

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
       ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                  'ECX_ACTIONS.ASSIGN_NEXTVAL_FROM_SEQUENCE');
       ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_NEXTVAL_FROM_SEQUENCE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END assign_nextval_from_sequence;


/**
Assigns the value returned by a function.
**/
procedure assign_function_value (
   i_variable_level     IN     pls_integer,
   i_variable_name      IN     Varchar2,
   i_variable_direction      IN     Varchar2,
   i_variable_pos       IN     pls_integer,
   i_function_name      IN     Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.assign_function_value';

   var_value            Varchar2(4000);
   var_on_stack         Boolean := FALSE;
   var_stack_pos        pls_integer;
   function_value       Varchar2(4000);

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   get_var_attr (i_variable_level, i_variable_name,
                 i_variable_direction,i_variable_pos,
                 var_value, var_on_stack, var_stack_pos);

   get_function_value (i_function_name, function_value);

   assign_value (var_on_stack, var_stack_pos,
                    i_variable_pos, i_variable_direction,function_value);

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
          ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name,
	               'PROGRESS_LEVEL', 'ECX_ACTIONS.ASSIGN_FUNCTION_VALUE');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	              'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_FUNCTION_VALUE');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END assign_function_value;


procedure append_clause (
   i_level           IN   pls_integer,
   i_where_clause    IN   Varchar2) IS

i_method_name   varchar2(2000) := 'ecx_actions.append_clause';


BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_level',i_level,i_method_name);
     ecx_debug.log(l_statement,'i_where_clause',i_where_clause,i_method_name);
   end if;

   ecx_utils.g_source_levels(i_level).sql_stmt :=
      ecx_utils.g_source_levels(i_level).sql_stmt ||'  '|| i_where_clause;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_where_clause', ecx_utils.g_source_levels(i_level).sql_stmt,
                  i_method_name);
   end if;

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
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_PROGRAM_ERROR', i_method_name,
	              'PROGRESS_LEVEL',
                  'ECX_ACTIONS.APPEND_CLAUSE');
          ecx_debug.log(l_unexpected, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name,
	               'ERROR_MESSAGE',SQLERRM);
      end if;
     ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.APPEND_CLAUSE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END append_clause;

procedure append_clause_for_view (
   i_stage                     IN     pls_integer,
   i_level                    IN     pls_integer
   ) IS

   i_method_name   varchar2(2000) := 'ecx_actions.get_var_attr';
   pre_var_value               Varchar2(2000);
   pre_var_on_stack            Boolean;
   pre_var_stack_pos           pls_integer;
   i_date                      date;
   i_number                    Number;
   i_variable_name             varchar2(100);
   l_data_type                 pls_integer;
   i_where_clause		varchar2(2000);

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (ecx_utils.g_stage_data.count <> 0)
   then
      FOR i in ecx_utils.g_stage_data.first..ecx_utils.g_stage_data.last
      loop
         if (ecx_utils.g_stage_data(i).stage = i_stage and ecx_utils.g_stage_data(i).level = i_level)
         then
            if  ecx_utils.g_stage_data(i).action_type = APPEND_WHERECLAUSE
            then
               i_where_clause := ecx_utils.g_stage_data(i).clause;
                if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'Where Clause ', i_where_clause,i_method_name);
	        end if;
	 	if i_where_clause is not null
	 	then
			append_clause(i_level,i_where_clause);
         	end if; -- if_condition
       	    end if; -- Append Clause
     	 end if; -- Level /Stage Check
      end loop;
   end if;
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
      if(l_statementEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	              'PROGRESS_LEVEL','ECX_ACTIONS.APPEND_CLAUSE_FOR_VIEW');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.APPEND_CLAUSE_FOR_VIEW');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END append_clause_for_view;

procedure bind_variables_for_view (
   i_stage                     IN     pls_integer,
   i_level                    IN     pls_integer
   ) IS

   i_method_name   varchar2(2000) := 'ecx_actions.bind_variables_for_view';
   pre_var_value               Varchar2(4000);
   pre_var_on_stack            Boolean;
   pre_var_stack_pos           pls_integer;
   i_date                      date;
   i_number                    Number;
   i_variable_name             ecx_tran_stage_data.variable_value%type;
   l_data_type                 pls_integer;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (ecx_utils.g_stage_data.count <> 0)
   then
      FOR i in ecx_utils.g_stage_data.first..ecx_utils.g_stage_data.last
      loop
         if (ecx_utils.g_stage_data(i).stage = i_stage and ecx_utils.g_stage_data(i).level = i_level)
         then
            if  ecx_utils.g_stage_data(i).action_type = APPEND_WHERECLAUSE
            then
               i_variable_name := ecx_utils.g_stage_data(i).variable_value;
               if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'Bind Variable Name ', i_variable_name,i_method_name);
	       end if;

	       if i_variable_name is not null
	       then
	          /**
	          get from Default. If null , get it from the variable
	          **/
	          pre_var_value := ecx_utils.g_stage_data(i).operand1_constant;
	          if pre_var_value is null
	          then
         		get_var_attr (ecx_utils.g_stage_data(i).operand1_level,
                       	ecx_utils.g_stage_data(i).operand1_name,
                       	ecx_utils.g_stage_data(i).operand1_direction,
                       	ecx_utils.g_stage_data(i).operand1_pos,
                       	pre_var_value, pre_var_on_stack,
                       	pre_var_stack_pos);
       		   end if;
		   if pre_var_value = 'NULL'
		   then
			pre_var_value :=null;
		   end if;
                   if(l_statementEnabled) then
                     ecx_debug.log(l_statement,'Prev Variable Val ', pre_var_value,i_method_name);
                     ecx_debug.log(l_statement,'Prev Variable Pos ', pre_var_stack_pos,i_method_name);
		   end if;

                   --if not ( ecx_conditions.check_type_condition('6',pre_var_value,1,null,1)) then
                   if pre_var_on_stack then
                      l_data_type := ecx_utils.g_stack(pre_var_stack_pos).data_type;
                      if(l_statementEnabled) then
                       ecx_debug.log(l_statement,'Data Type' , to_char(nvl(l_data_type,-1)),i_method_name);
		      end if;
                   else
                      l_data_type := ecx_utils.g_source(
                              ecx_utils.g_stage_data(i).operand1_pos).data_type;
                      if(l_statementEnabled) then
                       ecx_debug.log(l_statement, 'Data Type 2' , to_char(nvl(l_data_type,-1)),i_method_name);
		      end if;
                   end if;


                   if l_data_type = 2 then
                      i_number := to_number(pre_var_value);
                      dbms_sql.bind_variable (
                                  ecx_utils.g_source_levels(i_level).Cursor_Handle,
                                  i_variable_name, i_number);
                      if(l_statementEnabled) then
                       ecx_debug.log(l_statement, 'Binding Value ',i_number,i_method_name);
		      end if;

		   elsif l_data_type = 12 then
                      i_date := to_date(pre_var_value,'YYYYMMDD HH24MISS');
                      dbms_sql.bind_variable (
                                 ecx_utils.g_source_levels(i_level).Cursor_Handle,
                                 i_variable_name, i_date);
                      if(l_statementEnabled) then
                       ecx_debug.log(l_statement,'Binding Value ',i_date,i_method_name);
		      end if;
		   else
                      dbms_sql.bind_variable (
                               ecx_utils.g_source_levels(i_level).Cursor_Handle,
                               i_variable_name, pre_var_value);
                      if(l_statementEnabled) then
                       ecx_debug.log(l_statement,'Binding Value ',pre_var_value,i_method_name);
		      end if;
                   end if;
	    --end if; -- if condition for variable_name
                end if; -- if_condition
             end if; -- Append Clause
         end if; -- Level /Stage Check
      end loop;
   end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN invalid_number then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
    ecx_debug.setErrorInfo(1,30,'ECX_INVALID_NUMBER','pre_var_value',
                                 pre_var_value,'variable_name',i_variable_name);
     raise ecx_utils.program_exit;
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_ACTIONS.BIND_VARIABLES_FOR_VIEW');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	              'ERROR_MESSAGE',SQLERRM);
      end if;
       ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BIND_VARIABLES_FOR_VIEW');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END bind_variables_for_view;


procedure build_procedure_call (
   p_transtage_id     IN     pls_integer,
   p_procedure_name   IN     Varchar2,
   x_proc_cursor      OUT    NOCOPY pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.build_procedure_call';

   error_position     pls_integer;
   l_proc_call        Varchar2(32000);
   l_first_param      Boolean := True;
   parse_error        EXCEPTION;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
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

            l_proc_call := l_proc_call ||
				ecx_utils.g_procedure_mappings(i).parameter_name ||
                        	' => :'  || ecx_utils.g_procedure_mappings(i).parameter_name;
         end if;
      end loop;
   end if;

   l_proc_call := l_proc_call || '); END;';

   if(l_statementEnabled) then
	ecx_debug.log(l_statement,'proc_call', l_proc_call, i_method_name);
   end if;
   x_proc_cursor := dbms_sql.open_cursor;

   BEGIN
      dbms_sql.parse (x_proc_cursor, l_proc_call, dbms_sql.native);

   EXCEPTION
      when others then
         raise parse_error;
   END;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN PARSE_ERROR then
      error_position := dbms_sql.last_error_position;
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	  'PROGRESS_LEVEL','ECX_ACTIONS.BUILD_PROCEDURE_CALL');
      end if;
      ecx_error_handling_pvt.print_parse_error (error_position, l_proc_call);
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BUILD_PROCEDURE_CALL');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	               'PROGRESS_LEVEL','ECX_ACTIONS.BUILD_PROCEDURE_CALL');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BUILD_PROCEDURE_CALL');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END build_procedure_call;

procedure bind_proc_variables (
   p_transtage_id     IN     pls_integer,
   p_procedure_name   IN     Varchar2,
   p_proc_cursor      IN     pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.bind_proc_variables';
   l_stack_found      Boolean;
   l_var_value        Varchar2(32767);
   l_stack_pos        pls_integer;
   l_numrows          pls_integer;
   l_clob_value       Clob;
   l_temp_loc         Clob;
   i_clob_len         pls_integer;
   l_len              number;


BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if (ecx_utils.g_procedure_mappings.count <> 0)
   then
      for i in ecx_utils.g_procedure_mappings.first..ecx_utils.g_procedure_mappings.last
      loop
         if (ecx_utils.g_procedure_mappings(i).transtage_id = p_transtage_id) and
            (ecx_utils.g_procedure_mappings(i).procedure_name = p_procedure_name) then
	    /** Look for Constant Value first. If null get it from Variable **/
          l_var_value  := null;
          l_clob_value := null;
          l_temp_loc   := null;
	    l_var_value := ecx_utils.g_procedure_mappings(i).variable_constant;

	    if l_var_value = 'NULL'
	    then
		l_var_value :=null;
	    end if;

	    if l_var_value is null
--do not assign value to OUT parameters
		and ecx_utils.g_procedure_mappings(i).action_type <> 1070
	    then
	       if ( ecx_utils.g_procedure_mappings(i).variable_direction = 'G' )
	       then
                  l_stack_found := find_stack_variable(
                                  ecx_utils.g_procedure_mappings(i).variable_name,
                                  l_stack_pos);
            	  l_var_value := ecx_utils.g_stack(l_stack_pos).variable_value;

                  /* Based on the direction look in either source or target */
               elsif ecx_utils.g_procedure_mappings(i).variable_direction = 'S'
               then
                  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Bind variable is in source',i_method_name);
		  end if;
                  if (l_clob_value is null) then
                     dbms_lob.createtemporary(l_clob_value,true,dbms_lob.session);
                  end if;
                  l_clob_value := ecx_utils.g_source(ecx_utils.g_procedure_mappings(i).variable_pos).clob_value;
                  l_var_value := ecx_utils.g_source(ecx_utils.g_procedure_mappings(i).variable_pos).value;

                  if ecx_utils.g_procedure_mappings(i).data_type <> 112 then
                        l_len := dbms_lob.getlength(l_clob_value) ;
                        if (l_clob_value is not null and
                           ( l_len > ecx_utils.G_VARCHAR_LEN)) then
                                 get_varchar(l_clob_value ,
                                             l_var_value,
                                             l_var_value);
                                 l_clob_value :=  null;
                        end if;
                        l_len := length(l_var_value) ;
                        if (l_var_value is not null and
                            ( l_len > ecx_utils.G_VARCHAR_LEN)) then
                                 get_varchar(l_clob_value ,
                                             l_var_value,
                                             l_var_value);
                                 l_clob_value :=  null;
                        end if;


                  End If;
               else
                  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Bind variable is in target',i_method_name);
		  end if;
                  if (l_clob_value is null) then
                     dbms_lob.createtemporary(l_clob_value,true,dbms_lob.session);
                  end if;

                  l_clob_value := ecx_utils.g_target(ecx_utils.g_procedure_mappings(i).variable_pos).clob_value;
                  l_var_value := ecx_utils.g_target(ecx_utils.g_procedure_mappings(i).variable_pos).value;

                  if ecx_utils.g_procedure_mappings(i).data_type <> 112 then
                        l_len := dbms_lob.getlength(l_clob_value) ;
                        if (l_clob_value is not null and
                           (l_len > ecx_utils.G_VARCHAR_LEN)) then
                                 get_varchar(l_clob_value ,
                                             l_var_value,
                                             l_var_value);
                                 l_clob_value :=  null;
                        end if;
                        l_len := length(l_var_value) ;
                        if (l_var_value is not null and
                           ( l_len > ecx_utils.G_VARCHAR_LEN)) then
                                 get_varchar(l_clob_value ,
                                             l_var_value,
                                             l_var_value);
                                 l_clob_value :=  null;
                        end if;


                  End If;
               end if;
	    end if;
	    if(l_statementEnabled) then
		ecx_debug.log(l_statement,'l_var_value', l_var_value,i_method_name);
		if (l_clob_value is not null) then
                    ecx_debug.log(l_statement,'l_clob_value', l_clob_value,i_method_name);
		end if;
		ecx_debug.log(l_statement,'variable_name', ecx_utils.g_procedure_mappings(i).variable_name,
	                   i_method_name);
	    end if;

            if (ecx_utils.g_procedure_mappings(i).data_type = 1) then
               dbms_sql.bind_variable(p_proc_cursor,
                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                     l_var_value,ecx_utils.G_VARCHAR_LEN);

            elsif (ecx_utils.g_procedure_mappings(i).data_type = 2) then
               dbms_sql.bind_variable(p_proc_cursor,
                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                     to_number(l_var_value));
               if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'after binding',i_method_name);
	       end if;
            elsif (ecx_utils.g_procedure_mappings(i).data_type = 12) then
               dbms_sql.bind_variable(p_proc_cursor,
                     ':' || ecx_utils.g_procedure_mappings(i).parameter_name,
                     to_date(l_var_value, 'YYYYMMDD HH24MISS'));

            elsif (ecx_utils.g_procedure_mappings(i).data_type = 96) then
               dbms_sql.bind_variable(p_proc_cursor,
                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name, l_var_value, 600);

            /** Change required for Clob Support -- 2263729 ***/
            elsif (ecx_utils.g_procedure_mappings(i).data_type = 112) then
               if l_clob_value is not null Then
                  if(l_statementEnabled) then
                      ecx_debug.log(l_statement,'Binding clob is not null',i_method_name);
		  end if;
                  dbms_sql.bind_variable(p_proc_cursor,
                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name, l_clob_value);

                  elsif l_var_value is not null Then
                  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Binding varchar is not null',i_method_name);
                  end if;
                  /** bind the varchar2 variable to clob. ***/
                   get_clob(l_clob_value,l_var_value,l_temp_loc);
                   dbms_sql.bind_variable(p_proc_cursor,
                         ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,l_temp_loc);

               else
                  if(l_statementEnabled) then
                    ecx_debug.log(l_statement,'Binding clob is null',i_method_name);
		  end if;

                  /** just bind the null clob so that bind will not fail***/
                  dbms_sql.bind_variable(p_proc_cursor,
                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,l_clob_value);
               end if;
            else
	       if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'ECX', 'ECX_PROCEDURE_EXECUTION',i_method_name,
		              'PROCEDURE_NAME',
                          p_procedure_name);
                 ecx_debug.log(l_statement,'ECX', 'ECX_UNSUPPORTED_DATATYPE',i_method_name,
                          'Unsupported Data Type');
	       end if;
               ecx_debug.setErrorInfo(2,30,'ECX_UNSUPPORTED_DATATYPE');
               raise ecx_utils.program_exit;
            end if;
         end if;
         if dbms_lob.istemporary(l_temp_loc) = 1 Then
                     dbms_lob.freetemporary(l_temp_loc);
         end if;
         if dbms_lob.istemporary(l_clob_value) = 1 Then
                    dbms_lob.freetemporary(l_clob_value);
         end if;
      end loop;
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'before execute procedure',i_method_name);
   end if;
   l_numrows := dbms_sql.execute (p_proc_cursor);
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'after execute procedure',i_method_name);
   end if;
   if dbms_lob.istemporary(l_temp_loc) = 1 Then
      dbms_lob.freetemporary(l_temp_loc);
   end if;
   if dbms_lob.istemporary(l_clob_value) = 1 Then
      dbms_lob.freetemporary(l_clob_value);
   end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN ecx_utils.PROGRAM_EXIT then
      if dbms_lob.istemporary(l_temp_loc) = 1 Then
            dbms_lob.freetemporary(l_temp_loc);
      end if;
      if dbms_lob.istemporary(l_clob_value) = 1 Then
            dbms_lob.freetemporary(l_clob_value);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_ACTIONS.BIND_PROC_VARIABLES');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.BIND_PROC_VARIABLES');
      if dbms_lob.istemporary(l_temp_loc) = 1 Then
            dbms_lob.freetemporary(l_temp_loc);
      end if;
      if dbms_lob.istemporary(l_clob_value) = 1 Then
            dbms_lob.freetemporary(l_clob_value);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END bind_proc_variables;


procedure assign_out_variables (
   p_transtage_id     IN     pls_integer,
   p_procedure_name   IN     Varchar2,
   p_proc_cursor      IN     pls_integer) IS

   i_method_name   varchar2(2000) := 'ecx_actions.assign_out_variables';

   l_stack_var        Boolean;
   l_var_pos          pls_integer;
   l_stack_pos        pls_integer;
   l_varchar_value    Varchar2(32767);
   l_clob_value       clob;
   l_num              number;
   l_date             date;
   xml_frag_count     pls_integer;
   frag_found         Boolean;
BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (ecx_utils.g_procedure_mappings.count <> 0)
   then
      for i in ecx_utils.g_procedure_mappings.first..ecx_utils.g_procedure_mappings.last
      loop
         if (ecx_utils.g_procedure_mappings(i).transtage_id = p_transtage_id) and
            (ecx_utils.g_procedure_mappings(i).procedure_name = p_procedure_name) and
            (ecx_utils.g_procedure_mappings(i).action_type = 1070 or
	     ecx_utils.g_procedure_mappings(i).action_type = 1080) then
             xml_frag_count := ecx_utils.g_xml_frag.count;
	    if ( ecx_utils.g_procedure_mappings(i).variable_direction = 'G' )
	       then
            	  l_stack_var := find_stack_variable(
                           ecx_utils.g_procedure_mappings(i).variable_name,
                                l_stack_pos);
            else
               l_stack_var := false;
               l_var_pos   := ecx_utils.g_procedure_mappings(i).variable_pos;
            end if;
	    if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'fragment count',xml_frag_count,i_method_name);
           end if;


            if (ecx_utils.g_procedure_mappings(i).data_type = 1) then
               dbms_sql.variable_value (p_proc_cursor,
                                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                                     l_varchar_value);
               frag_found := FALSE;
               -- XML Fragment change
               if (instr(p_procedure_name,ECX_UTILS.G_XML_FRAG_PROC) > 0 and l_var_pos is
not null and ecx_utils.g_procedure_mappings(i).variable_direction = 'T') then
              if ecx_utils.g_xml_frag.count > 0 then
                for frag_count in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
                loop
                  if ecx_utils.g_xml_frag(frag_count).variable_pos = l_var_pos
then
                  ecx_utils.g_xml_frag(frag_count).value := l_varchar_value;
                  frag_found := TRUE;
                   if frag_found then
                     exit;
                   end if;
                  end if;
		end loop;
	      end if;

                if (not frag_found) then
                ecx_utils.g_xml_frag(xml_frag_count+1).variable_pos :=
l_var_pos;
                ecx_utils.g_xml_frag(xml_frag_count+1).value := l_varchar_value;
		  if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'value',ecx_utils.g_xml_frag(xml_frag_count+1).value,i_method_name);
                   end if;
                end if;

                if (ecx_utils.g_target(l_var_pos).attribute_type =1) then
                ecx_utils.g_target(l_var_pos).value := null;
                ecx_utils.g_target(l_var_pos).clob_value := null;
                end if;

               else
               assign_value (l_stack_var, l_stack_pos, l_var_pos,
                          ecx_utils.g_procedure_mappings(i).variable_direction,l_varchar_value);
               end if;

            elsif (ecx_utils.g_procedure_mappings(i).data_type = 2) then
               dbms_sql.variable_value (p_proc_cursor,
                                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                                     l_num);
               frag_found := FALSE;
               if (instr(p_procedure_name,ECX_UTILS.G_XML_FRAG_PROC) > 0 and l_var_pos is
not null and ecx_utils.g_procedure_mappings(i).variable_direction = 'T' ) then
               -- XML Fragment change

                 if ecx_utils.g_xml_frag.count > 0 then
                    for frag_count in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
                    loop
                        if ecx_utils.g_xml_frag(frag_count).variable_pos = l_var_pos then
                           ecx_utils.g_xml_frag(frag_count).value := to_char(l_num);
                           frag_found := TRUE;
                           if frag_found then
                               exit;
                           end if;
                        end if;
		     end loop;
	         end if;

                  if (not frag_found) then
                      ecx_utils.g_xml_frag(xml_frag_count+1).variable_pos := l_var_pos;
                      ecx_utils.g_xml_frag(xml_frag_count+1).value := to_char(l_num);
                  end if;

                   if (ecx_utils.g_target(l_var_pos).attribute_type =1) then
                       ecx_utils.g_target(l_var_pos).value := null;
                       ecx_utils.g_target(l_var_pos).clob_value := null;
                   end if;
              else
               assign_value (l_stack_var, l_stack_pos, l_var_pos,
                          ecx_utils.g_procedure_mappings(i).variable_direction,
                          to_char(l_num));
              end if;

            elsif (ecx_utils.g_procedure_mappings(i).data_type = 12) then
               dbms_sql.variable_value (p_proc_cursor,
                                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                                     l_date);
               frag_found := FALSE;
               if (instr(p_procedure_name,ECX_UTILS.G_XML_FRAG_PROC) > 0 and l_var_pos is
not null and ecx_utils.g_procedure_mappings(i).variable_direction = 'T'  ) then

		if ecx_utils.g_xml_frag.count > 0 then
                  for frag_count in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
                  loop
                      if ecx_utils.g_xml_frag(frag_count).variable_pos = l_var_pos then
                            ecx_utils.g_xml_frag(frag_count).value := to_char(l_date,'YYYYMMDD HH24MISS');
                            frag_found := TRUE;
                            if frag_found then
                             exit;
                            end if;
                      end if;
		  end loop;
	        end if;

                 if (not frag_found) then
                  ecx_utils.g_xml_frag(xml_frag_count+1).variable_pos := l_var_pos;
                  ecx_utils.g_xml_frag(xml_frag_count+1).value := to_char(l_date,'YYYYMMDD HH24MISS');
                 end if;

                 if (ecx_utils.g_target(l_var_pos).attribute_type =1) then
                   ecx_utils.g_target(l_var_pos).value := null;
                   ecx_utils.g_target(l_var_pos).clob_value := null;
                 end if;
              else
               assign_value (l_stack_var, l_stack_pos, l_var_pos,
                          ecx_utils.g_procedure_mappings(i).variable_direction,
                          to_char(l_date,'YYYYMMDD HH24MISS'));
              end if;


            elsif (ecx_utils.g_procedure_mappings(i).data_type = 96) then
               dbms_sql.variable_value (p_proc_cursor,
                                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                                     l_varchar_value);
               frag_found := FALSE;
               if (instr(p_procedure_name,ECX_UTILS.G_XML_FRAG_PROC) > 0 and l_var_pos is
not null and ecx_utils.g_procedure_mappings(i).variable_direction = 'T'  ) then
                if ecx_utils.g_xml_frag.count > 0 then
                for frag_count in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
                loop
                  if ecx_utils.g_xml_frag(frag_count).variable_pos = l_var_pos then
                  ecx_utils.g_xml_frag(frag_count).value := l_varchar_value;
                  frag_found := TRUE;
                   if frag_found then
                     exit;
                   end if;
                  end if;
		end loop;
	      end if;

                if (not frag_found) then
                ecx_utils.g_xml_frag(xml_frag_count+1).variable_pos :=
l_var_pos;
                 ecx_utils.g_xml_frag(xml_frag_count+1).value :=
l_varchar_value;
                end if;

                if (ecx_utils.g_target(l_var_pos).attribute_type =1) then
                ecx_utils.g_target(l_var_pos).value := null;
                ecx_utils.g_target(l_var_pos).clob_value := null;
                end if;
              else
               assign_value (l_stack_var, l_stack_pos, l_var_pos,
                          ecx_utils.g_procedure_mappings(i).variable_direction,
                          l_varchar_value );
              end if;
             /** Change required for Clob Support -- 2263729 ***/
             elsif (ecx_utils.g_procedure_mappings(i).data_type = 112) then
                  dbms_sql.variable_value (p_proc_cursor,
                                     ':' ||ecx_utils.g_procedure_mappings(i).parameter_name,
                                      l_clob_value);

                  assign_value (l_stack_var, l_stack_pos, l_var_pos,
                                   ecx_utils.g_procedure_mappings(i).variable_direction,
                                   l_clob_value );
            end if;
         end if;
      end loop;
   end if;
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
       ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
                    'PROGRESS_LEVEL','ECX_ACTIONS.ASSIGN_OUT_VARIABLES');
       ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.ASSIGN_OUT_VARIABLES');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END assign_out_variables;


/**
Executes a given stored procedure or a function with parameters of following datatype :
1. Date
2. Number
3. Varchar2
4. Char.
Other types are not supported at this point of time because PL/SQL language does not support
dynamic binding of other types of variables. Probably we should use Java and do it in next release.
**/

procedure execute_proc (
   i_transtage_id     IN     pls_integer,
   i_procedure_name   IN     Varchar2) IS

i_method_name   varchar2(2000) := 'ecx_actions.execute_proc';

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_transtage_id',i_transtage_id,i_method_name);
     ecx_debug.log(l_statement,'i_procedure_name',i_procedure_name,i_method_name);
   end if;

   bind_proc_variables (i_transtage_id, i_procedure_name,
                        ecx_utils.g_procedure_list(i_transtage_id).cursor_handle);

   assign_out_variables (i_transtage_id, i_procedure_name,
                         ecx_utils.g_procedure_list(i_transtage_id).cursor_handle);

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.EXECUTE_PROC');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.EXECUTE_PROC');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

END execute_proc;

procedure exit_program
IS
i_method_name   varchar2(2000) := 'ecx_actions.exit_program';
begin
      ecx_debug.setErrorInfo(1,20,'ECX_USER_INVOKED_EXIT');
      raise ecx_utils.program_exit;
exception
   WHEN ecx_utils.PROGRAM_EXIT then
      raise ecx_utils.program_exit;
   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.EXIT_PROGRAM');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.EXIT_PROGRAM');
      raise ecx_utils.PROGRAM_EXIT;
end exit_program;

/** This procedure is overloaded below **/
procedure set_error_exit_program(
    i_err_type    in  pls_integer,
    i_err_code    in  pls_integer,
    i_err_msg     in  varchar2
)
IS

i_method_name   varchar2(2000) := 'ecx_actions.set_error_exit_program';
i_len           pls_integer := 0;
i_prod_code_cnt pls_integer :=0;

/* Start of Bug 2186358 */
i_msg  varchar2(2000):= null;
/* End of Bug 2186358 */
begin
      if (l_procedureEnabled) then
        ecx_debug.push(i_method_name);
      end if;
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Error Type : ' , i_err_type,i_method_name);
        ecx_debug.log(l_statement,'Error Code: ', i_err_code,i_method_name);
        ecx_debug.log(l_statement,'Error Msg: ', i_err_msg,i_method_name);
      end if;

      i_msg := i_err_msg;

      if (i_msg is null) then
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Resetting error msg',i_method_name);
	 end if;
         i_msg := 'ECX_USER_INVOKED_EXIT';
      end if;

      if ((i_err_msg not like 'ECX%') and (i_err_msg not like 'WF%'))
      then
         i_len := instr(i_msg, '_') - 1;
	/* if i_len <= 20 then
            ecx_utils.g_cust_msg_code := substr(i_msg, 1, i_len);
         end if;*/
	 select count(*) into i_prod_code_cnt from fnd_application where APPLICATION_SHORT_NAME = substr(i_msg, 1, i_len);
	 if i_prod_code_cnt = 1 then
	ecx_utils.g_cust_msg_code := substr(i_msg, 1, i_len);
      end if;
    end if;
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Product Code' , ecx_utils.g_cust_msg_code,i_method_name);
      end if;

      ecx_utils.set_error(p_error_type => i_err_type,
                          p_error_code => i_err_code,
                          p_error_msg  => i_msg);

      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Raising program exit',i_method_name);
      end if;
      raise ecx_utils.program_exit;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
exception
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
   WHEN OTHERS THEN
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      /*if(l_statementEnabled) then
       ecx_debug.log(l_statement,'ECX','ECX_PROGRAM_ERROR',i_method_name,
                    'PROGRESS_LEVEL','ECX_ACTIONS.SET_ERR_EXIT_PROGRAM');
       ecx_debug.log(l_statement,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;*/
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.SET_ERR_EXIT_PROGRAM');
      raise ecx_utils.PROGRAM_EXIT;
end set_error_exit_program;

/** Overloaded for enabling MLS for user invoked error
    messages with parameters -2535659 **/
procedure set_error_exit_program(
    i_err_type    in  pls_integer,
    i_err_code    in  pls_integer,
    i_err_msg     in  varchar2,
    p_token1       in varchar2,
    p_value1       in varchar2,
    p_token2       in varchar2,
    p_value2       in varchar2,
    p_token3       in varchar2,
    p_value3       in varchar2,
    p_token4       in varchar2,
    p_value4       in varchar2,
    p_token5       in varchar2,
    p_value5       in varchar2,
    p_token6       in varchar2,
    p_value6       in varchar2,
    p_token7       in varchar2,
    p_value7       in varchar2,
    p_token8       in varchar2,
    p_value8       in varchar2,
    p_token9       in varchar2,
    p_value9       in varchar2,
    p_token10      in varchar2,
    p_value10      in varchar2
)
IS
i_method_name   varchar2(2000) := 'ecx_actions.set_error_exit_program';
i_len           pls_integer := 0;
i_prod_code_cnt pls_integer :=0;

/* Start of Bug 2186358 */
i_msg  varchar2(2000):= null;
/* End of Bug 2186358 */
begin
      if (l_procedureEnabled) then
        ecx_debug.push(i_method_name);
      end if;
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Error Type : ' , i_err_type,i_method_Name);
        ecx_debug.log(l_statement,'Error Code: ', i_err_code,i_method_Name);
        ecx_debug.log(l_statement,'Error Msg: ', i_err_msg,i_method_Name);
        ecx_debug.log(l_statement,'Param1' , p_token1,i_method_Name);
        ecx_debug.log(l_statement,'Value1' , p_value1,i_method_Name);
        ecx_debug.log(l_statement,'Param2' , p_token2,i_method_Name);
        ecx_debug.log(l_statement,'Value2' , p_value2,i_method_Name);
        ecx_debug.log(l_statement,'Param3' , p_token3,i_method_Name);
        ecx_debug.log(l_statement,'Value3' , p_value3,i_method_Name);
        ecx_debug.log(l_statement,'Param4' , p_token4,i_method_Name);
        ecx_debug.log(l_statement,'Value4' , p_value4,i_method_Name);
        ecx_debug.log(l_statement,'Param5' , p_token5,i_method_Name);
        ecx_debug.log(l_statement,'Value5' , p_value5,i_method_Name);
        ecx_debug.log(l_statement,'Param6' , p_token6,i_method_Name);
        ecx_debug.log(l_statement,'Value6' , p_value6,i_method_Name);
        ecx_debug.log(l_statement,'Param7' , p_token7,i_method_Name);
        ecx_debug.log(l_statement,'Value7' , p_value7,i_method_Name);
        ecx_debug.log(l_statement,'Param8' , p_token8,i_method_Name);
        ecx_debug.log(l_statement,'Value8' , p_value8,i_method_Name);
        ecx_debug.log(l_statement,'Param9' , p_token9,i_method_Name);
        ecx_debug.log(l_statement,'Value9' , p_value9,i_method_Name);
        ecx_debug.log(l_statement,'Param10' , p_token10,i_method_Name);
        ecx_debug.log(l_statement,'Value10' , p_value10,i_method_Name);
      end if;
      i_msg := i_err_msg;

      if (i_msg is null) then
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Resetting error msg',i_method_name);
	 end if;
         i_msg := 'ECX_USER_INVOKED_EXIT';
      end if;

      if ((i_err_msg not like 'ECX%') and (i_err_msg not like 'WF%'))
      then
         i_len := instr(i_msg, '_') - 1;
       /*  if i_len <= 20 then
            ecx_utils.g_cust_msg_code := substr(i_msg, 1, i_len);
         end if;*/
	  select count(*) into i_prod_code_cnt from fnd_application where APPLICATION_SHORT_NAME = substr(i_msg, 1, i_len);
	 if i_prod_code_cnt = 1 then
	ecx_utils.g_cust_msg_code := substr(i_msg, 1, i_len);
        end if;
      end if;
      if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Product Code' , ecx_utils.g_cust_msg_code,i_method_name);
      end if;

      ecx_utils.set_error(p_error_type => i_err_type,
                          p_error_code => i_err_code,
                          p_error_msg  => i_msg,
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

      if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Raising program exit',i_method_name);
      end if;
      raise ecx_utils.program_exit;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;

exception
   WHEN ecx_utils.PROGRAM_EXIT then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
   WHEN OTHERS THEN
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_ACTIONS.SET_ERR_EXIT_PROGRAM');
         ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.SET_ERR_EXIT_PROGRAM');
      raise ecx_utils.PROGRAM_EXIT;
end set_error_exit_program;



procedure send_err (
   i_variable_level		IN     pls_integer,
   i_variable_name             	IN     Varchar2,
   i_variable_direction         IN     Varchar2,
   i_variable_pos              	IN     pls_integer,
   i_variable_constant		IN	varchar2,
   i_previous_variable_level   	IN     pls_integer,
   i_previous_variable_name    	IN     Varchar2,
   i_previous_variable_direction    IN     Varchar2,
   i_previous_variable_pos     	IN     pls_integer,
   i_previous_variable_constant	IN	varchar2) IS

   var_value                   Varchar2(4000);
   var_on_stack                Boolean := FALSE;
   var_stack_pos               pls_integer;
   pre_var_value               Varchar2(4000);
   pre_var_on_stack            Boolean := FALSE;
   pre_var_stack_pos           pls_integer;
   o_ret_code                  pls_integer;
   o_ret_msg                   Varchar2(2000);

i_method_name   varchar2(2000) := 'ecx_actions.send_err';
BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;


   /** First get the COnstant and then look for the variable value **/
   var_value := i_variable_constant;
   if var_value is null
   then
      get_var_attr (i_variable_level, i_variable_name,
                    i_variable_direction,i_variable_pos,
       		    var_value, var_on_stack, var_stack_pos);
   end if;

   if var_value = 'NULL'
   then
      var_value :=null;
   end if;

   pre_var_value := i_previous_variable_constant;
   if pre_var_value is null
   then
      get_var_attr (i_previous_variable_level, i_previous_variable_name,
       		    i_previous_variable_direction,
       		    i_previous_variable_pos, pre_var_value, pre_var_on_stack,
       		    pre_var_stack_pos);

   end if;

   if pre_var_value = 'NULL'
   then
      pre_var_value :=null;
   end if;

   ecx_errorlog.send_error (to_number(var_value),
                            pre_var_value,
                            ecx_utils.g_snd_tp_id,
                            ecx_utils.g_document_id,
                            ecx_utils.g_transaction_type,
                            o_ret_code,
                            o_ret_msg);

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
               'PROGRESS_LEVEL','ECX_ACTIONS.SEND_ERR');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.SEND_ERR');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
END send_err;


procedure get_api_retcode (
   i_variable_level            	IN     pls_integer,
   i_variable_name             	IN     Varchar2,
   i_variable_direction             IN     Varchar2,
   i_variable_pos              	IN     pls_integer,
   i_default_value		IN	varchar2,
   i_previous_variable_level     IN     pls_integer,
   i_previous_variable_name     IN     varchar2,
   i_previous_variable_direction     IN     varchar2,
   i_previous_variable_pos     	IN     pls_integer,
   i_function_name			IN	varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.get_api_retcode';

   var_value                   Varchar2(2000);
   var_on_stack                Boolean := FALSE;
   var_stack_pos               pls_integer;
   pre_var_value               Varchar2(2000);
   pre_var_on_stack            Boolean := FALSE;
   pre_var_stack_pos           pls_integer;
   ret_code                    Varchar2(1);

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   get_var_attr (i_variable_level, i_variable_name,
             	 i_variable_direction,
       	         i_variable_pos, var_value, var_on_stack,
       	         var_stack_pos);

   if i_default_value is not null
   then

      if i_default_value = 'CODE_CONVERSION'
      then
         if i_previous_variable_direction = 'S'
	 then
   	    ret_code := ecx_utils.g_source(i_previous_variable_pos).xref_retcode;
	 else
   	    ret_code := ecx_utils.g_target(i_previous_variable_pos).xref_retcode;
	 end if;
	 if(l_statementEnabled) then
   		ecx_debug.log(l_statement,'return code', ret_code, i_method_name);
	 end if;
   	 assign_value (var_on_stack, var_stack_pos,
                	i_variable_pos,i_variable_direction, ret_code);

      elsif i_default_value = 'DOCUMENT_ID'
      then
         assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.g_document_id);

      elsif i_default_value = 'RET_CODE'
      then
         assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.i_ret_code);

      elsif i_default_value = 'RET_MESG'
      then
         assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.i_errbuf);
       elsif i_default_value = 'SENDER_TP_ID'
       then
          assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.g_snd_tp_id);
       elsif i_default_value = 'RECEIVER_TP_ID'
       then
   	  assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.g_rec_tp_id);

	elsif i_default_value = 'ORG_ID'
	then
   	   assign_value (var_on_stack, var_stack_pos,
                 	i_variable_pos,i_variable_direction, ecx_utils.g_org_id);
	end if;
   end if;

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
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	              'PROGRESS_LEVEL','ECX_ACTIONS.GET_API_RETCODE');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_API_RETCODE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
END get_api_retcode;


procedure split_number (
   p_number        IN      NUMBER,
   p_value         OUT     NOCOPY VARCHAR2,
   p_sign          OUT     NOCOPY VARCHAR2,
   p_numofdec      OUT     NOCOPY VARCHAR2) IS

   i_method_name   varchar2(2000) := 'ecx_actions.split_number';

   num1            NUMBER := 0;
   num2            NUMBER := 0;
   numchar         VARCHAR2(40);
   nls_dec_char    VARCHAR2(1);
   charvalue       VARCHAR2(100);
      /*http://st-doc.us.oracle.com/9.0/9202/appdev.920/a96624/03_types.htm#10680
	The maximum precision (total number of digits) of a NUMBER value is 38 decimal digits. */
/*max_dec_length is max (theoritical) num of digits in decimal part.
Actual num of digits in decimal part will be always less than or equal to 38.
If num > 0 then total number of digits will be 39 or less
If num < 0 then total number of digits will be 38 or less

few examples of expected behaviour of this procedure:
p_number = 1.0123456789 ==> p_value = 10123456789, p_sign = +, p_numofdec = 10
p_number = -00.012345678901234567890123456789012345678901234567899123456789 ==> p_value = 1234567890123456789012345678901234568, p_sign = -, p_numofdec = 38
p_number = +12345.000001234567890123456789012345678901234567890123456789 ==> p_value = 123450000012345678901234567890123456789, p_sign = +, p_numofdec = 34
p_number = +12345000001234567890123456789012345678901234567890123456789.12 ==> p_value = 12345000001234567890123456789012345678900000000000000000000, p_sign = +, p_numofdec = null
p_number = +1.000001234567890123456789012345678901234567890123456789 ==> p_value = 100000123456789012345678901234567890123, p_sign = +, p_numofdec = 38
p_number = -12345678900.00000001234567890123456789012345678901234567890123456789 ==> p_value = 123456789000000000123456789012345678901, p_sign = -, p_numofdec = 28
p_number = -.014400 ==> p_value = 144, p_sign = -, p_numofdec = 4
p_number =  -.54 ==> p_value = 54, p_sign = -, p_numofdec = 2
p_number =  +00.054040 ==> p_value = 5404, p_sign = +, p_numofdec = 5
*/
   max_dec_length      PLS_INTEGER := 38;

begin
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
    end if;
   /* Oracle guarantees the portability of numbers with precision ranging from 1 to 38.
      precision =>  the total number of digits */

   /* Bug #2319022 */
   if (p_number = 0 ) then
        p_value    := 0;
        p_sign     := '+';
        p_numofdec := 0;
   return;
   end if;

   /* Determine Sign */
   IF nvl(p_number, 0) < 0 THEN
      p_sign := '-';
   ELSE
      p_sign := '+';
   END IF;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'sign', p_sign,i_method_name);
   end if;

   /* Get Value */
   num1 := trunc(p_number,0);
   num2 := mod(p_number, num1);

  /* if num2 is not null then */
   if ( num2 <> 0 ) then
      num2 := round(num2, max_dec_length);
      numchar := substrb(to_char(abs(num2)),2);
   end if;

   if (num1 = 0) then
      p_value := abs(to_number(numchar));
   else
      p_value := ltrim(rtrim(to_char(abs(num1)) || numchar));
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'value',p_value,i_method_name);
   end if;

   -- Get Num of Decimal places
/*   select substr(value, 1, 1)
   into   nls_dec_char
   from   v$nls_parameters
   where  parameter = 'NLS_NUMERIC_CHARACTERS';

   if(num1 = 0) then
     charvalue := ltrim(rtrim(to_char(abs(p_number)), max_dec_length));
   else
     charvalue := ltrim(rtrim(to_char(abs(p_number))));
   end if;

   if (instrb(charvalue, nls_dec_char) > 0) then
      p_numofdec := lengthb(charvalue) - instrb(charvalue, nls_dec_char);
      if (p_numofdec > max_dec_length) then
        p_numofdec := max_dec_length;
      end if;
   else
      p_numofdec := 0;
   end if;
*/
   p_numofdec := lengthb(numchar);

if(l_statementEnabled) then
   ecx_debug.log(l_statement, 'numofdec', p_numofdec, i_method_name);
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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.SPLIT_NUMBER');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.SPLIT_NUMBER');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

end split_number;

/**
   Returns the server timezone's offset from GMT in OAG format
**/
function gmt_offset(
   i_year varchar2,
   i_month varchar2,
   i_day varchar2,
   i_hour varchar2,
   i_minute varchar2,
   i_second varchar2

   ) return varchar2
is

   i_method_name   varchar2(2000) := 'ecx_actions.gmt_offset';
   i_server_offset              number;
   i_server_offset_hours        number;
   i_server_offset_mins         number;
   i_timezone                   varchar2(500);
   i_string			varchar2(2000);
   i_timezone_sign		varchar2(80);
begin
     if (l_procedureEnabled) then
        ecx_debug.push(i_method_name);
     end if;

   if (ecx_actions.g_server_timezone is null) then
       --- Check for the Installation Type ( Standalone or Embedded );
      if (ecx_utils.g_install_mode is null) then
         ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
      end if;

      if ecx_utils.g_install_mode = 'EMBEDDED'
      then
         i_string := 'begin
         fnd_profile.get('||'''ECX_SERVER_TIMEZONE'''||',ecx_actions.g_server_timezone);
      end;';
         execute immediate i_string ;
      else
         ecx_actions.g_server_timezone:= wf_core.translate('ECX_SERVER_TIMEZONE');
      end if;
   end if;


   -- if profile option is not set assume gmt
   if (ecx_actions.g_server_timezone is null) then
      ecx_actions.g_server_timezone := 'GMT';
   end if;

   -- get the DB server offset from the Java API
   i_server_offset := getTimeZoneOffset(to_number(i_year), to_number(i_month),
                                        to_number(i_day), to_number(i_hour),
                                        to_number(i_minute), to_number(i_second),
                                        ecx_actions.g_server_timezone);
   if i_server_offset >= 0 then
	i_timezone_sign := '+';
   end if;

   -- calculate the timezone in the OAG format
   i_server_offset_hours := floor(i_server_offset);
   i_server_offset_mins := (i_server_offset * 60)  mod 60;
   i_timezone := rtrim(ltrim(to_char(i_server_offset_hours, '09'))) ||
                 rtrim(ltrim(to_char(i_server_offset_mins, '09')));

   if i_timezone_sign is NOT NULL then
   	i_timezone := i_timezone_sign || i_timezone;
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_server_offset', i_server_offset,i_method_name);
     ecx_debug.log(l_statement, 'i_server_offset_hours', i_server_offset_hours,i_method_name);
     ecx_debug.log(l_statement, 'i_server_offset_mins', i_server_offset_mins,i_method_name);
   end if;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;


   return(i_timezone);
exception
   WHEN OTHERS THEN
       if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.GMT_OFFSET');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GMT_OFFSET');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end gmt_offset;

procedure convert_to_oag_date(
   i_variable_level     IN      pls_integer,
   i_variable_name      IN      varchar2,
   i_variable_pos       IN      pls_integer,
   i_variable_direction IN      varchar2,
   i_opr1_level        	IN      pls_integer,
   i_opr1_name         	IN      varchar2,
   i_opr1_pos          	IN      pls_integer,
   i_opr1_direction     IN      varchar2,
   i_opr1_constant	in	varchar2
   ) IS

   i_method_name   varchar2(2000) := 'ecx_actions.convert_to_oag_date';
   TYPE oag_dt_tbl is table of varchar2(10) index by BINARY_INTEGER;

   variable_value       varchar2(2000);
   var			date;
   stack_var       	boolean := FALSE;
   stack_pos       	pls_integer;
   var_pos         	pls_integer;
   oag_date_tbl		oag_dt_tbl;
   opr1_stack  		boolean := FALSE;
   opr1_stack_pos  	pls_integer;
   opr1_value		varchar2(2000);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
   end if;

   opr1_value := i_opr1_constant;
   if opr1_value is null
   then
      get_var_attr(i_opr1_level, i_opr1_name, i_opr1_direction,
         	  i_opr1_pos, opr1_value, opr1_stack, opr1_stack_pos);
   end if;
   if opr1_value = 'NULL'
   then
      opr1_value :=null;
   end if;

   /** Resultant variable **/
   get_var_attr(i_variable_level, i_variable_name, i_variable_direction,
                i_variable_pos, variable_value, stack_var, stack_pos);

   var := to_date(opr1_value, 'YYYYMMDD HH24MISS');

   oag_date_tbl(1) := to_char(var,'YYYY');
   oag_date_tbl(2) := to_char(var,'MM');
   oag_date_tbl(3) := to_char(var,'DD');
   oag_date_tbl(4) := to_char(var,'HH24');
   oag_date_tbl(5) := to_char(var,'MI');
   oag_date_tbl(6) := to_char(var,'SS');
   if(opr1_value is not null) then
    oag_date_tbl(7) := '0000';
    oag_date_tbl(8) := gmt_offset(oag_date_tbl(1), oag_date_tbl(2), oag_date_tbl(3),
                                 oag_date_tbl(4), oag_date_tbl(5), oag_date_tbl(6));
   end if;

   var_pos := i_variable_pos+1;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'name',ecx_utils.g_target(var_pos).attribute_name,i_method_name);
   end if;
   if ecx_utils.g_target(var_pos).attribute_name = 'qualifier' then
    var_pos := var_pos + 1;
   end if;

   if ecx_utils.g_target(var_pos).attribute_name = 'type' then
     var_pos := var_pos + 1;
   end if;
   if ecx_utils.g_target(var_pos).attribute_name = 'index' then
    var_pos := var_pos +1;
   end if;

   for i in 1..oag_date_tbl.COUNT loop
      assign_value(stack_var, stack_pos, var_pos,i_variable_direction, oag_date_tbl(i));
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'name',ecx_utils.g_target(var_pos).attribute_name,i_method_name);
        ecx_debug.log(l_statement,'value',ecx_utils.g_target(var_pos).value,i_method_name);
      end if;
      var_pos := var_pos + 1;
   end loop;

   /** make the value of the DATETIME to null **/
   ecx_utils.g_target(i_variable_pos).value:=null;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_TO_OAG_DATE');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_TO_OAG_DATE');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_to_oag_date;


procedure convert_to_oag_operamt(
   i_variable_level           	IN    pls_integer,
   i_variable_name            	IN    varchar2,
   i_variable_pos             	IN    pls_integer,
   i_variable_direction       	IN    varchar2,
   i_opr1_level  		IN    pls_integer,
   i_opr1_name       		IN    Varchar2,
   i_opr1_pos        		IN    pls_integer,
   i_opr1_direction       	IN    Varchar2,
   i_opr1_constant        	IN    varchar2,
   i_opr2_level      		IN    pls_integer,
   i_opr2_name       		IN    Varchar2,
   i_opr2_pos        		IN    pls_integer,
   i_opr2_direction       	IN    Varchar2,
   i_opr2_constant        	IN    varchar2,
   i_opr3_level      		IN    pls_integer,
   i_opr3_name       		IN    Varchar2,
   i_opr3_pos        		IN    pls_integer,
   i_opr3_direction       	IN    Varchar2,
   i_opr3_constant        	IN    varchar2
   ) IS

   i_method_name   varchar2(2000) := 'ecx_actions.convert_to_oag_operamt';
   TYPE oag_oamt_tbl is table of VARCHAR2(2000) index by BINARY_INTEGER;
   /** For Resultant **/

   var_value                  	varchar2(2000);
   stack_var                  	boolean := FALSE;
   stack_pos                  	pls_integer;

   /** For Opr1 **/
   opr1_stack           	Boolean := FALSE;
   opr1_stack_pos          	pls_integer;
   i_amount                     NUMBER;
   i_opr1_value                 varchar2(2000);

   /** For Opr2 **/
   opr2_stack          		Boolean := FALSE;
   opr2_stack_pos         	pls_integer;
   i_curr_code                	Varchar2(2000);

   /** For Opr3 **/
   opr3_stack           	Boolean := FALSE;
   opr3_stack_pos          	pls_integer;
   i_uom_code                 	Varchar2(2000) := 'EACH';
   var_pos                    	pls_integer;
   i_value                    	varchar2(2000);
   i_sign                     	varchar2(1);
   i_numofdec                 	varchar2(100);
   numofdec                   	number;
   p_numofdec                 	number := 0;
   v_numofdec                 	number :=0;
   i_uom_quant                	number :=1;
   i_uom_value                	varchar2(2000) := '1';
   i_uomnumofdec              	varchar2(100) := '0';
   i_uomsign                  	varchar2(1) :='+';
   oag_operamt_tbl            	oag_oamt_tbl;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_level',i_opr3_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_name',i_opr3_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_pos',i_opr3_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_direction',i_opr3_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_constant',i_opr3_constant,i_method_name);
   end if;

   get_var_attr(i_variable_level, i_variable_name,
                i_variable_direction,i_variable_pos,
                var_value, stack_var, stack_pos);


   i_opr1_value := i_opr1_constant;
   if i_opr1_value is null
   then
      get_var_attr(i_opr1_level, i_opr1_name,
                   i_opr1_direction,i_opr1_pos,
       		   i_opr1_value, opr1_stack, opr1_stack_pos);
   end if;

   if i_opr1_value = 'NULL'
   then
      i_opr1_value :=null;
   end if;

   i_amount := to_number(i_opr1_value);

   split_number(i_amount, i_value, i_sign, i_numofdec);

   /** Currency Code **/
   i_curr_code := i_opr2_constant;
   if i_curr_code is null
   then
      if i_opr2_level is not null
      then
         get_var_attr (i_opr2_level, i_opr2_name,
         	       i_opr2_direction,i_opr2_pos,
                       i_curr_code, opr2_stack,
                       opr2_stack_pos);
       end if;
   end if;

   if i_curr_code = 'NULL'
   then
      i_curr_code :=null;
   end if;

   /** UOM Code **/
   i_uom_code := i_opr3_constant;
   if i_uom_code is null
   then
      if i_opr3_level is not null
      then
         get_var_attr (i_opr3_level, i_opr3_name,
                       i_opr3_direction,
                       i_opr3_pos, i_uom_code, opr3_stack,
                       opr3_stack_pos);
      end if;
   end if;

   if i_uom_code = 'NULL'
   then
      i_uom_code :=null;
   end if;

   if (i_uom_quant <> 1) then
      split_number(i_uom_quant, i_uom_value,i_uomsign, i_uomnumofdec);
   end if;

   oag_operamt_tbl(1) := i_value;
   if (i_value is not null) then
      oag_operamt_tbl(2) := i_numofdec;
      oag_operamt_tbl(3) := i_sign;
      oag_operamt_tbl(4) := i_curr_code; --currency code
      oag_operamt_tbl(5) := i_uom_value;
      oag_operamt_tbl(6) := i_uomnumofdec;
      oag_operamt_tbl(7) := i_uom_code;
  end if;

   -- UOM code
   var_pos := i_variable_pos +3;

   for i in 1..oag_operamt_tbl.COUNT loop
      assign_value(stack_var, stack_pos, var_pos, i_variable_direction,oag_operamt_tbl(i));
      var_pos := var_pos +1;
   end loop;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_TO_OAG_OPERAMT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_TO_OAG_OPERAMT');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_to_oag_operamt;

procedure convert_to_oag_amt(
   i_variable_level           IN    pls_integer,
   i_variable_name            IN    varchar2,
   i_variable_pos             IN    pls_integer,
   i_variable_direction            IN    varchar2,
   i_opr1_level  		IN    pls_integer,
   i_opr1_name       		IN    Varchar2,
   i_opr1_pos        		IN    pls_integer,
   i_opr1_direction       	IN    Varchar2,
   i_opr1_constant        	IN    varchar2,
   i_opr2_level      		IN    pls_integer,
   i_opr2_name       		IN    Varchar2,
   i_opr2_pos        		IN    pls_integer,
   i_opr2_direction       	IN    Varchar2,
   i_opr2_constant        	IN    varchar2,
   i_opr3_level      		IN    pls_integer,
   i_opr3_name       		IN    Varchar2,
   i_opr3_pos        		IN    pls_integer,
   i_opr3_direction       	IN    Varchar2,
   i_opr3_constant        	IN    varchar2
   )
   is

   i_method_name   varchar2(2000) := 'ecx_actions.convert_to_oag_amt';
   TYPE oag_oamt_tbl is table of VARCHAR2(2000) index by BINARY_INTEGER;

   var_value                  	varchar2(2000);
   stack_var                  	boolean := FALSE;
   stack_pos                  	pls_integer;

   /** For Opr1 **/
   opr1_stack           	Boolean := FALSE;
   opr1_stack_pos          	pls_integer;
   i_opr1_value                 varchar2(2000);
   i_amount                   	NUMBER;

   /** For Opr2 **/
   opr2_stack          		Boolean := FALSE;
   opr2_stack_pos         	pls_integer;
   i_opr2_value                	Varchar2(2000);

   /** For Opr3 **/
   opr3_stack           	Boolean := FALSE;
   opr3_stack_pos          	pls_integer;
   i_opr3_value                 Varchar2(2000);
   i_crdr                     	varchar2(1);
   var_pos                    	pls_integer := 0;
   i_value                    	varchar2(2000);
   i_sign                     	varchar2(1);
   i_numofdec                 	varchar2(100);
   numofdec                   	number;
   p_numofdec                 	number := 0;
   v_numofdec                 	number :=0;
   i_uom_quant                	number :=1;
   i_uom_value                	varchar2(2000) := '1';
   i_uomnumofdec              	varchar2(100) := '0';
   i_uomsign                  	varchar2(1) :='+';
   oag_operamt_tbl            	oag_oamt_tbl;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_level',i_opr3_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_name',i_opr3_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_pos',i_opr3_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_direction',i_opr3_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_constant',i_opr3_constant,i_method_name);
  end if;

   get_var_attr(i_variable_level, i_variable_name,
                i_variable_direction,i_variable_pos,
                var_value, stack_var, stack_pos);

   i_opr1_value := i_opr1_constant;
   if i_opr1_value is null
   then
      get_var_attr(i_opr1_level, i_opr1_name,
                   i_opr1_direction,i_opr1_pos,
                   i_opr1_value, opr1_stack,opr1_stack_pos);
   end if;

   if i_opr1_value = 'NULL'
   then
      i_opr1_value :=null;
   end if;
   i_amount := to_number(i_opr1_value);

   split_number(i_amount, i_value, i_sign, i_numofdec);

   i_opr2_value := i_opr2_constant;
   if i_opr2_value is null
   then
      if i_opr2_level is not null
      then
         get_var_attr(i_opr2_level, i_opr2_name,
                      i_opr2_direction,i_opr2_pos,
                      i_opr2_value, opr2_stack, opr2_stack_pos);
      end if;
   end if;
   if i_opr2_value = 'NULL'
   then
      i_opr2_value :=null;
   end if;

   i_opr3_value := i_opr3_constant;
   if i_opr3_value is null
   then
      if i_opr3_level is not null
      then
         get_var_attr(i_opr3_level, i_opr3_name,
             	      i_opr3_direction,i_opr3_pos,
         	      i_opr3_value, opr3_stack, opr3_stack_pos);
      end if;
   end if;
   if i_opr3_value = 'NULL'
   then
      i_opr3_value :=null;
   end if;

   if (i_uom_quant <> 1) then
      split_number(i_uom_quant, i_uom_value,i_uomsign, i_uomnumofdec);
   end if;

   i_crdr := substrb(i_opr3_value,1,1);

   if (( i_crdr is null ) OR (i_crdr = ' '))
   then
      if ( i_sign  = '+' )
      then
         i_crdr := 'D';
      else
         i_crdr := 'C';
      end if;
   end if;

   oag_operamt_tbl(1) := i_value;
   if (i_value is not null) then
      oag_operamt_tbl(2) := i_numofdec;
      oag_operamt_tbl(3) := i_sign;
      oag_operamt_tbl(4) := i_opr2_value; --currency code
      oag_operamt_tbl(5) := i_crdr;
   end if;

   var_pos := i_variable_pos+1;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'name',ecx_utils.g_target(var_pos).attribute_name,
                  i_method_name);
   end if;
   if ecx_utils.g_target(var_pos).attribute_name = 'qualifier' then
    var_pos := var_pos + 1;
   end if;

   if ecx_utils.g_target(var_pos).attribute_name = 'type' then
     var_pos := var_pos + 1;
   end if;
   if ecx_utils.g_target(var_pos).attribute_name = 'index' then
    var_pos := var_pos +1;
   end if;

   for i in 1..oag_operamt_tbl.COUNT loop
      assign_value(stack_var, stack_pos, var_pos,i_variable_direction, oag_operamt_tbl(i));
      var_pos := var_pos +1;
   end loop;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_TO_OAG_AMT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_TO_OAG_AMT');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_to_oag_amt;


procedure convert_to_oag_quantity(
   i_variable_level           IN    pls_integer,
   i_variable_name            IN    varchar2,
   i_variable_pos             IN    pls_integer,
   i_variable_direction            IN    varchar2,
   i_opr1_level  		IN    pls_integer,
   i_opr1_name       		IN    Varchar2,
   i_opr1_pos        		IN    pls_integer,
   i_opr1_direction       	IN    Varchar2,
   i_opr1_constant        	IN    varchar2,
   i_opr2_level      		IN    pls_integer,
   i_opr2_name       		IN    Varchar2,
   i_opr2_pos        		IN    pls_integer,
   i_opr2_direction       	IN    Varchar2,
   i_opr2_constant        	IN    varchar2
   ) is
   i_method_name   varchar2(2000) := 'ecx_actions.convert_to_oag_quantity';
   var_value                  	varchar2(2000);
   stack_var                  	boolean := FALSE;
   stack_pos			pls_integer;

   opr1_stack           	Boolean := FALSE;
   opr1_stack_pos          	pls_integer;
   i_opr1_value                 varchar2(2000);
   i_amount                   	NUMBER;

   /** For Opr2 **/
   opr2_stack          		Boolean := FALSE;
   opr2_stack_pos         	pls_integer;
   i_opr2_value                	Varchar2(2000);
   var_pos                    	pls_integer;
   i_uom_quant     		number;
   i_uom_value     		varchar2(2000);
   i_uomnumofdec   		varchar2(100);
   i_uomsign       		varchar2(1);

   TYPE oag_qt_tbl is TABLE OF varchar2(2000) index by BINARY_INTEGER;
   oag_quant_tbl oag_qt_tbl;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
  end if;

   get_var_attr (i_variable_level, i_variable_name,
                 i_variable_direction,i_variable_pos,var_value, stack_var, stack_pos);

   i_opr1_value := i_opr1_constant;
   if i_opr1_value is null
   then
      get_var_attr(i_opr1_level, i_opr1_name,
                   i_opr1_direction,i_opr1_pos,
                   i_opr1_value, opr1_stack, opr1_stack_pos);
   end if;
   if i_opr1_value = 'NULL'
   then
      i_opr1_value :=null;
   end if;

   i_uom_quant := to_number(i_opr1_value);

   if i_uom_quant is NOT null then
      split_number(i_uom_quant, i_uom_value,i_uomsign, i_uomnumofdec);
   end if;

   i_opr2_value := i_opr2_constant;
   if i_opr2_value is null
   then
      if i_opr2_level is not null
      then
         get_var_attr(i_opr2_level, i_opr2_name,
                      i_opr2_direction,i_opr2_pos,
                      i_opr2_value, opr2_stack, opr2_stack_pos);
      end if;
   end if;
   if i_opr2_value = 'NULL'
   then
      i_opr2_value :=null;
   end if;

   var_pos := i_variable_pos +2;
   oag_quant_tbl(1) := i_uom_value;

   if (i_uom_value is not null) then
    oag_quant_tbl(2) := i_uomnumofdec;
    oag_quant_tbl(3) := i_uomsign;
    oag_quant_tbl(4) := i_opr2_value;
   end if;

   for i in 1..oag_quant_tbl.COUNT loop
      assign_value(stack_var, stack_pos, var_pos,i_variable_direction,
                    oag_quant_tbl(i));
      var_pos := var_pos +1;
   end loop;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_TO_OAG_QUANTITY');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_TO_OAG_QUANTITY');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_to_oag_quantity;


procedure combine_number (
   p_number        out     NOCOPY number,
   p_value         in      varchar2,
   p_sign          in      varchar2,
   p_numofdec      in      varchar2) IS

i_method_name   varchar2(2000) := 'ecx_actions.combine_number';

begin

   if (to_number(ltrim(rtrim(p_numofdec))) > 0) then
      p_number := to_number(ltrim(rtrim(p_value)))/power(10,to_number(ltrim(rtrim(p_numofdec))));
   else
      p_number := to_number(ltrim(rtrim(p_value)));
   end if;

   if (ltrim(rtrim(p_sign)) = '-') then
      p_number := -1 * p_number;
   end if;

EXCEPTION
   WHEN OTHERS THEN
       if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.COMBINE_NUMBER');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.COMBINE_NUMBER');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end combine_number;


/**
   Returns the date in the server timezone
**/
function get_converted_date(
   i_year       IN      varchar2,
   i_month      IN      varchar2,
   i_day        IN      varchar2,
   i_hour       IN      varchar2,
   i_minute     IN      varchar2,
   i_second     IN      varchar2,
   i_timezone   IN      varchar2
   ) return date
is

   i_method_name   varchar2(2000) := 'ecx_actions.get_converted_date';
   v_datetime           varchar2(500);
   x_date               Date    	:= null;
   i_server_offset      number;
   i_offset_diff        number;
   i_timezone_hours     number;
   incomplete_date      exception;

   i_string		varchar2(2000);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   -- Combining the values obtained to a datetime format specified in the next line.
   if ( (i_year is not null) and (i_month is not null) and (i_day is not null) and
        (i_hour is not null) and (i_minute is not null) and (i_second is not null) ) then
      v_datetime := i_year || i_month || i_day || ' '||i_hour || i_minute || i_second;

   elsif ( (i_year is null) or (i_month is null) or (i_day is null) or (i_hour is null) or
         (i_minute is null) or (i_second is null) ) then
      v_datetime := i_year || i_month || i_day || ' '||i_hour || i_minute || i_second;

      if nvl(v_datetime,' ') = ' ' then
         v_datetime := null;
      else
         raise incomplete_date;
      end if;
   end if;

   if (v_datetime is not null) then
      x_date := to_date(v_datetime,'YYYYMMDD HH24MISS');

      if (ecx_actions.g_server_timezone is null) then
         --- Check for the Installation Type ( Standalone or Embedded );
         if (ecx_utils.g_install_mode is null) then
            ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
         end if;

         if ecx_utils.g_install_mode = 'EMBEDDED'
         then
            i_string := 'begin
            fnd_profile.get('||'''ECX_SERVER_TIMEZONE'''||',ecx_actions.g_server_timezone);
         end;';
            execute immediate i_string ;
         else
            ecx_actions.g_server_timezone:= wf_core.translate('ECX_SERVER_TIMEZONE');
         end if;
      end if;

      -- if profile option is not set assume gmt
      if (ecx_actions.g_server_timezone is null) then
         ecx_actions.g_server_timezone := 'GMT';
      end if;

      -- get the DB server offset from the Java API
      i_server_offset := getTimeZoneOffset(to_number(i_year), to_number(i_month), to_number(i_day),
                                           to_number(i_hour), to_number(i_minute), to_number(i_second),
                                           ecx_actions.g_server_timezone);

      -- get the time in hours from the input xml
      i_timezone_hours := to_number(substr(i_timezone, 1, length(i_timezone) - 2)) +
                          (to_number(substr(i_timezone, length(i_timezone) - 1)) / 60);

      -- get the offset difference
      i_offset_diff := i_server_offset - i_timezone_hours;

      if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'g_server_timezone', ecx_actions.g_server_timezone,i_method_name);
       ecx_debug.log(l_statement, 'i_server_offset', i_server_offset,i_method_name);
       ecx_debug.log(l_statement, 'i_timezone_hours', i_timezone_hours,i_method_name);
       ecx_debug.log(l_statement, 'i_offset_diff', i_offset_diff,i_method_name);
      end if;

      x_date := x_date + (i_offset_diff / 24);
   end if;

    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;

   return (x_date);
exception
   WHEN incomplete_date THEN
      ecx_debug.setErrorInfo(1,20,'ECX_INCOMPLETE_OAG_DATE',
                            'p_datetime',v_datetime);
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	            'PROGRESS_LEVEL', 'ECX_ACTIONS.GET_CONVERTED_DATE');
        ecx_debug.log(l_unexpected,'ECX','ECX_INCOMPLETE_OAG_DATE',i_method_name,'p_datetime',
                                                    v_datetime);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN ecx_utils.PROGRAM_EXIT THEN
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.GET_CONVERTED_DATE');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_CONVERTED_DATE');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end get_converted_date;


procedure convert_from_oag_date(
   i_variable_level        IN      pls_integer,
   i_variable_name         IN      varchar2,
   i_variable_pos          IN      pls_integer,
   i_variable_direction    IN      varchar2,
   i_opr1_level  		IN    pls_integer,
   i_opr1_name       		IN    Varchar2,
   i_opr1_pos        		IN    pls_integer,
   i_opr1_direction       	IN    Varchar2,
   i_opr1_constant        	IN    varchar2
   ) is

   i_method_name   varchar2(2000) := 'ecx_actions.convert_from_oag_date';

   i_year      varchar2(4);
   i_month     varchar2(2);
   i_day       varchar2(2);
   i_hour      varchar2(2);
   i_minute    varchar2(2);
   i_second    varchar2(2);
   i_subsecond varchar2(4);
   i_timezone  varchar2(5);
   var_pos     pls_integer;
   stack_pos   pls_integer := null;
   stack_var   Boolean := FALSE;

   i_variable_value   		varchar2(2000);

   /** For Opr1 **/
   opr1_stack           	Boolean := FALSE;
   opr1_stack_pos          	pls_integer;
   i_opr1_value                 varchar2(2000);
   v_datetime			varchar2(25);
   x_date			date;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
   end if;
   -- The variable_name, level and variable_pos passed in should be that of "DATETIME"
   -- The interface column names should be named YEAR, MONTH, DAY etc.
   -- Calculate position

   var_pos := i_opr1_pos+1;

  if i_opr1_direction = 'S'
  then
     while ecx_utils.g_source(var_pos).attribute_name <> 'YEAR'
     loop
        if(l_statementEnabled) then
         ecx_debug.log(l_statement,'name',ecx_utils.g_source(var_pos).attribute_name,i_method_name);
	end if;
    	var_pos := var_pos + 1;
     end loop;
  else
     while ecx_utils.g_target(var_pos).attribute_name <> 'YEAR'
     loop
        if(l_statementEnabled) then
         ecx_debug.log(l_statement,'name',ecx_utils.g_target(var_pos).attribute_name,i_method_name);
	end if;
    	var_pos := var_pos + 1;
     end loop;
  end if;


   -- Using positional dependence from this point to get the values.

   get_var_attr(i_opr1_level, 'YEAR',i_opr1_direction,var_pos,i_year, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'MONTH',i_opr1_direction,var_pos+1,i_month, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'DAY',i_opr1_direction,var_pos+2,i_day, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'HOUR',i_opr1_direction,var_pos+3,i_hour, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'MINUTE',i_opr1_direction,var_pos+4,i_minute, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'SECOND',i_opr1_direction,var_pos+5,i_second, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'SUBSECOND',i_opr1_direction,var_pos+6,i_subsecond, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'TIMEZONE',i_opr1_direction,var_pos+7,i_timezone, opr1_stack, opr1_stack_pos);


   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_year',i_year,i_method_name);
     ecx_debug.log(l_statement,'i_month',i_month,i_method_name);
     ecx_debug.log(l_statement,'i_day',i_day,i_method_name);
     ecx_debug.log(l_statement,'i_hour',i_hour,i_method_name);
     ecx_debug.log(l_statement,'i_minute',i_minute,i_method_name);
     ecx_debug.log(l_statement,'i_second',i_second,i_method_name);
     ecx_debug.log(l_statement,'i_timezone',i_timezone,i_method_name);
  end if;
   -- convert the date to the database timezone
   x_date := get_converted_date(i_year, i_month, i_day, i_hour,
                                i_minute, i_second, i_timezone);

   if (x_date is not null) then
      v_datetime := to_char(x_date, 'YYYYMMDD HH24MISS');
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'v_datetime', v_datetime,i_method_name);
   end if;

   -- Assigning the date value to the DATETIME field.
   get_var_attr(i_variable_level, i_variable_name,i_variable_direction,
		i_variable_pos,i_variable_value, stack_var, stack_pos);

   assign_value(stack_var, stack_pos, i_variable_pos,i_variable_direction, ltrim(rtrim(v_datetime)));

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN ecx_utils.PROGRAM_EXIT THEN
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_FROM_OAG_DATE');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
       ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_FROM_OAG_DATE');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_from_oag_date;


procedure convert_from_oag_operamt(
	i_variable_level		IN	pls_integer,
	i_variable_name			IN	varchar2,
	i_variable_pos			IN	pls_integer,
	i_variable_direction			IN	varchar2,
   	i_opr1_level  		IN    pls_integer,
   	i_opr1_name       		IN    Varchar2,
   	i_opr1_pos        		IN    pls_integer,
   	i_opr1_direction       	IN    Varchar2,
   	i_opr1_constant        	IN    varchar2,
   	i_opr2_level      		IN    pls_integer,
   	i_opr2_name       		IN    Varchar2,
   	i_opr2_pos        		IN    pls_integer,
   	i_opr2_direction       	IN    Varchar2,
   	i_opr2_constant        	IN    varchar2,
   	i_opr3_level      		IN    pls_integer,
   	i_opr3_name       		IN    Varchar2,
   	i_opr3_pos        		IN    pls_integer,
   	i_opr3_direction       	IN    Varchar2,
   	i_opr3_constant        	IN    varchar2
	) IS

i_method_name   varchar2(2000) := 'ecx_actions.convert_from_oag_operamt';

i_number	number;
i_value		varchar2(250);
i_numofdec 	varchar2(100);
i_sign		varchar2(1);
i_currency	varchar2(5);
i_uomvalue	varchar2(30);
i_uomnumdec	varchar2(100);
i_uom		varchar2(30);

stack_var       boolean := FALSE;
stack_pos       pls_integer := null;

   i_variable_value 		varchar2(2000);

   /** For Opr1 **/
   opr1_stack           	Boolean := FALSE;
   opr1_stack_pos          	pls_integer;
   i_opr1_value                 varchar2(2000);

   /** For Opr2 **/
   opr2_stack          		Boolean := FALSE;
   opr2_stack_pos         	pls_integer;
   i_opr2_value                	Varchar2(2000);

   /** For Opr3 **/
   opr3_stack           	Boolean := FALSE;
   opr3_stack_pos          	pls_integer;
   i_opr3_value                 Varchar2(2000);

begin

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_level',i_opr3_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_name',i_opr3_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_pos',i_opr3_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_direction',i_opr3_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_constant',i_opr3_constant,i_method_name);
  end if;

   -- Variable_name, level, pos is OPERAMT
   -- Previous variable, name, pos is CURRENCY
   -- Next Variable, name pos is UOM

   -- Adding 3 to i_variable_pos to skip the attributes of OPERAMT

   get_var_attr(i_opr1_level, 'VALUE',i_opr1_direction,i_opr1_pos +3,i_value, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'NUMOFDEC',i_opr1_direction,i_opr1_pos +4,i_numofdec, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'SIGN',i_opr1_direction,i_opr1_pos +5,i_sign, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'CURRENCY',i_opr1_direction,i_opr1_pos +6,i_currency, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'UOMVALUE',i_opr1_direction,i_opr1_pos +7,i_uomvalue, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'UOMNUMDEC',i_opr1_direction,i_opr1_pos +8,i_uomnumdec, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'UOM',i_opr1_direction,i_opr1_pos +9,i_uom, opr1_stack, opr1_stack_pos);

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_value',i_value,i_method_name);
     ecx_debug.log(l_statement,'i_numofdec',i_numofdec,i_method_name);
     ecx_debug.log(l_statement,'i_sign',i_sign,i_method_name);
     ecx_debug.log(l_statement,'i_currency',i_currency,i_method_name);
     ecx_debug.log(l_statement,'i_uomvalue',i_uomvalue,i_method_name);
     ecx_debug.log(l_statement,'i_uomnumdec',i_uomnumdec,i_method_name);
     ecx_debug.log(l_statement,'i_uom',i_uom,i_method_name);
   end if;

   if i_value is not null then
      combine_number(i_number, i_value, i_sign, i_numofdec);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_number',i_number);
   end if;
   -- Assign the amount obtained to the OPERAMT variable
   get_var_attr(i_variable_level, i_variable_name,i_variable_direction,i_variable_pos,
	        i_variable_value, stack_var, stack_pos);
   assign_value(stack_var, stack_pos,i_variable_pos,i_variable_direction, i_number);

   /** This field is optional.Target Currency **/
   if (i_opr2_level >= 0 )
   then
      get_var_attr(i_opr2_level, i_opr2_name,i_opr2_direction,i_opr2_pos,i_opr2_value, opr2_stack, opr2_stack_pos);
      -- Assign the currency to the CURRENCY
      assign_value(opr2_stack, opr2_stack_pos, i_opr2_pos,i_opr2_direction, i_currency);
   end if;

   /** This field is optional.UOM_CODE **/
   if ( i_opr3_level >=0 )
   then
      get_var_attr(i_opr3_level, i_opr3_name,i_opr3_direction,i_opr3_pos,i_opr3_value, opr3_stack, opr3_stack_pos);
      -- Assign the uom code to the UOM_CODE
      assign_value(opr3_stack, opr3_stack_pos,i_opr3_pos,i_opr3_direction, i_uom);
   end if;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_FROM_OAG_OPERAMT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_FROM_OAG_OPERAMT');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_from_oag_operamt;

procedure convert_from_oag_amt(
	i_variable_level		IN	pls_integer,
	i_variable_name			IN	varchar2,
	i_variable_pos			IN	pls_integer,
	i_variable_direction		IN	varchar2,
  	i_opr1_level  		IN    pls_integer,
   	i_opr1_name       		IN    Varchar2,
   	i_opr1_pos        		IN    pls_integer,
   	i_opr1_direction       	IN    Varchar2,
   	i_opr1_constant        	IN    varchar2,
   	i_opr2_level      		IN    pls_integer,
   	i_opr2_name       		IN    Varchar2,
   	i_opr2_pos        		IN    pls_integer,
   	i_opr2_direction       	IN    Varchar2,
   	i_opr2_constant        	IN    varchar2,
   	i_opr3_level      		IN    pls_integer,
   	i_opr3_name       		IN    Varchar2,
   	i_opr3_pos        		IN    pls_integer,
   	i_opr3_direction       	IN    Varchar2,
   	i_opr3_constant        	IN    varchar2
) IS

   i_method_name   varchar2(2000) := 'ecx_actions.convert_from_oag_amt';
   i_number		number;
   i_value		varchar2(250);
   i_numofdec 		varchar2(100);
   i_sign		varchar2(1);
   i_currency		varchar2(5);
   i_uomvalue		varchar2(30);
   i_uomnumdec		varchar2(100);
   --i_uom		varchar2(30);
   i_crdr 		varchar2(500);
   var_pos         	number;
   stack_var       	boolean := FALSE;
   stack_pos       	pls_integer := null;
   i_variable_value	varchar2(2000);

   /** For Opr1 **/
   opr1_stack           Boolean := FALSE;
   opr1_stack_pos	pls_integer;
   i_opr1_value         varchar2(2000);

   /** For Opr2 **/
   opr2_stack          	Boolean := FALSE;
   opr2_stack_pos       pls_integer;
   i_opr2_value         Varchar2(2000);

   /** For Opr3 **/
   opr3_stack           Boolean := FALSE;
   opr3_stack_pos       pls_integer;
   i_opr3_value         Varchar2(2000);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_level',i_opr3_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_name',i_opr3_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_pos',i_opr3_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_direction',i_opr3_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr3_constant',i_opr3_constant,i_method_name);
   end if;
   -- Variable_name, level, pos is AMOUNT
   -- Previous variable, name, pos is CURRENCY
   -- Next Variable, name pos is CR/DR

   -- Adding 4 to i_variable_pos to skip the attributes of OPERAMT

   -- Calculate position
   var_pos := i_opr1_pos+1;

   if  i_opr1_direction = 'S'
   then
      while ecx_utils.g_source(var_pos).attribute_name <> 'VALUE'
      loop
   	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'name',ecx_utils.g_source(var_pos).attribute_name,i_method_name);
	end if;
    	var_pos := var_pos + 1;
      end loop;
   else
      while ecx_utils.g_target(var_pos).attribute_name <> 'VALUE'
      loop
   	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'name',ecx_utils.g_target(var_pos).attribute_name,i_method_name);
        end if;
    	var_pos := var_pos + 1;
      end loop;
   end if;

   get_var_attr(i_opr1_level, 'VALUE',i_opr1_direction,var_pos ,i_value, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'NUMOFDEC',i_opr1_direction,var_pos+1,i_numofdec, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'SIGN',i_opr1_direction,var_pos+2,i_sign, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'CURRENCY',i_opr1_direction,var_pos +3,i_currency, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level, 'CRDR',i_opr1_direction,var_pos +4,i_crdr, opr1_stack, opr1_stack_pos);

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_value',i_value,i_method_name);
     ecx_debug.log(l_statement,'i_numofdec',i_numofdec,i_method_name);
     ecx_debug.log(l_statement,'i_sign',i_sign,i_method_name);
     ecx_debug.log(l_statement,'i_currency',i_currency,i_method_name);
     ecx_debug.log(l_statement,'i_crdr',i_crdr,i_method_name);
   end if;

   if i_value is not null then
      combine_number(i_number, i_value, i_sign, i_numofdec);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_number',i_number,i_method_name);
   end if;

   -- Assign the amount obtained to the OPERAMT variable
   get_var_attr(i_variable_level, i_variable_name,i_variable_direction,i_variable_pos ,i_variable_value, stack_var, stack_pos);
   assign_value(stack_var, stack_pos,i_variable_pos,i_variable_direction, i_number);

   if ( i_opr2_level >=0 )
   then
      -- Assign the currency to the CURRENCY
      get_var_attr(i_opr2_level, i_opr2_name,i_opr2_direction,i_opr2_pos,i_opr2_value, opr2_stack, opr2_stack_pos);
      assign_value(opr2_stack, opr2_stack_pos, i_opr2_pos,i_opr2_direction, i_currency);
   end if;

   -- Assign the cr/dr sign to the CRDR
   if ( i_crdr is null )
   then
      if ( i_sign = '+' )
      then
         i_crdr := 'D';
      else
         i_crdr := 'C';
      end if;
   end if;

   if ( i_opr3_level >=0 )
   then
      get_var_attr(i_opr3_level, i_opr3_name,i_opr3_direction,i_opr3_pos ,i_opr3_value, opr3_stack, opr3_stack_pos);
      assign_value(opr3_stack, opr3_stack_pos,i_opr3_pos,i_opr3_direction, i_crdr);
   end if;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_FROM_OAG_AMT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_FROM_OAG_AMT');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_from_oag_amt;

procedure derive_address_id
	(
	i_variable_level  		IN      pls_integer,
	i_variable_name			IN	varchar2,
	i_variable_pos			IN	pls_integer,
	i_variable_direction		IN	varchar2,
  	i_opr1_level  			IN    pls_integer,
   	i_opr1_name       		IN    Varchar2,
   	i_opr1_pos        		IN    pls_integer,
   	i_opr1_direction       		IN    Varchar2,
   	i_opr1_constant        		IN    varchar2,
   	i_opr2_constant        		IN    varchar2,
   	i_opr3_level      		IN    pls_integer,
   	i_opr3_name       		IN    Varchar2,
   	i_opr3_pos        		IN    pls_integer,
   	i_opr3_direction       		IN    Varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_actions.derive_address_id';
i_variable_value	varchar2(2000);
i_value			varchar2(2000);
i_value3		varchar2(2000);
i_info_type		varchar2(2000);
opr3_stack		boolean;
opr3_stack_pos		pls_integer;
var_stack		boolean;
var_stack_pos		pls_integer;
opr1_stack		boolean;
opr1_stack_pos		pls_integer;
retcode			pls_integer;
retmsg			varchar2(400);
p_entity_address_id	pls_integer;
p_org_id		pls_integer;
begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   i_value := i_opr1_constant;
   if i_value is null
   then
      get_var_attr(
	i_opr1_level,
	i_opr1_name,
	i_opr1_direction,
	i_opr1_pos ,
	i_value,
	opr1_stack,
	opr1_stack_pos
	);
   end if;

   if i_value = 'NULL'
   then
      i_value := null;
   end if;

   /** check for Info Type **/
   if i_opr2_constant = 0
   then
      i_info_type := 'CUSTOMER';
   elsif i_opr2_constant = 1
   then
      i_info_type := 'SUPPLIER';
   elsif i_opr2_constant = 2
   then
      i_info_type := 'LOCATION';
   elsif i_opr2_constant = 3
   then
      i_info_type := 'BANK';
   end if;

   ecx_trading_partner_pvt.get_address_id
		(
		i_value,
		i_info_type,
		p_entity_address_id,
		p_org_id,
		retcode,
		retmsg
		);

   /** Assign the value back to the Address Id **/
   if i_variable_level is not null
   then
      get_var_attr(
		i_variable_level,
		i_variable_name,
		i_variable_direction,
		i_variable_pos ,
		i_variable_value,
		var_stack,
		var_stack_pos
		);
	assign_value(var_stack, var_stack_pos,i_variable_pos,i_variable_direction, p_entity_address_id);
   end if;

   /** Assign the value back to the p_org_id **/
   if i_opr3_level is not null
   then
      get_var_attr(
		i_opr3_level,
		i_opr3_name,
		i_opr3_direction,
		i_opr3_pos ,
		i_value3,
		opr3_stack,
		opr3_stack_pos
		);
	assign_value(opr3_stack, opr3_stack_pos,i_opr3_pos,i_opr3_direction, p_org_id);
   end if;

   if retcode = 2
   then
      raise ecx_utils.program_exit;
   end if;
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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.DERIVE_ADDRESS_ID');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.DERIVE_ADDRESS_ID');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end derive_address_id;

procedure convert_from_oag_quantity(
	i_variable_level  		IN      pls_integer,
	i_variable_name			IN	varchar2,
	i_variable_pos			IN	pls_integer,
	i_variable_direction		IN	varchar2,
  	i_opr1_level  		IN    pls_integer,
   	i_opr1_name       		IN    Varchar2,
   	i_opr1_pos        		IN    pls_integer,
   	i_opr1_direction       	IN    Varchar2,
   	i_opr1_constant        	IN    varchar2,
   	i_opr2_level      		IN    pls_integer,
   	i_opr2_name       		IN    Varchar2,
   	i_opr2_pos        		IN    pls_integer,
   	i_opr2_direction       	IN    Varchar2,
   	i_opr2_constant        	IN    varchar2
)IS


   i_method_name   varchar2(2000) := 'ecx_actions.convert_from_oag_quantity';

   var_value	 	varchar2(2000);
   stack_var		boolean := FALSE;
   stack_pos		pls_integer := null;
   i_variable_value	varchar2(2000);

   /** For Opr1 **/
   opr1_stack           Boolean := FALSE;
   opr1_stack_pos       pls_integer;
   i_opr1_value         varchar2(2000);

   /** For Opr2 **/
   opr2_stack          	Boolean := FALSE;
   opr2_stack_pos       pls_integer;
   i_opr2_value         Varchar2(2000);
   i_number		number;
   i_value		varchar2(2000);
   i_numofdec		varchar2(100);
   i_sign		varchar2(1);
   i_uom		varchar2(250);
   var_pos		pls_integer;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_variable_level',i_variable_level,i_method_name);
     ecx_debug.log(l_statement,'i_variable_name',i_variable_name,i_method_name);
     ecx_debug.log(l_statement,'i_variable_pos',i_variable_pos,i_method_name);
     ecx_debug.log(l_statement,'i_variable_direction',i_variable_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_level',i_opr1_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_name',i_opr1_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_pos',i_opr1_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_direction',i_opr1_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr1_constant',i_opr1_constant,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_level',i_opr2_level,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_name',i_opr2_name,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_pos',i_opr2_pos,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_direction',i_opr2_direction,i_method_name);
     ecx_debug.log(l_statement,'i_opr2_constant',i_opr2_constant,i_method_name);
   end if;
   -- Variable_name, pos, level here correspond to QUANTITY
   -- Previuos variable_name, pos, level here is UOM CODE.
   -- Adding 2 to i_variable_pos to skip the attribute of QUANTITY

   get_var_attr(i_opr1_level,'VALUE',i_opr1_direction,i_opr1_pos+2,i_value, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level,'NUMOFDEC',i_opr1_direction,i_opr1_pos+3, i_numofdec, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level,'SIGN',i_opr1_direction,i_opr1_pos+4,i_sign, opr1_stack, opr1_stack_pos);
   get_var_attr(i_opr1_level,'UOM',i_opr1_direction,i_opr1_pos+5,i_uom, opr1_stack, opr1_stack_pos);

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_value',i_value,i_method_name);
     ecx_debug.log(l_statement,'i_sign',i_sign,i_method_name);
     ecx_debug.log(l_statement,'i_uom',i_uom,i_method_name);
     ecx_debug.log(l_statement,'i_numofdec',i_numofdec,i_method_name);
   end if;

   if i_value is not null then
      combine_number(i_number, i_value, i_sign, i_numofdec);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_number',i_number,i_method_name);
   end if;
   -- Assign the quantity obtained to the field QUANTITY
   get_var_attr(i_variable_level, i_variable_name,i_variable_direction,i_variable_pos ,i_variable_value, stack_var, stack_pos);
   assign_value(stack_var, stack_pos,i_variable_pos,i_variable_direction, i_number);

   if ( i_opr2_level >= 0 )
   then
      -- Assign the uom code to the fied UOM_CODE
      get_var_attr(i_opr2_level, i_opr2_name,i_opr2_direction,i_opr2_pos ,i_opr2_value, opr2_stack, opr2_stack_pos);
      assign_value(opr2_stack, opr2_stack_pos,i_opr2_pos,i_opr2_direction, i_uom);
   end if;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	            'PROGRESS_LEVEL','ECX_ACTIONS.CONVERT_FROM_OAG_QUANTITY');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.CONVERT_FROM_AG_QUANTITY');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end convert_from_oag_quantity;

procedure execute_math_functions
	(
	action	in	pls_integer,
	x_level	in	pls_integer,
	x_name	in	varchar2,
	x_pos	in	pls_integer,
	x_dir	in	varchar2,
	y_level	in	pls_integer,
	y_name	in	varchar2,
	y_pos	in	pls_integer,
	y_dir	in	varchar2,
	y_def	in	varchar2,
	z_level	in	pls_integer,
	z_name	in	varchar2,
	z_pos	in	pls_integer,
	z_dir	in	varchar2,
	z_def	in	varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_actions.execute_math_functions';

x		varchar2(2000);
y		varchar2(2000);
z		varchar2(2000);
x1		varchar2(2000);

stack_var	boolean := false;
stack_pos	pls_integer;
i_math_fun_type	varchar2(20);
y_number	number;
z_number	number;
begin
	if (l_procedureEnabled) then
         ecx_debug.push(i_method_name);
        end if;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'action',action,i_method_name);
	  ecx_debug.log(l_statement,'x_level',x_level,i_method_name);
	  ecx_debug.log(l_statement,'x_name',x_name,i_method_name);
	  ecx_debug.log(l_statement,'x_pos',x_pos,i_method_name);
	  ecx_debug.log(l_statement,'x_dir',x_dir,i_method_name);
	  ecx_debug.log(l_statement,'y_level',y_level,i_method_name);
	  ecx_debug.log(l_statement,'y_name',y_name,i_method_name);
	  ecx_debug.log(l_statement,'y_pos',y_pos,i_method_name);
	  ecx_debug.log(l_statement,'y_dir',y_dir,i_method_name);
	  ecx_debug.log(l_statement,'y_def',y_def,i_method_name);
	  ecx_debug.log(l_statement,'z_level',z_level,i_method_name);
	  ecx_debug.log(l_statement,'z_name',z_name,i_method_name);
	  ecx_debug.log(l_statement,'z_pos',z_pos,i_method_name);
	  ecx_debug.log(l_statement,'z_dir',z_dir,i_method_name);
	  ecx_debug.log(l_statement,'z_def',z_def,i_method_name);
       end if;
	if action = 4000
	then
		i_math_fun_type := '+';
	elsif action = 4010
	then
		i_math_fun_type := '-';
	elsif action = 4020
	then
		i_math_fun_type := '*';
	elsif action = 4030
	then
		i_math_fun_type := '/';
	end if;

	/** Find the values of y and z
	Look for Default First and than the variable Value
	**/

	z := z_def;
	if z is null
	then
		get_var_attr	(
				z_level,
				z_name,
				z_dir,
				z_pos,
				z,
				stack_var,
				stack_pos);

	end if;
	if z = 'NULL'
	then
		z :=null;
	end if;

	y := y_def;
	if y is null
	then
		get_var_attr	(
				y_level,
				y_name,
				y_dir,
				y_pos,
				y,
				stack_var,
				stack_pos);
	end if;
	if y = 'NULL'
	then
		y :=null;
	end if;

	/** Check for numbers here **/
	begin
		y_number := to_number(y);
	exception
	when others then
		if(l_unexpectedEnabled) then
                   ecx_debug.log(l_unexpected,'Cannot convert to number',y,i_method_name);
		end if;
                ecx_debug.setErrorInfo(2,30,'ECX_CANNOT_CONVERT_TO_NUM',
                                       'p_value',y);
		raise	ecx_utils.program_exit;
	end;

	begin
		z_number := to_number(z);
	exception
	when others then
		if(l_unexpectedEnabled) then
                  ecx_debug.log(l_unexpected,'Cannot convert to number the value',z,i_method_name);
		end if;
                ecx_debug.setErrorInfo(2,30,'ECX_CANNOT_CONVERT_TO_NUM',
                                               'p_value',z);
		raise	ecx_utils.program_exit;
	end;
	x := ecx_conditions.math_functions ( i_math_fun_type, y_number, z_number);

	get_var_attr	(
			x_level,
			x_name,
			x_dir,
			x_pos,
			x1,
			stack_var,
			stack_pos);

	-- Assign the value obtained for x
	assign_value	(
			stack_var,
			stack_pos,
			x_pos,
			x_dir,
			x);
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
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	               'PROGRESS_LEVEL','ECX_ACTIONS.EXECUTE_MATH_FUNCTIONS');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	               'ERROR_MESSAGE',SQLERRM);
        end if;
      	ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.EXECUTE_MATH_FUNCTIONS');
      	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
      	raise ecx_utils.PROGRAM_EXIT;
end execute_math_functions;


procedure transform_xml_with_xslt
  (
  p_default_value  IN	 varchar2,
  p_opr1_level     IN    pls_integer,
  p_opr1_name      IN    Varchar2,
  p_opr1_pos       IN    pls_integer,
  p_opr1_direction IN    Varchar2,
  p_opr1_constant  IN    varchar2
  ) is

  l_filename        Varchar2(500);
  l_opr1_stack      boolean;
  l_opr1_stack_pos  pls_integer;

begin
  if p_default_value is not null then
    l_filename := p_default_value;
  else
    l_filename := p_opr1_constant;
    if l_filename is null then
      get_var_attr(
	p_opr1_level,
	p_opr1_name,
	p_opr1_direction,
	p_opr1_pos ,
	l_filename,
	l_opr1_stack,
	l_opr1_stack_pos
	);
    end if;
  end if;

  if (l_filename is null) or (l_filename = 'NULL')
  then
    return;
  end if;

  transform_xml_with_xslt (l_filename);

exception
   when others then
     raise ecx_utils.program_exit;
end transform_xml_with_xslt;


procedure 	transform_xml_with_xslt
		(
		i_filename		in	varchar2,
		i_version		in	number,
		i_application_code	in	varchar2
		)
is
i_method_name   varchar2(2000) := 'ecx_actions.transform_xml_with_xslt';

i_stylesheet	xslprocessor.Stylesheet;
i_processor	xslprocessor.Processor;
i_xmlDocFrag	xmlDOM.DOMDocumentFragment;
i_domDocFrag	xmlDOM.DOMDocumentFragment;
i_domNode       xmlDOM.DOMNode;
i_xslt_dir	varchar2(200);
i_fullpath	varchar2(200);
i_string	varchar2(2000);
l_xslt_payload	clob;
l_parser	xmlparser.parser;
l_xsl_doc	xmldom.DOMDocument;
i_doc           xmlDOM.DOMDocument;
i_doc_frag      xmlDOM.DOMDocumentFragment;
i_node_type     pls_integer;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (xmlDOM.isNull(ecx_utils.g_xmldoc)) then
        return;
   end if;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_filename',i_filename,i_method_name);
   end if;

   if i_filename is null
   then
	return;
   end if;

   -- check if the XSLT file is loaded in the DB
   begin
       select payload
      into   l_xslt_payload
      from   ecx_files
      where  (i_version is null or version = i_version)
      and    (i_application_code is null or application_code = i_application_code)
      and    name = i_filename
      and    type = 'XSLT';
	exception
      when no_data_found then
         null;
      when too_many_rows then
         -- currently we do not support version and application_code as
         -- input parameters for XSLT actions, so for now, this exception
         -- means that the API was invoked within the actions code. So, check
         -- the file system
         if(l_unexpectedEnabled) then
             ecx_debug.log(l_unexpected, SQLERRM,i_method_name);
	 end if;
         l_xslt_payload := null;
      when others then
        ecx_debug.setErrorInfo(2,30,SQLERRM);
         raise ecx_utils.program_exit;
   end;

   if (l_xslt_payload is null)
   then
      -- xslt file is not loaded in the DB table
      -- do the transformation assuming that it is on the file system
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'XSLT file not loaded in the DB. Checking the file system...',
                     i_method_name);
      end if;

      if (ecx_actions.g_xslt_dir is null) then
         --- Check for the Installation Type ( Standalone or Embedded );
         if (ecx_utils.g_install_mode is null) then
            ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
         end if;

         if ecx_utils.g_install_mode = 'EMBEDDED'
         then
            i_string := 'begin
            fnd_profile.get('||'''ECX_UTL_XSLT_DIR'''||',ecx_actions.g_xslt_dir);
         end;';
            execute immediate i_string ;
         else
            ecx_actions.g_xslt_dir:= wf_core.translate('ECX_UTL_XSLT_DIR');
         end if;
      end if;

      i_fullpath := ecx_actions.g_xslt_dir||ecx_utils.getFileSeparator()||i_filename;
      if(l_statementEnabled) then
             ecx_debug.log(l_statement, 'XSLT Fullpath', i_fullpath,i_method_name);
      end if;
      l_parser := xmlparser.newParser;
      xmlparser.setPreservewhitespace(l_parser,true); -- bug:4953557
      xmlparser.parse(l_parser,i_fullpath);
      l_xsl_doc := xmlparser.getDocument(l_parser);
      i_stylesheet := xslprocessor.newStyleSheet(l_xsl_doc,i_fullpath);
   else
      -- payload found in DB,
      if(l_statementEnabled) then
             ecx_debug.log(l_statement, 'Found XSLT file in the DB',i_method_name);
      end if;
      -- convert l_xslt_paylod from clob to DOMDocument
      l_parser := xmlparser.newParser;
      xmlparser.setPreservewhitespace(l_parser,true); -- bug:4953557
      xmlparser.parseCLOB(l_parser, l_xslt_payload);
      l_xsl_doc := xmlparser.getDocument(l_parser);

      -- get the stylesheet
      i_stylesheet := xslprocessor.newStyleSheet(l_xsl_doc, null);
   end if;

   i_processor := xslprocessor.newProcessor;

   -- get the type of the DOMNode
   i_node_type := xmlDOM.getNodeType(ecx_utils.g_xmldoc);
             if(l_statementEnabled) then
               ecx_debug.log(l_statement, 'i_node_type', i_node_type,i_method_name);
	     end if;

   if (i_node_type = xmlDOM.DOCUMENT_NODE)
   then
      if(l_statementEnabled) then
           ecx_debug.log(l_statement, 'Creating Document Object from DOM Node...',i_method_name);
      end if;
      i_doc := xmlDOM.makeDocument(ecx_utils.g_xmldoc);
      if(l_statementEnabled) then
        ecx_debug.log(l_statement, 'Before processing XSL',i_method_name);
      end if;
      i_xmlDocFrag := xslprocessor.processXSL(i_processor, i_stylesheet, i_doc);

   elsif (i_node_type = xmlDOM.DOCUMENT_FRAGMENT_NODE)
   then
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Creating Document fragment from DOM Node...',i_method_name);
      end if;
      i_doc_frag := xmlDOM.makeDocumentFragment(ecx_utils.g_xmldoc);
      if(l_statementEnabled) then
        ecx_debug.log(l_statement, 'Before processing XSL',i_method_name);
      end if;
      i_xmlDocFrag := xslprocessor.processXSL(i_processor, i_stylesheet, i_doc_frag);
   end if;

   if(l_statementEnabled) then
        ecx_debug.log(l_statement,'XSL processed.Creating Node...',i_method_name);
   end if;
   i_domNode := xmlDOM.makeNode(i_xmlDocFrag);
   if(l_statementEnabled) then
     ecx_debug.log(l_statement, 'Node created.',i_method_name);
   end if;
   ecx_utils.g_xmldoc := i_domNode;

   -- free all the used variables

   xslprocessor.freeStylesheet(i_stylesheet);
   xslprocessor.freeProcessor(i_processor);

   if (l_parser.id <> -1)
   then
      xmlParser.freeParser(l_parser);
   end if;
   if (not xmldom.isNull(l_xsl_doc))
   then
      xmldom.freeDocument(l_xsl_doc);
   end if;
   if (not xmldom.isNull(i_doc))
   then
      xmldom.freeDocument(i_doc);
   end if;

   if (not xmldom.isNull(i_doc_frag))
   then
      xmldom.freeDocFrag(i_doc_frag);
   end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
-- Put All DOM Parser Exceptions Here.
when	xmlDOM.INDEX_SIZE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.DOMSTRING_SIZE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.HIERARCHY_REQUEST_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.WRONG_DOCUMENT_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.INVALID_CHARACTER_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NO_DATA_ALLOWED_ERR then
         ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.No_MODIFICATION_ALLOWED_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NOT_FOUND_ERR then
         ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NOT_SUPPORTED_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.INUSE_ATTRIBUTE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;

   WHEN OTHERS THEN
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.TRANSFORM_XML_WITH_XSLT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
       ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.TRANSFORM_XML_WITH_XSLT');
	-- free all the used variables
	if (l_parser.id <> -1)
	then
	   xmlParser.freeParser(l_parser);
	end if;
	if (not xmldom.isNull(l_xsl_doc))
	then
	   xmldom.freeDocument(l_xsl_doc);
	end if;
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end transform_xml_with_xslt;

/**
Executes the Data from the ECX_TRAN_STAGE_DATA for a given Stage and Level.
**/
procedure execute_stage_data (
   i_stage      IN     pls_integer,
   i_level      IN     pls_integer,
   i_direction  IN     varchar2 ) IS

   i_method_name   varchar2(2000) := 'ecx_actions.execute_stage_data';

   /* Cursor to get all the Level 0 Stack Data */
   cursor stack_data is
   select variable_name,
          variable_value,
          variable_direction,
          data_type datatype
   from   ecx_tran_stage_data ets
   where  ets.map_id = ecx_utils.g_map_id
   and    variable_level = 0
   and action_type = 10;

   i_counter           pls_integer:= 0;
   /** variables for evaluating the condition **/

   i_var1	varchar2(4000);
   i_var2	varchar2(4000);
   i_val1	varchar2(4000);
   i_val2	varchar2(4000);

   i_vartype1	pls_integer;
   i_valtype1	pls_integer;
   i_vartype2	pls_integer;
   i_valtype2	pls_integer;
   stack_var	boolean;
   stack_pos	pls_integer;
   i_date	date;
   i_number	number;

   condition_flag	boolean := true;

begin
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_stage',i_stage,i_method_name);
     ecx_debug.log(l_statement,'i_level',i_level,i_method_name);
     ecx_debug.log(l_statement,'i_direction',i_direction,i_method_name);
   end if;

   if i_stage = 10 then

      if (i_level = 0) then

         ecx_actions.g_server_timezone := null;
         ecx_actions.g_xslt_dir := null;

         ecx_utils.g_stack.DELETE;

         for get_stack_data in stack_data loop
            i_counter := i_counter + 1;
            ecx_utils.g_stack(i_counter).variable_name := get_stack_data.variable_name;
            ecx_utils.g_stack(i_counter).variable_value := get_stack_data.variable_value;
            ecx_utils.g_stack(i_counter).data_type := get_stack_data.datatype;
         end loop;

	 if(l_statementEnabled) then
		dump_stack;
	 end if;

      end if;
   end if;

   if(ecx_utils.g_stage_data.count <> 0)
   then
      FOR i in ecx_utils.g_stage_data.first..ecx_utils.g_stage_data.last
      loop
         exit when i = ecx_utils.g_stage_data.count;
         if (ecx_utils.g_stage_data(i).stage = i_stage
             and ecx_utils.g_stage_data(i).level = i_level and
             ecx_utils.g_stage_data(i).object_direction = i_direction)
         then

	    /**
	    Check for Condition First. If Defined , evaluate it first and then execute an action.
	    If the condition is not defined , execute the action i.e. action without condition.
	    Initialize the values of the variables.
	    Word NULL will be used to specify NULL values for the Variables. It will be reserved for XML gateway.
	    **/
	    i_var1 :=null;
	    i_var2 :=null;
	    i_val1 :=null;
	    i_val2 :=null;

	    /** Set Default Datatype to varchar2 **/
	    i_vartype1 :=1;
	    i_valtype1 :=1;
	    i_vartype2 :=1;
	    i_valtype2 :=1;
	    condition_flag :=true;

	    if ecx_utils.g_stage_data(i).cond_operator1 is not null
	    then
		/** Condition based on one variable **/
		-- Find variable Values
			-- Look for Default first. If null , get it from the variable

			i_var1 := ecx_utils.g_stage_data(i).cond_var1_constant;
			if i_var1 is null
			then
				get_var_attr	(
					ecx_utils.g_stage_data(i).cond_var1_level,
					ecx_utils.g_stage_data(i).cond_var1_name,
					ecx_utils.g_stage_data(i).cond_var1_direction,
					ecx_utils.g_stage_data(i).cond_var1_pos,
					i_var1,
					stack_var,
					stack_pos);

				/** Get the Data Type for the Left hand side variables **/
				if ecx_utils.g_stage_data(i).cond_var1_direction = 'G'
				then
					i_vartype1 := ecx_utils.g_stack(stack_pos).data_type;
				else
					if ecx_utils.g_stage_data(i).cond_var1_direction = 'S'
					then
						i_vartype1 := ecx_utils.g_source(ecx_utils.g_stage_data(i).cond_var1_pos).data_type;
					else
						i_vartype1 := ecx_utils.g_target(ecx_utils.g_stage_data(i).cond_var1_pos).data_type;
					end if;
				end if;
				if(l_statementEnabled) then
                                  ecx_debug.log(l_statement,'i_vartype1',i_vartype1,i_method_name);
				end if;
			else
				if i_var1 = 'NULL'
				then
					i_var1 :=null;
				else
					/** Try to find out the data type **/
					/** Attempt for date **/
					begin
						i_date := to_date(i_var1,'YYYYMMDD HH24MISS');
						if(l_statementEnabled) then
                                                  ecx_debug.log(l_statement,'i_date',i_date,i_method_name);
						end if;
						i_vartype1 :=12;
					exception
					when others then
						if(l_unexpectedEnabled) then
                                                  ecx_debug.log(l_unexpected,'i_date','Not a date',i_method_name);
						end if;

						/** Attempt for number **/
						begin
							i_number := to_number(i_var1);
							if(l_unexpectedEnabled) then
                                                          ecx_debug.log(l_unexpected,'i_number',i_number,i_method_name);
							end if;
							i_vartype1 :=2;
						exception
						when others then
							if(l_unexpectedEnabled) then
                                                         ecx_debug.log(l_unexpected,'i_number','Not a number',i_method_name);
						        end if;
						end;
					end;
				end if;
			end if;




			if ecx_utils.g_stage_data(i).cond_operator1 not in ('6','7')
			then
				i_val1 := ecx_utils.g_stage_data(i).cond_val1_constant;
				if i_val1 is null
				then
					get_var_attr	(
						ecx_utils.g_stage_data(i).cond_val1_level,
						ecx_utils.g_stage_data(i).cond_val1_name,
						ecx_utils.g_stage_data(i).cond_val1_direction,
						ecx_utils.g_stage_data(i).cond_val1_pos,
						i_val1,
						stack_var,
						stack_pos);
					/** Get the Data Type for the right hand side variables **/
					if ecx_utils.g_stage_data(i).cond_val1_direction = 'G'
					then
						i_valtype1 := ecx_utils.g_stack(stack_pos).data_type;
					else
						if ecx_utils.g_stage_data(i).cond_val1_direction = 'S'
						then
							i_valtype1 := ecx_utils.g_source(ecx_utils.g_stage_data(i).cond_val1_pos).data_type;
						else
							i_valtype1 := ecx_utils.g_target(ecx_utils.g_stage_data(i).cond_val1_pos).data_type;
						end if;
					end if;
					if(l_statementEnabled) then
                                           ecx_debug.log(l_statement,'i_valtype1',i_valtype1,i_method_name);
					end if;
				else
					if i_val1 = 'NULL'
					then
						i_val1 :=null;
					else
						/** Try to find out the data type **/
						/** Attempt for date **/
						begin
							i_date := to_date(i_val1,'YYYYMMDD HH24MISS');
							if(l_statementEnabled) then
                                                          ecx_debug.log(l_statement,'i_date',i_date,i_method_name);
							end if;
							i_valtype1 :=12;
						exception
						when others then
							if(l_unexpectedEnabled) then
                                                          ecx_debug.log(l_unexpected,'i_date','Not a date',i_method_name);
		                                        end if;
							/** Attempt for number **/
							begin
								i_number := to_number(i_val1);
								if(l_unexpectedEnabled) then
                                                                  ecx_debug.log(l_unexpected,'i_number',i_number,i_method_name);
								end if;
								i_valtype1 :=2;
							exception
							when others then
								if(l_unexpectedEnabled) then
                                                                  ecx_debug.log(l_unexpected,'i_number','Not a number',
								               i_method_name);
							        end if;

							end;
						end;
					end if;
				end if;

			end if;
	end if;

	 if ecx_utils.g_stage_data(i).cond_logical_operator is not null
	 then

		/** Condition based on two variables **/
			i_var2 := ecx_utils.g_stage_data(i).cond_var2_constant;
			if i_var2 is null
			then
				get_var_attr	(
					ecx_utils.g_stage_data(i).cond_var2_level,
					ecx_utils.g_stage_data(i).cond_var2_name,
					ecx_utils.g_stage_data(i).cond_var2_direction,
					ecx_utils.g_stage_data(i).cond_var2_pos,
					i_var2,
					stack_var,
					stack_pos);
			end if;


			if i_var2 = 'NULL'
			then
				i_var2 :=null;
			end if;

			/** Get the Data Type for the Left hand side variables **/
			if ecx_utils.g_stage_data(i).cond_var2_direction = 'G'
			then
				i_vartype2 := ecx_utils.g_stack(stack_pos).data_type;
			else
				if ecx_utils.g_stage_data(i).cond_var2_direction = 'S'
				then
					i_vartype2 := ecx_utils.g_source(ecx_utils.g_stage_data(i).cond_var2_pos).data_type;
				else
					i_vartype2 := ecx_utils.g_target(ecx_utils.g_stage_data(i).cond_var2_pos).data_type;
				end if;
			end if;
			if(l_statementEnabled) then
                          ecx_debug.log(l_statement,'i_vartype2',i_vartype2,i_method_name);
			end if;


			if ecx_utils.g_stage_data(i).cond_operator1 not in ('6','7')
			then
				i_val2 := ecx_utils.g_stage_data(i).cond_val2_constant;
				if i_val2 is null
				then
					get_var_attr	(
						ecx_utils.g_stage_data(i).cond_val2_level,
						ecx_utils.g_stage_data(i).cond_val2_name,
						ecx_utils.g_stage_data(i).cond_val2_direction,
						ecx_utils.g_stage_data(i).cond_val2_pos,
						i_val2,
						stack_var,
						stack_pos);
				end if;

				if i_val2 = 'NULL'
				then
					i_val2 :=null;
				end if;

				/** Get the Data Type for the right hand side variables **/
				if ecx_utils.g_stage_data(i).cond_val2_direction = 'G'
				then
					i_valtype2 := ecx_utils.g_stack(stack_pos).data_type;
				else
					if ecx_utils.g_stage_data(i).cond_val2_direction = 'S'
					then
						i_valtype2 := ecx_utils.g_source(ecx_utils.g_stage_data(i).cond_val2_pos).data_type;
					else
						i_valtype2 := ecx_utils.g_target(ecx_utils.g_stage_data(i).cond_val2_pos).data_type;
					end if;
				end if;
				if(l_statementEnabled) then
                                    ecx_debug.log(l_statement,'i_valtype2',i_valtype2,i_method_name);
				end if;

			end if;
	 end if;

	/** Now check the condition **/
	if 	(ecx_utils.g_stage_data(i).cond_operator1 is not null
		or
		ecx_utils.g_stage_data(i).cond_logical_operator is not null
		)
	then
		condition_flag := ecx_conditions.check_condition
			(
			ecx_utils.g_stage_data(i).cond_logical_operator,
			ecx_utils.g_stage_data(i).cond_operator1,
			i_var1,
			i_vartype1,
			i_val1,
			i_valtype1,
			ecx_utils.g_stage_data(i).cond_operator2,
			i_var2,
			i_vartype2,
			i_val2,
			i_valtype2
			);
	else
		/** No Condition Found **/
		condition_flag :=true;
	end if;

  if ( condition_flag )
  then

	/** Not required anymore
         if ecx_utils.g_stage_data(i).action_type = ASSIGN_DEFAULT then
            assign_default_to_variables
		(
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).default_value
		);
	**/

         if ecx_utils.g_stage_data(i).action_type = ASSIGN_PRE_DEFINED then
            assign_pre_defined_variables
                (
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type = ASSIGN_NEXTVALUE then
           assign_nextval_from_sequence
                (
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).sequence_name
                );

         elsif ecx_utils.g_stage_data(i).action_type = ASSIGN_FUNCVAL then
            assign_function_value
                (
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).function_name
                );

         elsif ecx_utils.g_stage_data(i).action_type = CONV_TO_OAGDATE then
            convert_to_oag_date
                (
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant
                );

        elsif ecx_utils.g_stage_data(i).action_type = CONV_TO_OAGOPERAMT then
            convert_to_oag_operamt(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant,
		ecx_utils.g_stage_data(i).operand3_level,
		ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_direction,
		ecx_utils.g_stage_data(i).operand3_constant
                );
        elsif ecx_utils.g_stage_data(i).action_type = CONV_TO_OAGAMT then
            convert_to_oag_amt(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant,
		ecx_utils.g_stage_data(i).operand3_level,
		ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_direction,
		ecx_utils.g_stage_data(i).operand3_constant
                );

        elsif ecx_utils.g_stage_data(i).action_type = CONV_TO_OAGQUANT then
            convert_to_oag_quantity(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type = CONV_FROM_OAGDATE then
            convert_from_oag_date
                (
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant
                );

        elsif ecx_utils.g_stage_data(i).action_type = CONV_FROM_OAGOPERAMT then
            convert_from_oag_operamt(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant,
		ecx_utils.g_stage_data(i).operand3_level,
		ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_direction,
		ecx_utils.g_stage_data(i).operand3_constant
                );
        elsif ecx_utils.g_stage_data(i).action_type = CONV_FROM_OAGAMT then
            convert_from_oag_amt(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant,
		ecx_utils.g_stage_data(i).operand3_level,
		ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_direction,
		ecx_utils.g_stage_data(i).operand3_constant
                );

        elsif ecx_utils.g_stage_data(i).action_type = CONV_FROM_OAGQUANT then
            convert_from_oag_quantity(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).operand1_level,
		ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_level,
		ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type = INSERT_INTO_OPEN_INTERFACE then
            insert_level_into_table (i_level);

	 /** Removed the call as it is being called in the initialization of source itself **/
         --elsif ecx_utils.g_stage_data(i).action_type = APPEND_WHERECLAUSE then
            --append_clause
                --(
		--ecx_utils.g_stage_data(i).level,
                --ecx_utils.g_stage_data(i).clause
                --);

         elsif ecx_utils.g_stage_data(i).action_type = EXEC_PROCEDURES then
            execute_proc
                (
                 ecx_utils.g_stage_data(i).transtage_id,
                 ecx_utils.g_stage_data(i).custom_procedure_name
                );

         elsif ecx_utils.g_stage_data(i).action_type = EXITPROGRAM then
            exit_program;

         elsif ecx_utils.g_stage_data(i).action_type = SEND_ERROR then
            send_err
                (
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_constant,
                ecx_utils.g_stage_data(i).operand2_level,
                ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type = API_RETURN_CODE then
            get_api_retcode
                (
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).default_value,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).function_name
                );
         elsif ecx_utils.g_stage_data(i).action_type = CONCAT_VAR then
            concat_variables
                (
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_constant,
                ecx_utils.g_stage_data(i).operand2_level,
                ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type = SUBSTR_VAR then
            substr_variables
                (
		ecx_utils.g_stage_data(i).variable_level,
		ecx_utils.g_stage_data(i).variable_name,
		ecx_utils.g_stage_data(i).variable_direction,
		ecx_utils.g_stage_data(i).variable_pos,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_constant,
                ecx_utils.g_stage_data(i).operand2_level,
                ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_constant,
                ecx_utils.g_stage_data(i).operand3_level,
                ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_direction,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_constant
                );

         elsif ecx_utils.g_stage_data(i).action_type in ( 4000,4010,4020,4030)
	 then
		execute_math_functions
		(
                ecx_utils.g_stage_data(i).action_type,
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
                ecx_utils.g_stage_data(i).operand2_level,
                ecx_utils.g_stage_data(i).operand2_name,
		ecx_utils.g_stage_data(i).operand2_pos,
		ecx_utils.g_stage_data(i).operand2_direction,
		ecx_utils.g_stage_data(i).operand2_constant
		);
         elsif ecx_utils.g_stage_data(i).action_type = XSLT_TRANSFORM then
		transform_xml_with_xslt
		(
		ecx_utils.g_stage_data(i).default_value,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant
		);
         elsif ecx_utils.g_stage_data(i).action_type = GET_ADDRESS_ID
	 then
		derive_address_id
		(
                ecx_utils.g_stage_data(i).variable_level,
                ecx_utils.g_stage_data(i).variable_name,
                ecx_utils.g_stage_data(i).variable_pos,
		ecx_utils.g_stage_data(i).variable_direction,
                ecx_utils.g_stage_data(i).operand1_level,
                ecx_utils.g_stage_data(i).operand1_name,
		ecx_utils.g_stage_data(i).operand1_pos,
		ecx_utils.g_stage_data(i).operand1_direction,
		ecx_utils.g_stage_data(i).operand1_constant,
		ecx_utils.g_stage_data(i).operand2_constant,
                ecx_utils.g_stage_data(i).operand3_level,
                ecx_utils.g_stage_data(i).operand3_name,
		ecx_utils.g_stage_data(i).operand3_pos,
		ecx_utils.g_stage_data(i).operand3_direction
		);
         end if;

   end if; --- Condition Flag

      end if; -- Stage Check
   end loop;
end if;
   if(l_statementEnabled) then
	dump_stack;
   end if;

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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_ACTIONS.EXECUTE_STAGE_DATA');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.EXECUTE_STAGE_DATA');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;


end execute_stage_data;

/*
  Gets the timezone offset for the DB server timezone based on the date
*/
Function getTimeZoneOffset (year number, month number, day number, hour number,
                    minute number, second number, timezone varchar2)
return number
is language java
name 'oracle.apps.ecx.util.TimeZoneOffset.getOffset(int, int, int, int, int, int,
                                                    java.lang.String) returns float';


Procedure get_clob(clobValue in clob , value in Varchar2 , clobOut out nocopy clob) as
i_method_name   varchar2(2000) := 'ecx_actions.get_clob';
begin

if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if (clobValue is not null) or
   (value is not null ) Then
     dbms_lob.createtemporary(clobOut,true,dbms_lob.session);
     if (value is not null) then
         dbms_lob.write(clobOut ,length(value),1,value );
     elsif (clobValue is not null) then
         clobOut := clobValue;
     end if;
end if;
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
            ecx_debug.log(l_unexpected,'ECX', 'ECX_PROGRAM_ERROR',i_method_name,
	                 'PROGRESS_LEVEL',
                   'ECX_ACTIONS.GET_CLOB');
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_CLOB');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;
end;

procedure get_varchar(clobValue in clob , value in Varchar2 , valueOut out nocopy varchar2) as
i_method_name   varchar2(2000) := 'ecx_actions.get_varchar';
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if (value is not null) then
         valueOut := substr(value , 1, ecx_utils.G_VARCHAR_LEN);
elsif (clobValue is not null)  then
        valueOut := dbms_lob.substr(clobValue,ecx_utils.G_VARCHAR_LEN,1);
end if;
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
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.GET_VARCHAR');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_VARCHAR');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.PROGRAM_EXIT;

end;

procedure delete_doctype as
begin
	null;
end;

PROCEDURE get_xml_fragment
        ( proc_name IN varchar2,
          xml_fragment  OUT NOCOPY varchar2
        ) as
     i_method_name   varchar2(2000) := 'ecx_actions.get_xml_fragment';
     proc_call       varchar2(32767);
     temp_xml        varchar2(32767);
     temp_parser     xmlparser.parser;
     v_name          varchar2(32767);
     v_value         varchar2(32767);
BEGIN
     if (l_procedureEnabled) then
        ecx_debug.push(i_method_name);
     end if;


     -- Initialize the event if it is not already initialized.
     if (ecx_utils.g_event is null) then
        wf_event_t.initialize(ecx_utils.g_event);
     end if;

     -- Add all global variables as parameters to the event.
     for k in 1..ecx_utils.g_stack.count
     loop
        v_name  := ecx_utils.g_stack(k).variable_name;
        v_value := ecx_utils.g_stack(k).variable_value;
        ecx_utils.g_event.addparametertolist
                  ( v_name,
                    v_value);

      if(l_statementEnabled) then
           ecx_debug.log(l_statement,'global variable name',
                        ecx_utils.g_stack(k).variable_name,i_method_name);
           ecx_debug.log(l_statement,'global variable value',
                        ecx_utils.g_stack(k).variable_value,i_method_name);
      end if;
     end loop;
     -- Call the procedure. The procedure takes wf_event_t as
     -- input and gives out xml_fragment as output.

       proc_call := 'BEGIN ' || proc_name || ' (:EVENT,:XML_FRAGMENT);
       END;' ;

      execute immediate proc_call using in ecx_utils.g_event, out xml_fragment;

      if(l_statementEnabled) then
           ecx_debug.log(l_statement,'xml fragment',
                        xml_fragment,i_method_name);
      end if;

      -- Adding  dummy root element before parsing the xml fragment.

      temp_xml := '<dummy>'||xml_fragment||'</dummy>';
      temp_parser := xmlparser.newparser;
      xmlparser.parsebuffer(temp_parser,temp_xml);
      if (temp_parser.id not in (-1)) then
         xmlparser.freeparser(temp_parser);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
EXCEPTION
   when others then
     if (temp_parser.id not in (-1)) then
        xmlparser.freeparser(temp_parser);
     end if;
     if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL','ECX_ACTIONS.GET_XML_FRAGMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
     end if;
     ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_ACTIONS.GET_XML_FRAGMENT');
     if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
     end if;
     raise ecx_utils.PROGRAM_EXIT;
end;

end ecx_actions;

/
