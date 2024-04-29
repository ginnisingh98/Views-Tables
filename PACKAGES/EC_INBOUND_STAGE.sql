--------------------------------------------------------
--  DDL for Package EC_INBOUND_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_INBOUND_STAGE" AUTHID CURRENT_USER AS
-- $Header: ECISTGS.pls 120.4 2005/09/29 10:38:28 arsriniv ship $
/*#
 * This package contains routines to copy data from the incoming flat file to the staging tables.
 * @rep:scope internal
 * @rep:product EC
 * @rep:lifecycle active
 * @rep:displayname Inbound Staging Program
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY EC_INBOUND
 */

/**
Global Variables
**/
g_record_num_start      number := 92;
g_common_key_length     number := 100;
g_record_num_length     number := 4;
/* bug2110652 */
g_source_charset        varchar2(30);

/**
Record Type for storing the Information Specific to a Level
i.e. Start record Number, Document id , Document Number , Key Column name etc.
**/
TYPE start_rec is RECORD
(
start_record_number	number(15),
Document_Id		number(15),
Line_Number		number(15),
Parent_Stage_Id		number(15),
Insert_Cursor		number(15),
Transaction_type	varchar2(40),
Run_Id			number(15),
Document_Number		varchar2(200),
Status			varchar2(40),
Stage_Id		number(15),
Key_Column_Name		varchar2(80),
key_column_position	number(4),
primary_address_type	ece_interface_tables.primary_address_type%TYPE,
tp_code			ece_tp_headers.tp_code%TYPE
);

-- TYPE Stage_Record_Type 	is TABLE of stage_record index by BINARY_INTEGER;  -- mguthrie
TYPE Level_Info 	is TABLE of start_rec INDEX by BINARY_INTEGER;

/**
This is the Main Staging Program.
For a given transaction , and the Inbound File information i.e. File name
and File Path , it loads the Flat File into the Staging table. There is no
checking done for the data , and is loaded according to the Mapping
information seeded for a transaction.
**/
/*#
 * This is the main procedure to copy data from the incoming flat file to the staging tables.
 * No validation is performed on the data.  The data is loaded according to the seeded map provided for the transaction.
 * @param i_transaction_type Transaction Type
 * @param i_file_name Flat File Name
 * @param i_file_path File Path of the Inbound File
 * @param i_map_id    Map Id of the Map Used
 * @param i_run_id Run Id of the Inbound Process
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Load Incoming Data To Staging Tables
 * @rep:compatibility S
 */

procedure Load_Data
	(
	i_transaction_type	IN	varchar2,
	i_file_name		IN	varchar2,
	i_file_path		IN	varchar2,
	i_map_id		IN	number,		-- mguthrie
	i_run_id		OUT NOCOPY	number
	);

/**
This Function returns the Boolean True or False for a match between the
Record Number read from the File and the Record Number seeded for the
transaction. If the match is found , then it returns back the number of
Data elements present , and the Cursor Position in the line upto which
the Data has been read.
**/

function match_record_num
	(
	i_current_level		IN	number,
	i_record_num		IN	number,
	i_file_pos		OUT NOCOPY	number,
	i_next_file_pos         IN OUT NOCOPY number,
	i_total_rec_unit	OUT NOCOPY	number
	) return boolean;

/**
After a successful match of record number between the Line Read from
FlatFile and the seeded data , the Line is loaded into the PL/SQL
table. The PL/SQL table is defined as a Local variable in the Body
of the package and is accessible to the Functions and Procedures
inside the package body only.
**/
procedure load_data_from_file
	(
	i_file_pos		IN	number,
	i_total_rec_unit	IN	number,
	c_current_line		IN OUT NOCOPY varchar2 -- Added OUT NOCOPY as per bug:4555935
	);

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
	i_transaction_type	in	varchar2,
	i_level			in	number,
	i_map_id		IN	number		-- mguthrie
	);

/**
The Data loaded in the Local PL/SQL table is inserted into the Staging table.
This procedures takes Transaction Level and the Cursor handle as the parameter.
The Cursor handle is passed as 0 in the First call , and the subsequent calls
uses the Cursor Handle returned by the Procedure. This helps in avoiding the
expensive parsing of the SQL Statement again and again for the Same level.
**/
procedure Insert_Into_Stage_Table
        (
        i_level         	IN      NUMBER,
        i_map_id		IN	NUMBER,		-- mguthrie
        i_insert_cursor 	IN OUT NOCOPY  NUMBER
        );

procedure find_pos
        (
        i_level                 IN      number,
        i_search_text           IN      varchar2,
        o_pos                   OUT  NOCOPY   NUMBER,
        i_required              IN      BOOLEAN DEFAULT TRUE
        );

procedure get_tp_code
        (
        i_translator_code       in      varchar2,
        i_location_code         in      varchar2,
        i_address_type          in      varchar2,
	i_transaction_type	in	varchar2,
        i_tp_code               OUT  NOCOPY   varchar2
        );

end EC_INBOUND_STAGE;

 

/
