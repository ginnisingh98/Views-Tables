--------------------------------------------------------
--  DDL for Package Body ECX_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_OUTBOUND" as
-- $Header: ECXOUBXB.pls 120.12 2006/12/18 09:40:38 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

TYPE l_stack is table of pls_integer index by binary_integer;
i_stack		l_stack;

/**
stage 10 - Pre-Processing
stage 20 - In-Processing
stage 30 - Post-Processing
**/

procedure move_from_source_to_target
	(
	i_target_level	IN	pls_integer
	)
is

i_method_name   varchar2(2000) := 'ecx_outbound.move_from_source_to_target';
i	pls_integer;
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_target_level',i_target_level,i_method_name);
end if;
/**
Move the Values from Source to the Target
**/

for i in ecx_utils.g_target_levels(i_target_level).file_start_pos..ecx_utils.g_target_levels(i_target_level).file_end_pos
loop
	/** Do a Clean up for the Target **/
	ecx_utils.g_target(i).value := null;

        /** Change required for Clob Support -- 2263729 ***/
	ecx_utils.g_target(i).clob_value := null;
	ecx_utils.g_target(i).clob_length := null;
        ecx_utils.g_target(i).is_clob := null;

	if ecx_utils.g_target(i).map_attribute_id is not null
	then
            /** Change required for Clob Support -- 2263729 **/
            if (ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).data_type  = 112) Then
                ecx_utils.g_target(i).clob_length :=  ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).clob_length;
                ecx_utils.g_target(i).is_clob     :=  ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).is_clob;

               if (ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).clob_length > ecx_utils.G_CLOB_VARCHAR_LEN)
               Then

                ecx_utils.g_target(i).clob_value  :=  ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).clob_value;
               else
		ecx_utils.g_target(i).value :=
			ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).value;
               end if;
            else
               ecx_utils.g_target(i).value :=
                        ecx_utils.g_source(ecx_utils.g_target(i).map_attribute_id).value;
	    end if;
 	end if;

       	/** If the value is null then assign the target default value
	If ecx_utils.g_target(i).value is null
	then
	        ecx_utils.g_target(i).value := ecx_utils.g_target(i).default_value;
	End if;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement, ecx_utils.g_target(i).attribute_name,ecx_utils.g_target(i).value,
	               i_method_name);
	end if;
	End if;
	**/

	If ecx_utils.g_target(i).clob_value is not null Then
	     if(l_statementEnabled) then
		ecx_debug.log(l_statement,i||'=>'||ecx_utils.g_target(i).parent_attribute_id||'=>'||
		             ecx_utils.g_target(i).attribute_type||'=>'||
	                     ecx_utils.g_target(i).attribute_name,ecx_utils.g_target(i).clob_value,
			     i_method_name);
             end if;
	else
        	-- if clob_value is null this means that it is varchar2
	       /** If the value is null then assign the target default value **/
	        If ecx_utils.g_target(i).value is null
	        then
		        ecx_utils.g_target(i).value := ecx_utils.g_target(i).default_value;
	        End if;
		if(l_statementEnabled) then
	          ecx_debug.log(l_statement,i||'=>'||ecx_utils.g_target(i).parent_attribute_id||'=>'||
		             ecx_utils.g_target(i).attribute_type||'=>'||
	                     ecx_utils.g_target(i).attribute_name,ecx_utils.g_target(i).value,
			     i_method_name);
                end if;
        End If;
end loop;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when others then
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
	             'ECX_OUTBOUND.MOVE_FROM_SOURCE_TO_TARGET');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
        end if;
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.MOVE_FROM_SOURCE_TO_TARGET');
	if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.MOVE_FROM_SOURCE_TO_TARGET',
	               i_method_name);
	end if;
	if (l_procedureEnabled) then
	  ecx_debug.pop(i_method_name);
	end if;
        raise ecx_utils.PROGRAM_EXIT;
end move_from_source_to_target;

procedure processTarget
	(
	i_target	in	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_outbound.processtarget';
i_init_msg_list		varchar2(20);
i_simulate		varchar2(20);
i_validation_level	varchar2(20);
i_commit		varchar2(20);
i_return_status		varchar2(20);
i_msg_count		varchar2(20);
i_msg_data		varchar2(2000);

begin

if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_target',i_target,i_method_name);
end if;

	-- don't need t execute stage 10, level 0 action for target as this is
	-- already done in the initilization phase
        if (i_target <> 0)
        then
	   -- Pre-Processing Stage for Target
           ecx_actions.execute_stage_data ( 10, i_target, 'T');
        end if;

	/** Move the Values from Source to the Target **/
	move_from_source_to_target(i_target);

	-- In Processing Stage for Target
	   ecx_actions.execute_stage_data ( 20, i_target, 'T');

	ecx_print_local.print_new_level
		(
		i_target,
		ecx_utils.g_target_levels(i_target).dtd_node_index
		);

        if (i_target <> 0)
        then
	   -- Post Processing Stage for Target
	   ecx_actions.execute_stage_data ( 30, i_target, 'T');
        end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

exception
when ecx_utils.program_exit then
        ecx_debug.pop('ECX_OUTBOUND.processTarget');
        raise ecx_utils.program_exit;
when others then
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
	             'ECX_OUTBOUND.PROCESSTARGET');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
        end if;
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PROCESSTARGET');
	if(l_unexpectedEnabled) then
	  ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_OUTBOUND.PROCESSTARGET',
	               i_method_name);
        end if;
	if (l_procedureEnabled) then
	  ecx_debug.pop(i_method_name);
	end if;
        raise ecx_utils.PROGRAM_EXIT;
end processTarget;

procedure process_data
	(
	i		IN	pls_integer,
	i_stage		in	pls_integer ,
	i_next		IN	pls_integer
	)
is

        i_method_name   varchar2(2000) := 'ecx_outbound.process_data';
	i_init_msg_list         varchar2(20);
	i_simulate              varchar2(20);
	i_validation_level      varchar2(20);
	i_commit                varchar2(20);
	i_return_status         varchar2(20);
	i_msg_count             varchar2(20);
	i_msg_data	        varchar2(2000);
        j                       pls_integer;
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i',i,i_method_name);
  ecx_debug.log(l_statement,'i_stage',i_stage,i_method_name);
  ecx_debug.log(l_statement,'i_next',i_next,i_method_name);
end if;

if i < 0
then
        if (l_procedureEnabled) then
	  ecx_debug.pop(i_method_name);
	end if;
	return;
end if;

if i_stage = 10
then

	/** Should clean up the Current Source and the down levels first**/
	for k in i..ecx_utils.g_source_levels.last
	loop
		for j in ecx_utils.g_source_levels(k).file_start_pos..ecx_utils.g_source_levels(k).file_end_pos
       		loop
			if ecx_utils.g_source(j).default_value is null
			then
       				ecx_utils.g_source(j).value := null;
                                ecx_utils.g_source(j).clob_value := null;
                                ecx_utils.g_source(j).is_clob    := null;
                                ecx_utils.g_source(j).clob_length := null;
			else
       				ecx_utils.g_source(j).value := ecx_utils.g_source(j).default_value;
			end if;
			if(l_statementEnabled) then
   			  ecx_debug.log(l_statement,'Source '||ecx_utils.g_source(j).attribute_name,
			               ecx_utils.g_source(j).value,i_method_name);
			end if;
		end loop;
	end loop;

         -- For level 0 this is already done in the initialization
         if (i <> 0)
         then
	   /** Execute the pre-processing for the Source **/
            ecx_actions.execute_stage_data (i_stage, i, 'S');
         end if;
end if;

if i_stage = 20
then
	-- Perform Code Conversion
	ecx_code_conversion_pvt.populate_plsql_tbl_with_extval
		(
		p_api_version_number 	=> 1.0,
		p_init_msg_list		=> i_init_msg_list,
		p_simulate		=> i_simulate,
		p_commit		=> i_commit,
		p_validation_level	=> i_validation_level,
		p_return_status		=> i_return_status,
		p_msg_count		=> i_msg_count,
		p_msg_data		=> i_msg_data,
		p_level			=> i,
		p_tbl			=> ecx_utils.g_source,
		p_tp_id			=> ecx_utils.g_rec_tp_id,
		p_standard_id		=> ecx_utils.g_standard_id
		);

	--Check the Status of the Code Conversion API and take appropriate action.
	IF 	(
		i_return_status = ecx_code_conversion_pvt.G_RET_STS_ERROR OR
		i_return_status is NULL OR
		i_return_status = ecx_code_conversion_pvt.G_RET_STS_UNEXP_ERROR
		)
	THEN
	        if(l_statementEnabled) then
                     ecx_debug.log(l_statement,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
	                         'ECX_OUTBOUND.PROCESS_DATA');
		     ecx_debug.log(l_statement,'ECX','EC_CODE_CONVERSION_FAILED',i_method_name,'LEVEL',i);
		 end if;
		ecx_utils.i_ret_code := 2;
		RAISE ecx_utils.PROGRAM_EXIT;
	END IF;

	/** Execute the In-processing for the Source **/
        ecx_actions.execute_stage_data (i_stage, i, 'S');

	for j in ecx_utils.g_source_levels(i).first_target_level .. ecx_utils.g_source_levels(i).last_target_level
	loop
		/** Initialize the Target **/
	        for k in ecx_utils.g_target_levels(j).file_start_pos..ecx_utils.g_target_levels(j).file_end_pos
        	loop
			if ecx_utils.g_target(k).default_value is null
			then
           			ecx_utils.g_target(k).value := null;
                               /** Change required for Clob Support -- 2263729 ***/
           			ecx_utils.g_target(k).clob_value := null;
           			ecx_utils.g_target(k).clob_length := null;
                                ecx_utils.g_target(k).is_clob := null;
			else
           			ecx_utils.g_target(k).value := ecx_utils.g_target(k).default_value;
			end if;
			if(l_statementEnabled) then
	   		  ecx_debug.log(l_statement,'target '||ecx_utils.g_target(k).attribute_name,
			               ecx_utils.g_target(k).value,i_method_name);
	                end if;
		end loop;
	   end loop;

	   /** Check for Collapsion. Do depth checking for Collapsion only **/
	   if(l_statementEnabled) then
	     ecx_debug.log(l_statement,'Previous Level',i,i_method_name);
	     ecx_debug.log(l_statement,'Current Level',i_next,i_method_name);
           end if;

	   if ( ecx_utils.g_source_levels(i).last_source_level -
		ecx_utils.g_source_levels(i).first_source_level > 0 )
	   then
		if i_next > i
		then
			if 	( i_next >= ecx_utils.g_source_levels(i).first_source_level )
				and
				( i_next <= ecx_utils.g_source_levels(i).last_source_level )
			then
			        if(l_statementEnabled) then
				  ecx_debug.log(l_statement,'Skipping Source',i,i_method_name);
				 end if;
			else
				processTarget(ecx_utils.g_source_levels(i).first_target_level);
			end if;
		end if;

		if i_next <= i
		then
				processTarget(ecx_utils.g_source_levels(i).first_target_level);
		end if;
	   else
		/** Else Expansion or 1-1 mapping **/
		for j in ecx_utils.g_source_levels(i).first_target_level .. ecx_utils.g_source_levels(i).last_target_level
		loop
			processTarget(j);
	end loop;
     end if;
end if;

if i_stage = 30
then
         -- For level 0 this will be done in the end
         if (i <> 0)
         then
	    /** Execute the Post-processing for the Source **/
           ecx_actions.execute_stage_data (30, i, 'S');
        end if;

        /*
        Before doing a stage 30 for level we need to print any remaning discontinuous elements
        for this level. This way if another occurrance of this level arrives the data for the
        discontinuous elements will be printed before it gets overwritten.
        */

        -- for all the target levels mapped to this source level print the discont elements
        j := ecx_utils.g_source_levels(i).last_target_level;
	if (l_statementEnabled) then
          ecx_debug.log(l_statement,'last target level', ecx_utils.g_source_levels(i).last_target_level,i_method_name);
          ecx_debug.log(l_statement, 'first target level', ecx_utils.g_source_levels(i).first_target_level,
	               i_method_name);
	end if;
        while (j >= ecx_utils.g_source_levels(i).first_target_level)
        loop
                ecx_print_local.print_discont_elements(ecx_print_local.last_printed + 1,
                          ecx_utils.g_target_levels(j).file_end_pos,
                          ecx_utils.g_target(ecx_utils.g_target_levels(j).file_start_pos).attribute_id,
                                j);
                j := j - 1;
	end loop;
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
	end if;
        raise ecx_utils.program_exit;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PROCESS_DATA');
	if(l_unexpectedEnabled) then
	  ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_OUTBOUND.PROCESS_DATA',i_method_name);
	end if;
	if (l_procedureEnabled) then
		ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end process_data;


procedure print_stack
is
i_method_name   varchar2(2000) := 'ecx_outbound.print_stack';
begin

        if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Stack Status','====',i_method_name);
	end if;
	for i in 1..i_stack.COUNT
	loop
	        if(l_statementEnabled) then
                   ecx_debug.log(l_statement,i_stack(i),i_method_name);
		end if;
	end loop;
exception
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PRINT_STACK');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.PRINT_STACK',i_method_name);
        end if;
	raise ecx_utils.program_exit;
end print_stack;

procedure pop
	(
	i_next	in	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_outbound.pop';

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name );
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_next',i_next,i_method_name);
  print_stack;
end if;

	if i_stack.COUNT = 0
	then
	        if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Stack Error. Nothing to pop','xxxxx',i_method_name);
		end if;
		if (l_procedureEnabled) then
		  ecx_debug.pop(i_method_name);
		end if;
		return;
	end if;

	/** Post Process and then pop. **/
	process_data(i_stack(i_stack.COUNT),30,i_next);

	i_stack.delete(i_stack.COUNT);

	if(l_statementEnabled) then
		print_stack;
	end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name );
end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.POP');
	if(l_unexpectedEnabled) then
	  ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_OUTBOUND.POP',i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end pop;

procedure push
	(
	i	in	pls_integer
	)
is

i_method_name   varchar2(2000) := 'ecx_outbound.push';
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
	if(l_statementEnabled) then
	  ecx_debug.log(l_statement,i,i_method_name);
	  print_stack;
	end if;

	if i_stack.COUNT = 0
	then
		-- Nothing on the Stack. Push the value
		i_stack(i_stack.COUNT+1):=i;

		/** pre stage processing **/
		process_data(i_stack(i_stack.COUNT),10,i);

		if(l_statementEnabled) then
			print_stack;
		end if;

		if (l_procedureEnabled) then
		  ecx_debug.pop(i_method_name);
		end if;

		return;
	end if;

	if i > i_stack(i_stack.COUNT)
	then
		/** In stage processing **/
		process_data(i_stack(i_stack.COUNT),20,i);

		-- Push
		i_stack(i_stack.COUNT+1):=i;

		/** pre stage processing **/
		process_data(i_stack(i_stack.COUNT),10,i);

		if(l_statementEnabled) then
			print_stack;
		end if;

		if (l_procedureEnabled) then
		  ecx_debug.pop(i_method_name);
		end if;
		return;
	end if;

	if i = i_stack(i_stack.COUNT)
	then
		/** In-Processing and then pop the Top Entry. **/
		process_data(i_stack(i_stack.COUNT),20,i);
		pop(i);
	end if;

	if i_stack.COUNT <> 0
	then
		if i < i_stack(i_stack.COUNT)
		then

			/** In-Processing and then pop the Top Entry. **/
			process_data(i_stack(i_stack.COUNT),20,i);
			pop(i);

			/** Pop The rest of the Elements **/
			while ( i <= i_stack(i_stack.COUNT) )
			loop
				pop(i);
				exit when i_stack.COUNT = 0;
			end loop;

		end if;
	end if;

	-- Push the value
	i_stack(i_stack.COUNT+1):=i;
	/** pre stage processing **/
	process_data(i_stack(i_stack.COUNT),10,i);


	if(l_statementEnabled) then
		print_stack;
	end if;

if (l_procedureEnabled) then
	ecx_debug.pop(i_method_name);
end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
	end if;
        raise ecx_utils.program_exit;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PUSH');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.PUSH',i_method_name);
	end if;
	if (l_procedureEnabled) then
	  ecx_debug.pop(i_method_name);
	end if;
	raise ecx_utils.program_exit;
end push;


procedure popall
is
i_method_name   varchar2(2000) := 'ecx_outbound.popall';
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name );
end if;
	/** In-Process the last Level on the Stack **/
	if i_stack.COUNT <> 0
	then
		process_data(i_stack(i_stack.COUNT),20,0);
	end if;

	if(l_statementEnabled) then
		print_stack;
	end if;

	while ( i_stack.COUNT > 0)
	loop
		pop(0);
	end loop;

	if(l_statementEnabled) then
		print_stack;
	end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name );
end if;

exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name );
        end if;
        raise ecx_utils.program_exit;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.POPALL');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.POPALL',i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name );
        end if;
	raise ecx_utils.program_exit;
end popall;

/**
Fetches data from the ec_views recurrsively for a given document.
**/
procedure fetch_data_from_view
	(
	i_level		IN	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_outbound.fetch_data_from_view';
i_column_counter	pls_integer :=0;
i_rows_processed	pls_integer ;
i_start_element		varchar2(2000);
j                       pls_integer;
i_count			pls_integer;
l_clob                  clob;
i_len                   pls_integer;
BEGIN
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name );
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_level',i_level,i_method_name);
  ecx_debug.log(l_statement,'Source level',ecx_utils.g_source_levels.COUNT,i_method_name);
  ecx_debug.log(l_statement,'target_source_levels',ecx_utils.g_target_source_levels.COUNT,i_method_name);
end if;
-- push root element on stack
if (i_level = 0)
then
	push(i_level);
end if;

for i in 1..ecx_utils.g_source_levels.last
loop
	IF ecx_utils.g_source_levels(i).parent_level = i_level
	THEN
	        if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'SQL Statement',ecx_utils.g_source_levels(i).sql_stmt,i_method_name);
		end if;
		-- Set the Global Variable for Current Level
		ecx_utils.g_current_level := i;

		/* Bind the Variables for the Where Clause */
		ecx_actions.bind_variables_for_view(10,i);
		i_rows_processed := dbms_sql.execute (ecx_utils.g_source_levels(i).Cursor_Handle);
		if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'Cursor Handle',ecx_utils.g_source_levels(i).Cursor_handle,
		                i_method_name);
		end if;


		while (dbms_sql.fetch_rows( ecx_utils.g_source_levels(i).Cursor_handle) > 0)
		LOOP
			push(i);

                        if(l_statementEnabled) then
                           ecx_debug.log(l_statement,'Executing Fetch Rows',i_method_Name);
			end if;

			-- Get Values from the View
			-- Initialize the Column Counter
			i_column_counter :=0;
                       	j := ecx_utils.g_source_levels(i).file_start_pos;
			loop
                       		if (ecx_utils.g_source(j).external_level = i)
				then
					i_column_counter := i_column_counter + 1;

                                        if ecx_utils.g_source(j).data_type <> 112 Then
                                           dbms_sql.column_value
                                                (
                                                  ecx_utils.g_source_levels(i).Cursor_handle,
                                                  i_column_counter,
                                                  ecx_utils.g_source(j).value
                                                );
                                         else
					   dbms_sql.column_value
						(
						ecx_utils.g_source_levels(i).Cursor_handle,
						i_column_counter,
						ecx_utils.g_source(j).clob_value
						);
                                           /** Change required for Clob Support -- 2263729 ***/
                                           ecx_utils.g_source(j).clob_length := dbms_lob.getlength( ecx_utils.g_source(j).clob_value);
                                           i_len := ecx_utils.g_source(j).clob_length;

                                           ecx_utils.g_source(j).is_clob := 'N';

                                           If i_len <= ecx_utils.G_CLOB_VARCHAR_LEN Then
                                                ecx_utils.g_source(j).is_clob := 'Y';   /** To indicate value has a shorter string of clob value ***/
			                         ecx_utils.g_source(j).value :=
                                                     dbms_lob.substr(ecx_utils.g_source(j).clob_value,i_len,1);
                                                ecx_utils.g_source(j).clob_value := null ;
                                                ecx_utils.g_source(j).clob_length := null ;
	                                     End If;
                                        end if;

					/** If the value is null set the default value **/
					if ecx_utils.g_source(j).value is null
					then
						ecx_utils.g_source(j).value := ecx_utils.g_source(j).default_value;
					end if;

					if(l_statementEnabled) then
						if ecx_utils.g_source(j).base_column_name is not null
						then
						   /**  Change required for Clob Support -- 2263729 ***/
						   if ecx_utils.g_source(j).data_type = 112 Then
								if ecx_utils.g_source(j).clob_value is null Then

									ecx_debug.log(l_statement,
									ecx_utils.g_source(j).base_column_name,
									ecx_utils.g_source(j).value,
									i_method_name
									);

								else

									ecx_debug.log(l_statement,
									ecx_utils.g_source(j).base_column_name,
									ecx_utils.g_source(j).clob_value,
									i_method_name
									);
								end if;
						   else

								ecx_debug.log(l_statement,
								ecx_utils.g_source(j).base_column_name,
								ecx_utils.g_source(j).value,
								i_method_name
								);
						   End If;
						end if;
					end if;
                        	end if;
                             	exit when j = ecx_utils.g_source_levels(i).file_end_pos;
                             	j := ecx_utils.g_source.next(j);
			end loop;
			if(l_statementEnabled) then
			  ecx_debug.log(l_statement,'All Rows fetched',i_method_name);
                        end if;


			i_count :=0;
                        if (ecx_utils.g_source_levels.count <> 0)
			then
			   for m in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
			   loop
			        if(l_statementEnabled) then
                                   ecx_debug.log(l_statement,'Source level '||m,'Parent level'||ecx_utils.g_source_levels(m).parent_level,
					       i_method_name);
				end if;
				if ecx_utils.g_source_levels(m).parent_level=i
				then
					i_count := i_count+1;
				end if;
			   end loop;
                        end if;
			if(l_statementEnabled) then
                          ecx_debug.log(l_statement,'i_count',i_count,i_method_name);
                        end if;

			if i_count > 0
			then
				fetch_data_from_view(i);
			end if;

		END LOOP;
		if i = 1
		then
			ecx_utils.g_source_levels(i).rows_processed := dbms_sql.last_row_count;
		else
			ecx_utils.g_source_levels(i).rows_processed :=
			ecx_utils.g_source_levels(i).rows_processed + dbms_sql.last_row_count;
		end if;
	END IF;
end loop;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name );
end if;
EXCEPTION
WHEN invalid_number then
  if(l_unexpectedEnabled) then
    ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,
	             'PROGRESS_LEVEL','ECX_OUTBOUND.FETCH_DATA_FROM_VIEW');
    ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,
	              'ERROR_MESSAGE',SQLERRM);
  end if;
  ecx_debug.setErrorInfo(2,30,'ECX_INVALID_NUMBER - ECX_OUTBOUND.FETCH_DATA_FROM_VIEW' );
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
  raise ecx_utils.program_exit;
WHEN ecx_utils.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
	             'ECX_OUTBOUND.FETCH_DATA_FROM_VIEW');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
        end if;
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.FETCH_DATA_FROM_VIEW');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_OUTBOUND.FETCH_DATA_FROM_VIEW',
		       i_method_name);
	end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name );
        end if;
        raise ecx_utils.PROGRAM_EXIT;
END fetch_data_from_view;

procedure log_summary(level pls_integer)
is
i_method_name varchar2(2000);
begin
	i_method_name:='ecx_outbound.log_summary';
        if (l_procedureEnabled) then
          ecx_debug.push(i_method_name);
        end if;

	ecx_debug.log(level,'Processing Summary','====',i_method_name);
	if (ecx_utils.g_source_levels.count <> 0)
	then
	   for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
	   loop
		ecx_debug.log(level,ecx_utils.g_source_levels(i).rows_processed||
			     ' row(s) processed for Level : '|| ecx_utils.g_source_levels(i).start_element
			     || '('|| i || ') ',i_method_name);
	   end loop;
	end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
exception
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.LOG_SUMMARY');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.LOG_SUMMARY',i_method_name);
	end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

	raise ecx_utils.program_exit;
end log_summary;

/**
Main Call for Processing Outbound Documents
**/
procedure process_outbound_documents
	(
	i_message_standard	IN	varchar2,
	i_transaction_type	IN	varchar2,
	i_transaction_subtype	IN	varchar2,
	i_tp_id			IN	varchar2,
	i_tp_site_id		IN	varchar2,
	i_tp_type		In	varchar2,
	i_document_id		IN	varchar2,
	i_map_code		IN	varchar2,
	i_xmldoc		IN OUT	NOCOPY clob,
        i_message_type          IN      varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_outbound.process_outbound_documents';

i_msgid			raw(16);
i_dtd_id		pls_integer;
i_run_id		pls_integer;
i_variable_found	BOOLEAN := TRUE;
i_stack_pos		pls_integer;
i_fullpath		ecx_objects.fullpath%TYPE;
i_root_element		ecx_objects.root_element%TYPE;
i_filename		varchar2(200);
i_temp			varchar2(32767);
i_logdir                varchar2(200);
x_same_map		BOOLEAN := FALSE;
i_tp_header_id		pls_integer;
i_map_id		pls_integer;
i_standard_id		pls_integer;
i_parameterlist		wf_parameter_list_t;
i_parameter		wf_parameter_t;
counter number;
i_paramCount     number;
i_stack_param_name 	VARCHAR2(2000);
i_stack_param_value 	VARCHAR2(4000);
i_param_name       	VARCHAR2(30);
i_mode                  varchar2(10) := 'FALSE';
l_IANAcharset           varchar2(2000);
l_xmldecl               varchar2(4000);
l_parseXML              boolean;
l_value                 number;
i_node_type             pls_integer;

attachment_id pls_integer;
ctemp              varchar2(32767);
clength            pls_integer;
offset            pls_integer := 1;
g_varmaxlength     pls_integer := 1999;
g_instlmode         VARCHAR2(100);

begin


if (l_procedureEnabled) then
  ecx_debug.push(i_method_name );
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'ECX','ECX_START_OUTBOUND','MAP_ID',i_map_id,i_method_name);
  ecx_debug.log(l_statement,'i_message_standard',i_message_standard,i_method_name);
  ecx_debug.log(l_statement,'i_transaction_type',i_transaction_type,i_method_name);
  ecx_debug.log(l_statement,'i_transaction_subtype',i_transaction_subtype,i_method_name);
  ecx_debug.log(l_statement,'i_tp_id',i_tp_id,i_method_name);
  ecx_debug.log(l_statement,'i_tp_site_id',i_tp_site_id,i_method_name);
  ecx_debug.log(l_statement,'i_tp_type',i_tp_type,i_method_name);
  ecx_debug.log(l_statement,'i_document_id',i_document_id,i_method_name);
  ecx_debug.log(l_statement,'i_map_code',i_map_code,i_method_name);
end if;

/** check for the Event Object. If null , initialize it **/
if ecx_utils.g_event is null
then
	wf_event_t.initialize(ecx_utils.g_event);
end if;
i_parameterlist := wf_event_t.getParameterList(ecx_utils.g_event);
if(l_statementEnabled) then
	if i_parameterList is not null
	then
		for i in i_parameterList.FIRST..i_parameterList.LAST
		loop
			i_parameter := i_parameterList(i);
			ecx_debug.log(l_statement,i_parameter.getName(),i_parameter.getValue(),i_method_name);
		end loop;
	end if;
end if;


/** Set the GLobal variables **/
ecx_utils.g_transaction_type := i_transaction_type;
ecx_utils.g_transaction_subtype := i_transaction_subtype;
ecx_utils.g_document_id := i_document_id;

	/** Check for Message Standard Code **/
	begin
		select 	standard_id
		into  	i_standard_id
		from  	ecx_standards
		where 	standard_code = i_message_standard
                and     standard_type = nvl(i_message_type, 'XML');

		ecx_utils.g_standard_id := i_standard_id;
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_CODE_CONVERSION_DISABLED',
				      'MESSAGE_STANDARD', i_message_standard);
		if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'ECX', 'ECX_CODE_CONVERSION_DISABLED',i_method_name,
 				      'MESSAGE_STANDARD', i_message_standard);
	        end if;
	end;

	/** Check for Map Code **/
	begin
		select 	map_id
		into  	i_map_id
		from  	ecx_mappings
		where 	map_code = i_map_code;
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_MAP_NOT_FOUND', 'MAP_CODE', i_map_code);
		if(l_unexpectedEnabled) then
                   ecx_debug.log(l_unexpected,'ECX', 'ECX_MAP_NOT_FOUND', i_method_name,'MAP_CODE', i_map_code);
		end if;
		raise ecx_utils.program_exit;
	end;

	/** Check for tp_header_id **/
	begin
		select 	tp_header_id
		into  	i_tp_header_id
		from  	ecx_tp_headers
		where 	party_id = i_tp_id
		and 	party_site_id = i_tp_site_id
		and 	party_type = i_tp_type;

		/** Set the GLobal g_rcv_tp_id **/
		ecx_utils.g_rec_tp_id:= i_tp_header_id;
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_TP_NOT_FOUND', 'PARTY_ID', i_tp_id);
		if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'ECX', 'ECX_TP_NOT_FOUND', i_method_name,'PARTY_ID', i_tp_id);
		end if;
	end;

	begin
		select 	root_element,
			fullpath
		into  	i_root_element,
			i_filename
		from  	ecx_objects eo
		where 	eo.map_id = i_map_id
		and   	eo.object_type in ('DTD','XML')
		and	eo.object_id = 2;
	exception
	when others then
		ecx_debug.setErrorInfo(1, 30, 'ECX_ROOT_ELEMENT_NOT_FOUND', 'MAP_ID', i_map_id);
		if(l_unexpectedEnabled) then
                   ecx_debug.log(l_unexpected,'ECX', 'ECX_ROOT_ELEMENT_NOT_FOUND',i_method_name, 'MAP_ID', i_map_id);
		end if;
		raise ecx_utils.program_exit;
	end;

	/**
	Initialize Memory Structures Set the direction for the Transaction **/
	ecx_utils.g_direction :='OUT';
	ecx_utils.initialize(i_map_id,x_same_map);


	/**
	Find the Stack Variable.If Found set the value.
	**/
			i_variable_found := ecx_actions.find_stack_variable
				(
				'TRANSACTION_TYPE',
				i_stack_pos
				);

			if (i_variable_found AND i_transaction_type is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_transaction_type;
			end if;

			i_variable_found := ecx_actions.find_stack_variable
				(
				'TRANSACTION_SUBTYPE',
				i_stack_pos
				);

			if (i_variable_found AND i_transaction_subtype is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_transaction_subtype;
			end if;


			i_variable_found := ecx_actions.find_stack_variable
				(
				'DOCUMENT_ID',
				i_stack_pos
				);

			if (i_variable_found AND i_document_id is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_document_id;
			end if;

			i_variable_found := ecx_actions.find_stack_variable
				(
				'TP_ID',
				i_stack_pos
				);

			if (i_variable_found AND i_tp_id is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_tp_id;
			end if;

			i_variable_found := ecx_actions.find_stack_variable
				(
				'TP_SITE_ID',
				i_stack_pos
				);

			if (i_variable_found AND i_tp_site_id is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_tp_site_id;
			end if;

			i_variable_found := ecx_actions.find_stack_variable
				(
				'TP_TYPE',
				i_stack_pos
				);

			if (i_variable_found AND i_tp_type is not null)
			then
				ecx_utils.g_stack(i_stack_pos).variable_value := i_tp_type;
			end if;

			/* If the input wf_event_t object passed is null , the following loop raises an exception.
			   so initialize the i_event_obj
			IF ( i_event_obj IS NULL ) THEN
				WF_EVENT_T.initialize(i_event_obj);
			END IF; */

			-- Get the Parameter List from the Global Event Message Object. Iterate through it and populate the
			-- Global variables in the Engine Stack
			if i_parameterlist is not null
			then
				FOR counter in i_parameterList.FIRST..i_parameterList.LAST
				LOOP
					i_parameter := i_parameterList(counter);
					if i_parameter is not null
					then
						i_stack_param_name := i_parameter.getname();
						-- For backward Compatability , if the ECX_PARAMETER1..5 is passed changed it to
						-- PARAMETER1..5
						if i_stack_param_name = 'ECX_PARAMETER1'
						then
							i_stack_param_name := 'PARAMETER1';

						elsif i_stack_param_name = 'ECX_PARAMETER2'
						then
							i_stack_param_name := 'PARAMETER2';

						elsif i_stack_param_name = 'ECX_PARAMETER3'
						then
							i_stack_param_name := 'PARAMETER3';

						elsif i_stack_param_name = 'ECX_PARAMETER4'
						then
							i_stack_param_name := 'PARAMETER4';

						elsif i_stack_param_name = 'ECX_PARAMETER5'
						then
							i_stack_param_name := 'PARAMETER5';
						end if;

						if ( i_stack_param_name is not null)
						then
							i_variable_found := ecx_actions.find_stack_variable
							(
							i_stack_param_name,
							i_stack_pos
							);

							if (i_variable_found)
							then
								i_stack_param_value := i_parameter.getValue();
								/** Only overwrite the Global variable value if not null **/
								if i_stack_param_value is not null
								then
									ecx_utils.g_stack(i_stack_pos).variable_value
										:= i_stack_param_value;
								end if;
							end if;
						end if;
					end if;
				END LOOP;
			end if;
			/* End of changes for bug 2120165 */

	/**
	Should Avoid Parsing and Loading the Next Map if it is same as the previous one.
	**/
	if NOT (x_same_map)
	then
		ecx_utils.load_objects(i_map_id);
	end if;

	if (ecx_utils.g_source_levels.count <> 0)
	then
	   for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
	   loop
		ecx_utils.g_source_levels(i).rows_processed := 0;
	   end loop;
	end if;
	/**
	Initialize the temporary XML Buffer
	**/
	ecx_print_local.i_tmpxml.DELETE;
	ecx_print_local.l_node_stack.DELETE;

         l_IANACharset := ECX_UTIL_API.getIANACharset();
         l_xmlDecl := 'version = "1.0" encoding= "'||l_IANAcharset||'" standalone="no"';

	/** PI Node **/
	--ecx_print_local.pi_node('xml','version = "1.0" standalone="no" ');
        ecx_print_local.pi_node('xml',l_xmlDecl);

	/** Comment Node **/
	ecx_print_local.comment_node('Oracle eXtensible Markup Language Gateway Server ');


	/** DOCUMENT NODE **/
	if (not ecx_utils.g_delete_doctype) then
		ecx_print_local.document_node(i_root_element,i_filename,null);
		if(l_statementEnabled) then
			ecx_debug.log(l_statement, 'Printed DOCTYPE', i_method_name);
		end if;
	end if;

	fetch_data_from_view (0);
	popall;
	ecx_print_local.xmlPOPALL(i_xmldoc);

        ecx_util_api.parseXML(ecx_utils.g_parser, i_xmldoc, l_parseXML, ecx_utils.g_xmldoc);
	if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'Parsed XML', l_parseXML,i_method_name);
	end if;

        -- Post-Processing for the Document on Target Side
	ecx_actions.execute_stage_data
		(
		30,
		0,
		'T'
		);

        -- Post Processing for the Document on Source Side
        ecx_actions.execute_stage_data
                (
                30,
                0,
		'S'
                );

	-- set the out variable to have the latest document.
       if l_parseXML then
           dbms_lob.trim(i_xmldoc, 0);
           xmlDOM.writetoCLOB(ecx_utils.g_xmldoc,i_xmldoc);

        g_instlmode := wf_core.translate('WF_INSTALL');

           if (l_statementEnabled)
           then
		IF g_instlmode = 'EMBEDDED' THEN
			fnd_message.set_name('ecx', 'XML File for logging');
			attachment_id := fnd_log.message_with_attachment(fnd_log.level_statement, substr(ecx_debug.g_aflog_module_name,1,length(ecx_debug.g_aflog_module_name)-4)||'.xml', TRUE);
			if(attachment_id <> -1 AND i_xmldoc is not null) then
			       clength := dbms_lob.getlength(i_xmldoc);
			       while  clength >= offset LOOP
				     ctemp :=  dbms_lob.substr(i_xmldoc,g_varmaxlength,offset);
				     fnd_log_attachment.writeln(attachment_id, ctemp);
				     offset := offset + g_varmaxlength;
			       End Loop;
				fnd_log_attachment.close(attachment_id);
			end if;
		ELSE
			xmlDOM.writetofile(ecx_utils.g_xmldoc,ecx_utils.g_logdir||'/'||
			substr(ecx_utils.g_logfile,1,length(ecx_utils.g_logfile)-4)
			||'.xml');
		END IF;
           end if;
        end if;

	if(l_statementEnabled) then
		ecx_outbound.log_summary(l_statement);

		ecx_debug.log(l_statement,'ECX','ECX_DOCUMENTS_PROCESSED',i_method_name,'NO_OF_DOCS',
		    ecx_utils.g_source_levels(0).rows_processed);
		ecx_debug.log(l_statement,'ECX','ECX_FINISH_OUTBOUND',i_method_name,'MAP_ID',i_map_id);
	end if;

if not XMLDom.isNull(ecx_utils.g_xmldoc) then
        i_node_type := xmlDOM.getNodeType(ecx_utils.g_xmldoc);
        if (i_node_type = xmlDOM.DOCUMENT_NODE) then
	  xmlDOM.freeDocument(xmlDOM.makeDocument(ecx_utils.g_xmldoc));
        else
          xmlDOM.freeDocFrag(xmlDOM.makeDocumentFragment(ecx_utils.g_xmldoc));
        end if;
xmlparser.freeparser(ecx_utils.g_parser);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name );
end if;

EXCEPTION
WHEN ecx_utils.PROGRAM_EXIT then
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'Clean-up i_stack, l_node_stack, i_tmpxml and last_printed',
	               i_method_name);
	  ecx_outbound.log_summary(l_unexpected);
	end if;
        i_stack.DELETE;
	ecx_print_local.i_tmpxml.DELETE;
	ecx_print_local.l_node_stack.DELETE;
	ecx_print_local.last_printed := -1;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name );
        end if;
	raise ecx_utils.program_exit;
WHEN OTHERS THEN
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
	             'ECX_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
          ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
	  ecx_outbound.log_summary(l_unexpected);
        end if;
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
	if(l_unexpectedEnabled) then
	  ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS',i_method_name);
	  ecx_debug.log(l_unexpected, 'Clean-up i_stack, l_node_stack, i_tmpxml and last_printed',i_method_name);
	end if;
        i_stack.DELETE;
	ecx_print_local.i_tmpxml.DELETE;
	ecx_print_local.l_node_stack.DELETE;
	ecx_print_local.last_printed := -1;
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name );
        end if;
	raise ecx_utils.PROGRAM_EXIT;
end process_outbound_documents;


procedure putmsg
	(
	i_transaction_type	IN	varchar2,
	i_transaction_subtype	IN	varchar2,
	i_party_id		IN	varchar2,
	i_party_site_id		IN	varchar2,
	i_party_type		IN	varchar2,
	i_document_id		IN	varchar2,
	i_map_code		IN	varchar2,
	i_message_type		IN	varchar2,
	i_message_standard	IN	varchar2,
	i_ext_type		IN	varchar2,
	i_ext_subtype		IN	varchar2,
	i_destination_code	IN	varchar2,
	i_destination_type	IN	varchar2,
	i_destination_address	IN	varchar2,
	i_username		IN	varchar2,
	i_password		IN	varchar2,
	i_attribute1		IN	varchar2,
	i_attribute2		IN	varchar2,
	i_attribute3		IN	varchar2,
	i_attribute4		IN	varchar2,
	i_attribute5		IN	varchar2,
	i_debug_level		IN	pls_integer,
        i_trigger_id            IN      number,
	i_msgid			OUT	NOCOPY raw
	)
is
i_method_name   varchar2(2000) := 'ecx_outbound.putmsg';
i_xmldoc		CLOB;
ecx_logging_enabled boolean := false;
e_qtimeout	exception;
pragma		exception_init(e_qtimeout,-25228);
i_logdir	varchar2(200);
i_direct	BOOLEAN := true;

/* Start changes for bug 2120165 */
i_paramCount number;
/* End of changes for bug 2120165 */

i_from_agt      wf_agent_t := wf_agent_t(NULL, NULL);
i_system        varchar2(200);

cursor get_run_s
is
select  ecx_output_runs_s.NEXTVAL
from    dual;

p_aflog_module_name         VARCHAR2(2000) ;

begin
--- Sets the Log Directory in both Standalone and the Embedded mode
ecx_utils.getLogDirectory;

if ecx_utils.g_logfile is null
then
	i_direct := false;
	--  Fetch the Run Id for the Transaction
	open	get_run_s;
	fetch	get_run_s
	into	ecx_utils.g_run_id;
	close	get_run_s;

	ecx_utils.g_logfile :=i_message_standard||'OUT'||
		i_transaction_type||i_transaction_subtype||i_document_id||ecx_utils.g_run_id||'.log';

	p_aflog_module_name := '';
	IF (i_message_standard is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_message_standard||'.';
	END IF;
	p_aflog_module_name := p_aflog_module_name || 'out.';
	IF (i_transaction_type is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_transaction_type||'.';
	END IF;
	IF (i_transaction_subtype is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_transaction_subtype||'.';
	END IF;
	IF (i_document_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_document_id||'.';
	END IF;
	IF (ecx_utils.g_run_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||ecx_utils.g_run_id;
	END IF;
	p_aflog_module_name := p_aflog_module_name||'.log';

	ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir,ecx_utils.g_logfile, p_aflog_module_name);
end if;

-- Assign local variables with the ecx_debug global variables
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
  ecx_debug.log(l_statement,'i_transaction_type',i_transaction_type,i_method_name );
  ecx_debug.log(l_statement,'i_transaction_subtype',i_transaction_subtype,i_method_name );
  ecx_debug.log(l_statement,'i_party_id',i_party_id,i_method_name );
  ecx_debug.log(l_statement,'i_party_site_id',i_party_site_id,i_method_name );
  ecx_debug.log(l_statement,'i_party_type',i_party_type,i_method_name );
  ecx_debug.log(l_statement,'i_document_id',i_document_id,i_method_name );
  ecx_debug.log(l_statement,'i_map_code',i_map_code,i_method_name );
  ecx_debug.log(l_statement,'i_message_type',i_message_type,i_method_name );
  ecx_debug.log(l_statement,'i_message_standard',i_message_standard,i_method_name );
  ecx_debug.log(l_statement,'i_ext_type',i_ext_type,i_method_name );
  ecx_debug.log(l_statement,'i_ext_subtype',i_ext_subtype,i_method_name );
  ecx_debug.log(l_statement,'i_destination_code',i_destination_code,i_method_name );
  ecx_debug.log(l_statement,'i_destination_address',i_destination_address,i_method_name );
  ecx_debug.log(l_statement,'i_destination_type',i_destination_type,i_method_name );
  ecx_debug.log(l_statement,'i_username',i_username,i_method_name );
  ecx_debug.log(l_statement,'i_password',i_password,i_method_name );
  ecx_debug.log(l_statement,'i_attribute1',i_attribute1,i_method_name );
  ecx_debug.log(l_statement,'i_attribute2',i_attribute2,i_method_name );
  ecx_debug.log(l_statement,'i_attribute3',i_attribute3,i_method_name );
  ecx_debug.log(l_statement,'i_attribute4',i_attribute4,i_method_name );
  ecx_debug.log(l_statement,'i_attribute5',i_attribute5,i_method_name );
end if;

ecx_errorlog.outbound_engine
(
  i_trigger_id,
  '10',
  'Processing message...',
  null,
  null,
  i_party_type
 );

	process_outbound_documents
			(
			i_message_standard,
			i_transaction_type,
			i_transaction_subtype,
			i_party_id,
			i_party_site_id,
			i_party_type,
			i_document_id,
			i_map_code,
			i_xmldoc,
                        i_message_type
			);

	-- call ecx_out_wf_qh.enqueue with the correct parameters
     	ecx_utils.g_event.addParameterToList('PARTY_TYPE', i_party_type);
     	ecx_utils.g_event.addParameterToList('PARTYID', i_destination_code);
     	ecx_utils.g_event.addParameterToList('PARTY_SITE_ID', i_destination_code);
     	ecx_utils.g_event.addParameterToList('DOCUMENT_NUMBER', ecx_utils.g_document_id);
     	ecx_utils.g_event.addParameterToList('MESSAGE_TYPE', i_message_type);
     	ecx_utils.g_event.addParameterToList('MESSAGE_STANDARD', i_message_standard);
     	ecx_utils.g_event.addParameterToList('TRANSACTION_TYPE', i_ext_type);
     	ecx_utils.g_event.addParameterToList('TRANSACTION_SUBTYPE', i_ext_subtype);
     	ecx_utils.g_event.addParameterToList('PROTOCOL_TYPE', i_destination_type);
     	ecx_utils.g_event.addParameterToList('PROTOCOL_ADDRESS', i_destination_address);
     	ecx_utils.g_event.addParameterToList('USERNAME', i_username);
     	ecx_utils.g_event.addParameterToList('PASSWORD', i_password);
     	ecx_utils.g_event.addParameterToList('ATTRIBUTE1', i_attribute1);
     	ecx_utils.g_event.addParameterToList('ATTRIBUTE2', i_attribute2);
     	ecx_utils.g_event.addParameterToList('ATTRIBUTE3', i_attribute3);
     	ecx_utils.g_event.addParameterToList('ATTRIBUTE4', i_attribute4);
     	ecx_utils.g_event.addParameterToList('ATTRIBUTE5', i_attribute5);
        ecx_utils.g_event.addParameterToList('TRIGGER_ID', i_trigger_id);
     	ecx_utils.g_event.addParameterToList('LOGFILE', ecx_utils.g_logfile);
     	ecx_utils.g_event.addParameterToList('ITEM_TYPE', ecx_utils.g_item_type);
     	ecx_utils.g_event.addParameterToList('ITEM_KEY', ecx_utils.g_item_key);
     	ecx_utils.g_event.addParameterToList('ACTIVITY_ID', ecx_utils.g_activity_id);
     	ecx_utils.g_event.addParameterToList('EVENT_NAME', ecx_utils.g_event.event_name);
     	ecx_utils.g_event.addParameterToList('EVENT_KEY', ecx_utils.g_event.event_key);
     	ecx_utils.g_event.event_data := i_xmldoc;

	 -- set the from agent
     	select  name
     	into    i_system
     	from    wf_systems
     	where   guid = wf_core.translate('WF_SYSTEM_GUID');

        -- set default outbound agents based on protocol_type
        if (upper(i_destination_type) = 'SOAP') then
          i_from_agt.setname('WF_WS_JMS_OUT');

          -- set default Web Services related attributes
          ecx_utils.g_event.addParameterToList('WS_SERVICE_NAMESPACE',
                            'urn:defaultSoapMessaging');
          ecx_utils.g_event.addParameterToList('WS_PORT_OPERATION',
                            'ReceiveDocument');
          ecx_utils.g_event.addParameterToList('WS_HEADER_IMPL_CLASS',
                            'oracle.apps.fnd.wf.ws.client.DefaultHeaderGenerator');
          ecx_utils.g_event.addParameterToList('WS_RESPONSE_IMPL_CLASS',
                            'oracle.apps.fnd.wf.ws.client.WfWsResponse');
          ecx_utils.g_event.addParameterToList('WS_CONSUMER', 'ecx');

        else

          if (upper(i_destination_type) = 'JMS') then
            if(i_destination_address is null) then
 		i_from_agt.setname('WF_JMS_OUT');
	    else
 		i_from_agt.setname(i_destination_address);
	    end if;
          else
            i_from_agt.setname('ECX_OUTBOUND');
          end if;

        end if;
     	i_from_agt.setsystem(i_system);
	ecx_utils.g_event.setFromAgent(i_from_agt);

                if(l_statementEnabled) then
                     ecx_debug.log(l_statement, 'Calling WF_EVENT.Send for Enqueue', i_method_name);
                 end if;
     	wf_event.send(ecx_utils.g_event);
        ecx_errorlog.outbound_log(ecx_utils.g_event);

        if (upper(i_destination_type) = 'SOAP') or
           (upper(i_destination_type) = 'JMS') then
            i_msgid := wf_event.g_msgid; -- JMS QH store enqueue msgid in wf_event.g_msgid
        else
            i_msgid := ecx_out_wf_qh.msgid;
        end if;

        -- check the retcode and retmsg. This should be populated here only
        -- in the case of dup val index when inserting in doclogs (since no
        -- exception is raised in this case)
        if (ecx_out_wf_qh.retmsg is not null) then
           ecx_debug.setErrorInfo(ecx_out_wf_qh.retcode, 30, ecx_out_wf_qh.retmsg);
	   if(l_unexpectedEnabled) then
             ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
	  end if;
        end if;

   if dbms_lob.istemporary(i_xmldoc) = 1 then
      dbms_lob.freetemporary(i_xmldoc);
   end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'msgid',i_msgid,i_method_name);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
 end if;

if NOT ( i_direct )
then
	ecx_debug.print_log;
	ecx_debug.disable_debug;
	ecx_utils.g_logfile:=null;
end if;

EXCEPTION
WHEN ecx_utils.PROGRAM_EXIT then
        if dbms_lob.istemporary(i_xmldoc) = 1 then
	   dbms_lob.freetemporary(i_xmldoc);
        end if;
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	if NOT ( i_direct )
	then
		ecx_debug.print_log;
		ecx_debug.disable_debug;
		ecx_utils.g_logfile:=null;

                ecx_errorlog.outbound_engine
                (
                 i_trigger_id,
                 ecx_utils.i_ret_code,
                 ecx_utils.i_errbuf,
                 i_msgid,
                 null,
                 i_party_type
                );

	else
		raise ecx_utils.program_exit;
	end if;

WHEN OTHERS THEN
	if (ecx_out_wf_qh.retmsg is null AND ecx_out_wf_qh.retcode = 0)
        then
	   ecx_debug.setErrorInfo(2, 30, SQLERRM);
	   if(l_unexpectedEnabled) then
	     ecx_debug.log(l_unexpected, 'ECX', SQLERRM,i_method_name);
	   end if;
	else
	   ecx_debug.setErrorInfo(ecx_out_wf_qh.retcode, 30, ecx_out_wf_qh.retmsg);
	   if(l_unexpectedEnabled) then
	     ecx_debug.log(l_unexpected, 'msg and code set in queue handler',i_method_name);
	     ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	   end if;
	end if;

        if dbms_lob.istemporary(i_xmldoc) = 1 then
   	   dbms_lob.freetemporary(i_xmldoc);
        end if;

	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	if NOT ( i_direct )
	then
		IF (ecx_logging_enabled ) THEN
			ecx_debug.print_log;
			ecx_debug.disable_debug;
			ecx_utils.g_logfile:=null;
		END IF;
                ecx_errorlog.outbound_engine
                (
                 i_trigger_id,
                 ecx_utils.i_ret_code,
                 ecx_utils.i_errbuf,
                 i_msgid,
                 null,
                 i_party_type
                );
	else
		raise ecx_utils.program_exit;
	end if;

end putmsg;

/* Wrapper procedure for backward comaptibilty */
procedure putmsg
	(
	i_transaction_type	IN	varchar2,
	i_transaction_subtype	IN	varchar2,
	i_party_id		IN	varchar2,
	i_party_site_id		IN	varchar2,
	i_party_type		IN	varchar2,
	i_document_id		IN	varchar2,
	i_parameter1		IN	varchar2,
	i_parameter2		IN	varchar2,
	i_parameter3		IN	varchar2,
	i_parameter4		IN	varchar2,
	i_parameter5		IN	varchar2,
	i_map_code		IN	varchar2,
	i_message_type		IN	varchar2,
	i_message_standard	IN	varchar2,
	i_ext_type		IN	varchar2,
	i_ext_subtype		IN	varchar2,
	i_destination_code	IN	varchar2,
	i_destination_type	IN	varchar2,
	i_destination_address	IN	varchar2,
	i_username		IN	varchar2,
	i_password		IN	varchar2,
	i_attribute1		IN	varchar2,
	i_attribute2		IN	varchar2,
	i_attribute3		IN	varchar2,
	i_attribute4		IN	varchar2,
	i_attribute5		IN	varchar2,
	i_debug_level		IN	pls_integer,
        i_trigger_id            IN    number,
	i_msgid			OUT	NOCOPY raw
	) as


i_method_name   varchar2(2000) := 'ecx_outbound.putmsg';

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
--To populate the global variable ecx_debug.g_v_module_name , need to call ecx_debug.module_enabled
ecx_debug.g_v_module_name := 'ecx.plsql.';
ecx_debug.module_enabled(i_message_standard,i_transaction_type,i_transaction_subtype,i_document_id);
fnd_profile.get('AFLOG_ENABLED',logging_enabled);
fnd_profile.get('AFLOG_MODULE',module);
if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
OR module='%')
AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
end if;
-- /logging enabled

/**
  Populate the Parameters in the global event Object .if it is null ,
  initialize and create a new Instance and populate the variables
 **/

  if ecx_utils.g_event is null
  then
        wf_event_t.initialize(ecx_utils.g_event);

  end if;

  /* Add the above Parameters to the Global Event Message Object
     For backward compatability */

  ecx_utils.g_event.addparametertolist('PARAMETER1',i_parameter1);
  ecx_utils.g_event.addparametertolist('PARAMETER2',i_parameter2);
  ecx_utils.g_event.addparametertolist('PARAMETER3',i_parameter3);
  ecx_utils.g_event.addparametertolist('PARAMETER4',i_parameter4);
  ecx_utils.g_event.addparametertolist('PARAMETER5',i_parameter5);

  putmsg(  i_transaction_type	 ,
	   i_transaction_subtype ,
	   i_party_id		 ,
	   i_party_site_id       ,
	   i_party_type	         ,
	   i_document_id         ,
	   i_map_code		 ,
	   i_message_type	 ,
	   i_message_standard	 ,
	   i_ext_type		 ,
	   i_ext_subtype	 ,
	   i_destination_code	 ,
	   i_destination_type	 ,
	   i_destination_address ,
	   i_username		 ,
	   i_password		 ,
	   i_attribute1		 ,
	   i_attribute2		 ,
	   i_attribute3		 ,
	   i_attribute4		 ,
	   i_attribute5		 ,
	   i_debug_level	 ,
           i_trigger_id          ,
	   i_msgid		);
Exception
WHEN OTHERS THEN
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.putmsg ');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.putmsg ',
	               i_method_name);
	end if;
        raise ecx_utils.PROGRAM_EXIT;
end putmsg;

procedure GETXML
	(
	i_message_standard	IN	varchar2,
	i_transaction_type	IN	varchar2,
	i_transaction_subtype	IN	varchar2,
	i_tp_id			IN	varchar2,
	i_tp_site_id		IN	varchar2,
	i_tp_type		In	varchar2,
	i_document_id		IN	varchar2,
	i_map_code		IN	varchar2,
	i_debug_level		IN	pls_integer,
	i_xmldoc		IN OUT	NOCOPY clob,
	i_ret_code		OUT	NOCOPY pls_integer,
	i_errbuf		OUT	NOCOPY varchar2,
	i_log_file		OUT	NOCOPY varchar2,
        i_message_type          IN      VARCHAR2 default 'XML'
	)
is
i_method_name   varchar2(2000) := 'ecx_outbound.getxml';
/* Start changes for Bug 2120165 */
i_paramCount number;
/* End of changes for bug 2120165 */
cursor get_run_s
is
select  ecx_output_runs_s.NEXTVAL
from    dual;

i_logdir	varchar2(200);
i_tmpxmldoc     CLOB;
p_aflog_module_name         VARCHAR2(2000) ;
g_instlmode         VARCHAR2(100);

ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
--To populate the global variable ecx_debug.g_v_module_name , need to call ecx_debug.module_enabled
ecx_debug.g_v_module_name := 'ecx.plsql.';
ecx_debug.module_enabled(i_message_standard,i_transaction_type,i_transaction_subtype,i_document_id);

  g_instlmode := wf_core.translate('WF_INSTALL');

  if(g_instlmode = 'EMBEDDED')
  then
    fnd_profile.get('AFLOG_ENABLED',logging_enabled);
    fnd_profile.get('AFLOG_MODULE',module);
if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
OR module='%')
       AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
      ecx_logging_enabled := true;
    end if;
  elsif(g_instlmode = 'STANDALONE')
  then
    if (i_debug_level > 0) then
      ecx_logging_enabled := true;
    end if;
  end if;

  IF (ecx_logging_enabled ) THEN
	--- Sets the Log Directory in both Standalone and the Embedded mode
	ecx_utils.getLogDirectory;

	/** Fetch the Run Id for the Transaction **/
	open	get_run_s;
	fetch	get_run_s
	into	ecx_utils.g_run_id;
	close	get_run_s;

	ecx_utils.g_logfile :=i_message_standard||'OUT'||
		i_transaction_type||i_transaction_subtype||i_document_id||ecx_utils.g_run_id||'.log';

	p_aflog_module_name := '';
	IF (i_message_standard is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_message_standard||'.';
	END IF;
	p_aflog_module_name := p_aflog_module_name || 'out.';
	IF (i_transaction_type is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_transaction_type||'.';
	END IF;
	IF (i_transaction_subtype is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_transaction_subtype||'.';
	END IF;
	IF (i_document_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||i_document_id||'.';
	END IF;
	IF (ecx_utils.g_run_id is not null) THEN
		p_aflog_module_name := p_aflog_module_name||ecx_utils.g_run_id;
	END IF;
	p_aflog_module_name := p_aflog_module_name||'.log';
	ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir,ecx_utils.g_logfile, p_aflog_module_name);
  END IF;

	IF g_instlmode = 'EMBEDDED' THEN
		IF (ecx_logging_enabled ) THEN
			i_log_file := ecx_debug.g_sqlprefix || p_aflog_module_name;
		ELSE
			i_log_file := 'Please ensure that FND-Logging is enabled for module '||ecx_debug.g_sqlprefix||'%';
		END IF;
	ELSE
		if (ecx_logging_enabled) then
			i_log_file := ecx_utils.g_logdir||ecx_utils.getFileSeparator()||ecx_utils.g_logfile;
		else
			i_log_file := 'Please ensure that logging is enabled';
		end if;
	END IF;

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
  ecx_debug.log(l_statement,'i_transaction_type',i_transaction_type,i_method_name );
  ecx_debug.log(l_statement,'i_transaction_subtype',i_transaction_subtype,i_method_name );
  ecx_debug.log(l_statement,'i_tp_id',i_tp_id,i_method_name );
  ecx_debug.log(l_statement,'i_tp_site_id',i_tp_site_id,i_method_name );
  ecx_debug.log(l_statement,'i_tp_type',i_tp_type,i_method_name );
  ecx_debug.log(l_statement,'i_document_id',i_document_id,i_method_name );
  ecx_debug.log(l_statement,'i_map_code',i_map_code,i_method_name );
end if;
-- initialize i_tmpxmldoc
dbms_lob.createtemporary(i_tmpxmldoc,TRUE,DBMS_LOB.SESSION);

	process_outbound_documents
			(
			i_message_standard,
			i_transaction_type,
			i_transaction_subtype,
			i_tp_id,
			i_tp_site_id,
			i_tp_type,
			i_document_id,
			i_map_code,
			i_tmpxmldoc
			);
-- assign i_tmpxmldoc to the return variable
i_xmldoc := i_tmpxmldoc;

-- free i_tmpxmldoc
if i_tmpxmldoc is not null
then
   dbms_lob.freetemporary (i_tmpxmldoc);
end if;
ecx_debug.setErrorInfo(0, 10, 'ECX_SUCCESSFUL_EXECUTION');
i_ret_code := ecx_utils.i_ret_code;
i_errbuf := ecx_utils.i_errbuf;

if(ecx_utils.i_ret_code = 0 ) then
  if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'Ret Code',ecx_utils.i_ret_code,i_method_name);
  ecx_debug.log(l_statement, 'Ret Msg ',ecx_utils.i_errbuf,i_method_name);
  end if;
else
if(l_unexpectedEnabled) then
  ecx_debug.log(l_unexpected, 'Ret Code',ecx_utils.i_ret_code,i_method_name);
  ecx_debug.log(l_unexpected, 'Ret Msg ',ecx_utils.i_errbuf,i_method_name);
end if;
end if;

if(l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;
EXCEPTION
WHEN ecx_utils.program_exit THEN
	i_ret_code := ecx_utils.i_ret_code;
	i_errbuf := ecx_utils.i_errbuf;
	if(l_unexpectedEnabled) then
	  ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
        end if;
	if(l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
	end if;
	-- free i_tmpxmldoc
	if i_tmpxmldoc is not null
	then
		dbms_lob.freetemporary (i_tmpxmldoc);
	end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
WHEN OTHERS THEN
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_OUTBOUND.PUTMSG');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_OUTBOUND.PUTMSG',i_method_name);
        end if;
        i_ret_code := ecx_utils.i_ret_code;
        i_errbuf := ecx_utils.i_errbuf;
	if(l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
	end if;
	-- free i_tmpxmldoc
	if i_tmpxmldoc is not null
	then
		dbms_lob.freetemporary (i_tmpxmldoc);
	end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
end GETXML;

end ecx_outbound;

/
