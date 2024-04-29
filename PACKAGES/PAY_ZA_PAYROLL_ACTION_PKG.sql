--------------------------------------------------------
--  DDL for Package PAY_ZA_PAYROLL_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_PAYROLL_ACTION_PKG" AUTHID CURRENT_USER as
/* $Header: pyzapay.pkh 120.2.12010000.1 2008/07/28 00:04:02 appldev ship $ */

PROCEDURE total_payment(p_assignment_action_id in number,
                                p_total_payment out nocopy number);

PROCEDURE total_deduct(p_assignment_action_id in number,
                     p_total_deduct out nocopy number);

FUNCTION defined_balance_id (p_balance_type     in varchar2,
                             p_dimension_suffix in varchar2) return number;

FUNCTION get_balance_reporting_name (p_balance_type  in varchar2 ) return varchar2;

PROCEDURE formula_inputs_wf (p_session_date in     date,
                 p_payroll_exists           in out nocopy varchar2,
                 p_assignment_action_id     in out nocopy number,
                 p_run_assignment_action_id in out nocopy number,
                 p_assignment_id            in     number,
                 p_payroll_action_id        in out nocopy number,
                 p_date_earned              in out nocopy varchar2);

PROCEDURE formula_inputs_hc (p_assignment_action_id   in out nocopy number,
                 p_run_assignment_action_id in out nocopy number,
                 p_assignment_id            in out nocopy number,
                 p_payroll_action_id        in out nocopy number,
                 p_date_earned              in out nocopy varchar2);

procedure get_home_add(p_person_id IN NUMBER,
                       p_add1 IN out nocopy VARCHAR2,
                       p_add2 IN out nocopy VARCHAR2,
                       p_add3 IN out nocopy VARCHAR2,
		               p_reg1 IN out nocopy VARCHAR2,
		               p_reg2 IN out nocopy VARCHAR2,
		               p_reg3 IN out nocopy VARCHAR2,
                       p_twnc IN out nocopy VARCHAR2);

END PAY_ZA_PAYROLL_ACTION_PKG;

/
