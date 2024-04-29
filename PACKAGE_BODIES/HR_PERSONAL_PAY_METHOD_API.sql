--------------------------------------------------------
--  DDL for Package Body HR_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSONAL_PAY_METHOD_API" as
/* $Header: pyppmapi.pkb 120.5.12010000.4 2009/07/24 09:57:17 pgongada ship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := 'hr_personal_pay_method_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_insert_legislation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure ensures that the legislation rule for the
--   for the personal payment method being inserted is the
--   of the required business process.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_personal_payment_method_id   Yes  number   Id of personal payment
--                                                method being deleted.
--   p_effective_date               Yes  date     The session date.
--   p_leg_code                     Yes  varchar2 Legislation of business
--                                                group
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure check_insert_legislation
  (p_assignment_id          in            number
  ,p_effective_date         in out nocopy date
  ,p_leg_code               in            varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
  l_effective_date      date;
  --
  cursor legsel is
    select pbg.legislation_code
    from   per_business_groups pbg,
           per_assignments_f   asg
    where  pbg.business_group_id = asg.business_group_id
    and    asg.assignment_id     = p_assignment_id
    and    p_effective_date between asg.effective_start_date
                            and     asg.effective_end_date;
  --
begin
  if g_debug then
     l_proc := g_package||'chk_insert_legislation';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Check that p_assignment_id and p_effective_date are not null as they
  -- are used by the cursor to validate the business group.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Ensure that the legislation rule for the employee assignment
  -- business group is that of p_leg_code.
  --
  open legsel;
  fetch legsel
  into l_valid;
  --
  if legsel%notfound then
    close legsel;
    hr_utility.set_message(801, 'HR_7348_ASSIGNMENT_INVALID');
    hr_utility.raise_error;
  end if;
  if legsel%found and l_valid <> p_leg_code then
    close legsel;
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Assign out parameter after truncating the date by using a local
  -- variable.
  --
  l_effective_date := trunc(p_effective_date);
  p_effective_date := l_effective_date;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 8);
  end if;
  --
end check_insert_legislation;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_update_legislation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure ensures that the legislation rule for the
--   for the personal payment method being updated or deleted is the
--   of the required business process.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_personal_payment_method_id   Yes  number   Id of personal payment
--                                                method being deleted.
--   p_effective_date               Yes  date     The session date.
--   p_leg_code                     Yes  varchar2 Legislation of business
--                                                group
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure check_update_legislation
  (p_personal_payment_method_id    in
     pay_personal_payment_methods_f.personal_payment_method_id%type
  ,p_effective_date                in     date
  ,p_leg_code                      in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
  --
  cursor legsel is
    select pbg.legislation_code
    from   per_business_groups pbg,
           pay_personal_payment_methods_f ppm
    where  pbg.business_group_id = ppm.business_group_id
    and    ppm.personal_payment_method_id = p_personal_payment_method_id
    and    p_effective_date between ppm.effective_start_date
                            and     ppm.effective_end_date;
--
begin
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is that of p_leg_code.
  --
  if g_debug then
     l_proc := g_package||'check_update_legislation';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  open legsel;
  fetch legsel
  into l_valid;
  --
  if legsel%notfound then
    close legsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  if legsel%found and l_valid <> p_leg_code then
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
  end if;
  --
end check_update_legislation;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< stamp_prenote_date >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This private procedure stamps the prenote date on the external account
--   row for US legislation. Contains minimal validation - it's called at the
--   end of create_personal_pay_method and update_personal_pay_method after
--   the EXA and PPM row handlers will have done the validation already.
--
-- Prerequisites:
--   Must only be called for US territory code, and if the payment method
--   is for a magtape payment.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_personal_payment_method_id   Yes  number   Id of personal payment
--                                                method being created/updated.
--   p_effective_date               Yes  date     The session date.
--   p_external_account_id          Yes  number   Id of external account row.
--   p_external_account_ovn         Yes  number   Object version number of
--                                                external account row.
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure stamp_prenote_date
(p_personal_payment_method_id in            number
,p_effective_date             in            date
,p_external_account_id        in            number
,p_external_account_ovn       in out nocopy number
) is
l_proc              varchar2(2000);
l_prenote_date      date;
l_new_prenote_date  date;
l_3rd_party_payment varchar2(2000);
l_prenote_allowed   varchar2(2000);
l_validation_days   number;
--
-- Cursor to get payment-related information (PPM->OPM direction).
--
cursor csr_payment_details
(p_personal_payment_method_id in number
,p_effective_date             in date
) is
select nvl(to_char(opm.defined_balance_id), 'Y') third_party
,      nvl(ppt.validation_days, 0)               validation_days
from   pay_personal_payment_methods_f ppm
,      pay_org_payment_methods_f      opm
,      pay_payment_types              ppt
where  ppm.personal_payment_method_id = p_personal_payment_method_id
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
and    opm.org_payment_method_id = ppm.org_payment_method_id
and    p_effective_date between
       opm.effective_start_date and opm.effective_end_date
and    ppt.payment_type_id = opm.payment_type_id
;
--
-- Cursor to get payroll information (PPM->ASG->PAYROLL direction).
--
cursor csr_payroll_details
(p_personal_payment_method_id in number
,p_effective_date             in date
) is
select nvl(pap.prl_information3, 'Y') prenote_allowed
from   pay_personal_payment_methods_f ppm
,      per_all_assignments_f paa
,      pay_all_payrolls_f    pap
where  ppm.personal_payment_method_id = p_personal_payment_method_id
and    p_effective_date between
       ppm.effective_start_date and ppm.effective_end_date
and    paa.assignment_id = ppm.assignment_id
and    p_effective_date between
       paa.effective_start_date and paa.effective_end_date
and    pap.payroll_id = paa.payroll_id
and    p_effective_date between
       pap.effective_start_date and pap.effective_end_date
;
--
-- Cursor to get the current prenote date.
--
cursor csr_curr_prenote_date
(p_external_account_id in number
) is
select exa.prenote_date
from   pay_external_accounts exa
where  exa.external_account_id = p_external_account_id
;
begin
  if g_debug then
     l_proc := g_package || 'stamp_prenote_date';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Prenotification is allowed by default.
  --
  l_prenote_allowed := 'Y';
  --
  -- Get the payment-related information.
  --
  open csr_payment_details
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => p_effective_date
  );
  fetch csr_payment_details
  into  l_3rd_party_payment
  ,     l_validation_days;
  if csr_payment_details%notfound then
    if g_debug then
       hr_utility.set_location('Leaving (csr_payment_details):'|| l_proc, 20);
    end if;
    close csr_payment_details;
    --
    -- There must've been an invalid primary key for the query to
    -- return no rows.
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_payment_details;
  --
  -- Standard prenote date.
  --
  l_new_prenote_date := p_effective_date - l_validation_days;
  --
  -- Handle prenotification depending on payment type.
  --
  if l_3rd_party_payment = 'Y' then
    --
    -- bug1870072 requirement.
    --
    l_new_prenote_date := l_new_prenote_date - 1;
    l_prenote_allowed := 'N';
  else
    open csr_payroll_details
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => p_effective_date
    );
    fetch csr_payroll_details
    into  l_prenote_allowed;
    if csr_payroll_details%notfound then
      if g_debug then
         hr_utility.set_location('Leaving (csr_payroll_details):'|| l_proc, 30);
      end if;
      close csr_payroll_details;
      --
      -- There must've been an invalid primary key for the query to
      -- return no rows.
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    close csr_payroll_details;
  end if;
  --
  -- Stamp the prenote date using the row handler if prenotification is not
  -- allowed.
  --
  if upper(l_prenote_allowed) <> 'Y' then
    --
    -- This is an API call (implicit behaviour) so we should only stamp the
    -- prenote date if it is NULL. Without this restriction, each API call
    -- would be stamping the prenote date with a new value.
    --
    open csr_curr_prenote_date
    (p_external_account_id => p_external_account_id);
    fetch csr_curr_prenote_date
    into  l_prenote_date;
    if csr_curr_prenote_date%notfound then
      if g_debug then
         hr_utility.set_location
         ('Leaving (csr_curr_prenote_date):'|| l_proc, 35);
      end if;
      close csr_curr_prenote_date;
      --
      -- There must've been an invalid primary key for the query to
      -- return no rows.
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    close csr_curr_prenote_date;
    --
    if l_prenote_date is null then
      if g_debug then
         hr_utility.set_location('Stamp the prenote date:'|| l_proc, 40);
      end if;
      pay_exa_upd.upd
      (p_external_account_id   => p_external_account_id
      ,p_object_version_number => p_external_account_ovn
      ,p_territory_code        => 'US'
      ,p_prenote_date          => l_new_prenote_date
      ,p_validate              => false
      );
    end if;
  end if;
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 50);
  end if;
end stamp_prenote_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< upd_prenote_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to update the prenote date in pay_external_accounts
--   with the value provided by the user. However the prenote date is updated
--   only if prenoting is allowed for the payroll(ie. prl_information3 = 'Y').
--
-- Prerequisites:
--   Must be called only from 'US' specific insert and update APIs.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_personal_payment_method_id   Yes  number   Id of personal payment
--                                                method being created/updated.
--   p_effective_date               Yes  date     The session date.
--   p_external_account_id          Yes  number   Id of external account row.
--   p_prenote_date                 Yes  date     Prenote Date that needs to
--                                                updated on the external
--                                                account row.
--
-- Post Success:
--   The procedure returns control back to the calling process.
--
-- Post Failure:
--   The process raises an error and stops execution.
--
-- Access Status:
--   Private.
--
-- {End Of Comments}
--
procedure upd_prenote_date
  (p_personal_payment_method_id in number
  ,p_external_account_id        in number
  ,p_effective_date             in date
  ,p_prenote_date               in date
  ) is
  --
  l_proc                varchar2(72) := 'upd_prenote_date';
  l_exa_ovn             pay_external_accounts.object_version_number%type;
  l_prenote_allowed     pay_all_payrolls_f.prl_information3%type;
  --
  cursor csr_payroll_details(p_personal_payment_method_id in number
                            ,p_effective_date             in date
                            ) is
    select nvl(pap.prl_information3, 'Y') prenote_allowed
    from   pay_personal_payment_methods_f ppm
    ,      per_all_assignments_f paa
    ,      pay_all_payrolls_f    pap
    where  ppm.personal_payment_method_id = p_personal_payment_method_id
    and    p_effective_date between
           ppm.effective_start_date and ppm.effective_end_date
    and    paa.assignment_id = ppm.assignment_id
    and    p_effective_date between
           paa.effective_start_date and paa.effective_end_date
    and    pap.payroll_id = paa.payroll_id
    and    p_effective_date between
           pap.effective_start_date and pap.effective_end_date;
  --
  cursor csr_exa_ovn(p_external_account_id in number) is
    select pea.object_version_number
    from   pay_external_accounts pea
    where  pea.external_account_id = p_external_account_id;
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering: '|| l_proc, 5);
  end if;
  --
  open csr_payroll_details
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => trunc(p_effective_date)
    );
  fetch csr_payroll_details into l_prenote_allowed;
  if csr_payroll_details%notfound then
    if g_debug then
      hr_utility.set_location('Leaving (csr_payroll_details):'|| l_proc, 8);
    end if;
    close csr_payroll_details;
    --
    -- There must've been an invalid primary key for the query to
    -- return no rows.
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close csr_payroll_details;
  --
  if l_prenote_allowed = 'Y' then
    --
    open csr_exa_ovn(p_external_account_id);
    fetch csr_exa_ovn into l_exa_ovn;
    if csr_exa_ovn%notfound then
      if g_debug then
        hr_utility.set_location('Leaving (csr_exa_ovn):'|| l_proc, 9);
      end if;
      close csr_exa_ovn;
      --
      -- There must've been an invalid primary key for the query to
      -- return no rows.
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    close csr_exa_ovn;
    --
    pay_exa_upd.upd
      (p_external_account_id   => p_external_account_id
      ,p_object_version_number => l_exa_ovn
      ,p_territory_code        => 'US'
      ,p_prenote_date          => trunc(p_prenote_date)
      ,p_validate              => false
      );
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving: '|| l_proc, 10);
  end if;
  --
end upd_prenote_date;
-- ----------------------------------------------------------------------------
-- |----------------------< create_personal_pay_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_territory_code                in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
/** sbilling **/
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_ppm_information_category      in     varchar2 default null  --Bug 6439573
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_business_group_id   per_assignments_f.business_group_id%TYPE;
  l_external_account_id pay_personal_payment_methods_f.external_account_id%TYPE;
  l_validate            boolean := FALSE;
  l_exa_ovn             number;
  l_exists              varchar2(1);
  l_category            varchar2(2);
  l_effective_date      date;
  l_ppm_information_category pay_personal_payment_methods_f.ppm_information_category%TYPE;
  --
  -- Declare OUT variables.
  --
  l_personal_payment_method_id    pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
  l_object_version_number         pay_personal_payment_methods_f.object_version_number%TYPE;
  l_effective_start_date          pay_personal_payment_methods_f.effective_start_date%TYPE;
  l_effective_end_date            pay_personal_payment_methods_f.effective_end_date%TYPE;
  l_comment_id                    pay_personal_payment_methods_f.comment_id%TYPE;
  --
  cursor bgsel is
    select pa.business_group_id
    from   per_assignments_f pa
    where  pa.assignment_id = p_assignment_id
    and    p_effective_date between pa.effective_start_date
                            and     pa.effective_end_date;
  --
  -- Bug 4644507. Removed the usage of per_business_groups from the cursor.
  cursor csr_is_valid is
    select  null
    from    pay_org_payment_methods_f opm,
            pay_payment_types ppt
    where   opm.org_payment_method_id = p_org_payment_method_id
    and     p_effective_date
    between opm.effective_start_date
    and     opm.effective_end_date
    and     ppt.payment_type_id   = opm.payment_type_id ;
  --
  cursor csr_chk_pay_type is
    select pyt.category
    from pay_org_payment_methods_f opm
    ,    pay_payment_types pyt
    where p_org_payment_method_id = opm.org_payment_method_id
      and opm.payment_type_id = pyt.payment_type_id
      and p_effective_date between opm.effective_start_date
                               and opm.effective_end_date;
  --
  cursor csr_ppm_info_category ( p_org_payment_method_id number,
                                 p_effective_date        date) is
     select decode(ppt.territory_code,null,null,ppt.territory_code||'_')||UPPER(ppt.payment_type_name) ppm_information_category
       from pay_payment_types ppt,
            pay_org_payment_methods_f opm
      where opm.org_payment_method_id = p_org_payment_method_id
        and p_effective_date between opm.effective_start_date and opm.effective_end_date
        and opm.payment_type_id = ppt.payment_type_id;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'create_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint.
  --
  savepoint create_personal_pay_method;
  --
  -- Initialize local variables
  --
  l_external_account_id   := null;
  --
  -- Check that p_assignment_id and p_effective_date are not null as they
  -- are used by the cursor to derive the business group.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'assignment_id',
     p_argument_value => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'org_payment_method_id'
    ,p_argument_value => p_org_payment_method_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_personal_pay_method
    --
    hr_personal_pay_method_bk1.create_personal_pay_method_b
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_org_payment_method_id         => p_org_payment_method_id
      ,p_amount                        => p_amount
      ,p_percentage                    => p_percentage
      ,p_priority                      => p_priority
      ,p_comments                      => p_comments
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_territory_code                => p_territory_code
      ,p_segment1                      => p_segment1
      ,p_segment2                      => p_segment2
      ,p_segment3                      => p_segment3
--    ,p_segment4                      => lpad(p_segment4,9,'0')
      ,p_segment4                      => p_segment4
      ,p_segment5                      => p_segment5
      ,p_segment6                      => p_segment6
      ,p_segment7                      => p_segment7
      ,p_segment8                      => p_segment8
      ,p_segment9                      => p_segment9
      ,p_segment10                     => p_segment10
      ,p_segment11                     => p_segment11
      ,p_segment12                     => p_segment12
      ,p_segment13                     => p_segment13
      ,p_segment14                     => p_segment14
      ,p_segment15                     => p_segment15
      ,p_segment16                     => p_segment16
      ,p_segment17                     => p_segment17
      ,p_segment18                     => p_segment18
      ,p_segment19                     => p_segment19
      ,p_segment20                     => p_segment20
      ,p_segment21                     => p_segment21
      ,p_segment22                     => p_segment22
      ,p_segment23                     => p_segment23
      ,p_segment24                     => p_segment24
      ,p_segment25                     => p_segment25
      ,p_segment26                     => p_segment26
      ,p_segment27                     => p_segment27
      ,p_segment28                     => p_segment28
      ,p_segment29                     => p_segment29
      ,p_segment30                     => p_segment30
      ,p_payee_type                    => p_payee_type
      ,p_payee_id                      => p_payee_id
      ,p_ppm_information1              => p_ppm_information1
      ,p_ppm_information2              => p_ppm_information2
      ,p_ppm_information3              => p_ppm_information3
      ,p_ppm_information4              => p_ppm_information4
      ,p_ppm_information5              => p_ppm_information5
      ,p_ppm_information6              => p_ppm_information6
      ,p_ppm_information7              => p_ppm_information7
      ,p_ppm_information8              => p_ppm_information8
      ,p_ppm_information9              => p_ppm_information9
      ,p_ppm_information10             => p_ppm_information10
      ,p_ppm_information11             => p_ppm_information11
      ,p_ppm_information12             => p_ppm_information12
      ,p_ppm_information13             => p_ppm_information13
      ,p_ppm_information14             => p_ppm_information14
      ,p_ppm_information15             => p_ppm_information15
      ,p_ppm_information16             => p_ppm_information16
      ,p_ppm_information17             => p_ppm_information17
      ,p_ppm_information18             => p_ppm_information18
      ,p_ppm_information19             => p_ppm_information19
      ,p_ppm_information20             => p_ppm_information20
      ,p_ppm_information21             => p_ppm_information21
      ,p_ppm_information22             => p_ppm_information22
      ,p_ppm_information23             => p_ppm_information23
      ,p_ppm_information24             => p_ppm_information24
      ,p_ppm_information25             => p_ppm_information25
      ,p_ppm_information26             => p_ppm_information26
      ,p_ppm_information27             => p_ppm_information27
      ,p_ppm_information28             => p_ppm_information28
      ,p_ppm_information29             => p_ppm_information29
      ,p_ppm_information30             => p_ppm_information30
      ,p_ppm_information_category      => p_ppm_information_category
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSONAL_PAY_METHOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_personal_pay_method
    --
  end;
  --
  -- Derive the business group id, using the assignment id.
  --
  open bgsel;
  fetch bgsel
  into l_business_group_id;
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  if bgsel%notfound then
    close bgsel;
    hr_utility.set_message(801, 'HR_7348_ASSIGNMENT_INVALID');
    Hr_utility.raise_error;
  end if;
  close bgsel;
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Validate the organization payment method
  --
  open csr_is_valid;
  fetch csr_is_valid into l_exists;
  if csr_is_valid%notfound then
    close csr_is_valid;

    hr_utility.set_message(801, 'HR_7347_PPM_INVALID_PAY_TYPE');
    hr_utility.raise_error;
  end if;
  close csr_is_valid;
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Bug 3940935. Derive PPM_INFORMATION_CATEGORY.
  --
  if ((p_ppm_information1 is not null or
      p_ppm_information2 is not null or
      p_ppm_information3 is not null or
      p_ppm_information4 is not null or
      p_ppm_information5 is not null or
      p_ppm_information6 is not null or
      p_ppm_information7 is not null or
      p_ppm_information8 is not null or
      p_ppm_information9 is not null or
      p_ppm_information10 is not null or
      p_ppm_information11 is not null or
      p_ppm_information12 is not null or
      p_ppm_information13 is not null or
      p_ppm_information14 is not null or
      p_ppm_information15 is not null or
      p_ppm_information16 is not null or
      p_ppm_information17 is not null or
      p_ppm_information18 is not null or
      p_ppm_information19 is not null or
      p_ppm_information20 is not null or
      p_ppm_information21 is not null or
      p_ppm_information22 is not null or
      p_ppm_information23 is not null or
      p_ppm_information24 is not null or
      p_ppm_information25 is not null or
      p_ppm_information26 is not null or
      p_ppm_information27 is not null or
      p_ppm_information28 is not null or
      p_ppm_information29 is not null or
      p_ppm_information30 is not null   ) and
      p_ppm_information_category is null) then  --6439573

      open csr_ppm_info_category ( p_org_payment_method_id => p_org_payment_method_id
                                  ,p_effective_date => p_effective_date );

      fetch csr_ppm_info_category into l_ppm_information_category;
      if (csr_ppm_info_category%notfound) then
         close csr_ppm_info_category;
         fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
         fnd_message.set_token('COLUMN_NAME', 'PPM_INFORMATION_CATEGORY');
         fnd_message.raise_error;
      end if;
      close csr_ppm_info_category;
  /* Bug 6439573 ppm_info_category is not null, then assigned to the local one */
  elsif p_ppm_information_category is not null then
      l_ppm_information_category := p_ppm_information_category;
  end if;
  --
  -- Check that if payment type of the organization payment method
  -- is not 'MT' then all external account details should be null.
  --
  open csr_chk_pay_type;
  fetch csr_chk_pay_type into l_category;
  close csr_chk_pay_type;
  --
  if (l_category <> 'MT' or l_category is null)
    and (p_segment1  is not null or
         p_segment2  is not null or
         p_segment3  is not null or
         p_segment4  is not null or
         p_segment5  is not null or
         p_segment6  is not null or
         p_segment7  is not null or
         p_segment8  is not null or
         p_segment9  is not null or
         p_segment10 is not null or
         p_segment11 is not null or
         p_segment12 is not null or
         p_segment13 is not null or
         p_segment14 is not null or
         p_segment15 is not null or
         p_segment16 is not null or
         p_segment17 is not null or
         p_segment18 is not null or
         p_segment19 is not null or
         p_segment20 is not null or
         p_segment21 is not null or
         p_segment22 is not null or
         p_segment23 is not null or
         p_segment24 is not null or
         p_segment25 is not null or
         p_segment26 is not null or
         p_segment27 is not null or
         p_segment28 is not null or
         p_segment29 is not null or
         p_segment30 is not null ) then
  --
  --  Raise Error
      hr_utility.set_message(801, 'HR_51377_PPM_NON_MAG_TAPE_SEGM');
      hr_utility.raise_error;
  --
  elsif l_category = 'MT' then
    --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
    --
    -- call table handler pay_exa_ins to control the processing of the external
    -- account combination keyflex, discarding the returning parameter
    -- p_object_version_number
    --
    pay_exa_ins.ins_or_sel
    (p_segment1              => p_segment1
    ,p_segment2              => p_segment2
    ,p_segment3              => p_segment3
--  ,p_segment4              => lpad(p_segment4,9,'0')
    ,p_segment4              => p_segment4
    ,p_segment5              => p_segment5
    ,p_segment6              => p_segment6
    ,p_segment7              => p_segment7
    ,p_segment8              => p_segment8
    ,p_segment9              => p_segment9
    ,p_segment10             => p_segment10
    ,p_segment11             => p_segment11
    ,p_segment12             => p_segment12
    ,p_segment13             => p_segment13
    ,p_segment14             => p_segment14
    ,p_segment15             => p_segment15
    ,p_segment16             => p_segment16
    ,p_segment17             => p_segment17
    ,p_segment18             => p_segment18
    ,p_segment19             => p_segment19
    ,p_segment20             => p_segment20
    ,p_segment21             => p_segment21
    ,p_segment22             => p_segment22
    ,p_segment23             => p_segment23
    ,p_segment24             => p_segment24
    ,p_segment25             => p_segment25
    ,p_segment26             => p_segment26
    ,p_segment27             => p_segment27
    ,p_segment28             => p_segment28
    ,p_segment29             => p_segment29
    ,p_segment30             => p_segment30
/** sbilling **/
    ,p_concat_segments       => p_concat_segments
    ,p_business_group_id     => l_business_group_id
    ,p_territory_code        => p_territory_code
    ,p_external_account_id   => l_external_account_id
    ,p_object_version_number => l_exa_ovn
    ,p_validate              => l_validate
    --
    -- Special p_prenote_date value after bug2307154 changes.
    --
    ,p_prenote_date          => hr_api.g_date
    );
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- Call the row handler to insert the personal payment method.
  --
  pay_ppm_ins.ins
  (p_personal_payment_method_id   => l_personal_payment_method_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_business_group_id            => l_business_group_id
  ,p_external_account_id          => l_external_account_id
  ,p_assignment_id                => p_assignment_id
  ,p_run_type_id                  => p_run_type_id
  ,p_org_payment_method_id        => p_org_payment_method_id
  ,p_amount                       => p_amount
  ,p_comment_id                   => l_comment_id
  ,p_comments                     => p_comments
  ,p_percentage                   => p_percentage
  ,p_priority                     => p_priority
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => l_object_version_number
  ,p_payee_type                   => p_payee_type
  ,p_payee_id                     => p_payee_id
  ,p_effective_date               => l_effective_date
  ,p_validate                     => l_validate
  ,p_ppm_information_category     => l_ppm_information_category
  ,p_ppm_information1             => p_ppm_information1
  ,p_ppm_information2             => p_ppm_information2
  ,p_ppm_information3             => p_ppm_information3
  ,p_ppm_information4             => p_ppm_information4
  ,p_ppm_information5             => p_ppm_information5
  ,p_ppm_information6             => p_ppm_information6
  ,p_ppm_information7             => p_ppm_information7
  ,p_ppm_information8             => p_ppm_information8
  ,p_ppm_information9             => p_ppm_information9
  ,p_ppm_information10            => p_ppm_information10
  ,p_ppm_information11            => p_ppm_information11
  ,p_ppm_information12            => p_ppm_information12
  ,p_ppm_information13            => p_ppm_information13
  ,p_ppm_information14            => p_ppm_information14
  ,p_ppm_information15            => p_ppm_information15
  ,p_ppm_information16            => p_ppm_information16
  ,p_ppm_information17            => p_ppm_information17
  ,p_ppm_information18            => p_ppm_information18
  ,p_ppm_information19            => p_ppm_information19
  ,p_ppm_information20            => p_ppm_information20
  ,p_ppm_information21            => p_ppm_information21
  ,p_ppm_information22            => p_ppm_information22
  ,p_ppm_information23            => p_ppm_information23
  ,p_ppm_information24            => p_ppm_information24
  ,p_ppm_information25            => p_ppm_information25
  ,p_ppm_information26            => p_ppm_information26
  ,p_ppm_information27            => p_ppm_information27
  ,p_ppm_information28            => p_ppm_information28
  ,p_ppm_information29            => p_ppm_information29
  ,p_ppm_information30            => p_ppm_information30
  );
  --
  -- Stamp the prenote_date on the external accounts row for 'US' magtape
  -- payments only.
  --
  if g_debug then
     hr_utility.set_location(l_proc, 65);
  end if;
  if p_territory_code = 'US' and l_category = 'MT' then
    stamp_prenote_date
    (p_personal_payment_method_id => l_personal_payment_method_id
    ,p_effective_date             => l_effective_date
    ,p_external_account_id        => l_external_account_id
    ,p_external_account_ovn       => l_exa_ovn
    );
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 70);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_personal_pay_method
    --
    hr_personal_pay_method_bk1.create_personal_pay_method_a
      (p_effective_date                => l_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_org_payment_method_id         => p_org_payment_method_id
      ,p_amount                        => p_amount
      ,p_percentage                    => p_percentage
      ,p_priority                      => p_priority
      ,p_comments                      => p_comments
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_territory_code                => p_territory_code
      ,p_segment1                      => p_segment1
      ,p_segment2                      => p_segment2
      ,p_segment3                      => p_segment3
--    ,p_segment4                      => lpad(p_segment4,9,'0')
      ,p_segment4                      => p_segment4
      ,p_segment5                      => p_segment5
      ,p_segment6                      => p_segment6
      ,p_segment7                      => p_segment7
      ,p_segment8                      => p_segment8
      ,p_segment9                      => p_segment9
      ,p_segment10                     => p_segment10
      ,p_segment11                     => p_segment11
      ,p_segment12                     => p_segment12
      ,p_segment13                     => p_segment13
      ,p_segment14                     => p_segment14
      ,p_segment15                     => p_segment15
      ,p_segment16                     => p_segment16
      ,p_segment17                     => p_segment17
      ,p_segment18                     => p_segment18
      ,p_segment19                     => p_segment19
      ,p_segment20                     => p_segment20
      ,p_segment21                     => p_segment21
      ,p_segment22                     => p_segment22
      ,p_segment23                     => p_segment23
      ,p_segment24                     => p_segment24
      ,p_segment25                     => p_segment25
      ,p_segment26                     => p_segment26
      ,p_segment27                     => p_segment27
      ,p_segment28                     => p_segment28
      ,p_segment29                     => p_segment29
      ,p_segment30                     => p_segment30
      ,p_payee_type                    => p_payee_type
      ,p_payee_id                      => p_payee_id
      ,p_personal_payment_method_id    => l_personal_payment_method_id
      ,p_external_account_id           => l_external_account_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_comment_id                    => l_comment_id
      ,p_ppm_information1              => p_ppm_information1
      ,p_ppm_information2              => p_ppm_information2
      ,p_ppm_information3              => p_ppm_information3
      ,p_ppm_information4              => p_ppm_information4
      ,p_ppm_information5              => p_ppm_information5
      ,p_ppm_information6              => p_ppm_information6
      ,p_ppm_information7              => p_ppm_information7
      ,p_ppm_information8              => p_ppm_information8
      ,p_ppm_information9              => p_ppm_information9
      ,p_ppm_information10             => p_ppm_information10
      ,p_ppm_information11             => p_ppm_information11
      ,p_ppm_information12             => p_ppm_information12
      ,p_ppm_information13             => p_ppm_information13
      ,p_ppm_information14             => p_ppm_information14
      ,p_ppm_information15             => p_ppm_information15
      ,p_ppm_information16             => p_ppm_information16
      ,p_ppm_information17             => p_ppm_information17
      ,p_ppm_information18             => p_ppm_information18
      ,p_ppm_information19             => p_ppm_information19
      ,p_ppm_information20             => p_ppm_information20
      ,p_ppm_information21             => p_ppm_information21
      ,p_ppm_information22             => p_ppm_information22
      ,p_ppm_information23             => p_ppm_information23
      ,p_ppm_information24             => p_ppm_information24
      ,p_ppm_information25             => p_ppm_information25
      ,p_ppm_information26             => p_ppm_information26
      ,p_ppm_information27             => p_ppm_information27
      ,p_ppm_information28             => p_ppm_information28
      ,p_ppm_information29             => p_ppm_information29
      ,p_ppm_information30             => p_ppm_information30
      ,p_ppm_information_category      => l_ppm_information_category
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSONAL_PAY_METHOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_personal_pay_method
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_personal_payment_method_id    := l_personal_payment_method_id;
  p_external_account_id           := l_external_account_id;
  p_object_version_number         := l_object_version_number;
  p_effective_start_date          := l_effective_start_date;
  p_effective_end_date            := l_effective_end_date;
  p_comment_id                    := l_comment_id;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_personal_pay_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_personal_payment_method_id := null;
    p_external_account_id := null;
    p_object_version_number  := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_comment_id := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_personal_pay_method;
    p_personal_payment_method_id := null;
    p_external_account_id := null;
    p_object_version_number  := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_comment_id := null;
    raise;
    --
    -- End of fix.
    --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 90);
  end if;
    --
end create_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_gb_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_sort_code                     in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_bank_branch_location          in     varchar2 default null
  ,p_bldg_society_account_number   in     varchar2 default null
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ,p_segment9                      in     varchar2 default null -- Bug 7185344
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null -- Bug 7185344
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
  l_effective_date      date;
  l_territory_code      varchar2(30);
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
     l_proc := g_package||'create_gb_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  l_effective_date := p_effective_date;
  --
  hr_personal_pay_method_api.check_insert_legislation
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date
  ,p_leg_code        => 'GB');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  if p_territory_code is null then
     l_territory_code := 'GB';
  else
     l_territory_code := p_territory_code;
  end if;
  --
  -- Call the business process to create the personal payment method
  --
  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
  ,p_assignment_id                 => p_assignment_id
  ,p_run_type_id                   => p_run_type_id
  ,p_org_payment_method_id         => p_org_payment_method_id
  ,p_amount                        => p_amount
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_comments                      => p_comments
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => l_territory_code   --6469439
  ,p_segment1                      => p_bank_name
  ,p_segment2                      => p_bank_branch
  ,p_segment3                      => p_sort_code
  ,p_segment4                      => p_account_number
  ,p_segment5                      => p_account_name
  ,p_segment6                      => p_account_type
  ,p_segment7                      => p_bldg_society_account_number
  ,p_segment8                      => p_bank_branch_location
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  ,p_segment9                      => p_segment9    -- Bug 7185344
  ,p_segment10                     => p_segment10
  ,p_segment11                     => p_segment11
  ,p_segment12                     => p_segment12
  ,p_segment13                     => p_segment13
  ,p_segment14                     => p_segment14
  ,p_segment15                     => p_segment15
  ,p_segment16                     => p_segment16
  ,p_segment17                     => p_segment17
  ,p_segment18                     => p_segment18
  ,p_segment19                     => p_segment19
  ,p_segment20                     => p_segment20
  ,p_segment21                     => p_segment21
  ,p_segment22                     => p_segment22
  ,p_segment23                     => p_segment23
  ,p_segment24                     => p_segment24
  ,p_segment25                     => p_segment25
  ,p_segment26                     => p_segment26
  ,p_segment27                     => p_segment27
  ,p_segment28                     => p_segment28
  ,p_segment29                     => p_segment29
  ,p_segment30                     => p_segment30   -- Bug 7185344
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  );
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 8);
  end if;
end create_gb_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_us_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_us_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_transit_code                  in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_prenote_date                  in     date     default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
  l_effective_date      date;
  l_territory_code      varchar2(30);
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'create_us_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  l_effective_date := p_effective_date;
  --
  --
  hr_personal_pay_method_api.check_insert_legislation
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date
  ,p_leg_code        => 'US');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  if p_territory_code is null then
     l_territory_code := 'US';
  else
     l_territory_code := p_territory_code;
  end if;
  --
  -- Call the business process to create the personal payment method
  --
  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
  ,p_assignment_id                 => p_assignment_id
  ,p_run_type_id                   => p_run_type_id
  ,p_org_payment_method_id         => p_org_payment_method_id
  ,p_amount                        => p_amount
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_comments                      => p_comments
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => l_territory_code   --6469439
  ,p_segment1                      => p_account_name
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_account_number
  ,p_segment4                      => lpad(p_transit_code,9,'0')
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_bank_branch
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );
  --
  -- Update prenote date if external account is generated.
  --
  if p_prenote_date is not null and p_external_account_id is not null then
    --
    upd_prenote_date
      (p_personal_payment_method_id => p_personal_payment_method_id
      ,p_external_account_id        => p_external_account_id
      ,p_effective_date             => l_effective_date
      ,p_prenote_date               => p_prenote_date);
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
end create_us_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_ca_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_run_type_id                   in     number  default null
  ,p_org_payment_method_id         in     number
  ,p_account_name                  in     varchar2
  ,p_account_number                in     varchar2
  ,p_transit_code                  in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_bank_number                   in     varchar2
  ,p_account_type                  in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_amount                        in     number   default null
  ,p_percentage                    in     number   default null
  ,p_priority                      in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_territory_code                in     varchar2 default null      -- Bug 6469439
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default null
  ,p_ppm_information1              in     varchar2 default null
  ,p_ppm_information2              in     varchar2 default null
  ,p_ppm_information3              in     varchar2 default null
  ,p_ppm_information4              in     varchar2 default null
  ,p_ppm_information5              in     varchar2 default null
  ,p_ppm_information6              in     varchar2 default null
  ,p_ppm_information7              in     varchar2 default null
  ,p_ppm_information8              in     varchar2 default null
  ,p_ppm_information9              in     varchar2 default null
  ,p_ppm_information10             in     varchar2 default null
  ,p_ppm_information11             in     varchar2 default null
  ,p_ppm_information12             in     varchar2 default null
  ,p_ppm_information13             in     varchar2 default null
  ,p_ppm_information14             in     varchar2 default null
  ,p_ppm_information15             in     varchar2 default null
  ,p_ppm_information16             in     varchar2 default null
  ,p_ppm_information17             in     varchar2 default null
  ,p_ppm_information18             in     varchar2 default null
  ,p_ppm_information19             in     varchar2 default null
  ,p_ppm_information20             in     varchar2 default null
  ,p_ppm_information21             in     varchar2 default null
  ,p_ppm_information22             in     varchar2 default null
  ,p_ppm_information23             in     varchar2 default null
  ,p_ppm_information24             in     varchar2 default null
  ,p_ppm_information25             in     varchar2 default null
  ,p_ppm_information26             in     varchar2 default null
  ,p_ppm_information27             in     varchar2 default null
  ,p_ppm_information28             in     varchar2 default null
  ,p_ppm_information29             in     varchar2 default null
  ,p_ppm_information30             in     varchar2 default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
  l_effective_date      date;
  l_territory_code      varchar2(30);
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'create_ca_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  l_effective_date := p_effective_date;
  --
  --
  hr_personal_pay_method_api.check_insert_legislation
  (p_assignment_id   => p_assignment_id
  ,p_effective_date  => l_effective_date
  ,p_leg_code        => 'CA');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  if p_territory_code is null then
     l_territory_code := 'CA';
  else
     l_territory_code := p_territory_code;
  end if;
  --
  -- Call the business process to create the personal payment method
  --
  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
  ,p_assignment_id                 => p_assignment_id
  ,p_run_type_id                   => p_run_type_id
  ,p_org_payment_method_id         => p_org_payment_method_id
  ,p_amount                        => p_amount
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_comments                      => p_comments
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => l_territory_code   --6469439
  ,p_segment1                      => p_account_name
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_account_number
  ,p_segment4                      => lpad(p_transit_code,5,'0')
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_bank_branch
  ,p_segment7                      => p_bank_number
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 8);
  end if;
end create_ca_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_personal_pay_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
/** sbilling **/
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2  --Bug 6439573
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc               varchar2(72);
  l_business_group_id  per_assignments_f.business_group_id%TYPE;
  l_validate           boolean := FALSE;
  l_external_account_id
                       pay_personal_payment_methods_f.external_account_id%TYPE;
  l_object_version_number
                       pay_external_accounts.object_version_number%TYPE;
  l_exa_ovn            number;
  l_effective_date     date;
  l_ppm_information_category pay_personal_payment_methods_f.ppm_information_category%TYPE;
  --
  -- Declare OUT variables
  --
  l_comment_id
                       pay_personal_payment_methods_f.comment_id%TYPE;
  l_effective_start_date
                       pay_personal_payment_methods_f.effective_start_date%TYPE;
  l_effective_end_date
                       pay_personal_payment_methods_f.effective_end_date%TYPE;
  l_category varchar(2000);
  l_territory_code varchar2(2000);
  l_exa_territory_code varchar2(2000);
  --
  cursor bgsel is
    select ppm.business_group_id,
           ppm.external_account_id
    from   pay_personal_payment_methods_f ppm
    where  ppm.personal_payment_method_id = p_personal_payment_method_id
    and    p_effective_date between ppm.effective_start_date
                            and     ppm.effective_end_date;
  --
  cursor ovnsel is
    select pea.object_version_number
    ,      pea.territory_code
    from pay_external_accounts pea
    where pea.external_account_id = l_external_account_id;
  --
  cursor csr_chk_pay_type is
  select pyt.category
  from pay_personal_payment_methods_f ppm
  ,    pay_org_payment_methods_f opm
  ,    pay_payment_types pyt
  where ppm.personal_payment_method_id = p_personal_payment_method_id
  and   p_effective_date between
        ppm.effective_start_date and ppm.effective_end_date
  and   opm.org_payment_method_id = ppm.org_payment_method_id
  and   p_effective_date between
        opm.effective_start_date and opm.effective_end_date
  and   opm.payment_type_id = pyt.payment_type_id
  ;
  --
  cursor csr_ppm_info_category ( p_personal_payment_method_id number,
                                 p_effective_date date) is
     select decode(ppt.territory_code,null,null,ppt.territory_code||'_')||UPPER(ppt.payment_type_name) ppm_information_category
       from pay_payment_types ppt,
            pay_org_payment_methods_f opm,
            pay_personal_payment_methods_f ppm
      where ppm.personal_payment_method_id = p_personal_payment_method_id
        and p_effective_date between ppm.effective_start_date and ppm.effective_end_date
        and opm.org_payment_method_id = ppm.org_payment_method_id
        and p_effective_date between opm.effective_start_date and opm.effective_end_date
        and opm.payment_type_id = ppt.payment_type_id;
  --
--
-- In Out parameter
--
  l_object_version_number1        number;
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Assign in-out parameters to local variable
  -- and issue the savepoint.
  --
  l_object_version_number1 := p_object_version_number;
  --
  savepoint update_personal_pay_method;
  --
  --
  -- Check that p_personal_payment_method_id and p_effective_date are not null
  -- as they are used by the cursor to derive the business group.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'personal_payment_method_id',
     p_argument_value => p_personal_payment_method_id);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_personal_pay_method
    --
    hr_personal_pay_method_bk2.update_personal_pay_method_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_personal_payment_method_id    => p_personal_payment_method_id
      ,p_object_version_number         => p_object_version_number
      ,p_amount                        => p_amount
      ,p_comments                      => p_comments
      ,p_percentage                    => p_percentage
      ,p_priority                      => p_priority
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_territory_code                => p_territory_code
      ,p_segment1                      => p_segment1
      ,p_segment2                      => p_segment2
      ,p_segment3                      => p_segment3
--    ,p_segment4                      => lpad(p_segment4,9,'0')
      ,p_segment4                      => p_segment4
      ,p_segment5                      => p_segment5
      ,p_segment6                      => p_segment6
      ,p_segment7                      => p_segment7
      ,p_segment8                      => p_segment8
      ,p_segment9                      => p_segment9
      ,p_segment10                     => p_segment10
      ,p_segment11                     => p_segment11
      ,p_segment12                     => p_segment12
      ,p_segment13                     => p_segment13
      ,p_segment14                     => p_segment14
      ,p_segment15                     => p_segment15
      ,p_segment16                     => p_segment16
      ,p_segment17                     => p_segment17
      ,p_segment18                     => p_segment18
      ,p_segment19                     => p_segment19
      ,p_segment20                     => p_segment20
      ,p_segment21                     => p_segment21
      ,p_segment22                     => p_segment22
      ,p_segment23                     => p_segment23
      ,p_segment24                     => p_segment24
      ,p_segment25                     => p_segment25
      ,p_segment26                     => p_segment26
      ,p_segment27                     => p_segment27
      ,p_segment28                     => p_segment28
      ,p_segment29                     => p_segment29
      ,p_segment30                     => p_segment30
      ,p_payee_type                    => p_payee_type
      ,p_payee_id                      => p_payee_id
      ,p_ppm_information1              => p_ppm_information1
      ,p_ppm_information2              => p_ppm_information2
      ,p_ppm_information3              => p_ppm_information3
      ,p_ppm_information4              => p_ppm_information4
      ,p_ppm_information5              => p_ppm_information5
      ,p_ppm_information6              => p_ppm_information6
      ,p_ppm_information7              => p_ppm_information7
      ,p_ppm_information8              => p_ppm_information8
      ,p_ppm_information9              => p_ppm_information9
      ,p_ppm_information10             => p_ppm_information10
      ,p_ppm_information11             => p_ppm_information11
      ,p_ppm_information12             => p_ppm_information12
      ,p_ppm_information13             => p_ppm_information13
      ,p_ppm_information14             => p_ppm_information14
      ,p_ppm_information15             => p_ppm_information15
      ,p_ppm_information16             => p_ppm_information16
      ,p_ppm_information17             => p_ppm_information17
      ,p_ppm_information18             => p_ppm_information18
      ,p_ppm_information19             => p_ppm_information19
      ,p_ppm_information20             => p_ppm_information20
      ,p_ppm_information21             => p_ppm_information21
      ,p_ppm_information22             => p_ppm_information22
      ,p_ppm_information23             => p_ppm_information23
      ,p_ppm_information24             => p_ppm_information24
      ,p_ppm_information25             => p_ppm_information25
      ,p_ppm_information26             => p_ppm_information26
      ,p_ppm_information27             => p_ppm_information27
      ,p_ppm_information28             => p_ppm_information28
      ,p_ppm_information29             => p_ppm_information29
      ,p_ppm_information30             => p_ppm_information30
      ,p_ppm_information_category      => p_ppm_information_category
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSONAL_PAY_METHOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_personal_pay_method
    --
  end;
  --
  -- Derive the business group id, using the personal payment method id.
  --
  open bgsel;
  fetch bgsel
  into l_business_group_id,
       l_external_account_id;
  --
  if bgsel%notfound then
    close bgsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    Hr_utility.raise_error;
  end if;
  --
  close bgsel;
  --
  if l_external_account_id is not null then
    open ovnsel;
    fetch ovnsel
    into l_object_version_number
    ,    l_territory_code;
    if ovnsel%notfound then
      close ovnsel;
      --
      -- The external account primary key is invalid, so raise an error.
      --
      hr_utility.set_message(801, 'HR_51457_PPM_INVALID_OVN');
      hr_utility.raise_error;
    end if;
    close ovnsel;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Check that if payment type of the organization payment method
  -- is not 'MT' then all external account details should be null.
  -- If the values have been defaulted then assume that the code is
  -- updating a valid record.
  --
  open csr_chk_pay_type;
  fetch csr_chk_pay_type into l_category;
  close csr_chk_pay_type;
  --
  if l_category <> 'MT'and
     (nvl(p_segment1, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment2, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment3, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment4, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment5, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment6, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment7, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment8, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment9, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment10, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment11, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment12, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment13, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment14, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment15, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment16, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment17, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment18, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment19, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment20, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment21, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment22, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment23, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment24, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment25, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment26, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment27, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment28, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment29, hr_api.g_varchar2) <> hr_api.g_varchar2 or
      nvl(p_segment30, hr_api.g_varchar2) <> hr_api.g_varchar2) then
   --
   --  Raise Error
   --
   hr_utility.set_message(801, 'HR_51377_PPM_NON_MAG_TAPE_SEGM');
   hr_utility.raise_error;
  --
  elsif l_category = 'MT' then
    --
    -- Call table handler pay_exa_upd to control the processing of the external
    -- account combination keyflex.
    --

    -- Bug #3829284. When territory code is defaulted with hr_api.g_varchar2
    -- pass the derived territory code.

    l_exa_territory_code := p_territory_code;

    if p_territory_code = hr_api.g_varchar2 then

        l_exa_territory_code := l_territory_code;

    end if;

    pay_exa_upd.upd_or_sel
    (p_segment1              => p_segment1
    ,p_segment2              => p_segment2
    ,p_segment3              => p_segment3
    ,p_segment4              => p_segment4
    ,p_segment5              => p_segment5
    ,p_segment6              => p_segment6
    ,p_segment7              => p_segment7
    ,p_segment8              => p_segment8
    ,p_segment9              => p_segment9
    ,p_segment10             => p_segment10
    ,p_segment11             => p_segment11
    ,p_segment12             => p_segment12
    ,p_segment13             => p_segment13
    ,p_segment14             => p_segment14
    ,p_segment15             => p_segment15
    ,p_segment16             => p_segment16
    ,p_segment17             => p_segment17
    ,p_segment18             => p_segment18
    ,p_segment19             => p_segment19
    ,p_segment20             => p_segment20
    ,p_segment21             => p_segment21
    ,p_segment22             => p_segment22
    ,p_segment23             => p_segment23
    ,p_segment24             => p_segment24
    ,p_segment25             => p_segment25
    ,p_segment26             => p_segment26
    ,p_segment27             => p_segment27
    ,p_segment28             => p_segment28
    ,p_segment29             => p_segment29
    ,p_segment30             => p_segment30
  /** sbilling **/
    ,p_concat_segments       => p_concat_segments
    ,p_business_group_id     => l_business_group_id
    ,p_territory_code        => l_exa_territory_code
    ,p_external_account_id   => l_external_account_id
    ,p_object_version_number => l_exa_ovn
    ,p_validate              => l_validate
    --
    -- Special p_prenote_date value after bug2307154 changes.
    --
    ,p_prenote_date          => hr_api.g_date
    );
  end if;
  --
  -- Bug 3940935. Derive PPM_INFORMATION_CATEGORY.
  --
  l_ppm_information_category := hr_api.g_varchar2;

  if ((p_ppm_information1 <> hr_api.g_varchar2 or
      p_ppm_information2 <> hr_api.g_varchar2 or
      p_ppm_information3 <> hr_api.g_varchar2 or
      p_ppm_information4 <> hr_api.g_varchar2 or
      p_ppm_information5 <> hr_api.g_varchar2 or
      p_ppm_information6 <> hr_api.g_varchar2 or
      p_ppm_information7 <> hr_api.g_varchar2 or
      p_ppm_information8 <> hr_api.g_varchar2 or
      p_ppm_information9 <> hr_api.g_varchar2 or
      p_ppm_information10 <> hr_api.g_varchar2 or
      p_ppm_information11 <> hr_api.g_varchar2 or
      p_ppm_information12 <> hr_api.g_varchar2 or
      p_ppm_information13 <> hr_api.g_varchar2 or
      p_ppm_information14 <> hr_api.g_varchar2 or
      p_ppm_information15 <> hr_api.g_varchar2 or
      p_ppm_information16 <> hr_api.g_varchar2 or
      p_ppm_information17 <> hr_api.g_varchar2 or
      p_ppm_information18 <> hr_api.g_varchar2 or
      p_ppm_information19 <> hr_api.g_varchar2 or
      p_ppm_information20 <> hr_api.g_varchar2 or
      p_ppm_information21 <> hr_api.g_varchar2 or
      p_ppm_information22 <> hr_api.g_varchar2 or
      p_ppm_information23 <> hr_api.g_varchar2 or
      p_ppm_information24 <> hr_api.g_varchar2 or
      p_ppm_information25 <> hr_api.g_varchar2 or
      p_ppm_information26 <> hr_api.g_varchar2 or
      p_ppm_information27 <> hr_api.g_varchar2 or
      p_ppm_information28 <> hr_api.g_varchar2 or
      p_ppm_information29 <> hr_api.g_varchar2 or
      p_ppm_information30 <> hr_api.g_varchar2   ) and
      p_ppm_information_category = hr_api.g_varchar2   )then  --6439573

      open csr_ppm_info_category ( p_personal_payment_method_id => p_personal_payment_method_id
                                  ,p_effective_date => p_effective_date );

      fetch csr_ppm_info_category into l_ppm_information_category;
      if (csr_ppm_info_category%notfound) then
         close csr_ppm_info_category;
         fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
         fnd_message.set_token('COLUMN_NAME', 'PPM_INFORMATION_CATEGORY');
         fnd_message.raise_error;
      end if;
      close csr_ppm_info_category;
  /* Bug 6439573 ppm_info_category is not null, then assigned to the local one */
  elsif p_ppm_information_category <> hr_api.g_varchar2 then
      l_ppm_information_category := p_ppm_information_category;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 8);
  end if;
  --
  -- Call the row handler to update the personal payment method.
  --
  pay_ppm_upd.upd
  (p_personal_payment_method_id   => p_personal_payment_method_id
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_external_account_id          => l_external_account_id
  ,p_amount                       => p_amount
  ,p_comment_id                   => l_comment_id
  ,p_comments                     => p_comments
  ,p_percentage                   => p_percentage
  ,p_priority                     => p_priority
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => p_object_version_number
  ,p_payee_type                   => p_payee_type
  ,p_payee_id                     => p_payee_id
  ,p_effective_date               => l_effective_date
  ,p_datetrack_mode               => p_datetrack_update_mode
  ,p_validate                     => l_validate
  ,p_ppm_information_category     => l_ppm_information_category
  ,p_ppm_information1             => p_ppm_information1
  ,p_ppm_information2             => p_ppm_information2
  ,p_ppm_information3             => p_ppm_information3
  ,p_ppm_information4             => p_ppm_information4
  ,p_ppm_information5             => p_ppm_information5
  ,p_ppm_information6             => p_ppm_information6
  ,p_ppm_information7             => p_ppm_information7
  ,p_ppm_information8             => p_ppm_information8
  ,p_ppm_information9             => p_ppm_information9
  ,p_ppm_information10            => p_ppm_information10
  ,p_ppm_information11            => p_ppm_information11
  ,p_ppm_information12            => p_ppm_information12
  ,p_ppm_information13            => p_ppm_information13
  ,p_ppm_information14            => p_ppm_information14
  ,p_ppm_information15            => p_ppm_information15
  ,p_ppm_information16            => p_ppm_information16
  ,p_ppm_information17            => p_ppm_information17
  ,p_ppm_information18            => p_ppm_information18
  ,p_ppm_information19            => p_ppm_information19
  ,p_ppm_information20            => p_ppm_information20
  ,p_ppm_information21            => p_ppm_information21
  ,p_ppm_information22            => p_ppm_information22
  ,p_ppm_information23            => p_ppm_information23
  ,p_ppm_information24            => p_ppm_information24
  ,p_ppm_information25            => p_ppm_information25
  ,p_ppm_information26            => p_ppm_information26
  ,p_ppm_information27            => p_ppm_information27
  ,p_ppm_information28            => p_ppm_information28
  ,p_ppm_information29            => p_ppm_information29
  ,p_ppm_information30            => p_ppm_information30
  );
  --
  -- Stamp the prenote_date on the external accounts row for 'US' magtape
  -- payments only.
  --
  if g_debug then
     hr_utility.set_location(l_proc, 9);
  end if;
  if l_territory_code = 'US' and l_category = 'MT' then
    stamp_prenote_date
    (p_personal_payment_method_id => p_personal_payment_method_id
    ,p_effective_date             => l_effective_date
    ,p_external_account_id        => l_external_account_id
    ,p_external_account_ovn       => l_exa_ovn
    );
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 10);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_personal_pay_method
    --
    hr_personal_pay_method_bk2.update_personal_pay_method_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_personal_payment_method_id    => p_personal_payment_method_id
      ,p_object_version_number         => p_object_version_number
      ,p_amount                        => p_amount
      ,p_comments                      => p_comments
      ,p_percentage                    => p_percentage
      ,p_priority                      => p_priority
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_territory_code                => p_territory_code
      ,p_segment1                      => p_segment1
      ,p_segment2                      => p_segment2
      ,p_segment3                      => p_segment3
--    ,p_segment4                      => lpad(p_segment4,9,'0')
      ,p_segment4                      => p_segment4
      ,p_segment5                      => p_segment5
      ,p_segment6                      => p_segment6
      ,p_segment7                      => p_segment7
      ,p_segment8                      => p_segment8
      ,p_segment9                      => p_segment9
      ,p_segment10                     => p_segment10
      ,p_segment11                     => p_segment11
      ,p_segment12                     => p_segment12
      ,p_segment13                     => p_segment13
      ,p_segment14                     => p_segment14
      ,p_segment15                     => p_segment15
      ,p_segment16                     => p_segment16
      ,p_segment17                     => p_segment17
      ,p_segment18                     => p_segment18
      ,p_segment19                     => p_segment19
      ,p_segment20                     => p_segment20
      ,p_segment21                     => p_segment21
      ,p_segment22                     => p_segment22
      ,p_segment23                     => p_segment23
      ,p_segment24                     => p_segment24
      ,p_segment25                     => p_segment25
      ,p_segment26                     => p_segment26
      ,p_segment27                     => p_segment27
      ,p_segment28                     => p_segment28
      ,p_segment29                     => p_segment29
      ,p_segment30                     => p_segment30
      ,p_payee_type                    => p_payee_type
      ,p_payee_id                      => p_payee_id
      ,p_comment_id                    => l_comment_id
      ,p_external_account_id           => l_external_account_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_ppm_information1              => p_ppm_information1
      ,p_ppm_information2              => p_ppm_information2
      ,p_ppm_information3              => p_ppm_information3
      ,p_ppm_information4              => p_ppm_information4
      ,p_ppm_information5              => p_ppm_information5
      ,p_ppm_information6              => p_ppm_information6
      ,p_ppm_information7              => p_ppm_information7
      ,p_ppm_information8              => p_ppm_information8
      ,p_ppm_information9              => p_ppm_information9
      ,p_ppm_information10             => p_ppm_information10
      ,p_ppm_information11             => p_ppm_information11
      ,p_ppm_information12             => p_ppm_information12
      ,p_ppm_information13             => p_ppm_information13
      ,p_ppm_information14             => p_ppm_information14
      ,p_ppm_information15             => p_ppm_information15
      ,p_ppm_information16             => p_ppm_information16
      ,p_ppm_information17             => p_ppm_information17
      ,p_ppm_information18             => p_ppm_information18
      ,p_ppm_information19             => p_ppm_information19
      ,p_ppm_information20             => p_ppm_information20
      ,p_ppm_information21             => p_ppm_information21
      ,p_ppm_information22             => p_ppm_information22
      ,p_ppm_information23             => p_ppm_information23
      ,p_ppm_information24             => p_ppm_information24
      ,p_ppm_information25             => p_ppm_information25
      ,p_ppm_information26             => p_ppm_information26
      ,p_ppm_information27             => p_ppm_information27
      ,p_ppm_information28             => p_ppm_information28
      ,p_ppm_information29             => p_ppm_information29
      ,p_ppm_information30             => p_ppm_information30
      ,p_ppm_information_category      => l_ppm_information_category
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSONAL_PAY_METHOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_personal_pay_method
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set remaining output arguments
  --
  p_comment_id                  := l_comment_id;
  p_external_account_id         := l_external_account_id;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_personal_pay_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number1;
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_personal_pay_method;
    p_object_version_number  := l_object_version_number1;
    p_comment_id := null;
    p_external_account_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
    -- End of fix.
    --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 11);
  end if;
end update_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_gb_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_gb_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_sort_code                     in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch_location          in     varchar2 default hr_api.g_varchar2
  ,p_bldg_society_account_number   in     varchar2 default hr_api.g_varchar2
  ,p_amount                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_segment9                      in     varchar2 default null -- Bug 7185344
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null -- Bug 7185344
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_gb_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'GB'.
  --
  hr_personal_pay_method_api.check_update_legislation
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => p_effective_date
  ,p_leg_code                   => 'GB');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the business process to update the personal payment method
  --
hr_personal_pay_method_api.update_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => trunc(p_effective_date)
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_object_version_number         => p_object_version_number
  ,p_amount                        => p_amount
  ,p_comments                      => p_comments
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => p_territory_code     --Bug 6469439
  ,p_segment1                      => p_bank_name
  ,p_segment2                      => p_bank_branch
  ,p_segment3                      => p_sort_code
  ,p_segment4                      => p_account_number
  ,p_segment5                      => p_account_name
  ,p_segment6                      => p_account_type
  ,p_segment7                      => p_bldg_society_account_number
  ,p_segment8                      => p_bank_branch_location
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_segment9                      => p_segment9    -- Bug 7185344
  ,p_segment10                     => p_segment10
  ,p_segment11                     => p_segment11
  ,p_segment12                     => p_segment12
  ,p_segment13                     => p_segment13
  ,p_segment14                     => p_segment14
  ,p_segment15                     => p_segment15
  ,p_segment16                     => p_segment16
  ,p_segment17                     => p_segment17
  ,p_segment18                     => p_segment18
  ,p_segment19                     => p_segment19
  ,p_segment20                     => p_segment20
  ,p_segment21                     => p_segment21
  ,p_segment22                     => p_segment22
  ,p_segment23                     => p_segment23
  ,p_segment24                     => p_segment24
  ,p_segment25                     => p_segment25
  ,p_segment26                     => p_segment26
  ,p_segment27                     => p_segment27
  ,p_segment28                     => p_segment28
  ,p_segment29                     => p_segment29
  ,p_segment30                     => p_segment30   -- Bug 7185344
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  );
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 7);
  end if;
end update_gb_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_us_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_transit_code                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_amount                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_prenote_date                  in     date     default hr_api.g_date
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
   /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_gb_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'US'.
  --
  hr_personal_pay_method_api.check_update_legislation
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => p_effective_date
  ,p_leg_code                   => 'US');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the business process to update the personal payment method
  --
hr_personal_pay_method_api.update_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => trunc(p_effective_date)
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_object_version_number         => p_object_version_number
  ,p_amount                        => p_amount
  ,p_comments                      => p_comments
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => p_territory_code     --Bug 6469439
  ,p_segment1                      => p_account_name
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_account_number
  ,p_segment4                      => lpad(p_transit_code,9,'0')
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_bank_branch
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  -- Update prenote date if external account is generated.
  --
  if nvl(p_prenote_date, hr_api.g_date+1) <> hr_api.g_date and p_external_account_id is not null then
    --
    upd_prenote_date
      (p_personal_payment_method_id => p_personal_payment_method_id
      ,p_external_account_id        => p_external_account_id
      ,p_effective_date             => p_effective_date
      ,p_prenote_date               => p_prenote_date);
    --
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 7);
  end if;
end update_us_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_ca_personal_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ca_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2
  ,p_transit_code                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_number                   in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_account_type                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_amount                        in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_territory_code                in     varchar2 default hr_api.g_varchar2
  /*Bug# 8717589*/
  ,p_ppm_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information1              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information2              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information3              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information4              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information5              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information6              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information7              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information8              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information9              in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information10             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information11             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information12             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information13             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information14             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information15             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information16             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information17             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information18             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information19             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information20             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information21             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information22             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information23             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information24             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information25             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information26             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information27             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information28             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information29             in     varchar2 default hr_api.g_varchar2
  ,p_ppm_information30             in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'update_gb_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'US'.
  --
  hr_personal_pay_method_api.check_update_legislation
  (p_personal_payment_method_id => p_personal_payment_method_id
  ,p_effective_date             => p_effective_date
  ,p_leg_code                   => 'CA');
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the business process to update the personal payment method
  --
hr_personal_pay_method_api.update_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => trunc(p_effective_date)
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_object_version_number         => p_object_version_number
  ,p_amount                        => p_amount
  ,p_comments                      => p_comments
  ,p_percentage                    => p_percentage
  ,p_priority                      => p_priority
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_territory_code                => p_territory_code     --Bug 6469439
  ,p_segment1                      => p_account_name
  ,p_segment2                      => p_account_type
  ,p_segment3                      => p_account_number
  ,p_segment4                      => lpad(p_transit_code,5,'0')
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_bank_branch
  ,p_segment7                      => p_bank_number
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_ppm_information_category      => p_ppm_information_category
  ,p_ppm_information1              => p_ppm_information1
  ,p_ppm_information2              => p_ppm_information2
  ,p_ppm_information3              => p_ppm_information3
  ,p_ppm_information4              => p_ppm_information4
  ,p_ppm_information5              => p_ppm_information5
  ,p_ppm_information6              => p_ppm_information6
  ,p_ppm_information7              => p_ppm_information7
  ,p_ppm_information8              => p_ppm_information8
  ,p_ppm_information9              => p_ppm_information9
  ,p_ppm_information10             => p_ppm_information10
  ,p_ppm_information11             => p_ppm_information11
  ,p_ppm_information12             => p_ppm_information12
  ,p_ppm_information13             => p_ppm_information13
  ,p_ppm_information14             => p_ppm_information14
  ,p_ppm_information15             => p_ppm_information15
  ,p_ppm_information16             => p_ppm_information16
  ,p_ppm_information17             => p_ppm_information17
  ,p_ppm_information18             => p_ppm_information18
  ,p_ppm_information19             => p_ppm_information19
  ,p_ppm_information20             => p_ppm_information20
  ,p_ppm_information21             => p_ppm_information21
  ,p_ppm_information22             => p_ppm_information22
  ,p_ppm_information23             => p_ppm_information23
  ,p_ppm_information24             => p_ppm_information24
  ,p_ppm_information25             => p_ppm_information25
  ,p_ppm_information26             => p_ppm_information26
  ,p_ppm_information27             => p_ppm_information27
  ,p_ppm_information28             => p_ppm_information28
  ,p_ppm_information29             => p_ppm_information29
  ,p_ppm_information30             => p_ppm_information30
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 7);
  end if;
end update_ca_personal_pay_method;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_personal_pay_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               varchar2(72);
  l_validate           boolean := FALSE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'delete_personal_pay_method';
     hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;
  --
  -- Issue a savepoint.
  --
  savepoint delete_personal_pay_method;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the row handler to delete the personal payment method.
  --
  pay_ppm_del.del
  (p_personal_payment_method_id   => p_personal_payment_method_id
  ,p_effective_start_date         => p_effective_start_date
  ,p_effective_end_date           => p_effective_end_date
  ,p_object_version_number        => p_object_version_number
  ,p_effective_date               => trunc(p_effective_date)
  ,p_datetrack_mode               => p_datetrack_delete_mode
  ,p_validate                     => l_validate
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 8);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_personal_pay_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO delete_personal_pay_method;
    p_object_version_number  := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
    -- End of fix.
    --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 9);
  end if;
end delete_personal_pay_method;
--
end hr_personal_pay_method_api;

/
