--------------------------------------------------------
--  DDL for Package Body EC_OUTBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_OUTBOUND" as
-- $Header: ECOUBB.pls 120.3 2005/09/29 11:18:59 arsriniv ship $

cursor	seq_stage_id
is
Select	ece_stage_id_s.NEXTVAL
from 	dual;

cursor	seq_document_id
is
select	ece_document_id_s.NEXTVAL
from	dual;
c_local_chr_10 varchar2(1) := fnd_global.local_chr(10);
c_local_chr_9  varchar2(1) := fnd_global.local_chr(9);
c_local_chr_13 varchar2(1) := fnd_global.local_chr(13);

/**
Build and Parses the Insert Statement for insert into ece_stage for each Level.
The Cursor handles are stored in the ec_utils.g_int_levels(i).cursor_handle.
**/
procedure	parse_insert_statement
		(
		i_level			in	pls_integer
		)
is
i_Insert_Cursor		pls_integer;
cInsert_stmt		varchar2(32000) := 'INSERT INTO ECE_STAGE ( ';
cValue_stmt		varchar2(32000) := 'VALUES (';
dummy			pls_integer;
error_position		pls_integer;
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.PARSE_INSERT_STATEMENT');
ec_debug.pl(3,'i_level',i_level);
end if;

	--- Add Mandatory Columns for the Record
	cInsert_stmt := cInsert_stmt||' Stage_id, Document_Id , Transaction_type , Transaction_Level ,';
	cInsert_stmt := cInsert_stmt||' Line_Number , Parent_Stage_Id , Run_Id , Document_Number ,Status ,';

	--- Add Who Columns for the Staging Table
	cInsert_stmt := cInsert_stmt||' creation_date , created_by , last_update_date , last_updated_by ,';

	cValue_stmt := cValue_stmt||':a1 ,:a2 ,:a3 ,:a4 ,:a5,:a6,:a7,:a8,:a9 ,';
	cValue_stmt := cValue_stmt||':w1 ,:w2 ,:w3 ,:w4 ,';

	--- Add Variable Columns for the Record
	for i in ec_utils.g_int_levels(i_level).file_start_pos..ec_utils.g_int_levels(i_level).file_end_pos
	loop
		if 	ec_utils.g_file_tbl(i).staging_column is not null
		then
			--- Build Insert Statement
			cInsert_stmt := cInsert_stmt||' '||ec_utils.g_file_tbl(i).staging_column|| ',';
			cValue_stmt  := cvalue_stmt || ':b'||i||',';
		end if;
	end loop;

	cInsert_stmt := RTRIM(cInsert_stmt,',')||')';
	cValue_stmt := RTRIM(cValue_stmt,',')||')';
	cInsert_stmt := cInsert_stmt||cValue_stmt;

	if ec_Debug.G_debug_level = 3 then
	ec_debug.pl(3,'EC','ECE_STAGE_INSERT_LEVEL','LEVEL',i_level,null);
	ec_debug.pl(3,cInsert_stmt);
        end if;

	/**
	Open the cursor and parse the SQL Statement. Trap any parsing error and report
	the Error Position in the SQL Statement
	**/
	i_Insert_Cursor := dbms_sql.Open_Cursor;

	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'i_insert_cursor',i_insert_cursor);
	end if;

	ec_utils.g_ext_levels(i_level).cursor_handle := i_insert_cursor;

	begin
		dbms_sql.parse(i_Insert_Cursor,cInsert_stmt,dbms_sql.native);
	exception
	when others then
		error_position := dbms_sql.last_error_position;
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.PARSE_INSERT_STATEMENT');
		ece_error_handling_pvt.print_parse_error (error_position,cInsert_stmt);
		ec_utils.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	end;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.PARSE_INSERT_STATEMENT');
end if;

EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.PARSE_INSERT_STATEMENT');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
END parse_insert_statement;

/**
Prepares the Select statement for the ec_views on the base Oracle Applications tables.
**/
procedure select_clause
	(
        i_level       	IN 		pls_integer,
        i_Where_string   OUT NOCOPY		VARCHAR2
	) IS
cSelect_stmt         VARCHAR2(32000) := 'SELECT ';
cFrom_stmt           VARCHAR2(100) := ' FROM ';
cWhere_stmt		VARCHAR2(80) := ' WHERE 1=1 ';

cTO_CHAR		VARCHAR2(20) := 'TO_CHAR(';
cDATE		VARCHAR2(40) := ',''YYYYMMDD HH24MISS'')';
cWord1		VARCHAR2(20) := ' ';
cWord2		VARCHAR2(40) := ' ';

iRow_count		pls_integer := ec_utils.g_file_tbl.COUNT;

BEGIN
if ec_debug.G_debug_level >= 2 then
EC_DEBUG.PUSH('EC_OUTBOUND.SELECT_CLAUSE');
EC_DEBUG.PL(3, 'i_level',i_level);
end if;

For i in ec_utils.g_int_levels(i_level).file_start_pos..ec_utils.g_int_levels(i_level).file_end_pos
loop
      	-- **************************************
      	-- apply appropriate data conversion
      	-- convert everything to VARCHAR
      	-- **************************************

      		if 'DATE' = ec_utils.g_file_tbl(i).data_type Then
         		cWord1 := cTO_CHAR;
         		cWord2 := cDATE;

      		elsif 'NUMBER' = ec_utils.g_file_tbl(i).data_type Then
         		cWord1 := cTO_CHAR;
         		cWord2 := ')';
      		else
         		cWord1 := NULL;
         		cWord2 := NULL;
      		END if;

      	-- build SELECT statement
       		cSelect_stmt :=  cSelect_stmt || ' ' || cWord1 ||
			nvl(ec_utils.g_file_tbl(i).base_column_Name,'NULL') || cWord2 || ',';
End Loop;

   -- build FROM, WHERE statements

cFrom_stmt  := cFrom_Stmt||' '||ec_utils.g_int_levels(i_level).base_table_name;

cSelect_stmt := RTRIM(cSelect_stmt, ',');
i_Where_string := cSelect_stmt||' '||cFrom_stmt||' '||cWhere_Stmt;

if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'i_Where_String',i_Where_String);
EC_DEBUG.POP('EC_OUTBOUND.SELECT_CLAUSE');
end if;

exception
when others then
	EC_DEBUG.PL(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.SELECT_CLAUSE');
	EC_DEBUG.PL(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
END select_clause;

/**
Loads the Objects required by the Outbound transaction. This includes
1. Select statement on the ec_views.
2. Insert statement for ece_stage table.
3. Parses and loads Custom Procedures into memory table.
4. Loads mappings required by these procedures into memory tables.
**/
procedure load_objects
is
i_counter	pls_integer :=0;
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.LOAD_OBJECTS');
end if;

for i in 1..ec_utils.g_int_levels.COUNT
LOOP
	select_clause
		(
		i,
		ec_utils.g_int_levels(i).sql_stmt
		);

	ec_utils.execute_stage_data
		(
		10,
		i
		);


	-- Open Cursor For Each level and store the handles in the PL/SQL table.
	ec_utils.g_int_levels(i).Cursor_handle := dbms_sql.open_cursor;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'Cursor handle',ec_utils.g_int_levels(i).Cursor_handle);
        end if;

	-- Parse the Select Statement for Each level
	BEGIN
		dbms_sql.parse	(
				ec_utils.g_int_levels(i).cursor_handle,
				ec_utils.g_int_levels(i).sql_stmt,
				dbms_sql.native
				);
	EXCEPTION
	WHEN OTHERS THEN
		ece_error_handling_pvt.print_parse_error
				(
				dbms_sql.last_error_position,
				ec_utils.g_int_levels(i).sql_stmt
				);
        	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.LOAD_OBJECTS');
		ec_debug.pl(0,'EC','ECE_PARSE_VIEW_ERROR','LEVEL',i);
		raise EC_UTILS.PROGRAM_EXIT;
	END;

	i_counter :=0;
	-- Define Columns for Each Level
	FOR k in ec_utils.g_int_levels(i).file_start_pos..ec_utils.g_int_levels(i).file_end_pos
	LOOP
			i_counter := i_counter + 1;
			dbms_sql.define_column
				(
				ec_utils.g_int_levels(i).Cursor_Handle,
				i_counter,
				ec_utils.g_int_levels(i).sql_stmt,
				ece_extract_utils_PUB.G_MaxColWidth
				);
	END LOOP;

END LOOP;

ec_utils.i_stage_data := ec_utils.i_tmp2_stage_data;    -- 2920679

for i in 1..ec_utils.g_ext_levels.COUNT
LOOP
	-- Parse the Insert Statement for Staging table.
	parse_insert_statement
			(
			i
			);
end loop;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.LOAD_OBJECTS');
end if;

EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.LOAD_OBJECTS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end load_objects;


/**
Bind the values to the Insert statement for the ece_stage table.
**/
procedure	bind_insert_statement
		(
		i_level		in	pls_integer
		)
is
i_Insert_Cursor		pls_integer := ec_utils.g_ext_levels(i_level).cursor_handle;
dummy			pls_integer;
error_position		pls_integer;
i_status		ece_stage.status%TYPE := 'NEW';
ins_value               varchar2(32000);
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.BIND_INSERT_STATEMENT');
ec_debug.pl(3,'i_level',i_level);
end if;

	begin
		-- Bind values for Mandatory Columns
		dbms_sql.bind_variable (i_Insert_Cursor,'a1',to_number(ec_utils.g_ext_levels(i_level).Stage_Id));
		dbms_sql.bind_variable (i_Insert_Cursor,'a2',to_number(ec_utils.g_ext_levels(i_level).Document_Id));
		dbms_sql.bind_variable (i_Insert_Cursor,'a3',ec_utils.g_transaction_type);
		dbms_sql.bind_variable (i_Insert_Cursor,'a4',to_number(i_level));
		dbms_sql.bind_variable (i_Insert_Cursor,'a5',to_number(ec_utils.g_ext_levels(i_level).Line_Number));
		dbms_sql.bind_variable (i_Insert_Cursor,'a6',ec_utils.g_ext_levels(i_level).Parent_Stage_Id);
		dbms_sql.bind_variable (i_Insert_Cursor,'a7',ec_utils.g_run_id);
		dbms_sql.bind_variable (i_Insert_Cursor,'a8',ec_utils.g_ext_levels(i_level).Document_Number);
		dbms_sql.bind_variable (i_Insert_Cursor,'a9',i_status);

		-- Bind values for Mandatory Columns
		dbms_sql.bind_variable (i_Insert_Cursor,'w1',sysdate);
		dbms_sql.bind_variable (i_Insert_Cursor,'w2',fnd_global.user_id);
		dbms_sql.bind_variable (i_Insert_Cursor,'w3',sysdate);
		dbms_sql.bind_variable (i_Insert_Cursor,'w4',fnd_global.user_id);

                if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'STAGE_ID',ec_utils.g_ext_levels(i_level).Stage_Id);
		ec_debug.pl(3,'DOCUMENT_ID',ec_utils.g_ext_levels(i_level).Document_Id);
		ec_debug.pl(3,'TRANSACTION_TYPE',ec_utils.g_transaction_type);
		ec_debug.pl(3,'TRANSACTION_LEVEL',i_level);
		ec_debug.pl(3,'LINE_NUMBER',ec_utils.g_ext_levels(i_level).Line_Number);
		ec_debug.pl(3,'PARENT_STAGE_ID',ec_utils.g_ext_levels(i_level).Parent_Stage_Id);
		ec_debug.pl(3,'RUN_ID',ec_utils.g_run_id);
		ec_debug.pl(3,'DOCUMENT_NUMBER',ec_utils.g_ext_levels(i_level).Document_Number);
		ec_debug.pl(3,'CREATION_DATE',sysdate);
		ec_debug.pl(3,'CREATED_BY',fnd_global.user_id);
		ec_debug.pl(3,'LAST_UPDATE_DATE',sysdate);
		ec_debug.pl(3,'LAST_UPDATED_BY',fnd_global.user_id);
		end if;

		-- Bind values for Staging Columns mapped to the Flat File
		for k in ec_utils.g_int_levels(i_level).file_start_pos..ec_utils.g_int_levels(i_level).file_end_pos
		loop
			if 	( ec_utils.g_file_tbl(k).staging_column is not null)
			then
                                ins_value := replace(replace(replace(ec_utils.g_file_tbl(k).value,c_local_chr_10,''),c_local_chr_9,''),c_local_chr_13,'');
				dbms_sql.bind_variable	(
							i_Insert_Cursor,
							'b'||k,ins_value,
							500
							);
                                if ec_debug.G_debug_level = 3 then
				ec_debug.pl(3,upper(ec_utils.g_file_tbl(k).staging_column)||'-'||
						upper(ec_utils.g_file_tbl(k).interface_column_name),
						ec_utils.g_file_tbl(k).value);
			        end if;
			end if;
		end loop;

		dummy := dbms_sql.execute(i_Insert_Cursor);
		if dummy = 1 then
		        if ec_debug.G_debug_level = 3 then
			ec_debug.pl(3,'EC','ECE_STAGE_INSERTED',null);
			end if;
		else
			ec_debug.pl(0,'EC','ECE_STAGE_INSERT_FAILED','LEVEL',i_level);
			ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.BIND_INSERT_STATEMENT');
			ec_utils.i_ret_code :=2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

	exception
	when others then
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.BIND_INSERT_STATEMENT');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ec_debug.pl(0,'EC','ECE_ERROR_SQL',null);

		ec_utils.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	end;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.BIND_INSERT_STATEMENT');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.BIND_INSERT_STATEMENT');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
END bind_insert_statement;


/**
Inserts the data into the staging table.
**/
procedure	insert_into_stage
		(
		i_level		in	pls_integer
		)
is
i_parent_stage_id	pls_integer;
i_stage_id		pls_integer;
i_document_id		pls_integer;
i_line_number		pls_integer :=0;
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.INSERT_INTO_STAGE');
ec_debug.pl(3,'i_level',i_level);
end if;

			-- Generate Stage Id anyways
			open	seq_stage_id;
			fetch	seq_stage_id
			into	i_stage_id;
			close	seq_stage_id;

			-- Insert data into Stage table
			if i_level = 1
			then
				--Generate Document Id
				open 	seq_document_id;
				fetch	seq_document_id
				into 	i_document_id;
				close	seq_document_id;

				ec_utils.g_ext_levels(1).document_id := i_document_id;
				ec_utils.g_ext_levels(1).parent_stage_id := 0;
				ec_utils.g_ext_levels(1).Line_Number := 1;
				ec_utils.g_ext_levels(1).stage_id := i_stage_id;

				/**
				Initialize all the Down Levels
				**/
				for j in 2..ec_utils.g_ext_levels.COUNT
				loop
					ec_utils.g_ext_levels(j).document_id := i_document_id;
					ec_utils.g_ext_levels(j).parent_stage_id := null;
					ec_utils.g_ext_levels(j).Line_Number := 0;
					ec_utils.g_ext_levels(j).stage_id := null;
				end loop;


				if g_key_column_pos is null
				then
				        if ec_debug.G_debug_level >= 1 then
					ec_debug.pl(1,'EC','ECE_DOCUMENT_ID','DOCUMENT_ID',i_document_id);
					end if;
				else
				        if ec_debug.G_debug_level >= 1 then
					ec_debug.pl(1,'EC','ECE_DOCUMENT_ID','DOCUMENT_ID',i_document_id,
						'DOCUMENT_NUMBER',ec_utils.g_file_tbl(g_key_column_pos).value);
					end if;
					ec_utils.g_ext_levels(1).Document_Number :=
						ec_utils.g_file_tbl(g_key_column_pos).value;
				end if;
			else
				ec_utils.g_ext_levels(i_level).Line_Number :=
					ec_utils.g_ext_levels(i_level).Line_Number + 1;
				ec_utils.g_ext_levels(i_level).stage_id := i_stage_id;
				/**
				If the previous Level Stage Id is null , go all the way up till you find
				a not null stage_id.
				**/
				for j in REVERSE 1..i_level-1
				loop
					if ec_utils.g_ext_levels(j).stage_id is not null
					then
						ec_utils.g_ext_levels(i_level).parent_stage_id :=
							ec_utils.g_ext_levels(j).stage_id;
						exit;
					end if;
				end loop;

				/**
				Initialize all Down Levels
				**/
				for j in i_level+1..ec_utils.g_ext_Levels.COUNT
				loop
					ec_utils.g_ext_levels(j).parent_stage_id := null;
					ec_utils.g_ext_levels(j).Line_Number := 0;
				end loop;
			end if;
                        if ec_debug.G_debug_level = 3 then
			ec_debug.pl(3,'Stage Id',ec_utils.g_ext_levels(i_level).Stage_Id);
			ec_debug.pl(3,'Document Id',ec_utils.g_ext_levels(i_level).Document_Id);
			ec_debug.pl(3,'Document Number',ec_utils.g_ext_levels(i_level).Document_Number);
			ec_debug.pl(3,'Line Number',ec_utils.g_ext_levels(i_level).Line_Number);
			ec_debug.pl(3,'Parent Stage Id',ec_utils.g_ext_levels(i_level).Parent_Stage_Id);
			ec_debug.pl(3,'Transaction Level',ec_utils.g_ext_levels(i_level).external_level);
			end if;

			bind_insert_statement
				(
				i_level
				);
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.INSERT_INTO_STAGE');
end if;

EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.INSERT_INTO_STAGE');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
END insert_into_stage;


/**
Fetches data from the ec_views recurrsively for a given document.
**/
procedure fetch_data_from_view
	(
	i_level		IN	pls_integer
	)
is

i_column_counter	pls_integer :=0;
i_rows_processed	pls_integer ;
i_init_msg_list		varchar2(20);
i_simulate		varchar2(20);
i_validation_level	varchar2(20);
i_commit		varchar2(20);
i_return_status		varchar2(20);
i_msg_count		varchar2(20);
i_msg_data		varchar2(2000);


BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.FETCH_DATA_FROM_VIEW');
ec_debug.pl(3,'i_level',i_level);
end if;

for i in 1..ec_utils.g_int_levels.COUNT
loop
	IF ec_utils.g_int_levels(i).parent_level = i_level
	THEN
		-- Set the Global Variable for Current Level
		ec_utils.g_current_level := i;
		ec_utils.execute_stage_data
				(
				20,
				i
				);

		i_rows_processed := dbms_sql.execute (ec_utils.g_int_levels(i).Cursor_Handle);
                if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'Cursor Handle',ec_utils.g_int_levels(i).Cursor_handle);
		end if;
		while dbms_sql.fetch_rows( ec_utils.g_int_levels(i).Cursor_handle) > 0
		LOOP
		        if ec_debug.G_debug_level = 3 then
			ec_debug.pl(3,'Processing Row: '||dbms_sql.last_row_count||' for Level '||
					ec_utils.g_int_levels(i).interface_level);
			end if;
			-- Get Values from the View
			-- Initialize the Column Counter
			i_column_counter :=0;
			for j in ec_utils.g_int_levels(i).file_start_pos..ec_utils.g_int_levels(i).file_end_pos
			loop
					i_column_counter := i_column_counter + 1;

					dbms_sql.column_value
						(
						ec_utils.g_int_levels(i).Cursor_handle,
						i_column_counter,
						ec_utils.g_file_tbl(j).value
						);
                                        if ec_debug.G_debug_level = 3 then
					 if ec_utils.g_file_tbl(j).base_column_name is not null
					 then
						ec_debug.pl(
							3,
							ec_utils.g_file_tbl(j).base_column_name,
							ec_utils.g_file_tbl(j).value
							);
					 end if;
					end if;
			end loop;

			-- Stage 30 Actions
			ec_utils.execute_stage_data
				(
				30,
				i
				);


			for k in 1..ec_utils.g_int_ext_levels.COUNT
			loop
				if ec_utils.g_int_ext_levels(k).interface_level = i
				then
					if k < ec_utils.g_int_ext_levels.COUNT
					then
						if ec_utils.g_int_ext_levels(k+1).external_level  <>
							ec_utils.g_int_ext_levels(k).external_level
						then

						/**
						Perform Code Conversion
						**/
						ec_code_conversion_pvt.populate_plsql_tbl_with_extval
						(
						p_api_version_number 	=> 1.0,
						p_init_msg_list		=> i_init_msg_list,
						p_simulate		=> i_simulate,
						p_commit		=> i_commit,
						p_validation_level	=> i_validation_level,
						p_return_status		=> i_return_status,
						p_msg_count		=> i_msg_count,
						p_msg_data		=> i_msg_data,
						p_level		=> ec_utils.g_int_ext_levels(k).external_level,
						p_tbl			=> ec_utils.g_file_tbl
						);

						/**
        					Check the Status of the Code Conversion API
        					and take appropriate action.
						**/
        					IF 	(
							i_return_status = FND_API.G_RET_STS_ERROR OR
							i_return_status is NULL OR
							i_return_status = FND_API.G_RET_STS_UNEXP_ERROR
							)
						THEN
        						ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
								'EC_OUTBOUND.FETCH_DATA_FROM_VIEW');
							ec_debug.pl(0,'EC','EC_CODE_CONVERSION_FAILED','LEVEL',i);
                					ec_utils.i_ret_code := 2;
                					RAISE EC_UTILS.PROGRAM_EXIT;
        					END IF;

						-- Stage 40 Actions
						ec_utils.execute_stage_data
							(
							40,
							i
							);

							/**
							Write to Flat File , if staging is not used.
							**/
							--Insert into Staging
							insert_into_stage
									(
									ec_utils.g_int_ext_levels(k).external_level
									);

						end if;
					else
						/**
						Perform Code Conversion
						**/
						ec_code_conversion_pvt.populate_plsql_tbl_with_extval
						(
						p_api_version_number 	=> 1.0,
						p_init_msg_list		=> i_init_msg_list,
						p_simulate		=> i_simulate,
						p_commit		=> i_commit,
						p_validation_level	=> i_validation_level,
						p_return_status		=> i_return_status,
						p_msg_count		=> i_msg_count,
						p_msg_data		=> i_msg_data,
						p_level		=> ec_utils.g_int_ext_levels(k).external_level,
						p_tbl			=> ec_utils.g_file_tbl
						);

						/**
        					Check the Status of the Code Conversion API
        					and take appropriate action.
						**/
        					IF 	(
							i_return_status = FND_API.G_RET_STS_ERROR OR
							i_return_status is NULL OR
							i_return_status = FND_API.G_RET_STS_UNEXP_ERROR
							)
						THEN
        						ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
								'EC_OUTBOUND.FETCH_DATA_FROM_VIEW');
							ec_debug.pl(0,'EC','EC_CODE_CONVERSION_FAILED','LEVEL',i);
                					ec_utils.i_ret_code := 2;
                					RAISE EC_UTILS.PROGRAM_EXIT;
        					END IF;

						-- Stage 40 Actions
						ec_utils.execute_stage_data
							(
							40,
							i
							);

							/**
							Write to Flat File , if staging is not used.
							**/
							--Insert into Staging
							insert_into_stage
								(
								ec_utils.g_int_ext_levels(k).external_level
								);
					end if;
				end if;
			end loop;

			-- Stage 50 Actions
			ec_utils.execute_stage_data
				(
				50,
				i
				);

			-- Fetch Child records recursively
			fetch_data_from_view (i);

		END LOOP;
		if i = 1
		then
			ec_utils.g_int_levels(i).rows_processed := dbms_sql.last_row_count;
		else
			ec_utils.g_int_levels(i).rows_processed :=
				ec_utils.g_int_levels(i).rows_processed + dbms_sql.last_row_count;
		end if;

	END IF;
end loop;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.FETCH_DATA_FROM_VIEW');
end if;

EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
        raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.FETCH_DATA_FROM_VIEW');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
END fetch_data_from_view;

/**
Closes all the cursor handles .
**/
procedure close_outbound
is
begin
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.CLOSE_OUTBOUND');
end if;
/**
Successful execution of the transaction. Close the Cursor handles,
Disbale the Debug.
**/

for i in 1..ec_utils.g_procedure_stack.COUNT
loop
	if dbms_sql.IS_OPEN(ec_utils.g_procedure_stack(i).Cursor_Handle)
	then
		dbms_sql.close_cursor(ec_utils.g_procedure_stack(i).Cursor_Handle);
	end if;
end loop;

for i in 1..ec_utils.g_int_levels.COUNT
loop
	if dbms_sql.IS_OPEN(ec_utils.g_int_levels(i).Cursor_Handle)
	then
		dbms_sql.close_cursor(ec_utils.g_int_levels(i).Cursor_Handle);
	end if;
end loop;

for i in 1..ec_utils.g_ext_levels.COUNT
loop

	if dbms_sql.IS_OPEN(ec_utils.g_ext_levels(i).cursor_handle)
	then
		dbms_sql.close_cursor(ec_utils.g_ext_levels(i).cursor_handle);
	end if;
end loop;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.CLOSE_OUTBOUND');
end if;

exception
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.CLOSE_OUTBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code :=2;
        raise EC_UTILS.PROGRAM_EXIT;
end close_outbound;

/**
Main Call for Processing Outbound Documents
**/
procedure process_outbound_documents
	(
	i_transaction_type	IN	varchar2,
	i_map_id		IN	pls_integer,
	i_run_id		OUT NOCOPY	pls_integer
	)
is
i_plsql_pos		pls_integer;
begin
ec_debug.pl(0,'EC','ECE_START_OUTBOUND','TRANSACTION_TYPE',i_transaction_type,'MAP_ID',i_map_id);
if ec_debug.G_debug_level >= 2 then
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.push('EC_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
end if;

	/** Initialize Memory Structures**/
	ec_utils.g_file_tbl.DELETE;
	ec_utils.g_int_levels.DELETE;
	ec_utils.g_ext_levels.DELETE;
	ec_utils.g_int_ext_levels.DELETE;
	ec_utils.g_stage_data.DELETE;
	ec_utils.g_parameter_stack.DELETE;
	ec_utils.g_procedure_stack.DELETE;
	ec_utils.g_procedure_mappings.DELETE;
	ec_utils.g_stack_pointer.DELETE;
	ec_utils.g_transaction_type := i_transaction_type;
	ec_utils.g_direction := substrb(i_transaction_type,length(i_transaction_type),1);
	ec_utils.g_map_id := i_map_id;

	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'g_direction',ec_utils.g_direction);
        end if;
	/**
	If the program is run from SQLplus , the Concurrent Request id is
	< 0. In this case , get the run id from ECE_OUTPUT_RUNS_S.NEXTVAL.
	**/
	i_run_id := fnd_global.conc_request_id;
	if i_run_id <= 0
	then
        	select  ece_output_runs_s.NEXTVAL
        	into    i_run_id
        	from    dual;
	end if;
	ec_utils.g_run_id := i_run_id;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'Run Id for the Transaction',ec_utils.g_run_id);
        end if;

	ec_utils.get_tran_stage_data
		(
		i_transaction_type,
		i_map_id
		);

	ec_execution_utils.load_mappings
		(
		i_transaction_type,
		i_map_id
		);

	ec_utils.sort_stage_data;

	ec_utils.find_pos
        	(
		1,
		ec_utils.g_int_levels(1).key_column_name,
		i_plsql_pos,
		TRUE
        	);

		g_key_column_pos := i_plsql_pos;

        ec_utils.i_stage_data := ec_utils.i_tmp_stage_data;     -- 2920679

	ec_utils.execute_stage_data
		(
		10,
		0
		);

	load_objects;

	fetch_data_from_view (0);
	if ec_debug.G_debug_level >= 1 then
	for i in 1..ec_utils.g_int_levels.COUNT
	loop
		ec_debug.pl(1,ec_utils.g_int_levels(i).rows_processed||' row(s) processed for Level '||i);
	end loop;
        end if;
ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',ec_utils.g_int_levels(1).rows_processed);

close_outbound;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
end if;
ec_debug.pl(0,'EC','ECE_FINISH_OUTBOUND','TRANSACTION_TYPE',i_transaction_type,'MAP_ID',i_map_id);
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
        ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	close_outbound;
	ec_debug.pop('EC_OUTBOUND.PROCESS_OUTBOUND_DOCUMENTS');
	raise EC_UTILS.PROGRAM_EXIT;
end process_outbound_documents;

/**
This file will delete all records in a staging table without using the
expense parsing of dbms_sql package.  The RUN_ID parameter is the only required parameter.
The DOCUMENT_ID parameter can be optionally used to delete one document from the staging table
at a time.
**/
procedure delete_stage_data
	(
	i_run_id		IN	number,
	i_document_id		IN	number DEFAULT NULL
	) IS
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND.DELETE_STAGE_DATA');
ec_debug.pl(3,'i_run_id',i_run_id);
ec_debug.pl(3,'i_document_id',i_document_id);
end if;
	IF i_run_id IS NULL THEN
		ec_debug.pl(0,'EC','ECE_PARAM_MISSING','PARAMETER','I_RUN_ID', 'PROCEDURE','EC_OUTBOUND.DELETE_STAGE_DATA');
		/**
		Set the FAILURE Retcode for the Concurrent Manager
		**/
		EC_UTILS.i_ret_code := 2;
	        raise EC_UTILS.PROGRAM_EXIT;
	END IF;

	/**
	Delete all indicated records from ECE_STAGE
	**/
	DELETE FROM ece_stage
	WHERE run_id = i_run_id
	AND (document_id = i_document_id OR i_document_id IS NULL);

	IF SQL%ROWCOUNT = 0 THEN
		/**
		Output a warning message if no rows are deleted
		**/
		if ec_debug.G_debug_level >= 1 then
		ec_debug.pl(1,'NO rows deleted from ECE_STAGE');
		end if;
	END IF;
	if ec_debug.G_debug_level >= 2 then
	ec_debug.pl(3,'Number of rows deleted from ECE_STAGE',SQL%ROWCOUNT);

ec_debug.pop('EC_OUTBOUND.DELETE_STAGE_DATA');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND.DELETE_STAGE_DATA');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
        ec_utils.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END delete_stage_data;

end ec_outbound;

/
