--------------------------------------------------------
--  DDL for Package OTAFRUDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTAFRUDT" AUTHID CURRENT_USER AS
/* $Header: otafrudt.pkh 120.1 2005/06/20 06:36:03 sbairagi noship $ */

PROCEDURE insert_table_data (P_BUSINESS_GROUP_ID_ITD	IN number,
			     P_LEGISLATION_CODE_ITD	IN varchar2,
			     P_APPLICATION_ID_ITD	IN number,
			     P_RANGE_OR_MATCH_ITD	IN varchar2,
			     P_USER_KEY_UNITS_ITD	IN varchar2,
			     P_USER_TABLE_NAME_ITD	IN varchar2,
			     P_USER_ROW_TITLE_ITD	IN varchar2);

PROCEDURE create_table (P_BUSINESS_GROUP_ID_CT	IN number,
			P_APPLICATION_ID_CT	IN number,
			P_RANGE_OR_MATCH_CT	IN varchar2,
			P_USER_KEY_UNITS_CT	IN varchar2,
			P_USER_TABLE_NAME_CT	IN varchar2,
			P_USER_ROW_TITLE_CT	IN varchar2);

PROCEDURE create_column (P_BUSINESS_GROUP_ID_CC	IN number,
		         P_USER_TABLE_NAME_CC	IN varchar2,
		         P_USER_COLUMN_NAME_CC	IN varchar2);

PROCEDURE create_row (P_BUSINESS_GROUP_ID_CR		IN number,
		      P_USER_TABLE_NAME_CR		IN varchar2,
		      P_USER_COLUMN_NAME_CR		IN varchar2,
		      P_ROW_LOW_RANGE_OR_NAME_CR	IN varchar2,
		      P_DISPLAY_SEQUENCE_CR		IN number,
		      P_VALUE_CR			IN varchar2);

PROCEDURE create_from_lookup (P_BUSINESS_GROUP_ID	IN varchar2,
			      P_REQUIRED_DEFAULTS	IN varchar2,
			      P_DEFAULT_VALUE		IN varchar2,
			      P_LOOKUP_TYPE		IN varchar2,
			      P_USER_COLUMN_NAME	IN varchar2,
			      P_USER_KEY_UNITS		IN varchar2);

procedure load_alternate_lookup (l_business_group_id in number);

END OTAFRUDT;

 

/
