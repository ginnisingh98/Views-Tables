--------------------------------------------------------
--  DDL for Package Body HR_FR_PERS_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_PERS_PAY_METHOD_API" as
/* $Header: peppmfri.pkb 115.2 2002/11/26 17:28:38 sfmorris noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_fr_pers_pay_method_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_fr_pers_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fr_pers_pay_method
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_org_payment_method_id         in     number
  ,p_amount                        in     number
  ,p_percentage                    in     number
  ,p_priority                      in     number
  ,p_comments                      in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_bank_code                     in     varchar2
  ,p_branch_code                   in     varchar2
  ,p_branch_name                   in     varchar2
  ,p_account_number                in     varchar2
  ,p_account_name                  in     varchar2
  ,p_3rd_party_payee               in     varchar2
  ,p_transmitter_code              in     varchar2
  ,p_deposit_type                  in     varchar2
  ,p_valid_bank_branch             in     varchar2
  ,p_payee_type                    in     varchar2
  ,p_payee_id                      in     number
  ,p_personal_payment_method_id    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ,p_comment_id                    out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
    cursor legsel is
    select pbg.legislation_code
    from   per_business_groups pbg,
	   per_assignments_f   asg
    where  pbg.business_group_id = asg.business_group_id
    and    asg.assignment_id     = p_assignment_id
    and    p_effective_date between asg.effective_start_date
			    and     asg.effective_end_date;


  l_proc                varchar2(72) :=
			g_package||'create_fr_pers_pay_method';
  l_valid               varchar2(150);
  l_effective_date      date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  l_effective_date := p_effective_date;
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
  if legsel%found and l_valid <> 'FR' then
    close legsel;
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
  hr_utility.set_location(l_proc, 7);
  --
  -- Call the business process to create the personal payment method
  --
  hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => l_effective_date
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
  ,p_territory_code                => 'FR'
  ,p_segment1                      => p_bank_name
  ,p_segment2                      => p_bank_code
  ,p_segment3                      => p_branch_code
  ,p_segment4                      => p_branch_name
  ,p_segment5                      => p_account_number
  ,p_segment6                      => p_account_name
  ,p_segment7                      => p_3rd_party_payee
  ,p_segment8                      => p_transmitter_code
  ,p_segment9                      => p_deposit_type
  ,p_segment10                     => p_valid_bank_branch
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 8);
end create_fr_pers_pay_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_fr_pers_pay_method >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fr_pers_pay_method
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in out nocopy number
  ,p_amount                        in     number
  ,p_comments                      in     varchar2
  ,p_percentage                    in     number
  ,p_priority                      in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_bank_name                     in     varchar2
  ,p_bank_code                     in     varchar2
  ,p_branch_code                   in     varchar2
  ,p_branch_name                   in     varchar2
  ,p_account_number                in     varchar2
  ,p_account_name                  in     varchar2
  ,p_3rd_party_payee               in     varchar2
  ,p_transmitter_code              in     varchar2
  ,p_deposit_type                  in     varchar2
  ,p_valid_bank_branch             in     varchar2
  ,p_payee_type                    in     varchar2
  ,p_payee_id                      in     number
  ,p_comment_id                    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) :=
			  g_package||'update_fr_pers_pay_method';
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
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Ensure that the legislation rule for the employee assignment business
  -- group is 'FR'.
  --
  open legsel;
  fetch legsel
  into l_valid;
  --
  if legsel%notfound then
    close legsel;
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  if legsel%found and l_valid <> 'FR' then
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
  --
  hr_utility.set_location(l_proc, 6);
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
  ,p_attribute2                    => p_attribute1
  ,p_attribute3                    => p_attribute1
  ,p_attribute4                    => p_attribute1
  ,p_attribute5                    => p_attribute1
  ,p_attribute6                    => p_attribute1
  ,p_attribute7                    => p_attribute1
  ,p_attribute8                    => p_attribute1
  ,p_attribute9                    => p_attribute1
  ,p_attribute10                   => p_attribute1
  ,p_attribute11                   => p_attribute1
  ,p_attribute12                   => p_attribute1
  ,p_attribute13                   => p_attribute1
  ,p_attribute14                   => p_attribute1
  ,p_attribute15                   => p_attribute1
  ,p_attribute16                   => p_attribute1
  ,p_attribute17                   => p_attribute1
  ,p_attribute18                   => p_attribute1
  ,p_attribute19                   => p_attribute1
  ,p_attribute20                   => p_attribute1
  ,p_territory_code                => 'FR'
  ,p_segment1                      => p_bank_name
  ,p_segment2                      => p_bank_code
  ,p_segment3                      => p_branch_code
  ,p_segment4                      => p_branch_name
  ,p_segment5                      => p_account_number
  ,p_segment6                      => p_account_name
  ,p_segment7                      => p_3rd_party_payee
  ,p_segment8                      => p_transmitter_code
  ,p_segment9                      => p_deposit_type
  ,p_segment10                     => p_valid_bank_branch
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_comment_id                    => p_comment_id
  ,p_external_account_id           => p_external_account_id
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end update_fr_pers_pay_method;
--
end hr_fr_pers_pay_method_api;

/
