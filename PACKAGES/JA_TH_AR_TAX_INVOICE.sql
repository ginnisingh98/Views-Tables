--------------------------------------------------------
--  DDL for Package JA_TH_AR_TAX_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_TH_AR_TAX_INVOICE" AUTHID CURRENT_USER AS
/* $Header: jathrtis.pls 120.2 2005/10/30 01:47:58 appldev ship $ */

  FUNCTION validate_trx_date(
    p_customer_trx_id  IN NUMBER,
    p_trx_date         IN DATE,
    p_last_issued_date IN DATE,
    p_advance_days     IN NUMBER,
    p_created_from     IN VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION validate_tax_code(
    p_customer_trx_id IN NUMBER,
    p_created_from IN VARCHAR2
  )
  RETURN NUMBER;

  FUNCTION update_last_issued_date(
    p_customer_trx_id  IN NUMBER,
    p_cust_trx_type_id IN NUMBER,
    p_trx_date         IN DATE,
    p_created_from     IN VARCHAR2
  )
  RETURN NUMBER;

END ja_th_ar_tax_invoice;

/
