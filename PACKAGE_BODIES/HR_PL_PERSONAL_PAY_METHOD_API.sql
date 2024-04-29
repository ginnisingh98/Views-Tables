--------------------------------------------------------
--  DDL for Package Body HR_PL_PERSONAL_PAY_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_PERSONAL_PAY_METHOD_API" as
/* $Header: pyppmpli.pkb 120.0.12010000.2 2009/12/18 10:48:00 bkeshary ship $ */
--
-- Package Variables
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_personal_pay_method >---------------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_personal_pay_method
  (p_validate					   in     boolean  default false
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
  ,p_account_check_digit           in     varchar2
  ,p_bank_id                       in     varchar2
  ,p_account_number                in     varchar2 default null /* modified */
  ,p_account_name                  in     varchar2 default null
  ,p_bank_name                     in     varchar2 default null
  ,p_bank_branch                   in     varchar2 default null
  ,p_address                       in     varchar2 default null
  ,p_additional_information        in     varchar2 default null
  ,p_segment9		               in     varchar2 default '*'
  ,p_segment10          	       in     varchar2 default '1'
  ,p_bic_code                      in     varchar2 default null /* added bkeshary */
  ,p_iban_number                   in     varchar2 default null /* added bkeshary */
  /*,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null */
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
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default null
  ,p_payee_id                      in     number   default null
  ,p_personal_payment_method_id    out    nocopy number
  ,p_external_account_id           out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_comment_id                    out    nocopy number) is

  --
  -- Declare local variables
  --
  l_proc                varchar2(72);
  l_valid               varchar2(150);
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
  --
begin
     g_package :='hr_pl_personal_pay_method_api.';
     l_proc    := g_package||'create_pl_personal_pay_method';

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
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

  if legsel%found and l_valid <> 'PL' then
    close legsel;
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
hr_personal_pay_method_api.create_personal_pay_method
  (p_validate                      => p_validate
  ,p_effective_date                => p_effective_date
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
  ,p_territory_code                => p_territory_code
  ,p_segment1                      => p_account_check_digit
  ,p_segment2                      => p_bank_id
  ,p_segment3                      => p_account_number
  ,p_segment4                      => p_account_name
  ,p_segment5                      => p_bank_name
  ,p_segment6                      => p_bank_branch
  ,p_segment7                      => p_address
  ,p_segment8                      => p_additional_information
  ,p_segment9                      => p_segment9
  ,p_segment10                     => p_segment10
  ,p_segment11                     => p_bic_code  /* added  */
  ,p_segment12                     => p_iban_number /* added */
  /*,p_segment11                     => p_segment11
  ,p_segment12                     => p_segment12 */
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
  ,p_concat_segments               => p_concat_segments
  ,p_payee_type                    => p_payee_type
  ,p_payee_id                      => p_payee_id
  ,p_personal_payment_method_id    => p_personal_payment_method_id
  ,p_external_account_id           => p_external_account_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_comment_id                    => p_comment_id
  );

end create_pl_personal_pay_method;

procedure update_pl_personal_pay_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_personal_payment_method_id    in     number
  ,p_object_version_number         in     out nocopy number
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
  ,p_account_check_digit           in     varchar2
  ,p_bank_id                       in     varchar2
  ,p_account_number                in     varchar2 default hr_api.g_varchar2/* Modified  */
  ,p_account_name                  in     varchar2 default hr_api.g_varchar2
  ,p_bank_name                     in     varchar2 default hr_api.g_varchar2
  ,p_bank_branch                   in     varchar2 default hr_api.g_varchar2
  ,p_address                       in     varchar2 default hr_api.g_varchar2
  ,p_additional_information        in     varchar2 default hr_api.g_varchar2
  ,p_segment9        		       in     varchar2 default '*'
  ,p_segment10	                   in     varchar2 default '1'
  ,p_bic_code                      in     varchar2 default hr_api.g_varchar2 /* added  */
  ,p_iban_number                   in     varchar2 default hr_api.g_varchar2/* added  */
  /*,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2 */
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
  ,p_concat_segments               in     varchar2 default null
  ,p_payee_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payee_id                      in     number   default hr_api.g_number
  ,p_comment_id                    out nocopy    number
  ,p_external_account_id           out nocopy    number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  ) is

  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_valid                varchar2(150);
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
     g_package :='hr_pl_personal_pay_method_api.';
     l_proc    := g_package||'update_pl_personal_pay_method';

     hr_utility.set_location('Entering:'|| l_proc, 5);
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
  if legsel%found and l_valid <> 'PL' then
    hr_utility.set_message(801, 'HR_7898_PPM_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  close legsel;
hr_personal_pay_method_api.update_personal_pay_method
(  p_validate                      =>     p_validate
  ,p_effective_date                =>     p_effective_date
  ,p_datetrack_update_mode         =>     p_datetrack_update_mode
  ,p_personal_payment_method_id    =>     p_personal_payment_method_id
  ,p_object_version_number         =>     p_object_version_number
  ,p_amount                        =>     p_amount
  ,p_comments                      =>     p_comments
  ,p_percentage                    =>     p_percentage
  ,p_priority                      =>     p_priority
  ,p_attribute_category            =>     p_attribute_category
  ,p_attribute1                    =>     p_attribute1
  ,p_attribute2                    =>     p_attribute2
  ,p_attribute3                    =>     p_attribute3
  ,p_attribute4                    =>     p_attribute4
  ,p_attribute5                    =>     p_attribute5
  ,p_attribute6                    =>     p_attribute6
  ,p_attribute7                    =>     p_attribute7
  ,p_attribute8                    =>     p_attribute8
  ,p_attribute9                    =>     p_attribute9
  ,p_attribute10                   =>     p_attribute10
  ,p_attribute11                   =>     p_attribute11
  ,p_attribute12                   =>     p_attribute12
  ,p_attribute13                   =>     p_attribute13
  ,p_attribute14                   =>     p_attribute14
  ,p_attribute15                   =>     p_attribute15
  ,p_attribute16                   =>     p_attribute16
  ,p_attribute17                   =>     p_attribute17
  ,p_attribute18                   =>     p_attribute18
  ,p_attribute19                   =>     p_attribute19
  ,p_attribute20                   =>     p_attribute20
  ,p_territory_code                =>     p_territory_code
  ,p_segment1                      =>  	  p_account_check_digit
  ,p_segment2                      =>     p_bank_id
  ,p_segment3                      => 	  p_account_number
  ,p_segment4                      => 	  p_account_name
  ,p_segment5                      => 	  p_bank_name
  ,p_segment6                      => 	  p_bank_branch
  ,p_segment7                      => 	  p_address
  ,p_segment8                      => 	  p_additional_information
  ,p_segment9                      => 	  p_segment9
  ,p_segment10                     => 	  p_segment10
  ,p_segment11                     =>     p_bic_code  /* added bkeshary */
  ,p_segment12                     =>     p_iban_number /* added bkeshary */
 /* ,p_segment11                     =>     p_segment11
  ,p_segment12                     =>     p_segment12 */
  ,p_segment13                     =>     p_segment13
  ,p_segment14                     =>     p_segment14
  ,p_segment15                     =>     p_segment15
  ,p_segment16                     =>     p_segment16
  ,p_segment17                     =>     p_segment17
  ,p_segment18                     =>     p_segment18
  ,p_segment19                     =>     p_segment19
  ,p_segment20                     =>     p_segment20
  ,p_segment21                     =>     p_segment21
  ,p_segment22                     =>     p_segment22
  ,p_segment23                     =>     p_segment23
  ,p_segment24                     =>     p_segment24
  ,p_segment25                     =>     p_segment25
  ,p_segment26                     =>     p_segment26
  ,p_segment27                     =>     p_segment27
  ,p_segment28                     =>     p_segment28
  ,p_segment29                     =>     p_segment29
  ,p_segment30                     =>     p_segment30
  ,p_concat_segments               =>     p_concat_segments
  ,p_payee_type                    =>     p_payee_type
  ,p_payee_id                      =>     p_payee_id
  ,p_comment_id                    =>     p_comment_id
  ,p_external_account_id           =>     p_external_account_id
  ,p_effective_start_date          =>     p_effective_start_date
  ,p_effective_end_date            =>     p_effective_end_date
  );

end update_pl_personal_pay_method;

--
end hr_pl_personal_pay_method_api;

/
