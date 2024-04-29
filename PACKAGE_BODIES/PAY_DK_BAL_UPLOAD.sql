--------------------------------------------------------
--  DDL for Package Body PAY_DK_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_BAL_UPLOAD" AS
/* $Header: pydkbalupl.pkb 120.1 2007/03/13 07:12:31 saurai noship $ */

   START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
   END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');


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
   --  p_original_entry_id - ORIGINAL_ENTRY_ID context.
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.dim_expiry_date.
   --  If the expiry date cannot be derived then it is set to the end of time
   --  to indicate that a failure has occured. The process that uses the
   --  expiry date knows this rule and acts accordingly.
   -----------------------------------------------------------------------------

  function expiry_date
  (
     p_upload_date       date,
     p_dimension_name    varchar2,
     p_assignment_id     number,
     p_original_entry_id number
  ) return date is

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

l_itd_start_date        date;
l_oe_start_date         date;
l_holiday_year		date;
l_expiry_date	        DATE;


  begin

    --fnd_file.put_line(fnd_file.log,'Entered PROCEDURE expiry_date -->'||p_dimension_name);

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
    --

    if(p_dimension_name = 'ASSIGNMENT CALENDAR HALF YEAR TO DATE'
       -- or p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
       -- or     p_dimension_name = 'PERSON WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
       )
    then
       --fnd_file.put_line(fnd_file.log,' Validate upload date -->'||to_char(p_upload_date, 'MM'));
       if to_char(p_upload_date, 'MM') in ('01','02','03','04','05','06')
       then
           --fnd_file.put_line(fnd_file.log,' Return date -->'||to_date('01/01/'||to_char(p_upload_date,'yyyy'),'DD/MM/YYYY'));
           l_expiry_date := to_date('01/01/'||to_char(p_upload_date,'yyyy'),'DD/MM/YYYY');
       else
           --fnd_file.put_line(fnd_file.log,' Return date -->'||to_date('01/07/'||to_char(p_upload_date,'yyyy'),'DD/MM/YYYY'));
           l_expiry_date := to_date('01/07/'||to_char(p_upload_date,'yyyy'),'DD/MM/YYYY');
       end if;
    elsif(p_dimension_name = 'ASSIGNMENT HOLIDAY YEAR TO DATE'
          -- or  p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR TO DATE'
       )
    then
       --fnd_file.put_line(fnd_file.log,' Validate upload date -->'||to_char(p_upload_date, 'MM'));

       		SELECT TO_DATE('0105'||TO_CHAR(p_upload_date,'YYYY'),'DD/MM/YYYY')
		INTO l_holiday_year
		FROM DUAL;

		IF p_upload_date >=  l_holiday_year THEN
			l_expiry_date := l_holiday_year;
		ELSE
			l_expiry_date := ADD_MONTHS(l_holiday_year , -12);
		END IF;

                hr_utility.trace('HY Start Date=' || l_expiry_date);
       --fnd_file.put_line(fnd_file.log,' l_expiry_date -->'||l_expiry_date);
    else
       return END_OF_TIME;
    end if;

  l_expiry_date := nvl(greatest(l_itd_start_date
                               ,l_expiry_date
                               ,nvl(l_oe_start_date, l_expiry_date)
                               ), END_OF_TIME);

  if (l_expiry_date <> END_OF_TIME) and (l_expiry_date > p_upload_date) then
    hr_utility.trace('Expiry date is later than upload_date! expiry_date='||l_expiry_date);
    --
    l_expiry_date := END_OF_TIME;
  end if;

  --fnd_file.put_line(fnd_file.log,' l_expiry_date -->'||l_expiry_date);
  hr_utility.trace('Final Expiry Date=' || l_expiry_date);

  RETURN l_expiry_date;

  end expiry_date;


   -----------------------------------------------------------------------------
   -- NAME
   --  is_supported
   -- PURPOSE
   --  Checks if the dimension is supported by the upload process.
   -- ARGUMENTS
   --  p_dimension_name - the balance dimension to be checked.
   -- USES
   -- NOTES
   --  Only a subset of the DK dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------

  function is_supported
  (
    p_dimension_name varchar2
  ) return number is
   begin
--      hr_utility.trace('Entering pay_kd_bal_upload.is_supported');
      --fnd_file.put_line(fnd_file.log,' Entered PROCEDURE IS_SUPPORTED'||p_dimension_name);
      if (p_dimension_name in
      (
        --'_ASG_LE_HYTD',
        -- '_PER_LE_HYTD',
        '_ASG_HYTD' ,
	'_ASG_HOLIDAY_YTD'
	--'_ASG_LE_HOLIDAY_YTD'
      )
      or
      (
         substr(p_dimension_name, 31, 4) = 'USER'
         and
         substr(p_dimension_name, 40, 3) = 'ASG'
      ))
      or
      (p_dimension_name = 'ASSIGNMENT CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'PERSON WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR TO DATE'
      or p_dimension_name = 'ASSIGNMENT HOLIDAY YEAR TO DATE'
      )
      then
         --fnd_file.put_line(fnd_file.log,' condition is true');
         return 1;
      else
         --fnd_file.put_line(fnd_file.log,' condition is false');
         return 0;
      end if;
      --fnd_file.put_line(fnd_file.log,' Exiting pay_dk_bal_upload.is_supported');
  end is_supported;


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

  function include_adjustment
   (
      p_balance_type_id    number,
      p_dimension_name     varchar2,
      p_original_entry_id  number,
      p_upload_date        date,
      p_batch_line_id      number,
      p_test_batch_line_id number
   ) return number is
   l_source_text varchar2(10);
   l_return number := 0;--TRUE;--True
   l_original_entry_id Number;
   l_include_adj BOOLEAN :=  TRUE ;
   Begin
      --fnd_file.put_line(fnd_file.log,' Entering pay_dk_bal_upload.include_adjustment');
      if (p_dimension_name = 'ASSIGNMENT CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'PERSON WITHIN LEGAL EMPLOYER CALENDAR HALF YEAR TO DATE'
      -- or p_dimension_name = 'ASSIGNMENT WITHIN LEGAL EMPLOYER HOLIDAY YEAR TO DATE'
      or p_dimension_name = 'ASSIGNMENT HOLIDAY YEAR TO DATE'
      )
      then  l_include_adj := TRUE;
      else

			NULL;
      end if;

      --fnd_file.put_line(fnd_file.log,' Exiting pay_dk_bal_upload.include_adjustment l_return:'||l_return);

      	 if  l_include_adj  then
            l_return := 1;
         else
             l_return := 0;
         end if;

      Return l_return;
  end include_adjustment;

       -----------------------------------------------------------------------------
     -- NAME
     --  validate_batch_lines
     -- PURPOSE
     --  Applies DK specific validation to the batch.
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


END PAY_DK_BAL_UPLOAD;


/
