--------------------------------------------------------
--  DDL for Package Body EC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_UTILS" as
-- $Header: ECUTILB.pls 120.2.12000000.2 2007/02/08 14:05:55 cpeixoto ship $

NEW_VARIABLE				CONSTANT 	pls_integer 	:=10;
ASSIGN_DEFAULT				CONSTANT	pls_integer 	:=20;
ASSIGN_PRE_DEFINED			CONSTANT	pls_integer	:=30;
ASSIGN_NEXTVALUE			CONSTANT	pls_integer	:=40;
IF_NULL_PRE_DEFINED			CONSTANT	pls_integer	:=50;
INCREMENT_ONE				CONSTANT	pls_integer	:=60;
IF_DEFAULT_PRE_DEFINED			CONSTANT	pls_integer	:=70;
CUSTOM_PROCEDURE			CONSTANT	pls_integer	:=80;
IF_NULL_DEFAULT				CONSTANT	pls_integer	:=90;
ASSIGN_FUNCVAL				CONSTANT	pls_integer	:=100;
MANDATORY_COLUMNS			CONSTANT	pls_integer	:=110;
IF_DIFF_PRE_NEXT_DEFAULT		CONSTANT	pls_integer  	:=120;
IF_NULL_SKIP_DOC			CONSTANT	pls_integer  	:=130;
IF_XNULL_SET_YDEFAULT			CONSTANT	pls_integer  	:=140;
IF_NOT_NULL_DEFINED			CONSTANT	pls_integer  	:=150;   /*Bug 1999536*/
APPEND_WHERECLAUSE                      CONSTANT        pls_integer  	:= 1000;
IF_NOTNULL_APPCLAUSE                    CONSTANT        pls_integer  	:= 1010;
BIND_VARIABLES                          CONSTANT        pls_integer  	:= 1030;
EXEC_PROCEDURES                         CONSTANT        pls_integer  	:= 1050;
IFXNULLEXEC_PROCEDURES                  CONSTANT        pls_integer  	:= 1080;
IFXNOTNULLEXEC_PROCEDURES               CONSTANT        pls_integer  	:= 1090;
IFXPREEXEC_PROCEDURES                   CONSTANT        pls_integer  	:= 1100;
IFXCONSTEXEC_PROCEDURES                 CONSTANT        pls_integer  	:= 1110;

/* Bug 2422787
i_tmp_stage_data	stage_data;---- Used for Stage 10 data only.
i_tmp2_stage_data	stage_data;---- used for Stages other than 10.
i_stage_data		stage_data;---- Temporary place holder for all Stages .
*/

function find_variable
        (
	i_variable_level		IN	NUMBER,
        i_variable_name           	IN      varchar2,
	i_stack_pos			OUT NOCOPY	NUMBER,
        i_plsql_pos                   	OUT NOCOPY	NUMBER
        ) return boolean
IS
cIn_String      varchar2(1000) := UPPER(i_variable_name);
bFound BOOLEAN 	:= FALSE;
hash_value              pls_integer;            -- Bug 2708573
hash_string             varchar2(3200);
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.FIND_VARIABLE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
end if;
/**
For a given Level , find out the Start and End Position of the Stack. use this range
to loop through the Stack.
**/
/* Bug 2708573
for k in g_stack_pointer(i_variable_level).start_pos..g_stack_pointer(i_variable_level).end_pos
loop
        	if upper(g_stack(k).VARIABLE_NAME) = cIn_String
        	then
               		i_stack_pos := k;
			i_plsql_pos := to_number(nvl(g_stack(k).variable_position,0));
               		bFound := TRUE;
               		exit;
        	end if;
end loop;
*/
	-- Bug 2708573
        hash_string:=to_char(i_variable_level) || '-' ||i_variable_name;
        hash_value:= dbms_utility.get_hash_value(hash_string,1,100000);
        if ec_utils.g_stack_pos_tbl.exists(hash_value) then
                i_stack_pos := ec_utils.g_stack_pos_tbl(hash_value);
                i_plsql_pos := to_number(nvl(g_stack(i_stack_pos).variable_position,0));
                bFound := TRUE;
        end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'i_stack_pos',i_stack_pos);
ec_debug.pl(3,'i_plsql_pos',i_plsql_pos);
ec_debug.pl(3,'bFound',bFound);
ec_debug.pop('EC_UTILS.FIND_VARIABLE');
end if;
return bFound;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.FIND_VARIABLE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code :=2;
	raise EC_UTILS.PROGRAM_EXIT;
END find_variable;

/**
Executes a select string and returns the First Column from the select
clause as OUT parameter.
**/
procedure execute_string
	(
	cString			in	varchar2,
	o_value			OUT  NOCOPY	varchar2
	)
is
cursor_handle	pls_integer;
ret_query	pls_integer;
m_value		varchar2(20000);
m_success	boolean;
error_position	pls_integer;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.EXECUTE_STRING');
ec_debug.pl(3,'cString',cString);
end if;

/*	cursor_handle := dbms_sql.open_cursor;

        BEGIN
		dbms_sql.parse(cursor_handle,cString,dbms_sql.native);
        EXCEPTION
        WHEN OTHERS THEN
                error_position := dbms_sql.last_error_position;
                ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXECUTE_STRING');
		ece_error_handling_pvt.print_parse_error (error_position,cString);

		if dbms_sql.is_open(cursor_handle)
		then
			dbms_sql.close_cursor(cursor_handle);
		end if;
                i_ret_code :=2;
                raise EC_UTILS.PROGRAM_EXIT;
        END;

	dbms_sql.define_column(cursor_handle,1,m_value,20000);
	ret_query := dbms_sql.execute_and_fetch(cursor_handle,m_success);
	dbms_sql.column_value(cursor_handle,1,m_value);
	dbms_sql.close_cursor(cursor_handle);
	o_value := m_value;
*/

/*Bug 1853627- Replaced the above dbms_sql with execute immediate statement */

	EXECUTE IMMEDIATE cString
	                 INTO o_value;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_value',o_value);
ec_debug.POP('EC_UTILS.EXECUTE_STRING');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
/*	if DBMS_SQL.IS_OPEN(cursor_handle) then
		dbms_sql.close_cursor(cursor_handle);
	end if;
*/
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXECUTE_STRING');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code :=2;
	raise EC_UTILS.PROGRAM_EXIT;
end execute_string;

procedure get_nextval_seq
	(
	i_seq_name		IN	VARCHAR2,
	o_value			OUT NOCOPY	varchar2
	)
is
cString		varchar2(2000);
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.GET_NEXTVAL_SEQ');
ec_debug.pl(3,'i_seq_name',i_seq_name);
end if;
	cString := 'select  '||i_seq_name||'.NEXTVAL  from dual';
	execute_string
		(
		cString,
		o_value
		);
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_value',o_value);
ec_debug.pop('EC_UTILS.GET_NEXTVAL_SEQ');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.GET_NEXTVAL_SEQ');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end get_nextval_seq;

/**
Returns the Function Value by building a select Clause for the
Function name.
**/
procedure get_function_value
	(
	i_function_name		IN	VARCHAR2,
	o_value			OUT NOCOPY	varchar2
	)
is
cString		varchar2(2000);
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.GET_FUNCTION_VALUE');
ec_debug.pl(3,'i_function_name',i_function_name);
end if;
	if i_function_name = 'SYSDATE'
	then
		cString := 'to_char(SYSDATE,''YYYYMMDD HH24MISS'')';
	else
		cString := i_function_name;
	end if;


	cString := 'select  '||cString||'  from dual';
	execute_string
		(
		cString,
		o_value
		);
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_value',o_value);
ec_debug.pop('EC_UTILS.GET_FUNCTION_VALUE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.GET_FUNCTION_VALUE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end get_function_value;

procedure dump_stack
is
m_count		pls_integer := g_stack.COUNT;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.DUMP_STACK');
ec_debug.pl(3,'EC','ECE_STACK_DUMP',null);
end if;

	for i in 1..m_count
	loop
         if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl
			(3,
			g_stack(i).level||' '||
			g_stack(i).variable_name||' ' ||
			g_stack(i).variable_position||' '||
			g_stack(i).variable_value||' '||
			g_stack(i).data_type
			);
         end if;
	end loop;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.POP('EC_UTILS.DUMP_STACK');
end if;
EXCEPTION
WHEN OTHERS then
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.DUMP_STACK');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end dump_stack;

procedure get_position_for_stack
	(
	i_level		IN	number
	)
is
i_first_found	BOOLEAN := FALSE;
i_last_found	BOOLEAN := FALSE;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.GET_POSITION_FOR_STACK');
ec_debug.pl(3,'i_level',i_level);
end if;

if ec_utils.g_stack.COUNT = 0
then
        if EC_DEBUG.G_debug_level >= 2 then
     	ec_debug.pop('EC_UTILS.GET_POSITION_FOR_STACK');
        end if;
	return;
end if;
	for i in 1..ec_utils.g_stack.COUNT
	loop
		if g_stack(i).level is null
		then
			ec_debug.pl(0,'EC','ECE_LEVEL_NULL','VARIABLE_NAME',ec_utils.g_stack(i).variable_name);
        		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.FIND_VARIABLE');
			i_ret_code :=2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		if g_stack(i).level = i_level
		then
			if NOT ( i_first_found )
			then
				i_first_found := TRUE;
				g_stack_pointer(i_level).start_pos := i;
			else
				if i < g_stack.COUNT
				then
					if g_stack(i).level <> g_stack(i+1).level
					then
						i_last_found := TRUE;
						g_stack_pointer(i_level).end_pos := i;
						exit;
					end if;
				elsif i = g_stack.COUNT
				then
					i_last_found := TRUE;
					g_stack_pointer(i_level).end_pos := i;
					exit;
				else
					null;
				end if;
			end if;
		end if;
	end loop;

	if ( i_first_found) and NOT (i_last_found)
	then
		g_stack_pointer(i_level).end_pos := g_stack_pointer(i_level).start_pos;
	end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'Stack Pointer('||i_level||') Start Position',g_stack_pointer(i_level).start_pos);
ec_debug.pl(3,'Stack Pointer('||i_level||') End Position',g_stack_pointer(i_level).end_pos);
ec_debug.pop('EC_UTILS.GET_POSITION_FOR_STACK');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.GET_POSITION_FOR_STACK');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end get_position_for_stack;
/**
Executes the Data from the ECE_TRAN_STAGE_DATA for a given Stage and Level.
**/
procedure 	execute_stage_data
	(
	i_stage		IN	number,
	i_level		IN	number
	)
is
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.EXECUTE_STAGE_DATA');
ec_debug.pl(3,'i_stage',i_stage);
ec_debug.pl(3,'i_level',i_level);
end if;
/* Bug 2708573
if i_stage = 10
then
	i_stage_data := i_tmp_stage_data;
else
	i_stage_data := i_tmp2_stage_data;
end if;
*/

FOR i in 1..i_stage_data.COUNT
loop
	if 	(
		i_stage_data(i).stage = i_stage
		and i_stage_data(i).level = i_level
		and i_stage_data(i).action_type <> 110
		)
	then
                if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,'i_transtage_id',i_stage_data(i).transtage_id);
		ec_debug.pl(3,'i_seq_number',i_stage_data(i).seq_number);
		ec_debug.pl(3,'i_action_type',i_stage_data(i).action_type);
		ec_debug.pl(3,'i_variable_level',i_stage_data(i).variable_level);
		ec_debug.pl(3,'i_variable_name',i_stage_data(i).variable_name);
		ec_debug.pl(3,'i_variable_value',i_stage_data(i).variable_value);
		ec_debug.pl(3,'i_default_value',i_stage_data(i).default_value);
		ec_debug.pl(3,'i_previous_variable_level',i_stage_data(i).previous_variable_level);
		ec_debug.pl(3,'i_previous_variable_name',i_stage_data(i).previous_variable_name);
		ec_debug.pl(3,'i_next_variable_name',i_stage_data(i).next_variable_name);
		ec_debug.pl(3,'i_sequence_name',i_stage_data(i).sequence_name);
		ec_debug.pl(3,'i_custom_procedure_name',i_stage_data(i).custom_procedure_name);
		ec_debug.pl(3,'i_data_type',i_stage_data(i).data_type);
		ec_debug.pl(3,'i_function_name',i_stage_data(i).function_name);
		ec_debug.pl(3,'i_where_clause',i_stage_data(i).clause);
                end if;
		if i_stage_data(i).action_type = NEW_VARIABLE
		then
			create_new_variable
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).variable_value,
				i_stage_data(i).data_type
				);

		elsif i_stage_data(i).action_type = ASSIGN_DEFAULT
		then
			assign_default_to_variables
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).default_value
				);
		elsif i_stage_data(i).action_type = ASSIGN_PRE_DEFINED
		then
			assign_pre_defined_variables
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).previous_variable_name
				);
		elsif i_stage_data(i).action_type = ASSIGN_NEXTVALUE
		then
			assign_nextval_from_sequence
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).sequence_name
				);
		elsif i_stage_data(i).action_type = ASSIGN_FUNCVAL
		then
			assign_function_value
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).function_name
				);
		elsif i_stage_data(i).action_type = INCREMENT_ONE
		then
			increment_by_one
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name
				);
		elsif i_stage_data(i).action_type = IF_NULL_PRE_DEFINED
		then
			if_null_pre_defined_variable
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).previous_variable_name
				);
		elsif i_stage_data(i).action_type = IF_DEFAULT_PRE_DEFINED
		then
			if_default_pre_defined_var
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).previous_variable_name,
				i_stage_data(i).default_value
				);
		elsif i_stage_data(i).action_type = CUSTOM_PROCEDURE
		then
                        execute_proc
                                (
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );

		elsif i_stage_data(i).action_type = IF_NULL_DEFAULT
		then
			if_null_equal_default_value
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).default_value
				);
		elsif i_stage_data(i).action_type = MANDATORY_COLUMNS
		then
			create_mandatory_columns
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).default_value,
				i_stage_data(i).data_type,
				i_stage_data(i).function_name
				);
		elsif i_stage_data(i).action_type = IF_DIFF_PRE_NEXT_DEFAULT
		then
			if_diff_pre_next_then_default
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).previous_variable_name,
				i_stage_data(i).next_variable_name,
				i_stage_data(i).default_value
				);
		elsif i_stage_data(i).action_type = IF_NULL_SKIP_DOC
		then
			if_null_skip_document
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name
				);
		elsif i_stage_data(i).action_type = IF_XNULL_SET_YDEFAULT
		then
			if_xnull_setydefault
				(
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
				i_stage_data(i).previous_variable_level,
				i_stage_data(i).previous_variable_name,
				i_stage_data(i).default_value
				);

               elsif i_stage_data(i).action_type = IF_NOT_NULL_DEFINED  /*Bug 1999536*/
                then
                       if_not_null_defined_variable
                                (
                                i_stage_data(i).variable_level,
                                i_stage_data(i).variable_name,
                                i_stage_data(i).previous_variable_level,
                                i_stage_data(i).previous_variable_name
                                );

    	  	elsif i_stage_data(i).action_type = APPEND_WHERECLAUSE
                then
                        append_clause
                                (
				i_stage_data(i).level,
                                i_stage_data(i).clause
                                );
		elsif i_stage_data(i).action_type = IF_NOTNULL_APPCLAUSE
                then
                        if_notnull_append_clause
                                (
				i_stage_data(i).level,
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
                                i_stage_data(i).clause
                                );
                elsif i_stage_data(i).action_type = BIND_VARIABLES
                then
                        bind_variables_for_view
                                (
                                i_stage_data(i).variable_name,
                                i_stage_data(i).previous_variable_level,
                                i_stage_data(i).previous_variable_name
                                );
                elsif i_stage_data(i).action_type = EXEC_PROCEDURES
                then
                        execute_proc
                                (
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );

                elsif i_stage_data(i).action_type = IFXNULLEXEC_PROCEDURES
                then
                        ifxnull_execute_proc
                                (
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );

                elsif i_stage_data(i).action_type = IFXNOTNULLEXEC_PROCEDURES
                then
                        ifxnotnull_execute_proc
                                (
				i_stage_data(i).variable_level,
				i_stage_data(i).variable_name,
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );
                elsif i_stage_data(i).action_type = IFXPREEXEC_PROCEDURES
                then
                        ifxpre_execute_proc
                                (
                                i_stage_data(i).variable_level,
                                i_stage_data(i).variable_name,
                                i_stage_data(i).previous_variable_level,
                                i_stage_data(i).previous_variable_name,
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );
                elsif i_stage_data(i).action_type = IFXCONSTEXEC_PROCEDURES
                then
                        ifxconst_execute_proc
                                (
                                i_stage_data(i).variable_level,
                                i_stage_data(i).variable_name,
				i_stage_data(i).default_value,
                                i_stage_data(i).transtage_id,
                                i_stage_data(i).custom_procedure_name
                                );
		end if;

	end if;
end loop;

/* Bug 1853627 - Added the following condition which suppress the call to the procedure
** dump_stack when the debug_mode is less than 2
*/

if (ec_debug.G_debug_level >=2) then
 dump_stack;
end if;
/**
If Stage = 10 , get the stack pointer location.
**/
if 	i_stage = 10 and
	i_level = 0
then
	if g_direction = 'I'
	then
		for i in 0..g_ext_levels.COUNT
		loop
			get_position_for_stack(i);
		end loop;
	else
		for i in 0..g_int_levels.COUNT
		loop
			get_position_for_stack(i);
		end loop;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.EXECUTE_STAGE_DATA');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXECUTE_STAGE_DATA');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end execute_stage_data;


/**
Retrieves the Data from the ECE_TRAN_STAGE_DATA for a given Stage and Level.
**/
procedure	get_tran_stage_data
	(
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number
	)
is
	cursor	stage_data
		(
		p_transaction_type	IN	varchar2,
		p_map_id		IN	number
		) is
	select	transtage_id,
		transaction_level,
		stage,
		seq_number,
		action_type,
		variable_level,
		upper(variable_name) variable_name,
		variable_value,
		default_value,
		previous_variable_level,
		upper(previous_variable_name) previous_variable_name,
		upper(next_variable_name) next_variable_name,
		upper(sequence_name) sequence_name,
		upper(custom_procedure_name) custom_procedure_name,
		data_type,
		upper(function_name) function_name,
		where_clause
	from	ece_tran_stage_data
	where	transaction_type = p_transaction_type
	and	map_id = p_map_id
	order by stage,transaction_level,seq_number;

i_counter 		pls_integer :=0;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.GET_TRAN_STAGE_DATA');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'EC','ECE_TRAN_STAGE_DATA','TRANSACTION_TYPE',i_transaction_type);
end if;

/* Bug 2019253 Clearing the Staging tables */

i_tmp_stage_data.DELETE;
i_tmp2_stage_data.DELETE;
i_stage_data.DELETE;

for get_stage_data in stage_data
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
	i_counter := g_stage_data.COUNT + 1;
	g_stage_data(i_counter).transtage_id := get_stage_data.transtage_id;
	g_stage_data(i_counter).level := get_stage_data.transaction_level;
	g_stage_data(i_counter).stage := get_stage_data.stage;
	g_stage_data(i_counter).seq_number := get_stage_data.seq_number;
	g_stage_data(i_counter).action_type := get_stage_data.action_type;
	g_stage_data(i_counter).variable_level := get_stage_data.variable_level;
	g_stage_data(i_counter).variable_name := get_stage_data.variable_name;
	g_stage_data(i_counter).variable_value := get_stage_data.variable_value;
	g_stage_data(i_counter).default_value := get_stage_data.default_value;
	g_stage_data(i_counter).previous_variable_level := get_stage_data.previous_variable_level;
	g_stage_data(i_counter).previous_variable_name := get_stage_data.previous_variable_name;
	g_stage_data(i_counter).next_variable_name := get_stage_data.next_variable_name;
	g_stage_data(i_counter).sequence_name := get_stage_data.sequence_name;
	g_stage_data(i_counter).custom_procedure_name := get_stage_data.custom_procedure_name;
	g_stage_data(i_counter).data_type := get_stage_data.data_type;
	g_stage_data(i_counter).function_name := get_stage_data.function_name;
	g_stage_data(i_counter).clause := get_stage_data.where_clause;
        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl
		(3,
		g_stage_data(i_counter).transtage_id||' '||
		g_stage_data(i_counter).level||' '||
		g_stage_data(i_counter).stage||' '||
		g_stage_data(i_counter).seq_number||' '||
		g_stage_data(i_counter).action_type||' '||
		g_stage_data(i_counter).variable_level||' '||
		g_stage_data(i_counter).variable_name||' '||
		g_stage_data(i_counter).variable_value||' '||
		g_stage_data(i_counter).default_value||' '||
		g_stage_data(i_counter).previous_variable_level||' '||
		g_stage_data(i_counter).previous_variable_name||' '||
		g_stage_data(i_counter).next_variable_name||' '||
		g_stage_data(i_counter).custom_procedure_name||' '||
		g_stage_data(i_counter).data_type||' '||
		g_stage_data(i_counter).function_name||' '||
		g_stage_data(i_counter).clause
		);
        end if;

end loop;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.GET_TRAN_STAGE_DATA');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.GET_TRAN_STAGE_DATA');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end get_tran_stage_data;

procedure sort_stage_data
is
j			pls_integer :=0;
k			pls_integer :=0;
l			pls_integer :=0;
i_tmp1_stage_data	ec_utils.stage_data;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.SORT_STAGE_DATA');
end if;
/**
Store the Stage 10 data in i_tmp1_stage_data tbl.
**/
for i in 1..g_stage_data.COUNT
loop
	if  g_stage_data(i).stage = 10
	then
		j := i_tmp1_stage_data.COUNT +1;
		i_tmp1_stage_data(j).transtage_id := g_stage_data(i).transtage_id;
		i_tmp1_stage_data(j).level := g_stage_data(i).level;
		i_tmp1_stage_data(j).stage := g_stage_data(i).stage;
		i_tmp1_stage_data(j).seq_number := g_stage_data(i).seq_number;
		i_tmp1_stage_data(j).action_type := g_stage_data(i).action_type;
		i_tmp1_stage_data(j).variable_level := g_stage_data(i).variable_level;
		i_tmp1_stage_data(j).variable_name := g_stage_data(i).variable_name;
		i_tmp1_stage_data(j).variable_value := g_stage_data(i).variable_value;
		i_tmp1_stage_data(j).default_value := g_stage_data(i).default_value;
		i_tmp1_stage_data(j).previous_variable_level := g_stage_data(i).previous_variable_level;
		i_tmp1_stage_data(j).previous_variable_name := g_stage_data(i).previous_variable_name;
		i_tmp1_stage_data(j).next_variable_name := g_stage_data(i).next_variable_name;
		i_tmp1_stage_data(j).sequence_name := g_stage_data(i).sequence_name;
		i_tmp1_stage_data(j).custom_procedure_name := g_stage_data(i).custom_procedure_name;
		i_tmp1_stage_data(j).data_type := g_stage_data(i).data_type;
		i_tmp1_stage_data(j).function_name := g_stage_data(i).function_name;
		i_tmp1_stage_data(j).clause := g_stage_data(i).clause;
	else
		k := i_tmp2_stage_data.COUNT +1;
		i_tmp2_stage_data(k).transtage_id := g_stage_data(i).transtage_id;
		i_tmp2_stage_data(k).level := g_stage_data(i).level;
		i_tmp2_stage_data(k).stage := g_stage_data(i).stage;
		i_tmp2_stage_data(k).seq_number := g_stage_data(i).seq_number;
		i_tmp2_stage_data(k).action_type := g_stage_data(i).action_type;
		i_tmp2_stage_data(k).variable_level := g_stage_data(i).variable_level;
		i_tmp2_stage_data(k).variable_name := g_stage_data(i).variable_name;
		i_tmp2_stage_data(k).variable_value := g_stage_data(i).variable_value;
		i_tmp2_stage_data(k).default_value := g_stage_data(i).default_value;
		i_tmp2_stage_data(k).previous_variable_level := g_stage_data(i).previous_variable_level;
		i_tmp2_stage_data(k).previous_variable_name := g_stage_data(i).previous_variable_name;
		i_tmp2_stage_data(k).next_variable_name := g_stage_data(i).next_variable_name;
		i_tmp2_stage_data(k).sequence_name := g_stage_data(i).sequence_name;
		i_tmp2_stage_data(k).custom_procedure_name := g_stage_data(i).custom_procedure_name;
		i_tmp2_stage_data(k).data_type := g_stage_data(i).data_type;
		i_tmp2_stage_data(k).function_name := g_stage_data(i).function_name;
		i_tmp2_stage_data(k).clause := g_stage_data(i).clause;
	end if;
end loop;
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'Separation of Data into Stage 10 and rest done. Sorting to proceed');
end if;

/**
Depending on Inbound or Outbound transaction sort the
Stage 10 data based on variable_level.If direction not set then
default to Internal representation.
**/
if g_direction = 'I'
then
	/**
	Sorts only entries with Action Type = 10 i.e. Create_new_variable
	**/
	for j in 0..g_ext_levels.COUNT
	loop
		for k in 1..i_tmp1_stage_data.COUNT
		loop
			if 	(
				i_tmp1_stage_data(k).action_type = 10 and
				i_tmp1_stage_data(k).variable_level = j
				)
			then
			l := i_tmp_stage_data.COUNT +1;
			i_tmp_stage_data(l).transtage_id := i_tmp1_stage_data(k).transtage_id;
			i_tmp_stage_data(l).level := i_tmp1_stage_data(k).level;
			i_tmp_stage_data(l).stage := i_tmp1_stage_data(k).stage;
			i_tmp_stage_data(l).seq_number := i_tmp1_stage_data(k).seq_number;
			i_tmp_stage_data(l).action_type := i_tmp1_stage_data(k).action_type;
			i_tmp_stage_data(l).variable_level := i_tmp1_stage_data(k).variable_level;
			i_tmp_stage_data(l).variable_name := i_tmp1_stage_data(k).variable_name;
			i_tmp_stage_data(l).variable_value := i_tmp1_stage_data(k).variable_value;
			i_tmp_stage_data(l).default_value := i_tmp1_stage_data(k).default_value;
			i_tmp_stage_data(l).previous_variable_level := i_tmp1_stage_data(k).previous_variable_level;
			i_tmp_stage_data(l).previous_variable_name := i_tmp1_stage_data(k).previous_variable_name;
			i_tmp_stage_data(l).next_variable_name := i_tmp1_stage_data(k).next_variable_name;
			i_tmp_stage_data(l).sequence_name := i_tmp1_stage_data(k).sequence_name;
			i_tmp_stage_data(l).custom_procedure_name := i_tmp1_stage_data(k).custom_procedure_name;
			i_tmp_stage_data(l).data_type := i_tmp1_stage_data(k).data_type;
			i_tmp_stage_data(l).function_name := i_tmp1_stage_data(k).function_name;
			i_tmp_stage_data(l).clause := i_tmp1_stage_data(k).clause;
			end if;
		end loop;
	end loop;
	/**
	Put all other action Types .
	**/
		for k in 1..i_tmp1_stage_data.COUNT
		loop
			if 	i_tmp1_stage_data(k).action_type <> 10
			then
			l := i_tmp_stage_data.COUNT +1;
			i_tmp_stage_data(l).transtage_id := i_tmp1_stage_data(k).transtage_id;
			i_tmp_stage_data(l).level := i_tmp1_stage_data(k).level;
			i_tmp_stage_data(l).stage := i_tmp1_stage_data(k).stage;
			i_tmp_stage_data(l).seq_number := i_tmp1_stage_data(k).seq_number;
			i_tmp_stage_data(l).action_type := i_tmp1_stage_data(k).action_type;
			i_tmp_stage_data(l).variable_level := i_tmp1_stage_data(k).variable_level;
			i_tmp_stage_data(l).variable_name := i_tmp1_stage_data(k).variable_name;
			i_tmp_stage_data(l).variable_value := i_tmp1_stage_data(k).variable_value;
			i_tmp_stage_data(l).default_value := i_tmp1_stage_data(k).default_value;
			i_tmp_stage_data(l).previous_variable_level := i_tmp1_stage_data(k).previous_variable_level;
			i_tmp_stage_data(l).previous_variable_name := i_tmp1_stage_data(k).previous_variable_name;
			i_tmp_stage_data(l).next_variable_name := i_tmp1_stage_data(k).next_variable_name;
			i_tmp_stage_data(l).sequence_name := i_tmp1_stage_data(k).sequence_name;
			i_tmp_stage_data(l).custom_procedure_name := i_tmp1_stage_data(k).custom_procedure_name;
			i_tmp_stage_data(l).data_type := i_tmp1_stage_data(k).data_type;
			i_tmp_stage_data(l).function_name := i_tmp1_stage_data(k).function_name;
			i_tmp_stage_data(l).clause := i_tmp1_stage_data(k).clause;
			end if;
		end loop;
else
	for j in 0..g_int_levels.COUNT
	loop
		for k in 1..i_tmp1_stage_data.COUNT
		loop
			if 	(
				i_tmp1_stage_data(k).action_type = 10 and
				i_tmp1_stage_data(k).variable_level = j
				)
			then
			l := i_tmp_stage_data.COUNT + 1;
			i_tmp_stage_data(l).transtage_id := i_tmp1_stage_data(k).transtage_id;
			i_tmp_stage_data(l).level := i_tmp1_stage_data(k).level;
			i_tmp_stage_data(l).stage := i_tmp1_stage_data(k).stage;
			i_tmp_stage_data(l).seq_number := i_tmp1_stage_data(k).seq_number;
			i_tmp_stage_data(l).action_type := i_tmp1_stage_data(k).action_type;
			i_tmp_stage_data(l).variable_level := i_tmp1_stage_data(k).variable_level;
			i_tmp_stage_data(l).variable_name := i_tmp1_stage_data(k).variable_name;
			i_tmp_stage_data(l).variable_value := i_tmp1_stage_data(k).variable_value;
			i_tmp_stage_data(l).default_value := i_tmp1_stage_data(k).default_value;
			i_tmp_stage_data(l).previous_variable_level := i_tmp1_stage_data(k).previous_variable_level;
			i_tmp_stage_data(l).previous_variable_name := i_tmp1_stage_data(k).previous_variable_name;
			i_tmp_stage_data(l).next_variable_name := i_tmp1_stage_data(k).next_variable_name;
			i_tmp_stage_data(l).sequence_name := i_tmp1_stage_data(k).sequence_name;
			i_tmp_stage_data(l).custom_procedure_name := i_tmp1_stage_data(k).custom_procedure_name;
			i_tmp_stage_data(l).data_type := i_tmp1_stage_data(k).data_type;
			i_tmp_stage_data(l).function_name := i_tmp1_stage_data(k).function_name;
			i_tmp_stage_data(l).clause := i_tmp1_stage_data(k).clause;
			end if;
		end loop;
	end loop;
	/**
	Put the rest of the Data now
	**/
		for k in 1..i_tmp1_stage_data.COUNT
		loop
			if 	i_tmp1_stage_data(k).action_type <> 10
			then
			l := i_tmp_stage_data.COUNT + 1;
			i_tmp_stage_data(l).transtage_id := i_tmp1_stage_data(k).transtage_id;
			i_tmp_stage_data(l).level := i_tmp1_stage_data(k).level;
			i_tmp_stage_data(l).stage := i_tmp1_stage_data(k).stage;
			i_tmp_stage_data(l).seq_number := i_tmp1_stage_data(k).seq_number;
			i_tmp_stage_data(l).action_type := i_tmp1_stage_data(k).action_type;
			i_tmp_stage_data(l).variable_level := i_tmp1_stage_data(k).variable_level;
			i_tmp_stage_data(l).variable_name := i_tmp1_stage_data(k).variable_name;
			i_tmp_stage_data(l).variable_value := i_tmp1_stage_data(k).variable_value;
			i_tmp_stage_data(l).default_value := i_tmp1_stage_data(k).default_value;
			i_tmp_stage_data(l).previous_variable_level := i_tmp1_stage_data(k).previous_variable_level;
			i_tmp_stage_data(l).previous_variable_name := i_tmp1_stage_data(k).previous_variable_name;
			i_tmp_stage_data(l).next_variable_name := i_tmp1_stage_data(k).next_variable_name;
			i_tmp_stage_data(l).sequence_name := i_tmp1_stage_data(k).sequence_name;
			i_tmp_stage_data(l).custom_procedure_name := i_tmp1_stage_data(k).custom_procedure_name;
			i_tmp_stage_data(l).data_type := i_tmp1_stage_data(k).data_type;
			i_tmp_stage_data(l).function_name := i_tmp1_stage_data(k).function_name;
			i_tmp_stage_data(l).clause := i_tmp1_stage_data(k).clause;
			end if;
		end loop;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'Stage 10 data after sorting is as follows :');
for i in 1..i_tmp_stage_data.COUNT
loop
	ec_debug.pl
		(3,
		i_tmp_stage_data(i).transtage_id||' '||
		i_tmp_stage_data(i).level||' '||
		i_tmp_stage_data(i).stage||' '||
		i_tmp_stage_data(i).seq_number||' '||
		i_tmp_stage_data(i).action_type||' '||
		i_tmp_stage_data(i).variable_level||' '||
		i_tmp_stage_data(i).variable_name||' '||
		i_tmp_stage_data(i).variable_value||' '||
		i_tmp_stage_data(i).default_value||' '||
		i_tmp_stage_data(i).previous_variable_level||' '||
		i_tmp_stage_data(i).previous_variable_name||' '||
		i_tmp_stage_data(i).next_variable_name||' '||
		i_tmp_stage_data(i).custom_procedure_name||' '||
		i_tmp_stage_data(i).data_type||' '||
		i_tmp_stage_data(i).function_name||' '||
		i_tmp_stage_data(i).clause
		);
end loop;
ec_debug.pl(3,'Data for Stages other then 10 is as follows :');
for i in 1..i_tmp2_stage_data.COUNT
loop
        ec_debug.pl
		(3,
		i_tmp2_stage_data(i).transtage_id||' '||
		i_tmp2_stage_data(i).level||' '||
		i_tmp2_stage_data(i).stage||' '||
		i_tmp2_stage_data(i).seq_number||' '||
		i_tmp2_stage_data(i).action_type||' '||
		i_tmp2_stage_data(i).variable_level||' '||
		i_tmp2_stage_data(i).variable_name||' '||
		i_tmp2_stage_data(i).variable_value||' '||
		i_tmp2_stage_data(i).default_value||' '||
		i_tmp2_stage_data(i).previous_variable_level||' '||
		i_tmp2_stage_data(i).previous_variable_name||' '||
		i_tmp2_stage_data(i).next_variable_name||' '||
		i_tmp2_stage_data(i).custom_procedure_name||' '||
		i_tmp2_stage_data(i).data_type||' '||
		i_tmp2_stage_data(i).function_name||' '||
		i_tmp2_stage_data(i).clause
		);
end loop;
ec_debug.POP('EC_UTILS.SORT_STAGE_DATA');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.SORT_STAGE_DATA');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end sort_stage_data;

procedure find_pos
        (
	i_level			IN	number,
        i_search_text           IN      varchar2,
        o_pos                   OUT NOCOPY  	NUMBER,
	i_required		IN	BOOLEAN DEFAULT TRUE
        )
IS
        cIn_String      varchar2(1000) := UPPER(i_search_text);
        bFound BOOLEAN := FALSE;
        POS_NOT_FOUND   EXCEPTION;
        hash_value      pls_integer;		-- Bug 2617428
        hash_string     varchar2(3200);
        tbl_pos         pls_integer;

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.FIND_POS');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_search_text',i_search_text);
end if;

if g_direction = 'I'
then
	/* Bug 2617428
	for i in g_ext_levels(i_level).file_start_pos..g_ext_levels(i_level).file_end_pos
	loop
        	if upper(g_file_tbl(i).interface_column_name) = cIn_String
        	then
               		o_pos := i;
               		bFound := TRUE;
               		exit;
        	end if;
	end loop;
	*/
	-- Bug 2617428
	hash_string:=to_char(i_level) || '-' ||cIn_String;
        hash_value:= dbms_utility.get_hash_value(hash_string,1,8192);
        if ec_utils.g_col_pos_tbl_1.exists(hash_value) then
           if ec_utils.g_col_pos_tbl_1(hash_value).occr = 1 then
                o_pos := ec_utils.g_col_pos_tbl_1(hash_value).value;
                bFound := TRUE;
           else
		-- Bug 2834366
		-- Added the following to prevent hash collision.
                tbl_pos :=  ec_utils.g_col_pos_tbl_1(hash_value).start_pos;
                while tbl_pos<=ec_utils.g_col_pos_tbl_2.LAST
                loop
                      if ec_utils.g_col_pos_tbl_2(tbl_pos) = hash_value then
                         if upper(g_file_tbl(tbl_pos).interface_column_name) = cIn_String and
                           g_file_tbl(tbl_pos).external_level=i_level then
                                 o_pos := tbl_pos;
                                bFound := TRUE;
                                exit;
                         end if;
                      end if;
                      tbl_pos:=ec_utils.g_col_pos_tbl_2.NEXT(tbl_pos);
                end loop;
           end if;
        end if;
else
	for i in g_int_levels(i_level).file_start_pos..g_int_levels(i_level).file_end_pos
	loop
        	if upper(g_file_tbl(i).interface_column_name) = cIn_String
        	then
                	o_pos := i;
                	bFound := TRUE;
                	exit;
        	end if;
	end loop;
end if;

if not bFound
then
	if (i_required)
	then
		raise POS_NOT_FOUND;
	else
		o_pos := NULL;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_pos',o_pos);
ec_debug.POP('EC_UTILS.FIND_POS');
end if;
EXCEPTION
WHEN POS_NOT_FOUND THEN
	ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_String);
        ec_debug.POP('EC_UTILS.FIND_POS');
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.FIND_POS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END find_pos;

/**
Overloaded Function to search for a column on the Pl/SQL table , from a Given level to
an Lower Level.
**/
procedure find_pos
        (
	i_from_level			IN	number,
	i_to_level			IN	number,
        i_search_text           	IN      varchar2,
        o_pos                   	OUT NOCOPY  	NUMBER,
	i_required			IN	BOOLEAN DEFAULT TRUE
        )
IS
        cIn_String      varchar2(1000) := UPPER(i_search_text);
        nColumn_count   pls_integer := g_file_tbl.COUNT;
        bFound BOOLEAN := FALSE;
        POS_NOT_FOUND   EXCEPTION;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.FIND_POS');
ec_debug.pl(3,'i_from_level',i_from_level);
ec_debug.pl(3,'i_to_level',i_to_level);
ec_debug.pl(3,'i_search_text',i_search_text);
ec_debug.pl(3,'i_required',i_required);
end if;
for j in i_from_level..i_to_level
loop
	for k in 1..nColumn_count
	loop
		if g_file_tbl(k).interface_level = j
		then
        		if upper(g_file_tbl(k).interface_column_name) = cIn_String
        		then
                		o_pos := k;
                		bFound := TRUE;
                		exit;
        		end if;
		end if;
	end loop;

	if ( bfound)
	then
		exit;
	end if;
end loop;

if not bFound
then
	if (i_required)
	then
		raise POS_NOT_FOUND;
	else
		o_pos := NULL;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'o_pos',o_pos);
ec_debug.POP('EC_UTILS.FIND_POS');
end if;
EXCEPTION
WHEN POS_NOT_FOUND THEN
	ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_String);
        ec_debug.POP('EC_UTILS.FIND_POS');
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.FIND_POS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END find_pos;

/**
Creates a variable passed as i_variable_name on the Stack for a given Level.
If the variable level <> 0 , then it means that the variable is to be searched
on the PL/SQL mapping table. The position and the Value from the PL/SQL mapping
table is maintained on the Stack table to avoid un-necessary search.
i.e.	i := 5;
**/
procedure create_new_variable
		(
		i_variable_level	IN	NUMBER,
		i_variable_name		IN	VARCHAR2,
		i_variable_value	IN	varchar2,
		i_data_type		IN	varchar2 default NULL
		)
is
m_count			pls_integer	:= g_stack.COUNT;
current_on_stack	BOOLEAN := FALSE;
i_stack_pos		pls_integer;
i_interface_pos		pls_integer;
i_pre_interface_pos	pls_integer;
hash_value              pls_integer;            -- Bug 2708573
hash_string             varchar2(3200);
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.CREATE_NEW_VARIABLE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_variable_value',i_variable_value);
end if;
		current_on_stack := find_variable
				(
				i_variable_level,
				i_variable_name,
				i_stack_pos,
				i_interface_pos
				);

	if ( current_on_stack )
	then
		/* Bug 2708573
		ec_debug.pl(0,'EC','ECE_DUPLICATE_VARIABLE_STACK','VARIABLE_NAME',i_variable_name);
		i_ret_code := 2;
		raise EC_UTILS.PROGRAM_EXIT;
		*/
		-- Bug 2708573
		if i_variable_level = 0 and g_stack(i_stack_pos).variable_value is null
                then
                    g_stack(i_stack_pos).variable_value := i_variable_value;
                end if;
                if EC_DEBUG.G_debug_level >= 3 then
		  ec_debug.pl(3,'Variable already on Stack');
		  ec_debug.pl(3,i_variable_name,i_variable_value);
                end if;

	else
			if i_variable_level = 0
			then
				m_count := m_count + 1;
				g_stack(m_count).level := i_variable_level;
				g_stack(m_count).variable_name := i_variable_name;
				g_stack(m_count).variable_value := i_variable_value;
				g_stack(m_count).data_type := i_data_type;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,i_variable_value);
                                end if;
			else
				FIND_POS
					(
					i_variable_level,
					i_variable_name,
					i_pre_interface_pos
					);

				m_count := m_count + 1;
				g_stack(m_count).level := i_variable_level;
				g_stack(m_count).variable_name := i_variable_name;
				g_stack(m_count).variable_position := i_pre_interface_pos;
				g_stack(m_count).data_type := i_data_type;
				g_file_tbl(i_pre_interface_pos).value := i_variable_value;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_file_tbl(i_pre_interface_pos).value);
                                end if;
			end if;
			-- Bug 2708573
			-- Populate Hash table for searching the g_stack
			hash_string := to_char(i_variable_level)||'-'||i_variable_name ;
                        hash_value  := dbms_utility.get_hash_value(hash_string,1,100000);
                        ec_utils.g_stack_pos_tbl(hash_value):=m_count;

	end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.CREATE_NEW_VARIABLE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.CREATE_NEW_VARIABLE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end create_new_variable;

/**
if x is null then set y := default value
i.e. 	i := j;
**/
procedure IF_XNULL_SETYDEFAULT
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2,
	i_default_value				IN	varchar2
	)
is

var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_XNULL_SETYDEFAULT');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
end if;
		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
	if g_stack(o_stack_pos).variable_value is NULL
	then
		if i_previous_variable_level = 0
		then
			g_stack(o_stack_pre_pos).variable_value
				:= i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_previous_variable_name,g_stack(o_stack_pre_pos).variable_value);
                        end if;
		else
			g_file_tbl(o_plsql_pre_pos).value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pre_pos).value);
                        end if;
		end if;
	end if;
else
	if g_file_tbl(o_plsql_pos).value is NULL
	then
		if i_previous_variable_level = 0
		then
			g_stack(o_stack_pre_pos).variable_value
				:= i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_previous_variable_name,g_stack(o_stack_pre_pos).variable_value);
                        end if;
		else
			g_file_tbl(o_plsql_pre_pos).value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pre_pos).value);
                        end if;
		end if;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_XNULL_SETYDEFAULT');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_XNULL_SETYDEFAULT');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END IF_XNULL_SETYDEFAULT;

/**
Assigns the Value from a Previously Defined Variable
i.e. 	i := j;
**/
procedure assign_pre_defined_variables
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2
	)
is

var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.ASSIGN_PRE_DEFINED_VARIABLES');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
end if;
		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
		if i_previous_variable_level = 0
		then
			g_stack(o_stack_pos).variable_value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		else
			g_stack(o_stack_pos).variable_value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		end if;
else
		if i_previous_variable_level = 0
		then
			g_file_tbl(o_plsql_pos).value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		else
			g_file_tbl(o_plsql_pos).value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.ASSIGN_PRE_DEFINED_VARIABLES');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.ASSIGN_PRE_DEFINED_VARIABLES');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END assign_pre_defined_variables;


/**
Assign Default Value to a Variable.
i.e.	i := 5;
**/
procedure assign_default_to_variables
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_default_value		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.ASSIGN_DEFAULT_TO_VARIABLES');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
end if;

		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
			if i_variable_level = 0
			then
				g_stack(o_stack_pos).variable_value := i_default_value;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                                end if;
			else
				g_file_tbl(o_plsql_pos).value := i_default_value;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                                end if;
			end if;
		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.ASSIGN_DEFAULT_TO_VARIABLES');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.ASSIGN_DEFAULT_TO_VARIABLES');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END assign_default_to_variables;

/**
If the Variable is null then assign the Default Value.
i.e.	if i is NULL
	then
		i := 5;
	end if;
**/
procedure if_null_equal_default_value
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_default_value		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_NULL_EQUAL_DEFAULT_VALUE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
end if;

		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
			if i_variable_level = 0
			then
				if g_stack(o_stack_pos).variable_value is NULL
				then
					g_stack(o_stack_pos).variable_value := i_default_value;
                                        if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                                        end if;
				end if;
			else
				if g_file_tbl(o_plsql_pos).value is NULL
				then
					g_file_tbl(o_plsql_pos).value := i_default_value;
                                        if EC_DEBUG.G_debug_level >= 3 then
					ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                                        end if;
				end if;
			end if;
		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_NULL_EQUAL_DEFAULT_VALUE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_NULL_EQUAL_DEFAULT_VALUE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END if_null_equal_default_value;

/**
If the Value of the Variable is Null then assign
the Value of a previously defined variable.
i.e.	If i is NULL
	then
		i := j;
	end if;
**/
procedure if_null_pre_defined_variable
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2
	)
is

var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_NULL_PRE_DEFINED_VARIABLE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
end if;

		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
	if g_stack(o_stack_pos).variable_value is NULL
	then
		if i_previous_variable_level = 0
		then
			g_stack(o_stack_pos).variable_value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		else
			g_stack(o_stack_pos).variable_value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		end if;
	end if;
else
	if g_file_tbl(o_plsql_pos).value is NULL
	then
		if i_previous_variable_level = 0
		then
			g_file_tbl(o_plsql_pos).value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		else
			g_file_tbl(o_plsql_pos).value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		end if;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_NULL_PRE_DEFINED_VARIABLE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_NULL_PRE_DEFINED_VARIABLE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END if_null_pre_defined_variable;

/**
If the Value of the Variable is not Null then assign
the Value of the Variable to previously defined variable.
i.e.    If b is not NULL             b -> Variable at current Level
        then                         a -> Variable at Previous Level
                a := b;
        end if;
**/

/* Bug 1999536*/
procedure if_not_null_defined_variable
        (
        i_variable_level                        IN      number,
        i_variable_name                         IN      varchar2,
        i_previous_variable_level               IN      number,
        i_previous_variable_name                IN      varchar2
        )
is

var_present             BOOLEAN := FALSE;
pre_var_present         BOOLEAN := FALSE;
o_stack_pos             pls_integer;
o_stack_pre_pos         pls_integer;
o_plsql_pos             pls_integer;
o_plsql_pre_pos         pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_NOT_NULL_DEFINED_VARIABLE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
end if;

                var_present     :=find_variable
                                        (
                                        i_variable_level,
                                        i_variable_name,
                                        o_stack_pos,
                                        o_plsql_pos
                                        );
   if NOT ( var_present)
   then
   ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
   i_ret_code := 2;
   raise EC_UTILS.PROGRAM_EXIT;
   end if;

                pre_var_present := find_variable
                                (
                                i_previous_variable_level,
                                i_previous_variable_name,
                                o_stack_pre_pos,
                                o_plsql_pre_pos
                                );

                if NOT ( pre_var_present)
                then
ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_previous_variable_name);
i_ret_code := 2;
raise EC_UTILS.PROGRAM_EXIT;
end if;

if i_variable_level = 0  /* My current Variable Level is 0 */
then
        if g_stack(o_stack_pos).variable_value is NOT NULL
        then
                if i_previous_variable_level = 0
                then
                 g_stack(o_stack_pre_pos).variable_value
                    := g_stack(o_stack_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
                        ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
                else
                       g_file_tbl(o_plsql_pre_pos).value
                             := g_stack(o_stack_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
                        ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
                end if;
        end if;
else     /* My current Variable Level is not 0 */
        if g_file_tbl(o_plsql_pos).value is NOT NULL
        then
                if i_previous_variable_level = 0
                then
                        g_stack(o_stack_pre_pos).variable_value
                              := g_file_tbl(o_plsql_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
                        ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
                else
                        g_file_tbl(o_plsql_pre_pos).value
                                 := g_file_tbl(o_plsql_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
                        ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
                end if;
        end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_NOT_NULL_DEFINED_VARIABLE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_NOT_NULL_DEFINED_VARIABLE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
END if_not_null_defined_variable;  /* Bug 1999536*/

/**
If the Variable is different from Previous variable Value and the
Next variable Value , then Assign Default.
e.g. 	If i <> x AND i <> y
	then
		i = 10;
	end if;
**/
procedure if_diff_pre_next_then_default
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2,
	i_next_variable_name			IN	varchar2,
	i_default_value				IN	varchar2
	)
is

var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
next_var_present	BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_stack_next_pos	pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
o_plsql_next_pos	pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_DIFF_PRE_NEXT_THEN_DEFAULT');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
ec_debug.pl(3,'i_next_variable_name',i_next_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
end if;
		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		next_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_next_variable_name,
				o_stack_next_pos,
				o_plsql_next_pos
				);

		if NOT ( next_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_next_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
	if i_previous_variable_level = 0
	then
		if g_stack(o_stack_pos).variable_value <>
				g_stack(o_stack_pre_pos).variable_value and
			g_stack(o_stack_pos).variable_value <>
				g_stack(o_stack_next_pos).variable_value
		then
			g_stack(o_stack_pos).variable_value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		end if;
	else
		if g_stack(o_stack_pos).variable_value <>
				g_file_tbl(o_plsql_pre_pos).value and
			g_stack(o_stack_pos).variable_value <>
				g_file_tbl(o_plsql_next_pos).value
		then
			g_stack(o_stack_pos).variable_value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		end if;
	end if;

else
	if i_previous_variable_level = 0
	then
		if g_file_tbl(o_plsql_pos).value <>
				g_stack(o_stack_pre_pos).variable_value and
		g_file_tbl(o_plsql_pos).value <>
			g_stack(o_stack_next_pos).variable_value
		then
			g_file_tbl(o_plsql_pos).value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		end if;
	else
		if g_file_tbl(o_plsql_pos).value <>
				g_file_tbl(o_plsql_pre_pos).value and
		g_file_tbl(o_plsql_pos).value <>
				g_file_tbl(o_plsql_next_pos).value
		then
			g_file_tbl(o_plsql_pos).value := i_default_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		end if;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_DIFF_PRE_NEXT_THEN_DEFAULT');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_DIFF_PRE_NEXT_THEN_DEFAULT');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end if_diff_pre_next_then_default;

/**
If the Variable is equal to Default value then assign the value of a
previously defined variable.
e.g.	if x = 1000
	then
		x = y;
	end if;
**/
procedure if_default_pre_defined_var
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2,
	i_default_value				IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_DEFAULT_PRE_DEFINED_VAR');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
end if;

		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
				'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
	if g_stack(o_stack_pos).variable_value = i_default_value
	then
		if i_previous_variable_level = 0
		then
			g_stack(o_stack_pos).variable_value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		else
			g_stack(o_stack_pos).variable_value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                        end if;
		end if;
	end if;
else
	if g_file_tbl(o_plsql_pos).value = i_default_value
	then
		if i_previous_variable_level = 0
		then
			g_file_tbl(o_plsql_pos).value
				:= g_stack(o_stack_pre_pos).variable_value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		else
			g_file_tbl(o_plsql_pos).value
				:= g_file_tbl(o_plsql_pre_pos).value;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                        end if;
		end if;
	end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_DEFAULT_PRE_DEFINED_VAR');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_DEFAULT_PRE_DEFINED_VAR');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END if_default_pre_defined_var;

/**
Assign the Nextvalue from a sequence.
e.g.	x := document.NEXTVAL;
**/
procedure assign_nextval_from_sequence
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_sequence_name		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.ASSIGN_NEXTVAL_FROM_SEQUENCE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_sequence_name',i_sequence_name);
end if;
		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
			if i_variable_level = 0
			then
				get_nextval_seq
					(
					i_sequence_name,
					g_stack(o_stack_pos).variable_value
					);
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                                end if;
			else
				get_nextval_seq
					(
					i_sequence_name,
					g_file_tbl(o_plsql_pos).value
					);
				ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
			end if;
		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.ASSIGN_NEXTVAL_FROM_SEQUENCE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.ASSIGN_NEXTVAL_FROM_SEQUENCE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END assign_nextval_from_sequence;

/**
Assigns the value returned by a function.
e.g.	x := fnd_global.sysdate;
**/
procedure assign_function_value
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2,
	i_function_name		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.ASSIGN_FUNCTION_VALUE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_function_name',i_function_name);
end if;

		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
			if i_variable_level = 0
			then
				get_function_value
					(
					i_function_name,
					g_stack(o_stack_pos).variable_value
					);
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                                end if;
			else
				get_function_value
					(
					i_function_name,
					g_file_tbl(o_plsql_pos).value
					);
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                                end if;
			end if;
		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.ASSIGN_FUNCTION_VALUE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.ASSIGN_FUNCTION_VALUE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END assign_function_value;

/**
If the value of the variable is null then skip the Document.
e.g. 	If Purchase_Order_Num is null
	then
		skip Document;
	end if;
**/
procedure if_null_skip_document
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_NULL_SKIP_DOCUMENT');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
end if;

		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if NOT ( var_present )
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		if i_variable_level = 0
		then
			if g_stack(o_stack_pos).variable_value is null
			then
				ec_debug.pl(0,'EC','ECE_MANDATORY_NULL','VARIABLE_NAME',i_variable_name);
				g_ext_levels(g_current_level).Status := 'SKIP_DOCUMENT';
				i_ret_code :=1;
			end if;
		else
			if g_file_tbl(o_plsql_pos).value is null
			then
				ec_debug.pl(0,'EC','ECE_MANDATORY_NULL','VARIABLE_NAME',i_variable_name);
				g_ext_levels(g_current_level).Status := 'SKIP_DOCUMENT';
				i_ret_code :=1;
			end if;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_NULL_SKIP_DOCUMENT');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_NULL_SKIP_DOCUMENT');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END if_null_skip_document;

/**
Increment the value of the variable by 1.
e.g.	i := i + 1;
**/
procedure increment_by_one
	(
	i_variable_level	IN	number,
	i_variable_name		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.INCREMENT_BY_ONE');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
end if;
		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
			if i_variable_level = 0
			then
				g_stack(o_stack_pos).variable_value
					:= g_stack(o_stack_pos).variable_value + 1;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_stack(o_stack_pos).variable_value);
                                end if;
			else
				g_file_tbl(o_plsql_pos).value
					:= g_file_tbl(o_plsql_pos).value + 1;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,i_variable_name,g_file_tbl(o_plsql_pos).value);
                                end if;
			end if;
		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.INCREMENT_BY_ONE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.INCREMENT_BY_ONE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END increment_by_one;

/**
Creates the Columns in the PL/SQL table required by the Open Interface Tables but are not
present on the Spreasheet. If the Function is defined , then it assigns
the value of the Function or assigns the Default Value.
e.g.	CREATION_DATE := FND_GLOBAL.SYSDATE;
**/

procedure create_mandatory_columns
	(
	i_variable_level		IN	number,
	i_previous_variable_level	IN	number,
	i_variable_name			IN	varchar2,
	i_default_value			IN	varchar2,
	i_data_type			IN	varchar2,
	i_function_name			IN	varchar2
	)
is
m_count			pls_integer :=g_file_tbl.COUNT;
hash_val                pls_integer;     -- 2996147
hash_string             varchar2(3200);
p_count                 pls_integer :=0; -- 2996147
BEGIN
if EC_DEBUG.G_debug_level >=  2 then
ec_debug.push('EC_UTILS.CREATE_MANDATORY_COLUMNS');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
ec_debug.pl(3,'i_data_type',i_data_type);
ec_debug.pl(3,'i_function_name',i_function_name);
end if;
	m_count := m_count + 1;
	g_file_tbl(m_count).interface_level := i_variable_level;
	g_file_tbl(m_count).external_level := i_previous_variable_level;
	g_file_tbl(m_count).base_column_name := upper(i_variable_name);
	g_file_tbl(m_count).interface_column_name := upper(i_variable_name);
	g_file_tbl(m_count).data_type := upper(i_data_type);
	g_file_tbl(m_count).value := i_default_value;

	if i_previous_variable_level is null
	then
		g_file_tbl(m_count).external_level := i_variable_level;
	end if;

	if i_function_name is not null
	then
		get_function_value
			(
			i_function_name,
			g_file_tbl(m_count).value
			);
	end if;
         -- 2996147
           hash_string:=to_char( g_file_tbl(m_count).external_level)||'-'||upper(g_file_tbl(m_count).interface_column_name);
           hash_val  := dbms_utility.get_hash_value(hash_string,1,8192);
           if ec_utils.g_col_pos_tbl_1.exists(hash_val) then
                if ec_utils.g_col_pos_tbl_1(hash_val).occr=1 then
                        p_count:=ec_utils.g_col_pos_tbl_1(hash_val).value;
                        ec_utils.g_col_pos_tbl_2(p_count):=hash_val;
                        ec_utils.g_col_pos_tbl_1(hash_val).value:=0;
                        ec_utils.g_col_pos_tbl_1(hash_val).start_pos:=p_count;
                end if;
                ec_utils.g_col_pos_tbl_1(hash_val).occr:=
                                ec_utils.g_col_pos_tbl_1(hash_val).occr +1;
                ec_utils.g_col_pos_tbl_2(m_count):=hash_val;
            else
                ec_utils.g_col_pos_tbl_1(hash_val).occr:=1;
                ec_utils.g_col_pos_tbl_1(hash_val).value:=m_count;
            end if;
        -- 2996147
        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,i_variable_name,g_file_tbl(m_count).value);
        end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.CREATE_MANDATORY_COLUMNS');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.CREATE_MANDATORY_COLUMNS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end create_mandatory_columns;

procedure append_clause
	(
	i_level			In	number,
	i_where_clause		IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.APPEND_CLAUSE');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_where_clause',i_where_clause);
end if;
	g_int_levels(i_level).sql_stmt :=
			g_int_levels(i_level).sql_stmt ||'  '|| i_where_clause;
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'i_where_clause',
		g_int_levels(i_level).sql_stmt);
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.APPEND_CLAUSE');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.APPEND_CLAUSE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END append_clause;

procedure if_Notnull_append_clause
	(
	i_level				IN	number,
	i_variable_level		IN	number,
	i_variable_name			IN	varchar2,
	i_where_clause			IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IF_NOTNULL_APPEND_CLAUSE');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_where_clause',i_where_clause);
end if;

		var_present :=	find_variable
				(
				i_variable_level,
				i_variable_name,
				o_stack_pos,
				o_plsql_pos
				);


		if ( var_present )
		then
			if g_stack(o_stack_pos).variable_value is not null
			then
			g_int_levels(i_level).sql_stmt
				:= g_int_levels(i_level).sql_stmt
				||'  '||i_where_clause;
			end if;

		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

	ec_debug.pl(3,'i_where_clause',g_int_levels(i_level).sql_stmt);
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IF_NOTNULL_APPEND_CLAUSE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IF_NOTNULL_APPEND_CLAUSE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END if_notnull_append_clause;

procedure bind_variables_for_view
	(
	i_variable_name			IN	varchar2,
	i_previous_variable_level	IN	integer,
	i_previous_variable_name	IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
i_date			date;
i_number		number;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.BIND_VARIABLES_FOR_VIEW');
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
end if;
		var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pos,
				o_plsql_pos
				);

		if ( var_present )
		then
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,'Select Stmt',g_int_levels(g_current_level).sql_stmt);
                        end if;
			if i_previous_variable_level = 0
			then
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,'Current Level and Cursor '||g_current_level||' '||
				g_int_levels(g_current_level).Cursor_Handle,g_stack(o_stack_pos).variable_value);
                                end if;

			if g_stack(o_stack_pos).variable_value is not null
			then

				if g_stack(o_stack_pos).data_type = 'NUMBER'
				then
					i_number := to_number(g_stack(o_stack_pos).variable_value);
					dbms_sql.bind_variable
						(
						g_int_levels(g_current_level).Cursor_Handle,
						i_variable_name,
						i_number
						);
                                        if EC_DEBUG.G_debug_level >= 3 then
					ec_debug.pl(3,'Binding Value ',i_number);
                                        end if;
				elsif g_stack(o_stack_pos).data_type = 'DATE'
				then
                                   /* Bug 2463916
                                      Bug 5763541
					i_date := to_date(g_stack(o_stack_pos).variable_value,'DD-MM-RR'); */

                                        i_date := FND_CONC_DATE.string_to_date(g_stack(o_stack_pos).variable_value);
					dbms_sql.bind_variable
						(
						g_int_levels(g_current_level).Cursor_Handle,
						i_variable_name,
						i_date
						);
                                        if EC_DEBUG.G_debug_level >= 3 then
					ec_debug.pl(3,'Binding Value ',i_date);
                                        end if;
				else
					dbms_sql.bind_variable
						(
						g_int_levels(g_current_level).Cursor_Handle,
						i_variable_name,
						g_stack(o_stack_pos).variable_value
						);
                                        if EC_DEBUG.G_debug_level >= 3 then
					ec_debug.pl(3,'Binding Value ',g_stack(o_stack_pos).variable_value);
                                        end if;
				end if;
			end if;
			else
				dbms_sql.bind_variable
					(
					g_int_levels(g_current_level).Cursor_Handle,
					i_variable_name,
					g_file_tbl(o_plsql_pos).value
					);
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,'Binding Value ',g_file_tbl(o_plsql_pos).value);
                                end if;
			end if;

		else
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.BIND_VARIABLES_FOR_VIEW');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.BIND_VARIABLES_FOR_VIEW');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END bind_variables_for_view;

/**
Executes a given stored procedure or a function with parameters of following datatype :
1. Date
2. Number
3. varchar2
4. Char.
Other types are not supported at this point of time because PL/SQL language does not support
dynamic binding of other types of variables. Probably we should use Java and do it in next release.
**/
procedure execute_proc
	(
	i_transtage_id		IN	number,
	i_procedure_name	IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.EXECUTE_PROC');
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;

	ec_execution_utils.assign_values
				(
				i_transtage_id,
				i_procedure_name,
				1060
				);

	ec_execution_utils.runproc
				(
				i_procedure_name
				);

	ec_execution_utils.assign_values
				(
				i_transtage_id,
				i_procedure_name,
				1070
				);
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.EXECUTE_PROC');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXECUTE_PROC');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END execute_proc;

/**
Execute the Stored procedure or function only when x is null.
i.e.
If x is null
then
	execute_procedure;
end if;
**/
procedure ifxnull_execute_proc
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_transtage_id				IN	number,
	i_procedure_name			IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IFXNULL_EXECUTE_PROC');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;

		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
		if g_stack(o_stack_pos).variable_value is null
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
else
		if g_file_tbl(o_plsql_pos).value  is null
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IFXNULL_EXECUTE_PROC');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IFXNULL_EXECUTE_PROC');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END ifxnull_execute_proc;

/**
Execute the Stored procedure or function only when x is null.
i.e.
If x is not null
then
	execute_procedure;
end if;
**/
procedure ifxnotnull_execute_proc
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_transtage_id				IN	number,
	i_procedure_name			IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IFXNOTNULL_EXECUTE_PROC');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;

		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
		if g_stack(o_stack_pos).variable_value is not null
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
else
		if g_file_tbl(o_plsql_pos).value  is not null
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IFXNOTNULL_EXECUTE_PROC');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IFXNOTNULL_EXECUTE_PROC');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END ifxnotnull_execute_proc;

/**
Execute the Stored procedure or function only when x = default value.
i.e.
If x = 5
then
	execute_procedure;
end if;
**/
procedure ifxconst_execute_proc
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_default_value				IN	varchar2,
	i_transtage_id				IN	number,
	i_procedure_name			IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_plsql_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IFXCONST_EXECUTE_PROC');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_default_value',i_default_value);
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;
		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
		if g_stack(o_stack_pos).variable_value = i_default_value
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
else
		if g_file_tbl(o_plsql_pos).value  = i_default_value
		then
			execute_proc
				(
				i_transtage_id,
				i_procedure_name
				);
		end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IFXCONST_EXECUTE_PROC');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IFXCONST_EXECUTE_PROC');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END ifxconst_execute_proc;

/**
if x is equal to y , then execute procedure or function.
i.e. 	if i = j
	then
		execute_procedure
	end if;
**/
procedure ifxpre_execute_proc
	(
	i_variable_level			IN	number,
	i_variable_name				IN	varchar2,
	i_previous_variable_level		IN	number,
	i_previous_variable_name		IN	varchar2,
	i_transtage_id				IN	number,
	i_procedure_name			IN	varchar2
	)
is
var_present		BOOLEAN := FALSE;
pre_var_present		BOOLEAN := FALSE;
o_stack_pos		pls_integer;
o_stack_pre_pos		pls_integer;
o_plsql_pos		pls_integer;
o_plsql_pre_pos		pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.IFXPRE_EXECUTE_PROC');
ec_debug.pl(3,'i_variable_level',i_variable_level);
ec_debug.pl(3,'i_variable_name',i_variable_name);
ec_debug.pl(3,'i_previous_variable_level',i_previous_variable_level);
ec_debug.pl(3,'i_previous_variable_name',i_previous_variable_name);
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;
		var_present 	:=find_variable
					(
					i_variable_level,
					i_variable_name,
					o_stack_pos,
					o_plsql_pos
					);
		if NOT ( var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',i_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

		pre_var_present :=	find_variable
				(
				i_previous_variable_level,
				i_previous_variable_name,
				o_stack_pre_pos,
				o_plsql_pre_pos
				);

		if NOT ( pre_var_present)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK',
					'VARIABLE_NAME',i_previous_variable_name);
			i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

if i_variable_level = 0
then
		if i_previous_variable_level = 0
		then
			if g_stack(o_stack_pos).variable_value = g_stack(o_stack_pre_pos).variable_value
			then
				execute_proc
					(
					i_transtage_id,
					i_procedure_name
					);
			end if;
		else
			if g_stack(o_stack_pos).variable_value = g_file_tbl(o_plsql_pre_pos).value
			then
				execute_proc
					(
					i_transtage_id,
					i_procedure_name
					);
			end if;
		end if;
else
		if i_previous_variable_level = 0
		then
			if g_file_tbl(o_plsql_pos).value = g_stack(o_stack_pre_pos).variable_value
			then
				execute_proc
					(
					i_transtage_id,
					i_procedure_name
					);
			end if;
		else
			if g_file_tbl(o_plsql_pos).value = g_file_tbl(o_plsql_pre_pos).value
			then
				execute_proc
					(
					i_transtage_id,
					i_procedure_name
					);
			end if;
		end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.IFXPRE_EXECUTE_PROC');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.IFXPRE_EXECUTE_PROC');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END ifxpre_execute_proc;

procedure ext_find_position
        (
        i_level                 IN      number,
        i_search_text           IN      varchar2,
        o_pos                   OUT NOCOPY     NUMBER,
        i_required              IN      BOOLEAN DEFAULT TRUE
        )
IS
        cIn_String      varchar2(1000) := UPPER(i_search_text);
        bFound BOOLEAN := FALSE;
        POS_NOT_FOUND   EXCEPTION;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_UTILS.EXT_FIND_POSITION');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_search_text',i_search_text);
end if;

if g_direction = 'I'
then
        for i in g_ext_levels(i_level).file_start_pos..g_ext_levels(i_level).file_end_pos
        loop
                if upper(g_file_tbl(i).interface_column_name) = cIn_String
                then
                        o_pos := i;
                        bFound := TRUE;
                        exit;
                end if;
        end loop;
else
        for i in g_int_levels(i_level).file_start_pos..g_int_levels(i_level).file_end_pos
        loop
                if upper(g_file_tbl(i).interface_column_name) = cIn_String
                then
                        o_pos := i;
                        bFound := TRUE;
                        exit;
                end if;
        end loop;
end if;

if not bFound
then
        if (i_required)
        then
                raise POS_NOT_FOUND;
        else
                o_pos := NULL;
        end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_pos',o_pos);
ec_debug.POP('EC_UTILS.EXT_FIND_POSITION');
end if;
EXCEPTION
WHEN POS_NOT_FOUND THEN
        ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_String);
        ec_debug.POP('EC_UTILS.EXT_FIND_POSITION');
        i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXT_FIND_POSITION');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
END ext_find_position;

procedure EXT_GET_KEY_VALUE
        (
        i_position        IN      number,
        o_value           OUT NOCOPY     varchar2
        )
is
o_stack_pos             pls_integer;
o_plsql_pos             pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.EXT_GET_KEY_VALUE');
ec_debug.pl(3,'i_position',i_position);
end if;
if i_position is not null then
   o_value := g_file_tbl(i_position).value;
   if EC_DEBUG.G_debug_level >= 3 then
   ec_debug.pl(3,o_value,g_file_tbl(i_position).value);
   end if;
end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.EXT_GET_KEY_VALUE');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXT_GET_KEY_VALUE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
END EXT_GET_KEY_VALUE;

procedure EXT_INSERT_VALUE
        (
        i_position        IN      number,
        i_value           IN     varchar2
        )
is
o_stack_pos             pls_integer;
o_plsql_pos             pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_UTILS.EXT_INSERT_VALUE');
ec_debug.pl(3,'i_position',i_position);
ec_debug.pl(3,'i_value',i_value);
end if;
if i_position is not null   then
    g_file_tbl(i_position).value := i_value;
ec_debug.pl(3,'i_value_put',g_file_tbl(i_position).value);
end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_UTILS.EXT_INSERT_VALUE');
end if;
EXCEPTION
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_UTILS.EXT_INSERT_VALUE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        i_ret_code := 2;
        raise EC_UTILS.PROGRAM_EXIT;
END EXT_INSERT_VALUE;

end ec_utils;

/
