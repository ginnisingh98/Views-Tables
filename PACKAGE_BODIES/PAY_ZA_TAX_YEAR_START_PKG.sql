--------------------------------------------------------
--  DDL for Package Body PAY_ZA_TAX_YEAR_START_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_TAX_YEAR_START_PKG" AS
/* $Header: pyzatysp.pkb 115.2 2002/11/28 15:16:22 jlouw noship $ */
/*
REM +=====================================================================+
REM |         Copyright (c) 1997 Oracle Corporation South Africa Ltd      |
REM |                  Cape Town, Western Cape, South Africa              |
REM |                           All rights reserved.                      |
REM +=====================================================================+
REM
REM Package File Name   : pyzatysp.pkb
REM Description         : This package declares a procedure to process the
REM                       start of the tax year.  I.e. resetting the tax directive
REM                       numbers, tax directive value and tax status.
REM
REM Change List:
REM ------------
REM
REM Name           Date        Version Bug      Text
REM -------------- ----------- ------- -------- ----------------------
REM K de Klerk     19-APR-1999 110.0           Initial Version
REM E. ShungKing   23-OCT-1999 110.1           Change to tax year start
REM A.STANDER      12-MAR-2000 110.2           Change not to update people that
REM                                            have been updated manualy
REM L. Kloppers    23-SEP-2002 115.1   2224332 Modify to cater for new
REM                                            Tax Statuses 'N' and 'P'
REM ========================================================================
*/


/* This procedure sets the Tax Certificate number
   (input value on the ZA_Tax element) to 'N', clears the
   Tax Directive Number and Tax Directive Value (also input
   values on the ZA_Tax element) and set the input value
   Tax Status on the ZA_Tax element to 'A' - Normal where the Tax Status is
   'C' or 'D', and set it to 'M' - Private Director where the Tax Status is
   'N' or 'P'*/

PROCEDURE reset_all_ind
          (
           p_errmsg        OUT NOCOPY VARCHAR2,
           p_errcode       OUT NOCOPY NUMBER,
           p_payroll           NUMBER,
           p_tax_year          VARCHAR2)
AS
    l_tax_year              NUMBER;
    l_tax_year_end          DATE;
    l_tax_year_start        DATE;
    l_error_message         VARCHAR2(100);
    l_one_record            c_entry_details%ROWTYPE;
    l_new_value             VARCHAR2(60);
    l_element_type_id       NUMBER;
    tax_status_id           NUMBER;
    tax_directive_number_id NUMBER;
    tax_directive_value_id  NUMBER;




BEGIN


 -- Get the tax year end and new start date --
    l_tax_year_start := Pay_Za_Update_Pkg.get_tax_year_end(p_payroll, p_tax_year);

    l_tax_year_end := l_tax_year_start - 1;

 -- Get the tax year that the process must run for --
    l_tax_year := TO_NUMBER(SUBSTR(p_tax_year,-4));

 -- Get the element_type_id for ZA_tax --
      SELECT element_type_id
        INTO l_element_type_id
        FROM pay_element_types_f
       WHERE element_name = 'ZA_Tax'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;


-- Get the input_value_id's for Tax Status ,Tax Directive Number, Tax Directive Value
      SELECT input_value_id
        INTO tax_status_id
        FROM pay_input_values_f
       WHERE element_type_id = l_element_type_id
         AND name = 'Tax Status'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

      SELECT input_value_id
        INTO tax_directive_number_id
        FROM pay_input_values_f
       WHERE element_type_id = l_element_type_id
         AND name = 'Tax Directive Number'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

       SELECT input_value_id
         INTO tax_directive_value_id
         FROM pay_input_values_f
        WHERE element_type_id = l_element_type_id
          AND name = 'Tax Directive Value'
          AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;


    -- Check if the payroll is updatable --
    IF Pay_Za_Update_Pkg.payroll_updateble(p_payroll, l_tax_year) THEN

       FOR v_assignments IN c_assignments(p_payroll, l_tax_year_end)
 LOOP

      OPEN c_entry_details(l_element_type_id,tax_status_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
     FETCH c_entry_details INTO l_one_record;

          IF l_one_record.screen_entry_value IN ('C','D') THEN

           IF NOT Pay_Za_Update_Pkg.entry_valid(l_one_record,'NEXT_DAY_CHANGE') THEN
              l_new_value := 'Normal';

                  Pay_Za_Update_Pkg.update_this_record
                                (
                                 l_one_record,
                                 l_new_value,
                                 'UPDATE_CHANGE_INSERT'
                                 );

           END IF;
          END IF;

          IF l_one_record.screen_entry_value IN ('N','P') THEN

           IF NOT Pay_Za_Update_Pkg.entry_valid(l_one_record,'NEXT_DAY_CHANGE') THEN
              l_new_value := 'Private Director';

                  Pay_Za_Update_Pkg.update_this_record
                                (
                                 l_one_record,
                                 l_new_value,
                                 'UPDATE_CHANGE_INSERT'
                                 );

           END IF;
          END IF;

    CLOSE c_entry_details;

    OPEN c_entry_details(l_element_type_id,tax_directive_number_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
   FETCH c_entry_details INTO l_one_record;

        IF l_one_record.screen_entry_value IS NOT NULL THEN

         IF NOT Pay_Za_Update_Pkg.entry_valid(l_one_record,'NEXT_DAY_CHANGE') THEN
            l_new_value := ' ';

                  Pay_Za_Update_Pkg.update_this_record
                                (
                                 l_one_record,
                                 l_new_value,
                                 'UPDATE_CHANGE_INSERT'
                                 );

          END IF;
         END IF;
   CLOSE c_entry_details;

   OPEN c_entry_details(l_element_type_id,tax_directive_value_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
  FETCH c_entry_details INTO l_one_record;

       IF l_one_record.screen_entry_value IS NOT NULL THEN

        IF NOT Pay_Za_Update_Pkg.entry_valid(l_one_record,'NEXT_DAY_CHANGE') THEN
--           l_new_value := ' ';
           l_new_value := null;

                  Pay_Za_Update_Pkg.update_this_record
                                (
                                 l_one_record,
                                 l_new_value,
                                 'UPDATE_CHANGE_INSERT'
                                 );

       END IF;
      END IF;
  CLOSE c_entry_details;
 END LOOP;

           -- Update the TYS table --
           Pay_Za_Update_Pkg.update_tysp_table
                         (
                          p_payroll,
                          l_tax_year
                         );
        END IF;

END reset_all_ind;

/* This procedure does a rollback on the tax year end process */

PROCEDURE rollback_all_ind
          (
           p_errmsg        OUT NOCOPY VARCHAR2,
           p_errcode       OUT NOCOPY NUMBER,
           p_payroll           NUMBER,
           p_tax_year          VARCHAR2
          )
AS

    l_tax_year        NUMBER;
    l_tax_year_end    DATE;
    l_tax_year_start  DATE;
    l_error_message   VARCHAR2(100);
    l_one_record      c_entry_details%ROWTYPE;
    l_new_value       VARCHAR2(60);
    l_element_type_id NUMBER;
    tax_status_id     NUMBER;
    tax_directive_number_id NUMBER;
    tax_directive_value_id NUMBER;

BEGIN

-- Get the tax year end date --
    l_tax_year_start := Pay_Za_Update_Pkg.get_tax_year_end(p_payroll, p_tax_year);
    l_tax_year_end   := l_tax_year_start -1;

-- Get the tax year that the process must run for --
    l_tax_year := TO_NUMBER(SUBSTR(p_tax_year,-4));

-- Get the element_type_id for ZA_tax --
      SELECT element_type_id
        INTO l_element_type_id
        FROM pay_element_types_f
       WHERE element_name = 'ZA_Tax'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

-- Get the input_value_id's for Tax Status ,Tax Directive Number, Tax Directive Value
      SELECT input_value_id
        INTO tax_status_id
        FROM pay_input_values_f
       WHERE element_type_id = l_element_type_id
         AND name = 'Tax Status'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

      SELECT input_value_id
        INTO tax_directive_number_id
        FROM pay_input_values_f
       WHERE element_type_id = l_element_type_id
         AND name = 'Tax Directive Number'
         AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

       SELECT input_value_id
         INTO tax_directive_value_id
         FROM pay_input_values_f
        WHERE element_type_id = l_element_type_id
          AND name = 'Tax Directive Value'
          AND l_tax_year_end BETWEEN effective_start_date AND effective_end_date;

-- Check if the payroll is updatable --
    IF Pay_Za_Update_Pkg.payroll_rollbackable(p_payroll, l_tax_year) THEN

      FOR v_assignments IN c_assignments(p_payroll, l_tax_year_end)
 LOOP

-- Check and update tax_status if tax_status in ('C','D','N','P') --
  OPEN c_entry_details(l_element_type_id,tax_status_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
 FETCH c_entry_details INTO l_one_record;

           Pay_Za_Update_Pkg.rollback_this_record(l_one_record);
 CLOSE c_entry_details;

  OPEN c_entry_details(l_element_type_id,tax_directive_number_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
 FETCH c_entry_details INTO l_one_record;

       Pay_Za_Update_Pkg.rollback_this_record(l_one_record);
 CLOSE c_entry_details;

  OPEN c_entry_details(l_element_type_id,tax_directive_value_id,v_assignments.assignment_id,p_payroll,l_tax_year_end);
 FETCH c_entry_details INTO l_one_record;

           Pay_Za_Update_Pkg.rollback_this_record(l_one_record);
 CLOSE c_entry_details;
 END LOOP;

   -- Update the TYS table --
           Pay_Za_Update_Pkg.delete_tysp_table
                         (
                          p_payroll,
                          l_tax_year
                         );
        END IF;

END rollback_all_ind;
END Pay_Za_Tax_Year_Start_Pkg;

/
