--------------------------------------------------------
--  DDL for Package PAY_US_FS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_FS_UPD_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusfsup.pkh 115.1 2003/09/05 12:10 tclewis noship $ */


/* DESCRIPTION OF THE LOCAL PROCEDURES:
        pay_us_fs_upd_pkg  => updates rows in
                              pay_us_emp_state_tax_rules_f

*/

PROCEDURE update_report_fs_rec (p_pest_state_code     IN VARCHAR2,
                                           p_pest_fs_code        IN VARCHAR2,
                                           p_pest_id             IN NUMBER,
                                           p_session_id          IN NUMBER,
                                           p_bug_number          IN NUMBER,
                                           p_new_fs_code         IN VARCHAR2 );

PROCEDURE update_filing_status(
                          p_tax_rule_id_start IN NUMBER,
                          p_tax_rule_id_end   IN NUMBER ) ;



end pay_us_fs_upd_pkg;

 

/
