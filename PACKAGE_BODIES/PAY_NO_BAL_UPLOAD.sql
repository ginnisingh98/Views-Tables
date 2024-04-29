--------------------------------------------------------
--  DDL for Package Body PAY_NO_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_BAL_UPLOAD" AS
/* $Header: pynobalupl.pkb 120.0.12000000.1 2007/05/22 06:14:46 rajesrin noship $ */

-- Date Constants
START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');

----------------------------------------------------------------------------
-- Name           : EXPIRY_DATE
-- Type           : FUNCTION
-- Access         : Public
-- Description    : Function to return the expiry date of the given
--                  balance dimension relative to a date.
-- Arguments      :
--  IN :
--    p_upload_date       - the date on which the balance should be correct.
--    p_dimension_name    - the dimension being set.
--    p_assignment_id     - the assignment involved.
--    p_original_entry_id - ORIGINAL_ENTRY_ID context.
--  OUT : N/A
--  RETURN : Date
--
-- NOTES
--  This is used by pay_balance_upload.dim_expiry_date.
--  If the expiry date cannot be derived then it is set to the end of time
--  to indicate that a failure has occured. The process that uses the
--  expiry date knows this rulw and acts accordingly.
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


  l_prd_start_date              DATE;    -- Holds the start of the period for the upload date.
  l_expiry_date                 DATE;    -- Holds the expiry date of the dimension.
  l_cal_yr_start_date           DATE;    -- Holds the start date of the calendar year for the upload date.
  l_bi_month_start_date         DATE;    -- Holds the start date of the bi-monthly period for the upload date.

BEGIN
  -- Calculate the expiry date for the specified dimension relative to the
  -- upload date, taking into account any contexts where appropriate. Each of
  -- the calculations also takes into account when the assignment is on a
  -- payroll to ensure that a balance adjustment could be made at that point
  -- if it were required.

hr_utility.trace('Entering pay_no_bal_upload.expiry_date');

IF p_dimension_name IN ('ASSIGNMENT ELEMENT CODE PERIOD TO DATE')
THEN

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

ELSIF p_dimension_name IN ('ASSIGNMENT ELEMENT CODE YEAR TO DATE') THEN
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

ELSIF p_dimension_name IN ('ASSIGNMENT BI-MONTHLY TO DATE') THEN

  l_bi_month_start_date := trunc(Add_months(p_upload_date,MOD(TO_NUMBER(TO_CHAR(p_upload_date,'MM')),2)-1),'MM');

  OPEN csr_asg_start_date( p_assignment_id
                           , p_upload_date
                           , l_bi_month_start_date
                           );
    FETCH csr_asg_start_date
    INTO l_bi_month_start_date;
    CLOSE csr_asg_start_date;
   l_expiry_date :=  l_bi_month_start_date;


END IF;

RETURN l_expiry_date;

hr_utility.trace('Leaving pay_no_bal_upload.expiry_date ');

EXCEPTION
   WHEN no_data_found THEN
         l_expiry_date := END_OF_TIME;
         RETURN l_expiry_date;

END expiry_date;

--------------------------------------------------------------------------
-- Name           : IS_SUPPORTED
-- Type           : FUNCTION
-- Access         : Public
-- Description    : Function to check if the specified dimension is
--                  supported by the upload process.
--
-- Arguments      :
--  IN :   p_dimension_name - the balance dimension to be checked.
--  OUT : N/A
--  RETURN : Number
--
-- NOTES
--  Only a subset of the NO dimensions are supported.
--  This is used by pay_balance_upload.validate_dimension.
--------------------------------------------------------------------------

  FUNCTION is_supported
  (p_dimension_name varchar2)
  RETURN number IS

  BEGIN
  hr_utility.trace('Entering pay_no_bal_upload.is_supported');

  IF p_dimension_name in ('ASSIGNMENT ELEMENT CODE PERIOD TO DATE'
                         ,'ASSIGNMENT ELEMENT CODE YEAR TO DATE'
                         ,'ASSIGNMENT BI-MONTHLY TO DATE') THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  hr_utility.trace('Leaving pay_no_bal_upload.is_supported ');
  END is_supported;

--------------------------------------------------------------------------
-- Name           : INCLUDE_ADJUSTMENT
-- Type           : FUNCTION
-- Access         : Public
-- Description    : Given a dimension, and relevant contexts and details of an existing
--  balanmce adjustment, it will find out if the balance adjustment effects
--  the dimension to be set. Both the dimension to be set and the adjustment
--  are for the same assignment and balance. The adjustment also lies between
--  the expiry date of the new balance and the date on which it is to set.
--
-- Arguments      :
--  IN :
--    p_balance_type_id    - the balance to be set.
--    p_dimension_name     - the balance dimension to be set.
--    p_original_entry_id  - ORIGINAL_ENTRY_ID context.
--    p_upload_date
--    p_batch_line_id
--    p_test_batch_line_id
--  OUT : N/A
--  RETURN : Number
--
-- Notes
--  all the NO dimensions affect each other when they share the same context
--  values so there is no special support required for individual dimensions.
--  this is used by pay_balance_upload.get_current_value.
--------------------------------------------------------------------------
 FUNCTION include_adjustment
 	(
	  p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 ) RETURN number IS

          CURSOR csr_bal_adj (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.source_text ,  tba.tax_unit_id
	  FROM   pay_temp_balance_adjustments tba,
		 pay_balance_batch_lines bbl
	  WHERE  tba.balance_type_id = bbl.balance_type_id
	  AND    tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	  AND    nvl(tba.source_text ,0) = nvl(bbl.source_text ,0);


        l_include_adj Number :=  1 ; -- True
	v_cur_bal_adj_st1  csr_bal_adj%ROWTYPE;

   BEGIN
      hr_utility.trace(' Entering pay_no_bal_upload.include_adjustment ');

       -- When not to allow adjustment
       -- Suppose,we want    _ASG_ELE_CODE_PTD   (Source_text 'test1' and balance value 7000)
       --                    _ASG_ELE_CODE_PTD   (Source_text 'test2' and balance value 4000)
       -- Here we expect _ASG_PTD to be 11000 after upload
       -- In this case,if adjustment is allowed (True)
       -- _ASG_PTD = 4000
       -- (Source_text 'test1' and YTD balance value  7000)
       -- (Source_text 'test2' and YTD balance value -3000)
       -- balance values will be adjusted to get make the balance satisy last entry
       -- Hence donot allow adjustment.

       IF p_dimension_name IN ('ASSIGNMENT BI-MONTHLY TO DATE') THEN

             l_include_adj := 1 ; -- True

       ELSIF p_dimension_name IN ('ASSIGNMENT ELEMENT CODE PERIOD TO DATE'
                                  ,'ASSIGNMENT ELEMENT CODE YEAR TO DATE') THEN

             OPEN csr_bal_adj(p_test_batch_line_id => p_test_batch_line_id,
                              p_batch_line_id => p_batch_line_id);

             FETCH csr_bal_adj INTO v_cur_bal_adj_st1;

             IF csr_bal_adj%NOTFOUND THEN
                l_include_adj := 0 ; -- False
             END IF;
             CLOSE csr_bal_adj;
       ELSE
          NULL;
       END IF;

       hr_utility.trace(' Leaving pay_no_bal_upload.include_adjustment' );
       RETURN l_include_adj;

   END include_adjustment;

  PROCEDURE validate_batch_lines ( p_batch_id  IN  NUMBER) is
  BEGIN
    null;
  END;

END PAY_NO_BAL_UPLOAD;

/
