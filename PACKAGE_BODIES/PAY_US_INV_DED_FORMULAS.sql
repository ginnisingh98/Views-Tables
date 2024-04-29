--------------------------------------------------------
--  DDL for Package Body PAY_US_INV_DED_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_INV_DED_FORMULAS" AS
/* $Header: pyusgrfm.pkb 120.33.12010000.21 2010/01/22 11:08:17 nkjaladi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_inv_ded_formulas

    Description : This package is used by fast formulas of involuntary
                  deduction elements to calculate deduction amounts.
                  Different functions cater to different categories of
                  involuntary deduction.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-APR-2004 sdahiya    115.0            Created.
    12-MAY-2004 sdahiya    115.1            Modified phase to plb.
    17-MAY-2004 sdahiya    115.2   3622290  Added fnd_date.canonical_to_date
                                            while converting varchar to date.
    18-MAY-2004 sdahiya    115.3   2658290, - Moved dedn amount calculation
                                   1481913,   from cal_formula_bo to
                                              base_formula.
                                   2992741  - Enabled proration rules fori
                                              cal_formula_bo.
                                            - Modified proration algorithm
                                              so that current
                                              support orders are prorated
                                              before the arrears.
                                            - Modified usage of global
                                              variables as PL/SQL tables
                                              instead of scalar variables.
    01-JUN-2004 sdahiya    115.4   3549207  - Removed VOLDEDNS_AT_WRIT
                                              and VOL_DEDNS_ASG_GRE_LTD
                                              parameters from BASE_FORMULA.
    17-JUN-2004 kvsankar   115.5   3692468  Removed the check for
                                            days_in_arrears
                                            from CAL_FORMULA_SS
    22-JUN-2004 kvsankar   115.6   3704744  Modified CAL_FORMULA_SS to
                                            use the overriden Proration
                                            rule instead of the seeded
                                            rule(if overriden).
    28-JUN-2004 kvsankar   115.7   3715182  Included a new cursor
                                             c_garn_max_fee_amt in
                                   3719168  CAL_FORMULA_SS and
                                            CAL_FORMULA_BO to set the
                                   3722152  value of GARN_FEE_MAX_FEE_AMOUNT
                                            to 99999999 if the it is defaulted
                                            to ZERO in the formula.
                                            File Arch in for KVSANKAR by
                                            djoshi
    29-JUN-2004 kvsankar   115.8   3718454  Added 1 to the calculation of
                                            garn_days as the both
                                            PAY_EARNED_END_DATE and VF_DATE_SERVED
                                            should be included for calculating
                                            the STOP_ENTRY value
    30-JUN-2004 kvsankar   115.9   3718454  Added a new IF condition to check
                                   3734415  whether deduction amount needs to
                                            taken if the Ending payroll was skipped
                                            in cases where Max Withholding days
                                            comes into picture.
    30-JUN-2004 kvsankar   115.10           Added code for deleting the Global
                                            tables once an Employee is processed.
    02-JUL-2004 kvsankar   115.11  1481913  Removed the STOP_ENTRY = 'Y' from the
                                            solution earlier provided for 1481913.
    06-JUL-2004 kvsankar   115.12  3734557  Added the condition so that Proration
                                            rules are applied only if DI is less.
    08-JUL-2004 kvsankar   115.13  3749162  Rewrote the IF condition checking
                                            for Monthly_Cap_Amount <> 0 and
                                            Period_Cap_Amount <> 0 in
                                            CAL_FORMULA_TL
                                            Created a new procedure 'RESET_GLOBAL_VAR'
                                            for the deletion of Global tables and
                                            for resetting Global variables to NULL.
                                   2992741  Modified the calculation of DI for
                                            arrears in case of Child Support
                                            elements. Also added an IF condition
                                            to set FEE to ZERO in case of Proration.
    08-JUL-2004 kvsankar   115.14  2992741  Added an IF condition to take arrears
                                            only if VF_DI_SUBJ_ARR > 0.
    08-JUL-2004 kvsankar   115.15  3737081  Modified the IF condition in function
                                            CAL_FORMULA_BO to correctly calculate
                                            the value of DI_state_exemption_amt
    20-JUL-2004 kvsankar   115.16  3777900  Removed '=' sign from the fix
                                            for 3718454
    08-NOV-2004 kvsankar   115.17  3549298  Made changes for Initial Fee Flag
                                            No Initial fee is taken if the
                                            Initial Fee Flag is set.
    09-DEC-2004 kvsankar   115.18  3650283  Added paramters to BASE_FORMULA
                                            and CAL_FORMULA_BO for DCIA category.
    20-DEC-2004 kvsankar   115.19  4072103  Modified the calculation of the amount
                                            to be deducted for each element in the
                                            BASE_FORMULA
                                   4079142  Removed calculation of State Exempt
                                            amount for DCIA as it is a Federal
                                            Level deduction.
                                            Modified the code to not to calculate
                                            fees for DCIA.
                                            Added Cdde to limit DCIA to 25% of
                                            of disposable income if we have DCIA
                                            along with Support or Other Elements
    31-JAN-2005 kvsankar   115.21  4143803  Added code to correctly default
                                            Allowances and Filing Status if
                                            defaulted in the BALANCE_SETUP
                                            formula for Tax Levy Category
    03-FEB-2005 kvsankar   115.22           Introduced a new function
                                            GET_CCPA_PROTECTION for the
                                            calculation of CCPA Protection value.
    03-FEB-2005 kvsankar   115.23  4145789  Modified the code to override the
                                            CCPA Protection value if the
                                            Exemption percenatge overridden makes
                                            the DI value to be more than CCPA
                                            value.
    04-FEB-2005 kvsankar   115.24  4145789  Modified the comment.
    18-FEB-2005 kvsankar   115.25  4154950  Modified the BASE_FORMULA definition
                                            to use _ASG dimension instead of _ASG_GRE
                                            becuase of the the Bug fix made to the
                                            'BALANCE_SETUP_FORMULA' for all categories.
                                            The following are the parameters modified: -
                                              i. ACCRUED_ASG_GRE_LTD
                                             ii. ACCRUED_FEES_ASG_GRE_LTD
                                            iii. ASG_GRE_MONTH
                                             iv. ASG_GRE_PTD
                                            The formula text is also modified to use
                                            the corresponding new paramter name.
    24-FEB-2005 kvsankar   115.26  4107302  Commented the code that sets STOP_ENTRY
                                            based on the Termination Status of
                                            Employee. The reason being Involuntary
                                            Deduction elements are subjected to
                                            Severance payments too.
    03-MAR-2005 kvsankar   115.27  4104842  Modified the BASE_FORMULA to calculate
                                            Gross Earnings that is later used to
                                            calculate Tax Levy.
                                   4234046  Added code to set the Fee Amount to
                                            ZERO when no deduction is taken.
    16-MAR-2005 kvsankar   115.28   NILL    Modified the code where there is an
                                            NVL condition using 0 to use
                                            'default_number' for the same.
    04-APR-2005 kvsankar   115.29  3800845  Modified the cursor 'csr_get_ovrd_values'
                                            and 'csr_exmpt_ovrd' to use 'Date
                                            Earned' instead of 'Start Date'.
    13-JUN-2005 kvsankar   115.30  4318944  Modified the Federal and State Exemption
                                            calculation part for Hawaii State
    18-AUG-2005 kvsankar   115.31  3528349  Modified the formula CAL_FORMULA_TL
                                            for getting the Fed Exemption
                                            amounts based on the overridden
                                            Year specified.
    14-NOV-2005 kvsankar   115.32  4556146  Changes made to CAL_FORMULA_BO
                                            for the amendments made to Illinois
                                            Garnishment law
    29-NOV-2005 kvsankar   115.33  4758841  We default value of GLB_ALLOWS to
                                              i. '1' if Filing Status was
                                                 defaulted too
                                             ii. '0' if Filing Status was
                                                 not defaulted
    08-DEC-2005 kvsankar   115.34  4710692  Modified the IF condition that
                                            defaults GLB_ALLOWS
    12-DEC-2005 kvsankar   115.35  4881680  Modified the way PL/SQL tables
                                            are accessed for performance
    16-DEC-2005 kvsankar   115.36  4748532  Modified the package to correctly
                                            deduct garnishment when the Fast
                                            Formula is modified by customer to
                                            look into PTD values
    20-DEC-2005 kvsankar  115.37   4748532  Modifed the package for the above
                                            multiple payment garnishment
    06-JAN-2006 kvsankar  115.38   4858720  Modified the caluclation for all
                                            Involuntary Deduction elements to
                                            take 'EIC Advance' into account
    19-JAN-2006 kvsankar  115.39   4924454  Modified CAL_FORMULA_TL to
                                            take no deduction when Net Salary
                                            is Negative.
    15-Feb-2006 kvsankar  115.40   4309544  Modified the formula
                                            CAL_FORMULA_BO to take fees during
                                            Proration only if 'Take Fee On
                                            Proration' checkbox is checked.
    17-Mar-2006 kvsankar  115.41   5098366  Added NVL condition to make Exemption
                                            Override work
                                   5095823  Added a new Global variable
                                            GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN
                                            to sum up the Support Fees
    07-APR-2006 kvsankar  115.42   4858720  Added a new parameter 'EIC_ADVANCE_ASG_GRE_RUN'
                                            to BASE_FORMULA
    12-APR-2006 kvsankar  115.43   5149450  Added a new global variable
                                            'GLB_AMT_NOT_SPEC' for correctly
                                            calculating Arrears balance value
                                            when no amount is specified
    17-APR-2006 kvsankar  115.44   5165704  Modified the code to use PL/SQL
                                            table values while calculating
                                            prorated amount in PRORATION section
    27-APR-2006 kvsankar  115.45   5189256  Modified the package to correctly
                                            deduct fees
    21-Jun-2006 sudedas   115.46   5150447  Modified CAL_FORMULA_BO to incorporate
                                            90% exemption of DI in case of Missouri Head of Household.
                                            Also added changes to keep Subject Disposable Income constant.
                                   5249037  Modified CAL_FORMULA_SS, replaced TOTAL_WITHHELD_FEE_ASG_GRE_ITD
                                            by vf_accrued_fees.
    11-Jul-2006 sudedas   115.47   5295813  Added Function GET_PRORATED_DEDN_AMOUNT and
                                            modified CAL_FORMULA_SS and RESET_GLOBAL_VAR
                                            for Proration Rule set to EQUAL.
    11-Aug-2006 sudedas   115.49   4676867  Added parameters VOL_DEDN_ROTH_ASG_GRE_RUN,
                                            VOL_DEDN_SB_TX_ASG_GRE_RUN,
                                            VOL_DEDN_SB_TX_JD_ASG_GRE_RUN INTO BASE_FORMULA,
                                            CAL_FORMULA_SS, CAL_FORMULA_BO and
                                            changed c_Balance_Subject_to_Garn .
                                   5111601  Modified CAL_FORMULA_TL to take care of
                                            Addl Exemption Amt for 65 Yr Old / Blind case.
    21-Sep-2006 sudedas   115.50            Modified CAL_FORMULA_TL (removed nvl from
                                            csr_get_blind_65_flag) .
    06-Dec-2006 sudedas   115.51   5688488  Restricting Garn Category to CD and G
                                            For 90% Exemption in Missouri HOH Issue.
    11-Dec-2006 sudedas   115.52   5706544  Commenting 90% exemption for Filing Status
                                            Code ('04') for State of Missouri.
    19-Dec-2006 sudedas   115.53   5672067  Modified BASE_FORMULA to add cursor to fetch
                                            Screen Entry Values for 'Amount' and 'Percentage'
                                            Input Value.
                                   5701665  cal_formula_bo in Modified for New York
                                            For Garn category Educational Loan.
    02-Feb-2007 sudedas   115.54            Reverting back the changes for Bug# 5672067
    05-Apr-2007 sudedas   115.55   5672067  Modified BASE_FORMULA to add cursor to fetch
                                            Screen Entry Value for 'Replace Amt' of SI Element.
    13-Apr-2007 sudedas   115.56            Added Assignment ID, dates join condition in
                                            the cursor c_get_Replace_Amount_val.
    07-Jun-2007 sudedas   115.57   6063353  Cal_Formula_BO Changed For Nebraska HOH
                                   6043168  Cal_Formula_SS Changed to stop dedn
                                            at Monthly Max with arrearage.
                                   6085139  Federal Minimum Wage Changed to $5.85
    20-Jun-2007 sudedas   115.58            Reverting Back Changes for Bug# 6085139
                                   5520471  Modified Function GET_GARN_LIMIT_MAX_DURATION
                                            to check Element Level Limit Rule Override.
                                   6132855  Federal Minimum Wage now stored in JIT Table.
                                            This is addressing Bug# 6085139 too.
    04-Jul-2007 sudedas   115.59   6140374  Corrected CAL_FORMULA_BO to remove Inconsistency.
    14-Jul-2007 sudedas   115.60            Changed GET_GARN_LIMIT_MAX_DURATION
                                            to add a check for Base Element instead of Calculator.
    27-Aug-2007 sudedas   115.61   6339209  Changed GET_GARN_LIMIT_MAX_DURATION
                                            to take care of Old Arch Elements.
                                   6068769  Modified cal_formula_bo for processing
                                            Multiple Educational Loans.
    19-sep-2007 sudedas   115.62   6194070  Change For Maine state Min Wage.
    31-MAR-2008 vmkulkar  115.64   6683994  Maine State Exemption amount changes
    31-MAR-2008 vmkulkar  115.65   6678760  Credit Debt Deduction amount changes for
					    Delaware
    31-MAR-2008 vmkulkar  115.66   6678760  Garnishment Deduction amount changes for
					    Delaware
    23-APR-2008 vmkulkar  115.67   6683994  Modified the user table name from
					    'Garnishment State Exemptions Table' to
					    'Wage Attach State Exemptions Table'
    23-APR-2008 vmkulkar  115.69   6678760  Garnishment Deduction amount changes for
					    Delaware
    31-Jul-2008 sudedas   115.70   6133337  Provided Flexibility to define Fed / State
                                            Min Wage Rule / Factor at Element Extra
                                            Information Level and use that to Override
                                            any Statutory (Fed / State) Rules.
                                   7268701  Added Colorado State Min Wage Change.
    19-Sep-2008 sudedas    115.71  6818016  Base_Formula and Cal_Formula_BO modified
                                            to pass 2 extra parameters NET_ASG_RUN
                                            and NET_ASG_PTD.
    27-Nov-2008 sudedas    115.72  7600041  Changed Cal_Formula_BO for Edu Loan.
    17-Dec-2008 sudedas    115.73  7596224  Changed Function Convert_Period_Type.
                                            Removed call to package hr_us_ff_udfs
    13-Jan-2008 sudedas    115.74  7589784  Changed Cal_Formula_BO for Bug 7589784
    15-Jan-2009 sudedas    115.75  7674615  Changed cal_formula_bo for multiple
                                            Educational Loan.
    10-Apr-2009 sudedas    115.76  8343866  Changed Cal_Formula_BO for Alaska.
    22-Jun-2009 sudedas    115.77  8556724  Modified RESET_GLOBAL_VAR.
    14-Aug-2009 asgugupt   115.78  8607790  Modified CAL_FORMULA_TL
    26-Aug-2009 asgugupt   115.79  8754824  Modified CAL_FORMULA_BO
    11-Sep-2009 asgugupt   115.81  8898635  Modified CAL_FORMULA_BO
    22-Sep-2009 asgugupt   115.82  8673016  Modified CAL_FORMULA_BO
    21-Jan-2010 nkjaladi   115.83  9284206  Modified CAL_FORMULA_BO for education
                                            loan deduction of Illinois state.
..****************************************************************************/

-- New Function added (Reference Bug# 5295813)
/****************************************************************************
    Name        : GET_PRORATED_DEDN_AMOUNT
    Description : This Function Prorates the Deduction Amount in case one or
                  more Actual Deduction Amount expects less than the Divide
                  Equally Amount.
*****************************************************************************/

FUNCTION GET_PRORATED_DEDN_AMOUNT
  (
  DI_subj                 number,
  P_CTX_ORIGINAL_ENTRY_ID number

  ) RETURN NUMBER IS

  cntr                 number ;
  ln_counter           number ;
  ln_xtra              number ;
  ln_counter_iterative number ;
  ln_counter_lwrdedn   number ;
  ln_iterative_flag    boolean ;
  cntr_iterative       number ;
  ln_xtra_iterative    number ;
  equal_dedn_amt       number ;
  tmp_dedn_amt         number ;
  mod_dedn_amt         number ;

  BEGIN

  hr_utility.trace('Entering into PAY_US_INV_DED_FORMULAS.GET_PRORATED_DEDN_AMOUNT.') ;

  IF mod_dedn_tab.count = 0 THEN

  ln_counter := 0 ;
  ln_xtra := 0 ;
  /* Getting the Equal Deduction Amount for Rule Divide Equally */
  equal_dedn_amt := DI_subj / dedn_tab.count ;
  cntr := dedn_tab.first ;

    /* Looping through the Deduction Table and checking the existence of any
       Deduction Amount that is less than Equal Deduction (Divide Equally) Amount
       And populating another Table mod_dedn_tab with the Modified Amount */

    WHILE cntr is not null LOOP
       hr_utility.trace('Original Deduction('||cntr||') = '||dedn_tab(cntr));
       IF dedn_tab(cntr) < equal_dedn_amt THEN
          ln_counter := ln_counter + 1 ;
          ln_xtra := ln_xtra + (equal_dedn_amt - dedn_tab(cntr)) ;
          mod_dedn_tab(cntr) := dedn_tab(cntr) ;
       ELSE
          mod_dedn_tab(cntr) := equal_dedn_amt ;
       END IF ;
       hr_utility.trace('1st Iteration Deduction('||cntr||') = '||mod_dedn_tab(cntr)) ;
       cntr := dedn_tab.NEXT(cntr) ;
    END LOOP;

    /* If there exist any Deduction Amount that expects less than Equal Deduction one
       setting Iterative Flag to True and recalculating Equal Deduction Amount */

    IF ln_counter > 0 THEN
       ln_iterative_flag := TRUE ;
       equal_dedn_amt := equal_dedn_amt + ( ln_xtra / (mod_dedn_tab.count - ln_counter)) ;
    END IF ;
    cntr_iterative := mod_dedn_tab.first ;

    While ln_iterative_flag LOOP
    /* Repeat Iteration as long as Iterative Flag is True */
      ln_xtra_iterative := 0 ;
      ln_counter_iterative := 0 ;
      ln_counter_lwrdedn := 0 ;
      ln_iterative_flag := FALSE ;

      cntr_iterative := mod_dedn_tab.FIRST ;

      WHILE cntr_iterative is not null LOOP

       tmp_dedn_amt := ( mod_dedn_tab(cntr_iterative) + ( ln_xtra / (dedn_tab.count - ln_counter)) ) ;

       IF ( dedn_tab(cntr_iterative) >= tmp_dedn_amt )
         OR  ( tmp_dedn_amt > dedn_tab(cntr_iterative)
             AND   tmp_dedn_amt = equal_dedn_amt ) THEN

          mod_dedn_tab(cntr_iterative) := tmp_dedn_amt ;

          IF mod_dedn_tab(cntr_iterative) > dedn_tab(cntr_iterative) THEN
             ln_xtra_iterative := ln_xtra_iterative + ( mod_dedn_tab(cntr_iterative) - dedn_tab(cntr_iterative) ) ;
             ln_counter_iterative := ln_counter_iterative + 1 ;
             ln_iterative_flag := TRUE ;
             mod_dedn_tab(cntr_iterative) := dedn_tab(cntr_iterative) ;
             hr_utility.trace('Modified Nth Deduction('||cntr_iterative||') = '||mod_dedn_tab(cntr_iterative)) ;
          END IF ;

        ELSIF mod_dedn_tab(cntr_iterative) = dedn_tab(cntr_iterative) THEN
              ln_counter_lwrdedn := ln_counter_lwrdedn + 1 ;
              hr_utility.trace('Original Deduction is less and Modified Deduction Table is Updated already, Counter := '||ln_counter_lwrdedn) ;
        END IF ;

        /* Setting Equal Dedn Amt when it reaches Last */
        IF cntr_iterative = mod_dedn_tab.last THEN

           ln_xtra := ln_xtra_iterative ;
           ln_counter := ln_counter_iterative + ln_counter_lwrdedn ;

           equal_dedn_amt := equal_dedn_amt + ( ln_xtra / (mod_dedn_tab.count - ln_counter)) ;

           hr_utility.trace('Equal Dedn Amt := '||equal_dedn_amt) ;

           IF ln_iterative_flag THEN
              hr_utility.trace('Iterative Flag Value := '||'TRUE') ;
           END IF ;
        END IF ; -- Reaches Last Record

        cntr_iterative := mod_dedn_tab.NEXT(cntr_iterative) ;
      END LOOP ; -- Modified Deduction Table Looped through

    END LOOP ; -- As long as Iterative Flag True
  END IF ;  -- End of population of mod_dedn_tab when tab count = 0

  mod_dedn_amt := mod_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) ;
  hr_utility.trace('Final Deduction Amount for the Inv Dedn Element ('||to_char(P_CTX_ORIGINAL_ENTRY_ID)||') := '||to_char(mod_dedn_amt)) ;

  RETURN mod_dedn_amt ;

  hr_utility.trace('Leaving PAY_US_INV_DED_FORMULAS.GET_PRORATED_DEDN_AMOUNT.') ;

END GET_PRORATED_DEDN_AMOUNT ;

  /****************************************************************************
    Name        : BASE_FORMULA
    Description : This function calculates deduction amount and fees claimed by
                  each involuntary deduction element. It also initializes input
                  values of calculator element. these input values are later
                  sent as indirect inputs.
  *****************************************************************************/

FUNCTION BASE_FORMULA(
    P_CTX_DATE_EARNED                   date,
    P_CTX_ELEMENT_ENTRY_ID              number,
    P_CTX_JURISDICTION_CODE             varchar2,
    P_CTX_ORIGINAL_ENTRY_ID             number,
    ADDITIONAL_ASG_GRE_LTD              IN OUT NOCOPY number,
    REPLACEMENT_ASG_GRE_LTD             IN OUT NOCOPY number,
    ACCRUED_ASG_LTD                     IN OUT NOCOPY number,
    ACCRUED_FEES_ASG_LTD                number,
    FEES_ENTRY_PTD                      IN OUT NOCOPY number,
    FEES_ENTRY_ITD                      IN OUT NOCOPY number,
    FEES_ENTRY_MONTH                    IN OUT NOCOPY number,
    ASG_MONTH                           number,
    ASG_PTD                             number,
    /*VOL_DEDNS_ASG_GRE_LTD               number,*/
    VOL_DED_ASG_GRE_LASTRUN             number,
    PRE_TAX_DED_ASG_GRE_LASTRUN         number,
    ASG_WORK_AT_HOME                    varchar2,
    OVERRIDE_PER_ADR_REGION_2           varchar2,
    OVERRIDE_PER_ADR_REGION_1           varchar2,
    OVERRIDE_PER_ADR_CITY               varchar2,
    OVERRIDE_PER_ADR_POSTAL_CODE        varchar2,
    OVERRIDE_LOC_ADR_REGION_2           varchar2,
    OVERRIDE_LOC_ADR_REGION_1           varchar2,
    OVERRIDE_LOC_ADR_CITY               varchar2,
    OVERRIDE_LOC_ADR_POSTAL_CODE        varchar2,
    AMOUNT                              number,
    JURISDICTION                        IN OUT NOCOPY varchar2,
    DATE_SERVED                         IN OUT NOCOPY date,
    DEDNS_AT_TIME_OF_WRIT               number,
    PAY_EARNED_END_DATE                 date,
    EXEMPT_AMOUNT                       number,
    ARREARS_DATE                        date,
    NUM_DEPS                            number,
    FIL_STAT                            varchar2,
    ALLOWS                              number,
    /*VOLDEDNS_AT_WRIT                    OUT NOCOPY number,*/
    CALC_SUBPRIO                        OUT NOCOPY number,
    REGULAR_EARNINGS_ASG_GRE_RUN        number,
    DI_SUBJ_TAX_JD_ASG_GRE_RUN          number,
    DI_SUBJ_TAX_ASG_GRE_RUN             number,
    TAX_DEDUCTIONS_ASG_GRE_RUN          number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN      number,
    PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN      number,
    PRE_TAX_SUBJ_TX_ASG_GRE_RUN         number,
    ARREARS_OVERRIDE                    number,
    PERCENTAGE                          number,
    MONTHLY_CAP_AMOUNT                  number,
    PERIOD_CAP_AMOUNT                   number,
    GARN_FEE_FEE_RULE                   varchar2,
    GARN_FEE_FEE_AMOUNT                 number,
    GARN_FEE_MAX_FEE_AMOUNT             number,
    ACCRUED_FEES                        number,
    GARN_FEE_PCT_CURRENT                number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT       number,
    TOTAL_OWED                          number,
    GARN_TOTAL_FEES_ASG_GRE_RUN         number,
    GRN_DI_SUBJ_TX_ASG_GRE_RUN          number,
    GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN       number,
    PR_TX_DED_SBJ_TX_ASG_GRE_RN         number,
    PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN      number,
    GARN_EXEMPTION_CALC_RULE            varchar2,
    GARN_TOTAL_DEDNS_ASG_GRE_RUN        number,
    DCIA_DI_SUBJ_TX_ASG_GRE_RUN         number default 0,
    DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN      number default 0,
    PR_TX_DCIA_SB_TX_ASG_GRE_RN         number default 0,
    PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN      number default 0,
    FEES_ASG_GRE_PTD                    number default -9999,
    EIC_ADVANCE_ASG_GRE_RUN             number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN           number  default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN          number  default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN       number  default 0,
    NET_ASG_RUN                         number  default 0,
    NET_ASG_PTD                         number  default 0

) RETURN number IS

default_number number;
default_string varchar2(11);
default_date date;
garn_category varchar2(5);
c_Gross_Subject_to_Garn number;
c_balance_Subject_to_Garn number;
dedn_amt number;
calcd_fee number;
l_total_owed number;
sub_prio_max number;
amt number;
dedn_override number;
exempt_amt number;
to_accrued_fees number;
l_garn_fee_max_fee_amt number;

l_debug_on varchar2(1);
l_proc_name varchar2(50);
l_ini_fee_flag varchar2(10);
lv_allow_value varchar2(10);
lv_filing_status varchar2(10);

-- Bug# 5672067
ln_SI_Replace_Amt      number ;

b_default_flag boolean;

    CURSOR cur_debug is
    SELECT parameter_value
      FROM pay_action_parameters
     WHERE parameter_name = 'GARN_DEBUG_ON';

    /* Cursor for Bug 3715182 and 3719168 */
    CURSOR c_garn_max_fee_amt is
    select target.MAX_FEE_AMOUNT from
           PAY_US_GARN_FEE_RULES_F target,
           PAY_ELEMENT_TYPES_F pet,
           PAY_ELEMENT_ENTRIES_F pee
    WHERE target.state_code = substr(P_CTX_JURISDICTION_CODE,1,2)
      AND target.garn_category = pet.element_information1
      AND P_CTX_DATE_EARNED BETWEEN target.effective_start_date
                                AND target.effective_end_date
      AND pet.element_type_id = pee.element_type_id
      AND pee.element_entry_id = P_CTX_ELEMENT_ENTRY_ID
      AND P_CTX_DATE_EARNED BETWEEN pet.effective_start_date
                                AND pet.effective_end_date;

    /* Cursot to return the Initial Fee Flag value Bug 3549298 */
    CURSOR csr_get_ini_fee_flag is
    SELECT nvl(entry_information9, 'N')
      FROM pay_element_entries_f
     WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
       AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
       AND P_CTX_DATE_EARNED BETWEEN effective_start_date and effective_end_date;

    -- Get the value entered for Allowances Input Value
    CURSOR c_get_allowance_value(c_input_value_name varchar2) IS
    select peev.screen_entry_value
      from pay_element_entries_f peef,
           pay_element_entry_values_f peev,
           pay_input_values_f pivf
     where peef.element_entry_id = P_CTX_ELEMENT_ENTRY_ID
       and peev.element_entry_id = peef.element_entry_id
       and pivf.element_type_id = peef.element_type_id
       and pivf.name = c_input_value_name
       and peev.input_value_id = pivf.input_value_id
       and P_CTX_DATE_EARNED between peev.effective_start_date
                                 and peev.effective_end_date;

    -- Bug# 5672067
    -- Get the Screen Entry Value for 'Replace Amt' Input Values
    CURSOR c_get_Replace_Amount_val(c_input_value_name varchar2) IS
    select peev_si.screen_entry_value
      from pay_element_entries_f peef_base,
           pay_element_entries_f peef_si,
           pay_element_entry_values_f peev_si,
           pay_input_values_f pivf_si,
           pay_element_types_f pet_base,
           pay_element_types_f pet_si
     where peef_base.element_entry_id = P_CTX_ELEMENT_ENTRY_ID
       and peef_base.element_type_id = pet_base.element_type_id
       and pet_base.element_information18 = pet_si.element_type_id
       and peef_base.assignment_id = peef_si.assignment_id
       and peef_si.element_type_id = pet_si.element_type_id
       and peev_si.element_entry_id = peef_si.element_entry_id
       and pivf_si.element_type_id = peef_si.element_type_id
       and pivf_si.name = c_input_value_name
       and peev_si.input_value_id = pivf_si.input_value_id
       and P_CTX_DATE_EARNED between peev_si.effective_start_date
                                 and peev_si.effective_end_date
       and P_CTX_DATE_EARNED between peef_si.effective_start_date
                                 and peef_si.effective_end_date
       and P_CTX_DATE_EARNED between pivf_si.effective_start_date
                                 and pivf_si.effective_end_date
       and P_CTX_DATE_EARNED between pet_si.effective_start_date
                                 and pet_si.effective_end_date ;

BEGIN

    l_package_name := 'PAY_US_INV_DED_FORMULAS.';
    l_proc_name := l_package_name||'BASE_FORMULA';

    default_number := -9999;
    default_string := 'NOT ENTERED';
    default_date := fnd_date.canonical_to_date('0001/01/01');
    sub_prio_max := 9999;
    l_garn_fee_max_fee_amt := NULL;
    GLB_NUM_ELEM := nvl(GLB_NUM_ELEM ,0);
    lv_allow_value := NULL;
    lv_filing_status := NULL;
    b_default_flag := FALSE;

    -- Bug 4079142
    if GLB_OTHER_DI_FLAG is NULL then
        GLB_OTHER_DI_FLAG := FALSE;
    end if;

    if GLB_DCIA_EXIST_FLAG is NULL then
        GLB_DCIA_EXIST_FLAG := FALSE;
    end if;

    OPEN cur_debug;
        FETCH cur_debug into l_debug_on;
    CLOSE cur_debug;

    /*
     * Fetch the value of Initial Fee Flag. Bug 3549298
     */
    open csr_get_ini_fee_flag;
    fetch csr_get_ini_fee_flag into l_ini_fee_flag;
    close csr_get_ini_fee_flag;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace_on(NULL, 'GARN');
        hr_utility.trace('Entering '||l_proc_name);
        hr_utility.trace('Input parameters ....');
        hr_utility.trace('P_CTX_DATE_EARNED = '||P_CTX_DATE_EARNED);
        hr_utility.trace('P_CTX_ELEMENT_ENTRY_ID = '||P_CTX_ELEMENT_ENTRY_ID);
        hr_utility.trace('P_CTX_JURISDICTION_CODE = '||P_CTX_JURISDICTION_CODE);
        hr_utility.trace('P_CTX_ORIGINAL_ENTRY_ID = '||P_CTX_ORIGINAL_ENTRY_ID);
        hr_utility.trace('ADDITIONAL_ASG_GRE_LTD = '||ADDITIONAL_ASG_GRE_LTD);
        hr_utility.trace('REPLACEMENT_ASG_GRE_LTD = '||REPLACEMENT_ASG_GRE_LTD);
        hr_utility.trace('ACCRUED_ASG_LTD = '||ACCRUED_ASG_LTD);
        hr_utility.trace('ACCRUED_FEES_ASG_LTD = '||ACCRUED_FEES_ASG_LTD);
        hr_utility.trace('FEES_ENTRY_PTD = '||FEES_ENTRY_PTD);
        hr_utility.trace('FEES_ENTRY_ITD = '||FEES_ENTRY_ITD);
        hr_utility.trace('FEES_ENTRY_MONTH = '||FEES_ENTRY_MONTH);
        hr_utility.trace('ASG_MONTH = '||ASG_MONTH);
        hr_utility.trace('ASG_PTD = '||ASG_PTD);
        --hr_utility.trace('VOL_DEDNS_ASG_GRE_LTD = '||VOL_DEDNS_ASG_GRE_LTD);
        hr_utility.trace('VOL_DED_ASG_GRE_LASTRUN = '||VOL_DED_ASG_GRE_LASTRUN);
        hr_utility.trace('PRE_TAX_DED_ASG_GRE_LASTRUN = '||PRE_TAX_DED_ASG_GRE_LASTRUN);
        hr_utility.trace('ASG_WORK_AT_HOME = '||ASG_WORK_AT_HOME);
        hr_utility.trace('OVERRIDE_PER_ADR_REGION_2 = '||OVERRIDE_PER_ADR_REGION_2);
        hr_utility.trace('OVERRIDE_PER_ADR_REGION_1 = '||OVERRIDE_PER_ADR_REGION_1);
        hr_utility.trace('OVERRIDE_PER_ADR_CITY = '||OVERRIDE_PER_ADR_CITY);
        hr_utility.trace('OVERRIDE_PER_ADR_POSTAL_CODE = '||OVERRIDE_PER_ADR_POSTAL_CODE);
        hr_utility.trace('OVERRIDE_LOC_ADR_REGION_2 = '||OVERRIDE_LOC_ADR_REGION_2);
        hr_utility.trace('OVERRIDE_LOC_ADR_REGION_1 = '||OVERRIDE_LOC_ADR_REGION_1);
        hr_utility.trace('OVERRIDE_LOC_ADR_CITY = '||OVERRIDE_LOC_ADR_CITY);
        hr_utility.trace('OVERRIDE_LOC_ADR_POSTAL_CODE = '||OVERRIDE_LOC_ADR_POSTAL_CODE);
        hr_utility.trace('AMOUNT = '||AMOUNT);
        hr_utility.trace('JURISDICTION = '||JURISDICTION);
        hr_utility.trace('DATE_SERVED = '||DATE_SERVED);
        hr_utility.trace('DEDNS_AT_TIME_OF_WRIT = '||DEDNS_AT_TIME_OF_WRIT);
        hr_utility.trace('PAY_EARNED_END_DATE = '||PAY_EARNED_END_DATE);
        hr_utility.trace('EXEMPT_AMOUNT = '||EXEMPT_AMOUNT);
        hr_utility.trace('ARREARS_DATE = '||ARREARS_DATE);
        hr_utility.trace('NUM_DEPS = '||NUM_DEPS);
        hr_utility.trace('FIL_STAT = '||FIL_STAT);
        hr_utility.trace('ALLOWS = '||ALLOWS);
        --hr_utility.trace('VOLDEDNS_AT_WRIT = '||VOLDEDNS_AT_WRIT);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
        hr_utility.trace('REGULAR_EARNINGS_ASG_GRE_RUN = '||REGULAR_EARNINGS_ASG_GRE_RUN);
        hr_utility.trace('DI_SUBJ_TAX_JD_ASG_GRE_RUN = '||DI_SUBJ_TAX_JD_ASG_GRE_RUN);
        hr_utility.trace('DI_SUBJ_TAX_ASG_GRE_RUN = '||DI_SUBJ_TAX_ASG_GRE_RUN);
        hr_utility.trace('TAX_DEDUCTIONS_ASG_GRE_RUN = '||TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_DEDUCTIONS_ASG_GRE_RUN = '||PRE_TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN = '||PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_SUBJ_TX_ASG_GRE_RUN = '||PRE_TAX_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('ARREARS_OVERRIDE = '||ARREARS_OVERRIDE);
        hr_utility.trace('PERCENTAGE = '||PERCENTAGE);
        hr_utility.trace('MONTHLY_CAP_AMOUNT = '||MONTHLY_CAP_AMOUNT);
        hr_utility.trace('PERIOD_CAP_AMOUNT = '||PERIOD_CAP_AMOUNT);
        hr_utility.trace('GARN_FEE_FEE_RULE = '||GARN_FEE_FEE_RULE);
        hr_utility.trace('GARN_FEE_FEE_AMOUNT = '||GARN_FEE_FEE_AMOUNT);
        hr_utility.trace('GARN_FEE_MAX_FEE_AMOUNT = '||GARN_FEE_MAX_FEE_AMOUNT);
        hr_utility.trace('ACCRUED_FEES = '||ACCRUED_FEES);
        hr_utility.trace('GARN_FEE_PCT_CURRENT = '||GARN_FEE_PCT_CURRENT);
        hr_utility.trace('GARN_FEE_ADDL_GARN_FEE_AMOUNT = '||GARN_FEE_ADDL_GARN_FEE_AMOUNT);
        hr_utility.trace('TOTAL_OWED = '||TOTAL_OWED);
        hr_utility.trace('GARN_TOTAL_FEES_ASG_GRE_RUN = '||GARN_TOTAL_FEES_ASG_GRE_RUN);
        hr_utility.trace('GRN_DI_SUBJ_TX_ASG_GRE_RUN = '||GRN_DI_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN = '||GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('PR_TX_DED_SBJ_TX_ASG_GRE_RN = '||PR_TX_DED_SBJ_TX_ASG_GRE_RN);
        hr_utility.trace('PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN = '||PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN);
        hr_utility.trace('GARN_EXEMPTION_CALC_RULE = '||GARN_EXEMPTION_CALC_RULE);
        hr_utility.trace('GARN_TOTAL_DEDNS_ASG_GRE_RUN = '||GARN_TOTAL_DEDNS_ASG_GRE_RUN);
        hr_utility.trace('DCIA_DI_SUBJ_TX_ASG_GRE_RUN = '||DCIA_DI_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN = '||DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('PR_TX_DCIA_SB_TX_ASG_GRE_RN = '||PR_TX_DCIA_SB_TX_ASG_GRE_RN);
        hr_utility.trace('PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN = '||PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN);
        hr_utility.trace('INITIAL FEE FLAG = ' || l_ini_fee_flag);
        hr_utility.trace('FEES_ASG_GRE_PTD = ' || FEES_ASG_GRE_PTD);
        hr_utility.trace('EIC_ADVANCE_ASG_GRE_RUN = ' || EIC_ADVANCE_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_ROTH_ASG_GRE_RUN = ' || VOL_DEDN_ROTH_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_JD_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('NET_ASG_RUN = ' || NET_ASG_RUN);
        hr_utility.trace('NET_ASG_PTD = ' || NET_ASG_PTD);
    END IF;

    -- Bug 4154950
    -- Modified the paramter name from ACCRUED_FEES_ASG_GRE_LTD to
    -- ACCRUED_FEES_ASG_LTD
    IF ACCRUED_FEES_ASG_LTD = FEES_ENTRY_ITD THEN
        to_accrued_fees := 0;
    ELSE
        to_accrued_fees := FEES_ENTRY_ITD - ACCRUED_FEES_ASG_LTD;
    END IF;

    -- Bug 5095823
    IF GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN IS NULL THEN
       GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN := 0;
    END IF;

    /*---- SET CONTEXTS -----*/
    CTX_DATE_EARNED := P_CTX_DATE_EARNED;
    CTX_ELEMENT_ENTRY_ID := P_CTX_ELEMENT_ENTRY_ID;
    CTX_JURISDICTION_CODE := P_CTX_JURISDICTION_CODE;
    /*-----------------------*/

    GLB_NUM_ELEM := GLB_NUM_ELEM + 1;
    hr_utility.trace('GLB_NUM_ELEM = '|| GLB_NUM_ELEM);

    -- Bug 4748532
    GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) := FEES_ASG_GRE_PTD;
    GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) := ASG_PTD;
    GLB_AMT_NOT_SPEC(P_CTX_ORIGINAL_ENTRY_ID)     := FALSE;

    amt := NVL(amount,0);
    calc_subprio := entry_subpriority;

/*    IF ACCRUED_ASG_GRE_LTD = 0 THEN

        voldedns_at_writ := VOL_DED_ASG_GRE_LASTRUN
                            + PRE_TAX_DED_ASG_GRE_LASTRUN;
    END IF;*/

    IF Dedns_at_Time_of_Writ <> default_number THEN
        dedn_override := Dedns_at_Time_of_Writ;

    /* Commented because Vol Dedns At Writ input value no longer exists
      ELSE
        IF ACCRUED_ASG_GRE_LTD = 0 THEN
            dedn_override := voldedns_at_writ;
  		ELSIF VOL_DEDNS_ASG_GRE_LTD <> default_number THEN
            dedn_override := VOL_DEDNS_ASG_GRE_LTD;
        END IF;*/
    END IF;

    IF calc_subprio = 1 THEN
	    IF date_served <> default_date THEN
		    calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - Date_Served);
        END IF;
    END IF;

    garn_category := garn_cat;

    IF Exempt_Amount  <> default_number THEN
        IF garn_category = 'BO' THEN
            Exempt_Amt := Exempt_Amount;
        ELSE
            Exempt_Amt := 0;
        END IF;
    ELSE
        exempt_amt := 0;
    END IF;

    IF garn_category in ('AY','CS','SS') THEN
    /*------ Support Deduction amount calculation starts -----------*/

        c_Gross_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN
    	                	       +LEAST(DI_SUBJ_TAX_JD_ASG_GRE_RUN,
                                          DI_SUBJ_TAX_ASG_GRE_RUN));
        -- Bug# 4676867
        c_Balance_Subject_to_Garn :=
                                (REGULAR_EARNINGS_ASG_GRE_RUN +
                                  LEAST(DI_SUBJ_TAX_JD_ASG_GRE_RUN,
                                        DI_SUBJ_TAX_ASG_GRE_RUN)) -
                                 ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                  + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN -
                                    (LEAST(PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN,
                                     PRE_TAX_SUBJ_TX_ASG_GRE_RUN )))
                                  + (VOL_DEDN_ROTH_ASG_GRE_RUN -
                                     (LEAST(VOL_DEDN_SB_TX_ASG_GRE_RUN,
                                            VOL_DEDN_SB_TX_JD_ASG_GRE_RUN)))
                                     );

        hr_utility.trace('c_Gross_Subject_to_Garn = '||c_Gross_Subject_to_Garn);
        hr_utility.trace('c_Balance_Subject_to_Garn = '||c_Balance_Subject_to_Garn);

        IF calc_subprio = 1 THEN
            IF date_served <> default_date THEN
                calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - Date_Served);
            END IF;
        END IF;

        -- Bug# 5672067
        -- Reverting Back the Changes
        -- Changing for Special Input Element
        OPEN c_get_Replace_Amount_val('Replace Amt') ;
        FETCH c_get_Replace_Amount_val INTO ln_SI_Replace_Amt ;
        CLOSE c_get_Replace_Amount_val ;

        hr_utility.trace('ln_SI_Replace_Amt := '||ln_SI_Replace_Amt) ;

        IF ln_SI_Replace_Amt IS NOT NULL THEN
            dedn_amt := ln_SI_Replace_Amt ;
            IF dedn_amt < 0 THEN
               dedn_amt := 0 ;
            END IF ;
        ELSIF Amount <> 0 THEN
            dedn_amt := Amount;
        ELSIF Percentage <> 0 THEN
            IF SUBSTR(Jurisdiction,1,2) = '50' THEN
                dedn_amt := (Percentage * c_Gross_Subject_to_Garn) / 100;
            ELSE
                dedn_amt := (Percentage * c_Balance_Subject_to_Garn) / 100;
            END IF;
        ELSE
            dedn_amt :=  c_Balance_Subject_to_Garn;  /* total_owed */
            GLB_AMT_NOT_SPEC(P_CTX_ORIGINAL_ENTRY_ID) := TRUE;
        END IF;

        IF ADDITIONAL_ASG_GRE_LTD <> 0 THEN
            dedn_amt := dedn_amt + ADDITIONAL_ASG_GRE_LTD;
        END IF;

        -- Bug 4072103
        -- Added code to recalculate DEDN_AMT if amount to be deducted
        -- overshoots TOTAL_OWED

        actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := DEDN_AMT;
        -- Bug 4154950
        -- Modified the paramter name from ACCRUED_ASG_GRE_LTD to
        -- ACCRUED_ASG_LTD
        IF TOTAL_OWED > 0 THEN
           IF ACCRUED_ASG_LTD + DEDN_AMT > TOTAL_OWED THEN
              -- Bug 4748532
              IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                 actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := TOTAL_OWED - ACCRUED_ASG_LTD;
                 hr_utility.trace('Actual Deduction Amount(TO) = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
                 hr_utility.trace('Deduction Amount(TO) = ' || DEDN_AMT);
              ELSE
                 DEDN_AMT := TOTAL_OWED - ACCRUED_ASG_LTD;
              END IF;
           END IF;
        END IF;

    /* *** Calculation Section END *** */

        /*IF arrears_override <> default_number THEN
            dedn_amt := dedn_amt + arrears_override;
        END IF;*/
        hr_utility.set_location(l_proc_name,10);
        hr_utility.trace('dedn_amt = '||dedn_amt);
        IF arrears_override <> default_number THEN
            arrears_tab(P_CTX_ORIGINAL_ENTRY_ID) := arrears_override; /* Bug 2992741 */
        END IF;

        hr_utility.trace('Dedn_amt before cap adjustments = '||dedn_amt);
        hr_utility.trace('Monthly_Cap_Amount = '||Monthly_Cap_Amount);


        IF Monthly_Cap_Amount <> 0  THEN
            -- Bug 4154950
            -- Modified the paramter name from ASG_GRE_MONTH to
            -- ASG_MONTH
            IF Monthly_Cap_Amount - ASG_MONTH >= 0 THEN
               -- Bug 4748532
               IF dedn_amt + ASG_MONTH > Monthly_Cap_Amount THEN
                  IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                     IF actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) > (Monthly_Cap_Amount - ASG_MONTH) THEN
                        actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := Monthly_Cap_Amount - ASG_MONTH;
                     END IF;
                     hr_utility.trace('Actual Deduction Amount(MTD) = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
                     hr_utility.trace('Deduction Amount(MTD) = ' || DEDN_AMT);
                  ELSE
                     dedn_amt := Monthly_Cap_Amount - ASG_MONTH;
                  END IF;
               END IF;
            END IF;
        END IF;

        hr_utility.trace('Period_Cap_Amount = '||Period_Cap_Amount); /* Max_Per_Period */
        IF Period_Cap_Amount <> 0  THEN
            -- Bug 4154950
            -- Modified the paramter name from ASG_GRE_PTD to
            -- ASG_PTD
            IF Period_Cap_Amount - ASG_PTD >= 0 THEN
                IF dedn_amt + ASG_PTD > Period_Cap_Amount THEN
                   -- Bug 4748532
                   IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                      IF actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) > (Period_Cap_Amount - ASG_PTD) THEN
                         actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := Period_Cap_Amount - ASG_PTD;
                      END IF;
                      hr_utility.trace('Actual Deduction Amount(PTD) = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
                      hr_utility.trace('Deduction Amount(PTD) = ' || DEDN_AMT);
                   ELSE
                      dedn_amt := Period_Cap_Amount - ASG_PTD;
                   END IF;
                END IF;
            END IF;
        END IF;
        hr_utility.trace('Dedn_amt after cap adjustments = '||dedn_amt);
        IF Amount = 0 and arrears_override <> default_number THEN
            dedn_amt := dedn_amt - arrears_override; /* For Bug 2992741, we need Arrears Dedn Amount and dedn_amt in separate
                                                        PL/SQL tables. But the above Max Per Period adjustment tends to merge the
                                                        dedn_amt and Arrears Dedn Amount (arrears_override). Hence dedn_amt is
                                                        brought down to a value which does not contain Arrears Dedn Amount. */
        END IF;

    /* *** Fee processing BEGIN. *** */
        calcd_fee := 0;
    /* 01-FEB-1999 ***********
       If the amount deducted for Child support is ZERO
       then the fee amount to be deducted should be set to ZERO
       If the Child support amount to be deducted is less than ZERO
       then also set the dedn_amt to 0
    */

    /* Bug 3715182 and 3719168
     * Get the GARN_FEE_MAX_FEE_AMOUNT
     */
    open c_garn_max_fee_amt;
    fetch c_garn_max_fee_amt into l_garn_fee_max_fee_amt;
    close c_garn_max_fee_amt;

    if l_garn_fee_max_fee_amt is NULL then
       l_garn_fee_max_fee_amt := 99999999;
    else
       l_garn_fee_max_fee_amt := GARN_FEE_MAX_FEE_AMOUNT;
    end if;
    hr_utility.trace('Modified GARN_FEE_MAX_FEE_AMOUNT = '||l_garn_fee_max_fee_amt);


        IF dedn_amt <= 0 THEN
            dedn_amt := 0;
            calcd_fee := 0;
        ELSE
            IF GARN_FEE_FEE_RULE <> default_string THEN
                IF GARN_FEE_FEE_RULE = 'AMT_OR_PCT_PER_GARN' THEN
                    IF total_owed = default_number THEN
                        l_total_owed := 0;
                    ELSE
                        l_total_owed := total_owed;
                    END IF;
                    calcd_fee := FNC_FEE_CALCULATION(GARN_FEE_FEE_RULE,
                                                     GARN_FEE_FEE_AMOUNT,
                                                     GARN_FEE_PCT_CURRENT,
                                                     l_total_owed,
                                                     ACCRUED_ASG_LTD,
                                                     GARN_FEE_ADDL_GARN_FEE_AMOUNT,
                                                     l_garn_fee_max_fee_amt,
                                                     FEES_ENTRY_PTD,
                                                     GARN_TOTAL_FEES_ASG_GRE_RUN,
                                                     dedn_amt,
                                                     FEES_ENTRY_MONTH,
                                                     Accrued_fees);

                ELSIF GARN_FEE_FEE_RULE = 'AMT_OR_PCT' THEN
                    calcd_fee := GREATEST(GARN_FEE_FEE_AMOUNT,
                    GARN_FEE_PCT_CURRENT * dedn_amt);
                ELSIF GARN_FEE_FEE_RULE = 'PCT_PER_MONTH' OR
                    GARN_FEE_FEE_RULE = 'PCT_PER_PERIOD' OR
                    GARN_FEE_FEE_RULE = 'PCT_PER_RUN' THEN
                    calcd_fee := LEAST(l_garn_fee_max_fee_amt, GARN_FEE_PCT_CURRENT * dedn_amt);
                ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_GARN' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_MONTH' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_RUN' THEN
                    calcd_fee := GARN_FEE_FEE_AMOUNT;
                ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_GARN_ADDL' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD_ADDL' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_MONTH_ADDL' OR
                    GARN_FEE_FEE_RULE = 'AMT_PER_RUN_ADDL' THEN
                    IF Accrued_Fees = 0 THEN
                        calcd_fee := GARN_FEE_FEE_AMOUNT;
                    ELSIF Accrued_Fees >= GARN_FEE_FEE_AMOUNT THEN
                        calcd_fee := GARN_FEE_ADDL_GARN_FEE_AMOUNT;
                    -- Bug 4748532
                    ELSIF Accrued_Fees = FEES_ENTRY_PTD THEN
                        calcd_fee := GARN_FEE_FEE_AMOUNT;
                    ELSE
                        calcd_fee := GARN_FEE_FEE_AMOUNT - Accrued_Fees + GARN_FEE_ADDL_GARN_FEE_AMOUNT;
                    END IF;
                END IF;
                /*
                 * Check for Initial Fee Flag set. If yes then do not take the initial fee.
                 * Only take the Additional Fee if specified. Bug 3549298
                 */
                if l_ini_fee_flag = 'Y' then
                    if (GARN_FEE_FEE_RULE = 'AMT_PER_GARN_ADDL' OR
                        GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD_ADDL' OR
                        GARN_FEE_FEE_RULE = 'AMT_PER_MONTH_ADDL' OR
                        GARN_FEE_FEE_RULE = 'AMT_PER_RUN_ADDL') then
                        calcd_fee := GARN_FEE_ADDL_GARN_FEE_AMOUNT;
                    else
                        -- Initial Fee Taken
                        calcd_fee := 0;
                    end if;
                end if;
            END IF;
        END IF;


    /* *** Fee processing END. *** */

        hr_utility.trace('Storing deduction and fees values at index '||p_ctx_original_entry_id);
        dedn_tab(p_ctx_original_entry_id) := dedn_amt;
        fees_tab(p_ctx_original_entry_id) := calcd_fee;

        hr_utility.trace('Deduction Count = '||dedn_tab.count());
        hr_utility.trace('Fees Count = '||fees_tab.count());
        hr_utility.trace('Current deduction value = '||dedn_tab(p_ctx_original_entry_id));
        hr_utility.trace('Current fees value = '||fees_tab(p_ctx_original_entry_id));

    END IF;

    IF garn_category in ('BO','CD','G','EL','ER', 'DCIA') THEN
        /* -- Calculation for Garnishments' Deduction amount --*/
       IF garn_category = 'EL' THEN
            -- Bug# 4676867
            c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                            GRN_DI_SUBJ_TX_ASG_GRE_RUN)
                                            - ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                               + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN
                                                  - PR_TX_DED_SBJ_TX_ASG_GRE_RN)
                                            + (VOL_DEDN_ROTH_ASG_GRE_RUN
                                               - VOL_DEDN_SB_TX_ASG_GRE_RUN)
                                              );
           -- Bug 4079142
           -- Set flag to indicate Other Garnishment Deductions being taken
           GLB_OTHER_DI_FLAG := TRUE;
        ELSIF garn_category = 'DCIA' THEN
            GLB_DCIA_EXIST_FLAG := TRUE;
            -- Bug# 4676867
            c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                            DCIA_DI_SUBJ_TX_ASG_GRE_RUN)
                                            - ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                            + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN
                                               - PR_TX_DCIA_SB_TX_ASG_GRE_RN)
                                            + (VOL_DEDN_ROTH_ASG_GRE_RUN
                                               - VOL_DEDN_SB_TX_ASG_GRE_RUN)
                                            );
        ELSE
            -- Bug# 4676867
            c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                        LEAST(GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN, GRN_DI_SUBJ_TX_ASG_GRE_RUN)) -
                                        ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                        + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN -
                                          (LEAST(PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN, PR_TX_DED_SBJ_TX_ASG_GRE_RN )))
                                        + (VOL_DEDN_ROTH_ASG_GRE_RUN -
                                          (LEAST(VOL_DEDN_SB_TX_ASG_GRE_RUN,
                                                 VOL_DEDN_SB_TX_JD_ASG_GRE_RUN)))
                                         );
           -- Bug 4079142
           -- Set flag to indicate Other Garnishment Deductions being taken
           GLB_OTHER_DI_FLAG := TRUE;
        END IF;

        calc_subprio := entry_subpriority;
        IF calc_subprio = 1 THEN
            IF date_served <> default_date THEN
                calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - Date_Served);
            END IF;
        END IF;

        /* *** Calculation Section BEGIN *** */
        /*IF GARN_EXEMPTION_CALC_RULE = 'ONE_FED' OR
              GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_AMT' OR
              GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_PCT' OR
              GARN_EXEMPTION_CALC_RULE = 'ONE_MARSTAT_RULE' OR
              GARN_EXEMPTION_CALC_RULE = 'ONE_EXEMPT_BALANCE' THEN
            IF GARN_TOTAL_DEDNS_ASG_GRE_RUN = 0 THEN
                IF REPLACEMENT_ASG_GRE_LTD <> 0 THEN
                    dedn_amt := REPLACEMENT_ASG_GRE_LTD;
                ELSIF Amount <> 0 THEN
                    dedn_amt := Amount;
                ELSIF Percentage <> 0 THEN
                    dedn_amt := (Percentage * c_Balance_Subject_to_Garn) / 100;
                ELSE
                    dedn_amt := c_Balance_Subject_to_Garn;
                END IF;
            ELSE
                dedn_amt := 0;
                STOP_ENTRY := 'Y';
                calcd_dedn_amt := dedn_amt;
            END IF;*/

        /* *** Check for override to wage attachment deduction amount. *** */

        -- Bug# 5672067
        -- Reverting Back the Changes
        -- Changing for Special Input Element

        OPEN c_get_Replace_Amount_val('Replace Amt') ;
        FETCH c_get_Replace_Amount_val INTO ln_SI_Replace_Amt ;
        CLOSE c_get_Replace_Amount_val ;
        hr_utility.trace('ln_SI_Replace_Amt := '||ln_SI_Replace_Amt) ;

        IF ln_SI_Replace_Amt IS NOT NULL THEN
            dedn_amt := ln_SI_Replace_Amt ;
            IF dedn_amt < 0 THEN
               dedn_amt := 0 ;
            END IF ;
        ELSIF Amount <> 0 THEN
            dedn_amt := Amount;

        ELSIF Percentage <> 0 THEN
            dedn_amt := (Percentage * c_Balance_Subject_to_Garn) / 100;
        ELSE
            dedn_amt := c_Balance_Subject_to_Garn;
            GLB_AMT_NOT_SPEC(P_CTX_ORIGINAL_ENTRY_ID) := TRUE;
        END IF;

        /* *** Add in any adjustments. *** */
        IF ADDITIONAL_ASG_GRE_LTD <> 0 THEN
            dedn_amt := dedn_amt + ADDITIONAL_ASG_GRE_LTD;
        END IF;

        -- Bug 4072103
        -- Added code to recalculate DEDN_AMT if amount to be deducted
        -- overshoots TOTAL_OWED
        actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := dedn_amt;

        IF TOTAL_OWED > 0 THEN
           IF ACCRUED_ASG_LTD + dedn_amt > TOTAL_OWED THEN
              -- Bug 4748532
              IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                 actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := TOTAL_OWED - ACCRUED_ASG_LTD;
                 hr_utility.trace('Actual Deduction Amount = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
                 hr_utility.trace('Deduction Amount = ' || DEDN_AMT);
              ELSE
                 DEDN_AMT := TOTAL_OWED - ACCRUED_ASG_LTD;
              END IF;
           END IF;
        END IF;

        gar_dedn_tab (P_CTX_ORIGINAL_ENTRY_ID) := dedn_amt;

    END IF;
    /*-----------------------------------------------------*/

    /*----------- Transfer input values to global variables --------------*/
    GLB_AMT(P_CTX_ORIGINAL_ENTRY_ID) := AMT;                             -- Amount
    GLB_ARREARS_OVERRIDE(P_CTX_ORIGINAL_ENTRY_ID) := ARREARS_OVERRIDE;   -- Arrears Dedn Amount
    GLB_ARREARS_DATE(P_CTX_ORIGINAL_ENTRY_ID) := ARREARS_DATE;           -- Date In Arrears
    GLB_NUM_DEPS(P_CTX_ORIGINAL_ENTRY_ID) := NUM_DEPS;                   -- Num Dependents
    GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) := FIL_STAT;                   -- Filing Status
    GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID) := ALLOWS;                       -- Allowances
    GLB_DEDN_OVERRIDE(P_CTX_ORIGINAL_ENTRY_ID) := DEDN_OVERRIDE;         -- Dedns at Time of Writ
    GLB_PCT(P_CTX_ORIGINAL_ENTRY_ID) := PERCENTAGE;                      -- Percentage
    GLB_MONTH_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID) := MONTHLY_CAP_AMOUNT;    -- Monthly Cap Amount
    GLB_MTD_BAL(P_CTX_ORIGINAL_ENTRY_ID) := ASG_MONTH;               -- Month To Date Balance
    GLB_EXEMPT_AMT(P_CTX_ORIGINAL_ENTRY_ID) := EXEMPT_AMT;               -- Exempt Amt BO
    GLB_PTD_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID) := PERIOD_CAP_AMOUNT;       -- Period Cap Amount
    GLB_PTD_BAL(P_CTX_ORIGINAL_ENTRY_ID) := ASG_PTD;                 -- Period To Date Balance
    GLB_TO_ACCRUED_FEES(P_CTX_ORIGINAL_ENTRY_ID) := TO_ACCRUED_FEES;     -- Accrued Fee Correction
    /*---------------------------------------------------------------------*/
    -- Fix for Bug 4143803 Starts here
    if garn_category = 'TL' then

        -- Bug 4104842
        -- Calculating the Gross earnings that can be used to calculate
        -- Tax Levy. This Gross amount becomes the maximum amount that Tax
        -- Levy can take. This is different from the GROSS_EARNINGS_ASG_GRE_RUN
        -- passed in the CAL_FORMULA_TL parameters as it calculates the
        -- Income that can be subjected for Tax Levy based on the Earning rules.

        c_Gross_Subject_to_Garn := REGULAR_EARNINGS_ASG_GRE_RUN
                                   + LEAST(GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN, GRN_DI_SUBJ_TX_ASG_GRE_RUN);

        GLB_TL_GROSS_EARNINGS := c_Gross_Subject_to_Garn;

       -- Bug 4143803
       -- Get the value entered for the Input Value "Filing Status"
       -- in the element entry screen.
       -- If Filing Status is defaulted to 'XX' or '01',
       -- we need to correctly default the values
       --    i. '01' for elements created before the fix for 4143803
       --   ii. 'XX' for elements created after the fix for 4143803
       -- We correct the value of GLB_FIL_STAT to '01', if defaulted wrongly.
        b_default_flag := FALSE;
        open c_get_allowance_value('Filing Status');
        fetch c_get_allowance_value into lv_filing_status;
        close c_get_allowance_value;
        if FIL_STAT = '01' then
            -- If Allowances was defaulted then correct the default value to 1
            if lv_filing_status is NULL then
                b_default_flag := TRUE;
            end if;
        elsif FIL_STAT = 'XX' then
            b_default_flag := TRUE;
        end if;

        -- Default value for Allowances. Modify here if the default value
        -- changes in future for Allowances
        if b_default_flag then
            GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) := '01';
            hr_utility.trace('Defaulting Filing Status for Tax Levy to ' || GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID));
        end if;

       -- Get the value entered for the Input Value "Allowances" and
       -- in the element entry screen.
       -- If Allowances is defaulted to '0' or '-9', we need to correctly
       -- default the values.
       --    i. '0' for elements created before the fix for 4143803
       --   ii. '-9' for elements created after the fix for 4143803
       -- Bug 4758841
       -- We correct the value of GLB_ALLOWS to
       --    i. '1' if Filing Status was defaulted too
       --   ii. '0' if Filing Status was not defaulted

        b_default_flag := FALSE;
        if ALLOWS = 0 then
            open c_get_allowance_value('Allowances');
            fetch c_get_allowance_value into lv_allow_value;
            close c_get_allowance_value;

            -- If Allowances was defaulted then correct the default value to 1
            if lv_allow_value is NULL then
                b_default_flag := TRUE;
            end if;
        elsif ALLOWS = -9 then
            b_default_flag := TRUE;
        end if;

        -- Default value for Allowances. Modify here if the default value
        -- changes in future for Allowances
        -- Bug 4710692
        if b_default_flag then
           if lv_filing_status is NULL then
               GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID) := 1;
               hr_utility.trace('Defaulting Allowances for Tax Levy to ' || GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID));
           else
               GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID) := 0;
               hr_utility.trace('Defaulting Allowances for Tax Levy to ' || GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID));
           end if; -- if lv_filing_status
        end if; -- if b_default_flag

    end if;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Return values ....');
        hr_utility.trace('ADDITIONAL_ASG_GRE_LTD = '||ADDITIONAL_ASG_GRE_LTD);
        hr_utility.trace('REPLACEMENT_ASG_GRE_LTD = '||REPLACEMENT_ASG_GRE_LTD);
        hr_utility.trace('ACCRUED_ASG_LTD = '||ACCRUED_ASG_LTD);
        hr_utility.trace('FEES_ENTRY_PTD = '||FEES_ENTRY_PTD);
        hr_utility.trace('FEES_ENTRY_ITD = '||FEES_ENTRY_ITD);
        hr_utility.trace('FEES_ENTRY_MONTH = '||FEES_ENTRY_MONTH);
        hr_utility.trace('DATE_SERVED = '||DATE_SERVED);
        --hr_utility.trace('VOLDEDNS_AT_WRIT = '||VOLDEDNS_AT_WRIT);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
    END IF;

    hr_utility.trace('Leaving '||l_proc_name);
    RETURN (0);
END BASE_FORMULA;


  /****************************************************************************
    Name        : CAL_FORMULA_SS
    Description : This function performs DI calculation for involuntary
                  deduction elements of type AY/CS/SS. This function also
                  distributes the deducted amount over different elements
                  according to the proration rule defined.
  *****************************************************************************/

FUNCTION CAL_FORMULA_SS
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    GARN_EXEMPTION_CALC_RULE varchar2,
    GARN_EXMPT_DEP_CALC_RULE varchar2,
    GARN_EXEMPTION_DI_PCT number,
    GARN_EXMPT_DI_PCT_IN_ARR number,
    GARN_EXMPT_DI_PCT_DEP number,
    GARN_EXMPT_DI_PCT_DEP_IN_ARR number,
    GARN_EXEMPTION_MIN_WAGE_FACTOR number,
    GARN_EXEMPTION_AMOUNT_VALUE number,
    GARN_EXMPT_DEP_AMT_VAL number,
    GARN_EXMPT_ADDL_DEP_AMT_VAL number,
    GARN_EXEMPTION_PRORATION_RULE varchar2,
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_PCT_CURRENT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE  date,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    ASG_FREQ varchar2,
    REGULAR_EARNINGS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    DI_SUBJ_TAX_JD_ASG_GRE_RUN number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN number,
    DI_SUBJ_TAX_ASG_GRE_RUN number,
    PRE_TAX_SUBJ_TX_ASG_GRE_RUN number,
    PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    JURISDICTION varchar2,
    TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    ARREARS_AMOUNT_BALANCE number,
    SUPPORT_OTHER_FAMILY varchar2,
    ACCRUED_FEES number,
    PTD_FEE_BALANCE number,
    MONTH_FEE_BALANCE number,
    TAX_LEVIES_ASG_GRE_RUN number,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    CHILD_SUPP_COUNT_ASG_GRE_RUN number,
    CHILD_SUPP_TOT_DED_ASG_GRE_RUN IN OUT NOCOPY number,
    CHILD_SUPP_TOT_FEE_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_ITD number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    GARN_FEE_TAKE_FEE_ON_PRORATION varchar2,
    ARREARS_AMT IN OUT NOCOPY number,
    DIFF_DEDN_AMT IN OUT NOCOPY number,
    DIFF_FEE_AMT IN OUT NOCOPY number,
    NOT_TAKEN IN OUT NOCOPY number,
    SF_ACCRUED_FEES IN OUT NOCOPY number,
    STOP_ENTRY IN OUT NOCOPY varchar2,
    TO_COUNT IN OUT NOCOPY number,
    TO_TOTAL_OWED IN OUT NOCOPY number,
    WH_DEDN_AMT IN OUT NOCOPY number,
    WH_FEE_AMT IN OUT NOCOPY number,
    FATAL_MESG IN OUT NOCOPY varchar2,
    MESG IN OUT NOCOPY varchar2,
    CALC_SUBPRIO OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    TO_ADDL OUT NOCOPY number,
    EIC_ADVANCE_ASG_GRE_RUN number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN        number  default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN       number  default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN    number  default 0

) RETURN number IS

    default_date date;
    default_string varchar2(11);
    default_number number;
    default_fee    number;
    c_Gross_Subject_to_Garn number;
    c_Balance_Subject_to_Garn number;
    c_Fed_Supp_xmpt_wks_in_Arrs number;
    c_Federal_Minimum_Wage number;
    dedn_amt number;
    calcd_arrears number;
    Total_DI number;
    fed_criteria_pct_prd_di_xmpt number;
    days_in_arrears number;
    fed_criteria_minwage_exemption number;
    fed_criteria_exemption number;
    DI_state_exemption_amt number;
    DI_state_dependents_exemption number;
    DI_state_weekly_exemption_amt number;
    DI_state_addl_pct_exempt number;
    DI_total_state_exemption number;
    DI_total_exemption number;
    DI_NC_exemption_amt_55 number;
    di_subj_NC45 number;
    DI_NC_exemption_amt_50 number;
    di_subj_nc50 number;
    supp_other_family varchar2(5);
    subject_disposable_income number;
    calcd_dedn_amt number;
    proration_rule varchar2(100);
    verify_dedn_amt number;
    verify_fee_amt number;
    verify_arrears_amt number;
    di_subj number;
    verify_jd_code varchar2(20);
    prim_bal number;
    total_owed_amt number;
    verif_date_served date;
    pr_accrued_fees number;
    pr_ptd_fee_bal number;
    pr_month_fee_bal number;
    dedn_ok varchar2(5);
    total_fees_run number;
    total_support_run number;
    total_child_supp_deduction number;
    excess_amt number;
    equal_dedn_amounts number;
    proportional_dedn_amount number;
    garn_days number;
    garn_days_end_per number;
    vf_calc_subprio number;
    vf_dedn_amt number;
    vf_di_subj number;
    vf_jd_code varchar2(20);
    vf_arrears_amount number;
    vf_fee_amt number;
    vf_prim_bal number;
    vf_total_owed_amt number;
    vf_date_served date;
    vf_di_subject_45 number;
    vf_di_subject_50 number;
    vf_supp_other_family varchar2(1);
    vf_accrued_fees number;
    vf_month_fee_bal number;
    vf_ptd_fee_bal number;
    fed_criteria_pct_wk_di_xmpt number;
    DI_state_wk_dep_exmpt number;
    DI_NC_weekly_exemption_amt_55 number;
    DI_NC_tot_prd_exmpt_55 number;
    DI_NC_weekly_exemption_amt_50 number;
    DI_NC_tot_prd_exmpt_50 number;
    DI_total_period_exemption number;
    calcd_fee number;
    garn_limit_days number;
    weekly_total_di number;
    vf_di_subj_arr number;
    total_support_run_arr number;
    wh_dedn_amt_arr number;
    vf_dedn_amt_arr number;
    INV_DED_OVR_GRN_EX_DI_PCT number;
    INV_DED_OVR_GRN_EX_DI_PCT_ARR number;
    INV_DED_OVR_GRN_EX_DI_PCT_DEP number;
    INV_DED_GRN_EX_DI_PCT_DEP_ARR number;

    amount number;
    arrears_dedn_amount number;
    date_in_arrears date;
    num_dependents number;
    filing_status varchar2(10);
    allowances number;
    dedns_at_time_of_writ number;
    percentage number;
    monthly_cap_amount number;
    month_to_date_balance number;
    period_cap_amount number;
    period_to_date_balance number;
    accrued_fee_correction number;
    cntr number;

    sub_prio_max number;
    calc_subprio_max number;
    l_debug_on varchar2(1);
    l_proc_name varchar2(50);
    l_proration_ovrd varchar2(15);
    l_garn_fee_max_fee_amt number;
    l_ini_fee_flag varchar2(10);
    lv_ele_name varchar2(100);
    ld_override_date date;

    CURSOR cur_debug is
        SELECT parameter_value
          FROM pay_action_parameters
         WHERE parameter_name = 'GARN_DEBUG_ON';

    CURSOR csr_get_ovrd_values(c_override_date date) is
        SELECT nvl(entry_information4, default_number),
               nvl(entry_information5, default_number),
               nvl(entry_information6, default_number),
               nvl(entry_information7, default_number)
          FROM pay_element_entries_f
         WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
           AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
           AND c_override_date BETWEEN effective_start_date and effective_end_date;

    /*-- Cursor for Bug 3704744 --*/
    CURSOR csr_get_proration_ovrd is
        select aei.aei_information3
          from per_assignment_extra_info aei,
               pay_element_entries_f pee
         where aei.assignment_id = pee.assignment_id
           and aei.information_type = 'US_PRORATION_RULE'
           and aei.aei_information_category = 'US_PRORATION_RULE'
           and aei.aei_information2 = garn_cat
           and substr(aei.aei_information1, 1, 2) = substr(P_CTX_JURISDICTION_CODE, 1, 2)
           and pee.element_entry_id = P_CTX_ORIGINAL_ENTRY_ID ;

    /* Cursot to return the Initial Fee Flag value Bug 3549298 */
    CURSOR csr_get_ini_fee_flag is
    SELECT nvl(entry_information9, 'N')
      FROM pay_element_entries_f
     WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
       AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
       AND P_CTX_DATE_EARNED BETWEEN effective_start_date and effective_end_date;


    /* Cursor for Bug 3715182 and 3719168 */
    CURSOR c_garn_max_fee_amt is
    select target.MAX_FEE_AMOUNT from
           PAY_US_GARN_FEE_RULES_F target,
           PAY_ELEMENT_TYPES_F pet
    WHERE target.state_code = substr(P_CTX_JURISDICTION_CODE,1,2)
      AND target.garn_category = pet.element_information1
      AND P_CTX_DATE_EARNED BETWEEN target.effective_start_date
                                AND target.effective_end_date
      AND pet.element_type_id = P_CTX_ELEMENT_TYPE_ID
      AND P_CTX_DATE_EARNED BETWEEN pet.effective_start_date
                                AND pet.effective_end_date;


    -- Bug 4079142
    -- Cursor to get the element name to be used in the message.
    CURSOR csr_get_ele_name (p_ele_type_id number) is
    select rtrim(element_name,' Calculator' )
      from pay_element_types_f
     where element_type_id = p_ele_type_id;

     -- Bug# 6132855
     -- Federal Minimum Wage now is stored in JIT table
     CURSOR c_get_federal_min_wage IS
     SELECT fed_information1
       FROM pay_us_federal_tax_info_f
      WHERE fed_information_category = 'WAGEATTACH LIMIT'
        AND P_CTX_DATE_EARNED BETWEEN effective_start_date
                                  AND effective_end_date;

BEGIN
    l_proc_name := l_package_name||'CAL_FORMULA_SS';
    hr_utility.trace('Entering '||l_proc_name);

    default_date := fnd_date.canonical_to_date('0001/01/01');
    default_string := 'NOT ENTERED';
    default_number := -9999;
    INV_DED_OVR_GRN_EX_DI_PCT := default_number;
    INV_DED_OVR_GRN_EX_DI_PCT_ARR := default_number;
    INV_DED_OVR_GRN_EX_DI_PCT_DEP := default_number;
    INV_DED_GRN_EX_DI_PCT_DEP_ARR := default_number;
    amount := GLB_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    arrears_dedn_amount := GLB_ARREARS_OVERRIDE(P_CTX_ORIGINAL_ENTRY_ID);
    date_in_arrears := GLB_ARREARS_DATE(P_CTX_ORIGINAL_ENTRY_ID);
    num_dependents := GLB_NUM_DEPS(P_CTX_ORIGINAL_ENTRY_ID);
    filing_status := GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID);
    allowances := GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID);
    dedns_at_time_of_writ := GLB_DEDN_OVERRIDE(P_CTX_ORIGINAL_ENTRY_ID);
    percentage := GLB_PCT(P_CTX_ORIGINAL_ENTRY_ID);
    monthly_cap_amount := GLB_MONTH_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    month_to_date_balance := GLB_MTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);
    period_cap_amount := GLB_PTD_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    period_to_date_balance := GLB_PTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);
    accrued_fee_correction := GLB_TO_ACCRUED_FEES(P_CTX_ORIGINAL_ENTRY_ID);
    sub_prio_max := 9999;
    calc_subprio_max := 1000000;
    l_garn_fee_max_fee_amt := NULL;
    default_fee := 99999999;

    OPEN cur_debug;
        FETCH cur_debug into l_debug_on;
    CLOSE cur_debug;

    /* Fetch the value of Initial Fee Flag value. Bug 3549298 */
    open csr_get_ini_fee_flag;
    fetch csr_get_ini_fee_flag into l_ini_fee_flag;
    close csr_get_ini_fee_flag;

    -- Fetching Federal Minimum Wage Value from JIT table
    OPEN c_get_federal_min_wage;
    FETCH c_get_federal_min_wage INTO c_Federal_Minimum_Wage;
    CLOSE c_get_federal_min_wage;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Input parameters....');
        hr_utility.trace('P_CTX_BUSINESS_GROUP_ID = '||P_CTX_BUSINESS_GROUP_ID);
        hr_utility.trace('P_CTX_PAYROLL_ID = '||P_CTX_PAYROLL_ID);
        hr_utility.trace('P_CTX_ELEMENT_TYPE_ID = '||P_CTX_ELEMENT_TYPE_ID);
        hr_utility.trace('P_CTX_ORIGINAL_ENTRY_ID = '||P_CTX_ORIGINAL_ENTRY_ID);
        hr_utility.trace('P_CTX_DATE_EARNED = '||P_CTX_DATE_EARNED);
        hr_utility.trace('P_CTX_JURISDICTION_CODE = '||P_CTX_JURISDICTION_CODE);
        hr_utility.trace('P_CTX_ELEMENT_ENTRY_ID = '||P_CTX_ELEMENT_ENTRY_ID);
        hr_utility.trace('GARN_EXEMPTION_CALC_RULE = '||GARN_EXEMPTION_CALC_RULE);
        hr_utility.trace('GARN_EXMPT_DEP_CALC_RULE = '||GARN_EXMPT_DEP_CALC_RULE);
        hr_utility.trace('GARN_EXEMPTION_DI_PCT = '||GARN_EXEMPTION_DI_PCT);
        hr_utility.trace('GARN_EXMPT_DI_PCT_IN_ARR = '||GARN_EXMPT_DI_PCT_IN_ARR);
        hr_utility.trace('GARN_EXMPT_DI_PCT_DEP = '||GARN_EXMPT_DI_PCT_DEP);
        hr_utility.trace('GARN_EXMPT_DI_PCT_DEP_IN_ARR = '||GARN_EXMPT_DI_PCT_DEP_IN_ARR);
        hr_utility.trace('GARN_EXEMPTION_MIN_WAGE_FACTOR = '||GARN_EXEMPTION_MIN_WAGE_FACTOR);
        hr_utility.trace('GARN_EXEMPTION_AMOUNT_VALUE = '||GARN_EXEMPTION_AMOUNT_VALUE);
        hr_utility.trace('GARN_EXMPT_DEP_AMT_VAL = '||GARN_EXMPT_DEP_AMT_VAL);
        hr_utility.trace('GARN_EXMPT_ADDL_DEP_AMT_VAL = '||GARN_EXMPT_ADDL_DEP_AMT_VAL);
        hr_utility.trace('GARN_EXEMPTION_PRORATION_RULE = '||GARN_EXEMPTION_PRORATION_RULE);
        hr_utility.trace('GARN_FEE_FEE_RULE = '||GARN_FEE_FEE_RULE);
        hr_utility.trace('GARN_FEE_FEE_AMOUNT = '||GARN_FEE_FEE_AMOUNT);
        hr_utility.trace('GARN_FEE_ADDL_GARN_FEE_AMOUNT = '||GARN_FEE_ADDL_GARN_FEE_AMOUNT);
        hr_utility.trace('GARN_FEE_PCT_CURRENT = '||GARN_FEE_PCT_CURRENT);
        hr_utility.trace('GARN_FEE_MAX_FEE_AMOUNT = '||GARN_FEE_MAX_FEE_AMOUNT);
        hr_utility.trace('PAY_EARNED_START_DATE = '||PAY_EARNED_START_DATE);
        hr_utility.trace('PAY_EARNED_END_DATE = '||PAY_EARNED_END_DATE);
        hr_utility.trace('SCL_ASG_US_WORK_SCHEDULE = '||SCL_ASG_US_WORK_SCHEDULE);
        hr_utility.trace('ASG_HOURS = '||ASG_HOURS);
        hr_utility.trace('ASG_FREQ = '||ASG_FREQ);
        hr_utility.trace('REGULAR_EARNINGS_ASG_GRE_RUN = '||REGULAR_EARNINGS_ASG_GRE_RUN);
        hr_utility.trace('NET_ASG_GRE_RUN = '||NET_ASG_GRE_RUN);
        hr_utility.trace('DI_SUBJ_TAX_JD_ASG_GRE_RUN = '||DI_SUBJ_TAX_JD_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_DEDUCTIONS_ASG_GRE_RUN = '||PRE_TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('DI_SUBJ_TAX_ASG_GRE_RUN = '||DI_SUBJ_TAX_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_SUBJ_TX_ASG_GRE_RUN = '||PRE_TAX_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN = '||PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('TAX_DEDUCTIONS_ASG_GRE_RUN = '||TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('GARN_TOTAL_FEES_ASG_GRE_RUN = '||GARN_TOTAL_FEES_ASG_GRE_RUN);
        hr_utility.trace('JURISDICTION = '||JURISDICTION);
        hr_utility.trace('TOTAL_OWED = '||TOTAL_OWED);
        hr_utility.trace('DATE_SERVED = '||DATE_SERVED);
        hr_utility.trace('ADDITIONAL_AMOUNT_BALANCE = '||ADDITIONAL_AMOUNT_BALANCE);
        hr_utility.trace('REPLACEMENT_AMOUNT_BALANCE = '||REPLACEMENT_AMOUNT_BALANCE);
        hr_utility.trace('PRIMARY_AMOUNT_BALANCE = '||PRIMARY_AMOUNT_BALANCE);
        hr_utility.trace('ARREARS_AMOUNT_BALANCE = '||ARREARS_AMOUNT_BALANCE);
        hr_utility.trace('SUPPORT_OTHER_FAMILY = '||SUPPORT_OTHER_FAMILY);
        hr_utility.trace('ACCRUED_FEES = '||ACCRUED_FEES);
        hr_utility.trace('PTD_FEE_BALANCE = '||PTD_FEE_BALANCE);
        hr_utility.trace('MONTH_FEE_BALANCE = '||MONTH_FEE_BALANCE);
        hr_utility.trace('TAX_LEVIES_ASG_GRE_RUN = '||TAX_LEVIES_ASG_GRE_RUN);
        hr_utility.trace('TERMINATED_EMPLOYEE = '||TERMINATED_EMPLOYEE);
        hr_utility.trace('FINAL_PAY_PROCESSED = '||FINAL_PAY_PROCESSED);
        hr_utility.trace('CHILD_SUPP_COUNT_ASG_GRE_RUN = '||CHILD_SUPP_COUNT_ASG_GRE_RUN);
        hr_utility.trace('CHILD_SUPP_TOT_DED_ASG_GRE_RUN = '||CHILD_SUPP_TOT_DED_ASG_GRE_RUN);
        hr_utility.trace('CHILD_SUPP_TOT_FEE_ASG_GRE_RUN = '||CHILD_SUPP_TOT_FEE_ASG_GRE_RUN);
        hr_utility.trace('TOTAL_WITHHELD_FEE_ASG_GRE_RUN = '||GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN);
        hr_utility.trace('TOTAL_WITHHELD_FEE_ASG_GRE_ITD = '||TOTAL_WITHHELD_FEE_ASG_GRE_ITD);
        hr_utility.trace('TOT_WHLD_SUPP_ASG_GRE_RUN = '||TOT_WHLD_SUPP_ASG_GRE_RUN);
        hr_utility.trace('GARN_FEE_TAKE_FEE_ON_PRORATION = '||GARN_FEE_TAKE_FEE_ON_PRORATION);
        hr_utility.trace('ARREARS_AMT = '||ARREARS_AMT);
        hr_utility.trace('DIFF_DEDN_AMT = '||DIFF_DEDN_AMT);
        hr_utility.trace('DIFF_FEE_AMT = '||DIFF_FEE_AMT);
        hr_utility.trace('NOT_TAKEN = '||NOT_TAKEN);
        hr_utility.trace('SF_ACCRUED_FEES = '||SF_ACCRUED_FEES);
        hr_utility.trace('STOP_ENTRY = '||STOP_ENTRY);
        hr_utility.trace('TO_COUNT = '||TO_COUNT);
        hr_utility.trace('TO_TOTAL_OWED = '||TO_TOTAL_OWED);
        hr_utility.trace('WH_DEDN_AMT = '||WH_DEDN_AMT);
        hr_utility.trace('WH_FEE_AMT = '||WH_FEE_AMT);
        hr_utility.trace('FATAL_MESG = '||FATAL_MESG);
        hr_utility.trace('MESG = '||MESG);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
        hr_utility.trace('TO_REPL = '||TO_REPL);
        hr_utility.trace('TO_ADDL = '||TO_ADDL);
        hr_utility.trace('EIC_ADVANCE_ASG_GRE_RUN = ' || EIC_ADVANCE_ASG_GRE_RUN);
        hr_utility.trace('INITIAL FEE FLAG ' || l_ini_fee_flag);
        hr_utility.trace('VOL_DEDN_ROTH_ASG_GRE_RUN = ' || VOL_DEDN_ROTH_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_JD_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('c_Federal_Minimum_Wage = ' || c_Federal_Minimum_Wage);
    END IF;


    /*--------- Set Contexts -------------*/
    CTX_BUSINESS_GROUP_ID := P_CTX_BUSINESS_GROUP_ID;
    CTX_PAYROLL_ID        := P_CTX_PAYROLL_ID;
    CTX_ELEMENT_TYPE_ID   := P_CTX_ELEMENT_TYPE_ID;
    CTX_ORIGINAL_ENTRY_ID := P_CTX_ORIGINAL_ENTRY_ID;
    CTX_DATE_EARNED       := P_CTX_DATE_EARNED;
    CTX_JURISDICTION_CODE := P_CTX_JURISDICTION_CODE;
    CTX_ELEMENT_ENTRY_ID  := P_CTX_ELEMENT_ENTRY_ID;
    /*------------------------------------*/

    GLB_NUM_ELEM := GLB_NUM_ELEM - 1;
    hr_utility.trace('GLB_NUM_ELEM = '|| GLB_NUM_ELEM);

    calc_subprio := entry_subpriority;

    c_Gross_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN
	                	       +LEAST(DI_SUBJ_TAX_JD_ASG_GRE_RUN, DI_SUBJ_TAX_ASG_GRE_RUN));

    -- Bug 4858720
    -- Use EIC_ADVANCE_ASG_GRE_RUN for calculatin the Deduction amount
    -- Bug# 4676867
    c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                  LEAST(DI_SUBJ_TAX_JD_ASG_GRE_RUN, DI_SUBJ_TAX_ASG_GRE_RUN)) -
                                 ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                 + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN -
                                 (LEAST(PRE_TAX_SUBJ_TX_JD_ASG_GRE_RUN,
                                  PRE_TAX_SUBJ_TX_ASG_GRE_RUN )))
                                 + (VOL_DEDN_ROTH_ASG_GRE_RUN -
                                   (LEAST(VOL_DEDN_SB_TX_ASG_GRE_RUN,
                                         VOL_DEDN_SB_TX_JD_ASG_GRE_RUN)))
                                  );

    c_Fed_Supp_xmpt_wks_in_Arrs := 12;  /* Multiply times 7 for days. */
    --c_Federal_Minimum_Wage := 5.15;  /* Current as of July 1996 */

    -- Bug 3800845
    -- Use the maximum of the 'Date Earned' and 'End Date' for finding
    -- the override values
    if P_CTX_DATE_EARNED > PAY_EARNED_END_DATE then
        ld_override_date := P_CTX_DATE_EARNED;
    else
        ld_override_date := PAY_EARNED_END_DATE;
    end if;

    /*-- Obtain overriding values --*/
    OPEN csr_get_ovrd_values(ld_override_date);
        FETCH csr_get_ovrd_values INTO
            INV_DED_OVR_GRN_EX_DI_PCT,
            INV_DED_OVR_GRN_EX_DI_PCT_ARR,
            INV_DED_OVR_GRN_EX_DI_PCT_DEP,
            INV_DED_GRN_EX_DI_PCT_DEP_ARR;
    CLOSE csr_get_ovrd_values;

    -- Bug 4079142
    -- Get the element name to be used in the message.
    open csr_get_ele_name(CTX_ELEMENT_TYPE_ID);
    fetch csr_get_ele_name into lv_ele_name;
    close csr_get_ele_name;

    /* Bug 3715182 and 3719168
     * Get the GARN_FEE_MAX_FEE_AMOUNT
     */
    open c_garn_max_fee_amt;
    fetch c_garn_max_fee_amt into l_garn_fee_max_fee_amt;
    close c_garn_max_fee_amt;

    if l_garn_fee_max_fee_amt is NULL then
       l_garn_fee_max_fee_amt := default_fee;
    else
       l_garn_fee_max_fee_amt := GARN_FEE_MAX_FEE_AMOUNT;
    end if;

/* *** Support calculation section BEGIN *** */
/*
   1. Find DISPOSABLE INCOME
      Calculate DI balance for child support according to current
      earnings and subject rules (ie. implemented via taxability rules).
   2. Calculate disposable income exemption according to:
      2.1 Standard federal criteria, ie. % Weekly DI and factor of minwage
          unless override exemption percentage is entered through
          element entries. Then use override exemption percentage.
      2.2 State specific legislation.
      2.3 Calculate disposable income exemption resulting from dependents.
      2.4 The most favorable exemption to employee is used.
   3. Calculate Subject_DISPOSABLE_INCOME = DI(#1) - #2 - #3 - Levies in place.
   4. Calculate total_child_supp_deduction = dedn_amt +
                                              CHILD_SUPP_TOT_DED_ASG_GRE_RUN
*/

    /* Step #1 */

    Total_DI := c_Balance_Subject_to_Garn;

    -- Bug 4079142
    -- Saving Total DI for use in DCIA deduction calculation
    if GLB_SUPPORT_DI is NULL then
       GLB_SUPPORT_DI := Total_DI;
    end if;

    /* Step #2 */
    /* NOTE: 95% child support exemptions are calculated by fed criteria only. */
    /* Step #2.1 Child support exemption by federal criteria. */

    IF Arrears_Amount_Balance = 0 THEN
        IF Support_Other_Family = 'N' THEN
            IF INV_DED_OVR_GRN_EX_DI_PCT = default_number THEN
                fed_criteria_pct_prd_di_xmpt := (GARN_EXEMPTION_DI_PCT / 100) * Total_DI;
            ELSE
                fed_criteria_pct_prd_di_xmpt := (TO_NUMBER(INV_DED_OVR_GRN_EX_DI_PCT) / 100) * Total_DI;
            END IF;

        ELSE
            IF INV_DED_OVR_GRN_EX_DI_PCT_DEP = default_number THEN
                fed_criteria_pct_prd_di_xmpt := (GARN_EXMPT_DI_PCT_DEP / 100) * Total_DI;
            ELSE
                fed_criteria_pct_prd_di_xmpt := (TO_NUMBER(INV_DED_OVR_GRN_EX_DI_PCT_DEP) / 100) * Total_DI;
            END IF;
        END IF;
/*
    Else need to check balance in arrears against 12 weeks normal support payments.
    Are we sure this is the federal requirement?
    We could document NOT TO ENTER an arrears balance unless it were 12 weeks or more,
    in which case the current code would suffice...otherwise, convert the current period Amount
    (if any) to a weekly amount and multiply by 12; compare this figure with arrearage, make
    exemption percentage decision based on this comparison.
*/
    ELSIF Support_Other_Family = 'N' THEN
    -- Removed the Arrears date check as now court determines when arrears exist and
    -- issue a new order to the employer
    -- Bug 3692468
       IF INV_DED_OVR_GRN_EX_DI_PCT_ARR = default_number THEN
          fed_criteria_pct_prd_di_xmpt := (GARN_EXMPT_DI_PCT_IN_ARR / 100) * Total_DI;
       ELSE
          fed_criteria_pct_prd_di_xmpt := (TO_NUMBER(INV_DED_OVR_GRN_EX_DI_PCT_ARR) / 100) * Total_DI;
       END IF;
    ELSE
    -- Removed the Arrears date check as now court determines when arrears exist and
    -- issue a new order to the employer
    -- Bug 3692468
       IF INV_DED_GRN_EX_DI_PCT_DEP_ARR = default_number THEN
          fed_criteria_pct_prd_di_xmpt := (GARN_EXMPT_DI_PCT_DEP_IN_ARR / 100) * Total_DI;
       ELSE
          fed_criteria_pct_prd_di_xmpt := (TO_NUMBER(INV_DED_GRN_EX_DI_PCT_DEP_ARR) / 100) * Total_DI;
       END IF;
    END IF;

    fed_criteria_pct_wk_di_xmpt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        fed_criteria_pct_prd_di_xmpt,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

    fed_criteria_minwage_exemption := GARN_EXEMPTION_MIN_WAGE_FACTOR * c_Federal_Minimum_Wage;

    fed_criteria_exemption := GREATEST(fed_criteria_pct_wk_di_xmpt, fed_criteria_minwage_exemption);

    hr_utility.trace('fed_criteria_pct_wk_di_xmpt = '||fed_criteria_pct_wk_di_xmpt);
    hr_utility.trace('fed_criteria_minwage_exemption = '||fed_criteria_minwage_exemption);

    /* Step #2.2 Child support exemption by state specific criteria. */

    DI_state_exemption_amt := 0;
    DI_state_dependents_exemption := 0;
    DI_state_weekly_exemption_amt := 0;
    DI_state_wk_dep_exmpt := 0;

    IF GARN_EXEMPTION_CALC_RULE = 'FEDRULE' THEN
        DI_state_weekly_exemption_amt := 0;
    ELSIF GARN_EXEMPTION_CALC_RULE = 'FLAT_AMT' THEN
        weekly_total_di := 0;
        IF SUBSTR(Jurisdiction, 1, 2) = '07' THEN
            /*weekly_total_DI calculated for  Bug 3561416*/
            weekly_total_di := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                   ASG_HOURS,
                                                   Total_DI,
                                                   'NOT ENTERED',
                                                   'WEEK',
                                                   PAY_EARNED_START_DATE,
                                                   PAY_EARNED_END_DATE,
	                                               ASG_FREQ);

            IF weekly_total_di  <= GARN_EXEMPTION_AMOUNT_VALUE THEN
                DI_state_weekly_exemption_amt := ( weekly_total_di * 85 /100 );
            ELSE
                DI_state_weekly_exemption_amt := ( GARN_EXEMPTION_AMOUNT_VALUE * 85 /100 );
            END IF;
        END IF;
    END IF;

    IF SUBSTR(Jurisdiction,1,2) <> '07' /*not equal to Connecticut*/ THEN
     /* This is quite exceptional case
       - ie. only CT specifies a $ amount exemption!
     */
        DI_state_weekly_exemption_amt := GARN_EXEMPTION_AMOUNT_VALUE;
    END IF;

/* Step #2.3 : Note for child supports, this is also quite exceptional
               processing; currently only Deleware and Washington grant
               additional exemption amounts for having dependents.
*/

    IF GARN_EXMPT_DEP_CALC_RULE <> 'NONE' THEN
        IF GARN_EXMPT_DEP_CALC_RULE = 'FLAT_PCT' THEN
            DI_state_addl_pct_exempt := GARN_EXMPT_DEP_AMT_VAL * Num_Dependents;
            DI_state_dependents_exemption := (DI_state_addl_pct_exempt / 100) * Total_DI;
            DI_state_wk_dep_exmpt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                         ASG_HOURS,
                                                         DI_state_dependents_exemption,
                                                         'NOT ENTERED',
                                                         'WEEK',
                                                         PAY_EARNED_START_DATE,
                                                         PAY_EARNED_END_DATE,
                                                         ASG_FREQ);
        ELSIF GARN_EXMPT_DEP_CALC_RULE = 'FLAT_AMT' THEN
            DI_state_wk_dep_exmpt := GARN_EXMPT_DEP_AMT_VAL * Num_Dependents;

        ELSIF GARN_EXMPT_DEP_CALC_RULE = 'FLAT_AMT_ADDL' THEN
            DI_state_wk_dep_exmpt := GARN_EXMPT_DEP_AMT_VAL +
                                    (GARN_EXMPT_ADDL_DEP_AMT_VAL *
                                    (Num_Dependents - 1));

        ELSIF GARN_EXMPT_DEP_CALC_RULE = 'FLAT_PCT_ADDL' THEN
            DI_state_addl_pct_exempt := GARN_EXMPT_DEP_AMT_VAL +
                                       (GARN_EXMPT_ADDL_DEP_AMT_VAL *
                                       (Num_Dependents - 1));
            DI_state_dependents_exemption := (DI_state_addl_pct_exempt / 100) * Total_DI;
            DI_state_wk_dep_exmpt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                         ASG_HOURS,
                                                         DI_state_dependents_exemption,
                                                         'NOT ENTERED',
                                                         'WEEK',
                                                         PAY_EARNED_START_DATE,
                                                         PAY_EARNED_END_DATE,
                                                         ASG_FREQ);
        END IF;
    END IF;


    DI_total_state_exemption := DI_state_weekly_exemption_amt +
                                DI_state_wk_dep_exmpt;

/* Step #2.4 */

    DI_total_exemption := GREATEST(fed_criteria_exemption,
                                   DI_total_state_exemption);

    hr_utility.trace('fed_criteria_exemption = '||fed_criteria_exemption);
    hr_utility.trace('DI_total_state_exemption = '||DI_total_state_exemption);

    IF SUBSTR(Jurisdiction, 1, 2) = '34' THEN
  /* Special state exemption calculation for North Carolina */
        DI_NC_exemption_amt_55 := (55 / 100) * Total_DI;
        DI_NC_weekly_exemption_amt_55 := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                             ASG_HOURS,
                                                             DI_NC_exemption_amt_55,
                                                             'NOT ENTERED',
                                                             'WEEK',
                                                             PAY_EARNED_START_DATE,
                                                             PAY_EARNED_END_DATE,
                                                             ASG_FREQ);

        DI_NC_tot_prd_exmpt_55 := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                      ASG_HOURS,
                                                      DI_NC_weekly_exemption_amt_55,
                                                      'WEEK',
                                                      'NOT ENTERED',
                                                      PAY_EARNED_START_DATE,
                                                      PAY_EARNED_END_DATE,
                                                      ASG_FREQ);

        di_subj_NC45 := Total_DI - DI_NC_tot_prd_exmpt_55;
        DI_NC_exemption_amt_50 := (50 / 100) * Total_DI;

        DI_NC_weekly_exemption_amt_50 := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                             ASG_HOURS,
                                                             DI_NC_exemption_amt_50,
                                                             'NOT ENTERED',
                                                             'WEEK',
                                                             PAY_EARNED_START_DATE,
                                                             PAY_EARNED_END_DATE,
                                                             ASG_FREQ);

        DI_NC_tot_prd_exmpt_50 := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                      ASG_HOURS,
                                                      DI_NC_weekly_exemption_amt_50,
                                                      'WEEK',
                                                      'NOT ENTERED',
                                                      PAY_EARNED_START_DATE,
                                                      PAY_EARNED_END_DATE,
                                                      ASG_FREQ);

        di_subj_NC50 := Total_DI - DI_NC_tot_prd_exmpt_50;
    END IF;
/* Step #3 */
    supp_other_family := Support_Other_Family;

    /* The exemption amount so far is the amount exempt PER WEEK!
       So we convert it to a PER PAY PERIOD figure for calculating Subject DI. */

    DI_total_period_exemption := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                     ASG_HOURS,
                                                     DI_total_exemption,
                                                     'WEEK',
                                                     'NOT ENTERED',
                                                     PAY_EARNED_START_DATE,
                                                     PAY_EARNED_END_DATE,
                                                     ASG_FREQ);

    hr_utility.trace('DI_total_period_exemption = '||DI_total_period_exemption);
    hr_utility.trace('DI_total_exemption = '||DI_total_exemption);

    Subject_DISPOSABLE_INCOME := Total_DI - DI_total_period_exemption;

    IF Total_Owed <> 0 THEN
        IF Primary_Amount_Balance - Period_to_date_balance < 0 THEN
            mesg := 'Total Owed already reached, no child support being withheld for ' || lv_ele_name || '.';
            dedn_amt := 0;
            calcd_dedn_amt := dedn_amt;
            calcd_fee := 0;
            calcd_arrears := 0;
            not_taken := 0;
            Subject_DISPOSABLE_INCOME := 0;
            di_subj_NC45 := 0;
            di_subj_NC50 := 0;
            to_count := 1;

            proration_rule := GARN_EXEMPTION_PRORATION_RULE;
            verify_dedn_amt := dedn_amt;
            verify_fee_amt := calcd_fee;
            verify_arrears_amt := 0;
            di_subj := Subject_DISPOSABLE_INCOME;
            verify_jd_code := Jurisdiction;
            prim_bal := Primary_Amount_Balance;
            total_owed_amt := Total_Owed;
            verif_date_served := Date_Served;
            sf_accrued_fees := accrued_fee_correction;
        END IF;
    END IF;

    IF Subject_DISPOSABLE_INCOME <= 0 THEN
        mesg := 'Disposable income is less than federal exemption, no child support being withheld for ' || lv_ele_name || '.';
        dedn_amt := 0;
        calcd_dedn_amt := dedn_amt;
        calcd_fee := 0;
        calcd_arrears := 0;
        not_taken := 0;
        Subject_DISPOSABLE_INCOME := 0;
        di_subj_NC45 := 0;
        di_subj_NC50 := 0;
        to_count := 1;

        proration_rule := GARN_EXEMPTION_PRORATION_RULE;
        verify_dedn_amt := dedn_amt;
        verify_fee_amt := calcd_fee;
        verify_arrears_amt := 0;
        di_subj := Subject_DISPOSABLE_INCOME;
        verify_jd_code := Jurisdiction;
        prim_bal := Primary_Amount_Balance;
        total_owed_amt := Total_Owed;
        verif_date_served := Date_Served;
        sf_accrued_fees := accrued_fee_correction;
END IF;

/* *** Support calculation section BEGIN *** */


/* 15TH JULY 1996 : NOTICE!!!
NOW that we have both dedn and fee amounts CALCULATED, need to
pass to verification formula for legislative limit checks...
When that is complete, the dedn amount and fee amounts can be
fixed and returned appropriately...ie. to base element pay value
and to fee element primary balance (ie. NOT via pay value for
third party payment reasons).

ALSO need to move negative net and stop entry checks into verification
formula...ie. we can stop the base ele entry via the verifier just as
easily as from the calculator.

THIS IS A CONFIGURATION CHANGE!!!

Total Owed change also...
*/

    to_count := 1;

    calcd_dedn_amt := dedn_tab(P_CTX_ORIGINAL_ENTRY_ID);
    verify_dedn_amt:= dedn_tab(P_CTX_ORIGINAL_ENTRY_ID);
    -- Bug 5149450
    -- Set the value of calcd_dedn_amt and verify_dedn_amt to the
    -- correct value. BASE_FORMULA only calculates an estimated value
    if GLB_AMT_NOT_SPEC(P_CTX_ORIGINAL_ENTRY_ID) then
       if dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) > Subject_DISPOSABLE_INCOME then
          calcd_dedn_amt := Subject_DISPOSABLE_INCOME;
          verify_dedn_amt:= Subject_DISPOSABLE_INCOME;
       end if; -- if
    end if;
    verify_arrears_amt := 0;
    verify_fee_amt := fees_tab(P_CTX_ORIGINAL_ENTRY_ID);
    di_subj := Subject_DISPOSABLE_INCOME;
    verify_jd_code := Jurisdiction;
    prim_bal := Primary_Amount_Balance;
    total_owed_amt := Total_Owed;
    verif_date_served := Date_Served;

    IF Accrued_Fees <> default_number THEN
        PR_Accrued_Fees := Accrued_Fees;
    ELSE
        PR_Accrued_Fees := 0;
    END IF;

    IF PTD_Fee_Balance <> default_number THEN
        PR_PTD_Fee_Bal := PTD_Fee_Balance;
    ELSE
        PR_PTD_Fee_Bal := 0;
    END IF;

    IF Month_Fee_Balance <> default_number THEN
        PR_Month_Fee_Bal := Month_Fee_Balance;
    ELSE
        PR_Month_Fee_Bal := 0;
    END IF;

    sf_accrued_fees := accrued_fee_correction;

    IF DI_SUBJ < CHILD_SUPP_TOT_DED_ASG_GRE_RUN AND
       GARN_EXEMPTION_PRORATION_RULE = 'EQUAL' THEN
        vf_calc_subprio := calc_subprio_max + (VERIFY_DEDN_AMT - DI_SUBJ);
    ELSE
        vf_calc_subprio := CALC_SUBPRIO;
    END IF;

    IF SUBSTR(VERIFY_JD_CODE,1,2) = '34' THEN
        IF CHILD_SUPP_COUNT_ASG_GRE_RUN > 1 THEN
            IF SUPP_OTHER_FAMILY = 'Y' THEN
                DI_SUBJ := DI_SUBJ_NC45;
            ELSE
                DI_SUBJ := DI_SUBJ_NC50;
            END IF;
        END IF;
    END IF;

    DI_SUBJ := DI_SUBJ - TAX_LEVIES_ASG_GRE_RUN;

    IF DI_SUBJ <= 0 THEN
        DI_SUBJ := 0;
    END IF;

    vf_dedn_amt          := VERIFY_DEDN_AMT;
    vf_di_subj           := DI_SUBJ;
    vf_jd_code           := VERIFY_JD_CODE;
    vf_arrears_amount    := VERIFY_ARREARS_AMT;
    vf_fee_amt           := VERIFY_FEE_AMT;
    vf_prim_bal          := PRIM_BAL;
    vf_total_owed_amt    := TOTAL_OWED_AMT;
    vf_date_served       := VERIF_DATE_SERVED;
    vf_di_subject_45     := DI_SUBJ_NC45;
    vf_di_subject_50     := DI_SUBJ_NC50;
    vf_supp_other_family := SUPP_OTHER_FAMILY;

    IF PR_ACCRUED_FEES <> default_number THEN
        VF_Accrued_Fees := PR_ACCRUED_FEES;
    ELSE
        VF_Accrued_Fees := 0;
    END IF;

    IF PR_PTD_FEE_BAL <> default_number THEN
        VF_PTD_Fee_Bal := PR_PTD_FEE_BAL;
    ELSE
        VF_PTD_Fee_Bal := 0;
    END IF;

    IF PR_MONTH_FEE_BAL <> default_number THEN
        VF_Month_Fee_Bal := PR_MONTH_FEE_BAL;
    ELSE
        VF_Month_Fee_Bal := 0;
    END IF;

/*Algorithm:
1.  Check individual support and total support deduction amounts against
    legislative limits.  Also perform negative net checks.
2.  If necessary, check proration rule to recalculate child support
    deductions to either proportionally or equally share available
    disposable income.
3.  Equally: divide available disposable income (ie. Subject_DI) by total
             number of child support payments to be made...
4.  Proportionally: apportion Subject_DI into proportional amounts according
                    to scheduled child support deduction amounts...
                    ie. Subject_DI = 1000; childsupp A = 750;
                        childsupp B = 500;
			Total child supp scheduled = 750 + 500 = 1250.
			Childsupp A's proportion = 750 / 1250 = 60%
			Childsupp B's proportion = 500 / 1250 = 40%
			So divide available DI proportionally makes:
			Childsupp A = 60% of 1000 = 600
			Childsupp B = 40% of 1000 = 400
			Make adjustments to originally calculated amounts as
			appropriate.*/


/* *** Legislative limit verification BEGIN *** */

/*
   Fees have their own legislative limits...check these first
   then check that child support deduction plus fee amount
   is within legislative limits: ie. deduction + fees < DI_Subject

*/
    diff_dedn_amt :=0;
    diff_fee_amt :=0;
    dedn_ok := 'No';

/* Check fee against leg limits... */

/* Check child support fee against legislative maximum for time period. */

    calc_subprio := entry_subpriority;
    IF calc_subprio = 1 THEN
        IF VF_DATE_SERVED <> default_date THEN
            calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - VF_DATE_SERVED);
        END IF;
    END IF;

    wh_fee_amt := VF_FEE_AMT;
    --total_fees_run := CHILD_SUPP_TOT_FEE_ASG_GRE_RUN;
    total_fees_run := 0;
    cntr := fees_tab.first;
    WHILE cntr is not null LOOP
       total_fees_run := total_fees_run + fees_tab(cntr);
       cntr := fees_tab.NEXT(cntr);
    END LOOP;

    hr_utility.trace('GARN_FEE_MAX_FEE_AMOUNT = '||l_garn_fee_max_fee_amt);
    hr_utility.trace('GARN_FEE_FEE_RULE = '||GARN_FEE_FEE_RULE);
    hr_utility.trace('VF_ACCRUED_FEES ' || VF_ACCRUED_FEES);


    IF GARN_FEE_FEE_RULE = 'AMT_PER_GARN' OR
       GARN_FEE_FEE_RULE = 'AMT_PER_GARN_ADDL' OR
       GARN_FEE_FEE_RULE = 'PCT_PER_GARN' OR
       GARN_FEE_FEE_RULE = 'AMT_OR_PCT'  THEN
        IF l_garn_fee_max_fee_amt <> default_fee THEN
        /* Check that total fees collected are within legislative limit. */
            IF ( vf_accrued_fees + VF_FEE_AMT ) > l_garn_fee_max_fee_amt THEN /* 5249037 */
           /* Recalculate fee amount */
                wh_fee_amt := l_garn_fee_max_fee_amt - vf_accrued_fees ; /* 5249037 */
                IF wh_fee_amt < 0 THEN
                    wh_fee_amt := 0;
                END IF;
                total_fees_run := total_fees_run - VF_FEE_AMT + wh_fee_amt;
            END IF;
        ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_GARN_ADDL' THEN
            -- Bug 4748532
            wh_fee_amt := VF_FEE_AMT;
        END IF;
    ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD' OR
          GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD_ADDL' OR
          GARN_FEE_FEE_RULE = 'PCT_PER_PERIOD' THEN
        IF l_garn_fee_max_fee_amt <> default_number THEN
        /* Check that total fees collected are within legislative limit. */
            IF (VF_PTD_FEE_BAL + VF_FEE_AMT)  > l_garn_fee_max_fee_amt THEN
           /* Recalculate fee amount */
                wh_fee_amt := l_garn_fee_max_fee_amt - VF_PTD_FEE_BAL;
                IF wh_fee_amt < 0 THEN
                    wh_fee_amt := 0;
                END IF;
                total_fees_run := total_fees_run - VF_FEE_AMT + wh_fee_amt;
            END IF;
        END IF;
    ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_MONTH' OR
          GARN_FEE_FEE_RULE = 'AMT_PER_MONTH_ADDL' OR
          GARN_FEE_FEE_RULE = 'PCT_PER_MONTH' THEN
        IF l_garn_fee_max_fee_amt <> default_number THEN
            IF (VF_MONTH_FEE_BAL + VF_FEE_AMT)  > l_garn_fee_max_fee_amt THEN
           /* Recalculate fee amount */
                wh_fee_amt := l_garn_fee_max_fee_amt - VF_MONTH_FEE_BAL;
                IF wh_fee_amt < 0 THEN
                    wh_fee_amt := 0;
                END IF;
                total_fees_run := total_fees_run - VF_FEE_AMT + wh_fee_amt;
            END IF;
        END IF;
    ELSIF GARN_FEE_FEE_RULE = 'AMT_PER_RUN' OR
          GARN_FEE_FEE_RULE = 'AMT_PER_RUN_ADDL' OR
          GARN_FEE_FEE_RULE = 'PCT_PER_RUN' THEN
        IF l_garn_fee_max_fee_amt <> default_number THEN
            --IF CHILD_SUPP_TOT_FEE_ASG_GRE_RUN > l_garn_fee_max_fee_amt THEN
            IF total_fees_run > l_garn_fee_max_fee_amt THEN
           /* Recalculate fee amount */
	        -- Bug 5095823
                wh_fee_amt := l_garn_fee_max_fee_amt - GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN;
                IF wh_fee_amt < 0 THEN
                    wh_fee_amt := 0;
                END IF;
                total_fees_run := total_fees_run - VF_FEE_AMT + wh_fee_amt;
            END IF;
        END IF;
    END IF;

/* Check against legislative limits for child support deduction:

   1. Check that total_child_supp_deduction + total fees
       is less than Subject_DISPOSABLE_INCOME
   2. If so, then dedn amounts ok
   3. If not, then
      3.1 Check GARN_EXEMPTION_PRORATION_RULE
      3.2 If rule is 'NONE' or 'ORDER_RECEIVED' then take dedns in
          order of receipt (ie. by subpriority until total dedns hits
          Subject_DISPOSABLE_INCOME.  Also have to adjust for current
          fees as well...then do we have to check fees against limits again!?
      3.3 If rule is 'PROPORTION' or 'EQUAL' then recalc appropriately.

NOTE: We do not currently make any provisions for withholding all current
support before arrearages, or alternatively all current plus support in
order of receipt.  We do not make the distinction between current and
arrearage withholding currently.  We could possibly using the arrears
deduction amount input value...
*/


    --total_support_run := CHILD_SUPP_TOT_DED_ASG_GRE_RUN;
    total_support_run := 0;
    cntr := dedn_tab.first;
    WHILE cntr is not null LOOP
       hr_utility.trace('Deduction('||cntr||') = '||dedn_tab(cntr));
       total_support_run := total_support_run + dedn_tab(cntr);
       cntr := dedn_tab.NEXT(cntr);
    END LOOP; -- While Cntr is not null

    total_child_supp_deduction := total_support_run + total_fees_run;

    wh_dedn_amt := VF_DEDN_AMT;
    IF GLB_TOT_WHLD_SUPP_ASG_GRE_RUN IS NULL THEN
        GLB_TOT_WHLD_SUPP_ASG_GRE_RUN := 0;
    END IF;

    IF GLB_TOT_WHLD_ARR_ASG_GRE_RUN IS NULL THEN
        GLB_TOT_WHLD_ARR_ASG_GRE_RUN := 0;
    END IF;

    --hr_utility.trace('Total withheld fees = '|| GLB_TOT_WHLD_SUPP_ASG_GRE_RUN);
    hr_utility.trace('Current deduction amount = '|| vf_dedn_amt);
    hr_utility.trace('DI Subject = '|| vf_di_subj);
    hr_utility.trace('Proration Rule = '|| GARN_EXEMPTION_PRORATION_RULE);

    IF total_child_supp_deduction < VF_DI_SUBJ THEN
        dedn_ok := 'YES';
        wh_dedn_amt := VF_DEDN_AMT;
    ELSE
        IF total_support_run < VF_DI_SUBJ THEN
            dedn_ok := 'YES';
            wh_dedn_amt := VF_DEDN_AMT;
	    -- Bug 5095823
            IF total_support_run + wh_fee_amt + GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN > VF_DI_SUBJ
                AND GARN_FEE_TAKE_FEE_ON_PRORATION <> 'Y' THEN
                wh_fee_amt := VF_DI_SUBJ - (total_support_run + GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN);
                IF wh_fee_amt < 0 THEN
                    wh_fee_amt := 0;
                END IF;
            END IF;

            -- Bug 5095823
            IF total_support_run + wh_fee_amt + GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN > VF_DI_SUBJ
                AND GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                excess_amt := VF_DI_SUBJ - (total_support_run + GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN);
                IF excess_amt < 0 THEN
                    excess_amt := 0;
                END IF;
                IF wh_dedn_amt+excess_amt - wh_fee_amt > 0 THEN
                    not_taken := wh_dedn_amt - (wh_dedn_amt + excess_amt - wh_fee_amt);
                    wh_dedn_amt := wh_dedn_amt+excess_amt - wh_fee_amt;
                ELSE
                    wh_fee_amt := 0;
                END IF;
            END IF;
        ELSE
        -- Bug 3704744
        -- Use the overriden proration rule if overrided.
           OPEN csr_get_proration_ovrd;
              FETCH csr_get_proration_ovrd INTO l_proration_ovrd;
           CLOSE csr_get_proration_ovrd;

           IF l_proration_ovrd is null then
              l_proration_ovrd := GARN_EXEMPTION_PRORATION_RULE;
              hr_utility.trace ('Proration rule not overriden. Proceeding with proration rule = '||l_proration_ovrd);
           ELSE
              hr_utility.trace ('Proration rule overriden to '||l_proration_ovrd);
           END IF;

            /* total_support_run >= VF_DI_SUBJ */
                IF l_proration_ovrd = 'NONE' OR
                   l_proration_ovrd = 'ORDER' THEN
                    wh_dedn_amt := VF_DEDN_AMT;
                /*
                Check when current deduction amounts exceed VF_DI_SUBJ...ie. withhold
                in order received until di subject is reached, then shortpay any
                remaining support payments.
                */
		    -- Bug 5095823
                    IF GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                       GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN+
                       wh_dedn_amt > VF_DI_SUBJ THEN
                        wh_dedn_amt := VF_DI_SUBJ - ( GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                                                      GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN );
                        IF wh_dedn_amt <= 0 THEN
                            wh_dedn_amt := 0;
                            wh_fee_amt := 0;
                            not_taken := VF_DI_SUBJ;
                            arrears_amt := not_taken;
                        ELSE
                            not_taken := VF_DI_SUBJ - wh_dedn_amt;
                            IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                                IF wh_dedn_amt - wh_fee_amt > 0 THEN
                                    wh_dedn_amt := wh_dedn_amt - wh_fee_amt;
                                    not_taken := VF_DI_SUBJ - wh_dedn_amt;
                                ELSE
                                    wh_fee_amt := 0;
                                END IF;
                            ELSE
                                wh_fee_amt := 0;
                            END IF;
                        END IF;
                    ELSE
		        -- Bug 5095823
                        IF GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                           GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN +
                           wh_dedn_amt +
                           wh_fee_amt > VF_DI_SUBJ THEN
                            IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                                IF wh_dedn_amt - wh_fee_amt > 0 THEN
                                    wh_dedn_amt := wh_dedn_amt - wh_fee_amt;
                                    not_taken := VF_DI_SUBJ - wh_dedn_amt;
                                ELSE
				    -- Bug 5095823
                                    wh_fee_amt := VF_DI_SUBJ - ( GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                                                                 GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN +
                                                                 wh_dedn_amt);
                                END IF;
                            ELSE
			        -- Bug 5095823
                                wh_fee_amt := VF_DI_SUBJ - ( GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                                                             GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN +
                                                             wh_dedn_amt);
                            END IF;
                        END IF;
                    END IF;
                ELSE
                IF l_proration_ovrd = 'EQUAL' THEN
                -- Bug 3704744
                -- Removed GLB_TOT_WHLD_SUPP_ASG_GRE_RUN from the calculation of dedn_amt to be
                -- deducted as it will result in lesser amount to be deducted for every
                -- further element processed
                --  equal_dedn_amounts := (vf_di_subj - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN)/dedn_tab.count();
                    equal_dedn_amounts := vf_di_subj/dedn_tab.count();
                    IF VF_DI_SUBJ - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN <= 0 THEN
                        equal_dedn_amounts := 0 ;
                    ELSE
                        IF VF_DI_SUBJ-TOT_WHLD_SUPP_ASG_GRE_RUN-equal_dedn_amounts < 0 THEN
                            equal_dedn_amounts :=VF_DI_SUBJ -TOT_WHLD_SUPP_ASG_GRE_RUN;
                        END IF;
                    END IF;
                    -- Calling Function to get Prorated Amount (Reference Bug# 5295813)

                     wh_dedn_amt := GET_PRORATED_DEDN_AMOUNT(vf_di_subj, P_CTX_ORIGINAL_ENTRY_ID) ;

                    -- Commenting following part
                    --wh_dedn_amt := LEAST(equal_dedn_amounts,wh_dedn_amt);
                    not_taken := VF_DI_SUBJ - wh_dedn_amt;
                    arrears_amt := not_taken;

                    IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                        IF wh_dedn_amt - wh_fee_amt > 0 THEN
                            wh_dedn_amt := wh_dedn_amt - wh_fee_amt;
                            not_taken := VF_DI_SUBJ - wh_dedn_amt;
                        ELSE
                            wh_fee_amt := 0;
                        END IF;
                    ELSE
                        wh_fee_amt := 0;
                    END IF;
                ELSE
                    IF l_proration_ovrd = 'PROPORTION' AND
                        total_support_run <> 0 THEN
                        -- Bug 5165704
                        -- Used dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) instead of
                        -- VF_DEDN_AMT for calculating the Proportional amount
                        -- VF_DEDN_AMT gets modified and as a result the proportional
                        -- amount gets incorrectly calculated
                        proportional_dedn_amount := (dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) / total_support_run) * VF_DI_SUBJ;
                        IF VF_DI_SUBJ - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN <= 0 THEN
                            proportional_dedn_amount := 0;
                        ELSE
                            IF VF_DI_SUBJ
                                - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN
                                - proportional_dedn_amount < 0 THEN
                                proportional_dedn_amount := VF_DI_SUBJ - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN;
                            END IF;
                        END IF;

                        wh_dedn_amt := proportional_dedn_amount;
                        not_taken := VF_DI_SUBJ - wh_dedn_amt;
                        arrears_amt := not_taken;

                        hr_utility.trace ('DI Subject = "'||vf_di_subj||'"');
                        hr_utility.trace ('Deduction amount = "'||wh_dedn_amt||'"');
                        hr_utility.trace ('Not taken amount = "'||not_taken||'"');
                        hr_utility.trace ('Arrears amount = "'||arrears_amt||'"');

                        IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                            IF wh_dedn_amt - Wh_fee_amt > 0 THEN
                                wh_dedn_amt := wh_dedn_amt - wh_fee_amt;
                                not_taken := VF_DI_SUBJ - wh_dedn_amt;
                            ELSE
                                wh_fee_amt := 0;
                            END IF;
                        ELSE
                                wh_fee_amt := 0;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    /* Proration for arrears (Bug 2992741) */
    IF arrears_tab.exists(P_CTX_ORIGINAL_ENTRY_ID) THEN
        VF_DEDN_AMT_ARR := arrears_tab(P_CTX_ORIGINAL_ENTRY_ID);
    ELSE
        VF_DEDN_AMT_ARR := 0;
    END IF;

    IF VF_DEDN_AMT_ARR > 0 THEN
        total_support_run_arr := 0;
        cntr := arrears_tab.first;
        WHILE cntr is not null LOOP
           hr_utility.trace('Arrears ('||cntr||') = '||arrears_tab(cntr));
           total_support_run_arr := total_support_run_arr + arrears_tab(cntr);
           cntr := arrears_tab.NEXT(cntr);
        END LOOP;

       -- Bug 2992741
       -- VF_DI_SUBJ_ARR := VF_DI_SUBJ - wh_dedn_amt - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN + GLB_TOT_WHLD_ARR_ASG_GRE_RUN;
          VF_DI_SUBJ_ARR := VF_DI_SUBJ - total_support_run;

            IF total_support_run_arr < VF_DI_SUBJ_ARR THEN
                wh_dedn_amt_arr := VF_DEDN_AMT_ARR;
                /*IF total_support_run_arr + wh_fee_amt + TOTAL_WITHHELD_FEE_ASG_GRE_RUN > VF_DI_SUBJ_ARR
                    AND GARN_FEE_TAKE_FEE_ON_PRORATION <> 'Y' THEN
                    wh_fee_amt := VF_DI_SUBJ_ARR - (total_support_run_arr + TOTAL_WITHHELD_FEE_ASG_GRE_RUN);
                    IF wh_fee_amt < 0 THEN
                        wh_fee_amt := 0;
                    END IF;
                END IF;*/

                /*IF total_support_run_arr + wh_fee_amt + TOTAL_WITHHELD_FEE_ASG_GRE_RUN > VF_DI_SUBJ_ARR
                    AND GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                    excess_amt := VF_DI_SUBJ_ARR - (total_support_run_arr + TOTAL_WITHHELD_FEE_ASG_GRE_RUN);
                    IF excess_amt < 0 THEN
                        excess_amt := 0;
                    END IF;
                    IF wh_dedn_amt_arr+excess_amt - wh_fee_amt > 0 THEN
                        not_taken := wh_dedn_amt_arr - (wh_dedn_amt_arr + excess_amt - wh_fee_amt);
                        wh_dedn_amt_arr := wh_dedn_amt_arr+excess_amt - wh_fee_amt;
                    ELSE
                        wh_fee_amt := 0;
                    END IF;
                END IF;*/
            ELSE
                /* total_support_run_arr >= VF_DI_SUBJ_ARR */
                -- Bug 2992741
                IF VF_DI_SUBJ_ARR > 0 THEN
                   IF GARN_EXEMPTION_PRORATION_RULE = 'NONE' OR
                          GARN_EXEMPTION_PRORATION_RULE = 'ORDER' THEN

                           wh_dedn_amt_arr := VF_DEDN_AMT_ARR;
                           IF wh_dedn_amt_arr > VF_DI_SUBJ_ARR THEN
                               wh_dedn_amt_arr := VF_DI_SUBJ_ARR;
                           END IF;
                       ELSE
                       IF GARN_EXEMPTION_PRORATION_RULE = 'EQUAL' THEN
                           equal_dedn_amounts := VF_DI_SUBJ_ARR/arrears_tab.count();
                           wh_dedn_amt_arr := equal_dedn_amounts;
                       ELSE
                           IF GARN_EXEMPTION_PRORATION_RULE = 'PROPORTION' AND
                               total_support_run_arr <> 0 THEN
                               proportional_dedn_amount := (VF_DEDN_AMT_ARR / total_support_run_arr) * VF_DI_SUBJ_ARR;
                               /*IF VF_DI_SUBJ_ARR - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN <= 0 THEN
                                   proportional_dedn_amount := 0;
                               ELSE
                                   IF VF_DI_SUBJ_ARR
                                       - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN
                                       - proportional_dedn_amount < 0 THEN
                                       proportional_dedn_amount := VF_DI_SUBJ_ARR - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN;
                                   END IF;
                               END IF;*/

                               wh_dedn_amt_arr := proportional_dedn_amount;

                               hr_utility.trace ('Arrears DI Subject = "'||VF_DI_SUBJ_ARR||'"');
                               hr_utility.trace ('Arrears Deduction amount = "'||wh_dedn_amt_arr||'"');
                           END IF;
                       END IF;
                   END IF;
                ELSE
                   wh_dedn_amt_arr := 0;
                END IF;
                -- Bug 2992741
                -- Set the fee amount to ZERO in case of Proration
                IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'N' then
                    wh_fee_amt := 0;
                    hr_utility.trace ('Setting Fee to Zero as GARN_FEE_TAKE_FEE_ON_PRORATION is N');
                END IF;
            END IF;
    wh_dedn_amt := wh_dedn_amt + wh_dedn_amt_arr;
    hr_utility.trace('wh_dedn_amt = '||wh_dedn_amt);
    END IF;

    /*-----------------------*/

    -- Bug 4748532
    -- Deduct PTD amount for Garnishment and Fees if the value of
    -- GLB_FEES_ASG_GRE_PTD is not set to -9999(default_number) in BASE_FORMULA
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
       hr_utility.trace('Deduction that can be taken = ' || WH_DEDN_AMT);
       hr_utility.trace('Deduction already taken     = ' || GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID));
       hr_utility.trace('Fees That can be taken      = ' || WH_FEE_AMT);
       hr_utility.trace('Fees already taken          = ' || GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID));
       IF WH_DEDN_AMT <= 0 THEN
           WH_FEE_AMT := 0;
       ELSIF WH_DEDN_AMT >= GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) THEN
          WH_DEDN_AMT := WH_DEDN_AMT - GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
       ELSE
          WH_DEDN_AMT := 0;
       END IF;

       IF WH_DEDN_AMT > actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) THEN
          WH_DEDN_AMT := actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID);
       END IF;
       IF WH_FEE_AMT >= 0 AND WH_FEE_AMT >= GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) THEN
          WH_FEE_AMT := WH_FEE_AMT - GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
       ELSE
          WH_FEE_AMT := 0;
       END IF;
    END IF; -- IF GLB_FEES_ASG_GRE_PTD

   -- Adding condition for checking wh_dedn_amt Against Monthly Cap
   hr_utility.trace('monthly_cap_amount := '||monthly_cap_amount);
   hr_utility.trace('month_to_date_balance := '||month_to_date_balance);
   IF monthly_cap_amount <> 0 THEN
      IF (monthly_cap_amount - month_to_date_balance) >= 0 THEN
           IF WH_DEDN_AMT > (monthly_cap_amount - month_to_date_balance) THEN
              WH_DEDN_AMT := monthly_cap_amount - month_to_date_balance;
           END IF;
      END IF;
   END IF;
   -- End of Addition for checking wh_dedn_amt Against Monthly Cap

   -- Adding condition for checking wh_dedn_amt Against Period Cap
   hr_utility.trace('period_cap_amount := '||monthly_cap_amount);
   hr_utility.trace('period_to_date_balance := '||month_to_date_balance);
   IF period_cap_amount <> 0 THEN
      IF (period_cap_amount - period_to_date_balance) >= 0 THEN
           IF WH_DEDN_AMT > (period_cap_amount - period_to_date_balance) THEN
              WH_DEDN_AMT := period_cap_amount - period_to_date_balance;
           END IF;
      END IF;
   END IF;
   -- End of Addition for checking wh_dedn_amt Against Period Cap

    /* *** Negative Net checks *** */

    IF NET_ASG_GRE_RUN - wh_dedn_amt - wh_fee_amt < 0 THEN
        IF NET_ASG_GRE_RUN - wh_dedn_amt > 0 THEN
      /* Part of fee makes net go negative, charge enough
         to make net = 0 */
            wh_fee_amt := NET_ASG_GRE_RUN - wh_dedn_amt;
            not_taken := VF_DI_SUBJ - wh_dedn_amt;
            arrears_amt := not_taken;

        ELSIF NET_ASG_GRE_RUN - wh_dedn_amt = 0 THEN
         /* Fee causes net to go negative, don't charge fee. */
            wh_fee_amt := 0;
            not_taken := VF_DI_SUBJ - wh_dedn_amt;
            arrears_amt := not_taken;

        ELSIF (NET_ASG_GRE_RUN - wh_dedn_amt < 0) AND (NET_ASG_GRE_RUN > 0) THEN
         /* Dedn amount itself causes net to go negative (? how ?),
            so don't charge a fee and take max available.
         */
            wh_fee_amt := 0;
            wh_dedn_amt := NET_ASG_GRE_RUN;
            not_taken := VF_DI_SUBJ - wh_dedn_amt;
            arrears_amt := not_taken;
        END IF;
    END IF;


/* *** Negative Net checks end *** */


/* *** Stop Rule Processing BEGIN *** */

    IF VF_TOTAL_OWED_AMT <> 0 THEN
        IF VF_TOTAL_OWED_AMT - VF_PRIM_BAL < 0 THEN
            fatal_mesg := 'Deduction Balance > Total Owed by $' ||TO_CHAR(VF_PRIM_BAL - VF_TOTAL_OWED_AMT ) || '. Adjust Balance for ' ||  lv_ele_name || '.';
            reset_global_var;
            RETURN (-1);
        ELSE
            IF VF_PRIM_BAL + wh_dedn_amt >= VF_TOTAL_OWED_AMT THEN
                wh_dedn_amt := VF_TOTAL_OWED_AMT - VF_PRIM_BAL;
                    STOP_ENTRY := 'Y';
                    mesg := 'Support obligation has been satisfied because of Total Owed Reached for ' || lv_ele_name || '.';
                    IF VF_PRIM_BAL <> 0 THEN
                        to_total_owed := -1 * VF_PRIM_BAL;
                    ELSE
                        to_total_owed := 0;
                    END IF;
            ELSE
                    to_total_owed := wh_dedn_amt;
            END IF;
        END IF;
    ELSE
        to_total_owed := wh_dedn_amt;
    END IF;

    garn_limit_days := get_garn_limit_max_duration(PAY_EARNED_START_DATE);

   /*
    * Bug 3718454
    * Added 1 to the calculation of garn_days as the both
    * PAY_EARNED_END_DATE and VF_DATE_SERVED should be included for
    * calculating the STOP_ENTRY value.
    */
    IF garn_limit_days > 0 THEN
        garn_days := PAY_EARNED_END_DATE - VF_DATE_SERVED + 1;
        IF garn_days >= garn_limit_days THEN
            garn_days_end_per := PAY_EARNED_START_DATE - Date_Served + 1;
            /*
             * Added the IF condition te determine whether any amount needs
             * to be deducted.(Bug 3718454 and 3734415)
             * Bug 3777900 : Removed '=' sign from the IF condition below
             */
            IF garn_days_end_per > garn_limit_days THEN
                STOP_ENTRY := 'Y';
                WH_DEDN_AMT := 0;
                WH_FEE_AMT := 0;
                mesg := garn_limit_days || ' days Limit for element was reached before current pay period. No Deduction will be taken for ' || lv_ele_name || '. Element will be end dated';
                IF VF_PRIM_BAL <> 0 THEN
                   to_total_owed := -1 * VF_PRIM_BAL;
                ELSE
                   to_total_owed := 0;
                END IF;
            ELSE
                STOP_ENTRY := 'Y';
                /* BUG 1752791 Added the following to reset the balance */
                mesg := 'Support obligation has been satisfied for ' || lv_ele_name || ' because of Max Withholding Days Limit Reached.';
                to_total_owed := -1 * Primary_Amount_Balance;
                IF VF_PRIM_BAL <> 0 THEN
                   to_total_owed := -1 * VF_PRIM_BAL;
                ELSE
                   to_total_owed := 0;
                END IF;
            END IF;
        END IF;
    END IF;

/* *** Stop Rule Processing END *** */

-- Commented the following Final Pay section for Bug 4107302
/* *** Final Pay Section BEGIN *** */
/*
    IF (TERMINATED_EMPLOYEE = 'Y' AND FINAL_PAY_PROCESSED = 'N') THEN
        STOP_ENTRY := 'Y';
    END IF;
*/
/* *** Final Pay Section END *** */

    -- Bug 4234046 and 4748532
    -- Set Fee Amount to ZERO when
    --- * No deduction is taken
    --  * We are not looking at PTD values for deducting Garnishment
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) = default_number THEN
       IF WH_DEDN_AMT <= 0 THEN
           WH_FEE_AMT := 0;
       END IF;
    END IF;


    to_count := -1;
    SF_Accrued_Fees := wh_fee_amt;

    /*Bug 3500570*/
    IF NET_ASG_GRE_RUN > (VF_DI_SUBJ - GLB_TOT_WHLD_SUPP_ASG_GRE_RUN) AND total_support_run <> 0 THEN
        not_taken := 0;
    END IF;

    -- Bug 5095823
    GLB_TOT_WHLD_SUPP_ASG_GRE_RUN := GLB_TOT_WHLD_SUPP_ASG_GRE_RUN + wh_dedn_amt;
    GLB_TOT_WHLD_ARR_ASG_GRE_RUN := GLB_TOT_WHLD_ARR_ASG_GRE_RUN + wh_dedn_amt_arr;
    GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN := GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN + WH_FEE_AMT;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Return values...');
        hr_utility.trace('CHILD_SUPP_TOT_DED_ASG_GRE_RUN = '||CHILD_SUPP_TOT_DED_ASG_GRE_RUN);
        hr_utility.trace('ARREARS_AMT = '||ARREARS_AMT);
        hr_utility.trace('DIFF_DEDN_AMT = '||DIFF_DEDN_AMT);
        hr_utility.trace('DIFF_FEE_AMT = '||DIFF_FEE_AMT);
        hr_utility.trace('NOT_TAKEN = '||NOT_TAKEN);
        hr_utility.trace('SF_ACCRUED_FEES = '||SF_ACCRUED_FEES);
        hr_utility.trace('STOP_ENTRY = '||STOP_ENTRY);
        hr_utility.trace('TO_COUNT = '||TO_COUNT);
        hr_utility.trace('TO_TOTAL_OWED = '||TO_TOTAL_OWED);
        hr_utility.trace('WH_DEDN_AMT = '||WH_DEDN_AMT);
        hr_utility.trace('WH_FEE_AMT = '||WH_FEE_AMT);
        hr_utility.trace('FATAL_MESG = '||FATAL_MESG);
        hr_utility.trace('MESG = '||MESG);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
        hr_utility.trace('TO_REPL = '||TO_REPL);
        hr_utility.trace('TO_ADDL = '||TO_ADDL);
    END IF;

    /*
     * Delete the GLOBAL tables once an employee is procesed
     */
    if GLB_NUM_ELEM = 0 then
       reset_global_var;
    end if;
    hr_utility.trace('Leaving '||l_proc_name);
    RETURN (0);

END CAL_FORMULA_SS;


  /****************************************************************************
    Name        : ENTRY_SUBPRIORITY
    Description : This function return sub-priority of specified
                  element_entry_id.
  *****************************************************************************/

FUNCTION ENTRY_SUBPRIORITY RETURN number IS
BEGIN
    RETURN (pay_wat_udfs.entry_subpriority(CTX_DATE_EARNED, CTX_ELEMENT_ENTRY_ID));
END ENTRY_SUBPRIORITY;

  /****************************************************************************
    Name        : CONVERT_PERIOD_TYPE
    Description : This function converts amount according to the time units
                  specified.
  *****************************************************************************/

FUNCTION CONVERT_PERIOD_TYPE
(
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    FED_CRITERIA_PCT_PRD_DI_XMPT number,
    P_FROM_FREQ varchar2,
    P_TO_FREQ varchar2,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    P_ASST_STD_FREQ varchar2
)
RETURN number IS

-- **********************************************************************
-- **********************************************************************

/* Introducing following Private function to be used to
   replace hr_us_ff_udfs.convert_period_type function call
*/

FUNCTION Garn_Convert_Period_Type(
		p_bus_grp_id		in NUMBER,
		p_payroll_id		in NUMBER,
		p_asst_work_schedule	in VARCHAR2,
		p_asst_std_hours	      in NUMBER,
		p_figure		      in NUMBER,
		p_from_freq		      in VARCHAR2,
		p_to_freq		      in VARCHAR2,
		p_period_start_date	in DATE,
		p_period_end_date	      in DATE,
		p_asst_std_freq		in VARCHAR2)

RETURN NUMBER IS

-- local variables
v_calc_type                  VARCHAR2(50);
v_from_stnd_factor           NUMBER(30,7);
v_stnd_start_date            DATE;
v_converted_figure           NUMBER(27,7);
v_from_annualizing_factor    NUMBER(30,7);
v_to_annualizing_factor	     NUMBER(30,7);

CURSOR get_asg_hours_freq(cp_date_earned date,
                        cp_assignment_id number) IS
  SELECT hr_general.decode_lookup('FREQUENCY', ASSIGN.frequency)
        ,ASSIGN.normal_hours
  FROM  per_all_assignments_f ASSIGN
  where cp_date_earned BETWEEN ASSIGN.effective_start_date
  AND ASSIGN.effective_end_date
  and ASSIGN.assignment_id = cp_assignment_id
  and UPPER(ASSIGN.frequency) = 'W';

-- local functions

FUNCTION Get_Annualizing_Factor(p_bg	in NUMBER,
				p_payroll		in NUMBER,
				p_freq		in VARCHAR2,
				p_asg_work_sched	in VARCHAR2,
				p_asg_std_hrs	in NUMBER,
				p_asg_std_freq	in VARCHAR2)
RETURN NUMBER IS

-- local constants

c_weeks_per_year	NUMBER(3);
c_days_per_year	NUMBER(3);
c_months_per_year	NUMBER(3);

-- local variables
/* 353434, 368242 : Fixed number width for total hours variables */

v_annualizing_factor	NUMBER(30,7);
v_periods_per_fiscal_yr	NUMBER(5);
v_hrs_per_wk		NUMBER(15,7);
v_hrs_per_range		NUMBER(15,7);
v_use_pay_basis	NUMBER(1);
v_pay_basis		VARCHAR2(80);
v_range_start		DATE;
v_range_end		DATE;
v_work_sched_name	VARCHAR2(80);
v_ws_id			NUMBER(9);
v_period_hours		BOOLEAN;

BEGIN -- Get_Annualizing_Factor

  /* Init */

c_weeks_per_year   := 52;
c_days_per_year    := 200;
c_months_per_year  := 12;
v_use_pay_basis	   := 0;
--
-- Check for use of salary admin (ie. pay basis) as frequency.
-- Selecting "count" because we want to continue processing even if
-- the from_freq is not a pay basis.
--

 hr_utility.trace('  Entered  Get_Annualizing_Factor ');

 BEGIN	-- Is Freq pay basis?

  --
  -- Decode pay basis and set v_annualizing_factor accordingly.
  -- PAY_BASIS "Meaning" is passed from FF !
  --

  hr_utility.trace('  Getting lookup code for lookup_type = PAY_BASIS');
  hr_utility.trace('  p_freq ='||p_freq);

  SELECT	lookup_code
  INTO		v_pay_basis
  FROM		hr_lookups	 	lkp
  WHERE 	lkp.application_id	= 800
  AND		lkp.lookup_type		= 'PAY_BASIS'
  AND		lkp.meaning		= p_freq;

  hr_utility.trace('  Lookup_code ie v_pay_basis ='||v_pay_basis);
  v_use_pay_basis := 1;

  IF v_pay_basis = 'MONTHLY' THEN

    hr_utility.trace('  Entered for MONTHLY v_pay_basis');

    v_annualizing_factor := 12;

    hr_utility.trace(' v_annualizing_factor = 12 ');
  ELSIF v_pay_basis = 'HOURLY' THEN

      hr_utility.trace('  Entered for HOURLY v_pay_basis');

      IF p_period_start_date IS NOT NULL THEN

      hr_utility.trace('  p_period_start_date IS NOT NULL v_period_hours=T');
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
      ELSE

      hr_utility.trace('  p_period_start_date IS NULL');

        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
      END IF;

      IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

      -- Hourly employee using work schedule.
      -- Get work schedule name

      hr_utility.trace('  Hourly employee using work schedule');
      hr_utility.trace('  Get work schedule name');

         v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

      hr_utility.trace('  v_ws_id ='||to_number(v_ws_id));


        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'US')      = 'US';

         hr_utility.trace('  v_work_sched_name ='||v_work_sched_name);
         hr_utility.trace('  Calling hr_us_ff_udfs.Work_Schedule_Total_Hours');

         v_hrs_per_range := hr_us_ff_udfs.Work_Schedule_Total_Hours(	p_bg,
							v_work_sched_name,
							v_range_start,
							v_range_end);

      ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.trace('  Hourly emp using Standard Hours on asg');


         hr_utility.trace('  calling hr_us_ff_udfs.Standard_Hours_Worked');
         v_hrs_per_range := hr_us_ff_udfs.Standard_Hours_Worked(	p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

      END IF;

      IF v_period_hours THEN

         hr_utility.trace('  v_period_hours is TRUE');

         select TPT.number_per_fiscal_year
          into    v_periods_per_fiscal_yr
          from   pay_payrolls_f  PPF,
                 per_time_period_types TPT,
                 fnd_sessions fs
         where  PPF.payroll_id = p_payroll
         and    fs.session_id = USERENV('SESSIONID')
         and    fs.effective_date between PPF.effective_start_date and PPF.effective_end_date
            and   TPT.period_type = PPF.period_type;

         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;

      ELSE

         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

      END IF;

  ELSIF v_pay_basis = 'PERIOD' THEN

    hr_utility.trace('  v_pay_basis = PERIOD');

    SELECT  TPT.number_per_fiscal_year
    INTO        v_annualizing_factor
    FROM    pay_payrolls_f          PRL,
            per_time_period_types   TPT,
            fnd_sessions            fs
    WHERE   TPT.period_type         = PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date  BETWEEN PRL.effective_start_date
                          AND PRL.effective_end_date
    AND     PRL.payroll_id          = p_payroll
    AND     PRL.business_group_id + 0   = p_bg;


  ELSIF v_pay_basis = 'ANNUAL' THEN


    hr_utility.trace('  v_pay_basis = ANNUAL');
    v_annualizing_factor := 1;

  ELSE

    -- Did not recognize "pay basis", return -999 as annualizing factor.
    -- Remember this for debugging when zeroes come out as results!!!

    hr_utility.trace('  Did not recognize pay basis');

    v_annualizing_factor := 0;
    RETURN v_annualizing_factor;

  END IF;

 EXCEPTION

  WHEN NO_DATA_FOUND THEN

    hr_utility.trace('  When no data found' );
    v_use_pay_basis := 0;

 END; /* SELECT LOOKUP CODE */

IF v_use_pay_basis = 0 THEN

    hr_utility.trace('  Not using pay basis as frequency');

  -- Not using pay basis as frequency...

  IF (p_freq IS NULL) 			OR
     (UPPER(p_freq) = 'PERIOD') 		OR
     (UPPER(p_freq) = 'NOT ENTERED') 	THEN

    -- Get "annuallizing factor" from period type of the payroll.

    hr_utility.trace('Get annuallizing factor from period type of the payroll');

    SELECT  TPT.number_per_fiscal_year
    INTO    v_annualizing_factor
    FROM    pay_payrolls_f          PRL,
            per_time_period_types   TPT,
            fnd_sessions            fs
    WHERE   TPT.period_type         = PRL.period_type
    and     fs.session_id = USERENV('SESSIONID')
    and     fs.effective_date  BETWEEN PRL.effective_start_date
                          AND PRL.effective_end_date
    AND     PRL.payroll_id          = p_payroll
    AND     PRL.business_group_id + 0   = p_bg;

    hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

  ELSIF UPPER(p_freq) <> 'HOURLY' THEN

    -- Not hourly, an actual time period type!
   hr_utility.trace('Not hourly - an actual time period type');

   BEGIN

    hr_utility.trace(' selecting from per_time_period_types');

    SELECT	PT.number_per_fiscal_year
    INTO		v_annualizing_factor
    FROM	per_time_period_types 	PT
    WHERE	UPPER(PT.period_type) 	= UPPER(p_freq);

    hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

   EXCEPTION when NO_DATA_FOUND then

     -- Added as part of SALLY CLEANUP.
     -- Could have been passed in an ASG_FREQ dbi which might have the values of
     -- 'Day' or 'Month' which do not map to a time period type.  So we'll do these by hand.

      IF UPPER(p_freq) = 'DAY' THEN
        hr_utility.trace('  p_freq = DAY');
        v_annualizing_factor := c_days_per_year;
      ELSIF UPPER(p_freq) = 'MONTH' THEN
        v_annualizing_factor := c_months_per_year;
        hr_utility.trace('  p_freq = MONTH');
      END IF;

    END;

  ELSE  -- Hourly employee...
     hr_utility.trace('  Hourly Employee');

     IF p_period_start_date IS NOT NULL THEN
        v_range_start 	:= p_period_start_date;
        v_range_end	:= p_period_end_date;
        v_period_hours	:= TRUE;
     ELSE
        v_range_start 	:= sysdate;
        v_range_end	:= sysdate + 6;
        v_period_hours 	:= FALSE;
     END IF;

     IF UPPER(p_asg_work_sched) <> 'NOT ENTERED' THEN

    -- Hourly emp using work schedule.
    -- Get work schedule name:

        v_ws_id := fnd_number.canonical_to_number(p_asg_work_sched);

        SELECT	user_column_name
        INTO	v_work_sched_name
        FROM	pay_user_columns
        WHERE	user_column_id 			= v_ws_id
        AND	NVL(business_group_id, p_bg) 	= p_bg
  	AND     NVL(legislation_code,'US')      = 'US';


        v_hrs_per_range := hr_us_ff_udfs.WORK_SCHEDULE_TOTAL_HOURS(	p_bg,
							v_work_sched_name,
							v_range_start,
							v_range_end);

     ELSE-- Hourly emp using Standard Hours on asg.

         hr_utility.trace('  Hourly emp using Standard Hours on asg');

         hr_utility.trace('calling hr_us_ff_udfs.Standard_Hours_Worked');

         v_hrs_per_range := hr_us_ff_udfs.Standard_Hours_Worked(p_asg_std_hrs,
						v_range_start,
						v_range_end,
						p_asg_std_freq);

         hr_utility.trace('returned hr_us_ff_udfs.Standard_Hours_Worked');
     END IF;


      IF v_period_hours THEN

         hr_utility.trace('v_period_hours = TRUE');

         select TPT.number_per_fiscal_year
          into    v_periods_per_fiscal_yr
          from   pay_payrolls_f        PPF,
                 per_time_period_types TPT,
                 fnd_sessions          fs
         where  PPF.payroll_id = p_payroll
         and    fs.session_id = USERENV('SESSIONID')
         and    fs.effective_date  between PPF.effective_start_date and PPF.effective_end_date
         and   TPT.period_type = PPF.period_type;

         v_annualizing_factor := v_hrs_per_range * v_periods_per_fiscal_yr;
         hr_utility.trace('v_hrs_per_range ='||to_number(v_hrs_per_range));
         hr_utility.trace('v_periods_per_fiscal_yr ='||to_number(v_periods_per_fiscal_yr));
         hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

      ELSE

         hr_utility.trace('v_period_hours = FALSE');

         v_annualizing_factor := v_hrs_per_range * c_weeks_per_year;

         hr_utility.trace('v_hrs_per_range ='||to_number(v_hrs_per_range));
         hr_utility.trace('c_weeks_per_year ='||to_number(c_weeks_per_year));
         hr_utility.trace('v_annualizing_factor ='||to_number(v_annualizing_factor));

      END IF;

  END IF;

END IF;	-- (v_use_pay_basis = 0)


    hr_utility.trace('  Getting out of Get_Annualizing_Factor for '||v_pay_basis);
RETURN v_annualizing_factor;

END Get_Annualizing_Factor;


BEGIN -- begin Garn_Convert_Period_Type
-- begin Garn_Convert_Period_Type

hr_utility.trace('Entered Garn_Convert_Period_Type');

hr_utility.trace('  p_bus_grp_id: '|| p_bus_grp_id);
hr_utility.trace('  p_payroll_id: '||p_payroll_id);
hr_utility.trace('  p_asst_work_schedule: '||p_asst_work_schedule);
hr_utility.trace('  p_asst_std_hours: '||p_asst_std_hours);
hr_utility.trace('  p_figure: '||p_figure);
hr_utility.trace('  p_from_freq : '||p_from_freq);
hr_utility.trace('  p_to_freq: '||p_to_freq);
hr_utility.trace('  p_period_start_date: '||to_char(p_period_start_date));
hr_utility.trace('  p_period_end_date: '||to_char(p_period_end_date));
hr_utility.trace('  p_asst_std_freq: '||p_asst_std_freq);


  --
  -- If From_Freq and To_Freq are the same, then we're done.
  --

  IF NVL(p_from_freq, 'NOT ENTERED') = NVL(p_to_freq, 'NOT ENTERED') THEN

    RETURN p_figure;

  END IF;
  hr_utility.trace('Calling Get_Annualizing_Factor for FROM case');
  v_from_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq		=> p_from_freq,
			p_asg_work_sched	=> p_asst_work_schedule,
			p_asg_std_hrs	=> p_asst_std_hours,
			p_asg_std_freq	=> p_asst_std_freq);

  hr_utility.trace('Calling Get_Annualizing_Factor for TO case');

  v_to_annualizing_factor := Get_Annualizing_Factor(
			p_bg			=> p_bus_grp_id,
			p_payroll		=> p_payroll_id,
			p_freq		=> p_to_freq,
			p_asg_work_sched	=> p_asst_work_schedule,
			p_asg_std_hrs	=> p_asst_std_hours,
			p_asg_std_freq	=> p_asst_std_freq);

  --
  -- Annualize "Figure" and convert to To_Freq.
  --
 hr_utility.trace('v_from_annualizing_factor ='||to_char(v_from_annualizing_factor));
 hr_utility.trace('v_to_annualizing_factor ='||to_char(v_to_annualizing_factor));

  IF v_to_annualizing_factor = 0 	OR
     v_to_annualizing_factor = -999	OR
     v_from_annualizing_factor = -999	THEN

    hr_utility.trace(' v_to_ann =0 or -999 or v_from = -999');

    v_converted_figure := 0;
    RETURN v_converted_figure;

  ELSE

    hr_utility.trace(' v_to_ann NOT 0 or -999 or v_from = -999');

    hr_utility.trace('p_figure Monthly Salary = '||p_figure);
    hr_utility.trace('v_from_annualizing_factor = '||v_from_annualizing_factor);
    hr_utility.trace('v_to_annualizing_factor   = '||v_to_annualizing_factor);

    v_converted_figure := (p_figure * v_from_annualizing_factor) / v_to_annualizing_factor;
    hr_utility.trace('conv figure is monthly_sal * ann_from div by ann to');

    hr_utility.trace('UDFS v_converted_figure := '||v_converted_figure);

  END IF;

  /* Removed the logic to return the converted figure based on
     Payroll level 'Hours Calculation Type'. This should not matter
     in case of conversion from weekly to period figure and vice
     versa for involuntary deduction elements.
  */

-- Done

RETURN v_converted_figure;

END Garn_Convert_Period_Type; -- End of Garn_Convert_Period_Type

BEGIN -- Begin of CONVERT_PERIOD_TYPE

/* Instead of directly calling hr_us_ff_udfs, introducing an internal
   (Private) Function Call to be used within pay_us_inv_ded_formulas.
   hr_us_ff_udfs.convert_period_type fails to convert 'weekly' figure
   to 'period' one and vica-versa in case 'Hours Calculation Type'
   is set to 'Standard' at Payroll definition level.
   Irrespective of Payroll level 'Hours Calculation Type',
   (Annualized or Standard) system should be able to convert
   weekly to period figure correctly and vice-versa.
*/
/*
    RETURN (hr_us_ff_udfs.convert_period_type(CTX_BUSINESS_GROUP_ID,
                                              CTX_PAYROLL_ID,
                                              SCL_ASG_US_WORK_SCHEDULE,
                                              ASG_HOURS,
                                              FED_CRITERIA_PCT_PRD_DI_XMPT,
                                              P_FROM_FREQ,
                                              P_TO_FREQ,
                                              PAY_EARNED_START_DATE,
                                              PAY_EARNED_END_DATE,
                                              P_ASST_STD_FREQ)
           );
*/

RETURN (Garn_Convert_Period_Type(
		p_bus_grp_id => ctx_business_group_id
	     ,p_payroll_id => ctx_payroll_id
	     ,p_asst_work_schedule => scl_asg_us_work_schedule
	     ,p_asst_std_hours => asg_hours
	     ,p_figure => fed_criteria_pct_prd_di_xmpt
	     ,p_from_freq => p_from_freq
	     ,p_to_freq => p_to_freq
	     ,p_period_start_date => pay_earned_start_date
	     ,p_period_end_date => pay_earned_end_date
	     ,p_asst_std_freq => p_asst_std_freq
            )
       );

END CONVERT_PERIOD_TYPE;

  /****************************************************************************
    Name        : FNC_FEE_CALCULATION
    Description : This function calculates fees amount for different categories
                  of involuntary deductions.
  *****************************************************************************/

FUNCTION FNC_FEE_CALCULATION
(
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_PCT_CURRENT number,
    TOTAL_OWED number,
    PRIMARY_AMOUNT_BALANCE number,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PTD_FEE_BALANCE number,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    DEDN_AMT number,
    MONTH_FEE_BALANCE number,
    ACCRUED_FEES number
)
RETURN number IS
BEGIN
RETURN (pay_wat_udfs.fnc_fee_calculation(CTX_JURISDICTION_CODE,
                                        GARN_FEE_FEE_RULE,
                                        GARN_FEE_FEE_AMOUNT,
                                        GARN_FEE_PCT_CURRENT,
                                        TOTAL_OWED,
                                        PRIMARY_AMOUNT_BALANCE,
                                        GARN_FEE_ADDL_GARN_FEE_AMOUNT,
                                        GARN_FEE_MAX_FEE_AMOUNT,
                                        PTD_FEE_BALANCE,
                                        GARN_TOTAL_FEES_ASG_GRE_RUN,
                                        DEDN_AMT,
                                        MONTH_FEE_BALANCE,
                                        ACCRUED_FEES)
      );
END FNC_FEE_CALCULATION;


  /****************************************************************************
    Name        : GET_GARN_LIMIT_MAX_DURATION
    Description : This function returns the maximum duration, in
                  number of days, for which a particular garnishment can be
                  taken in a particular state. The duration is obtained with
                  respect to the 'Date Served' of the garnishment.
  *****************************************************************************/

FUNCTION GET_GARN_LIMIT_MAX_DURATION(PAY_EARNED_START_DATE DATE)
RETURN number IS
    CURSOR csr_ovrd_duration IS
        SELECT entry_information8
          FROM pay_element_entries_f
         WHERE element_entry_id = CTX_ORIGINAL_ENTRY_ID
           AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
           AND PAY_EARNED_START_DATE BETWEEN effective_start_date AND effective_end_date;

    -- Checking Element level Override
    CURSOR csr_elem_ovrd_duration IS
         SELECT petei.eei_information12
         FROM   pay_element_entries_f peef,
                pay_element_types_f petf,
                pay_element_types_f petf_calc,
                pay_element_type_extra_info petei
         WHERE  peef.element_entry_id = CTX_ORIGINAL_ENTRY_ID
         AND    petf.element_type_id = peef.element_type_id
         AND    petf_calc.element_type_id = CTX_ELEMENT_TYPE_ID
         AND    petf_calc.element_type_id = petf.element_information5
         AND    petf.element_type_id = petei.element_type_id
         AND    petei.information_type = 'PAY_US_GARN_PROCESSING_RULE'
         AND    petei.eei_information11 = substr(CTX_JURISDICTION_CODE, 1, 2) ;

    l_ovrd_duration number;
    default_number number;
    ln_elem_ovrd_duration number ;
BEGIN

    default_number := -9999;

    OPEN csr_ovrd_duration;
        FETCH csr_ovrd_duration into l_ovrd_duration;
    CLOSE csr_ovrd_duration;

    -- If Element Entry level override is not there then check for Element level override
    IF nvl(l_ovrd_duration,default_number) = default_number THEN
       OPEN csr_elem_ovrd_duration ;
       FETCH csr_elem_ovrd_duration into ln_elem_ovrd_duration ;
       CLOSE csr_elem_ovrd_duration ;
       l_ovrd_duration := ln_elem_ovrd_duration ;
    END IF ;

    /* If exists, return the override value. Bug 3549191. */
    IF nvl(l_ovrd_duration,default_number) = default_number THEN
        RETURN (pay_wat_udfs.get_garn_limit_max_duration(CTX_ELEMENT_TYPE_ID,
                                                         CTX_ORIGINAL_ENTRY_ID,
                                                         CTX_DATE_EARNED,
                                                         CTX_JURISDICTION_CODE));
    ELSE
        RETURN (l_ovrd_duration);
    END IF;
END GET_GARN_LIMIT_MAX_DURATION;


  /****************************************************************************
    Name        : GET_GEOCODE
    Description : This function returns the geocode corresponding to inputs
                  specified.
  *****************************************************************************/


FUNCTION GET_GEOCODE
(
OVERRIDE_ADR_REGION_2 varchar2,
OVERRIDE_ADR_REGION_1 varchar2,
OVERRIDE_ADR_CITY varchar2,
OVERRIDE_ADR_POSTAL_CODE varchar2
) RETURN varchar2 IS
BEGIN
    RETURN hr_us_ff_udfs.addr_val (OVERRIDE_ADR_REGION_2,
                                   OVERRIDE_ADR_REGION_1,
                                   OVERRIDE_ADR_CITY,
                                   OVERRIDE_ADR_POSTAL_CODE);
END GET_GEOCODE;


  /****************************************************************************
    Name        : GARN_CAT
    Description : This function returns garnishment category of the specified
                  element_entry_id.
  *****************************************************************************/

FUNCTION GARN_CAT RETURN varchar2 IS
BEGIN
    RETURN(pay_wat_udfs.garn_cat (CTX_DATE_EARNED,
                                  CTX_ELEMENT_ENTRY_ID));
END GARN_CAT;

  /****************************************************************************
    Name        : CAL_FORMULA_BO
    Description : This function calculates amount to be withheld for BO, CD, G,
                  EL, ER and DCIA categories.
  *****************************************************************************/


FUNCTION CAL_FORMULA_BO
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    GARN_EXEMPTION_CALC_RULE varchar2,
    GRN_EXMPT_DEP_CALC_RULE varchar2,
    GARN_EXEMPTION_DI_PCT number,
    GARN_EXEMPTION_MIN_WAGE_FACTOR number,
    GARN_EXEMPTION_AMOUNT_VALUE number,
    GRN_EXMPT_DEP_AMT_VAL number,
    GRN_EXMPT_ADDL_DEP_AMT_VAL number,
    GARN_FEE_FEE_RULE varchar2,
    GARN_FEE_ADDL_GARN_FEE_AMOUNT number,
    GARN_FEE_FEE_AMOUNT number,
    GARN_FEE_TAKE_FEE_ON_PRORATION varchar2,
    GARN_FEE_PCT_CURRENT number,
    GARN_FEE_MAX_FEE_AMOUNT number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    STATE_MIN_WAGE number,
    ASG_FREQ varchar2,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    GARN_TOTAL_FEES_ASG_GRE_RUN number,
    GARN_TOTAL_DEDNS_ASG_GRE_RUN number,
    GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN number,
    GROSS_EARNINGS_ASG_GRE_MONTH number,
    GROSS_EARNINGS_ASG_GRE_RUN number,
    REGULAR_EARNINGS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    TAX_LEVIES_ASG_GRE_RUN number,
    GRN_DI_SUBJ_TX_ASG_GRE_RUN number,
    PRE_TAX_DEDUCTIONS_ASG_GRE_RUN number,
    PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN number,
    PR_TX_DED_SBJ_TX_ASG_GRE_RN number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    JURISDICTION varchar2,
    TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    ACCRUED_FEES number,
    PTD_FEE_BALANCE number,
    MONTH_FEE_BALANCE number,
    GARN_EXEMPTION_PRORATION_RULE varchar2,
    CALCD_ARREARS OUT NOCOPY number,
    CALCD_DEDN_AMT OUT NOCOPY number,
    CALCD_FEE OUT NOCOPY number,
    FATAL_MESG OUT NOCOPY varchar2,
    GARN_FEE OUT NOCOPY number,
    MESG OUT NOCOPY varchar2,
    MESG1 OUT NOCOPY varchar2,
    NOT_TAKEN OUT NOCOPY number,
    SF_ACCRUED_FEES OUT NOCOPY number,
    STOP_ENTRY OUT NOCOPY varchar2,
    TO_ADDL OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    TO_TOTAL_OWED OUT NOCOPY number,
    calc_subprio OUT NOCOPY number,
    DCIA_DI_SUBJ_TX_ASG_GRE_RUN number default 0,
    DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN number default 0,
    PR_TX_DCIA_SB_TX_ASG_GRE_RN number default 0,
    PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN number default 0,
    EIC_ADVANCE_ASG_GRE_RUN number default 0,
    VOL_DEDN_ROTH_ASG_GRE_RUN     number default 0,
    VOL_DEDN_SB_TX_ASG_GRE_RUN    number default 0,
    VOL_DEDN_SB_TX_JD_ASG_GRE_RUN number default 0,
    NET_ASG_RUN                   number default 0,
    NET_ASG_PTD                   number default 0

) RETURN number IS

    default_number number;
    default_date date;
    di_subj number;
    inv_dedn_in_run number;
    garn_category varchar2(10);
    dedn_amt number;
    dedn_amt_cp number;
    c_Balance_Subject_to_Garn number;
    c_Hawaii_Pct_Exempt_Range_1 number;
    c_Hawaii_Pct_Exempt_Range_2 number;
    c_Hawaii_Pct_Exempt_Range_3 number;
    c_hawaii_range_1_mnth_erngs number;
    c_hawaii_range_2_mnth_erngs number;
    c_ny_minwage_multpl_range_1 number;
    c_ny_gross_erngs_exmpt_pct number;
    c_ny_minwage_exmpt_multpl_1 number;
    c_ny_minwage_exmpt_multpl_2 number;
    c_ny_di_exmpt_pct number;
    c_ok_range_1_wkly_erngs number;
    c_ok_range_2_wkly_erngs number;
    c_Oklahoma_earnings_exempt_pct number;
    c_Federal_Minimum_Wage number;
--Bug 6678760 VMKULKAR
    l_fed_criteria_minwage_dl number;
    c_dl_gross_erngs_exmpt_pct number;
--Bug 6678760 VMKULKAR
    c_State_Minimum_Wage number; -- Bug 4556146
    ccpa_protection number;
    total_di number;
    Total_DI_per_week number;
    diff number;
    fed_criteria_pct_prd_di_xmpt number;
    fed_criteria_wk_prd_di_xmpt number;
    fed_criteria_minwage_exemption number;
    fed_criteria_exemption number;
    DI_state_exemption_amt number;
    di_state_dependents_exemption number;
    max_garn number;
    earnings_per_week number;
    OK_weekly_state_exemption_amt number;
    di_state_addl_pct_exempt number;
    di_total_state_exemption number;
    di_total_exemption number;
    di_total_period_exemption number;
    di_total_week number;
    di_hawaii_max_cd number;
    di_hawaii_max_cd_month number;
    total_di_month number;
    Subject_DISPOSABLE_INCOME number;
    IN_GARN_FEE_MAX_FEE_AMOUNT number;
    t_dedn_amt number;
    l_exmpt_ovrd number;
    garn_limit_days number;
    garn_days number;
    garn_days_end_per number;
    total_garn_run number;
    proportional_dedn_amount number;
    equal_dedn_amounts number;
    l_proration_ovrd varchar2(15);
    sub_prio_max number;
    equal_DI number;
    calcd_fee_rec number;

    amount number;
    percentage number;
    num_dependents number;
    filing_status varchar2(10);
    exempt_amt_bo number;
    monthly_cap_amount number;
    month_to_date_balance number;
    period_cap_amount number;
    period_to_date_balance number;
    accrued_fee_correction number;
    cntr number;

    l_debug_on varchar2(1);
    l_proc_name varchar2(50);
    l_garn_fee_max_fee_amt number;
    l_ini_fee_flag varchar2(10);
    lv_ele_name varchar2(100);

    ln_others_di number;
    ld_override_date date;
    ld_entry_start_date   date;
    lb_use_state_min_wage boolean;

    ln_assignment_id        Number ; -- Bug# 5150447
    ln_resident_state_code  Varchar2(30) ;
    ln_filing_status_code   Varchar2(30) ;
    l_garn_exemption_amount_value number;

    -- VMKULKAR

    l_pay_period_length varchar2(30);
    l_state_period_exemption_amt number;

    -- VMKULKAR

    -- Bug# 6133337
    lv_M_rule          VARCHAR2(100);
    ln_M_factor        NUMBER(2);
    ln_M_F_factor      NUMBER(2);
    ln_M_S_factor      NUMBER(2);
    ln_ovrd_cnt        NUMBER(2);

    -- Bug 6818016
    tmp_DI_total_week_exempt        NUMBER;
    tmp_fed_state_week_exemption    NUMBER;
    tmp_net_asg_run_prd             NUMBER;
    tmp_net_asg_ptd_week            NUMBER;
    tmp_net_asg_run_week            NUMBER;

    -- Bug# 7589784
    tmp_dedn_amt                    NUMBER;
    tmp_calc_fee                    NUMBER;
    tmp_not_taken                   NUMBER;

    -- Bug 7674615
    lb_EL_reduce_di                 BOOLEAN DEFAULT FALSE;
    fed_min_wage_prd_exempt         NUMBER;


    CURSOR cur_debug is
        SELECT parameter_value
          FROM pay_action_parameters
         WHERE parameter_name = 'GARN_DEBUG_ON';


    /*-- Cursor for Bug 3520523 --*/
    CURSOR csr_exmpt_ovrd(c_override_date date) is
        SELECT entry_information4
          FROM pay_element_entries_f
         WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
           AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
           AND c_override_date BETWEEN effective_start_date and effective_end_date;


    /* Cursot to return the Initial Fee Flag value Bug 3549298 */
    CURSOR csr_get_ini_fee_flag is
    SELECT nvl(entry_information9, 'N')
      FROM pay_element_entries_f
     WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
       AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
       AND P_CTX_DATE_EARNED BETWEEN effective_start_date and effective_end_date;

    /*-- Cursor for Bug 2658290 --*/
    CURSOR csr_get_proration_ovrd is
        select aei.aei_information3
          from per_assignment_extra_info aei,
               pay_element_entries_f pee
         where aei.assignment_id = pee.assignment_id
           and aei.information_type = 'US_PRORATION_RULE'
           and aei.aei_information_category = 'US_PRORATION_RULE'
           and aei.aei_information2 = garn_cat
           and substr(aei.aei_information1, 1, 2) = substr(P_CTX_JURISDICTION_CODE, 1, 2)
           and pee.element_entry_id = P_CTX_ORIGINAL_ENTRY_ID ;

    /* Bug 3722152 */
    CURSOR c_garn_max_fee_amt is
    select target.MAX_FEE_AMOUNT from
           PAY_US_GARN_FEE_RULES_F target,
           PAY_ELEMENT_TYPES_F pet
    WHERE target.state_code = substr(P_CTX_JURISDICTION_CODE,1,2)
      AND target.garn_category = pet.element_information1
      AND P_CTX_DATE_EARNED BETWEEN target.effective_start_date
                                AND target.effective_end_date
      AND pet.element_type_id = P_CTX_ELEMENT_TYPE_ID
      AND P_CTX_DATE_EARNED BETWEEN pet.effective_start_date
                                AND pet.effective_end_date;

    -- Bug 4079142
    -- Cursor to get the element name to be used in the message.
    CURSOR csr_get_ele_name (p_ele_type_id number) is
    select rtrim(element_name,' Calculator' )
      from pay_element_types_f
     where element_type_id = p_ele_type_id;

    -- Bug 4556146
    CURSOR csr_get_entry_start_date is
    select min(effective_start_date)
      from pay_element_entries_f
     where element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
     group by element_entry_id;

    -- Added for Bug# 5150447
    CURSOR c_get_res_state_code(p_element_entry_id in number) is
	select 	paf.assignment_id,
	        pus.state_code
	  from 	pay_element_entries_f pee,
		per_all_assignments_f paf,
		per_all_people_f ppf,
		per_addresses pa,
		pay_us_states pus
	 where	pee.element_entry_id = p_element_entry_id
	   and  pee.assignment_id = paf.assignment_id
	   and  paf.person_id = ppf.person_id
	   and  ppf.person_id = pa.person_id
	   and  pa.primary_flag = 'Y'
	   and  trim(pa.region_2) = pus.state_abbrev ;

    CURSOR c_get_filing_status(p_assignment_id in number) is
    select  filing_status_code
	from    pay_us_emp_state_tax_rules_f pestr,
	        per_all_assignments_f paf,
     		hr_locations hl,
		    pay_us_states pus
	where   pestr.assignment_id = p_assignment_id
	and     pestr.assignment_id = paf.assignment_id
	and     paf.location_id = hl.location_id
	and     pus.state_abbrev = nvl(loc_information17,region_2) ;

    CURSOR c_get_allowance_value(c_input_value_name varchar2) IS
    select peev.screen_entry_value
      from pay_element_entries_f peef,
           pay_element_entry_values_f peev,
           pay_input_values_f pivf
     where peef.element_entry_id = P_CTX_ELEMENT_ENTRY_ID
       and peev.element_entry_id = peef.element_entry_id
       and pivf.element_type_id = peef.element_type_id
       and pivf.name = c_input_value_name
       and peev.input_value_id = pivf.input_value_id
       and P_CTX_DATE_EARNED between peev.effective_start_date
                                 and peev.effective_end_date;
     -- Bug# 6132855
     -- Federal Minimum Wage now is stored in JIT table
     CURSOR c_get_federal_min_wage IS
     SELECT fed_information1
       FROM pay_us_federal_tax_info_f
      WHERE fed_information_category = 'WAGEATTACH LIMIT'
        AND P_CTX_DATE_EARNED BETWEEN effective_start_date
                                  AND effective_end_date;

-- VMKULKAR
     CURSOR c_get_state_garn_exemption_amt(p_column_name varchar2, p_row_name varchar2) IS
	select puci.value
	from pay_user_column_instances_f puci,
	   pay_user_tables put,
	   pay_user_rows_f pur,
	   pay_user_columns puc
	where puci.user_column_id = puc.user_column_id
	and puci.user_row_id = pur.user_row_id
	and put.user_table_id = puc.user_table_id
	and put.user_table_id = pur.user_table_id
	and put.user_table_name = 'Wage Attach State Exemptions Table'
	and pur.row_low_range_or_name = p_row_name
	and puc.user_column_name = p_column_name
	and p_ctx_date_earned between puci.effective_start_date
                                  and puci.effective_end_date;


     CURSOR c_get_pay_period_length(p_payroll_id number) IS
	select period_type
	   from pay_all_payrolls_f
	 where payroll_id = p_payroll_id
	 and p_ctx_date_earned between effective_start_date
                                  and effective_end_date;

-- VMKULKAR

    -- Bug# 6133337
    -- Checking If Multiple Element level Overrides exist
    CURSOR csr_elem_ovrd_fed_stat_M_count IS
         SELECT count(petei.eei_information13)
         FROM   pay_element_entries_f peef,
                pay_element_types_f petf,
                pay_element_types_f petf_calc,
                pay_element_type_extra_info petei
         WHERE  peef.element_entry_id = CTX_ORIGINAL_ENTRY_ID
         AND    petf.element_type_id = peef.element_type_id
         AND    petf_calc.element_type_id = CTX_ELEMENT_TYPE_ID
         AND    petf_calc.element_type_id = petf.element_information5
         AND    petf.element_type_id = petei.element_type_id
         AND    petei.information_type = 'PAY_US_GARN_PROCESSING_RULE'
         AND    petei.eei_information11 = substr(CTX_JURISDICTION_CODE, 1, 2)
         GROUP BY petei.information_type
                 ,petei.eei_information11;

    -- Checking Element level Override
    CURSOR csr_elem_ovrd_fed_stat_M IS
         SELECT petei.eei_information13
               ,petei.eei_information14
         FROM   pay_element_entries_f peef,
                pay_element_types_f petf,
                pay_element_types_f petf_calc,
                pay_element_type_extra_info petei
         WHERE  peef.element_entry_id = CTX_ORIGINAL_ENTRY_ID
         AND    petf.element_type_id = peef.element_type_id
         AND    petf_calc.element_type_id = CTX_ELEMENT_TYPE_ID
         AND    petf_calc.element_type_id = petf.element_information5
         AND    petf.element_type_id = petei.element_type_id
         AND    petei.information_type = 'PAY_US_GARN_PROCESSING_RULE'
         AND    petei.eei_information11 = substr(CTX_JURISDICTION_CODE, 1, 2) ;

BEGIN
    l_proc_name := l_package_name||'CAL_FORMULA_BO';
    hr_utility.trace('Entering '||l_proc_name);

    default_number := -9999;
    default_date := fnd_date.canonical_to_date('0001/01/01');
    sub_prio_max := 9999;
    amount := GLB_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    percentage := GLB_PCT(P_CTX_ORIGINAL_ENTRY_ID);
    num_dependents := GLB_NUM_DEPS(P_CTX_ORIGINAL_ENTRY_ID);
    filing_status := GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID);
    exempt_amt_bo := GLB_EXEMPT_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    monthly_cap_amount := GLB_MONTH_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    month_to_date_balance := GLB_MTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);
    period_cap_amount := GLB_PTD_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    period_to_date_balance := GLB_PTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);
    accrued_fee_correction := GLB_TO_ACCRUED_FEES(P_CTX_ORIGINAL_ENTRY_ID);
    l_garn_fee_max_fee_amt := NULL;

    --Bug 6678760 VMKULKAR
    l_fed_criteria_minwage_dl:=0;
    --Bug 6678760 VMKULKAR


    OPEN cur_debug;
        FETCH cur_debug into l_debug_on;
    CLOSE cur_debug;

    /*
     * Fetch the value of Initial Fee Flag. Bug 3549298
     */

    open csr_get_ini_fee_flag;
    fetch csr_get_ini_fee_flag into l_ini_fee_flag;
    close csr_get_ini_fee_flag;

    -- Fetching Federal Minimum Wage Value from JIT table
    OPEN c_get_federal_min_wage;
    FETCH c_get_federal_min_wage INTO c_Federal_Minimum_Wage;
    CLOSE c_get_federal_min_wage;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Input parameters....');
        hr_utility.trace('P_CTX_BUSINESS_GROUP_ID = '||P_CTX_BUSINESS_GROUP_ID);
        hr_utility.trace('P_CTX_PAYROLL_ID = '||P_CTX_PAYROLL_ID);
        hr_utility.trace('P_CTX_ELEMENT_TYPE_ID = '||P_CTX_ELEMENT_TYPE_ID);
        hr_utility.trace('P_CTX_ORIGINAL_ENTRY_ID = '||P_CTX_ORIGINAL_ENTRY_ID);
        hr_utility.trace('P_CTX_DATE_EARNED = '||P_CTX_DATE_EARNED);
        hr_utility.trace('P_CTX_JURISDICTION_CODE = '||P_CTX_JURISDICTION_CODE);
        hr_utility.trace('P_CTX_ELEMENT_ENTRY_ID = '||P_CTX_ELEMENT_ENTRY_ID);
        hr_utility.trace('GARN_EXEMPTION_CALC_RULE = '||GARN_EXEMPTION_CALC_RULE);
        hr_utility.trace('GRN_EXMPT_DEP_CALC_RULE = '||GRN_EXMPT_DEP_CALC_RULE);
        hr_utility.trace('GARN_EXEMPTION_DI_PCT = '||GARN_EXEMPTION_DI_PCT);
        hr_utility.trace('GARN_EXEMPTION_MIN_WAGE_FACTOR = '||GARN_EXEMPTION_MIN_WAGE_FACTOR);
        hr_utility.trace('GARN_EXEMPTION_AMOUNT_VALUE = '||GARN_EXEMPTION_AMOUNT_VALUE);
        hr_utility.trace('GRN_EXMPT_DEP_AMT_VAL = '||GRN_EXMPT_DEP_AMT_VAL);
        hr_utility.trace('GRN_EXMPT_ADDL_DEP_AMT_VAL = '||GRN_EXMPT_ADDL_DEP_AMT_VAL);
        hr_utility.trace('GARN_FEE_FEE_RULE = '||GARN_FEE_FEE_RULE);
        hr_utility.trace('GARN_FEE_ADDL_GARN_FEE_AMOUNT = '||GARN_FEE_ADDL_GARN_FEE_AMOUNT);
        hr_utility.trace('GARN_FEE_FEE_AMOUNT = '||GARN_FEE_FEE_AMOUNT);
        hr_utility.trace('GARN_FEE_TAKE_FEE_ON_PRORATION = '||GARN_FEE_TAKE_FEE_ON_PRORATION);
        hr_utility.trace('GARN_FEE_PCT_CURRENT = '||GARN_FEE_PCT_CURRENT);
        hr_utility.trace('GARN_FEE_MAX_FEE_AMOUNT = '||GARN_FEE_MAX_FEE_AMOUNT);
        hr_utility.trace('PAY_EARNED_START_DATE = '||PAY_EARNED_START_DATE);
        hr_utility.trace('PAY_EARNED_END_DATE = '||PAY_EARNED_END_DATE);
        hr_utility.trace('SCL_ASG_US_WORK_SCHEDULE = '||SCL_ASG_US_WORK_SCHEDULE);
        hr_utility.trace('ASG_HOURS = '||ASG_HOURS);
        hr_utility.trace('STATE_MIN_WAGE = '||STATE_MIN_WAGE);
        hr_utility.trace('ASG_FREQ = '||ASG_FREQ);
        hr_utility.trace('TERMINATED_EMPLOYEE = '||TERMINATED_EMPLOYEE);
        hr_utility.trace('FINAL_PAY_PROCESSED = '||FINAL_PAY_PROCESSED);
        hr_utility.trace('GARN_TOTAL_FEES_ASG_GRE_RUN = '||GARN_TOTAL_FEES_ASG_GRE_RUN);
        hr_utility.trace('GARN_TOTAL_DEDNS_ASG_GRE_RUN = '||GARN_TOTAL_DEDNS_ASG_GRE_RUN);
        hr_utility.trace('GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN = '||GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('GROSS_EARNINGS_ASG_GRE_MONTH = '||GROSS_EARNINGS_ASG_GRE_MONTH);
        hr_utility.trace('GROSS_EARNINGS_ASG_GRE_RUN = '||GROSS_EARNINGS_ASG_GRE_RUN);
        hr_utility.trace('REGULAR_EARNINGS_ASG_GRE_RUN = '||REGULAR_EARNINGS_ASG_GRE_RUN);
        hr_utility.trace('NET_ASG_GRE_RUN = '||NET_ASG_GRE_RUN);
        hr_utility.trace('TAX_DEDUCTIONS_ASG_GRE_RUN = '||TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('TAX_LEVIES_ASG_GRE_RUN = '||TAX_LEVIES_ASG_GRE_RUN);
        hr_utility.trace('GRN_DI_SUBJ_TX_ASG_GRE_RUN = '||GRN_DI_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('PRE_TAX_DEDUCTIONS_ASG_GRE_RUN = '||PRE_TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN = '||PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN);
        hr_utility.trace('PR_TX_DED_SBJ_TX_ASG_GRE_RN = '||PR_TX_DED_SBJ_TX_ASG_GRE_RN);
        hr_utility.trace('TOT_WHLD_SUPP_ASG_GRE_RUN = '||TOT_WHLD_SUPP_ASG_GRE_RUN);
        hr_utility.trace('TOTAL_WITHHELD_FEE_ASG_GRE_RUN = '||TOTAL_WITHHELD_FEE_ASG_GRE_RUN);
        hr_utility.trace('JURISDICTION = '||JURISDICTION);
        hr_utility.trace('TOTAL_OWED = '||TOTAL_OWED);
        hr_utility.trace('DATE_SERVED = '||DATE_SERVED);
        hr_utility.trace('ADDITIONAL_AMOUNT_BALANCE = '||ADDITIONAL_AMOUNT_BALANCE);
        hr_utility.trace('REPLACEMENT_AMOUNT_BALANCE = '||REPLACEMENT_AMOUNT_BALANCE);
        hr_utility.trace('PRIMARY_AMOUNT_BALANCE = '||PRIMARY_AMOUNT_BALANCE);
        hr_utility.trace('ACCRUED_FEES = '||ACCRUED_FEES);
        hr_utility.trace('PTD_FEE_BALANCE = '||PTD_FEE_BALANCE);
        hr_utility.trace('MONTH_FEE_BALANCE = '||MONTH_FEE_BALANCE);
        hr_utility.trace('GARN_EXEMPTION_PRORATION_RULE = '||GARN_EXEMPTION_PRORATION_RULE);
        hr_utility.trace('DCIA_DI_SUBJ_TX_ASG_GRE_RUN = '||DCIA_DI_SUBJ_TX_ASG_GRE_RUN);
        hr_utility.trace('DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN = '||DCIA_DI_SUBJ_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('PR_TX_DCIA_SB_TX_ASG_GRE_RN = '||PR_TX_DCIA_SB_TX_ASG_GRE_RN);
        hr_utility.trace('PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN = '||PR_TX_DCIA_SB_TX_JD_ASG_GRE_RN);
        hr_utility.trace('EIC_ADVANCE_ASG_GRE_RUN = ' || EIC_ADVANCE_ASG_GRE_RUN);
        hr_utility.trace('INITIAL FEE FLAG ' || l_ini_fee_flag);
        hr_utility.trace('VOL_DEDN_ROTH_ASG_GRE_RUN = ' || VOL_DEDN_ROTH_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_ASG_GRE_RUN);
        hr_utility.trace('VOL_DEDN_SB_TX_JD_ASG_GRE_RUN = ' || VOL_DEDN_SB_TX_JD_ASG_GRE_RUN);
        hr_utility.trace('c_Federal_Minimum_Wage = ' || c_Federal_Minimum_Wage);
        hr_utility.trace('NET_ASG_RUN = ' || NET_ASG_RUN);
        hr_utility.trace('NET_ASG_PTD = ' || NET_ASG_PTD);
    END IF;


    /*--------- Set Contexts -------------*/
    CTX_BUSINESS_GROUP_ID := P_CTX_BUSINESS_GROUP_ID;
    CTX_PAYROLL_ID        := P_CTX_PAYROLL_ID;
    CTX_ELEMENT_TYPE_ID   := P_CTX_ELEMENT_TYPE_ID;
    CTX_ORIGINAL_ENTRY_ID := P_CTX_ORIGINAL_ENTRY_ID;
    CTX_DATE_EARNED       := P_CTX_DATE_EARNED;
    CTX_JURISDICTION_CODE := P_CTX_JURISDICTION_CODE;
    CTX_ELEMENT_ENTRY_ID  := P_CTX_ELEMENT_ENTRY_ID;
    /*------------------------------------*/

    garn_fee:=0;
    inv_dedn_in_run := TAX_LEVIES_ASG_GRE_RUN
                           + TOT_WHLD_SUPP_ASG_GRE_RUN
                           + TOTAL_WITHHELD_FEE_ASG_GRE_RUN
                           + GARN_TOTAL_DEDNS_ASG_GRE_RUN
                           + GARN_TOTAL_FEES_ASG_GRE_RUN;
    garn_category := garn_cat;

    GLB_NUM_ELEM := GLB_NUM_ELEM - 1;
    hr_utility.trace('GLB_NUM_ELEM = '|| GLB_NUM_ELEM);

    IF Accrued_Fees <> default_number THEN
        SF_Accrued_Fees := Accrued_Fees;
    ELSE
        SF_Accrued_Fees := 0;
    END IF;

    -- Bug 4079142
    -- Get the element name to be used in the message.
    open csr_get_ele_name(CTX_ELEMENT_TYPE_ID);
    fetch csr_get_ele_name into lv_ele_name;
    close csr_get_ele_name;

    /*
     * Bug 3722152
     * Get the GARN_FEE_MAX_FEE_AMOUNT
     */
    open c_garn_max_fee_amt;
    fetch c_garn_max_fee_amt into l_garn_fee_max_fee_amt;
    close c_garn_max_fee_amt;

    if l_garn_fee_max_fee_amt is NULL then
       l_garn_fee_max_fee_amt := 99999999;
    else
       l_garn_fee_max_fee_amt := GARN_FEE_MAX_FEE_AMOUNT;
    end if;

    -- Bug 4858720
    -- Use EIC_ADVANCE_ASG_GRE_RUN for calculatin the Deduction amount
    IF garn_category = 'EL' THEN
        -- Bug# 4676867
        c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                        GRN_DI_SUBJ_TX_ASG_GRE_RUN)
                                        - ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                           + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN
                                              - PR_TX_DED_SBJ_TX_ASG_GRE_RN)
                                           + (VOL_DEDN_ROTH_ASG_GRE_RUN
                                             - VOL_DEDN_SB_TX_ASG_GRE_RUN)
                                           );
    ELSIF garn_category = 'DCIA' THEN
        -- Bug# 4676867
        c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                        DCIA_DI_SUBJ_TX_ASG_GRE_RUN)
                                        - ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                           + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN
                                              - PR_TX_DCIA_SB_TX_ASG_GRE_RN)
                                           + (VOL_DEDN_ROTH_ASG_GRE_RUN
                                             - VOL_DEDN_SB_TX_ASG_GRE_RUN)
                                           );
    ELSE
        -- Bug# 4676867
        c_Balance_Subject_to_Garn := (REGULAR_EARNINGS_ASG_GRE_RUN +
                                    LEAST(GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN, GRN_DI_SUBJ_TX_ASG_GRE_RUN)) -
                                    ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                                     + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN -
                                    (LEAST(PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN, PR_TX_DED_SBJ_TX_ASG_GRE_RN )))
                                     + (VOL_DEDN_ROTH_ASG_GRE_RUN -
                                        LEAST(VOL_DEDN_SB_TX_ASG_GRE_RUN,VOL_DEDN_SB_TX_JD_ASG_GRE_RUN))
                                    );
    END IF;

    -- This DI is used for the calculation of CCPA Protection
    -- if DCIA is processed along with Non Support elements.
    -- Bug 4858720
    -- Use EIC_ADVANCE_ASG_GRE_RUN for calculatin the Deduction amount
    -- Bug# 4676867
    ln_others_di := (REGULAR_EARNINGS_ASG_GRE_RUN +
                    LEAST(GRN_DI_SUBJ_TX_JD_ASG_GRE_RUN, GRN_DI_SUBJ_TX_ASG_GRE_RUN)) -
                    ((TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN)
                     + (PRE_TAX_DEDUCTIONS_ASG_GRE_RUN -
                    (LEAST(PR_TX_DED_SBJ_TX_JD_ASG_GRE_RN, PR_TX_DED_SBJ_TX_ASG_GRE_RN )))
                     + (VOL_DEDN_ROTH_ASG_GRE_RUN -
                        LEAST(VOL_DEDN_SB_TX_ASG_GRE_RUN, VOL_DEDN_SB_TX_JD_ASG_GRE_RUN))
                    );

    calc_subprio := entry_subpriority;
    IF calc_subprio = 1 THEN
        IF date_served <> default_date THEN
            calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - Date_Served);
        END IF;
    END IF;
    c_Hawaii_Pct_Exempt_Range_1 := .95;
    c_Hawaii_Pct_Exempt_Range_2 := .90;
    c_Hawaii_Pct_Exempt_Range_3 := .80;
    c_hawaii_range_1_mnth_erngs := 100;
    c_hawaii_range_2_mnth_erngs := 200;
    c_ny_minwage_multpl_range_1 := 30;
    c_ny_minwage_multpl_range_1 := 40;
    c_ny_gross_erngs_exmpt_pct := .90;
    c_ny_minwage_exmpt_multpl_1 := 30;
    c_ny_minwage_exmpt_multpl_2 := 40;
    c_ny_di_exmpt_pct := .75;
    c_ok_range_1_wkly_erngs := 48;
    c_ok_range_2_wkly_erngs := 64;
    c_Oklahoma_earnings_exempt_pct := .75;

--bug 6678760 VMKULKAR
    c_dl_gross_erngs_exmpt_pct :=.85;
--bug 6678760 VMKULKAR

    --c_Federal_Minimum_Wage := 5.15;  /* Current as of September 1997. */
    ln_M_F_Factor := GARN_EXEMPTION_MIN_WAGE_FACTOR;
    ln_M_S_Factor := NULL;

    -- Bug 4556146
    IF SUBSTR(Jurisdiction,1,2) = '07' THEN
        c_Federal_Minimum_Wage := STATE_MIN_WAGE;
    ELSIF (SUBSTR(Jurisdiction,1,2) = '14'
           AND (garn_category = 'G' OR garn_category = 'CD')) THEN
        c_State_Minimum_Wage := STATE_MIN_WAGE;
        hr_utility.trace('Setting State Minimum Wage for Illinois to ' || c_State_Minimum_Wage);
    -- Adding State Minimum Wage for Maine
    ELSIF (SUBSTR(Jurisdiction,1,2) = '20'
           AND (garn_category = 'G' OR garn_category = 'CD')) THEN
	c_State_Minimum_Wage := STATE_MIN_WAGE;
        hr_utility.trace('Setting State Minimum Wage for Maine to : ' || c_State_Minimum_Wage);
    ELSIF (SUBSTR(Jurisdiction,1,2) = '06'
           AND (garn_category = 'G' OR garn_category = 'CD')) THEN
        c_State_Minimum_Wage := STATE_MIN_WAGE;
        hr_utility.trace('Setting State Minimum Wage for Colorado := ' || c_State_Minimum_Wage);
    END IF;
    --mesg1 := 'STATE_MIN_WAGE = '||TO_CHAR(STATE_MIN_WAGE);

    IF NVL(STATE_MIN_WAGE, 0) <> 0 AND (garn_category = 'G' OR garn_category = 'CD') THEN
       c_State_Minimum_Wage := STATE_MIN_WAGE;
       hr_utility.trace('For Garn Category CD and G State Min Wage to be used := '||c_State_Minimum_Wage);
    END IF;

    OPEN csr_elem_ovrd_fed_stat_M_count;
    FETCH csr_elem_ovrd_fed_stat_M_count INTO ln_ovrd_cnt;
    CLOSE csr_elem_ovrd_fed_stat_M_count;

    -- Checking Count()
    IF NVL(ln_ovrd_cnt,0) > 1 THEN
        STOP_ENTRY := 'Y';
        mesg := 'Multiple overrides for the same state exist at Element Extra Information level for '|| lv_ele_name
                ||' in US Garnishment Processing Rules. Please correct your setup before running payroll.';
        to_total_owed := 0;
        if GLB_NUM_ELEM = 0 then
           GLB_SUPPORT_DI := NULL;
           GLB_OTHER_DI_FLAG := NULL;
           reset_global_var;
        end if;
        RETURN (1);
    END IF;

    OPEN csr_elem_ovrd_fed_stat_M;
    FETCH csr_elem_ovrd_fed_stat_M INTO lv_M_rule, ln_M_factor;
    CLOSE csr_elem_ovrd_fed_stat_M;

    hr_utility.trace('lv_M_rule := ' || lv_M_rule);
    hr_utility.trace('ln_M_F_factor := ' || ln_M_F_factor);
    hr_utility.trace('ln_M_S_factor := ' || ln_M_S_factor);


    IF lv_M_rule IS NOT NULL THEN
       IF lv_M_rule = 'H' THEN
          c_State_Minimum_Wage := GREATEST(c_Federal_Minimum_Wage, NVL(STATE_MIN_WAGE,0));
          IF ln_M_factor IS NOT NULL THEN
             ln_M_S_factor := ln_M_factor;
          ELSE
             ln_M_S_factor := GARN_EXEMPTION_MIN_WAGE_FACTOR;
          END IF;
       ELSIF lv_M_rule = 'S' THEN
          c_State_Minimum_Wage := NVL(STATE_MIN_WAGE, c_Federal_Minimum_Wage);
          IF ln_M_factor IS NOT NULL THEN
             ln_M_S_factor := ln_M_factor;
          ELSE
             ln_M_S_factor := GARN_EXEMPTION_MIN_WAGE_FACTOR;
          END IF;
       ELSIF lv_M_rule = 'F' THEN
          c_State_Minimum_Wage := c_Federal_Minimum_Wage;
          IF ln_M_factor IS NOT NULL THEN
             ln_M_F_factor := ln_M_factor;
          END IF;
       END IF;
    END IF;

    IF NVL(c_State_Minimum_Wage, 0) = 0 THEN
       c_State_Minimum_Wage := c_Federal_Minimum_Wage;
    END IF;

    /* Adding for Bug# 7600041 */

    IF NVL(ln_M_S_factor, 0) = 0 THEN
       IF NVL(ln_M_F_factor, 0) = 0 THEN
          ln_M_F_factor := 30;
       END IF;
    END IF;


    /* *** Calculation Section BEGIN *** */
    IF GARN_EXEMPTION_CALC_RULE = 'NOT_ALLOWED' THEN
        STOP_ENTRY := 'Y';
        mesg := 'This type of garnishment is not allowed in this state.';
        to_total_owed := 0;
        if GLB_NUM_ELEM = 0 then
           GLB_SUPPORT_DI := NULL;
           GLB_OTHER_DI_FLAG := NULL;
           reset_global_var;
        end if;
        RETURN (1);
    ELSIF GARN_EXEMPTION_CALC_RULE = 'ONE_FED' OR
          GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_AMT' OR
          GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_PCT' OR
          GARN_EXEMPTION_CALC_RULE = 'ONE_MARSTAT_RULE' OR
          GARN_EXEMPTION_CALC_RULE = 'ONE_EXEMPT_BALANCE' THEN
        IF GARN_TOTAL_DEDNS_ASG_GRE_RUN = 0 THEN
            IF Replacement_Amount_Balance <> 0 THEN
                --dedn_amt := Replacement_Amount_Balance;
                to_repl := -1 * Replacement_Amount_Balance;
            /*ELSIF Amount <> 0 THEN
                dedn_amt := Amount;
            ELSIF Percentage <> 0 THEN
                dedn_amt := (Percentage * c_Balance_Subject_to_Garn) / 100;
            ELSE
                dedn_amt := c_Balance_Subject_to_Garn;*/
            END IF;
        ELSIF NOT GLB_ALLOW_MULT_DEDN THEN /* Bug 1481913 */
            dedn_amt := 0;
            calcd_dedn_amt := dedn_amt;
            to_total_owed := 0;
            mesg := 'Element ' || lv_ele_name || ' will not be processed as there is no Garnishment amount to be taken.';
            if GLB_NUM_ELEM = 0 then
                GLB_SUPPORT_DI := NULL;
                GLB_OTHER_DI_FLAG := NULL;
                GLB_DCIA_EXIST_FLAG := NULL;
                reset_global_var;
            end if;
            RETURN (2);
        END IF;
        GLB_ALLOW_MULT_DEDN := FALSE; /* Bug 1481913 */

    /* *** Check for override to wage attachment deduction amount. *** */
    ELSIF Replacement_Amount_Balance <> 0 THEN
        --dedn_amt := Replacement_Amount_Balance;
        to_repl := -1 * Replacement_Amount_Balance;

    /*ELSIF Amount <> 0 THEN
        dedn_amt := Amount;

    ELSIF Percentage <> 0 THEN
        dedn_amt := (Percentage * c_Balance_Subject_to_Garn) / 100;
    ELSE
        dedn_amt := c_Balance_Subject_to_Garn;*/
    END IF;

    /* *** Add in any adjustments. *** */
    IF Additional_Amount_Balance <> 0 THEN
        --dedn_amt := dedn_amt + Additional_Amount_Balance;
        to_addl := -1 * Additional_Amount_Balance;
    END IF;

    dedn_amt := gar_dedn_tab (P_CTX_ORIGINAL_ENTRY_ID);
    dedn_amt_cp := dedn_amt;
    total_garn_run := 0;
    cntr := gar_dedn_tab.first;
    WHILE cntr is not null LOOP
       hr_utility.trace('Garnishment deduction ('||cntr||') = '||gar_dedn_tab(cntr));
       total_garn_run := total_garn_run + gar_dedn_tab(cntr);
       cntr := gar_dedn_tab.NEXT(cntr);
    END LOOP;

/* *** Arrears processing BEGIN *** */

    IF Monthly_Cap_Amount <> 0  THEN
        IF Monthly_Cap_Amount - Month_To_Date_Balance < 0 THEN
            fatal_mesg := 'MTD Balance > Monthly Cap by $' ||
                            TO_CHAR(Month_To_Date_Balance - Monthly_Cap_Amount ) ||
                            '. Adjust Balance for ' || lv_ele_name || '.';
            GLB_SUPPORT_DI := NULL;
            GLB_OTHER_DI_FLAG := NULL;
            GLB_DCIA_EXIST_FLAG := NULL;
            reset_global_var;
            RETURN (3);
        ELSIF dedn_amt + Month_To_Date_Balance > Monthly_Cap_Amount THEN
            -- Bug 4748532
            IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
               IF actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) > (Monthly_Cap_Amount - Month_To_Date_Balance) THEN
                  actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := Monthly_Cap_Amount - Month_To_Date_Balance;
               END IF;
               hr_utility.trace('Actual Deduction Amount(MTD) = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
               hr_utility.trace('Deduction Amount(MTD) = ' || DEDN_AMT);
            ELSE
               dedn_amt := Monthly_Cap_Amount - Month_To_Date_Balance;
            END IF;
        END IF;
    END IF;

    IF Period_Cap_Amount <> 0  THEN
        IF Period_Cap_Amount - Period_To_Date_Balance < 0 THEN
            fatal_mesg := 'PTD Balance > Period Cap by $' ||
							 TO_CHAR(Period_To_Date_Balance - Period_Cap_Amount ) ||
                             '. Adjust Balance for ' || lv_ele_name || '.';
            GLB_SUPPORT_DI := NULL;
            GLB_OTHER_DI_FLAG := NULL;
            GLB_DCIA_EXIST_FLAG := NULL;
            reset_global_var;
            RETURN (4);
        ELSIF dedn_amt + Period_To_Date_Balance > Period_Cap_Amount THEN
            -- Bug 4748532
            IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
               IF actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) > (Period_Cap_Amount - Period_To_Date_Balance) THEN
                  actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) := Period_Cap_Amount - Period_To_Date_Balance;
               END IF;
               hr_utility.trace('Actual Deduction Amount(PTD) = ' || actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID));
               hr_utility.trace('Deduction Amount(PTD) = ' || DEDN_AMT);
            ELSE
               dedn_amt := Period_Cap_Amount - Period_To_Date_Balance;
            END IF;
        END IF;
    END IF;

    /**** Legislative limit verification BEGIN *****/

    Total_DI := c_Balance_Subject_to_Garn; /* Step #2 */
    ccpa_protection  := GET_CCPA_PROTECTION(Total_DI,
                                            ln_others_di,
                                            GLB_SUPPORT_DI,
                                            .25);

    /*-- Bug 3520523. Obtain the exemption percentage override value, if exists. --*/
    -- Bug 3800845
    -- Use the maximum of the 'Date Earned' and 'End Date' for finding
    -- the override values
    if P_CTX_DATE_EARNED > PAY_EARNED_END_DATE then
        ld_override_date := P_CTX_DATE_EARNED;
    else
        ld_override_date := PAY_EARNED_END_DATE;
    end if;

    FOR csr_exmpt_ovrd_rec IN csr_exmpt_ovrd(ld_override_date) LOOP
        l_exmpt_ovrd := csr_exmpt_ovrd_rec.entry_information4;
    END LOOP;

    /* Garnishment exemption by federal criteria. */
    IF GARN_EXEMPTION_DI_PCT = 0 AND (garn_category = 'EL' OR garn_category = 'DCIA') THEN
        fed_criteria_pct_prd_di_xmpt := .75 * Total_DI;
    ELSE
        IF nvl(l_exmpt_ovrd,default_number) = default_number THEN
           -- Bug 4318944 For Hawaii
           -- Convert the DI to PER Week DI and if calculate the Federal
           -- Exemption amount based on the Weekly DI
           IF SUBSTR(Jurisdiction,1,2) = '12' AND garn_category = 'CD' THEN
              di_total_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                   ASG_HOURS,
                                                   Total_DI,
                                                   'NOT ENTERED',
                                                   'WEEK',
                                                   PAY_EARNED_START_DATE,
                                                   PAY_EARNED_END_DATE,
                                                   ASG_FREQ);

              -- If DI is > 206 then 75% of the amount is exempted
              -- If it is < 206 and > 154.50 then the whole 154.5 is exempted
              IF di_total_week  > 206 THEN
                 fed_criteria_wk_prd_di_xmpt := 0.75 * di_total_week;
              ELSIF di_total_week  > 154.50 THEN
                 fed_criteria_wk_prd_di_xmpt := 154.50;
              ELSE
                 fed_criteria_wk_prd_di_xmpt := di_total_week;
              END IF;
              fed_criteria_pct_prd_di_xmpt := Convert_Period_Type(
                                                      SCL_ASG_US_WORK_SCHEDULE,
                                                      ASG_HOURS,
                                                      fed_criteria_wk_prd_di_xmpt,
                                                      'WEEK',
                                                      'NOT ENTERED',
                                                      PAY_EARNED_START_DATE,
                                                      PAY_EARNED_END_DATE,
                                                      ASG_FREQ);
              hr_utility.trace('Hawaii Credit Debt Federal Exemption Calculation');
              hr_utility.trace('Total Period DI = ' || Total_DI);
              hr_utility.trace('Total Weekly DI = ' || di_total_week);
              hr_utility.trace('Federal Weekly Exemption = ' || fed_criteria_wk_prd_di_xmpt);
              hr_utility.trace('Federal Period Exemption = ' || fed_criteria_pct_prd_di_xmpt);
           ELSE
              fed_criteria_pct_prd_di_xmpt := (GARN_EXEMPTION_DI_PCT / 100) * Total_DI;
           END IF;
        ELSE
            hr_utility.trace('Overriding exemption percentage = '||l_exmpt_ovrd);
            fed_criteria_pct_prd_di_xmpt := (l_exmpt_ovrd / 100) * Total_DI;
            -- Bug 4145789
            -- We override the CCPA value, if the Exemption percenatge
            -- overridden makes the DI value to be more than CCPA value
            -- therby allowing to deduct according to the Exemption percentage
            -- specified
            IF (Total_DI - fed_criteria_pct_prd_di_xmpt) > ccpa_protection THEN
                ccpa_protection := Total_DI - fed_criteria_pct_prd_di_xmpt;
                hr_utility.trace('New CCPA Value : ' || ccpa_protection);
            END IF;
        END IF;
    END IF;

    /* The period DI exemption must be converted to a Weekly figure. */
    fed_criteria_wk_prd_di_xmpt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,ASG_HOURS,
                                                        fed_criteria_pct_prd_di_xmpt,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                         PAY_EARNED_START_DATE,
                                                         PAY_EARNED_END_DATE,
                                                         ASG_FREQ);

    hr_utility.trace('fed_criteria_pct_prd_di_xmpt = '||fed_criteria_pct_prd_di_xmpt);
    IF GARN_EXEMPTION_MIN_WAGE_FACTOR = 0 AND (garn_category = 'EL' or garn_category = 'DCIA') THEN

        /* Adding for Bug# 7600041 */
        IF NVL(ln_M_F_Factor, 0) = 0 THEN
           ln_M_F_Factor := 30;
        END IF;

        fed_criteria_minwage_exemption := NVL(ln_M_F_Factor, 30) * c_Federal_Minimum_Wage;
    ELSE
        fed_criteria_minwage_exemption := NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage;
    END IF;

    fed_criteria_exemption := GREATEST(fed_criteria_wk_prd_di_xmpt,
                                       fed_criteria_minwage_exemption);
    hr_utility.trace('fed_criteria_wk_prd_di_xmpt = '||fed_criteria_wk_prd_di_xmpt);
    hr_utility.trace('fed_criteria_minwage_exemption = '||fed_criteria_minwage_exemption);
    /* Garnishment exemption by state specific criteria. */
    DI_state_exemption_amt := 0;
    DI_state_dependents_exemption := 0;

    -- Bug 4079142
    -- Added the IF condition as State Exemption Calculation as DCIA is
    -- Federal Involuntary Deduction

--    VMKULKAR

    l_garn_exemption_amount_value := GARN_EXEMPTION_AMOUNT_VALUE;

    hr_utility.trace('Before l_garn_exemption_amount_value = '||l_garn_exemption_amount_value);


    hr_utility.trace('Vallabh Jurisdiction = '||Jurisdiction);

    hr_utility.trace('Vallabh garn_category = '||garn_category);

    IF SUBSTR(Jurisdiction,1,2) = '38' AND garn_category in ('CD','G') THEN

    hr_utility.trace('Inside Vallabh IF');

    hr_utility.trace('P_CTX_PAYROLL_ID = '||P_CTX_PAYROLL_ID);
    hr_utility.trace('p_ctx_date_earned = '||p_ctx_date_earned);


    -- Get the pay period length
	OPEN c_get_pay_period_length(P_CTX_PAYROLL_ID);
	fetch c_get_pay_period_length into l_pay_period_length;
	close c_get_pay_period_length;

    hr_utility.trace('l_pay_period_length = '||l_pay_period_length);

    -- Get the exemption amount

	OPEN c_get_state_garn_exemption_amt(l_pay_period_length,'Oregon');
	fetch c_get_state_garn_exemption_amt into l_state_period_exemption_amt;
	close c_get_state_garn_exemption_amt;

    hr_utility.trace('l_state_period_exemption_amt = '||l_state_period_exemption_amt);


        l_garn_exemption_amount_value := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                              ASG_HOURS,
                                              l_state_period_exemption_amt,
                                              'NOT ENTERED',
                                              'WEEK',
                                              PAY_EARNED_START_DATE,
                                              PAY_EARNED_END_DATE,
                                              ASG_FREQ);

    hr_utility.trace('GARN_EXEMPTION_AMOUNT_VALUE = '||GARN_EXEMPTION_AMOUNT_VALUE);
    hr_utility.trace('Leaving Vallabh IF');


    END IF;

--    VMKULKAR

    hr_utility.trace('After l_garn_exemption_amount_value = '||l_garn_exemption_amount_value);


    IF GARN_CATEGORY <> 'DCIA' THEN -- Bug# 6068769
       IF GARN_EXEMPTION_CALC_RULE = 'FEDRULE' OR
           GARN_EXEMPTION_CALC_RULE = 'ONE_FED' THEN
             DI_state_exemption_amt := 0;
       ELSIF GARN_EXEMPTION_CALC_RULE = 'FLAT_AMT' OR
           GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_AMT' THEN
           DI_state_exemption_amt := l_garn_exemption_amount_value;
       ELSIF GARN_EXEMPTION_CALC_RULE = 'FLAT_PCT' OR
           GARN_EXEMPTION_CALC_RULE = 'ONE_FLAT_PCT' THEN
           hr_utility.trace('inv_dedn_in_run = '||inv_dedn_in_run);

           -- Bug 4318944 For Hawaii
           -- Convert the DI calculated to monthly DI value for Hawaii
           -- and then calculate the exemption amount on it.
           IF SUBSTR(Jurisdiction,1,2) = '12' AND garn_category = 'CD' THEN
              total_di_month := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                    ASG_HOURS,
                                                    Total_DI,
                                                    'NOT ENTERED',
                                                    'MONTH',
                                                    PAY_EARNED_START_DATE,
                                                    PAY_EARNED_END_DATE,
                                                    ASG_FREQ);
              IF total_di_month > 200 THEN
                 DI_hawaii_max_cd_month := 5 + 10 + ((100 - GARN_EXEMPTION_AMOUNT_VALUE)/100) * (total_di_month - 200);
              ELSIF total_di_month > 100 THEN
                 DI_hawaii_max_cd_month := 5 + 0.1 * (total_di_month - 100);
              ELSE
                 DI_hawaii_max_cd_month := 0.05 * total_di_month;
              END IF;
              DI_hawaii_max_cd := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                      ASG_HOURS,
                                                      DI_hawaii_max_cd_month,
                                                      'MONTH',
                                                      'NOT ENTERED',
                                                      PAY_EARNED_START_DATE,
                                                      PAY_EARNED_END_DATE,
                                                      ASG_FREQ);
              hr_utility.trace('Hawaii Credit Debt Calculation');
              hr_utility.trace('Total Period DI = ' || Total_DI);
              hr_utility.trace('Total Monthly DI = ' || total_di_month);
              hr_utility.trace('Max Monthly CD deduction = ' || DI_hawaii_max_cd_month);
              hr_utility.trace('Max Period CD deduction = ' || DI_hawaii_max_cd);
           END IF;

           IF inv_dedn_in_run > 0 THEN
               diff := ccpa_protection - inv_dedn_in_run;
               hr_utility.trace('ccpa_protection = ' || ccpa_protection);
               hr_utility.trace('GARN_EXEMPTION_AMOUNT_VALUE = ' || GARN_EXEMPTION_AMOUNT_VALUE);
               hr_utility.trace('Total_DI = ' || Total_DI);
               max_garn := ((100 - GARN_EXEMPTION_AMOUNT_VALUE) / 100 ) * Total_DI;
               -- Bug 4318944 For Hawaii Credit Debt
               IF SUBSTR(Jurisdiction,1,2) = '12' AND garn_category = 'CD' THEN
                  max_garn := DI_hawaii_max_cd;
               END IF;
               IF diff >= 0 THEN
                   IF diff >= max_garn THEN
                       diff := max_garn;
                       DI_state_exemption_amt := Total_DI-(inv_dedn_in_run+diff);
                   END IF;
               ELSE
                   -- Bug 4318944 For Hawaii Credit Debt
                   IF SUBSTR(Jurisdiction,1,2) = '12' AND garn_category = 'CD' THEN
                      DI_state_exemption_amt := Total_DI - DI_hawaii_max_cd;
                   ELSE
                      DI_state_exemption_amt := (GARN_EXEMPTION_AMOUNT_VALUE / 100) * Total_DI;
                   END IF;
               END IF;
           ELSE
               IF SUBSTR(Jurisdiction,1,2) = '12' AND garn_category = 'CD' THEN
                  DI_state_exemption_amt := Total_DI - DI_hawaii_max_cd;
               ELSE
                  DI_state_exemption_amt := (GARN_EXEMPTION_AMOUNT_VALUE / 100) * Total_DI;
               END IF;
           END IF;

           -- If DCIA element is processed then CCPA Protection is taken care by the
           -- code written for DCIA.
           -- Handling CCPA Protection here results in incorrect calculations when
           -- handled later.
           if GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' then -- Bug# 6068769
               DI_state_exemption_amt := (GARN_EXEMPTION_AMOUNT_VALUE / 100) * Total_DI;
           end if;
           hr_utility.trace('FLAT_PCT => EL DI_state_exemption_amt := '||DI_state_exemption_amt);

           /*
            * Moved the calculation of 'DI_state_exemption_amt' from the
            * ELSE part above to outside the IF condition for the same. (3737081)
            */
           DI_state_exemption_amt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                         ASG_HOURS,
                                                         DI_state_exemption_amt,
                                                         'NOT ENTERED',
                                                         'WEEK',
                                                         PAY_EARNED_START_DATE,
                                                         PAY_EARNED_END_DATE,
                                                         ASG_FREQ);
           hr_utility.trace('Weekly DI_state_exemption_amt := '||DI_state_exemption_amt);

       ELSIF GARN_EXEMPTION_CALC_RULE = 'MARSTAT_RULE' OR
             GARN_EXEMPTION_CALC_RULE = 'ONE_MARSTAT_RULE' THEN
           IF SUBSTR(Jurisdiction,1,2) = '02' /* Alaska */  THEN

             IF P_CTX_DATE_EARNED < fnd_date.canonical_to_date('2009/01/01') THEN
                IF Filing_Status = '01' THEN  /* SINGLE */
                    DI_state_exemption_amt := 420;
                ELSE /* otherwise considered H OF H */
                   DI_state_exemption_amt := 660;
                END IF;
             ELSE
                DI_state_exemption_amt := 456; -- Alaska changes effective 1st Jan, 2009
             END IF;

           ELSIF SUBSTR(Jurisdiction,1,2) = '04' /* Arkansas */  THEN
               IF Filing_Status = '01' THEN  /* SINGLE */
                   DI_state_exemption_amt := 200;
               ELSE /* otherwise considered H OF H */
                   DI_state_exemption_amt := 500;
               END IF;
           ELSIF SUBSTR(Jurisdiction,1,2) = '10' /* Florida */  THEN
               IF Filing_Status = '04' THEN  /* HEAD OF HOUSEHOLD */
                   DI_state_exemption_amt := 500;
               END IF;
           -- Commenting for Bug# 5706544
           --ELSIF SUBSTR(Jurisdiction,1,2) = '26' /* Missouri */  THEN
               --IF Filing_Status = '04' THEN  /* HEAD OF HOUSEHOLD */
                   --DI_state_exemption_amt := .9 * Total_DI;
               --END IF;
           ELSIF SUBSTR(Jurisdiction,1,2) = '28' /* Nebraska */  THEN
               -- Bug# 6063353 (Filing Status '04' is not for HOH)
               IF Filing_Status = '03' THEN  /* HEAD OF HOUSEHOLD */
                   DI_state_exemption_amt := .85 * Total_DI;
               END IF;
               hr_utility.trace('Converting into Weekly Figure.') ;

               DI_state_exemption_amt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                             ASG_HOURS,
                                                             DI_state_exemption_amt,
                                                             'NOT ENTERED',
                                                             'WEEK',
                                                             PAY_EARNED_START_DATE,
                                                             PAY_EARNED_END_DATE,
                                                             ASG_FREQ);
               hr_utility.trace('DI_state_exemption_amt (Weekly) := '||DI_state_exemption_amt) ;

           END IF;
       ELSIF GARN_EXEMPTION_CALC_RULE = 'EXEMPT_BALANCE' OR
             GARN_EXEMPTION_CALC_RULE = 'ONE_EXEMPT_BALANCE' THEN
           IF SUBSTR(Jurisdiction,1,2) = '12' /* Hawaii */  THEN
               IF GROSS_EARNINGS_ASG_GRE_MONTH < c_hawaii_range_1_mnth_erngs THEN
                   DI_state_exemption_amt := c_Hawaii_Pct_Exempt_Range_1 *
                                             GROSS_EARNINGS_ASG_GRE_MONTH;
               ELSIF GROSS_EARNINGS_ASG_GRE_MONTH < c_hawaii_range_2_mnth_erngs THEN
                   DI_state_exemption_amt := (c_Hawaii_Pct_Exempt_Range_1 *
                                              c_hawaii_range_1_mnth_erngs) +
                                                 (c_Hawaii_Pct_Exempt_Range_2 *
                                                   ( c_hawaii_range_2_mnth_erngs -
                                                     c_hawaii_range_1_mnth_erngs));
               ELSE
                   DI_state_exemption_amt := (c_Hawaii_Pct_Exempt_Range_1 *
                                              c_hawaii_range_1_mnth_erngs) +
                                                   (c_Hawaii_Pct_Exempt_Range_2 *
                                                       (c_hawaii_range_2_mnth_erngs -
                                                        c_hawaii_range_1_mnth_erngs)) +
                                                       (c_Hawaii_Pct_Exempt_Range_3 *
                                                           (GROSS_EARNINGS_ASG_GRE_MONTH -
                                                       c_hawaii_range_2_mnth_erngs));
               END IF;
           ELSIF SUBSTR(Jurisdiction,1,2) = '14' /* Illinois */  THEN
               Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
               earnings_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        GROSS_EARNINGS_ASG_GRE_RUN,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
               DI_state_exemption_amt := GREATEST((0.85 * earnings_per_week),
                                                       NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                                       NVL(c_State_Minimum_Wage,c_Federal_Minimum_Wage));
               hr_utility.trace('Total_DI_per_week = ' || Total_DI_per_week);
               hr_utility.trace('earnings_per_week = ' || earnings_per_week);
               hr_utility.trace('DI_state_exemption_amt per week = ' || DI_state_exemption_amt);

               -- Bug 4556146
               IF (garn_category = 'G' OR garn_category = 'CD') THEN
                  lb_use_state_min_wage := FALSE;
                  IF date_served = default_date THEN
                     open csr_get_entry_start_date;
                     fetch csr_get_entry_start_date into ld_entry_start_date;
                     close csr_get_entry_start_date;
                     IF ld_entry_start_date >= fnd_date.canonical_to_date('2006/01/01') THEN
                        lb_use_state_min_wage := TRUE;
                        DI_state_exemption_amt := GREATEST(DI_state_exemption_amt,
                                                           NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * NVL(c_State_Minimum_Wage, c_Federal_Minimum_Wage));
                     END IF;
                  ELSIF date_served >= fnd_date.canonical_to_date('2006/01/01') THEN
                     lb_use_state_min_wage := TRUE;
                     DI_state_exemption_amt := GREATEST(DI_state_exemption_amt,
                                                        NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * NVL(c_State_Minimum_Wage, c_Federal_Minimum_Wage));
                  END IF;

                  IF DI_state_exemption_amt = 0.85 * earnings_per_week THEN
                    if lv_M_rule is not null then
                        DI_state_exemption_amt := Total_DI_per_week -
                                                (LEAST ( 0.15 * earnings_per_week ,
                                                ( Total_DI_per_week -  NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                                c_Federal_Minimum_Wage),( Total_DI_per_week -  NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                                c_State_Minimum_Wage)));
                    else
                     IF lb_use_state_min_wage THEN
                        DI_state_exemption_amt := Total_DI_per_week -
                                                (LEAST ( 0.15 * earnings_per_week ,
                                                ( Total_DI_per_week -  NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                                c_Federal_Minimum_Wage),( Total_DI_per_week -  NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                                c_State_Minimum_Wage)));
                     ELSE
                        DI_state_exemption_amt := Total_DI_per_week -
                                                (LEAST ( 0.15 * earnings_per_week ,
                                                ( Total_DI_per_week -  GARN_EXEMPTION_MIN_WAGE_FACTOR *
                                                c_Federal_Minimum_Wage)));
                     END IF;
                    end if;
                  END IF;
               ELSE
                  IF DI_state_exemption_amt = 0.85 * earnings_per_week THEN
                      DI_state_exemption_amt := Total_DI_per_week -
                                              (LEAST ( 0.15 * earnings_per_week ,
                                              ( Total_DI_per_week -  NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                              c_Federal_Minimum_Wage),
                                              ( Total_DI_per_week -  NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) *
                                              c_State_Minimum_Wage)));
                  END IF;
               END IF; -- IF garn_category = 'G' OR
           ELSIF SUBSTR(Jurisdiction,1,2) = '31' /* New Jersey */  THEN
               Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
               earnings_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        GROSS_EARNINGS_ASG_GRE_RUN,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
               /*-- Bug 3520523 --*/
               IF nvl(l_exmpt_ovrd,0) = 0 THEN
                   DI_state_exemption_amt := GREATEST((GARN_EXEMPTION_DI_PCT/100) * Total_DI_per_week,
                                                      Total_DI_per_week - (0.10 * earnings_per_week),
                                                      NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage,
                                                      NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage);
               ELSE
                   DI_state_exemption_amt := GREATEST((l_exmpt_ovrd/100) * Total_DI_per_week,
                                                      Total_DI_per_week - (0.10 * earnings_per_week),
                                                      NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage,
                                                      NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage);
               END IF;

           ELSIF SUBSTR(Jurisdiction,1,2) = '33' /* New York */  THEN
               Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

               earnings_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        GROSS_EARNINGS_ASG_GRE_RUN,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

               IF Total_DI_per_week <
                  GREATEST((c_ny_minwage_exmpt_multpl_1 * c_Federal_Minimum_Wage)
                          ,NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage
                          ,NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage)  THEN
                   DI_state_exemption_amt := Total_DI_per_week;
               ELSE
                   DI_state_exemption_amt := c_ny_di_exmpt_pct * Total_DI_per_week;
               END IF;

           ELSIF SUBSTR(Jurisdiction,1,2) = '37' /* Oklahoma */  THEN
               earnings_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        GROSS_EARNINGS_ASG_GRE_RUN,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
               IF earnings_per_week < c_ok_range_1_wkly_erngs THEN
                   DI_state_exemption_amt := GROSS_EARNINGS_ASG_GRE_RUN;
               ELSIF earnings_per_week < c_ok_range_2_wkly_erngs THEN
                   OK_weekly_state_exemption_amt := earnings_per_week - c_ok_range_1_wkly_erngs;
                   DI_state_exemption_amt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                                 ASG_HOURS,
                                                                 OK_weekly_state_exemption_amt,
                                                                 'NOT ENTERED',
                                                                 'WEEK',
                                                                 PAY_EARNED_START_DATE,
                                                                 PAY_EARNED_END_DATE,
                                                                 ASG_FREQ);
               ELSE
                   DI_state_exemption_amt := c_Oklahoma_earnings_exempt_pct * GROSS_EARNINGS_ASG_GRE_RUN;
               END IF;
               DI_state_exemption_amt := GREATEST(DI_state_exemption_amt,
                                                  NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage
                                                 ,NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage);
           END IF;
       END IF;
       -- Bug# 6194070
       -- For State of Maine 'Garnishment' and 'Credit Debt'
       -- Higher of 25% weekly DI or Factor of Federal or State Min Wage
       IF (SUBSTR(Jurisdiction,1,2) = '20'
            AND garn_category IN ('CD', 'G')) THEN
              Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);
	       hr_utility.trace('For Maine CD or G Total_DI_per_week := '||Total_DI_per_week);
	       hr_utility.trace('0.75 * Total_DI_per_week := '||(0.75 * Total_DI_per_week));
	       hr_utility.trace('Federal Exemption := '||(NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage));
	       hr_utility.trace('State Exemption := '||(NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage));

               DI_state_exemption_amt := GREATEST((0.75 * Total_DI_per_week),
                                                  (NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage),
						  (NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage));

               hr_utility.trace('DI_state_exemption_amt For maine  CD / G := '||DI_state_exemption_amt);

       END IF;

    END IF; /* IF GARN_CATEGORY <> 'DCIA' */

    -- 4079142
    -- Added the IF condition as State Dependents Exemption Calculation as DCIA is
    -- Federal Involuntary Deduction

    IF GARN_CATEGORY <> 'DCIA' THEN -- No Change needed for Bug# 6068769 ?
       IF GRN_EXMPT_DEP_CALC_RULE <> 'NONE' THEN
           IF GRN_EXMPT_DEP_CALC_RULE = 'FLAT_AMT' THEN
               IF SUBSTR(Jurisdiction,1,2) = '23' /* Michigan */  THEN
                   IF Filing_Status = '04' THEN  /* Head of Household gets dep exemption */
                       DI_state_dependents_exemption := GRN_EXMPT_DEP_AMT_VAL *
                                                        Num_Dependents;
                   ELSE
                       DI_state_dependents_exemption := GRN_EXMPT_DEP_AMT_VAL *
                                                        Num_Dependents;
                   END IF;
               END IF;
           ELSIF GRN_EXMPT_DEP_CALC_RULE = 'FLAT_AMT_ADDL' THEN
               DI_state_dependents_exemption := GRN_EXMPT_DEP_AMT_VAL +
                                                (GRN_EXMPT_ADDL_DEP_AMT_VAL *
                                                (Num_Dependents - 1));
           ELSIF GRN_EXMPT_DEP_CALC_RULE = 'FLAT_PCT' THEN
               DI_state_addl_pct_exempt := GRN_EXMPT_DEP_AMT_VAL * Num_Dependents;
               DI_state_dependents_exemption := (DI_state_addl_pct_exempt / 100) * Total_DI;
               DI_state_dependents_exemption := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                                    ASG_HOURS,
                                                                    DI_state_dependents_exemption,
                                                                    'NOT ENTERED',
                                                                    'WEEK',
                                                                    PAY_EARNED_START_DATE,
                                                                    PAY_EARNED_END_DATE,
                                                                    ASG_FREQ);
           ELSIF GRN_EXMPT_DEP_CALC_RULE = 'FLAT_PCT_ADDL' THEN
               DI_state_addl_pct_exempt := GRN_EXMPT_DEP_AMT_VAL +
                                          (GRN_EXMPT_ADDL_DEP_AMT_VAL * (Num_Dependents - 1));
               DI_state_dependents_exemption := (DI_state_addl_pct_exempt / 100) * Total_DI;
               DI_state_dependents_exemption := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                                    ASG_HOURS,
                                                                    DI_state_dependents_exemption,
                                                                    'NOT ENTERED',
                                                                    'WEEK',
                                                                    PAY_EARNED_START_DATE,
                                                                    PAY_EARNED_END_DATE,
                                                                    ASG_FREQ);
           END IF;
       END IF;
    END IF; /* IF GARN_CATEGORY <> 'DCIA' */

    DI_total_state_exemption := DI_state_exemption_amt + DI_state_dependents_exemption;
    hr_utility.trace('DI_state_exemption_amt = '||DI_state_exemption_amt);
    hr_utility.trace('DI_state_dependents_exemption = '||DI_state_dependents_exemption);
    hr_utility.trace('DI_total_state_exemption = '||DI_total_state_exemption);

    -- Change for Bug# 5150447
    -- Change Garn Category for Bug# 5688488
    --IF garn_category <> 'BO' THEN
    IF garn_category IN ('CD', 'G') THEN

       IF Substr(Jurisdiction,1,2) = '26' THEN

          open c_get_res_state_code(ctx_element_entry_id) ;
          fetch c_get_res_state_code into ln_assignment_id, ln_resident_state_code ;
          IF c_get_res_state_code%notfound THEN
             close c_get_res_state_code ;
           END IF ;
           hr_utility.trace('ln_assignment_id '|| to_char(ln_assignment_id)) ;
           hr_utility.trace('ln_resident_state_code '|| ln_resident_state_code) ;

           open c_get_allowance_value('Filing Status');
           fetch c_get_allowance_value into ln_filing_status_code;
           close c_get_allowance_value;

           hr_utility.trace('Element Level: ln_filing_status_code := '|| ln_filing_status_code) ;

           IF ln_filing_status_code IS NULL THEN
              open c_get_filing_status(ln_assignment_id) ;
              fetch c_get_filing_status into ln_filing_status_code ;
              IF c_get_filing_status%notfound THEN
                 close c_get_filing_status ;
              END IF ;
           END IF ;
           hr_utility.trace('ln_filing_status_code '|| ln_filing_status_code) ;

           IF ln_resident_state_code = '26'
              and ln_filing_status_code = '03' THEN

              Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

              DI_total_state_exemption := GREATEST(DI_total_state_exemption,
	                                           0.9 * Total_DI_per_week) ;
              hr_utility.trace('DI_total_state_exemption '|| to_char(DI_total_state_exemption)) ;

           END IF ;
        END IF ;
    END IF ;
    -- End of Change for Bug# 5150447
    /*
    DI_total_state_exemption := GREATEST(DI_total_state_exemption,
                                        NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage,
                                        NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage);
    */
    -- Bug 4079142
    ---Bug #9284206 Added the Category 'EL' to the if condition so that for Education loan
    --- of illinois state is deducted as per the federal minimum wage.
    ---
    IF ((SUBSTR(Jurisdiction,1,2) = '14') and (GARN_CATEGORY NOT IN ('DCIA','EL'))) THEN -- No Change Neede for Bug# 6068769 ?
        DI_total_exemption := DI_total_state_exemption;
    ELSE
        DI_total_exemption := GREATEST(fed_criteria_exemption,
                                       DI_total_state_exemption);
    END IF;
    hr_utility.trace('fed_criteria_exemption = '||fed_criteria_exemption);
    hr_utility.trace('DI_total_exemption = '||DI_total_exemption);

--  Code change to be started here for Bug# 6818016
    IF GARN_CATEGORY IN ('CD', 'G') THEN

       IF (NET_ASG_PTD - NET_ASG_RUN) > 0 THEN

       tmp_DI_total_week_exempt := GREATEST(fed_criteria_wk_prd_di_xmpt, DI_total_state_exemption);
       tmp_fed_state_week_exemption := GREATEST(NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage,
                                                NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage);

       hr_utility.trace('tmp_DI_total_week_exempt := ' || tmp_DI_total_week_exempt);
       hr_utility.trace('tmp_fed_state_week_exemption := ' || tmp_fed_state_week_exemption);

       IF tmp_fed_state_week_exemption > tmp_DI_total_week_exempt THEN

         -- Temporary Calculation for NET_ASG_PTD per week
         tmp_net_asg_ptd_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        (NET_ASG_PTD - NET_ASG_RUN),
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

            hr_utility.trace('tmp_net_asg_ptd_week := ' || tmp_net_asg_ptd_week);

            -- Should it be tmp_net_asg_ptd_week
            -- Or, Aggregate DI for all Previous Runs for the Period
            -- But no way to get Aggregate DI as there is No Balance
            -- Following would be Most probable case

            IF (tmp_net_asg_ptd_week + tmp_DI_total_week_exempt) >= tmp_fed_state_week_exemption THEN
               DI_total_exemption := tmp_DI_total_week_exempt;
            ELSE
               -- Temporary Calculation for NET_ASG_RUN per week
               tmp_net_asg_run_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,
                                                        NET_ASG_RUN,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

               hr_utility.trace('tmp_net_asg_run_week := ' || tmp_net_asg_run_week);

               IF tmp_fed_state_week_exemption > tmp_net_asg_run_week THEN
                  IF (tmp_net_asg_ptd_week + tmp_net_asg_run_week) >= tmp_fed_state_week_exemption THEN
                     DI_total_exemption := (tmp_fed_state_week_exemption - tmp_net_asg_ptd_week);
                  ELSE
                     DI_total_exemption := tmp_fed_state_week_exemption;
                  END IF;
               ELSE
                  DI_total_exemption := tmp_fed_state_week_exemption;
               END IF;
            END IF;
            hr_utility.trace('DI_total_exemption (For G , CD NAP - NAR > 0) := ' || DI_total_exemption);
       ELSE
            DI_total_exemption := GREATEST(tmp_DI_total_week_exempt, tmp_fed_state_week_exemption);
       END IF;

     --  Code change to be ended here for Bug# 6818016
     ELSE
      if lv_M_rule is not null then
        DI_total_exemption := GREATEST(DI_total_exemption,
                                   NVL(ln_M_S_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage,
                                   NVL(ln_M_F_Factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage);
      end if;
     END IF;
   END IF; -- garn_category G or CD

   -- Introduced for Bug# 7674615
   IF GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' THEN
      IF DI_total_exemption = fed_criteria_exemption and GARN_CATEGORY = 'EL' THEN
         lb_EL_reduce_di := FALSE;
      ELSE
         lb_EL_reduce_di := TRUE;
      END IF;
   END IF;

/* The exemption amount so far is the amount exempt PER WEEK
   So we convert it to a PER PAY PERIOD figure for calculating Subject DI. */

    DI_total_period_exemption := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                     ASG_HOURS,
                                                     DI_total_exemption,
                                                     'WEEK',
                                                     'NOT ENTERED',
                                                     PAY_EARNED_START_DATE,
                                                     PAY_EARNED_END_DATE,
                                                     ASG_FREQ);

    hr_utility.trace('DI_total_period_exemption = ' || DI_total_period_exemption);

    IF garn_category = 'BO' THEN /* Step #4 */
        DI_total_period_exemption := Exempt_Amt_BO;
    END IF;


    Subject_DISPOSABLE_INCOME := Total_DI  - DI_total_period_exemption
                                           - TAX_LEVIES_ASG_GRE_RUN
                                           - TOT_WHLD_SUPP_ASG_GRE_RUN
                                           - TOTAL_WITHHELD_FEE_ASG_GRE_RUN
                                           - GARN_TOTAL_DEDNS_ASG_GRE_RUN
                                           - GARN_TOTAL_FEES_ASG_GRE_RUN;
    hr_utility.trace('Initial Subject Disposable Income = ' || Subject_DISPOSABLE_INCOME);

    -- Bug 5149450
    -- Set the value of calcd_dedn_amt and verify_dedn_amt to the
    -- correct value. BASE_FORMULA only calculates an estimated value
    if GLB_AMT_NOT_SPEC(P_CTX_ORIGINAL_ENTRY_ID) then
       if dedn_amt > (Total_DI - DI_total_period_exemption) then
          dedn_amt := Total_DI - DI_total_period_exemption;
       end if; -- if
    end if;


    -- Bug 4079142
    -- Do not reduce DI with the Involunatry Deductions already deducted.
    -- This is because in presence of DCIA element, we can take upto 25% of Total DI.
    -- Reducing DI here with the Involuntary Deductions deducted might make Subject DI
    -- to be lesser than ZERO resulting in no deduction of the current element.
    -- A check later makes sure that the Total Deductions is not more than 25% of
    -- Total DI. So we can safely ignore the other deductions here in case of
    -- DCIA element also processed in the Payroll.

    if GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' then
      -- Introduced for Bug# 7674615
      if lb_EL_reduce_di then
        Subject_DISPOSABLE_INCOME := Total_DI  - DI_total_period_exemption;
      end if;
      hr_utility.trace('Modified Initial Subject Disposable Income = ' || Subject_DISPOSABLE_INCOME);
    end if;

    /* Need a check here that Subject DI is not less than or equal to zero!  If it is, then DI is
    below the federal minimum allowable - so do not withhold anything!*/
    calcd_arrears := 0;
    not_taken := 0;
    IF Subject_DISPOSABLE_INCOME <= 0 THEN
        calcd_arrears := dedn_amt;
        not_taken := 0;
        dedn_amt := 0;
        to_total_owed := 0;
        calcd_dedn_amt := 0;
        calcd_fee := 0;
        garn_fee := 0;
        Subject_DISPOSABLE_INCOME := 0;
        mesg := 'Not enough money to take garnishment for the element ' || lv_ele_name || '.';
        SF_Accrued_Fees := SF_Accrued_Fees + accrued_fee_correction;
        if GLB_NUM_ELEM = 0 then
           GLB_SUPPORT_DI := NULL;
           GLB_OTHER_DI_FLAG := NULL;
           GLB_DCIA_EXIST_FLAG := NULL;
           reset_global_var;
        end if;
        RETURN(5);
    END IF;

    -- 'EL' Added for Bug# 5701665
    IF SUBSTR(Jurisdiction,1,2) = '33' AND garn_category <> 'BO' AND garn_category <> 'DCIA' AND garn_category <> 'EL'/* New York */ THEN
        dedn_amt := LEAST(LEAST(Subject_DISPOSABLE_INCOME,
                                ((1 - c_ny_gross_erngs_exmpt_pct) *
                                GROSS_EARNINGS_ASG_GRE_RUN)),dedn_amt);
    END IF;

--Bug 6678760 VMKULKAR
    IF SUBSTR(Jurisdiction,1,2) = '08' AND garn_category in ('G','CD') /* Delaware */ THEN
    l_fed_criteria_minwage_dl := GREATEST(30 * c_Federal_Minimum_Wage
                                         ,NVL(ln_M_F_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_Federal_Minimum_Wage
                                         ,NVL(ln_M_S_factor, GARN_EXEMPTION_MIN_WAGE_FACTOR) * c_State_Minimum_Wage
                                         );

     Total_DI_per_week := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,Total_DI,
                                                        'NOT ENTERED',
                                                        'WEEK',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);

    dedn_amt := LEAST((1-c_dl_gross_erngs_exmpt_pct)* Total_DI_per_week,
                 Total_DI_per_week - l_fed_criteria_minwage_dl);
    /*    converting dedn_amt to period amount  */

    dedn_amt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                        ASG_HOURS,dedn_amt,
                                                        'WEEK',
                                                        'NOT ENTERED',
                                                        PAY_EARNED_START_DATE,
                                                        PAY_EARNED_END_DATE,
                                                        ASG_FREQ);


    END IF;
--Bug 6678760 VMKULKAR

    -- Bug 5098366
    -- Added the NVL condition to override the .25 condition if
    -- Exemption percentage is overridden at Employee level
    IF garn_category <> 'BO'AND garn_category <> 'DCIA' AND GARN_CATEGORY <> 'EL' AND
       SUBSTR(Jurisdiction,1,2) <> '14' AND
       SUBSTR(Jurisdiction,1,2) <> '06' AND
       nvl(l_exmpt_ovrd,default_number) = default_number THEN
        IF Subject_DISPOSABLE_INCOME > Total_DI * .25 THEN
            Subject_DISPOSABLE_INCOME := Total_DI * .25;
        END IF;
    END IF;
    hr_utility.trace('Subject_Disposable_Income = '||Subject_Disposable_Income);

    /*
     * Bug 3734557
     * Added the condition so that Proration rules are applied only if
     * DI is less.
     */
    if total_garn_run > Subject_DISPOSABLE_INCOME then -- 6140374
       /*-- Proration rules for states which allow more than one garnishments to be processed (Bug 2658290). ---*/
       IF GARN_EXEMPTION_CALC_RULE <> 'ONE_FED' AND
             GARN_EXEMPTION_CALC_RULE <> 'ONE_FLAT_AMT' AND
             GARN_EXEMPTION_CALC_RULE <> 'ONE_FLAT_PCT' AND
             GARN_EXEMPTION_CALC_RULE <> 'ONE_MARSTAT_RULE' AND
             GARN_EXEMPTION_CALC_RULE <> 'ONE_EXEMPT_BALANCE' THEN

           OPEN csr_get_proration_ovrd;
               FETCH csr_get_proration_ovrd INTO l_proration_ovrd;
           CLOSE csr_get_proration_ovrd;

           IF l_proration_ovrd is null then
               l_proration_ovrd := GARN_EXEMPTION_PRORATION_RULE;
               hr_utility.trace ('Proration rule not overriden. Proceeding with proration rule = '||l_proration_ovrd);
           ELSE
               hr_utility.trace ('Proration rule overriden to '||l_proration_ovrd);
           END IF;

           IF l_proration_ovrd = 'NONE' OR
              l_proration_ovrd = 'ORDER' THEN
                   IF dedn_amt > Subject_DISPOSABLE_INCOME THEN
                       calcd_arrears := dedn_amt - Subject_DISPOSABLE_INCOME;
                       dedn_amt      := Subject_DISPOSABLE_INCOME;
                       not_taken     := Subject_DISPOSABLE_INCOME - dedn_amt;
                   END IF;


                   /*IF (GARN_TOTAL_DEDNS_ASG_GRE_RUN + dedn_amt) > subject_disposable_income THEN
                       dedn_amt := subject_disposable_income - GARN_TOTAL_DEDNS_ASG_GRE_RUN;
                       IF dedn_amt <= 0 THEN
                           dedn_amt := 0;
                           not_taken := subject_disposable_income;
                       ELSE
                           not_taken := dedn_amt - subject_disposable_income;
                       END IF;
                   ELSE
                       IF GARN_TOTAL_DEDNS_ASG_GRE_RUN +
                          GARN_TOTAL_FEES_ASG_GRE_RUN +
                          dedn_amt +
                          wh_fee_amt > VF_DI_SUBJ THEN
                           IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                                  IF wh_dedn_amt - wh_fee_amt > 0 THEN
                                   wh_dedn_amt := wh_dedn_amt - wh_fee_amt;
                                   not_taken := VF_DI_SUBJ - wh_dedn_amt;
                               ELSE
                                   wh_fee_amt := VF_DI_SUBJ - ( GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                                                                TOTAL_WITHHELD_FEE_ASG_GRE_RUN +
                                                                wh_dedn_amt);
                               END IF;
                       ELSE
                               wh_fee_amt := VF_DI_SUBJ - ( GLB_TOT_WHLD_SUPP_ASG_GRE_RUN +
                                                            TOTAL_WITHHELD_FEE_ASG_GRE_RUN +
                                                            wh_dedn_amt);
                       END IF;
                   END IF;
               END IF;*/
           ELSE
            /* For calculating "equal" and "proportionate" amounts, DI should remain same for
               all deduction elements. But subject_disposable_income reduces each time an element
               is processed. Hence, introducing equal_DI to bring subject_disposable_income to
               correct value for calculations. */

               -- In the presence of DCIA, Subject Disposable Income does not reduce
               -- each time an element is processed. So we do not nned to correct
               -- the value for calculation
               IF GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' THEN
                  equal_DI := subject_disposable_income;
               ELSE
                  equal_DI := subject_disposable_income +
                              GARN_TOTAL_DEDNS_ASG_GRE_RUN +
                              GARN_TOTAL_FEES_ASG_GRE_RUN;
               END IF;
               IF l_proration_ovrd = 'EQUAL' THEN
                   equal_dedn_amounts := equal_DI /gar_dedn_tab.count();
                   --not_taken := subject_disposable_income - dedn_amt;
                   not_taken := equal_DI - equal_dedn_amounts;
                   dedn_amt := equal_dedn_amounts;
--changes for bug 8673016
                   IF dedn_amt > Subject_DISPOSABLE_INCOME THEN
                       calcd_arrears := dedn_amt - Subject_DISPOSABLE_INCOME;
                       dedn_amt      := Subject_DISPOSABLE_INCOME;
                       not_taken     := Subject_DISPOSABLE_INCOME - dedn_amt;
                   END IF;
--changes for bug 8673016
               ELSIF l_proration_ovrd = 'PROPORTION' AND
                   total_garn_run <> 0 THEN
                   -- Bug 5165704
                   -- Used gar_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID) instead of
                   -- DEDN_AMT for calculating the Proportional amount
                   -- DEDN_AMT gets modified and as a result the proportional
                   -- amount gets incorrectly calculated
                   proportional_dedn_amount := (gar_dedn_tab (P_CTX_ORIGINAL_ENTRY_ID) / total_garn_run) * equal_DI;
                   not_taken := equal_DI - proportional_dedn_amount;
                   dedn_amt := proportional_dedn_amount;
               END IF;
           END IF;
       ELSE
           /* Only one garnishment allowed for current state and category. */
           IF dedn_amt > Subject_DISPOSABLE_INCOME THEN
               calcd_arrears := dedn_amt - Subject_DISPOSABLE_INCOME;
               dedn_amt      := Subject_DISPOSABLE_INCOME;
               not_taken     := Subject_DISPOSABLE_INCOME - dedn_amt;
           END IF;
       END IF;
    END IF;

    -- Bug 4079142
    -- Checking for Federal Consumer Credit Protection Act in case of DCIA
    -- using the following rule

    IF GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' THEN -- Bug# 6068769
       hr_utility.trace('Deductions Amount Before CCPA check = ' || dedn_amt);

       -- Check for DCIA limit to 25% of DI when combined with other Involuntary Deductions
       -- or with itself.
       diff := ccpa_protection - inv_dedn_in_run;
       hr_utility.trace('Garnishment Deductions For the Run = ' || inv_dedn_in_run);
       if diff <= 0 then
           calcd_arrears := dedn_amt;
           dedn_amt := 0;
       elsif dedn_amt > diff then
          calcd_arrears := dedn_amt - diff;
          dedn_amt := diff;
          not_taken := Subject_DISPOSABLE_INCOME - dedn_amt;
       end if;
       hr_utility.trace('Deductions Amount After CCPA check = ' || dedn_amt);

       -- Introduced for Bug# 7674615
       -- Period figure of Federal Min Wage exemption
    if not lb_EL_reduce_di then
       fed_min_wage_prd_exempt := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                                     ASG_HOURS,
                                                     fed_criteria_exemption,
                                                     'WEEK',
                                                     'NOT ENTERED',
                                                     PAY_EARNED_START_DATE,
                                                     PAY_EARNED_END_DATE,
                                                     ASG_FREQ);
       hr_utility.trace('fed_min_wage_prd_exempt := ' || fed_min_wage_prd_exempt);
       hr_utility.trace('Total_DI := ' || Total_DI);
       hr_utility.trace('dedn_amt := ' || dedn_amt);
       hr_utility.trace('inv_dedn_in_run := ' || inv_dedn_in_run);

       if (Total_DI - (dedn_amt + inv_dedn_in_run)) < fed_min_wage_prd_exempt then
          calcd_arrears := dedn_amt - (Total_DI - inv_dedn_in_run - fed_min_wage_prd_exempt);
          dedn_amt := Total_DI - inv_dedn_in_run - fed_min_wage_prd_exempt;
       end if;

       hr_utility.trace('calcd_arrears := ' || calcd_arrears);
       hr_utility.trace('dedn_amt := ' || dedn_amt);
    end if;
       -- End of change for Bug# 7674615

       /* Need a check here that Deductions AMount calculated is not less than or equal to zero!
       If it is, then  so do not withhold anything!*/
       IF dedn_amt <= 0 THEN
           to_total_owed := 0;
           not_taken := 0;
           dedn_amt := 0;
           calcd_dedn_amt := 0;
           calcd_fee := 0;
           garn_fee := 0;
           Subject_DISPOSABLE_INCOME := 0;
           mesg := 'Not enough money to take garnishment for the element ' || lv_ele_name || '.';
           SF_Accrued_Fees := SF_Accrued_Fees + accrued_fee_correction;
           if GLB_NUM_ELEM = 0 then
              GLB_SUPPORT_DI := NULL;
              GLB_OTHER_DI_FLAG := NULL;
              GLB_DCIA_EXIST_FLAG := NULL;
              reset_global_var;
           end if;
           RETURN(5);
       END IF;

    END IF;
    /*----------------------*/


    -- Bug 4748532
    -- Deduct PTD amount for Garnishment and Fees if the value of
    -- GLB_FEES_ASG_GRE_PTD is not set to -9999(default_number) in BASE_FORMULA
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
       hr_utility.trace('Deduction that can be taken = ' || dedn_amt_cp);
       hr_utility.trace('Deduction already taken     = ' || GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID));

       IF dedn_amt <= 0 THEN
          dedn_amt := 0;
       ELSIF (dedn_amt + GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID)) > dedn_amt_cp THEN
          dedn_amt := dedn_amt_cp - GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
       END IF;

       IF (dedn_amt > actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID)) THEN
          dedn_amt := actual_dedn_tab(P_CTX_ORIGINAL_ENTRY_ID);
       END IF;
    END IF;

    /* *** limit verification END ***

    *** Fee processing BEGIN *** */
    calcd_fee := 0;
    calcd_fee_rec := 0;
    /* Fee Calculation is done in a function.Accrued_Fee,PTD_Fee_Balance and
    Month_Fee_Balance are passed as parameters to the function*/

    -- Bug 4079142
    -- Added the IF condition as DCIA does not have any fees associated
    -- with it.

    IF GARN_CATEGORY <> 'DCIA' THEN

       -- DCIA elements presence overrides the Subject Disposabel Income for CCPA
       -- check. We set the DI to the (CCPA value - the Inv Deductions deducted).
       -- From here we make sure that the dedn_amt for the current element + Fee
       -- should not be more than the DI calculated making the total deduction
       -- to be 25% of DI
       IF GLB_DCIA_EXIST_FLAG OR GARN_CATEGORY = 'EL' THEN -- Bug# 6068769
          Subject_DISPOSABLE_INCOME := ccpa_protection - inv_dedn_in_run;
          hr_utility.trace('Subject_DISPOSABLE_INCOME Modified To ' || Subject_DISPOSABLE_INCOME);
       END IF;

       IF l_garn_fee_max_fee_amt <> default_number THEN
           IN_GARN_FEE_MAX_FEE_AMOUNT := l_garn_fee_max_fee_amt;
       ELSE
           IN_GARN_FEE_MAX_FEE_AMOUNT :=-99999;
       END IF;

       hr_utility.trace('Modified GARN_FEE_MAX_FEE_AMOUNT = '||l_garn_fee_max_fee_amt);

       calcd_fee := FNC_FEE_CALCULATION(GARN_FEE_FEE_RULE,
                                        GARN_FEE_FEE_AMOUNT,
                                        GARN_FEE_PCT_CURRENT,
                                        total_owed,
                                        Primary_Amount_Balance,
                                        GARN_FEE_ADDL_GARN_FEE_AMOUNT,
                                        IN_GARN_FEE_MAX_FEE_AMOUNT,
                                        PTD_Fee_Balance,
                                        GARN_TOTAL_FEES_ASG_GRE_RUN,
                                        dedn_amt,
                                        Month_Fee_Balance,
                                        ACCRUED_FEES);

       /*
        * Check if Initial Fee Flag is set. Bug 3549298
        */
       IF calcd_fee < 0 THEN
           calcd_fee := 0;
       ELSIF l_ini_fee_flag = 'Y' THEN
           IF GARN_FEE_FEE_RULE = 'AMT_PER_GARN_ADDL' OR
              GARN_FEE_FEE_RULE = 'AMT_PER_PERIOD_ADDL' OR
              GARN_FEE_FEE_RULE = 'AMT_PER_MONTH_ADDL' OR
              GARN_FEE_FEE_RULE = 'AMT_PER_RUN_ADDL' THEN
              IF calcd_fee > GARN_FEE_ADDL_GARN_FEE_AMOUNT THEN
                  calcd_fee := GARN_FEE_ADDL_GARN_FEE_AMOUNT;
              END IF;
           ELSE
              calcd_fee := 0;
           END IF;
       END IF;
       /* Suppress fee result when no fees charged.  */
       /* Check for dedn_amt+fee crossing legislative limits of fed/state */
       -- Bug 4309544
       -- During Proration fee should be taken only if 'Take Fee On Proration'
       -- is set to Yes
       IF total_garn_run > Subject_DISPOSABLE_INCOME THEN -- 6140374

          -- During Proration take fees only if 'Take Fee On Proration' is
          -- checked
          IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
            /* Introduced for Bug 7589784 */
             hr_utility.trace('Take Fee on Proration.');
             IF dedn_amt > 0 THEN
                tmp_dedn_amt := dedn_amt;
                tmp_calc_fee := calcd_fee;
                tmp_not_taken := not_taken;
                dedn_amt  := dedn_amt - calcd_fee;
                not_taken := not_taken + (Subject_DISPOSABLE_INCOME - dedn_amt);
                calcd_fee_rec := calcd_fee;
             END IF;
             IF dedn_amt <= 0 THEN
                dedn_amt := tmp_dedn_amt;
                calcd_fee := 0;
                calcd_fee_rec := calcd_fee;
                not_taken := tmp_not_taken + (Subject_DISPOSABLE_INCOME - dedn_amt);
             END IF;
          ELSE
             calcd_fee := 0;
          END IF; -- IF
       ELSE
          IF calcd_fee > Subject_DISPOSABLE_INCOME - dedn_amt THEN
              IF GARN_FEE_TAKE_FEE_ON_PRORATION = 'Y' THEN
                  IF Subject_DISPOSABLE_INCOME - calcd_fee > 0 THEN
                      t_dedn_amt := Subject_DISPOSABLE_INCOME - calcd_fee;
                      dedn_amt   := t_dedn_amt;   /*Fee is taken initially by reducing the deduction amount */
                      not_taken := not_taken + (Subject_DISPOSABLE_INCOME - dedn_amt);
                      -- Bug 4748532
                      calcd_fee_rec := calcd_fee;
                  ELSE
                      calcd_fee := 0;
                  END IF;
              ELSE
                  IF Subject_DISPOSABLE_INCOME - dedn_amt > 0 THEN
                      calcd_fee := Subject_DISPOSABLE_INCOME - dedn_amt;
                  ELSE
                      calcd_fee := 0;
                  END IF;
              END IF;
          END IF;
       END IF;
    END IF; /*  IF GARN_CATEGORY <> 'DCIA'  */

    -- Bug 4748532
    -- Deduct PTD amount for Garnishment and Fees if the value of
    -- GLB_FEES_ASG_GRE_PTD is not set to -9999(default_number) in BASE_FORMULA
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
       hr_utility.trace('Fees That can be taken      = ' || calcd_fee);
       hr_utility.trace('Fees already taken          = ' || GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID));

       IF calcd_fee >= 0 THEN
          IF calcd_fee >= GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) THEN
             calcd_fee := calcd_fee - GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
           END IF;
       ELSE
          calcd_fee := 0;
       END IF;
       -- To recover Dedn Amoutn if Fees was reset to Zero here
       IF calcd_fee_rec > 0 THEN
          dedn_amt  := dedn_amt + calcd_fee_rec - calcd_fee;
       END IF;
    END IF;


    /**** Negative Net checks *** */
    IF NET_ASG_GRE_RUN - dedn_amt - calcd_fee < 0 THEN
        IF NET_ASG_GRE_RUN - dedn_amt > 0 THEN
            calcd_fee := NET_ASG_GRE_RUN - dedn_amt;
        ELSE
            IF NET_ASG_GRE_RUN - dedn_amt = 0 THEN
                /* Fee causes net to go negative, don't charge fee. */
                calcd_fee := 0;
            ELSIF NET_ASG_GRE_RUN - dedn_amt < 0 THEN
                calcd_fee     := 0;
                calcd_arrears :=  calcd_arrears + (dedn_amt-NET_ASG_GRE_RUN);
                dedn_amt      := NET_ASG_GRE_RUN;
                not_taken     := not_taken  + (Subject_DISPOSABLE_INCOME - dedn_amt);
            END IF;
        END IF;
    END IF;

    /* Check for G or CD and North Dekota (35) or South Dakota (42) or Tennessee (43)
       and then check for the Total Owed
    */
    calcd_dedn_amt := dedn_amt;
    IF garn_category = 'G' OR
        garn_category = 'CD' THEN
        IF SUBSTR(Jurisdiction,1,2) = '35' OR
           SUBSTR(Jurisdiction,1,2) = '42' OR
           SUBSTR(Jurisdiction,1,2) = '43' THEN
            IF num_dependents > 0 THEN
                calcd_dedn_amt := calcd_dedn_amt - (GRN_EXMPT_DEP_AMT_VAL * num_dependents);
            END IF;
        END IF;
    END IF;
    dedn_amt := calcd_dedn_amt;

    /* *** Negative Net checks end ***/

    /*** Stop Rule Processing BEGIN *** */
    IF Total_Owed <> 0 THEN
        IF Primary_Amount_Balance - Period_to_Date_Balance < 0 THEN
            dedn_amt := 0;
            mesg := 'Total Owed already reached, so no garnishment being withheld for ' || lv_ele_name || '.';
            to_total_owed := 0;
        ELSE
            IF Total_Owed - Primary_Amount_Balance < 0 THEN
                fatal_mesg := 'Accrued Deduction Balance > Total Owed by $' ||
                              to_char(Primary_Amount_Balance - Total_Owed ) || '. Adjust Balance for ' || lv_ele_name || '.';
                GLB_SUPPORT_DI := NULL;
                GLB_OTHER_DI_FLAG := NULL;
                GLB_DCIA_EXIST_FLAG := NULL;
                reset_global_var;
                RETURN (6);
            ELSIF Primary_Amount_Balance + dedn_amt >= Total_Owed THEN
                dedn_amt := Total_Owed - Primary_Amount_Balance;
                to_total_owed := -1 * Primary_Amount_Balance;
                STOP_ENTRY := 'Y';
                mesg := 'Garnishment obligation has been satisfied for ' || lv_ele_name || ' because of Total Owed Reached.';
                /*-- (Bug 1481913) Set a boolean flag to indicate that subsequent garnishments are allowed
                     to be processed. --*/
                GLB_ALLOW_MULT_DEDN := TRUE;
            ELSE
                to_total_owed := dedn_amt;
                --to_fees_accrued :=  calcd_fee;
            END IF;
        END IF;

    ELSE
        to_total_owed := 0;
    END IF;

    calcd_dedn_amt := dedn_amt;

    garn_limit_days := get_garn_limit_max_duration(PAY_EARNED_START_DATE);

   /*
    * Bug 3718454
    * Added 1 to the calculation of garn_days as the both
    * PAY_EARNED_END_DATE and VF_DATE_SERVED should be included for
    * calculating the STOP_ENTRY value
    */

    IF garn_limit_days > 0 THEN
        garn_days := PAY_EARNED_END_DATE - Date_Served + 1;
        IF garn_days >= garn_limit_days THEN
            garn_days_end_per := PAY_EARNED_START_DATE - Date_Served + 1;
            /*
             * Added the IF condition te determine whether any amount needs
             * to be deducted.(Bug 3718454 and 3734415)
	     * Bug 3777900 : Removed '=' sign from the IF condition below
             */
            IF garn_days_end_per > garn_limit_days THEN
                STOP_ENTRY := 'Y';
                CALCD_DEDN_AMT := 0;
                CALCD_FEE := 0;
                mesg := garn_limit_days || ' days Limit for element ' || lv_ele_name || ' was reached before current pay period. No Deduction will be taken. Element will be end dated';
            ELSE
                STOP_ENTRY := 'Y';
                mesg := 'Garnishment obligation has been satisfied for ' || lv_ele_name || ' because of Max Withholding Days Limit Reached.';
                to_total_owed := -1 * Primary_Amount_Balance;
            END IF;
        END IF;
    END IF;
    /* *** Stop Rule Processing END ***/

-- Commented the following Final Pay section for Bug 4107302
    /*** Final Pay Section BEGIN *** */
    /*
    IF (TERMINATED_EMPLOYEE = 'Y' AND FINAL_PAY_PROCESSED = 'N') THEN
        STOP_ENTRY := 'Y';
    END IF;
    */
    /**** Final Pay Section END ****/

    /* Bankrupcy Order and DCIA does not have fees */
    -- Bug 4079142
    IF garn_category = 'BO' or garn_category = 'DCIA' or garn_category = 'EL' THEN -- Bug# 6068769
        calcd_fee:= 0;
    END IF;

    /* Check for negative for dedn_amt and fees */
    IF calcd_fee < 0 THEN
        calcd_fee := 0;
    END IF;

    -- Bug 4234046 and 4748532
    -- Set Fee Amount to ZERO when
    --- * No deduction is taken
    --  * We are not looking at PTD values for deducting Garnishment
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) = default_number THEN
       IF calcd_dedn_amt <= 0 THEN
           calcd_dedn_amt := 0;
           calcd_fee := 0;
           to_total_owed := 0;
       END IF;
    ELSIF calcd_dedn_amt <= 0 THEN
           calcd_dedn_amt := 0;
           to_total_owed := 0;
    END IF;

    garn_fee:=calcd_fee;
    SF_Accrued_fees := calcd_fee;
    SF_Accrued_Fees := SF_Accrued_Fees + accrued_fee_correction;

    -- Bug 3500570
    IF NET_ASG_GRE_RUN > subject_disposable_income AND dedn_amt <> 0 THEN
        not_taken := 0;
    END IF;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Return values....');
        hr_utility.trace('CALCD_ARREARS = '||CALCD_ARREARS);
        hr_utility.trace('CALCD_DEDN_AMT = '||CALCD_DEDN_AMT);
        hr_utility.trace('CALCD_FEE = '||CALCD_FEE);
        hr_utility.trace('FATAL_MESG = '||FATAL_MESG);
        hr_utility.trace('GARN_FEE = '||GARN_FEE);
        hr_utility.trace('MESG = '||MESG);
        hr_utility.trace('MESG1 = '||MESG1);
        hr_utility.trace('NOT_TAKEN = '||NOT_TAKEN);
        hr_utility.trace('SF_ACCRUED_FEES = '||SF_ACCRUED_FEES);
        hr_utility.trace('STOP_ENTRY = '||STOP_ENTRY);
        hr_utility.trace('TO_ADDL = '||TO_ADDL);
        hr_utility.trace('TO_REPL = '||TO_REPL);
        hr_utility.trace('TO_TOTAL_OWED = '||TO_TOTAL_OWED);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
    END IF;

    if GLB_NUM_ELEM = 0 then
       GLB_SUPPORT_DI := NULL;
       GLB_OTHER_DI_FLAG := NULL;
       GLB_DCIA_EXIST_FLAG := NULL;
       reset_global_var;
    end if;

    hr_utility.trace('Leaving '||l_proc_name);
    IF calcd_fee = 0 THEN
        RETURN(7);
    ELSE
        RETURN(8);
    END IF;
END CAL_FORMULA_BO;


  /****************************************************************************
    Name        : CAL_FORMULA_TL
    Description : This function calculates amount to be withheld for TL
                  category.
  *****************************************************************************/
FUNCTION CAL_FORMULA_TL
(
    P_CTX_BUSINESS_GROUP_ID number,
    P_CTX_PAYROLL_ID number,
    P_CTX_ELEMENT_TYPE_ID number,
    P_CTX_ORIGINAL_ENTRY_ID number,
    P_CTX_DATE_EARNED date,
    P_CTX_JURISDICTION_CODE varchar2,
    P_CTX_ELEMENT_ENTRY_ID number,
    PAY_EARNED_START_DATE date,
    PAY_EARNED_END_DATE date,
    TOTAL_WITHHELD_FEE_ASG_GRE_RUN number,
    TOT_WHLD_SUPP_ASG_GRE_RUN number,
    SCL_ASG_US_WORK_SCHEDULE varchar2,
    ASG_HOURS number,
    ASG_FREQ varchar2,
    TERMINATED_EMPLOYEE varchar2,
    FINAL_PAY_PROCESSED varchar2,
    GROSS_EARNINGS_ASG_GRE_RUN number,
    TAX_DEDUCTIONS_ASG_GRE_RUN number,
    NET_ASG_GRE_RUN number,
    NET_ASG_RUN number,
    TOTAL_OWED number,
    DATE_SERVED date,
    ADDITIONAL_AMOUNT_BALANCE number,
    REPLACEMENT_AMOUNT_BALANCE number,
    PRIMARY_AMOUNT_BALANCE number,
    TAX_LEVIES_ASG_GRE_PTD number,
    CALCD_DEDN_AMT OUT NOCOPY number,
    NOT_TAKEN OUT NOCOPY number,
    TO_ARREARS OUT NOCOPY number,
    TO_TOTAL_OWED OUT NOCOPY number,
    TO_ADDL OUT NOCOPY number,
    TO_REPL OUT NOCOPY number,
    FATAL_MESG OUT NOCOPY varchar2,
    MESG OUT NOCOPY varchar2,
    CALC_SUBPRIO OUT NOCOPY number,
    STOP_ENTRY OUT NOCOPY varchar2,
    EIC_ADVANCE_ASG_GRE_RUN number default 0
) RETURN number IS

    dedn_amt number;
    default_date date;
    c_Fed_Levy_Exemption_Table varchar2(100);
    c_fed_levy_xmpt_tab_col varchar2(100);
    c_fed_levy_xmpt_per_xmpt_row varchar2(100);
    c_federal_minimum_wage number;
    take_home_pay number;
    standard_deduction pay_user_column_instances_f.value%TYPE;
    allowance_per_exemption pay_user_column_instances_f.value%TYPE;
    personal_exemption_allowance number;
    fed_levy_annual_exemption number;
    fed_levy_exemption number;
    amt_at_hand number;
    garn_limit_days number;
    garn_days number;
    garn_days_end_per number;
    sub_prio_max number;
    actual_dedn number;

    amount number;
    filing_status varchar2(10);
    allowances number;
    dedns_at_time_of_writ number;
    monthly_cap_amount number;
    month_to_date_balance number;
    period_cap_amount number;
    period_to_date_balance number;
    ld_entry_start_date   date;
    ld_filing_status_date date;
    ld_filing_status_year number;
    default_number number;

    l_debug_on varchar2(1);
    l_proc_name varchar2(50);
    lv_ele_name varchar2(100);

    CURSOR cur_debug is
        SELECT parameter_value
          FROM pay_action_parameters
         WHERE parameter_name = 'GARN_DEBUG_ON';

    -- Bug 4079142
    -- Cursor to get the element name to be used in the message.
    CURSOR csr_get_ele_name (p_ele_type_id number) is
    select rtrim(element_name,' Calculator' )
      from pay_element_types_f
     where element_type_id = p_ele_type_id;

    -- Bug 3528349
    -- Cursor to fetch the Filing Status year for the person if specified
    CURSOR csr_get_filing_status_year is
    select ppei.pei_information1
      from per_people_extra_info ppei,
           pay_element_entries_f peef,
           per_all_assignments_f paaf
     where peef.element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
       and peef.assignment_id = paaf.assignment_id
       and paaf.person_id = ppei.person_id
       and ppei.information_type = 'US_FED_LEVY_FIL_STATUS_YEAR';

    -- Bug 3528349
    -- Cursor to get the start date of the element
    CURSOR csr_get_entry_start_date is
    select min(effective_start_date)
      from pay_element_entries_f
     where element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
     group by element_entry_id;

    -- 5111601
    -- Cursor to Fetch whether the EE or Spouse is Blind / Age >= 65
    CURSOR csr_get_blind_65_flag is
    SELECT entry_information10
      FROM pay_element_entries_f
     WHERE element_entry_id = P_CTX_ORIGINAL_ENTRY_ID
       AND entry_information_category = 'US_INVOLUNTARY DEDUCTIONS'
       AND P_CTX_DATE_EARNED BETWEEN effective_start_date and effective_end_date;

     -- Bug# 6132855
     -- Federal Minimum Wage now is stored in JIT table
     CURSOR c_get_federal_min_wage IS
     SELECT fed_information1
       FROM pay_us_federal_tax_info_f
      WHERE fed_information_category = 'WAGEATTACH LIMIT'
        AND P_CTX_DATE_EARNED BETWEEN effective_start_date
                                  AND effective_end_date;

    c_Fed_65_Blind_Exemption_Table         varchar2(100) ;
    c_Fed_65_Blind_Xmpt_tab_col            varchar2(100) ;
    lv_65_blind                            number ;
    lv_temp_Filing_Status                  varchar2(100) ;
    lv_Filing_Status_name                  varchar2(100) ;
    exemption_for_age_65_or_blind          pay_user_column_instances_f.value%TYPE ;

BEGIN

    l_proc_name := l_package_name||'CAL_FORMULA_TL';
    hr_utility.trace('Entering '||l_proc_name);

    default_date := fnd_date.canonical_to_date('0001/01/01');
    sub_prio_max := 9999;
    default_number := -9999;
    amount := GLB_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    filing_status := GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID);
    allowances := GLB_ALLOWS(P_CTX_ORIGINAL_ENTRY_ID);
    dedns_at_time_of_writ := GLB_DEDN_OVERRIDE(P_CTX_ORIGINAL_ENTRY_ID);
    monthly_cap_amount := GLB_MONTH_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    month_to_date_balance := GLB_MTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);
    period_cap_amount := GLB_PTD_CAP_AMT(P_CTX_ORIGINAL_ENTRY_ID);
    period_to_date_balance := GLB_PTD_BAL(P_CTX_ORIGINAL_ENTRY_ID);

    OPEN cur_debug;
        FETCH cur_debug into l_debug_on;
    CLOSE cur_debug;

    -- Fetching Federal Minimum Wage Value from JIT table
    OPEN c_get_federal_min_wage;
    FETCH c_get_federal_min_wage INTO c_Federal_Minimum_Wage;
    CLOSE c_get_federal_min_wage;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Input parameters....');
        hr_utility.trace('P_CTX_BUSINESS_GROUP_ID = '||P_CTX_BUSINESS_GROUP_ID);
        hr_utility.trace('P_CTX_PAYROLL_ID = '||P_CTX_PAYROLL_ID);
        hr_utility.trace('P_CTX_ELEMENT_TYPE_ID = '||P_CTX_ELEMENT_TYPE_ID);
        hr_utility.trace('P_CTX_ORIGINAL_ENTRY_ID = '||P_CTX_ORIGINAL_ENTRY_ID);
        hr_utility.trace('P_CTX_DATE_EARNED = '||P_CTX_DATE_EARNED);
        hr_utility.trace('P_CTX_JURISDICTION_CODE = '||P_CTX_JURISDICTION_CODE);
        hr_utility.trace('P_CTX_ELEMENT_ENTRY_ID = '||P_CTX_ELEMENT_ENTRY_ID);
        hr_utility.trace('PAY_EARNED_START_DATE = '||PAY_EARNED_START_DATE);
        hr_utility.trace('PAY_EARNED_END_DATE = '||PAY_EARNED_END_DATE);
        hr_utility.trace('TOTAL_WITHHELD_FEE_ASG_GRE_RUN = '||TOTAL_WITHHELD_FEE_ASG_GRE_RUN);
        hr_utility.trace('TOT_WHLD_SUPP_ASG_GRE_RUN = '||TOT_WHLD_SUPP_ASG_GRE_RUN);
        hr_utility.trace('SCL_ASG_US_WORK_SCHEDULE = '||SCL_ASG_US_WORK_SCHEDULE);
        hr_utility.trace('ASG_HOURS = '||ASG_HOURS);
        hr_utility.trace('ASG_FREQ = '||ASG_FREQ);
        hr_utility.trace('TERMINATED_EMPLOYEE = '||TERMINATED_EMPLOYEE);
        hr_utility.trace('FINAL_PAY_PROCESSED = '||FINAL_PAY_PROCESSED);
        hr_utility.trace('GROSS_EARNINGS_ASG_GRE_RUN = '||GROSS_EARNINGS_ASG_GRE_RUN);
        hr_utility.trace('TAX_DEDUCTIONS_ASG_GRE_RUN = '||TAX_DEDUCTIONS_ASG_GRE_RUN);
        hr_utility.trace('NET_ASG_GRE_RUN = '||NET_ASG_GRE_RUN);
        hr_utility.trace('NET_ASG_RUN = '||NET_ASG_RUN);
        hr_utility.trace('TOTAL_OWED = '||TOTAL_OWED);
        hr_utility.trace('DATE_SERVED = '||DATE_SERVED);
        hr_utility.trace('ADDITIONAL_AMOUNT_BALANCE = '||ADDITIONAL_AMOUNT_BALANCE);
        hr_utility.trace('REPLACEMENT_AMOUNT_BALANCE = '||REPLACEMENT_AMOUNT_BALANCE);
        hr_utility.trace('PRIMARY_AMOUNT_BALANCE = '||PRIMARY_AMOUNT_BALANCE);
        hr_utility.trace('TAX_LEVIES_ASG_GRE_PTD = '||TAX_LEVIES_ASG_GRE_PTD);
        hr_utility.trace('EIC_ADVANCE_ASG_GRE_RUN = ' || EIC_ADVANCE_ASG_GRE_RUN);
        hr_utility.trace('c_Federal_Minimum_Wage = ' || c_Federal_Minimum_Wage);
    END IF;
    /*
    Algorithm: Federal Tax Levies are calculated according to the following:
    1. Calculate Take Home Pay which equals gross earnings less taxes and deductions in
       effect prior to the date of levy.
    2. Calculate Fed levy exemption as the employees standard deduction for fed
       income tax purposes; plus the personal exemption allowance.
       Convert this annual figure to the payroll period type of the employee.
    3. The difference between Take Home Pay and the fed levy exemption is the
       amount to withhold - ie. everything!

    NOTE: The filing status and allowances to be used to compute standard and
          personal exemption MUST BE ENTERED, we will not use W-4 for this info.

    */


    /*--------- Set Contexts -------------*/
    CTX_BUSINESS_GROUP_ID := P_CTX_BUSINESS_GROUP_ID;
    CTX_PAYROLL_ID        := P_CTX_PAYROLL_ID;
    CTX_ELEMENT_TYPE_ID   := P_CTX_ELEMENT_TYPE_ID;
    CTX_ORIGINAL_ENTRY_ID := P_CTX_ORIGINAL_ENTRY_ID;
    CTX_DATE_EARNED       := P_CTX_DATE_EARNED;
    CTX_JURISDICTION_CODE := P_CTX_JURISDICTION_CODE;
    CTX_ELEMENT_ENTRY_ID  := P_CTX_ELEMENT_ENTRY_ID;
    /*------------------------------------*/


    dedn_amt := 0;
    not_taken := 0;
    calc_subprio := entry_subpriority;
    ld_filing_status_year := NULL;

    GLB_NUM_ELEM := GLB_NUM_ELEM - 1;
    hr_utility.trace('GLB_NUM_ELEM = '|| GLB_NUM_ELEM);


    -- Bug 4079142
    -- Get the element name to be used in the message.
    open csr_get_ele_name(CTX_ELEMENT_TYPE_ID);
    fetch csr_get_ele_name into lv_ele_name;
    close csr_get_ele_name;

    open csr_get_filing_status_year;
    fetch csr_get_filing_status_year into ld_filing_status_year;
    close csr_get_filing_status_year;

    IF ld_filing_status_year is not NULL THEN
       ld_filing_status_date := trunc(to_date(ld_filing_status_year,'YYYY')
                                      , 'Y');
    ELSE
       hr_utility.trace('Getting the Element Entry Start Date');
       open csr_get_entry_start_date;
       fetch csr_get_entry_start_date into ld_entry_start_date;
       close csr_get_entry_start_date;

       ld_filing_status_date := trunc(ld_entry_start_date,'Y');
    END IF;

    IF calc_subprio = 1 THEN
        IF date_served <> default_date THEN
            calc_subprio :=  sub_prio_max  - (PAY_EARNED_END_DATE - Date_Served);
        END IF;
    END IF;

    c_Fed_Levy_Exemption_Table := 'Federal Tax Standard Deduction Table';
    c_fed_levy_xmpt_tab_col := 'Exemption Amount';
    c_fed_levy_xmpt_per_xmpt_row := 'Personal Exemption';

    -- 5111601
    c_Fed_65_Blind_Exemption_Table := 'Federal Tax Additional Exemption Table' ;
    c_Fed_65_Blind_Xmpt_tab_col := 'Exemption Amount' ;

    --c_Federal_Minimum_Wage := 5.15;  /* Current as of Septemerr 1997. */

  /* *** Step #1 *** */
    -- Bug 4104842
    -- Use GLB_TL_GROSS_EARNINGS instead of GROSS_EARNINGS_ASG_GRE_RUN
    -- as GROSS_EARNINGS_ASG_GRE_RUN sums up Imputed Earnings too.
    -- Disposable Income calculation of Tax Levy does not include
    -- the same. THis will also ensure that the take_home_pay calculated for
    -- TL is based on the Earning Rules specified.
    -- Bug 4858720
    -- Use EIC_ADVANCE_ASG_GRE_RUN for calculatin the Deduction amount
    -- Bug 5095823
    take_home_pay := GLB_TL_GROSS_EARNINGS -
                     (TAX_DEDUCTIONS_ASG_GRE_RUN - EIC_ADVANCE_ASG_GRE_RUN) -
                     TOT_WHLD_SUPP_ASG_GRE_RUN -
                     GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN -
                     Dedns_at_Time_of_Writ;

  /* *** Step #2 *** */

    standard_deduction := get_table_value(c_Fed_Levy_Exemption_Table,
                                          c_fed_levy_xmpt_tab_col,
                                          Filing_Status,
                                          ld_filing_status_date);

    allowance_per_exemption := get_table_value(c_Fed_Levy_Exemption_Table,
                                               c_fed_levy_xmpt_tab_col,
                                               c_fed_levy_xmpt_per_xmpt_row,
                                               ld_filing_status_date);

    hr_utility.trace('Year of Exemption '|| to_char(ld_filing_status_date,
                                                    'DD-MON-YYYY'));
    hr_utility.trace('Exemption Amount '|| standard_deduction);
    hr_utility.trace('Personal Exemption '|| allowance_per_exemption);


    personal_exemption_allowance := TO_NUMBER(allowance_per_exemption) * Allowances;

    -- 5111601
    OPEN csr_get_blind_65_flag ;
    FETCH csr_get_blind_65_flag INTO lv_65_blind ;
    CLOSE csr_get_blind_65_flag ;


    IF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '01', '03' ) AND lv_65_blind = 1 THEN
       lv_temp_Filing_Status := 'Single 01' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '01', '03' ) AND lv_65_blind = 2 THEN
       lv_temp_Filing_Status := 'Single 02' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '02', '04' ) AND lv_65_blind = 1 THEN
       lv_temp_Filing_Status := 'Married 01' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '02', '04' ) AND lv_65_blind = 2 THEN
       lv_temp_Filing_Status := 'Married 02' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '02', '04' ) AND lv_65_blind = 3 THEN
       lv_temp_Filing_Status := 'Married 03' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '02', '04' ) AND lv_65_blind = 4 THEN
       lv_temp_Filing_Status := 'Married 04' ;
    ELSIF GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID) IN ( '01', '03' ) AND lv_65_blind in ( 3 , 4 ) THEN
       lv_temp_Filing_Status := 'Single 02' ;

       select decode(GLB_FIL_STAT(P_CTX_ORIGINAL_ENTRY_ID),'01','Single','03','Head Of HouseHold')
       into   lv_Filing_Status_name
       from   dual ;
       mesg := 'The value '|| to_char(lv_65_blind) ||' for EE or Spouse Blind / Age >= 65 is invalid '||
               'for the Filing Status '|| lv_Filing_Status_name || ' and has been overridden to 2. ' ||
               'Please correct the same before the next run.' ;
    ELSE
       lv_temp_Filing_Status := NULL ;
    END IF ;

    IF lv_temp_Filing_Status IS NOT NULL THEN
       exemption_for_age_65_or_blind := get_table_value(c_Fed_65_Blind_Exemption_Table,
                                                        c_Fed_65_Blind_Xmpt_tab_col,
                                                        lv_temp_Filing_Status,
                                                        ld_filing_status_date) ;

    ELSE
       exemption_for_age_65_or_blind := 0 ;
    END IF ;
    hr_utility.trace('Exemption Amount for Age >= 65 or Blind '||to_char(exemption_for_age_65_or_blind)) ;

    fed_levy_annual_exemption := TO_NUMBER(standard_deduction) +
                                 personal_exemption_allowance  +
                                 exemption_for_age_65_or_blind ;

    hr_utility.trace('Federal Levy Annual Exemption '||to_char(fed_levy_annual_exemption)) ;

    fed_levy_exemption := Convert_Period_Type(SCL_ASG_US_WORK_SCHEDULE,
                                              ASG_HOURS,
                                              fed_levy_annual_exemption,
                                              'YEAR',
                                              'NOT ENTERED',
                                              PAY_EARNED_START_DATE,
                                              PAY_EARNED_END_DATE,
                                              ASG_FREQ);

    hr_utility.trace('Federal Levy Exemption '||to_char(fed_levy_exemption)) ;

    IF TAX_LEVIES_ASG_GRE_PTD > 0 THEN
        fed_levy_exemption := 0;
    END IF;

    amt_at_hand := take_home_pay - fed_levy_exemption;

    IF Replacement_Amount_Balance = 0 AND Amount = 0 THEN
        dedn_amt := take_home_pay - fed_levy_exemption;
        IF dedn_amt < 0 THEN
            dedn_amt := 0;
        END IF;
    ELSE
        IF Replacement_Amount_Balance <> 0 THEN
            dedn_amt := Replacement_Amount_Balance;
            IF amt_at_hand < dedn_amt THEN
                to_arrears := dedn_amt - amt_at_hand;
                dedn_amt := take_home_pay - fed_levy_exemption;
                not_taken := amt_at_hand - dedn_amt;
                IF dedn_amt < 0 THEN
                    dedn_amt := 0;
                END IF;
            END IF;

            to_repl := -1 * Replacement_Amount_Balance;
        ELSE
            dedn_amt := Amount;
            IF amt_at_hand < dedn_amt THEN
                to_arrears := dedn_amt - amt_at_hand;
                dedn_amt := take_home_pay - fed_levy_exemption;
                not_taken :=  amt_at_hand - dedn_amt;
                IF dedn_amt < 0 THEN
                    dedn_amt := 0;
                END IF;
            END IF;
        END IF;
    END IF;


  /* *** Add in any adjustments. *** */


    IF Additional_Amount_Balance <> 0 THEN
       dedn_amt := dedn_amt + Additional_Amount_Balance;
       IF amt_at_hand < dedn_amt THEN
          not_taken := not_taken + Additional_Amount_Balance;
          to_arrears := not_taken + Additional_Amount_Balance;
          dedn_amt := take_home_pay - fed_levy_exemption;
          IF dedn_amt < 0 THEN
             dedn_amt := 0;
          END IF;
       END IF;
       to_addl := -1 * Additional_Amount_Balance;
    END IF;

/* Start Cap functionality */
-- Bug 3749162
    actual_dedn := dedn_amt;
    IF Monthly_Cap_Amount <> 0  THEN
        IF Monthly_Cap_Amount - Month_To_Date_Balance < 0 THEN
            fatal_mesg := 'MTD Balance > Monthly Cap by $' ||
                          TO_CHAR(Month_To_Date_Balance - Monthly_Cap_Amount ) ||
                          '. Adjust Balance for ' || lv_ele_name || '.';
            reset_global_var;
            RETURN(1);
        ELSE
            IF dedn_amt + Month_To_Date_Balance > Monthly_Cap_Amount THEN
               IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                  actual_dedn := Monthly_Cap_Amount - Month_To_Date_Balance;
                  hr_utility.trace('Actual Deduction Amount(MTD) = ' || actual_dedn);
                  hr_utility.trace('Deduction Amount(MTD) = ' || dedn_amt);
               ELSE
                  dedn_amt := Monthly_Cap_Amount - Month_To_Date_Balance;
               END IF;

	    END IF;
        END IF;
    END IF;

-- Bug 3749162
    IF Period_Cap_Amount <> 0  THEN
        IF Period_Cap_Amount - Period_To_Date_Balance < 0 THEN
            fatal_mesg := 'PTD Balance > Period Cap by $' ||
                           TO_CHAR(Period_To_Date_Balance - Period_Cap_Amount ) ||
                          '. Adjust Balance for ' || lv_ele_name || '.';
            reset_global_var;
            RETURN(2);
        ELSE
            IF dedn_amt + Period_To_Date_Balance > Period_Cap_Amount THEN
               IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
                  IF actual_dedn > Period_Cap_Amount - Period_To_Date_Balance THEN
                     actual_dedn := Period_Cap_Amount - Period_To_Date_Balance;
                  END IF;
                  hr_utility.trace('Actual Deduction Amount(PTD) = ' || actual_dedn);
                  hr_utility.trace('Deduction Amount(PTD) = ' || dedn_amt);
               ELSE
                  dedn_amt := Period_Cap_Amount - Period_To_Date_Balance;
               END IF;
            END IF;
        END IF;
    END IF;

/* End Cap functionality */

    -- Bug 4748532
    -- Deduct PTD amount for Garnishment and Fees if the value of
    -- GLB_FEES_ASG_GRE_PTD is not set to -9999(default_number) in BASE_FORMULA
    IF GLB_FEES_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) <> default_number THEN
       if Amount <> 0 then
          hr_utility.trace('Deduction that can be taken = ' || DEDN_AMT);
          hr_utility.trace('Deduction already taken     = ' || GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID));
          IF (dedn_amt + GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID)) > Amount THEN
             dedn_amt := Amount - GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
          END IF;
       elsif dedn_amt > GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID) then
          dedn_amt := dedn_amt - GLB_BASE_ASG_GRE_PTD(P_CTX_ORIGINAL_ENTRY_ID);
       else
          dedn_amt := 0;
       end if; -- if

        IF dedn_amt > actual_dedn THEN
           dedn_amt := actual_dedn;
        END IF;
    END IF; -- IF GLB_FEES_ASG_GRE_PTD

     -- Bug 4924454
     -- Take no deduction when Net Salary < 0
     --Bug 8607790 moving this after IF Total_Owed <> 0
/*     IF NET_ASG_GRE_RUN < 0 THEN
        not_taken := 0;
        to_arrears := 0;
        dedn_amt := 0;
     ELSIF NET_ASG_GRE_RUN - dedn_amt < 0 THEN
         not_taken := dedn_amt - NET_ASG_RUN;
         to_arrears := dedn_amt - NET_ASG_RUN;
         dedn_amt := NET_ASG_GRE_RUN;
     END IF;*/


/* *** Stop Rule Processing BEGIN *** */

    IF Total_Owed <> 0 THEN
        IF Primary_Amount_Balance - Period_to_Date_Balance < 0 THEN
            dedn_amt := 0;
            mesg := 'Total Owed already reached, so no federal tax levy being withheld for ' || lv_ele_name || '.';
            to_total_owed := 0;
        ELSE
            IF Total_Owed - Primary_Amount_Balance < 0 THEN
                fatal_mesg := 'Deduction Balance > Total Owed by $' ||
                              TO_CHAR(Primary_Amount_Balance - Total_Owed ) || '. Adjust Balance for ' || lv_ele_name || '.';
                reset_global_var;
                RETURN(3);
            ELSE
                IF Primary_Amount_Balance + dedn_amt >= Total_Owed THEN
                    dedn_amt := Total_Owed - Primary_Amount_Balance;
                    STOP_ENTRY := 'Y';
                    mesg := 'Federal tax levy obligation has been satisfied for ' || lv_ele_name || ' because of Total Owed Reached.';
                    IF Primary_Amount_Balance <> 0 THEN
                        to_total_owed := -1 * Primary_Amount_Balance;
                    ELSE
                        to_total_owed := 0;
                    END IF;
                ELSE
                    to_total_owed := dedn_amt;
                END IF;
            END IF;
        END IF;
    ELSE
        to_total_owed := dedn_amt;
    END IF;
--moved this for resoving bug 8607790
     IF NET_ASG_GRE_RUN < 0 THEN
        not_taken := 0;
        to_arrears := 0;
        dedn_amt := 0;
     ELSIF NET_ASG_GRE_RUN - dedn_amt < 0 THEN
         not_taken := dedn_amt - NET_ASG_RUN;
         to_arrears := dedn_amt - NET_ASG_RUN;
         dedn_amt := NET_ASG_GRE_RUN;
     END IF;
--bug 8607790 fix ends here

    garn_limit_days := get_garn_limit_max_duration(PAY_EARNED_START_DATE);

   /*
    * Bug 3718454
    * Added 1 to the calculation of garn_days as the both
    * PAY_EARNED_END_DATE and VF_DATE_SERVED should be included for
    * calculating the STOP_ENTRY value
    */

    IF garn_limit_days > 0 THEN
        garn_days := PAY_EARNED_END_DATE - Date_Served + 1;
        IF garn_days >= garn_limit_days THEN
            garn_days_end_per := PAY_EARNED_START_DATE - Date_Served + 1;
            /*
             * Added the IF condition te determine whether any amount needs
             * to be deducted.(Bug 3718454 and 3734415)
	     * Bug 3777900 : Removed '=' sign from the IF condition below
             */
            IF garn_days_end_per > garn_limit_days THEN
                STOP_ENTRY := 'Y';
                DEDN_AMT := 0;
                mesg := garn_limit_days || ' days Limit for element ' || lv_ele_name || ' was reached before current pay period. No Deduction will be taken. Element will be end dated';
                IF Primary_Amount_Balance <> 0 THEN
                    to_total_owed := -1 * Primary_Amount_Balance;
                ELSE
                    to_total_owed := 0;
                END IF;
            ELSE
                STOP_ENTRY := 'Y';
                mesg := 'Federal tax levy obligation has been satisfied for ' || lv_ele_name || ' because of Max Withholding Days Limit Reached.';
                IF Primary_Amount_Balance <> 0 THEN
                    to_total_owed := -1 * Primary_Amount_Balance;
                ELSE
                    to_total_owed := 0;
                END IF;
            END IF;
        END IF;
    END IF;

-- Commented the following Final Pay section for Bug 4107302
/* *** Final Pay Section BEGIN *** */
    /*
    IF (TERMINATED_EMPLOYEE = 'Y' AND FINAL_PAY_PROCESSED = 'N') THEN
        STOP_ENTRY := 'Y';
    END IF;
    */
/* *** Final Pay Section END *** */

    calcd_dedn_amt := dedn_amt;

    -- Bug 3500570
    IF NET_ASG_GRE_RUN > amt_at_hand THEN
    	not_taken := 0;
    END IF;

    IF l_debug_on = 'Y' THEN
        hr_utility.trace('Values returned ...');
        hr_utility.trace('CALCD_DEDN_AMT = '||CALCD_DEDN_AMT);
        hr_utility.trace('NOT_TAKEN = '||NOT_TAKEN);
        hr_utility.trace('TO_ARREARS = '||TO_ARREARS);
        hr_utility.trace('TO_TOTAL_OWED = '||TO_TOTAL_OWED);
        hr_utility.trace('TO_ADDL = '||TO_ADDL);
        hr_utility.trace('TO_REPL = '||TO_REPL);
        hr_utility.trace('FATAL_MESG = '||FATAL_MESG);
        hr_utility.trace('MESG = '||MESG);
        hr_utility.trace('CALC_SUBPRIO = '||CALC_SUBPRIO);
        hr_utility.trace('STOP_ENTRY = '||STOP_ENTRY);
    END IF;

    if GLB_NUM_ELEM = 0 then
       reset_global_var;
    end if;

    hr_utility.trace('Leaving '||l_proc_name);

    RETURN(4);
END cal_formula_tl;


  /****************************************************************************
    Name        : GET_TABLE_VALUE
    Description : This function returns the value stored by specified column in
                  the specified table.
  *****************************************************************************/


FUNCTION GET_TABLE_VALUE
(
C_FED_LEVY_EXEMPTION_TABLE varchar2,
C_FED_LEVY_XMPT_TAB_COL varchar2,
FILING_STATUS varchar2,
FILING_STATUS_YEAR date
) RETURN pay_user_column_instances_f.value%TYPE IS
BEGIN
    RETURN(hruserdt.get_table_value(
                                    CTX_BUSINESS_GROUP_ID,
                                    C_FED_LEVY_EXEMPTION_TABLE,
                                    C_FED_LEVY_XMPT_TAB_COL,
                                    FILING_STATUS,
                                    FILING_STATUS_YEAR
                                    ));
END GET_TABLE_VALUE;

  /****************************************************************************
    Name        : GET_CCPA_PROTECTION
    Description : This function returns CCPA Protectiosn value which is then
                  serves as an upper limit of amount that can be deducted.
  *****************************************************************************/


FUNCTION GET_CCPA_PROTECTION
(
TOTAL_DI number,
OTHERS_DI number,
SUPPORT_DI number,
CCPA_PROT_PERC number
) RETURN number IS

    ln_ccpa_protection number;
    l_proc_name varchar2(50);

BEGIN

     -- Initialization Code
     ln_ccpa_protection := 0;
     l_proc_name := l_package_name||'GET_CCPA_PROTECTION';

     hr_utility.trace('Entering '||l_proc_name);

     IF GLB_DCIA_EXIST_FLAG THEN
         -- Bug 4079142
         -- Checking for Federal Consumer Credit Protection Act in case of DCIA
         -- using the following rule
         -- 1. Total deduction should not go beyond 25% of 'Others DI' in case of
         --    DCIA along with Other Deductions
         -- 2. Total deduction should not go beyond 25% of 'Supp DI' in case of
         --    DCIA along with Support Deductions
         -- 3. Total deduction should not go beyond 25% of 'Others DI' in case of
         --    DCIA along with Other Deductions and Support Deductions
         IF GLB_OTHER_DI_FLAG THEN
             ln_ccpa_protection := CCPA_PROT_PERC * OTHERS_DI;
             hr_utility.trace('Others DI = ' || OTHERS_DI);
             hr_utility.trace('CCPA Protection = ' || ln_ccpa_protection);
         ELSIF GLB_SUPPORT_DI is not NULL THEN
             ln_ccpa_protection := .25 * GLB_SUPPORT_DI;
             hr_utility.trace('Support DI = ' || GLB_SUPPORT_DI);
             hr_utility.trace('CCPA Protection = ' || ln_ccpa_protection);
         ELSE
             ln_ccpa_protection := CCPA_PROT_PERC * TOTAL_DI;
             hr_utility.trace('Total DI = ' || TOTAL_DI);
             hr_utility.trace('CCPA Protection = ' || ln_ccpa_protection);
         END IF;
     ELSE
         -- If DCIA element is not processed then CCPA value is
         -- calculated the current DI value.
         ln_ccpa_protection := CCPA_PROT_PERC * TOTAL_DI;
         hr_utility.trace('Total DI = ' || TOTAL_DI);
         hr_utility.trace('CCPA Protection = ' || ln_ccpa_protection);
     END IF;

     hr_utility.trace('Leaving '||l_proc_name);

     RETURN ln_ccpa_protection;

END GET_CCPA_PROTECTION;


/****************************************************************************
    Name        : RESET_GLOBAL_VAR
    Description : This procedure deletes all Global tables created and
                  resets the value of other Global variables.
*****************************************************************************/
PROCEDURE RESET_GLOBAL_VAR IS
   l_proc_name varchar2(50);
BEGIN
    l_proc_name := l_package_name || 'RESET_GLOBAL_VAR';
    hr_utility.trace('Entering '||l_proc_name);

    dedn_tab.delete;
    gar_dedn_tab.delete;
    fees_tab.delete;
    arrears_tab.delete;
    actual_dedn_tab.delete;
    mod_dedn_tab.delete ; /* Bug# 5295813 */
    GLB_AMT.delete;
    GLB_ARREARS_OVERRIDE.delete;
    GLB_ARREARS_DATE.delete;
    GLB_NUM_DEPS.delete;
    GLB_FIL_STAT.delete;
    GLB_ALLOWS.delete;
    GLB_DEDN_OVERRIDE.delete;
    GLB_PCT.delete;
    GLB_MTD_BAL.delete;
    GLB_EXEMPT_AMT.delete;
    GLB_PTD_CAP_AMT.delete;
    GLB_PTD_BAL.delete;
    GLB_TO_ACCRUED_FEES.delete;
    GLB_MONTH_CAP_AMT.delete;
    GLB_FEES_ASG_GRE_PTD.delete;
    GLB_BASE_ASG_GRE_PTD.delete;
    GLB_TOT_WHLD_SUPP_ASG_GRE_RUN := NULL;
    GLB_TOT_WHLD_ARR_ASG_GRE_RUN := NULL;
    GLB_ALLOW_MULT_DEDN := NULL;
    GLB_NUM_ELEM := NULL;
    GLB_TL_GROSS_EARNINGS := NULL;
    GLB_TOTAL_WHLD_FEE_ASG_GRE_RUN := NULL;
    GLB_SUPPORT_DI := NULL;  /* Bug# 8556724 */

    hr_utility.trace('Global Tables Deleted');
    hr_utility.trace('Leaving '||l_proc_name);

EXCEPTION
    WHEN OTHERS THEN
    NULL;

END;

END PAY_US_INV_DED_FORMULAS;

/
