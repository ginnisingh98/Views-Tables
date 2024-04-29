--------------------------------------------------------
--  DDL for Package Body PAY_AUD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AUD_BUS" as
/* $Header: pyaudrhi.pkb 115.4 2002/12/09 10:29:32 alogue ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_aud_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_stat_trans_audit_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_person_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_person_id
  (p_person_id             in pay_stat_trans_audit.person_id%TYPE
  ,p_business_group_id     in pay_stat_trans_audit.business_group_id%TYPE
  ,p_effective_date        in pay_stat_trans_audit.transaction_effective_date%TYPE
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
  -- the transaction business group
  --
  open csr_get_bus_grp;
  fetch csr_get_bus_grp into l_business_group_id;
  if l_business_group_id <> p_business_group_id then
    close csr_get_bus_grp;
    hr_utility.set_message(801, 'PAY_289127_TRANS_BG_NOT_PER_BG');
    hr_utility.raise_error;
  end if;
  close csr_get_bus_grp;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_person_id;
-- ----------------------------------------------------------------------------
-- |------< chk_assignment_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure validates the assignment_id with the following checks:
--    - the assignment_id exists in PER_ASSIGNMENTS_F
--    - the assignment's business group must match the tax record's bus grp.
--   The record's business_group_id is also validated by checking that it
--    matches an existing business_group_id in PER_ASSIGNMENTS_F.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_assignment_id           ID of FK column
--   p_business_group_id       business group id
--   p_effective_date          session date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_assignment_id
  (p_assignment_id            in pay_stat_trans_audit.assignment_id%TYPE
  ,p_business_group_id        in pay_stat_trans_audit.business_group_id%TYPE
  ,p_effective_date	      in pay_stat_trans_audit.transaction_effective_date%TYPE
  ) is
  --
  l_proc                    varchar2(72) := g_package||'chk_assignment_id';
  l_dummy                   varchar2(1);
  l_business_group_id       per_assignments_f.business_group_id%TYPE;
  --
  cursor csr_bg_id is
    select business_group_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
             and asg.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if (p_assignment_id is not null) then
    --
    open csr_bg_id;
      --
      fetch csr_bg_id into l_business_group_id;
      if csr_bg_id%notfound then
        --
        close csr_bg_id;
        --
        -- raise error as assignment_id not found in per_assignments_f
        -- table.
        --
        hr_utility.set_message(801, 'HR_51746_ASG_INV_ASG_ID');
        hr_utility.raise_error;
        --
      else
        --
        if p_business_group_id <> l_business_group_id then
          --
          close csr_bg_id;
          --
          hr_utility.set_message(801, 'PAY_289128_TRANS_BG_NOT_ASG_BG');
          hr_utility.raise_error;
          --
        end if;
        --
        close csr_bg_id;
        --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_assignment_id;
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_source    >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_source
  (p_source             in pay_stat_trans_audit.source1%TYPE
  ,p_source_type        in pay_stat_trans_audit.source1_type%TYPE
  ,p_effective_date     in pay_stat_trans_audit.transaction_effective_date%TYPE
  )
  is
--
   l_proc               varchar2(72)  :=  g_package||'chk_source';
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- make sure that the source type is valid
  if p_source_type is not null then
	if hr_api.not_exists_in_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'PAY_TRANSACTION_SOURCE_TYPE'
         ,p_lookup_code           => p_source_type
         ) then
  		hr_utility.set_message(801, 'PAY_289131_AUD_SRC_TYPE_INVAL');
  		hr_utility.raise_error;
	end if;
  end if;

  -- make sure if p_source is specified then p_source_type is specified
  if (p_source is not null) and (p_source_type is null) then
	hr_utility.set_message(801, 'PAY_289132_AUD_SRC_NO_SRC_TYPE');
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_source;
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_transaction_type>------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_transaction_type
  (p_transaction_type             in pay_stat_trans_audit.transaction_type%TYPE
  ,p_transaction_subtype          in pay_stat_trans_audit.transaction_subtype%TYPE
  ,p_effective_date               in pay_stat_trans_audit.transaction_effective_date%TYPE
  )
  is
--
   l_proc               varchar2(72)  :=  g_package||'chk_transaction_type';
   --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
   (p_api_name	      => l_proc
   ,p_argument	      => 'p_transaction_type'
   ,p_argument_value  => p_transaction_type
   );
  hr_utility.set_location(l_proc, 2);
  --
  -- make sure that the transaction type is valid
  if hr_api.not_exists_in_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'PAY_TRANSACTION_TYPE'
         ,p_lookup_code           => p_transaction_type
         ) then
  		hr_utility.set_message(801, 'PAY_289129_AUD_TRANS_TYPE_INVL');
  		hr_utility.raise_error;
  end if;

  -- make sure that if a subtype is specified, it is valid
  if p_transaction_subtype is not null and
	   hr_api.not_exists_in_hr_lookups
	         (p_effective_date        => p_effective_date
	         ,p_lookup_type           => p_transaction_type
	         ,p_lookup_code           => p_transaction_subtype
	         ) then
                  hr_utility.set_message(801, 'PAY_289130_AUD_SUB_TYPE_INVAL');
                  hr_utility.raise_error;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 3);
end chk_transaction_type;
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_stat_trans_audit_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_stat_trans_audit aud
     where aud.stat_trans_audit_id = p_stat_trans_audit_id
       and pbg.business_group_id = aud.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'stat_trans_audit_id'
    ,p_argument_value     => p_stat_trans_audit_id
    );
  --
  if ( nvl(pay_aud_bus.g_stat_trans_audit_id, hr_api.g_number)
       = p_stat_trans_audit_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_aud_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_aud_bus.g_stat_trans_audit_id := p_stat_trans_audit_id;
    pay_aud_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pay_aud_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_STAT_TRANS_AUDIT_DDF'
      ,p_attribute_category              => p_rec.audit_information_category
      ,p_attribute1_name                 => 'AUDIT_INFORMATION1'
      ,p_attribute1_value                => p_rec.audit_information1
      ,p_attribute2_name                 => 'AUDIT_INFORMATION2'
      ,p_attribute2_value                => p_rec.audit_information2
      ,p_attribute3_name                 => 'AUDIT_INFORMATION3'
      ,p_attribute3_value                => p_rec.audit_information3
      ,p_attribute4_name                 => 'AUDIT_INFORMATION4'
      ,p_attribute4_value                => p_rec.audit_information4
      ,p_attribute5_name                 => 'AUDIT_INFORMATION5'
      ,p_attribute5_value                => p_rec.audit_information5
      ,p_attribute6_name                 => 'AUDIT_INFORMATION6'
      ,p_attribute6_value                => p_rec.audit_information6
      ,p_attribute7_name                 => 'AUDIT_INFORMATION7'
      ,p_attribute7_value                => p_rec.audit_information7
      ,p_attribute8_name                 => 'AUDIT_INFORMATION8'
      ,p_attribute8_value                => p_rec.audit_information8
      ,p_attribute9_name                 => 'AUDIT_INFORMATION9'
      ,p_attribute9_value                => p_rec.audit_information9
      ,p_attribute10_name                => 'AUDIT_INFORMATION10'
      ,p_attribute10_value               => p_rec.audit_information10
      ,p_attribute11_name                => 'AUDIT_INFORMATION11'
      ,p_attribute11_value               => p_rec.audit_information11
      ,p_attribute12_name                => 'AUDIT_INFORMATION12'
      ,p_attribute12_value               => p_rec.audit_information12
      ,p_attribute13_name                => 'AUDIT_INFORMATION13'
      ,p_attribute13_value               => p_rec.audit_information13
      ,p_attribute14_name                => 'AUDIT_INFORMATION14'
      ,p_attribute14_value               => p_rec.audit_information14
      ,p_attribute15_name                => 'AUDIT_INFORMATION15'
      ,p_attribute15_value               => p_rec.audit_information15
      ,p_attribute16_name                => 'AUDIT_INFORMATION16'
      ,p_attribute16_value               => p_rec.audit_information16
      ,p_attribute17_name                => 'AUDIT_INFORMATION17'
      ,p_attribute17_value               => p_rec.audit_information17
      ,p_attribute18_name                => 'AUDIT_INFORMATION18'
      ,p_attribute18_value               => p_rec.audit_information18
      ,p_attribute19_name                => 'AUDIT_INFORMATION19'
      ,p_attribute19_value               => p_rec.audit_information19
      ,p_attribute20_name                => 'AUDIT_INFORMATION20'
      ,p_attribute20_value               => p_rec.audit_information20
      ,p_attribute21_name                => 'AUDIT_INFORMATION21'
      ,p_attribute21_value               => p_rec.audit_information21
      ,p_attribute22_name                => 'AUDIT_INFORMATION22'
      ,p_attribute22_value               => p_rec.audit_information22
      ,p_attribute23_name                => 'AUDIT_INFORMATION23'
      ,p_attribute23_value               => p_rec.audit_information23
      ,p_attribute24_name                => 'AUDIT_INFORMATION24'
      ,p_attribute24_value               => p_rec.audit_information24
      ,p_attribute25_name                => 'AUDIT_INFORMATION25'
      ,p_attribute25_value               => p_rec.audit_information25
      ,p_attribute26_name                => 'AUDIT_INFORMATION26'
      ,p_attribute26_value               => p_rec.audit_information26
      ,p_attribute27_name                => 'AUDIT_INFORMATION27'
      ,p_attribute27_value               => p_rec.audit_information27
      ,p_attribute28_name                => 'AUDIT_INFORMATION28'
      ,p_attribute28_value               => p_rec.audit_information28
      ,p_attribute29_name                => 'AUDIT_INFORMATION29'
      ,p_attribute29_value               => p_rec.audit_information29
      ,p_attribute30_name                => 'AUDIT_INFORMATION30'
      ,p_attribute30_value               => p_rec.audit_information30
      );
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
 -- Check the transaction type
  chk_transaction_type(p_transaction_type => p_rec.transaction_type
		      ,p_transaction_subtype => p_rec.transaction_subtype
		      ,p_effective_date => p_rec.transaction_effective_date
		      );

  -- Check the source columns
  chk_source(p_source => p_rec.source1
	    ,p_source_type => p_rec.source1_type
	    ,p_effective_date => p_rec.transaction_effective_date
	    );
  chk_source(p_source => p_rec.source2
	    ,p_source_type => p_rec.source2_type
	    ,p_effective_date => p_rec.transaction_effective_date
	    );
  chk_source(p_source => p_rec.source3
	    ,p_source_type => p_rec.source3_type
	    ,p_effective_date => p_rec.transaction_effective_date
	    );
  chk_source(p_source => p_rec.source4
	    ,p_source_type => p_rec.source4_type
	    ,p_effective_date => p_rec.transaction_effective_date
	    );
  chk_source(p_source => p_rec.source5
	    ,p_source_type => p_rec.source5_type
	    ,p_effective_date => p_rec.transaction_effective_date
	    );

  -- Check the foriegn keys
  chk_assignment_id(p_assignment_id => p_rec.assignment_id
		   ,p_business_group_id => p_rec.business_group_id
		   ,p_effective_date => p_rec.transaction_effective_date
		   );

  chk_person_id(p_person_id => p_rec.person_id
	       ,p_business_group_id => p_rec.business_group_id
	       ,p_effective_date => p_rec.transaction_effective_date
		);

  --
  --
  pay_aud_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_aud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_aud_bus;

/
