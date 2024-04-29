--------------------------------------------------------
--  DDL for Package GMF_GLSYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GLSYNCH" AUTHID CURRENT_USER AS
/*       $Header: gmfsyncs.pls 115.3 2002/11/11 00:46:15 rseshadr ship $ */

PROCEDURE Write_Exception(
		pi_table_code 	in	varchar2,
		pi_key_name 	in	varchar2,
		pi_message_code in	varchar2,
		pi_col1	 	in	varchar2,
		pi_col2 	in	varchar2,
		pi_col3 	in	varchar2,
		pi_col4 	in	varchar2,
		pi_col5 	in	varchar2,
		pi_key_value 	in	varchar2) ;

PROCEDURE Delete_Exception(
		pi_table_code 	in	varchar2,
		pi_key_value 	in	varchar2) ;

PROCEDURE Check_Required(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Check_Length(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2,
		pi_field_length	in	number) ;

PROCEDURE Check_Case(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;


PROCEDURE Check_Multiple_Delim(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2,
		pi_delim	in	varchar2) ;

PROCEDURE Validate_Currency(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Rate_Type(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Terms_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) ;

PROCEDURE Validate_Shipper_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) ;

PROCEDURE Validate_FOB_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) ;

PROCEDURE Validate_Frtbill_Mthd(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) ;

PROCEDURE Validate_Vendgl_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Slsrep_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Cust_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Custprice_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Custgl_class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Taxloc_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Taxcalc_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Validate_Whse_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) ;

PROCEDURE Save_Addr(
		pi_addr_id	in out	NOCOPY number,
		pi_addr1	in	varchar2,
		pi_addr2	in	varchar2,
		pi_addr3	in	varchar2,
		pi_addr4	in	varchar2,
		pi_ora_addr4	in	varchar2,
		pi_province	in	varchar2,
		pi_county	in	varchar2,
		pi_state_code	in	varchar2,
		pi_country_code	in	varchar2,
		pi_postal_code	in	varchar2,
		pi_pseudo_key	in	varchar2,
		pi_date_modified	in	date,
		pi_modified_by	in	varchar2,
		pi_date_added	in	varchar2,
		pi_added_by	in	varchar2);

FUNCTION Validate_Terms_Code(pi_field_value in varchar2) return boolean;
FUNCTION Validate_Shipper_Code(pi_field_value in varchar2) return boolean;
FUNCTION Validate_FOB_Code(pi_field_value in varchar2) return boolean;
FUNCTION Validate_Slsrep_Code(pi_field_value in varchar2) return boolean;

END; -- Gmf_Glsynch package

 

/
