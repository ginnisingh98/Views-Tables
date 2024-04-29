--------------------------------------------------------
--  DDL for Package Body PAY_IN_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_BAL_UPLOAD" AS
/* $Header: pyinupld.pkb 120.3 2008/06/03 11:23:28 rsaharay noship $ */

 -- Date Constants
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 g_package     CONSTANT VARCHAR2(100) := 'pay_in_bal_upload.';
 g_debug       BOOLEAN ;

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
-- 1.0   16-JUL-2004  lnagaraj  Created this function                   --
--------------------------------------------------------------------------


FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER)
RETURN DATE IS

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

  -- Holds the start of the statutory/calendar quarter for the upload date.
  l_tax_qtr_start_date          DATE;

   -- Holds the start of the mar-feb year for the upload date.
  l_prov_yr_start_date          DATE;

  -- Holds the start of the period for the upload date.
  l_prd_start_date              DATE;

  -- Holds the start date of the half tax year
  l_half_yr_start_date          DATE;

  -- Holds the expiry date of the dimension.
  l_expiry_date                 DATE;

  -- Holds the start date of the half calender year
  l_c_half_yr_start_date         DATE;

  l_year NUMBER(4);
  l_month NUMBER(2);
  l_start_dd_mm VARCHAR2(6);
  l_half_start1_dd_mm VARCHAR2(6);
  l_half_start2_dd_mm VARCHAR2(6);
BEGIN




  -- Calculate the expiry date for the specified dimension relative to the
  -- upload date, taking into account any contexts where appropriate. Each of
  -- the calculations also takes into account when the assignment is on a
  -- payroll to ensure that a balance adjustment could be made at that point
  -- if it were required.


IF p_dimension_name IN ('_ASG_PTD'
                       ,'_ASG_ORG_PTD'
		       ,'_ASG_STATE_PTD'
                       ,'_ASG_LE_PTD'
		       ,'_ASG_COMP_PTD'
		       ,'_ASG_LE_COMP_PTD')
THEN
   --
   -- What is the Current Period Start Date?
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


ELSIF p_dimension_name IN ('_ASG_MTD'
                          ,'_ASG_ORG_MTD'
			  ,'_ASG_STATE_MTD'
                          ,'_ASG_LE_MTD'
			  ,'_ASG_COMP_MTD'
			  ,'_ASG_LE_COMP_MTD')
THEN
   l_month_start_date := TRUNC(p_upload_date, 'MON');

   OPEN csr_asg_start_date ( p_assignment_id
                            , p_upload_date
                            , l_month_start_date
                            );
    FETCH csr_asg_start_date
    INTO l_month_start_date;
    CLOSE csr_asg_start_date;
    l_expiry_date := l_month_start_date;
ELSIF p_dimension_name IN ('_ASG_QTD'
                          ,'_ASG_ORG_QTD'
			  ,'_ASG_STATE_QTD'
                          ,'_ASG_LE_QTD'
			  ,'_ASG_COMP_QTD'
			  ,'_ASG_LE_COMP_QTD')
THEN
  l_tax_qtr_start_date := TRUNC(p_upload_date, 'Q');
  OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_tax_qtr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_tax_qtr_start_date;
    CLOSE csr_asg_start_date;
   l_expiry_date :=  l_tax_qtr_start_date;
ELSIF p_dimension_name IN ('_ASG_YTD'
                          ,'_ASG_ORG_YTD'
			  ,'_ASG_STATE_YTD'
                          ,'_ASG_LE_YTD'
			  ,'_ASG_COMP_YTD'
			  ,'_ASG_LE_COMP_YTD')
THEN --Bugfix 3796385
   l_year := to_number(to_char(p_upload_date,'yyyy'));
   l_start_dd_mm := '01-04-';
   IF p_upload_date>=to_date(l_start_dd_mm||to_char(l_year),'dd-mm-yyyy') THEN
      l_tax_yr_start_date :=to_date(l_start_dd_mm||to_char(l_year),'dd-mm-yyyy');
   ELSE
      l_tax_yr_start_date := to_date(l_start_dd_mm||to_char(l_year -1),'dd-mm-yyyy');
   END IF;


    --
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_tax_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_tax_yr_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_tax_yr_start_date;

ELSIF p_dimension_name IN ('_ASG_CYTD','_ASG_ORG_CYTD','_ASG_STATE_CYTD') THEN
    l_cal_yr_start_date := TRUNC(p_upload_date,'Y');
    --
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_cal_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_cal_yr_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_cal_yr_start_date;
ELSIF p_dimension_name IN ('_ASG_MAR_FEB_YTD'
                            ,'_ASG_ORG_MAR_FEB_YTD'
                           ,'_ASG_LE_MAR_FEB_YTD')
THEN
   l_year := to_number(to_char(p_upload_date,'yyyy'));
   l_start_dd_mm := '01-03-';
   IF p_upload_date>=to_date(l_start_dd_mm||to_char(l_year),'dd-mm-yyyy') THEN
      l_prov_yr_start_date :=to_date(l_start_dd_mm||to_char(l_year),'dd-mm-yyyy');
   ELSE
      l_prov_yr_start_date := to_date(l_start_dd_mm||to_char(l_year -1),'dd-mm-yyyy');
   END IF;

    --
    OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_prov_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_prov_yr_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_prov_yr_start_date;

ELSIF p_dimension_name IN('_ASG_HYTD'
                         ,'_ASG_ORG_HYTD'
			 ,'_ASG_STATE_HYTD'
                         ,'_ASG_LE_HYTD'
			 ,'_ASG_COMP_HYTD'
			 ,'_ASG_LE_COMP_HYTD')
THEN
    l_year := to_number(to_char(p_upload_date,'yyyy'));
    l_month :=to_number(to_char(p_upload_date,'mm'));
    l_half_start1_dd_mm := '01-04-';
    l_half_start2_dd_mm := '01-10-';
   IF l_month between 4 and 9 THEN
      l_half_yr_start_date :=to_date(l_half_start1_dd_mm||to_char(l_year),'dd-mm-yyyy');
   ELSIF l_month between 10 and 12 THEN
      l_half_yr_start_date := to_date(l_half_start2_dd_mm||to_char(l_year),'dd-mm-yyyy');
   ELSE
      l_half_yr_start_date := to_date(l_half_start2_dd_mm||to_char(l_year -1),'dd-mm-yyyy');
   END IF;

   OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_half_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_half_yr_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_half_yr_start_date;
ELSIF p_dimension_name IN ('_ASG_LTD','_ASG_SRC_LTD','_ASG_COMP_LTD') THEN
    OPEN csr_asg_start_date ( p_assignment_id
                            , p_upload_date
                            , to_date('01-01-0001','dd-mm-yyyy')
                            );
    FETCH csr_asg_start_date
    INTO l_month_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_month_start_date;
ELSIF p_dimension_name IN('_ASG_ORG_CHYTD'
                         ,'_ASG_STATE_CHYTD'
			 ,'_ASG_CHYTD'
                         )
THEN
    l_year := to_number(to_char(p_upload_date,'yyyy'));
    l_month :=to_number(to_char(p_upload_date,'mm'));
    l_half_start1_dd_mm := '01-01-';
    l_half_start2_dd_mm := '01-07-';
   IF l_month between 1 and 6 THEN
      l_c_half_yr_start_date :=to_date(l_half_start1_dd_mm||to_char(l_year),'dd-mm-yyyy');
   ELSE
      l_c_half_yr_start_date := to_date(l_half_start2_dd_mm||to_char(l_year),'dd-mm-yyyy');
   END IF;

   OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_c_half_yr_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_c_half_yr_start_date;
    CLOSE csr_asg_start_date;

    l_expiry_date := l_c_half_yr_start_date;
END IF;

RETURN l_expiry_date;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_period_start%ISOPEN THEN
       CLOSE csr_period_start;
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
--                  supported for India Localization                    --
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
-- 1.0   16-JUL-2004  lnagaraj  Created this function                     --

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
    AND    legislation_code = 'IN'
    AND    dimension_name NOT IN ( '_ASG_RUN'
                                 , '_ASG_ORG_RUN'
                                 , '_ASG_STATE_RUN'
                                 , '_PAYMENTS'
                                 , '_ASG_LE_RUN'
                                 , '_ASG_COMP_RUN'
                                 , '_ASG_LE_COMP_RUN'
                                 , '_ASG_SRC_RUN'
                                 ,'_ASG_COMP_LTD'
                                 ,'_ASG_LE_FY_PMTH'
                                 ,'_ASG_PMTH'
                                 ,'_ASG_P10MTH'
                                 );
  --
  l_dimension_id NUMBER;
  --
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'is_supported';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_dimension_name :',p_dimension_name);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

   --
  -- hr_utility.trace('Entering pay_in_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   OPEN csr_dimension (p_dimension_name);
   FETCH csr_dimension INTO l_dimension_id;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_dimension_id :',l_dimension_id);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

   IF csr_dimension%NOTFOUND THEN
     CLOSE csr_dimension;
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
     RETURN (0);  -- denotes FALSE
   ELSE
     CLOSE csr_dimension;
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
     RETURN (1);  -- denotes TRUE
   END IF;
   --
--   hr_utility.trace('Exiting pay_in_bal_upload.is_supported');
   --
EXCEPTION
  WHEN others THEN
    CLOSE csr_dimension;
    l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
    pay_in_utils.trace(l_message,l_procedure);
    pay_in_utils.trace('**************************************************','********************');
    RAISE;
END is_supported;


-- Function to check if adjustment is required for a particular Dimension.
-- p_test_batch_line_id identifies the adjustment that has already been processed
-- p_batch_line_id identifies the adjustment currently being processed.
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
-- 1.0   16-JUL-2004  lnagaraj  Created this function                   --
-- 1.1   21-Oct-2005  lnagaraj  Modified csr_get_details                --
--------------------------------------------------------------------------

FUNCTION include_adjustment
 	(
	  p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 )
RETURN NUMBER
IS

 -- Does the balance adjustment effect the new balance dimension.
  CURSOR csr_is_included( p_balance_type_id           NUMBER
			, p_source_id                 NUMBER
                        , p_original_entry_id         NUMBER
                        , p_tax_unit_id               NUMBER
                        , p_jurisdiction_code         VARCHAR2
			, p_source_text               VARCHAR2
			, p_source_text2              VARCHAR2
                        , p_bal_adj_tax_unit_id       NUMBER
                        , p_bal_adj_jurisdiction_code VARCHAR
			, p_bal_adj_source_id         NUMBER
                        , p_bal_adj_original_entry_id NUMBER
			, p_bal_adj_source_text       VARCHAR2
			, p_bal_adj_source_text2      VARCHAR2
                        ) IS
  SELECT BT.balance_type_id
  FROM   pay_balance_types BT
  WHERE  BT.balance_type_id = p_balance_type_id
       and  ((p_source_id is null)    or
             (p_source_id is not null and p_source_id = p_bal_adj_source_id))
       and  ((p_tax_unit_id is null)    or
             (p_tax_unit_id is not null and p_tax_unit_id = p_bal_adj_tax_unit_id))
       and  ((p_jurisdiction_code is null)    or
             (p_jurisdiction_code is not null and p_jurisdiction_code = p_bal_adj_jurisdiction_code))
       and  ((p_source_text is null)    or
             (p_source_text is not null and p_source_text = p_bal_adj_source_text))
       and  ((p_source_text2 is null)    or
             (p_source_text2 is not null and p_source_text2 = p_bal_adj_source_text2))
  AND  1 = 1;

  l_bal_type_id       pay_balance_types.balance_type_id%TYPE;

  -- Get the jurisdiction code from the original balance batch line
  --
  cursor csr_get_details(p_batch_line_id  number)
  is
    select pbbl.source_id
	  ,pbbl.original_entry_id
          ,pbbl.tax_unit_id
	  ,pbbl.jurisdiction_code
	  ,pbbl.source_text
	  ,pbbl.source_text2
    from   pay_balance_batch_lines pbbl
     where  pbbl.batch_line_id = p_batch_line_id;


  -- Get jurisdiction code and original_entry_id for previously tested adjustments
  CURSOR csr_get_tested_adjustments(p_test_batch_line_id NUMBER) IS
  SELECT source_id
        ,original_entry_id
        ,tax_unit_id
        ,jurisdiction_code
	,source_text
	,source_text2
  FROM   pay_temp_balance_adjustments
  WHERE  batch_line_id = p_test_batch_line_id;

  -- The balance returned by the include check.
  l_orig_entry_id       pay_balance_batch_lines.original_entry_id%TYPE;
  l_adj_orig_entry_id   pay_temp_balance_adjustments.original_entry_id%TYPE;
  l_source_id           pay_balance_batch_lines.source_id%TYPE;
  l_adj_source_id       pay_temp_balance_adjustments.source_id%TYPE;
  l_tax_unit_id         pay_balance_batch_lines.tax_unit_id%TYPE;
  l_adj_tax_unit_id     pay_temp_balance_adjustments.tax_unit_id%TYPE;
  l_source_text         pay_balance_batch_lines.source_text%TYPE;
  l_adj_source_text     pay_temp_balance_adjustments.source_text%TYPE;
  l_source_text2        pay_balance_batch_lines.source_text2%TYPE;
  l_adj_source_text2    pay_temp_balance_adjustments.source_text2%TYPE;
  l_jur_code            pay_balance_batch_lines.jurisdiction_code%TYPE;
  l_adj_jur_code        pay_temp_balance_adjustments.jurisdiction_code%TYPE;
  l_procedure           VARCHAR2(250);
  l_message             VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'include_adjustment';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_balance_type_id    :',p_balance_type_id   );
        pay_in_utils.trace('p_dimension_name     :',p_dimension_name    );
        pay_in_utils.trace('p_original_entry_id  :',p_original_entry_id );
        pay_in_utils.trace('p_upload_date        :',p_upload_date       );
        pay_in_utils.trace('p_batch_line_id      :',p_batch_line_id     );
        pay_in_utils.trace('p_test_batch_line_id :',p_test_batch_line_id);
        pay_in_utils.trace('**************************************************','********************');
   END IF;


  OPEN csr_get_details(p_batch_line_id);
  FETCH csr_get_details INTO l_source_id,
                             l_orig_entry_id,
			     l_tax_unit_id,
			     l_jur_code,
			     l_source_text,
			     l_source_text2;
  CLOSE csr_get_details;
   --

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_source_id     :',l_source_id    );
        pay_in_utils.trace('l_orig_entry_id :',l_orig_entry_id);
        pay_in_utils.trace('l_tax_unit_id   :',l_tax_unit_id  );
        pay_in_utils.trace('l_jur_code      :',l_jur_code     );
        pay_in_utils.trace('l_source_text   :',l_source_text  );
        pay_in_utils.trace('l_source_text2  :',l_source_text2 );
        pay_in_utils.trace('**************************************************','********************');
   END IF;

  OPEN  csr_get_tested_adjustments(p_test_batch_line_id);
  FETCH csr_get_tested_adjustments
  INTO   l_adj_source_id,
         l_adj_orig_entry_id,
	 l_adj_tax_unit_id,
	 l_adj_jur_code,
	 l_adj_source_text,
	 l_adj_source_text2;
  CLOSE csr_get_tested_adjustments;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_adj_source_id    :',l_adj_source_id    );
        pay_in_utils.trace('l_adj_orig_entry_id:',l_adj_orig_entry_id);
        pay_in_utils.trace('l_adj_tax_unit_id  :',l_adj_tax_unit_id  );
        pay_in_utils.trace('l_adj_jur_code     :',l_adj_jur_code     );
        pay_in_utils.trace('l_adj_source_text  :',l_adj_source_text  );
        pay_in_utils.trace('l_adj_source_text2 :',l_adj_source_text2 );
        pay_in_utils.trace('**************************************************','********************');
   END IF;
  -- Does the balance adjustment effect the new balance ?

  --hr_utility.trace('balance_type_id      = '||TO_CHAR(p_balance_type_id));

  --hr_utility.trace('jurisdiction_id    = '||TO_CHAR(l_jurisdiction_code));
  --hr_utility.trace('original_entry_id    = '||TO_CHAR(p_original_entry_id));


  -- hr_utility.trace('BA jurisdiction_id    = '||TO_CHAR(l_adj_jurisdiction_code));
  --hr_utility.trace('BA original_entry_id = '||TO_CHAR(l_adj_orig_entry_id));

  OPEN  csr_is_included(p_balance_type_id
                       ,l_source_id
                       ,p_original_entry_id
		       ,l_tax_unit_id
		       ,l_jur_code
		       ,l_source_text
		       ,l_source_text2
		       ,l_adj_tax_unit_id
		       ,l_adj_jur_code
                       ,l_adj_source_id
                       ,l_adj_orig_entry_id
		       ,l_adj_source_text
		       ,l_adj_source_text2
                       );
  FETCH csr_is_included INTO l_bal_type_id;
  CLOSE csr_is_included;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_bal_type_id    :',l_bal_type_id);
        pay_in_utils.trace('**************************************************','********************');
   END IF;

  --hr_utility.trace('Exiting pay_in_bal_upload.include_adjustment_test');

  -- Adjustment does contribute to the new balance.

  IF l_bal_type_id IS NOT NULL THEN
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
    RETURN (1);  --TRUE

    -- Adjustment does not contribute to the new balance.
  ELSE
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
    RETURN (0);  --FALSE

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_is_included%ISOPEN THEN
       CLOSE csr_is_included;
    END IF;

    IF csr_get_details%ISOPEN THEN
       CLOSE csr_get_details;
    END IF;

    IF csr_get_tested_adjustments%ISOPEN THEN
       CLOSE csr_get_tested_adjustments;
    END IF;

    l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
    pay_in_utils.trace(l_message,l_procedure);
    pay_in_utils.trace('**************************************************','********************');
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
-- 1.0   16-JUL-2004  lnagaraj  Created this function                     --
--------------------------------------------------------------------------
PROCEDURE validate_batch_lines (p_batch_id NUMBER)
IS

BEGIN
    NULL;
END validate_batch_lines;

END pay_in_bal_upload;


/
