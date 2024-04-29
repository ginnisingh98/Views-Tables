--------------------------------------------------------
--  DDL for Package AR_BFB_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BFB_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: ARBFBUTS.pls 120.4 2006/09/21 08:58:10 apandit noship $ */

function get_billing_date (p_billing_cycle_id IN NUMBER,
                           p_billing_date     IN DATE) RETURN DATE;

function get_bill_process_date (p_billing_cycle_id IN NUMBER,
                                p_billing_date     IN DATE,
                                p_last_bill_date   IN DATE DEFAULT SYSDATE) RETURN DATE;

function get_due_date ( p_billing_date in DATE,
                        p_payment_term_id in NUMBER) RETURN DATE;

function is_payment_term_bfb( p_payment_term_id  IN NUMBER) RETURN VARCHAR2;

function is_payment_term_bfb( p_payment_term_name IN VARCHAR2) RETURN  VARCHAR2;

function get_bill_level( p_cust_account_id IN NUMBER,
                         p_site_use_id     IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

function get_billing_cycle (p_payment_term_id in NUMBER) RETURN NUMBER;

function is_valid_billing_date(p_billing_cycle_id IN NUMBER,
                               p_entered_date IN DATE) RETURN VARCHAR2;

function get_cycle_type (p_bill_cycle_id IN NUMBER) RETURN VARCHAR2;

function get_open_rec(p_cust_trx_type_id IN NUMBER) RETURN VARCHAR2;

function get_default_term( p_trx_type_id IN NUMBER,
                           p_trx_date IN DATE,
                           p_org_id IN NUMBER,
                           p_bill_to_site IN NUMBER,
                           p_bill_to_customer IN NUMBER) RETURN NUMBER;

procedure validate_and_default_term (p_request_id IN NUMBER,
                                     p_error_count IN OUT NOCOPY NUMBER);

procedure populate(p_billing_cycle_id IN NUMBER);

end ar_bfb_utils_pvt;

 

/
