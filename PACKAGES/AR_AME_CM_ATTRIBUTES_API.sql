--------------------------------------------------------
--  DDL for Package AR_AME_CM_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AME_CM_ATTRIBUTES_API" AUTHID CURRENT_USER AS
/* $Header: ARAMEATS.pls 115.3 2003/06/05 22:02:39 orashid noship $ */


  c_application_id CONSTANT fnd_application.application_id%TYPE   := 222;
  c_item_type      CONSTANT wf_item_attributes.item_type%TYPE := 'ARAMECM';

-----------------------------------------------------------------------------


FUNCTION get_customer_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

FUNCTION get_customer_trx_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

FUNCTION get_bill_to_use_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

FUNCTION get_collector_id (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

FUNCTION get_non_default_person_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

FUNCTION get_requestor_person_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

FUNCTION get_approval_path (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

FUNCTION get_reason_code (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

FUNCTION get_transaction_amount (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

-- Get Approver ID
FUNCTION get_approver_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

-- Get Approver User Name
FUNCTION get_approver_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Batch Source Name
FUNCTION get_batch_source_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Bill to Customer Name
FUNCTION get_bill_to_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Bill to Customer Number
FUNCTION get_bill_to_customer_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Collector Employee Id
FUNCTION get_collector_employee_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

-- Get Collector Name
FUNCTION get_collector_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Collector User Name
FUNCTION get_collector_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Currency Code
FUNCTION get_currency_code (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Customer Name
FUNCTION get_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Original Transaction Number
FUNCTION get_orig_trx_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Requestor Id
FUNCTION get_requestor_id (p_transaction_id IN  NUMBER)
    RETURN NUMBER;

-- Get Requestor User Name
FUNCTION get_requestor_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Ship to Customer Name
FUNCTION get_ship_to_customer_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Get Ship to Customer Number
FUNCTION get_ship_to_customer_number (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- Tax Ex Certification Number
FUNCTION get_tax_ex_cert_num (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- primary salesperson user name
FUNCTION get_salesrep_user_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- transaction type name
FUNCTION get_transaction_type_name (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

-- transaction context
FUNCTION get_transaction_context (p_transaction_id IN  NUMBER)
    RETURN VARCHAR2;

END ar_ame_cm_attributes_api;

 

/
