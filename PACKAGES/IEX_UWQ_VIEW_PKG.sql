--------------------------------------------------------
--  DDL for Package IEX_UWQ_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_UWQ_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: iextuvws.pls 120.1.12010000.1 2008/07/29 10:08:01 appldev ship $ */
--Start bug 6634879 gnramasa 20th Nov 07
FUNCTION get_del_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER;
FUNCTION get_pro_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2 ,p_org_id NUMBER) RETURN NUMBER;
FUNCTION get_str_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER;
FUNCTION convert_amount(p_from_amount NUMBER, p_from_currency VARCHAR2) RETURN NUMBER;
FUNCTION get_last_payment_amount(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN NUMBER;
FUNCTION get_last_payment_number(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN VARCHAR2;
FUNCTION get_score(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER) RETURN NUMBER;
FUNCTION get_broken_prm_amt(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER,p_org_id NUMBER) RETURN NUMBER;
FUNCTION get_prm_amt(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER,p_org_id NUMBER) RETURN NUMBER;
FUNCTION get_case_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER;
FUNCTION get_contract_count(p_party_id NUMBER, p_cust_account_id NUMBER, p_site_use_id NUMBER, p_uwq_status VARCHAR2) RETURN NUMBER;
--End bug 6634879 gnramasa 20th Nov 07
END;

/
