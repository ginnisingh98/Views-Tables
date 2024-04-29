--------------------------------------------------------
--  DDL for Package Body EC_INBOUND_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_INBOUND_STAGE" AS
-- $Header: ECISTGB.pls 120.4 2005/09/29 10:38:49 arsriniv ship $

--- Local PL/SQL table variables.
--- i_stage_record_type	Stage_Record_Type;
i_stage_record_type	ec_utils.mapping_tbl;
i_level_info		Level_Info;
--bug 2110652
i_db_charset             varchar2(50);
i_db_charset_flag       varchar2(1);
i_fnd_charset_flag      varchar2(1);
--bug 2164672
i_data_status_flag      boolean:= TRUE;

/**
This is the Main Staging Program.
For a given transaction , and the Inbound File information i.e. File name
and File Path , it loads the Flat File into the Staging table. There is no
checking done for the data , and is loaded according to the Mapping
information seeded for a transaction.
**/
PROCEDURE Load_Data
	(
	i_transaction_type	IN	varchar2,
	i_file_name		IN	varchar2,
	i_file_path		IN	varchar2,
	i_map_id		IN	number,
	i_run_id		OUT NOCOPY	number
	)
is
	cursor 	c_level_info
		(
		p_transaction_type	varchar2,
		p_map_id		number
		)
	is
	select	eel.start_element,
                eel.external_level,
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

	cursor seq_stage_id
	is
	select	ece_stage_id_s.NEXTVAL
	from	dual;

	cursor seq_document_id
	is
	select	ece_document_id_s.NEXTVAL
	from	dual;

counter			number :=0;
i_level			number :=0;
l_file_pos		number :=0;
l_next_file_pos 	NUMBER :=0;
l_total_rec_unit	number :=0;
l_rec_number		NUMBER;
u_file_handle		utl_file.file_type;
c_current_line		varchar2(2000);
v_next_rec_number	varchar2(22);
next_rec_number		number :=0;
skip_record_flag	BOOLEAN := FALSE;
end_of_file		BOOLEAN := FALSE;
i_valid_record		BOOLEAN := FALSE;
match_found		BOOLEAN := FALSE;
i_first_line_flag	BOOLEAN := TRUE;
Document_Id		number :=0;
i_current_level		number :=1;
i_previous_level	number :=0;
i_stage_id		number :=0;
i_insert_cursor		number :=0;
i_document_number	number :=0;
i_empty_tbl		ec_utils.mapping_tbl;
i_translator_code	varchar2(400);
i_location_code		varchar2(400);
i_tp_code		varchar2(400);
i_translator_code_pos	number;
i_location_code_pos	number;

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_INBOUND_STAGE.LOAD_DATA');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_file_name',i_file_name);
ec_debug.pl(3,'i_file_path',i_file_path);
ec_debug.pl(3,'i_map_id',i_map_id);

end if;
/**
This program uses two PL/SQL tables defined in the Spec of the Package.

i_level_info		Stores the information about a particular level.
			This table is updated after each record is read i.e.
			Document Id , Stage Id , Line Number,Parent Stage id etc.
			and is used while inserting a record in the Staging table for a level.

i_stage_record_type	Stores the Mapping information for the Flat File
			Level,Record Number,Position,Staging Column,Width etc.
**/

-- Initialize PL/SQL tables.
i_level_info.DELETE;
i_stage_record_type.DELETE;
ece_flatfile_pvt.t_tran_attribute_tbl.DELETE;

/**
If the program is run from SQLplus , the Concurrent Request id is
< 0. In this case , get the run id from ECE_OUTPUT_RUNS_S.NEXTVAL.
**/
i_run_id := fnd_global.conc_request_id;
if i_run_id <= 0
then
	select	ece_output_runs_s.NEXTVAL
	into	i_run_id
	from	dual;
end if;
if EC_DEBUG.G_debug_level = 3 then
ec_debug.pl(3,'i_run_id',i_run_id);
end if;
-- Load the Output Definition for all Levels of a Transaction

FOR transaction_level in c_level_info
	(
	p_transaction_type => i_transaction_type,
	p_map_id => i_map_id
	)
loop
    i_level := transaction_level.external_level;

    if (i_level <> i_previous_level) then
        i_previous_level := i_level;
	i_level_info(i_level).start_record_number := TO_NUMBER(transaction_level.start_element);
	i_level_info(i_level).Key_Column_Name := transaction_level.key_column_name;
	i_level_info(i_level).primary_address_type := transaction_level.primary_address_type;

        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'Key Column Name',i_level_info(i_level).Key_Column_Name);
        end if;

	/**
	Set the Initial Values for each Level
	**/

	i_level_info(i_level).Document_Id := 0;
	i_level_info(i_level).Line_Number := 0;
	i_level_info(i_level).Parent_Stage_Id := 0;
	i_level_info(i_level).Insert_Cursor := 0;
	i_level_info(i_level).Stage_Id := 0;
	i_level_info(i_level).Transaction_Type := i_transaction_type;
	i_level_info(i_level).Run_Id := i_run_id;
	i_level_info(i_level).Document_Number := NULL;
	i_level_info(i_level).Status := 'NEW';
	i_level_info(i_level).Key_Column_Position := NULL;
	i_level_info(i_level).tp_code := NULL;

        if EC_DEBUG.G_debug_level = 3 then
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
   end if;
end loop;

/*
Reset the i_previous_level = 0
*/
i_previous_level := 0;

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
	EC_UTILS.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
end if;

-- Bug 2162062

if ec_inbound_stage.g_source_charset IS NULL then
	select value
	into   ec_inbound_stage.g_source_charset
	from   v$nls_parameters
	where  parameter='NLS_CHARACTERSET';
end if;

-- Get the character set from the profile option and verify it with fnd_lookups,and database settings.
-- bug 2110652


	select value,decode(value,ec_inbound_stage.g_source_charset,'Y','N')
        into   i_db_charset,i_db_charset_flag
        from   v$nls_parameters
        where  parameter   = 'NLS_CHARACTERSET';

        if sql%notfound then
              ec_debug.pl(0,'Characterset not not same as defined in Database');
        end if;

       if EC_DEBUG.G_debug_level = 3 then
        ec_debug.pl(3,'i_db_charset',i_db_charset);
       end if;

        select 'Y'
        into   i_fnd_charset_flag
        from   fnd_lookups
        where  lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
        and    lookup_code = ec_inbound_stage.g_source_charset;

        if sql%notfound then
           ec_debug.pl(0,'Invalid Character Set specified in the FND_LOOKUPS');
	   EC_UTILS.i_ret_code := 2;
           raise EC_UTILS.PROGRAM_EXIT;
	end if;


--- Open the Inbound Transaction File in the Read Mode
u_file_handle := utl_file.fopen(i_file_path,i_file_name,'r');


-- Find Positions for Translator Code and Location Code in the PL/SQL table.
find_pos
	(
	1,
	'TP_TRANSLATOR_CODE',
	i_translator_code_pos
	);

find_pos
	(
	1,
	'TP_LOCATION_CODE',
	i_location_code_pos
	);


BEGIN
LOOP


	BEGIN
		v_next_rec_number := NULL;
		skip_record_flag := FALSE;

		utl_file.get_line(u_file_handle,c_current_line);

		v_next_rec_number := SUBSTRB(c_current_line,
					    g_record_num_start,
					    g_record_num_length
					   );

		counter := counter + 1;

		next_rec_number := to_number(v_next_rec_number);

               if EC_DEBUG.G_debug_level = 3 then
        	ec_debug.pl(3,'counter',counter);
               end if;

	EXCEPTION
	WHEN VALUE_ERROR then
		ec_debug.pl(3,'counter',counter);

		/**
		If the record number found in the file cannot be converted to a number,
		i.e. it is a character value, then skip this record
		**/

		skip_record_flag := TRUE;
                ec_debug.pl(0,'EC','ECE_RECORD_NUM_INVALID','RECORD_NUMBER',v_next_rec_number,'LINE_NUMBER',counter);

		/**
		Set the Retcode for the Concurrent Manager BUT do not RAISE program exit
		**/
		EC_UTILS.i_ret_code := 1;

	WHEN NO_DATA_FOUND then
		ec_debug.pl(3,'counter',counter);

		/**
		If the End Of File is encountered and the Line Counter
		is zero , that means the File is empty then Exit the loop
		and proceed towards the end of program.
		**/
		if counter = 0 then
			exit;
		end if;

		end_of_file := TRUE;
	END;

IF NOT skip_record_flag THEN
        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'EC','ECE_STAGE_LINE_NUMBER','LINE_NUMBER',counter,'RECORD_NUMBER',next_rec_number);
	ec_debug.pl(3,'c_current_line',c_current_line);
        end if;
	/**
	Match the Record Number of the Line read with the Start Record Number for each level.
	If matches , then Insert the Data for the previous level.
	**/

	For i in 1..i_level_info.COUNT
	loop
		if  ( next_rec_number = i_level_info(i).start_record_number )
			or ( end_of_file )
		then
			i_current_level := i;

			if  NOT (i_first_line_flag) or ( end_of_file )
			then

				--- Generate Stage Id for each Record from Sequence
					open 	seq_stage_id;
					fetch 	seq_stage_id into i_stage_id;
					close 	seq_stage_id;
                                if EC_DEBUG.G_debug_level >= 3 then
				ec_debug.pl(3,'i_stage_id',i_stage_id);
                                end if;

				/**
				The Document Number in all the Levels should be populated only
				when the position of the Key Column is available in the PL/SQL
				table for Level Information.
				**/
				if i_previous_level = 1
				then

				-- Derive the Trading Partner Code , if possible.
				-- First Get the Values from the PL/SQL table.
					i_tp_code := NULL;
					i_translator_code :=
						i_stage_record_type(i_translator_code_pos).value;
					i_location_code := i_stage_record_type(i_location_code_pos).value;

					get_tp_code
						(
						i_translator_code,
						i_location_code,
						i_level_info(1).primary_address_type,
						i_transaction_type,
						i_tp_code
						);

					/**
					Populate Key Column Attribute for Error Handling
					**/
					ece_flatfile_pvt.t_tran_attribute_tbl(1).value
						:= i_level_info(1).Document_Number;

					for j in 1..i_level_info.COUNT
					loop
						if i_level_info(1).Key_Column_Position is not null
						then
							i_level_info(j).Document_Number :=
							i_stage_record_type(i_level_info(1).Key_column_Position).value;
							i_level_info(j).tp_code := i_tp_code;
						end if;
						i_level_info(j).tp_code := i_tp_code;
					end loop;
				end if;


				i_level_info(i_previous_level).Stage_id := i_stage_id;


				/**
				Insert Data into Staging table for Previous Level of Document .
				The value of the Insert Cursor for the First Call should be zero
				, and the rest of the calls can take the returned Cursor handle.
				This helps avoiding the Expensive Parsing for subsequent calls.
				**/
				Insert_into_Stage_table
					(
					i_previous_level,
					i_map_id,
					i_level_info(i_previous_level).Insert_Cursor
					);
				/**
				Initialize the PL/SQL table which was loaded with values.
				**/
                                --Bug 2500898,2608899
				--i_stage_record_type := i_empty_tbl;
                                for k in 1..i_stage_record_type.COUNT
                                loop
                                        i_stage_record_type(k).value    :=NULL;
                                end loop;


			if i_previous_level = 1
			then
                               if EC_DEBUG.G_debug_level >= 1 then
                                     ec_debug.pl(1,'EC','ECE_DOCUMENT_ID','DOCUMENT_ID',
					i_level_info(i_previous_level).Document_id,
					'DOCUMENT_NUMBER',
					i_level_info(i_previous_level).Document_Number);
                               end if;
			end if;

			/**
			Un-necessary.
			ec_debug.pl(2,'EC','ECE_LEVEL','LEVEL',i_previous_level);
			ec_debug.pl(2,'EC','ECE_SEQUENCE_NUMBER','SEQUENCE_NUMBER',
					i_level_info(i_previous_level).Line_Number);
			ec_debug.pl(2,'EC','ECE_STAGE_ID','STAGE_ID',
					i_level_info(i_previous_level).Stage_Id);
			ec_debug.pl(2,'EC','ECE_PARENT_STAGE_ID','PARENT_STAGE_ID',
					i_level_info(i_previous_level).Parent_Stage_Id);
			**/

				if ( end_of_file )
				then
					exit;
				end if;

			end if; -- First Line Flag

			/**
			If the Next record Number is a Header Record , initialize the data
			in the Level Information PL/SQL table and generate the
			Document Id .Set it for all the Levels because the Document Id will
			remain same for lower Levels.

			If the Record is a Line , Shipement etc. , then Increment the Line
			Number , set the Parent Stage Id equal to the Parent Level , and
			reset Line Number and Parent Stage id for the Down Level.
			**/
			if next_rec_number = i_level_info(1).Start_Record_Number
			then
				-- Generate Document Id
				open 	seq_document_id;
				fetch 	seq_document_id into Document_Id;
				close 	seq_document_id;

				i_document_number := i_document_number + 1;

                                -- Reset file position counter
				l_next_file_pos := 1;

				-- Initialize the variables
				i_level_info(1).Document_Id := Document_Id;
				i_level_info(1).Line_Number := 1;
				i_level_info(1).Parent_Stage_Id := NULL;
				i_level_info(1).tp_code := NULL;

				--- Initialize all the Down Levels
				For j in 2..i_level_info.COUNT
				loop
					i_level_info(j).Document_Id := i_level_info(1).Document_Id;
					i_level_info(j).Line_Number := 0;
					i_level_info(j).Parent_Stage_Id := NULL;
					i_level_info(j).tp_code := NULL;
				end loop;
			else
			        -- Reset file position counter - no big performance loss if it starts at 1 for every line
				l_next_file_pos := 1;

				i_level_info(i).Line_Number := i_level_info(i).Line_Number + 1;
				i_level_info(i).Parent_Stage_Id := i_level_info(i-1).Stage_Id;

				--- Initialize all the Down Levels
				For j in i+1..i_level_info.COUNT
				loop
					i_level_info(j).Line_Number := 0;
					i_level_info(j).Parent_Stage_Id := NULL;
				end loop;

			end if;

			exit;
		end if; --- ( Start record Number )
	end loop; -- ( For Start record Number )

	if ( end_of_file )
	then
		exit;
	end if;

	/**
	The record number read from the File is matched against the valid Record number
	for that Level in the PL/SQL table for Mapping Information. If the record
	is a valid record , then the line is loaded into the PL/SQL table.
	**/
	i_valid_record := match_record_num
			(
			i_current_level,
			next_rec_number,
			l_file_pos,
			l_next_file_pos,
			l_total_rec_unit
			);

	if ( i_valid_record ) then

		load_data_from_file
			(
			l_file_pos,
			l_total_rec_unit,
			c_current_line
			);

		i_valid_record := FALSE;

	end if;

	i_previous_level := i_current_level;

	if (i_first_line_flag)
	then
				/**
                                If the Record Number for the First Line is
				not equal to the Start record Number for Header
				then the program never encountered a Header record.
                                Serious Error with File.
                                **/
                                if nvl(next_rec_number,0) <> i_level_info(1).Start_Record_Number
                                then
                                        ec_debug.pl(0,'EC','ECE_MISSING_HEADER_RECORD',null);
                                        /**
                                        Set the Retcode for the Concurrent Manager
                                        **/
                                        EC_UTILS.i_ret_code := 2;
                                        raise EC_UTILS.PROGRAM_EXIT;
                                end if;
	end if;

	i_first_line_flag := FALSE;

END IF;

end loop;

	/**
	The Cursors for the Insert into Stage table are not closed in the Insert_Into_Stage_table
	procedure call. Since the Cursor handles are maintained in the I_LEVEL_INFO PL/SQL table ,
	Cursors for the all the Level are closed using these Cursor handles.
	**/
	For i in 1..i_level_info.COUNT
	loop
		IF dbms_sql.IS_OPEN(i_level_info(i).Insert_Cursor)
		then
			dbms_sql.Close_cursor(i_level_info(i).Insert_Cursor);
		end if;
	end loop;

	/**
	If the File is empty , the Line Counter will be zero and the End of File
	exception will transfer the Control over here.
	**/
	if ( nvl(length(c_current_line),0) = 0 )
		and ( counter = 0 )
	then
		ec_debug.pl(0,'EC','ECE_EMPTY_FILE','FILE_NAME',i_file_path||'/'||i_file_name,
					'TRANSACTION_TYPE',i_transaction_type);
		/**
		Set the Retcode for the Concurrent Manager
		**/
		EC_UTILS.i_ret_code := 1;
		raise EC_UTILS.PROGRAM_EXIT;
	end if;

end;

-- Close the Inbound Transaction File
utl_file.fclose(u_file_handle);

if EC_DEBUG.G_debug_level >= 1 then
ec_debug.pl(1,'EC','ECE_NO_LINES_READ','NO_OF_LINES',counter);
end if;
<<stage_over>>
        if EC_DEBUG.G_debug_level >= 1 then
	ec_debug.pl(1,'EC','ECE_DOCUMENTS_PROCESSED','NO_OF_DOCS',i_document_number);
	ec_debug.pop('EC_INBOUND_STAGE.LOAD_DATA');
	end if;
EXCEPTION
WHEN UTL_FILE.write_error THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_WRITE_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.read_error THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_READ_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_path THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_PATH',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_mode THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_MODE',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_operation THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_OPERATION',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.invalid_filehandle THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INVALID_FILEHANDLE',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN UTL_FILE.internal_error THEN
	EC_UTILS.i_ret_code :=2;
        ec_debug.pl(0,'EC','ECE_UTL_INTERNAL_ERROR',null);
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
WHEN EC_UTILS.PROGRAM_EXIT THEN
	raise;
WHEN OTHERS THEN
	EC_UTILS.i_ret_code :=2;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	utl_file.fclose(u_file_handle);
        raise EC_UTILS.PROGRAM_EXIT;
END Load_Data;

/**
This Function returns the Boolean True or False for a match between the
Record Number read from the File and the Record Number seeded for the
transaction. If the match is found , then it returns back the number of
Data elements present , and the Cursor Position in the line upto which
the Data has been read
**/
FUNCTION match_record_num
		(
		i_current_level		IN	NUMBER,
		i_record_num		IN	number,
		i_file_pos		OUT NOCOPY	number,
		i_next_file_pos         IN OUT NOCOPY  number,
		i_total_rec_unit	OUT NOCOPY	number
		)
return boolean
is
b_match_found 	BOOLEAN := FALSE;
i_total_unit	NUMBER :=0;

begin
   if EC_DEBUG.G_debug_level >= 2 then
	ec_debug.push('EC_INBOUND_STAGE.MATCH_RECORD_NUM');
	ec_debug.pl(3,'i_current_level',i_current_level);
	ec_debug.pl(3,'i_record_num',i_record_num);
  end if;
	for k in i_next_file_pos..i_stage_record_type.count
	loop
		if i_stage_record_type(k).external_level = i_current_level
		then
			if i_stage_record_type(k).Record_number = i_record_num
			and ( not b_match_found )
			then
			        i_file_pos :=k;
				i_total_unit := i_total_unit + 1;
				b_match_found := TRUE;
			elsif i_stage_record_type(k).record_number = i_record_num
			then
				i_total_unit := i_total_unit + 1;
			elsif b_match_found and i_stage_record_type(k).Record_number <> i_record_num
			then
			      exit;
			end if;
		end if;
	end loop;
	i_next_file_pos := NVL(i_file_pos + i_total_unit, i_next_file_pos);
	i_total_rec_unit := i_total_unit;

        if EC_DEBUG.G_debug_level >= 2 then
        ec_debug.pl(3,'i_file_pos',i_file_pos);
	ec_debug.pl(3,'i_next_file_pos',i_next_file_pos);
	ec_debug.pl(3,'i_total_rec_unit',i_total_rec_unit);
	ec_debug.pl(3,'b_match_found',b_match_found);
	ec_debug.pop('EC_INBOUND_STAGE.MATCH_RECORD_NUM');
        end if;
	return b_match_found;
EXCEPTION
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.MATCH_RECORD_NUM');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
end match_record_num;

/**
After a successful match of record number between the Line Read from
FlatFile and the seeded data , the Line is loaded into the PL/SQL
table. The PL/SQL table is defined as a Local variable in the Body
of the package and is accessible to the Functions and Procedures
inside the package body only.
**/
procedure load_data_from_file
	(
	i_file_pos		in	number,
	i_total_rec_unit	in	number,
	c_current_line		in out nocopy varchar2
	)
is

i_cur_pos	number := g_common_key_length;
i_data_length	number;

--bug 2164672
i_data_file_value    Varchar2(500);
i_new_file_value    Varchar2(500);

begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_INBOUND_STAGE.LOAD_DATA_FROM_FILE');
ec_debug.pl(3,'i_file_pos',i_file_pos);
ec_debug.pl(3,'i_total_rec_unit',i_total_rec_unit);
ec_debug.pl(3,'c_current_line',c_current_line);
end if;
-- bug 4555935
c_current_line := replace(c_current_line,fnd_global.local_chr(13));
c_current_line := replace(c_current_line,fnd_global.local_chr(10));
c_current_line := replace(c_current_line,fnd_global.local_chr(9));
--bug 2110652
    if i_fnd_charset_flag = 'Y' then
      if i_db_charset_flag = 'Y' then
  	for i in i_file_pos..(i_file_pos + i_total_rec_unit - 1 )
	loop
		i_data_length := nvl(i_stage_record_type(i).width,0);
		i_stage_record_type(i).value :=
		       rtrim(substrb(c_current_line,i_cur_pos+1,i_data_length));

		if replace(i_stage_record_type(i).value,' ') is null then
			i_stage_record_type(i).value :=NULL;
		end if;

		i_cur_pos := i_cur_pos + i_data_length;
	end loop;
      else
  	for i in i_file_pos..(i_file_pos + i_total_rec_unit - 1 )
	loop
		i_data_length := nvl(i_stage_record_type(i).width,0);
        --Bug 2164672
                i_data_file_value := rtrim(substrb(c_current_line,i_cur_pos+1,i_data_length));
		i_stage_record_type(i).value :=
                           convert(i_data_file_value,i_db_charset,ec_inbound_stage.g_source_charset);
                i_new_file_value :=
                           convert(i_stage_record_type(i).value,ec_inbound_stage.g_source_charset,i_db_charset);

                if i_new_file_value not like i_data_file_value then
                        i_data_status_flag := FALSE;
                end if;

		if replace(i_stage_record_type(i).value,' ') is null then
			i_stage_record_type(i).value :=NULL;
		end if;

		i_cur_pos := i_cur_pos + i_data_length;
	end loop;
     end if;
  end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_INBOUND_STAGE.LOAD_DATA_FROM_FILE');
end if;
EXCEPTION
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.LOAD_DATA_FROM_FILE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
end load_data_from_file;

/**
This procedures loads the mapping information between the Flat File
and the Staging table. This information is seeded in the ECE_INTERFACE_TABLES
and ECE_INTERFACE_COLUMNS. The mapping information is loaded into the Local Body
PL/SQL table variable for a given transaction Type and its level. This PL/SQL table
loaded with Mapping information is visible only to the functions and procedures
defined within this package.
**/
procedure populate_flatfile_mapping
	(
	i_transaction_type		in	varchar2,
	i_level				in	number,
	i_map_id			IN number
	)
is
	cursor c_file_mapping
		(
		p_level			number,
		p_map_id		number
		) is
	SELECT  eic.interface_column_name,
		eic.staging_column,
		eic.record_number,
		eic.position,
		eic.width
	FROM    ece_interface_columns eic
	WHERE 	eic.external_level = p_level
	AND	eic.map_id = p_map_id
	AND	eic.record_number IS NOT NULL
	AND	eic.position IS NOT NULL
	AND	eic.staging_column IS NOT NULL
	ORDER BY eic.record_number, eic.position;

i_counter	NUMBER :=i_stage_record_type.COUNT;
m_counter	number := i_counter;
i_previous_level NUMBER := 0;

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_INBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
ec_debug.pl(3,'i_transaction_type',i_transaction_type);
ec_debug.pl(3,'i_Level',i_level);
ec_debug.pl(3,'EC','ECE_INTERFACE_MAPPING','TRANSACTION_TYPE',i_transaction_type,'LEVEL',i_level);
end if;

FOR transaction_mapping in c_file_mapping
	(
	p_level => i_level,
	p_map_id => i_map_id
	)
Loop

	i_counter := i_counter + 1;
	i_stage_record_type(i_counter).external_level := i_level;
	i_stage_record_type(i_counter).interface_column_name := transaction_mapping.interface_column_name;
	i_stage_record_type(i_counter).staging_column := transaction_mapping.staging_column;
	i_stage_record_type(i_counter).record_number := transaction_mapping.record_number;
	i_stage_record_type(i_counter).position := transaction_mapping.position;
	i_stage_record_type(i_counter).width := transaction_mapping.width;

     if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl
	(
	3,
	i_counter||'|'||
	i_level||'|'||
	transaction_mapping.interface_column_name||'|'||
	transaction_mapping.staging_column||'|'||
	transaction_mapping.record_number||'|'||
	transaction_mapping.position||'|'||
	transaction_mapping.width
	);
     end if;
	if i_level = 1
	then
		if upper(i_stage_record_type(i_counter).interface_column_name) =
			i_level_info(1).key_column_name
		then
			ece_flatfile_pvt.t_tran_attribute_tbl(1).key_column_name
			 		:= i_level_info(1).Key_column_name;
			ece_flatfile_pvt.t_tran_attribute_tbl(1).position
					:= i_counter;
			i_level_info(1).key_column_position := i_counter;
                        if EC_DEBUG.G_debug_level >= 3 then
			ec_debug.pl(3,'Key_Column_Position',i_level_info(1).Key_Column_position);
                        end if;
		end if;
	end if;

end loop;

	if i_counter = m_counter then
		ec_debug.pl(0,'EC','ECE_SEED_NOT_LEVEL','TRANSACTION_TYPE',i_transaction_type,'LEVEL',i_level);
		/**
		Set the Retcode for the Concurrent Manager to Error.
		**/
		EC_UTILS.i_ret_code := 2;
		raise EC_UTILS.PROGRAM_EXIT;
	end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pop('EC_INBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.POPULATE_FLATFILE_MAPPING');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END populate_flatfile_mapping;

/**
The Data loaded in the Local PL/SQL table is inserted into the Staging table.
This procedures takes Transaction Level and the Cursor handle as the parameter.
The Cursor handle is passed as 0 in the First call , and the subsequent calls
uses the Cursor Handle returned by the Procedure. This helps in avoiding the
expensive parsing of the SQL Statement again and again for the Same level.
**/
procedure Insert_Into_Stage_Table
	(
	i_level		IN	NUMBER,
	i_map_id	IN	NUMBER,
	i_insert_cursor	IN OUT NOCOPY	NUMBER
	)
is
c_Insert_Cursor		INTEGER;
cInsert_stmt		varchar2(32000) := 'INSERT INTO ECE_STAGE ( ';
cValue_stmt		varchar2(32000) := 'VALUES (';
dummy			INTEGER;
error_position		integer;

BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_INBOUND_STAGE.INSERT_INTO_STAGE_TABLE');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_insert_cursor',i_insert_cursor);
end if;

if i_insert_cursor = 0
then
	i_insert_cursor := -911;
end if;

if i_insert_cursor < 0
then
	--- Add Mandatory Columns for the Record - includes the MAP_ID column
	cInsert_stmt := cInsert_stmt||' Stage_id ,Document_Id ,Transaction_type ,Transaction_Level ,';
	cInsert_stmt := cInsert_stmt||' Line_Number ,Parent_Stage_Id ,Run_Id ,Document_Number ,Status ,Tp_Code ,Map_ID ,';
        --- Bug 2500898

	-- cInsert_stmt := cInsert_stmt||' Parent_Stage_id ,Document_Id ,Transaction_type ,Transaction_Level ,';
	-- cInsert_stmt := cInsert_stmt||' Line_Number ,Stage_Id ,Run_Id ,Document_Number ,Status ,Tp_Code ,Map_ID ,';

	--- Add Who Columns for the Staging Table
	cInsert_stmt := cInsert_stmt||' creation_date ,created_by ,last_update_date ,last_updated_by ,';

	 cValue_stmt := cValue_stmt||':a1 ,:a2 ,:a3 ,:a4 ,:a5 ,:a6 ,:a7 ,:a8 ,:a9 ,:a10 ,:a11 ,';
	 -- cValue_stmt := cValue_stmt||':w1 ,:w2 ,:w3 ,:w4 ,';


	-- cValue_stmt := cValue_stmt||' ece_stage_id_s.CURRVAL ,:a2 ,:a3 ,:a4 ,:a5 ,ece_stage_id_s.NEXTVAL ,:a7 ,:a8 ,:a9 ,:a10 ,:a11 ,';
	cValue_stmt := cValue_stmt||' sysdate ,fnd_global.user_id ,sysdate ,fnd_global.user_id ,';

	--- Add Variable Columns for the Record
	for i in 1..i_stage_record_type.COUNT
	loop
		if i_stage_record_type(i).external_level = i_level
		then
			--- Build Insert Statement
			cInsert_stmt := cInsert_stmt||' '||i_stage_record_type(i).staging_column|| ',';
			cValue_stmt  := cvalue_stmt || ':b'||i||',';
		end if;
	end loop;

	cInsert_stmt := RTRIM(cInsert_stmt,',')||')';
	cValue_stmt := RTRIM(cValue_stmt,',')||')';
	cInsert_stmt := cInsert_stmt||cValue_stmt;

        if EC_DEBUG.G_debug_level >= 3 then
	ec_debug.pl(3,'EC','ECE_STAGE_INSERT_LEVEL','LEVEL',i_level,null);
	ec_debug.pl(3,cInsert_stmt);
        end if;

	/**
	Open the cursor and parse the SQL Statement. Trap any parsing error and report
	the Error Position in the SQL Statement
	**/
	i_Insert_Cursor := dbms_sql.Open_Cursor;
	begin
		dbms_sql.parse(i_Insert_Cursor,cInsert_stmt,dbms_sql.native);
	exception
	when others then
		error_position := dbms_sql.last_error_position;
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.INSERT_INTO_STAGE_TABLE');
		ece_error_handling_pvt.print_parse_error (error_position,cInsert_stmt);
		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	end;
end if;

if i_Insert_Cursor > 0
then
	begin
                -- Bug 2164672
                if  i_data_status_flag then
                        i_level_info(i_level).Status := 'NEW';
                else
                        i_level_info(i_level).Status := 'LOSSY_CONVERSION';
                end if;

		-- Bind values for Mandatory Columns

		dbms_sql.bind_variable (i_Insert_Cursor,'a1',to_number(i_level_info(i_level).Stage_Id));
		dbms_sql.bind_variable (i_Insert_Cursor,'a6',i_level_info(i_level).Parent_Stage_Id);
		dbms_sql.bind_variable (i_Insert_Cursor,'a2',to_number(i_level_info(i_level).Document_Id));
		dbms_sql.bind_variable (i_Insert_Cursor,'a3',i_level_info(i_level).Transaction_Type);
		dbms_sql.bind_variable (i_Insert_Cursor,'a4',to_number(i_level));
		dbms_sql.bind_variable (i_Insert_Cursor,'a5',to_number(i_level_info(i_level).Line_Number));
		dbms_sql.bind_variable (i_Insert_Cursor,'a7',to_number(i_level_info(i_level).Run_Id));
		dbms_sql.bind_variable (i_Insert_Cursor,'a8',i_level_info(i_level).Document_Number);
		dbms_sql.bind_variable (i_Insert_Cursor,'a9',i_level_info(i_level).Status);
		dbms_sql.bind_variable (i_Insert_Cursor,'a10',i_level_info(i_level).Tp_Code);
		dbms_sql.bind_variable (i_Insert_Cursor,'a11',i_map_id);

		-- Bind values for Mandatory Columns
		/* Bug 2500898
		dbms_sql.bind_variable (i_Insert_Cursor,'w1',sysdate);
		dbms_sql.bind_variable (i_Insert_Cursor,'w2',fnd_global.user_id);
		dbms_sql.bind_variable (i_Insert_Cursor,'w3',sysdate);
		dbms_sql.bind_variable (i_Insert_Cursor,'w4',fnd_global.user_id);
		*/

                if EC_DEBUG.G_debug_level >= 3 then
		ec_debug.pl(3,'STAGE_ID',i_level_info(i_level).Stage_Id);
		ec_debug.pl(3,'DOCUMENT_ID',i_level_info(i_level).Document_Id);
		ec_debug.pl(3,'TRANSACTION_TYPE',i_level_info(i_level).Transaction_Type);
		ec_debug.pl(3,'TRANSACTION_LEVEL',i_level);
		ec_debug.pl(3,'LINE_NUMBER',i_level_info(i_level).Line_Number);
		ec_debug.pl(3,'PARENT_STAGE_ID',i_level_info(i_level).Parent_Stage_Id);
		ec_debug.pl(3,'RUN_ID',i_level_info(i_level).Run_Id);
		ec_debug.pl(3,'DOCUMENT_NUMBER',i_level_info(i_level).Document_Number);
		ec_debug.pl(3,'TP_CODE',i_level_info(i_level).Tp_Code);
		ec_debug.pl(3,'MAP_ID',i_map_id);
		ec_debug.pl(3,'CREATION_DATE',sysdate);
		ec_debug.pl(3,'CREATED_BY',fnd_global.user_id);
		ec_debug.pl(3,'LAST_UPDATE_DATE',sysdate);
		ec_debug.pl(3,'LAST_UPDATED_BY',fnd_global.user_id);
		ec_debug.pl(3,'STATUS',i_level_info(i_level).Status);
                end if;
		-- Bind values for Staging Columns mapped to the Flat File
		for k in 1..i_stage_record_type.COUNT
		loop
			if i_stage_record_type(k).external_level = i_level
			then
				dbms_sql.bind_variable	(
							i_Insert_Cursor,
							'b'||k,
							i_stage_record_type(k).value
                                                        );

                                                     /* Bug 2500898
							'b'||k,substrb	(
									i_stage_record_type(k).value,
									1,
									i_stage_record_type(k).width
									)
							);
						     */

                            if EC_DEBUG.G_debug_level = 3 then
				ec_debug.pl(3,upper(i_stage_record_type(k).staging_column)||'-'||
						upper(i_stage_record_type(k).interface_column_name),
						i_stage_record_type(k).value);
                            end if;
  			end if;
		end loop;

		dummy := dbms_sql.execute(i_Insert_Cursor);
		if dummy = 1 then
                        if EC_DEBUG.G_debug_level = 3 then
			ec_debug.pl(3,'EC','ECE_STAGE_INSERTED',null);
                        end if;
                        i_data_status_flag := TRUE;    --Bug 2164672
		else
			EC_UTILS.i_ret_code :=2;
			raise EC_UTILS.PROGRAM_EXIT;
		end if;

	exception
	when others then
		ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
				'EC_INBOUND_STAGE.INSERT_INTO_STAGE_TABLE');
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
		ec_debug.pl(0,'EC','ECE_ERROR_SQL',null);
		ec_debug.pl(0,cInsert_stmt);

		EC_UTILS.i_ret_code :=2;
		raise EC_UTILS.PROGRAM_EXIT;
	end;
end if;

if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'i_insert_cursor',i_insert_cursor);
ec_debug.pop('EC_INBOUND_STAGE.INSERT_INTO_STAGE_TABLE');
end if;
EXCEPTION
WHEN EC_UTILS.PROGRAM_EXIT then
	raise;
WHEN OTHERS then
	IF dbms_sql.IS_OPEN(i_insert_cursor)
	then
		dbms_sql.close_cursor(i_insert_cursor);
	end if;
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.INSERT_INTO_STAGE_TABLE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
END Insert_Into_Stage_Table;


procedure get_tp_code
	(
	i_translator_code	in	varchar2,
	i_location_code		in	varchar2,
	i_address_type		in	varchar2,
	i_transaction_type	IN	varchar2,
	i_tp_code		OUT NOCOPY	varchar2
	)
is
i_translator_code_pos	number;
i_location_code_pos	number;
i_cur_pos	number := g_common_key_length;
i_data_length	number;


/* Bug 1966138.
   Replaced ra_addresses with hz_cust_acct_sites_all
   to improve performance*/
CURSOR  c_cust_addr
                (
                i_translator_code       IN      varchar2,
                i_location_code         IN      varchar2,
                i_transaction_type      IN      varchar2
                )
        IS
        select  tp_code
        from    ece_tp_details td,
                hz_cust_acct_sites_all hcas,
                ece_tp_headers th
        where   td.translator_code       = i_translator_code and
                hcas.ece_tp_location_code  = i_location_code and
                hcas.tp_header_id          = td.tp_header_id and
                td.tp_header_id          = th.tp_header_id and
                td.document_id           = i_transaction_type and
                NVL(hcas.ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1 ,1),
                ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99))
                = NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),
                ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99) and
                rownum                   = 1;


 /*	CURSOR 	c_cust_addr
		(
		i_translator_code	IN	varchar2,
		i_location_code		IN	varchar2,
		i_transaction_type	IN	varchar2
		)
	IS
   	select 	tp_code
   	from   	ece_tp_details td,
          	ra_addresses   ra,
		ece_tp_headers th
   	where  	td.translator_code       = i_translator_code and
          	ra.ece_tp_location_code  = i_location_code and
          	ra.tp_header_id          = td.tp_header_id and
		td.tp_header_id		 = th.tp_header_id and
          	td.document_id           = i_transaction_type and
          	rownum                   = 1;
*/

   	CURSOR 	c_supplier_addr
		(
		i_translator_code	IN	varchar2,
		i_location_code		IN	varchar2,
		i_transaction_type	IN	varchar2
		)
	IS
   	select 	tp_code
   	from   	ece_tp_details td,
          	po_vendor_sites pvs,
		ece_tp_headers th
   	where  	td.translator_code       = i_translator_code and
          	pvs.ece_tp_location_code = i_location_code and
          	pvs.tp_header_id         = td.tp_header_id and
          	th.tp_header_id         = td.tp_header_id and
          	td.document_id           = i_transaction_type and
          	rownum                   = 1;

   	CURSOR 	c_bank_addr
		(
		i_translator_code	IN	varchar2,
		i_location_code		IN	varchar2,
		i_transaction_type	IN	varchar2
		)
	IS
   	select 	tp_code
   	from   	ece_tp_details td,
          	ap_bank_branches abb,
		ece_tp_headers th
   	where  	td.translator_code       = i_translator_code and
          	abb.ece_tp_location_code = i_location_code and
          	abb.tp_header_id         = td.tp_header_id and
          	th.tp_header_id          = td.tp_header_id and
          	td.document_id           = i_transaction_type and
          	rownum                   = 1;


 	CURSOR 	c_hr_addr
		(
		i_translator_code	IN	varchar2,
		i_location_code		IN	varchar2,
		i_transaction_type	IN	varchar2
		)
	IS
   	select 	tp_code
   	from   	ece_tp_details td,
          	hr_locations hrl,
		ece_tp_headers th
   	where  	td.translator_code       = i_translator_code and
          	hrl.ece_tp_location_code = i_location_code and
          	hrl.tp_header_id         = td.tp_header_id and
          	th.tp_header_id          = td.tp_header_id and
          	td.document_id           = i_transaction_type and
          	rownum                   = 1;

counter			number :=0;
i_level			number :=0;
begin
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.push('EC_INBOUND_STAGE.GET_TP_CODE');
ec_debug.pl(3,'i_translator_code',i_translator_code);
ec_debug.pl(3,'i_location_code',i_location_code);
ec_debug.pl(3,'i_address_type',i_address_type);
end if;

	if i_address_type = 'CUSTOMER'
	then
		for c_customer in c_cust_addr
			(
			i_translator_code => i_translator_code,
			i_location_code => i_location_code,
			i_transaction_type => i_transaction_type
			)
		loop
			i_tp_code := c_customer.tp_code;
		end loop;

	elsif i_address_type = 'SUPPLIER'
	then
		for c_supplier in c_supplier_addr
			(
			i_translator_code => i_translator_code,
			i_location_code => i_location_code,
			i_transaction_type => i_transaction_type
			)
		loop
			i_tp_code := c_supplier.tp_code;
		end loop;

	elsif i_address_type = 'BANK'
	then
		for c_bank in c_bank_addr
			(
			i_translator_code => i_translator_code,
			i_location_code => i_location_code,
			i_transaction_type => i_transaction_type
			)
		loop
			i_tp_code := c_bank.tp_code;
		end loop;

	elsif i_address_type = 'LOCATIONS'
	then
		for c_locations in c_hr_addr
			(
			i_translator_code => i_translator_code,
			i_location_code => i_location_code,
			i_transaction_type => i_transaction_type
			)
		loop
			i_tp_code := c_locations.tp_code;
		end loop;

	else
		-- Not a Valid Address Type
		i_tp_code := null;

	end if;
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'i_tp_code',i_tp_code);
ec_debug.pop('EC_INBOUND_STAGE.GET_TP_CODE');
end if;
EXCEPTION
WHEN OTHERS then
	ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.GET_TP_CODE');
	ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code:=2;
	raise EC_UTILS.PROGRAM_EXIT;
end get_tp_code;

procedure find_pos
        (
	i_level			IN	number,
        i_search_text           IN      varchar2,
        o_pos                   OUT  NOCOPY 	NUMBER,
	i_required		IN	BOOLEAN DEFAULT TRUE
        )
IS
        cIn_String      varchar2(1000) := UPPER(i_search_text);
        nColumn_count   number := i_stage_record_type.COUNT;
        bFound BOOLEAN := FALSE;
        POS_NOT_FOUND   EXCEPTION;
BEGIN
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.PUSH('EC_INBOUND_STAGE.FIND_POS');
ec_debug.pl(3,'i_level',i_level);
ec_debug.pl(3,'i_search_text',i_search_text);
ec_debug.pl(3,'o_pos',o_pos);
ec_debug.pl(3,'i_required',i_required);
end if;
for k in 1..nColumn_count
loop
	if i_stage_record_type(k).external_level = i_level
	then
        	if upper(i_stage_record_type(k).interface_column_name) = cIn_String
        	then
                	o_pos := k;
                	bFound := TRUE;
                	exit;
        	end if;
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
if EC_DEBUG.G_debug_level >= 2 then
ec_debug.pl(3,'o_pos',o_pos);
ec_debug.POP('EC_INBOUND_STAGE.FIND_POS');
end if;
EXCEPTION
WHEN POS_NOT_FOUND THEN
	ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME',cIn_String);
        ec_debug.POP('EC_INBOUND_STAGE.FIND_POS');
	EC_UTILS.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','EC_INBOUND_STAGE.FIND_POS');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	EC_UTILS.i_ret_code := 2;
	raise EC_UTILS.PROGRAM_EXIT;
END find_pos;

END EC_INBOUND_STAGE;

/
