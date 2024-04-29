--------------------------------------------------------
--  DDL for Package FA_RX_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_FLEX_PKG" AUTHID CURRENT_USER as
/* $Header: FARXFLXS.pls 120.3.12010000.3 2009/07/19 11:56:50 glchen ship $ */


------------------------------------
-- Functions/Procedures
------------------------------------

-------------------------------------------------------------------------
--
-- FUNCTION flex_sql
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_table_alias		Table Alias
--		p_mode			Output mode
--		p_qualifier		Flexfield qualifier or segment number
--		p_function		Operator
--		p_operand1,2		Operands
--
-- Returns VARCHAR2
--   Returns the required SQL clause
--
-- Description
--   This function mimics the functionality of the userexit FLEXSQL.
--   Given the parameters, this function is equivalent to:
--	FND FLEXSQL
--		CODE=":p_id_flex_code"
--		APPL_SHORT_NAME="Short name from :p_application_id"
--		OUTPUT=":This is the return value"
--		MODE=":p_mode"
--		DISPLAY=":p_qualifier"
--		NUM=":p_id_flex_num"
--		TABLEALIAS=":p_table_alias"
--		OPERATOR=":p_function"
--		OPERAND1=":p_operand1"
--		OPERAND2=":p_operand2"
--
-- Restrictions
--   No support for SHOWDEPSEG parameter
--   No support for MULTINUM parameter
--   p_qualifier must be 'ALL' or a valid qualifier name or the segment number.
--   p_function does not support "QBE".
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function flex_sql(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default null,
	p_table_alias in varchar2,
	p_mode in varchar2,
	p_qualifier in varchar2,
	p_function in varchar2 default null,
	p_operand1 in varchar2 default null,
	p_operand2 in varchar2 default null) return varchar2;

-------------------------------------------------------------------------
--
-- FUNCTION get_value
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_table_alias		Table Alias
--		p_mode			Output mode
--		p_qualifier		Flexfield qualifier or segment number
--		p_ccid			Code combination ID
--
-- Returns VARCHAR2
--   Returns the concatenated segment values of the key flexfield
--
-- Description
--   There is no equivalent for this function. This function takes
--   the code combination id for the key flexfield and returns the
--   actual segment values. This function can be used within
--   the after fetch triggers for RXi reports to retrieve the value.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function get_value(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default NULL,
	p_qualifier in varchar2,
	p_ccid in number) return varchar2;

-------------------------------------------------------------------------
--
-- FUNCTION get_description
--
-- Parameters
--		p_application_id	Application ID of key flexfield
--		p_id_flex_code		Flexfield code
--		p_id_flex_num		Flexfield structure num
--		p_qualifier		Flexfield qualifier or segment number
--		p_data			Flexfield Segments
--
-- Returns VARCHAR2
--   Returns the concatenated description of the key flexfield
--
-- Description
--   This function mimics the functionality of the userexit FLEXIDVAL.
--   Given the parameters, this function is equivalent to:
--	FND FLEXIDVAL
--		CODE=":p_id_flex_code"
--		APPL_SHORT_NAME="Short name from :p_application_id"
--		DATA=":p_data"
--		NUM=":p_id_flex_num"
--		DISPLAY=":p_qualifier"
--		IDISPLAY=":p_qualifier"
--		DESCRIPTION=":This is the return value"
--
-- Restrictions
--   No support for SHOWDEPSEG parameter
--   No support for VALUE, APROMPT, LPROMPT, PADDED_VALUE, SECURITY parameter
--   p_qualifier must be 'ALL' or a valid qualifier name or segment number.
--   DISPLAY and IDISPLAY are always the same p_qualifier value.
--
-- Modification History
--  KMIZUTA    02-APR-99	Created.
--
-------------------------------------------------------------------------
function get_description(
	p_application_id in number,
	p_id_flex_code in varchar2,
	p_id_flex_num in number default NULL,
	p_qualifier in varchar2,
	p_data in varchar2) return varchar2;


----------------------
-- The following exception is raised if any
-- of the arguments are invalid for any of the
-- functions in this package
----------------------
invalid_argument exception;
----------------------

-- lgandhi added cache handling mechanism bug2951118

TYPE fa_rx_flex_desc_rec_type IS RECORD (
      application_id fnd_id_flex_structures.application_id%type,
	id_flex_code fnd_id_flex_structures.id_flex_code%type,
	id_flex_num  number,
        qualifier fnd_segment_attribute_types.segment_attribute_type%type,
 	data  varchar2(2000),
	concatenated_description   varchar2(2000)
                                      );


TYPE fa_rx_flex_desc_table_type IS
     TABLE OF fa_rx_flex_desc_rec_type
     INDEX BY BINARY_INTEGER;

fa_rx_flex_desc_t  fa_rx_flex_desc_table_type ;

TYPE fa_rx_flex_val_rec_type IS RECORD (
      application_id fnd_id_flex_structures.application_id%type,
	id_flex_code fnd_id_flex_structures.id_flex_code%type,
	id_flex_num  number,
      qualifier fnd_segment_attribute_types.segment_attribute_type%type,
       ccid number ,
	buffer   varchar2(2000)
                              );


TYPE fa_rx_flex_val_table_type IS
     TABLE OF fa_rx_flex_val_rec_type
     INDEX BY BINARY_INTEGER;

fa_rx_flex_val_t  fa_rx_flex_val_table_type ;

TYPE fa_rx_flex_par_seg_rec_type IS RECORD (
	fap_application_id	FND_ID_FLEX_SEGMENTS.application_id%type,
	fap_id_flex_code	FND_ID_FLEX_SEGMENTS.id_flex_code%type,
	fap_id_flex_num		FND_ID_FLEX_SEGMENTS.id_flex_num%type,
	fap_flex_value_set_id	FND_ID_FLEX_SEGMENTS.flex_value_set_id%type,
	fap_parent_segment_num	FND_ID_FLEX_SEGMENTS.segment_num%type
                                      );


TYPE fa_rx_flex_par_seg_table_type IS
     TABLE OF fa_rx_flex_par_seg_rec_type
     INDEX BY BINARY_INTEGER;

fa_rx_flex_par_seg_t  fa_rx_flex_par_seg_table_type ;

end fa_rx_flex_pkg;

/
