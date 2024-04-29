--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_SALARY" AS
/* $Header: hriodsal.pkb 115.3 2003/04/02 15:07:48 jtitmas noship $ */


/******************************************************************************/
/* This function will return the previous salary proposal of a given          */
/* pay_proposal_id, it is called from the Oracle Internal workbooks that      */
/* display previous salary.                                                   */
/*                                                                            */
/* The function was found to be the most performant way of returning an       */
/* employees previous salary proposal amount for a given employees            */
/* pay_proposal_id.                                                           */
/******************************************************************************/
FUNCTION get_prev_salary_pro_amount(p_pay_proposal_id   NUMBER)
                RETURN NUMBER IS

  CURSOR cur_get_prev_sal(cp_pay_proposal_id number) is
  SELECT
    asg.assignment_number assignment_number
  , pro.proposed_salary_n salary_amount
  , ppb.pay_annualization_factor annualization_factor
  , ppb.pay_annualization_factor * pro.proposed_salary_n annual_salary
  FROM per_assignments_f asg /* Secure */
  , per_pay_bases ppb
  , per_pay_proposals pro
  , per_pay_proposals pro_next
  , pay_input_values_f piv
  , pay_element_types_f pet
  , pay_payrolls_f pay /* Secure */
  WHERE
/* Joins inc. date joins */
      pro.assignment_id = asg.assignment_id
  AND pro.change_date BETWEEN asg.effective_start_date
                      AND asg.effective_end_date
/* only show people who have a salary */
  AND asg.pay_basis_id = ppb.pay_basis_id
/* Next Pay proposal to get date */
  AND pro.assignment_id = pro_next.assignment_id
  AND pro.change_date = pro_next.last_change_date
/* Element entry types and currencies */
  AND ppb.input_value_id = piv.input_value_id
  AND piv.element_type_id = pet.element_type_id
  AND pro.change_date BETWEEN pet.effective_start_date
                      AND pet.effective_end_date
/* Payrolls and periods */
  AND asg.payroll_id = pay.payroll_id
  AND pro.change_date BETWEEN pay.effective_start_date
                      AND pay.effective_end_date
  AND pro_next.pay_proposal_id = cp_pay_proposal_id;

  l_cur_rec cur_get_prev_sal%ROWTYPE;

  l_annual_salary  number := 0;

BEGIN

  OPEN cur_get_prev_sal(p_pay_proposal_id);
  FETCH cur_get_prev_sal INTO l_cur_rec;

  l_annual_salary := l_cur_rec.annual_salary;

  CLOSE cur_get_prev_sal;

  RETURN(l_annual_salary);

EXCEPTION
    WHEN OTHERS THEN
  IF cur_get_prev_sal%ISOPEN THEN
    CLOSE cur_get_prev_sal;
  END IF;

  RETURN(l_annual_salary);

END get_prev_salary_pro_amount;


/******************************************************************************/
/* Gets the annual salary for an assignment on a given date                   */
/******************************************************************************/
FUNCTION get_annual_salary_as_of_date(p_effective_date    DATE
                                     ,p_assignment_id     NUMBER)
          RETURN NUMBER IS

  cursor cur_get_ann_sal(cp_effective_date date,cp_assignment_id number) IS
  select annual_salary
  from HRIFV_SAL_PRO
  where assignment_id = cp_assignment_id
  and   cp_effective_date between effective_from_date and effective_to_date_nn;

  l_annual_salary number :=0;

BEGIN

   open cur_get_ann_sal(p_effective_date, p_assignment_id);
   fetch cur_get_ann_sal into l_annual_salary;
   close cur_get_ann_sal;

   return(l_annual_salary);

EXCEPTION
   WHEN OTHERS THEN
    IF cur_get_ann_sal%ISOPEN THEN
       close cur_get_ann_sal;
    END IF;

     return(l_annual_salary);

END get_annual_salary_as_of_date;

/******************************************************************************/
/* Converts currency amount using a specified precision and default rate type */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_precision        IN NUMBER)
            RETURN NUMBER IS

  l_converted_amount    NUMBER;

BEGIN

  l_converted_amount := hri_bpl_currency.convert_currency_amount
          (p_from_currency        => p_from_currency
          ,p_to_currency          => p_to_currency
          ,p_conversion_date      => p_conversion_date
          ,p_amount               => p_amount
          ,p_precision            => p_precision);

  RETURN l_converted_amount;

END convert_currency_amount;

/******************************************************************************/
/* Converts a currency amount given a rate type                               */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_rate_type        IN VARCHAR2)
            RETURN NUMBER IS

  l_converted_amount    NUMBER;

BEGIN

  l_converted_amount := hri_bpl_currency.convert_currency_amount
          (p_from_currency        => p_from_currency
          ,p_to_currency          => p_to_currency
          ,p_conversion_date      => p_conversion_date
          ,p_amount               => p_amount
          ,p_rate_type            => p_rate_type);

  RETURN l_converted_amount;

END convert_currency_amount;

/******************************************************************************/
/* Converts a currency amount using a default rate type                       */
/******************************************************************************/
FUNCTION convert_currency_amount(p_from_currency      IN VARCHAR2,
                                 p_to_currency        IN VARCHAR2,
                                 p_conversion_date    IN DATE,
                                 p_amount             IN NUMBER)
            RETURN NUMBER IS  l_converted_amount    NUMBER;

BEGIN

  l_converted_amount := hri_bpl_currency.convert_currency_amount
          (p_from_currency        => p_from_currency
          ,p_to_currency          => p_to_currency
          ,p_conversion_date      => p_conversion_date
          ,p_amount               => p_amount);

  RETURN l_converted_amount;

END convert_currency_amount;

END hri_oltp_disc_salary;

/
