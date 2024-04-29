--------------------------------------------------------
--  DDL for Package Body ASF_ERR_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_ERR_REP_PKG" AS
/* $Header: asflerrb.pls 115.1 2000/10/26 02:42:53 pkm ship      $ */
-- ---------------------------------------------------
--  Start of Comments
-- ---------------------------------------------------
--  PACKAGE NAME:   ASF_ERR_REP_PKG
-- ---------------------------------------------------
--  PURPOSE:
--            Stores the errors in the as_ls_err_t table when the API has
--            a problem to perform its function.
--
--  Procedures:
--           (see below for specification)
--
--  NOTES
--            This package is publicly available for use
--
--  HISTORY
--           05/23/00    SGHARAGO         Created
--
--  End of Comments
----------------------------------------------------------
  /* ******* ERROR MSG TABLE VARIABLES ******** */
  t_error_type_id as_ls_errs.error_type_id%TYPE;
  t_error_text as_ls_errs.error_text%TYPE;

PROCEDURE process_error
   (p_dir_flag 			IN VARCHAR2
   ,p_error_num 		IN NUMBER
   ,p_error_code 		IN VARCHAR2
   ,p_error_text 		IN VARCHAR2
   ,p_transaction_id 		IN NUMBER DEFAULT NULL
   ,p_lead_id 			IN NUMBER DEFAULT NULL
   ,p_partner_id 		IN NUMBER DEFAULT NULL
   ) IS

BEGIN
/*	>= 3100 and 3200 	Two Task Error
        >= 6000  and < 7000 	SQL*Net Errors
        >= 7200  and < 7500 	SQL*Net Errors
        >= 12100  and< 12300 	TNS errors
	>= 12500 and < 12700 	TNS errors
        Other are corrnection errors
*/

	IF ((p_error_num >= 3100 and p_error_num < 3200) or
            (p_error_num >= 6000 and p_error_num < 7000) or
            (p_error_num >= 7200 and p_error_num < 7500) or
            (p_error_num >= 12100 and p_error_num < 12300 ) or
            (p_error_num >= 12500 and p_error_num < 12700 ) or
             p_error_num in (28,600,1001,1003,1004,1012,1013,1014,1033,1034,
			     1035,1071,1089,1090,1092,2122))
	THEN
		t_error_type_id := 1;
	ELSE
		t_error_type_id := 2;
	END IF;

--	BEGIN
		INSERT INTO as_ls_errs (error_id, dir_flag,error_status,
					 error_type_id,error_num,error_code,
					 error_text, transaction_id,
					 lead_id,partner_id,error_cre_date)
		VALUES
					 (as_ls_errs_s.nextval,p_dir_flag,
					  'O',t_error_type_id,p_error_num,
					  p_error_code,p_error_text,
					  p_transaction_id,p_lead_id,
					  p_partner_id,sysdate);
	-- EXCEPTION
		--lead_share_mail;

	-- WHEN others THEN
	-- END;
END process_error;
--
END ASF_ERR_REP_PKG;

/
