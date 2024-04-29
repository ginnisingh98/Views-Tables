--------------------------------------------------------
--  DDL for Package Body PER_ASG_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_BUS2" as
/* $Header: peasgrhi.pkb 120.19.12010000.7 2009/11/20 09:42:17 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_asg_bus2.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_pay_basis_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_pay_basis_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_pay_basis_id             in per_all_assignments_f.pay_basis_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date           in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc                    varchar2(72)  :=  g_package||'chk_pay_basis_id';
   l_api_updating            boolean;
   l_business_group_id       per_business_groups.business_group_id%TYPE;
   l_max_pp_chg_date         date;
--
   --
   -- Cursor to validate that pay basis exists in PER_PAY_BASES
   --
   cursor csr_chk_pay_basis is
     select   business_group_id
     from     per_pay_bases
     where    pay_basis_id = p_pay_basis_id;
   --
   -- Cursor to validate that the validation start date for the assignment is
   -- after all change dates for pay proposals of the assignment.
   --
   cursor csr_get_max_pp_chg_date is
     select   nvl(max(change_date),p_validation_start_date)
     from     per_pay_proposals
     where    assignment_id = p_assignment_id;
   --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check if the assignment is being updated
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
  );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check if the assignment is being inserted or updated.
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.pay_basis_id, hr_api.g_number)
       <> nvl(p_pay_basis_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 3);
    --
    -- Check if the pay basis is set
    --
    if p_pay_basis_id is not null then
      --
      -- Check that the assignment is an Employee or Applicant
      -- or Benefits or Offer assignment.
      -- altered at allow applicants to have a pay basis. 28/1/99
      --
      -- <OAB_CHANGE>
      --
      if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51176_ASG_INV_ASG_TYP_PBS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID'
   );
   --
      end if;
      hr_utility.set_location(l_proc, 4);
      --
      -- Check that the pay basis exists in PER_PAY_BASES.
      --
      open csr_chk_pay_basis;
      fetch csr_chk_pay_basis into l_business_group_id;
      if csr_chk_pay_basis%notfound then
        close csr_chk_pay_basis;
        hr_utility.set_message(801, 'HR_51168_ASG_INV_PAY_BASIS_ID');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID'
   );
      else
        close csr_chk_pay_basis;
      end if;
      hr_utility.set_location(l_proc, 5);
      --
      -- Check that the pay basis is in the same business group as the pay
      -- basis of the assignment.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51169_ASG_INV_PAY_BAS_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 6);
      --
      -- Check if pay basis is being updated
      --
      if l_api_updating then
        --
        -- Get the latest change date for all pay proposals for the assignment
        --
        open csr_get_max_pp_chg_date;
        fetch csr_get_max_pp_chg_date into l_max_pp_chg_date;
        close csr_get_max_pp_chg_date;
        hr_utility.set_location(l_proc, 7);
        --
        -- Check if any pay proposal change dates exist for the assignment
        -- and error if a pay proposal change date exists after the validation
        -- start date for the assignment.
        --
        if l_max_pp_chg_date > p_validation_start_date then
           --
           hr_utility.set_message(801, 'HR_51171_ASG_INV_PB_PP_CD');
           hr_multi_message.add
           (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
      );
           --
        end if;
        hr_utility.set_location(l_proc, 8);
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);
end chk_pay_basis_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_payroll_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_payroll_id
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_payroll_id            in per_all_assignments_f.payroll_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_payroll_id_updated    out nocopy boolean
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc                         varchar2(72) :=  g_package||'chk_payroll_id';
  --
  cursor csr_pradd_exists is
    select   address_line1
    from     per_addresses
    where    person_id = p_person_id
    and      primary_flag='Y'
    and      ( (style='US' and region_1 is not null)
             or style<>'US');
  --
  l_address_line1 per_addresses.address_line1%type;
  --
  cursor csr_get_person_dob is
     select   date_of_birth
     from     per_people_f
     where    person_id    = p_person_id
     and      p_effective_date between effective_start_date
                                   and effective_end_date;
  --
  l_date_of_birth per_all_people_f.date_of_birth%type;
  l_payroll_id_updated boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_pradd_exists;
  fetch csr_pradd_exists into l_address_line1;
  close csr_pradd_exists;
  --
  hr_utility.set_location(l_proc, 20);
  --
  open csr_get_person_dob;
  fetch csr_get_person_dob into l_date_of_birth;
  close csr_get_person_dob;
  --
  hr_utility.set_location(l_proc, 30);
  --
  per_asg_bus2.chk_payroll_id_int
  (p_assignment_id         => p_assignment_id
  ,p_business_group_id     => p_business_group_id
  ,p_assignment_type       => p_assignment_type
  ,p_person_id             => p_person_id
  ,p_payroll_id            => p_payroll_id
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  ,p_effective_date        => p_effective_date
  ,p_datetrack_mode        => p_datetrack_mode
  ,p_address_line1         => l_address_line1
  ,p_date_of_birth         => l_date_of_birth
  ,p_payroll_id_updated    => l_payroll_id_updated
  ,p_object_version_number => p_object_version_number
  );
  --
  p_payroll_id_updated:=l_payroll_id_updated;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 300);
end chk_payroll_id;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_payroll_id_int >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_payroll_id_int
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_payroll_id            in per_all_assignments_f.payroll_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_address_line1         in per_addresses.address_line1%type
  ,p_date_of_birth         in per_all_people_f.date_of_birth%type
  ,p_payroll_id_updated    out nocopy boolean
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_legislation_code             per_business_groups.legislation_code%TYPE;
  l_api_updating                 boolean;
  l_cur_opu_effective_start_date date;
  l_cur_opu_effective_end_date   date;
  l_business_group_id            number(15);
  l_exists                       varchar2(1);
  l_future_change                boolean;
  l_invalid_ppm                  boolean;
  l_min_opu_effective_start_date date;
  l_min_ppm_effective_start_date date;
  l_max_opu_effective_end_date   date;
  l_max_ppm_effective_end_date   date;
  l_org_payment_method_id
                      pay_personal_payment_methods_f.org_payment_method_id%TYPE;
  l_org_pay_method_usage_id
                       pay_org_pay_method_usages_f.org_pay_method_usage_id%TYPE;
  l_personal_payment_method_id
                 pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
  l_proc                         varchar2(72) :=  g_package||'chk_payroll_id_int';
  l_working_start_date           date;
  l_working_end_date             date;

  -- Bug 979903
  cursor csr_get_legc_code is
  select legislation_code
  from per_business_groups_perf
  where business_group_id = p_business_group_id;
  --
  --VS Bug:1402408. 11/14/00
  cursor csr_payroll_exists is
    select   null
    from     sys.dual
    where exists(select   null
                 from     pay_all_payrolls_f pp
                 where    p_effective_date
                          between pp.effective_start_date
                          and     pp.effective_end_date
                 and      pp.payroll_id = p_payroll_id);
   --
   cursor csr_get_bus_grp is
     select   business_group_id
     from     pay_all_payrolls_f
     where    payroll_id    = p_payroll_id
     and      p_effective_date between effective_start_date
                               and     effective_end_date;
  --
  cursor csr_get_ppms is
    select ppm.personal_payment_method_id
          ,ppm.org_payment_method_id
          ,min(ppm.effective_start_date)
          ,max(ppm.effective_end_date)
    from   pay_personal_payment_methods_f ppm
    where  ppm.assignment_id         = p_assignment_id
    and    ppm.effective_start_date <= p_validation_end_date
    and    ppm.effective_end_date   >= p_validation_start_date
    group by ppm.personal_payment_method_id
            ,ppm.org_payment_method_id;
  --
  cursor csr_get_opus
    (c_org_payment_method_id number
    ,c_effective_start_date  date
    ,c_effective_end_date    date
    ) is
    select opu.org_pay_method_usage_id
          ,min(opu.effective_start_date)
          ,max(opu.effective_end_date)
    from   pay_org_pay_method_usages_f opu
    where  opu.org_payment_method_id  = c_org_payment_method_id
    and    opu.payroll_id             = p_payroll_id
    and    opu.effective_start_date  <= c_effective_end_date
    and    opu.effective_end_date    >= c_effective_start_date
    group by opu.org_pay_method_usage_id
    order by 2;
  --
  cursor csr_any_future_changes is
    select null
    from   per_all_assignments_f asg
    where  asg.assignment_id         = p_assignment_id
    and    asg.payroll_id           <> p_payroll_id
    and    asg.effective_start_date <= p_validation_end_date
    and    asg.effective_end_date   >= p_validation_start_date;
  --
  cursor csr_any_future_asas is
    select null
    from   pay_assignment_actions asa
          ,pay_payroll_actions    pra
          ,per_all_assignments_f  paf
    where  asa.assignment_id      = p_assignment_id
    and    pra.payroll_action_id  = asa.payroll_action_id
    --
    -- Fix for bug 3693830 starts here.
    --
    and    paf.assignment_id = p_assignment_id
    and    nvl(paf.payroll_id,-1) <> nvl(p_payroll_id,-1)
    and    paf.effective_end_date >= p_validation_start_date
    and    paf.effective_start_date <= p_validation_end_date
    --
    -- Fix for bug 3693830 ends here.
--
-- Start of Bug fix: 2185300.
--
    and    pra.action_type        not in ('X','BEE')   -- Fix for bug# 2711532
    and    ((pra.effective_date
    between p_validation_start_date
    and p_validation_end_date  )
    --updated for bug 8450873
    /*or  (nvl(pra.date_earned,p_validation_start_date-1)   >= p_validation_start_date
         and nvl(pra.date_earned,p_validation_end_date+1) <= p_validation_end_date )*/
    );
--
-- End of Bug fix: 2185300.
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialize payroll updated flag
  --
  p_payroll_id_updated := FALSE;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if (l_api_updating and
       ((nvl(per_asg_shd.g_old_rec.payroll_id, hr_api.g_number)
         <> nvl(p_payroll_id, hr_api.g_number)) or
        (per_asg_shd.g_old_rec.assignment_type='A' and
         p_assignment_type='E')
       )
     )
    or  NOT l_api_updating
  then
    hr_utility.set_location(l_proc, 40);
    --
    if (l_api_updating and
        nvl(per_asg_shd.g_old_rec.payroll_id, hr_api.g_number)
        <> nvl(p_payroll_id, hr_api.g_number)) then
    --
    -- As payroll id has been updated, set p_payroll_id_updated to true.
    -- This functionality is required for the /update/delete_assignment
    -- business processes
    --
      hr_utility.set_location(l_proc, 45);
      p_payroll_id_updated := TRUE;
    end if;
    --
    if p_payroll_id is not null then
      --
      -- Check that the assignment is an employee or applicant or benefit
      -- or offer assignment.
      -- added functionality to allow applicant to have a payroll specified
      --
      -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
      --
      if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51226_ASG_INV_ASG_TYP_PAY');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check if GEOCODES is installed
      --

-- Bug 979903
      open csr_get_legc_code;
      fetch csr_get_legc_code into l_legislation_code;
      close csr_get_legc_code;

      if hr_general.chk_geocodes_installed = 'Y'
      and p_assignment_type = 'E'
      and ( ( l_legislation_code = 'CA'
              and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
                                                 p_legislation => 'CA'))
            OR ( l_legislation_code = 'US'
              and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
                                                 p_legislation => 'US')))
      then
        --
        -- Check if a primary address exists for the person
        -- of the employee assignment
        --
        if p_address_line1 is null then
          hr_utility.set_message(800, 'PER_52990_ASG_PRADD_NE_PAY');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
          );
          --
        end if;
        hr_utility.set_location(l_proc, 55);
        --
      end if;
      --
      -- Check that payroll exists and the effective start date of the
      -- assignment is the same as or after the effective start date
      -- of the payroll. Also the effective end date of the assignment
      -- is the same as or before the effective end date of the payroll.
      --
      open csr_payroll_exists;
      fetch csr_payroll_exists into l_exists;
      if csr_payroll_exists%notfound then
        close csr_payroll_exists;
        hr_utility.set_message(801, 'HR_7370_ASG_INVALID_PAYROLL');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
          );
      else
        close csr_payroll_exists;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      -- Check that business group of payroll is the
      -- same as that of the assignment
      --
      open csr_get_bus_grp;
      fetch csr_get_bus_grp into l_business_group_id;
      if l_business_group_id <> p_business_group_id then
        close csr_get_bus_grp;
        hr_utility.set_message(801, 'HR_7373_ASG_INVALID_BG_PAYROLL');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
          );
      else
        close csr_get_bus_grp;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that person to whom the assignment is linked
      -- has their D.O.B. recorded on per_people_f
      --
      if p_assignment_type = 'E' then
        hr_utility.set_location(l_proc, 75);
        if p_date_of_birth is null then
          hr_utility.set_message(801, 'HR_7378_ASG_NO_DATE_OF_BIRTH');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DATE_OF_BIRTH'
          );
        end if;
        hr_utility.set_location(l_proc, 80);
      end if;
    end if;
  end if;
  --
  -- Now determine if CHK_PAYROLL_ID / e should be enforced.
  --
  open  csr_any_future_changes;
  fetch csr_any_future_changes into l_exists;
  l_future_change := csr_any_future_changes%FOUND;
  close csr_any_future_changes;
  hr_utility.set_location(l_proc, 90);
  --
  if (l_api_updating
      and  (per_asg_shd.g_old_rec.payroll_id is not null
        and   p_payroll_id                     is not null
        and   per_asg_shd.g_old_rec.payroll_id <> p_payroll_id))
    or  (l_future_change
      and  (p_datetrack_mode = 'DELETE_NEXT_CHANGE'
        or    p_datetrack_mode = 'FUTURE_CHANGE'
        or    p_datetrack_mode = 'UPDATE_OVERRIDE'
        or   p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) --added for bug 8404508
  then
    --
    hr_utility.set_location(l_proc, 100);
    --
    l_invalid_ppm        := FALSE;
    l_working_start_date := p_validation_start_date;
    --
    -- Get all PPMs for this assignment that are effective at some point in the
    -- validation range.
    --
    open  csr_get_ppms;
    fetch csr_get_ppms
     into l_personal_payment_method_id
         ,l_org_payment_method_id
         ,l_min_ppm_effective_start_date
         ,l_max_ppm_effective_end_date;
    --
    hr_utility.set_location(l_proc, 110);
    hr_utility.trace
      ('p_payroll_id                   = ' || p_payroll_id);
    hr_utility.trace
      ('p_validation_start_date        = ' || p_validation_start_date);
    hr_utility.trace
      ('p_validation_end_date          = ' || p_validation_end_date);
    hr_utility.trace
      ('l_personal_payment_method_id   = ' || l_personal_payment_method_id);
    hr_utility.trace
      ('l_org_payment_method_id        = ' || l_org_payment_method_id);
    hr_utility.trace
      ('l_min_ppm_effective_start_date = ' || l_min_ppm_effective_start_date);
    hr_utility.trace
      ('l_max_ppm_effective_end_date   = ' || l_max_ppm_effective_end_date);
    --
    -- If a PPM has been retrieved, and no invalid PPMs have been identified
    -- yet and we have not yet reached the validation end date then check the
    -- current PPM retrieved.
    --
    while csr_get_ppms%FOUND
    and   not l_invalid_ppm
    and   l_working_start_date < p_validation_end_date
    loop
      --
      hr_utility.set_location(l_proc, 120);
      --
      -- Get the latest end date for all OPUs that are effective for the
      -- current working date for the current PPM for the payroll id. As we are
      -- only interested in OPUs that span the current PPM, setting the current
      -- working date to the later of the validation start date or the PPM
      -- start date restricts the date range required.
      --
      if l_min_ppm_effective_start_date > p_validation_start_date
      then
        l_working_start_date := l_min_ppm_effective_start_date;
      else
        l_working_start_date := p_validation_start_date;
      end if;
      --
      if l_max_ppm_effective_end_date < p_validation_end_date
      then
        l_working_end_date := l_max_ppm_effective_end_date;
      else
        l_working_end_date := p_validation_end_date;
      end if;
      --
      hr_utility.set_location(l_proc, 130);
      hr_utility.trace
        ('l_working_start_date = ' || l_working_start_date);
      hr_utility.trace
        ('l_working_end_date   = ' || l_working_end_date);
      --
      open csr_get_opus
        (l_org_payment_method_id
        ,l_working_start_date
        ,l_working_end_date
        );
      fetch csr_get_opus
       into l_org_pay_method_usage_id
           ,l_cur_opu_effective_start_date
           ,l_cur_opu_effective_end_date;
      --
      l_min_opu_effective_start_date := nvl(l_cur_opu_effective_start_date,
                                            hr_api.g_eot);
      l_max_opu_effective_end_date   := nvl(l_cur_opu_effective_end_date,
                                            hr_api.g_date);
      --
      hr_utility.set_location(l_proc, 140);
      hr_utility.trace
        ('l_org_pay_method_usage_id      = ' || l_org_pay_method_usage_id);
      hr_utility.trace
        ('l_min_opu_effective_start_date = ' || l_min_opu_effective_start_date);
      hr_utility.trace
        ('l_max_opu_effective_end_date   = ' || l_max_opu_effective_end_date);
      --
      while csr_get_opus%FOUND
      and   not l_invalid_ppm
      and   (l_min_opu_effective_start_date > l_working_start_date
      or     l_max_opu_effective_end_date   < l_working_end_date
            )
      loop
        --
        hr_utility.set_location(l_proc, 150);
        --
        if l_cur_opu_effective_start_date < l_min_opu_effective_start_date
        then
          l_min_opu_effective_start_date := l_cur_opu_effective_start_date;
        end if;
        --
        if l_cur_opu_effective_end_date > l_max_opu_effective_end_date
        then
          l_max_opu_effective_end_date := l_cur_opu_effective_end_date;
        end if;
        --
        fetch csr_get_opus
         into l_org_pay_method_usage_id
             ,l_cur_opu_effective_start_date
             ,l_cur_opu_effective_end_date;
        --
        hr_utility.set_location(l_proc, 160);
        hr_utility.trace
          ('l_min_opu_effective_start_date = ' ||
           l_min_opu_effective_start_date);
        hr_utility.trace
          ('l_max_opu_effective_end_date   = ' || l_max_opu_effective_end_date);
        hr_utility.trace
          ('l_org_pay_method_usage_id      = ' || l_org_pay_method_usage_id);
        hr_utility.trace
          ('l_cur_opu_effective_start_date = ' ||
           l_cur_opu_effective_start_date);
        hr_utility.trace
          ('l_cur_opu_effective_end_date   = ' || l_cur_opu_effective_end_date);
        --
        if l_cur_opu_effective_start_date - 1 > l_max_opu_effective_end_date
        then
          --
          hr_utility.set_location(l_proc, 170);
          --
          -- We have found a 'hole'.
          --
          -- ie.               h
          --         <--------|o
          --                   l|------------>
          --                   e
          --
          l_invalid_ppm := TRUE;
        end if;
      end loop;
      --
      hr_utility.set_location(l_proc, 180);
      --
      close csr_get_opus;
      --
      if l_min_opu_effective_start_date > l_working_start_date
      or l_max_opu_effective_end_date   < l_working_end_date
      then
        --
        hr_utility.set_location(l_proc, 190);
        --
        l_invalid_ppm := TRUE;
      else
        --
        hr_utility.set_location(l_proc, 200);
        --
        fetch csr_get_ppms
         into l_personal_payment_method_id
             ,l_org_payment_method_id
             ,l_min_ppm_effective_start_date
             ,l_max_ppm_effective_end_date;
        --
        if l_min_ppm_effective_start_date > p_validation_start_date
        then
          l_working_start_date := l_min_ppm_effective_start_date;
        else
          l_working_start_date := p_validation_start_date;
        end if;
        --
        hr_utility.set_location(l_proc, 210);
        hr_utility.trace
          ('l_personal_payment_method_id   = ' || l_personal_payment_method_id);
        hr_utility.trace
          ('l_org_payment_method_id        = ' || l_org_payment_method_id);
        hr_utility.trace
          ('l_min_ppm_effective_start_date = ' ||
           l_min_ppm_effective_start_date);
        hr_utility.trace
          ('l_max_ppm_effective_end_date   = ' || l_max_ppm_effective_end_date);
        --
      end if;
    end loop;
    --
    close csr_get_ppms;
    hr_utility.set_location(l_proc, 220);
    --
    if l_invalid_ppm
    then
      --
      hr_utility.set_location(l_proc, 230);
      --
      hr_utility.set_message(801, 'HR_7969_ASG_INV_PAYROLL_PPMS');
      hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
          );
    end if;
  end if;
  --
  --
  if  (l_api_updating
   --  and  per_asg_shd.g_old_rec.payroll_id <> p_payroll_id changed for bug 8404508
   and NVL(per_asg_shd.g_old_rec.payroll_id,hr_api.g_number)
           <> NVL(p_payroll_id,hr_api.g_number)
      )
  or  (p_datetrack_mode = 'DELETE_NEXT_CHANGE'
  or   p_datetrack_mode = 'FUTURE_CHANGE'
  or   p_datetrack_mode = 'UPDATE_OVERRIDE'
  or   p_datetrack_mode = 'UPDATE_CHANGE_INSERT'            -- added for bug 8404508
      )
  then
    --
    hr_utility.set_location(l_proc, 220);
    --
    -- Find any ASAs that arise after the change effective date.
    --
    open  csr_any_future_asas;
    fetch csr_any_future_asas
     into l_exists;
    --
    if csr_any_future_asas%FOUND
    then
      --
      hr_utility.set_location(l_proc, 230);
      --
      close csr_any_future_asas;
      --
      hr_utility.set_message(801, 'HR_7975_ASG_INV_FUTURE_ASA');
      hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
          );
    else
      --
      hr_utility.set_location(l_proc, 240);
      --
      close csr_any_future_asas;
    end if;
    --
    hr_utility.set_location(l_proc, 250);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 300);
end chk_payroll_id_int;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_people_group_id >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_people_group_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_people_group_id         in     per_all_assignments_f.people_group_id%TYPE
  ,p_vacancy_id              in     per_all_assignments_f.vacancy_id%TYPE
  ,p_validation_start_date   in     per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date     in     per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_proc                 varchar2(72)  :=  g_package||'chk_people_group_id';
  l_vac_people_group_id  per_all_assignments_f.people_group_id%TYPE;
  l_enabled_flag         pay_people_groups.enabled_flag%TYPE;
  --
  cursor csr_valid_people_group is
    select   enabled_flag
    from     pay_people_groups
    where    people_group_id = p_people_group_id
    and      p_validation_start_date
      between nvl(start_date_active,hr_api.g_sot)
      and     nvl(end_date_active,hr_api.g_eot);
  --
  cursor csr_valid_id_flex_num is
    select   null
    from     per_business_groups_perf pbg
             ,pay_people_groups ppg
    where    ppg.people_group_id = p_people_group_id
    and      pbg.people_group_structure = to_char(ppg.id_flex_num)
    and      pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for people group has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.people_group_id, hr_api.g_number) <>
       nvl(p_people_group_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if people group is set
    --
    if p_people_group_id is not null then
      --
      -- Check that the people group exists
      --
      open csr_valid_people_group;
      fetch csr_valid_people_group into l_enabled_flag;
      if csr_valid_people_group%notfound then
        close csr_valid_people_group;
        hr_utility.set_message(801, 'HR_7385_ASG_INV_PEOPLE_GROUP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
        --
      else
        close csr_valid_people_group;
        hr_utility.set_location(l_proc, 50);
        --
        -- Check that the enabled flag is set to 'Y' for the people group.
        --
        If l_enabled_flag <> 'Y' then
          --
          hr_utility.set_message(801, 'HR_51252_ASG_INV_PGP_ENBD_FLAG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID'
     );
          --
        end if;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      -- Check that the id_flex_num value for the
      -- people_group_id can be cross referenced to the
      -- people_group_structure on per_business_groups for
      -- the assignment business group
      --
      open csr_valid_id_flex_num;
      fetch csr_valid_id_flex_num into l_exists;
      if csr_valid_id_flex_num%notfound then
        close csr_valid_id_flex_num;
        hr_utility.set_message(801, 'HR_7386_ASG_INV_PEOP_GRP_LINK');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID'
   );
        --
      else
        close csr_valid_id_flex_num;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
  --
end chk_people_group_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_perf_review_period_freq >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_perf_review_period_freq
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period_frequency in     per_all_assignments_f.perf_review_period_frequency%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc  varchar2(72)  :=  g_package||'chk_perf_review_period_freq';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for performance review period frequency has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.perf_review_period_frequency,
       hr_api.g_varchar2) <> nvl(p_perf_review_period_frequency,
       hr_api.g_varchar2))
    or
      (NOT l_api_updating))
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if performance review period frequency is set
    --
    if p_perf_review_period_frequency is not null then
      --
      -- Check that the assignment is an employee or applicant
      -- or benefit or offer assignment.
      --
      if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51178_ASG_INV_ASG_TYP_PRPF');
         hr_multi_message.add
        (p_associated_column1 =>
   'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD_FREQUENCY'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the performance review period frequency exists in
      -- hr_lookups for the lookup type 'FREQUENCY' with an enabled
      -- flag set to 'Y' and that the effective start date of the
      -- assignment is between start date active and end date active
      -- in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'FREQUENCY'
        ,p_lookup_code           => p_perf_review_period_frequency
        )
      then
        --
        hr_utility.set_message(801, 'HR_51149_ASG_INV_PRP_FREQ');
         hr_multi_message.add
        (p_associated_column1 =>
   'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD_FREQUENCY'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
    end if;
    hr_utility.set_location(l_proc, 70);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
  --
end chk_perf_review_period_freq;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_perf_review_period >------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_perf_review_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period           in per_all_assignments_f.perf_review_period%TYPE
  ,p_assignment_type              in per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc  varchar2(72)  :=  g_package||'chk_perf_review_period';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for perf review period has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.perf_review_period,
       hr_api.g_number) <> nvl(p_perf_review_period,
       hr_api.g_number))
     or (NOT l_api_updating))
  then
    --
    hr_utility.set_location(l_proc, 3);
    --
    -- Check if perf review period is not null
    --
    if p_perf_review_period is not null then
      --
      -- Check that the assignment is an Employee or Applicant
      -- Benefit or Offer assignment.
      --
      if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51179_ASG_INV_ASG_TYP_PRP');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 4);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      =>
    'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 6);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'|| l_proc, 7);
end chk_perf_review_period;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_perf_rp_freq_perf_rp >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_perf_rp_freq_perf_rp
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_perf_review_period_frequency in per_all_assignments_f.perf_review_period_frequency%TYPE
  ,p_perf_review_period           in per_all_assignments_f.perf_review_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc           varchar2(72):= g_package||'chk_perf_rp_freq_perf_rp';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      =>
       'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD'
       ,p_check_column2      =>
       'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD_FREQUENCY'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for perf review period frequency or perf review period has
  -- changed.
  --
  if ((l_api_updating)
    and
      ((nvl(per_asg_shd.g_old_rec.perf_review_period_frequency,
      hr_api.g_varchar2) <> nvl(p_perf_review_period_frequency, hr_api.g_varchar2))
      or
      (nvl(per_asg_shd.g_old_rec.perf_review_period,
      hr_api.g_number) <> nvl(p_perf_review_period, hr_api.g_number)))
    or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if perf review period frequency or perf review period is not null.
    --
    if p_perf_review_period_frequency is not null
       or p_perf_review_period is not null then
       hr_utility.set_location(l_proc, 3);
       --
       -- Check if perf review period frequency or perf review period are null.
       --
       if p_perf_review_period_frequency is null
          or p_perf_review_period is null then
          --
          hr_utility.set_message(801, 'HR_51163_ASG_INV_PRPF_PRP_COMB');
          hr_utility.raise_error;
          --
       end if;
       --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD'
         ,p_associated_column2      =>
    'PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD_FREQUENCY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_perf_rp_freq_perf_rp;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_period_of_service_id >------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_period_of_service_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_person_id              in     per_all_assignments_f.person_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_period_of_service_id   in     per_all_assignments_f.period_of_service_id%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_api_updating             boolean;
  l_exists                   varchar2(1);
  l_proc                     varchar2(72):= g_package||'chk_period_of_service_id';
  l_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE;
  l_business_group_id        per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_valid_pds is
    select   business_group_id, actual_termination_date
    from     per_periods_of_service
    where    period_of_service_id = p_period_of_service_id
    and      p_validation_start_date
      between  date_start
      and      nvl(actual_termination_date, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if NOT l_api_updating then
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- Check that the assignment is an employee assignment.
    --
    if p_assignment_type <> 'E' then
      --
      -- Check that period of service is not set
      --
      If p_period_of_service_id is not null then
        --
        hr_utility.set_message(801, 'HR_51203_ASG_INV_ASG_TYP_PDS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    else
      --
      -- Check the mandatory parameter period of service for
      -- an employee.
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc
        ,p_argument       => 'period_of_service_id'
        ,p_argument_value => p_period_of_service_id
        );
      hr_utility.set_location(l_proc, 60);
      --
      -- Check if the period of service exists between
      -- the period of service date start and actual termination date.
      --
      open csr_valid_pds;
      fetch csr_valid_pds into l_business_group_id, l_actual_termination_date;
      if csr_valid_pds%notfound then
        close csr_valid_pds;
        hr_utility.set_message(801, 'HR_7391_ASG_INV_PERIOD_OF_SERV');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
        --
      else
        close csr_valid_pds;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the period of service is in the same business group
      -- as the business group of the assignment.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51320_ASG_INV_PDS_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Check if the period of service has been closed before the
      -- validation end date.
      --
      If p_validation_end_date > nvl(l_actual_termination_date, hr_api.g_eot) then
        --
        hr_utility.set_message(801, 'HR_6434_EMP_ASS_PER_CLOSED');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 90);
      --
    end if;
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 8);
end chk_period_of_service_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_person_id
  (p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date        in per_all_assignments_f.effective_start_date%TYPE
  )
  is
--
   l_exists             varchar2(1);
   l_business_group_id  number(15);
   l_proc               varchar2(72)  :=  g_package||'chk_person_id';
   --
   cursor csr_get_bus_grp is
     select   ppf.business_group_id
     from     per_people_f ppf
     where    ppf.person_id = p_person_id
     and      p_effective_date between ppf.effective_start_date
                               and     ppf.effective_end_date;
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that person business group is the same as
  -- the assignment business group
  --
  open csr_get_bus_grp;
  fetch csr_get_bus_grp into l_business_group_id;
  if l_business_group_id <> p_business_group_id then
    close csr_get_bus_grp;
    hr_utility.set_message(801, 'HR_7374_ASG_INVALID_BG_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_get_bus_grp;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 4);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 5);
end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_person_referred_by_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_person_referred_by_id
  (p_assignment_id             in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type           in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id         in     per_all_assignments_f.business_group_id%TYPE
  ,p_person_id                 in     per_all_assignments_f.person_id%TYPE
  ,p_person_referred_by_id     in     per_all_assignments_f.person_referred_by_id%TYPE
  ,p_effective_date            in     date
  ,p_object_version_number     in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date     in     date
  ,p_validation_end_date       in     date
  )
  is
--
  l_proc                   varchar2(72)  :=  g_package||'chk_person_referred_by_id';
  l_api_updating           boolean;
  l_exists                 varchar2(1);
  l_business_group_id      per_all_assignments_f.business_group_id%TYPE;
  l_current_employee_flag  per_people_f.current_employee_flag%TYPE;
  l_current_npw_flag       per_people_f.current_npw_flag%TYPE;
  --
  cursor csr_val_prb_id is
    select   business_group_id, current_employee_flag, current_npw_flag
    from     per_all_people_f
    where    person_id = p_person_referred_by_id
    and      p_validation_start_date
      between  effective_start_date
        and    effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for person referred by has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.person_referred_by_id, hr_api.g_number)
       <> nvl(p_person_referred_by_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if person referred by is not null
    --
    if p_person_referred_by_id is not null then
      --
      -- Check that the assignment is not an applicant or Offer assignment.
      --
      if   p_assignment_type in ('E','B','C')then
        --
        hr_utility.set_message(801, 'HR_51224_ASG_INV_ASG_TYP_PRB');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the person referred by is'nt the same as the person
      -- of the assignment.
      --
      If p_person_referred_by_id = p_person_id then
        --
        hr_utility.set_message(801, 'HR_51304_ASG_APL_EQUAL_PRB');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      -- Check if the person referred by exists where the effective
      -- start date of the assignment is between the effective start
      -- date and effective end date of the person referred by.
      --
      open csr_val_prb_id;
      fetch csr_val_prb_id
      into l_business_group_id, l_current_employee_flag, l_current_npw_flag;
      --
      if csr_val_prb_id%notfound then
        close csr_val_prb_id;
        --
        -- Do not throw an error for Offer Assignment.
        --
        if p_assignment_type <> 'O'
        then
          --
          hr_utility.set_message(801, 'HR_51302_ASG_INV_PER_REF_BY');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
          ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID'
          );
          --
        end if;
        --
      else
        close csr_val_prb_id;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the person referred by is in the same business group
      -- as the business group of the assignment.
      --
      If (p_business_group_id <> l_business_group_id AND
         nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='N')
           then
        --
        hr_utility.set_message(801, 'HR_51303_ASG_INV_PER_REF_BY_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Check that the person referred by is an employee.
      --
      -- Bug 3190625
      -- Condition to check profile value also added
      -- If he is an employee or a contingent worker with the profile set,
      -- no errors shown
      if not ( (nvl(l_current_employee_flag,hr_api.g_varchar2) = 'Y' )  or
             ( nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N') = 'Y'  and
             nvl(l_current_npw_flag, 'N') = 'Y') ) then
        hr_utility.set_message(801, 'HR_51305_ASG_PER_RB_NOT_EMP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID');
        --
      end if;
      hr_utility.set_location(l_proc, 90);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_person_referred_by_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_position_id
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_position_id           in per_all_assignments_f.position_id%TYPE
  ,p_business_group_id     in per_all_assignments_f.business_group_id%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_vacancy_id            in per_all_assignments_f.vacancy_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
is
  --
  l_proc                    varchar2(72)  :=  g_package||'chk_position_id';
  l_exists                  varchar2(1);
  l_api_updating            boolean;
  l_position_id             per_all_assignments_f.position_id%TYPE;
  l_pos_bus_group_id        per_all_assignments_f.business_group_id%TYPE;
  l_vac_position_id         per_all_assignments_f.position_id%TYPE;
  --
  -- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) date tracked position requirement

  cursor csr_valid_pos is
    select   hp.business_group_id
    from     hr_positions_f hp
             , per_shared_types ps
    where    hp.position_id    = p_position_id
    and      p_validation_start_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      p_validation_start_date
    between  hp.date_effective
    and      nvl(hp.date_end, hr_api.g_eot)
    and      ps.shared_type_id = hp.availability_status_id
    and      ps.system_type_cd = 'ACTIVE' ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
     ,p_argument       =>  'effective_date'
     ,p_argument_value =>  p_effective_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_start_date'
     ,p_argument_value =>  p_validation_start_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
     ,p_argument       =>  'validation_end_date'
     ,p_argument_value =>  p_validation_end_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
     ,p_argument       =>  'business_group_id'
     ,p_argument_value =>  p_business_group_id
     );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
         ,p_effective_date        => p_effective_date
         ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating
         and
       nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
    or
       (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that if the value for position_id is not null
    -- then it exists date effective in HR_POSITIONS
    --
    if p_position_id is not null then
      --
      -- Check if the position_id exists date effectively
      --
      open csr_valid_pos;
      fetch csr_valid_pos into l_pos_bus_group_id;
      if csr_valid_pos%notfound then
        close csr_valid_pos;
        hr_utility.set_message(801, 'HR_51000_ASG_INVALID_POS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
      else
        close csr_valid_pos;
      end if;
      hr_utility.set_location(l_proc, 40);
      --
      -- Check if the business_group_id for the assignment matches
      -- the business_group_id in HR_POSITIONS date effectively.
      --
      if l_pos_bus_group_id <> p_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51009_ASG_INVALID_BG_POS');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    --
  --
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 80);
end chk_position_id;
--
------------------------------------------------------------------------------
-------------------< chk_position_id_grade_id >-------------------------------
------------------------------------------------------------------------------
--
procedure chk_position_id_grade_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
  ,p_position_id           in per_all_assignments_f.position_id%TYPE
  ,p_grade_id              in per_all_assignments_f.grade_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  ,p_inv_pos_grade_warning out nocopy boolean
  )
as
  l_proc             varchar2(72)  :=  g_package||'chk_position_id_grade_id';
  l_exists           varchar2(1);
  l_exists1          varchar2(1);  -- Bug 3566686
  l_api_updating     boolean;
  l_inv_pos_grade_warning    boolean := false;
  --
  -- Bug 3566686 Starts Here
  -- Description : The cursor checks whether ther are any grades defined as
  --               the valid grades for the selected POSITION.
  --
  cursor csr_valid_pos_val_grd_exists is
    select   null
    from     per_valid_grades
    where    position_id = p_position_id
    and      p_validation_start_date
    between  date_from
      and      nvl(date_to, hr_api.g_eot);
--
-- Bug 3566686 Ends Here
--
  cursor csr_valid_pos_val_grd is
    select   null
    from     per_valid_grades
    where    position_id = p_position_id
    and      grade_id = p_grade_id
    and      p_validation_start_date
      between  date_from
        and      nvl(date_to, hr_api.g_eot);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_start_date'
     ,p_argument_value =>  p_validation_start_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_end_date'
     ,p_argument_value =>  p_validation_end_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'effective_date'
     ,p_argument_value =>  p_effective_date
     );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id or grade_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date        => p_effective_date
        ,p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
       ((nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_asg_shd.g_old_rec.grade_id, hr_api.g_number) <>
       nvl(p_grade_id, hr_api.g_number))))
    or
       (NOT l_api_updating) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that position_id and grade_id both contain not null values
    --
    if p_position_id is not null and p_grade_id is not null then
      --
      -- Check if the position_id and grade_id exist date effectively
      --
      -- Bug 3566686 Starts Here
      -- Description : The first if condition checks whether there are any
      --               grades defined as the valid grades for the selected
      --               POSITION, if atleast one such grade exists then only
      --               it will check for the validity of the grade selected
      --               for the JOB.
      --
      open csr_valid_pos_val_grd_exists;
      fetch csr_valid_pos_val_grd_exists into l_exists1;
      if csr_valid_pos_val_grd_exists%found then
        close csr_valid_pos_val_grd_exists;
        open csr_valid_pos_val_grd;
        fetch csr_valid_pos_val_grd into l_exists;
        if csr_valid_pos_val_grd%notfound then
          l_inv_pos_grade_warning := true;
        end if;
        close csr_valid_pos_val_grd;
      else
        close csr_valid_pos_val_grd_exists;
      end if;
      --
      -- Bug 3566686 Ends Here
      --
      hr_utility.set_location(l_proc, 3);
      --
    end if;
    --
  end if;
  end if;
  --
  p_inv_pos_grade_warning := l_inv_pos_grade_warning;
  hr_utility.set_location('Leaving'||l_proc, 4);
end chk_position_id_grade_id;
--
------------------------------------------------------------------------------
--------------------------< chk_position_id_org_id >--------------------------
------------------------------------------------------------------------------
--
procedure chk_position_id_org_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
   ,p_position_id           in per_all_assignments_f.position_id%TYPE
   ,p_organization_id       in per_all_assignments_f.organization_id%TYPE
   ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
   ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
   ,p_effective_date        in date
   ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
   )
  as
    l_proc             varchar2(72)  :=  g_package||'chk_position_id_org_id';
    l_exists           varchar2(1);
    l_api_updating     boolean;
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position requirement
--

  cursor csr_valid_pos_org_comb is
    select   null
    from     hr_positions_f hp
             , per_shared_types ps
    where    hp.position_id     = p_position_id
    and      p_validation_start_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      hp.organization_id = p_organization_id
    and      p_validation_start_date
    between  hp.date_effective
    and      nvl(hp.date_end, hr_api.g_eot)
    and      ps.shared_type_id  = hp.availability_status_id
    and      ps.system_type_cd  = 'ACTIVE' ;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_start_date'
     ,p_argument_value =>  p_validation_start_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_end_date'
     ,p_argument_value =>  p_validation_end_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'effective_date'
     ,p_argument_value =>  p_effective_date
     );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id or grade_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
         ,p_effective_date        => p_effective_date
         ,p_object_version_number => p_object_version_number);
  --

  if (l_api_updating and
       ((nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_asg_shd.g_old_rec.organization_id, hr_api.g_number) <>
       nvl(p_organization_id, hr_api.g_number))))
    or
       (NOT l_api_updating) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if the position is null
    --
    If p_position_id is not null then
      --
      -- Check if assignment position_id and organization_id combination
      -- matches the combination in HR_POSITIONS.
      --
      hr_utility.set_location(l_proc, 3);
      open csr_valid_pos_org_comb;
      fetch csr_valid_pos_org_comb into l_exists;
      if csr_valid_pos_org_comb%notfound then
        close csr_valid_pos_org_comb;
        hr_utility.set_message(801, 'HR_51055_ASG_INV_POS_ORG_COMB');
        hr_utility.raise_error;
      end if;
      close csr_valid_pos_org_comb;
      --
    end if;
  end if;
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 4);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
         ,p_associated_column2      => 'PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID'
    ,p_associated_column3      => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_position_id_org_id;
--
------------------------------------------------------------------------------
-------------------------< chk_position_id_job_id >---------------------------
------------------------------------------------------------------------------
--
procedure chk_position_id_job_id
  (p_assignment_id          in per_all_assignments_f.assignment_id%TYPE
  ,p_position_id           in per_all_assignments_f.position_id%TYPE
  ,p_job_id                in per_all_assignments_f.job_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  )
  as
    l_proc             varchar2(72)  :=  g_package||'chk_position_id_job_id';
    l_exists           varchar2(1);
    l_api_updating     boolean;
  --
  -- Changed 02-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position requirement
  --
  cursor csr_valid_pos_job_comb is
    select   null
    from     hr_positions_f hp
             , per_shared_types ps
    where    hp.position_id = p_position_id
    and      p_validation_start_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      hp.job_id = p_job_id
    and      p_validation_start_date
    between  hp.date_effective
    and      nvl(hp.date_end,hr_api.g_eot)
    and      ps.shared_type_id = hp.availability_status_id
    and      ps.system_type_cd = 'ACTIVE' ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_start_date'
     ,p_argument_value =>  p_validation_start_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'validation_end_date'
     ,p_argument_value =>  p_validation_end_date
     );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
     ,p_argument       =>  'effective_date'
     ,p_argument_value =>  p_effective_date
     );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position or job has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
         ,p_effective_date        => p_effective_date
         ,p_object_version_number => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if (l_api_updating and
       ((nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_asg_shd.g_old_rec.job_id, hr_api.g_number) <>
       nvl(p_job_id, hr_api.g_number))))
    or
       (NOT l_api_updating)
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if the assignment job and position are not null
    --
    if p_position_id is not null and p_job_id is not null then
      --
      -- Check if assignment position and job combination matches
      -- the combination in HR_POSITIONS
      --
      open csr_valid_pos_job_comb;
      fetch csr_valid_pos_job_comb into l_exists;
      if csr_valid_pos_job_comb%notfound then
        close csr_valid_pos_job_comb;
        hr_utility.set_message(801, 'HR_51056_ASG_INV_POS_JOB_COMB');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
     ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
     );
      else
        close csr_valid_pos_job_comb;
      end if;
      --
    elsif p_job_id is null and p_position_id is not null then
      --
      -- Position is not null but job is null
      --
      hr_utility.set_message(801, 'HR_51057_ASG_JOB_NULL_VALUE');
      hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.POSITION_ID'
     );
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 3);
end chk_position_id_job_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_primary_flag >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_primary_flag
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_primary_flag          in per_all_assignments_f.primary_flag%TYPE
  ,p_assignment_type       in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id             in per_all_assignments_f.person_id%TYPE
  ,p_period_of_service_id  in per_all_assignments_f.period_of_service_id%TYPE
  ,p_pop_date_start        in DATE
  ,p_effective_date        in date
  ,p_object_version_number in per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ) is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_primary_flag';
  l_api_updating   boolean;
  --
  cursor csr_asg_exists is
    select   null
    from     per_all_assignments_f
    where    person_id = p_person_id
    and      period_of_service_id = p_period_of_service_id
    and      primary_flag = 'Y';
  --
  cursor csr_cwk_asg_exists is
    select   null
    from     per_all_assignments_f
    where    person_id = p_person_id
    and      period_of_placement_date_start = p_pop_date_start
    and      primary_flag = 'Y';
--
-- 120.10 (START)
--
  CURSOR csr_get_bg_id IS
    SELECT business_group_id
      FROM per_all_people_f
     WHERE person_id = p_person_id
       AND p_effective_date BETWEEN effective_start_date
                                AND effective_end_date;
  --
  l_bg_id per_all_people_f.business_group_id%TYPE;
  --
  CURSOR csr_chk_amends (p_bg_id per_all_people_f.business_group_id%TYPE) IS
    SELECT per_system_status
    FROM   per_ass_status_type_amends
    WHERE  assignment_status_type_id = per_asg_shd.g_old_rec.assignment_status_type_id
    AND    business_group_id = csr_chk_amends.p_bg_id;
  --
  CURSOR csr_valid_ast IS
    SELECT per_system_status
    FROM   per_assignment_status_types
    WHERE  assignment_status_type_id = per_asg_shd.g_old_rec.assignment_status_type_id;
  --
  l_per_system_status per_assignment_status_types.per_system_status%TYPE;
--
-- 120.10 (END)
--
  --
  -- Bug 2782545. Removed the validation that checks the primary
  -- assignment continues until the validation_end_date because
  -- the primary assignment can be different at the validation start
  -- and end.  It is instead safe to assume that if there is a primary
  -- assignment at the start there will be one at the end.
  -- An exception to this is corrupt data and it could be possible
  -- to check for that here but it means checking every date-track
  -- update for one and only primary assignment: high risk and
  -- reduced performance.
  --
--
-- 120.10 (START)
--
  --cursor csr_ins_non_prim is
  cursor csr_ins_non_prim (p_per_system_status VARCHAR2) is
--
-- 120.10 (END)
--
    select   null
    from     sys.dual
    where exists
      (select  null
       from    per_all_assignments_f pas
       where   pas.effective_start_date <= p_validation_start_date
       and     pas.person_id = p_person_id
       and     pas.period_of_service_id = p_period_of_service_id
--
-- 120.10 (START)
--
       --and     pas.primary_flag = 'Y');
       and     pas.primary_flag = 'Y')
    or (csr_ins_non_prim.p_per_system_status = 'TERM_ASSIGN' and exists
         (select null
          from   per_all_assignments_f pas1
          where  pas1.effective_start_date <= p_validation_start_date
          and    pas1.person_id = p_person_id
          and    pas1.period_of_service_id <> p_period_of_service_id
          and    pas1.primary_flag = 'Y'
         )
       );
--
-- 120.10 (END)
--

  cursor csr_ins_non_cwk_prim is
    select   null
    from     sys.dual
    where exists
      (select  null
       from    per_all_assignments_f pas
       where   pas.effective_start_date <= p_validation_start_date
       and     pas.person_id = p_person_id
       and     pas.period_of_placement_date_start = p_pop_date_start
       and     pas.primary_flag = 'Y');

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'primary_flag'
    ,p_argument_value => p_primary_flag
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc

    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for primary flag has changed
  --
  l_api_updating := per_asg_shd.api_updating
     (p_assignment_id          => p_assignment_id
     ,p_effective_date         => p_effective_date
     ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.primary_flag, hr_api.g_varchar2) <>
      nvl(p_primary_flag, hr_api.g_varchar2)) or
     (NOT l_api_updating)) then
    --
    -- Check if primary flag is either 'Y' or 'N'.
    --
    If p_primary_flag not in('Y','N') then
      --
      per_asg_shd.constraint_error
        (p_constraint_name => 'PER_ASS_PRIMARY_FLAG_CHK');
      --
      hr_utility.set_location(l_proc, 30);
      --
    end if;
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- If inserting 'primary' assignment, check that no
    -- other primary assignments exist for the person
    -- the new assignment is linked to
    --
    if p_primary_flag = 'Y' then
      --
      -- Check if the assignment is an applicant or offer assignment
      --
      if p_assignment_type = 'A'
      or p_assignment_type = 'O' then
        --
        hr_utility.set_message(801, 'HR_51198_ASG_INV_APL_ASG_PF');
      --
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PRIMARY_FLAG');
        --
      end if;
     --
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the effective end date is the end of time
      --
      If p_validation_end_date <> hr_api.g_eot then
        --
        hr_utility.set_message(801, 'HR_51323_ASG_INV_PRIM_ASG_EED');
      --
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE');
        --
      end if;
      --
      hr_utility.set_location(l_proc, 60);
      --
      if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
        ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID') then
        --
        hr_utility.set_location(l_proc, 70);
        --
        if p_assignment_type = 'C' then
          --
          hr_utility.set_location(l_proc, 80);
          --
          open csr_cwk_asg_exists;
          fetch csr_cwk_asg_exists into l_exists;
          --
          if csr_cwk_asg_exists%found then
            --
            close csr_cwk_asg_exists;
            --
            hr_utility.set_message(801, 'HR_7435_ASG_PRIM_ASS_EXISTS');
            --
            hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
              ,p_associated_column2 =>
             'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_PLACEMENT_DATE_START');
            --
          else
            --
            close csr_cwk_asg_exists;
            --
          end if;
          --
          hr_utility.set_location(l_proc, 90);
          --
        elsif p_assignment_type = 'E' then
          --
          hr_utility.set_location(l_proc, 100);
          --
          -- Check if a primary assignment already exists
          --
          open csr_asg_exists;
          fetch csr_asg_exists into l_exists;
        --
          if csr_asg_exists%found then
            --
            close csr_asg_exists;
            --
            hr_utility.set_message(801, 'HR_7435_ASG_PRIM_ASS_EXISTS');
            --
            hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
              ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID');
            --
          else
            --
            close csr_asg_exists;
            --
          end if;
          --
          hr_utility.set_location(l_proc, 110);
          --
        end if;
        --
      end if; -- no exclusive error
      --
      hr_utility.set_location(l_proc, 120);
      --
    else
      --
      hr_utility.set_location(l_proc, 130);
      --
      -- Check if the assignment is an employee assignment or a
      -- non payrolled worker assignment.
      --
      if p_assignment_type IN ('E','C') then
        --
        -- Check that a primary employee assignment exists during
        -- the entire date range of the non-primary assignment.
        --
        hr_utility.set_location(l_proc, 140);
        --
        if hr_multi_message.no_exclusive_error
          (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
          ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID') then
          --
          hr_utility.set_location(l_proc, 150);
          --
          -- Check that the primary cwk assignment exists during
          -- the entire date range of the non-primary assignment
          --
          if p_assignment_type = 'C' then
            --
            hr_utility.set_location(l_proc, 160);
            --
            open csr_ins_non_cwk_prim;
            fetch csr_ins_non_cwk_prim into l_exists;
            --
            if csr_ins_non_cwk_prim%notfound then
              --
              close csr_ins_non_cwk_prim;
              --
              hr_utility.set_message(801, 'HR_7436_ASG_NO_PRIM_ASS');
              --
              hr_multi_message.add
                (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
                ,p_associated_column2 =>
            'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_PLACEMENT_DATE_START'
                ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
                ,p_associated_column4 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE');
              --
            else
              --
              close csr_ins_non_cwk_prim;
              --
            end if;
            --
            hr_utility.set_location(l_proc, 170);
            --
          elsif p_assignment_type = 'E' then
            --
            hr_utility.set_location(l_proc, 180);
            --
--
-- 120.10 (START)
--
            --
            -- Get the person's BG Id
            --
            OPEN csr_get_bg_id;
            FETCH csr_get_bg_id INTO l_bg_id;
            CLOSE csr_get_bg_id;
            --
            -- Check for user defined assignment status
            --
            OPEN csr_chk_amends(l_bg_id);
            FETCH csr_chk_amends INTO l_per_system_status;
            IF csr_chk_amends%NOTFOUND THEN
              --
              -- Check for delivered assignment status
              --
              OPEN csr_valid_ast;
              FETCH csr_valid_ast INTO l_per_system_status;
              CLOSE csr_valid_ast;
            END IF;
            CLOSE csr_chk_amends;
            --open csr_ins_non_prim;
            open csr_ins_non_prim(l_per_system_status);
--
-- 120.10 (END)
--
            fetch csr_ins_non_prim into l_exists;
            --
            if csr_ins_non_prim%notfound then
              --
              close csr_ins_non_prim;
              --
              hr_utility.set_message(801, 'HR_7436_ASG_NO_PRIM_ASS');
              --
              hr_multi_message.add
                (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
               ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID'
               ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
               ,p_associated_column4 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE');
              --
            else
              --
              close csr_ins_non_prim;
              --
            end if;
            --
            hr_utility.set_location(l_proc, 190);
            --
          end if;
          --
        end if; -- no exclusive error
        --
        hr_utility.set_location(l_proc, 200);
        --
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 999);
  --
end chk_primary_flag;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_probation_period >---------------------------|
--  ---------------------------------------------------------------------------
procedure chk_probation_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_probation_period             in per_all_assignments_f.probation_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_probation_period';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for probation period has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.probation_period, hr_api.g_number)
       <> nvl(p_probation_period, hr_api.g_number))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check that if probation period is set then it's value
    -- is in the range 0 to 9999.99
    --
    -- Bug 3293930. Extended the maximum limit of probation period
    -- from 99.99 to 9999.99
    if p_probation_period is not null
      and p_probation_period not between 0 and 9999.99
    then
      --
      hr_utility.set_message(801, 'HR_51167_ASG_PB_PD_OUT_OF_RAN');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 50);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
--
end chk_probation_period;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_probation_unit >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_probation_unit
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_probation_unit               in     per_all_assignments_f.probation_unit%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
   l_proc           varchar2(72)  :=  g_package||'chk_probation_unit';
   l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for probation unit has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.probation_unit, hr_api.g_varchar2)
       <> nvl(p_probation_unit, hr_api.g_varchar2))
    or
      (NOT l_api_updating))
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if probation unit is not null
    --
    if p_probation_unit is not null then
      --
      -- Check that the probation unit exists in hr_lookups for the
      -- lookup type 'QUALIFYING_UNITS' with an enabled flag set to 'Y'
      -- and that the effective start date of the assignment is between
      -- start date active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'QUALIFYING_UNITS'
        ,p_lookup_code           => p_probation_unit
        )
      then
        --
        hr_utility.set_message(801, 'HR_51151_ASG_INV_PROB_UNIT');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_UNIT'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
end chk_probation_unit;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_prob_unit_prob_period >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_prob_unit_prob_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_probation_unit               in per_all_assignments_f.probation_unit%TYPE
  ,p_probation_period             in per_all_assignments_f.probation_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc           varchar2(72):= g_package||'chk_prob_unit_prob_period';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_UNIT'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD'
       ) then
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for probation unit or probation period changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating
    and
      nvl(per_asg_shd.g_old_rec.probation_unit, hr_api.g_varchar2)
      <> nvl(p_probation_unit, hr_api.g_varchar2)
      or
      nvl(per_asg_shd.g_old_rec.probation_period, hr_api.g_number)
      <> nvl(p_probation_period, hr_api.g_number))
    or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if probation unit or probation period is not null.
    --
    if p_probation_unit is not null or p_probation_period is not null then
      --
      -- Check if probation unit or probation period are null.
      --
      if p_probation_unit is null or p_probation_period is null then
        --
        hr_utility.set_message(801, 'HR_51166_ASG_INV_PU_PP_COMB');
        hr_utility.raise_error;
       --
      end if;
      hr_utility.set_location(l_proc, 3);
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_UNIT'
    ,p_associated_column2      => 'PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 6);
--
end chk_prob_unit_prob_period;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_recruiter_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_recruiter_id
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_person_id                    in     per_all_assignments_f.person_id%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id            in     per_all_assignments_f.business_group_id%TYPE
  ,p_recruiter_id                 in     per_all_assignments_f.recruiter_id%TYPE
  ,p_vacancy_id                   in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date               in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  )
  is
  --
  l_proc                  varchar2(72)  :=  g_package||'chk_recruiter_id';
  l_api_updating          boolean;
  l_vac_recruiter_id      per_all_assignments_f.recruiter_id%TYPE;
  l_business_group_id     per_all_assignments_f.business_group_id%TYPE;
  l_current_employee_flag per_people_f.current_employee_flag%TYPE;
  l_current_npw_flag      per_people_f.current_npw_flag%TYPE;
  --
  cursor csr_val_recruiter is
    select   business_group_id, current_employee_flag, current_npw_flag
   --from     per_people_f bug 5078945
    from     per_all_people_f
    where    person_id = p_recruiter_id
    and      p_validation_start_date
      between  effective_start_date
      and      nvl(effective_end_date, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  hr_utility.set_location(l_proc, 30);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  hr_utility.set_location(l_proc, 40);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for recruiter has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 50);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.recruiter_id, hr_api.g_number) <>
       nvl(p_recruiter_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 60);
    --
    -- Check if recruiter is not null
    --
    if p_recruiter_id is not null then
      --
      -- Check that the assignment is not an applicant or an offer assignment.
      --
      if    p_assignment_type in ('E','C','B')
      then
        --
        hr_utility.set_message(801, 'HR_51216_ASG_INV_ASG_TYP_REC');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITER_ID'
   );
   --
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the recruiter is'nt the same person as the assignment
      -- person.
      --
      If p_recruiter_id = p_person_id then
        --
        hr_utility.set_message(801, 'HR_51289_ASG_APL_EQUAL_RECRUIT');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITER_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Check if the recruiter exists between the effective start date
      -- and effective end date of the assignment.
      --
      open csr_val_recruiter;
      fetch csr_val_recruiter
      into l_business_group_id, l_current_employee_flag, l_current_npw_flag;
      if csr_val_recruiter%notfound then
        close csr_val_recruiter;
        hr_utility.set_message(801, 'HR_51280_ASG_INV_RECRUIT_ID');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.RECRUITER_ID'
   );
        --
      else
        close csr_val_recruiter;
      end if;
      --
      hr_utility.set_location(l_proc, 90);
      --
      -- Check that the recruiter is an employee.
      --
      -- Bug 3190625
      -- Condition to check profile value also added
      if not ( (nvl(l_current_employee_flag,hr_api.g_varchar2) = 'Y' )  or
                   ( nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N') = 'Y'  and
             nvl(l_current_npw_flag, 'N') = 'Y') ) then
        hr_utility.set_message(801, 'HR_51290_ASG_RECRUIT_NOT_EMP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITER_ID');
      end if;
      hr_utility.set_location(l_proc, 100);
      --
      -- Check that the recruiter is in the same business group
      -- as the business group of the applicant assignment.
      --
      If (p_business_group_id <> l_business_group_id AND
         nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'N')
               then
        --
        hr_utility.set_message(801, 'HR_51284_ASG_INV_RECRUIT_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITER_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 110);
      --
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 140);
  --
end chk_recruiter_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_recruitment_activity_id >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_recruitment_activity_id
  (p_assignment_id             in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type           in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id         in     per_all_assignments_f.business_group_id%TYPE
  ,p_recruitment_activity_id   in     per_all_assignments_f.recruitment_activity_id%TYPE
  ,p_effective_date            in     date
  ,p_object_version_number     in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date     in     date
  ,p_validation_end_date       in     date
  )
  is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_recruitment_activity_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_val_rec_act_id is
    select   business_group_id
    from     per_recruitment_activities
    where    recruitment_activity_id = p_recruitment_activity_id
    and      p_validation_start_date
      between  date_start
        and    nvl(date_end, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for recruitment activity has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.recruitment_activity_id, hr_api.g_number) <>
       nvl(p_recruitment_activity_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if recruitment activity is not null
    --
    if p_recruitment_activity_id is not null then
      --
      -- Check that the assignment is not an applicant or offer assignment.
      --
      if  p_assignment_type in ('E','C','B') then
        --
        hr_utility.set_message(801, 'HR_51223_ASG_INV_ASG_TYP_RCAT');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITMENT_ACTIVITY_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check if the recruitment activity exists where the effective
      -- start date of the assignment is between the date start and
      -- date end of the recruitment activity.
      --
      open csr_val_rec_act_id;
      fetch csr_val_rec_act_id into l_business_group_id;
      if csr_val_rec_act_id%notfound then
      close csr_val_rec_act_id;
        --
        -- Do not throw an error for Offer Assignment.
        --
        if p_assignment_type <> 'O'
        then
          hr_utility.set_message(801, 'HR_51306_ASG_INV_REC_ACT');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITMENT_ACTIVITY_ID'
          ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
          );
          --
        end if;
      --
      else
        close csr_val_rec_act_id;
      end if;
      --
      hr_utility.set_location(l_proc, 60);
      --
      -- Check that the recruitment activity is in the same business group
      -- as the business group of the assignment.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51307_ASG_INV_REC_ACT_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.RECRUITMENT_ACTIVITY_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 70);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_recruitment_activity_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_ref_int_del >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an assignment cannot be purged if foreign key
--    references exist to any of the following tables :
--
--               - PER_EVENTS
--               - PER_LETTER_REQUEST_LINES
--               - PAY_COST_ALLOCATIONS_F
--               - PAY_PAYROLL_ACTIONS
--               - PAY_PERSONAL_PAYMENT_METHODS_F
--               - PAY_ASSIGNMENT_ACTIONS
--               - PER_COBRA_COV_ENROLLMENTS
--               - PER_COBRA_COVERAGE_BENEFITS_F
--               - PER_ASSIGNMENTS_EXTRA_INFO
--               - HR_ASSIGNMENT_SET_AMENDMENTS
--               - PER_SECONDARY_ASS_STATUSES
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--
--  Post Success:
--    If no child rows exist in the table listed above then processing
--    continues.
--
--  Post Failure:
--    If child rows exist in any of the tables listed above, an application
--    error is raised and processing is terminated.
--
procedure chk_ref_int_del
  (p_assignment_id         in per_all_assignments_f.assignment_id%TYPE
  ,p_validation_start_date in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date   in per_all_assignments_f.effective_end_date%TYPE
  ,p_datetrack_mode        in varchar2
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_ref_int_del';
--
   cursor csr_per_events is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_events pe
                  where    pe.assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       date_start > p_validation_start_date))
                  and      not exists
                           (select null
                              from irc_interview_details iid
                             where pe.event_id = iid.event_id)
               );
--
   -- Start of 3096114
   /*cursor csr_per_lett_req_lines is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_letter_request_lines
                  where    assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       date_from > p_validation_start_date)));*/
   -- End of 3096114
--
   cursor csr_pay_cost_allocations_f is
     select   null
     from     sys.dual
     where exists(select   null
                  from     pay_cost_allocations_f
                  where    assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       effective_start_date > p_validation_start_date)));
--
   cursor csr_pay_pers_payment_methods is
     select   null
     from     sys.dual
     where exists(select   null
                  from     pay_personal_payment_methods_f
                  where    assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       effective_start_date > p_validation_start_date)));
--
   cursor csr_pay_assignment_actions is
     select   null
     from     sys.dual
     where exists(select null
                  from   pay_assignment_actions aa
                  ,      pay_payroll_actions pa
                  where  aa.assignment_id = p_assignment_id
                  and    pa.payroll_action_id = aa.payroll_action_id
                  and    (p_datetrack_mode = 'ZAP'
                  or     (p_datetrack_mode = 'DELETE'
                  and     pa.effective_date > p_validation_start_date))
                  and    pa.action_type not in ('X','BEE'));  -- Fix for bug# 2711532
--
   cursor csr_per_secondary_ass_stat is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_secondary_ass_statuses
                  where    assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       (p_datetrack_mode = 'DELETE'
                  and       start_date > p_validation_start_date)));
--
   cursor csr_per_cobra_cov_enrol is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_cobra_cov_enrollments
                  where    assignment_id = p_assignment_id
                  and      (p_datetrack_mode = 'ZAP'
                  or       ((p_datetrack_mode = 'DELETE'
                  and      coverage_start_date is null)
                  or       (coverage_start_date > p_validation_start_date))));
--
   cursor csr_per_cobra_cov_bens is
     select   null
     from     sys.dual
     where exists(select null
                  from   per_cobra_coverage_benefits_f b
                  ,      per_cobra_cov_enrollments e
                  where  e.assignment_id = p_assignment_id
                  and    e.cobra_coverage_enrollment_id =
                         b.cobra_coverage_enrollment_id
                  and    (p_datetrack_mode = 'ZAP'
                  or     (p_datetrack_mode = 'DELETE'
                  and     b.effective_start_date > p_validation_start_date)));
--
   cursor csr_per_ass_extra_info is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_assignment_extra_info
                  where    assignment_id = p_assignment_id);
--
   cursor csr_hr_ass_set_amend is
     select   null
     from     sys.dual
     where exists(select   null
                  from     hr_assignment_set_amendments
                  where    assignment_id = p_assignment_id);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that no child records exist for the
  -- assignment on per_events when the assignment is
  -- deleted
  --
  open csr_per_events;
  fetch csr_per_events into l_exists;
  if csr_per_events%found then
    close csr_per_events;
    hr_utility.set_message(801,'HR_7400_ASG_NO_DEL_ASS_EVENTS');
    hr_utility.raise_error;
  end if;
  close csr_per_events;
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that no child records exist for the
  -- assignment on per_letter_request_lines when
  -- the assignment is deleted
  --
  -- Start of 3096114
  /*open csr_per_lett_req_lines;
  fetch csr_per_lett_req_lines into l_exists;
  if csr_per_lett_req_lines%found then
    close csr_per_lett_req_lines;
    hr_utility.set_message(801,'HR_7401_ASG_NO_DEL_ASS_LET_REQ');
    hr_utility.raise_error;
  end if;
  close csr_per_lett_req_lines;*/
  -- End of 3096114
  --
  hr_utility.set_location(l_proc, 3);
  --
  -- Check that no child records exist for the
  -- assignment on pay_cost_allocations_f when
  -- the assignment is deleted
  --
  open csr_pay_cost_allocations_f;
  fetch csr_pay_cost_allocations_f into l_exists;
  if csr_pay_cost_allocations_f%found then
    close csr_pay_cost_allocations_f;
    hr_utility.set_message(801,'HR_7402_ASG_NO_DEL_COST_ALLOCS');
    hr_utility.raise_error;
  end if;
  close csr_pay_cost_allocations_f;
  --
  hr_utility.set_location(l_proc, 4);
  --
  -- Check that no child records exist for the
  -- assignment on pay_personal_payment_methods when
  -- the assignment is deleted
  --
  open csr_pay_pers_payment_methods;
  fetch csr_pay_pers_payment_methods into l_exists;
  if csr_pay_pers_payment_methods%found then
    close csr_pay_pers_payment_methods;
    hr_utility.set_message(801,'HR_7404_ASG_NO_DEL_PER_PAY_MET');
    hr_utility.raise_error;
  end if;
  close csr_pay_pers_payment_methods;
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Check that no child records exist for the
  -- assignment on pay_payroll_actions when
  -- the assignment is deleted
  --
  open csr_pay_assignment_actions;
  fetch csr_pay_assignment_actions into l_exists;
  if csr_pay_assignment_actions%found then
    close csr_pay_assignment_actions;
    hr_utility.set_message(801,'HR_7403_ASG_NO_DEL_PAYROLL_ACT');
    hr_utility.raise_error;
  end if;
  close csr_pay_assignment_actions;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check that no child records exist for the
  -- assignment on per_secondary_ass_statuses when
  -- the assignment is deleted
  --
  open csr_per_secondary_ass_stat;
  fetch csr_per_secondary_ass_stat into l_exists;
  if csr_per_secondary_ass_stat%found then
    close csr_per_secondary_ass_stat;
    hr_utility.set_message(801,'HR_7407_ASG_NO_DEL_ASS_STATUS');
    hr_utility.raise_error;
  end if;
  close csr_per_secondary_ass_stat;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Check that no child records exist for the
  -- assignment on per_cobra_cov_enrollments
  -- when the assignment is deleted
  --
  open csr_per_cobra_cov_enrol;
  fetch csr_per_cobra_cov_enrol into l_exists;
  if csr_per_cobra_cov_enrol%found then
    close csr_per_cobra_cov_enrol;
    hr_utility.set_message(801,'HR_7405_ASG_NO_DEL_COB_COV_ENR');
    hr_utility.raise_error;
  end if;
  close csr_per_cobra_cov_enrol;
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Check that no child records exist for the
  -- assignment on per_cobra_coverage_benefits_f
  -- when the assignment is deleted
  --
  open csr_per_cobra_cov_bens;
  fetch csr_per_cobra_cov_bens into l_exists;
  if csr_per_cobra_cov_bens%found then
    close csr_per_cobra_cov_bens;
    hr_utility.set_message(801,'HR_7406_ASG_NO_DEL_COB_COV_BEN');
    hr_utility.raise_error;
  end if;
  close csr_per_cobra_cov_bens;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Check that no child records exist for the
  -- assignment on per_assignment_extra_info when
  -- the assignment is deleted
  --
  -- Only allow processing in 'ZAP' mode
  --
  if p_datetrack_mode = 'ZAP' then
    open csr_per_ass_extra_info;
    fetch csr_per_ass_extra_info into l_exists;
    if csr_per_ass_extra_info%found then
      close csr_per_ass_extra_info;
      hr_utility.set_message(801,'HR_7409_ASG_NO_DEL_EXTR_INFO');
      hr_utility.raise_error;
    end if;
    close csr_per_ass_extra_info;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check that no child records exist for the
  -- assignment on hr_assignment_set_amendments
  -- when the assignment is deleted
  --
  -- Only allow processing in 'ZAP' mode
  --
  if p_datetrack_mode = 'ZAP' then
    open csr_hr_ass_set_amend;
    fetch csr_hr_ass_set_amend into l_exists;
    if csr_hr_ass_set_amend%found then
      close csr_hr_ass_set_amend;
      hr_utility.set_message(801,'HR_7410_ASG_NO_DEL_ASS_SET_AMD');
      hr_utility.raise_error;
    end if;
    close csr_hr_ass_set_amend;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 11);
end chk_ref_int_del;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_sal_review_period_freq >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_sal_review_period_freq
  (p_assignment_id                in     per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period_frequency  in
  per_all_assignments_f.sal_review_period_frequency%TYPE
  ,p_assignment_type              in     per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in     date
  ,p_validation_start_date        in     date
  ,p_validation_end_date          in     date
  ,p_object_version_number        in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc     varchar2(72)  :=  g_package||'chk_sal_review_period_freq';
  l_api_updating   boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for salary review period frequency has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.sal_review_period_frequency,
       hr_api.g_varchar2) <> nvl(p_sal_review_period_frequency,
       hr_api.g_varchar2))
    or
      (NOT l_api_updating))
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if sal review period frequency is not null
    --
    if p_sal_review_period_frequency is not null then
       --
       -- Check that the assignment is an employee or applicant
       -- or benefit or offer assignment.
       --
       if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51181_ASG_INV_ASG_TYP_SRPF');
        hr_multi_message.add
        (p_associated_column1 =>
   'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD_FREQUENCY'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that the salary review period frequency exists in
      -- hr_lookups for the lookup type 'FREQUENCY' with an enabled
      -- flag set to 'Y' and that the effective start date of the
      -- assignment is between start date active and end date active
      -- in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'FREQUENCY'
        ,p_lookup_code           => p_sal_review_period_frequency
        )
      then
        --
        hr_utility.set_message(801, 'HR_51164_ASG_INV_SRP_FREQ');
        hr_multi_message.add
        (p_associated_column1 =>
   'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD_FREQUENCY'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
    end if;
    hr_utility.set_location(l_proc, 70);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
end chk_sal_review_period_freq;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_sal_review_period >------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_sal_review_period
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period            in per_all_assignments_f.sal_review_period%TYPE
  ,p_assignment_type              in per_all_assignments_f.assignment_type%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc  varchar2(72)  :=  g_package||'chk_sal_review_period';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for perf review period has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.sal_review_period,
       hr_api.g_number) <> nvl(p_sal_review_period,
       hr_api.g_number)) or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 3);
    --
    -- Check if sal review period is not null
    --
    if p_sal_review_period is not null then
      --
      -- Check that the assignment is an employee or applicant
      -- or benefit or offer assignment.
      --
      if p_assignment_type not in ('E','A','B','O') then

        --
        hr_utility.set_message(801, 'HR_51180_ASG_INV_ASG_TYP_SRP');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 4);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 6);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 7);
end chk_sal_review_period;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_sal_rp_freq_sal_rp >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_sal_rp_freq_sal_rp
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_sal_review_period_frequency  in per_all_assignments_f.sal_review_period_frequency%TYPE
  ,p_sal_review_period            in per_all_assignments_f.sal_review_period%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_proc                     varchar2(72):= g_package||'chk_sal_rp_freq_sal_rp';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD'
       ,p_check_column2      =>
       'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD_FREQUENCY'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for sal review period frequency or sal review period has
  -- changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_asg_shd.g_old_rec.sal_review_period_frequency,
      hr_api.g_varchar2) <> nvl(p_sal_review_period_frequency, hr_api.g_varchar2)
      or
      nvl(per_asg_shd.g_old_rec.sal_review_period,
      hr_api.g_number) <> nvl(p_sal_review_period, hr_api.g_number))
    or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if sal review period frequency or sal review period is not null.
    --
    if p_sal_review_period_frequency is not null
       or p_sal_review_period is not null then
       hr_utility.set_location(l_proc, 3);
       --
       -- Check if sal review period frequency or sal review period are null.
       --
       if p_sal_review_period_frequency is null
          or p_sal_review_period is null then
          --
          hr_utility.set_message(801, 'HR_51165_ASG_INV_SRPF_SRP_COMB');
          hr_utility.raise_error;
          --
       end if;
       --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      =>
    'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD'
         ,p_associated_column2      =>
    'PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD_FREQUENCY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_sal_rp_freq_sal_rp;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_set_of_books_id >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_set_of_books_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_set_of_books_id         in     per_all_assignments_f.set_of_books_id%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_set_of_books_id';
  l_exists            varchar2(1);
  l_api_updating      boolean;
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_valid_sob is
    select   null
    from     gl_sets_of_books
    where    set_of_books_id = p_set_of_books_id;
  --
  cursor csr_valid_fsp_bg is
    select   null
    from     financials_system_params_all
    where    set_of_books_id   = p_set_of_books_id
    and      business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for set_of_books_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.set_of_books_id,
       hr_api.g_number) <> nvl(p_set_of_books_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if set of books is set
    --
    if p_set_of_books_id is not null then
      --
      -- Check that the assignment is an employee or applicant
      -- or contact or offer assignment.
      --
      if p_assignment_type not in ('E','A','C','O') then
        --
        hr_utility.set_message(801, 'HR_51175_ASG_INV_ASG_TYP_SOB');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
        -- Check that the set of books exists in GL_SETS_OF_BOOKS.
        --
        open csr_valid_sob;
        fetch csr_valid_sob into l_exists;
        if csr_valid_sob%notfound then
          close csr_valid_sob;
          hr_utility.set_message(801, 'HR_51160_ASG_INV_SET_OF_BOOKS');
          hr_utility.raise_error;
          --
        end if;
        close csr_valid_sob;
        hr_utility.set_location(l_proc, 60);
        --
        -- Check that the set of books exists in
        -- FINANCIALS_SYSTEM_PARAMS_ALL for the assignment business
        -- group.
        --
        open csr_valid_fsp_bg;
        fetch csr_valid_fsp_bg into l_exists;
        if csr_valid_fsp_bg%notfound then
          close csr_valid_fsp_bg;
          hr_utility.set_message(801, 'HR_51316_ASG_INV_FSP_SOB_BG');
          hr_utility.raise_error;
          --
        end if;
        close csr_valid_fsp_bg;
        hr_utility.set_location(l_proc, 70);
        --
      end if;
      hr_utility.set_location(l_proc, 80);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.SET_OF_BOOKS_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 120);
end chk_set_of_books_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_soft_coding_keyflex_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_soft_coding_keyflex_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in per_all_assignments_f.assignment_type%TYPE
  ,p_soft_coding_keyflex_id  in per_all_assignments_f.soft_coding_keyflex_id%TYPE
  ,p_effective_date          in date
  ,p_validation_start_date   in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_payroll_id              in per_all_assignments_f.payroll_id%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  )
  is
  --
  l_exists             varchar2(1);
  l_api_updating       boolean;
  l_proc               varchar2(72)  :=  g_package||'chk_soft_coding_keyflex_id';
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  --
  --
  cursor csr_valid_keyflex is
    select   null
    from     hr_soft_coding_keyflex
    where    soft_coding_keyflex_id = p_soft_coding_keyflex_id
    and      enabled_flag = 'Y'
    and      p_validation_start_date
      between nvl(start_date_active,hr_api.g_sot)
      and     nvl(end_date_active,hr_api.g_eot);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups_perf
    where business_group_id = p_business_group_id;
  --
  cursor csr_pay_legislation_rules is
    select null
    from pay_legislation_rules
    where legislation_code = l_legislation_code
    and rule_type = 'TAX_UNIT'
    and rule_mode = 'Y';
   --
  cursor csr_tax_unit_message(p_message_name varchar2) is
    select 1 from fnd_new_messages
    where message_name = p_message_name
    and application_id = 801;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for soft coding keyflex has changed
  -- c) Soft coding keyflex is null and Payroll is populated. --#2182184
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.soft_coding_keyflex_id, hr_api.g_number) <>
       nvl(p_soft_coding_keyflex_id, hr_api.g_number)) or
       --
       -- ****** Start new code for bug #2182184 **************************
       --
       (l_api_updating and
       (p_soft_coding_keyflex_id is null and p_payroll_id is not null)) or
       --
       -- ****** End new code for bug #2182184 ****************************
       --
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 40);
    --
    if p_soft_coding_keyflex_id is not null then
      --
      -- Check that the assignment is an employee assignment.
      -- altered to allow applicants to have this specified
      --
      -- <OAB_CHANGE> - Extend restriction to allow assignment type 'B'
      --
      if p_assignment_type not in ('E','A','B','C','O') then
        --
        hr_utility.set_message(801, 'HR_51227_ASG_INV_ASG_TYP_SCF');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOFT_CODING_KEYFLEX_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that soft_coding_keyflex_id exists on
      -- hr_soft_coding_keyflex
      --
      open csr_valid_keyflex;
      fetch csr_valid_keyflex into l_exists;
      if csr_valid_keyflex%notfound then
        close csr_valid_keyflex;
        hr_utility.set_message(801, 'HR_7383_ASG_INV_KEYFLEX');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOFT_CODING_KEYFLEX_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
      else
        close csr_valid_keyflex;
      end if;
      hr_utility.set_location(l_proc, 60);
    else
      --
      -- Check that for relevant legislations SCL is mandatory,
      --  when payroll_id is populated                 #909279
      --
      hr_utility.set_location(l_proc, 45);
      if p_payroll_id is not null and
         p_assignment_type = 'E' then
        open csr_bg;
        fetch csr_bg into l_legislation_code;
        close csr_bg;
      --
        hr_utility.set_location(l_proc, 55);
        open csr_pay_legislation_rules;
        fetch csr_pay_legislation_rules into l_exists;
        if csr_pay_legislation_rules%found then
          close csr_pay_legislation_rules;
          if l_legislation_code = 'US' then
            hr_utility.set_message(801, 'HR_50001_EMP_ASS_NO_GRE');
          else
         open csr_tax_unit_message('HR_INV_LEG_ENT_'||l_legislation_code);
      fetch csr_tax_unit_message into l_exists;

      if csr_tax_unit_message%found then
                      hr_utility.set_message(801, 'HR_INV_LEG_ENT_'||l_legislation_code);
      else
                    hr_utility.set_message(801, 'HR_34024_IP_INV_LEG_ENT');
      end if;
      close csr_tax_unit_message;
          end if;
     hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PAYROLL_ID'
       );
        else
          close csr_pay_legislation_rules;
        end if;
   hr_utility.set_location(l_proc, 65);
      end if;
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_soft_coding_keyflex_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_source_organization_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_source_organization_id
  (p_assignment_id           in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type         in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in     per_all_assignments_f.business_group_id%TYPE
  ,p_source_organization_id  in     per_all_assignments_f.source_organization_id%TYPE
  ,p_effective_date          in     date
  ,p_object_version_number   in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date   in     date
  ,p_validation_end_date     in     date
  )
  is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_source_organization_id';
  l_api_updating      boolean;
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_val_source_org_id is
    select   business_group_id
    from     per_organization_units
    where    organization_id = p_source_organization_id
    and      p_validation_start_date
      between  date_from
        and    nvl(date_to, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for source organization has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating
      and nvl(per_asg_shd.g_old_rec.source_organization_id, hr_api.g_number)
        <> nvl(p_source_organization_id, hr_api.g_number))
    or
      (NOT l_api_updating))
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if source organization is set
    --
    if p_source_organization_id is not null then
      --
      -- Check that the assignment is not an applicant or offer assignment.
      --
       if   p_assignment_type in ('E','C','B') then
        --
        -- Check if the employee assignment is being updated
        --
        If l_api_updating then
          --
          hr_utility.set_message(801, 'HR_51220_ASG_INV_EASG_U_SORG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOURCE_ORGANIZATION_ID'
     );
          --
        else -- inserting an employee assignment
          --
          hr_utility.set_message(801, 'HR_51219_ASG_INV_EASG_I_SORG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOURCE_ORGANIZATION_ID'
     );
          --
        end if;
        hr_utility.set_location(l_proc, 60);
        --
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check if the source organization exists where the effective
      -- start date of the assignment is between the date from and
      -- date to of the source organization.
      --
      open csr_val_source_org_id;
      fetch csr_val_source_org_id into l_business_group_id;
      if csr_val_source_org_id%notfound then
        close csr_val_source_org_id;
        hr_utility.set_message(801, 'HR_51308_ASG_INV_SOURCE_ORG');
        hr_multi_message.add
          (p_associated_column1 =>
     'PER_ALL_ASSIGNMENTS_F.SOURCE_ORGANIZATION_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
     );
        --
      else
        close csr_val_source_org_id;
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Check that the source organization is in the same business group
      -- as the business group of the assignment.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51309_ASG_INV_SOURCE_ORG_BG');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOURCE_ORGANIZATION_ID'
     );
        --
      end if;
      hr_utility.set_location(l_proc, 90);
      --
    end if;
    hr_utility.set_location(l_proc, 100);
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 110);
end chk_source_organization_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_source_type >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_source_type
  (p_assignment_id            in     per_all_assignments_f.assignment_id%TYPE
  ,p_source_type              in     per_all_assignments_f.source_type%TYPE
  ,p_recruitment_activity_id  in     per_all_assignments_f.recruitment_activity_id%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
  l_proc           varchar2(72)  :=  g_package||'chk_source_type';
  l_api_updating   boolean;
  l_rec_act_type   per_recruitment_activities.type%TYPE;
  --
  cursor csr_get_rec_act_type is
    select   type
    from     per_recruitment_activities
    where    recruitment_activity_id = p_recruitment_activity_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for source type has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.source_type, hr_api.g_varchar2) <>
       nvl(p_source_type, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if source type is set
    --
    if p_source_type is not null then
      --
      -- Check that the source type exists in hr_lookups for the lookup
      -- type 'REC_TYPE' with an enabled flag set to 'Y' and that the
      -- effective start date of the assignment is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'REC_TYPE'
        ,p_lookup_code           => p_source_type
        )
      then
        --
        hr_utility.set_message(801, 'HR_51162_ASG_INV_SOURCE_TYPE');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SOURCE_TYPE'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check if recruitment activity is set
      --
      If p_recruitment_activity_id is not null then
        --
        -- Check if the source type is the same as the type of the
        -- recruitment activity
        --
        open csr_get_rec_act_type;
        fetch csr_get_rec_act_type into l_rec_act_type;
        close csr_get_rec_act_type;
        hr_utility.set_location(l_proc, 60);
        --
        If p_source_type <> nvl(l_rec_act_type, hr_api.g_varchar2) then
          --
          hr_utility.set_message(801, 'HR_51325_ASG_INV_SOU_TYP_RAT');
          hr_multi_message.add
          (p_associated_column1 =>
     'PER_ALL_ASSIGNMENTS_F.RECRUITMENT_ACTIVITY_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SOURCE_TYPE'
     );
          --
        end if;
        hr_utility.set_location(l_proc, 70);
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
    end if;
    hr_utility.set_location(l_proc, 90);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_source_type;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_special_ceiling_step_id >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_special_ceiling_step_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          in per_all_assignments_f.assignment_type%TYPE
  ,p_special_ceiling_step_id  in per_all_assignments_f.special_ceiling_step_id%TYPE
  ,p_grade_id                 in per_all_assignments_f.grade_id%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date      in per_all_assignments_f.effective_end_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
   l_sequence           per_spinal_point_steps_f.sequence%TYPE;
   l_exists            varchar2(1);
   l_api_updating      boolean;
   l_business_group_id number(15);
   l_proc              varchar2(72) := g_package||'chk_special_ceiling_step_id';
--
   cursor csr_valid_step is
     select   1
     from     sys.dual
     where exists
          (select  null
             from  per_spinal_point_steps_f psps
            where  psps.effective_start_date <= p_validation_start_date
              and  psps.step_id               = p_special_ceiling_step_id
              and (exists
                  (select null
                     from per_spinal_point_steps_f psps2
                    where psps2.effective_end_date >= p_validation_end_date
                      and psps2.step_id             = p_special_ceiling_step_id
                      and psps2.grade_spine_id      = psps.grade_spine_id)));
--
   cursor csr_get_bus_grp is
     select   pgs.business_group_id
     from     per_grade_spines_f pgs
     where    pgs.ceiling_step_id = p_special_ceiling_step_id
     and      p_effective_date    between pgs.effective_start_date
                                  and     pgs.effective_end_date;
--
   cursor csr_valid_step_grade is
     select   psps.sequence
     from     per_grade_spines_f pgs,
              per_spinal_point_steps_f psps
     where    psps.step_id       = p_special_ceiling_step_id
       and    pgs.grade_id       = p_grade_id
       and    pgs.grade_spine_id = psps.grade_spine_id
       and    p_effective_date between pgs.effective_start_date
                                   and pgs.effective_end_date
       and    p_effective_date between psps.effective_start_date
                                   and psps.effective_end_date;
--
   cursor csr_low_step is
     select   1
     from     sys.dual
     where exists(select null
                  from  per_spinal_point_placements_f pspp
                  ,     per_spinal_point_steps_f      psps
                  ,     per_grade_spines_f            pgs
                  where pspp.assignment_id = p_assignment_id
                  and   pspp.step_id = psps.step_id
                  and   psps.grade_spine_id=pgs.grade_spine_id
                  and   pgs.grade_id = p_grade_id
                  and   psps.sequence > l_sequence
                  and   pspp.effective_start_date <= p_validation_end_date
                  and   pspp.effective_end_date >= p_validation_start_date
                  and   psps.effective_start_date between psps.effective_start_date
                                             and psps.effective_end_date
                  and   psps.effective_start_date between  pgs.effective_start_date
                                             and  pgs.effective_end_date);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for special ceiling step has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.special_ceiling_step_id, hr_api.g_number) <>
       nvl(p_special_ceiling_step_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 40);
    --
    if p_special_ceiling_step_id is not null then
      --
      -- Check that the assignment is an employee,applicant or benefits
      -- assignment.
      --
      if p_assignment_type not in ('E','A','B','O') then
        --
        hr_utility.set_message(801, 'HR_51225_ASG_INV_ASG_TYP_SCS');
        hr_multi_message.add
        (p_associated_column1 =>
   'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
   );
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that special_ceiling_step_id exists and is date effective
      -- per_grade_spines_f
      --
      open csr_valid_step;
      fetch csr_valid_step into l_exists;
      if csr_valid_step%notfound then
        close csr_valid_step;
        hr_utility.set_message(801, 'HR_7379_ASG_INV_SPEC_CEIL_STEP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE'
   );
        --
      else
        close csr_valid_step;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      -- Check that the business group of the special_ceiling_step_id on
      -- per_grade_spines is the same as that of the assignment.
      --
      open csr_get_bus_grp;
      fetch csr_get_bus_grp into l_business_group_id;
      if l_business_group_id <> p_business_group_id then
        close csr_get_bus_grp;
        hr_utility.set_message(801, 'HR_7375_ASG_INV_BG_SP_CLG_STEP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
   );
      else
        close csr_get_bus_grp;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
       ) then
      --
      -- Check that the special_ceiling_step_id is valid for the grade
      -- if p_grade is not null.
      --
      if p_grade_id is not null then
        open csr_valid_step_grade;
        fetch csr_valid_step_grade into l_sequence;
        if csr_valid_step_grade%notfound then
          close csr_valid_step_grade;
          hr_utility.set_message(801, 'HR_7380_ASG_STEP_INV_FOR_GRADE');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
     ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
   );
        else
     close csr_valid_step_grade;
        end if;
   hr_utility.set_location(l_proc, 80);
      else
        --
        -- If the value for special ceiling step is not null
        -- then grade id must also be not null
        --
        hr_utility.set_message(801, 'HR_7434_ASG_GRADE_REQUIRED');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
   );
      end if;
      hr_utility.set_location(l_proc, 90);
      --
      -- Check if updating
      --
      if l_api_updating then
        --
        -- Check that special_ceiling_step_id is not lower than the
        -- spinal point placement for the assignment.
        --
        open csr_low_step;
        fetch csr_low_step into l_exists;
        if csr_low_step%found then
          close csr_low_step;
          hr_utility.set_message(801, 'HR_7381_ASG_CEIL_STEP_TOO_HIGH');
          hr_multi_message.add
         (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.GRADE_ID'
    ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
    ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE'
    );
        else
     close csr_low_step;
        end if;
   hr_utility.set_location(l_proc, 110);
        --
      end if;
      hr_utility.set_location(l_proc, 120);
    end if;
    hr_utility.set_location(l_proc, 130);
    --
  end if; -- no exclusive error
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
end chk_special_ceiling_step_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_supervisor_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_supervisor_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_supervisor_id            in per_all_assignments_f.supervisor_id%TYPE
  ,p_person_id                in per_all_assignments_f.person_id%TYPE
  ,p_business_group_id        in per_all_assignments_f.business_group_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
   l_proc               varchar2(72)  :=  g_package||'chk_supervisor_id';
   l_api_updating       boolean;
   l_inst_type          varchar2(1);  -- Added for bug 8310023
   --
   l_business_group_id        per_people_f.business_group_id%TYPE;
   l_current_employee_flag    per_people_f.current_employee_flag%TYPE;
   l_current_npw_flag         per_people_f.current_npw_flag%TYPE;
   l_assignment_type          per_all_assignments_f.assignment_type%TYPE;
   --
   -- Fix for bug 4305723 starts here.
   --
   cursor csr_party_id(p_per_id number)  IS
   select party_id
   from   per_all_people_f
   where  person_id = p_per_id
   and    p_validation_start_date
      between  effective_start_date
        and    effective_end_date;
   --
   l_per_party_id number;
   l_sup_party_id number;
   --
   -- Fix for bug 4305723 ends here.
   --
   -- Bug#3917021
   cursor csr_asg_typ is
   select assignment_type
   from per_all_assignments_f asg
   where asg.assignment_id = p_assignment_id
   and  p_validation_start_date
      between asg.effective_start_date
        and asg.effective_end_date;
   --
   cursor csr_valid_supervisor_id is
    select   business_group_id, current_employee_flag, current_npw_flag
    from     per_all_people_f
    where    person_id = p_supervisor_id
    and      p_validation_start_date
      between  effective_start_date
        and    effective_end_date;
--
   -- Fix for Bug#8310023 starts here
   --
   cursor csr_valid_supervisor_sh_hr is
    select   business_group_id, current_employee_flag, current_npw_flag
    from     per_all_people_f
    where    person_id = p_supervisor_id;
   --
   -- Fix for Bug#8310023 ends here
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for supervisor_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.supervisor_id, hr_api.g_number) <>
       nvl(p_supervisor_id, hr_api.g_number)) or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if supervisor is not null
    --
    if p_supervisor_id is not null then
      --
      -- Check that the supervisor is'nt the same person as the person of the
      -- assignment.
      --
      If p_supervisor_id = p_person_id then
        --
        hr_utility.set_message(801, 'HR_51143_ASG_EMP_EQUAL_SUP');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
   );
      end if;
      hr_utility.set_location(l_proc, 50);
      --
      -- Fix for bug 4305723 starts here. Check if the party_id is same for
      -- employee and supervisor.
      --
      open csr_party_id(p_person_id);
      fetch csr_party_id into l_per_party_id;
      close csr_party_id;
      --
      open csr_party_id(p_supervisor_id);
      fetch csr_party_id into l_sup_party_id;
      close csr_party_id;
      --
      If l_per_party_id = l_sup_party_id
       then
         hr_utility.set_message(800, 'HR_449603_ASG_SUP_DUP_PER');
          hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
              ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
            );
      end if;
      --
      -- Fix for bug 4305723 ends here.
      --
      hr_utility.set_location(l_proc, 55);
      --
      -- Fix for Bug#8310023 starts here
      -- Finding the installation type ( Shared HR or Full HR )
      --
      select status into l_inst_type from fnd_product_installations
       where application_id = 800;
      --
      -- If its a Shared HR
      -- Check that supervisor_id exists
      --
      if (l_inst_type = 'S') then
        open csr_valid_supervisor_sh_hr;
        fetch csr_valid_supervisor_sh_hr
        into l_business_group_id, l_current_employee_flag, l_current_npw_flag;
        if csr_valid_supervisor_sh_hr%notfound then
          close csr_valid_supervisor_sh_hr;
          hr_utility.set_message(801, 'PER_50501_INV_SUPERVISOR');
        else
          close csr_valid_supervisor_sh_hr;
        end if;
      else
      --
      -- When Installation type is not Shared HR
      -- Check that supervisor_id exists and that it is date effective within
      -- the validation period of the assignment.
      --
      open csr_valid_supervisor_id;
      fetch csr_valid_supervisor_id
      into l_business_group_id, l_current_employee_flag, l_current_npw_flag;
      if csr_valid_supervisor_id%notfound then
        close csr_valid_supervisor_id;
        --
        hr_utility.set_message(801, 'PAY_7599_SYS_SUP_DT_OUTDATE');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
   );
      else
        close csr_valid_supervisor_id;
      end if;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      -- Check that the supervisor is in the same business group as the
      -- person of the assignment.
      --
      If (p_business_group_id <> l_business_group_id  AND
          nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='N')
           then
        --
        hr_utility.set_message(801, 'HR_51145_ASG_SUP_BG_NE_EMP_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
   );
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the supervisor is an employee or a contingent
      -- worker where the profile option permits.
      --
      If not (nvl(l_current_employee_flag, hr_api.g_varchar2) = 'Y'
           or (nvl(l_current_npw_flag, hr_api.g_varchar2) = 'Y' and
               nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'))
      Then
        --Bug3917021
        if csr_asg_typ%isopen then
          close csr_asg_typ;
        end if;
        open csr_asg_typ;
        fetch csr_asg_typ into l_assignment_type;
        close csr_asg_typ;
        if l_assignment_type in ('C','E','B') then
           --
           hr_utility.set_message(801, 'HR_51346_ASG_SUP_NOT_EMP');
           hr_multi_message.add
           (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID');
           --
        end if;
        --Bug#3917021 ends here
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 90);
end chk_supervisor_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_supervisor_assignment_id >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_supervisor_assignment_id
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_supervisor_id            in per_all_assignments_f.supervisor_id%TYPE
  ,p_supervisor_assignment_id in out nocopy per_all_assignments_f.supervisor_assignment_id%TYPE
  ,p_validation_start_date    in per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_assignments_f.object_version_number%TYPE
  )
  is
  --
   l_proc         varchar2(72)  :=  g_package||'chk_supervisor_assignment_id';
   l_api_updating boolean;
   l_assignment_type   per_all_assignments_f.assignment_type%TYPE;
   --
   cursor csr_supervisor_assignment_id is
   select   paaf.assignment_type
   from     per_all_assignments_f paaf
   where    paaf.person_id = p_supervisor_id
   and      p_supervisor_id is not null
   and      paaf.assignment_id = p_supervisor_assignment_id
   and      p_validation_start_date between
            paaf.effective_start_date and paaf.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for supervisor_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
        (p_assignment_id          => p_assignment_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 30);

  --
  -- Re-validate if either the supervisor or supervisor assignment
  -- has changed.
  --
  if (l_api_updating and
      ((nvl(per_asg_shd.g_old_rec.supervisor_id, hr_api.g_number) <>
        nvl(p_supervisor_id, hr_api.g_number))
       or
       (nvl(per_asg_shd.g_old_rec.supervisor_assignment_id, hr_api.g_number) <>
        nvl(p_supervisor_assignment_id, hr_api.g_number))) or
      (NOT l_api_updating))
  then

    hr_utility.set_location(l_proc, 40);
     ----
      if ((nvl(per_asg_shd.g_old_rec.supervisor_id, hr_api.g_number) <>
           nvl(p_supervisor_id, hr_api.g_number))
       and
       (nvl(per_asg_shd.g_old_rec.supervisor_assignment_id, hr_api.g_number) =
        nvl(p_supervisor_assignment_id, hr_api.g_number))) then
            p_supervisor_assignment_id := NULL;
       end if;
    ---

    if p_supervisor_assignment_id is not null then
      --
      --
      -- Only validate if the supervisor assignment is set.
      --
      -- There is no need to validate that the supervisor assignment is not
      -- the same as this person's assigment because the supervisor has already
      -- been validated at this point and so this assignment must belong to
      -- the given supervisor.
      --
      -- Check that supervisor assignment exists, that it is date effective
      -- within the validation period of the assignment and that it belongs
      -- to the given supervisor.
      --
      hr_utility.set_location(l_proc, 50);

      open  csr_supervisor_assignment_id;
      fetch csr_supervisor_assignment_id into l_assignment_type;
      if csr_supervisor_assignment_id%notfound then
        hr_utility.set_location(l_proc, 60);
        close csr_supervisor_assignment_id;
        --
        hr_utility.set_message(800, 'HR_50146_SUP_ASG_INVALID');
        hr_utility.raise_error;
       /* hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
        ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID'
        ,p_associated_column3 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ASSIGNMENT_ID'
   ); */
      else
        close csr_supervisor_assignment_id;
      end if;

      hr_utility.set_location(l_proc, 70);

      --
      -- Check that the supervisor assignment is an employee or a contingent
      -- worker assignment.
      --
      If not (nvl(l_assignment_type, hr_api.g_varchar2) = 'E'
           or (nvl(l_assignment_type, hr_api.g_varchar2) = 'C' and
               nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'))
      Then
        --
        hr_utility.set_location(l_proc, 80);
        hr_utility.set_message(800, 'HR_50147_SUP_ASG_WRONG_TYPE');
        hr_utility.raise_error;
        /*hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ASSIGNMENT_ID'
   ); */
        --
      end if;
      hr_utility.set_location(l_proc, 90);
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 100);

end chk_supervisor_assignment_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_system_pers_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that system person type has not changed in the future
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_validation_start_date
--    p_validation_end_date
--    p_datetrack_mode
--    p_effective_date
--
--  Post Success:
--    If no system person type changes exist in the future then processing
--    continues.
--
--  Post Failure:
--    If the system person type changes in the future an application error
--    is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_system_pers_type
  (p_person_id              in per_all_assignments_f.person_id%TYPE
  ,p_validation_start_date  in per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date    in per_all_assignments_f.effective_end_date%TYPE
  ,p_datetrack_mode         in varchar2
  ,p_effective_date         in date
  )
  is
--
   l_proc           varchar2(72)  :=  g_package||'chk_system_pers_type';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- Only trigger validation for the following datetrack modes :
  --    - UPDATE_OVERRIDE
  --    - ZAP
  --    - DELETE -> No longer required. When setting FPD which is
  --                the same as ATD any future dated ASG changes relative
  --                to FPD(ATD) require deleting. There will always be one
  --                in this case for the change from ACTIVE_ASSIGN to
  --                TERM_ASSIGN which was created when the actual_termination...
  --                API was called.
  --                The only call to the ASG RH with a datetrack mode of
  --                DELETE is from final_process_emp_asg_sup.
  --    - FUTURE_CHANGE
  --    - DELETE_NEXT_CHANGE
  --
  if p_datetrack_mode in ('UPDATE_OVERRIDE',
                          'ZAP',
                          'FUTURE_CHANGE',
                          'DELETE_NEXT_CHANGE') then
    --
    -- Get current value for system_person_type (i.e. as of the
    -- effective date)
    --
    per_per_bus.chk_system_pers_type
      (p_person_id             => p_person_id
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_datetrack_mode        => p_datetrack_mode
      ,p_effective_date        => p_effective_date
      );
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 6);
--
end chk_system_pers_type;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_term_status >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates an assignment cannot be deleted using the following datetrack
--    modes :
--                     - DELETE_NEXT_CHANGE
--                     - DELETE_FUTURE_CHANGE
--                     - UPDATE_OVERRIDE
--
--    if the assignment is terminated in the future, i.e. Assignment Status
--    Type set to 'TERM_ASSIGN'.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_assignment_id
--    p_validation_start_date
--    p_datetrack_mode
--
--  Post Success:
--    If assignment is not terminated in the future then processing
--    continues.
--
--  Post Failure:
--    If the assignment is terminated in the future then an
--    application error is raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_term_status
  (p_assignment_id            in per_all_assignments_f.assignment_id%TYPE
  ,p_datetrack_mode           in varchar2
  ,p_validation_start_date    in date
  )
  is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_term_status';
--
   cursor csr_chk_term_status is
     select   null
     from     per_all_assignments_f pas
     ,        per_assignment_status_types past
     where    pas.assignment_id = p_assignment_id
     and      pas.effective_start_date >= p_validation_start_date
     and      past.assignment_status_type_id = pas.assignment_status_type_id
     and      past.per_system_status = 'TERM_ASSIGN';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check whether assignment is terminated in the future
  --
  if p_datetrack_mode in ('UPDATE_OVERRIDE'
                         ,'FUTURE_CHANGE'
                         ,'DELETE_NEXT_CHANGE') then
    open csr_chk_term_status;
    fetch csr_chk_term_status into l_exists;
    if csr_chk_term_status%found then
      close csr_chk_term_status;
      hr_utility.set_message(801, 'HR_7412_ASG_ASS_TERM_IN_FUTURE');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.DATETRACK_MODE'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
   );
    else
      close csr_chk_term_status;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 2);
end chk_term_status;
--
-- 70.1 change d start.
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_time_normal_finish >--------------------------|
--  ---------------------------------------------------------------------------
-- << 2734822 >>
--
procedure chk_time_finish_formatted
  (p_time_normal_finish in out nocopy per_all_assignments_f.time_normal_finish%TYPE
  )
  is
--
   l_proc varchar2(72)  :=  g_package||'chk_time_finish_formatted';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that time_normal_finish is valid
  --
  if p_time_normal_finish is not null then
    --
    hr_dbchkfmt.is_db_format(p_value            => p_time_normal_finish
                            ,p_formatted_output => p_time_normal_finish  -- #2734822
                            ,p_arg_name         => 'time_normal_finish'
                            ,p_format           => 'TIMES');
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 2);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_FINISH'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 3);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 4);
--
end chk_time_finish_formatted;
--
--
procedure chk_time_normal_finish
  (p_time_normal_finish in per_all_assignments_f.time_normal_finish%TYPE
  )
  is
--
  l_value per_all_assignments_f.time_normal_finish%TYPE;
begin

   l_value := p_time_normal_finish;
   chk_time_finish_formatted(l_value);

end chk_time_normal_finish;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_time_normal_start >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_time_start_formatted     -- #2734822
  (p_time_normal_start in out nocopy per_all_assignments_f.time_normal_start%TYPE
  )
  is
--
   l_proc varchar2(72)  :=  g_package||'chk_time_normal_start_formatted';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that time_normal_start is valid
  --
  if p_time_normal_start is not null then
    --
    hr_dbchkfmt.is_db_format(p_value            => p_time_normal_start
                            ,p_formatted_output => p_time_normal_start   -- #2734822
                            ,p_arg_name         => 'time_normal_start'
                            ,p_format           => 'TIMES');
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 2);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_START'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 3);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 4);
end chk_time_start_formatted;
--
-- << 2734822 >>
--
procedure chk_time_normal_start
  (p_time_normal_start in per_all_assignments_f.time_normal_start%TYPE
  )
  is
--
  l_value per_all_assignments_f.time_normal_start%TYPE;
begin

   l_value := p_time_normal_start;
   chk_time_start_formatted(l_value);

end chk_time_normal_start;

--
--  Start changes for bug 8687386
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_dup_apl_vacancy >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_dup_apl_vacancy
  (p_person_id              in     per_all_assignments_f.person_id%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_vacancy_id             in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date         in     date
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE default null
  )
is
  l_proc     varchar2(72) := g_package||'chk_dup_apl_vacancy';
begin
  hr_utility.set_location('Entering: old'|| l_proc, 10);

  per_asg_bus2.chk_dup_apl_vacancy
  (p_person_id             =>  p_person_id
  ,p_business_group_id     =>  p_business_group_id
  ,p_vacancy_id            =>  p_vacancy_id
  ,p_effective_date        =>  p_effective_date
  ,p_assignment_type       =>  p_assignment_type
  ,p_assignment_id   	   =>  Null
  ,p_validation_start_date =>  p_effective_date
  ,p_validation_end_date   =>  hr_api.g_eot
  ,p_datetrack_mode        =>  'INSERT'
  );

  hr_utility.set_location('Leaving: old'|| l_proc, 100);
end;
--
--  End changes for bug 8687386
--

--  ---------------------------------------------------------------------------
--  |-----------------------< chk_dup_apl_vacancy >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_dup_apl_vacancy
  (p_person_id              in     per_all_assignments_f.person_id%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_vacancy_id             in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date         in     date
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE default null
  -- Start changes for bug 8687386
  ,p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_validation_start_date  in     per_all_assignments_f.effective_start_date%TYPE
  ,p_validation_end_date    in     per_all_assignments_f.effective_end_date%TYPE
  ,P_datetrack_mode         in     varchar2
  -- End changes for bug 8687386
  )
 is
--
  l_proc              varchar2(72)  :=  g_package||'chk_dup_apl_vacancy';
  l_application_id    per_applications.application_id%type;
--

  --
  -- Start changes for bug 8687386
  -- cursor to handle INSERT, UPDATE, UPDATE_OVERRIDE and FUTURE_CHANGE cases, return the
  -- assignment_id which already has the vacancy, which user is going to associate to this application.
  cursor csr_dup_apl_vac_with_eot is
   select paf.assignment_id
   from per_all_assignments_f paf
     ,per_applications        pa
     ,per_vacancies           pv
   where paf.application_id = pa.application_id
     and pa.date_end is null
     and paf.vacancy_id = pv.vacancy_id
     and paf.person_id = p_person_id
     and paf.vacancy_id = p_vacancy_id
     and paf.assignment_type = p_assignment_type
     and paf.assignment_id <> nvl(p_assignment_id,0)
     and (p_validation_start_date between paf.effective_start_date and paf.effective_end_date
          or
	  paf.effective_end_date >= p_validation_start_date);

  -- cursor to handle DELETE_NEXT_CHANGE, UPDATE_CHANGE_INSERT cases,
  -- return the assignment_id which already has the vacancy, which user is going to
  -- associate to this application.
  cursor csr_dup_apl_vac_without_eot is
  select paf.assignment_id
  from per_all_assignments_f paf
    ,per_applications        pa
    ,per_vacancies           pv
  where paf.application_id = pa.application_id
    and pa.date_end  is null
    and paf.vacancy_id = pv.vacancy_id
    and paf.person_id = p_person_id
    and paf.vacancy_id = p_vacancy_id
    and paf.assignment_type = p_assignment_type
    and paf.assignment_id <> nvl(p_assignment_id,0)
    and (p_validation_start_date between paf.effective_start_date and paf.effective_end_date
         or
	 p_validation_end_date between paf.effective_start_date and paf.effective_end_date);

    /*
    cursor csr_dup_apl_vacancy is
    select     pa.application_id
    from
        per_applications     pa,
             per_all_assignments_f     paf,
             per_vacancies         pv
    where
          paf.person_id         = p_person_id
    and   paf.vacancy_id          = pv.vacancy_id
    and   paf.vacancy_id          = p_vacancy_id
    and   paf.application_id     = pa.application_id
    and   paf.business_group_id    = p_business_group_id
    and   p_effective_date between paf.effective_start_date
                   and paf.effective_end_date
    and   pa.date_end         is null;
    */

    -- End changes for bug 8687386
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check this for Applicant assignments Only.
  --
  if    (p_assignment_type = 'A'
   or  p_assignment_type is null) and p_datetrack_mode not in ('ZAP','DELETE')
  then

  -- Start changes for bug 8687386
  --
    /*  open csr_dup_apl_vacancy;
        fetch csr_dup_apl_vacancy into l_application_id;
        if csr_dup_apl_vacancy%found then
           close csr_dup_apl_vacancy;
           hr_utility.set_message(800, 'HR_52217_DUP_APL_VACANCY');
           hr_utility.raise_error;
        --
        end if;
        close csr_dup_apl_vacancy;
        hr_utility.set_location(l_proc, 20);
    */
    hr_utility.set_location('p_person_id: '||p_person_id ,10);
    hr_utility.set_location('p_vacancy_id: '||p_vacancy_id ,10);
    hr_utility.set_location('p_effective_date: '||p_effective_date ,10);
    hr_utility.set_location('p_assignment_type: '||p_assignment_type ,10);
    hr_utility.set_location('p_assignment_id: '||p_assignment_id ,10);
    hr_utility.set_location('p_validation_start_date: '||p_validation_start_date ,10);
    hr_utility.set_location('p_validation_end_date: '||p_validation_end_date ,10);

    if P_validation_end_date = to_date('31/12/4712','dd/mm/yyyy') then
      --
      open csr_dup_apl_vac_with_eot;
      fetch csr_dup_apl_vac_with_eot into l_application_id;
      if csr_dup_apl_vac_with_eot%found then
        --
        close csr_dup_apl_vac_with_eot;
        hr_utility.set_message(800, 'HR_52217_DUP_APL_VACANCY');
        hr_utility.raise_error;
        --
      end if;
      close csr_dup_apl_vac_with_eot;
      hr_utility.set_location(l_proc, 20);
      --
    else
      --
      open csr_dup_apl_vac_without_eot;
      fetch csr_dup_apl_vac_without_eot into l_application_id;
      if csr_dup_apl_vac_without_eot%found then
        --
        close csr_dup_apl_vac_without_eot;
        hr_utility.set_message(800, 'HR_52217_DUP_APL_VACANCY');
        hr_utility.raise_error;
        --
      end if;
      close csr_dup_apl_vac_without_eot;
      hr_utility.set_location(l_proc, 30);
      --
    -- End changes for bug 8687386
    end if;

  end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.VACANCY_ID'
    ,p_associated_column2      => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
--
end chk_dup_apl_vacancy;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vacancy_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_vacancy_id
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        in     per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id      in     per_all_assignments_f.business_group_id%TYPE
  ,p_vacancy_id             in     per_all_assignments_f.vacancy_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_validation_start_date  in     date
  ,p_validation_end_date    in     date
  )
  is
--
  l_proc              varchar2(72)  :=  g_package||'chk_vacancy_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;
  --
  cursor csr_val_vacancy_id is
    select   business_group_id
    from     per_vacancies
    where    vacancy_id = p_vacancy_id
    and      p_validation_start_date
      between  date_from
        and    nvl(date_to, hr_api.g_eot);
  --
  cursor csr_val_vacancy_id_offer is
    select   business_group_id
    from     per_vacancies
    where    vacancy_id = p_vacancy_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for vacancy has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.vacancy_id, hr_api.g_number) <>
       nvl(p_vacancy_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if vacancy is not null
    --
    if p_vacancy_id is not null then
      --
      -- Check that when inserting the the assignment is an applicant or offer
      -- assignment on insert.
      --
      if p_assignment_type in ('E','C','B') then
        --
        -- Check if the employee assignment is being updated
        --
        If l_api_updating then
          --
          hr_utility.set_message(801, 'HR_51222_ASG_INV_EASG_U_VAC');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VACANCY_ID'
     );
          --
        else -- inserting a non employee
          --
          hr_utility.set_message(801, 'HR_51221_ASG_INV_EASG_I_VAC');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VACANCY_ID'
     );
          --
        end if;
        hr_utility.set_location(l_proc, 50);
        --
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      if p_assignment_type = 'O'
      then
         --
         -- Assignment is an Offer Assignment.
         -- Check if the the vacancy is a valid vacancy.
         --
         open csr_val_vacancy_id_offer;
         fetch csr_val_vacancy_id_offer into l_business_group_id;
         if csr_val_vacancy_id_offer%notfound
         then
            --
            close csr_val_vacancy_id;
            hr_utility.set_message(800, 'HR_52591_CEL_INVL_VAC_ID');
            hr_utility.raise_error;
            --
         end if;
         --
      else
         -- Assignment is not an Offer Assignment.
         --
         -- Check if the vacancy exists where the effective start date
         -- of the assignment is between the date from and date to of the
         -- vacancy.
         --
         open csr_val_vacancy_id;
         fetch csr_val_vacancy_id into l_business_group_id;
         if csr_val_vacancy_id%notfound then
           close csr_val_vacancy_id;
           hr_utility.set_message(801, 'HR_51297_ASG_INV_VACANCY');
           hr_utility.raise_error;
          /*  hr_multi_message.add
              (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VACANCY_ID'
             ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
              ); */
         --
         else
         close csr_val_vacancy_id;
      end if;
      --
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the vacancy is in the same business group
      -- as the business group of the assignment.
      --
      If p_business_group_id <> l_business_group_id then
        --
        hr_utility.set_message(801, 'HR_51300_ASG_INV_VAC_BG');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 80);
      --
    end if;
    hr_utility.set_location(l_proc, 90);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
end chk_vacancy_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< gen_assignment_sequence >------------------------|
--  ---------------------------------------------------------------------------
--
procedure gen_assignment_sequence
  (p_assignment_type     in per_all_assignments_f.assignment_type%TYPE
  ,p_person_id           in per_all_assignments_f.person_id%TYPE
  ,p_assignment_sequence in out nocopy per_all_assignments_f.assignment_sequence%TYPE
  )
  is
--
   l_assignment_sequence per_all_assignments_f.assignment_sequence%TYPE;
   l_proc                varchar2(72)  :=  g_package||'gen_assignment_sequence';
--
   cursor csr_get_ass_seq is
     select nvl(max(assignment_sequence),0) +1
     from   per_all_assignments_f
     where  person_id       = p_person_id
     and    assignment_type = p_assignment_type;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  --  Generate next assignment sequence
  --
  open csr_get_ass_seq;
  fetch csr_get_ass_seq into l_assignment_sequence;
  close csr_get_ass_seq;
  p_assignment_sequence := l_assignment_sequence;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
  --
end gen_assignment_sequence;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< other_managers_in_org >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks to see if any other current assignments for the same organization
--    have the manager_flag set to 'Y', and returns the appropriate boolean
--    result.
--
--  Pre-conditions:
--    A valid Organization ID
--
--  In Arguments:
--    p_assignment_id
--    p_effective_date
--    p_organization_id
--
--  Post Success:
--    TRUE if other managers found, FALSE otherwise.
--
--  Post Failure:
--    If the cursor raises an error, it will be passed back to the calling
--    routine as an unhandled exception.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
function other_managers_in_org
  (p_organization_id            in per_all_assignments_f.organization_id%TYPE
  ,p_assignment_id              in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date             in date
  )
  return boolean is
--
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'other_managers_in_org';
   l_other_manager_exists boolean;
   l_assignment_id  per_all_assignments_f.assignment_id%TYPE;
--
   cursor csr_other_manager_in_org is
     select   null
     from     per_all_assignments_f pas
     where    pas.organization_id  =      p_organization_id
     and      pas.assignment_type  =      'E'
     and      pas.manager_flag     =      'Y'
     and      pas.assignment_id   <>      l_assignment_id
     and      p_effective_date    between pas.effective_start_date
                                  and     pas.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_id'
    ,p_argument_value => p_organization_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Assigment_id will be NULL on insert, so set to default value.
  --
  l_assignment_id := nvl(p_assignment_id, hr_api.g_number);
  --
  -- Check whether another current assignment exists in the same
  -- organization with manager flag set to 'Y'.
  --
  open  csr_other_manager_in_org;
  fetch csr_other_manager_in_org into l_exists;
  --
  l_other_manager_exists := csr_other_manager_in_org%found;
  --
  close csr_other_manager_in_org;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
  --
  return l_other_manager_exists;
end other_managers_in_org;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< gen_date_probation_end >------------------------|
--  ---------------------------------------------------------------------------
--
procedure gen_date_probation_end
  (p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in     date
  ,p_probation_unit         in     per_all_assignments_f.probation_unit%TYPE
  ,p_probation_period       in     per_all_assignments_f.probation_period%TYPE
  ,p_validation_start_date  in     per_all_assignments_f.effective_start_date%TYPE
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_date_probation_end     in out nocopy per_all_assignments_f.date_probation_end%TYPE
  )
  is
--
   l_proc           varchar2(72)  :=  g_package||'gen_date_probation_end';
   l_api_updating    boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with generation if :
  -- a) The current g_old_rec is current and
  -- b) One or more of the values for date probation end, probation period or
  --    probation unit has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  hr_utility.set_location(l_proc, 30);
  --
  if NOT l_api_updating
    or
      (l_api_updating and
      ((nvl(per_asg_shd.g_old_rec.date_probation_end, hr_api.g_date) <>
      nvl(p_date_probation_end, hr_api.g_date))
      or
      (nvl(per_asg_shd.g_old_rec.probation_unit, hr_api.g_varchar2) <>
      nvl(p_probation_unit, hr_api.g_varchar2))
      or
      (nvl(per_asg_shd.g_old_rec.probation_period, hr_api.g_number) <>
      nvl(p_probation_period, hr_api.g_number))))
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if probation unit and probation period are both not null.
    --
    if p_probation_unit is not null and p_probation_period is not null then
      --
      -- Check that probation unit is not 'H'
      --
      If p_probation_unit <> 'H' then
        --
        -- Check the value of probation unit and perform the appropriate
        -- calculation for date probation end.
        --
        If p_probation_unit = 'D' then
          --
          p_date_probation_end := p_validation_start_date
          + (p_probation_period-1);
          hr_utility.set_location(l_proc, 50);
          --
        elsif p_probation_unit = 'W' then
          --
          p_date_probation_end := p_validation_start_date
          + ((p_probation_period*7)-1);
          hr_utility.set_location(l_proc, 60);
          --
        elsif p_probation_unit = 'M' then
          --
          p_date_probation_end := add_months(p_validation_start_date,
          p_probation_period)-1;
          hr_utility.set_location(l_proc, 70);
          --
        elsif p_probation_unit = 'Y' then
          --
          p_date_probation_end := add_months(p_validation_start_date,
          12*p_probation_period)-1;
          hr_utility.set_location(l_proc, 80);
          --
        end if;
        --
      else
        --
        -- Nullify date probation end
        --
        p_date_probation_end := null;
        hr_utility.set_location(l_proc, 9);
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
end gen_date_probation_end;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_internal_address_line >-----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_internal_address_line
  (p_assignment_id                in per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type              in per_all_assignments_f.assignment_type%TYPE
  ,p_internal_address_line        in per_all_assignments_f.internal_address_line%TYPE
  ,p_effective_date               in date
  ,p_object_version_number        in per_all_assignments_f.object_version_number%TYPE
  )
  is
--
  l_proc           varchar2(72)  :=  g_package||'chk_internal_address_line';
  l_api_updating      boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for internal address line has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.internal_address_line, hr_api.g_varchar2)
       <> nvl(p_internal_address_line, hr_api.g_varchar2))
    or
      (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if internal address line is not null
    --
    if p_internal_address_line is not null then
      --
      -- Check that the assignment is an employee, applicant, offer or benefits
      -- assignment.
      --
      if p_assignment_type not in ('E','A','B','C','O') then
        --
        hr_utility.set_message(801, 'HR_51230_ASG_INV_ASG_TYP_IAL');
        hr_utility.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.INTERNAL_ADDRESS_LINE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'|| l_proc, 80);
--
end chk_internal_address_line;
--
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_applicant_rank  >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_applicant_rank
  (p_applicant_rank         in  number
  ,p_assignment_type        in  varchar2
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in  date
  ,p_object_version_number  in  per_all_assignments_f.object_version_number%TYPE)
    IS
--
  l_proc              varchar2(72)  :=  g_package||'chk_applicant_rank';
  l_api_updating      boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.applicant_rank, hr_api.g_number) <>
       nvl(p_applicant_rank, hr_api.g_number)) or
      (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 20);
    --
    -- Check if applicant_rank is not null
    --
    if p_applicant_rank IS NOT NULL then
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- applicant rank must be between 0 and 100
      --
      if (p_applicant_rank < 0) or (p_applicant_rank >100) then
        --
        hr_utility.set_location(l_proc, 40);
        --
        hr_utility.set_message(800, 'PER_289768_APP_RANKING_INV'); --bug 3303215
        hr_utility.raise_error;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- Check that when inserting, the assignment is an applicant or offer assignment
      --
      if p_assignment_type in ('E','C','B') then
        hr_utility.set_location(l_proc, 60);
        --
        -- Check if the employee assignment is being updated
        --
        if l_api_updating then
          --
          -- non applicant, rank can only be updated to null
          --
          hr_utility.set_message(800, 'HR_289950_APP_RANK_INV_UPD');
          hr_utility.raise_error;
          --
        else -- inserting a non applicant
          --
          hr_utility.set_message(800, 'HR_289620_APPLICANT_RANK_ASG');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
        hr_utility.set_location('Leaving:'|| l_proc, 70);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.APPLICANT_RANK'
         ) then
      raise;
    end if;
end chk_applicant_rank;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_posting_content_id >-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_posting_content_id
  (p_posting_content_id     in  number
  ,p_assignment_type        in  varchar2
  ,p_assignment_id          in  per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date         in  date
  ,p_object_version_number  in  per_all_assignments_f.object_version_number%TYPE
  ) IS
--
  l_proc              varchar2(72)  :=  g_package||'chk_posting_content_id';
  l_api_updating      boolean;
  l_count number;
  l_posting_content_id irc_posting_contents.posting_content_id%type;
  --
  cursor irc_exists(p_posting_content_id number) is
    select posting_content_id
    from irc_posting_contents
    where posting_content_id = p_posting_content_id
    and rownum = 1;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.posting_content_id, hr_api.g_number) <>
       nvl(p_posting_content_id, hr_api.g_number)) or
      (NOT l_api_updating)) then

    hr_utility.set_location(l_proc, 20);
    --
    -- Check if posting_content_id is not null
    --
    if p_posting_content_id IS NOT NULL then
      --
      -- posting_content_id must exist in irc_posting_contents
      --
      open irc_exists(p_posting_content_id);
      fetch irc_exists into l_posting_content_id;
      --
      if irc_exists%notfound then
        l_posting_content_id := null;
      end if;
      --
      close irc_exists;
      hr_utility.set_location(l_proc, 30);
      --
      if (l_posting_content_id <> p_posting_content_id) then
        --
        hr_utility.set_message(800, 'HR_289621_INV_POSTING_CONTENT');
        hr_utility.raise_error;
        --
      end if;
      --
      -- Check that when inserting, the assignment is an applicant or offer assignment
      --
      if p_assignment_type in ('E','C','B') then
        hr_utility.set_location(l_proc, 40);
        --
        -- Check if the employee assignment is being updated
        --
        if l_api_updating then
          --
          -- non applicant/offer, posting_content_id can only be updated to null
          --
          hr_utility.set_message(800, 'HR_289951_POSTING_CONT_INV_UPD');
          hr_utility.raise_error;
          --
        else -- inserting a non applicant
          --
          hr_utility.set_message(800, 'HR_289619_POSTING_CONTENT_ASG');
          hr_utility.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  end if;
    hr_utility.set_location('Leaving: '||l_proc, 50);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.POSTING_CONTENT_ID'
         ) then
      raise;
    end if;
    --
end chk_posting_content_id;
--
end per_asg_bus2;

/
