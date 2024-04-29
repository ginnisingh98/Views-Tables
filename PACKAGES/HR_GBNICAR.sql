--------------------------------------------------------
--  DDL for Package HR_GBNICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GBNICAR" AUTHID CURRENT_USER as
/* $Header: pygbnicr.pkh 115.1 99/07/17 06:08:16 porting shi $ */
--
/*
/* Name                : NICAR_CLASS1A_YTD
 Parameters          : Period end date - the end date of the payroll period
                       Termination date - The employment termination date for the employee
                       Assignment ID -
                       Element Type ID - The ID for either 'NI Car Primary' or 'NI Car Secondary'
 Values Returned     : NI Class1A Year-to-date - The Summed NI Class1A
                                               for all Cars allocated to the employee (Pro-rata)
 Description         : Returns the summed NI Class1A employer's liability for the given
                       assignment ID from the start of the tax year to either the current period end date
                       or the employee's termination date, whichever is the earlier
*/
  function nicar_class1a_ytd
     (p_business_group_id number,
      p_assignment_id  number,
      p_element_type_id  number,
      p_end_of_period_date  date,
      p_term_date  date
     )
      return number ;
--
--
/*
 Name                : NICAR_DAYS_BETWEEN
 Parameters          : Start date
                       End date
 Values Returned     : Days between the two input dates, ignoring 29-Feb
 Description         : Returns the number of days between the two input dates. If 29-Feb appears
                       between them, then 1 is subtracted from the normal result
*/
  function nicar_days_between
     (p_start_date  date,
      p_end_date  date)  return number ;
--
--
/*
 Name                : NICAR_PAYMENT_YTD
 Parameters          : Period end date - the end date of the payroll period
                       Termination date - The employment termination date for the employee
                       Assignment ID -
                       Element Type ID - The ID for either 'NI Car Primary' or 'NI Car Secondary'
 Values Returned     : NI Class1A Year-to-date - The Summed NI Class1A
                                               for all Cars allocated to the employee (Pro-rata)
 Description         : Returns the summed employee contributions for private use of a company car for
                       the given assignment ID from the start of the tax year to either the current
                       period end date or the employee's termination date, whichever is the earlier
*/
--
  function nicar_payment_ytd
     (p_assignment_id  number,
      p_element_type_id  number,
      p_end_of_period_date  date,
      p_term_date  date
     )
      return number;
--
--
/*
 Name                : NICAR_SESSION_DATE
 Parameters          : Dummy (Number) Not used
 Values Returned     : Session date
 Description         : Returns the session date for the calling session
*/
--
  function nicar_session_date
    (p_dummy number)
     return date;
--
--
/*
 Name                : UK_TAX_YR_START
 Parameters          : Input date
 Values Returned     : Tax year start date
 Description         : Returns the start date of the tax year wherein lies the input date
*/
--
  function uk_tax_yr_start
     (p_input_date  date) return date;
--
  pragma restrict_references (uk_tax_yr_start, WNDS, WNPS);
--
/*
 Name                : UK_TAX_YR_END
 Parameters          : Input date
 Values Returned     : Tax year end date
 Description         : Returns the end date of the tax year wherein lies the input date
*/
--
  function uk_tax_yr_end
     (p_input_date  date) return date;
--
  pragma restrict_references (uk_tax_yr_end, WNDS, WNPS);
--
/*
 Name                : NICAR_NIABLE_VALUE
 Parameters          : Price                       - List price of car when new
                       Price Max                   - Price cap for car benefit purposes
                       Price Benefit               - Fraction of (capped) price for car
                                                     benefit purposes
                       Mileage factor              - Range of business mileage for full tax year
                       Primary/Secondary Indicator - Primary or secondary car
                       Registration date           - Date car was registered
                       Fuel Scale charge           - Scale charge for private fuel in company car
                       Annual Payment              - Total payment made by employee in full
                                                     tax year for private use of company car
 Values Returned     : NI-able value of car benefit
 Description         : Returns the NI-able value of a car benefit (1994/95 legislation)
                       for the given input parameters listed above.
*/
--
  function nicar_niable_value
     (p_price  number,
      p_price_cap  number,
      p_mileage_factor  number,
      p_pri_sec_ind  char,
      p_reg_date  date,
      p_fuel_scale  number,
      p_ann_payment  number,
      p_start_date  date,
      p_end_date  date,
      p_tax_end_date  date) return number ;
--
end hr_gbnicar;

 

/
