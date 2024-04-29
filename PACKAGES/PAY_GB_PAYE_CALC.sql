--------------------------------------------------------
--  DDL for Package PAY_GB_PAYE_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_PAYE_CALC" AUTHID CURRENT_USER as
/* $Header: pygbpaye.pkh 120.6.12010000.1 2008/07/27 22:46:03 appldev ship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_gb_paye_calc

    Description : This package contains calculations for use in PAYE processing

    Uses        :

    Used By     : FOT fast formula


    Change List :

    Version	Date	 Author		Description
    ------- 	-----	 --------	----------------
    115.0	6/6/01	 GBUTLER	Created
    115.4     21/12/06   SBAIRAGI       Added check_tax_ref function.
    115.5     28/12/05   TUKUMAR	Bug 4528372 : added function tax_year_of_pensioners_death


*/
	function free_pay (p_amount 		 IN NUMBER,
			   p_tax_code 		 IN VARCHAR2,
			   p_tax_basis		 IN VARCHAR2,
			   p_stat_annual_periods IN NUMBER,
			   p_current_period	 IN NUMBER) return NUMBER;

 	function tax_to_date (p_session_date	    IN DATE,
 	  		      p_taxable_pay	    IN NUMBER,
 			      p_tax_code	    IN VARCHAR2,
 			      p_tax_basis	    IN VARCHAR2,
 			      p_stat_annual_periods IN NUMBER,
 			      p_current_period	    IN NUMBER) return NUMBER;

	function check_tax_ref(p_assignment_id number, p_payroll_id number , p_pay_run_date date,p_payroll_action_id number) return number;

	function tax_year_of_pensioners_death (p_assignmnet_id in number ,p_pay_run_date in date)
	return varchar2 ;

	type g_paye_rec is record
        (
         g_gross_low_value    pay_user_rows_f.row_low_range_or_name%TYPE,
         g_gross_high_value   pay_user_rows_f.row_high_range%TYPE,
         g_rate		      pay_user_column_instances.value%TYPE,
         g_gross_denom	      NUMBER,
         g_tax_deduct	      NUMBER,
         g_tax_column	      NUMBER,
         g_net_low_value      pay_user_rows_f.row_low_range_or_name%TYPE,
         g_net_high_value     pay_user_rows_f.row_high_range%TYPE
        );

        type g_paye_tabtype is table of g_paye_rec index by binary_integer;

        tbl_paye_table  g_paye_tabtype;

	g_table_inited	BOOLEAN := FALSE;

end pay_gb_paye_calc;

/
