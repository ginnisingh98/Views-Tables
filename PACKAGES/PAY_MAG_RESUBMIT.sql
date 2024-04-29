--------------------------------------------------------
--  DDL for Package PAY_MAG_RESUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAG_RESUBMIT" AUTHID CURRENT_USER as
/* $Header: pymagrdo.pkh 115.0 99/07/17 06:16:31 porting ship $ */

 procedure redo (     errbuf		     out varchar2,
		      retcode		     out number,
		      p_payroll_action_id    in  varchar2);
end pay_mag_resubmit;

 

/
