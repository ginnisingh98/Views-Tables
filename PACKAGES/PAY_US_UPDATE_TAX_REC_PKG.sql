--------------------------------------------------------
--  DDL for Package PAY_US_UPDATE_TAX_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_UPDATE_TAX_REC_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusutxr.pkh 120.0 2005/05/29 10:08:04 appldev noship $ */

     PROCEDURE terminate_emp_tax_records    ( p_assignment_id  NUMBER
                                             ,p_process_date   DATE
					     ,p_actual_termination_date DATE DEFAULT NULL);

     PROCEDURE reverse_term_emp_tax_records ( p_assignment_id  NUMBER
                                             ,p_process_date   DATE);

end pay_us_update_tax_rec_pkg;

 

/
