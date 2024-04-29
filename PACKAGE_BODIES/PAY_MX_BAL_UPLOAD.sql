--------------------------------------------------------
--  DDL for Package Body PAY_MX_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_BAL_UPLOAD" AS
/* $Header: pymxupld.pkb 120.1 2005/12/28 14:29 vmehta noship $ */

 -- Date Constants
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');


--------------------------------------------------------------------------
-- Name           : EXPIRY_DATE                                         --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the expiry date of a             --
--                  given dimension relative to a upload date           --
-- Parameters     :                                                     --
--             IN : p_upload_date       DATE                            --
--                      the date on which the balance should be correct --
--                  p_dimension_name    VARCHAR2                        --
--                      the dimension being set                         --
--                  p_assignment_id     NUMBER                          --
--                      the assignment involved                         --
--                  p_original_entry_id NUMBER                          --
--                      ORIGINAL_ENTRY_ID context                       --
--            OUT : N/A                                                 --
--         RETURN : Date                                                --
--------------------------------------------------------------------------
FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER)
RETURN DATE IS

   --
   -- Returns the earliest date on which the assignment exists
   --
   cursor csr_ele_itd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ) is

     select nvl(min(ASG.effective_start_date), END_OF_TIME)
     from   per_all_assignments_f   ASG
     where  ASG.assignment_id         = p_assignment_id
       and  ASG.effective_start_date <= p_upload_date;

   --
   -- Returns the start date of the current period on the upload date.
   --
   cursor csr_period_start
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(PTP.start_date, END_OF_TIME)
     from   per_time_periods  PTP
           ,per_assignments_f ASS
     where  ASS.assignment_id = p_assignment_id
       and  p_upload_date       between ASS.effective_start_date
                                    and ASS.effective_end_date
       and  PTP.payroll_id    = ASS.payroll_id
       and  p_upload_date      between PTP.start_date
				   and PTP.end_date;

   --
   -- Returns the assignment start date
   --

   cursor csr_asg_start_date
     (p_assignment_id number
     ,p_upload_date   date
     ,p_expiry_date   date
     ) is
     select nvl(greatest(min(ASS.effective_start_date), p_expiry_date),
                END_OF_TIME)
       from per_all_assignments_f ASS
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and ASS.effective_end_date >= p_expiry_date;

   --
   -- Returns the bimonth date relative to upload date
   --

   cursor csr_get_bimonth_date
          (p_upload_date   date
          ) is
   select ADD_MONTHS(TRUNC(p_upload_date, 'Y'),
                       TO_CHAR(p_upload_date, 'MM') -
                       DECODE(MOD(TO_NUMBER(TO_CHAR(p_upload_date,'MM')),2),
                              1, 1,
                              0, 2)
                              )
    from dual ;

   -- Holds the start of the period for the upload date.
   l_prd_start_date              date;

   -- Holds the start of the tax month for the upload date.
   l_tax_month_start_date        date;

   -- Holds the start of the tax year for the upload date.
   l_tax_yr_start_date           date;

   -- Holds the start of the bimonth date for the upload date.
   l_bimonth_date        date;

   l_expiry_date                 date;

Begin

if p_dimension_name in ( 'ASSIGNMENT WITHIN GRE INCEPTION TO DATE' ) then

     --
     -- What is the earliest date on which the element entry exists and the
     -- assignment belongs to a specific legal company ??
     --
     open csr_ele_itd_start(p_assignment_id
                           ,p_upload_date
			   );
     fetch csr_ele_itd_start into l_expiry_date;
     close csr_ele_itd_start;
     --

elsif p_dimension_name in
       ( 'PERSON WITHIN PAYROLL AND GRE PERIOD TO DATE',
         'ASSIGNMENT WITHIN GRE PERIOD TO DATE' ) then

     --
     -- What is the current period start date ?
     --
     open  csr_period_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_period_start into l_prd_start_date;
     close csr_period_start;

     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_prd_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;


elsif p_dimension_name in
      ( 'PERSON WITHIN GRE MONTH TO DATE',
        'ASSIGNMENT WITHIN GRE MONTH TO DATE' ) then

     l_tax_month_start_date := trunc(p_upload_date, 'MM');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_month_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;


elsif p_dimension_name in
     ('PERSON WITHIN GRE YEAR TO DATE',
      'ASSIGNMENT WITHIN GRE YEAR TO DATE' ) then

     --
     -- What is the start date of the tax year ?
     --
     l_tax_yr_start_date := trunc(p_upload_date, 'Y');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_yr_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;

elsif p_dimension_name in
      ( 'PERSON WITHIN GOVERNMENT REPORTING ENTITY FOR SOCIAL SECURITY BI-MONTH' ) then
    -- nearest two month period from the upload date
    -- upload date = 17-Feb-2005 then expiry_date= 01-Jan-2005
    -- upload date = 20-Mar-2005 then expiry_date= 01-Mar-2005

    open  csr_get_bimonth_date(p_upload_date);
    fetch csr_get_bimonth_date into l_bimonth_date;
    close csr_get_bimonth_date;

    open csr_asg_start_date(p_assignment_id
                           ,p_upload_date
                           ,l_bimonth_date);
    fetch csr_asg_start_date into l_expiry_date;
    close csr_asg_start_date;

end if;

   --
   -- return the date on which the dimension expires.
   --

   RETURN l_expiry_date;

END expiry_date;


--------------------------------------------------------------------------
-- Name           : IS_SUPPORTED                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to check if the specified dimension is     --
--                  supported for Mexico Localization                    --
-- Parameters     :                                                     --
--             IN : p_dimension_name    VARCHAR2                        --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION is_supported ( p_dimension_name VARCHAR2)
RETURN NUMBER
IS
BEGIN
   --
  -- hr_utility.trace('Entering pay_mx_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name IN
       ('PERSON WITHIN GRE YEAR TO DATE'
       ,'PERSON WITHIN GRE MONTH TO DATE'
       ,'PERSON WITHIN PAYROLL AND GRE PERIOD TO DATE'
       ,'ASSIGNMENT WITHIN GRE YEAR TO DATE'
       ,'ASSIGNMENT WITHIN GRE MONTH TO DATE'
       ,'ASSIGNMENT WITHIN GRE PERIOD TO DATE'
       ,'PERSON WITHIN GOVERNMENT REPORTING ENTITY FOR SOCIAL SECURITY BI-MONTH'
       ,'ASSIGNMENT WITHIN GRE INCEPTION TO DATE' )
   then
     RETURN (1);  -- denotes TRUE
   else
     RETURN (0);  -- denotes FALSE
   end if;
   --
   --   hr_utility.trace('Exiting pay_mx_bal_upload.is_supported');
   --
END is_supported;


-- Function to check if adjustment is required for a particular Dimension.
-- p_test_batch_line_id identifies the adjustment that has already been processed
-- p_batch_line_id identifies the adjustment currently being processed.
--------------------------------------------------------------------------
--                                                                      --
-- Name           : INCLUDE_ADJUSTMENT                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to perform balance adjustment Given a      --
--                  dimension, and relevant contexts and details of an  --
--                  existing balance adjustment, it will find out       --
--                  if the balance adjustment effects the dimension to  --
--                  be set. Both the dimension to be set and the        --
--                  adjustment are for the same assignment and balance. --
--                  The adjustment also lies between the expiry date of --
--                  the new balance and the date on which it is to set. --
-- Parameters     :                                                     --
--             IN : p_balance_type_id    NUMBER                         --
--                  p_dimension_name     VARCHAR2                       --
--                  p_original_entry_id  NUMBER                         --
--                  p_upload_date        DATE                           --
--                  p_batch_line_id      NUMBER                         --
--                  p_test_batch_line_id NUMBER                         --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
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
			, p_bal_adj_source_id         NUMBER
                        , p_bal_adj_original_entry_id NUMBER
                        ) IS
  SELECT BT.balance_type_id
  FROM   pay_balance_types BT
  WHERE  BT.balance_type_id = p_balance_type_id
            --
            -- JURISDICTION_CODE context NB. if the jurisdiction code is
            -- used then only those adjustments which are for the same
            -- jurisdiction code can be included.
            --
       and  ((p_source_id is null)    or
             (p_source_id is not null and p_source_id = p_bal_adj_source_id))
	   --
	   --
	    -- ORIGINAL_ENTRY_ID context NB. this context controls the expiry
	    -- date of the dimension in the same way as the QTD dimension. Any
	    -- existing balance adjustments that lie between the upload date
	    -- and the expiry date are all included. There is no special
	    -- criteria that has to be met.
	    --
  AND  1 = 1;

  l_bal_type_id       pay_balance_types.balance_type_id%TYPE;

  -- Get the jurisdiction code from the original balance batch line
  --
  cursor csr_get_source_id(p_batch_line_id  number)
  is
    select pbbl.source_id
    from   pay_balance_batch_lines pbbl
          ,hr_organization_units hou
    where  pbbl.batch_line_id = p_batch_line_id
      and  pbbl.source_id=hou.organization_id;

  -- Get jurisdiction code and original_entry_id for previously tested adjustments
  CURSOR csr_get_tested_adjustments(p_test_batch_line_id NUMBER) IS
  SELECT source_id
        ,original_entry_id
  FROM   pay_temp_balance_adjustments
  WHERE  batch_line_id = p_test_batch_line_id;

  -- The balance returned by the include check.

  l_adj_orig_entry_id pay_temp_balance_adjustments.original_entry_id%TYPE;
  l_source_id number;
  l_adj_source_id number;

BEGIN


  OPEN csr_get_source_id(p_batch_line_id);
  FETCH csr_get_source_id INTO l_source_id;
  CLOSE csr_get_source_id;
   --

  OPEN  csr_get_tested_adjustments(p_test_batch_line_id);
  FETCH csr_get_tested_adjustments
  INTO   l_adj_source_id
       , l_adj_orig_entry_id;
  CLOSE csr_get_tested_adjustments;

  -- Does the balance adjustment effect the new balance ?

  hr_utility.trace('balance_type_id      = '||TO_CHAR(p_balance_type_id));

  --hr_utility.trace('jurisdiction_id    = '||TO_CHAR(l_jurisdiction_code));
  hr_utility.trace('original_entry_id    = '||TO_CHAR(p_original_entry_id));

  -- hr_utility.trace('BA jurisdiction_id    = '||TO_CHAR(l_adj_jurisdiction_code));
  hr_utility.trace('BA original_entry_id = '||TO_CHAR(l_adj_orig_entry_id));

  OPEN  csr_is_included(p_balance_type_id
                       ,l_source_id
                       ,p_original_entry_id
                       ,l_adj_source_id
                       ,l_adj_orig_entry_id
                       );
  FETCH csr_is_included INTO l_bal_type_id;
  CLOSE csr_is_included;

  --hr_utility.trace('Exiting pay_mx_bal_upload.include_adjustment_test');

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

    IF csr_get_source_id%ISOPEN THEN
       CLOSE csr_is_included;
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
-- Description    : Procedure to apply MX specific validation           --
--                  and/or user-defined validation to the batch         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_batch_id           NUMBER                         --
--            OUT : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE validate_batch_lines (p_batch_id NUMBER)
IS

BEGIN
   --
   hr_utility.trace('Entering pay_mx_bal_upload.validate_batch_lines');
   --
   hr_utility.trace('Exiting pay_mx_bal_upload.validate_batch_lines');
   --
END validate_batch_lines;

END pay_mx_bal_upload;


/
