--------------------------------------------------------
--  DDL for Package PAY_CA_WCB_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_WCB_FF_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: pycawcfc.pkh 120.0.12010000.3 2009/06/08 10:47:59 sapalani ship $ */
--
FUNCTION get_rate_id_for_wcb_code (p_bg_id          number
                                  ,p_account_number varchar2
                                  ,p_code           varchar2
                                  ,p_jurisdiction   varchar2)
RETURN NUMBER;
--
FUNCTION get_rate_id_for_job(p_account_number varchar2
                            ,p_job            varchar2
                            ,p_jurisdiction   varchar2)
RETURN NUMBER;
--
FUNCTION get_wcb_rate (p_rate_id number) RETURN number;
--
END pay_ca_wcb_ff_functions;
--

/
