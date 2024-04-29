--------------------------------------------------------
--  DDL for Package EC_OUTBOUND_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_OUTBOUND_STAGE" AUTHID CURRENT_USER AS
-- $Header: ECOSTGS.pls 120.2 2005/09/29 11:03:17 arsriniv ship $

/**
Global Variables
**/

counter			number :=0;
i_document_number	number :=0;

u_file_handle		utl_file.file_type;

/**
Global Common Key Constants: these can be changed if the common key specifications
change or become parameters in future versions.
**/
g_rec_num_ln		number := 4;
g_rec_num_fl		varchar2(1) := '0';

g_rec_lcd_ln		number := 2;
g_rec_lcd_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

g_rec_lql_ln		number := 3;
g_rec_lql_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

g_rec_appd_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

g_rec_ckey_ln		number := 91;
g_rec_ckey_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

g_tp_ckey_ln		number := 25;
g_tp_ckey_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

/**
The reference key lengths can be changed to a length of 13
so that at least 5 levels of reference keys can fit in a common key
of length 91 and tp code length of 25:
**/
-- g_ref_ckey_ln		number := 13;
g_ref_ckey_ln		number := 22;
g_ref_ckey_fl		varchar2(1) := fnd_global.local_chr(32);	-- space

/**
Record Type for storing the Information Specific to a Level
i.e. Start record Number, Document id , Document Number , Key Column name etc.
**/
TYPE start_rec is RECORD
(
start_record_number	ece_interface_columns.record_number%TYPE,
total_records		number(15),
Document_Id		number(15),
Line_Number		number(15),
Parent_Stage_Id		number(15),
Select_Cursor		number(15),
Transaction_type	ece_interface_tables.transaction_type%TYPE,
Run_Id			number(15),
Document_Number		varchar2(200),
Status			varchar2(40),
Stage_Id		number(15),
Key_Column_Name		ece_interface_tables.key_column_name%TYPE,
key_Column_Position	number(4),
Key_Column_Staging ece_interface_columns.staging_column%TYPE,
primary_address_type	ece_interface_tables.primary_address_type%TYPE,
tp_code_staging		ece_interface_columns.staging_column%TYPE
);

TYPE Level_Info 	IS TABLE OF start_rec INDEX by BINARY_INTEGER;

/**
Record Type for storing the Information Specific to a Record Number
i.e. record Number, position , width, and SQL select statment etc.
**/
TYPE all_rec is RECORD
(
record_number		ece_interface_columns.record_number%TYPE,
external_level		ece_external_levels.external_level%TYPE,
start_record_number	ece_interface_columns.record_number%TYPE,
counter		        number(15),
select_stmt		varchar2(32000)
);

TYPE Record_Info	IS TABLE OF all_rec INDEX by BINARY_INTEGER;

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
	);

/**
This procedures fetches the staging data in the proper hierarchecal order by recursively
calling itself using the current records STAGE_ID = PARENT_STAGE_ID.  It also calls the
procedures to format the common key and populate the flat file with the stage data.
Calling this procedure recursively guarantees that the flat file will be formatted in order
as long as the relationship between the STAGE_ID and the PARENT_STAGE_ID is populated
correctly by the OUTBOUND ENGINE regardless of the order they were populated.
**/
procedure Fetch_Stage_Data
	(
	i_transaction_type	in	varchar2,
	i_run_id		in	number,
	i_parent_stage_id	IN 	number,
	i_stage_cursor		IN OUT NOCOPY	number,
	i_common_key		IN OUT NOCOPY	varchar2
	);

/**
This procedures loads the mapping information between the Flat File
and the Staging table. This information is seeded in the ECE_INTERFACE_TABLES
and ECE_INTERFACE_COLUMNS. The mapping information is loaded into the Local Body
PL/SQL table variable for a given transaction Type and its level. This PL/SQL table
loaded with Mapping information is visible only to the functions and procedures
defined within this package.
**/
procedure Populate_Flatfile_Mapping
	(
	i_transaction_type	in	varchar2,
	i_level			in	number,
	i_map_id		IN	number
	);
/**
This procedure formats the main body of a SELECT statement for each record number of
a given transaction and saves the result in a local PL/SQL table for later parsing.
This procedure is called once for each record number regardless of the number of
columns in the staging table in order to save on the number of PL/SQL string operations
required
**/
PROCEDURE Get_Select_Stmt
		(
		i_current_level		IN	NUMBER,
		i_record_num		IN	number,
		i_file_pos		IN	number,
		i_next_file_pos         IN OUT NOCOPY  number,
		i_total_rec_unit	IN	number
		);

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
	i_select_cursor	IN OUT NOCOPY	NUMBER,
	i_common_key	IN OUT NOCOPY	VARCHAR2
	);
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
	i_common_key    IN OUT NOCOPY VARCHAR2
	);

end EC_OUTBOUND_STAGE;

 

/
