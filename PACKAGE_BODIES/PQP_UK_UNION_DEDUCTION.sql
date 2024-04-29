--------------------------------------------------------
--  DDL for Package Body PQP_UK_UNION_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UK_UNION_DEDUCTION" AS
/* $Header: pqgbundf.pkb 115.7 2003/03/13 02:09:54 tmehra noship $ */


g_proc                        VARCHAR2(31):= 'pqp_uk_union_deduction.';
g_union_org_info_type         VARCHAR2(30):= 'GB_TRADE_UNION_DETAILS';
g_union_ele_extra_info_type   VARCHAR2(30):= 'PQP_UK_UNION_INFO';

/*=======================================================================
 *                     GET_UK_UNION_ELE_EXTRA_INFO
 *
 * Formula Funtion, uses the context of element_type_id
 *
 * Extracts element type extra information for a give (union) element
 * with an infomation type of 'PQP_UK_UNION_INFO'
 *
 *=======================================================================*/

Function get_uk_union_ele_extra_info
           (p_element_type_id           IN   NUMBER    -- Context
           ,p_union_organization_id     OUT NOCOPY  NUMBER
           ,p_union_level_balance_name  OUT NOCOPY  VARCHAR2
           ,p_pension_rate_type_name    OUT NOCOPY  VARCHAR2
           ,p_fund_list                 OUT NOCOPY  VARCHAR2
           ,p_ERROR_MESSAGE	 OUT NOCOPY  VARCHAR2
           )
Return Number

Is

   l_proc     VARCHAR2(61):= g_proc||'get_uk_union_ele_extra_info';
   l_ret_vlu     NUMBER(2):= 0;

-- The following curosor has been replaced for the performance fixes.
-- The view hr_lookups has been replaced with the base table fnd_lookups.
-- The restriction clause NVL(hrl.lookup_type,'PQP_RATE_TYPE') = 'PQP_RATE_TYPE'
-- and NVL(hrl.enabled_flag,'Y') = 'Y' have been eliminated by using an
-- In-line view on fnd_lookups.

/*
   CURSOR csr_get_union_ele_extra_info IS
   SELECT TO_NUMBER(eei.eei_information1) -- Union Organisation_ID
         ,eei.eei_information2            -- Union Level Balance Name
         ,hrl.meaning                     -- Pension Rate Type Name
         ,eei.eei_information4            -- Union Funds Lookup Type - Fund List
   FROM   pay_element_types_f         ele
         ,pay_element_type_extra_info eei
         ,hr_lookups                  hrl
         ,fnd_sessions                fnd
   WHERE  ele.element_type_id  = p_element_type_id
     AND  eei.element_type_id  = ele.element_type_id
     AND  eei.information_type = g_union_ele_extra_info_type
     AND  NVL(hrl.lookup_type,'PQP_RATE_TYPE') = 'PQP_RATE_TYPE'
     AND  NVL(hrl.enabled_flag,'Y') = 'Y'
     AND  hrl.lookup_code(+)   = eei.eei_information3
     AND  fnd.effective_date BETWEEN ele.effective_start_date
                                 AND ele.effective_end_date
     AND  fnd.session_id = USERENV('sessionid');

*/

   CURSOR csr_get_union_ele_extra_info IS
   SELECT TO_NUMBER(eei.eei_information1) -- Union Organisation_ID
         ,eei.eei_information2            -- Union Level Balance Name
         ,hrl.meaning                     -- Pension Rate Type Name
         ,eei.eei_information4            -- Union Funds Lookup Type - Fund List
   FROM   pay_element_types_f         ele
         ,pay_element_type_extra_info eei
         ,fnd_sessions                fnd
         ,(SELECT *
             FROM fnd_lookup_values
            WHERE lookup_type       =   'PQP_RATE_TYPE'
              AND enabled_flag      =   'Y') hrl
   WHERE  ele.element_type_id  = p_element_type_id
     AND  eei.element_type_id  = ele.element_type_id
     AND  eei.information_type = g_union_ele_extra_info_type
     AND  hrl.lookup_code(+)   = eei.eei_information3
     AND  fnd.effective_date BETWEEN ele.effective_start_date
                                 AND ele.effective_end_date
     AND  fnd.session_id = USERENV('sessionid');


BEGIN

  hr_utility.set_location(' Entering: '||l_proc, 10);

  OPEN csr_get_union_ele_extra_info;

  FETCH csr_get_union_ele_extra_info
   INTO p_union_organization_id
       ,p_union_level_balance_name
       ,p_pension_rate_type_name
       ,p_fund_list;

  IF csr_get_union_ele_extra_info%NOTFOUND THEN

     l_ret_vlu := -1;
     p_ERROR_MESSAGE :=
'Add any extra information type details that are missing from the union '||
'element and then retry the payroll run. If you continue to receive '||
'this message '||
--'when all extra information is correct '||
--'information is correct, '||
'then '||
--'the union organization may have been '||
--'deleted. If so, '||
'contact your support representative.';

  END IF;

  CLOSE csr_get_union_ele_extra_info;

  hr_utility.set_location(' Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);

           p_union_organization_id     := NULL;
           p_union_level_balance_name  := NULL;
           p_pension_rate_type_name    := NULL;
           p_fund_list                 := NULL;
           p_ERROR_MESSAGE             := SQLERRM;

       raise;

END get_uk_union_ele_extra_info;

/*=======================================================================
 *                     GET_UK_UNION_ORG_INFO
 *
 * Formula Function
 *
 * Extracts Organization Information (type 'GB_TRADE_UNION_INFO') for a
 * given Union type organization.
 * This function will be used only by the existing elements. New element
 * created using the template will be using the function
 * get_uk_union_orginfo_fnddate.
 *=======================================================================*/

--
FUNCTION get_uk_union_org_info
           (p_union_organization_id     IN   NUMBER
           ,p_union_rates_table_id      OUT NOCOPY  NUMBER
           ,p_union_rates_table_name    OUT NOCOPY  VARCHAR2
           ,p_union_rates_table_type    OUT NOCOPY  VARCHAR2
           ,p_union_recalculation_date  OUT NOCOPY  VARCHAR2 --Returned 'DD-MON-YYYY'
           ,p_ERROR_MESSAGE             OUT NOCOPY  VARCHAR2
           )
   RETURN NUMBER
IS

   l_proc     VARCHAR2(61):= g_proc||'get_uk_union_org_info';
   l_ret_vlu     NUMBER(2):= 0;

   CURSOR csr_get_union_org_info IS
   SELECT TO_NUMBER(hoi.org_information1) -- Rates Table ID
         ,tbls.user_table_name            -- Rates Table Name
         ,tbls.range_or_match             -- Rates Table Type 'R' or 'M'
         ,to_char(fnd_date.canonical_to_date(hoi.org_information2),'DD-MON')||'-'|| -- Recalculation Date
          DECODE( -- Compare the recalculation month to the effective month
                 SIGN(  -- By checking the difference between
                      (
                       TO_CHAR(fnd_date.canonical_to_date(hoi.org_information2),'MM')
                        -1
                      )  -- The month of the recalculation date less 1
                     -
                      (
                       TO_CHAR(fnds.effective_date,'MM')
                      )  -- The month of the current effective date
                     )
                ,-1      -- Recalculation month < than current month
                   , TO_CHAR(fnds.effective_date,'YYYY') -- use current year
                         -- Recalculation month >= than current month
                ,TO_CHAR(fnds.effective_date-365,'YYYY') -- use previous year
                )
   FROM   hr_organization_information hoi
         ,pay_user_tables tbls
         ,fnd_sessions fnds
   WHERE  hoi.organization_id = p_union_organization_id
     AND  hoi.org_information_context = g_union_org_info_type
     AND  tbls.user_table_id = TO_NUMBER(hoi.org_information1)
     AND  fnds.session_id = USERENV('sessionid');

BEGIN


  hr_utility.set_location(' Entering: '||l_proc, 10);

  OPEN csr_get_union_org_info;

  FETCH csr_get_union_org_info
   INTO p_union_rates_table_id
       ,p_union_rates_table_name
       ,p_union_rates_table_type
       ,p_union_recalculation_date;

  IF csr_get_union_org_info%NOTFOUND THEN

     l_ret_vlu := -1;
     p_ERROR_MESSAGE :=
'You must complete all the details for your trade union organization '||
'before you run this payroll';

  END IF;

  CLOSE csr_get_union_org_info;
  hr_utility.set_location('Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);

           p_union_rates_table_id      := NULL;
           p_union_rates_table_name    := NULL;
           p_union_rates_table_type    := NULL;
           p_union_recalculation_date  := NULL;
           p_ERROR_MESSAGE             := SQLERRM;


       raise;

END get_uk_union_org_info;

/*=======================================================================
 *                     GET_UK_UNION_ORGINFO_FNDDATE
 *
 * Formula Function :
 *
 * Extracts Organization Information (type 'GB_TRADE_UNION_INFO') for a
 * given Union type organization.This function return p_union_recalculation_date
 * as a date field. This function will now be used for all Union elements created
 * using the deducation template.
 *=======================================================================*/

--
Function get_uk_union_orginfo_fnddate
           (p_union_organization_id     IN   NUMBER
           ,p_union_rates_table_id      OUT NOCOPY  NUMBER
           ,p_union_rates_table_name    OUT NOCOPY  VARCHAR2
           ,p_union_rates_table_type    OUT NOCOPY  VARCHAR2
           ,p_union_recalculation_date  OUT NOCOPY  date --Returned fnd_canonical_date
           ,p_ERROR_MESSAGE             OUT NOCOPY  VARCHAR2
           )
   Return Number
Is
   l_proc     VARCHAR2(61):= g_proc||'get_uk_union_org_info';
   l_ret_vlu     NUMBER(2):= 0;

   Cursor Csr_Get_Union_Org_Info Is
   Select To_Number(hoi.org_information1) -- Rates Table ID
         ,tbls.user_table_name            -- Rates Table Name
         ,tbls.range_or_match             -- Rates Table Type 'R' or 'M'
         ,-- Recalculation Date
          DECODE( -- Compare the recalculation month to the effective month
                 SIGN(  -- By checking the difference between
                      (
                       TO_CHAR(fnd_date.canonical_to_date(hoi.org_information2),'MM')
                        -1
                      )  -- The month of the recalculation date less 1
                     -
                      (
                       TO_CHAR(fnds.effective_date,'MM')
                      )  -- The month of the current effective date
                     )
                ,-1      -- Recalculation month < than current month
                   , TO_CHAR(fnds.effective_date,'YYYY') -- use current year
                         -- Recalculation month >= than current month
                ,TO_CHAR(fnds.effective_date-365,'YYYY') -- use previous year
                )
           ||'/'||to_char(fnd_date.canonical_to_date(hoi.org_information2),'MM/DD')
   FROM   hr_organization_information hoi
         ,pay_user_tables tbls
         ,fnd_sessions fnds
   WHERE  hoi.organization_id = p_union_organization_id
     AND  hoi.org_information_context = g_union_org_info_type
     AND  tbls.user_table_id = TO_NUMBER(hoi.org_information1)
     AND  fnds.session_id = USERENV('sessionid');

l_recalculation_date varchar(15);

BEGIN


  hr_utility.set_location(' Entering: '||l_proc, 10);

  OPEN csr_get_union_org_info;

  FETCH csr_get_union_org_info
   INTO p_union_rates_table_id
       ,p_union_rates_table_name
       ,p_union_rates_table_type
       ,l_recalculation_date;

  p_union_recalculation_date := to_date(l_recalculation_date,'YYYY/MM/DD');

  IF csr_get_union_org_info%NOTFOUND THEN

     l_ret_vlu := -1;
     p_ERROR_MESSAGE :=
'You must complete all the details for your trade union organization '||
'before you run this payroll';

  END IF;

  CLOSE csr_get_union_org_info;
  hr_utility.set_location('Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;


-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);

           p_union_rates_table_id      := NULL;
           p_union_rates_table_name    := NULL;
           p_union_rates_table_type    := NULL;
           p_union_recalculation_date  := NULL;
           p_ERROR_MESSAGE             := SQLERRM;

       raise;


END get_uk_union_orginfo_fnddate;


FUNCTION chk_uk_union_fund_selected
          (p_union_rates_column_name IN   VARCHAR2
          ,p_union_rates_table_name  IN   VARCHAR2
          ,p_ERROR_MESSAGE           IN OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER
IS

   l_proc     VARCHAR2(61):= g_proc||'chk_uk_union_fund_selected';
   l_ret_vlu     NUMBER(2):= 0;

   -- nocopy changes
   l_error_message_nc     VARCHAR2(200);

  CURSOR csr_uk_union_fund_selected IS
  SELECT NULL
  FROM   pay_user_columns cols
        ,pay_user_tables  tbls
  WHERE  tbls.user_table_name =  p_union_rates_table_name
    AND  tbls.user_table_id = cols.user_table_id
    AND  cols.user_column_name = p_union_rates_column_name;

BEGIN

  hr_utility.set_location(' Entering: '||l_proc, 10);

  l_error_message_nc := p_error_message;

  OPEN csr_uk_union_fund_selected;

  FETCH csr_uk_union_fund_selected
   INTO p_ERROR_MESSAGE;

  IF csr_uk_union_fund_selected%NOTFOUND THEN

     l_ret_vlu := -1;
--     p_ERROR_MESSAGE := 'Invalid input value for Fund_Selected.';
       p_ERROR_MESSAGE :=
'Recreate the selected union fund taking care to use the original name. '||
'You must also recreate the Union Rates table for this fund '||
'with separate columns for Union Fund Weekly and Union Fund Monthly.';

  END IF;

  CLOSE csr_uk_union_fund_selected;
  hr_utility.set_location('Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
       p_error_message := l_error_message_nc;
       raise;

END chk_uk_union_fund_selected;


FUNCTION get_uk_union_rates_table_row
          (p_union_rates_table_name IN   VARCHAR2
          ,p_union_rates_row_value  OUT NOCOPY   VARCHAR2
          ,p_ERROR_MESSAGE          OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER
IS

   l_proc     VARCHAR2(61):= g_proc||'get_uk_union_rates_table_row';
   l_ret_vlu     NUMBER(2):= 0;


  CURSOR csr_uk_union_rates_table_row IS
  SELECT urws.row_low_range_or_name
  FROM   pay_user_rows_f  urws
        ,pay_user_tables  tbls
        ,fnd_sessions     fnd
  WHERE  tbls.user_table_name = p_union_rates_table_name
    AND  tbls.range_or_match = 'M'
    AND  urws.user_table_id = tbls.user_table_id
    AND  fnd.effective_date BETWEEN urws.effective_start_date
                                AND urws.effective_end_date
    AND  fnd.session_id = USERENV('sessionid');


BEGIN

  hr_utility.set_location(' Entering: '||l_proc, 10);

  OPEN csr_uk_union_rates_table_row;

  FETCH csr_uk_union_rates_table_row
   INTO p_union_rates_row_value;

  IF csr_uk_union_rates_table_row%NOTFOUND THEN

     l_ret_vlu := -1;
     p_ERROR_MESSAGE :=
--   'No rows were found for a given exact match union rates table.';
'Add the values for the flat rate union deductions to the '||
p_union_rates_table_name||' table.';
  ELSE

     /* Fetch one more to check for more than one row */

   FETCH csr_uk_union_rates_table_row
    INTO p_union_rates_row_value;

   IF csr_uk_union_rates_table_row%FOUND THEN

    l_ret_vlu := -1;
    p_ERROR_MESSAGE :=
--ore than one effective row found for a given exact match union rates table.';
'Oracle Payroll cannot detect which flat rate deduction you want to apply. '||
'Edit the '||p_union_rates_table_name||' table so that it '||
'includes a single description of flat rate deductions.';

   END IF;

  END IF;

  CLOSE csr_uk_union_rates_table_row;
  hr_utility.set_location(' Leaving: '||l_proc, 20);

  RETURN l_ret_vlu;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc, 35);
          p_union_rates_row_value  := NULL;
          p_ERROR_MESSAGE          := SQLERRM;
       raise;

END get_uk_union_rates_table_row;


/*============================================================*/

FUNCTION get_uk_union_rates
          (p_bus_group_id            IN   NUMBER   -- Context
          ,p_union_rates_table_name  IN   VARCHAR2
          ,p_union_rates_column_name IN   VARCHAR2
          ,p_union_rates_row_value   IN   VARCHAR2
          ,p_effective_date          IN   DATE
          ,p_Union_Deduction_Value   OUT NOCOPY  NUMBER
          ,p_ERROR_MESSAGE           OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER
IS

l_proc     VARCHAR2(61):= g_proc||'get_uk_union_rates';

BEGIN

hr_utility.set_location(' Entering: '||l_proc, 10);

      p_Union_Deduction_Value := hruserdt.get_table_value
                                 (p_bus_group_id
                                 ,p_union_rates_table_name
                                 ,p_union_rates_column_name
                                 ,p_union_rates_row_value
                                 ,p_effective_date -- Default Sesn Date
                                 );

hr_utility.set_location(' Leaving: '||l_proc, 20);

       RETURN 0;
EXCEPTION

WHEN NO_DATA_FOUND THEN
 p_Union_Deduction_Value := 0;
 p_ERROR_MESSAGE :=
'Add the missing deduction rates to '||p_union_rates_table_name||
' and retry the payroll run.';
 RETURN -1;


WHEN TOO_MANY_ROWS THEN
 p_Union_Deduction_Value := 0;
 p_ERROR_MESSAGE :=
'Oracle Payroll cannot detect which union deduction you want to apply. '||
'If your deductions are based on salary bands, correct any overlapping '||
'bands, repeat your setup of the deductions element and then retry the '||
'payroll run.';
 RETURN -1;


--WHEN OTHERS THEN
-- p_Union_Deduction_Value := 0;
-- hr_utility.set_message('8303','PQP_UNDTEST_RATESFUN_OTHERS');
-- hr_utility.raise_error;

-- Added by tmehra for nocopy changes Feb'03

    WHEN OTHERS THEN

        p_Union_Deduction_Value := NULL;
        p_ERROR_MESSAGE := SQLERRM;

       hr_utility.set_location('Entering excep:'||l_proc, 35);
       raise;

END get_uk_union_rates;

/*============================================================*/

END pqp_uk_union_deduction;

/
