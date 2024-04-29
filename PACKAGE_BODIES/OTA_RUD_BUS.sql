--------------------------------------------------------
--  DDL for Package Body OTA_RUD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RUD_BUS" as
/* $Header: otrudrhi.pkb 120.2 2005/09/08 06:34:32 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_rud_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_resource_usage_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_resource_usage_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_resource_usages rud
         , ota_offerings off
     where rud.resource_usage_id = p_resource_usage_id
      and rud.offering_id = off.offering_id
      and pbg.business_group_id = off.business_group_id;
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
    ,p_argument           => 'resource_usage_id'
    ,p_argument_value     => p_resource_usage_id
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
        => nvl(p_associated_column1,'RESOURCE_USAGE_ID')
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
  (p_resource_usage_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_resource_usages rud
         , ota_suppliable_resources tsr
     where rud.resource_usage_id = p_resource_usage_id
      and rud.supplied_resource_id = tsr.supplied_Resource_id
      and pbg.business_group_id = tsr.business_group_id;
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
    ,p_argument           => 'resource_usage_id'
    ,p_argument_value     => p_resource_usage_id
    );
  --
  if ( nvl(ota_rud_bus.g_resource_usage_id, hr_api.g_number)
       = p_resource_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_rud_bus.g_legislation_code;
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
    ota_rud_bus.g_resource_usage_id           := p_resource_usage_id;
    ota_rud_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< check_unique_key >----------------------------|
-- ----------------------------------------------------------------------------
--
--	A specific resource cannot be entered against the same course
--      more than once.
--
procedure check_unique_key
  (p_supplied_resource_id               in number
  ,p_offering_id                in number
  ) is
  --
  l_proc       varchar2 (72)  := g_package || 'check_unique_key';
  l_ok         varchar2 (3);
  --
  cursor c1 is
    select 'No'
      from ota_resource_usages                  rud
      where rud.supplied_resource_id          = p_supplied_resource_id
        and rud.offering_id           = p_offering_id;
  --
begin
  --
  hr_utility.set_location ('Entering:' || l_proc, 5);
  --
  open c1;
  fetch c1
    into l_ok;
  if (c1%found) then
    ota_rud_shd.constraint_error ('OTA_RESOURCE_USAGES_PK');
  end if;
  close c1;
  --
  hr_utility.set_location (' leaving:' || l_proc, 10);
  --
end check_unique_key;
--
-- ----------------------------------------------------------------------------
-- --------------------------< check_start_end_dates >------------------------|
-- ----------------------------------------------------------------------------
--
--	The start date must be less than, or equal to, the end date.
--
procedure check_start_end_dates
  (
  p_start_date                in               date
  ,p_end_date                 in               date
  ) is
  --
  l_proc       varchar2 (72)  := g_package || 'check_start_end_dates';
  --
  --
begin
  --
  hr_utility.set_location ('entering:' || l_proc, 5);
  --
  if (p_start_date
        > nvl (p_end_date, to_date ('31-12-4712', 'DD-MM-YYYY'))) then
    ota_rud_shd.constraint_error ('OTA_RUD_DATES');
  end if;
  --
  hr_utility.set_location (' leaving:' || l_proc, 5);
--
end check_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- --------------------------------< check_off >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_off
  (p_offering_id      in       number
  ,p_start_date               in       date
  ,p_end_date                 in       date
  ) is
  --
  l_proc                    varchar2 (72)  :=   g_package || 'check_off';
  l_off_start_date          date;
  l_off_end_date            date;
  --
  cursor c1 is
	select
	   off.start_date
	  ,off.end_date
	from
	  ota_offerings  off
	where
	  off.offering_id = p_offering_id;
  --
begin
	--
	hr_utility.set_location ('Entering:' || l_proc, 5);
	--
	--	valid Offering ?
	--
	open c1;
	fetch c1
	  into l_off_start_date,
	       l_off_end_date;
	if (c1%notfound) then
		ota_rud_shd.constraint_error ('OTA_RESOURCE_USAGES_FK2');
	end if;
	close c1;
	--
	--	Start date in range ?
	--
	if (p_start_date
		not between l_off_start_date
                        and nvl (l_off_end_date, hr_general.end_of_time)) then
		ota_rud_shd.constraint_error ('OTA_RUD_TAV_DATES');
	end if;
	--
	--	End date in range ?
	--
	if (    (p_end_date is not null)
	    and (p_end_date
                not between l_off_start_date
                        and nvl (l_off_end_date, hr_general.end_of_time))) then
		ota_rud_shd.constraint_error ('OTA_RUD_TAV_DATES');
	end if;
	--
	hr_utility.set_location (' leaving:' || l_proc, 5);
	--
end check_off;
--
-- ----------------------------------------------------------------------------
-- --------------------------------< check_tsr >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_tsr
  (p_supplied_resource_id          in       number
  ,p_start_date                    in       date
  ,p_end_date                      in       date
  ) is
--
  --
  l_proc                    varchar2 (72)  :=   g_package || 'check_tsr';
  l_tsr_start_date          date;
  l_tsr_end_date            date;
  --
  cursor c1 is
    select tsr.start_date,
           tsr.end_date
      from ota_suppliable_resources		tsr
      where tsr.supplied_resource_id	      =	p_supplied_resource_id;
  --
begin
	--
	hr_utility.set_location ('Entering:' || l_proc, 5);
	--
	--	valid resource ?
	--
	open c1;
	fetch c1
	  into l_tsr_start_date,
	       l_tsr_end_date;
	 if (c1%notfound) then
		ota_rud_shd.constraint_error ('OTA_RESOURCE_USAGES_FK1');
	end if;
	close c1;
	--
	--	Start date in range ?
	--
	if (p_start_date
		 not between l_tsr_start_date
		         and nvl (l_tsr_end_date, hr_general.end_of_time)) then
		ota_rud_shd.constraint_error ('OTA_RUD_TSR_DATES');
        end if;
	--
	--	End date in range ?
	--
	if (    (p_end_date is not null)
	    and (p_end_date
                 not between l_tsr_start_date
                         and nvl (l_tsr_end_date, hr_general.end_of_time))) then
		ota_rud_shd.constraint_error ('OTA_RUD_TSR_DATES');
	end if;
	--
	hr_utility.set_location (' leaving:' || l_proc, 10);
  --
end check_tsr;
--
-- ----------------------------------------------------------------------------
-- -----------------------< check_off_tsr_bus_grp >---------------------------|
-- ----------------------------------------------------------------------------
--
--	The business group of the suppliable resource (if entered) and the
--	offering must be the same.
--
procedure check_off_tsr_bus_grp
  (p_supplied_resource_id                in      number
  ,p_offering_id                 in      number
  ) is
  --
  l_proc          varchar2 (72)  :=   g_package || 'check_off_tsr_bus_grp';
  l_ok            varchar2 (3);
  --
  cursor c1 is
	select 'YES'
	  from ota_suppliable_resources		tsr,
	       ota_offerings            	off
	    where tsr.supplied_resource_id    =	p_supplied_resource_id
	    and off.offering_id	              =	p_offering_id
	    and tsr.business_group_id	      =	off.business_group_id;
  --
begin
	--
	hr_utility.set_location ('Entering:' || l_proc, 5);
	--
	open c1;
	fetch c1
	  into l_ok;
	if (c1%notfound) then
		close c1;
		ota_rud_shd.constraint_error ('OTA_RUD_BUSINESS_GROUPS');
	end if;
	close c1;
	--
	hr_utility.set_location (' Leaving:' || l_proc, 10);
  --
end check_off_tsr_bus_grp;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< check_resource_type >-------------------------|
-- ----------------------------------------------------------------------------
--
--      The resource type must be in the domain 'RESOURCE_TYPE'.
--
procedure check_resource_type
  (p_resource_type             in            varchar2
  ) is
--
  l_proc          varchar2 (72)  :=   g_package || 'check_resource_type';
  --
begin
  --
  hr_utility.set_location ('Entering:' || l_proc, 5);
  --
  ota_general.check_domain_value ('RESOURCE_TYPE', p_resource_type);
  --
  hr_utility.set_location (' Leaving:' || l_proc, 10);
  --
end check_resource_type;
--
-- ----------------------------------------------------------------------------
-- --------------------------------< Check_role >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Check_role
  (p_role_to_play             in          varchar2
  ,p_resource_type            in          varchar2
  ,p_supplied_resource_id     in          number
  ) is
  --
  l_proc       varchar2 (72) := g_package || 'Check_role';
  l_res_type   varchar2(30);
  --
  Cursor cur_res_type is
    select
      tsr.resource_type
    from
      ota_suppliable_resources tsr
    where
      tsr.supplied_resource_id = p_supplied_resource_id;

Begin
  --
  hr_utility.set_location ('Entering' || l_proc, 10);
  --
  If p_role_to_play is not null then
    If p_resource_type is not null and p_resource_type <> 'T' then
      ota_rud_shd.constraint_error ('OTA_RUD_RESOURCE_ROLE');
    Else
      --
      open cur_res_type;
      fetch cur_res_type into l_res_type;
      close cur_res_type;
      --
      If l_res_type is not null and l_res_type <> 'T' then
        ota_rud_shd.constraint_error ('OTA_RUD_RESOURCE_ROLE');
      End If;
      --
    End If;
    --
    ota_general.check_domain_value ('TRAINER_PARTICIPATION', p_role_to_play);
    --
  End If;
  hr_utility.set_location (' Leaving:' || l_proc, 10);
  --
End Check_role;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< check_usage_reason >------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_usage_reason
  (p_usage_reason           in          varchar2
  ) is
  --
  l_proc       varchar2 (72) := g_package || 'check_usage_reason';
  --
begin
  --
  hr_utility.set_location ('Entering' || l_proc, 10);
  --
  ota_general.check_domain_value ('RESOURCE_USAGE_REASON', p_usage_reason);
  --
  hr_utility.set_location (' Leaving:' || l_proc, 10);
  --
end check_usage_reason;
--
-- ----------------------------------------------------------------------------
-- ------------------------------< check_quantity >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_quantity
  (p_resource_type                  in     varchar2
  ,p_quantity                       in     number
  ) is
  --
  l_proc       varchar2 (72) := g_package || 'check_quantity';
  --
begin
  --
  hr_utility.set_location ('Entering' || l_proc, 10);
  --
  If p_resource_type = 'V' or p_resource_type = 'T' Then
   --
    If p_quantity is null or p_quantity <> 1 Then
      --
      fnd_message.set_name      ( 'OTA', 'OTA_13265_TRB_QUANTITY_ENTERED');
      fnd_message.raise_error;
      --
    End If;
  ElsIf p_quantity < 1 Then
    --
    fnd_message.set_name      ( 'OTA', 'OTA_443369_POSITIVE_WHL_NUMBER');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location ('Leaving:' || l_proc, 20);
  --
Exception
  --
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1   => 'OTA_RESOURCE_USAGES.QUANTITY'
       )
    Then
      --
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
      --
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end check_quantity;

--
-- ----------------------------------------------------------------------------
-- ------------------------------< validity_checks >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure validity_checks
  (p_rec                          in        ota_rud_shd.g_rec_type
  ) is
  --
  l_proc       varchar2 (72) := g_package || 'check_usage_reason';
  l_resource_type ota_suppliable_resources.resource_type%Type;
  --
  Cursor Get_Resource_type is
    select resource_type
    from ota_suppliable_resources
    where supplied_resource_id = p_rec.supplied_resource_id;
  --
begin
  --
  hr_utility.set_location ('Entering' || l_proc, 10);
  --
  check_start_end_dates
  (p_start_date                =>    p_rec.start_date
  ,p_end_date                  =>    p_rec.end_date
  );
  --
  check_off
  (p_offering_id               =>    p_rec.offering_id
  ,p_start_date                =>    p_rec.start_date
  ,p_end_date                  =>    p_rec.end_date
  );
  --
  l_resource_type := p_rec.resource_type;
  --
  -- Get the resource_type using supplied_resource_id if resource_type is null
  --
  If l_resource_type is null Then
    --
    Open Get_Resource_type;
    Fetch Get_Resource_type into l_resource_type;
    Close Get_Resource_type;
    --
  End if;
  --
  check_quantity
  (p_resource_type             =>    l_resource_type
  ,p_quantity                  =>    p_rec.quantity
  );
  --
  --  specified resource ?
  --
  if (p_rec.supplied_resource_id is not null) then
    if (p_rec.resource_type is not null) then
      ota_rud_shd.constraint_error ('OTA_RUD_EXCLUSIVITY');
    end if;
    --
    check_tsr
    (p_supplied_resource_id   =>    p_rec.supplied_resource_id
    ,p_start_date             =>    p_rec.start_date
    ,p_end_date               =>    p_rec.end_date
    );
    --
    check_off_tsr_bus_grp
    (p_offering_id    =>    p_rec.offering_id
    ,p_supplied_resource_id   =>    p_rec.supplied_resource_id
    );
  --
  --  Type of resource ?
  --
  elsif (p_rec.resource_type is not null) then
    if (p_rec.supplied_resource_id is not null) then
      ota_rud_shd.constraint_error ('OTA_RUD_EXCLUSIVITY');
    end if;
    --
    check_resource_type
    (p_resource_type          =>    p_rec.resource_type
    );
    --
  else
    ota_rud_shd.constraint_error ('OTA_RUD_EXCLUSIVITY');
  end if;
  --
  check_role
  (p_role_to_play           =>      p_rec.role_to_play
  ,p_resource_type          =>      p_rec.resource_type
  ,p_supplied_resource_id   =>      p_rec.supplied_resource_id
  );
  --
  --  Required ?
  --
  if (p_rec.required_flag not in ('Y', 'N')) then
    ota_rud_shd.constraint_error ('OTA_RUD_REQUIRED');
  end if;
  --
  --  Reason
  --
  check_usage_reason
  (p_usage_reason           =>     p_rec.usage_reason
  );
  --
  hr_utility.set_location (' Leaving:' || l_proc, 10);
  --
end validity_checks;
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
  (p_rec in ota_rud_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.resource_usage_id is not null)  and (
    nvl(ota_rud_shd.g_old_rec.rud_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information_category, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information1, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information1, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information2, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information2, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information3, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information3, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information4, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information4, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information5, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information5, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information6, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information6, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information7, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information7, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information8, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information8, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information9, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information9, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information10, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information10, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information11, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information11, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information12, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information12, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information13, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information13, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information14, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information14, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information15, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information15, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information16, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information16, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information17, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information17, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information18, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information18, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information19, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information19, hr_api.g_varchar2)  or
    nvl(ota_rud_shd.g_old_rec.rud_information20, hr_api.g_varchar2) <>
    nvl(p_rec.rud_information20, hr_api.g_varchar2) ))
    or (p_rec.resource_usage_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_RESOURCE_USAGES'
      ,p_attribute_category              => p_rec.rud_information_category
      ,p_attribute1_name                 => 'RUD_INFORMATION1'
      ,p_attribute1_value                => p_rec.rud_information1
      ,p_attribute2_name                 => 'RUD_INFORMATION2'
      ,p_attribute2_value                => p_rec.rud_information2
      ,p_attribute3_name                 => 'RUD_INFORMATION3'
      ,p_attribute3_value                => p_rec.rud_information3
      ,p_attribute4_name                 => 'RUD_INFORMATION4'
      ,p_attribute4_value                => p_rec.rud_information4
      ,p_attribute5_name                 => 'RUD_INFORMATION5'
      ,p_attribute5_value                => p_rec.rud_information5
      ,p_attribute6_name                 => 'RUD_INFORMATION6'
      ,p_attribute6_value                => p_rec.rud_information6
      ,p_attribute7_name                 => 'RUD_INFORMATION7'
      ,p_attribute7_value                => p_rec.rud_information7
      ,p_attribute8_name                 => 'RUD_INFORMATION8'
      ,p_attribute8_value                => p_rec.rud_information8
      ,p_attribute9_name                 => 'RUD_INFORMATION9'
      ,p_attribute9_value                => p_rec.rud_information9
      ,p_attribute10_name                => 'RUD_INFORMATION10'
      ,p_attribute10_value               => p_rec.rud_information10
      ,p_attribute11_name                => 'RUD_INFORMATION11'
      ,p_attribute11_value               => p_rec.rud_information11
      ,p_attribute12_name                => 'RUD_INFORMATION12'
      ,p_attribute12_value               => p_rec.rud_information12
      ,p_attribute13_name                => 'RUD_INFORMATION13'
      ,p_attribute13_value               => p_rec.rud_information13
      ,p_attribute14_name                => 'RUD_INFORMATION14'
      ,p_attribute14_value               => p_rec.rud_information14
      ,p_attribute15_name                => 'RUD_INFORMATION15'
      ,p_attribute15_value               => p_rec.rud_information15
      ,p_attribute16_name                => 'RUD_INFORMATION16'
      ,p_attribute16_value               => p_rec.rud_information16
      ,p_attribute17_name                => 'RUD_INFORMATION17'
      ,p_attribute17_value               => p_rec.rud_information17
      ,p_attribute18_name                => 'RUD_INFORMATION18'
      ,p_attribute18_value               => p_rec.rud_information18
      ,p_attribute19_name                => 'RUD_INFORMATION19'
      ,p_attribute19_value               => p_rec.rud_information19
      ,p_attribute20_name                => 'RUD_INFORMATION20'
      ,p_attribute20_value               => p_rec.rud_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec in ota_rud_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_rud_shd.api_updating
      (p_resource_usage_id                 => p_rec.resource_usage_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  ota_off_bus.set_security_group_id(p_rec.offering_id);
  --
  CHECK_UNIQUE_KEY (
	P_SUPPLIED_RESOURCE_ID		     =>	P_REC.SUPPLIED_RESOURCE_ID,
	P_OFFERING_ID		     =>	P_REC.OFFERING_ID);
  --
  VALIDITY_CHECKS (
	P_REC				     => P_REC);
  -- Validate Dependent Attributes
  --
  --
  ota_rud_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_rud_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  ota_off_bus.set_security_group_id(p_rec.offering_id);
  --
  if (    (nvl (P_REC.SUPPLIED_RESOURCE_ID, 0)
		<> nvl (ota_rud_shd.g_old_rec.SUPPLIED_RESOURCE_ID, 0))
      or  (nvl (P_REC.OFFERING_ID,  0)
		<> nvl (ota_rud_shd.g_old_rec.OFFERING_ID,  0))) then
    ota_rud_shd.constraint_error ('OTA_RUD_NON_TRANSFER');
  end if;
  --
  VALIDITY_CHECKS (
        p_rec                                => p_rec);
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  ota_rud_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_rud_shd.g_rec_type
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
end ota_rud_bus;

/
