--------------------------------------------------------
--  DDL for Package PAY_ZA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyzaupdt.pkh 120.1.12010000.1 2008/07/28 00:06:46 appldev ship $ */

FUNCTION payroll_updateble
         (
          p_payroll  NUMBER,
          p_tax_year NUMBER
         )
RETURN   BOOLEAN;
PRAGMA RESTRICT_REFERENCES(payroll_updateble, WNDS);

/*
Function get_tax_year
         (
          p_payroll number
         )
Return    varchar2;
Pragma restrict_references(get_tax_year, WNDS, WNPS);
*/

FUNCTION get_tax_year_end
         (
          p_payroll NUMBER,
          p_tax_year VARCHAR2
         )
RETURN    DATE;
PRAGMA RESTRICT_REFERENCES(get_tax_year_end, WNDS);

FUNCTION entry_valid
         (
          p_record Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE,
          p_validation_mode VARCHAR2
         )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(entry_valid, WNDS);

PROCEDURE update_this_record
          (
           p_one_record  Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE,
           p_new_value   VARCHAR2,
           p_update_mode VARCHAR2
          );

PROCEDURE update_tysp_table
          (
           p_payroll  NUMBER,
           p_tax_year NUMBER
          );

PROCEDURE delete_tysp_table
          (
           p_payroll  NUMBER,
           p_tax_year NUMBER
          );

FUNCTION payroll_rollbackable
         (
          p_payroll  NUMBER,
          p_tax_year NUMBER
         )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(payroll_rollbackable, WNDS);

FUNCTION get_original_value
         (
          p_record Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE
         )
RETURN   VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_original_value, WNDS);

PROCEDURE rollback_this_record
          (
           p_record Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE
          );

END Pay_Za_Update_Pkg;

/
