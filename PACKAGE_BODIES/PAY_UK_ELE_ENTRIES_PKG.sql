--------------------------------------------------------
--  DDL for Package Body PAY_UK_ELE_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UK_ELE_ENTRIES_PKG" as
/* $Header: pygbeent.pkb 120.0.12010000.2 2009/05/12 12:12:20 jvaradra ship $ */
--
/*==========================================================================+
  |               Copyright (c) 1993 Oracle Corporation                       |
  |                  Redwood Shores, California, USA                          |
  |                       All rights reserved.                                |
  +===========================================================================+
 Name
    pay_uk_ele_entries_pkg
  Purpose
    Supports the PAYE block in the NI block in the form PAYGBTAX.
  Notes

  History
   19-AUG-94  H.Minton        40.0    Date created.
   05-MAY-95  M.Roychowdhury  40.1    Changed to use explicit cursors
                                      and added error message for missing formulas
   14-JAN-97  T.Inekuku       40.5    Included new I. Value in update to
                                      NI procedure.
   06-OCT-00  G.Butler	      115.1   Updated call to hr_entry_api.update_element_entry
   				      in update_paye_entries to include x_entry_information1,
   				      x_entry_information2, x_entry_information_category
   06-JUN-02  K.Thampan       115.2   Updated the procedure update_ni_entries to
                                      update the elment entry twice, but the second update
                                      use start date of the next period.
   10-Jun-02  K.Thampan       115.3   Add dbdrv command
   17-Jul-02  K.Thampan       115.4   Update the procedure update_ni_entries so that it will
                                      reset the process type to 'Normal' if the entry type
                                      is Irregular Periods or Multiple Periods
   19-Jul-02  K.Thampan       115.5   Force the second update_ni_entires to use
                                      UPDATE mode
   24-Jan-03  M.Ahmad         115.6   Added NOCOPY
   19-Feb-03  A.Sengar        115.8   Added one condition in the select statement of the
                                      PROCEDURE update_ni_entries.
   11-May-09  jvaradra        115.9   For bug 8485686
                                      Variable pqp_gb_ad_ee.g_global_paye_validation is
						  intialized to 'N' and reset to 'Y' in the end
==============================================================================*/
-----------------------------------------------------------------------------
-- Name                                                                    --
--   update_paye_entries                                                   --
-- Purpose                                                                 --
--   calls the hr_element_entry_api to perform updates to the PAYE element.--
-----------------------------------------------------------------------------
--
PROCEDURE update_paye_entries(
                            x_dt_update_mode     varchar2,
                            x_session_date       date,
                            x_element_entry_id   number,
                            x_input_value_id1    number,
                            x_entry_value1       varchar2,
                            x_input_value_id2    number,
                            x_entry_value2       varchar2,
                            x_input_value_id4    number,
                            x_entry_value4       varchar2,
                            x_input_value_id5    number,
                            x_entry_value5       varchar2,
                            x_input_value_id3    number,
                            x_entry_value3       varchar2,
                            x_input_value_id6    number,
                            x_entry_value6       varchar2,
                            x_entry_information1 varchar2,
                            x_entry_information2 varchar2,
                            x_entry_information_category varchar2,
                            p_effective_end_date in out nocopy date)
 IS
--
       l_effective_end_date DATE;

       BEGIN

            -- For bug 8485686
		pqp_gb_ad_ee.g_global_paye_validation := 'N';

           hr_entry_api.update_element_entry
             (p_dt_update_mode       => x_dt_update_mode,
              p_session_date         => x_session_date,
              p_element_entry_id     => x_element_entry_id,
              p_input_value_id1      => x_input_value_id1,
              P_entry_value1         => x_entry_value1,
              p_input_value_id2      => x_input_value_id2,
              P_entry_value2         => x_entry_value2,
              p_input_value_id3      => x_input_value_id3,
              P_entry_value3         => x_entry_value3,
              p_input_value_id4      => x_input_value_id4,
              P_entry_value4         => x_entry_value4,
              p_input_value_id5      => x_input_value_id5,
              P_entry_value5         => x_entry_value5,
              p_input_value_id6      => x_input_value_id6,
              P_entry_value6         => x_entry_value6,
              P_entry_information1   => x_entry_information1,
              P_entry_information2   => x_entry_information2,
              P_entry_information_category => x_entry_information_category);


            -- For bug 8485686
		pqp_gb_ad_ee.g_global_paye_validation := 'Y';

         select e.effective_end_date
         into   l_effective_end_date
         from pay_element_entries_f e
         where e.element_entry_id = x_element_entry_id
         and   x_session_date between e.effective_start_date and
                                      e.effective_end_date;

          p_effective_end_date := l_effective_end_date;

       END update_paye_entries;
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_paye_formula_id                                                   --
-- Purpose                                                                 --
--   this function finds the formula id for the validation of the PAYE     --
--   tax_code element entry value.
-----------------------------------------------------------------------------
--
FUNCTION get_paye_formula_id RETURN NUMBER IS

  cursor c_formula is
   select f.FORMULA_ID
   from   ff_formulas_f f,
          ff_formula_types t
   where  t.FORMULA_TYPE_ID   = f.FORMULA_TYPE_ID
     and    t.FORMULA_TYPE_NAME = 'Element Input Validation'
     and    f.FORMULA_NAME      = 'TAX_CODE';
--
  l_formula_id	NUMBER;
--
BEGIN
--
  open c_formula;
  fetch c_formula into l_formula_id;
  if c_formula%notfound then
  --
    close c_formula;
    --
    fnd_message.set_name ('FF', 'FFX03A_FORMULA_NOT_FOUND');
    fnd_message.set_token ('1','TAX_CODE');
    fnd_message.raise_error;
    --
  end if;
  close c_formula;
  --
  RETURN l_formula_id;
--
END get_paye_formula_id;

-----------------------------------------------------------------------------
-- Name                                                                    --
--   update_ni_entries                                                     --
-- Purpose                                                                 --
--   calls the hr_element_entry_api to perform updates to the NI element.  --
-----------------------------------------------------------------------------
--
PROCEDURE update_ni_entries(
                            x_dt_update_mode     varchar2,
                            x_session_date       date,
                            x_element_entry_id   number,
                            x_input_value_id1    number,
                            x_entry_value1       varchar2,
                            x_input_value_id2    number,
                            x_entry_value2       varchar2,
                            x_input_value_id3    number,
                            x_entry_value3       varchar2,
                            x_input_value_id4    number,
                            x_entry_value4       varchar2,
                            x_input_value_id5    number,
                            x_entry_value5       varchar2,
                            x_input_value_id6    number,
                            x_entry_value6       varchar2,
                            x_input_value_id7    number,
                            x_entry_value7       varchar2,
                            x_input_value_id8    number,
                            x_entry_value8       varchar2,
                            P_effective_end_date IN OUT NOCOPY DATE)  IS
--

    l_effective_end_date DATE;
    l_payroll_id         NUMBER;
    l_start_date         DATE;

       BEGIN
           hr_entry_api.update_element_entry
             (p_dt_update_mode       => x_dt_update_mode,
              p_session_date         => x_session_date,
              p_element_entry_id     => x_element_entry_id,
              p_input_value_id1      => x_input_value_id1,
              P_entry_value1         => x_entry_value1,
              p_input_value_id2      => x_input_value_id2,
              P_entry_value2         => x_entry_value2,
              p_input_value_id3      => x_input_value_id3,
              P_entry_value3         => x_entry_value3,
              p_input_value_id4      => x_input_value_id4,
              P_entry_value4         => x_entry_value4,
              p_input_value_id5      => x_input_value_id5,
              P_entry_value5         => x_entry_value5,
              p_input_value_id6      => x_input_value_id6,
              P_entry_value6         => x_entry_value6,
              p_input_value_id7      => x_input_value_id7,
              P_entry_value7         => x_entry_value7,
              p_input_value_id8      => x_input_value_id8,
              P_entry_value8         => x_entry_value8
           );

        /*****************************************/
        /* Bug 2391897 -- see readme for details */
        /*****************************************/
        if (x_entry_value5 = 'Irregular Periods') OR (x_entry_value5 = 'Multiple Periods') Then
           select ppf.payroll_id
           into   l_payroll_id
           from   pay_payrolls_f         ppf,
                  per_assignments_f      paf,
                  pay_element_entries_f  peef
           where  peef.element_entry_id = x_element_entry_id
             and  x_session_date between peef.effective_start_date and peef.effective_end_date
             and  peef.assignment_id = paf.assignment_id
             and  x_session_date between paf.effective_start_date and paf.effective_end_date
             --BUG 2791911 Added one more condition
             and  x_session_date between ppf.effective_start_date and ppf.effective_end_date
             and  paf.payroll_id = ppf.payroll_id;

           select ptp.start_date
           into   l_start_date
	   from   per_time_periods ptp
           where  ptp.payroll_id =  l_payroll_id
             and  ptp.start_date > x_session_date
             and  rownum = 1;

            hr_entry_api.update_element_entry
             (p_dt_update_mode       => 'UPDATE',
              p_session_date         => l_start_date,
              p_element_entry_id     => x_element_entry_id,
              p_input_value_id1      => x_input_value_id1,
              P_entry_value1         => x_entry_value1,
              p_input_value_id2      => x_input_value_id2,
              P_entry_value2         => x_entry_value2,
              p_input_value_id3      => x_input_value_id3,
              P_entry_value3         => x_entry_value3,
              p_input_value_id4      => x_input_value_id4,
              P_entry_value4         => x_entry_value4,
              p_input_value_id5      => x_input_value_id5,
              P_entry_value5         => 'Normal',
              p_input_value_id6      => x_input_value_id6,
              P_entry_value6         => 0,
              p_input_value_id7      => x_input_value_id7,
              P_entry_value7         => x_entry_value7,
              p_input_value_id8      => x_input_value_id8,
              P_entry_value8         => x_entry_value8
           );
         end if;

         select e.effective_end_date
         into   l_effective_end_date
         from pay_element_entries_f e
         where e.element_entry_id = x_element_entry_id
         and   x_session_date between e.effective_start_date and
                                      e.effective_end_date;
--
         p_effective_end_date := l_effective_end_date;
--
       END update_ni_entries;
--
-----------------------------------------------------------------------------
END PAY_UK_ELE_ENTRIES_PKG;

/
