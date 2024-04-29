--------------------------------------------------------
--  DDL for Package Body PER_OSV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OSV_BUS" as
/* $Header: peosvrhi.pkb 120.0 2005/05/31 12:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_osv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_org_structure_version_id    number         default null;


--
--  ---------------------------------------------------------------------------
--  |----------------------< get_business_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure get_business_group_id
  (p_organization_structure_id             in number
  ,p_business_group_id                   out nocopy number
  ) is
  l_proc              varchar2(72)  :=  g_package||'get_business_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  select business_group_id
   into p_business_group_id
   from per_organization_structures
   where p_organization_structure_id = organization_structure_id;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
 when no_data_found then
   fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
   fnd_message.raise_error;
end get_business_group_id;


--
--  ---------------------------------------------------------------------------
--  |---------------------------< set_date_to >-------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_date_to
  (p_org_structure_version_id            in number,
   p_organization_structure_id           in number,
   p_date_from                           in date,
   p_end_date_closedown_warning          out nocopy boolean) is
  l_proc           VARCHAR2(72)  :=  g_package||'set_date_to';
begin
         --
         -- Close down the open structure versions
         --

        update per_org_structure_versions osv
         set osv.date_to = (p_date_from - 1)
         where osv.organization_structure_id = p_organization_Structure_Id
         and   osv.date_to is null
         and   osv.org_structure_version_id
               <> nvl(p_org_structure_version_id,-1);

        p_end_date_closedown_warning := (sql%rowcount >0);



end;

--  ---------------------------------------------------------------------------
--  |----------------------------< chk_y_or_n>--------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_y_or_n
   (p_effective_date     in date
   ,p_flag               in varchar2
   ,p_flag_name          in varchar2)
 IS
  l_proc           VARCHAR2(72)  :=  g_package||'chk_sec_profile';
begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
 IF hr_api.not_exists_in_hrstanlookups
  (p_effective_date               => p_effective_date
  ,p_lookup_type                  => 'YES_NO'
  ,p_lookup_code                  => p_flag
  ) THEN
       fnd_message.set_name('801','HR_52970_COL_Y_OR_N');
       fnd_message.set_token('COLUMN',p_flag_name);
       fnd_message.raise_error;
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_y_or_n;

--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_version_number >---------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_version_number
  (p_org_structure_version_id            in number,
   p_version_number                      in number,
   p_organization_structure_id           in number
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_version_number';
  --
  -- Declare cursor
  --
  cursor csr_org_version is
   select org_structure_version_id,business_group_id
     from per_org_structure_versions
     where version_number = p_version_number
       and nvl(p_org_structure_version_id,-1) <> org_structure_version_id
       and p_organization_structure_id = organization_structure_id;
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'p_version_number'
    ,p_argument_value     => p_version_number
    );

--
--
hr_utility.set_location(l_proc, 20);
--
--
  for Crec in csr_org_version loop
          hr_utility.set_message(800, 'PER_7901_SYS_DUPLICATE_RECORDS');
          hr_utility.raise_error;
  end loop;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_version_number;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_top_node_pos_control >-----------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_top_node_pos_control
  (p_topnode_pos_ctrl_enabled_f       in varchar2,
   p_organization_structure_id           in varchar2
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_top_node_pos_control';
  --
  -- Declare cursor
  --
  cursor csr_parent is
   select count(*) as count
     from per_organization_structures
     where position_control_structure_flg = 'Y'
       and p_organization_structure_id = organization_structure_id;
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
--
--
hr_utility.set_location(l_proc, 20);
--
--
  for Crec in csr_parent loop
      if p_topnode_pos_ctrl_enabled_f = 'Y'
         and Crec.count = 0 then
          hr_utility.set_message(800, 'HR_6085_POS_ONE_PRIMARY');
          hr_utility.raise_error;
         end if;
  end loop;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_top_node_pos_control;

--  ---------------------------------------------------------------------------
--  |------------------------< chk_org_structure_id>--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_org_structure_id
  (p_business_group_id                   in varchar2,
   p_organization_structure_id           in varchar2
  ) is
  l_proc           VARCHAR2(72)  :=  g_package||'chk_top_node_pos_control';
  l_count          number;
  --
  -- Declare cursor
  --
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--

--
--
hr_utility.set_location(l_proc, 20);
--
--
select count(*) as count
     into l_count
     from per_organization_structures
       where p_organization_structure_id = organization_structure_id;

if l_count =0 then
          hr_utility.set_message(800, 'HR_51022_HR_INV_PRIMARY_KEY');
          hr_utility.raise_error;
  end if;
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_org_structure_id;

--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_dates >-------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_dates
  (p_org_structure_version_id            in number,
   p_date_from                           in date,
   p_date_to                             in date,
   p_organization_structure_id           in number,
   p_gap_warning                        out nocopy boolean
  ) is
  l_dummy          VARCHAR2(5);
  l_max_end_date DATE;
  l_min_start_date DATE;
  l_proc           VARCHAR2(72)  :=  g_package||'chk_dates';
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'p_date_from'
    ,p_argument_value     => p_date_from
    );

--
--
hr_utility.set_location(l_proc, 20);
--
--  Checks that date from is earlier than date to and neither
--  are before or after beginning/end of time
--

if p_date_from > p_date_to
   or p_date_from < hr_api.g_sot
   or p_date_from > hr_api.g_eot then
      hr_utility.set_message('801','HR_6021_ALL_START_END_DATE');
      hr_utility.raise_error;
   end if;

--  The code below checks for a gap between different versions
--
--
--
  p_gap_warning := FALSE;
  select max(osv.date_to)
  into   l_max_end_date
  from   per_org_structure_versions osv
  where  osv.date_from < p_Date_From
  and   osv.organization_structure_id = p_organization_structure_id
  and   osv.org_structure_Version_id = nvl(p_org_structure_version_id,-1);
  --
  if (l_max_end_date is not null and p_Date_from = (l_max_end_date +1)
   or (l_max_end_date is null)) then
        select min(osv.date_from)
                  into   l_min_start_date
        from   per_org_structure_versions osv
        where  osv.organization_structure_id = p_organization_structure_id
        and    osv.date_from > p_Date_To
        and    osv.org_structure_Version_id = nvl(p_org_structure_version_id,-1);
        --
        --
    if l_min_start_date is not null and (p_Date_To +1) <> l_min_start_date then
    p_gap_warning :=TRUE;
     end if;
  else
  p_gap_warning := TRUE;
  end if;
   begin
      --
      -- Test for overlapping rows
      --
      select null
      into   l_dummy
      from dual
      where exists
         (select 1
         from per_org_structure_versions osv
         where osv.date_from <= nvl(p_Date_To, hr_api.g_eot)
         and   nvl(osv.date_to,hr_api.g_eot) >= p_Date_From
         and   osv.organization_structure_id = p_organization_structure_id
         and   osv.org_structure_version_id
               <> nvl(p_org_structure_version_id,-1));
      --
      hr_utility.set_message('801','HR_6076_PO_POS_OVERLAP');
      hr_utility.raise_error;
      --
   end;
   exception
      when no_data_found then
         null;

--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
end chk_dates;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_org_structure_version_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_org_structure_versions osv
     where osv.org_structure_version_id = p_org_structure_version_id
       and pbg.business_group_id = osv.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'org_structure_version_id'
    ,p_argument_value     => p_org_structure_version_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_org_structure_version_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_org_structure_versions osv
     where osv.org_structure_version_id = p_org_structure_version_id
       and pbg.business_group_id (+) = osv.business_group_id;
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
    ,p_argument           => 'org_structure_version_id'
    ,p_argument_value     => p_org_structure_version_id
    );
  --
  if ( nvl(per_osv_bus.g_org_structure_version_id, hr_api.g_number)
       = p_org_structure_version_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_osv_bus.g_legislation_code;
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
    per_osv_bus.g_org_structure_version_id    := p_org_structure_version_id;
    per_osv_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  ,p_rec in per_osv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_osv_shd.api_updating
      (p_org_structure_version_id             => p_rec.org_structure_version_id
      ,p_object_version_number                => p_rec.object_version_number
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_osv_shd.g_rec_type
  ,p_gap_warning                  out nocopy boolean
   ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rec.business_group_id is not null then
hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
end if;

chk_version_number
  (p_org_structure_version_id            => p_rec.org_structure_version_id,
   p_version_number                      => p_rec.version_number,
   p_organization_structure_id           => p_rec.organization_structure_id);

chk_y_or_n
  (p_effective_date             =>      p_effective_date
  ,p_flag                       =>      nvl(p_rec.topnode_pos_ctrl_enabled_flag, 'N')  --2929528
  ,p_flag_name                  =>      'topnode_pos_ctrl_enabled_f');

chk_top_node_pos_control
  (p_topnode_pos_ctrl_enabled_f        => p_rec.topnode_pos_ctrl_enabled_flag,
   p_organization_structure_id           => p_rec.organization_structure_id
  );
chk_org_structure_id
  (p_business_group_id                   => p_rec.business_group_id,
   p_organization_structure_id           => p_rec.organization_structure_id);

chk_dates
  (p_org_structure_version_id            => p_rec.org_structure_version_id,
   p_date_from                           => p_rec.date_from,
   p_date_to                             => p_rec.date_to,
   p_organization_structure_id           => p_rec.organization_structure_id,
   p_gap_warning                         => p_gap_warning);

  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_osv_shd.g_rec_type
  ,p_gap_warning                  out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
if p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
end if;
 --
chk_version_number
  (p_org_structure_version_id            => p_rec.org_structure_version_id,
   p_version_number                      => p_rec.version_number,
   p_organization_structure_id           => p_rec.organization_structure_id);

chk_y_or_n
  (p_effective_date             =>      p_effective_date
  ,p_flag                       =>      nvl(p_rec.topnode_pos_ctrl_enabled_flag, 'N')     --2929528
  ,p_flag_name                  =>      'topnode_pos_ctrl_enabled_f');

chk_top_node_pos_control
  (p_topnode_pos_ctrl_enabled_f     => p_rec.topnode_pos_ctrl_enabled_flag,
   p_organization_structure_id         => p_rec.organization_structure_id
  );

chk_dates
  (p_org_structure_version_id            => p_rec.org_structure_version_id,
   p_date_from                           => p_rec.date_from,
   p_date_to                             => p_rec.date_to,
   p_organization_structure_id           => p_rec.organization_structure_id,
   p_gap_warning                         => p_gap_warning);

chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_osv_shd.g_rec_type
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
end per_osv_bus;

/
