--------------------------------------------------------
--  DDL for Package PAY_GB_EAS_SCOTLAND_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_EAS_SCOTLAND_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: pygbeasf.pkh 120.0.12010000.3 2009/12/24 13:09:25 krreddy ship $ */

FUNCTION get_current_freq(p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION count_main_eas_entry(p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION get_main_eas_pay_date(p_assignment_id IN NUMBER) RETURN DATE;

FUNCTION get_main_eas_freq(p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION check_ref(p_assignment_id IN NUMBER, p_reference IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_main_initial_debt(p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION get_main_fee(p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION get_eas_value(p_table_name IN VARCHAR2, p_row_value IN VARCHAR2,
         p_effective_date in DATE) RETURN NUMBER;

END pay_gb_eas_scotland_functions;

/
