--------------------------------------------------------
--  DDL for Package Body PQH_EFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_EFC" AS
/* $Header: pqefccon.pkb 120.3 2005/09/29 15:44:39 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_efc.';  -- Global package name
--

------------------------------------------------------------------------------------
FUNCTION get_currency_cd
(
 p_primary_key        IN NUMBER,
 p_entity_cd          IN VARCHAR2,
 p_business_group_id  IN NUMBER
) RETURN varchar2 IS

/*
 This function will return the currency code of the budget

*/

l_proc                       varchar2(72) := g_package||'get_currency_cd';

l_currency_cd                varchar2(240);

--
CURSOR csr_bus_grp IS
SELECT currency_code
FROM per_business_groups
WHERE business_group_id = p_business_group_id;
--
--
CURSOR csr_bvr IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = p_primary_key;
--
--
CURSOR csr_bdt IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.budget_detail_id  = p_primary_key;
--
--
CURSOR csr_bpr IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt,
     pqh_budget_periods bpr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.budget_detail_id  = bpr.budget_detail_id
  AND bpr.budget_period_id  = p_primary_key;
--
--
CURSOR csr_bst IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt,
     pqh_budget_periods bpr,
     pqh_budget_sets    bst
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.budget_detail_id  = bpr.budget_detail_id
  AND bpr.budget_period_id  = bst.budget_period_id
  AND bst.budget_set_id  = p_primary_key;
--
--
CURSOR csr_wdt IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND wdt.worksheet_detail_id  = p_primary_key;
--
--
CURSOR csr_wpr IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt,
     pqh_worksheet_periods wpr
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND wdt.worksheet_detail_id = wpr.worksheet_detail_id
  AND wpr.worksheet_period_id  = p_primary_key;
--
--
CURSOR csr_wst IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt,
     pqh_worksheet_periods wpr,
     pqh_worksheet_budget_sets wst
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND wdt.worksheet_detail_id = wpr.worksheet_detail_id
  AND wpr.worksheet_period_id = wst.worksheet_period_id
  AND wst.worksheet_budget_set_id  = p_primary_key;
--
--
CURSOR csr_pec IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_element_commitments pec
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = pec.budget_version_id
  AND pec.element_commitment_id = p_primary_key;
--
--
CURSOR csr_bre IS
SELECT currency_code
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_pools   bpl,
     pqh_bdgt_pool_realloctions bre
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bpl.budget_version_id
  AND bre.pool_id  = bpl.pool_id
  AND bre.reallocation_id = p_primary_key;
--
--
CURSOR csr_rmr IS
SELECT currency_code
FROM pqh_criteria_rate_defn crd,
     pqh_rate_matrix_rates_f rmr
WHERE crd.criteria_rate_defn_id = rmr.criteria_rate_defn_id
  AND rmr.rate_matrix_rate_id = p_primary_key
  and rmr.effective_start_date = (
  Select min(rmr1.effective_start_date)
    From pqh_rate_matrix_rates_f rmr1
   Where rmr1.rate_matrix_rate_id = p_primary_key );
--
CURSOR csr_ssl IS
SELECT currency_code
FROM per_salary_survey_lines ssl
WHERE ssl.salary_survey_line_id = p_primary_key;
--

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

     IF p_entity_cd = 'BVR' THEN
      -- Budget Version Table BVR
       OPEN csr_bvr;
         FETCH csr_bvr INTO l_currency_cd;
       CLOSE csr_bvr;
      --
     ELSIF p_entity_cd = 'BDT' THEN
      -- Budget Details Table BDT
       OPEN csr_bdt;
         FETCH csr_bdt INTO l_currency_cd;
       CLOSE csr_bdt;
      --
     ELSIF p_entity_cd = 'BPR' THEN
      -- Budget Period Table BPR
       OPEN csr_bpr;
         FETCH csr_bpr INTO l_currency_cd;
       CLOSE csr_bpr;
      --
     ELSIF p_entity_cd = 'BST' THEN
      -- Budget Sets Table BST
       OPEN csr_bst;
         FETCH csr_bst INTO l_currency_cd;
       CLOSE csr_bst;
      --
     ELSIF p_entity_cd = 'WDT' THEN
      -- Worksheet Details Table WDT
       OPEN csr_wdt;
         FETCH csr_wdt INTO l_currency_cd;
       CLOSE csr_wdt;
      --
     ELSIF p_entity_cd = 'WPR' THEN
      -- Worksheet Periods Table WPR
       OPEN csr_wpr;
         FETCH csr_wpr INTO l_currency_cd;
       CLOSE csr_wpr;
      --
     ELSIF p_entity_cd = 'WST' THEN
      -- Worksheet Budget Set Table WST
       OPEN csr_wst;
         FETCH csr_wst INTO l_currency_cd;
       CLOSE csr_wst;
      --
     ELSIF p_entity_cd = 'PEC' THEN
      --  pqh_element_commitments PEC
       OPEN csr_pec;
         FETCH csr_pec INTO l_currency_cd;
       CLOSE csr_pec;
      --
     ELSIF p_entity_cd = 'BRE' THEN
      --  pqh_bdgt_pool_realloctions BRE
       OPEN csr_bre;
         FETCH csr_bre INTO l_currency_cd;
       CLOSE csr_bre;
      --
    ELSIF p_entity_cd = 'RMR' THEN
      --  pqh_rate_matrix_rates_f RMR
       OPEN csr_rmr;
         FETCH csr_rmr INTO l_currency_cd;
       CLOSE csr_rmr;
      --
    ELSIF p_entity_cd = 'SSL' THEN
      --  per_salary_survey_lines SSL
       OPEN csr_ssl;
         FETCH csr_ssl INTO l_currency_cd;
       CLOSE csr_ssl;
      --
     END IF;


     IF l_currency_cd IS NULL THEN

       -- get currenct code for the business group
         OPEN csr_bus_grp;
           FETCH csr_bus_grp INTO l_currency_cd;
         CLOSE csr_bus_grp;

     END IF; -- currency for business group

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_currency_cd;

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
    hr_utility.set_message_token('ROUTINE', l_proc);
    hr_utility.set_message_token('REASON', SQLERRM);
    raise ;
END;

------------------------------------------------------------------------------------
--

FUNCTION convert_value
(
 p_primary_key        IN   NUMBER,
 p_entity_cd          IN   VARCHAR2,
 p_business_group_id  IN   NUMBER,
 p_unit_value         IN   NUMBER,
 p_column_no          IN   NUMBER
) RETURN number IS


/*
  This function will return the converted amount
*/

l_proc                       varchar2(72) := g_package||'convert_value';
l_converted_amt              pqh_budget_versions.budget_unit1_value%TYPE;
l_unit1_type                 varchar2(30);
l_unit2_type                 varchar2(30);
l_unit3_type                 varchar2(30);
l_existing_curr_cd           varchar2(150);

--
CURSOR csr_bvr_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = bvr.budget_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND bvr.budget_version_id = p_primary_key ;
--
--
CURSOR csr_bdt_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND bdt.budget_detail_id  = p_primary_key;
--
--
CURSOR csr_bpr_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt,
     pqh_budget_periods bpr,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.budget_detail_id  = bpr.budget_detail_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND bpr.budget_period_id  = p_primary_key;
--
--
CURSOR csr_bst_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_budget_versions bvr,
     pqh_budget_details bdt,
     pqh_budget_periods bpr,
     pqh_budget_sets    bst,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.budget_detail_id  = bpr.budget_detail_id
  AND bpr.budget_period_id  = bst.budget_period_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND bst.budget_set_id  = p_primary_key;
--
--
CURSOR csr_wdt_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND wdt.worksheet_detail_id  = p_primary_key;
--
--
CURSOR csr_wpr_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt,
     pqh_worksheet_periods wpr,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND wdt.worksheet_detail_id = wpr.worksheet_detail_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND wpr.worksheet_period_id  = p_primary_key;
--
--
CURSOR csr_wst_units IS
SELECT pst1.system_type_cd ,
       pst2.system_type_cd ,
       pst3.system_type_cd
FROM pqh_budgets bgt,
     pqh_worksheets wks,
     pqh_worksheet_details wdt,
     pqh_worksheet_periods wpr,
     pqh_worksheet_budget_sets wst,
     per_shared_types_vl pst1 ,
     per_shared_types_vl pst2 ,
     per_shared_types_vl pst3
WHERE bgt.budget_id = wks.budget_id
  AND wks.worksheet_id  = wdt.worksheet_id
  AND wdt.worksheet_detail_id = wpr.worksheet_detail_id
  AND wpr.worksheet_period_id = wst.worksheet_period_id
  AND bgt.budget_unit1_id = pst1.shared_type_id (+)
  AND bgt.budget_unit2_id = pst2.shared_type_id (+)
  AND bgt.budget_unit3_id = pst3.shared_type_id (+)
  AND wst.worksheet_budget_set_id  = p_primary_key;
--
--
--
CURSOR csr_bre_unit IS
SELECT pst1.system_type_cd
FROM pqh_bdgt_pool_realloctions bre,
     pqh_budget_pools bpl,
     per_shared_types_vl pst1
WHERE bre.pool_id = bpl.pool_id
  AND bpl.budget_unit_id = pst1.shared_type_id
  AND bre.reallocation_id  = p_primary_key;
--
--
CURSOR csr_rmr IS
SELECT crd.uom
FROM pqh_criteria_rate_defn crd,
     pqh_rate_matrix_rates_f rmr
WHERE crd.criteria_rate_defn_id = rmr.criteria_rate_defn_id
  AND rmr.rate_matrix_rate_id = p_primary_key
  and rmr.effective_start_date = (
  Select min(rmr1.effective_start_date)
    From pqh_rate_matrix_rates_f rmr1
   Where rmr1.rate_matrix_rate_id = p_primary_key );
--
Cursor csr_ssl is
Select stock_display_type
from per_salary_survey_lines
Where salary_survey_line_id = p_primary_key;
--

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- Get the unit of measure

     IF p_entity_cd = 'BVR' THEN
      -- Budget Version Table BVR
       OPEN csr_bvr_units;
         FETCH csr_bvr_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_bvr_units;
      --
     ELSIF p_entity_cd = 'BDT' THEN
      --
       OPEN csr_bdt_units;
         FETCH csr_bdt_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_bdt_units;
      --
     ELSIF p_entity_cd = 'BPR' THEN
      --
       OPEN csr_bpr_units;
         FETCH csr_bpr_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_bpr_units;
      --
     ELSIF p_entity_cd = 'BST' THEN
      --
       OPEN csr_bst_units;
         FETCH csr_bst_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_bst_units;
      --
     ELSIF p_entity_cd = 'WDT' THEN
      --
       OPEN csr_wdt_units;
         FETCH csr_wdt_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_wdt_units;
      --
     ELSIF p_entity_cd = 'WPR' THEN
      --
       OPEN csr_wpr_units;
         FETCH csr_wpr_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_wpr_units;
      --
     ELSIF p_entity_cd = 'WST' THEN
      --
       OPEN csr_wst_units;
         FETCH csr_wst_units INTO l_unit1_type, l_unit2_type, l_unit3_type ;
       CLOSE csr_wst_units;
      --
     ELSIF p_entity_cd = 'BRE' THEN
      --
       OPEN csr_bre_unit;
         FETCH csr_bre_unit INTO l_unit1_type;
       CLOSE csr_bre_unit;
      --
     ELSIF p_entity_cd = 'RMR' THEN
      --
       OPEN csr_rmr;
         FETCH csr_rmr INTO l_unit1_type;
       CLOSE csr_rmr;
      --
     ELSIF p_entity_cd = 'SSL' THEN
      --
       OPEN csr_ssl;
         FETCH csr_ssl INTO l_unit1_type;
       CLOSE csr_ssl;
      --

     END IF;

  -- Get the currency code

     l_existing_curr_cd :=
      get_currency_cd
     (
      p_primary_key        => p_primary_key,
      p_entity_cd          => p_entity_cd,
      p_business_group_id  => p_business_group_id
     );


  -- check if the value needs to be converted

     IF ( p_column_no = 1 AND l_unit1_type = 'MONEY' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );

     ELSIF ( p_column_no = 1 AND l_unit1_type = 'M' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );

    ELSIF ( p_column_no = 1 AND p_entity_cd = 'SSL' AND l_unit1_type = 'MONEY_VALUE') THEN
        -- convert for stock columns
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );
    ELSIF ( p_column_no = 2 AND p_entity_cd = 'SSL' ) THEN
        -- convert for monetary columns
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );
     ELSIF ( p_column_no = 2 AND l_unit2_type = 'MONEY' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );

     ELSIF ( p_column_no = 3 AND l_unit3_type = 'MONEY' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );
     ELSIF ( p_entity_cd = 'PEC' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );
     ELSIF ( p_entity_cd = 'BRE' AND l_unit1_type = 'MONEY' ) THEN
        -- convert
        l_converted_amt :=
        hr_currency_pkg.convert_amount
        ( p_from_currency    =>  l_existing_curr_cd,
          p_to_currency      =>  'EUR',
          p_conversion_date  =>  sysdate,
          p_amount           =>  NVL(p_unit_value,0),
          p_rate_type        =>  null
        );

     ELSE
        -- don't convert
         l_converted_amt  := p_unit_value;
     END IF;






  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_converted_amt;


EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
    hr_utility.set_message_token('ROUTINE', l_proc);
    hr_utility.set_message_token('REASON', SQLERRM);
    raise ;
END;
--

--


------------------------------------------------------------------------------------



END; -- Package Body PQH_EFC

/
