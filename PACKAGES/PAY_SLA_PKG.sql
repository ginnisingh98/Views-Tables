--------------------------------------------------------
--  DDL for Package PAY_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SLA_PKG" AUTHID CURRENT_USER AS
/* $Header: pysla.pkh 120.6.12010000.1 2008/07/27 23:42:36 appldev ship $ */
--
/*
 * ***************************************************************************
--
  Copyright (c) Oracle Corporation (UK) Ltd 1993,1994.
  All Rights Reserved.
--
  PRODUCT
    Oracle*Payroll
--
  NAME
    PAY_SLA_PKG  - Payroll support for SLA (Sub Ledger Accounting)
--
--
  DESCRIPTION

  MODIFIED      (DD-MON-YYYY)
     A.Logue    04-Oct-2006     Added create_custom_adrs.
     A.Logue    04-Sep-2006     Added delete_event.
     A.Logue	25-Nov-2005	Added stubs for SLA preaccounting,
                                postaccounting and extract hook procedures.
     A.Logue	22-Nov-2005	Changed post_processing to postprocessing.
     A.Logue	16-Nov-2005	Added various procedures and functions.
     A.Logue	07-Oct-2005	Created
--
*/
--
PROCEDURE trans_asg_costs
	(i_assignment_action_id NUMBER);
--
PROCEDURE postprocessing
        (p_application_id  NUMBER,
         p_accounting_mode VARCHAR2);
--
FUNCTION get_conversion_type
        (i_business_group_id NUMBER,
         i_conversion_date   DATE) RETURN VARCHAR2;
--
FUNCTION get_accounting_date
         (run_action_type     VARCHAR2,
          cost_effective_date DATE,
          run_effective_date  DATE,
          run_date_earned     DATE) RETURN DATE;
--
FUNCTION get_ecost_accounting_date
         (ecost_payroll_id    NUMBER,
          cost_effective_date DATE) RETURN DATE;
--
PROCEDURE preaccounting
        (p_application_id     NUMBER,
         p_ledger_id          NUMBER,
         p_process_category   VARCHAR2,
         p_end_date           DATE,
         p_accounting_mode    VARCHAR2,
         p_valuation_method   VARCHAR2,
         p_security_id_int_1  NUMBER,
         p_security_id_int_2  NUMBER,
         p_security_id_int_3  NUMBER,
         p_security_id_char_1 VARCHAR2,
         p_security_id_char_2 VARCHAR2,
         p_security_id_char_3 VARCHAR2,
         p_report_request_id  NUMBER);
--
PROCEDURE postaccounting
        (p_application_id     NUMBER,
         p_ledger_id          NUMBER,
         p_process_category   VARCHAR2,
         p_end_date           DATE,
         p_accounting_mode    VARCHAR2,
         p_valuation_method   VARCHAR2,
         p_security_id_int_1  NUMBER,
         p_security_id_int_2  NUMBER,
         p_security_id_int_3  NUMBER,
         p_security_id_char_1 VARCHAR2,
         p_security_id_char_2 VARCHAR2,
         p_security_id_char_3 VARCHAR2,
         p_report_request_id  NUMBER);
--
PROCEDURE extract
        (p_application_id     NUMBER,
         p_accounting_mode    VARCHAR2);
--
PROCEDURE delete_event
	(i_assignment_action_id NUMBER);
--
PROCEDURE create_custom_adrs;
--
END pay_sla_pkg;

/
