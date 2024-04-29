--------------------------------------------------------
--  DDL for Package Body PAY_CA_UPDATE_TAX_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_UPDATE_TAX_REC_PKG" AS
/* $Header: pycautxr.pkb 120.0.12010000.1 2008/11/12 09:26:53 sneelapa noship $ */
------------------------------------------------------------------------------
/*

 +======================================================================+
 |                Copyright (c) 1997 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : PAY_CA_UPDATE_TAX_REC_PKG
 Package File Name : pycautxr.pkb
 Description : This package was created to handle the update of the tax
               records in specific case:

               a) If the employee termination is reversed, the tax records
               need to be modified to update the Effective End Date to
               the end of time.

               The following two tables are updated:
               pay_ca_emp_fed_tax_info_f, pay_ca_emp_prov_tax_info_f.

 Change List:
 ------------

 Name           Date     Version    Bug     Text
 ----------- ---------- --------- ------- ------------------------------
 sneelapa     23-APR-08   115.0            Initial Version

 ======================================================================== */

     PROCEDURE reverse_term_emp_tax_records ( p_assignment_id  NUMBER
                                             ,p_process_date   DATE)
     IS
     BEGIN
     --
        hr_utility.trace('Entered reverse_term_emp_tax_records for assign ' ||
                         p_assignment_id );
        --
	hr_utility.set_location
	('pay_ca_update_tax_rec_pkg.reverse_term_emp_tax_records',5);
        UPDATE  pay_ca_emp_fed_tax_info_f peft
        SET     peft.effective_end_date    =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   peft.assignment_id         = p_assignment_id
        AND     peft.effective_end_date    = p_process_date;
        --
	hr_utility.set_location
	('pay_ca_update_tax_rec_pkg.reverse_term_emp_tax_records',6);
        UPDATE  pay_ca_emp_prov_tax_info_f pest
        SET     pest.effective_end_date    =
                to_date('31/12/4712','DD/MM/YYYY')
        WHERE   pest.assignment_id         = p_assignment_id
        AND     pest.effective_end_date    = p_process_date;
        --
        EXCEPTION
           when NO_DATA_FOUND then
                NULL;

     END reverse_term_emp_tax_records;

end pay_ca_update_tax_rec_pkg;

/
