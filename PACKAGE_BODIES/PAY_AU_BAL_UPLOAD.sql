--------------------------------------------------------
--  DDL for Package Body PAY_AU_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_BAL_UPLOAD" as
 --  $Header: pyaubaup.pkb 120.3.12010000.2 2008/12/16 04:27:29 skshin ship $

  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved

  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  16 Dec 2008 skshin   7644243    Modified c_assignment cursor in expiry_date
  --  21 Aug 2006 priupadh 5477861    Modified expiry_date
  --  06 Sep 2005 ksingla             Added dbdrv comments
  --  06 Sep 2005 ksingla             Modified for Bug 4516174.
  --  17 Feb 2000 JTurner             Completed development
  --  28-DEC-1999 sgoggin             Genesis

  g_package                       constant varchar2(240) := 'pay_au_bal_upload.';

  -- date constants.

  g_end_of_time                   constant date := to_date('31/12/4712','dd/mm/yyyy');
  g_tax_year_start                constant varchar2(6) := '01-07-';
  g_fbt_year_start                constant varchar2(6) := '01-04-';
  g_cal_year_start                constant varchar2(6) := '01-01-';



  -----------------------------------------------------------------------------
  -- name
  --  expiry_date
  -- purpose
  --  returns the expiry date of a given dimension relative to a date.
  -- arguments
  --  p_upload_date       - the date on which the balance should be correct.
  --  p_dimension_name    - the dimension being set.
  --  p_assignment_id     - the assignment involved.
  --  p_original_entry_id - original_entry_id context.
  -- uses
  -- notes
  --  this is used by pay_balance_upload.dim_expiry_date.
  --  if the expiry date cannot be derived then it is set to the end of time
  --  to indicate that a failure has occured. the process that uses the
  --  expiry date knows this rule and acts accordingly.
  -----------------------------------------------------------------------------

  function expiry_date
  (p_upload_date       date
  ,p_dimension_name    varchar2
  ,p_assignment_id     number
  ,p_original_entry_id number)
  return date is

    l_fn_name                       varchar2(61) := 'pay_au_bal_upload.expiry_date' ;
    l_business_group_id             per_assignments_f.business_group_id%type ;
    l_asg_start_date                per_assignments_f.effective_start_date%type ;
    l_dimension_start_date          date ;
    l_expiry_date                   date ;   -- expiry_date of the dimension.

    e_bad_expiry_date               exception ;

    --  get assignment details

 /* Bug 4516174- Modified for case when assignment is assigned to a payroll at a time
    when it does not have associated time periods */

  cursor c_assignment
    (p_assignment_id  number
    ,p_effective_date date) is
      select greatest (min(a.effective_start_date), min(PTP.start_date))
          , min(a.business_group_id)
     from   per_assignments_f   a
           ,per_time_periods    PTP
     where  a.assignment_id         = p_assignment_id
       and  PTP.payroll_id            = a.payroll_id
       and  PTP.start_date           <= p_effective_date
       and (ptp.start_date between a.effective_start_date and p_effective_date
           or p_effective_date between ptp.start_date and ptp.end_date) -- bug 7644243
       and  p_effective_date between a.effective_start_date and  a.effective_end_date
       order by a.effective_start_date ;

    --  get period details

    cursor csr_period_start
    (p_assignment_id  number
    ,p_upload_date    date) is
    select nvl(ptp.start_date, g_end_of_time)
    from   per_time_periods    ptp
    ,      per_assignments_f   paf
    where  paf.assignment_id = p_assignment_id
    and    p_upload_date between paf.effective_start_date
                             and paf.effective_end_date
    and    ptp.payroll_id = paf.payroll_id
    and    p_upload_date between ptp.start_date
                             and ptp.end_date ;



  begin

    hr_utility.trace('In: ' || l_fn_name) ;
    hr_utility.trace('  p_upload_date => ' || to_char(p_upload_date,'dd Mon yyyy')) ;
    hr_utility.trace('  p_dimension_name => ' || p_dimension_name) ;
    hr_utility.trace('  p_assignment_id => ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_original_entry_id => ' || to_char(p_original_entry_id)) ;

    -- get assignment details
    open c_assignment(p_assignment_id, p_upload_date);
    fetch c_assignment
      into l_asg_start_date
      ,    l_business_group_id ;
    if c_assignment%notfound
    then
      close c_assignment;
      raise e_bad_expiry_date ;
    end if;
    close c_assignment;

    -- Calculate the expiry_date of the specified dimension relative to the
    -- upload_date, taking account any contexts. each of
    -- the calculations also takes into account when the assignment is on a
    -- payroll to ensure that a balance adjustment could be made at that point
    -- if it were required.

/* bug 4516174 - Added LE level dimensions */
/*bug 5477861 In expiry_date changed '_ASG_CAL_LE_YTD' to '_ASG_LE_CAL_YTD' */

    if (p_dimension_name = '_ASG_CAL_YTD') or (p_dimension_name = '_ASG_LE_CAL_YTD')then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.span_start(p_upload_date, 1, g_cal_year_start) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_FBT_YTD') or (p_dimension_name = '_ASG_LE_FBT_YTD') then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.span_start(p_upload_date, 1, g_fbt_year_start) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_FY_QTD')or (p_dimension_name = '_ASG_LE_FY_QTD') then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.fiscal_span_start(p_upload_date, 4, l_business_group_id) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_FY_YTD') or (p_dimension_name = '_ASG_LE_FY_YTD')then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.fiscal_span_start(p_upload_date, 1, l_business_group_id) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_MTD')or (p_dimension_name = '_ASG_LE_MTD') then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.span_start(p_upload_date, 12, g_cal_year_start) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_PTD')or (p_dimension_name = '_ASG_LE_PTD')  then

      --  get start of dimension
      open  csr_period_start(p_assignment_id, p_upload_date);
      fetch csr_period_start
        into l_dimension_start_date;
      if csr_period_start%notfound
      then
        close csr_period_start;
        raise e_bad_expiry_date;
      end if;
      close csr_period_start;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_QTD') or (p_dimension_name = '_ASG_LE_QTD') then

      --  get start of dimension
      l_dimension_start_date := hr_au_routes.span_start(p_upload_date, 4, g_tax_year_start) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif (p_dimension_name = '_ASG_TD') or (p_dimension_name = '_ASG_LE_TD') then

      l_expiry_date := l_asg_start_date;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    elsif ( p_dimension_name = '_ASG_YTD') or ( p_dimension_name = '_ASG_LE_YTD')  then

      --  get start of dimension
      /* Bug 4516174 Modified the frequency from 4 to 1 */

      l_dimension_start_date := hr_au_routes.span_start(p_upload_date, 1, g_tax_year_start) ;
      l_expiry_date := greatest(l_asg_start_date, l_dimension_start_date) ;
      if l_expiry_date > p_upload_date
      then
        raise e_bad_expiry_date ;
      end if ;

    end if;

    -- check null value, as the no_data_found exception won't be raised by
    -- a pseudo-column null returned by the cursor.
    if l_expiry_date is null then
      raise e_bad_expiry_date ;
    end if;

    hr_utility.trace(l_fn_name || ' return: ' || to_char(l_expiry_date,'dd Mon yyyy')) ;
    hr_utility.trace('Out: ' || l_fn_name) ;
    return l_expiry_date;

  exception
    -- when e_bad_expiry_date then
    --   l_expiry_date := g_end_of_time;
    --   return l_expiry_date;
    when others then
      l_expiry_date := g_end_of_time;
      hr_utility.trace(l_fn_name || ' return: ' || to_char(l_expiry_date,'dd Mon yyyy')) ;
      hr_utility.trace('Out: ' || l_fn_name) ;
      return l_expiry_date;

  end expiry_date;

  -----------------------------------------------------------------------------
  -- name
  --  is_supported
  -- purpose
  --  checks if the dimension is supported by the upload process.
  -- arguments
  --  p_dimension_name - the balance dimension to be checked.
  -- uses
  -- notes
  --  only a subset of the au dimensions are supported
  --  this is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------

  function is_supported
  (p_dimension_name varchar2)
  return number is
    l_proc      constant varchar2(72) := g_package||'is_supported';
  begin

    hr_utility.trace('Entering '||l_proc);

    -- see if the dimension is supported.

/* Bug 4516174  - Added support for LE level dimensions */

  if p_dimension_name in ('_ASG_CAL_YTD'
                           ,'_ASG_FBT_YTD'
                           ,'_ASG_FY_QTD'
                           ,'_ASG_FY_YTD'
                           ,'_ASG_MTD'
                           ,'_ASG_PTD'
                           ,'_ASG_QTD'
                           ,'_ASG_TD'
                           ,'_ASG_YTD'
                           ,'_ASG_LE_CAL_YTD'
                           ,'_ASG_LE_FBT_YTD'
                           ,'_ASG_LE_FY_QTD'
                           ,'_ASG_LE_FY_YTD'
                           ,'_ASG_LE_MTD'
                           ,'_ASG_LE_PTD'
                           ,'_ASG_LE_QTD'
 	                   ,'_ASG_LE_TD'
                           ,'_ASG_LE_YTD'
                     )
    then
      hr_utility.trace('Exiting '||l_proc);
      return 1;
    else
      hr_utility.trace('Exiting '||l_proc);
      return 0;
    end if;

  end is_supported;

  -----------------------------------------------------------------------------
  -- name
  --  include_adjustment
  -- purpose
  --  given a dimension, and relevant contexts and details of an existing
  --  balanmce adjustment, it will find out if the balance adjustment effects
  --  the dimension to be set. both the dimension to be set and the adjustment
  --  are for the same assignment and balance. the adjustment also lies between
  --  the expiry date of the new balance and the date on which it is to set.
  -- arguments
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_original_entry_id  - original_entry_id context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- uses
  -- notes
  --  all the au dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  this is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------

/*Bug 4516174 Function Modified for checking valid adjustments */

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
 -- TAX_UNIT_ID context NB. if the tax unit is used then only those
 -- adjustments which are for the same tax unit can be included.

  CURSOR csr_is_included( p_balance_type_id           NUMBER
                        , p_tax_unit_id               NUMBER
                       , p_bal_adj_tax_unit_id       NUMBER
			) IS
  SELECT BT.balance_type_id
  FROM   pay_balance_types BT
  WHERE  BT.balance_type_id = p_balance_type_id
       and  ((p_tax_unit_id is null)    or
             (p_tax_unit_id is not null and p_tax_unit_id = p_bal_adj_tax_unit_id)) ;

  l_bal_type_id       pay_balance_types.balance_type_id%TYPE;

 -- To get the tax_unit_id from pay_balance_batch_lines

  CURSOR csr_get_tax_unit(p_batch_line_id  NUMBER) IS
  SELECT htuv.tax_unit_id
  FROM   pay_balance_batch_lines pbbl
        ,hr_tax_units_v htuv
  WHERE  pbbl.batch_line_id = p_batch_line_id
  AND    pbbl.tax_unit_id   = htuv.tax_unit_id
  AND    pbbl.tax_unit_id IS NOT NULL
  UNION ALL
  SELECT htuv.tax_unit_id
  FROM   pay_balance_batch_lines pbbl
        ,hr_tax_units_v htuv
  WHERE  pbbl.batch_line_id   = p_batch_line_id
  AND    upper(pbbl.gre_name) = UPPER(htuv.name)
  AND    pbbl.tax_unit_id IS NULL;


  -- Get tax_unit_id for previously tested adjustments

  CURSOR csr_get_tested_adjustments(p_test_batch_line_id NUMBER) IS
  SELECT tax_unit_id
  FROM   pay_temp_balance_adjustments
  WHERE  batch_line_id = p_test_batch_line_id;

  -- The balance returned by the include check.
  l_orig_entry_id       pay_balance_batch_lines.original_entry_id%TYPE;
  l_adj_orig_entry_id   pay_temp_balance_adjustments.original_entry_id%TYPE;
  l_tax_unit_id         pay_balance_batch_lines.tax_unit_id%TYPE;
  l_adj_tax_unit_id     pay_temp_balance_adjustments.tax_unit_id%TYPE;

BEGIN

  OPEN csr_get_tax_unit(p_batch_line_id);
       FETCH csr_get_tax_unit INTO l_tax_unit_id ;
  CLOSE csr_get_tax_unit;


  OPEN  csr_get_tested_adjustments(p_test_batch_line_id);
      FETCH csr_get_tested_adjustments
          INTO   l_adj_tax_unit_id ;
  CLOSE csr_get_tested_adjustments;

  -- Does the balance adjustment effect the new balance

  hr_utility.trace('balance_type_id      = '||TO_CHAR(p_balance_type_id));
  hr_utility.trace('tax_unit_id          = '||TO_CHAR(l_tax_unit_id));
  hr_utility.trace('original_entry_id    = '||TO_CHAR(p_original_entry_id));
  hr_utility.trace('BA tax_unit_id       = '||TO_CHAR(l_adj_tax_unit_id));
  hr_utility.trace('BA original_entry_id = '||TO_CHAR(l_adj_orig_entry_id));


 OPEN  csr_is_included(p_balance_type_id
		       ,l_tax_unit_id
		       ,l_adj_tax_unit_id
                       );

         FETCH csr_is_included
	    INTO l_bal_type_id;
  CLOSE csr_is_included;

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

  -----------------------------------------------------------------------------
  -- name
  --  validate_batch_lines
  -- purpose
  --   applies bf specific validation to the batch.
  -- arguments
  --  p_batch_id - the batch to be validate_batch_lines.
  -- uses
  -- notes
  --  this is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------

  procedure validate_batch_lines( p_batch_id number ) is
  begin

    hr_utility.trace('Entering '||g_package||'validate_batch_lines');

    hr_utility.trace('Exiting '||g_package||'validate_batch_lines');

  end validate_batch_lines;

end pay_au_bal_upload;

/
