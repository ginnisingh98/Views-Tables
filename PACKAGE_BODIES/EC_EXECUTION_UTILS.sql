--------------------------------------------------------
--  DDL for Package Body EC_EXECUTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_EXECUTION_UTILS" as
-- $Header: ECXUTILB.pls 115.24 2003/04/04 07:26:50 hgandiko ship $

-- Internal DBMS_DESCRIBE.DESCRIBE_PROCEDURE variables
v_overload	dbms_describe.number_table;
v_position	dbms_describe.number_table;
v_level		dbms_describe.number_table;
v_argumentname	dbms_describe.varchar2_table;
v_datatype	dbms_describe.number_table;
v_defaultvalue	dbms_describe.number_table;
v_inout		dbms_describe.number_table;
v_length	dbms_describe.number_table;
v_precision	dbms_describe.number_table;
v_scale		dbms_describe.number_table;
v_radix		dbms_describe.number_table;
v_spare		dbms_describe.number_table;

procedure printparams
        (
	i_procedure_name	IN	varchar2
        )
is
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.PRINTPARAMS');
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;
for i in 1..ec_utils.g_parameter_stack.COUNT
loop
	if ec_utils.g_parameter_stack(i).procedure_name = i_procedure_name
	then
              if EC_DEBUG.G_debug_level >= 3 then
              ec_debug.pl(3,ec_utils.g_parameter_stack(i).parameter_name,ec_utils.g_parameter_stack(i).value);
              end if;
	end if;
end loop;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.PRINTPARAMS');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.PRINTPARAMS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end printparams;

procedure describeproc
	(
	i_procedure_name	IN		varchar2
	)
is
i			pls_integer :=0;
j			pls_integer :=0;
v_argcounter		pls_integer :=1;
i_procedure_loaded 	BOOLEAN := FALSE;
v_proc_string		varchar2(32767);	-- Bug 2637838
v_firstparam		BOOLEAN := TRUE;
error_position		pls_integer;
is_function		BOOLEAN := FALSE;
i_return_value		varchar2(32000);
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.DESCRIBEPROC');
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;


--  This code is added for NULL procedure name
if nvl(length(replace(i_procedure_name, ' ')),0) < 1 then
   ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.DESCRIBEPROC');
   ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',' ===> NULL supplied as procedure name');
   ec_utils.i_ret_code :=2;
   raise EC_UTILS.PROGRAM_EXIT;
end if;

--- Describe and Load the procedure on Procedure Stack only if not loaded
for i in 1..ec_utils.g_procedure_stack.COUNT
loop
	if ec_utils.g_procedure_stack(i).procedure_name = i_procedure_name
	then
		i_procedure_loaded := TRUE;
		exit;
	end if;
end loop;

if NOT ( i_procedure_loaded )
then
	-- Standard Call provided by Oracle RDBMS

	BEGIN
		dbms_describe.describe_procedure
			(
			i_procedure_name,
			null,
			null,
			v_overload,
			v_position,
			v_level,
			v_argumentname,
			v_datatype,
			v_defaultvalue,
			v_inout,
			v_length,
			v_precision,
			v_scale,
			v_radix,
			v_spare
			);
	EXCEPTION
	WHEN OTHERS THEN
        	ec_debug.pl(0,'EC','ECE_PROCEDURE_EXECUTION','PROCEDURE_NAME',i_procedure_name);
        	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.DESCRIBEPROC');
        	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        	ec_utils.i_ret_code :=2;
        	raise EC_UTILS.PROGRAM_EXIT;
	END;


	v_proc_string := 'BEGIN '|| i_procedure_name || ' ( ';

	loop
	begin
                if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,'Overloaded',v_overload(v_argcounter));
		ec_debug.pl(3,'Position',v_position(v_argcounter));
		ec_debug.pl(3,'Argument Name',v_argumentname(v_argcounter));
		ec_debug.pl(3,'Level',v_level(v_argcounter));
		ec_debug.pl(3,'Data Type',v_datatype(v_argcounter));
		ec_debug.pl(3,'In/Out',v_inout(v_argcounter));
		ec_debug.pl(3,'Length',v_length(v_argcounter));
		ec_debug.pl(3,'Precision',v_precision(v_argcounter));
		ec_debug.pl(3,'scale',v_scale(v_argcounter));
                end if;


		-- Procedure with no Parameters.
		if v_datatype(v_argcounter) = 0
		then
			null;
			exit;
		end if;

		/**
		Procedures with Number,varchar2 and date are supported only.
		**/
		-- Procedure with no Parameters.
		if v_datatype(v_argcounter) not in ( 1,2,12,96)
		then
        		ec_debug.pl(0,'EC','ECE_PROCEDURE_EXECUTION','PROCEDURE_NAME',i_procedure_name);
        		ec_debug.pl(0,'EC','ECE_UNSUPPORTED_DATATYPE','Unsupported Data Type');
        		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.DESCRIBEPROC');
        		ec_utils.i_ret_code :=2;
        		raise EC_UTILS.PROGRAM_EXIT;
		end if;

		/**
		Check For Function
		**/
		if v_position(v_argcounter) = 0
		then
			is_function := TRUE;
			v_proc_string := 'BEGIN :i_return_value := '||i_procedure_name||' (';
			i := ec_utils.g_parameter_stack.COUNT+1;
			ec_utils.g_parameter_stack(i).procedure_name := upper(i_procedure_name);
                        ec_utils.g_parameter_stack(i).parameter_name := 'i_return_value';
                        ec_utils.g_parameter_stack(i).data_type := v_datatype(v_argcounter);
                        ec_utils.g_parameter_stack(i).in_out := v_inout(v_argcounter);

			goto end_fun;
		end if;

		-- Load the definition on the Parameter Stack.
		i := ec_utils.g_parameter_stack.COUNT+1;
		ec_utils.g_parameter_stack(i).procedure_name := upper(i_procedure_name);
		ec_utils.g_parameter_stack(i).parameter_name := v_argumentname(v_argcounter);
		ec_utils.g_parameter_stack(i).data_type := v_datatype(v_argcounter);
		ec_utils.g_parameter_stack(i).in_out := v_inout(v_argcounter);


		if is_function
		then
			if v_argcounter =2
			then
				v_proc_string := v_proc_string || ':'||v_argumentname(v_argcounter);
			elsif v_argcounter >= 2
			then
				v_proc_string := v_proc_string || ',:'||v_argumentname(v_argcounter);
			end if;
		else
			if v_firstparam
			then
				v_proc_string := v_proc_string || ':'||v_argumentname(v_argcounter);
				v_firstparam := FALSE;
			else
				v_proc_string := v_proc_string || ',:'||v_argumentname(v_argcounter);
			end if;
		end if;


		<<end_fun>>
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'Procedure name',ec_utils.g_parameter_stack(i).procedure_name);
                ec_debug.pl(3,'Parameter name',ec_utils.g_parameter_stack(i).parameter_name);
                ec_debug.pl(3,'Data Type',ec_utils.g_parameter_stack(i).data_type);
                ec_debug.pl(3,'In Out',ec_utils.g_parameter_stack(i).in_out);
                end if;

		v_argcounter := v_argcounter + 1;
	exception
	when no_data_found then
		exit;
	end;
	end loop;


	v_proc_string := v_proc_string || '); END;';

	if is_function
	then
		if v_argcounter = 2
		then
			v_proc_string := 'BEGIN :i_return_value := '||i_procedure_name||';END;';
		end if;
	else
		if v_argcounter = 1
		then
			v_proc_string := 'BEGIN '||i_procedure_name||'; END;';
		end if;
	end if;
        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'Execution String :',v_proc_string);
        end if;
	-- Open the Cursor and parse the Statement.

	-- Load the Procedure Stack
	j := ec_utils.g_procedure_stack.COUNT + 1;
	ec_utils.g_procedure_stack(j).procedure_name := i_procedure_name;
	ec_utils.g_procedure_stack(j).cursor_handle := dbms_sql.open_cursor;
	ec_utils.g_procedure_stack(j).execution_clause := v_proc_string;

        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'Procedure name',ec_utils.g_procedure_stack(j).procedure_name);
	ec_debug.pl(3,'Cursor Handle ',ec_utils.g_procedure_stack(j).cursor_handle);
	ec_debug.pl(3,'Procedure name',ec_utils.g_procedure_stack(j).execution_clause);
        end if;

	--Parse the Procedure String
	BEGIN
		dbms_sql.parse(ec_utils.g_procedure_stack(j).cursor_handle,v_proc_string,dbms_sql.native);
	EXCEPTION
	WHEN OTHERS THEN
        		ec_debug.pl(0,'EC','ECE_PROCEDURE_EXECUTION','PROCEDURE_NAME',i_procedure_name);
                	error_position := dbms_sql.last_error_position;
                	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.RUNPROC');
                	ece_error_handling_pvt.print_parse_error (error_position,v_proc_string);
                	ec_utils.i_ret_code :=2;
                	raise EC_UTILS.PROGRAM_EXIT;
	END;

end if;

-- Bug 2340691
if EC_DEBUG.G_debug_level = 3 then
	printparams
		(
		i_procedure_name
		);
end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.DESCRIBEPROC');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.DESCRIBEPROC');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end describeproc;

procedure runproc
	(
	i_procedure_name	IN		varchar2
	)
is

-- DBMS_SQL variables
v_cursor	pls_integer;
v_numrows	pls_integer;

v_proccall	varchar2(500);
v_firstparam	BOOLEAN := TRUE;
error_position	pls_integer;
i_date		date;
j_date		date;
i_number	number;
j_number	number;
i_char		char(500);

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.RUNPROC');
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
end if;

-- Bug 2340691
if EC_DEBUG.G_debug_level = 3 then
	printparams
		(
		i_procedure_name
		);
end if;

for i in 1..ec_utils.g_procedure_stack.COUNT
loop
if ec_utils.g_procedure_stack(i).procedure_name = i_procedure_name
then
	-- Bind the procedure parameters.
	for j in 1..ec_utils.g_parameter_stack.COUNT
	loop
	if ec_utils.g_parameter_stack(j).procedure_name = i_procedure_name
	then

		-- First set the Parameter Name
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'Name',ec_utils.g_parameter_stack(j).parameter_name);
		ec_debug.pl(3,'Datatype',ec_utils.g_parameter_stack(j).data_type);
                end if;

		-- Bind based on the parameter type
		-- 2 Number
		IF ec_utils.g_parameter_stack(j).data_type = 2
		then
			i_number := to_number(ec_utils.g_parameter_stack(j).value);
			dbms_sql.bind_variable
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					i_number
					);
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
                end if;
		-- 1 VARCHAR2
		elsif ec_utils.g_parameter_stack(j).data_type = 1
		then
			dbms_sql.bind_variable
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					ec_utils.g_parameter_stack(j).value,
					32000
					);
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
                end if;
		-- 12 DATE
		elsif ec_utils.g_parameter_stack(j).data_type = 12
		then
			i_date := to_date(ec_utils.g_parameter_stack(j).value,'YYYYMMDD HH24MISS');
			dbms_sql.bind_variable
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					i_date
					);
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,i_date);
end if;
		-- 96 CHAR
		elsif ec_utils.g_parameter_stack(j).data_type = 96
		then
			dbms_sql.bind_variable
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					ec_utils.g_parameter_stack(j).value,
					600
					);
if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
end if;
		else
        		ec_debug.pl(0,'EC','ECE_PROCEDURE_EXECUTION','PROCEDURE_NAME',i_procedure_name);
        		ec_debug.pl(0,'EC','ECE_UNSUPPORTED_DATATYPE','Unsupported Data Type');
        		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.RUNPROC');
        		ec_utils.i_ret_code :=2;
        		raise EC_UTILS.PROGRAM_EXIT;
		end if;

	end if; --- procedure name in the parameter Stack
	end loop; -- End of paremeter Loop i.e. j

-- Execute the Procedure.
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'Before Execution','Yes');

	ec_debug.pl(3,'Procedure name',ec_utils.g_procedure_stack(i).procedure_name);
	ec_debug.pl(3,'Cursor Handle ',ec_utils.g_procedure_stack(i).cursor_handle);
	ec_debug.pl(3,'Procedure name',ec_utils.g_procedure_stack(i).execution_clause);
end if;
v_numrows := DBMS_SQL.execute(ec_utils.g_procedure_stack(i).cursor_handle);
if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'Execution Successful','Yes');
end if;
	-- Call Variable value for any OUT or IN/OUT parameters
	for j in 1..ec_utils.g_parameter_stack.COUNT
	loop
	if ec_utils.g_parameter_stack(j).procedure_name = i_procedure_name
	then
		if ec_utils.g_parameter_stack(j).in_out = 1 or ec_utils.g_parameter_stack(j).in_out = 2
		then
			if ec_utils.g_parameter_stack(j).data_type= 2
			then
				dbms_sql.variable_value
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					j_number
					);
					ec_utils.g_parameter_stack(j).value := to_number(j_number);
                 if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
                 end if;
			elsif ec_utils.g_parameter_stack(j).data_type= 1
			then
				dbms_sql.variable_value
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					ec_utils.g_parameter_stack(j).value
					);
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
end if;
			elsif ec_utils.g_parameter_stack(j).data_type= 12
			then
				dbms_sql.variable_value
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					j_date
					);

				ec_utils.g_parameter_stack(j).value := to_char(j_date,'YYYYMMDD HH24MISS');
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
                        end if;
			elsif ec_utils.g_parameter_stack(j).data_type= 96
			then
				dbms_sql.variable_value
					(
					ec_utils.g_procedure_stack(i).cursor_handle,
					':'||ec_utils.g_parameter_stack(j).parameter_name,
					ec_utils.g_parameter_stack(j).value
					);
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,ec_utils.g_parameter_stack(j).value);
                        end if;
			else
        			ec_debug.pl(0,'EC','ECE_UNSUPPORTED_DATATYPE','Unsupported Data Type');
        			ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.RUNPROC');
        			ec_utils.i_ret_code :=2;
        			raise EC_UTILS.PROGRAM_EXIT;
			end if;

		end if; -- For In/OUT

	end if; -- i_procedure_name
	end loop; -- for parameter stack

exit; --- procedure Found. Exit the Loop.
end if; -- Main Procedure_name
end loop; -- for procedure_name in the Program Stack for i

-- Bug 2340691
if EC_DEBUG.G_debug_level = 3 then
printparams
	(
	i_procedure_name
	);
end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.RUNPROC');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROCEDURE_ERROR','PROCEDURE_NAME',i_procedure_name);
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.RUNPROC');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end runproc;

procedure load_procedure_definitions
is
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.LOAD_PROCEDURE_DEFINITIONS');
end if;
for i in 1..ec_utils.g_stage_data.COUNT
loop
	if 	(
		ec_utils.g_stage_data(i).action_type = 1050 OR
		ec_utils.g_stage_data(i).action_type = 80   OR
		ec_utils.g_stage_data(i).action_type = 1080 OR
		ec_utils.g_stage_data(i).action_type = 1090 OR
		ec_utils.g_stage_data(i).action_type = 1100 OR
		ec_utils.g_stage_data(i).action_type = 1110
		)
	then
		describeproc
			(
			ec_utils.g_stage_data(i).custom_procedure_name
			);
	end if;
end loop;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.LOAD_PROCEDURE_DEFINITIONS');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.LOAD_PROCEDURE_DEFINITIONS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end load_procedure_definitions;

procedure load_mandatory_columns
	(
	i_level		IN	pls_integer
	)
is
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.LOAD_MANDATORY_COLUMNS');
ec_debug.pl(3,'i_level',i_level);
end if;

for i in 1..ec_utils.g_stage_data.COUNT
loop
	if 	(
		ec_utils.g_stage_data(i).variable_level = i_level AND
		ec_utils.g_stage_data(i).action_type = 110
		)
	then
		ec_utils.create_mandatory_columns
			(
			ec_utils.g_stage_data(i).variable_level,
			ec_utils.g_stage_data(i).previous_variable_level,
			ec_utils.g_stage_data(i).variable_name,
			ec_utils.g_stage_data(i).default_value,
			ec_utils.g_stage_data(i).data_type,
			ec_utils.g_stage_data(i).function_name
			);
	end if;
end loop;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.LOAD_MANDATORY_COLUMNS');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.LOAD_MANDATORY_COLUMNS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end load_mandatory_columns;

procedure load_procedure_mappings
        (
        i_transaction_type      IN      	varchar2
        )
is
cursor proc_mapping
	(
	p_transaction_type	IN	varchar2
	)
is
select	epm.transtage_id transtage_id,
	upper(etsd.custom_procedure_name) procedure_name,
	upper(epm.parameter_name) parameter_name,
	epm.action_type action_type,
	epm.variable_level variable_level,
	upper(epm.variable_name) variable_name
from	ece_procedure_mappings epm,
	ece_tran_stage_data etsd
where	etsd.transtage_id = epm.transtage_id
and	etsd.transaction_type = p_transaction_type
and	etsd.map_id = ec_utils.g_map_id;
i	pls_integer	:= ec_utils.g_procedure_mappings.COUNT;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.LOAD_PROCEDURE_MAPPINGS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
end if;

for proc_map in proc_mapping
		(
		p_transaction_type => i_transaction_type
		)
loop
	i := i + 1;
	ec_utils.g_procedure_mappings(i).transtage_id := proc_map.transtage_id;
	ec_utils.g_procedure_mappings(i).procedure_name := proc_map.procedure_name;
	ec_utils.g_procedure_mappings(i).parameter_name := proc_map.parameter_name;
	ec_utils.g_procedure_mappings(i).action_type := proc_map.action_type;
	ec_utils.g_procedure_mappings(i).variable_level := proc_map.variable_level;
	ec_utils.g_procedure_mappings(i).variable_name := proc_map.variable_name;

      if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,	ec_utils.g_procedure_mappings(i).tranStage_id ||' '||
			ec_utils.g_procedure_mappings(i).procedure_name||' '||
			ec_utils.g_procedure_mappings(i).parameter_name||' '||
			ec_utils.g_procedure_mappings(i).action_type||' '||
			ec_utils.g_procedure_mappings(i).variable_level||' '||
			ec_utils.g_procedure_mappings(i).variable_name
			);
       end if;
end loop;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.LOAD_PROCEDURE_MAPPINGS');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.LOAD_PROCEDURE_MAPPINGS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end load_procedure_mappings;

procedure assign_values
        (
	i_transtage_id		IN		pls_integer,
	i_procedure_name	IN		varchar2,
	i_action_type		IN		pls_integer
        )
is
m_var_found	BOOLEAN := FALSE;
i_stack_pos	pls_integer;
i_plsql_pos	pls_integer;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.ASSIGN_VALUES');
ec_debug.pl(3,'i_transtage_id',i_transtage_id);
ec_debug.pl(3,'i_procedure_name',i_procedure_name);
ec_debug.pl(3,'i_action_type',i_action_type);
end if;
-- Print Procedure Mappings as well as Parameters
-- Bug 2340691
if EC_DEBUG.G_debug_level >= 3 then
 for k in 1..ec_utils.g_procedure_mappings.COUNT
 loop
	if 	(
		ec_utils.g_procedure_mappings(k).procedure_name = i_procedure_name AND
		ec_utils.g_procedure_mappings(k).transtage_id = i_transtage_id
		)
	then
		ec_debug.pl(3,
			ec_utils.g_procedure_mappings(k).parameter_name||' '||
			ec_utils.g_procedure_mappings(k).variable_level||' '||
			ec_utils.g_procedure_mappings(k).variable_name
			);
	end if;
 end loop;
end if;

--- Initialize all the values of parameter before assignment.
if i_action_type = 1060
then
	for k in 1..ec_utils.g_parameter_stack.COUNT
	loop
		if 	(
			ec_utils.g_parameter_stack(k).procedure_name = i_procedure_name
			)
		then
			ec_utils.g_parameter_stack(k).value := NULL;
		end if;
	end loop;
end if;

-- Bug 2340691
if EC_DEBUG.G_debug_level >= 3 then
printparams
	(
	i_procedure_name
	);
end if;

for i in 1..ec_utils.g_procedure_mappings.COUNT
loop
	IF 	(	ec_utils.g_procedure_mappings(i).transtage_id = i_transtage_id
		AND	ec_utils.g_procedure_mappings(i).procedure_name = i_procedure_name
		AND	ec_utils.g_procedure_mappings(i).action_type = i_action_type
		)
	then
if EC_DEBUG.G_debug_level >= 3 then
  	ec_debug.pl(3,'Processing ',ec_utils.g_procedure_mappings(i).parameter_name);
end if;
			m_var_found := 	ec_utils.find_variable
						(
						ec_utils.g_procedure_mappings(i).variable_level,
						ec_utils.g_procedure_mappings(i).variable_name,
						i_stack_pos,
						i_plsql_pos
						);
			if NOT ( m_var_found)
			then
				ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME',
					 ec_utils.g_procedure_mappings(i).variable_name);
                       		ec_utils.i_ret_code := 2;
                       		raise EC_UTILS.PROGRAM_EXIT;
			end if;

		for j in 1..ec_utils.g_parameter_stack.COUNT
		loop
			if 	(
				ec_utils.g_procedure_mappings(i).parameter_name is not null AND
				ec_utils.g_parameter_stack(j).procedure_name = ec_utils.g_procedure_mappings(i).procedure_name AND
				ec_utils.g_parameter_stack(j).parameter_name = ec_utils.g_procedure_mappings(i).parameter_name
				)
			then
                    if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,'Match Found for  ',ec_utils.g_procedure_mappings(i).parameter_name);
                   end if;
				if ec_utils.g_procedure_mappings(i).action_type = 1060
				then
						if ec_utils.g_procedure_mappings(i).variable_level = 0
						then
							ec_utils.g_parameter_stack(j).value :=
								ec_utils.g_stack(i_stack_pos).variable_value;
              if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,
								ec_utils.g_parameter_stack(j).value);
              end if;
	else
							ec_utils.g_parameter_stack(j).value := ec_utils.g_file_tbl(i_plsql_pos).value;
                                                     if EC_DEBUG.G_debug_level >= 3 then
							ec_debug.pl(3,ec_utils.g_parameter_stack(j).parameter_name,
								ec_utils.g_parameter_stack(j).value);
                                                     end if;
						end if;
					exit;

				elsif ec_utils.g_procedure_mappings(i).action_type = 1070
				then

					if 	ec_utils.g_parameter_stack(j).parameter_name is not null AND
						ec_utils.g_parameter_stack(j).parameter_name = ec_utils.g_procedure_mappings(i).parameter_name
					then
						if ec_utils.g_procedure_mappings(i).variable_level = 0
						then
							ec_utils.g_stack(i_stack_pos).variable_value := ec_utils.g_parameter_stack(j).value;
                                                  if EC_DEBUG.G_debug_level >= 3 then
							ec_debug.pl(3,ec_utils.g_stack(i_stack_pos).variable_name,
								ec_utils.g_stack(i_stack_pos).variable_value);
                                                  end if;
						else
							ec_utils.g_file_tbl(i_plsql_pos).value := ec_utils.g_parameter_stack(j).value;
                                                    if EC_DEBUG.G_debug_level >= 3 then
							ec_debug.pl(3,
							ec_utils.g_file_tbl(i_plsql_pos).interface_column_name,
							ec_utils.g_file_tbl(i_plsql_pos).value);
                                                     end if;
						end if;
						exit;
					end if;

				else
        				ec_debug.pl(0,'EC','ECE_PROCEDURE_EXECUTION','PROCEDURE_NAME',i_procedure_name);
        				ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.ASSIGN_VALUES');
        				ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        				ec_utils.i_ret_code :=2;
        				raise EC_UTILS.PROGRAM_EXIT;
				end if; -- For Action Types

			else
				-- Assign Back the Function value
				if 	(
					ec_utils.g_procedure_mappings(i).parameter_name is null AND
					ec_utils.g_parameter_stack(j).procedure_name = ec_utils.g_procedure_mappings(i).procedure_name AND
					ec_utils.g_parameter_stack(j).parameter_name is null
					)
				then
if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'Match Found for  ',ec_utils.g_procedure_mappings(i).parameter_name);
end if;
					if ec_utils.g_procedure_mappings(i).action_type = 1070
					then
						if ec_utils.g_procedure_mappings(i).variable_level = 0
						then
							ec_utils.g_stack(i_stack_pos).variable_value := ec_utils.g_parameter_stack(j).value;
						else
							ec_utils.g_file_tbl(i_plsql_pos).value := ec_utils.g_parameter_stack(j).value;
						end if;
					end if;
					exit;
				end if;
			end if;
		end loop; --- j

	end if;
end loop; --- i

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.ASSIGN_VALUES');
end if;
exception
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.ASSIGN_VALUES');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end assign_values;

procedure load_mappings
	(
	i_transaction_type		in	varchar2,
	i_map_id			in	pls_integer
	)
is
	cursor external_rec
		(
		p_transaction_type	IN	varchar2,
		p_map_id		in	number
		)
	is
	select	external_level_id,
		external_level,
		start_element
	from	ece_external_levels
	where	transaction_type = p_transaction_type
	and	map_id		= p_map_id
	order by external_level;

	cursor interface_rec
		(
		p_transaction_type	in	varchar2,
		p_map_id		In	number
		)
	is
	select	to_number(output_level) output_level,
		interface_table_name,
		parent_level,
		interface_table_id,
		key_column_name
	from	ece_interface_tables
	where	transaction_type = p_transaction_type
	and	map_id = p_map_id
	order by to_number(output_level);

	cursor interface_external_rec
		(
		p_external_id		in	number
		)
	is
	select	to_number(eit.output_level) output_level
	from	ece_level_matrices elm,
		ece_interface_tables eit
	where	elm.external_level_id = p_external_id
	and	eit.interface_table_id = elm.interface_table_id;

	cursor	mapping_rec
		(
		p_interface_table_id		number,
		p_map_id			number
		) is
	select	interface_column_name,
		interface_column_id,
		base_column_name,
		conversion_sequence,
		conversion_group_id,
		xref_category_id,
		xref_category_allowed,
		xref_key1_source_column,
		xref_key2_source_column,
		xref_key3_source_column,
		xref_key4_source_column,
		xref_key5_source_column,
		staging_column,
		data_type,
		width,
		record_number,
		position,
		record_layout_code,
		record_layout_qualifier,
		element_tag_name,
		external_level
	from	ece_interface_columns
	where	interface_table_id = p_interface_table_id
	and	map_id	= p_map_id
	ORDER BY interface_column_id;

        -- Bug 2708573
        CURSOR c_col_rule_info
        (
          p_interface_column_id  NUMBER
        ) IS
        select  column_rule_id,
                rule_type,
                action_code
        from   ece_column_rules
        where  interface_column_id = p_interface_column_id
        order  by sequence;

m_count			pls_integer := ec_utils.g_file_tbl.COUNT;
i_count			pls_integer :=0;
j_count			pls_integer :=0;
i_file_count		pls_integer :=0;
i			pls_integer :=0;
j			pls_integer :=0;
k			pls_integer :=0;
i_first_found	BOOLEAN := FALSE;
i_last_found	BOOLEAN := FALSE;
hash_value              pls_integer;		-- Bug 2617428
hash_val                pls_integer;
hash_string             varchar2(3200);
p_count                 pls_integer := 0;
begin

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_EXECUTION_UTILS.LOAD_MAPPINGS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_map_id',i_map_id);

ec_debug.pl(3,'EC','ECE_LOADING_LEVELS','LEVEL','Loading External levels');
end if;
i_count := ec_utils.g_ext_levels.COUNT;
i := i_count;

/**
Set the Stack Pointer for Level 0 to 1..0
**/
ec_utils.g_stack_pointer(0).start_pos :=1;
ec_utils.g_stack_pointer(0).end_pos :=0;

for c1 in external_rec
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
	i_count := i_count + 1;
	ec_utils.g_ext_levels(i_count).external_level := c1.external_level;
	ec_utils.g_ext_levels(i_count).record_number := c1.start_element;
	ec_utils.g_ext_levels(i_count).sql_stmt := NULL;
	ec_utils.g_ext_levels(i_count).cursor_handle := 0;
	ec_utils.g_ext_levels(i_count).file_start_pos := 0;
	ec_utils.g_ext_levels(i_count).file_end_pos := 0;
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'External Level ('||i_count||')',ec_utils.g_ext_levels(i_count).external_level);

	ec_debug.pl(3,'EC','ECE_LOADING_LEVELS','LEVEL','Loading Levels Matrices');
end if;

	j_count := ec_utils.g_int_ext_levels.COUNT;
	j := j_count;
	for c3 in interface_external_rec
		(
		p_external_id => c1.external_level_id
		)
	loop
		j_count := j_count + 1;
		ec_utils.g_int_ext_levels(j_count).interface_level := c3.output_level;
		ec_utils.g_int_ext_levels(j_count).external_level := c1.external_level;
                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'Internal Level '||c3.Output_level||' External Level '||c1.External_level);
                end if;
	end loop;

	/**
	Check for Seed Data. If not Found then , then do not process.
	**/
	if j_count = j
	then
       		ec_debug.pl(0,'EC','ECE_SEED_DATA_MISSING','TRANSACTION_TYPE',i_transaction_type,'MAPID',i_map_id);
       		/**
       		Set the Retcode for the Concurrent Manager
       		**/
       		ec_utils.i_ret_code := 2;
       		raise ec_utils.program_exit;
	end if;

end loop;

/**
Check for Seed Data. If not Found then , then do not process.
**/
if i_count = i
then
       	ec_debug.pl(0,'EC','ECE_SEED_DATA_MISSING','TRANSACTION_TYPE',i_transaction_type,'MAPID',i_map_id);
       	/**
       	Set the Retcode for the Concurrent Manager
       	**/
       	ec_utils.i_ret_code := 2;
       	raise ec_utils.program_exit;
end if;

if EC_DEBUG.G_debug_level >= 3 then
ec_debug.pl(3,'EC','ECE_LOADING_LEVELS','LEVEL','Loading Internal Levels');
end if;
i_count :=ec_utils.g_int_levels.COUNT;
k := i_count;
for c2 in interface_rec
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
	i_count := ec_utils.g_int_levels.COUNT + 1;
	ec_utils.g_int_levels(i_count).interface_level := c2.output_level;
	ec_utils.g_int_levels(i_count).base_table_name := c2.interface_table_name;
	ec_utils.g_int_levels(i_count).parent_level := c2.parent_level;
	ec_utils.g_int_levels(i_count).key_column_name := c2.key_column_name;
	ec_utils.g_int_levels(i_count).cursor_handle := 0;
	ec_utils.g_int_levels(i_count).rows_processed := 0;
	ec_utils.g_int_levels(i_count).file_start_pos := 1;
	ec_utils.g_int_levels(i_count).file_end_pos := 0;
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'Internal Level ('||i_count||') Object Name: '
			||ec_utils.g_int_levels(i_count).base_table_name||
			' Parent Level '||ec_utils.g_int_levels(i_count).parent_level);
end if;
	i_file_count := m_count;
	i_first_found := FALSE;

	for c4 in mapping_rec
		(
		c2.interface_table_id,
		i_map_id
		)
	loop
		m_count := ec_utils.g_file_tbl.COUNT + 1;
		/**
		Set the File Pointer now
		**/
		if NOT (i_first_found)
		then
			i_first_found := TRUE;
			ec_utils.g_int_levels(i_count).file_start_pos := m_count;
		end if;

		ec_utils.g_file_tbl(m_count).interface_level := c2.output_level;
		ec_utils.g_file_tbl(m_count).interface_column_id := c4.interface_column_id;
		ec_utils.g_file_tbl(m_count).interface_column_name := c4.interface_column_name;
		ec_utils.g_file_tbl(m_count).base_column_name := c4.base_column_name;
		ec_utils.g_file_tbl(m_count).conversion_sequence := c4.conversion_sequence;
		ec_utils.g_file_tbl(m_count).conversion_group_id := c4.conversion_group_id;
		ec_utils.g_file_tbl(m_count).xref_category_id := c4.xref_category_id;
		ec_utils.g_file_tbl(m_count).xref_category_allowed := c4.xref_category_allowed;
		ec_utils.g_file_tbl(m_count).xref_key1_source_column := c4.xref_key1_source_column;
		ec_utils.g_file_tbl(m_count).xref_key2_source_column := c4.xref_key2_source_column;
		ec_utils.g_file_tbl(m_count).xref_key3_source_column := c4.xref_key3_source_column;
		ec_utils.g_file_tbl(m_count).xref_key4_source_column := c4.xref_key4_source_column;
		ec_utils.g_file_tbl(m_count).xref_key5_source_column := c4.xref_key5_source_column;
		ec_utils.g_file_tbl(m_count).staging_column := c4.staging_column;
		ec_utils.g_file_tbl(m_count).data_type := c4.data_type;
		ec_utils.g_file_tbl(m_count).width := c4.width;
		ec_utils.g_file_tbl(m_count).record_layout_code := c4.record_layout_code;
		ec_utils.g_file_tbl(m_count).record_layout_qualifier := c4.record_layout_qualifier;
		ec_utils.g_file_tbl(m_count).record_number := c4.record_number;
		ec_utils.g_file_tbl(m_count).position := c4.position;
		ec_utils.g_file_tbl(m_count).element_tag_name := c4.element_tag_name;
		ec_utils.g_file_tbl(m_count).external_level := c4.external_level;

            if EC_DEBUG.G_debug_level = 3 then
		ec_debug.pl(3,
			m_count||' '||
			ec_utils.g_file_tbl(m_count).interface_level||' '||
			ec_utils.g_file_tbl(m_count).external_level||' '||
			ec_utils.g_file_tbl(m_count).interface_column_id||' '||
			ec_utils.g_file_tbl(m_count).interface_column_name||' '||
			ec_utils.g_file_tbl(m_count).base_column_name||' '||
			ec_utils.g_file_tbl(m_count).staging_column||' '||
			ec_utils.g_file_tbl(m_count).data_type||' '||
			ec_utils.g_file_tbl(m_count).width||' '||
			ec_utils.g_file_tbl(m_count).record_layout_code||' '||
			ec_utils.g_file_tbl(m_count).record_layout_qualifier||' '||
			ec_utils.g_file_tbl(m_count).record_number||' '||
			ec_utils.g_file_tbl(m_count).position||' '||
			ec_utils.g_file_tbl(m_count).element_tag_name||' '||
			ec_utils.g_file_tbl(m_count).conversion_sequence||' '||
			ec_utils.g_file_tbl(m_count).conversion_group_id||' '||
			ec_utils.g_file_tbl(m_count).xref_category_id||' '||
			ec_utils.g_file_tbl(m_count).xref_category_allowed||' '||
			ec_utils.g_file_tbl(m_count).xref_key1_source_column||' '||
			ec_utils.g_file_tbl(m_count).xref_key2_source_column||' '||
			ec_utils.g_file_tbl(m_count).xref_key3_source_column||' '||
			ec_utils.g_file_tbl(m_count).xref_key4_source_column||' '||
			ec_utils.g_file_tbl(m_count).xref_key5_source_column
			);
                   end if;

          /* Bug 1853627
                Added the following code which will be used by Validate
		Column Rules later in the inbound processing.
	  */
          -- Bug 2112028 - Added the rownum condition in the following query

	  /* Bug 2708573
          begin
                select 'Y'
	        into ec_utils.g_file_tbl(m_count).column_rule_flag
		from ece_column_rules
		where interface_column_id = c4.interface_column_id
                and rownum = 1;
	  exception
	    when no_data_found then
		ec_utils.g_file_tbl(m_count).column_rule_flag := 'N';
	  end;
	  */

          -- Bug 2708573
          for c5 in c_col_rule_info
             (
              c4.interface_column_id
             )
          loop
                ec_utils.g_column_rule_tbl(m_count).column_rule_id     := c5.column_rule_id;
                ec_utils.g_column_rule_tbl(m_count).rule_type          := c5.rule_type;
                ec_utils.g_column_rule_tbl(m_count).action_code        := c5.action_code;
                ec_utils.g_column_rule_tbl(m_count).level              := c4.external_level;
          end loop;

         -- Bug 2617428.
         -- Build hash table to store positions of columns requiring code conversion.
	 -- Bug 2791195: Modified the hash string and used dbms_utility to create hash table..
         if c4.conversion_group_id IS NOT NULL then
            hash_string:=to_char(c4.conversion_group_id)||'-'||
		         to_char(c4.external_level)||'-'||
		         to_char(c4.conversion_sequence);
            hash_value := dbms_utility.get_hash_value(hash_string,1,8192);
	    if ec_utils.g_code_conv_pos_tbl_1.exists(hash_value) then
                if ec_utils.g_code_conv_pos_tbl_1(hash_value).occr=1 then
                        p_count:=ec_utils.g_code_conv_pos_tbl_1(hash_value).value;
                        ec_utils.g_code_conv_pos_tbl_2(p_count):=hash_value;
                        ec_utils.g_code_conv_pos_tbl_1(hash_value).value:=0;
                        ec_utils.g_code_conv_pos_tbl_1(hash_value).start_pos:=p_count;
                end if;
                ec_utils.g_code_conv_pos_tbl_1(hash_value).occr:=
                                ec_utils.g_code_conv_pos_tbl_1(hash_value).occr +1;
                ec_utils.g_code_conv_pos_tbl_2(m_count):=hash_value;
            else
                ec_utils.g_code_conv_pos_tbl_1(hash_value).value:=m_count;
                ec_utils.g_code_conv_pos_tbl_1(hash_value).occr:=1;
                ec_utils.g_code_conv_pos_tbl_1(hash_value).value:=m_count;
            end if;
         end if;

         -- Build hash table to store positions of columns in g_file_tbl.
	 -- bug 2721631
         hash_string:=to_char(c4.external_level)||'-'||upper(c4.interface_column_name);
         hash_val  := dbms_utility.get_hash_value(hash_string,1,8192);

	 -- Bug 2834366
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

	end loop;

	/**
	Stub for calling ACTION TYPE = 110
	Applicable only for Inbound
	**/

	if ec_utils.g_direction = 'I'
	then
		load_mandatory_columns(i_count);
	end if;


	if i_file_count = m_count
	then
       		ec_debug.pl(0,'EC','ECE_SEED_NOT_LEVEL','TRANSACTION_TYPE',i_transaction_type,'LEVEL',c2.output_level);
       		/**
       		Set the Retcode for the Concurrent Manager to Error.
       		**/
       		ec_utils.i_ret_code := 2;
       		raise EC_UTILS.PROGRAM_EXIT;
	end if;

	/**
	Update the File/Stack pointer for Internal Levels over here.
	**/
	ec_utils.g_int_levels(i_count).file_end_pos := ec_utils.g_file_tbl.COUNT;
	if ec_utils.g_direction = 'O'
	then
		ec_utils.g_stack_pointer(i_count).start_pos :=1;
		ec_utils.g_stack_pointer(i_count).end_pos :=0;
	end if;
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'EC','ECE_INT_FILE_START','LEVEL',i_count,'POSITION',
			ec_utils.g_int_levels(i_count).file_start_pos);
	ec_debug.pl(3,'EC','ECE_INT_FILE_END','LEVEL',i_count,'POSITION',
			ec_utils.g_int_levels(i_count).file_end_pos);
end if;

end loop;

/**
Check for Seed Data. If not Found then , then do not process.
**/
if i_count = k
then
       	ec_debug.pl(0,'EC','ECE_SEED_DATA_MISSING','TRANSACTION_TYPE',i_transaction_type,'MAPID',i_map_id);
       	/**
       	Set the Retcode for the Concurrent Manager
       	**/
       	ec_utils.i_ret_code := 2;
       	raise ec_utils.program_exit;
end if;

/**
Update the File_pointer for External Levels over here.
**/
if ec_utils.g_direction = 'I'
then
for i in 1..ec_utils.g_ext_levels.COUNT
loop
	i_first_found := FALSE;
	i_last_found := FALSE;
	for j in 1..ec_utils.g_file_tbl.COUNT
	loop
		if ec_utils.g_file_tbl(j).external_level is null
		then
			ec_utils.i_ret_code := 2;
			ec_debug.pl(0,'EC','ECE_EXTERNAL_LEVELS_NULL','External Level is NULL');
			raise EC_UTILS.PROGRAM_EXIT;
		end if;
		if ec_utils.g_file_tbl(j).external_level = i
		then
			if NOT (i_first_found)
			then
				i_first_found := TRUE;
				ec_utils.g_ext_levels(i).file_start_pos := j;
			else
				if j < ec_utils.g_file_tbl.COUNT
				then
					if ec_utils.g_file_tbl(j+1).external_level <> i
					then
						i_last_found := TRUE;
						ec_utils.g_ext_levels(i).file_end_pos := j;
						exit;
					end if;
				else
					i_last_found := TRUE;
					ec_utils.g_ext_levels(i).file_end_pos := j;
					exit;
				end if;
			end if;
		end if;
	end loop;

	if (i_first_found) and NOT (i_last_found)
	then
		ec_utils.g_ext_levels(i).file_end_pos := ec_utils.g_ext_levels(i).file_start_pos;
	end if;
if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'EC','ECE_EXT_FILE_START','LEVEL',i,'POSITION',ec_utils.g_ext_levels(i).file_start_pos);
	ec_debug.pl(3,'EC','ECE_EXT_FILE_END','LEVEL',i,'POSITION',ec_utils.g_ext_levels(i).file_end_pos);
end if;
	ec_utils.g_stack_pointer(i).start_pos :=1;
	ec_utils.g_stack_pointer(i).end_pos :=0;
end loop;
end if;


		/**
		Load the Custom procedures and their Mappings
		**/
		load_procedure_definitions;

		load_procedure_mappings
                (
                ec_utils.g_transaction_type
                );

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_EXECUTION_UTILS.LOAD_MAPPINGS');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_EXECUTION_UTILS.LOAD_MAPPINGS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end load_mappings;

end ec_execution_utils;

/
