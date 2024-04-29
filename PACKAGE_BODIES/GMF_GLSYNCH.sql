--------------------------------------------------------
--  DDL for Package Body GMF_GLSYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GLSYNCH" AS
/*       $Header: gmfsyncb.pls 115.10 2002/11/11 00:46:04 rseshadr ship $ */
	/* Package variable will be used in cursor fetches */
	DummyN	NUMBER := 0;

	/* This procedure will insert exceptions into the sy_excp_tbl.
	The interface_id and co_code will always be -99 and ' ' respectively.*/

PROCEDURE Write_Exception(
		pi_table_code 	in	varchar2,
		pi_key_name 	in	varchar2,
		pi_message_code	in	varchar2,
		pi_col1	 	in	varchar2,
		pi_col2 	in	varchar2,
		pi_col3 	in	varchar2,
		pi_col4 	in	varchar2,
		pi_col5 	in	varchar2,
		pi_key_value 	in	varchar2) IS
	message_args	GMF_MSG_PKG.SubstituteTabTyp;
	message_id	number;
	message_text	varchar2(512);
	error_status	number;
BEGIN
	Gmf_Session_Vars.FOUND_ERRORS := 'Y';
	<<GL_LOG_TRIGGER_ERROR>>
	IF Gmf_Session_Vars.GL_LOG_TRIGGER_ERROR = 1 THEN
		INSERT into sy_excp_tbl(
			software_code,
			table_code ,
			message_code ,
			exception_date ,
			col1,
			col2,
			col3,
			col4,
			col5,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATED_BY,
			CREATION_DATE,
			interface_id ,
			co_code,
			key_value)
		VALUES(
			'ORAFIN',
			substrb(pi_table_code, 1, 16),
			substrb(pi_message_code, 1, 32),
			sysdate,
			substrb(pi_key_name || ' `' || pi_key_value || '`', 1, 64),
			substrb(pi_col2, 1, 64),
			substrb(pi_col3, 1, 64),
			substrb(pi_col4, 1, 64),
			substrb(pi_col5, 1, 64),
			sysdate,
			Gmf_session_vars.last_updated_by,
			Gmf_session_vars.last_updated_by,
			sysdate,
			-99,
			decode(pi_table_code, 'Customers', Gmf_Session_Vars.GL_EXCP_CO_CODE, NULL),
			substrb(pi_key_value, 1, 256));
	ELSE
		BEGIN
			message_args (1) := substrb(pi_key_name || ' ''' || pi_key_value || '''', 1, 64);
			message_args (2) :=substrb(pi_col2, 1, 64);
			message_args (3) :=substrb(pi_col3, 1, 64);
			message_args (4) :=substrb(pi_col4, 1, 64);
			message_args (5) :=substrb(pi_col5, 1, 64);

			GMF_MSG_PKG.get_msg_from_code(message_id,
						pi_message_code,
						message_text,
						gmf_session_vars.last_updated_by,
						message_args,
						error_status);

			Gmf_Session_Vars.ERROR_TEXT := substrb(message_text,1,512);

		EXCEPTION
			/*
			When there is no user defined in the GEMMS for the
			corresponding user of Oracle APPS an exception will be
			raised. In such case an error will be diaplayed in the
			default language of ORAF user which exists when
			integrating  Oracle Apps and GEMMS.
			*/

			WHEN others THEN
			BEGIN
				GMF_MSG_PKG.get_msg_from_code(message_id,
						pi_message_code,
						message_text,
						'ORAF',
						message_args,
						error_status);

				Gmf_Session_Vars.ERROR_TEXT := substrb(message_text,1,512);
			EXCEPTION
				When others THEN
					Gmf_Session_Vars.ERROR_TEXT:=pi_message_code;
			END;
		END;
	END IF; /*GL_LOG_TRIGGER_ERROR*/
EXCEPTION
	WHEN others THEN
		null;
END; /*Write_Exception*/

/* This procedure will delete exceptions from the sy_excp_tbl. */

PROCEDURE Delete_Exception(
		pi_table_code 	in	varchar2,
		pi_key_value 	in	varchar2) IS
BEGIN
	DELETE  FROM sy_excp_tbl
	WHERE key_value = pi_key_value
	AND table_code = pi_table_code;

EXCEPTION
	WHEN others THEN
		null;
END; /*  Delete_Exception */



/* This procedure will check if the field_value is NULL.
   If it is NULL, it logs an error into the sy_excp_tbl. */

PROCEDURE Check_Required(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
BEGIN
	IF pi_field_value is NULL THEN
		write_exception(pi_table_name, pi_key_name,
				'GL_MISSING_VAL', ' ',
				pi_field_name, pi_field_value,
				' ', ' ', pi_key_value);
		RAISE Gmf_Session_Vars.ex_error_found;
	END IF;
END; /* Check_Required */


/* This procedure will check if the field_value is
   in Upper case. If not, it logs an error into the
   sy_excp_tbl. */

PROCEDURE Check_Case(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
BEGIN
	IF pi_field_value <> UPPER(pi_field_value) THEN
		write_exception(pi_table_name, pi_key_name,
				'GL_INVALID_CASE', ' ',
				pi_field_value, pi_field_name,
				' ', ' ',pi_key_value);
		RAISE Gmf_Session_Vars.ex_error_found;
	END IF;
END; /* Check_Case */


/* This procedure will check if the length the field_value
   is greater than field_length. If yes, it logs an error
   into the sy_excp_tbl. */

PROCEDURE Check_Length(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2,
		pi_field_length	in	number) IS
BEGIN
	IF (LENGTHB(pi_field_value) > pi_field_length) THEN
		write_exception(pi_table_name, pi_key_name,
				'GL_INVALID_LEN', ' ',
				pi_field_value, pi_field_name,
				pi_field_length, ' ', pi_key_value);
		RAISE Gmf_Session_Vars.ex_error_found;
	END IF;
END; /* Check_Length */


/* This function validates that the Currency Codes exists
   in gl_curr_mst table */

PROCEDURE Validate_Currency(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Currency (v_apps_currency_code in varchar2) IS
	SELECT 1
	FROM gl_curr_mst
	WHERE currency_code = v_apps_currency_code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Currency%ISOPEN THEN
			CLOSE C_Val_Currency;
		END IF;

		OPEN C_Val_Currency (pi_field_value);
		FETCH C_Val_Currency INTO DummyN;
		IF C_Val_Currency%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Currency%ISOPEN THEN
				CLOSE C_Val_Currency;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Currency%ISOPEN THEN
			CLOSE C_Val_Currency;
		END IF;
	END IF;
END; /* Validate_Currency */


/* This procedure will check if the field_value contains
   multiple delimiters.
   If yes, it logs an error into the sy_excp_tbl. */

PROCEDURE Check_Multiple_Delim(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2,
		pi_delim	in	varchar2) IS
BEGIN
	IF instr(pi_field_value,pi_delim,instr(pi_field_value, pi_delim)+1) > 0 THEN
		write_exception(pi_table_name, pi_key_name,
				'GL_INVALID_DELIM', ' ',
				pi_field_value, pi_field_name,
				' ', ' ',pi_key_value);
		RAISE Gmf_Session_Vars.ex_error_found;
	END IF;
END; /* Check_Multiple_delimiters */

/* This function validates that the Rate Type Codes
   exists in gl_rate_typ table */

PROCEDURE Validate_Rate_Type(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Rate_Type (v_apps_rate_type_code in varchar2) IS
	SELECT 1
	FROM gl_rate_typ
	WHERE rate_type_code = v_apps_rate_type_code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Rate_Type%ISOPEN THEN
			CLOSE C_Val_Rate_Type;
		END IF;
		OPEN C_Val_Rate_Type (pi_field_value);
		FETCH C_Val_Rate_Type INTO DummyN;
		IF C_Val_Rate_Type%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			RAISE Gmf_Session_Vars.ex_error_found;
			IF C_Val_Rate_Type%ISOPEN THEN
				CLOSE C_Val_Rate_Type;
			END IF;
		END IF;
		IF C_Val_Rate_Type%ISOPEN THEN
			CLOSE C_Val_Rate_Type;
		END IF;
	END IF;
END; /* Validate_Rate_Type */

/* This function validates that the Terms Codes
   exists in op_term_mst table */

PROCEDURE Validate_Terms_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) IS
CURSOR C_Val_Terms_Code (v_of_terms_code in varchar2,
			 v_terms_code out varchar2) IS
	SELECT terms_code
	FROM op_term_mst
	WHERE of_terms_code = v_of_terms_code;
v_temp_terms_code	op_term_mst.terms_code%TYPE;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Terms_Code%ISOPEN THEN
			CLOSE C_Val_Terms_Code;
		END IF;
		OPEN C_Val_Terms_Code (pi_field_value, v_temp_terms_code);
		FETCH C_Val_Terms_Code INTO v_temp_terms_code;
		IF C_Val_Terms_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Terms_Code%ISOPEN THEN
				CLOSE C_Val_Terms_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		pi_field_value := v_temp_terms_code;
		IF C_Val_Terms_Code%ISOPEN THEN
			CLOSE C_Val_Terms_Code;
		END IF;
	END IF;
END; /* Validate_Terms_Code */

/* This function validates that the shipper code
   exists in op_ship_mst table */

PROCEDURE Validate_Shipper_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) IS
CURSOR C_Val_Shipper_Code (v_of_shipper_code in varchar2,
			 v_shipper_code out varchar2) IS
	SELECT shipper_code
	FROM op_ship_mst
	WHERE of_shipper_code = v_of_shipper_code;
v_temp_shipper_code	op_ship_mst.shipper_code%TYPE;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Shipper_Code%ISOPEN THEN
			CLOSE C_Val_Shipper_Code;
		END IF;
		OPEN C_Val_Shipper_Code (pi_field_value, v_temp_shipper_code);
		FETCH C_Val_Shipper_Code INTO v_temp_shipper_code;
		IF C_Val_Shipper_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Shipper_Code%ISOPEN THEN
				CLOSE C_Val_Shipper_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		pi_field_value := v_temp_shipper_code;
		IF C_Val_Shipper_Code%ISOPEN THEN
			CLOSE C_Val_Shipper_Code;
		END IF;
	END IF;
END; /* Validate_Shipper_Code */

/* This function validates that the FOB Codes
   exists in op_fobc_mst table */

PROCEDURE Validate_FOB_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) IS
CURSOR C_Val_FOB_Code (v_of_fob_code in varchar2,
			 v_fob_code out varchar2) IS
	SELECT fob_code
	FROM op_fobc_mst
	WHERE of_fob_code = v_of_fob_code;
v_temp_fob_code	op_fobc_mst.fob_code%TYPE;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_FOB_Code%ISOPEN THEN
			CLOSE C_Val_FOB_Code;
		END IF;
		OPEN C_Val_FOB_Code (pi_field_value, v_temp_fob_code);
		FETCH C_Val_FOB_Code INTO v_temp_fob_code;
		IF C_Val_FOB_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_FOB_Code%ISOPEN THEN
				CLOSE C_Val_FOB_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		pi_field_value := v_temp_fob_code;
		IF C_Val_FOB_Code%ISOPEN THEN
			CLOSE C_Val_FOB_Code;
		END IF;
	END IF;
END; /* Validate_FOB_Code */

/* This function validates that the Frtbill Method
   exists in op_frgt_mth table */

PROCEDURE Validate_Frtbill_Mthd(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in out	NOCOPY varchar2) IS
CURSOR C_Val_Frtbill_Mthd (v_of_Frtbill_Mthd in varchar2,
			 v_Frtbill_Mthd out varchar2) IS
	SELECT Frtbill_Mthd
	FROM op_frgt_mth
	WHERE of_Frtbill_Mthd = v_of_Frtbill_Mthd;
v_temp_Frtbill_Mthd	op_frgt_mth.Frtbill_Mthd%TYPE;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Frtbill_Mthd%ISOPEN THEN
			CLOSE C_Val_Frtbill_Mthd;
		END IF;
		OPEN C_Val_Frtbill_Mthd (pi_field_value, v_temp_Frtbill_Mthd);
		FETCH C_Val_Frtbill_Mthd INTO v_temp_Frtbill_Mthd;
		IF C_Val_Frtbill_Mthd%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Frtbill_Mthd%ISOPEN THEN
				CLOSE C_Val_Frtbill_Mthd;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		pi_field_value := v_temp_Frtbill_Mthd;
		IF C_Val_Frtbill_Mthd%ISOPEN THEN
			CLOSE C_Val_Frtbill_Mthd;
		END IF;
	END IF;
END; /* Validate_Frtbill_Mthd */

/* This function validates that the Rate Type Codes
   exists in gl_rate_typ table */

PROCEDURE Validate_Vendgl_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Vendgl_Class (v_apps_Vendgl_Class in varchar2) IS
	SELECT 1
	FROM po_vgld_cls
	WHERE Vendgl_Class = v_apps_Vendgl_Class;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Vendgl_Class%ISOPEN THEN
			CLOSE C_Val_Vendgl_Class;
		END IF;
		OPEN C_Val_Vendgl_Class (pi_field_value);
		FETCH C_Val_Vendgl_Class INTO DummyN;
		IF C_Val_Vendgl_Class%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Vendgl_Class%ISOPEN THEN
				CLOSE C_Val_Vendgl_Class;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Vendgl_Class%ISOPEN THEN
			CLOSE C_Val_Vendgl_Class;
		END IF;
	END IF;
END; /* Validate_Vendgl_Class */

/* This function validates that the Slsrep Code
   exists in op_slsr_mst table */

PROCEDURE Validate_Slsrep_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Slsrep_Code (v_apps_Slsrep_Code in varchar2) IS
	SELECT 1
	FROM op_slsr_mst
	WHERE Slsrep_Code = v_apps_Slsrep_Code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Slsrep_Code%ISOPEN THEN
			CLOSE C_Val_Slsrep_Code;
		END IF;
		OPEN C_Val_Slsrep_Code (pi_field_value);
		FETCH C_Val_Slsrep_Code INTO DummyN;
		IF C_Val_Slsrep_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Slsrep_Code%ISOPEN THEN
				CLOSE C_Val_Slsrep_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Slsrep_Code%ISOPEN THEN
			CLOSE C_Val_Slsrep_Code;
		END IF;
	END IF;
END; /* Validate_Slsrep_Code */

/* This function validates that the cust_class
   exists in op_cust_cls table */

PROCEDURE Validate_Cust_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Cust_Class (v_apps_Cust_Class in varchar2) IS
	SELECT 1
	FROM op_cust_cls
	WHERE Cust_Class = v_apps_Cust_Class;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Cust_Class%ISOPEN THEN
			CLOSE C_Val_Cust_Class;
		END IF;
		OPEN C_Val_Cust_Class (pi_field_value);
		FETCH C_Val_Cust_Class INTO DummyN;
		IF C_Val_Cust_Class%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Cust_Class%ISOPEN THEN
				CLOSE C_Val_Cust_Class;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Cust_Class%ISOPEN THEN
			CLOSE C_Val_Cust_Class;
		END IF;
	END IF;
END; /* Validate_Cust_Class */

/* This function validates that the Custgl Class
   exists in op_cgld_cls table */

PROCEDURE Validate_Custgl_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Custgl_Class (v_apps_Custgl_Class in varchar2) IS
	SELECT 1
	FROM op_cgld_cls
	WHERE Custgl_Class = v_apps_Custgl_Class;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Custgl_Class%ISOPEN THEN
			CLOSE C_Val_Custgl_Class;
		END IF;
		OPEN C_Val_Custgl_Class (pi_field_value);
		FETCH C_Val_Custgl_Class INTO DummyN;
		IF C_Val_Custgl_Class%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Custgl_Class%ISOPEN THEN
				CLOSE C_Val_Custgl_Class;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Custgl_Class%ISOPEN THEN
			CLOSE C_Val_Custgl_Class;
		END IF;
	END IF;
END; /* Validate_Custgl_Class */

/* This function validates that the custprice_class
   exists in op_cprc_cls table */

PROCEDURE Validate_Custprice_Class(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Custprice_Class (v_apps_Custprice_Class in varchar2) IS
	SELECT 1
	FROM op_cprc_cls
	WHERE Custprice_Class = v_apps_Custprice_Class;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Custprice_Class%ISOPEN THEN
			CLOSE C_Val_Custprice_Class;
		END IF;
		OPEN C_Val_Custprice_Class (pi_field_value);
		FETCH C_Val_Custprice_Class INTO DummyN;
		IF C_Val_Custprice_Class%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Custprice_Class%ISOPEN THEN
				CLOSE C_Val_Custprice_Class;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Custprice_Class%ISOPEN THEN
			CLOSE C_Val_Custprice_Class;
		END IF;
	END IF;
END; /* Validate_Custprice_Class */

/* This function validates that the taxloc_code
   exists in tx_tloc_cds table */

PROCEDURE Validate_Taxloc_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Taxloc_Code (v_apps_Taxloc_Code in varchar2) IS
	SELECT 1
	FROM tx_tloc_cds
	WHERE Taxloc_Code = v_apps_Taxloc_Code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Taxloc_Code%ISOPEN THEN
			CLOSE C_Val_Taxloc_Code;
		END IF;
		OPEN C_Val_Taxloc_Code (pi_field_value);
		FETCH C_Val_Taxloc_Code INTO DummyN;
		IF C_Val_Taxloc_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Taxloc_Code%ISOPEN THEN
				CLOSE C_Val_Taxloc_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Taxloc_Code%ISOPEN THEN
			CLOSE C_Val_Taxloc_Code;
		END IF;
	END IF;
END; /* Validate_Taxloc_Code */

/* This function validates that the taxcalc_code
   exists in tx_calc_mst table */

PROCEDURE Validate_Taxcalc_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Taxcalc_Code (v_apps_Taxcalc_Code in varchar2) IS
	SELECT 1
	FROM tx_calc_mst
	WHERE Taxcalc_Code = v_apps_Taxcalc_Code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Taxcalc_Code%ISOPEN THEN
			CLOSE C_Val_Taxcalc_Code;
		END IF;
		OPEN C_Val_Taxcalc_Code (pi_field_value);
		FETCH C_Val_Taxcalc_Code INTO DummyN;
		IF C_Val_Taxcalc_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Taxcalc_Code%ISOPEN THEN
				CLOSE C_Val_Taxcalc_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Taxcalc_Code%ISOPEN THEN
			CLOSE C_Val_Taxcalc_Code;
		END IF;
	END IF;
END; /* Validate_Taxcalc_Code */

/* This function validates that the taxcalc_code
   exists in ic_whse_mst table */

PROCEDURE Validate_Whse_Code(
		pi_table_name	in 	varchar2,
		pi_key_name	in	varchar2,
		pi_key_value	in	varchar2,
		pi_field_name	in	varchar2,
		pi_field_value	in	varchar2) IS
CURSOR C_Val_Whse_Code (v_apps_Whse_Code in varchar2) IS
	SELECT 1
	FROM ic_whse_mst
	WHERE Whse_Code = v_apps_Whse_Code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Whse_Code%ISOPEN THEN
			CLOSE C_Val_Whse_Code;
		END IF;
		OPEN C_Val_Whse_Code (pi_field_value);
		FETCH C_Val_Whse_Code INTO DummyN;
		IF C_Val_Whse_Code%NOTFOUND THEN
			write_exception(pi_table_name, pi_key_name,
					'GL_INVALID_VAL', ' ',
					pi_field_value, pi_field_name,
					' ', ' ',pi_key_value);
			IF C_Val_Whse_Code%ISOPEN THEN
				CLOSE C_Val_Whse_Code;
			END IF;
			RAISE Gmf_Session_Vars.ex_error_found;
		END IF;
		IF C_Val_Whse_Code%ISOPEN THEN
			CLOSE C_Val_Whse_Code;
		END IF;
	END IF;
END; /* Validate_Whse_Code */

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
		pi_added_by	in	varchar2) IS
BEGIN
	IF pi_addr_id <> 0 and pi_addr_id is not null THEN
		UPDATE sy_addr_mst
		SET
			addr1 = nvl(pi_addr1,' '),
			addr2 = nvl(pi_addr2,' '),
			addr3 = nvl(pi_addr3,' '),
			addr4 = nvl(pi_addr4,' '),
			ora_addr4     = nvl(pi_ora_addr4,' '),
			province = nvl(pi_province,' '),
			county   = nvl(pi_county,' '),
			state_code = nvl(pi_state_code,' '),
			country_code = nvl(pi_country_code,' '),
			postal_code = nvl(pi_postal_code,' '),
			pseudo_key = pi_pseudo_key,
			last_update_date = nvl(pi_date_modified, to_date(2440588,'J')),
			last_updated_by = nvl(pi_modified_by,0),
			creation_date = nvl(pi_date_added, to_date(2440588,'J')),
			created_by = nvl(pi_added_by,0)
		WHERE
			addr_id = pi_addr_id;
	END IF;

	IF SQL%NOTFOUND OR pi_addr_id = 0 or pi_addr_id is NULL THEN
		SELECT GEM5_address_id_s.nextval INTO pi_addr_id FROM dual;
		INSERT into sy_addr_mst(
			addr_id,
			addr1,
			addr2,
			addr3,
			addr4,
			ora_addr4,
			province,
			county,
			state_code,
			country_code,
			postal_code,
			pseudo_key,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			comments,
			delete_mark,
			trans_cnt)
		values(
			pi_addr_id,
			nvl(pi_addr1, ' '),
			nvl(pi_addr2, ' '),
			nvl(pi_addr3, ' '),
			nvl(pi_addr4, ' '),
			nvl(pi_ora_addr4, ' '),
			nvl(pi_province, ' '),
			nvl(pi_county, ' '),
			nvl(pi_state_code, ' '),
			nvl(pi_country_code, ' '),
			nvl(pi_postal_code, ' '),
			pi_pseudo_key,
			nvl(pi_date_modified, to_date(2440588,'J')),
			nvl(pi_modified_by,0),
			nvl(pi_date_added, to_date(2440588,'J')),
			nvl(pi_added_by,0),
			' ',
			0,
			0);
	END IF;
	/* Insert the state_code if it is not already there in sy_geog_mst */
	IF pi_state_code is not NULL THEN
		INSERT into SY_GEOG_MST(
			geog_type,
			geog_code,
			geog_desc,
			delete_mark,
			trans_cnt,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by)
		SELECT
			2,
			pi_state_code,
			pi_state_code,
			0,
			0,
			nvl(pi_date_added, to_date(2440588,'J')),
			nvl(pi_added_by,0),
			nvl(pi_date_modified, to_date(2440588,'J')),
			nvl(pi_modified_by,0)
		FROM	SYS.DUAL
		WHERE   not exists(
			SELECT 1 FROM SY_GEOG_MST
			WHERE geog_type = 2 and geog_code = pi_state_code);
	END IF;
	/* Insert the Country Code if it is not already there in sy_geog_mst */
	IF pi_country_code is not NULL THEN
		INSERT into SY_GEOG_MST(
			geog_type,
			geog_code,
			geog_desc,
			delete_mark,
			trans_cnt,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by)
		SELECT
			1,
			pi_country_code,
			territory_short_name,
			0,
			0,
			nvl(pi_date_added, to_date(2440588,'J')),
			nvl(pi_added_by,0),
			nvl(pi_date_modified, to_date(2440588,'J')),
			nvl(pi_modified_by,0)
		FROM	fnd_territories_vl
		WHERE   territory_code = pi_country_code and
			not exists(
			SELECT 1 FROM SY_GEOG_MST
			WHERE geog_type = 1 and geog_code = pi_country_code);
	END IF;
END; /* Save_Adddr */


FUNCTION Validate_Terms_Code(pi_field_value in varchar2) return boolean IS
CURSOR C_Val_Terms_Code (v_of_terms_code in varchar2) IS
	SELECT 1
	FROM op_term_mst
	WHERE of_terms_code = v_of_terms_code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Terms_Code%ISOPEN THEN
			CLOSE C_Val_Terms_Code;
		END IF;
		OPEN C_Val_Terms_Code (pi_field_value);
		FETCH C_Val_Terms_Code INTO DummyN;
		IF C_Val_Terms_Code%NOTFOUND THEN
			IF C_Val_Terms_Code%ISOPEN THEN
				CLOSE C_Val_Terms_Code;
			END IF;
			return FALSE;
		END IF;
		IF C_Val_Terms_Code%ISOPEN THEN
			CLOSE C_Val_Terms_Code;
		END IF;
		return TRUE;
	END IF;
	return TRUE;
END; /* Validate_Terms_Code */


FUNCTION Validate_Shipper_Code(pi_field_value varchar2) return boolean IS
CURSOR C_Val_Shipper_Code (v_of_shipper_code in varchar2) IS
	SELECT 1
	FROM op_ship_mst
	WHERE of_shipper_code = v_of_shipper_code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Shipper_Code%ISOPEN THEN
			CLOSE C_Val_Shipper_Code;
		END IF;
		OPEN C_Val_Shipper_Code (pi_field_value);
		FETCH C_Val_Shipper_Code INTO DummyN;
		IF C_Val_Shipper_Code%NOTFOUND THEN
			IF C_Val_Shipper_Code%ISOPEN THEN
				CLOSE C_Val_Shipper_Code;
			END IF;
			return FALSE;
		END IF;
		IF C_Val_Shipper_Code%ISOPEN THEN
			CLOSE C_Val_Shipper_Code;
		END IF;
		return TRUE;
	END IF;
	return TRUE;
END; /* Validate_Shipper_Code */


FUNCTION Validate_FOB_Code(pi_field_value varchar2) return boolean IS
CURSOR C_Val_FOB_Code (v_of_fob_code in varchar2) IS
	SELECT 1
	FROM op_fobc_mst
	WHERE of_fob_code = v_of_fob_code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_FOB_Code%ISOPEN THEN
			CLOSE C_Val_FOB_Code;
		END IF;
		OPEN C_Val_FOB_Code (pi_field_value);
		FETCH C_Val_FOB_Code INTO DummyN;
		IF C_Val_FOB_Code%NOTFOUND THEN
			IF C_Val_FOB_Code%ISOPEN THEN
				CLOSE C_Val_FOB_Code;
			END IF;
			return FALSE;
		END IF;
		IF C_Val_FOB_Code%ISOPEN THEN
			CLOSE C_Val_FOB_Code;
		END IF;
		return TRUE;
	END IF;
	return TRUE;
END; /* Validate_FOB_Code */


FUNCTION Validate_Slsrep_Code(pi_field_value varchar2) return boolean IS
CURSOR C_Val_Slsrep_Code (v_apps_Slsrep_Code in varchar2) IS
	SELECT 1
	FROM op_slsr_mst
	WHERE Slsrep_Code = v_apps_Slsrep_Code;
BEGIN
	IF pi_field_value IS NOT NULL THEN
		IF C_Val_Slsrep_Code%ISOPEN THEN
			CLOSE C_Val_Slsrep_Code;
		END IF;
		OPEN C_Val_Slsrep_Code (pi_field_value);
		FETCH C_Val_Slsrep_Code INTO DummyN;
		IF C_Val_Slsrep_Code%NOTFOUND THEN
			IF C_Val_Slsrep_Code%ISOPEN THEN
				CLOSE C_Val_Slsrep_Code;
			END IF;
			return FALSE;
		END IF;
		IF C_Val_Slsrep_Code%ISOPEN THEN
			CLOSE C_Val_Slsrep_Code;
		END IF;
		return TRUE;
	END IF;
	return TRUE;
END; /* Validate_Slsrep_Code */


END; /* Gmf_Glsynch package body */

/
