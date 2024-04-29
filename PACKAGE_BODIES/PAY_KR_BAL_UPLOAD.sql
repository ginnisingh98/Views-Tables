--------------------------------------------------------
--  DDL for Package Body PAY_KR_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_BAL_UPLOAD" as
/* $Header: pykrupld.pkb 120.0 2005/05/29 06:32:03 appldev noship $ */
--
-- Global Variables.
--
g_debug             boolean := hr_utility.debug_enabled;
g_eot               date := hr_api.g_eot;
g_sot               date := hr_api.g_sot;
--------------------------------------------------------------------------------
function expiry_date(p_upload_date       date,
                     p_dimension_name    varchar2,
                     p_assignment_id     number,
                     p_original_entry_id number) return date
--------------------------------------------------------------------------------
is
--
  l_start_date  date;
  l_expiry_date date;
--
   cursor csr_asg_start_date
     (p_assignment_id number
     ,p_upload_date   date
     ,p_expiry_date   date
     ) is
     select nvl(greatest(min(ASS.effective_start_date), p_expiry_date),
                g_eot)
       from per_assignments_f ASS
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and ASS.effective_end_date >= p_expiry_date
        and ASS.payroll_id is not null;
--
  cursor csr_asg_ptd
  is
  select nvl(ptp.start_date,g_eot)
  from   per_time_periods      ptp,
         per_assignments_f     pa
  where  pa.assignment_id = p_assignment_id
  and    p_upload_date
         between pa.effective_start_date and pa.effective_end_date
  and    ptp.payroll_id = pa.payroll_id
  and    p_upload_date
         between ptp.start_date and ptp.end_date;
--
  cursor csr_asg_itd
  is
  select nvl(min(pa.effective_start_date),g_eot)
  from   per_assignments_f pa
  where  pa.assignment_id = p_assignment_id
  and    pa.effective_start_date <= p_upload_date
  and  exists (
          select null
          from   per_time_periods PTP
          where  PTP.payroll_id = pa.payroll_id
            and  pa.effective_start_date between
                 PTP.start_date and PTP.end_date);
--
  cursor csr_asg_fytd
  is
  select nvl(add_months(fnd_date.canonical_to_date(org_information11),
     (floor(floor(months_between(p_upload_date,
                                  fnd_date.canonical_to_date(org_information11)))/12)*12)),
	g_eot)
  from   hr_organization_information hoi,
         per_assignments_f           pa
  where  pa.assignment_id = p_assignment_id
  and    p_upload_date
         between pa.effective_start_date and pa.effective_end_date
  and    hoi.organization_id = pa.business_group_id
  and    hoi.org_information_context = 'Business Group Information';
--
  cursor csr_asg_fqtd(p_fytd_date date,
                      p_upload_date date)
  is
  select nvl(add_months(p_fytd_date,
     (floor(floor(months_between(p_upload_date,
                                  p_fytd_date))/3)*3)),
        g_eot)
  from sys.dual;
--
  cursor csr_asg_hdtd
  is
  select nvl(add_months(ppos.date_start,
     (floor(floor(months_between(p_upload_date,
                                  ppos.date_start))/12)*12)),
        g_eot)
  from   per_periods_of_service ppos,
         per_assignments_f      pa
  where  pa.assignment_id = p_assignment_id
  and    p_upload_date
         between pa.effective_start_date and pa.effective_end_date
  and    ppos.period_of_service_id = pa.period_of_service_id;
--
--
-- This cursor takes the assignment, the expiry_date and the upload_date
-- and returns the next regular_payment_date after the expiry_date for
-- that particular payroll.
--
        CURSOR  csr_regular_payment
                (
                        l_assignment_id         NUMBER,
                        l_upload_date           DATE,
                        l_expiry_date           DATE
                )
        IS
        SELECT  MIN(ptp.regular_payment_date)
        FROM    per_time_periods ptp, per_assignments_f paf
        WHERE   paf.assignment_id = l_assignment_id
        AND     l_upload_date   BETWEEN paf.effective_start_date
                                AND     paf.effective_end_date
        AND     ptp.payroll_id = paf.payroll_id
        AND     ptp.regular_payment_date        BETWEEN l_expiry_date
                                                AND     l_upload_date;
--
begin
--
  if p_dimension_name like '_ASG_MTD%' then
     l_start_date := trunc(p_upload_date,'MM');
  elsif p_dimension_name like '_ASG_YTD%' then
     l_start_date := trunc(p_upload_date,'YYYY');
  elsif p_dimension_name like '_ASG_QTD%' then
     l_start_date := trunc(p_upload_date,'Q');
  elsif p_dimension_name like '_ASG_PTD%' then
     open csr_asg_ptd;
     fetch csr_asg_ptd into l_start_date;
     close csr_asg_ptd;
  elsif (p_dimension_name like '_ASG_ITD%' or
         p_dimension_name like '_ASG_WG_ITD%' ) then
     open csr_asg_itd;
     fetch csr_asg_itd into l_start_date;
     close csr_asg_itd;
  elsif p_dimension_name like '_ASG_FYTD%' then
     open csr_asg_fytd;
     fetch csr_asg_fytd into l_start_date;
     close csr_asg_fytd;
  elsif p_dimension_name like '_ASG_FQTD%' then
     declare
       l_fytd_date date;
     begin
       -- We need the financial year start to be able
       -- to work out the quarter start.
       open csr_asg_fytd;
       fetch csr_asg_fytd into l_fytd_date;
       close csr_asg_fytd;
       open csr_asg_fqtd(l_fytd_date, p_upload_date);
       fetch csr_asg_fqtd into l_start_date;
       close csr_asg_fqtd;
     end;
  elsif p_dimension_name like '_ASG_HDTD%' then
     open csr_asg_hdtd;
     fetch csr_asg_hdtd into l_start_date;
     close csr_asg_hdtd;
  end if;
  --
  open csr_asg_start_date(p_assignment_id
                         ,p_upload_date
                         ,l_start_date);
  fetch csr_asg_start_date into l_expiry_date;
  close csr_asg_start_date;
--
   -- For PTD's use the regular payment
   -- date.
   if p_dimension_name like '_ASG_PTD%' then
     --
     -- return the date on which the dimension expires.
     --
     OPEN    csr_regular_payment
               (p_assignment_id,
                p_upload_date,
                l_expiry_date);
     FETCH   csr_regular_payment
     INTO    l_expiry_date;

     CLOSE   csr_regular_payment;
   end if;
--
return (l_expiry_date);
--
end expiry_date;
--------------------------------------------------------------------------------
function is_supported(p_dimension_name varchar2) return number
--------------------------------------------------------------------------------
is
--
  l_support number := 0;
--
begin
--
  if g_debug then
    hr_utility.trace('Entering pay_kr_bal_upload.is_supported');
  end if;

  if p_dimension_name in
     ('_ASG_MTD',
      '_ASG_MTD_MTH',
      '_ASG_MTD_BON',
      '_ASG_MTD_SEP',
      '_ASG_QTD',
      '_ASG_YTD',
      '_ASG_YTD_MTH',
      '_ASG_YTD_BON',
      '_ASG_YTD_SEP',
      '_ASG_PTD',
      '_ASG_PTD_MTH',
      '_ASG_PTD_BON',
      '_ASG_PTD_SEP',
      '_ASG_FYTD',
      '_ASG_FQTD',
      '_ASG_HDTD',
      '_ASG_ITD',
      '_ASG_WG_ITD') then
     l_support := 1; -- TRUE
  else
     l_support := 0; -- FALSE
  end if;
--
  return (l_support);
--
  if g_debug then
    hr_utility.trace('Exiting pay_kr_bal_upload.is_supported');
  end if;
--
end is_supported;
--------------------------------------------------------------------------------
procedure validate_batch_lines(p_batch_id number)
--------------------------------------------------------------------------------
is
begin
--
  if g_debug then
    hr_utility.trace('Entering pay_kr_bal_upload.validate_batch_lines');
  end if;
  --
  if g_debug then
    hr_utility.trace('Exiting pay_kr_bal_upload.validate_batch_lines');
  end if;
--
end validate_batch_lines;
--------------------------------------------------------------------------------
function include_adjustment(p_balance_type_id    number,
                            p_dimension_name     varchar2,
                            p_original_entry_id  number,
                            p_upload_date	 date,
                            p_batch_line_id      number,
                            p_test_batch_line_id number)
return number
--------------------------------------------------------------------------------
is
--
  l_include_adj               number := 0;
  l_balance_type_id           number;
  l_tax_unit_id               number;
  l_run_type_id               number;
  l_bal_adj_tax_unit_id       number;
  l_bal_adj_run_type_id       number;
  l_bal_adj_original_entry_id number;
  l_source_text               varchar2(60);
  l_bal_adj_source_text       varchar2(60);
--
  cursor csr_tax_unit(
    p_batch_line_id number)
  is
  select pbbl.tax_unit_id,
         pbbl.run_type_id,
         pbbl.source_text
  from
         pay_balance_batch_lines     pbbl
  where  pbbl.batch_line_id = p_batch_line_id;
--
  cursor csr_bal_adj(
    p_test_batch_line_id number)
  is
  select tax_unit_id,
         original_entry_id,
         run_type_id,
         source_text
  from   pay_temp_balance_adjustments
  where  batch_line_id = p_test_batch_line_id;
--
  cursor csr_is_included(
    p_balance_type_id           number,
    p_run_type_id               number,
    p_bal_adj_run_type_id       number,
    p_source_text               varchar2,
    p_bal_adj_source_text       varchar2
   )
  is
  select pbt.balance_type_id
  from   pay_balance_types pbt
  where  pbt.balance_type_id = p_balance_type_id
  and    nvl(p_run_type_id, nvl(p_bal_adj_run_type_id,-1))
         = nvl(p_bal_adj_run_type_id,-1)
  and    nvl(p_source_text, nvl(p_bal_adj_source_text,'XX'))
         = nvl(p_bal_adj_source_text,'XX');
--
begin
--
  if g_debug then
    hr_utility.trace('Entering pay_kr_bal_upload.include_adjustment');
  end if;
--
  open csr_tax_unit(p_batch_line_id => p_batch_line_id);
  fetch csr_tax_unit
    into l_tax_unit_id,
         l_run_type_id,
         l_source_text;
  close csr_tax_unit;
--
  open csr_bal_adj(p_test_batch_line_id => p_test_batch_line_id);
  fetch csr_bal_adj
    into l_bal_adj_tax_unit_id,
         l_bal_adj_original_entry_id,
         l_bal_adj_run_type_id,
         l_bal_adj_source_text;
  close csr_bal_adj;
--
  open csr_is_included(
         p_balance_type_id           => p_balance_type_id,
         p_run_type_id               => l_run_type_id,
         p_bal_adj_run_type_id       => l_bal_adj_run_type_id,
         p_source_text               => l_source_text,
         p_bal_adj_source_text       => l_bal_adj_source_text);

  fetch csr_is_included
    into l_balance_type_id;
  close csr_is_included;
--
  if l_balance_type_id is not null then
      l_include_adj := 1; --TRUE
  else
      l_include_adj := 0; --FALSE
  end if;
--
  return (l_include_adj);
--
  if g_debug then
    hr_utility.trace('Exiting pay_kr_bal_upload.include_adjustment');
  end if;
--
end include_adjustment;
end pay_kr_bal_upload;

/
