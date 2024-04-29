--------------------------------------------------------
--  DDL for Package JA_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_ZZ_INVOICE_CREATE" AUTHID CURRENT_USER AS
/* $Header: jazzrics.pls 115.3 2004/02/09 20:34:23 thwon ship $ */

----------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES  					  --
----------------------------------------------------------------------------
TYPE varchar2_150_tbl_type is Table of Varchar2(150) index by binary_integer;
TYPE varchar2_50_tbl_type is Table of Varchar2(50) index by binary_integer;
TYPE varchar2_20_tbl_type is Table of Varchar2(20) index by binary_integer;
TYPE number_tbl_type is Table of Number index by binary_integer;
TYPE date_tbl_type is Table of Date index by binary_integer;

Type R_interface_line is RECORD
  (
   trx_header_id          Number_tbl_type,
   trx_line_id            Number_tbl_type,
   customer_trx_id        Number_tbl_type,
   cust_trx_type_id       Number_tbl_type,
   trx_date               Date_tbl_type,
   vat_tax_id             Number_tbl_type,
   line_type              Varchar2_20_tbl_type
   );

Type R_interface_line1 is RECORD
  (
   trx_line_id            Number_tbl_type,
   customer_trx_id        Number_tbl_type,
   cust_trx_type_id       Number_tbl_type,
   trx_date               Date_tbl_type,
   last_issued_date       Date_tbl_type,
   advance_days           Number_tbl_type,
   vat_tax_id             Number_tbl_type,
   line_type              Varchar2_20_tbl_type
   );

FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

END ja_zz_invoice_create;


 

/
