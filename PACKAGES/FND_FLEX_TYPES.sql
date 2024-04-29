--------------------------------------------------------
--  DDL for Package FND_FLEX_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_TYPES" AUTHID CURRENT_USER AS
/* $Header: AFFFTYPS.pls 120.2.12010000.1 2008/07/25 14:14:35 appldev ship $ */



bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);



-- check that a default type exists
-- @param code the code for the type
PROCEDURE validate_default_type(code IN VARCHAR2);

/* flex default type */
-- default type; constant
def_constant CONSTANT VARCHAR2(1) := 'C';
-- default type; date
def_date     CONSTANT VARCHAR2(1) := 'D';
-- default type; time
def_time     CONSTANT VARCHAR2(1) := 'T';
-- default type; environment variable
def_envvar   CONSTANT VARCHAR2(1) := 'E';
-- default type; field
def_field    CONSTANT VARCHAR2(1) := 'F';
-- default type; profile
def_profile  CONSTANT VARCHAR2(1) := 'P';
-- default type; sql statement
def_sql      CONSTANT VARCHAR2(1) := 'S';
-- default type; segment
def_segment  CONSTANT VARCHAR2(1) := 'A';



-- check that a range code exists
-- @param code the code for the type
PROCEDURE validate_range_code(code IN VARCHAR2);

/* range codes */
-- range code; high
rng_high  CONSTANT VARCHAR2(1) := 'H';
-- range code; low
rng_low   CONSTANT VARCHAR2(1) := 'L';
-- range code; pair
rng_pair  CONSTANT VARCHAR2(1) := 'P';



-- check that a field type code exists
-- @param code the code for the type
PROCEDURE validate_field_type(code IN VARCHAR2);

/* field type */
-- field type; character
fld_char           CONSTANT VARCHAR2(1) := 'C';
-- field type; money
fld_money          CONSTANT VARCHAR2(1) := 'M';
-- field type; number
fld_number         CONSTANT VARCHAR2(1) := 'N';
-- field type; standard date
fld_std_date       CONSTANT VARCHAR2(1) := 'X';
-- field type; standard time
fld_std_time       CONSTANT VARCHAR2(1) := 'Z';
-- field type; standart date-time
fld_std_datetime   CONSTANT VARCHAR2(1) := 'Y';
-- field type; old style date
fld_old_date       CONSTANT VARCHAR2(1) := 'D';
-- field type; old style time
fld_old_time       CONSTANT VARCHAR2(1) := 'I';
-- field type; old style datatime
fld_old_datetime   CONSTANT VARCHAR2(1) := 'T';



-- check that a segment validation type code exists
-- @param code the code for the type
PROCEDURE validate_segval_type(code IN VARCHAR2);

/* seg_val_types */
-- segment validation; dependent
val_dependent    CONSTANT VARCHAR2(1) := 'D';
-- segment validation; indendent
val_independent  CONSTANT VARCHAR2(1) := 'I';
-- segment validation; none
val_none         CONSTANT VARCHAR2(1) := 'N';
-- segment validation; pair
val_pair         CONSTANT VARCHAR2(1) := 'P';
-- segment validation; special
val_special      CONSTANT VARCHAR2(1) := 'U';
-- segment validation; table
val_table        CONSTANT VARCHAR2(1) := 'F';



-- check that a event type code exists
-- @param code the code for the type
PROCEDURE validate_event_type(code IN VARCHAR2);

/* flex validation events */
-- validation event type; edit event
evt_edit           CONSTANT VARCHAR2(1) := 'E';
-- validation event type; edit/edit
evt_edit_edit      CONSTANT VARCHAR2(1) := 'O';
-- validation event type; insert/update
evt_insert_update  CONSTANT VARCHAR2(1) := 'I';
-- validation event type; listval
evt_listval        CONSTANT VARCHAR2(1) := 'Q';
-- validation event type; load
evt_load           CONSTANT VARCHAR2(1) := 'L';
-- validation event type; query
evt_query          CONSTANT VARCHAR2(1) := 'F';
-- validation event type; validate
evt_validate       CONSTANT VARCHAR2(1) := 'V';



-- check that a column type code exists
-- @param code the code for the type
PROCEDURE validate_column_type(code IN VARCHAR2);

/* column type */
-- column type; character
col_char         CONSTANT VARCHAR2(1) := 'C';
-- column type; date
col_date         CONSTANT VARCHAR2(1) := 'D';
-- column type; long
col_long         CONSTANT VARCHAR2(1) := 'L';
-- column type; long raw
col_long_raw     CONSTANT VARCHAR2(1) := 'X';
-- column type; mlslabel
col_mlslabel     CONSTANT VARCHAR2(1) := 'M';
-- column type; number
col_number       CONSTANT VARCHAR2(1) := 'N';
-- column type; raw
col_raw          CONSTANT VARCHAR2(1) := 'R';
-- column type; raw mlslabel
col_raw_mlslabel CONSTANT VARCHAR2(1) := 'Z';
-- column type; rowid
col_rowid        CONSTANT VARCHAR2(1) := 'I';
-- column type; varchar
col_varchar      CONSTANT VARCHAR2(1) := 'U';
-- column type; varchar2
col_varchar2     CONSTANT VARCHAR2(1) := 'V';



-- check that a yes_no code exists
-- @param code is the code for the type
PROCEDURE validate_yes_no_flag(code IN VARCHAR2);

/* yes_no type */
-- flag ; yes
flag_yes   CONSTANT VARCHAR2(1) := 'Y';
-- flag ; no
flag_no    CONSTANT VARCHAR2(1) := 'N';

-- given a description of a code, try and find the
-- the code.
FUNCTION get_code(typ IN VARCHAR2, descr IN VARCHAR2) RETURN VARCHAR2;


FUNCTION ad_dd_used_by_flex(p_application_id IN fnd_tables.application_id%TYPE,
			    p_table_name     IN fnd_tables.table_name%TYPE,
			    p_column_name    IN fnd_columns.column_name%TYPE,
			    x_message        OUT NOCOPY VARCHAR2) RETURN BOOLEAN;

END fnd_flex_types;			/* end package */

/
