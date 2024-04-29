--------------------------------------------------------
--  DDL for Package Body PAY_MAG_RESUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAG_RESUBMIT" as
/* $Header: pymagrdo.pkb 115.0 99/07/17 06:16:28 porting ship $ */

 procedure redo (     errbuf		    out varchar2,
		      retcode   	    out number,
		      p_payroll_action_id   in varchar2) is

 l_report_type		varchar2(240);
 l_errbuf		varchar2(240);
 l_retcode		number;

 begin

     	select ltrim(substr(legislative_parameters, 11,5))
   	into  l_report_type
     	from pay_payroll_actions
     	where payroll_action_id = p_payroll_action_id;

        if (instr(l_report_type,'MWS',1,1) > 0)   /* MWS */
	then
		pay_mws_magtape_reporting.redo(l_errbuf,
					       l_retcode,
					       p_payroll_action_id);

        elsif (instr(l_report_type,'1099',1,1) > 0) /* 1099R */
	then
		pay_us_magtape_reporting.redo(l_errbuf,
					      l_retcode,
					      p_payroll_action_id);

	else  /* W2 */
		pay_us_magtape_reporting.redo(l_errbuf,
					      l_retcode,
					      p_payroll_action_id);
	end if;

        errbuf := l_errbuf;
	retcode := l_retcode;

   exception
	when no_data_found then
	   errbuf := 'No Report for this payroll action id : ' ||
						p_payroll_action_id;
	   retcode := 2;

	when others then
	   errbuf := 'ORA :' || to_char(sqlcode) || sqlerrm;
	   retcode := sqlcode;
 end redo;


end pay_mag_resubmit;

/
