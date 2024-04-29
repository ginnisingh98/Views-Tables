--------------------------------------------------------
--  DDL for Package PAY_CA_UPDATE_TAX_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_UPDATE_TAX_REC_PKG" AUTHID CURRENT_USER AS
/* $Header: pycautxr.pkh 120.1.12010000.1 2008/11/12 09:29:26 sneelapa noship $ */
------------------------------------------------------------------------------
/*

 +======================================================================+
 |                Copyright (c) 1997 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Header Name : PAY_CA_UPDATE_TAX_REC_PKG
 Package File Name   : pycautxr.pkh
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
                                             ,p_process_date   DATE);

end pay_ca_update_tax_rec_pkg;

/
