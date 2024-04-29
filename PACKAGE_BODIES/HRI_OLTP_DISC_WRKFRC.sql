--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_WRKFRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_WRKFRC" AS
/* $Header: hriodwrk.pkb 115.4 2003/08/04 04:58:59 cbridge noship $ */

---------------------------
-- Package global variables
---------------------------
/* Values for last calc_abv lookup call */
g_bmt_code     VARCHAR2(30);
g_bmt_meaning  VARCHAR2(80);

g_last_bg_id			per_business_groups.business_group_id%type;
g_last_formula_id		ff_formulas_f.formula_id%type;
g_last_formula_name		ff_formulas_f.formula_name%type;

/* Holds value passed to Discoverer when fast formulas do not exist */
g_no_valid_formula		number := to_number(null);
/* Holds value passed to Discoverer when fast formulas do not exist or are not compiled */
g_no_valid_formula_id		number := to_number(null);


/******************************************************************************/
/* Public function to determine the Id of a FastFormula                       */
/******************************************************************************/
FUNCTION get_formula_id(p_business_group_id    IN NUMBER
                       ,p_formula_name         IN VARCHAR2)
             RETURN NUMBER IS

  l_formula_id       ff_formulas_f.formula_id%type := 0;

  CURSOR customer_formula_csr IS
  SELECT formula_id
  FROM ff_formulas_x
  WHERE formula_name = 'BUDGET_' || p_formula_name
  AND business_group_id = p_business_group_id;

  CURSOR template_formula_csr IS
  SELECT formula_id
  FROM ff_formulas_x
  WHERE formula_name = 'TEMPLATE_' || p_formula_name
  AND business_group_id IS NULL;

BEGIN

  IF (p_formula_name IS NULL) OR (p_business_group_id IS NULL) THEN
/* Fast formula depends upon business group and formula name */
    RETURN(0);
  ELSE

    IF (p_formula_name = g_last_formula_name) AND
       (p_business_group_id = g_last_bg_id) THEN
      RETURN(g_last_formula_id);
    ELSE
      OPEN customer_formula_csr;
      FETCH customer_formula_csr INTO l_formula_id;
      IF customer_formula_csr%FOUND THEN
        CLOSE customer_formula_csr;
        g_last_formula_name := p_formula_name;
        g_last_bg_id := p_business_group_id;
        g_last_formula_id := l_formula_id;
        RETURN(l_formula_id);
      ELSE
        CLOSE customer_formula_csr;
        OPEN template_formula_csr;
        FETCH template_formula_csr INTO l_formula_id;
        CLOSE template_formula_csr;
        g_last_formula_name := p_formula_name;
        g_last_bg_id := p_business_group_id;
        g_last_formula_id := l_formula_id;
        RETURN(l_formula_id);
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_formula_id;


/******************************************************************************/
/* Public function to determine the appropriate FastFormula Id to be used for */
/* calculating manpower actuals                                               */
/******************************************************************************/
FUNCTION get_manpower_formula_id(p_business_group_id       IN NUMBER
                                ,p_budget_measurement_code IN VARCHAR2)
              RETURN NUMBER IS

  l_return_value     NUMBER;

BEGIN

  l_return_value := get_formula_id
                       (p_business_group_id => p_business_group_id,
                        p_formula_name => p_budget_measurement_code);

  IF (l_return_value = 0) THEN
    RETURN (g_no_valid_formula_id);
  ELSE
    RETURN l_return_value;
  END IF;

END get_manpower_formula_id;

/******************************************************************************/
/* Public function to calculate manpower actuals for a single assignment      */
/******************************************************************************/
FUNCTION get_ff_actual_value(p_budget_id         IN NUMBER
                            ,p_formula_id        IN NUMBER
                            ,p_grade_id          IN NUMBER DEFAULT NULL
                            ,p_job_id            IN NUMBER DEFAULT NULL
                            ,p_organization_id   IN NUMBER DEFAULT NULL
                            ,p_position_id       IN NUMBER DEFAULT NULL
                            ,p_time_period_id    IN NUMBER)
             RETURN NUMBER IS

  CURSOR budget_csr IS
  SELECT
   b.unit
  ,b.business_group_id
  FROM per_budgets   b
  WHERE b.budget_id = p_budget_id;

  CURSOR time_period_csr IS
  SELECT tp.end_date
  FROM per_time_periods    tp
  WHERE tp.time_period_id	= p_time_period_id;

/* 115.22 - replaced NVL logic with ORs */
/*----------------------------------------------------------------------------*/
/* Bug 2483207 - To fix high cost SQL it was necessary to split out the one   */
/* main cursor into five cursors. Depending on the values of the parameters   */
/* passed in a different cursor is used. The most selective parameter to use  */
/* is p_position_id, so this is checked first, followed by grade, job and     */
/* organization. If all parameters are null, then business group id is used.  */
/* Note that the option of using this index is disabled in the former four    */
/* cursors. This is to prevent an inefficient query plan being used.          */
/*----------------------------------------------------------------------------*/
/* To be accessed if p_position_id is not null */
  CURSOR pos_assignment_csr(
         p_business_group_id	NUMBER
        ,p_grade_id		NUMBER
        ,p_job_id		NUMBER
        ,p_organization_id	NUMBER
        ,p_position_id		NUMBER
        ,p_period_end_date	DATE) is
  SELECT asg.assignment_id
  FROM  per_assignments_f    asg
       ,per_assignment_status_types   ast
  WHERE p_position_id = asg.position_id
  AND (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
  AND (p_job_id IS NULL OR asg.job_id = p_job_id)
  AND (p_grade_id IS NULL OR asg.grade_id = p_grade_id)
  AND asg.business_group_id + 0 = p_business_group_id
  AND asg.assignment_type = 'E'
  AND p_period_end_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status = 'ACTIVE_ASSIGN';

/* If p_position_id is null, then use this if p_grade_id is not null */
  CURSOR grd_assignment_csr(
         p_business_group_id	NUMBER
        ,p_grade_id		NUMBER
        ,p_job_id		NUMBER
        ,p_organization_id	NUMBER
        ,p_period_end_date	DATE) is
  SELECT asg.assignment_id
  FROM  per_assignments_f    asg
       ,per_assignment_status_types   ast
  WHERE (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
  AND (p_job_id IS NULL OR asg.job_id = p_job_id)
  AND p_grade_id = asg.grade_id
  AND asg.business_group_id + 0 = p_business_group_id
  AND asg.assignment_type = 'E'
  AND p_period_end_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status = 'ACTIVE_ASSIGN';

/* If position and grade are null, access this with p_job_id if not null */
  CURSOR job_assignment_csr(
         p_business_group_id	NUMBER
        ,p_job_id		NUMBER
        ,p_organization_id	NUMBER
        ,p_period_end_date	DATE) is
  SELECT asg.assignment_id
  FROM  per_assignments_f    asg
       ,per_assignment_status_types   ast
  WHERE (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
  AND p_job_id = asg.job_id
  AND asg.business_group_id + 0 = p_business_group_id
  AND asg.assignment_type = 'E'
  AND p_period_end_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status = 'ACTIVE_ASSIGN';

/* If position, grade and job are null, use p_organization_id if not null */
  CURSOR org_assignment_csr(
         p_business_group_id	NUMBER
        ,p_organization_id	NUMBER
        ,p_period_end_date	DATE) is
  SELECT asg.assignment_id
  FROM  per_assignments_f    asg
       ,per_assignment_status_types   ast
  WHERE p_organization_id = asg.organization_id
  AND asg.business_group_id + 0 = p_business_group_id
  AND asg.assignment_type = 'E'
  AND p_period_end_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status = 'ACTIVE_ASSIGN';

/* If organization, position, grade and job are null, use p_business_group_id */
  CURSOR bgr_assignment_csr(
         p_business_group_id	NUMBER
        ,p_period_end_date	DATE) is
  SELECT asg.assignment_id
  FROM  per_assignments_f    asg
       ,per_assignment_status_types   ast
  WHERE asg.business_group_id = p_business_group_id
  AND asg.assignment_type = 'E'
  AND p_period_end_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status = 'ACTIVE_ASSIGN';

  l_actuals		NUMBER := 0;
  l_actuals_total       NUMBER := 0;
  l_assignment_id       per_all_assignments_f.assignment_id%type;
  l_budget_type_code    per_budgets.unit%type;
  l_business_group_id   per_budgets.business_group_id%type;
  l_formula_id          ff_formulas_f.formula_id%type;
  l_grade_id            per_budget_elements.grade_id%type;
  l_job_id              per_budget_elements.job_id%type;
  l_organization_id     per_budget_elements.organization_id%type;
  l_period_end_date     per_time_periods.end_date%type;
  l_position_id	        per_budget_elements.position_id%type;

BEGIN

-- Return zero if any of the mandatory input parameters is null
  IF (p_budget_id IS NULL) OR (p_formula_id IS NULL) OR (p_time_period_id IS NULL) THEN
    RETURN 0;
  END IF;

-- Get Budget Type Code and confirm budget exists
  OPEN budget_csr;
  FETCH budget_csr INTO l_budget_type_code, l_business_group_id;
  IF budget_csr%FOUND THEN
    CLOSE budget_csr;
  ELSE
    CLOSE budget_csr;
    RETURN(0);
  END IF;

-- Get End Date of the time period
  OPEN time_period_csr;
  FETCH time_period_csr INTO l_period_end_date;
  IF time_period_csr%FOUND THEN
    CLOSE time_period_csr;
  ELSE
    CLOSE time_period_csr;
    RETURN(0);
  END IF;

/* JRHYDE - 1999/11/05 Bug -
   Call to get_ff_actual_value replaced with call to GetBudgetValue function
   that tests the ABV first then if that does not exist it calls the
   Fast Formula (thus being much quicker than calling the ff for each row) */

-- Sum the budget values for all relevant assignments

/*----------------------------------------------------------------------------*/
/* Bug 2483207 - To fix high cost SQL it was necessary to split out the one   */
/* main cursor into five cursors. Depending on the values of the parameters   */
/* passed in a different cursor is used. The most selective parameter to use  */
/* is p_position_id, so this is checked first, followed by grade, job and     */
/* organization. If all parameters are null, then business group id is used.  */
/* Note that the option of using this index is disabled in the former four    */
/* cursors. This is to prevent an inefficient query plan being used.          */
/*----------------------------------------------------------------------------*/

  IF (p_position_id IS NOT NULL) THEN

    FOR assignment_rec in pos_assignment_csr(
	 l_business_group_id
	,p_grade_id
	,p_job_id
	,p_organization_id
	,p_position_id
	,l_period_end_date) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      l_actuals := HrFastAnswers.GetBudgetValue(
         p_budget_metric_formula_id    => p_formula_id
        ,p_budget_metric               => l_budget_type_code
        ,p_assignment_id               => l_assignment_id
        ,p_effective_date              => l_period_end_date
        ,p_session_date                => sysdate );

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_grade_id IS NOT NULL) THEN

    FOR assignment_rec in grd_assignment_csr(
	 l_business_group_id
	,p_grade_id
	,p_job_id
	,p_organization_id
	,l_period_end_date) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      l_actuals := HrFastAnswers.GetBudgetValue(
         p_budget_metric_formula_id    => p_formula_id
        ,p_budget_metric               => l_budget_type_code
        ,p_assignment_id               => l_assignment_id
        ,p_effective_date              => l_period_end_date
        ,p_session_date                => sysdate );

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_job_id IS NOT NULL) THEN

    FOR assignment_rec in job_assignment_csr(
	 l_business_group_id
	,p_job_id
	,p_organization_id
	,l_period_end_date
	) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      l_actuals := HrFastAnswers.GetBudgetValue(
         p_budget_metric_formula_id    => p_formula_id
        ,p_budget_metric               => l_budget_type_code
        ,p_assignment_id               => l_assignment_id
        ,p_effective_date              => l_period_end_date
        ,p_session_date                => sysdate );

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_organization_id IS NOT NULL) THEN

    FOR assignment_rec in org_assignment_csr(
	 l_business_group_id
	,p_organization_id
	,l_period_end_date) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      l_actuals := HrFastAnswers.GetBudgetValue(
         p_budget_metric_formula_id    => p_formula_id
        ,p_budget_metric               => l_budget_type_code
        ,p_assignment_id               => l_assignment_id
        ,p_effective_date              => l_period_end_date
        ,p_session_date                => sysdate );

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSE

    FOR assignment_rec in bgr_assignment_csr(
	 l_business_group_id
	,l_period_end_date) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      l_actuals := HrFastAnswers.GetBudgetValue(
         p_budget_metric_formula_id    => p_formula_id
        ,p_budget_metric               => l_budget_type_code
        ,p_assignment_id               => l_assignment_id
        ,p_effective_date              => l_period_end_date
        ,p_session_date                => sysdate );

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  END IF;

  RETURN(l_actuals_total);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_ff_actual_value;

/******************************************************************************/
/* Function to get an assignment budget value for an assignment               */
/******************************************************************************/
FUNCTION get_asg_budget_value(p_budget_metric_formula_id  IN NUMBER
                             ,p_budget_metric             IN VARCHAR2
                             ,p_assignment_id             IN NUMBER
                             ,p_effective_date            IN DATE
                             ,p_session_date              IN DATE )
               RETURN NUMBER IS

  l_budget_value    NUMBER;

BEGIN

  l_budget_value := HrFastAnswers.GetBudgetValue
  ( p_budget_metric_formula_id => p_budget_metric_formula_id
  , p_budget_metric            => p_budget_metric
  , p_assignment_id            => p_assignment_id
  , p_effective_date           => p_effective_date
  , p_session_date             => p_session_date );

  RETURN l_budget_value;

EXCEPTION
  WHEN hrfastanswers.ff_not_compiled THEN
    RETURN g_no_valid_formula;

  WHEN hrfastanswers.ff_not_exist THEN
    RETURN g_no_valid_formula;

END get_asg_budget_value;


/******************************************************************************/
/* cbridge, 28/06/2001 , pqh budgets support function for                     */
/* hrfv_workforce_budgets business view                                       */
/* Public function to calculate workforce actuals for a single assignment     */
/* using new PQH budgets schema model                                         */
/* bug enhancement 1317484                                                    */
/******************************************************************************/
FUNCTION get_ff_actual_value_pqh
(p_budget_id            IN NUMBER
,p_business_group_id    IN NUMBER
,p_grade_id             IN NUMBER       DEFAULT NULL
,p_job_id               IN NUMBER       DEFAULT NULL
,p_organization_id      IN NUMBER       DEFAULT NULL
,p_position_id          IN NUMBER       DEFAULT NULL
,p_time_period_id       IN NUMBER
,p_budget_metric        IN VARCHAR2
)
RETURN NUMBER IS

cursor budget_csr is
select  pst1.system_type_cd     unit1_name
      , pst2.system_type_cd     unit2_name
      , pst3.system_type_cd     unit3_name
      , bgt.business_group_id   business_group_id
from    pqh_budgets     bgt
      , per_shared_types_vl pst1
      , per_shared_types_vl pst2
      , per_shared_types_vl pst3
where bgt.budget_id     = p_budget_id
AND   bgt.budget_unit1_id               = pst1.shared_type_id (+)
AND   bgt.budget_unit2_id               = pst2.shared_type_id (+)
AND   bgt.budget_unit3_id               = pst3.shared_type_id (+);

cursor time_period_csr is
select  tp.end_date
from    per_time_periods        tp, pqh_budget_periods bpr
where   bpr.budget_period_id = p_time_period_id
and     tp.time_period_id    = bpr.end_time_period_id;

/* 115.22 - replaced NVL logic with ORs */
/*----------------------------------------------------------------------------*/
/* Bug 2483207 - To fix high cost SQL it was necessary to split out the one   */
/* main cursor into five cursors. Depending on the values of the parameters   */
/* passed in a different cursor is used. The most selective parameter to use  */
/* is p_position_id, so this is checked first, followed by grade, job and     */
/* organization. If all parameters are null, then business group id is used.  */
/* Note that the option of using this index is disabled in the former four    */
/* cursors. This is to prevent an inefficient query plan being used.          */
/*----------------------------------------------------------------------------*/
/* To be used if p_position_id is not null */
cursor pos_assignment_csr(
         p_business_group_id    NUMBER
        ,p_grade_id             NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_position_id          NUMBER
        ,p_period_end_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     p_position_id = asg.position_id
and     (p_job_id IS NULL OR asg.job_id = p_job_id)
and     (p_grade_id IS NULL OR asg.grade_id = p_grade_id)
and     asg.business_group_id + 0 = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_period_end_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_grade_id is not null */
cursor grd_assignment_csr(
         p_business_group_id    NUMBER
        ,p_grade_id             NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_period_end_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     (p_job_id IS NULL OR asg.job_id = p_job_id)
and     p_grade_id = asg.grade_id
and     asg.business_group_id + 0 = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_period_end_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_job_id is not null */
cursor job_assignment_csr(
         p_business_group_id    NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_period_end_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     p_job_id = asg.job_id
and     asg.business_group_id + 0 = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_period_end_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_organization_id is not null */
cursor org_assignment_csr(
         p_business_group_id    NUMBER
        ,p_organization_id      NUMBER
        ,p_period_end_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   p_organization_id = asg.organization_id
and     asg.business_group_id + 0 = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_period_end_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if all parameters are null */
cursor bgr_assignment_csr(
         p_business_group_id    NUMBER
        ,p_period_end_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   asg.business_group_id = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_period_end_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

l_actuals               number := 0;
l_actuals_total         number := 0;
l_assignment_id         per_all_assignments_f.assignment_id%type;
l_budget_type_code1     per_budgets.unit%type;
l_budget_type_code2     per_budgets.unit%type;
l_budget_type_code3     per_budgets.unit%type;
l_business_group_id     per_budgets.business_group_id%type;
l_formula_id            ff_formulas_f.formula_id%type;
l_grade_id              per_budget_elements.grade_id%type;
l_job_id                per_budget_elements.job_id%type;
l_organization_id       per_budget_elements.organization_id%type;
l_period_end_date       per_time_periods.end_date%type;
l_position_id           per_budget_elements.position_id%type;
p_formula_id	        ff_formulas_x.formula_id%type;

BEGIN

-- Return zero if any of the mandatory input parameters is null

p_formula_id := get_manpower_formula_id
                   (p_business_group_id => p_business_group_id
                   , p_budget_measurement_code => p_budget_metric);

if (p_budget_id is null) or (p_formula_id is null) or (p_time_period_id is null) then
  return(0);
else

  -- Get Budget Type Code and confirm budget exists

  open budget_csr;
  fetch budget_csr into
     l_budget_type_code1,l_budget_type_code2,l_budget_type_code3, l_business_group_id;

  if budget_csr%found then

    if (p_budget_metric = l_budget_type_code1) or
       (p_budget_metric = l_budget_type_code2) or
       (p_budget_metric = l_budget_type_code3) then
        close budget_csr;
    else
        close budget_csr;
        return(0);
    end if;

  else
    close budget_csr;
    return(0);
  end if;

  -- Get End Date of the time period

  open time_period_csr;
  fetch time_period_csr into l_period_end_date;
  close time_period_csr;

    -- JRHYDE - 1999/11/05 Bug -
    -- Call to get_ff_actual_value replaced with call to GetBudgetValue function
    -- that tests the ABV first then if that does not exist it calls the
    -- Fast Formula (thus being much quicker than calling the ff for each row)

/*----------------------------------------------------------------------------*/
/* Bug 2483207 - To fix high cost SQL it was necessary to split out the one   */
/* main cursor into five cursors. Depending on the values of the parameters   */
/* passed in a different cursor is used. The most selective parameter to use  */
/* is p_position_id, so this is checked first, followed by grade, job and     */
/* organization. If all parameters are null, then business group id is used.  */
/* Note that the option of using this index is disabled in the former four    */
/* cursors. This is to prevent an inefficient query plan being used.          */
/*----------------------------------------------------------------------------*/

  IF (p_position_id IS NOT NULL) THEN

    FOR assignment_rec IN pos_assignment_csr(
         l_business_group_id
        ,p_grade_id
        ,p_job_id
        ,p_organization_id
        ,p_position_id
        ,l_period_end_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => l_period_end_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_grade_id IS NOT NULL) THEN

    FOR assignment_rec IN grd_assignment_csr(
         l_business_group_id
        ,p_grade_id
        ,p_job_id
        ,p_organization_id
        ,l_period_end_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => l_period_end_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_job_id IS NOT NULL) THEN

    FOR assignment_rec IN job_assignment_csr(
         l_business_group_id
        ,p_job_id
        ,p_organization_id
        ,l_period_end_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => l_period_end_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_organization_id IS NOT NULL) THEN

    FOR assignment_rec IN org_assignment_csr(
         l_business_group_id
        ,p_organization_id
        ,l_period_end_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => l_period_end_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSE

    FOR assignment_rec IN bgr_assignment_csr(
         l_business_group_id
        ,l_period_end_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => l_period_end_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  END IF;

  -- Sum the budget values for all relevant assignments

  return(l_actuals_total);

end if;

EXCEPTION
  when others then
    return(0);

END get_ff_actual_value_pqh;


/******************************************************************************/
/* Function returning the number of direct reports for a person on a date     */
/******************************************************************************/
FUNCTION direct_reports
(p_person_id            IN NUMBER
,p_effective_start_date IN DATE
,p_effective_end_date   IN DATE)
RETURN NUMBER IS
   v_person_id             NUMBER;
   v_effective_start_date  DATE;
   v_effective_end_date    DATE;
   v_direct_reports        NUMBER;
BEGIN
   v_person_id := p_person_id;
   v_effective_start_date := p_effective_start_date;
   v_effective_end_date := p_effective_end_date;

   -- 17-OCT-2001, bug 2052714, fixed to exclude terminated direct reports from the count
   --

   SELECT count(*) INTO v_direct_reports
   FROM   per_all_assignments_f   asg, per_all_people_f peo
   WHERE  asg.supervisor_id = v_person_id
   AND    v_effective_end_date BETWEEN asg.effective_start_date
                               AND     asg.effective_end_date
   AND    asg.person_id = peo.person_id
   AND    v_effective_end_date
      BETWEEN peo.effective_start_date AND peo.effective_end_date
   AND    peo.current_employee_flag = 'Y' ;

  RETURN (v_direct_reports);
END direct_reports;

/******************************************************************************/
/* This function will return the lookup code given the meaning for a lookup   */
/* type of budget measurement type                                            */
/******************************************************************************/
PROCEDURE cache_bmt_code(p_bmt_meaning   IN VARCHAR2) IS

  CURSOR bmt_code_csr IS
  SELECT lookup_code
  FROM hr_standard_lookups
  WHERE lookup_type = 'BUDGET_MEASUREMENT_TYPE'
  AND meaning = p_bmt_meaning;

BEGIN

/* Store new BMT code in global */
  OPEN bmt_code_csr;
  FETCH bmt_code_csr INTO g_bmt_code;
  CLOSE bmt_code_csr;

/* Store meaning for new BMT code in global */
  g_bmt_meaning := p_bmt_meaning;

END cache_bmt_code;

/******************************************************************************/
/* Calculates the ABV given a BMT meaning, business group and assignment      */
/******************************************************************************/
FUNCTION calc_abv_lookup(p_assignment_id     IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_bmt_meaning       IN VARCHAR2,
                         p_effective_date    IN DATE)
          RETURN NUMBER IS

BEGIN

  IF (p_bmt_meaning = g_bmt_meaning) THEN
    null;
  ELSE
    cache_bmt_code(p_bmt_meaning => p_bmt_meaning);
  END IF;

  RETURN (hri_bpl_abv.calc_abv
           (p_assignment_id => p_assignment_id,
            p_business_group_id => p_business_group_id,
            p_budget_type => g_bmt_code,
            p_effective_date => p_effective_date));

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);
END calc_abv_lookup;

/******************************************************************************/
/* Calculates the ABV given a BMT meaning, business group and assignment      */
/******************************************************************************/
FUNCTION calc_abv_lookup(p_assignment_id     IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_bmt_meaning       IN VARCHAR2,
                         p_effective_date    IN DATE,
                         p_primary_flag      IN VARCHAR2)
          RETURN NUMBER IS

BEGIN

  IF (p_bmt_meaning = g_bmt_meaning) THEN
    null;
  ELSE
    cache_bmt_code(p_bmt_meaning => p_bmt_meaning);
  END IF;

  RETURN (hri_bpl_abv.calc_abv
           (p_assignment_id => p_assignment_id,
            p_business_group_id => p_business_group_id,
            p_budget_type => g_bmt_code,
            p_effective_date => p_effective_date,
            p_primary_flag => p_primary_flag));

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);
END calc_abv_lookup;

-- cbridge, 09-JAN-02, new function to return pqh budget
-- actual values for a given budget on an effective_date
FUNCTION get_ff_actual_value_pqh
(p_budget_id            IN NUMBER
,p_business_group_id    IN NUMBER
,p_grade_id             IN NUMBER       DEFAULT NULL
,p_job_id               IN NUMBER       DEFAULT NULL
,p_organization_id      IN NUMBER       DEFAULT NULL
,p_position_id          IN NUMBER       DEFAULT NULL
,p_effective_date       IN DATE
,p_budget_metric        IN VARCHAR2
)
RETURN NUMBER IS

CURSOR budget_csr is
SELECT  pst1.system_type_cd     unit1_name
      , pst2.system_type_cd     unit2_name
      , pst3.system_type_cd     unit3_name
      , bgt.business_group_id   business_group_id
FROM    pqh_budgets     bgt
      , per_shared_types_vl pst1
      , per_shared_types_vl pst2
      , per_shared_types_vl pst3
WHERE bgt.budget_id     = p_budget_id
AND   bgt.budget_unit1_id               = pst1.shared_type_id (+)
AND   bgt.budget_unit2_id               = pst2.shared_type_id (+)
AND   bgt.budget_unit3_id               = pst3.shared_type_id (+);


/* To be used if p_position_id is not null */
cursor pos_assignment_csr(
         p_business_group_id    NUMBER
        ,p_grade_id             NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_position_id          NUMBER
        ,p_effective_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     p_position_id = asg.position_id
and     (p_job_id IS NULL OR asg.job_id = p_job_id)
and     (p_grade_id IS NULL OR asg.grade_id = p_grade_id)
and     asg.business_group_id   = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_effective_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_grade_id is not null */
cursor grd_assignment_csr(
         p_business_group_id    NUMBER
        ,p_grade_id             NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_effective_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     (p_job_id IS NULL OR asg.job_id = p_job_id)
and     p_grade_id = asg.grade_id
and     asg.business_group_id  = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_effective_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_job_id is not null */
cursor job_assignment_csr(
         p_business_group_id    NUMBER
        ,p_job_id               NUMBER
        ,p_organization_id      NUMBER
        ,p_effective_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   (p_organization_id IS NULL OR asg.organization_id = p_organization_id)
and     p_job_id = asg.job_id
and     asg.business_group_id   = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_effective_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if p_organization_id is not null */
cursor org_assignment_csr(
         p_business_group_id    NUMBER
        ,p_organization_id      NUMBER
        ,p_effective_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   p_organization_id = asg.organization_id
and     asg.business_group_id  = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_effective_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

/* To be used if all parameters are null */
cursor bgr_assignment_csr(
         p_business_group_id    NUMBER
        ,p_effective_date      DATE
        ) is
select  asg.assignment_id
from     per_assignments_f              asg
        ,per_assignment_status_types    ast
where   asg.business_group_id = p_business_group_id
and     asg.assignment_type     = 'E'
and     p_effective_date between asg.effective_start_date and
        asg.effective_end_date
and     asg.assignment_status_type_id   = ast.assignment_status_type_id
and     ast.per_system_status           = 'ACTIVE_ASSIGN';

l_actuals               number := 0;
l_actuals_total         number := 0;
l_assignment_id         per_all_assignments_f.assignment_id%type;
l_budget_type_code1     per_budgets.unit%type;
l_budget_type_code2     per_budgets.unit%type;
l_budget_type_code3     per_budgets.unit%type;
l_business_group_id     per_budgets.business_group_id%type;
l_formula_id            ff_formulas_f.formula_id%type;
l_grade_id              per_budget_elements.grade_id%type;
l_job_id                per_budget_elements.job_id%type;
l_organization_id       per_budget_elements.organization_id%type;
l_period_end_date       per_time_periods.end_date%type;
l_position_id           per_budget_elements.position_id%type;
p_formula_id	        ff_formulas_x.formula_id%type;

BEGIN


p_formula_id := get_manpower_formula_id
                   (p_business_group_id => p_business_group_id
                   , p_budget_measurement_code => p_budget_metric);

if (p_budget_id is null) or (p_formula_id is null) or (p_effective_date is null) then
  return(0);
else

  -- Get Budget Type Code and confirm budget exists

  open budget_csr;
  fetch budget_csr into
     l_budget_type_code1,l_budget_type_code2,l_budget_type_code3, l_business_group_id;

  if budget_csr%found then

    if (p_budget_metric = l_budget_type_code1) or
       (p_budget_metric = l_budget_type_code2) or
       (p_budget_metric = l_budget_type_code3) then
        close budget_csr;
    else
        close budget_csr;
        return(0);
    end if;

  else
    close budget_csr;
    return(0);
  end if;

  IF (p_position_id IS NOT NULL) THEN

    FOR assignment_rec IN pos_assignment_csr(
         l_business_group_id
        ,p_grade_id
        ,p_job_id
        ,p_organization_id
        ,p_position_id
        ,p_effective_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => p_effective_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_grade_id IS NOT NULL) THEN

    FOR assignment_rec IN grd_assignment_csr(
         l_business_group_id
        ,p_grade_id
        ,p_job_id
        ,p_organization_id
        ,p_effective_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => p_effective_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_job_id IS NOT NULL) THEN

    FOR assignment_rec IN job_assignment_csr(
         l_business_group_id
        ,p_job_id
        ,p_organization_id
        ,p_effective_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;


      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => p_effective_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSIF (p_organization_id IS NOT NULL) THEN


    FOR assignment_rec IN org_assignment_csr(
         l_business_group_id
        ,p_organization_id
        ,p_effective_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => p_effective_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  ELSE

    FOR assignment_rec IN bgr_assignment_csr(
         l_business_group_id
        ,p_effective_date
        ) LOOP

      l_assignment_id := assignment_rec.assignment_id;

      BEGIN /* cbridge bug 1875197 */
        l_actuals := HrFastAnswers.GetBudgetValue(
           p_budget_metric_formula_id    => p_formula_id
          ,p_budget_metric               => p_budget_metric
          ,p_assignment_id               => l_assignment_id
          ,p_effective_date              => p_effective_date
          ,p_session_date                => sysdate );
       EXCEPTION
          WHEN OTHERS THEN
           -- fast formula not compiled for an assignment that has no abv,
           -- so need to trap exception.
           l_actuals := 0;
       END;

      l_actuals_total := l_actuals_total + l_actuals;

    END LOOP;

  END IF;

  -- Sum the budget values for all relevant assignments

  return(l_actuals_total);

end if;

EXCEPTION
  when others then
    return(0);

END get_ff_actual_value_pqh;

-- returns period of time, in months, of the persons period of service
-- taking into account breaks in service for employee rehires
FUNCTION get_period_service_in_months(p_person_id IN NUMBER
                                     ,p_period_of_service_id IN NUMBER
                                     ,p_effective_date IN DATE) RETURN NUMBER

IS

CURSOR get_pps_months_cur IS
SELECT sum(months_between(least(nvl(actual_termination_date + 1,
       p_effective_date + 1), p_effective_date + 1), date_start)) total_months
FROM  per_periods_of_service
WHERE  person_id             = p_person_id
AND    date_start           <= p_effective_date
AND    period_of_service_id <= p_period_of_service_id;


l_period_service_months NUMBER :=0;

BEGIN

    OPEN  get_pps_months_cur;
    FETCH get_pps_months_cur INTO l_period_service_months;
    CLOSE get_pps_months_cur;

    RETURN (l_period_service_months);

EXCEPTION
     WHEN OTHERS THEN
     BEGIN
         IF get_pps_months_cur%ISOPEN THEN
            CLOSE get_pps_months_cur;
         END IF;
         RETURN (l_period_service_months);
     END; -- exception

END get_period_service_in_months;

-- returns period of time, in years, of the persons period of service
-- taking into account breaks in service for employee rehires
FUNCTION get_period_service_in_years(p_person_id IN NUMBER
                                     ,p_period_of_service_id IN NUMBER
                                     ,p_effective_date IN DATE) RETURN NUMBER

IS

CURSOR get_pps_years_cur IS
SELECT sum(months_between
                (least(nvl(actual_termination_date + 1, p_effective_date + 1),
                   p_effective_date + 1), date_start)) / 12   total_years
FROM  per_periods_of_service
WHERE  person_id             = p_person_id
AND    date_start           <= p_effective_date
AND    period_of_service_id <= p_period_of_service_id;

l_period_service_years NUMBER :=0;

BEGIN

    OPEN  get_pps_years_cur;
    FETCH get_pps_years_cur INTO l_period_service_years;
    CLOSE get_pps_years_cur;

    RETURN (l_period_service_years);

EXCEPTION
     WHEN OTHERS THEN
     BEGIN
         IF get_pps_years_cur%ISOPEN THEN
            CLOSE get_pps_years_cur;
         END IF;
         RETURN (l_period_service_years);
     END; -- exception

END get_period_service_in_years;


END hri_oltp_disc_wrkfrc;

/
