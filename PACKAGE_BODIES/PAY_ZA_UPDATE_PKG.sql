--------------------------------------------------------
--  DDL for Package Body PAY_ZA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_UPDATE_PKG" AS
/* $Header: pyzaupdt.pkb 120.1.12010000.2 2008/08/06 08:48:56 ubhat ship $ */

/* This function checks whether a payroll is updatuble for TYSP. */

FUNCTION payroll_updateble
         (
          p_payroll  NUMBER,
          p_tax_year NUMBER
         )
RETURN BOOLEAN
AS

    l_result NUMBER;

BEGIN

    SELECT
        COUNT(tysp_id) INTO l_result
    FROM
        pay_za_tys_processes
    WHERE
        payroll_id = p_payroll
        AND tax_year = p_tax_year;

    IF l_result > 0 THEN
       RETURN (FALSE);
    ELSE
       RETURN (TRUE);
    END IF;

END payroll_updateble;

/* This function returns the current tax year for a specific payroll. */

/*
Function get_tax_year
         (
          p_payroll number
         )
Return varchar2
As

    l_tax_year varchar2(4);

Begin

    Select
        ptp.prd_information1 into l_tax_year
    From
        per_time_periods ptp
    Where
        ptp.payroll_id = p_payroll
    And (sysdate - 365) between ptp.start_date and ptp.end_date;

    Return l_tax_year;

End get_tax_year;
*/

/* This function returns the tax year end date */

FUNCTION get_tax_year_end
         (
          p_payroll  NUMBER,
          p_tax_year VARCHAR2
         )
RETURN DATE
AS

    l_tax_year_end DATE;
    l_year         VARCHAR2(4);

BEGIN

    l_year := TO_CHAR(TO_NUMBER( SUBSTR(p_tax_year,-4) ) - 1);

    SELECT MAX(ptp.end_date) + 1 INTO l_tax_year_end
    FROM
        per_time_periods ptp
    WHERE
        ptp.payroll_id = p_payroll
    AND ptp.prd_information1 = SUBSTR(p_tax_year,-4);

    RETURN l_tax_year_end;

END get_tax_year_end;

/* This function does validation on one entry
   If the validation_mode is 'NEXT_DAY_CHANGE', the function will check
   that their is not a date effective entry on the following day of the
   effective_date */

FUNCTION entry_valid
         (
          p_record Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE,
          p_validation_mode VARCHAR2
         )
RETURN BOOLEAN
AS

    l_result VARCHAR2(60);
    l_count  NUMBER;
    l_current_eff_start_date DATE ;
    l_current_eff_end_date DATE;

BEGIN
    IF p_validation_mode = 'NEXT_DAY_CHANGE' THEN
     BEGIN
        SELECT
            peev.screen_entry_value INTO l_result
                FROM
                pay_element_entries_f pee,
                pay_element_entry_values_f peev,
                pay_input_values_f piv,
                pay_element_types_f pet,
                pay_element_links_f pel,
                per_assignments_f pa
                WHERE
                pee.element_entry_id = peev.element_entry_id
            AND piv.input_value_id = peev.input_value_id
            AND piv.name = p_record.name
            AND pee.element_entry_id = p_record.element_entry_id
            AND piv.input_value_id = p_record.input_value_id
            AND piv.input_value_id = peev.input_value_id
            AND pet.element_name = 'ZA_Tax'
            AND pel.element_type_id = pet.element_type_id
            AND pee.element_link_id = pel.element_link_id
            AND pa.assignment_id = pee.assignment_id
            AND (p_record.p_effective_date + 1) BETWEEN peev.effective_start_date AND peev.effective_end_date
            AND (p_record.p_effective_date + 1)BETWEEN pee.effective_start_date AND pee.effective_end_date
            AND (p_record.p_effective_date + 1)BETWEEN piv.effective_start_date AND piv.effective_end_date
            AND (p_record.p_effective_date + 1)BETWEEN pet.effective_start_date AND pet.effective_end_date
            AND (p_record.p_effective_date + 1)BETWEEN pel.effective_start_date AND pel.effective_end_date
            AND (p_record.p_effective_date + 1)BETWEEN pa.effective_start_date AND pa.effective_end_date;

        IF NVL(l_result,'x') = NVL(p_record.screen_entry_value,'x') THEN
               RETURN (FALSE);
        ELSE
               RETURN (TRUE);
        END IF;

                EXCEPTION when no_data_found then
                   RETURN (TRUE);
        END;

    ELSIF p_validation_mode = 'FUTURE_CHANGE' THEN
        SELECT
            COUNT(piv.input_value_id) INTO l_count
        FROM
            pay_input_values_f piv,
            pay_element_types_f pet,
            pay_element_links_f pel,
            pay_element_entries_f pee,
            pay_element_entry_values_f peev
        WHERE
            pee.element_entry_id = peev.element_entry_id
        AND pee.element_entry_id = p_record.element_entry_id
        AND piv.input_value_id = peev.input_value_id
        AND pet.element_type_id = piv.element_type_id
        AND pet.element_name = 'ZA_Tax'
        AND pel.element_type_id = pet.element_type_id
        AND pee.element_link_id = pel.element_link_id
        AND (p_record.p_effective_date + 2) < peev.effective_start_date
        AND (p_record.p_effective_date + 2) < pee.effective_start_date
        AND (p_record.p_effective_date + 1) BETWEEN piv.effective_start_date AND piv.effective_end_date
        AND (p_record.p_effective_date + 1) BETWEEN pet.effective_start_date AND pet.effective_end_date
        AND (p_record.p_effective_date + 1) BETWEEN pel.effective_start_date AND pel.effective_end_date;

        IF l_count > 0 THEN
           RETURN (TRUE);
        ELSE
           RETURN (FALSE);
        END IF;

    ELSIF p_validation_mode = 'ALREADY_NEW' THEN
        SELECT
            peev.screen_entry_value INTO l_result
                FROM
                pay_element_entries_f pee,
                pay_element_entry_values_f peev,
                pay_input_values_f piv,
                pay_element_types_f pet,
                pay_element_links_f pel,
                per_assignments_f pa
                WHERE
                pee.element_entry_id = peev.element_entry_id
            AND piv.input_value_id = peev.input_value_id
            AND piv.name = p_record.name
            AND pee.element_entry_id = p_record.element_entry_id
            AND piv.input_value_id = p_record.input_value_id
            AND piv.input_value_id = peev.input_value_id
            AND pet.element_name = 'ZA_Tax'
            AND pel.element_type_id = pet.element_type_id
            AND pee.element_link_id = pel.element_link_id
            AND pa.assignment_id = pee.assignment_id
            AND (p_record.p_effective_date - 1) BETWEEN peev.effective_start_date AND peev.effective_end_date
            AND (p_record.p_effective_date - 1) BETWEEN pee.effective_start_date AND pee.effective_end_date
            AND (p_record.p_effective_date - 1) BETWEEN piv.effective_start_date AND piv.effective_end_date
            AND (p_record.p_effective_date - 1) BETWEEN pet.effective_start_date AND pet.effective_end_date
            AND (p_record.p_effective_date - 1) BETWEEN pel.effective_start_date AND pel.effective_end_date
            AND (p_record.p_effective_date - 1) BETWEEN pa.effective_start_date AND pa.effective_end_date;

         IF p_record.screen_entry_value IS NULL OR
                    NVL(l_result,'x') = NVL(p_record.screen_entry_value,'x') THEN
                RETURN (FALSE);
         ELSE
                RETURN (TRUE);
         END IF;
    ELSIF p_validation_mode = 'DELETE_NEXT_CHANGE' THEN
         /* Bug 5956650
         to check if there exists an element_entry row (which we intend to rollback)
         after the current row*/
         select ee.effective_start_date,
                ee.effective_end_date
         into   l_current_eff_start_date,
                l_current_eff_end_date
         from   pay_element_entries_f ee,
            pay_element_links_f el,
            pay_element_types_f et,
            pay_element_classifications ec
         where  ee.element_entry_id = p_record.element_entry_id
           and  el.element_link_id = ee.element_link_id
           and  et.element_type_id = el.element_type_id
           and  ec.classification_id = et.classification_id
           and  p_record.p_effective_date between ee.effective_start_date
                               and ee.effective_end_date
           and  p_record.p_effective_date between el.effective_start_date
                               and el.effective_end_date
           and  p_record.p_effective_date between et.effective_start_date
                               and et.effective_end_date;

         select count(ee.effective_end_date)
         into   l_count
         from   pay_element_entries_f ee
         where  ee.element_entry_id = p_record.element_entry_id
           and  ee.effective_start_date > l_current_eff_end_date;

        IF l_count > 0 THEN
           RETURN TRUE;
        ELSE
           RETURN FALSE;
        END IF;
    END IF;

END entry_valid;

/* This procedure updates the record that is passed in as a parameer. */

PROCEDURE update_this_record
          (
           p_one_record  Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE,
           p_new_value   VARCHAR2,
           p_update_mode VARCHAR2
          )
AS
BEGIN
    hr_utility.set_location('Update_this_record ',10);
    hr_entry_api.update_element_entry
                 (
                  p_dt_update_mode   => p_update_mode,
                  p_session_date     => p_one_record.p_effective_date + 1,
                  p_element_entry_id => p_one_record.element_entry_id,
                  p_input_value_id1  => p_one_record.input_value_id,
                  p_entry_value1     => p_new_value
                 );

END update_this_record;

/* This procedure updates the PAY_ZA_TYS_PROCESSES table to ensure that
   the process will not be run for the same payroll and the same tax year.*/

PROCEDURE update_tysp_table
          (
           p_payroll  NUMBER,
           p_tax_year NUMBER
          )
AS
BEGIN
    INSERT INTO pay_za_tys_processes (
      TYSP_ID
    , PAYROLL_ID
    , CONSOLIDATION_SET_ID
    , TAX_YEAR
    )
    VALUES
    (
     pay_za_tys_processes_s.NEXTVAL,
     p_payroll,
     0,
     p_tax_year
    );

END update_tysp_table;

/* This procedure deletes the PAY_ZA_TYS_PROCESSES table to indicate that the
   TYSP process was rolled back for this specific payroll.  In other words if
   the user wants to run the process for this payroll, he will be allowed to. */

PROCEDURE delete_tysp_table
          (
           p_payroll  NUMBER,
           p_tax_year NUMBER
          )
AS
BEGIN

    DELETE FROM pay_za_tys_processes
    WHERE  payroll_id = p_payroll
    AND    tax_year = p_tax_year;

END delete_tysp_table;

/* This function determines if the payroll can be rolled back */

FUNCTION payroll_rollbackable
         (
          p_payroll  NUMBER,
          p_tax_year NUMBER
         )
RETURN BOOLEAN
AS
    l_result NUMBER;

BEGIN
    SELECT
        COUNT(tysp_id) INTO l_result
    FROM
        pay_za_tys_processes
    WHERE
        payroll_id = p_payroll
    AND tax_year = p_tax_year;

    IF l_result > 0 THEN
           RETURN (TRUE);
        ELSE
           RETURN (FALSE);
        END IF;

END payroll_rollbackable;

/* This function returns the original value of a record */

FUNCTION get_original_value
         (
          p_record Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE
         )
RETURN VARCHAR2
AS

    l_result VARCHAR2(60);

BEGIN
    SELECT
        peev.screen_entry_value INTO l_result
    FROM
                pay_element_entries_f pee,
                pay_element_entry_values_f peev,
                pay_input_values_f piv,
                pay_element_types_f pet,
                pay_element_links_f pel,
                per_assignments_f pa
    WHERE
                pee.element_entry_id = peev.element_entry_id
        AND     piv.input_value_id = peev.input_value_id
        AND     piv.name = p_record.name
        AND     pee.element_entry_id = p_record.element_entry_id
        AND     piv.input_value_id = p_record.input_value_id
        AND     piv.input_value_id = peev.input_value_id
        AND     pet.element_name = 'ZA_Tax'
        AND     pel.element_type_id = pet.element_type_id
        AND     pee.element_link_id = pel.element_link_id
        AND     pa.assignment_id = pee.assignment_id
        AND     (p_record.p_effective_date - 1) BETWEEN peev.effective_start_date AND peev.effective_end_date
        AND     (p_record.p_effective_date - 1) BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     (p_record.p_effective_date - 1) BETWEEN piv.effective_start_date AND piv.effective_end_date
        AND     (p_record.p_effective_date - 1) BETWEEN pet.effective_start_date AND pet.effective_end_date
        AND     (p_record.p_effective_date - 1) BETWEEN pel.effective_start_date AND pel.effective_end_date
        AND     (p_record.p_effective_date - 1) BETWEEN pa.effective_start_date AND pa.effective_end_date;

    RETURN (l_result);

END get_original_value;

/* This procedure rolls back one record, depending on its state */

PROCEDURE rollback_this_record
         (
          p_record   Pay_Za_Tax_Year_Start_Pkg.c_entry_details%ROWTYPE
         )
AS

    l_original_value VARCHAR2(60);

BEGIN
     hr_utility.set_location('Pay_Za_Tax_Year_Start_Pkg.rollback_this_record ',10);
     IF NOT entry_valid(p_record,'ALREADY_NEW') THEN
        IF entry_valid(p_record,'FUTURE_CHANGE') THEN
           hr_utility.set_location('Future Change ',10);
           l_original_value := get_original_value(p_record);
           update_this_record
             (
              p_record,
              l_original_value,
              'CORRECTION'
             );
         ELSE
           /*Bug 5956650
           before calling hr_entry_valid.delete_element_entry check
           if there exists another element_entry row (Next change which we intend to delete)
           after the current row
           */
           IF entry_valid(p_record,'DELETE_NEXT_CHANGE') THEN
              hr_utility.set_location('Delete Next Change  ',20);
              hr_entry_api.delete_element_entry
                        (
                         p_dt_delete_mode   => 'DELETE_NEXT_CHANGE',
                         p_session_date     => p_record.p_effective_date - 1,
                         p_element_entry_id => p_record.element_entry_id
               );
            END IF;
         END IF;
     END IF;

END rollback_this_record;

END Pay_Za_Update_Pkg;

/
