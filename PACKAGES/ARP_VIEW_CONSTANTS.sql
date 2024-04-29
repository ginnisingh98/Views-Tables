--------------------------------------------------------
--  DDL for Package ARP_VIEW_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_VIEW_CONSTANTS" AUTHID CURRENT_USER AS
/* $Header: ARCUVIES.pls 120.3 2005/11/14 18:39:57 jypandey ship $ */

PROCEDURE set_customer_id (pn_customer_id IN NUMBER);
FUNCTION get_customer_id RETURN NUMBER;

PROCEDURE set_apply_date (pd_apply_date IN DATE);
FUNCTION get_apply_date RETURN DATE;

PROCEDURE set_receipt_gl_date (pd_receipt_gl_date IN DATE);
FUNCTION get_receipt_gl_date RETURN DATE;

PROCEDURE set_receipt_currency (pd_receipt_currency IN VARCHAR2);
FUNCTION get_receipt_currency RETURN VARCHAR2;

FUNCTION is_gl_date_valid(
                           p_gl_date                in date,
                           p_trx_date               in date,
                           p_validation_date1       in date,
                           p_validation_date2       in date,
                           p_validation_date3       in date,
                           p_allow_not_open_flag    in varchar2,
                           p_set_of_books_id        in number,
                           p_application_id         in number,
                           p_check_period_status    in boolean default TRUE
                         ) RETURN BOOLEAN;

function mass_apps_default_gl_date(
                                    gl_date                in date,
                                    trx_date               in date,
                                    validation_date1       in date,
                                    validation_date2       in date,
                                    validation_date3       in date,
                                    default_date1          in date,
                                    default_date2          in date,
                                    default_date3          in date,
                                    p_allow_not_open_flag  in varchar2,
                                    p_invoicing_rule_id    in varchar2,
                                    p_set_of_books_id      in number,
                                    p_application_id       in number,
                                    default_gl_date        out NOCOPY date,
                                    defaulting_rule_used   out NOCOPY varchar2,
                                    error_message          out NOCOPY varchar2
                                  ) return boolean;

FUNCTION get_default_gl_date (pd_candidate_gl_date IN DATE) RETURN DATE;

PROCEDURE set_sales_order (p_sales_order IN VARCHAR2);
FUNCTION  get_sales_order RETURN VARCHAR2;

PROCEDURE set_status (p_status IN VARCHAR2);
FUNCTION  get_status RETURN VARCHAR2;

PROCEDURE set_incl_receipts_at_risk (p_incl_receipts_at_risk IN VARCHAR2);
FUNCTION get_incl_receipts_at_risk RETURN VARCHAR2;

PROCEDURE set_ps_selected_in_batch (p_ps_autorct_batch IN varchar2);
FUNCTION get_ps_selected_in_batch RETURN varchar2;

END ARP_VIEW_CONSTANTS;

 

/
