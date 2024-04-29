--------------------------------------------------------
--  DDL for Package Body PAY_NZ_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_BAL_UPLOAD" as
/* $Header: pynzbaup.pkb 120.0.12010000.4 2008/08/06 08:07:46 ubhat ship $ */
  --
  -- Change List
  -- ----------
  -- DATE        Name            Vers     Bug No    Description
  -- -----------+---------------+--------+--------+------------------------------+
  -- 23-Aug-1999 sclarke         110.0              Created
  -- 24-Aug-1999 sclarke         110.1              Added support for asg_hol_ytd
  --                                                and asg_4week dimensions
  -- 14-Sep-1999 sclarke         110.2              Bug 993389
  -- 12-Jun-2001 apunekar        110.3              Parameter p_test_batch_line_id to function include_adjustment
  -- 24-Sep-2001 jlin            115.2    2011512   Should choose the greater date
  --                                                between the earliest pay period's
  --                                                start date for the current payroll
  --                                                and the earliest EFFECTIVE_START_
  --                                                EFFECTIVE_START_DATE for the
  --                                                assignment for a variable called
  --                                                l_asg_start_date
  -- 19-Jun-2008 vamittal        115.3    7037181   Removed support for asg_hol_ytd dimension
  -- 14-Jul-2008 vamittal        115.4    7037181   Comments are added.
  -- -----------+---------------+--------+--------+------------------------------+
  g_package     constant varchar2(240) := 'pay_nz_bal_upload.';
  --
  -- date constants.
  --
  start_of_time       constant date := to_date('01/01/0001','dd/mm/yyyy');
  end_of_time         constant date := to_date('31/12/4712','dd/mm/yyyy');
  g_tax_start_dd_mm   constant varchar2(11) := '01-04-';
  --
  -- Dimension Name constants
  --
  g_asg_td            constant pay_balance_dimensions.dimension_name%type := upper('_asg_td');
  g_asg_ptd           constant pay_balance_dimensions.dimension_name%type := upper('_asg_ptd');
  g_asg_ytd           constant pay_balance_dimensions.dimension_name%type := upper('_asg_ytd');
  g_asg_fy_qtd        constant pay_balance_dimensions.dimension_name%type := upper('_asg_fy_qtd');
  g_asg_fy_ytd        constant pay_balance_dimensions.dimension_name%type := upper('_asg_fy_ytd');
  /*Bug 7037181 variable for dimension asg_hol_ytd is removed */
  g_asg_4week         constant pay_balance_dimensions.dimension_name%type := upper('_asg_4week');
  --
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
  --
  function expiry_date
  ( p_upload_date       date
  , p_dimension_name    varchar2
  , p_assignment_id     number
  , p_original_entry_id number
  )
  return date is
    --
    -- returns the date of 4 weeks ago
    --
    cursor csr_asg_4week
    ( p_assignment_id number
    , p_upload_date   date) is
    select  p_upload_date - 28
    from    per_assignments_f   paf
    ,       per_time_periods    ptp
    where   paf.assignment_id   = p_assignment_id
            and ptp.payroll_id  = paf.payroll_id
            and p_upload_date   between ptp.start_date and ptp.end_date
            and p_upload_date   between paf.effective_start_date and paf.effective_end_date;
    --
    -- returns the start date of the fiscal year.
    --
    cursor csr_fiscal_year
    ( p_assignment_id number
    , p_upload_date   date) is
    select hr_nz_routes.fiscal_span_start( p_upload_date, 1, paf.business_group_id )
    from   per_assignments_f  paf
    ,      per_time_periods   ptp
    where  paf.assignment_id  = p_assignment_id
           and ptp.payroll_id = paf.payroll_id
           and p_upload_date  between ptp.start_date and ptp.end_date
           and p_upload_date  between paf.effective_start_date and paf.effective_end_date;
    --
    -- returns the start date of the fiscal quarter.
    --
    cursor csr_fiscal_quarter
    ( p_assignment_id number
    , p_upload_date   date) is
    select hr_nz_routes.fiscal_span_start( p_upload_date, 4, paf.business_group_id )
    from   per_assignments_f    paf
    ,      per_time_periods     ptp
    where  paf.assignment_id    = p_assignment_id
           and ptp.payroll_id   = paf.payroll_id
           and p_upload_date    between ptp.start_date and ptp.end_date
           and p_upload_date    between paf.effective_start_date and paf.effective_end_date;
    --
    -- returns the start date of the current period on the upload date.
    --
    cursor csr_period_start
    ( p_assignment_id number
    , p_upload_date   date) is
    select nvl(ptp.start_date, end_of_time)
    from   per_time_periods    ptp
    ,      per_assignments_f   paf
    where  paf.assignment_id   = p_assignment_id
           and p_upload_date   between paf.effective_start_date and paf.effective_end_date
           and ptp.payroll_id  = paf.payroll_id
           and p_upload_date   between ptp.start_date and ptp.end_date;
    --
    -- returns the earliest date on which the assignment exists.
    --
    cursor csr_asg_start
    ( p_assignment_id     number
    , p_upload_date       date) is
    select nvl(greatest(min(ptp.start_date), min(paf.effective_start_date)),end_of_time)
    ,      paf.business_group_id
    from   per_assignments_f             paf
    ,      per_time_periods              ptp
    where  paf.assignment_id             = p_assignment_id
           and paf.payroll_id            = ptp.payroll_id
           and paf.effective_start_date <= p_upload_date
           and ptp.start_date           <= p_upload_date
    group by paf.business_group_id;
    --
    --
    --
    cursor csr_asg_start_date
    ( p_assignment_id number
    , p_upload_date   date
    , p_expiry_date   date) is
    select nvl(greatest(min(paf.effective_start_date), p_expiry_date), end_of_time)
    from   per_assignments_f             paf
    ,      per_time_periods              ptp
    where  paf.assignment_id             = p_assignment_id
           and ptp.payroll_id            = paf.payroll_id
           and p_upload_date   between ptp.start_date and ptp.end_date
           and paf.effective_start_date  <= p_upload_date
           and paf.effective_end_date    >= p_expiry_date;
    --
    --
    --
    l_tax_yr_start_date       date;   -- start of the tax year using the upload_date.
    l_tax_qtr_start_date      date;   -- start of the tax quarter using the upload_date.
    l_fiscal_yr_start_date    date;   -- start of the fiscal year using the upload_date.
    l_fiscal_qtr_start_date   date;   -- start of the fiscal quarter using the upload_date.
    l_prd_start_date          date;   -- start of the period using the upload_date.
    l_expiry_date             date;   -- expiry_date of the dimension.
    l_asg_start_date          date;   -- earliest date on which the assignment exists.
    l_asg_4week_start         date;   -- start of 4 weeks prior to upload date
    l_start_date              date;
    l_anniversary_date   date;   -- start date of the last anniversary
    l_business_group_id       per_assignments_f.business_group_id%type;
    --
  begin
    --
    -- get the earliest effective date that the assignment can exist
    -- expiry dates cannot be before this date, also get the business
    -- group id for later use
    --
    open csr_asg_start(p_assignment_id, p_upload_date);
    fetch csr_asg_start into l_asg_start_date, l_business_group_id;
    if csr_asg_start%notfound then
      close csr_asg_start;
      raise no_data_found;
    end if;
    close csr_asg_start;
    --
    -- Calculate the expiry_date of the specified dimension relative to the
    -- upload_date, taking account any contexts. each of
    -- the calculations also takes into account when the assignment is on a
    -- payroll to ensure that a balance adjustment could be made at that point
    -- if it were required.
    --
    if p_dimension_name = g_asg_td then
      --
      l_expiry_date := l_asg_start_date;
       --
       /* Bug 7037181 code for dimension asg_hol_ytd is removed */
    elsif p_dimension_name = g_asg_4week then
      --
      open csr_asg_4week(p_assignment_id, p_upload_date);
      fetch csr_asg_4week into l_asg_4week_start;
      if csr_asg_4week%notfound then
        close csr_asg_4week;
        raise no_data_found;
      end if;
      close csr_asg_4week;
      l_expiry_date := greatest(l_asg_4week_start, l_asg_start_date);
      --
    elsif p_dimension_name = g_asg_ptd then
      --
      -- what's the current period start_date ?
      --
      open  csr_period_start(p_assignment_id, p_upload_date);
      fetch csr_period_start into l_prd_start_date;
      if csr_period_start%notfound then
        close csr_period_start;
        raise no_data_found;
      else
        close csr_period_start;
        open csr_asg_start_date(p_assignment_id, p_upload_date, l_prd_start_date);
        fetch csr_asg_start_date into l_start_date;
        if csr_asg_start_date%notfound then
          close csr_asg_start_date;
          raise no_data_found;
        end if;
        close csr_asg_start_date;
        l_expiry_date := greatest(l_start_date, l_asg_start_date);
      end if;
      --
    elsif p_dimension_name = g_asg_ytd then
      --
      -- what's the start_date of the tax year ?
      --
      l_tax_yr_start_date := hr_nz_routes.span_start(p_upload_date, 1, g_tax_start_dd_mm);
      open csr_asg_start_date(p_assignment_id, p_upload_date, l_tax_yr_start_date);
      fetch csr_asg_start_date into l_start_date;
      if csr_asg_start_date%notfound then
        close csr_asg_start_date;
        raise no_data_found;
      end if;
      close csr_asg_start_date;
      l_expiry_date := greatest(l_start_date, l_asg_start_date);
      --
    elsif p_dimension_name = g_asg_fy_qtd then
      --
      -- what's the start_date of the fiscal quarter ?
      --
      open  csr_fiscal_quarter(p_assignment_id, p_upload_date);
      fetch csr_fiscal_quarter into l_fiscal_qtr_start_date;
      if csr_fiscal_quarter%notfound then
        close csr_fiscal_quarter;
        raise no_data_found;
      else
        close csr_fiscal_quarter;
        open csr_asg_start_date(p_assignment_id, p_upload_date, l_fiscal_qtr_start_date);
        fetch csr_asg_start_date into l_start_date;
        if csr_asg_start_date%notfound then
          close csr_asg_start_date;
          raise no_data_found;
        end if;
        close csr_asg_start_date;
        l_expiry_date := greatest(l_start_date, l_asg_start_date);
      end if;
      --
    elsif p_dimension_name = g_asg_fy_ytd then
      --
      -- what's the start_date of the fiscal year ?
      --
      open  csr_fiscal_year(p_assignment_id, p_upload_date);
      fetch csr_fiscal_year into l_fiscal_yr_start_date;
      if csr_fiscal_year%notfound then
        close csr_fiscal_year;
        raise no_data_found;
      else
        close csr_fiscal_year;
        --
        open csr_asg_start_date(p_assignment_id, p_upload_date, l_fiscal_yr_start_date);
        fetch csr_asg_start_date into l_start_date;
        if csr_asg_start_date%notfound then
          close csr_asg_start_date;
          raise no_data_found;
        end if;
        close csr_asg_start_date;
        --
        l_expiry_date := greatest(l_start_date, l_asg_start_date);
        --
      end if;
    end if;
    --
    -- check null value, as the no_data_found exception won't be raised by
    -- a pseudo-column null returned by the cursor.
    --
    if l_expiry_date is null then
      raise no_data_found;
    end if;
    --
    return l_expiry_date;
    --
  exception
    when no_data_found then
      l_expiry_date := end_of_time;
      return l_expiry_date;
    when others then
      l_expiry_date := end_of_time;
      return l_expiry_date;
    --
  end expiry_date;
  --
  -----------------------------------------------------------------------------
  -- name
  --  is_supported
  -- purpose
  --  checks if the dimension is supported by the upload process.
  -- arguments
  --  p_dimension_name - the balance dimension to be checked.
  -- uses
  -- notes
  --  only a subset of the nz dimensions are supported
  --  this is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
  --
  function is_supported ( p_dimension_name varchar2)
  return number is
    l_proc      constant varchar2(72) := g_package||'is_supported';
  begin
    --
    hr_utility.trace('Entering '||l_proc);
    --
    -- see if the dimension is supported.
    --
    /* Bug 7037181 dimension name for _asg_hol_ytd is removed */
    if p_dimension_name in
      ( g_asg_td
      , g_asg_ptd
      , g_asg_ytd
      , g_asg_fy_qtd
      , g_asg_fy_ytd
      , g_asg_4week
      ) then
      return 1;
    else
      return 0;
    end if;
    --
    hr_utility.trace('Exiting '||l_proc);
    --
  end is_supported;
  --
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
  --  all the nz dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  this is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
  --
    function include_adjustment ( p_balance_type_id    number
                                , p_dimension_name     varchar2
                                , p_original_entry_id  number
                                , p_upload_date        date
                                , p_batch_line_id      number
                                , p_test_batch_line_id  number
                                ) return number is
    --
    l_bal_type_id number;
    l_proc        constant varchar2(72) := g_package||'include_adjustment';
    --
  begin
    --
    hr_utility.trace('Entering '||l_proc);
    --
    return 1;
    --
    hr_utility.trace('Exiting '||l_proc);
    --
  end include_adjustment;
  --
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
  --
  procedure validate_batch_lines( p_batch_id number ) is
  begin
    --
    hr_utility.trace('Entering '||g_package||'validate_batch_lines');
    --
    hr_utility.trace('Exiting '||g_package||'validate_batch_lines');
    --
  end validate_batch_lines;
  --
end pay_nz_bal_upload;

/
