--------------------------------------------------------
--  DDL for Package Body PQH_MGMT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_MGMT_RPT_PKG" AS
/* $Header: pqmgtpkg.pkb 120.2 2006/05/11 14:53:19 nsanghal noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_mgmt_rpt_pkg.';  -- Global package name

-------------------------------------------------------------------------------
FUNCTION get_budget_measurement_type
(
p_unit_of_measure_id    in  number
)
RETURN VARCHAR2
IS
/* This is a private function which returns the Budget Measurement Type for a particular
   Budget Unit */
--
 Cursor csr_budget_measurement_type is
   Select system_type_cd
     From per_shared_types
    Where shared_type_id = p_unit_of_measure_id
     AND  lookup_type = 'BUDGET_MEASUREMENT_TYPE';
--
l_proc        varchar2(72) := g_package||'get_budget_measurement_type';
--
l_budget_measurement_type   per_shared_types.system_type_cd%TYPE;
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Check if the unit of measure exists in per_shared_types
 --
 Open csr_budget_measurement_type;
 --
 Fetch csr_budget_measurement_type into l_budget_measurement_type;
 --
 If csr_budget_measurement_type%notfound then
    --
     Close csr_budget_measurement_type;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BUDGET_UOM');
     APP_EXCEPTION.RAISE_EXCEPTION;
    --
 End if;
 --
 Close csr_budget_measurement_type;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 RETURN l_budget_measurement_type;
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 15);
  RETURN l_budget_measurement_type;
  --
END get_budget_measurement_type;
--
FUNCTION get_currency_cd(p_budget_version_id number) return varchar2 is
l_proc        varchar2(72) := g_package||'get_currency_cd';
l_currency_cd varchar2(30);
cursor csr_bdgt(p_budget_version_id number) is
SELECT pqh_budget.get_currency_cd(bvr.budget_id)   CURRENCY_CODE
FROM    pqh_budget_versions bvr
WHERE   bvr.budget_version_id              = p_budget_version_id;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
      open csr_bdgt(p_budget_version_id);
      fetch csr_bdgt into l_currency_cd;
      close csr_bdgt;
  hr_utility.set_location('Leaving:'||l_proc, 10);
  RETURN l_currency_cd;
end;
---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a position given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_posn_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_posn_bdgt_unit1 IS
SELECT bdt.budget_unit1_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/* changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bdt.position_id                    = p_position_id ;

CURSOR csr_posn_bdgt_unit2 IS
SELECT  bdt.budget_unit2_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/* changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bdt.position_id                    = p_position_id ;


CURSOR csr_posn_bdgt_unit3 IS
SELECT bdt.budget_unit3_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.

pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe */
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bdt.position_id                    = p_position_id ;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  -- get unit1 amt
  OPEN csr_posn_bdgt_unit1;
    FETCH csr_posn_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_posn_bdgt_unit1;
  -- get unit2 amt
  OPEN csr_posn_bdgt_unit2;
    FETCH csr_posn_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_posn_bdgt_unit2;
  -- get unit3 amt
  OPEN csr_posn_bdgt_unit3;
    FETCH csr_posn_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_posn_bdgt_unit3;
  --
  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
  RETURN l_total_amt;
EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_posn_bdgt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_entity_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_job_id                 IN    per_jobs.job_id%TYPE DEFAULT NULL,
 p_grade_id               IN    per_grades.grade_id%TYPE DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE DEFAULT NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for an entity given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_entity_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_job_bdgt_unit1 IS
SELECT bdt.budget_unit1_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_job_id	   = bdt.job_id;

CURSOR csr_job_bdgt_unit2 IS
SELECT bdt.budget_unit2_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/* changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_job_id	   = bdt.job_id;

CURSOR csr_job_bdgt_unit3 IS
SELECT bdt.budget_unit3_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_job_id	   = bdt.job_id;

CURSOR csr_grade_bdgt_unit1 IS
SELECT bdt.budget_unit1_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_grade_id	   = bdt.grade_id;

CURSOR csr_grade_bdgt_unit2 IS
SELECT  bdt.budget_unit2_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_grade_id	   = bdt.grade_id;

CURSOR csr_grade_bdgt_unit3 IS
SELECT bdt.budget_unit3_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.

  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_grade_id	   = bdt.grade_id;

CURSOR csr_org_bdgt_unit1 IS
SELECT  bdt.budget_unit1_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.

pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_organization_id	   = bdt.organization_id;

CURSOR csr_org_bdgt_unit2 IS
SELECT bdt.budget_unit2_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.

  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_organization_id	   = bdt.organization_id;

CURSOR csr_org_bdgt_unit3 IS
SELECT bdt.budget_unit3_value
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe
*/
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
/*changed for bug#3784023. Now budgeted values will be reported from budget details.
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
*/
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   p_organization_id	   = bdt.organization_id;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  if p_budgeted_entity_cd = 'JOB' then
    -- get unit1 amt
    OPEN csr_job_bdgt_unit1;
      FETCH csr_job_bdgt_unit1 INTO l_unit1_amt;
    CLOSE csr_job_bdgt_unit1;
    -- get unit2 amt
    OPEN csr_job_bdgt_unit2;
      FETCH csr_job_bdgt_unit2 INTO l_unit2_amt;
    CLOSE csr_job_bdgt_unit2;
    -- get unit3 amt
    OPEN csr_job_bdgt_unit3;
      FETCH csr_job_bdgt_unit3 INTO l_unit3_amt;
    CLOSE csr_job_bdgt_unit3;
  elsif p_budgeted_entity_cd = 'GRADE' then
    -- get unit1 amt
    OPEN csr_grade_bdgt_unit1;
      FETCH csr_grade_bdgt_unit1 INTO l_unit1_amt;
    CLOSE csr_grade_bdgt_unit1;
    -- get unit2 amt
    OPEN csr_grade_bdgt_unit2;
      FETCH csr_grade_bdgt_unit2 INTO l_unit2_amt;
    CLOSE csr_grade_bdgt_unit2;
    -- get unit3 amt
    OPEN csr_grade_bdgt_unit3;
      FETCH csr_grade_bdgt_unit3 INTO l_unit3_amt;
    CLOSE csr_grade_bdgt_unit3;
  elsif p_budgeted_entity_cd = 'ORGANIZATION' then
    -- get unit1 amt
    OPEN csr_org_bdgt_unit1;
      FETCH csr_org_bdgt_unit1 INTO l_unit1_amt;
    CLOSE csr_org_bdgt_unit1;
    -- get unit2 amt
    OPEN csr_org_bdgt_unit2;
      FETCH csr_org_bdgt_unit2 INTO l_unit2_amt;
    CLOSE csr_org_bdgt_unit2;
    -- get unit3 amt
    OPEN csr_org_bdgt_unit3;
      FETCH csr_org_bdgt_unit3 INTO l_unit3_amt;
    CLOSE csr_org_bdgt_unit3;
  end if;


  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_entity_bdgt;
--
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_element_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a position given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_posn_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_posn_bdgt_unit1 IS
SELECT
 SUM(bst.budget_unit1_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.position_id                    = p_position_id ;

CURSOR csr_posn_bdgt_unit2 IS
SELECT
 SUM(bst.budget_unit2_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd	    	   = 'POSITION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.position_id                    = p_position_id ;

CURSOR csr_posn_bdgt_unit3 IS
SELECT
 SUM(bst.budget_unit3_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.position_id                    = p_position_id ;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  -- get unit1 amt
  OPEN csr_posn_bdgt_unit1;
    FETCH csr_posn_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_posn_bdgt_unit1;
  -- get unit2 amt
  OPEN csr_posn_bdgt_unit2;
    FETCH csr_posn_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_posn_bdgt_unit2;
  -- get unit3 amt
  OPEN csr_posn_bdgt_unit3;
    FETCH csr_posn_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_posn_bdgt_unit3;
  --
  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
  RETURN l_total_amt;
EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_posn_element_bdgt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_bset_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budget_set_id          IN    pqh_budget_sets.dflt_budget_set_id%TYPE,
  p_start_date            IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a position given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_posn_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_posn_bdgt_unit1 IS
SELECT
 SUM(bst.budget_unit1_value)
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bst.dflt_budget_set_id             = p_budget_set_id
  AND   bdt.position_id                    = p_position_id ;

CURSOR csr_posn_bdgt_unit2 IS
SELECT
 SUM(bst.budget_unit2_value )
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bst.dflt_budget_set_id             = p_budget_set_id
  AND   bdt.position_id                    = p_position_id ;

CURSOR csr_posn_bdgt_unit3 IS
SELECT
 SUM(bst.budget_unit3_value)
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst
WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id                = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		       = 'POSITION'
  AND   bst.dflt_budget_set_id             = p_budget_set_id
  AND   bdt.position_id                    = p_position_id ;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  -- get unit1 amt
  OPEN csr_posn_bdgt_unit1;
    FETCH csr_posn_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_posn_bdgt_unit1;
  -- get unit2 amt
  OPEN csr_posn_bdgt_unit2;
    FETCH csr_posn_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_posn_bdgt_unit2;
  -- get unit3 amt
  OPEN csr_posn_bdgt_unit3;
    FETCH csr_posn_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_posn_bdgt_unit3;
  --
  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
  RETURN l_total_amt;
EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_posn_bset_bdgt;
--
--
--
FUNCTION get_position_bdgt_ver_values
(
 p_budget_version_id      IN    number,
 p_budget_id              IN    number,
 p_position_id            IN    number,
 p_start_date             IN    date,
 p_end_date               IN    date,
 p_unit_of_measure_id     IN    number,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    varchar2,
 p_budget_set_id          IN    number,
 p_element_type_id        IN    number,
 p_summarize_by           IN    varchar2,
 p_budgeted_or_cmmt       IN    varchar2
)
RETURN  NUMBER IS
l_curr_ver_tot number := 0;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;

BEGIN
 IF (p_summarize_by in ('BUDGET', 'ELEMENT')) THEN
   --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   --
   if (( l_budget_measurement_type <> 'MONEY') OR
          ( l_budget_measurement_type = 'MONEY' and
            nvl(p_currency_code,'X')  = nvl(pqh_budget.get_currency_cd(p_budget_id),'X'))) then

      if (p_summarize_by = 'BUDGET' and p_budgeted_or_cmmt = 'BUDGETED') then
        l_curr_ver_tot := get_posn_bdgt
           (
             p_budget_version_id      =>  p_budget_version_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_position_id            =>  p_position_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
      elsif (p_summarize_by = 'BUDGET' and p_budgeted_or_cmmt = 'CMMT') then
        l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
        (
          p_budget_version_id      =>  p_budget_version_id,
          p_position_id            =>  p_position_id,
          p_start_date             =>  p_start_date,
          p_end_date               =>  p_end_date,
          p_unit_of_measure_id     =>  p_unit_of_measure_id,
          p_value_type             =>  p_value_type
        );
      elsif (p_summarize_by = 'ELEMENT' and p_budgeted_or_cmmt = 'BUDGETED') then
        l_curr_ver_tot := get_posn_element_bdgt
           (
             p_budget_version_id      =>  p_budget_version_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_position_id            =>  p_position_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
      end if;
   end if;
 ELSIF (p_summarize_by = 'BSET') THEN
   if (p_budgeted_or_cmmt = 'BUDGETED') then
      l_curr_ver_tot := get_posn_bset_bdgt
           (
             p_budget_version_id      =>  p_budget_version_id,
             p_budget_set_id          =>  p_budget_set_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_position_id            =>  p_position_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
    end if;
 END IF;
 return l_curr_ver_tot;
EXCEPTION
      WHEN OTHERS THEN
         l_curr_ver_tot := 0;
         return l_curr_ver_tot;
END;
---------------------------------------------------------------------------------------------------------
FUNCTION get_position_budgeted_or_cmmt
(
 p_budget_version_id      IN    number  DEFAULT NULL,
 p_position_id            IN    number,
 p_start_date             IN    date,
 p_end_date               IN    date,
 p_unit_of_measure_id     IN    number,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    varchar2 DEFAULT NULL,
 p_budget_set_id          IN    number,
 p_element_type_id        IN    number,
 p_summarize_by           IN    varchar2,
 p_budgeted_or_cmmt       IN    varchar2
)
RETURN  NUMBER IS
l_proc                           varchar2(72) := g_package||'get_position_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_budget_id                      pqh_budget_versions.budget_id%TYPE;
l_business_group_id              number;

cursor csr_bdgt(p_budget_version_id number) is
SELECT bvr.budget_id
FROM    pqh_budget_versions bvr
WHERE   bvr.budget_version_id              = p_budget_version_id;

CURSOR csr_bdgt_positions(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bgt.budget_id
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.position_id                    = p_position_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  if (p_budget_version_id is not null) then
    if (p_summarize_by IN ('BUDGET', 'BSET', 'ELEMENT')) then
      open csr_bdgt(p_budget_version_id);
      fetch csr_bdgt into l_budget_id;
      close csr_bdgt;
      l_curr_ver_tot := get_position_bdgt_ver_values
                     (
          p_budget_version_id      =>  p_budget_version_id,
          p_budget_id              =>  l_budget_id,
          p_position_id            =>  p_position_id,
          p_start_date             =>  p_start_date,
          p_end_date               =>  p_end_date,
          p_unit_of_measure_id     =>  p_unit_of_measure_id,
          p_value_type             =>  p_value_type,
          p_currency_code          =>  p_currency_code,
          p_budget_set_id          =>  p_budget_set_id,
          p_element_type_id        =>  p_element_type_id,
          p_summarize_by           =>  p_summarize_by,
          p_budgeted_or_cmmt       =>  p_budgeted_or_cmmt
                      );
       --
    end if;
    --
    l_total_amt := l_total_amt + l_curr_ver_tot;
    --
  else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
     OPEN csr_bdgt_positions(l_business_group_id);
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id,l_budget_id;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;
       --
       if (p_summarize_by IN ('BUDGET', 'BSET', 'ELEMENT')) then
         l_curr_ver_tot := get_position_bdgt_ver_values
                     (
          p_budget_version_id      =>  l_budget_version_id,
          p_budget_id              =>  l_budget_id,
          p_position_id            =>  p_position_id,
          p_start_date             =>  p_start_date,
          p_end_date               =>  p_end_date,
          p_unit_of_measure_id     =>  p_unit_of_measure_id,
          p_value_type             =>  p_value_type,
          p_currency_code          =>  p_currency_code,
          p_budget_set_id          =>  p_budget_set_id,
          p_element_type_id        =>  p_element_type_id,
          p_summarize_by           =>  p_summarize_by,
          p_budgeted_or_cmmt       =>  p_budgeted_or_cmmt
                      );
         --
       end if;
       --
       l_total_amt := l_total_amt + l_curr_ver_tot;
       --
     END LOOP;
     CLOSE csr_bdgt_positions;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;
EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_position_budgeted_or_cmmt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_position_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER is
/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg. get_pos_actual_and_cmmtmnt as we did not want any errors
  to be returned by the original function.
  This function will return the actual or commitment for a position. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the position is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/
begin
return get_position_budgeted_or_cmmt
(
 p_budget_version_id      =>p_budget_version_id,
 p_position_id            =>p_position_id,
 p_start_date             =>p_start_date,
 p_end_date               =>p_end_date,
 p_unit_of_measure_id     =>p_unit_of_measure_id,
 p_value_type             =>p_value_type,
 p_currency_code          =>p_currency_code,
 p_budget_set_id          =>NULL,
 p_element_type_id        =>NULL,
 p_summarize_by           =>'BUDGET',
 p_budgeted_or_cmmt       =>'CMMT'
);
end;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_entity_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_job_id                 IN    per_jobs.job_id%TYPE DEFAULT NULL,
 p_grade_id               IN    per_grades.grade_id%TYPE DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE DEFAULT NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg. get_ent_actual_and_cmmtmnt.
  This function will return the actual or commitment for an entity. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the entity is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/

l_proc                           varchar2(72) := g_package||'get_entity_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgts_job(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.job_id	   = p_job_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
CURSOR csr_bdgts_grade(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.grade_id	   = p_grade_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
CURSOR csr_bdgts_org(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.organization_id = p_organization_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc_job is
  BEGIN

         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then

	       l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
	       (
		 p_budget_version_id      =>  l_budget_version_id,
		 p_budgeted_entity_cd     =>  p_budgeted_entity_cd,
		 p_entity_id              =>  p_job_id,
		 p_start_date             =>  p_start_date,
		 p_end_date               =>  p_end_date,
		 p_unit_of_measure_id     =>  p_unit_of_measure_id,
		 p_value_type             =>  p_value_type
		);

		l_total_amt := l_total_amt + l_curr_ver_tot;

         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
  procedure proc_grade is
  BEGIN

         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
	       l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
	       (
		 p_budget_version_id      =>  l_budget_version_id,
		 p_budgeted_entity_cd     =>  p_budgeted_entity_cd,
		 p_entity_id              =>  p_grade_id,
		 p_start_date             =>  p_start_date,
		 p_end_date               =>  p_end_date,
		 p_unit_of_measure_id     =>  p_unit_of_measure_id,
		 p_value_type             =>  p_value_type
		);

		l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
  procedure proc_org is
  BEGIN

         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
	       l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
	       (
		 p_budget_version_id      =>  l_budget_version_id,
		 p_budgeted_entity_cd     =>  p_budgeted_entity_cd,
		 p_entity_id              =>  p_organization_id,
		 p_start_date             =>  p_start_date,
		 p_end_date               =>  p_end_date,
		 p_unit_of_measure_id     =>  p_unit_of_measure_id,
		 p_value_type             =>  p_value_type
		);

		l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
  l_business_group_id := hr_general.get_business_group_id;
  if (p_budget_version_id is not null) then
    l_budget_version_id := p_budget_version_id;
    l_currency_code := get_currency_cd(p_budget_version_id);
   If p_budgeted_entity_cd = 'JOB' Then
       proc_job;
   elsif p_budgeted_entity_cd = 'GRADE' Then
       proc_grade;
   elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
       proc_org;
   end if;
  else
     --
   If p_budgeted_entity_cd = 'JOB' Then
   OPEN csr_bdgts_job(l_business_group_id);
     LOOP
       FETCH csr_bdgts_job INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_job%NOTFOUND;
       proc_job;
     END LOOP;
   CLOSE csr_bdgts_job;
   elsif p_budgeted_entity_cd = 'GRADE' Then
   OPEN csr_bdgts_grade(l_business_group_id);
     LOOP
       FETCH csr_bdgts_grade INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_grade%NOTFOUND;
       proc_grade;
     END LOOP;
   CLOSE csr_bdgts_grade;
   elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
   OPEN csr_bdgts_org(l_business_group_id);
     LOOP
       FETCH csr_bdgts_org INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_org%NOTFOUND;
       proc_org;
     END LOOP;
   CLOSE csr_bdgts_org;
   end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_entity_actual_cmmtmnts;
--
--


---------------------------------------------------------------------------------------------------------
FUNCTION  get_assignment_actuals
(
 p_assignment_id              IN number,
 p_element_type_id            IN number  default NULL,
 p_actuals_start_date         IN date,
 p_actuals_end_date           IN date,
 p_unit_of_measure_id         IN number
)
RETURN  NUMBER IS
/*
  This function is a wrapper to pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_actuals
*/
l_proc                           varchar2(72) := g_package||'get_assignment_actuals';
l_total_amt                      NUMBER := 0;
l_last_payroll_date              DATE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  l_total_amt := pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_actuals
   (
     p_assignment_id              => p_assignment_id,
     p_element_type_id            => p_element_type_id,
     p_actuals_start_date         => p_actuals_start_date,
     p_actuals_end_date           => p_actuals_end_date,
     p_unit_of_measure_id         => p_unit_of_measure_id,
     p_last_payroll_dt            => l_last_payroll_date
   );

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_assignment_actuals;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION  get_assignment_commitment
(
 p_assignment_id              IN number,
 p_budget_version_id          IN number default NULL,
 p_period_start_date          IN  date,
 p_period_end_date            IN  date,
 p_unit_of_measure_id         IN  number
)
RETURN NUMBER IS
/*
  This function is a wrapper to pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_commitment
*/
l_proc                           varchar2(72) := g_package||'get_assignment_commitment';
l_total_amt                      NUMBER := 0;
l_last_payroll_date              DATE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  l_total_amt := pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_commitment
   (
     p_assignment_id              => p_assignment_id,
     p_budget_version_id          => p_budget_version_id,
     p_period_start_date          => p_period_start_date,
     p_period_end_date            => p_period_end_date,
     p_unit_of_measure_id         => p_unit_of_measure_id
   );



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_assignment_commitment;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_position_budget_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
  This function will return the budgeted amt for a position. If the budget version is
  specified then it would return the budgeted amt  for that budget version. If no budget version is
  specified the it would return the budgeted amt for all the budget versions where the position is
  budgeted between the start date and end date.
*/
BEGIN
return get_position_budgeted_or_cmmt
(
 p_budget_version_id      =>p_budget_version_id,
 p_position_id            =>p_position_id,
 p_start_date             =>p_start_date,
 p_end_date               =>p_end_date,
 p_unit_of_measure_id     =>p_unit_of_measure_id,
 p_currency_code          =>p_currency_code,
 p_budget_set_id          =>NULL,
 p_element_type_id        =>NULL,
 p_summarize_by           =>'BUDGET',
 p_budgeted_or_cmmt       =>'BUDGETED'
);
END get_position_budget_amt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_entity_budget_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_job_id                 IN    per_jobs.job_id%TYPE DEFAULT NULL,
 p_grade_id               IN    per_grades.grade_id%TYPE DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE DEFAULT NULL,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
  This function will return the budgeted amt for an entity. If the budget version is
  specified then it would return the budgeted amt  for that budget version. If no budget version is
  specified the it would return the budgeted amt for all the budget versions where the entity is
  budgeted between the start date and end date.
*/

l_proc                           varchar2(72) := g_package||'get_entity_budget_amt';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgts_job(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.job_id	   = p_job_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

CURSOR csr_bdgts_grade(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.grade_id	   = p_grade_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

CURSOR csr_bdgts_org(p_business_group_id number) IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = p_budgeted_entity_cd
  AND   bdt.organization_id	   = p_organization_id
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

  procedure proc1 is
  begin
       if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := get_entity_bdgt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  p_budgeted_entity_cd,
	         p_job_id                 =>  p_job_id,
    	     p_grade_id               =>  p_grade_id,
	         p_organization_id        =>  p_organization_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
           l_total_amt := l_total_amt + l_curr_ver_tot;
       end if;
  end;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
  if (p_budget_version_id is not null) then
    l_budget_version_id := p_budget_version_id;
    l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
  else
   l_business_group_id := hr_general.get_business_group_id;
   If p_budgeted_entity_cd = 'JOB' Then
   OPEN csr_bdgts_job(l_business_group_id);
     LOOP
       FETCH csr_bdgts_job INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_job%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgts_job;
   elsif p_budgeted_entity_cd = 'GRADE' Then
   OPEN csr_bdgts_grade(l_business_group_id);
     LOOP
       FETCH csr_bdgts_grade INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_grade%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgts_grade;
   elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
   OPEN csr_bdgts_org(l_business_group_id);
     LOOP
       FETCH csr_bdgts_org INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgts_org%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgts_org;
   end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_entity_budget_amt;
--
--


---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
BEGIN
return get_position_budgeted_or_cmmt
(
 p_budget_version_id      =>p_budget_version_id,
 p_position_id            =>p_position_id,
 p_start_date             =>p_start_date,
 p_end_date               =>p_end_date,
 p_unit_of_measure_id     =>p_unit_of_measure_id,
 p_value_type             =>null,
 p_currency_code          =>p_currency_code,
 p_budget_set_id          =>null,
 p_element_type_id        =>p_element_type_id,
 p_summarize_by           =>'ELEMENT',
 p_budgeted_or_cmmt       =>'BUDGETED'
);
END get_posn_element_bdgt_amt;
--
--
--
FUNCTION get_job_element_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_job_id                 IN    per_jobs.job_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a job given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_job_element_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_job_bdgt_unit1 IS
SELECT
 SUM(bst.budget_unit1_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel

WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.job_id                         = p_job_id ;

CURSOR csr_job_bdgt_unit2 IS
SELECT
 SUM(bst.budget_unit2_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.job_id                         = p_job_id ;


CURSOR csr_job_bdgt_unit3 IS
SELECT
 SUM(bst.budget_unit3_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.job_id                         = p_job_id ;



BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  -- get unit1 amt
  OPEN csr_job_bdgt_unit1;
    FETCH csr_job_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_job_bdgt_unit1;

  -- get unit2 amt
  OPEN csr_job_bdgt_unit2;
    FETCH csr_job_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_job_bdgt_unit2;

  -- get unit3 amt
  OPEN csr_job_bdgt_unit3;
    FETCH csr_job_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_job_bdgt_unit3;


  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_job_element_bdgt;
--
-- This function picks the budget version and currency in which the passed job exists and
-- calls another function which calculates the budgeted amount.
--
FUNCTION get_job_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_job_id            	  IN    per_jobs.job_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
l_proc                           varchar2(72) := g_package||'get_job_element_bdgt_amt';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_jobs IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.job_id                         = p_job_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  begin
       if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code ,'X'))) then
           l_curr_ver_tot := get_job_element_bdgt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_job_id                 =>  p_job_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
            l_total_amt := l_total_amt + l_curr_ver_tot;
       end if;
  end;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_jobs;
     LOOP
       FETCH csr_bdgt_jobs INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_jobs%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_jobs;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_job_element_bdgt_amt;
--
--
--
FUNCTION get_grde_element_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_grade_id               IN    per_grades.grade_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a grade given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_grde_element_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_grade_bdgt_unit1 IS
SELECT
 SUM(bst.budget_unit1_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel

WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.grade_id                       = p_grade_id ;

CURSOR csr_grade_bdgt_unit2 IS
SELECT
 SUM(bst.budget_unit2_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.grade_id                       = p_grade_id ;


CURSOR csr_grade_bdgt_unit3 IS
SELECT
 SUM(bst.budget_unit3_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.grade_id                       = p_grade_id ;



BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  -- get unit1 amt
  OPEN csr_grade_bdgt_unit1;
    FETCH csr_grade_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_grade_bdgt_unit1;

  -- get unit2 amt
  OPEN csr_grade_bdgt_unit2;
    FETCH csr_grade_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_grade_bdgt_unit2;

  -- get unit3 amt
  OPEN csr_grade_bdgt_unit3;
    FETCH csr_grade_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_grade_bdgt_unit3;


  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_grde_element_bdgt;
--
-- This function picks the budget version and currency in which the passed grade exists and
-- calls another function which calculates the budgeted amount.
--
FUNCTION get_grde_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_grade_id            	  IN    per_grades.grade_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
*/

l_proc                           varchar2(72) := g_package||'get_grde_element_bdgt_amt';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_grades IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.grade_id                       = p_grade_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  begin
       if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := get_grde_element_bdgt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_grade_id               =>  p_grade_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
           l_total_amt := l_total_amt + l_curr_ver_tot;
       end if;
  end;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_grades;
     LOOP
       FETCH csr_bdgt_grades INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_grades%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_grades;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_grde_element_bdgt_amt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_orgn_element_bdgt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
/*
  This is a private function which will get the budgeted amount for a organization given a
  budget_version_id and unit_of_measure_id
*/
l_proc                           varchar2(72) := g_package||'get_grde_element_bdgt';
l_total_amt                      NUMBER := 0;
l_unit1_amt                      NUMBER := 0;
l_unit2_amt                      NUMBER := 0;
l_unit3_amt                      NUMBER := 0;

CURSOR csr_orgn_bdgt_unit1 IS
SELECT
 SUM(bst.budget_unit1_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel

WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit1_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.organization_id                = p_organization_id ;

CURSOR csr_orgn_bdgt_unit2 IS
SELECT
 SUM(bst.budget_unit2_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit2_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.organization_id                = p_organization_id ;


CURSOR csr_orgn_bdgt_unit3 IS
SELECT
 SUM(bst.budget_unit3_value * NVL(bel.distribution_percentage/100,0))
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
per_time_periods                            ptps,
per_time_periods                            ptpe,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel


WHERE
        bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   ptps.time_period_id                = bpr.start_time_period_id
  AND   ptpe.time_period_id                = bpr.end_time_period_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND ( ptps.start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN ptps.start_date AND ptpe.end_date )
  AND   bvr.budget_version_id              = p_budget_version_id
  AND   bgt.budget_unit3_id        = p_unit_of_measure_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   bel.element_type_id                = p_element_type_id
  AND   bdt.organization_id                = p_organization_id ;



BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  -- get unit1 amt
  OPEN csr_orgn_bdgt_unit1;
    FETCH csr_orgn_bdgt_unit1 INTO l_unit1_amt;
  CLOSE csr_orgn_bdgt_unit1;

  -- get unit2 amt
  OPEN csr_orgn_bdgt_unit2;
    FETCH csr_orgn_bdgt_unit2 INTO l_unit2_amt;
  CLOSE csr_orgn_bdgt_unit2;

  -- get unit3 amt
  OPEN csr_orgn_bdgt_unit3;
    FETCH csr_orgn_bdgt_unit3 INTO l_unit3_amt;
  CLOSE csr_orgn_bdgt_unit3;


  l_total_amt := NVL(l_unit1_amt,0) + NVL(l_unit2_amt,0) + NVL(l_unit3_amt,0);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_orgn_element_bdgt;
--
-- This function picks the budget version and currency in which the passed grade exists and
-- calls another function which calculates the budgeted amount.
--
FUNCTION get_orgn_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
l_proc                           varchar2(72) := g_package||'get_orgn_element_bdgt_amt';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_orgs IS
SELECT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.organization_id                = p_organization_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
       if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := get_orgn_element_bdgt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_organization_id        =>  p_organization_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );
           l_total_amt := l_total_amt + l_curr_ver_tot;
       end if;
  end;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_orgs;
     LOOP
       FETCH csr_bdgt_orgs INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_orgs%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_orgs;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_orgn_element_bdgt_amt;
/****************************************/

--
--


---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_bset_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_budget_set_id          IN    pqh_budget_sets.dflt_budget_set_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE
)
RETURN  NUMBER IS
BEGIN
return get_position_budgeted_or_cmmt
(
 p_budget_version_id      =>p_budget_version_id,
 p_position_id            =>p_position_id,
 p_start_date             =>p_start_date,
 p_end_date               =>p_end_date,
 p_unit_of_measure_id     =>p_unit_of_measure_id,
 p_value_type             =>null,
 p_currency_code          =>null,
 p_budget_set_id          =>p_budget_set_id,
 p_element_type_id        =>NULL,
 p_summarize_by           =>'BSET',
 p_budgeted_or_cmmt       =>'BUDGETED'
);
END get_posn_bset_bdgt_amt;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt as we did not want any errors
  to be returned by the original function.
  This function will return the actual or commitment for a position. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the position is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/

l_proc                           varchar2(72) := g_package||'get_posn_elmnt_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.position_id                    = p_position_id
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then

           l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'POSITION',
             p_entity_id              =>  p_position_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_positions;
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_positions;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_posn_elmnt_actual_cmmtmnts;

--
-- JOB
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_job_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_job_id                 IN    per_jobs.job_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt as we did not want any errors
  to be returned by the original function.
  This function will return the actual or commitment for a job. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the job is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/

l_proc                           varchar2(72) := g_package||'get_job_elmnt_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_jobs IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.job_id                         = p_job_id
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'JOB',
             p_entity_id              =>  p_job_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_jobs;
     LOOP
       FETCH csr_bdgt_jobs INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_jobs%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_jobs;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_job_elmnt_actual_cmmtmnts;
--
-- GRADE
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_grde_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_grade_id               IN    per_grades.grade_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt as we did not want any errors
  to be returned by the original function.
  This function will return the actual or commitment for a grade. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the grade is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/

l_proc                           varchar2(72) := g_package||'get_grde_elmnt_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_grades IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.grade_id                       = p_grade_id
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'GRADE',
             p_entity_id              =>  p_grade_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_grades;
     LOOP
       FETCH csr_bdgt_grades INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_grades%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_grades;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_grde_elmnt_actual_cmmtmnts;
--
-- ORGANIZATION
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_orgn_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

/*
  This function is a wrapper on pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt as we did not want any errors
  to be returned by the original function.
  This function will return the actual or commitment for a organization. If the budget version is
  specified then it would return the actual or commitment  for that budget version. If no budget version is
  specified the it would return the actual or commitment  for all the budget versions where the organization is
  budgeted between the start date and end date.
  For Actuals : Value Type is 'A'
  For commitments : Value Type is 'C'
  Default for value type is 'T' which means both actual and commitments us returned
*/

l_proc                           varchar2(72) := g_package||'get_orgn_elmnt_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_orgs IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.organization_id                = p_organization_id
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'ORGANIZATION',
             p_entity_id              =>  p_organization_id,
             p_element_type_id        =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_ver_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_ver_tot := 0;
                l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   if (p_budget_version_id is not null) then
      l_budget_version_id := p_budget_version_id;
      l_currency_code := get_currency_cd(p_budget_version_id);
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
     OPEN csr_bdgt_orgs;
     LOOP
       FETCH csr_bdgt_orgs INTO l_budget_version_id,l_currency_code;
       EXIT WHEN csr_bdgt_orgs%NOTFOUND;
       proc1;
     END LOOP;
     CLOSE csr_bdgt_orgs;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_orgn_elmnt_actual_cmmtmnts;
--
--

---------------------------------------------------------------------------------------------------------
FUNCTION get_posn_bset_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_budget_set_id          IN    pqh_budget_sets.dflt_budget_set_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T'
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_posn_bset_actual_cmmtmnts';
l_total_amt                      NUMBER := 0;
l_curr_ver_tot                   NUMBER := 0;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_element_type_id                pqh_budget_elements.element_type_id%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst
WHERE
        bgt.business_group_id              = NVL(l_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.position_id                    = p_position_id
  AND   bst.dflt_budget_set_id             = p_budget_set_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

CURSOR csr_bgt_elements IS
SELECT element_type_id
FROM pqh_dflt_budget_elements
WHERE dflt_budget_set_id  = p_budget_set_id;

  procedure proc1 is
  BEGIN
               l_curr_ver_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
               (
                 p_budget_version_id      =>  l_budget_version_id,
                 p_position_id            =>  p_position_id,
                 p_element_type_id        =>  l_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type             =>  p_value_type
                );

                l_total_amt := l_total_amt + l_curr_ver_tot;
            EXCEPTION
               WHEN OTHERS THEN
                    l_curr_ver_tot := 0;
                    l_total_amt := l_total_amt + l_curr_ver_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
   if (p_budget_version_id is not null) then
    l_budget_version_id := p_budget_version_id;
    proc1;
   else
     --
     l_business_group_id := hr_general.get_business_group_id;
     --
   OPEN csr_bdgt_positions;
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;
       --
       --
       OPEN csr_bgt_elements;
          LOOP
            FETCH csr_bgt_elements INTO l_element_type_id;
            EXIT WHEN csr_bgt_elements%NOTFOUND;
            proc1;
          END LOOP; -- bgt_elements
        CLOSE csr_bgt_elements;
        --
        --
     END LOOP;
   CLOSE csr_bdgt_positions;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_posn_bset_actual_cmmtmnts;
---------------------------------------------------------------------------------------------------------
FUNCTION get_org_posn_budget_amt
(
 p_organization_id        IN    pqh_budget_details.organization_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/
l_proc                           varchar2(72) := g_package||'get_org_posn_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id                             position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.organization_id                = p_organization_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := get_posn_bdgt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_position_id            =>  l_position_id,
             p_unit_of_measure_id     =>  p_unit_of_measure_id
           );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;

        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_positions(l_business_group_id);
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id, l_position_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_positions;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_org_posn_budget_amt;

---------------------------------------------------------------------------------------------------------
FUNCTION get_org_posn_actual_cmmtmnts
(
 p_organization_id        IN    pqh_budget_details.organization_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/

l_proc                           varchar2(72) := g_package||'get_org_posn_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id                             position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bdt.organization_id                = p_organization_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );
  procedure proc1 is
  BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_position_id            =>  l_position_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;

        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
  END;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

   --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_positions(l_business_group_id);
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id, l_position_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;
       proc1;
     END LOOP;
   CLOSE csr_bdgt_positions;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_org_posn_actual_cmmtmnts;

---------------------------------------------------------------------------------------------------------

FUNCTION get_bgrp_posn_budget_amt
(
 p_business_group_id      IN    pqh_budgets.business_group_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                    varchar2(72) := g_package||'get_bgrp_posn_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt               NUMBER := 0;
l_curr_posn_tot           NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;

CURSOR csr_bdgt_positions IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id                             position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                      bgt,
pqh_budget_versions              bvr,
pqh_budget_details               bdt
WHERE bgt.business_group_id      = p_business_group_id
AND   bgt.budget_id              = bvr.budget_id
AND   bvr.budget_version_id      = bdt.budget_version_id
AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
       bgt.budget_unit2_id                = p_unit_of_measure_id or
       bgt.budget_unit3_id                = p_unit_of_measure_id)
AND   bgt.budgeted_entity_cd	 = 'POSITION'
AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
	OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  	hr_utility.set_location('Entering: '||l_proc, 5);
      --
      l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);


	OPEN csr_bdgt_positions;
	LOOP
		FETCH csr_bdgt_positions INTO  l_budget_version_id, l_position_id,l_currency_code;
		EXIT WHEN csr_bdgt_positions%NOTFOUND;

		BEGIN
             if (( l_budget_measurement_type <> 'MONEY') OR
                 ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
                 l_curr_posn_tot := get_posn_bdgt
		 	(
		      p_budget_version_id      =>  l_budget_version_id,
			p_start_date             =>  p_start_date,
			p_end_date               =>  p_end_date,
			p_position_id            =>  l_position_id,
			p_unit_of_measure_id     =>  p_unit_of_measure_id
			);

		  l_total_amt := l_total_amt + l_curr_posn_tot;
             end if;

		EXCEPTION
		WHEN OTHERS THEN
		  l_curr_posn_tot := 0;
		END;
																				  END LOOP;
	CLOSE csr_bdgt_positions;

	hr_utility.set_location('Leaving:'||l_proc, 1000);

	RETURN l_total_amt;

EXCEPTION
WHEN OTHERS THEN
	RETURN 0;
END get_bgrp_posn_budget_amt;
---------------------------------------------------------------------------------------------------------
FUNCTION get_bgrp_posn_actual_cmmtmnts
(
 p_business_group_id      IN    pqh_budgets.business_group_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_bgrp_posn_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;

CURSOR csr_bdgt_positions IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id                             position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = p_business_group_id
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);


   OPEN csr_bdgt_positions;
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id, l_position_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;

       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot :=  pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
           (
		 p_budget_version_id      =>  l_budget_version_id,
	       p_position_id            =>  l_position_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );
            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;

        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
        END;

     END LOOP;
   CLOSE csr_bdgt_positions;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END get_bgrp_posn_actual_cmmtmnts;
--
--
---------------------------------------------------------------------------------------------------------
FUNCTION get_elem_posn_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_elem_posn_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_positions(l_business_group_id);
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id, l_position_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := get_posn_element_bdgt_amt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_position_id            =>  l_position_id,
		 p_element_type_id	  =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_currency_code          =>  p_currency_code
           );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_positions;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_posn_budget_amt;

--
-- JOB
--
FUNCTION get_elem_job_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_elem_job_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_job_id                         pqh_budget_details.job_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_jobs(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.job_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_jobs(l_business_group_id);
     LOOP
       FETCH csr_bdgt_jobs INTO l_budget_version_id, l_job_id,l_currency_code;
       EXIT WHEN csr_bdgt_jobs%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := get_job_element_bdgt_amt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_job_id                 =>  l_job_id,
             p_element_type_id	      =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_currency_code          =>  p_currency_code
           );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_jobs;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_job_budget_amt;

---------------------------------------------------------------------------------------------------------
--
-- GRADE
--
FUNCTION get_elem_grde_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_elem_grd_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_grade_id                       pqh_budget_details.grade_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;
CURSOR csr_bdgt_grades(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.grade_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_grades(l_business_group_id);
     LOOP
       FETCH csr_bdgt_grades INTO l_budget_version_id, l_grade_id,l_currency_code;
       EXIT WHEN csr_bdgt_grades%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := get_grde_element_bdgt_amt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_grade_id               =>  l_grade_id,
             p_element_type_id	      =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_currency_code          =>  p_currency_code
           );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_grades;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_grde_budget_amt;
---------------------------
--
-- ORGANIZATION
--
FUNCTION get_elem_orgn_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_proc                           varchar2(72) := g_package||'get_elem_org_budget_amt';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_organization_id                pqh_budget_details.organization_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_orgs(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.organization_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_orgs(l_business_group_id);
     LOOP
       FETCH csr_bdgt_orgs INTO l_budget_version_id, l_organization_id,l_currency_code;
       EXIT WHEN csr_bdgt_orgs%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
           l_curr_posn_tot := get_orgn_element_bdgt_amt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_organization_id        =>  l_organization_id,
             p_element_type_id	      =>  p_element_type_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_currency_code          =>  p_currency_code
           );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_orgs;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_orgn_budget_amt;
----------------------------

---------------------------------------------------------------------------------------------------------
FUNCTION get_elem_posn_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/

l_proc                           varchar2(72) := g_package||'get_elem_posn_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_position_id                    pqh_budget_details.position_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_posn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_positions(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.position_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'POSITION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_positions(l_business_group_id);
     LOOP
       FETCH csr_bdgt_positions INTO l_budget_version_id, l_position_id,l_currency_code;
       EXIT WHEN csr_bdgt_positions%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
              l_curr_posn_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'POSITION',
             p_element_type_id        =>  p_element_type_id,   /* Bug Fix 2719170 */
             p_entity_id              =>  l_position_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_posn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_posn_tot := 0;
                l_total_amt := l_total_amt + l_curr_posn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_positions;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_posn_actual_cmmtmnts;

--
-- JOB
--
FUNCTION get_elem_job_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/

l_proc                           varchar2(72) := g_package||'get_elem_job_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_job_id                         pqh_budget_details.job_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_job_tot                   NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_jobs(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.job_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'JOB'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;
   OPEN csr_bdgt_jobs(l_business_group_id);
     LOOP
       FETCH csr_bdgt_jobs INTO l_budget_version_id, l_job_id,l_currency_code;
       EXIT WHEN csr_bdgt_jobs%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
              l_curr_job_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'JOB',
             p_element_type_id        =>  p_element_type_id,   /* Bug Fix 2719170 */
             p_entity_id              =>  l_job_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_job_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_job_tot := 0;
                l_total_amt := l_total_amt + l_curr_job_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_jobs;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_job_actual_cmmtmnts;

--
-- GRADE
--
FUNCTION get_elem_grde_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/

l_proc                           varchar2(72) := g_package||'get_elem_grde_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_grade_id                       pqh_budget_details.grade_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_grade_tot                 NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_grades(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.grade_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'GRADE'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_grades(l_business_group_id);
     LOOP
       FETCH csr_bdgt_grades INTO l_budget_version_id, l_grade_id,l_currency_code;
       EXIT WHEN csr_bdgt_grades%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
              l_curr_grade_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'GRADE',
             p_element_type_id        =>  p_element_type_id,   /* Bug Fix 2719170 */
             p_entity_id              =>  l_grade_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_grade_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_grade_tot := 0;
                l_total_amt := l_total_amt + l_curr_grade_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_grades;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_grde_actual_cmmtmnts;
--
-- ORGANIZATION
--
FUNCTION get_elem_orgn_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS
/*
*/

l_proc                           varchar2(72) := g_package||'get_elem_orgn_actual_cmmtmnts';
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_organization_id                pqh_budget_details.organization_id%TYPE;
l_total_amt                      NUMBER := 0;
l_curr_orgn_tot                  NUMBER := 0;

l_currency_code                  fnd_currencies.currency_code%TYPE;
l_budget_measurement_type        per_shared_types.system_type_cd%TYPE;
l_business_group_id              number;

CURSOR csr_bdgt_orgs(p_business_group_id number) IS
SELECT DISTINCT
bvr.BUDGET_VERSION_ID                       BUDGET_VERSION_ID,
bdt.organization_id,
pqh_budget.get_currency_cd(bgt.budget_id)   CURRENCY_CODE
FROM
pqh_budgets                                 bgt,
pqh_budget_versions                         bvr,
pqh_budget_details                          bdt,
pqh_budget_periods                          bpr,
pqh_budget_sets                             bst,
pqh_budget_elements                         bel
WHERE
        bgt.business_group_id              = NVL(p_business_group_id, bgt.business_group_id )
  AND   bgt.budget_id                      = bvr.budget_id
  AND   bvr.budget_version_id              = bdt.budget_version_id
  AND   bdt.budget_detail_id               = bpr.budget_detail_id
  AND   bpr.budget_period_id               = bst.budget_period_id
  AND   bst.budget_set_id                  = bel.budget_set_id
  AND   (bgt.budget_unit1_id                = p_unit_of_measure_id or
         bgt.budget_unit2_id                = p_unit_of_measure_id or
         bgt.budget_unit3_id                = p_unit_of_measure_id)
  AND   bel.element_type_id                = p_element_type_id
  AND   bgt.budgeted_entity_cd		   = 'ORGANIZATION'
  AND   hr_general.effective_date BETWEEN bvr.date_from AND bvr.date_to
  AND ( bgt.budget_start_date BETWEEN p_start_date AND p_end_date
        OR p_start_date  BETWEEN bgt.budget_start_date AND bgt.budget_end_date );

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
   l_budget_measurement_type := get_budget_measurement_type(p_unit_of_measure_id);
   l_business_group_id := hr_general.get_business_group_id;

   OPEN csr_bdgt_orgs(l_business_group_id);
     LOOP
       FETCH csr_bdgt_orgs INTO l_budget_version_id, l_organization_id,l_currency_code;
       EXIT WHEN csr_bdgt_orgs%NOTFOUND;

       --
       --
       BEGIN
         if (( l_budget_measurement_type <> 'MONEY') OR
             ( l_budget_measurement_type = 'MONEY' and
                 nvl(l_currency_code,'X') = nvl(p_currency_code,'X') )) then
              l_curr_orgn_tot := pqh_bdgt_actual_cmmtmnt_pkg.get_ent_actual_and_cmmtmnt
           (
             p_budget_version_id      =>  l_budget_version_id,
             p_budgeted_entity_cd     =>  'ORGANIZATION',
             p_element_type_id        =>  p_element_type_id,   /* Bug Fix 2719170 */
             p_entity_id              =>  l_organization_id,
             p_start_date             =>  p_start_date,
             p_end_date               =>  p_end_date,
             p_unit_of_measure_id     =>  p_unit_of_measure_id,
             p_value_type             =>  p_value_type
            );

            l_total_amt := l_total_amt + l_curr_orgn_tot;
         end if;
        EXCEPTION
           WHEN OTHERS THEN
                l_curr_orgn_tot := 0;
                l_total_amt := l_total_amt + l_curr_orgn_tot;
        END;
        --
        --

     END LOOP;
   CLOSE csr_bdgt_orgs;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_total_amt;

EXCEPTION
  WHEN OTHERS THEN
    l_total_amt := 0;
    RETURN l_total_amt;
END get_elem_orgn_actual_cmmtmnts;


---------------------------------------------------------------------------------------------------------
FUNCTION get_position_type
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS
/*
  This function will return
  U => Under budgeted Position ( balance less then zero )
  O => Over budgeted Position  ( balance more then zero )
  A => balance is zero
*/
l_proc                           varchar2(72) := g_package||'get_position_type';
l_posn_type                      varchar2(10);
l_budgeted_amt                   NUMBER := 0;
l_actual_amt                     NUMBER := 0;
l_cmmtmnt_amt                    NUMBER := 0;
l_projected_amt                  NUMBER := 0;
l_balance_amt                    NUMBER := 0;
l_shared_type_cd                 per_shared_types.system_type_cd%TYPE;
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  l_budgeted_amt := pqh_mgmt_rpt_pkg.get_position_budget_amt
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Budgeted Amt : '||NVL(l_budgeted_amt,0),10);

  l_actual_amt := pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'A',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Actual Amt : '||NVL(l_actual_amt,0),20);

  l_cmmtmnt_amt := pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'C',
   p_currency_code       => p_currency_code
  );
  hr_utility.set_location('Commitment Amt : '||NVL(l_cmmtmnt_amt,0),30);

  l_shared_type_cd := get_budget_measurement_type(p_unit_of_measure_id);
  IF l_shared_type_cd = 'MONEY' THEN
     l_projected_amt := NVL(l_actual_amt,0) + NVL(l_cmmtmnt_amt,0);
  ELSE
     l_projected_amt := NVL(l_actual_amt,0);
  END IF;

  hr_utility.set_location('Projected Amt : '||NVL(l_projected_amt,0),40);

  l_balance_amt  := NVL(l_budgeted_amt,0) - NVL(l_projected_amt,0);
  hr_utility.set_location('Balance Amt : '||NVL(l_balance_amt,0),50);

  IF NVL(l_balance_amt,0) > 0 THEN
    -- Over budgeted
    l_posn_type := 'O';
  ELSIF NVL(l_balance_amt,0) < 0 THEN
    -- Under Budgeted
    l_posn_type := 'U';
  ELSE
    -- just right
    l_posn_type := 'A';
  END IF;
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  RETURN l_posn_type;
EXCEPTION
  WHEN OTHERS THEN
    l_posn_type := 'A';
    RETURN l_posn_type;
END get_position_type;

---------------------------------------------------------------------------------------------------------
--
--
FUNCTION check_pos_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_position_id            IN    per_positions.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_position_type	        IN	  VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	        IN	  NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS
/*
  This function will return
  U => Under budgeted Position ( balance less then zero )
  O => Over budgeted Position  ( balance more then zero )
  A => balance is zero

*/

l_proc                           varchar2(72) := g_package||'get_position_type';
l_posn_type                      varchar2(10);
l_budgeted_amt                   NUMBER := 0;
l_actual_amt                     NUMBER := 0;
l_cmmtmnt_amt                    NUMBER := 0;
l_projected_amt                  NUMBER := 0;
l_balance_amt                    NUMBER := 0;
l_variance_prcnt		 NUMBER := 0;
l_shared_type_cd                 per_shared_types.system_type_cd%TYPE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  IF p_position_type = 'A' THEN
	RETURN 'A';
  END IF;

  l_budgeted_amt := pqh_mgmt_rpt_pkg.get_position_budget_amt
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Budgeted Amt : '||NVL(l_budgeted_amt,0),10);

  l_actual_amt := pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'A',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Actual Amt : '||NVL(l_actual_amt,0),20);

  l_cmmtmnt_amt := pqh_mgmt_rpt_pkg.get_position_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_position_id         => p_position_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'C',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Commitment Amt : '||NVL(l_cmmtmnt_amt,0),30);

  l_shared_type_cd := get_budget_measurement_type(p_unit_of_measure_id);
  IF l_shared_type_cd = 'MONEY' THEN
     l_projected_amt := NVL(l_actual_amt,0) + NVL(l_cmmtmnt_amt,0);
  ELSE
     l_projected_amt := NVL(l_actual_amt,0);
  END IF;

  hr_utility.set_location('Projected Amt : '||NVL(l_projected_amt,0),40);

  l_balance_amt  := NVL(l_budgeted_amt,0) - NVL(l_projected_amt,0);

  hr_utility.set_location('Balance Amt : '||NVL(l_balance_amt,0),50);

  IF l_budgeted_amt = 0 THEN
	l_variance_prcnt	:= 0;
  ELSE
	l_variance_prcnt	:= ABS(l_balance_amt / l_budgeted_amt * 100) ;
  END IF;

  IF p_position_type = 'E' THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
		RETURN 'E';
	ELSE
		RETURN 'N';
	END IF;
  END IF;

  IF NVL(l_balance_amt,0) > 0 THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
	    -- Over budgeted
	    l_posn_type := 'O';
	ELSE
	    l_posn_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSIF NVL(l_balance_amt,0) < 0 THEN
	IF l_variance_prcnt >=  p_variance_prcnt THEN
	    -- Under Budgeted
	    l_posn_type := 'U';
	ELSE
	    l_posn_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSE
    -- just right
    l_posn_type := 'N';
  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_posn_type;

EXCEPTION
  WHEN OTHERS THEN
    l_posn_type := 'A';
    RETURN l_posn_type;

END check_pos_type_and_variance;

--
-- This function checks whether a job is Under or Over budgeted and returns the type 'U' or 'O' or 'A'
--
FUNCTION check_job_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_job_id            	  IN    per_jobs.job_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_entity_type	  	  IN	VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	  IN	NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS
/*
  This function will return
  U => Under budgeted job ( balance less then zero )
  O => Over budgeted job  ( balance more then zero )
  A => balance is zero

*/

l_proc                           varchar2(72) := g_package||'check_job_type';
l_entity_type                    varchar2(10);
l_budgeted_amt                   NUMBER := 0;
l_actual_amt                     NUMBER := 0;
l_cmmtmnt_amt                    NUMBER := 0;
l_projected_amt                  NUMBER := 0;
l_balance_amt                    NUMBER := 0;
l_variance_prcnt		 NUMBER := 0;
l_shared_type_cd                 Per_Shared_Types.System_Type_Cd%TYPE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  IF p_entity_type = 'A' THEN
	RETURN 'A';
  END IF;

  l_budgeted_amt := pqh_mgmt_rpt_pkg.get_entity_budget_amt
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'JOB',
   p_job_id              => p_job_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Budgeted Amt : '||NVL(l_budgeted_amt,0),10);

  l_actual_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'JOB',
   p_job_id              => p_job_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'A',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Actual Amt : '||NVL(l_actual_amt,0),20);

  l_cmmtmnt_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'JOB',
   p_job_id              => p_job_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'C',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Commitment Amt : '||NVL(l_cmmtmnt_amt,0),30);

  l_shared_type_cd := get_budget_measurement_type(p_unit_of_measure_id);
  IF l_shared_type_cd = 'MONEY' THEN
     l_projected_amt := NVL(l_actual_amt,0) + NVL(l_cmmtmnt_amt,0);
  ELSE
     l_projected_amt := NVL(l_actual_amt,0);
  END IF;

  hr_utility.set_location('Projected Amt : '||NVL(l_projected_amt,0),40);

  l_balance_amt  := NVL(l_budgeted_amt,0) - NVL(l_projected_amt,0);

  hr_utility.set_location('Balance Amt : '||NVL(l_balance_amt,0),50);

  IF l_budgeted_amt = 0 THEN
	l_variance_prcnt	:= 0;
  ELSE
	l_variance_prcnt	:= ABS(l_balance_amt / l_budgeted_amt * 100) ;
  END IF;

  IF p_entity_type = 'E' THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
		RETURN 'E';
	ELSE
		RETURN 'N';
	END IF;
  END IF;

  IF NVL(l_balance_amt,0) > 0 THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
	    -- Over budgeted
	    l_entity_type := 'O';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSIF NVL(l_balance_amt,0) < 0 THEN
	IF l_variance_prcnt >=  p_variance_prcnt THEN
	    -- Under Budgeted
	    l_entity_type := 'U';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSE
    -- just right
    l_entity_type := 'N';
  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_entity_type;

EXCEPTION
  WHEN OTHERS THEN
    l_entity_type := 'A';
    RETURN l_entity_type;

END check_job_type_and_variance;


--
-- This function checks whether a grade is Under or Over budgeted and returns the type 'U' or 'O' or 'A'
--

FUNCTION check_grde_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_grade_id            	  IN    per_grades.grade_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_entity_type	  	  IN	VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	  IN	NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS
/*
  This function will return
  U => Under budgeted grade ( balance less then zero )
  O => Over budgeted grade  ( balance more then zero )
  A => balance is zero

*/

l_proc                           varchar2(72) := g_package||'check_grde_type';
l_entity_type                    varchar2(10);
l_budgeted_amt                   NUMBER := 0;
l_actual_amt                     NUMBER := 0;
l_cmmtmnt_amt                    NUMBER := 0;
l_projected_amt                  NUMBER := 0;
l_balance_amt                    NUMBER := 0;
l_variance_prcnt		 NUMBER := 0;
l_shared_type_cd                 Per_Shared_Types.System_Type_Cd%TYPE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  IF p_entity_type = 'A' THEN
	RETURN 'A';
  END IF;

  l_budgeted_amt := pqh_mgmt_rpt_pkg.get_entity_budget_amt
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'GRADE',
   p_grade_id            => p_grade_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Budgeted Amt : '||NVL(l_budgeted_amt,0),10);

  l_actual_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'GRADE',
   p_grade_id            => p_grade_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'A',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Actual Amt : '||NVL(l_actual_amt,0),20);

  l_cmmtmnt_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'GRADE',
   p_grade_id            => p_grade_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'C',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Commitment Amt : '||NVL(l_cmmtmnt_amt,0),30);

  l_shared_type_cd := get_budget_measurement_type(p_unit_of_measure_id);
  IF l_shared_type_cd = 'MONEY' THEN
     l_projected_amt := NVL(l_actual_amt,0) + NVL(l_cmmtmnt_amt,0);
  ELSE
     l_projected_amt := NVL(l_actual_amt,0);
  END IF;

  hr_utility.set_location('Projected Amt : '||NVL(l_projected_amt,0),40);

  l_balance_amt  := NVL(l_budgeted_amt,0) - NVL(l_projected_amt,0);

  hr_utility.set_location('Balance Amt : '||NVL(l_balance_amt,0),50);

  IF l_budgeted_amt = 0 THEN
	l_variance_prcnt	:= 0;
  ELSE
	l_variance_prcnt	:= ABS(l_balance_amt / l_budgeted_amt * 100) ;
  END IF;

  IF p_entity_type = 'E' THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
		RETURN 'E';
	ELSE
		RETURN 'N';
	END IF;
  END IF;

  IF NVL(l_balance_amt,0) > 0 THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
	    -- Over budgeted
	    l_entity_type := 'O';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSIF NVL(l_balance_amt,0) < 0 THEN
	IF l_variance_prcnt >=  p_variance_prcnt THEN
	    -- Under Budgeted
	    l_entity_type := 'U';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSE
    -- just right
    l_entity_type := 'N';
  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_entity_type;

EXCEPTION
  WHEN OTHERS THEN
    l_entity_type := 'A';
    RETURN l_entity_type;

END check_grde_type_and_variance;

--
-- This function checks whether an organization is Under or Over budgeted and returns the type 'U' or 'O' or 'A'
--
FUNCTION check_orgn_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_organization_id        IN    hr_organization_units.organization_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_entity_type	  	  IN	VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	  IN	NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS
/*
  This function will return
  U => Under budgeted organization ( balance less then zero )
  O => Over budgeted organization  ( balance more then zero )
  A => balance is zero

*/

l_proc                           varchar2(72) := g_package||'check_orgn_type';
l_entity_type                    varchar2(10);
l_budgeted_amt                   NUMBER := 0;
l_actual_amt                     NUMBER := 0;
l_cmmtmnt_amt                    NUMBER := 0;
l_projected_amt                  NUMBER := 0;
l_balance_amt                    NUMBER := 0;
l_variance_prcnt		 NUMBER := 0;
l_shared_type_cd                 per_shared_types.system_type_cd%TYPE;

BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);
  IF p_entity_type = 'A' THEN
	RETURN 'A';
  END IF;

  l_budgeted_amt := pqh_mgmt_rpt_pkg.get_entity_budget_amt
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'ORGANIZATION',
   p_organization_id     => p_organization_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Budgeted Amt : '||NVL(l_budgeted_amt,0),10);

  l_actual_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'ORGANIZATION',
   p_organization_id     => p_organization_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'A',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Actual Amt : '||NVL(l_actual_amt,0),20);

  l_cmmtmnt_amt := pqh_mgmt_rpt_pkg.get_entity_actual_cmmtmnts
  (
   p_budget_version_id   => p_budget_version_id,
   p_budgeted_entity_cd  => 'ORGANIZATION',
   p_organization_id     => p_organization_id,
   p_start_date          => p_start_date,
   p_end_date            => p_end_date,
   p_unit_of_measure_id  => p_unit_of_measure_id,
   p_value_type          => 'C',
   p_currency_code       => p_currency_code
  );

  hr_utility.set_location('Commitment Amt : '||NVL(l_cmmtmnt_amt,0),30);

  l_shared_type_cd := get_budget_measurement_type(p_unit_of_measure_id);
  IF l_shared_type_cd = 'MONEY' THEN
     l_projected_amt := NVL(l_actual_amt,0) + NVL(l_cmmtmnt_amt,0);
  ELSE
     l_projected_amt := NVL(l_actual_amt,0);
  END IF;

  hr_utility.set_location('Projected Amt : '||NVL(l_projected_amt,0),40);

  l_balance_amt  := NVL(l_budgeted_amt,0) - NVL(l_projected_amt,0);

  hr_utility.set_location('Balance Amt : '||NVL(l_balance_amt,0),50);

  IF l_budgeted_amt = 0 THEN
	l_variance_prcnt	:= 0;
  ELSE
	l_variance_prcnt	:= ABS(l_balance_amt / l_budgeted_amt * 100) ;
  END IF;

  IF p_entity_type = 'E' THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
		RETURN 'E';
	ELSE
		RETURN 'N';
	END IF;
  END IF;

  IF NVL(l_balance_amt,0) > 0 THEN
	IF l_variance_prcnt >= p_variance_prcnt THEN
	    -- Over budgeted
	    l_entity_type := 'O';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSIF NVL(l_balance_amt,0) < 0 THEN
	IF l_variance_prcnt >=  p_variance_prcnt THEN
	    -- Under Budgeted
	    l_entity_type := 'U';
	ELSE
	    l_entity_type := 'N';  -- Such records are not to be selected.
	END IF;
  ELSE
    -- just right
    l_entity_type := 'N';
  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_entity_type;

EXCEPTION
  WHEN OTHERS THEN
    l_entity_type := 'A';
    RETURN l_entity_type;

END check_orgn_type_and_variance;

--
-- This function is a wrapper which calls other functions depending on the budgeted entity code.
--
FUNCTION check_ent_type_and_variance
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_entity_type	  	  IN	VARCHAR2 DEFAULT 'Y',
 p_variance_prcnt	  IN	NUMBER DEFAULT 0,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN VARCHAR2 IS

l_entity_type                    varchar2(10);

l_proc        varchar2(72) := g_package||'chk_ent_type';

BEGIN

--hr_utility.set_location('Entering: '||l_proc,1000);

    IF p_budgeted_entity_cd = 'POSITION' THEN

        l_entity_type := check_pos_type_and_variance
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_position_id            =>  p_entity_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_position_type	  =>  p_entity_type,
                 p_variance_prcnt         =>  p_variance_prcnt,
                 p_currency_code          =>  p_currency_code
               );
         RETURN l_entity_type;

    ELSIF p_budgeted_entity_cd = 'JOB' THEN


        l_entity_type := check_job_type_and_variance
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_job_id                 =>  p_entity_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_entity_type	          =>  p_entity_type,
                 p_variance_prcnt         =>  p_variance_prcnt,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'GRADE' THEN

        l_entity_type := check_grde_type_and_variance
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_grade_id               =>  p_entity_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_entity_type	          =>  p_entity_type,
                 p_variance_prcnt         =>  p_variance_prcnt,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN

        l_entity_type := check_orgn_type_and_variance
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_organization_id        =>  p_entity_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_entity_type	          =>  p_entity_type,
                 p_variance_prcnt         =>  p_variance_prcnt,
                 p_currency_code          =>  p_currency_code
               );
    END IF;

  hr_utility.set_location('Leaving: '||l_proc,1000);

  RETURN l_entity_type;

EXCEPTION
  WHEN OTHERS THEN
    l_entity_type := 'A';
    RETURN l_entity_type;

END;

--
-- This is a wrapper function which calls all other functions depending on the budgeted entity code
-- and returns the budgeted amount for an entity and element type
--

FUNCTION get_ent_element_bdgt_amt
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)

RETURN NUMBER IS

l_curr_ent_tot NUMBER :=0;

l_proc        varchar2(72) := g_package||'get_ent_elmt_bdgt_amt';

BEGIN

  hr_utility.set_location('Entering: '||l_proc,1000);

    IF p_budgeted_entity_cd = 'POSITION' THEN

        l_curr_ent_tot := get_posn_element_bdgt_amt
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_position_id            =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'JOB' THEN

        l_curr_ent_tot := get_job_element_bdgt_amt
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_job_id            	  =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'GRADE' THEN

        l_curr_ent_tot := get_grde_element_bdgt_amt
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_grade_id           	  =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN

        l_curr_ent_tot := get_orgn_element_bdgt_amt
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_organization_id        =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    END IF;

  hr_utility.set_location('Leaving: '||l_proc,1000);


RETURN l_curr_ent_tot;

EXCEPTION
    WHEN OTHERS THEN
    l_curr_ent_tot := 0;
    RETURN l_curr_ent_tot;

END get_ent_element_bdgt_amt;
--
-- ENTITY
--
FUNCTION get_ent_elmnt_actual_cmmtmnts
(
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE  DEFAULT NULL,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id              IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_curr_ent_tot NUMBER :=0;
l_proc        varchar2(72) := g_package||'get_ent_elmt_act_cmmt';

BEGIN

  hr_utility.set_location('Entering: '||l_proc,1000);

    IF p_budgeted_entity_cd = 'POSITION' THEN

        l_curr_ent_tot := get_posn_elmnt_actual_cmmtmnts
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_position_id            =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'JOB' THEN

        l_curr_ent_tot := get_job_elmnt_actual_cmmtmnts
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_job_id                 =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'GRADE' THEN

        l_curr_ent_tot := get_grde_elmnt_actual_cmmtmnts
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_grade_id               =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN

        l_curr_ent_tot := get_orgn_elmnt_actual_cmmtmnts
               (
                 p_budget_version_id      =>  p_budget_version_id,
                 p_organization_id        =>  p_entity_id,
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );
    END IF;

  hr_utility.set_location('Leaving: '||l_proc,1000);

RETURN l_curr_ent_tot;

EXCEPTION
    WHEN OTHERS THEN
    l_curr_ent_tot := 0;

    RETURN l_curr_ent_tot;


END get_ent_elmnt_actual_cmmtmnts;

--
-- ENTITY
--
FUNCTION get_elem_ent_budget_amt
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_curr_ent_tot NUMBER :=0;

BEGIN
    IF p_budgeted_entity_cd = 'POSITION' THEN


        l_curr_ent_tot := get_elem_posn_budget_amt
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'JOB' THEN

        l_curr_ent_tot := get_elem_job_budget_amt
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'GRADE' THEN

        l_curr_ent_tot := get_elem_grde_budget_amt
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN

        l_curr_ent_tot := get_elem_orgn_budget_amt
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_currency_code          =>  p_currency_code
               );
    END IF;

RETURN l_curr_ent_tot;

EXCEPTION
    WHEN OTHERS THEN
    l_curr_ent_tot := 0;

    RETURN l_curr_ent_tot;


END get_elem_ent_budget_amt;
--
--
--
FUNCTION get_elem_ent_actual_cmmtmnts
(
 p_element_type_id        IN    pqh_budget_elements.element_type_id%TYPE,
 p_budgeted_entity_cd     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_start_date             IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date               IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id     IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type             IN    varchar2  DEFAULT 'T',
 p_currency_code          IN    fnd_currencies.currency_code%TYPE DEFAULT NULL
)
RETURN  NUMBER IS

l_curr_ent_tot NUMBER :=0;

BEGIN
    IF p_budgeted_entity_cd = 'POSITION' THEN


        l_curr_ent_tot := get_elem_posn_actual_cmmtmnts
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );

    ELSIF p_budgeted_entity_cd = 'JOB' THEN

        l_curr_ent_tot := get_elem_job_actual_cmmtmnts
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );

    ELSIF p_budgeted_entity_cd = 'GRADE' THEN

        l_curr_ent_tot := get_elem_grde_actual_cmmtmnts
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );

    ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN

        l_curr_ent_tot := get_elem_orgn_actual_cmmtmnts
               (
    		 p_element_type_id	  =>  p_element_type_id,
                 p_start_date             =>  p_start_date,
                 p_end_date               =>  p_end_date,
                 p_unit_of_measure_id     =>  p_unit_of_measure_id,
                 p_value_type		  =>  p_value_type,
                 p_currency_code          =>  p_currency_code
               );

    END IF;

RETURN l_curr_ent_tot;

EXCEPTION
    WHEN OTHERS THEN
    l_curr_ent_tot := 0;

RETURN l_curr_ent_tot;

END get_elem_ent_actual_cmmtmnts;
--
--
FUNCTION get_pos_org
(
 p_position_id           IN     hr_all_positions_f.position_id%TYPE
)
RETURN  VARCHAR2 is

Cursor     Cr_Org_name is
 Select    Org.Name Org_name
   from    Hr_all_Positions_F pos, hr_all_organization_units_tl Org
  where    position_id          = p_position_id
    and    org.organization_id  = pos.organization_id
    and    language = userenv('LANG');

l_org_name     hr_all_organization_units_tl.Name%TYPE := NULL;
Begin
If p_position_id is NOT NULL Then
   Open  Cr_Org_Name;
   Fetch Cr_Org_name into l_org_name;
   Close Cr_Org_name;
   Return l_org_name;
End If;
End get_pos_org;
--
--
Function GET_ENTITY_BUDGET_AMT( p_budgeted_entity_cd IN varchar2,
                               p_entity_id IN Number,
                               p_budget_version_id IN Number,
                               p_start_date IN DATE,
                               p_end_date IN DATE,
                               p_unit_of_measure_id IN Number) RETURN NUMBER
IS
l_amt  NUMBER;
BEGIN
  IF p_budgeted_entity_cd = 'POSITION' THEN
    l_amt := get_position_budget_amt(p_budget_version_id => p_budget_version_id,
                            p_position_id => p_entity_id,
                            p_start_date=> p_start_date,
                            p_end_date => p_end_date,
                            p_unit_of_measure_id => p_unit_of_measure_id);
  ELSIF p_budgeted_entity_cd = 'GRADE' THEN
    l_amt := get_entity_budget_amt(p_budget_version_id => p_budget_version_id,
                          p_budgeted_entity_cd => p_budgeted_entity_cd,
                          p_grade_id => p_entity_id,
                          p_start_date => p_start_date,
                          p_end_date => p_end_date,
                          p_unit_of_measure_id => p_unit_of_measure_id);
  ELSIF p_budgeted_entity_cd = 'JOB' THEN
    l_amt := get_entity_budget_amt(p_budget_version_id => p_budget_version_id,
                          p_budgeted_entity_cd => p_budgeted_entity_cd,
                          p_job_id => p_entity_id,
                          p_start_date => p_start_date,
                          p_end_date => p_end_date,
                          p_unit_of_measure_id => p_unit_of_measure_id);
  ELSIF p_budgeted_entity_cd = 'ORGANIZATION' THEN
    l_amt := get_entity_budget_amt(p_budget_version_id => p_budget_version_id,
                          p_budgeted_entity_cd => p_budgeted_entity_cd,
                          p_organization_id => p_entity_id,
                          p_start_date => p_start_date,
                          p_end_date => p_end_date,
                          p_unit_of_measure_id => p_unit_of_measure_id);
  END IF;
  RETURN l_amt;
Exception
  When Others THen
     Return 0;
END GET_ENTITY_BUDGET_AMT;
END pqh_mgmt_rpt_pkg;

/
