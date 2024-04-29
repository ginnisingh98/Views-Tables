--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTA_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTA_MATRIX" AUTHID CURRENT_USER as
/* $Header: pydputil.pkh 120.1 2005/06/14 02:23 mkataria noship $ */


/*------------------------------------------------------------------------*/
/*----------------------- < Utility data structures >---------------------*/
/*------------------------------------------------------------------------*/
type user_column_key_rec
is record (
 qualifier varchar2(30)
,user_column_key varchar2(240)
,user_column_value pay_user_column_instances_f.value%type
);

type userkeys is table of user_column_key_rec index by binary_integer;


/*------------------------------------------------------------------------
  --------------------<Create Data Pump Batch Lines>----------------------
  ------------------------------------------------------------------------
  NAME
    CREATE_DATA_PUMP_BATCH_LINES
  DESCRIPTION
    Interface procedure for User Column Instance Matrix spreadsheet.
  NOTES
    Calls the main data pump package hrdpp_create_user_column_insta once
    for each column value passed.
    For example if there are 'N' columns and 'M' rows for the passed
    User Table, this procedure will be called 'M' number of times through
    WebADI (each time with 'N' column values). Each time the procedure is
    called, it will call hrdpp_create_user_column_insta.insert_batch_lines
    'N' number of times.
  PARAMETERS
    p_batch_id                    : Batch Id under which the batch lines
                                    will be created. Mandatory.
    p_data_pump_batch_line_id     : Keeping it for future use.
    p_data_pump_business_grp_name : Business group name. Mandatory.
    p_effective_date              : Effective date of the column instance.
                                    Mandatory.
    p_row_low_range_or_name       : Row name. Mandatory.
    p_user_table_name             : User Table name. Mandatory.
    p_row_high_range              : Row High Range, in case the table is
                                    range type. Optional.
    p_value1..p_value25           : Values corresponding to user columns.
                                    May be null.
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/

procedure create_data_pump_batch_lines
(
  p_batch_id in number
,p_data_pump_batch_line_id      in number    default null
,p_data_pump_business_grp_name  in varchar2
,p_effective_date               in date
,p_row_low_range_or_name       in varchar2
,p_user_table_name             in varchar2
,p_row_high_range              in varchar2 default null
,p_value1                      in varchar2  default null
,p_value2                      in varchar2  default null
,p_value3                      in varchar2  default null
,p_value4                      in varchar2  default null
,p_value5                      in varchar2  default null
,p_value6                      in varchar2  default null
,p_value7                      in varchar2  default null
,p_value8                      in varchar2  default null
,p_value9                      in varchar2  default null
,p_value10                     in varchar2  default null
,p_value11                     in varchar2  default null
,p_value12                     in varchar2  default null
,p_value13                     in varchar2  default null
,p_value14                     in varchar2  default null
,p_value15                     in varchar2  default null
,p_value16                     in varchar2  default null
,p_value17                     in varchar2  default null
,p_value18                     in varchar2  default null
,p_value19                     in varchar2  default null
,p_value20                     in varchar2  default null
,p_value21                     in varchar2  default null
,p_value22                     in varchar2  default null
,p_value23                     in varchar2  default null
,p_value24                     in varchar2  default null
,p_value25                     in varchar2  default null
);


/*------------------------------------------------------------------------
  -------------------------<Create Batch Header>--------------------------
  ------------------------------------------------------------------------
  NAME
    CREATE_BATCH_HEADER
  DESCRIPTION
    Interface procedure for Create Batch Header spreadsheet.
  NOTES
    Creates Data Pump Batch header.
  PARAMETERS
    p_batch_id                    : Name of the batch. Mandatory.
    p_business_group_name         : Business group name. Mandatory.
    p_reference                   : Batch reference. Optional
    p_batch_id                    : Out parameter.
  RETURNS
    p_batch_id                    : Batch Id of the created batch
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/

procedure create_batch_header
(
   p_batch_name          in varchar2,
   p_business_group_name in varchar2  default null,
   p_reference           in varchar2  default null,
   p_batch_id            out nocopy number
);

/*------------------------------------------------------------------------
  -----------------------< Batch Overall Status>--------------------------
  ------------------------------------------------------------------------
  NAME
    BATCH_OVERALL_STATUS
  DESCRIPTION
    Returns overall status of the batch.
  NOTES
    Determines the overall status of the batch.
  PARAMETERS
    p_batch_id                    : Data Pump Batch Id. Mandatory.
  RETURNS
    Overall status of the batch.
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/
function batch_overall_status (p_batch_id number) return varchar2;



/*------------------------------------------------------------------------
  ---------------------------<Get Link Value>-----------------------------
  ------------------------------------------------------------------------
  NAME
    GET_LINK_VALUE
  DESCRIPTION
    Interface function to return link_value for entities belonging to
    one batch.
  NOTES
    Generates link values.
  PARAMETERS
    p_batch_line_id               : Batch Line Id. Optional.
    p_business_group_name         : Business group name. Mandatory.
    p_user_row_user_key           : User Row User Key.May be null.
                                    Mandatory.
    p_user_table_user_key         : User Table User Key. May be null.
                                    Mandatory.
  RETURNS
    link value                    : Link value
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/
function get_link_value
(
   p_batch_line_id number
  ,p_business_group_name varchar2
  ,p_user_row_user_key varchar2
  ,p_user_table_user_key varchar2
) return number;



/*------------------------------------------------------------------------
  ---------------------------<Insert User Key>----------------------------
  ------------------------------------------------------------------------
  NAME
    GET_LINK_VALUE
  DESCRIPTION
    Overloaded procedure to insert user key for a user column. This
    procedure will be invoked when we are creating column instance batch
    line for the column of a table which exists in the live tables.
  NOTES
    Inserts User Column User Key in HR_PUMP_BATCH_LINE_USER_KEYS table.
  PARAMETERS
    p_business_group           : Business group name. Mandatory.
    p_user_column_name         : User column name. Mandatory.
    p_user_table_name          : User table name. Mandatory

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/
procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_column_name  varchar2
 ,p_user_table_name   varchar2
);


/*------------------------------------------------------------------------
  ---------------------------<Insert User Key>----------------------------
  ------------------------------------------------------------------------
  NAME
    GET_LINK_VALUE
  DESCRIPTION
    Overloaded procedure to insert user key for a user row. This
    procedure will be invoked when we are creating column instance batch
    line for the row of a table which exists in the live tables.
  NOTES
    Inserts User Row User Key in HR_PUMP_BATCH_LINE_USER_KEYS table.
  PARAMETERS
    p_business_group           : Business group name. Mandatory.
    p_user_row_name            : User row name. Mandatory.
    p_user_table_name          : User table name. Mandatory
    p_effective_date           : Effective date.
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/
procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_row_name     varchar2
 ,p_user_table_name   varchar2
 ,p_effective_date    date
);


/*------------------------------------------------------------------------
  ---------------------------<Insert User Key>----------------------------
  ------------------------------------------------------------------------
  NAME
    GET_LINK_VALUE
  DESCRIPTION
    Overloaded procedure to insert user key for a user table. This
    procedure will be invoked when we are creating column/row batch
    line for a table which exists in the live table.
  NOTES
    Inserts User Table User Key in HR_PUMP_BATCH_LINE_USER_KEYS table.
  PARAMETERS
    p_business_group           : Business group name. Mandatory.
    p_user_table_name          : User table name. Mandatory

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/
procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_table_name   varchar2
 );


 /*-----------------------------------------------------------------------
  ------------------------<Get Matrix Row Values>-------------------------
  ------------------------------------------------------------------------
  NAME
    GET_MATRIX_ROW_VALUES
  DESCRIPTION
    Function to return all the values corresponding to a row from
    pay_user_column_instances_f and hrdpv_create_user_column_insta to
    display in matrix spreadsheet.
  NOTES
    This function is invoked at the time of download/upload of user
    column instances through matrix spreadsheet.
  PARAMETERS
    p_batch_id number              : Batch Id. Mandatory.
    p_user_table_name              : User table name. Mandatory.
    p_row_low_range_or_name        : User row name. Mandatory
    p_business_group_id            : Business group id. Mandatory.
  RETURNS
    returns all the column instances correponding to a row in the order
    the columns appear in matrix spreadsheet, enclosed between '$'
    characters.
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------*/

function get_matrix_row_values
 (
  p_batch_id number
 ,p_user_table_name varchar2
 ,p_row_low_range_or_name varchar2
 ,p_business_group_id number
 )return varchar2;


end pay_user_column_insta_matrix;


 

/
