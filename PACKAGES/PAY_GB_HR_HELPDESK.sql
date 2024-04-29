--------------------------------------------------------
--  DDL for Package PAY_GB_HR_HELPDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_HR_HELPDESK" 
 /* $Header: pygbhelpdesk.pkh 120.0.12010000.2 2009/04/17 10:05:30 rlingama noship $ */
AUTHID CURRENT_USER AS

procedure GET_UKPAY_DETAILS (p_per_id number,
                             p_bg_id number,
                             p_eff_date date,
                             p_leg_code varchar2,
                             --p_pyrl_dtls  out nocopy HR_PERSON_PAY_RECORD.PAYROLL_RECORD,
			     p_pyrl_dtls  out nocopy HR_PERSON_RECORD.PAYROLL_RECORD,
                             p_error out nocopy varchar2);
END PAY_GB_HR_HELPDESK;

/
