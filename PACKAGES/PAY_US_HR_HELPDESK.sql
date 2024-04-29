--------------------------------------------------------
--  DDL for Package PAY_US_HR_HELPDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_HR_HELPDESK" AUTHID CURRENT_USER AS
/* $Header: payushrhd.pkh 120.0.12010000.2 2009/04/17 09:55:40 sudedas noship $ */

procedure GET_USPAY_DETAILS (p_per_id number,
                             p_bg_id number,
                             p_eff_date date,
                             p_leg_code varchar2,
                             p_pyrl_dtls  out nocopy HR_PERSON_RECORD.PAYROLL_RECORD,
                             p_error out nocopy varchar2);
END PAY_US_HR_HELPDESK;

/
