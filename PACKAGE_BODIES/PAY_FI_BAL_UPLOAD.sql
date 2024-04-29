--------------------------------------------------------
--  DDL for Package Body PAY_FI_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_BAL_UPLOAD" AS
/* $Header: pyfibupl.pkb 120.0.12000000.1 2007/04/26 11:57:45 dbehera noship $ */
   --
   -- Date constants.
   --
   start_of_time CONSTANT DATE := TO_date('01/01/0001','DD/MM/YYYY');
   end_of_time   CONSTANT DATE := TO_date('31/12/4712','DD/MM/YYYY');

   procedure get_expiry_date_info
   (p_assignment_id  in             number
   ,p_upload_date    in             date
   ,p_itd_start_date    out  nocopy date
   )
 is

   cursor csr_itd_start_date
   is
   select
     greatest(min(asg.effective_start_date)
             ,min(ptp.start_date))
   from
     per_all_assignments_f asg
    ,per_time_periods  ptp
   where asg.assignment_id = p_assignment_id
   and ptp.payroll_id   = asg.payroll_id
   and ptp.start_date <= asg.effective_end_date;

   l_itd_start_date date;

 begin

     open csr_itd_start_date;
     fetch csr_itd_start_date into l_itd_start_date;
     close csr_itd_start_date;

     l_itd_start_date := nvl(l_itd_start_date, END_OF_TIME);

   --
   -- Check to see if the start date is before the upload date.
   --
   if l_itd_start_date <= p_upload_date then
     p_itd_start_date := l_itd_start_date;
   else
     p_itd_start_date := END_OF_TIME;
   end if;

 end get_expiry_date_info;

   -----------------------------------------------------------------------------
   -- NAME
   --  expiry_date
   -- PURPOSE
   --  Returns the expiry date of a given dimension relative to a date.
   -- ARGUMENTS
   --  p_upload_date       - the date on which the balance should be correct.
   --  p_dimension_name    - the dimension being set.
   --  p_assignment_id     - the assignment involved.
   --  p_original_entry_id - Original_entry_id context.
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.dim_expiry_date.
   --  If the expiry date cannot be derived then it is set to the end of time
   --  to indicate that a failure has occured. The process that uses the
   --  expiry DATE knows this rule and acts accordingly.
   -----------------------------------------------------------------------------
   -- -------------------------------------------------------------------------
-- Funtion to return expiry date for supported Routes.
-- -------------------------------------------------------------------------
  FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER)
		 RETURN DATE IS

-- period start date
--
CURSOR csr_start_of_date
		(p_assignment_id	NUMBER
		,p_upload_date		DATE
		) IS
SELECT  ptp.start_date
FROM	per_all_assignments_f ass
       ,per_time_periods  ptp
WHERE	ass.assignment_id = p_assignment_id
AND 	ass.effective_start_date <= p_upload_date
AND	ass.effective_end_date	 >= p_upload_date
AND 	ptp.payroll_id		  = ass.payroll_id
AND 	p_upload_date BETWEEN ptp.start_date
AND     ptp.end_date;

l_expiry_date	DATE;
l_business_group_id	PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID%TYPE;
l_itd_start_date        date;
--l_oe_start_date         date;
 l_holiday_year		date;
BEGIN

    hr_utility.trace('Entering pay_ip_bal_upload.expiry_date');

    --
    -- Get the ITD start date.
    --
    get_expiry_date_info
       (p_assignment_id  => p_assignment_id
       ,p_upload_date    => p_upload_date
       ,p_itd_start_date => l_itd_start_date
       );
    --
    hr_utility.trace('Asg Start Date='||l_itd_start_date);

IF  p_dimension_name IN ('ASSIGNMENT HOLIDAY PERIOD TO DATE') THEN

	open csr_start_of_date(p_assignment_id, p_upload_date);
	fetch csr_start_of_date into l_expiry_date;
	close csr_start_of_date;
        hr_utility.trace('Period Start Date=' || l_expiry_date);

ELSIF  p_dimension_name IN ('ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER INCEPTION TO DATE') THEN
		l_expiry_date := l_itd_start_date;
                hr_utility.trace('Asg Start Date=' || l_expiry_date);

ELSIF  p_dimension_name IN ('ASSIGNMENT HOLIDAY MONTH TO DATE') THEN
		l_expiry_date := TRUNC(p_upload_date,'MM');
                hr_utility.trace('Mth Start Date=' || l_expiry_date);

ELSIF  p_dimension_name IN ('ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER YEAR TO DATE') THEN
		l_expiry_date := TRUNC(p_upload_date,'Y');
                hr_utility.trace('Year Start Date=' || l_expiry_date);

ELSIF  p_dimension_name IN ('ASSIGNMENT HOLIDAY YEAR TO DATE') THEN

		SELECT TO_DATE('0104'||TO_CHAR(p_upload_date,'YYYY'),'DD/MM/YYYY')
		INTO l_holiday_year
		FROM DUAL;

		IF p_upload_date >=  l_holiday_year THEN
			l_expiry_date := l_holiday_year;
		ELSE
			l_expiry_date := ADD_MONTHS(l_holiday_year , -12);
		END IF;

                hr_utility.trace('HY Start Date=' || l_expiry_date);

ELSE
  --
  -- Dimension not supported.
  --
  l_expiry_date := END_OF_TIME;
  hr_utility.trace('Dimension Not Supported. ' || p_dimension_name);

END IF;

  l_expiry_date := nvl(greatest(l_itd_start_date
                               ,l_expiry_date
                               ), END_OF_TIME);

  if (l_expiry_date <> END_OF_TIME) and (l_expiry_date > p_upload_date) then
    hr_utility.trace('Expiry date is later than upload_date! expiry_date='||l_expiry_date);
    --
    l_expiry_date := END_OF_TIME;
  end if;

    hr_utility.trace('Exiting pay_ip_bal_upload.expiry_date');

RETURN l_expiry_date;

END expiry_date;

   -----------------------------------------------------------------------------
   -- NAME
   --  is_supported
   -- PURPOSE
   --  Checks if the dimension is supported by the upload process.
   -- ARGUMENTS
   --  p_dimension_name - the balance dimension to be checked.
   -- USES
   -- NOTES
   --  Only a subset of the FI dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------
   FUNCTION is_supported(p_dimension_name VARCHAR2) RETURN NUMBER IS
      p_dimension_name_temp VARCHAR2(100);
    BEGIN
      -- See if the dimension is supported.
      IF p_dimension_name IN ('ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER INCEPTION TO DATE',
							'ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER YEAR TO DATE',
							'ASSIGNMENT HOLIDAY MONTH TO DATE',
							'ASSIGNMENT HOLIDAY PERIOD TO DATE',
							'ASSIGNMENT HOLIDAY YEAR TO DATE')

	THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
      hr_utility.trace('Exiting pay_fi_bal_upload.is_supported stub');
   END is_supported;
   -----------------------------------------------------------------------------
   -- NAME
   --  include_adjustment
   -- PURPOSE
   --  Given a dimension, and relevant contexts and details of an existing
   --  balance adjustment, it will find out if the balance adjustment effects
   --  the dimension to be set. Both the dimension to be set and the adjustment
   --  are for the same assignment and balance.
   -- ARGUMENTS
   --  p_balance_type_id    - the balance to be set.
   --  p_dimension_name     - the balance dimension to be set.
   --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
   --  p_test_batch_line_id -
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.get_current_value.
   -----------------------------------------------------------------------------
 FUNCTION include_adjustment
 	(
	  p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 ) RETURN NUMBER IS

    	CURSOR csr_bal_adj_st1 (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.source_text ,  tba.tax_unit_id
	  FROM   pay_temp_balance_adjustments tba,
		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	 AND    nvl(tba.balance_type_id ,0) = nvl(bbl.balance_type_id ,0)
	  AND    nvl(tba.source_text ,0) = nvl(bbl.source_text ,0)
	  AND    nvl(tba.tax_unit_id,0) = nvl(bbl.tax_unit_id,0)
	  AND  tba.tax_unit_id IS NOT NULL
	  AND  tba.source_text IS NOT NULL;

	l_include_adj BOOLEAN :=  TRUE ;
	v_cur_bal_adj_st1  csr_bal_adj_st1%ROWTYPE;

   BEGIN
	       hr_utility.trace('Entering pay_fi_bal_upload.include_adjustment stub');

		IF p_dimension_name IN ('ASSIGNMENT HOLIDAY PERIOD TO DATE',
								'ASSIGNMENT HOLIDAY MONTH TO DATE',
								'ASSIGNMENT HOLIDAY YEAR TO DATE') THEN

			 l_include_adj := TRUE;

		 ELSIF p_dimension_name IN ('ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER INCEPTION TO DATE','ASSIGNMENT EMPLOYMENT TYPE LEGAL EMPLOYER YEAR TO DATE') THEN

			 OPEN csr_bal_adj_st1(p_test_batch_line_id => p_test_batch_line_id,
			 p_batch_line_id => p_batch_line_id);

			 FETCH csr_bal_adj_st1 INTO v_cur_bal_adj_st1;

			 IF csr_bal_adj_st1%NOTFOUND THEN
			      l_include_adj := FALSE ;
			 END IF;

			 CLOSE csr_bal_adj_st1;

		ELSE

			NULL;

		END IF;

	    hr_utility.trace('Exiting pay_fi_bal_upload.include_adjustment');

	  if  l_include_adj  then
            RETURN 1;
         else
             RETURN 0;
         end if;

   END include_adjustment;
       -----------------------------------------------------------------------------
     -- NAME
     --  validate_batch_lines
     -- PURPOSE
     --  Applies FI specific validation to the batch.
     -- ARGUMENTS
     --  p_batch_id - the batch to be validate_batch_linesd.
     -- USES
     -- NOTES
     --  This is used by pay_balance_upload.validate_batch_lines.
     -----------------------------------------------------------------------------
   --
     PROCEDURE validate_batch_lines(p_batch_id NUMBER) IS
     BEGIN
        hr_utility.trace('Entering pay_fi_bal_upload.validate_batch_lines stub');
        hr_utility.trace('Exiting pay_fi_bal_upload.validate_batch_lines stub' );
     END validate_batch_lines;

END pay_fi_bal_upload;

/
