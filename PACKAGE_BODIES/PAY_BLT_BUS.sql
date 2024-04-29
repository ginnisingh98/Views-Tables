--------------------------------------------------------
--  DDL for Package Body PAY_BLT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLT_BUS" as
/* $Header: pybltrhi.pkb 120.0.12010000.2 2008/10/16 09:57:17 asnell ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_blt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_balance_type_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_balance_type_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_balance_types blt
     where blt.balance_type_id = p_balance_type_id
       and pbg.business_group_id (+) = blt.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'balance_type_id'
    ,p_argument_value     => p_balance_type_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'BALANCE_TYPE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_balance_type_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_balance_types blt
     where blt.balance_type_id = p_balance_type_id
       and pbg.business_group_id (+) = blt.business_group_id;
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
    ,p_argument           => 'balance_type_id'
    ,p_argument_value     => p_balance_type_id
    );
  --
  if ( nvl(pay_blt_bus.g_balance_type_id, hr_api.g_number)
       = p_balance_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_blt_bus.g_legislation_code;
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
    pay_blt_bus.g_balance_type_id             := p_balance_type_id;
    pay_blt_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in pay_blt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.balance_type_id is not null)  and (
    nvl(pay_blt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_blt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.balance_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_BALANCE_TYPES'
      ,p_attribute_category              =>  p_rec.ATTRIBUTE_CATEGORY
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assignment_remuneration_fg >----------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_assignment_remuneration_fg
  (p_assignment_remuneration_flag   in varchar2
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  )  is
--
  l_proc        varchar2(72) := g_package||'chk_assignment_remuneration_fg';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  if p_assignment_remuneration_flag = 'Y' then
     pay_balance_types_pkg.chk_balance_type
         ( p_row_id            => null,
           p_business_group_id => p_business_group_id,
           p_legislation_code  => nvl(p_legislation_code,
                      hr_api.return_legislation_code(p_business_group_id)),
           p_balance_name      => null,
           p_reporting_name    => null,
           p_assignment_remuneration_flag =>p_assignment_remuneration_flag
	 );
  end if;
	    --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_currency_code >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_currency_code
  (p_effective_date  	   in date
  ,p_business_group_id     in number
  ,p_legislation_code      in varchar2
  ,p_balance_uom           in varchar2
  ,p_currency_code         in varchar2
  ) is
--
  l_proc                  varchar2(72) := g_package||'chk_currency_code';
  l_exists	          varchar2(1);

  Cursor c_chk_currency
  is
  -- bug 7462502 in startup mode remove restriction on enabled currencies
    select '1'
      from fnd_currencies
     where currency_code = p_currency_code
       and ( ( enabled_flag = 'Y') or
             ( hr_startup_data_api_support.g_startup_mode IN ('STARTUP') ))
       and currency_flag = 'Y'
       and p_effective_date between nvl(start_date_active,p_effective_date)
       and nvl(end_date_active,p_effective_date);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_balance_uom <> 'M' and p_currency_code is not null) then
      fnd_message.set_name('PAY','PAY_34193_UOM_NOT_MONEY');
      fnd_message.raise_error;
  elsIf p_currency_code is not null then
    --
    Open c_chk_currency;
    Fetch c_chk_currency into l_exists;
    If c_chk_currency%notfound Then
    --
      Close c_chk_currency;
      fnd_message.set_name('PAY','HR_51855_QUA_CCY_INV');
      fnd_message.raise_error;
    End if;
    --
    Close c_chk_currency;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_name >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_balance_name
  (p_business_group_id         in number
  ,p_legislation_code          in varchar2
  ,p_balance_type_id           in number
  ,p_balance_name              in varchar2
  ,p_balance_name_warning      out nocopy number
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_balance_name';
  l_exists       varchar2(1);
  l_dbi_exists   varchar2(1);
--
  cursor chk_source_lang is
    select '1'
      from pay_balance_types_tl
     where balance_type_id = p_balance_type_id
       and source_lang <> userenv('LANG');

  cursor chk_db_items is
    select '1'
      from ff_user_entities uet,
           pay_defined_balances dfb
     where uet.creator_id = dfb.defined_balance_id
       and uet.creator_type = 'B'
       and dfb.balance_type_id = p_balance_type_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_balance_types_pkg.chk_balance_type
       (null,
        p_business_group_id,
        p_legislation_code,
        p_balance_name,
        null,
        null);
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if( p_balance_name <> nvl(pay_blt_shd.g_old_rec.balance_name,p_balance_name)) then
     --
     -- Check db items exist for this balance
     --
     open chk_db_items;
     fetch chk_db_items into l_dbi_exists;
     close chk_db_items;
     --
       hr_utility.set_location('Entering:'||l_proc, 15);
     --
     if l_dbi_exists is null then
         -- if database item does not exist
          p_balance_name_warning := 1;
     else
     --
     -- Check between source and env languages for update operations
     -- against the base table
     --
        open chk_source_lang;
        fetch chk_source_lang into l_exists;
        close chk_source_lang;
     --
        if l_exists is null then
          -- fnd_message.set_name ('PAY', 'PAY_34172_BAL_DBI_UPD');
   	  p_balance_name_warning := 2;
        else
          -- fnd_message.set_name('PAY','PAY_34173_BASE_TBL_UPD');
          p_balance_name_warning := 3;
        end if;
     --
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_uom >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_balance_uom
  (p_effective_date  	   in date
  ,p_balance_uom           in varchar2
  ,p_assignment_remuneration_flag in varchar2
  ,p_balance_type_id       in number
  ,p_object_version_number in number
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_balance_uom';
  l_exists	      varchar2(1);
  l_class_exists      varchar2(1);

  Cursor c_chk_balance_uom
  is
    select '1'
      from hr_lookups hl
     where hl.lookup_type = 'UNITS' and
       (hl.lookup_code in ('M','I','N','ND') or hl.lookup_code like 'H%') and
        hl.enabled_flag = 'Y' and
        hl.lookup_code = p_balance_uom and
        p_effective_date between nvl(hl.start_date_active,p_effective_date) and
        nvl(hl.end_date_active,p_effective_date);

  Cursor c_chk_balance_uom_class(p_balance_uom_old varchar2)
  is
    select '1'
      from hr_lookups hl
     where hl.lookup_type = 'UNITS' and
           hl.lookup_code = p_balance_uom and
           substr(hl.lookup_code,1,1) = substr(p_balance_uom_old,1,1) and
           hl.enabled_flag = 'Y' and
           p_effective_date between nvl(hl.start_date_active,p_effective_date) and
           nvl(hl.end_date_active,p_effective_date);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_assignment_remuneration_flag = 'Y' and p_balance_uom <> 'M') then
      fnd_message.set_name('PAY','PAY_34194_UOM_MUST_BE_MONEY');
      fnd_message.raise_error;
  elsif((pay_blt_shd.api_updating
            (p_balance_type_id => p_balance_type_id
            ,p_object_version_number  => p_object_version_number)) and
    nvl(p_balance_uom,hr_api.g_varchar2) <>
    nvl(pay_blt_shd.g_old_rec.balance_uom,hr_api.g_varchar2)) then
    --
    hr_utility.set_location('Entering:'||l_proc|| ' new :'||p_balance_uom||' old '||pay_blt_shd.g_old_rec.balance_uom, 10);
    --
    Open c_chk_balance_uom_class(pay_blt_shd.g_old_rec.balance_uom);
    Fetch c_chk_balance_uom_class into l_class_exists;
    If c_chk_balance_uom_class%notfound Then
    --
      Close c_chk_balance_uom_class;
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'BALANCE_UOM');
      fnd_message.raise_error;
    --
    End If;
    Close c_chk_balance_uom_class;
    --
  else
    --
    hr_utility.set_location('Entering:'||l_proc, 15);
    --
    Open c_chk_balance_uom;
    Fetch c_chk_balance_uom into l_exists;
    If c_chk_balance_uom%notfound Then
    --
      Close c_chk_balance_uom;
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'BALANCE_UOM');
      fnd_message.raise_error;
    --
     End If;
    Close c_chk_balance_uom;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
End;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_reporting_name >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_reporting_name
  (p_business_group_id         in number
  ,p_legislation_code          in varchar2
  ,p_reporting_name            in varchar2
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_reporting_name';
  l_exists       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_balance_types_pkg.chk_balance_type
       (null,
        p_business_group_id,
        p_legislation_code,
        null,
        p_reporting_name,
        null);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_balance_category_id >---------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_balance_category_id
  (p_effective_date  	          in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_balance_category_id          in number
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_balance_category_id';
  l_exists	      varchar2(1);

  Cursor c_chk_balance_category
  is
   select '1'
     from pay_balance_categories_f
    where balance_category_id = p_balance_category_id
       and  nvl(legislation_code,
         nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
       nvl(p_legislation_code,nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))
      and p_effective_date between effective_start_date
                                     and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_balance_category_id is null and
     pay_balance_types_pkg.chk_balance_category_rule(
        nvl(p_legislation_code,hr_api.return_legislation_code(p_business_group_id)))) then
     hr_api.mandatory_arg_error
     (p_api_name                     => l_proc
     ,p_argument                     => 'balance_category_id'
     ,p_argument_value               => p_balance_category_id
    );
  end if;
   --
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
   Open c_chk_balance_category;
   Fetch c_chk_balance_category into l_exists;
   If c_chk_balance_category%notfound Then
    --
      Close c_chk_balance_category;
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'BALANCE_CATEGORY_ID');
      fnd_message.raise_error;
    --
   End If;
    Close c_chk_balance_category;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_base_balance_type_id >---------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_base_balance_type_id
  (p_effective_date  	          in date
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_base_balance_type_id         in number
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_base_balance_type_id';
  l_exists	      varchar2(1);

  Cursor c_chk_base_balance
  is
   select '1'
     from  pay_balance_types
    where  base_balance_type_id is null
      and  balance_type_id = p_base_balance_type_id
      and    ((p_business_group_id is not null
      and    nvl(business_group_id,-1) = p_business_group_id
       or     nvl(legislation_code,nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
                    nvl(p_legislation_code,nvl(hr_api.return_legislation_code(p_business_group_id),'~~nvl~~')))
       or     (p_legislation_code is not null
      and    nvl(legislation_code,' ') = p_legislation_code
       or     business_group_id is not null
      and    legislation_code = p_legislation_code)
       or     business_group_id is null
      and    legislation_code is null)	;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   Open c_chk_base_balance;
   Fetch c_chk_base_balance into l_exists;
   If c_chk_base_balance%notfound Then
    --
      Close c_chk_base_balance;
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'BASE_BALANCE_TYPE_ID'||p_base_balance_type_id||'value unknown');
      fnd_message.raise_error;
    --
     End If;
    Close c_chk_base_balance;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_input_value_id >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_input_value_id
  (p_effective_date  	    in date
  ,p_input_value_id         in number
  ,p_balance_uom            in varchar2
  ,p_balance_type_id        in number
  ) is
--
  l_proc              varchar2(72) := g_package||'chk_input_value_id';
  l_exists	      varchar2(1);

  Cursor c_chk_input_value
  is
    select '1'
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and uom = p_balance_uom
       and p_effective_date between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   Open c_chk_input_value;
   Fetch c_chk_input_value into l_exists;
   If c_chk_input_value%notfound Then
    --
      Close c_chk_input_value;
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'INPUT_VALUE_ID');
      fnd_message.raise_error;
    --
   End If;
   Close c_chk_input_value;
  --
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --
  -- INPUT_VALUE_ID can be updated only if its value is null and there is
  -- no balance feed exist except initial feed or there is no balance
  -- classification exists.
  --
  If(p_input_value_id is not null and
    nvl(p_input_value_id,hr_api.g_number) <>
     nvl(pay_blt_shd.g_old_rec.input_value_id,hr_api.g_number)) then
     --

     if (hr_balance_feeds.manual_bal_feeds_exist(p_balance_type_id) or
        hr_balance_feeds.bal_classifications_exist(p_balance_type_id)) then
     --
        fnd_message.set_name('PAY','PAY_34195_FEED_OR_CLASS_EXIST');
        fnd_message.raise_error;
     end if;
    --
  End if;


  hr_utility.set_location('Leaving:'||l_proc, 10);
End;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< recreate_db_items >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE recreate_db_items(p_balance_type_id in number) is
  cursor get_defined_balances is
    select defined_balance_id,
           balance_dimension_id,
           business_group_id,
           legislation_code
      from pay_defined_balances dfb
     where dfb.balance_type_id = p_balance_type_id;
  --
  l_exists varchar2(1);
  --
  BEGIN
    --
      for l_dfb in get_defined_balances loop
        hrdyndbi.recreate_defined_balance
          (p_defined_balance_id   => l_dfb.defined_balance_id,
           p_balance_dimension_id => l_dfb.balance_dimension_id,
           p_balance_type_id      => p_balance_type_id,
           p_business_group_id    => l_dfb.business_group_id,
           p_legislation_code     => l_dfb.legislation_code);
       end loop;
    --
  END recreate_db_items;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_primary_balance_feed >-----------------|
-- ----------------------------------------------------------------------------
--
procedure insert_primary_balance_feed
   ( p_effective_date       in date
    ,p_business_group_id    in number
    ,p_balance_type_id      in number
    ,p_input_value_id       in number
   ) is
  --
  l_proc   varchar2(72) := g_package||'insert_primary_balance_feed';
  l_exists number;

  cursor feed_exists
  is
  select null
  from   pay_balance_feeds_f pbf
  where  pbf.balance_type_id = p_balance_type_id
  and    pbf.input_value_id  = p_input_value_id
  and    nvl(pbf.business_group_id, -1) = nvl(p_business_group_id, -1)
  and    nvl(pbf.legislation_code, 'NULL') =
         nvl(hr_api.return_legislation_code(p_business_group_id), 'NULL')
  and    p_effective_date between pbf.effective_start_date
                                       and pbf.effective_end_date;


  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    open  feed_exists;
    fetch feed_exists into l_exists;
    if feed_exists%notfound then
      close feed_exists;
      --
      hr_utility.set_location('Entering:'||l_proc, 10);
      --
      hr_balances.ins_balance_feed
        (p_option                     => 'INS_PRIMARY_BALANCE_FEED'
        ,p_input_value_id             => p_input_value_id
        ,p_element_type_id            => null
        ,p_primary_classification_id  => ''
        ,p_sub_classification_id      => ''
        ,p_sub_classification_rule_id => ''
        ,p_balance_type_id            => p_balance_type_id
        ,p_scale                      => 1
        ,p_session_date               => p_effective_date
        ,p_business_group             => p_business_group_id
        ,p_legislation_code
	             => hr_api.return_legislation_code(p_business_group_id)
        ,p_mode
	             => hr_startup_data_api_support.g_startup_mode
        );
    else
      close feed_exists;
    end if;
    --
    hr_utility.set_location('Leaving:'||l_proc, 15);
    --
  END Insert_primary_balance_feed;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is used to validate the legislation code against the
--   parent table
--
-- ----------------------------------------------------------------------------
Procedure chk_legislation_code
  (p_legislation_code  in varchar2)
  is
--
  l_proc        varchar2(72) := g_package||'chk_legislation_code';
  l_exists varchar2(1);

  Cursor c_chk_leg_code
  is
    select null
      from fnd_territories
     where territory_code = p_legislation_code;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_legislation_code is not null then

    Open c_chk_leg_code;
    Fetch c_chk_leg_code into l_exists;
    If c_chk_leg_code%notfound Then
      --
      Close c_chk_leg_code;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','LEGISLATION_CODE');
      fnd_message.set_token('TABLE','FND_TERRITORIES');
      fnd_message.raise_error;
      --
    End If;
    Close c_chk_leg_code;

  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
End;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in pay_blt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_argument varchar2(80);
  l_error    exception;
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_blt_shd.api_updating
      (p_balance_type_id                   => p_rec.balance_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
   hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Ensure that the following attributes are not updated.
  --
  If nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(pay_blt_shd.g_old_rec.business_group_id,hr_api.g_number) then
    --
    l_argument := 'business_group_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  --
  If nvl(p_rec.legislation_code,hr_api.g_varchar2) <>
     nvl(pay_blt_shd.g_old_rec.legislation_code,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_code';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
  If nvl(p_rec.balance_type_id,hr_api.g_number) <>
     nvl(pay_blt_shd.g_old_rec.balance_type_id,hr_api.g_number) then
    --
    l_argument := 'balance_type_id';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Entering:'||l_proc, 25);
  -- balance category can be updated only if it is null
  --
  If(pay_blt_shd.g_old_rec.balance_category_id is not null and
    nvl(p_rec.balance_category_id,hr_api.g_number) <>
     nvl(pay_blt_shd.g_old_rec.balance_category_id,hr_api.g_number)) then
    --
    l_argument := 'balance_category_id';
    raise l_error;
    --
  End if;
  --
   hr_utility.set_location('Entering:'||l_proc, 30);
  -- jurisdiction_level can not be updated
  --
  If nvl(p_rec.jurisdiction_level,hr_api.g_number) <>
     nvl(pay_blt_shd.g_old_rec.jurisdiction_level,hr_api.g_number) then
    --
    l_argument := 'jurisdiction_level';
    raise l_error;
    --
  End if;
  --
     hr_utility.set_location('Entering:'||l_proc, 35);
  -- Tax_Type can not be updated
  --
  If nvl(p_rec.tax_type,hr_api.g_varchar2) <>
     nvl(pay_blt_shd.g_old_rec.tax_type,hr_api.g_varchar2) then
    --
    l_argument := 'tax_type';
    raise l_error;
    --
  End if;
  --
   --
  hr_utility.set_location('Entering:'||l_proc, 45);
  --
  If nvl(p_rec.legislation_subgroup,hr_api.g_varchar2) <>
     nvl(pay_blt_shd.g_old_rec.legislation_subgroup,hr_api.g_varchar2) then
    --
    l_argument := 'legislation_subgroup';
    raise l_error;
    --
  End if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 50);
EXCEPTION
  WHEN l_error THEN
      hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
  WHEN OTHERS THEN
      RAISE;
  --
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => FALSE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => FALSE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_blt_shd.g_rec_type
  ) is
--
  l_proc                    varchar2(72) := g_package||'insert_validate';
  l_balance_name_warning    number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_blt_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  -- ----------------------------------------------------------------------------
  IF hr_startup_data_api_support.g_startup_mode
                     IN ('STARTUP') THEN

   chk_legislation_code
       (p_legislation_code    => p_rec.legislation_code);
  End if;
  --
  -- ----------------------------------------------------------------------------
  --
  chk_assignment_remuneration_fg
  (p_assignment_remuneration_flag   => p_rec.assignment_remuneration_flag
  ,p_business_group_id              => p_rec.business_group_id
  ,p_legislation_code               => p_rec.legislation_code
  );
  -- ----------------------------------------------------------------------------
  --
  chk_currency_code
  (p_effective_date  	   => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  ,p_balance_uom           => p_rec.balance_uom
  ,p_currency_code         => p_rec.currency_code
  );

  -- ----------------------------------------------------------------------------

 chk_balance_name
  (p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  ,p_balance_type_id       => p_rec.balance_type_id
  ,p_balance_name          => p_rec.balance_name
  ,p_balance_name_warning  => l_balance_name_warning
  );

  -- ----------------------------------------------------------------------------

 chk_balance_uom
  (p_effective_date  	           => p_effective_date
  ,p_balance_uom                   => p_rec.balance_uom
  ,p_assignment_remuneration_flag  => p_rec.assignment_remuneration_flag
  ,p_balance_type_id               => p_rec.balance_type_id
  ,p_object_version_number         => p_rec.object_version_number
  );
  -- ----------------------------------------------------------------------------
  if p_rec.reporting_name is not null then
     chk_reporting_name
     (p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_reporting_name        => p_rec.reporting_name
     );
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.balance_category_id is not null then
     chk_balance_category_id
     (p_effective_date        => p_effective_date
     ,p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_balance_category_id   => p_rec.balance_category_id
     );
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.base_balance_type_id is not null then
     chk_base_balance_type_id
     (p_effective_date        => p_effective_date
     ,p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_base_balance_type_id  => p_rec.base_balance_type_id
     ) ;
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.input_value_id is not null then
     chk_input_value_id
     (p_effective_date         => p_effective_date
     ,p_input_value_id         => p_rec.input_Value_id
     ,p_balance_uom            => p_rec.balance_uom
     ,p_balance_type_id        => p_rec.balance_type_id
     );
  end if;

  pay_blt_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_blt_shd.g_rec_type
  ,p_balance_name_warning         out nocopy number

  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_balance_name_warning    number;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_blt_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  -- ----------------------------------------------------------------------------
  --
  chk_assignment_remuneration_fg
  (p_assignment_remuneration_flag   => p_rec.assignment_remuneration_flag
  ,p_business_group_id              => p_rec.business_group_id
  ,p_legislation_code               => p_rec.legislation_code
  );
  -- ----------------------------------------------------------------------------
  --
  chk_currency_code
  (p_effective_date  	   => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => p_rec.legislation_code
  ,p_balance_uom           => p_rec.balance_uom
  ,p_currency_code         => p_rec.currency_code
  );

  -- ----------------------------------------------------------------------------
  if nvl(p_rec.balance_name,hr_api.g_varchar2) <>
       nvl(pay_blt_shd.g_old_rec.balance_name,hr_api.g_varchar2) then
     chk_balance_name
     (p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_balance_type_id       => p_rec.balance_type_id
     ,p_balance_name          => p_rec.balance_name
     ,p_balance_name_warning  => l_balance_name_warning
     );
      p_balance_name_warning := l_balance_name_warning;
  end if;


  -- ----------------------------------------------------------------------------

  chk_balance_uom
  (p_effective_date  	           => p_effective_date
  ,p_balance_uom                   => p_rec.balance_uom
  ,p_assignment_remuneration_flag  => p_rec.assignment_remuneration_flag
  ,p_balance_type_id               => p_rec.balance_type_id
  ,p_object_version_number         => p_rec.object_version_number
  );
  -- ----------------------------------------------------------------------------

  if (p_rec.reporting_name is not null  and
      nvl(p_rec.reporting_name,hr_api.g_varchar2) <>
           nvl(pay_blt_shd.g_old_rec.reporting_name,hr_api.g_varchar2)) then
     chk_reporting_name
     (p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_reporting_name        => p_rec.reporting_name
     );
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.balance_category_id is not null then
     chk_balance_category_id
     (p_effective_date        => p_effective_date
     ,p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_balance_category_id   => p_rec.balance_category_id
     );
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.base_balance_type_id is not null then
     chk_base_balance_type_id
     (p_effective_date        => p_effective_date
     ,p_business_group_id     => p_rec.business_group_id
     ,p_legislation_code      => p_rec.legislation_code
     ,p_base_balance_type_id  => p_rec.base_balance_type_id
     ) ;
  end if;
  -- ----------------------------------------------------------------------------
  if p_rec.input_value_id is not null then
     chk_input_value_id
     (p_effective_date         => p_effective_date
     ,p_input_value_id         => p_rec.input_Value_id
     ,p_balance_uom            => p_rec.balance_uom
     ,p_balance_type_id        => p_rec.balance_type_id
     );
  end if;
-- ----------------------------------------------------------------------------

  --
  pay_blt_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_blt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pay_blt_shd.g_old_rec.business_group_id
                    ,pay_blt_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_blt_bus;

/
