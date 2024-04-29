--------------------------------------------------------
--  DDL for Package Body PAY_ES_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_BAL_UPLOAD" AS
/* $Header: pyesbupl.pkb 120.1 2005/05/31 02:02:09 vbattu noship $ */
   --
   -- Date constants.
   --
   start_of_time CONSTANT DATE := TO_date('01/01/0001','DD/MM/YYYY');
   end_of_time   CONSTANT DATE := TO_date('31/12/4712','DD/MM/YYYY');
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
   FUNCTION expiry_date (p_upload_date       DATE
                        ,p_dimension_name    VARCHAR2
                        ,p_assignment_id     NUMBER
                        ,p_original_entry_id NUMBER) RETURN DATE IS
    -- Returns the legislative start date
          CURSOR csr_tax_start_date   IS
	      SELECT rule_mode
	      FROM   pay_legislation_rules
	      WHERE  legislation_code   ='ES'
	      AND    rule_type          = 'L';
   -- Holds the legislative start date
      l_leg_start          pay_legislation_rules.rule_mode%TYPE;
   -- Returns the start date of the first period of the tax year in which
   -- the upload date falls.
   -- 1)  to_char(to_date(p_upload_date,'DD/MM/YYYY'),'YYYY')
   --     retuned incorrect output depening on the date setting
   --     of the env. to_date(p_upload_date,'DD/MM/YYYY') is not needed as
   --      p_upload_date is a date!
   -- 2)   if the upload is being done on say 01-jan-2003, it would return null
   --      record as below condition will not be fulfilled
   --      ptp2.start_date between
   --      to_date(l_leg_start||to_char(to_date(
   --      p_upload_date,'DD/MM/YYYY'),'YYYY'),'DD/MM/YYYY')
   --      and ptp.end_date;
   --      But due to 1, condition 2 did not happen and it returned the
   --      first period of the payroll which is incorrect.
   --      if 1 is fixed ,  then condtion 2 would occur.
   -- Returns the start DATE of the current period on the upload date.
   CURSOR csr_period_start (p_assignment_id NUMBER
                           ,p_upload_date   DATE) IS
	   SELECT nvl(ptp.start_date, end_of_time)
	   FROM   per_time_periods   ptp
	         ,per_assignments_f  ass
	   WHERE  ass.assignment_id  = p_assignment_id
	   AND    ptp.payroll_id     = ass.payroll_id
	   AND    p_upload_date between ass.effective_start_date and ass.effective_end_date
	   AND    p_upload_date between ptp.start_date and ptp.end_date;
   -- Returns the start date of the assignment.
   CURSOR csr_asg_itd_start(p_assignment_id NUMBER
			   ,p_upload_date   DATE) IS
	   SELECT  nvl(min(ass.effective_start_date), end_of_time)
	   FROM    per_assignments_f ass
	   WHERE   ass.assignment_id         = p_assignment_id
	   AND     ass.payroll_id            IS NOT NULL
	   AND     ass.effective_start_date <= p_upload_date;
   -- Generic start date variable.
   l_start_date            DATE;
   -- Holds the assignment start date.
   l_asg_itd_start_date    DATE;
   --Holds the LQTD start date.
   l_lqtd_start_date       DATE;
   --Holds month start date
   l_month_start_date	   DATE;
   -- Holds the first regular payment date after the expiry date of the dimension.
   l_regular_date          DATE;
   -- Holds the expiry date of the dimension.
   l_expiry_date           DATE;
   -- Holds the business group of the dimension.
   l_business_group_id     NUMBER;
   -- Holds the start date of the quarter.
   l_qtr_start_date        DATE;
   -- Holds theearliest date an element entry
   l_ele_itd_start_date    DATE;
   --Used for _ASG_LQTD expiry date calculation
   BEGIN_date		       DATE;
   end_date		           DATE;
   CURSOR csr_payroll_start_date (p_assignment_id NUMBER
				                 ,p_upload_date   DATE) IS
	   SELECT nvl(ppf.effective_start_date, end_of_time)
	   FROM   per_all_assignments_f ass
		     ,pay_all_payrolls_f ppf
	   WHERE  ass.assignment_id = p_assignment_id
	   AND    p_upload_date BETWEEN
			     nvl(ass.effective_start_date,p_upload_date) AND
			     nvl(ass.effective_end_date,p_upload_date)
	   AND  ppf.payroll_id      = ass.payroll_id
	   AND  p_upload_date BETWEEN
			     nvl(ppf.effective_start_date,p_upload_date) AND
			     nvl(ppf.effective_end_date,p_upload_date);
   --
   -- Returns the earliest DATE on which the element entry exists.
   --
   CURSOR csr_ele_itd_start(p_assignment_id     NUMBER
			               ,p_upload_date       DATE
			               ,p_original_entry_id NUMBER) IS
	   SELECT nvl(min(EE.effective_start_date), end_of_time)
	   FROM   pay_element_entries_f EE
	   WHERE  EE.assignment_id         = p_assignment_id
	   AND   (EE.element_entry_id      = p_original_entry_id OR
		      EE.original_entry_id     = p_original_entry_id)
	   AND    EE.effective_start_date <= p_upload_date;
   --
   --Holds the tax year start DATE for the upload process
   l_tax_year		DATE;
   --------------------------------------------------------------------------------------
   BEGIN --                        Expiry_date - Main                                  --
   --------------------------------------------------------------------------------------
      -- What is the start DATE of the assignment? All loading must come after this DATE.
      OPEN csr_asg_itd_start(p_assignment_id
			                ,p_upload_date);
      FETCH csr_asg_itd_start INTO l_asg_itd_start_date;
      CLOSE csr_asg_itd_start;
      -- RETURN the date on which the dimension expires.
     IF substr(p_dimension_name, 31, 4) = 'USER' THEN
         -- User balance
         SELECT  business_group_id
         INTO    l_business_group_id
         FROM    per_assignments_f
         WHERE   assignment_id = p_assignment_id;
         l_expiry_date := hr_gbbal.dimension_reset_date(p_dimension_name
						                               ,p_upload_date
						                               ,l_business_group_id);
         l_expiry_date := GREATEST(l_expiry_date, l_asg_itd_start_date);
     ELSIF p_dimension_name IN ('ASSIGNMENT DEDUCTION KEY PERIOD TO DATE',
				                'ASSIGNMENT PAYMENT KEY PERIOD TO DATE') THEN
         -- Calculate expiry DATE for '_PTD' dimensions.
         -- What is the current period start DATE?
         OPEN csr_period_start(p_assignment_id
			                  ,p_upload_date);
         FETCH csr_period_start INTO l_start_date;
         CLOSE csr_period_start;
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);
     ELSIF p_dimension_name  IN ('ASSIGNMENT DEDUCTION KEY CALENDAR YEAR TO DATE',
				                 'ASSIGNMENT PAYMENT KEY CALENDAR YEAR TO DATE') THEN
         OPEN csr_tax_start_date;
  	     FETCH csr_tax_start_date INTO l_leg_start;
         CLOSE csr_tax_start_date;
        -- Calculate expiry date for '_YTD' dimensions.
        -- What is the current tax year start DATE?
        -- calculate the the payroll start DATE
         OPEN csr_payroll_start_date(p_assignment_id
				                    ,p_upload_date);
         FETCH csr_payroll_start_date INTO l_start_date;
         CLOSE csr_payroll_start_date;
         -- calculate the tax year start date for the upload process
         l_tax_year    := to_date(l_leg_start || to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');
        -- calculate the expiry DATE
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date,l_tax_year );
     ELSIF p_dimension_name IN ('ASSIGNMENT DEDUCTION KEY CALENDAR QUARTER TO DATE',
				                'ASSIGNMENT PAYMENT KEY CALENDAR QUARTER TO DATE') THEN
         -- calculate the qtr start date
         l_qtr_start_date :=  trunc(p_upload_date,'Q');
         -- calculate the the payroll start date
         OPEN csr_payroll_start_date(p_assignment_id
				                    ,p_upload_date);
         FETCH csr_payroll_start_date INTO l_start_date;
         CLOSE csr_payroll_start_date;
         -- calculate the expiry date
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date, l_qtr_start_date );
     END IF;
     RETURN nvl(l_expiry_date,end_of_time);
     EXCEPTION
        WHEN no_data_found THEN
           l_expiry_date := end_of_time;
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
   --  Only a subset of the ES dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------
   FUNCTION is_supported(p_dimension_name VARCHAR2) RETURN NUMBER IS
      p_dimension_name_temp VARCHAR2(100);
    BEGIN
      -- See if the dimension is supported.
      IF p_dimension_name IN ('ASSIGNMENT DEDUCTION KEY CALENDAR QUARTER TO DATE',
                              'ASSIGNMENT DEDUCTION KEY CALENDAR YEAR TO DATE',
                              'ASSIGNMENT DEDUCTION KEY PERIOD TO DATE',
                              'ASSIGNMENT PAYMENT KEY CALENDAR QUARTER TO DATE',
                              'ASSIGNMENT PAYMENT KEY CALENDAR YEAR TO DATE',
                              'ASSIGNMENT PAYMENT KEY PERIOD TO DATE',
                              'PERSON RUN' )
      OR (  substr(p_dimension_name, 31, 4) = 'USER'
             AND
            substr(p_dimension_name, 40, 3) = 'ASG'   ) THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
      hr_utility.trace('Exiting pay_es_bal_upload.is_supported stub');
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
   --  p_bal_adjustment_rec - details of an existing balance adjustment.
   --  p_test_batch_line_id -
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.get_current_value.
   -----------------------------------------------------------------------------
   FUNCTION include_adjustment (p_balance_type_id    NUMBER
			                   ,p_dimension_name     VARCHAR2
			                   ,p_original_entry_id  NUMBER
			                   ,p_upload_date        DATE
			                   ,p_batch_line_id      NUMBER
			                   ,p_test_batch_line_id NUMBER) RETURN NUMBER IS
      CURSOR csr_bal_adj(p_test_batch_line_id NUMBER
	  		            ,p_batch_line_id      NUMBER) IS
	  SELECT tba.source_text,tba.source_text2,tba.balance_type_id
	  FROM   pay_temp_balance_adjustments tba,
    		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id;
	  l_source_text1 VARCHAR2(10);
  	  l_source_text2 VARCHAR2(10);
	  l_RETURN 	 NUMBER := 0; -- False
          v_cur_bal_adj  csr_bal_adj%ROWTYPE;
   BEGIN
       hr_utility.trace('Entering pay_es_bal_upload.include_adjustment stub');
       --Select source text/source text2 of the current batch line
       SELECT source_text    ,source_text2
       INTO   l_source_text1 ,l_source_text2
       FROM   pay_balance_batch_lines
       WHERE  batch_line_id = p_batch_line_id;
       --For context balances
       IF (l_source_text1 IS NOT NULL) OR (l_source_text2 IS NOT NULL) THEN
       	  OPEN csr_bal_adj(p_test_batch_line_id
			              ,p_batch_line_id);
       	  FETCH csr_bal_adj INTO v_cur_bal_adj;
       	  --Two different dimensions of the same balance and same context, hence adjustment needs to be done
       	  IF v_cur_bal_adj.source_text=l_source_text1 AND v_cur_bal_adj.balance_type_id=p_balance_type_id THEN
        	 l_RETURN := 1; -- True
      	  ELSIF (v_cur_bal_adj.source_text2      = l_source_text2) AND 						                    (v_cur_bal_adj.balance_type_id   = p_balance_type_id) THEN
        	 l_RETURN := 1; -- True
	  END IF;
       	 --When no other dimension of the same balance has been processed before
      	 -- IF csr_bal_adj%NOTFOUND THEN
         --	 l_RETURN  := 0; -- False
      	 -- END IF;
       	  CLOSE csr_bal_adj;
       --For non context balances , adjustment should be done
       ELSE
		l_RETURN := 1;
       END IF;
      hr_utility.trace('Exiting pay_es_bal_upload.include_adjustment stub');
      RETURN l_return;
   END include_adjustment;
   --
    -----------------------------------------------------------------------------
    -- NAME
    --  get_tax_unit
    -- PURPOSE
    --  Returns the legal company an assignment is associated with at
    --  particular point in time.
    -- ARGUMENTS
    --  p_assignment_id  - the assignment
    --  p_effective_date - the DATE on which the information is required.
    -- USES
    -- NOTES
    -----------------------------------------------------------------------------
   --
   FUNCTION get_tax_unit (p_assignment_id  NUMBER
			             ,p_effective_date DATE) RETURN NUMBER IS
     --
      CURSOR csr_get_wc_details IS
	      SELECT scl.segment2                 work_center
	      FROM   per_all_assignments_f        paaf
		        ,hr_soft_coding_keyflex       scl
	      WHERE  paaf.assignment_id           = p_assignment_id
	      AND    paaf.soft_coding_keyflex_id  = scl.soft_coding_keyflex_id
	      AND    p_effective_date             BETWEEN effective_start_date
						                      AND     effective_end_date;
    --
      CURSOR csr_get_le_details (p_wc_organization_id NUMBER) IS
	      SELECT hoi.organization_id          le_id
	      FROM   hr_organization_information  hoi
	      WHERE  hoi.org_information1         = p_wc_organization_id
	      AND    hoi.org_information_context  = 'ES_WORK_CENTER_REF';
    --
      l_wc_id         hr_all_organization_units.organization_id%TYPE;
      l_tax_unit_id   NUMBER;
   --
   BEGIN
      --
      hr_utility.trace('Entering pay_es_bal_upload.get_tax_unit');
      --
      l_tax_unit_id  := NULL;
      l_wc_id        := NULL;
      --
      OPEN  csr_get_wc_details;
      FETCH csr_get_wc_details INTO l_wc_id;
      CLOSE csr_get_wc_details;
      --
      IF  l_wc_id IS NOT NULL THEN
	  OPEN  csr_get_le_details(l_wc_id);
	  FETCH csr_get_le_details INTO l_tax_unit_id;
	  CLOSE csr_get_le_details;
      END IF;
      --
      --
      -- RETURN the tax unit.
      --
      RETURN (l_tax_unit_id);
      --
      hr_utility.trace('Exiting pay_es_bal_upload.get_tax_unit');
      --
   END get_tax_unit;
   --
     -----------------------------------------------------------------------------
     -- NAME
     --  validate_batch_lines
     -- PURPOSE
     --  Applies ES specific validation to the batch.
     -- ARGUMENTS
     --  p_batch_id - the batch to be validate_batch_linesd.
     -- USES
     -- NOTES
     --  This is used by pay_balance_upload.validate_batch_lines.
     -----------------------------------------------------------------------------
   --
     PROCEDURE validate_batch_lines(p_batch_id NUMBER) IS
     BEGIN
        hr_utility.trace('Entering pay_es_bal_upload.validate_batch_lines stub');
        hr_utility.trace('Exiting pay_es_bal_upload.validate_batch_lines stub' );
     END validate_batch_lines;
END pay_es_bal_upload;

/
