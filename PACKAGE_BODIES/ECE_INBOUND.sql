--------------------------------------------------------
--  DDL for Package Body ECE_INBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_INBOUND" as
-- $Header: ECEINBB.pls 120.2 2005/09/28 11:26:03 arsriniv ship $

/* Bug 2422787 */
g_count                      number:=0;
m_orig_stack                 ec_utils.pl_stack;
m_orig_int_levels            ec_utils.interface_level_tbl;
m_orig_ext_levels            ec_utils.external_level_tbl;
m_orig_int_ext_levels        ec_utils.interface_external_tbl;
m_orig_stage_data            ec_utils.stage_data;
m_orig_stack_pointer         ec_utils.stack_pointer;
m_tmp1_stage_data            ec_utils.stage_data;
m_tmp2_stage_data            ec_utils.stage_data;
m_tmp3_stage_data            ec_utils.stage_data;
stage_20_flag                varchar2(1):='N';   --bug 2500898
stage_30_flag                varchar2(1):='N';
stage_40_flag                varchar2(1):='N';
stage_50_flag                varchar2(1):='N';


procedure process_inbound_documents
	(
	i_transaction_type	IN	varchar2,
	i_document_id		IN	number
	)
is
i_select_cursor		INTEGER;
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_document_id',i_document_id);
 end if;

	ec_utils.g_stack.DELETE;
	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
	g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	process_documents
		(
		i_document_id,
		i_transaction_type,
		i_select_cursor
		);

	/**
	The Documents is processed. Save the changes now.
	**/
	commit;

	ec_utils.g_file_tbl 	:= m_file_tbl_empty;

	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
end if;

EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END process_inbound_documents;

procedure process_inbound_documents
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number
	)
IS
	cursor	documents
	(
	p_run_id		in	number,
	p_transaction_type	IN	varchar2
	)is
	select	document_id
	from	ece_stage
	where	run_id			= p_run_id
	and	transaction_type 	= p_transaction_type
	and	transaction_level	= 1
	and	line_number 		= 1
	for update of Document_Id NOWAIT;

i_select_cursor	INTEGER;
i_count				number:=0;

begin
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_run_id',i_run_id);
end if;

	ec_utils.g_stack.DELETE;
	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
	g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	for c1 in documents
	(
	p_run_id => i_run_id ,
	p_transaction_type => i_transaction_type
	)
	loop

		process_documents
		(
		c1.document_id,
		i_transaction_type,
		i_select_cursor
		);

		/* Bug 2019253 Re-initializing the global map_id and moved the commit out of the loop */
                g_previous_map_id := -99;

--		commit;

	       /* Bug 2422787
		i_count 	:= i_count + 1;
		ec_utils.g_file_tbl 	:= m_file_tbl_empty;
	       */
		g_count         := g_count + 1;
	end loop;
        commit;
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',g_count);	--Bug 2422787

	/**
	Close the Cursors and print the information.
	**/
	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
end if;

EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_inbound_documents;

procedure process_run_inbound
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number
	)
IS
	cursor	documents
		(
		p_run_id		in	number,
		p_transaction_type	IN	varchar2
		)is
	select	document_id
	from	ece_stage
	where	run_id 			= p_run_id
	and	transaction_type 	= p_transaction_type
	and	transaction_level	= 1
	and	line_number 		= 1
	for update of Document_Id NOWAIT;

i_select_cursor		number;
i_count			number:=0;

begin
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_RUN_INBOUND');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_run_id',i_run_id);
 end if;
	/**
	Gather table Statistics for CBO ( ece_stage , ece_rule_violations ).
	**/
	/**
	fnd_stats.gather_table_stats
			(
			'EC',
			'ECE_STAGE',
			20,
			null,
			null,
			null,
			TRUE
			);
	fnd_stats.gather_table_stats
			(
			'EC',
			'ECE_RULE_VIOLATIONS',
			20,
			null,
			null,
			null,
			TRUE
			);
	**/

	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
        g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	for c1 in documents
		(
		p_run_id => i_run_id ,
		p_transaction_type => i_transaction_type
		)
	loop
		/**
		Savepoint for the document. If any error encountered during processing of the
		document , the whole document will be rolled back to this savepoint.
		Partial processing of the document is not allowed.
		**/
		savepoint document_start;

		run_inbound
			(
			c1.document_id,
			i_transaction_type,
			i_select_cursor
			);

                /* Bug 2019253 Re-initializing the global map_id */
                g_previous_map_id := -99;

		/**
		If the Status is ABORT then stop the program execution.
		Rollback the Staging Data , Violations etc.
		**/
		if ec_utils.g_ext_levels(1).Status = 'ABORT'
		then
			rollback work;
			ec_utils.i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		elsif (ec_utils.g_ext_levels(1).Status = 'SKIP_DOCUMENT')
			or (ec_utils.g_ext_levels(1).Status = 'INSERT_FAILED')
		then
			rollback to Document_start;
			update_document_status;
		end if;

		/**
		Make sure that the all the records for a document are successfully
		inserted into the production open Interface tables.  Check whether
		the document is ready for Insert.
		If yes then save the Document and delete from the Staging table.
		**/

		if ( ec_utils.g_ext_levels(1).Status = 'INSERT'
		or ec_utils.g_ext_levels(1).Status = 'NEW'
		or ec_utils.g_ext_levels(1).Status = 'RE_PROCESS'
		)
		then
			delete	from ece_rule_violations
			where	document_id = c1.document_id;

			delete 	from ece_stage
			where	document_id = c1.document_id;

			if sql%notfound
			then
				ec_debug.pl(1,'EC','ECE_DELETE_FAILED_STAGING','DOCUMENT_ID',c1.document_id);
				ec_utils.i_ret_code :=1;
				rollback to Document_Start;
			end if;
		end if;

		/** Save the Violations.  **/
		Insert_Into_Violations(c1.Document_Id);


		/* Bug 2422787
		   i_count 	:= i_count + 1;
	           ec_utils.g_file_tbl     := m_file_tbl_empty;
		*/
                g_count         := g_count + 1;

	end loop;
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',g_count);	--Bug 2422787
	/**
	Close the Cursors and print the information.
	**/
	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_RUN_INBOUND');
end if;
EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_RUN_INBOUND');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_run_inbound;

procedure process_inbound_documents
	(
	i_transaction_type	IN	varchar2,
	i_status		IN	varchar2
	)
IS
	cursor	documents
		(
		p_transaction_type	in	varchar2,
		p_status		IN	varchar2
		)is
	select	document_id
	from	ece_stage
	where	transaction_type 	= p_transaction_type
	and	status			= p_status
	and	transaction_level	= 1
	and	line_number		= 1
	for update of Document_Id NOWAIT;

i_select_cursor		number;
i_count					number:=0;

begin
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_status',i_status);
end if;
	ec_utils.g_stack.DELETE;
	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
	g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	for c1 in documents
		(
		p_status => i_status ,
		p_transaction_type => i_transaction_type
		)
	loop
		process_documents
			(
			c1.document_id,
			i_transaction_type,
			i_select_cursor
			);

	        /* Bug 2019253 Re-initializing the global map_id and moved the commit out of the loop */
                g_previous_map_id := -99;

		/** The Documents are processed. Save the changes now.  **/
--		commit;

	       /* Bug 2422787
		i_count 	:= i_count + 1;
		ec_utils.g_file_tbl 	:= m_file_tbl_empty;
	       */
		g_count         := g_count + 1;

	end loop;
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',g_count);	--Bug 2422787

	/**
	Close the Cursors and print the information.
	**/
	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
end if;
EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_inbound_documents;

procedure process_inbound_documents
	(
	i_transaction_type	IN	varchar2
	)
IS
	cursor	documents
		(
		p_transaction_type	in	varchar2
		)is
	select	document_id
	from	ece_stage
	where	transaction_type 	= p_transaction_type
	and	transaction_level	= 1
	and	line_number		= 1
	for update of Document_Id NOWAIT;

i_select_cursor		number;
i_count					number:=0;

begin
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
end if;
	ec_utils.g_stack.DELETE;
	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
        g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	for c1 in documents
		(
		p_transaction_type => i_transaction_type
		)
	loop
		process_documents
			(
			c1.document_id,
			i_transaction_type,
			i_select_cursor
			);

              /* Bug 2019253 Re-initializing the global map_id and moved the commit out of the loop */
                g_previous_map_id := -99;

		/** The Documents are processed. Save the changes now.  **/
	--	commit;

	       /* Bug 2422787
		i_count 	:= i_count + 1;
		ec_utils.g_file_tbl 	:= m_file_tbl_empty;
	       */
		g_count         := g_count + 1;

	end loop;

        commit;

	ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',g_count);

	/**
	Close the Cursors and print the information.
	**/
	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
end if;
EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_inbound_documents;

procedure process_inbound_documents
	(
	i_transaction_type	IN	varchar2,
	i_tp_code		IN	varchar2,
	i_status		IN	varchar2
	)
IS
	cursor	documents
		(
		p_transaction_type	in	varchar2,
		p_tp_code		in	varchar2,
		p_status		IN	varchar2
		)is
	select	document_id
	from	ece_stage
	where	transaction_type 	= p_transaction_type
	and	tp_code 		= p_tp_code
	and	status			= p_status
	and	transaction_level	= 1
	and	line_number		= 1
	for update of Document_Id NOWAIT;

	cursor	documents_fornulltp
		(
		p_transaction_type	in	varchar2,
		p_status		IN	varchar2
		)is
	select	document_id
	from	ece_stage
	where	transaction_type 	= p_transaction_type
	and	tp_code 		is null
	and	status			= p_status
	and	transaction_level	= 1
	and	line_number		= 1
	for update of Document_Id NOWAIT;

i_select_cursor		number;
i_count			number:=0;

begin
if ec_debug.G_debug_level >= 2 then
ec_debug.PUSH('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_tp_code',i_tp_code);
ec_debug.pl(3,'i_status',i_status);
end if;
	ec_utils.g_stack.DELETE;
	ec_utils.g_documents_skipped := 0;
	ec_utils.g_insert_failed := 0;
	g_previous_map_id := -99;

	select_stage ( i_select_cursor );

	if i_tp_code is not null
	then
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'i_tp_code',i_tp_code);
       end if;
		for c1 in documents
			(
			p_status => i_status ,
			p_tp_code => i_tp_code ,
			p_transaction_type => i_transaction_type
			)
		loop
			process_documents
				(
				c1.document_id,
				i_transaction_type,
				i_select_cursor
				);

                   /* Bug 2019253 Re-initializing the global map_id and moved the commit out of the loop */
                         g_previous_map_id := -99;

			/** The Documents are processed. Save the changes now.  **/

	--		commit;

			/* Bug 2422787
			  i_count 	:= i_count + 1;
		          ec_utils.g_file_tbl 	:= m_file_tbl_empty;
			*/
			g_count         := g_count + 1;
		end loop;
	elsif i_tp_code is null
	then
		if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'i_tp_code','NULL');
		end if;
		for c1 in documents_fornulltp
			(
			p_status => i_status ,
			p_transaction_type => i_transaction_type
			)
		loop
			process_documents
				(
				c1.document_id,
				i_transaction_type,
				i_select_cursor
				);

                  /* Bug 2019253 Re-initializing the global map_id and moved the commit out of the loop */
                         g_previous_map_id := -99;

			/** The Documents are processed. Save the changes now.  **/

	--		commit;

			/* Bug 2422787
			 i_count 	:= i_count + 1;
			 ec_utils.g_file_tbl 	:= m_file_tbl_empty;
			*/
			g_count         := g_count + 1;

		end loop;
	else
		ec_debug.pl(3,'iii','invalid tp code');
	end if;

        commit;

	ec_debug.pl(1,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',g_count);	--Bug 2422787

	/**
	Close the Cursors and print the information.
	**/
	close_inbound;

	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.POP('ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
end if;
EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_INBOUND_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_inbound_documents;

procedure run_inbound
	(
	i_document_id		IN	NUMBER,
	i_transaction_type	IN	varchar2,
	i_select_cursor		IN	integer
	)
IS
  	l_return_status     	VARCHAR2(1);
  	l_msg_count         	NUMBER;
  	l_msg_data          	VARCHAR2(2000);
	i_level			ece_stage.transaction_level%TYPE;
	i_line_number		ece_stage.line_number%TYPE;
	i_field_number		number;
	dummy			number;
	i_total_records		number;
	i_status		ece_stage.status%TYPE;
	i_map_id		ece_stage.map_id%TYPE;
	i_document_number	ece_stage.document_number%TYPE;
	i_stage_id		ece_stage.stage_id%TYPE;
	i_insert_ok		BOOLEAN := FALSE;
	i_insert		BOOLEAN := FALSE;
	i_document_failed	BOOLEAN := FALSE;
	i_level_found		BOOLEAN := FALSE;
	i_plsql_pos		number;
	i_stack_pos		number;
	m_var_found		BOOLEAN := FALSE;
	i_interface_level	number;
	i_previous_level	number := 0;
	i_last_insert_level	number := 0;

	c_stage_id              number;
	c_rule_id               number;
	c_interface_col_id      number;
	i_count                 pls_integer := 1;

	CURSOR c_ignore_rule (
          p_document_id     IN     NUMBER
          ) IS
         select stage_id,rule_id,interface_column_id
         from   ece_rule_violations
         where  document_id          = p_document_id and
                violation_level      = 'COLUMN' and
	        nvl(ignore_flag,'N') = 'Y';


BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.RUN_INBOUND');
ec_debug.pl(3,'i_document_id',i_document_id);
ec_debug.pl(3,'i_select_cursor',i_select_cursor);
end if;
--Set the Document Id package variable
ec_utils.g_document_id := i_document_id;

/**
Bind the Value of Document Id
**/

FOR i_ignore_rule in c_ignore_rule(i_document_id)
loop
  g_col_rule_viol_tbl(i_count).stage_id := i_ignore_rule.stage_id;
  g_col_rule_viol_tbl(i_count).rule_id := i_ignore_rule.rule_id;
  g_col_rule_viol_tbl(i_count).interface_col_id := i_ignore_rule.interface_column_id;
  i_count := i_count + 1;
END LOOP;

dbms_sql.bind_variable(i_select_cursor,'i_document_id',i_document_id);

dummy := dbms_sql.execute(i_select_cursor);
while dbms_sql.fetch_rows(i_select_cursor) > 0
loop

	dbms_sql.column_value(i_select_cursor,1,i_stage_id);

	dbms_sql.column_value(i_select_cursor,2,i_document_number);

       dbms_sql.column_value(i_select_cursor,3,i_level);

       dbms_sql.column_value(i_select_cursor,4,i_line_number);

       dbms_sql.column_value(i_select_cursor,5,i_status);

	dbms_sql.column_value(i_select_cursor,6,i_map_id);

     if ec_debug.G_debug_level = 3 then
        ec_debug.pl(3,'i_stage_id',i_stage_id);
        ec_debug.pl(3,'i_document_number',i_document_number);
        ec_debug.pl(3,'i_previous_level',i_previous_level);
        ec_debug.pl(3,'i_level',i_level);
        ec_debug.pl(3,'i_line_number',i_line_number);
        ec_debug.pl(3,'i_status',i_status);
	ec_debug.pl(3,'i_map_id',i_map_id);
	ec_debug.pl(3,'g_previous_map_id',g_previous_map_id);
    end if;
	if (i_level = 1) and (i_map_id <> g_previous_map_id) then
		initialize_inbound (i_transaction_type, i_map_id);
		g_previous_map_id := i_map_id;
	end if;

	/**
	 In the case that the current external level is less than the
	 previous level and the previous data wasn't inserted into the
	 open interface table, then we have to insert the previous data
	 before continue processing the new fetched data.
	**/

	if (i_level <= i_previous_level) and NOT (i_insert) then
            if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'Ready to insert into open interface table');
		ec_debug.pl(3,'i_interface_level',i_interface_level);
	   end if;
		/**
		 If the last_insert_level is a lower level, then we have to
		 make sure we clean up all the lower level data so that it would
		 not carry over data from previous insert.
		**/

		if (i_last_insert_level > i_previous_level) then
			for k in ec_utils.g_ext_levels(i_previous_level+1).file_start_pos..ec_utils.g_ext_levels(i_last_insert_level).file_end_pos
			loop
				ec_utils.g_file_tbl(k).value := m_file_tbl_empty(k).value;
			end loop;
		end if;

		i_last_insert_level := i_previous_level;

		--Insert_into_prod_interface;
		i_insert_ok := Insert_Into_prod_Interface
		(
		ec_utils.g_int_levels(i_interface_level).Cursor_handle,
		i_interface_level
		);

		-- if Insert Failed then
		if NOT ( i_insert_ok) then
			ec_utils.g_ext_levels(1).Status := 'INSERT_FAILED';
			ec_utils.g_ext_levels(i_level).Status := ec_utils.g_ext_levels(1).status;
			ec_utils.g_insert_failed := ec_utils.g_insert_failed + 1;
			ec_debug.pl(1,'EC','ECE_INSERT_SKIPPED','DOCUMENT_ID',i_document_id);

			/**
			Exit the processing for the Document
			**/
			exit;

		end if; --- Insert Check
	end if;

	/**
	Update the Level Info table for Latest Document Number , Stage Id and Level
	**/

	ec_utils.g_ext_levels(i_level).Stage_Id := i_stage_id;
	ec_utils.g_ext_levels(i_level).Document_Id := i_Document_Id;
	ec_utils.g_ext_levels(i_level).Document_Number := i_Document_Number;
	ec_utils.g_ext_levels(i_level).Line_Number := i_Line_Number;
	ec_utils.g_ext_levels(i_level).Status := i_Status;

        --Bug 2164672
        if ec_utils.g_ext_levels(i_level).status = 'LOSSY_CONVERSION' then
                  ec_utils.g_ext_levels(i_level).Status := 'SKIP_DOCUMENT';
                  ec_debug.pl(0,'This Line  has Lossy Conversion Exception ');
                  goto skip_document;
        end if;

	/**
	Update Global variable to hold the Current level of the Record.
	**/
	ec_utils.g_current_level := i_level;
	i_previous_level := i_level;

	/**
	Populate Transaction Attribute table for Error Handling.
	**/
	if i_level = 1
	then
		ece_flatfile_pvt.t_tran_attribute_tbl(1).value := i_Document_Number;
	end if;

	/**
	Initialize values for the Level , copy the values from empty table.
	**/
	for k in ec_utils.g_ext_levels(i_level).file_start_pos..ec_utils.g_ext_levels(i_level).file_end_pos
	loop
	   ec_utils.g_file_tbl(k).value := m_file_tbl_empty(k).value;
	end loop;

	/**
	Extracting a given Column from Staging table.
	From the PL/SQL table , we are concerned about only those fields which
	are mapped to the Staging Columns in the Stage Table. The Data from the
	Stage table is extracted only for the mapped fields.
	e.g. select statement build for Extract is
		select	Stage_Id,Document_Number,transaction_level,Line_number,Status,map_id,
			Field1,Field2,Field3........Field500 from ece_stage;
		To extract Field3 , first Find out the relative position of the Column
		in the Select Statement which is 6 + 3 ( 3 for Field3 , 5 for Field5).
		Pass this to the DBMS_SQL call to get the Column Value.
	**/
        if ec_debug.G_debug_level = 3 then
 	   ec_debug.pl(3,'EC','ECE_FIELDS_EXTRACTED_STAGING',null);
        end if;
	for i in ec_utils.g_ext_levels(i_level).file_start_pos..ec_utils.g_ext_levels(i_level).file_end_pos
	loop
		if ec_utils.g_file_tbl(i).Staging_Column is not null
		then
                  /* Bug 2500898
			i_field_number := to_number( substrb(
				ec_utils.g_file_tbl(i).Staging_Column,
				6,
				length(ec_utils.g_file_tbl(i).Staging_Column)-5));

           		dbms_sql.column_value(
				i_select_cursor,
				i_field_number+6,
				ec_utils.g_file_tbl(i).value
				);
                  */

	        	dbms_sql.column_value(
				i_select_cursor,
				ec_utils.g_file_tbl(i).staging_column_no+6,
				ec_utils.g_file_tbl(i).value
				);

		-- Check the value extracted from the Staging table. If null then assign the default
		-- values from the backup PL/SQL table from stage 10.
		-- Bug 2708573/2808880
		if ec_utils.g_file_tbl(i).value is null
		then
			ec_utils.g_file_tbl(i).value := m_file_tbl_empty(i).value;
		end if;

		if ec_debug.G_debug_level = 3  then		--bug 2500898
		   if ec_utils.g_file_tbl(i).value is not null
		   then
			ec_debug.pl(3,'i_Interface_Column_Name',ec_utils.g_file_tbl(i).Interface_Column_Name);
			ec_debug.pl(3,'i_field_name',ec_utils.g_file_tbl(i).Staging_Column);
			ec_debug.pl(3,'i_field_value',ec_utils.g_file_tbl(i).value);
		   end if;
		end if;

	   end if; --- Staging Column mapped to the Interface Column
	end loop;  -- end loop for Column values

        if stage_20_flag  = 'Y' then	 --Bug 2500898
	  /**
	   Get Stage Data for Stage = 20
	  **/
	  ec_utils.execute_stage_data ( 20, i_level);
        end if;

	if i_level = 1
	then
		m_var_found := ec_utils.find_variable
				(
				0,
				'P_ADDRESS_TYPE',
				i_stack_pos,
				i_plsql_pos
				);
		if not (m_var_found)
		then
			ec_debug.pl(0,'EC','ECE_VARIABLE_NOT_ON_STACK','VARIABLE_NAME','P_ADDRESS_TYPE');
			ec_utils.i_ret_code :=2;
			raise ec_utils.program_exit;
		end if;

		ECE_RULES_PKG.Validate_Process_Rules
				(
				1.0,
				NULL,
				null,
				null,
				null,
				l_return_status,
				l_msg_count,
				l_msg_data,
				ec_utils.g_transaction_type,
				ec_utils.g_stack(i_stack_pos).variable_value,
				i_stage_id,
				i_document_id,
				i_document_number,
				i_level,
				i_map_id,
				ec_utils.g_file_tbl
				);

		--Check the Status of the Process Rule Exception API
		--and take appropriate action.
		if l_return_status = fnd_api.g_ret_sts_success then
			if ec_utils.g_ext_levels(i_level).Status = 'SKIP_DOCUMENT'
				or ec_utils.g_ext_levels(i_level).Status = 'ABORT'
			then
				goto skip_document;
			end if;
		elsif ( l_return_status = FND_API.G_RET_STS_ERROR
				OR l_return_status is NULL
        		OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			ec_utils.i_ret_code := 2;
        	RAISE EC_UTILS.PROGRAM_EXIT;
		END IF;

	end if; --- For Header execute Process Rules

        if stage_30_flag  = 'Y' then		--Bug 2500898
	  --Get Stage Data for Stage = 30
	  ec_utils.execute_stage_data ( 30, i_level);
        end if;

	ec_code_conversion_pvt.populate_plsql_tbl_with_intval
	(
		p_api_version_number => 1.0,
		p_return_status      => l_return_status,
		p_msg_count          => l_msg_count,
		p_msg_data           => l_msg_data,
		p_apps_tbl           => ec_utils.g_file_tbl,
		p_level              => i_level
	);

	/**
	Check the Status of the Code Conversion API
	and take appropriate action.
	**/
	IF ( l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status is NULL
        	OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		ec_utils.i_ret_code := 2;
     	RAISE EC_UTILS.PROGRAM_EXIT;
  	END IF;

        if stage_40_flag  = 'Y' then		--Bug 2500898
	  --Get Stage Data for Stage = 40
	  ec_utils.execute_stage_data ( 40, i_level);
	end if;

	--Perform Column Exception Processing
	ECE_RULES_PKG.Validate_Column_Rules
	(
		1.0,
		NULL,
		null,
		null,
		null,
		l_return_status,
		l_msg_count,
		l_msg_data,
		ec_utils.g_transaction_type,
		i_stage_id,
		i_document_id,
		i_document_number,
		i_level,
		ec_utils.g_file_tbl
	);

	---
	---Check the Status of the Column Rule Exception API
	---and take appropriate action.
	---
	if l_return_status = fnd_api.g_ret_sts_success then
		if ec_utils.g_ext_levels(i_level).Status = 'SKIP_DOCUMENT'
			or ec_utils.g_ext_levels(i_level).Status = 'ABORT'
		then
			goto skip_document;
		end if;
	elsif ( l_return_status = FND_API.G_RET_STS_ERROR OR l_return_status is NULL
        		OR l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
			ec_utils.i_ret_code := 2;
     		RAISE EC_UTILS.PROGRAM_EXIT;
  	END IF;

	g_col_rule_viol_tbl.delete;

        if stage_50_flag  = 'Y' then		--Bug 2500898
	   --Get Stage Data for Stage = 50
	   ec_utils.execute_stage_data (50, i_level);
	end if;


	<<skip_document>>

	if ec_utils.g_ext_levels(i_level).Status = 'ABORT' or
		ec_utils.g_ext_levels(i_level).Status = 'SKIP_DOCUMENT'
	then
		/**
		If Abort or Skip Document, then Mark the Control Record ( 1st Record )
		or the header as Abort. This will be checked in the calling program
		to rollback and abort the program.
		**/
		ec_utils.g_ext_levels(1).Status := ec_utils.g_ext_levels(i_level).Status;

		/**
		Keep Track of how many documents have been skipped in this
		run of the transaction.
		**/
		if ec_utils.g_ext_levels(i_level).Status = 'SKIP_DOCUMENT'
		then
			ec_debug.pl(1,'EC','ECE_DOCUMENT_SKIPPED','DOCUMENT_ID',i_document_id);
			ec_utils.g_documents_skipped := ec_utils.g_documents_skipped + 1;
		end if;

		/**
		Exit the processing for the Document
		**/
		exit;

	elsif
		/**
		The Exception processing does not update the Status of a record
		if there are no Process rules or Column Rules defined .The Status
		remains New, or Re-Process.
		**/
		(
		ec_utils.g_ext_levels(i_level).Status = 'INSERT'
		or ec_utils.g_ext_levels(i_level).Status = 'NEW'
		or ec_utils.g_ext_levels(i_level).Status = 'RE_PROCESS'
		)
	then
		/**
		This is the new flexible hierarchy feature.  It loops thru the
		g_int_ext_levels and make sure all the data is completed
		before it writes to the open interface table.
		**/

		for i in 1..ec_utils.g_int_ext_levels.COUNT
		loop
			if ec_utils.g_int_ext_levels(i).external_level = i_level then
				i_interface_level := ec_utils.g_int_ext_levels(i).interface_level;
				i_insert := FALSE;
				ec_debug.pl (3, 'i', i);
				if i < ec_utils.g_int_ext_levels.COUNT then
					if ec_utils.g_int_ext_levels(i+1).interface_level <>
						ec_utils.g_int_ext_levels(i).interface_level then
						i_insert := TRUE;
					end if;
				else
					i_insert := TRUE;
				end if;

				if i_insert then
					i_last_insert_level := i_level;
 					if ec_debug.G_debug_level = 3 then
					ec_debug.pl(3,'Ready to insert into open interface table');
					ec_debug.pl(3,'i_interface_level',i_interface_level);
                                        end if;
					--Insert_into_prod_interface;
					i_insert_ok := Insert_Into_prod_Interface
					(
						ec_utils.g_int_levels(i_interface_level).Cursor_handle,
						i_interface_level
					);

					-- if Insert Failed then
					if NOT ( i_insert_ok)
					then
						ec_utils.g_ext_levels(1).Status := 'INSERT_FAILED';
						ec_utils.g_ext_levels(i_level).Status := ec_utils.g_ext_levels(1).status;
						ec_utils.g_insert_failed := ec_utils.g_insert_failed + 1;
						ec_debug.pl(1,'EC','ECE_INSERT_SKIPPED','DOCUMENT_ID',i_document_id);

						/**
						Exit the processing for the Document
						**/
						exit;

					end if; --- Insert Check
				end if; -- i_insert
			end if;
		end loop;
	else
		/**
		Invalid Status , Skipping the Document.
		**/
		ec_utils.g_ext_levels(1).Status := 'SKIP_DOCUMENT';

		/**
		Keep Track of how many documents have been skipped in this
		run of the transaction.
		**/
		ec_debug.pl(1,'EC','ECE_DOCUMENT_SKIPPED','DOCUMENT_ID',i_document_id);
		ec_utils.g_documents_skipped := ec_utils.g_documents_skipped + 1;

		/**
		Exit the processing for the Document
		**/
		exit;
	end if;

	if (i_insert) and not (i_insert_ok) then
   	-- Exit the processing for the document.
   	exit;
   end if;

end loop; --- ( End of Fetch )

if (ec_utils.g_ext_levels(i_level).Status = 'INSERT'
    or ec_utils.g_ext_levels(i_level).Status = 'NEW'
    or ec_utils.g_ext_levels(i_level).Status = 'RE_PROCESS') and
    Not (i_insert) then

	if (i_last_insert_level > i_level) then
		for k in ec_utils.g_ext_levels(i_level+1).file_start_pos..ec_utils.g_ext_levels(i_last_insert_level).file_end_pos
		loop
			ec_utils.g_file_tbl(k).value := m_file_tbl_empty(k).value;
		end loop;
	end if;

if ec_debug.G_debug_level = 3 then
   ec_debug.pl(3,'Ready to insert into open interface table');
   ec_debug.pl(3,'i_interface_level',i_interface_level);
end if ;

   --Insert_into_prod_interface;
   i_insert_ok := Insert_Into_prod_Interface
   (
    ec_utils.g_int_levels(i_interface_level).Cursor_handle,
    i_interface_level
   );

   --	if Insert Failed then
   if NOT ( i_insert_ok) then
      ec_utils.g_ext_levels(1).Status := 'INSERT_FAILED';
      ec_utils.g_ext_levels(i_level).Status := ec_utils.g_ext_levels(1).status;
      ec_utils.g_insert_failed := ec_utils.g_insert_failed + 1;
      ec_debug.pl(1,'EC','ECE_INSERT_SKIPPED','DOCUMENT_ID',i_document_id);
   end if;

end if;

i_total_records := dbms_sql.last_row_count;
if ec_debug.G_debug_level >= 1 then
ec_debug.pl(1,'EC','ECE_TOTAL_RECORDS_PROCESSED','TOTAL_RECORDS',i_total_records,'DOCUMENT_ID',i_document_id);

ec_debug.POP('ECE_INBOUND.RUN_INBOUND');
end if;

EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	ec_utils.i_ret_code :=0;
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.RUN_INBOUND');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END run_inbound;

procedure update_document_status
is
BEGIN

if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.UPDATE_DOCUMENT_STATUS');
end if;
  	/**
  	Update Header record in the Staging Table.
  	**/
	update  ece_stage
	set     status = ec_utils.g_ext_levels(1).Status
	where   document_id = ec_utils.g_ext_levels(1).Document_id
	and     transaction_level = 1
	and     line_number = 1;

	if sql%notfound
	then
		ec_debug.pl(0,'EC','ECE_STATUS_UPDATE_FAILED','DOCUMENT_ID',
		ec_utils.g_ext_levels(ec_utils.g_current_level).Document_Id);
		ec_utils.i_ret_code := 2;
		raise EC_UTILS.PROGRAM_EXIT;
	end if;

	if ec_utils.g_current_Level > 1
	then

		/**
		 Need to update all the previous processed line to have status
		 'INSERT' so that it will show the 'GREEN' icon in View Staged
		 Document form.
		**/

		update ece_stage
		set status = 'INSERT'
		where (stage_id > ec_utils.g_ext_levels(1).stage_id) and
		      (stage_id < ec_utils.g_ext_levels(ec_utils.g_current_level).stage_id);

  		/**
  		Update the Status of the Line where error encountered in
		the Staging Table.
  		**/
		update  ece_stage
		set     status = ec_utils.g_ext_levels(ec_utils.g_current_level).Status
		where   stage_id = ec_utils.g_ext_levels(ec_utils.g_current_level).stage_id;

		if sql%notfound
		then
			ec_debug.pl(0,'EC','ECE_STATUS_UPDATE_FAILED','DOCUMENT_ID',
			ec_utils.g_ext_levels(ec_utils.g_current_level).Document_Id);
			ec_utils.i_ret_code := 2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('ECE_INBOUND.UPDATE_DOCUMENT_STATUS');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.UPDATE_DOCUMENT_STATUS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END update_document_status;

procedure initialize_inbound
	(
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number
	)
is
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.INITIALIZE_INBOUND');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
end if;

      if g_count=0 then      			-- Bug 2422787

	/**
	Initialize the PL/SQL tables.Stack Table will be initialized
	from where it is called.
	**/
	ec_utils.g_file_tbl.DELETE;
	ec_utils.g_int_levels.DELETE;
	ec_utils.g_ext_levels.DELETE;
	ec_utils.g_int_ext_levels.DELETE;
	ec_utils.g_stack_pointer.DELETE;
	ec_utils.g_stage_data.DELETE;
     /* Bug 2019253 cleared the global stack table. */
        ec_utils.g_stack.DELETE;
	ec_utils.g_direction := 'I';
	ec_utils.g_transaction_type := i_transaction_type;
	ec_utils.g_map_id := i_map_id;
	ece_rules_pkg.g_rule_violation_tbl.DELETE;
	ece_flatfile_pvt.get_tran_attributes(i_transaction_type);

	/**
	Get all the Dynamic Inbound Staging data. The data is retrieved from the
	table ( ece_tran_stage_data ) and kept in the Local Pl/SQL table. Since the
	data is in PL/SQL memory , no further lookups in the table are required.
	This helps in improving the perfromance , as un-necessary selects are saved.
	**/
	ec_utils.get_tran_stage_data ( i_transaction_type, i_map_id);

	ec_execution_utils.load_mappings ( i_transaction_type, i_map_id);

	ec_utils.sort_stage_data;

	/**
	Execute the Dynamic Inbound Stage data for Stage = 10.
	After Level 0 execution , the Stack Pointers are built.
	**/

        ec_utils.i_stage_data := ec_utils.i_tmp_stage_data;     -- 2708573

	for i in 0..ec_utils.g_ext_levels.COUNT
	loop
		ec_utils.execute_stage_data (10,i);
        end loop;

        ec_utils.i_stage_data := ec_utils.i_tmp2_stage_data;    -- 2708573

	/**  Bug 2422787
	Save the PL/SQL table with default values. This will be used
	by all the documents.
	**/
	m_file_tbl_empty := ec_utils.g_file_tbl;
--      m_orig_int_levels       :=      ec_utils.g_int_levels;
        m_orig_ext_levels       :=      ec_utils.g_ext_levels;
--      m_orig_int_ext_levels   :=      ec_utils.g_int_ext_levels;
        m_orig_stage_data       :=      ec_utils.g_stage_data;
--      m_orig_stack_pointer    :=      ec_utils.g_stack_pointer;
        m_tmp1_stage_data       :=      ec_utils.i_tmp_stage_data;
        m_tmp2_stage_data       :=      ec_utils.i_tmp2_stage_data;
        m_tmp3_stage_data       :=      ec_utils.i_stage_data;

      -- Searching the staging table to ensure if the stage is present
      -- in the Seed Data. This is for avoiding the execution of the
      -- staging procedure unnecessarly.  Bug 2500898
        for k in 1..ec_utils.g_stage_data.COUNT
        loop
            if ec_utils.g_stage_data(k).stage=20 then
                 stage_20_flag:='Y';
            elsif ec_utils.g_stage_data(k).stage=30 then
                 stage_30_flag:='Y';
            elsif ec_utils.g_stage_data(k).stage=40 then
                 stage_40_flag:='Y';
            elsif ec_utils.g_stage_data(k).stage=50 then
                 stage_50_flag:='Y';
            end if;
        end loop;

      -- Extracting the no. from the Staging_column as this will
      -- be used  to determine the position of staging column in
      -- the dynamic select stmt on ece_stage table. Bug 2500898
        for k in 1..ec_utils.g_file_tbl.COUNT
        loop
              ec_utils.g_file_tbl(k).staging_column_no :=
                             to_number( substrb(
                                ec_utils.g_file_tbl(k).Staging_Column,
                                6,
                                length(ec_utils.g_file_tbl(k).Staging_Column)-5));
        end loop;

     else

        for i in 1..ec_utils.g_file_tbl.COUNT
        loop
                ec_utils.g_file_tbl(i).value    :=NULL;
                ec_utils.g_file_tbl(i).ext_val1 :=NULL;
                ec_utils.g_file_tbl(i).ext_val2 :=NULL;
                ec_utils.g_file_tbl(i).ext_val3 :=NULL;
                ec_utils.g_file_tbl(i).ext_val4 :=NULL;
                ec_utils.g_file_tbl(i).ext_val5 :=NULL;
        end loop;

        ec_utils.g_ext_levels    :=     m_orig_ext_levels;
        ec_utils.g_stage_data    :=     m_orig_stage_data;
        ec_utils.i_tmp_stage_data:=     m_tmp1_stage_data;
        ec_utils.i_tmp2_stage_data:=    m_tmp2_stage_data;
        ec_utils.i_stage_data    :=     m_tmp3_stage_data;

        -- Bug 2708573
	-- Initialize the g_stack instead of performing a delete.
	-- ec_utils.g_stack.DELETE;
	for i in 1..ec_utils.g_stack.COUNT
        loop
                ec_utils.g_stack(i).variable_value := NULL;
        end loop;

        ec_utils.g_stack_pointer.DELETE;
        ece_rules_pkg.g_rule_violation_tbl.DELETE;

        ec_utils.g_stack_pointer(0).start_pos :=1;
        ec_utils.g_stack_pointer(0).end_pos :=0;
        for i in 1..ec_utils.g_ext_levels.COUNT
        loop
                ec_utils.g_stack_pointer(i).start_pos :=1;
                ec_utils.g_stack_pointer(i).end_pos :=0;
        end loop;

        /**
        Execute the Dynamic Inbound Stage data for Stage = 10.
        After Level 0 execution , the Stack Pointers are built.
        **/

        ec_utils.i_stage_data := ec_utils.i_tmp_stage_data;     -- 2708573

        for i in 0..ec_utils.g_ext_levels.COUNT
        loop
                ec_utils.execute_stage_data (10,i);
        end loop;

        ec_utils.i_stage_data := ec_utils.i_tmp2_stage_data;    -- 2708573

     end if;


if ec_debug.G_debug_level>= 2 then
ec_debug.pop('ECE_INBOUND.INITIALIZE_INBOUND');
end if;
EXCEPTION
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.INITIALIZE_INBOUND');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end initialize_inbound;

procedure close_inbound
is
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.CLOSE_INBOUND');
end if;

        g_count:=0;           		  --Bug 2422787

	if ec_utils.g_documents_skipped > 0
	then
		ec_debug.pl(0,'EC','ECE_TOTAL_SKIPPED','SKIPPED',ec_utils.g_documents_skipped);
		ec_utils.i_ret_code :=1;
	end if;

	if ec_utils.g_insert_failed > 0
	then
		ec_debug.pl(0,'EC','ECE_TOTAL_FAILED','FAILED',ec_utils.g_insert_failed);
		ec_utils.i_ret_code :=1;
	end if;


	/**
	Close all open Cursors.
  	The Cursors for the Insert into Open Interface table are not closed
	in the Insert_Into_Prod_Interface function call. Since the Cursor
	handles are maintained in the I_LEVEL_INFO PL/SQL table ,
  	Cursors for the all the Level are closed using these Cursor handles.
  	**/
	For i in 1..ec_utils.g_ext_levels.COUNT
	loop
		IF dbms_sql.IS_OPEN(ec_utils.g_ext_levels(i).Cursor_Handle)
		then
			dbms_sql.Close_cursor(ec_utils.g_ext_levels(i).Cursor_Handle);
		end if;
	end loop;

if ec_debug.G_debug_level >= 2 then
ec_debug.pop('ECE_INBOUND.CLOSE_INBOUND');
end if;
EXCEPTION
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.CLOSE_INBOUND');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end close_inbound;

procedure Insert_into_violations
		(
		i_document_id	IN	number
		)
is
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.INSERT_INTO_VIOLATIONS');
ec_debug.pl(3,'i_document_id',i_document_id);
end if;
	/**
	Delete the Old violations for this Document
	**/
	Delete 	from ece_rule_violations
	where	document_id = i_document_id
	and 	ignore_flag = 'N';


	for i in 1..ece_rules_pkg.g_rule_violation_tbl.COUNT
	loop
		INSERT into ece_rule_violations
		(
			violation_id,
			document_id,
			stage_id,
			interface_column_id,
			rule_id,
			transaction_type,
			document_number,
			violation_level,
			ignore_flag,
			message_text,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login
		)
		VALUES
		(
			ece_rules_pkg.g_rule_violation_tbl(i).violation_id,
			ece_rules_pkg.g_rule_violation_tbl(i).document_id,
			ece_rules_pkg.g_rule_violation_tbl(i).stage_id,
			ece_rules_pkg.g_rule_violation_tbl(i).interface_column_id,
			ece_rules_pkg.g_rule_violation_tbl(i).rule_id,
			ece_rules_pkg.g_rule_violation_tbl(i).transaction_type,
			ece_rules_pkg.g_rule_violation_tbl(i).document_number,
			ece_rules_pkg.g_rule_violation_tbl(i).violation_level,
			ece_rules_pkg.g_rule_violation_tbl(i).ignore_flag,
			ece_rules_pkg.g_rule_violation_tbl(i).message_text,
 			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.login_id
		);
	end loop;
	/** Clean the PL/SQL table for next set of violations.
	**/
	ece_rules_pkg.g_rule_violation_tbl.DELETE;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('ECE_INBOUND.INSERT_INTO_VIOLATIONS');
end if;
EXCEPTION
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.INSERT_INTO_VIOLATIONS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end Insert_Into_Violations;

procedure process_for_reqid
	(
	errbuf		        OUT NOCOPY varchar2,
	retcode			OUT NOCOPY varchar2,
	i_transaction_type	IN	varchar2,
	i_reqid			IN	number,
	i_debug_mode		in	number
	)
is
begin
ec_debug.enable_debug(i_debug_mode);
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_FOR_REQID');
ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_reqid',i_reqid);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;
	ece_inbound.process_inbound_documents
	(
		i_transaction_type => i_transaction_type,
		i_run_id => i_reqid
		);
	retcode := ec_utils.i_ret_code;

if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(2,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pop('ECE_INBOUND.PROCESS_FOR_REQID');
end if;
ec_debug.disable_debug;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	ece_flatfile_pvt.print_attributes;
	retcode := ec_utils.i_ret_code;
	ec_debug.disable_debug;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_REQID');
WHEN OTHERS THEN
	retcode :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_FOR_REQID');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_REQID');
	ec_debug.disable_debug;
end process_for_reqid;

procedure process_for_document_id
	(
	errbuf		        OUT NOCOPY	varchar2,
	retcode		        OUT NOCOPY	varchar2,
	i_transaction_type	IN	varchar2,
	i_document_id		IN	number,
	i_debug_mode		IN	number
	)
is
begin
ec_debug.enable_debug(i_debug_mode);
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_FOR_DOCUMENT_ID');
ec_debug.pl(2,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_document_id',i_document_id);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;
	ece_inbound.process_inbound_documents
		(
		i_transaction_type => i_transaction_type,
		i_document_id => i_document_id
		);
	retcode := ec_utils.i_ret_code;
if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(2,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pop('ECE_INBOUND.PROCESS_FOR_DOCUMENT_ID');
end if;
ec_debug.disable_debug;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_DOCUMENT_ID');
WHEN OTHERS THEN
	retcode :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_FOR_DOCUMENT_ID');
	ec_debug.pl(1,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_DOCUMENT_ID');
	ec_debug.disable_debug;
end process_for_document_id;

procedure process_for_status
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_transaction_type	IN	varchar2,
	i_status		IN	varchar2,
	i_debug_mode		in	number
	)
is
begin
ec_debug.enable_debug(i_debug_mode);
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_FOR_STATUS');
ec_debug.pl(2,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_status',i_status);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;

	ece_inbound.process_inbound_documents
		(
		i_transaction_type => i_transaction_type,
		i_status => i_status
		);
	retcode := ec_utils.i_ret_code;
if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(2,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pop('ECE_INBOUND.PROCESS_FOR_STATUS');
end if;
ec_debug.disable_debug;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_STATUS');
WHEN OTHERS THEN
	retcode :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_FOR_STATUS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_STATUS');
	ec_debug.disable_debug;
end process_for_status;

procedure process_for_transaction
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_transaction_type	IN	varchar2,
	i_debug_mode		in	number
	)
is
begin
ec_debug.enable_debug(i_debug_mode);
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_FOR_TRANSACTION');
ec_debug.pl(2,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;
	ece_inbound.process_inbound_documents
		(
		i_transaction_type => i_transaction_type
		);
	retcode := ec_utils.i_ret_code;

if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(2,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TRANSACTION');
end if;
ec_debug.disable_debug;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TRANSACTION');
WHEN OTHERS THEN
	retcode :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_FOR_TRANSACTION');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TRANSACTION');
	ec_debug.disable_debug;
end process_for_transaction;

procedure process_for_tpstatus
	(
	errbuf			OUT NOCOPY	varchar2,
	retcode			OUT NOCOPY	varchar2,
	i_transaction_type	IN	varchar2,
	i_tp_code		IN	varchar2,
	i_status		IN	varchar2,
	i_debug_mode		in	number
	)
is
begin
ec_debug.enable_debug(i_debug_mode);
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_FOR_TPSTATUS');
ec_debug.pl(2,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_tp_code',i_tp_code);
ec_debug.pl(3,'i_status',i_status);
ec_debug.pl(3,'i_debug_mode',i_debug_mode);
end if;
	ece_inbound.process_inbound_documents
		(
		i_transaction_type => i_transaction_type,
		i_tp_code => i_tp_code,
		i_status => i_status
		);
	retcode := ec_utils.i_ret_code;

if ec_debug.G_debug_level >=2 then
ec_debug.pl(3,'errbuf',errbuf);
ec_debug.pl(3,'retcode',retcode);
ec_debug.pl(2,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TPSTATUS');
end if;
ec_debug.disable_debug;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TPSTATUS');
WHEN OTHERS THEN
	retcode :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_FOR_TPSTATUS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ece_flatfile_pvt.print_attributes;
	ec_debug.pop('ECE_INBOUND.PROCESS_FOR_TPSTATUS');
	ec_debug.disable_debug;
end process_for_tpstatus;

procedure process_documents
	(
	i_document_id		IN	number,
	i_transaction_type	IN	varchar2,
	i_select_cursor		IN	INTEGER
	)
is
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('ECE_INBOUND.PROCESS_DOCUMENTS');
ec_debug.pl(3,'i_document_id',i_document_id);
ec_debug.pl(3,'i_select_cursor',i_select_cursor);
end if;
	/**
	Savepoint for the document. If any error encountered during processing of the
	document , the whole document will be rolled back to this savepoint.
	Partial processing of the document is not allowed.
	**/
	savepoint document_start;

	run_inbound
	(
		i_document_id,
		i_transaction_type,
		i_select_cursor
	);

	/**
	If the Status is ABORT then stop the program execution.
	Rollback the Staging Data , Violations etc.
	**/
	if ec_utils.g_ext_levels(1).Status = 'ABORT'
	then
		rollback work;
		ec_utils.i_ret_code := 2;
		raise EC_UTILS.PROGRAM_EXIT;
	elsif (ec_utils.g_ext_levels(1).Status = 'SKIP_DOCUMENT')
		or (ec_utils.g_ext_levels(1).Status = 'INSERT_FAILED')
	then
		rollback to Document_start;
		update_document_status;
	end if;

	/**
	Make sure that the all the records for a document are successfully
	inserted into the production open Interface tables.  Check whether
	the document is ready for Insert.
	If yes then save the Document and delete from the Staging table.
	**/

	if (
		ec_utils.g_ext_levels(1).Status = 'INSERT'
		or ec_utils.g_ext_levels(1).Status = 'NEW'
		or ec_utils.g_ext_levels(1).Status = 'RE_PROCESS'
		)
	then
		delete	from ece_rule_violations
		where	document_id = i_document_id;

		delete 	from ece_stage
		where	document_id = i_document_id;

		if sql%notfound
		then
			ec_debug.pl(1,'EC','ECE_DELETE_FAILED_STAGING','DOCUMENT_ID',i_document_id);
			ec_utils.i_ret_code :=1;
			rollback to Document_Start;
		end if;
	end if;

	/** Save the Violations.  **/
	Insert_Into_Violations(i_Document_Id);
if ec_debug.G_debug_level >=2 then
ec_debug.pop('ECE_INBOUND.PROCESS_DOCUMENTS');
end if;
EXCEPTION
WHEN EC_UTILS.DOCUMENTS_UNDER_PROCESS then
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_UNDER_PROCESS',null);
	raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.PROCESS_DOCUMENTS');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code :=2;
	raise EC_UTILS.PROGRAM_EXIT;
end process_documents;

procedure select_stage
	(
	i_select_cursor		OUT NOCOPY	integer
	)
	is
i_Select_Stmt		varchar2(32000);
i_cursor_handle	pls_integer;
error_position		pls_integer;
i_level				pls_integer;
i_line_number		pls_integer;
i_stage_id			pls_integer;
i_document_number	ece_stage.document_number%TYPE;
i_status				ece_stage.status%TYPE;
i_map_id				ece_stage.map_id%TYPE;
i_columns			ece_stage.field1%TYPE;

begin
if ec_debug.G_debug_level >=2 then
ec_debug.push('ECE_INBOUND.SELECT_STAGE');
end if;

	i_Select_Stmt := 'select Stage_Id ,Document_Number ,transaction_level ,line_number ,Status , map_id, ';

	/**
	Include all the 500 Columns in the Select Clause.
	**/
	for i in 1..500
	loop
		i_Select_Stmt := i_Select_Stmt ||'FIELD'||i||',';
	end loop;

	i_Select_Stmt := RTRIM(i_Select_Stmt,',');
	i_Select_Stmt := i_Select_Stmt ||'  from ECE_STAGE where Document_Id = :i_document_id order by stage_id for update of Document_id NOWAIT';

	/**
	Open the cursor and parse the SQL Statement. Trap any parsing error and
	report the Error Position in the SQL Statement
	**/

	i_Cursor_handle := dbms_sql.Open_Cursor;

	BEGIN
		dbms_sql.parse(i_Cursor_handle,i_Select_Stmt,dbms_sql.native);
	EXCEPTION
		WHEN OTHERS THEN
			error_position := dbms_sql.last_error_position;
			ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.SELECT_STAGE');
			ece_error_handling_pvt.print_parse_error (error_position,i_Select_Stmt);
			ec_utils.i_ret_code :=2;
			raise EC_UTILS.PROGRAM_EXIT;
	END;

	/**
	Define Columns used in the Select Clause
	**/
	dbms_sql.define_column(i_Cursor_Handle,1,i_stage_id);
	dbms_sql.define_column(i_Cursor_Handle,2,i_document_number,500);
	dbms_sql.define_column(i_Cursor_Handle,3,i_level);
	dbms_sql.define_column(i_Cursor_Handle,4,i_line_number);
	dbms_sql.define_column(i_Cursor_Handle,5,i_status,20);
	dbms_sql.define_column(i_Cursor_Handle,6,i_map_id);
	for i in 7..506
	loop
		dbms_sql.define_column(i_Cursor_Handle,i,i_columns,500);
	end loop;

	ec_debug.pl(3,'Select Statement',i_select_stmt);

	i_Select_Cursor := i_Cursor_Handle;
if ec_debug.G_debug_level >=2 then
ec_debug.pl(3,'i_select_cursor',i_select_cursor);
ec_debug.pop('ECE_INBOUND.SELECT_STAGE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_INBOUND.SELECT_STAGE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code :=2;
	raise EC_UTILS.PROGRAM_EXIT;
end select_stage;


function insert_into_prod_interface
	(
	i_Insert_cursor		IN OUT NOCOPY 	INTEGER,
	i_level			IN	NUMBER
	)
return boolean
IS

cInsert_stmt	VARCHAR2(32000) := 'INSERT INTO ';
cValue_stmt	VARCHAR2(32000) := 'VALUES (';

c_Insert_cur	pls_INTEGER ;
dummy		pls_INTEGER;
d_date		DATE;
n_number	number;
c_count 	pls_integer;
i_success	BOOLEAN := TRUE;
error_position	pls_integer;

BEGIN
if ec_debug.G_debug_level >=2 then
ec_debug.push('ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
ec_debug.pl(3,'i_Insert_Cursor',i_Insert_Cursor);
ec_debug.pl(3,'i_level',i_level);
end if;

if i_Insert_Cursor = 0
then
	i_Insert_Cursor := -911;
	ec_debug.pl(3,'i_Insert_Cursor',i_Insert_Cursor);
end if;

if i_Insert_Cursor < 0
then
	cInsert_Stmt := cInsert_Stmt||' '||ec_utils.g_int_levels(i_level).Base_Table_Name||' (';

	For i in ec_utils.g_int_levels(i_level).file_start_pos..ec_utils.g_int_levels(i_level).file_end_pos
	loop
		If ( ec_utils.g_file_tbl(i).base_column_name is not null )
		then
			cInsert_stmt :=cInsert_stmt||' '||ec_utils.g_file_tbl(i).base_column_name || ',';
			cValue_stmt  := cValue_stmt || ':b' || i ||',';
		end if;
	end loop;

  	cInsert_stmt := RTRIM (cInsert_stmt, ',') || ') ';
  	cValue_stmt  := RTRIM (cValue_stmt, ',') || ')';
  	cInsert_stmt := cInsert_stmt || cValue_stmt;

       if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'Insert_Statement',cInsert_stmt);
      end if;

  	i_Insert_Cursor := dbms_sql.open_cursor;

	begin
  		dbms_sql.parse(i_Insert_Cursor, cInsert_stmt, dbms_sql.native);
	exception
	when others then
		error_position := dbms_sql.last_error_position;
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
		'ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
		ece_error_handling_pvt.print_parse_error (error_position,cInsert_stmt);
		ec_utils.i_ret_code :=2;
		ec_debug.pop('ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
		raise EC_UTILS.PROGRAM_EXIT;
	end;
end if;

if i_Insert_Cursor > 0
then

begin
   for k in ec_utils.g_int_levels(i_level).file_start_pos..ec_utils.g_int_levels(i_level).file_end_pos
   loop
		if ec_utils.g_file_tbl(k).base_column_name is not null
		then
		BEGIN
		-- This Begin is to trap the Data Type Conversion problem on a field.

			if 'DATE' = ec_utils.g_file_tbl(k).data_type
			Then
				if ec_utils.g_file_tbl(k).value is not NULL
				then
					d_date := to_date(ec_utils.g_file_tbl(k).value,'YYYYMMDD HH24MISS');
				else
					d_date := NULL;
				end if;
			      if ec_debug.G_debug_level = 3 then
				ec_debug.pl(3,ec_utils.g_file_tbl(k).Base_Column_Name,d_date);
			      end if;
				dbms_sql.bind_variable(i_Insert_Cursor, 'b'||k, d_date);

			elsif 'NUMBER' = ec_utils.g_file_tbl(k).data_type
			then
				if ec_utils.g_file_tbl(k).value is not NULL
				then
					n_number := to_number(ec_utils.g_file_tbl(k).value);
				else
					n_number := NULL;
				end if;
			      if ec_debug.G_debug_level = 3 then
				ec_debug.pl(3,ec_utils.g_file_tbl(k).Base_Column_Name,n_number);
			      end if;
				dbms_sql.bind_variable(i_Insert_Cursor, 'b'||k, n_number);

			else
                              if ec_debug.G_debug_level = 3 then
				ec_debug.pl(3,ec_utils.g_file_tbl(k).Base_Column_Name,ec_utils.g_file_tbl(k).value);
                                  end if;
				dbms_sql.bind_variable(i_Insert_Cursor, 'b'||k,ec_utils.g_file_tbl(k).value);
			end if; -- End If for Data Type

		EXCEPTION
		WHEN OTHERS then
			ec_debug.pl(0,'EC','ECE_DATATYPE_CONVERSION_FAILED',
							'DATATYPE',ec_utils.g_file_tbl(k).data_type);
			ec_debug.pl(0,ec_utils.g_file_tbl(k).Base_Column_Name,ec_utils.g_file_tbl(k).value);
			raise;
		END; --- Data Type Conversion Trap.

		end if; -- End if for i_level and Base Table Name

	end loop;
dummy := dbms_sql.execute(i_Insert_Cursor);

end;

end if;

if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'i_success',i_success);
ec_debug.pop('ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
end if;
return i_success;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
					'ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	i_success := FALSE;
	ec_utils.i_ret_code :=1;
	ec_debug.pl(0,'EC','ECE_INSERT_FAILED',null);
	ec_debug.pl(3,'i_success',i_success);
	ec_debug.pop('ECE_INBOUND.INSERT_INTO_PROD_INTERFACE');
	return i_success;
END insert_into_prod_interface;


end ece_inbound;

/
