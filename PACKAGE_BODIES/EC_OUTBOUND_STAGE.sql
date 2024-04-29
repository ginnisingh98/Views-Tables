--------------------------------------------------------
--  DDL for Package Body EC_OUTBOUND_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_OUTBOUND_STAGE" AS
-- $Header: ECOSTGB.pls 120.2.12000000.2 2007/03/09 14:41:15 cpeixoto ship $
--bug 3133379
TYPE STAGE_ID_TYPE is table of ece_stage.stage_id%TYPE index by binary_integer;
TYPE TRANSACTION_LEVEL_TYPE is table of ece_stage.transaction_level%TYPE index by binary_integer;
B_STAGE_ID STAGE_ID_TYPE;
B_TRANSACTION_LEVEL TRANSACTION_LEVEL_TYPE;
--bug 3133379
--- Local PL/SQL table variables.
i_stage_record_type	ec_utils.mapping_tbl;
i_record_info		Record_Info;
i_level_info		Level_Info;

vPath                   varchar2(1000);
vFileName               varchar2(1000);

/**
This is the Main Staging Program.
For a given transaction, and the Outbound File information i.e. File name
and File Path , it extracts the Staging table data into the Flat File. There is no
checking done for the data, and it is extracted according to the Mapping
information seeded for a transaction.
**/
PROCEDURE Get_Data
	(
	i_transaction_type	IN	varchar2,
	i_file_name		IN	varchar2,
	i_file_path		IN	varchar2,
	i_map_id		IN	number,
	i_run_id		IN	number
	)
is

	cursor 	c_level_info
		(
		p_transaction_type	varchar2,
		p_map_id		number
		)
	is
	select	eel.start_element,
		eit.interface_table_id,
		eit.key_column_name,
		eit.primary_address_type
	from	ece_interface_tables eit,
		ece_level_matrices elm,
		ece_external_levels eel
	where	eit.transaction_type = p_transaction_type
	and	eit.interface_table_id = elm.interface_table_id
	and	elm.external_level_id = eel.external_level_id
	and	eel.map_id = p_map_id
	order by to_number(external_level);

	cursor 	c_record_info
		(
		p_transaction_type	varchar2,
		p_map_id		number
		)
	is
	select	DISTINCT(eic.record_number) record_number
	        , eel.external_level external_level
	        , eel.start_element start_element
	        , COUNT(*) counter
	from	ece_interface_tables eit,
	        ece_interface_columns eic,
		ece_level_matrices elm,
		ece_external_levels eel
	where	eit.transaction_type = p_transaction_type
	and     eic.interface_table_id = eit.interface_table_id
	and	eit.interface_table_id = elm.interface_table_id
	and	elm.external_level_id = eel.external_level_id
	and     eic.record_number IS NOT NULL
	and	eic.position IS NOT NULL
	and	eel.map_id = p_map_id
	group by eel.external_level, eic.record_number, eel.start_element
	order by eel.external_level, eic.record_number;

i_level			number :=0;
i_record		number :=0;
l_next_file_pos 	number :=0;

i_stage_cursor		number :=0;
l_common_key		varchar2(2000);

i_empty_tbl		ec_utils.mapping_tbl;

BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.GET_DATA');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_map_id',i_map_id);
ec_debug.pl(3,'i_run_id',i_run_id);
end if;

-- Initialize PL/SQL tables.
i_level_info.DELETE;
i_stage_record_type.DELETE;
-- ece_flatfile_pvt.t_tran_attribute_tbl.DELETE;

-- Load the Output Definition for all Record_Number's of a Transaction
FOR transaction_level in c_level_info
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
LOOP
	i_level := i_level + 1;
	i_level_info(i_level).start_record_number := TO_NUMBER(transaction_level.start_element);
	i_level_info(i_level).Key_Column_Name := transaction_level.key_column_name;
	i_level_info(i_level).Key_Column_Staging := transaction_level.primary_address_type;
	i_level_info(i_level).primary_address_type := transaction_level.primary_address_type;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'Key Column Name',i_level_info(i_level).Key_Column_Name);
	ec_debug.pl(3,'Key Column Name',i_level_info(i_level).Key_Column_Name);
        end if;

	/**
	Set the Initial Values for each Level
	i_level_info(i_level).Select_Cursor := 0;
	i_level_info(i_level).Document_Number := NULL;
	i_level_info(i_level).Status := 'NEW';
	**/
	i_level_info(i_level).Transaction_Type := i_transaction_type;
	i_level_info(i_level).Run_Id := i_run_id;
	i_level_info(i_level).Key_Column_Position := NULL;
	i_level_info(i_level).Key_Column_Staging := NULL;
	i_level_info(i_level).tp_code_staging := NULL;

	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'EC','ECE_STAGE_START_RECORD_NUMBER','LEVEL',i_level,'START_RECORD_NUMBER',
				i_level_info(i_level).start_record_number);
        end if;
	/**
	Load the Mapping Information between Flat File and Staging Fields
	**/
	populate_flatfile_mapping
		(
		i_transaction_type,
		i_level,
		i_map_id
		);

END LOOP;

/**
Make a copy of the PL/SQL table and save it. After Inserting the Data into the
staging table , initialize the PL/SQL table with values from saved PL/SQL table.
**/
i_empty_tbl := i_stage_record_type;

/**
Check for Seed Data. If not Found then , then do not process.
**/
if i_level = 0
then
	ec_debug.pl(0,'EC','ECE_SEED_DATA_MISSING','TRANSACTION_TYPE',i_transaction_type);
	/**
	Set the Retcode for the Concurrent Manager
	**/
	ec_utils.i_ret_code := 2;
	raise ec_utils.program_exit;
end if;

/**
Build each record's SELECT statement
**/
l_next_file_pos :=1;
FOR record_level in c_record_info
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
LOOP
	i_record := i_record + 1;
	i_record_info(i_record).record_number := record_level.record_number;
	i_record_info(i_record).external_level := record_level.external_level;
	i_record_info(i_record).start_record_number := TO_NUMBER(record_level.external_level);
	i_record_info(i_record).counter := record_level.counter;

	get_select_stmt(record_level.external_level,
		        i_record_info(i_record).record_number,
		        i_record,
		        l_next_file_pos,
		        i_record_info(i_record).counter);


END LOOP;

--- operation moved to inside the Select_From_Stage_Table
--- Open the Outbound Transaction File in the Write Mode
--- u_file_handle := utl_file.fopen(i_file_path,i_file_name,'w', 3000);

vPath    := i_file_path;
vFileName:= i_file_name;


/**
Extract staging information to flat file starting with the top external level
**/
Fetch_Stage_Data
	(
	i_transaction_type,
	i_run_id,
	0,
	i_stage_cursor,
	l_common_key
	);

-- Close the Outbound Transaction File
if (utl_file.is_open(u_file_handle)) then
utl_file.fclose(u_file_handle);
end if;

/**
The Cursors for the Select From Stage table are not closed in the Select_From_Stage_table
procedure call. Since the Cursor handles are maintained in the I_LEVEL_INFO PL/SQL table,
Cursors for the all Levels are closed using these Cursor handles.
**/
FOR i in 1..i_level_info.COUNT
LOOP
	IF dbms_sql.IS_OPEN(i_level_info(i).Select_Cursor)
	THEN
		dbms_sql.Close_cursor(i_level_info(i).Select_Cursor);
	END IF;
END LOOP;

/**
Delete all records from the staging table
**/
ec_outbound.delete_stage_data
	(
	i_run_id,
	NULL
	);

ec_debug.pl(0,'EC','ECE_NO_LINES_READ','NO_OF_LINES',counter);
<<stage_over>>
	ec_debug.pl(0,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',i_document_number);
	if ec_debug.G_debug_level >= 2 then
	ec_debug.pop('EC_OUTBOUND_STAGE.GET_DATA');
	end if;
EXCEPTION
WHEN UTL_FILE.write_error THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_WRITE_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.read_error THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_READ_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_path THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_PATH',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_mode THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_MODE',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_operation THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_OPERATION',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_filehandle THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_FILEHANDLE',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.internal_error THEN
	ec_utils.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INTERNAL_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT THEN
	raise;
WHEN OTHERS THEN
	ec_utils.i_ret_code :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
END Get_Data;

/**
This procedures fetches the staging data in the proper hierarchecal order by recursively
calling itself using the current records STAGE_ID = PARENT_STAGE_ID.  It also calls the
procedures to format the common key and populate the flat file with the stage data.
Calling this procedure recursively guarantees that the flat file will be formatted in order
as long as the relationship between the STAGE_ID and the PARENT_STAGE_ID is populated
correctly by the OUTBOUND ENGINE regardless of the order they were populated.
**/
PROCEDURE Fetch_Stage_Data
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number,
	i_parent_stage_id	IN 	number,
	i_stage_cursor		IN OUT NOCOPY	number,
	i_common_key		IN OUT NOCOPY	varchar2
	) AS
Cursor cur_stage(p_transaction_type IN varchar2,
                 p_run_id           IN number
		 )
IS
  SELECT STAGE_ID,TRANSACTION_LEVEL
  FROM ECE_STAGE
  WHERE TRANSACTION_TYPE = p_transaction_type
  AND RUN_ID = p_run_id
  ORDER BY STAGE_ID;        -- bug 3133379

--cSelect_stmt		varchar2(1000) := 'SELECT STAGE_ID,  TRANSACTION_LEVEL';
--cFrom_stmt		varchar2(1000) := ' FROM ECE_STAGE';
--cWhere_stmt		varchar2(1000) := ' WHERE TRANSACTION_TYPE = :a1 AND RUN_ID = :a2 order by stage_id';  --2457262
i_select_cursor		INTEGER := 0;
dummy			INTEGER;
error_position		INTEGER;
v_parent_stage_id	number;
v_stage_id		number;
v_transaction_level	ece_stage.transaction_level%TYPE;
i_new_stage_cursor	number := 0;
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_run_id',i_run_id);
ec_debug.pl(3,'i_parent_stage_id',i_parent_stage_id);
ec_debug.pl(3,'i_stage_cursor',i_stage_cursor);
end if;
/* Implemented bulk collect for performance improvement. bug 3133379 */
  OPEN cur_stage(i_transaction_type,i_run_id);
  loop
  FETCH cur_stage BULK COLLECT INTO B_STAGE_ID,B_TRANSACTION_LEVEL limit 1000;
  EXIT WHEN B_STAGE_ID.COUNT =0;
  FOR i IN B_STAGE_ID.FIRST .. B_STAGE_ID.LAST
  LOOP

  IF b_transaction_level(i) = 1
  THEN
    i_document_number := i_document_number + 1;

  END IF;
  counter := counter + 1;
  i_select_cursor := NVL(i_level_info(b_transaction_level(i)).select_cursor,0);

    Select_From_Stage_Table(
					B_TRANSACTION_LEVEL(i),
					B_STAGE_ID(i),
					i_select_cursor,
					i_common_key
					);
    if ec_debug.G_debug_level = 3 then
    ec_debug.pl(3,'b_stage_id',b_stage_id(i));
    ec_debug.pl(3,'b_transaction_level',b_transaction_level(i));
    end if;

  END LOOP;
  b_stage_id.delete;
  b_transaction_level.delete;
  --EXIT WHEN cur_stage%NOTFOUND;
  END LOOP;
  CLOSE cur_stage;
	--cSelect_stmt := cSelect_stmt||cFrom_stmt||cWhere_stmt;

	/**
	Open the cursor and parse the SQL Statement. Trap any parsing error and report
	the Error Position in the SQL Statement
	**/
	--i_stage_cursor := dbms_sql.Open_Cursor;
	-- BEGIN
	--	dbms_sql.parse(i_stage_cursor,cSelect_stmt,dbms_sql.native);
	-- EXCEPTION
	-- WHEN OTHERS THEN
	--	error_position := dbms_sql.last_error_position;
	--	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
	--	ece_error_handling_pvt.print_parse_error (error_position,cSelect_stmt);
	-- 	EC_UTILS.i_ret_code :=2;
	--	raise EC_UTILS.PROGRAM_EXIT;
	-- END;

	/**
	Bind values
	**/
	--dbms_sql.bind_variable(i_stage_cursor,'a1',i_transaction_type);
	--dbms_sql.bind_variable(i_stage_cursor,'a2',i_run_id);
	--dbms_sql.bind_variable(i_stage_cursor,'a3',i_parent_stage_id);

 	/**
 	Define the column for return string
 	**/
 /**	dbms_sql.define_column(i_stage_cursor,1,v_stage_id);
 	dbms_sql.define_column(i_stage_cursor,2,v_parent_stage_id);
 	dbms_sql.define_column(i_stage_cursor,3,v_transaction_level);
 **/
   	/**
   	Execute the cursor; debug on the number of rows returned
   	**/
/**	BEGIN
		dummy := dbms_sql.execute(i_stage_cursor);
		if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'EC','ECE_STAGE_SELECTED',NULL);
		ec_debug.pl(3,'i_stage_cursor', i_stage_cursor);
		ec_debug.pl(3,cSelect_stmt);
		end if;

	EXCEPTION
	WHEN OTHERS THEN
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL', 'EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ec_debug.pl(0,'EC','ECE_ERROR_SQL',null);
		ec_debug.pl(0,cSelect_stmt);
		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	END; **/

/**	BEGIN
	   WHILE dbms_sql.fetch_rows(i_stage_cursor) > 0
	   LOOP
	   	dbms_sql.column_value(i_stage_cursor,1,v_stage_id);
	   	dbms_sql.column_value(i_stage_cursor,2,v_parent_stage_id);
	   	dbms_sql.column_value(i_stage_cursor,3,v_transaction_level);
		if ec_debug.G_debug_level = 3 then
	   	ec_debug.pl(3,'v_stage_id',v_stage_id);
		ec_debug.pl(3,'v_parent_stage_id',v_parent_stage_id);
		ec_debug.pl(3,'v_transaction_level',v_transaction_level);
		end if;


		if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'i_level_info(v_transaction_level).select_cursor',i_level_info(v_transaction_level).select_cursor);
		end if;

		Select_From_Stage_Table(
					v_transaction_level,
					v_stage_id,
					i_select_cursor,
					i_common_key
					);

		Fetch_Stage_Data(
				i_transaction_type,
				i_run_id,
				v_stage_id,
				i_new_stage_cursor,
				i_common_key);
	   END LOOP;
	EXCEPTION
	WHEN OTHERS THEN
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL', 'EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	END;
**/
	/**
	Close Cursor
	**/
	-- dbms_sql.close_cursor(i_stage_cursor);
        if ec_debug.G_debug_level >= 2 then
        ec_debug.pop('EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
        end if;

EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT THEN
	raise;
WHEN OTHERS THEN
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.FETCH_STAGE_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END Fetch_Stage_Data;

/**
This procedures loads the mapping information between the Flat File
and the Staging table. This information is seeded in the ECE_INTERFACE_TABLES
and ECE_INTERFACE_COLUMNS. The mapping information is loaded into the Local Body
PL/SQL table variable for a given transaction Type, record_number and level.
This PL/SQL table loaded with Mapping information is visible only to the functions
and procedures defined within this package.
**/
procedure populate_flatfile_mapping
	(
	i_transaction_type		in	varchar2,
	i_level				in	number,
	i_map_id			IN 	number
	)
is
	cursor c_file_mapping
		(
		p_transaction_type	varchar2,
		p_level			number,
		p_map_id		number
		) is
	SELECT eic.interface_table_id,
		eic.interface_column_name,
		eic.staging_column,
		eic.record_number,
		eic.record_layout_code,
		eic.record_layout_qualifier,
		eic.data_type,
		eic.position,
		eic.width
	FROM ece_interface_tables eit,
		ece_level_matrices elm,
		ece_external_levels eel,
		ece_interface_columns eic
	WHERE eit.interface_table_id = eic.interface_table_id
	AND	eit.transaction_type = p_transaction_type
	AND	eic.external_level = p_level
	AND	eit.interface_table_id = elm.interface_table_id
	AND	elm.external_level_id = eel.external_level_id
	AND	eel.map_id = p_map_id
	and     eic.record_number IS NOT NULL
	and	eic.position IS NOT NULL
	ORDER BY eic.record_number, eic.position;
i_counter	NUMBER :=i_stage_record_type.COUNT;
m_counter	number := i_counter;
b_tp_found	BOOLEAN := FALSE;
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_Level',i_level);
ec_debug.pl(3,'EC','ECE_INTERFACE_MAPPING','TRANSACTION_TYPE',i_transaction_type,'LEVEL',i_level);
end if;

FOR transaction_mapping in c_file_mapping
	(
	p_transaction_type => i_transaction_type,
	p_level => i_level,
	p_map_id => i_map_id
	)
LOOP
	i_counter := i_counter + 1;
	i_stage_record_type(i_counter).interface_level := i_level;
	i_stage_record_type(i_counter).interface_column_name := transaction_mapping.interface_column_name;
	i_stage_record_type(i_counter).staging_column := transaction_mapping.staging_column;
	i_stage_record_type(i_counter).record_number := transaction_mapping.record_number;
	i_stage_record_type(i_counter).record_layout_code := transaction_mapping.record_layout_code;
	i_stage_record_type(i_counter).record_layout_qualifier := transaction_mapping.record_layout_qualifier;
	i_stage_record_type(i_counter).data_type := transaction_mapping.data_type;
	i_stage_record_type(i_counter).position := transaction_mapping.position;
	i_stage_record_type(i_counter).width := transaction_mapping.width;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl
	(
	3,
	i_counter||'|'||
	i_level||'|'||
	transaction_mapping.interface_column_name||'|'||
	transaction_mapping.staging_column||'|'||
	transaction_mapping.record_number||'|'||
	transaction_mapping.record_layout_code||'|'||
	transaction_mapping.record_layout_qualifier||'|'||
	transaction_mapping.position||'|'||
	transaction_mapping.width||'|'||
	transaction_mapping.data_type
	);
        end if;
	IF upper(i_stage_record_type(i_counter).interface_column_name) =
		i_level_info(i_level).key_column_name
	THEN
		i_level_info(i_level).key_column_position := i_counter;
		i_level_info(i_level).key_column_staging := i_stage_record_type(i_counter).staging_column;
		if ec_debug.G_debug_level = 3 then
		ec_debug.pl
		(3,
		'Key_Column',
		i_level_info(i_level).Key_Column_position||'|'||
		i_level_info(i_level).Key_Column_position
		);
		end if;
	END IF;

	IF i_level = 1 AND
	   b_tp_found = FALSE AND
	   UPPER(i_stage_record_type(i_counter).interface_column_name) = 'TP_TRANSLATOR_CODE'
	THEN
		-- ece_flatfile_pvt.t_tran_attribute_tbl(1).key_column_name
		--			:= i_level_info(1).Key_column_name;
		-- ece_flatfile_pvt.t_tran_attribute_tbl(1).position
		--			:= i_counter;
		i_level_info(1).tp_code_staging := i_stage_record_type(i_counter).staging_column;
		if ec_debug.G_debug_level = 3 then
		ec_debug.pl
		(3,
		'tp_code_staging',
		i_stage_record_type(i_counter).staging_column
		);
		end if;
		b_tp_found := TRUE;
	END IF;

END LOOP;

	if i_counter = m_counter then
		ec_debug.pl(0,'EC','ECE_SEED_NOT_LEVEL','TRANSACTION_TYPE',i_transaction_type,'LEVEL',i_level);
		/**
		Set the Retcode for the Concurrent Manager to Error.
		**/
		ec_utils.i_ret_code := 2;
		raise EC_UTILS.PROGRAM_EXIT;
	end if;
if ec_debug.G_debug_level >= 2 then
ec_debug.pop('EC_OUTBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code:=2;
	raise ec_utils.program_exit;
END populate_flatfile_mapping;

/**
This procedure formats the main body of a SELECT statement for each record number of
a given transaction and saves the result in a local PL/SQL table for later parsing.
This procedure is called once for each record number regardless of the number of
columns in the staging table in order to save on the number of PL/SQL string operations
required
**/
PROCEDURE get_select_stmt
		(
		i_current_level		IN	NUMBER,
		i_record_num		IN	number,
		i_file_pos		IN	number,
		i_next_file_pos         IN OUT NOCOPY  number,
		i_total_rec_unit	IN	number
		)
IS
i_rec_cd	ece_interface_columns.record_layout_code%TYPE;
i_rec_ql	ece_interface_columns.record_layout_qualifier%TYPE;
c_local_chr_39  VARCHAR2(1) := fnd_global.local_chr(39);
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.GET_SELECT_STMT');
ec_debug.pl(3,'i_current_level',i_current_level);
ec_debug.pl(3,'record_number',i_record_num);
ec_debug.pl(3,'i_file_pos',i_file_pos);
ec_debug.pl(3,'counter',i_total_rec_unit);
ec_debug.pl(3,'i_next_file_pos',i_next_file_pos);
end if;

	/**
	Build Application Data SELECT statement
	**/
	FOR k IN i_next_file_pos..i_next_file_pos+i_total_rec_unit
	LOOP
	   IF i_next_file_pos <= i_stage_record_type.count
	   THEN
	      -- ec_debug.pl(3,'k:interface_level',k||'|'||i_stage_record_type(k).interface_level);
	      -- ec_debug.pl(3,'k:external_level',k||'|'||i_record_info(i_file_pos).external_level);
	      IF i_stage_record_type(k).interface_level = i_record_info(i_file_pos).external_level AND
	         i_stage_record_type(k).record_number = i_record_info(i_file_pos).record_number
	      THEN
	         -- ec_debug.pl(3,'i_next_file_pos',i_next_file_pos);
	         -- ec_debug.pl(3,'staging_column',i_stage_record_type(k).staging_column);
	         i_rec_cd := i_stage_record_type(k).record_layout_code;
	         i_rec_ql := i_stage_record_type(k).record_layout_qualifier;
	         i_record_info(i_file_pos).select_stmt := i_record_info(i_file_pos).select_stmt||
	                               '||RPAD(NVL('||
	                               NVL(i_stage_record_type(k).staging_column,'NULL')||
	                               ','||
	                               c_local_chr_39 ||g_rec_appd_fl||c_local_chr_39||
	                               '),'||
	                               i_stage_record_type(k).width||
	                               ','||
	                               c_local_chr_39||g_rec_appd_fl||c_local_chr_39||
	                               ')';
	         i_next_file_pos := i_next_file_pos + 1;
	      ELSE
	         exit;
	      END IF;
	   ELSE
	      exit;
	   END IF;
	END LOOP;

	/**
	Add LAST record number/code/qualifier found - should be seeded consistently or
	the code/qualier values will not match up exactly with what is in the data repository
	**/
	i_record_info(i_file_pos).select_stmt :=
	                   c_local_chr_39||
                           LPAD(NVL(TO_CHAR(i_record_info(i_file_pos).record_number),g_rec_num_fl),
                           g_rec_num_ln, g_rec_num_fl)||c_local_chr_39||'||'||
	                   c_local_chr_39||
                           RPAD(NVL(i_rec_cd, g_rec_lcd_fl),g_rec_lcd_ln, g_rec_lcd_fl)||
                           c_local_chr_39||'||'||
	                   c_local_chr_39||RPAD(NVL(i_rec_ql, g_rec_lql_fl),
                           g_rec_lql_ln, g_rec_lql_fl)||c_local_chr_39||
	                   i_record_info(i_file_pos).select_stmt;
	if ec_debug.G_debug_level >= 2 then
	ec_debug.pl(3,i_file_pos||'|'||
	              i_record_info(i_file_pos).record_number||'|'||
	              i_record_info(i_file_pos).select_stmt);
        ec_debug.pop('EC_OUTBOUND_STAGE.GET_SELECT_STMT');
	end if;
EXCEPTION
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.GET_SELECT_STMT');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END get_select_stmt;

/**
The Data is extracted from the Staging table using loaded in the Local PL/SQL table.
This procedures uses Transaction Level and cursor handle as parameters to parse a SQL
statement.
The Cursor handle is passed as 0 in the First call , and the subsequent calls
use the Cursor Handle returned by the Procedure. This helps in avoiding the
expensive parsing of the SQL Statement again and again for the Same level.
**/
procedure Select_From_Stage_Table
	(
	i_level		IN	NUMBER,
	i_stage_id	IN	NUMBER,
	i_select_cursor	IN OUT NOCOPY 	NUMBER,
	i_common_key	IN OUT NOCOPY	VARCHAR2
	)
is
cSelect_stmt		varchar2(32000) := 'SELECT ';
cFrom_stmt		varchar2(100)	:= ' FROM ECE_STAGE';
cWhere_stmt		varchar2(100) 	:= ' WHERE STAGE_ID = :a1';

TYPE t_dummy		IS TABLE OF varchar(2000) INDEX BY BINARY_INTEGER;
v_dummy			t_dummy;
v_dummy_tp_code		varchar2(2000);
v_dummy_key_staging	varchar2(2000);

i_select_count 		INTEGER := 0;
i_next_common_key	varchar2(2000)	:= NULL;
i_current_common_key	varchar2(2000)	:= NULL;
dummy			INTEGER;
error_position		integer;

BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_stage_id',i_stage_id);
ec_debug.pl(3,'i_select_cursor',i_select_cursor);
end if;

if i_select_cursor = 0
then
	i_select_cursor := -911;
end if;

if i_select_cursor < 0
then
	cSelect_stmt := cSelect_stmt||
			NVL(i_level_info(i_level).tp_code_staging,'NULL')||
			','||
			NVL(i_level_info(i_level).Key_Column_Staging,'NULL')||
			',';

	FOR k IN 1..i_record_info.count
	LOOP
	   -- ec_debug.pl(3,'k:external_level',k||'|'||i_record_info(k).external_level);
	   IF i_record_info(k).external_level = i_level
	   THEN
		/**
		Get Select Statement from PLSQL table
		**/
		i_select_count := i_select_count + 1;
		cSelect_stmt := cSelect_stmt||
				i_record_info(k).select_stmt||
				',';
	   END IF;
	END LOOP;

	cSelect_stmt := RTRIM(cSelect_stmt,',');
	cSelect_stmt := cSelect_stmt||cFrom_stmt||cWhere_stmt;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'cSelect_stmt',cSelect_stmt);
        end if;
	/**
	Open the cursor and parse the SQL Statement. Trap any parsing error and report
	the Error Position in the SQL Statement. Store cursor handle in PL/SQL table for
	later use.
	**/
	i_select_cursor := dbms_sql.Open_Cursor;
	BEGIN
		dbms_sql.parse(i_select_cursor,cSelect_stmt,dbms_sql.native);
		i_level_info(i_level).select_cursor := i_select_cursor;
		i_level_info(i_level).total_records := i_select_count;
	EXCEPTION
	WHEN OTHERS THEN
		error_position := dbms_sql.last_error_position;
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
		ece_error_handling_pvt.print_parse_error (error_position,cSelect_stmt);
	 	EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	END;
	if ec_debug.G_debug_level = 3 then
	ec_debug.pl(3,'EC','ECE_STAGE_SELECT_LEVEL','LEVEL',i_level,null);
	end if;
end if;

if i_select_cursor > 0
then

	/**
	Bind values for Primary Key
	**/
	dbms_sql.bind_variable(i_select_cursor,'a1',i_stage_id);
        if ec_debug.G_debug_level = 3 then
 	ec_debug.pl(3,'STAGE_ID',i_stage_id);
 	end if;
 	/**
 	Define the columns for return string
 	**/
 	dbms_sql.define_column(i_select_cursor,1,v_dummy_tp_code,2000);
 	dbms_sql.define_column(i_select_cursor,2,v_dummy_key_staging,2000);
 	FOR n IN 3..i_level_info(i_level).total_records + 2
 	LOOP
 		v_dummy(n) := '';
 		dbms_sql.define_column(i_select_cursor,n,v_dummy(n),2000);
 	END LOOP;

   	/**
   	Execute the cursor; debug on the number of rows returned
   	**/
      	BEGIN
		dummy := dbms_sql.execute(i_select_cursor);
		if ec_debug.G_debug_level = 3 then
		ec_debug.pl(3,'EC','ECE_STAGE_SELECTED',NULL);
		ec_debug.pl(3,'i_select_cursor', i_select_cursor);
		end if;
	EXCEPTION
	WHEN OTHERS THEN
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL', 'EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ec_debug.pl(0,'EC','ECE_ERROR_SQL',null);
		ec_debug.pl(0,cSelect_stmt);
		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	END;

	BEGIN
	   WHILE dbms_sql.fetch_rows(i_select_cursor) > 0
	   LOOP

		/** You can comment out this call if you don't want the Common Key to be formatted on the flat file.
		This is provides a performance boost due to the slow PL/SQL string operations required for the common key
		**/
		dbms_sql.column_value(i_select_cursor,1,v_dummy_tp_code);
		dbms_sql.column_value(i_select_cursor,2,v_dummy_key_staging);
		Select_Common_key(
				 i_level,
				 v_dummy_tp_code,
				 v_dummy_key_staging,
			  	 i_common_key
			  	 );
                if (NOT utl_file.is_open(u_file_handle)) then
                u_file_handle := utl_file.fopen(vPath,vFileName,'w', 3000);
                end if;

	   	FOR m IN 3..i_level_info(i_level).total_records + 2
 		LOOP
 			dbms_sql.column_value(i_select_cursor,m,v_dummy(m));
			UTL_FILE.PUT_LINE(u_file_handle,i_common_key||v_dummy(m));
		END LOOP;
	   END LOOP;
	EXCEPTION
	WHEN OTHERS THEN
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL', 'EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	END;

end if;
	if ec_debug.G_debug_level >= 2 then
	ec_debug.pl(3,'i_select_cursor',i_select_cursor);

	ec_debug.pop('EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
	end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT THEN
	raise;
WHEN OTHERS THEN
	IF dbms_sql.IS_OPEN(i_select_cursor)
	then
		dbms_sql.close_cursor(i_select_cursor);
	end if;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.SELECT_FROM_STAGE_TABLE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END Select_From_Stage_Table;

/**
This procedure formats the common key for each level of a given transaction.  It takes the previous common key
string and formats it according to the level before concatenting the new KEY COLUMN on to the end of it.
NOTE: all common key variables (eg: length, fill character) are defined as global variables and can be
changed if the common key specifications change or become parameters in future versions.
Additionally, the call to this procedure can be commented out if NO common key is desired.  This provides a
modest increase in perfomance and a decrease in flat file size.
**/
procedure Select_Common_Key
	(
	i_level		IN	NUMBER,
	i_tp_code	IN	VARCHAR2,
	i_key_column	IN	VARCHAR2,
	i_common_key    IN OUT NOCOPY  VARCHAR2
	)
is
i_common_key_ln		INTEGER := 0;
BEGIN
if ec_debug.G_debug_level >= 2 then
ec_debug.push('EC_OUTBOUND_STAGE.SELECT_COMMON_KEY');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_tp_code',i_tp_code);
ec_debug.pl(3,'i_key_column',i_key_column);
ec_debug.pl(3,'i_common_key',i_common_key);
end if;
	IF i_level = 1
	THEN
		i_common_key := NULL;
		/**
		Build Common Key TP CODE SELECT
		**/
		i_common_key := RPAD(SUBSTRB(NVL(i_tp_code,g_tp_ckey_fl),1,g_tp_ckey_ln),g_tp_ckey_ln,g_tp_ckey_fl);
	ELSE
		/**
		Trim off the value of the first common key in the level for later use
		**/
		i_common_key_ln := g_tp_ckey_ln + (i_level)*(g_ref_ckey_ln) - g_ref_ckey_ln;
		i_common_key := SUBSTRB(RPAD(i_common_key,g_rec_ckey_ln,g_rec_ckey_fl),1,i_common_key_ln);
	END IF;

	i_common_key := i_common_key||RPAD(SUBSTRB(NVL(i_key_column,g_ref_ckey_fl),1,g_ref_ckey_ln),g_ref_ckey_ln,g_ref_ckey_fl);

	i_common_key := RPAD(SUBSTRB(NVL(i_common_key,g_rec_ckey_fl),1,g_rec_ckey_ln),g_rec_ckey_ln,g_rec_ckey_fl);
	if ec_debug.G_debug_level >= 2 then
	ec_debug.pop('EC_OUTBOUND_STAGE.SELECT_COMMON_KEY');
	end if;
EXCEPTION
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_OUTBOUND_STAGE.SELECT_COMMON_KEY');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	ec_utils.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END Select_Common_Key;

END EC_OUTBOUND_STAGE;

/
