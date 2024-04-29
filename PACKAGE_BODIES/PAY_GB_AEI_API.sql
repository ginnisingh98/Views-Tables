--------------------------------------------------------
--  DDL for Package Body PAY_GB_AEI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_AEI_API" as
/* $Header: pyaeigbi.pkb 120.9.12010000.3 2009/02/13 16:35:53 namgoyal ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_gb_aei_api.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p45_3>-----------------------|
-- ----------------------------------------------------------------------------
-- Bug 1843915 Added the parameter p_aei_information8 to insert the column
-- P45_3_SEND_EDI_FLAG
-- Bug 6345375 Added following parameters :
-- p_aei_information9  -> PREVIOUS_TAX_PAID_NOTIFIED
-- p_aei_information10 -> NOT_PAID_BETWEEN_START_N_5APR
-- p_aei_information11 -> CONTINUE_SL_DEDUCTIONS
--

procedure pay_gb_ins_p45_3
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10              in     varchar2 default null
  ,p_aei_information11              in     varchar2 default null
  ,p_aei_information12              in     varchar2 default null -- Bug 6994632 added for Prev Tax Pay Notified
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_ins_p45_3';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  hr_utility.trace('Inside pay_gb_ins_p45_3');
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  -- Bug 3454500 check for Send EDI flag
  if (p_aei_information8 is null) then
    hr_utility.set_message(800, 'HR_GB_78120_MISSING_EDI_FLAG');
    hr_utility.set_message_token('TYPE','P45(3)');
    hr_utility.raise_error;
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
-- Bug 1843915 Added the parameter p_aei_information8 to insert the column
-- P45_3_SEND_EDI_FLAG

  hr_assignment_extra_info_api.create_assignment_extra_info
(p_validate                 =>  p_validate
,p_assignment_id            =>  p_assignment_id
,p_information_type         =>  p_information_type
,p_aei_information_category => p_aei_information_category
,p_aei_information1         => p_aei_information1
,p_aei_information2         => p_aei_information2
,p_aei_information3         => p_aei_information3
,p_aei_information4         => p_aei_information4
,p_aei_information5         => p_aei_information5
,p_aei_information6         => p_aei_information6
,p_aei_information7         => p_aei_information7
,p_aei_information8         => p_aei_information8
,p_aei_information9         => p_aei_information9
,p_aei_information10        => p_aei_information10
,p_aei_information11        => p_aei_information11
,p_aei_information12        => p_aei_information12 -- Bug 6994632 added for Prev Tax Pay Notified
,p_object_version_number    => p_object_version_number
,p_assignment_extra_info_id => p_assignment_extra_info_id);

  hr_utility.set_location(' Leaving:'||l_proc, 40);
end pay_gb_ins_p45_3;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p45_3>-----------------------|
-- ----------------------------------------------------------------------------
-- Bug 1843915 Added the parameter p_aei_information8 to update the column
-- P45_3_SEND_EDI_FLAG
-- Bug 6345375 Added following parameters :
-- p_aei_information9  -> PREVIOUS_TAX_PAID_NOTIFIED
-- p_aei_information10 -> NOT_PAID_BETWEEN_START_N_5APR
-- p_aei_information11 -> CONTINUE_SL_DEDUCTIONS

procedure pay_gb_upd_p45_3
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null -- Bug 6994632 added for Prev Tax Pay Notified
  )is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_upd_p45_3';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the Assignment Extra Information Business API
  --
-- Bug 1843915 Added the parameter p_aei_information8 to update the column
-- P45_3_SEND_EDI_FLAG

  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => P_aei_information7
  ,p_aei_information8           => P_aei_information8
  ,p_aei_information9           => P_aei_information9
  ,p_aei_information10          => P_aei_information10
  ,p_aei_information11          => P_aei_information11
  ,p_aei_information12          => P_aei_information12 -- Bug 6994632 added for Prev Tax Pay Notified
  );

  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end pay_gb_upd_p45_3;
--
-----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p45_info>-----------------------|
-- --------------------------------------------------------------------------
procedure pay_gb_ins_p45_info
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_aggregated_paye_flag          in     varchar2 default null
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_ins_p45_info';
  l_asg_tax_dist   varchar2(50);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;

  cursor csr_aggr_paye_flag (c_person_id in number,
                             c_effective_date in date) is
   select per_information10
   from   per_all_people_f
   where  person_id = c_person_id
   and    c_effective_date between
        effective_start_date and effective_end_date;

  l_effective_date date;
  l_aggregated_paye_flag per_all_people_f.per_information10%type;
  l_period_of_service_id per_all_assignments_f.period_of_service_id%type;
  l_object_version_number number;
  l_assignment_extra_info_id number;
  --
  -- fetch the tax PAYE reference for the given asg. on the effective date
  --
  CURSOR tax_district(c_assignment_id in number,
                      c_effective_date in date) IS
    SELECT hsck.segment1, period_of_service_id
    FROM  hr_soft_coding_keyflex hsck,
          pay_all_payrolls_f papf,
          per_all_assignments_f paaf
    WHERE hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
    AND papf.payroll_id = paaf.payroll_id
    AND paaf.assignment_id = c_assignment_id
    AND c_effective_date between
          papf.effective_start_date and papf.effective_end_date
    AND c_effective_date between
          paaf.effective_start_date and paaf.effective_end_date;
  --

  --
  -- to fetch all the aggregated assignments and corresponding extra info
  -- based on effective date, if the extra info id is null then insert else update
  -- except the current assignment; because we directly insert the value for this asg.
  --
  cursor csr_person_agg_asg (c_person_id in number,
                             c_tax_ref in varchar2,
                             c_effective_date in date,
                             c_assignment_id in number,
                             c_period_of_service_id in number) is
   select distinct
          a.assignment_id,
          extra.assignment_extra_info_id,
          extra.object_version_number ovn,
          extra.aei_information_category,
          extra.aei_information1,
          extra.aei_information2,
          extra.aei_information3,
          extra.aei_information4
   from   per_all_assignments_f a,
          pay_all_payrolls_f pay,
          hr_soft_coding_keyflex flex,
          per_assignment_status_types past,
          per_assignment_extra_info extra
   where  a.person_id   = c_person_id
   and    flex.segment1 = c_tax_ref
   and    pay.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   and    a.payroll_id  = pay.payroll_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    a.period_of_service_id = c_period_of_service_id
   and    c_effective_date between
          pay.effective_start_date and pay.effective_end_date
   and    a.effective_start_date <= pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_ref, c_effective_date)
   and    a.effective_end_date   >= pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_ref, c_effective_date)
   and    extra.assignment_id(+)    = a.assignment_id
   and    extra.information_type(+) = p_information_type
   and    a.assignment_id          <> c_assignment_id
   ;

  --
  -- to fetch the last active/susp status date for the given assignment
  --
  cursor  csr_asg_last_active_date(c_assignment_id number) is
   select max(effective_end_date)
   from   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.assignment_id = c_assignment_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

  --
  -- to fetch the earliest aggregation start date near to the manual issue date/override date.
  --
  cursor  csr_latest_aggr_start_date(c_person_id number, c_effective_date date) is
   select max(effective_end_date) + 1
   from   per_all_people_f
   where  person_id = c_person_id
   and    nvl(per_information10,'N') = 'N'
   and    effective_end_date < c_effective_date;

  --
  -- to check whether the given assignment present between
  -- the earliest aggregation start date and manual issue date/override date.
  --
  cursor  csr_asg_present_status(c_assignment_id number, c_start_date date, c_end_date date) is
   select 1
   from   per_all_assignments_f a
   where  a.assignment_id = c_assignment_id
   and    a.effective_end_date   >= c_start_date
   and    a.effective_start_date <= c_end_date;

  l_found                    boolean;
  l_dummy                    number;
  l_asg_last_active_date     date;
  l_rec_asg_tax_dist         varchar2(50);
  l_rec_period_of_service_id number;
  l_latest_aggr_start_date   date;
--

begin
--  hr_utility.trace_on(null, 'ARUL');
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  hr_utility.set_location(l_proc,20);
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 30);

  -- inserting the extra info for the current assignment.
  --
  hr_assignment_extra_info_api.create_assignment_extra_info
  (p_validate                 => p_validate
  ,p_assignment_id            => p_assignment_id
  ,p_information_type         => p_information_type
  ,p_aei_information_category => p_aei_information_category
  ,p_aei_information1         => p_aei_information1
  ,p_aei_information2         => p_aei_information2
  ,p_aei_information3         => p_aei_information3
  ,p_aei_information4         => p_aei_information4
  ,p_object_version_number    => p_object_version_number
  ,p_assignment_extra_info_id => p_assignment_extra_info_id);
  --
  -- inserting the extra info for the current assignment ends.


  -- first insert/update EIT info based on the manual issue date then
  -- continue the same based on override date


  hr_utility.set_location(l_proc,50);
  --
  -- considering the manual issue date as the effective date
  --
  l_effective_date := fnd_date.canonical_to_date(p_aei_information3);
  --

  hr_utility.set_location(l_proc,50);
  --
  -- fetching the Aggregated PAYE flag at manual issue date
  --
  open csr_aggr_paye_flag(p_person_id, l_effective_date);
  fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
  close csr_aggr_paye_flag;
  --

  hr_utility.set_location(l_proc,60);

  -- if PAYE flag 'Y' then
  -- Call the Assignment Extra Information Business API
  -- For each agg assignment.

  if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then

     hr_utility.set_location(l_proc, 70);
     -- Aggregated paye, so loop through active/suspended assignments
     -- in current Tax District, and insert/update a row for each
     -- based on record already exists (or) not, manual issue date is null
     open tax_district(p_assignment_id, l_effective_date);
     fetch tax_district into l_asg_tax_dist, l_period_of_service_id;
     close tax_district;
     --

     --
     -- to fetch the latest aggregation start date near to manual issue date.
     --
     l_latest_aggr_start_date := null;
     open csr_latest_aggr_start_date(p_person_id, l_effective_date);
     fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
     close csr_latest_aggr_start_date;
     --

     hr_utility.set_location(l_proc, 80);

     --
     -- if extra info already exists for the asg and manual issue date is null then update
     -- if extra info not found for the asg then insert extra info for that asg.
     for r_rec in csr_person_agg_asg(p_person_id, l_asg_tax_dist,
                                     l_effective_date, p_assignment_id,
                                     l_period_of_service_id) loop

        hr_utility.set_location(l_proc, 90);

        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 100);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 110);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and manual issue date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
            hr_utility.set_location(l_proc, 120);
            -- extra info id null then insert only the manual issue date
            if r_rec.assignment_extra_info_id is null then
              hr_utility.set_location(l_proc, 130);

              hr_assignment_extra_info_api.create_assignment_extra_info
               (p_validate                 => p_validate
               ,p_assignment_id            => r_rec.assignment_id
               ,p_information_type         => p_information_type
               ,p_aei_information_category => p_aei_information_category
               ,p_aei_information1         => null
               ,p_aei_information2         => null
               ,p_aei_information3         => p_aei_information3
               ,p_aei_information4         => null
               ,p_object_version_number    => l_object_version_number
               ,p_assignment_extra_info_id => l_assignment_extra_info_id);

            -- extra info id not null and manual issue date is null then update
            elsif r_rec.assignment_extra_info_id is not null and r_rec.aei_information3 is null then
               hr_utility.set_location(l_proc, 140);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => p_aei_information3
               ,p_aei_information4           => r_rec.aei_information4);

            end if;
          end if;
        end if; -- paye reference, period of service id same
        --
     end loop;
     --
     hr_utility.set_location(l_proc, 150);
  end if;
  -- insert/update based on manual issue date ends


  --
  -- considering the override date as the effective date
  --
  l_effective_date := fnd_date.canonical_to_date(p_aei_information4);
  --

  hr_utility.set_location(l_proc,160);
  -- fetching the Aggregated PAYE flag at override date
  --
  open csr_aggr_paye_flag(p_person_id, l_effective_date);
  fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
  close csr_aggr_paye_flag;
  --

  hr_utility.set_location(l_proc,170);
  --
  -- if PAYE flag 'Y' then
  -- Call the Assignment Extra Information Business API
  -- For each agg assignment.
  if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then
     hr_utility.set_location(l_proc, 180);
     -- Aggregated paye, so loop through active assignments
     -- in current Tax District, and insert/update a row for each
     -- based on record already exists (or) not, override date is null
     open tax_district(p_assignment_id, l_effective_date);
     fetch tax_district into l_asg_tax_dist, l_period_of_service_id;
     close tax_district;
     --

     --
     -- to fetch the latest aggregation start date near to override date.
     --
     l_latest_aggr_start_date := null;
     open csr_latest_aggr_start_date(p_person_id, l_effective_date);
     fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
     close csr_latest_aggr_start_date;
     --

     hr_utility.set_location(l_proc, 190);

     --
     -- if extra info already exists for the asg and override date is null then update
     -- if extra info not found for the asg then insert extra info for that asg.
     for r_rec in csr_person_agg_asg(p_person_id, l_asg_tax_dist,
                                     l_effective_date, p_assignment_id,
                                     l_period_of_service_id) loop

        hr_utility.set_location(l_proc, 200);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 210);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 220);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and override date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
             hr_utility.set_location(l_proc, 230);
            -- extra info id null then insert only the override date
            if r_rec.assignment_extra_info_id is null then
              hr_utility.set_location(l_proc, 240);
              hr_assignment_extra_info_api.create_assignment_extra_info
               (p_validate                 => p_validate
               ,p_assignment_id            => r_rec.assignment_id
               ,p_information_type         => p_information_type
               ,p_aei_information_category => p_aei_information_category
               ,p_aei_information1         => null
               ,p_aei_information2         => null
               ,p_aei_information3         => null
               ,p_aei_information4         => p_aei_information4
               ,p_object_version_number    => l_object_version_number
               ,p_assignment_extra_info_id => l_assignment_extra_info_id);

            -- extra info id not null and override date is null then update
            elsif r_rec.assignment_extra_info_id is not null and r_rec.aei_information4 is null then
               hr_utility.set_location(l_proc, 250);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => r_rec.aei_information3
               ,p_aei_information4           => p_aei_information4);

            end if;
          end if;
        end if; -- paye reference, period of service id same
        --
     end loop;
     --
     hr_utility.set_location(l_proc, 260);
  end if;
  -- insert/update based on override date ends

  hr_utility.set_location(' Leaving:'||l_proc, 300);
--  hr_utility.trace_off;
end pay_gb_ins_p45_info;
-- -----------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p45_info>-----------------------|
-- -----------------------------------------------------------------------
procedure pay_gb_upd_p45_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_person_id                     in     number
  ,p_effective_date                in     date
  ,p_aggregated_paye_flag          in     varchar2 default null
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_upd_p45_info';
  l_asg_tax_dist        varchar2(50);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

  cursor csr_aggr_paye_flag (c_person_id in number,
                             c_effective_date in date) is
   select per_information10
   from   per_all_people_f
   where  person_id = c_person_id
   and    c_effective_date between
        effective_start_date and effective_end_date;

  l_effective_date           date;
  l_aggregated_paye_flag     per_all_people_f.per_information10%type;
  l_period_of_service_id     number;


  l_old_aei_information3     per_assignment_extra_info.aei_information3%type;
  l_old_aei_information4     per_assignment_extra_info.aei_information4%type;
  l_old_effective_date       date;
  l_old_aggregated_paye_flag per_all_people_f.per_information10%type;
  l_old_asg_tax_dist         varchar2(50);
  l_old_period_of_service_id number;
  l_information_type         per_assignment_extra_info.information_type%type;
  l_assignment_extra_info_id number;
  l_object_version_number    number;

  --
  cursor csr_old_aei_info(c_assignment_extra_info_id number) is
    select aei_information3, aei_information4, information_type
    from   per_assignment_extra_info
    where  assignment_extra_info_id = c_assignment_extra_info_id;
  --

  --
  CURSOR tax_district(c_assignment_id in number,
                      c_effective_date in date) IS
    SELECT hsck.segment1, period_of_service_id
    FROM  hr_soft_coding_keyflex hsck,
          pay_all_payrolls_f papf,
          per_all_assignments_f paaf
    WHERE hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
    AND papf.payroll_id = paaf.payroll_id
    AND paaf.assignment_id = c_assignment_id
    AND c_effective_date between
          papf.effective_start_date and papf.effective_end_date
    AND c_effective_date between
          paaf.effective_start_date and paaf.effective_end_date;
  --

  --
  -- to fetch all the aggregated assignments and corresponding extra info
  -- based on old effective date. if the extra info id is not null then update information when
  -- if both are same, effective date and manual issue date/override date; else no need to update.
  -- based on new effective date, if the extra info id is null then insert else update
  -- except the current assignment; will update separately after fetching the old values
  --
  cursor csr_per_agg_asg_extra (c_person_id in number,
                                c_tax_ref in varchar2,
                                c_effective_date in date,
                                c_information_type in varchar2,
                                c_assignment_id in number,
                                c_period_of_service_id in number) is
   select distinct
          a.assignment_id,
          extra.assignment_extra_info_id,
          extra.object_version_number ovn,
          extra.aei_information_category,
          extra.aei_information1,
          extra.aei_information2,
          extra.aei_information3,
          extra.aei_information4
   from   per_all_assignments_f a,
          pay_all_payrolls_f pay,
          hr_soft_coding_keyflex flex,
          per_assignment_status_types past,
          per_assignment_extra_info extra
   where  a.person_id   = c_person_id
   and    flex.segment1 = c_tax_ref
   and    pay.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   and    a.payroll_id  = pay.payroll_id
   and    extra.assignment_id(+)      = a.assignment_id
   and    extra.information_type(+)   = c_information_type
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    a.period_of_service_id      = c_period_of_service_id
   and    c_effective_date between
          pay.effective_start_date and pay.effective_end_date
   and    a.effective_start_date <= pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_ref, c_effective_date)
   and    a.effective_end_date   >= pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_ref, c_effective_date)
   and    a.assignment_id        <> c_assignment_id
  ;

  --
  -- to fetch the last active/susp status date for the given assignment
  --
  cursor  csr_asg_last_active_date(c_assignment_id number) is
   select max(effective_end_date)
   from   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.assignment_id = c_assignment_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

  --
  -- to fetch the earliest aggregation start date near to the manual issue date/override date.
  --
  cursor  csr_latest_aggr_start_date(c_person_id number, c_effective_date date) is
   select max(effective_end_date) + 1
   from   per_all_people_f
   where  person_id = c_person_id
   and    nvl(per_information10,'N') = 'N'
   and    effective_end_date < c_effective_date;

  --
  -- to check whether the given assignment present between
  -- the earliest aggregation start date and manual issue date/override date.
  --
  cursor  csr_asg_present_status(c_assignment_id number, c_start_date date, c_end_date date) is
   select 1
   from   per_all_assignments_f a
   where  a.assignment_id = c_assignment_id
   and    a.effective_end_date   >= c_start_date
   and    a.effective_start_date <= c_end_date;

  l_found                    boolean;
  l_dummy                    number;
  l_asg_last_active_date     date;
  l_rec_asg_tax_dist         varchar2(50);
  l_rec_period_of_service_id number;
  l_latest_aggr_start_date   date;
  l_old_latest_aggr_start_date date;
  --

begin
--  hr_utility.trace_on(null, 'ARUL');
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --

  hr_utility.set_location(l_proc,20);
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;
  --

  hr_utility.set_location(l_proc, 30);
  hr_utility.trace('p_assignment_extra_info_id = ' || p_assignment_extra_info_id);
  hr_utility.trace('p_aggregated_paye_flag = ' || p_aggregated_paye_flag);
  hr_utility.trace('p_aei_information1 = ' || p_aei_information1);
  hr_utility.trace('p_aei_information2 = ' || p_aei_information2);
  hr_utility.trace('p_aei_information3 = ' || p_aei_information3);
  hr_utility.trace('p_aei_information4 = ' || p_aei_information4);
  --

  -- fething the old manual issue date, old override date for the current assignment extra info id
  open csr_old_aei_info(p_assignment_extra_info_id);
  fetch csr_old_aei_info into l_old_aei_information3, l_old_aei_information4, l_information_type;
  close csr_old_aei_info;

  hr_utility.set_location(l_proc, 40);

  --
  -- update the current asg extra information if manual issue date or override date changed
  -- so no need to update this current record again
  --
  if nvl(l_old_aei_information3,'X') <> nvl(p_aei_information3,'X') or
     nvl(l_old_aei_information4,'X') <> nvl(p_aei_information4,'X') then
     hr_utility.set_location(l_proc, 50);
     hr_assignment_extra_info_api.update_assignment_extra_info
     (p_validate                   => p_validate
     ,p_assignment_extra_info_id   => p_assignment_extra_info_id
     ,p_object_version_number      => p_object_version_number
     ,p_aei_information_category   => p_aei_information_category
     ,p_aei_information1           => p_aei_information1
     ,p_aei_information2           => p_aei_information2
     ,p_aei_information3           => p_aei_information3
     ,p_aei_information4           => p_aei_information4);
  end if;
  -- current record updation ends

  -- first update EIT info based on the manual issue date then
  -- continue the same based on override date

  -- the entered manual issue date, old manual issue date are different
  -- then will have to clear(update as null) all the agg. asg EIT's associated at old manual issue date and
  -- update agg asg's extra info as of new manual issue date
  if nvl(l_old_aei_information3,'X') <> nvl(p_aei_information3,'X') then
     hr_utility.set_location(l_proc, 60);

     --
     -- considering the manual issue date as the effective date
     --
     l_old_effective_date := fnd_date.canonical_to_date(l_old_aei_information3);
     --

     hr_utility.set_location(l_proc, 70);
     --
     open csr_aggr_paye_flag(p_person_id, l_old_effective_date);
     fetch csr_aggr_paye_flag into l_old_aggregated_paye_flag;
     close csr_aggr_paye_flag;
     --

     -- Aggregated PAYE, loop through agg assignments in
     --
     if nvl(l_old_aggregated_paye_flag,'X') = 'Y' and l_old_effective_date is not null then
       hr_utility.set_location(l_proc, 80);
       -- Aggregated paye, so loop through active/suspended assignments
       -- in old Tax District, and update manual issue date as null
       -- for each row
       open tax_district(p_assignment_id, l_old_effective_date);
       fetch tax_district into l_old_asg_tax_dist, l_old_period_of_service_id;
       close tax_district;
       --

       --
       -- to fetch the latest aggregation start date near to old manual issue date.
       --
       l_old_latest_aggr_start_date := null;
       open csr_latest_aggr_start_date(p_person_id, l_old_effective_date);
       fetch csr_latest_aggr_start_date into l_old_latest_aggr_start_date;
       close csr_latest_aggr_start_date;
       --

       hr_utility.set_location(l_proc, 90);
       --
       -- fetching all the agg asg's based on the manual issue date
       --
       for r_rec in csr_per_agg_asg_extra(p_person_id, l_old_asg_tax_dist,
                                         l_old_effective_date,
                                         l_information_type, p_assignment_id,
                                         l_old_period_of_service_id)
       loop
       hr_utility.set_location(l_proc, 100);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_old_asg_tax_dist and
                       l_rec_period_of_service_id = l_old_period_of_service_id then

          hr_utility.set_location(l_proc, 110);

          if l_old_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 120);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and old manual issue date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_old_latest_aggr_start_date, l_old_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
             hr_utility.set_location(l_proc, 130);
             --
             -- if extra info id already exists for the asg and manual issue date is same, then update as null
             --
             if r_rec.assignment_extra_info_id is not null and r_rec.aei_information3 = l_old_aei_information3 then
               hr_utility.set_location(l_proc, 140);

               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => null
               ,p_aei_information4           => r_rec.aei_information4);
             end if;
             --
          end if;
        end if; -- paye reference, period of service id same
       end loop;
     end if;

    hr_utility.set_location(l_proc, 150);

    --
    -- considering the entered manual issue date as the effective date
    --
    l_effective_date := fnd_date.canonical_to_date(p_aei_information3);
    --

    hr_utility.set_location(l_proc, 160);
    --
    open csr_aggr_paye_flag(p_person_id, l_effective_date);
    fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
    close csr_aggr_paye_flag;
    --

    hr_utility.set_location(l_proc, 170);

    if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then -- PAYE as 'Y'

      -- Aggregated PAYE, loop through agg assignments in
      -- current tax district
      hr_utility.set_location(l_proc, 180);


      -- Aggregated paye, so loop through active assignments
      -- in current Tax District, and insert a row for each.
      open tax_district(p_assignment_id, l_effective_date);
      fetch tax_district into l_asg_tax_dist, l_period_of_service_id;
      close tax_district;
      --

      --
      -- to fetch the latest aggregation start date near to manual issue date.
      --
      l_latest_aggr_start_date := null;
      open csr_latest_aggr_start_date(p_person_id, l_effective_date);
      fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
      close csr_latest_aggr_start_date;
      --

      hr_utility.set_location(l_proc, 190);

      --
      -- if extra info already exists for the asg and manual issue date is null then update
      -- if extra info not found for the asg then insert extra info for that asg.
      --
      for r_rec in csr_per_agg_asg_extra(p_person_id, l_asg_tax_dist,
                                     l_effective_date, l_information_type,
                                     p_assignment_id, l_period_of_service_id) loop
        hr_utility.set_location(l_proc, 200);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 210);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 220);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and manual issue date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
            hr_utility.set_location(l_proc, 230);
            --
            -- extra info id null then insert only the override date
            if r_rec.assignment_extra_info_id is null then
              hr_utility.set_location(l_proc, 240);
              hr_assignment_extra_info_api.create_assignment_extra_info
               (p_validate                 => p_validate
               ,p_assignment_id            => r_rec.assignment_id
               ,p_information_type         => l_information_type
               ,p_aei_information_category => p_aei_information_category
               ,p_aei_information1         => null
               ,p_aei_information2         => null
               ,p_aei_information3         => p_aei_information3
               ,p_aei_information4         => null
               ,p_object_version_number    => l_object_version_number
               ,p_assignment_extra_info_id => l_assignment_extra_info_id);

            -- extra info id not null and override date is null then update
            elsif r_rec.assignment_extra_info_id is not null and r_rec.aei_information3 is null then
               hr_utility.set_location(l_proc, 250);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => p_aei_information3
               ,p_aei_information4           => r_rec.aei_information4);

            end if;
            --
          end if;
        end if; -- paye reference, period of service id same
      end loop;
    end if; -- PAYE as 'Y'
  end if; -- old and new manual issue date are different
  -- manual issue date updation ends
  --


  hr_utility.set_location(l_proc, 300);

  -- the entered override date, old override date are different
  -- then will have to clear(update as null) all the agg. asg EIT's associated at old override date and
  -- update agg asg's extra info as of new override date
  if nvl(l_old_aei_information4,'X') <> nvl(p_aei_information4,'X') then
     hr_utility.set_location(l_proc, 310);

     --
     -- considering the manual issue date as the effective date
     --
     l_old_effective_date := fnd_date.canonical_to_date(l_old_aei_information4);
     --

     hr_utility.set_location(l_proc, 320);
     --
     open csr_aggr_paye_flag(p_person_id, l_old_effective_date);
     fetch csr_aggr_paye_flag into l_old_aggregated_paye_flag;
     close csr_aggr_paye_flag;
     --

     -- Aggregated PAYE, loop through agg assignments in
     --
     if nvl(l_old_aggregated_paye_flag,'X') = 'Y' and l_old_effective_date is not null then
       hr_utility.set_location(l_proc, 330);
       -- Aggregated paye, so loop through active/suspended assignments
       -- in old Tax District, and update manual issue date as null
       -- for each row
       open tax_district(p_assignment_id, l_old_effective_date);
       fetch tax_district into l_old_asg_tax_dist, l_old_period_of_service_id;
       close tax_district;
       --

       --
       -- to fetch the latest aggregation start date near to old override date.
       --
       l_old_latest_aggr_start_date := null;
       open csr_latest_aggr_start_date(p_person_id, l_old_effective_date);
       fetch csr_latest_aggr_start_date into l_old_latest_aggr_start_date;
       close csr_latest_aggr_start_date;
       --

       hr_utility.set_location(l_proc, 340);
       --
       -- fetching all the agg asg's based on the old override date
       --
       for r_rec in csr_per_agg_asg_extra(p_person_id, l_old_asg_tax_dist,
                                         l_old_effective_date,
                                         l_information_type, p_assignment_id,
                                         l_old_period_of_service_id)
       loop
        hr_utility.set_location(l_proc, 350);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_old_asg_tax_dist and
                       l_rec_period_of_service_id = l_old_period_of_service_id then

          hr_utility.set_location(l_proc, 360);

          if l_old_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 370);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and old override date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_old_latest_aggr_start_date, l_old_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
             hr_utility.set_location(l_proc, 380);

             --
             -- if extra info id already exists for the asg and override date is same, then update as null
             --
             if r_rec.assignment_extra_info_id is not null and r_rec.aei_information4 = l_old_aei_information4 then
               hr_utility.set_location(l_proc, 390);

               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => r_rec.aei_information3
               ,p_aei_information4           => null);
             end if;
             --
           end if;
         end if; -- paye reference, period of service id same
       end loop;
     end if;

    hr_utility.set_location(l_proc, 400);

    --
    -- considering the entered override date as the effective date
    --
    l_effective_date := fnd_date.canonical_to_date(p_aei_information4);
    --

    hr_utility.set_location(l_proc, 410);
    --
    open csr_aggr_paye_flag(p_person_id, l_effective_date);
    fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
    close csr_aggr_paye_flag;
    --

    hr_utility.set_location(l_proc, 420);

    if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then -- PAYE as 'Y'

      -- Aggregated PAYE, loop through agg assignments in
      -- current tax district
      hr_utility.set_location(l_proc, 430);

      -- Aggregated paye, so loop through active assignments
      -- in current Tax District, and insert a row for each.
      open tax_district(p_assignment_id, l_effective_date);
      fetch tax_district into l_asg_tax_dist, l_period_of_service_id;
      close tax_district;
      --

      --
      -- to fetch the latest aggregation start date near to override date.
      --
      l_latest_aggr_start_date := null;
      open csr_latest_aggr_start_date(p_person_id, l_effective_date);
      fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
      close csr_latest_aggr_start_date;
      --

      hr_utility.set_location(l_proc, 440);

      --
      -- if extra info already exists for the asg and override date is null then update
      -- if extra info not found for the asg then insert extra info for that asg.
      --
      for r_rec in csr_per_agg_asg_extra(p_person_id, l_asg_tax_dist,
                                     l_effective_date, l_information_type
                                     , p_assignment_id, l_period_of_service_id) loop
        hr_utility.set_location(l_proc, 450);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 460);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 470);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and override date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
            hr_utility.set_location(l_proc, 480);

            --
            -- extra info id null then insert only the override date
            if r_rec.assignment_extra_info_id is null then
              hr_utility.set_location(l_proc, 490);
              hr_assignment_extra_info_api.create_assignment_extra_info
               (p_validate                 => p_validate
               ,p_assignment_id            => r_rec.assignment_id
               ,p_information_type         => l_information_type
               ,p_aei_information_category => p_aei_information_category
               ,p_aei_information1         => null
               ,p_aei_information2         => null
               ,p_aei_information3         => null
               ,p_aei_information4         => p_aei_information4
               ,p_object_version_number    => l_object_version_number
               ,p_assignment_extra_info_id => l_assignment_extra_info_id);

            -- extra info id not null and override date is null then update
            elsif r_rec.assignment_extra_info_id is not null and r_rec.aei_information4 is null then
               hr_utility.set_location(l_proc, 500);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => r_rec.aei_information3
               ,p_aei_information4           => p_aei_information4);

            end if;
            --
          end if;
        end if; -- paye reference, period of service id same
      end loop;
    end if; -- PAYE as 'Y'
  end if; -- old and new override are different

  hr_utility.set_location(' Leaving:'||l_proc, 600);
--  hr_utility.trace_off;
end pay_gb_upd_p45_info;
-- -----------------------------------------------------------------------
-- |-------------------------< pay_gb_del_p45_info>-----------------------|
-- -----------------------------------------------------------------------
procedure pay_gb_del_p45_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
  )is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_del_p45_info';
  l_asg_tax_dist        varchar2(50);
  l_person_id           number;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

  --
  cursor csr_aggr_paye_flag (c_person_id in number,
                             c_effective_date in date) is
    select per_information10
    from   per_all_people_f
    where  person_id = c_person_id
    and    c_effective_date between
           effective_start_date and effective_end_date;
  --

  l_effective_date       date;
  l_aggregated_paye_flag per_all_people_f.per_information10%type;
  l_period_of_service_id per_all_assignments_f.period_of_service_id%type;
  l_assignment_id        per_all_assignments_f.assignment_id%type;
  l_object_version_number number;

  l_aei_information3 per_assignment_extra_info.aei_information3%type;
  l_aei_information4 per_assignment_extra_info.aei_information4%type;
  l_information_type per_assignment_extra_info.information_type%type;

  --
  cursor csr_aei_info(c_assignment_extra_info_id number) is
    select aei_information3, aei_information4, information_type, assignment_id
    from   per_assignment_extra_info
    where  assignment_extra_info_id = c_assignment_extra_info_id;
  --

  --
  CURSOR tax_district(c_assignment_id in number,
                      c_effective_date in date) IS
    SELECT hsck.segment1, period_of_service_id, person_id
    FROM   hr_soft_coding_keyflex hsck,
           pay_all_payrolls_f papf,
           per_all_assignments_f paaf
    WHERE  hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
    AND    papf.payroll_id = paaf.payroll_id
    AND    paaf.assignment_id = c_assignment_id
    AND    c_effective_date between
             papf.effective_start_date and papf.effective_end_date
    AND    c_effective_date between
             paaf.effective_start_date and paaf.effective_end_date;
  --

  --
  -- to fetch all the aggregated assignments and corresponding extra info
  -- based on old effective date. if the extra info id is not null then update information as null
  -- if both are same, effective date and manual issue date/override date; else no need to update.
  -- based on new effective date, if the extra info id is null then insert else update
  -- except the current assignment; will delete separately after fetching the old values
  --
  cursor csr_per_agg_asg_extra (c_person_id in number,
                                c_tax_ref in varchar2,
                                c_effective_date in date,
                                c_information_type in varchar2,
                                c_assignment_id in number,
                                c_period_of_service_id in number) is
   select distinct
          a.assignment_id,
          extra.assignment_extra_info_id,
          extra.object_version_number ovn,
          extra.aei_information_category,
          extra.aei_information1,
          extra.aei_information2,
          extra.aei_information3,
          extra.aei_information4
   from   per_all_assignments_f a,
          pay_all_payrolls_f pay,
          hr_soft_coding_keyflex flex,
          per_assignment_status_types past,
          per_assignment_extra_info extra
   where  a.person_id   = c_person_id
   and    flex.segment1 = c_tax_ref
   and    pay.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   and    a.payroll_id  = pay.payroll_id
   and    extra.assignment_id(+)      = a.assignment_id
   and    extra.information_type(+)   = c_information_type
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
   and    a.period_of_service_id = c_period_of_service_id
   and    c_effective_date between
            pay.effective_start_date and pay.effective_end_date
   and    a.effective_start_date <= pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_ref, c_effective_date)
   and    a.effective_end_date   >= pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_ref, c_effective_date)
   and    a.assignment_id        <> c_assignment_id
  ;
  --
  -- to fetch the last active/susp status date for the given assignment
  --
  cursor  csr_asg_last_active_date(c_assignment_id number) is
   select max(effective_end_date)
   from   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.assignment_id = c_assignment_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

  --
  -- to fetch the earliest aggregation start date near to the manual issue date/override date.
  --
  cursor  csr_latest_aggr_start_date(c_person_id number, c_effective_date date) is
   select max(effective_end_date) + 1
   from   per_all_people_f
   where  person_id = c_person_id
   and    nvl(per_information10,'N') = 'N'
   and    effective_end_date < c_effective_date;

  --
  -- to check whether the given assignment present between
  -- the earliest aggregation start date and manual issue date/override date.
  --
  cursor  csr_asg_present_status(c_assignment_id number, c_start_date date, c_end_date date) is
   select 1
   from   per_all_assignments_f a
   where  a.assignment_id = c_assignment_id
   and    a.effective_end_date   >= c_start_date
   and    a.effective_start_date <= c_end_date;

  l_found                    boolean;
  l_dummy                    number;
  l_asg_last_active_date     date;
  l_rec_asg_tax_dist         varchar2(50);
  l_rec_period_of_service_id number;
  l_latest_aggr_start_date   date;
  --

begin
--  hr_utility.trace_on(null, 'ARUL');
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  hr_utility.set_location(l_proc,20);

  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.trace('p_assignment_extra_info_id = ' || p_assignment_extra_info_id);

  hr_utility.set_location(l_proc, 30);
  --
  -- fething the manual issue date, extra information type, assignment id
  --
  open csr_aei_info(p_assignment_extra_info_id);
  fetch csr_aei_info into l_aei_information3, l_aei_information4, l_information_type, l_assignment_id;
  close csr_aei_info;
  --

  hr_utility.set_location(l_proc, 40);

  -- delete the current asg extra info details separately
  --
  hr_assignment_extra_info_api.delete_assignment_extra_info
     (p_validate                 => false,
      p_assignment_extra_info_id => p_assignment_extra_info_id,
      p_object_version_number    => p_object_version_number);
  -- deletion for the current asg extra info ends


  -- first update EIT info based on the manual issue date then
  -- continue the same based on override date

  hr_utility.set_location(l_proc, 50);
  --
  -- considering the manual issue date as the effective date
  --
  l_effective_date := fnd_date.canonical_to_date(l_aei_information3);
  --

  hr_utility.set_location(l_proc, 60);
  --
  -- fetch the tax district, period of servive id and persion id
  -- from the given asg extra info id
  --
  open tax_district(l_assignment_id, l_effective_date);
  fetch tax_district into l_asg_tax_dist, l_period_of_service_id, l_person_id;
  close tax_district;
  --

  hr_utility.set_location(l_proc, 70);
  --
  -- fetching the Agg. PAYE flag value on the effective date
  --
  open csr_aggr_paye_flag(l_person_id, l_effective_date);
  fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
  close csr_aggr_paye_flag;
  --

  hr_utility.set_location(l_proc, 80);
  --
  -- When PAYE as 'Y' then update all the agg asg extra info manual issue date as null
  -- if the manual issue date is same with current asg' manual issue date
  --
  if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then
    -- Aggregated PAYE, loop through agg assignments in
    -- current tax district
    --
    hr_utility.set_location(l_proc, 90);

    --
    -- to fetch the latest aggregation start date near to manual issue date.
    --
    l_latest_aggr_start_date := null;
    open csr_latest_aggr_start_date(l_person_id, l_effective_date);
    fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
    close csr_latest_aggr_start_date;
    --

    --
    -- fetching all the agg asg extra info details except the current asg extra info
    --
    for r_rec in csr_per_agg_asg_extra(l_person_id, l_asg_tax_dist,
                                       l_effective_date, l_information_type,
                                       l_assignment_id, l_period_of_service_id) loop
        hr_utility.set_location(l_proc, 100);
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id, l_person_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 110);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 120);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and manual issue date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
            hr_utility.set_location(l_proc, 130);

            --
            -- if extra info id not null and manual issue date is same as current manual issue date then update as null
            --
            if r_rec.assignment_extra_info_id is not null and r_rec.aei_information3 = l_aei_information3 then
               hr_utility.set_location(l_proc, 140);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => null
               ,p_aei_information4           => r_rec.aei_information4);
            end if;
            --
          end if;
        end if; -- paye reference, period of service id same
    end loop;
    --
  end if; -- PAYE as 'Y'
  --


  hr_utility.set_location(l_proc, 150);
  --
  -- considering the override date as the effective date
  --
  l_effective_date := fnd_date.canonical_to_date(l_aei_information4);
  --

  hr_utility.set_location(l_proc, 160);
  --
  -- fetch the tax district, period of servive id and persion id
  -- from the given asg extra info id
  --
  open tax_district(l_assignment_id, l_effective_date);
  fetch tax_district into l_asg_tax_dist, l_period_of_service_id, l_person_id;
  close tax_district;
  --

  hr_utility.set_location(l_proc, 170);
  --
  -- fetching the Agg. PAYE flag value on the effective date
  --
  open csr_aggr_paye_flag(l_person_id, l_effective_date);
  fetch csr_aggr_paye_flag into l_aggregated_paye_flag;
  close csr_aggr_paye_flag;
  --

  hr_utility.set_location(l_proc, 180);
  --
  -- When PAYE as 'Y' then update all the agg asg extra info override date as null
  -- if the override date is same with current asg' override date
  --
  if nvl(l_aggregated_paye_flag,'X') = 'Y' and l_effective_date is not null then
    -- Aggregated PAYE, loop through agg assignments in
    -- current tax district
    --
    hr_utility.set_location(l_proc, 190);

    --
    -- to fetch the latest aggregation start date near to override date.
    --
    l_latest_aggr_start_date := null;
    open csr_latest_aggr_start_date(l_person_id, l_effective_date);
    fetch csr_latest_aggr_start_date into l_latest_aggr_start_date;
    close csr_latest_aggr_start_date;
    --

    --
    -- fetching all the agg asg extra info details except the current asg extra info
    --
    for r_rec in csr_per_agg_asg_extra(l_person_id, l_asg_tax_dist,
                                       l_effective_date, l_information_type,
                                       l_assignment_id, l_period_of_service_id) loop
        --
        -- fetch the last active/susp status of the r_rec assignemnt
        --
        l_asg_last_active_date := null;
        open csr_asg_last_active_date(r_rec.assignment_id);
        fetch csr_asg_last_active_date into l_asg_last_active_date;
        close csr_asg_last_active_date;
        --

        --
        -- fetch the tax reference and period of service id for the r_rec asg
        -- on the last active/susp status date
        --
        open tax_district(r_rec.assignment_id, l_asg_last_active_date);
        fetch tax_district into l_rec_asg_tax_dist, l_rec_period_of_service_id, l_person_id;
        l_found := tax_district%found;
        close tax_district;
        --

        if l_found and l_rec_asg_tax_dist = l_asg_tax_dist and
                       l_rec_period_of_service_id = l_period_of_service_id then

          hr_utility.set_location(l_proc, 200);

          if l_latest_aggr_start_date is not null then
             hr_utility.set_location(l_proc, 210);
             --
             -- to check whther the given assignment present between
             -- the earliest aggregation start date and manual issue date
             --
             open csr_asg_present_status(r_rec.assignment_id, l_latest_aggr_start_date, l_effective_date);
             fetch csr_asg_present_status into l_dummy;
             l_found := csr_asg_present_status%found;
             close csr_asg_present_status;
             --
          end if;

          if l_found then
            hr_utility.set_location(l_proc, 220);

            --
            -- if extra info id not null and override date is same as current override date then update as null
            --
            if r_rec.assignment_extra_info_id is not null and r_rec.aei_information4 = l_aei_information4 then
               hr_utility.set_location(l_proc, 230);
               l_object_version_number := r_rec.ovn;
               hr_assignment_extra_info_api.update_assignment_extra_info
               (p_validate                   => p_validate
               ,p_assignment_extra_info_id   => r_rec.assignment_extra_info_id
               ,p_object_version_number      => l_object_version_number
               ,p_aei_information_category   => r_rec.aei_information_category
               ,p_aei_information1           => r_rec.aei_information1
               ,p_aei_information2           => r_rec.aei_information2
               ,p_aei_information3           => r_rec.aei_information3
               ,p_aei_information4           => null);
            end if;
            --
          end if;
        end if; -- paye reference, period of service id same
    end loop;
    --
  end if; -- PAYE as 'Y'
  --

  hr_utility.set_location(' Leaving:'||l_proc, 300);
--  hr_utility.trace_off;
 end pay_gb_del_p45_info;
-- --------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46>-----------------------|
-- --------------------------------------------------------------------
/* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FLAG */
procedure pay_gb_ins_p46
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_ins_p46';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  -- Bug 3454500 check for Send EDI flag
  if (p_aei_information3 is null and p_aei_information6 is null) then
    hr_utility.set_message(800, 'HR_GB_78120_MISSING_EDI_FLAG');
    hr_utility.set_message_token('TYPE','P46');
    hr_utility.raise_error;
  end if;
  --
  -- Call the Assignment Extra Information Business API
  /* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FLAG */
  hr_assignment_extra_info_api.create_assignment_extra_info
(p_validate                 =>  p_validate
,p_assignment_id            =>  p_assignment_id
,p_information_type         =>  p_information_type
,p_aei_information_category => p_aei_information_category
,p_aei_information1         => p_aei_information1
,p_aei_information2         => p_aei_information2
,p_aei_information3         => p_aei_information3
,p_aei_information4         => p_aei_information4
,p_aei_information5         => p_aei_information5
,p_aei_information6         => p_aei_information6
,p_object_version_number    => p_object_version_number
,p_assignment_extra_info_id => p_assignment_extra_info_id);

  hr_utility.set_location(' Leaving:'||l_proc, 40);
end pay_gb_ins_p46;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46>-----------------------|
-- ----------------------------------------------------------------------------
/* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FlAG */
procedure pay_gb_upd_p46
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_upd_p46';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the Assignment Extra Information Business API
  --
  /* BUG 1843915 Added parameter p_aei_information3  for
     passing value of P46_SEND_EDI_FlAG */
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  );
--
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end pay_gb_upd_p46;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46_pennot>-----------------------|
-- ----------------------------------------------------------------------------
-- Bug 1843915 Added the parameter p_aei_information4 to insert the column
-- P46_PENNOT_SEND_EDI_FLAG

procedure pay_gb_ins_p46_pennot
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10              in     varchar2 default null
  ,p_aei_information11              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_ins_p46_pennot';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  -- Bug 3454500 check for Send EDI flag
  if (p_aei_information4 is null) then
    hr_utility.set_message(800, 'HR_GB_78120_MISSING_EDI_FLAG');
    hr_utility.set_message_token('TYPE','P46 Pension Notification');
    hr_utility.raise_error;
  end if;
  --
  -- Call the Assignment Extra Information Business API
  --
-- Bug 1843915 Added the parameter p_aei_information4 to insert the column
-- P46_PENNOT_SEND_EDI_FLAG

  hr_assignment_extra_info_api.create_assignment_extra_info
(p_validate                 =>  p_validate
,p_assignment_id            =>  p_assignment_id
,p_information_type         =>  p_information_type
,p_aei_information_category => p_aei_information_category
,p_aei_information1         => p_aei_information1
,p_aei_information2         => p_aei_information2
,p_aei_information3         => p_aei_information3
,p_aei_information4         => p_aei_information4
,p_aei_information5         => p_aei_information5
,p_aei_information6         => p_aei_information6
,p_aei_information7         => p_aei_information7
,p_aei_information8         => p_aei_information8
,p_aei_information9         => p_aei_information9
,p_aei_information10        => p_aei_information10
,p_aei_information11        => p_aei_information11
,p_object_version_number    => p_object_version_number
,p_assignment_extra_info_id => p_assignment_extra_info_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end pay_gb_ins_p46_pennot;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46_pennot>-----------------------|
-- ----------------------------------------------------------------------------
-- Bug 1843915 Added the parameter p_aei_information4 to insert the column
-- P46_PENNOT_SEND_EDI_FLAG

procedure pay_gb_upd_p46_pennot
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10              in     varchar2 default null
  ,p_aei_information11              in     varchar2 default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_upd_p46_pennot';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    hr_utility.set_location(l_proc, 30);
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_location(l_proc, 40);
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 50);
  --
  -- Call the Assignment Extra Information Business API
  --
-- Bug 1843915 Added the parameter p_aei_information4 to insert the column
-- P46_PENNOT_SEND_EDI_FLAG

  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
,p_aei_information_category => p_aei_information_category
,p_aei_information1         => p_aei_information1
,p_aei_information2         => p_aei_information2
,p_aei_information3         => p_aei_information3
,p_aei_information4         => p_aei_information4
,p_aei_information5         => p_aei_information5
,p_aei_information6         => p_aei_information6
,p_aei_information7         => p_aei_information7
,p_aei_information8         => p_aei_information8
,p_aei_information9         => p_aei_information9
,p_aei_information10        => p_aei_information10
,p_aei_information11        => p_aei_information11);
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
 end pay_gb_upd_p46_pennot;
--

--P46(Expat):Added API procedures
-- --------------------------------------------------------------------
-- |-------------------------< pay_gb_ins_p46_expat>-----------------------|
-- --------------------------------------------------------------------
procedure pay_gb_ins_p46_expat
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_business_group_id             in     number
  ,p_information_type              in     varchar2
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_object_version_number            out nocopy number
  ,p_assignment_extra_info_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_ins_p46_expat';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  -- Bug 3454500 check for Send EDI flag
  if (p_aei_information3 is null) then
    hr_utility.set_message(800, 'HR_GB_78120_MISSING_EDI_FLAG');
    hr_utility.set_message_token('TYPE','P46');
    hr_utility.raise_error;
  end if;
  --
  -- Call the Assignment Extra Information Business API

hr_assignment_extra_info_api.create_assignment_extra_info
(p_validate                 =>  p_validate
,p_assignment_id            =>  p_assignment_id
,p_information_type         =>  p_information_type
,p_aei_information_category => p_aei_information_category
,p_aei_information1         => p_aei_information1
,p_aei_information2         => p_aei_information2
,p_aei_information3         => p_aei_information3
,p_aei_information4         => p_aei_information4
,p_aei_information5         => p_aei_information5
,p_aei_information6         => p_aei_information6
,p_aei_information7         => p_aei_information7
,p_object_version_number    => p_object_version_number
,p_assignment_extra_info_id => p_assignment_extra_info_id);

  hr_utility.set_location(' Leaving:'||l_proc, 40);
end pay_gb_ins_p46_expat;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< pay_gb_upd_p46_expat>-----------------------|
-- ----------------------------------------------------------------------------
procedure pay_gb_upd_p46_expat
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_business_group_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_legislation_code    varchar2(2);
  l_proc                varchar2(72) := g_package||'pay_gb_upd_p46_expat';
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the Assignment Extra Information Business API
  --
  hr_assignment_extra_info_api.update_assignment_extra_info
  (p_validate                   => p_validate
  ,p_assignment_extra_info_id   => p_assignment_extra_info_id
  ,p_object_version_number      => p_object_version_number
  ,p_aei_information_category   => p_aei_information_category
  ,p_aei_information1           => p_aei_information1
  ,p_aei_information2           => p_aei_information2
  ,p_aei_information3           => p_aei_information3
  ,p_aei_information4           => p_aei_information4
  ,p_aei_information5           => p_aei_information5
  ,p_aei_information6           => p_aei_information6
  ,p_aei_information7           => p_aei_information7
  );
--
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end pay_gb_upd_p46_expat;
--
end pay_gb_aei_api;

/
