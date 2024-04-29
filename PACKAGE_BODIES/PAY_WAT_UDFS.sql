--------------------------------------------------------
--  DDL for Package Body PAY_WAT_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WAT_UDFS" AS
/*  $Header: pywatudf.pkb 120.1.12000000.2 2007/07/17 08:29:56 sudedas noship $*/
FUNCTION entry_subpriority (	p_date_earned	in date,
				p_ele_entry_id	in number) RETURN number IS
l_subprio	number(9);
BEGIN
SELECT	nvl(pee.subpriority, 1)
INTO	l_subprio
FROM	pay_element_entries_f            	PEE
WHERE  	PEE.element_entry_id	= p_ele_entry_id
AND	p_date_earned
		BETWEEN PEE.effective_start_date
		    AND PEE.effective_end_date;
RETURN l_subprio;
EXCEPTION when no_data_found THEN
  l_subprio := 1;
  RETURN l_subprio;
END entry_subpriority;
FUNCTION garn_cat( p_date_earned   in date,
                   p_ele_entry_id  in number) return varchar2 IS
l_cat      varchar2(20);
begin
SELECT  pet.element_information1
INTO    l_cat
FROM    pay_element_types_f pet,
        pay_element_links_f pel,
        pay_element_entries_f                   PEE
WHERE   PEE.element_entry_id    = p_ele_entry_id
AND     p_date_earned
                BETWEEN PEE.effective_start_date
                    AND PEE.effective_end_date
AND     pel.element_link_id = PEE.element_link_id
AND     PEE.effective_start_date between pel.effective_start_date
        and pel.effective_end_date
ANd     pet.element_type_id = pel.element_type_id
AND     pel.effective_start_date between pet.effective_start_date
        and pet.effective_end_date;
RETURN l_cat;
EXCEPTION when no_data_found THEN
  l_cat := null;
  RETURN l_cat;
END garn_cat;


/*************************************************************************
routine name: fnc_fee_calculation
purpose:      It calculates the garnishment fee value and then checks this
              fee against legislative maximum for time period.
parameters:
return:       Calculated fee value
specs:
***************************************************************************/
FUNCTION FNC_FEE_CALCULATION ( IN_JURISDICTION                  IN VARCHAR2,
                               IN_GARN_FEE_FEE_RULE             IN VARCHAR2,
                               IN_GARN_FEE_FEE_AMOUNT           IN NUMBER,
                               IN_GARN_FEE_PCT_CURRENT          IN NUMBER,
                               IN_TOTAL_OWED                    IN NUMBER,
                               IN_PRIMARY_AMOUNT_BALANCE        IN NUMBER,
                               IN_ADDL_GARN_FEE_AMOUNT          IN NUMBER,
                               IN_GARN_FEE_MAX_FEE_AMOUNT       IN NUMBER,
                               IN_GARN_FEE_BAL_ASG_GRE_PTD      IN NUMBER,
                               IN_GARN_TOTAL_FEES_ASG_GRE_RUN   IN NUMBER,
                               IN_DEDN_AMT                      IN NUMBER,
                               IN_GARN_FEE_BAL_ASG_GRE_MONTH    IN NUMBER,
                               IN_ACCRUED_FEES                  IN NUMBER) RETURN NUMBER IS


l_calcd_fee NUMBER(7,2):=0.0;  -- stores value to be returned

BEGIN
   IF IN_garn_fee_fee_rule <> 'NONE' THEN
      IF IN_garn_fee_fee_rule = 'AMT_OR_PCT' THEN /*Bug:1009539,Bug:1020421*/
         l_calcd_fee := GREATEST(IN_garn_fee_fee_amount,IN_garn_fee_pct_current * IN_dedn_amt);
      END IF;
      IF IN_garn_fee_fee_rule = 'AMT_OR_PCT_PER_GARN' THEN
       /*
         IF SUBSTR(IN_jurisdiction,1,2) = '11'
            OR SUBSTR(IN_jurisdiction,1,2) = '14'
            OR SUBSTR(IN_jurisdiction,1,2) = '15'
            OR SUBSTR(IN_jurisdiction,1,2) = '26'
         THEN
      */
      -- Bug 3734540
            l_calcd_fee := Greatest(IN_garn_fee_fee_amount,IN_garn_fee_pct_current *IN_dedn_amt);
   --      END IF;
      END IF;

      IF IN_garn_fee_fee_rule = 'PCT_PER_GARN' OR
         IN_garn_fee_fee_rule = 'PCT_PER_PERIOD' OR
         IN_garn_fee_fee_rule = 'PCT_PER_MONTH' OR
         IN_garn_fee_fee_rule = 'PCT_PER_RUN'
      THEN
         /* Tennessee Fee rule for support is 5% of the amount withheld but not to exceed $5 a month */
         l_calcd_fee := IN_garn_fee_pct_current * IN_dedn_amt;
      END IF;

      IF IN_garn_fee_fee_rule = 'AMT_PER_GARN' OR
         IN_garn_fee_fee_rule = 'AMT_PER_PERIOD' OR
         IN_garn_fee_fee_rule = 'AMT_PER_MONTH' OR
         IN_garn_fee_fee_rule = 'AMT_PER_RUN'
      THEN
         l_calcd_fee := IN_garn_fee_fee_amount;
      END IF;

      IF IN_garn_fee_fee_rule = 'AMT_PER_GARN_ADDL' OR
         IN_garn_fee_fee_rule = 'AMT_PER_PERIOD_ADDL' OR
         IN_garn_fee_fee_rule = 'AMT_PER_MONTH_ADDL' OR
         IN_garn_fee_fee_rule = 'AMT_PER_RUN_ADDL'
      THEN
         /* 344140: Check for Accrued Fees = 0 to determine if
         this is first time the wage attachment has been processed, or a
         subsequent processing.*/
         IF IN_Accrued_Fees = 0 THEN
            l_calcd_fee := IN_garn_fee_fee_amount;
         -- Bug 4748532
         -- Modified the package to return Initial Fee for every run in the
         -- payroll period where garnishment is processed first.
         ELSIF IN_Accrued_Fees > 0 AND IN_Accrued_Fees = IN_GARN_FEE_BAL_ASG_GRE_PTD THEN
            l_calcd_fee := IN_garn_fee_fee_amount;
         ELSE
            l_calcd_fee := IN_addl_garn_fee_amount;
         END IF;
      END IF;
   END IF;
   /* *** Fee processing END *** */

   /* Check garnishment fee against legislative maximum for time period. */
   IF IN_garn_fee_fee_rule = 'AMT_OR_PCT' OR
      IN_garn_fee_fee_rule = 'AMT_PER_GARN_ADDL' OR
      IN_garn_fee_fee_rule = 'AMT_PER_GARN' OR
      IN_garn_fee_fee_rule = 'PCT_PER_GARN'
   THEN
      IF IN_Accrued_Fees > 0 AND
         IN_Accrued_Fees < IN_garn_fee_fee_amount THEN
         l_calcd_fee:= IN_garn_fee_fee_amount - IN_Accrued_fees;
      END IF;

      IF IN_garn_fee_max_fee_amount <> -99999 THEN
         /* Check that total fees collected are within legislative limit.
            Check if the fee has addl amt.IF so see whether the accrued has taken all
            Initial amount else assign the left over initial fee. */
         IF  IN_ACCRUED_FEES >= IN_garn_fee_max_fee_amount THEN
            l_calcd_fee := 0;
         ELSIF l_calcd_fee = IN_addl_garn_fee_amount THEN
            IF l_calcd_fee + IN_Accrued_Fees > IN_Garn_fee_max_fee_amount THEN
               l_calcd_fee:=  IN_Garn_fee_max_fee_amount - IN_Accrued_Fees;
            ELSE
               l_calcd_fee:= IN_addl_Garn_fee_amount   ;
            END IF;
         END IF;
         END IF;
      END IF;


   IF IN_garn_fee_fee_rule = 'AMT_OR_PCT_PER_GARN' THEN
      IF IN_garn_fee_max_fee_amount <> -99999 THEN
         /* Check that total fees collected are within legislative limit. */
         IF l_calcd_fee > IN_garn_fee_max_fee_amount THEN
            l_calcd_fee := IN_garn_fee_max_fee_amount;
         END IF;
       END IF;
       IF IN_Accrued_Fees > 0 AND IN_Accrued_Fees >= IN_garn_fee_max_fee_amount  THEN
          /* changes for bug  3734540 */
         /* l_calcd_fee := 0 ; Check if Accrued Fee is less than the calcd fee
                               Otherwise assign the remaining fee to be taken to
                               l_calcd_Fee so that the initial fee is picked up in full.*/
            l_calcd_fee := 0;
         ELSIF (IN_Accrued_Fees + l_calcd_fee) > IN_garn_fee_max_fee_amount THEN
           l_calcd_fee:= IN_garn_fee_max_fee_amount - IN_Accrued_Fees;
        END IF;

   ELSIF IN_garn_fee_fee_rule = 'AMT_PER_PERIOD' OR
         IN_garn_fee_fee_rule = 'PCT_PER_PERIOD' OR
         IN_garn_fee_fee_rule = 'AMT_PER_PERIOD_ADDL'
   THEN
      IF IN_garn_fee_max_fee_amount <> -99999 THEN
         /* Check that total fees collected are within legislative limit. */
         IF IN_GARN_FEE_BAL_ASG_GRE_PTD + l_calcd_fee > IN_garn_fee_max_fee_amount THEN
            /* Recalculate fee amount */
            l_calcd_fee := IN_garn_fee_max_fee_amount - IN_GARN_FEE_BAL_ASG_GRE_PTD;
         END IF;
      END IF;
   ELSIF IN_garn_fee_fee_rule = 'AMT_PER_MONTH' OR
         IN_garn_fee_fee_rule = 'PCT_PER_MONTH' OR
         IN_garn_fee_fee_rule = 'AMT_PER_MONTH_ADDL'
         THEN
            IF IN_garn_fee_max_fee_amount <> -99999 THEN
               IF (IN_GARN_FEE_BAL_ASG_GRE_MONTH + l_calcd_fee) > IN_garn_fee_max_fee_amount THEN
                  /* Recalculate fee amount Check against Month Fee Balance */
                  l_calcd_fee := IN_garn_fee_max_fee_amount - IN_GARN_FEE_BAL_ASG_GRE_MONTH;
               END IF;
            END IF;
    ELSIF IN_garn_fee_fee_rule = 'AMT_PER_RUN' OR
          IN_garn_fee_fee_rule = 'PCT_PER_RUN' OR
          IN_garn_fee_fee_rule = 'AMT_PER_RUN_ADDL'
          THEN
              IF IN_garn_fee_max_fee_amount <> -99999 THEN
                 IF IN_GARN_FEE_BAL_ASG_GRE_PTD + l_calcd_fee > IN_garn_fee_max_fee_amount THEN
                        /* Recalculate fee amount  Check against PTD Fee balance*/
                        l_calcd_fee := IN_garn_fee_max_fee_amount - IN_garn_total_fees_asg_gre_run;
                  END IF;

               END IF;
   END IF;


   RETURN l_calcd_fee;

END fnc_fee_calculation;

FUNCTION get_garn_limit_max_duration (p_element_type_id NUMBER,
                                    p_element_entry_id NUMBER,
                                    p_effective_date DATE,
                                    p_jursd_code VARCHAR2)
RETURN NUMBER IS

/******************************************************************************
Function    : get_garn_limit_max_duration
Description : This function is used to return the maximum duration, in
              number of days, for which a particular garnishment can be
              taken in a particular state. The duration is obtained with
              respect to the 'Date Served' of the garnishment. If 'Date Served'
              is null, then the mimimum effective_start_date for the
              element_entry is used.
Parameters  : p_element_type_id (element_type_id context)
              p_element_entry_id (original_entry_id context)
              p_effective_date (date_earned context)
              p_jursd_code (jurisdiction_code context)
******************************************************************************/

CURSOR c_get_dt_srvd IS
SELECT fnd_date.canonical_to_date(ev.screen_entry_value)
FROM pay_input_values_f iv,
  pay_element_entry_values_f ev
WHERE ev.element_entry_id = p_element_entry_id
AND p_effective_date
             BETWEEN ev.effective_start_date and ev.effective_end_date
AND iv.input_value_id = ev.input_value_id
AND iv.name = 'Date Served';

ld_garn_date DATE := NULL;
ln_garn_limit_days NUMBER(15) := 0;
lv_mod_name VARCHAR2(30) := 'get_garn_limit_max_duration';

BEGIN
  hr_utility.trace(lv_mod_name || ': p_element_type_id');
  hr_utility.trace(lv_mod_name || ': ' || to_char(p_element_type_id));
  hr_utility.trace(lv_mod_name || ': p_element_entry_id');
  hr_utility.trace(lv_mod_name || ': ' || to_char(p_element_entry_id));
  hr_utility.trace(lv_mod_name || ': p_effective_date');
  hr_utility.trace(lv_mod_name || ': ' || p_effective_date);
  hr_utility.trace(lv_mod_name || ': p_jursd_code');
  hr_utility.trace(lv_mod_name || ': ' || p_jursd_code);

  OPEN c_get_dt_srvd;

  FETCH c_get_dt_srvd
  INTO ld_garn_date;

  CLOSE c_get_dt_srvd;

  IF ld_garn_date is NULL
  THEN
    SELECT MIN(effective_start_date)
    INTO ld_garn_date
    FROM pay_element_entries_f ee
    WHERE ee.element_entry_id = p_element_entry_id;
    hr_utility.trace(lv_mod_name || ': Min. Effective Start Date');
    hr_utility.trace(lv_mod_name || ': '
                     || to_char(ld_garn_date, 'dd-mon-yyyy'));
  END IF;

  SELECT target.max_withholding_duration_days
  INTO ln_garn_limit_days
  FROM PAY_US_GARN_LIMIT_RULES_F target,
    PAY_ELEMENT_TYPES_F pet
  WHERE target.state_code = SUBSTR(p_jursd_code,1,2)
  AND target.garn_category = pet.element_information1
  AND ld_garn_date BETWEEN target.effective_start_date
                                  AND target.effective_end_date
  AND pet.element_type_id = p_element_type_id;

/* Commenting the section below as per the Update by Nora Daly
   in Bug# 6140374 on 07/16/07 11:16 am

  AND ld_garn_date
          BETWEEN pet.effective_start_date AND pet.effective_end_date;
*/

  hr_utility.trace(lv_mod_name || ': Garnishment Duration Limit');
  hr_utility.trace(lv_mod_name || ': ' || to_char(ln_garn_limit_days));
  return ln_garn_limit_days;

EXCEPTION WHEN NO_DATA_FOUND THEN
          hr_utility.oracle_error(sqlcode);
          return ln_garn_limit_days;

          WHEN OTHERS THEN
          hr_utility.oracle_error(sqlcode);
          return ln_garn_limit_days;

END get_garn_limit_max_duration;


END pay_wat_udfs;

/
