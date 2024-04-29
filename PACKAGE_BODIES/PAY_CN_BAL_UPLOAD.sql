--------------------------------------------------------
--  DDL for Package Body PAY_CN_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_BAL_UPLOAD" AS
/* $Header: pycnupld.pkb 120.1 2005/12/19 21:36:05 snekkala noship $ */

-- Date constants.
  START_OF_TIME CONSTANT DATE := TO_DATE('01/01/0001','DD/MM/YYYY');
  END_OF_TIME   CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');

--------------------------------------------------------------------------
--                                                                      --
-- Name           : EXPIRY_DATE                                         --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the expiry date for the specified--
--                  balance dimension                                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_upload_date       DATE                            --
--                  p_dimension_name    VARCHAR2                        --
--                  p_assignment_id     NUMBER                          --
--                  p_original_entry_id NUMBER                          --
--            OUT : N/A                                                 --
--         RETURN : Date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-Mar-03  saikrish  Created this function                     --
-- 1.1   19-Jun-03  bramajey  Removed dimensions which are not          --
--                            supported by CN Legislation               --
-- 1.2   08-Jul-03  bramajey  Modified SELECT part of csr_tax_year      --
--                            cursor                                    --
--------------------------------------------------------------------------
FUNCTION expiry_date ( p_upload_date       DATE
                     , p_dimension_name    VARCHAR2
                     , p_assignment_id     NUMBER
                     , p_original_entry_id NUMBER
                     )
RETURN DATE
IS

  -- Returns the start date of the fiscal year.
  CURSOR  csr_fiscal_year ( p_assignment_id NUMBER
                          , p_upload_date   DATE
                          ) IS
  SELECT  NVL(ADD_MONTHS(fnd_date.canonical_to_date(HOI.ORG_INFORMATION11)
                       ,12*(floor(months_between(p_upload_date
                       ,fnd_date.canonical_to_date(HOI.ORG_INFORMATION11))/12)))
	               ,END_OF_TIME)
  FROM    per_assignments_f           ASS
         ,hr_organization_information HOI
  WHERE   ASS.assignment_id                  = p_assignment_id
  AND     p_upload_date BETWEEN ASS.effective_start_date
  AND     ASS.effective_end_date
  AND     HOI.organization_id                = ASS.business_group_id
  AND     UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION';

  -- Returns the start date of the tax year.
  -- Change for bug 3041205 starts

  CURSOR  csr_tax_year( p_assignment_id NUMBER
                      , p_upload_date   DATE
                      ) IS
  SELECT  TRUNC(p_upload_date,'Y')
  FROM    per_assignments_f           ASS
  WHERE   ASS.assignment_id = p_assignment_id
  AND     p_upload_date BETWEEN ASS.effective_start_date AND ASS.effective_end_date;

  -- Change for bug 3041205 ends

  -- Returns the start date of the fiscal quarter.
  CURSOR  csr_fiscal_quarter( p_assignment_id NUMBER
                            , p_upload_date   DATE
                            ) IS
  SELECT  NVL(ADD_MONTHS(fnd_date.canonical_to_date(HOI.ORG_INFORMATION11)
                    , 3*(FLOOR(MONTHS_BETWEEN(p_upload_date
                    , fnd_date.canonical_to_date(HOI.ORG_INFORMATION11))/3)))
	            , END_OF_TIME)
  FROM    per_assignments_f           ASS
         ,hr_organization_information HOI
  WHERE   ASS.assignment_id                  = p_assignment_id
  AND     p_upload_date  BETWEEN ASS.effective_start_date AND ASS.effective_end_date
  AND     HOI.organization_id                = ASS.business_group_id
  AND     UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION';

  -- Returns the start date of the current period on the upload date.
  CURSOR   csr_period_start( p_assignment_id NUMBER
                           , p_upload_date   DATE
                           ) IS
  SELECT   NVL(PTP.start_date, END_OF_TIME)
  FROM     per_time_periods  PTP
          ,per_assignments_f ASS
  WHERE    ASS.assignment_id = p_assignment_id
  AND      p_upload_date  BETWEEN ASS.effective_start_date AND ASS.effective_end_date
  AND      PTP.payroll_id    = ASS.payroll_id
  AND      p_upload_date  BETWEEN PTP.start_date AND PTP.end_date;

  -- Returns the earliest date on which the assignment exists.
  CURSOR   csr_ele_ltd_start( p_assignment_id NUMBER
                            , p_upload_date DATE
                            ) IS
  SELECT   NVL(MIN(ASG.effective_start_date), END_OF_TIME)
  FROM     per_assignments_f   ASG
  WHERE    ASG.assignment_id         = p_assignment_id
  AND      ASG.effective_start_date <= p_upload_date;

  CURSOR   csr_asg_start_date( p_assignment_id NUMBER
                             , p_upload_date DATE
                             , p_expiry_date DATE
                             ) IS
  SELECT   NVL(GREATEST(MIN(ASS.effective_start_date), p_expiry_date),END_OF_TIME)
  FROM     per_assignments_f ASS
  WHERE    ASS.assignment_id = p_assignment_id
  AND      ASS.effective_start_date <= p_upload_date
  AND      ASS.effective_end_date >= p_expiry_date;

  -- Holds the start of the month for the upload date.
  l_month_start_date            DATE;

  -- Holds the start of the calendar year for the upload date.
  l_cal_yr_start_date           DATE;

  -- Holds the start of the statutory year for the upload date.
  l_tax_yr_start_date           DATE;

  -- Holds the start of the statutory quarter for the upload date.
  l_tax_qtr_start_date          DATE;

  -- Holds the start of the fiscal year for the upload date.
  l_fiscal_yr_start_date        DATE;

  -- Holds the start of the fiscal quarter for the upload date.
  l_fiscal_qtr_start_date       DATE;

  -- Holds the start of the period for the upload date.
  l_prd_start_date              DATE;

  -- Holds the earliest date on which the element entry exists.
  l_ele_ltd_start_date          DATE;

  -- Holds the expiry date of the dimension.
  l_expiry_date                 DATE;

BEGIN

  -- Calculate the expiry date for the specified dimension relative to the
  -- upload date, taking into account any contexts where appropriate. Each of
  -- the calculations also takes into account when the assignment is on a
  -- payroll to ensure that a balance adjustment could be made at that point
  -- if it were required.
  --
  -- Lifetime to date dimension.

  IF p_dimension_name IN ('_ASG_LTD','_ASG_ER_LTD','_ASG_ER_JUR_LTD') THEN
    --
    -- What is the earliest date on which the element entry exists ?
    --
    OPEN  csr_ele_ltd_start( p_assignment_id
                           , p_upload_date
                           );
    FETCH csr_ele_ltd_start
    INTO l_ele_ltd_start_date;
    CLOSE csr_ele_ltd_start;
    --
    l_expiry_date := l_ele_ltd_start_date;
    --
    -- Inception to date within a tax unit dimension.
    --
    -- Period to date dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_PTD'
    ,'_ASG_ER_PTD'
    ,'_ASG_ER_JUR_PTD') THEN
    --
    -- What is the current period start date ?
    --
    OPEN  csr_period_start( p_assignment_id
                          , p_upload_date
                          );
    FETCH csr_period_start
    INTO l_prd_start_date;
    CLOSE csr_period_start;
    --
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_prd_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_expiry_date;
    CLOSE csr_asg_start_date;
    --
    -- Month dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_MTD'
    ,'_ASG_ER_MTD'
    ,'_ASG_ER_JUR_MTD') THEN
    --
    -- What is the current month start ?
    --
    l_month_start_date := TRUNC(p_upload_date, 'MON');
    OPEN csr_asg_start_date ( p_assignment_id
                            , p_upload_date
                            , l_month_start_date
                            );
    FETCH csr_asg_start_date
    INTO l_month_start_date;
    CLOSE csr_asg_start_date;

    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_month_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_expiry_date;
    CLOSE csr_asg_start_date;
    --
    -- Quarter to date dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_QTD'
    ,'_ASG_ER_QTD'
    ,'_ASG_ER_JUR_QTD') THEN
    --
    -- What is the start date of the tax quarter ?
    --
    l_tax_qtr_start_date := TRUNC(p_upload_date, 'Q');
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_tax_qtr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_tax_qtr_start_date;
    CLOSE csr_asg_start_date;
    --
    l_expiry_date := l_tax_qtr_start_date;
    --
    -- Year to date dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_YTD'
    ,'_ASG_ER_YTD'
    ,'_ASG_ER_JUR_YTD') THEN
    --
    -- What is the start date of the tax year ?
    --
    OPEN  csr_tax_year(p_assignment_id
                      ,p_upload_date);
    FETCH csr_tax_year
    INTO l_tax_yr_start_date;
    CLOSE csr_tax_year;
    --
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_tax_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_tax_yr_start_date;
    CLOSE csr_asg_start_date;
    --
    -- Ensure that the expiry date is at a date where the assignment is to the
    -- correct legal company ie. matches the TAX_UNIT_ID context specified.
    --
    l_expiry_date := l_tax_yr_start_date;
    --
    -- Fiscal quarter to date dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_FY_QTD'
    ,'_ASG_ER_FY_QTD') THEN

    -- What is the start date of the fiscal quarter ?
    OPEN  csr_fiscal_quarter( p_assignment_id
                            , p_upload_date
                            );
    FETCH csr_fiscal_quarter
    INTO l_fiscal_qtr_start_date;
    CLOSE csr_fiscal_quarter;

    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_fiscal_qtr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_expiry_date;
    CLOSE csr_asg_start_date;
    --
    -- Fiscal year to date dimensions.
    --
  ELSIF p_dimension_name IN
    ('_ASG_FY_YTD'
    ,'_ASG_ER_FY_YTD') THEN

    -- What is the start date of the fiscal year ?
    OPEN  csr_fiscal_year( p_assignment_id
                         , p_upload_date
                         );
    FETCH csr_fiscal_year
    INTO l_fiscal_yr_start_date;
    CLOSE csr_fiscal_year;

    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_fiscal_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_expiry_date;
    CLOSE csr_asg_start_date;

  END IF;
  --
  -- return the date on which the dimension expires.
  --
  RETURN (l_expiry_date);
  --
EXCEPTION
  WHEN OTHERS THEN
    IF  csr_fiscal_year%ISOPEN THEN
        CLOSE csr_fiscal_year;
    END IF;
    IF csr_tax_year%ISOPEN THEN
       CLOSE csr_tax_year;
    END IF;
    IF csr_fiscal_quarter%ISOPEN THEN
        CLOSE csr_fiscal_quarter;
    END IF;
    IF csr_period_start%ISOPEN THEN
       CLOSE csr_period_start;
    END IF;
    IF csr_ele_ltd_start%ISOPEN THEN
       CLOSE csr_ele_ltd_start;
    END IF;
    IF csr_asg_start_date%ISOPEN THEN
       CLOSE csr_asg_start_date;
    END IF;

    RAISE;
END expiry_date;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_SUPPORTED                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to check if the specified dimension is     --
--                  supported for China Localization                    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_dimension_name    VARCHAR2                        --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-Mar-03  saikrish  Created this function                     --
-- 1.1   18-Jun-03  bramajey  Introduced cursor to check whether        --
--                            dimension is a valid dimension for CN     --
--------------------------------------------------------------------------
FUNCTION is_supported ( p_dimension_name VARCHAR2)
RETURN NUMBER
IS
  CURSOR csr_dimension (p_dimension_name VARCHAR2)
  IS
  --
    SELECT balance_dimension_id
    FROM   pay_balance_dimensions
    WHERE  dimension_name   = p_dimension_name
    AND    legislation_code = 'CN'
	AND    dimension_name NOT IN ( '_ASG_RUN'
                                 , '_ASG_ER_RUN'
                                 , '_ASG_ER_JUR_RUN'
                                 , '_ASG_PMTH'
                                 , '_ASG_P12MTH'
                                 , '_PAYMENTS');
  --
  l_dimension_id NUMBER;
  --
BEGIN
   --
   hr_utility.trace('Entering pay_cn_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   OPEN csr_dimension (p_dimension_name);
   FETCH csr_dimension INTO l_dimension_id;

   IF csr_dimension%NOTFOUND THEN
     CLOSE csr_dimension;
     RETURN (0);  -- denotes FALSE
   ELSE
     CLOSE csr_dimension;
     RETURN (1);  -- denotes TRUE
   END IF;
   --
   hr_utility.trace('Exiting pay_cn_bal_upload.is_supported');
   --
EXCEPTION
  WHEN others THEN
    CLOSE csr_dimension;
    RAISE;
END is_supported;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INCLUDE_ADJUSTMENT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to perform balance adjustment              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_balance_type_id    NUMBER                         --
--                  p_dimension_name     VARCHAR2                       --
--                  p_original_entry_id  NUMBER                         --
--                  p_upload_date        DATE                           --
--                  p_batch_line_id      NUMBER                         --
--                  p_test_batch_line_id NUMBER                         --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-Mar-03  saikrish  Created this function                     --
-- 1.1   30-Nov-05  snekkala  Modified cursor csr_get_tax_unit          --
--------------------------------------------------------------------------
FUNCTION include_adjustment ( p_balance_type_id    NUMBER
                            , p_dimension_name     VARCHAR2
                            , p_original_entry_id  NUMBER
                            , p_upload_date        DATE
                            , p_batch_line_id      NUMBER
                            , p_test_batch_line_id NUMBER
                            )
RETURN NUMBER
IS
  -- Does the balance adjustment effect the new balance dimension.
  CURSOR csr_is_included( p_balance_type_id           NUMBER
                        , p_tax_unit_id               NUMBER
                        , p_original_entry_id         NUMBER
                        , p_bal_adj_tax_unit_id       NUMBER
                        , p_bal_adj_original_entry_id NUMBER
                        ) IS
  SELECT BT.balance_type_id
  FROM   pay_balance_types BT
  WHERE  BT.balance_type_id = p_balance_type_id
	    --
	    -- TAX_UNIT_ID context NB. if the tax unit is used then only those
	    -- adjustments which are for the same tax unit can be included.
	    --
  AND    NVL(p_tax_unit_id, NVL(p_bal_adj_tax_unit_id, -1)) =
	 NVL(p_bal_adj_tax_unit_id, -1)
	    --
	    -- ORIGINAL_ENTRY_ID context NB. this context controls the expiry
	    -- date of the dimension in the same way as the QTD dimension. Any
	    -- existing balance adjustments that lie between the upload date
	    -- and the expiry date are all included. There is no special
	    -- criteria that has to be met.
	    --
  AND  1 = 1;

  l_bal_type_id       pay_balance_types.balance_type_id%TYPE;

  -- Get the tax_unit_id from the original balance batch line
  CURSOR csr_get_tax_unit(p_batch_line_id  NUMBER)
  IS
    SELECT pbbl.tax_unit_id
      FROM pay_balance_batch_lines      pbbl
         , hr_all_organization_units_tl otl
         , hr_organization_information  hoi
     WHERE pbbl.batch_line_id   = p_batch_line_id
       AND pbbl.tax_unit_id     = otl.organization_id
       AND pbbl.tax_unit_id    IS NOT NULL
       AND otl.organization_id  = hoi.organization_id
       AND hoi.org_information1 = 'HR_LEGAL'
       AND hoi.org_information2 = 'Y'
       AND otl.language         = userenv('LANG')
     UNION ALL
     SELECT pbbl.tax_unit_id
       FROM pay_balance_batch_lines      pbbl
          , hr_all_organization_units_tl otl
          , hr_organization_information  hoi
      WHERE pbbl.batch_line_id   = p_batch_line_id
        AND upper(pbbl.gre_name) = UPPER(otl.name)
        AND pbbl.tax_unit_id    IS NULL
        AND otl.organization_id  = hoi.organization_id
        AND hoi.org_information1 = 'HR_LEGAL'
        AND hoi.org_information2 = 'Y'
        AND otl.language         = userenv('LANG');

  -- Get tax_unit_id and original_entry_id for previously tested adjustments
  CURSOR csr_get_tested_adjustments(p_test_batch_line_id NUMBER) IS
  SELECT tax_unit_id
        ,original_entry_id
  FROM   pay_temp_balance_adjustments
  WHERE  batch_line_id = p_test_batch_line_id;

  -- The balance returned by the include check.
  l_tax_unit_id       hr_tax_units_v.tax_unit_id%TYPE;
  l_adj_tax_unit_id   pay_temp_balance_adjustments.tax_unit_id%TYPE;
  l_adj_orig_entry_id pay_temp_balance_adjustments.original_entry_id%TYPE;

BEGIN
  hr_utility.trace('Entering pay_cn_bal_upload.include_adjustment_test');

  OPEN  csr_get_tax_unit(p_batch_line_id);
  FETCH csr_get_tax_unit
  INTO l_tax_unit_id;
  CLOSE csr_get_tax_unit;

  OPEN  csr_get_tested_adjustments(p_test_batch_line_id);
  FETCH csr_get_tested_adjustments
  INTO  l_adj_tax_unit_id
      , l_adj_orig_entry_id;
  CLOSE csr_get_tested_adjustments;

  -- Does the balance adjustment effect the new balance ?

  hr_utility.trace('balance_type_id      = '||TO_CHAR(p_balance_type_id));
  hr_utility.trace('tax_unit_id          = '||TO_CHAR(l_tax_unit_id));
  hr_utility.trace('original_entry_id    = '||TO_CHAR(p_original_entry_id));
  hr_utility.trace('BA tax_unit_id       = '||TO_CHAR(l_adj_tax_unit_id));
  hr_utility.trace('BA original_entry_id = '||TO_CHAR(l_adj_orig_entry_id));

  OPEN  csr_is_included(p_balance_type_id
                       ,l_tax_unit_id
                       ,p_original_entry_id
                       ,l_adj_tax_unit_id
                       ,l_adj_orig_entry_id
                       );
  FETCH csr_is_included
  INTO l_bal_type_id;
  CLOSE csr_is_included;

  hr_utility.trace('Exiting pay_cn_bal_upload.include_adjustment_test');

  -- Adjustment does contribute to the new balance.

  IF l_bal_type_id IS NOT NULL THEN
    RETURN (1);  --TRUE

    -- Adjustment does not contribute to the new balance.
  ELSE
    RETURN (0);  --FALSE

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_is_included%ISOPEN THEN
       CLOSE csr_is_included;
    END IF;
    IF csr_get_tax_unit%ISOPEN THEN
       CLOSE csr_get_tax_unit;
    END IF;
    IF csr_get_tested_adjustments%ISOPEN THEN
       CLOSE csr_get_tested_adjustments;
    END IF;
  RAISE;
END include_adjustment;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_BATCH_LINES                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to perform user-defined validation         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_batch_id           NUMBER                         --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-Mar-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
PROCEDURE validate_batch_lines (p_batch_id NUMBER)
IS

BEGIN
  hr_utility.trace('Entering pay_cn_bal_upload.validate_batch_lines');

  hr_utility.trace('Exiting pay_cn_bal_upload.validate_batch_lines');

END validate_batch_lines;

END pay_cn_bal_upload;

/
