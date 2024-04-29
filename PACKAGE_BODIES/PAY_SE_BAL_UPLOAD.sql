--------------------------------------------------------
--  DDL for Package Body PAY_SE_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_BAL_UPLOAD" AS
/* $Header: pysebalupl.pkb 120.0.12000000.1 2007/07/23 10:28:24 rravi noship $ */

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

CURSOR csr_earning_year( csr_v_assignment_id number,
csr_v_upload_date date)
IS
SELECT SUBSTR (hoi4.org_information1, 4, 2)
,SUBSTR (hoi4.org_information2, 4, 2)
FROM hr_organization_units o1
,hr_organization_information hoi1
,hr_organization_information hoi2
,hr_organization_information hoi3
,hr_organization_information hoi4
, (SELECT TRIM (scl.segment2) AS org_id
,business_group_id AS bus_id
FROM per_all_assignments_f asg
,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = csr_v_assignment_id
AND asg.soft_coding_keyflex_id =
scl.soft_coding_keyflex_id
AND csr_v_upload_date BETWEEN asg.effective_start_date
AND asg.effective_end_date) x
WHERE o1.business_group_id = x.bus_id
AND hoi1.organization_id = o1.organization_id
AND hoi1.organization_id = x.org_id
AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
AND hoi1.org_information_context = 'CLASS'
AND o1.organization_id = hoi2.org_information1
AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
AND hoi2.organization_id = hoi3.organization_id
AND hoi3.org_information_context = 'CLASS'
AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi3.organization_id = hoi4.organization_id
AND hoi4.org_information_context = 'SE_HOLIDAY_YEAR_DEFN'
AND hoi4.org_information1 IS NOT NULL;


CURSOR csr_saved_year_limit( csr_v_assignment_id number,
csr_v_upload_date date)
IS

SELECT HOI4.ORG_INFORMATION2
FROM hr_organization_units o1
,hr_organization_information hoi1
,hr_organization_information hoi2
,hr_organization_information hoi3
,hr_organization_information hoi4
, (SELECT TRIM (scl.segment2) AS org_id
,business_group_id AS bus_id
FROM per_all_assignments_f asg
,hr_soft_coding_keyflex scl
WHERE asg.assignment_id = csr_v_assignment_id
AND asg.soft_coding_keyflex_id =
scl.soft_coding_keyflex_id
AND csr_v_upload_date BETWEEN asg.effective_start_date
AND asg.effective_end_date) x
WHERE o1.business_group_id = x.bus_id
AND hoi1.organization_id = o1.organization_id
AND hoi1.organization_id = x.org_id
AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
AND hoi1.org_information_context = 'CLASS'
AND o1.organization_id = hoi2.org_information1
AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
AND hoi2.organization_id = hoi3.organization_id
AND hoi3.org_information_context = 'CLASS'
AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi3.organization_id = hoi4.organization_id
AND hoi4.org_information_context = 'SE_LE_HOLIDAY_PAY_DETAILS'
AND hoi4.org_information1 IS NOT NULL;



  l_prd_start_date              DATE;    -- Holds the start of the period for the upload date.
  l_expiry_date                 DATE;    -- Holds the expiry date of the dimension.
  l_cal_yr_start_date           DATE;    -- Holds the start date of the calendar year for the upload date.
  l_bi_month_start_date         DATE;    -- Holds the start date of the bi-monthly period for the upload date.
  l_start_month	CHAR(2);
  l_end_month CHAR(2);
  l_earn_end_year NUMBER;
  l_saved_year_limit NUMBER;

BEGIN
  -- Calculate the expiry date for the specified dimension relative to the
  -- upload date, taking into account any contexts where appropriate. Each of
  -- the calculations also takes into account when the assignment is on a
  -- payroll to ensure that a balance adjustment could be made at that point
  -- if it were required.



IF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY HOLIDAY YEAR',
			'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR')
THEN


   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||l_earn_end_year,'DD/MM/YYYY');

ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY EARNING YEAR',
 			'ASSIGNMENT WITHIN LEGAL EMPLOYER EARNING YEAR')
THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-1),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT THIRD YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-2),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FOURTH YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-3),'DD/MM/YYYY');

ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FIFTH YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-4),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SIXTH YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-5),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SEVENTH YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-6),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE HOLIDAY YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   OPEN	csr_saved_year_limit(p_assignment_id
                          , p_upload_date);
	FETCH csr_saved_year_limit INTO l_saved_year_limit;

   CLOSE csr_saved_year_limit;
   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-l_saved_year_limit+1),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE EARNING YEAR') THEN



   OPEN  csr_earning_year( p_assignment_id
                          , p_upload_date
                          );
   FETCH csr_earning_year
    INTO l_start_month,l_end_month;
   CLOSE csr_earning_year;

   --
   l_earn_end_year:=GET_EARN_END_YEAR(l_start_month,l_end_month,p_upload_date );

   OPEN	csr_saved_year_limit(p_assignment_id
                          , p_upload_date);
	FETCH csr_saved_year_limit INTO l_saved_year_limit;

   CLOSE csr_saved_year_limit;
   l_expiry_date:=TO_DATE('01/'||l_start_month||'/'||(l_earn_end_year-l_saved_year_limit),'DD/MM/YYYY');


ELSIF p_dimension_name IN ('ASSIGNMENT LAST 13 MONTHS DIMENSION FOR SE LEGISLATION') THEN
      l_expiry_date:=trunc(ADD_MONTHS(p_upload_date,-12),'MM');
ELSIF p_dimension_name IN ('LEGAL EMPLOYER MONTH') THEN
      l_expiry_date:=trunc(p_upload_date,'MM');
END IF;

RETURN l_expiry_date;



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


  IF p_dimension_name in ('ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY HOLIDAY YEAR',
			  'ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY EARNING YEAR',
 			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SEVENTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SIXTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FIFTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FOURTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT THIRD YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE HOLIDAY YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE EARNING YEAR',
			       'ASSIGNMENT LAST 13 MONTHS DIMENSION FOR SE LEGISLATION',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER EARNING YEAR',
			       'LEGAL EMPLOYER MONTH') THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;

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

       IF p_dimension_name IN ('ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY HOLIDAY YEAR',
        		       'ASSIGNMENT WITHIN LEGAL EMPLOYER ABSENCE CATEGORY EARNING YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SEVENTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT SIXTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FIFTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT FOURTH YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT THIRD YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE HOLIDAY YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER SAVED HOLIDAY LIMIT BEFORE EARNING YEAR',
			       'ASSIGNMENT LAST 13 MONTHS DIMENSION FOR SE LEGISLATION',
       			       'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR',
			       'ASSIGNMENT WITHIN LEGAL EMPLOYER EARNING YEAR',
			       'LEGAL EMPLOYER MONTH') THEN
	l_include_adj := 0 ;
           /*  OPEN csr_bal_adj(p_test_batch_line_id => p_test_batch_line_id,
                              p_batch_line_id => p_batch_line_id);

             FETCH csr_bal_adj INTO v_cur_bal_adj_st1;

             IF csr_bal_adj%NOTFOUND THEN
                l_include_adj := 0 ; -- False
             END IF;
             CLOSE csr_bal_adj;
       ELSE
          NULL;*/
       END IF;


       RETURN l_include_adj;

   END include_adjustment;

  PROCEDURE validate_batch_lines ( p_batch_id  IN  NUMBER) is
  BEGIN
    null;
  END;

  FUNCTION GET_EARN_END_YEAR(p_start_month varchar2,
  p_end_month varchar2,
  p_upload_date date)
  RETURN NUMBER IS

  BEGIN

  IF p_start_month = '01' AND p_end_month = '12'
      THEN

         RETURN TO_NUMBER (TO_CHAR (p_upload_date, 'YYYY'));
      ELSE
         IF TO_NUMBER (TO_CHAR (p_upload_date, 'MM')) <
                                                    TO_NUMBER (p_start_month)
         THEN

            RETURN TO_NUMBER (TO_CHAR (p_upload_date, 'YYYY') - 1);
         ELSE

            RETURN TO_NUMBER (TO_CHAR (p_upload_date, 'YYYY'));
         END IF;
      END IF;

  END;

END PAY_SE_BAL_UPLOAD;

/
