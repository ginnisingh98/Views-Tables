--------------------------------------------------------
--  DDL for Package Body FV_THIRD_PARTY_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_THIRD_PARTY_PAYMENTS_PKG" AS
/* $Header: FVTPPPRB.pls 120.4 2005/12/29 22:01:12 dsadhukh ship $ */

PROCEDURE LOG_MESSAGE
(
  p_error_level NUMBER,
  p_module_name VARCHAR2,
  p_message     VARCHAR2,
  p_debug       VARCHAR2 DEFAULT 'Y'
);

PROCEDURE INITIALIZATION;

PROCEDURE PROCESS_PAYMENT_RECS;

PROCEDURE POPULATE_TPP_CHK_DTLS (p_assignment_id      NUMBER,
                                 p_check_number       NUMBER,
                                 p_checkrun_name      VARCHAR2,
                                 p_exception_category VARCHAR2,
                                 p_org_id             NUMBER,
                                 p_set_of_books_id    NUMBER,
                                 p_creation_date      DATE,
                                 p_created_by         NUMBER,
                                 p_last_update_date   DATE,
                                 p_last_updated_by    NUMBER,
                                 p_last_update_login  NUMBER);

PROCEDURE PRINT_EXCEPTION_REPORT;

FUNCTION VENDOR_NAME(p_vendor_id NUMBER) RETURN VARCHAR2;

FUNCTION VENDOR_SITE(p_vendor_site_id NUMBER) RETURN VARCHAR2;

PROCEDURE SUBMIT_TPP_REPORT;

-- -------------------------------------------------------------
--              PROCEDURE MAIN
-- -------------------------------------------------------------
-- This is called from the concurrent program to execute Third
-- Party Payments Process. The purpose of this process is to call
-- all the subsequent procedures.
-- -------------------------------------------------------------
PROCEDURE MAIN(x_errbuf          OUT NOCOPY VARCHAR2,
               x_retcode         OUT NOCOPY NUMBER,
               p_checkrun_name              VARCHAR2)
IS
  BEGIN
   null;
END MAIN;


-- -------------------------------------------------------------
--              PROCEDURE LOG_MESSAGE
-- -------------------------------------------------------------
-- The purpose of this procedures is to accept a message and
-- print it to the log file.
-- -------------------------------------------------------------
PROCEDURE LOG_MESSAGE
(
  p_error_level NUMBER,
  p_module_name VARCHAR2,
  p_message     VARCHAR2,
  p_debug       VARCHAR2 DEFAULT 'Y'
) IS
 BEGIN
null;
END LOG_MESSAGE;


-- -------------------------------------------------------------
--              PROCEDURE INITIALIZATION
-- -------------------------------------------------------------
-- The purpose of this procedure is to delete any existing data
-- from Fv_Tpp_Check_Details table for g_checkrun_name.
-- -------------------------------------------------------------
PROCEDURE INITIALIZATION IS
  BEGIN
   null;
END INITIALIZATION;


-- -------------------------------------------------------------
--              PROCEDURE PROCESS_PAYMENT_RECS
-- -------------------------------------------------------------
-- The purpose of this procedure is to fetch payments and update
-- the supplier information with the third party information.
-- -------------------------------------------------------------
PROCEDURE PROCESS_PAYMENT_RECS IS
BEGIN
  null;
END PROCESS_PAYMENT_RECS;


-- -------------------------------------------------------------
--              PROCEDURE POPULATE_TPP_CHK_DTLS
-- -------------------------------------------------------------
-- The purpose of this procedure is to populate fv_tpp_check_
-- details_all table.
-- -------------------------------------------------------------
PROCEDURE POPULATE_TPP_CHK_DTLS (p_assignment_id NUMBER,
				 p_check_number NUMBER,
				 p_checkrun_name VARCHAR2,
				 p_exception_category VARCHAR2,
				 p_org_id NUMBER,
				 p_set_of_books_id NUMBER,
				 p_creation_date DATE,
				 p_created_by NUMBER,
				 p_last_update_date DATE,
				 p_last_updated_by NUMBER,
				 p_last_update_login NUMBER) IS
  BEGIN
   null;
END POPULATE_TPP_CHK_DTLS;


-- -------------------------------------------------------------
--              PROCEDURE PRINT_EXCEPTION_REPORT
-- -------------------------------------------------------------
-- The purpose of this procedure is to print the exception report
-- in the output/log file.
-- -------------------------------------------------------------
PROCEDURE PRINT_EXCEPTION_REPORT IS

BEGIN
  null;
END PRINT_EXCEPTION_REPORT;


-- -------------------------------------------------------------
--              FUNCTION VENDOR_NAME
-- -------------------------------------------------------------
-- The purpose of this function is return a vendor_name
-- corresponding to a vendor_id
-- -------------------------------------------------------------
FUNCTION VENDOR_NAME(p_vendor_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
   RETURN null;
  END VENDOR_NAME;


-- -------------------------------------------------------------
--              FUNCTION VENDOR_SITE
-- -------------------------------------------------------------
-- The purpose of this function is return a vendor_site_code
-- corresponding to a vendor_site_id
-- -------------------------------------------------------------
FUNCTION VENDOR_SITE(p_vendor_site_id NUMBER) RETURN VARCHAR2 IS
 BEGIN
   RETURN null;
END VENDOR_SITE;


-- -------------------------------------------------------------
--              PROCEDURE SUBMIT_TPP_REPORT
-- -------------------------------------------------------------
-- The purpose of this procedure is to submit TPP Report if any
-- data found in fv_tpp_check_details for the payment batch. The
-- process waits for the report to complete.
-- -------------------------------------------------------------
PROCEDURE SUBMIT_TPP_REPORT IS
 BEGIN
  null;
END SUBMIT_TPP_REPORT;

END FV_THIRD_PARTY_PAYMENTS_PKG;

/
