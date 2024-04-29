--------------------------------------------------------
--  DDL for Package Body PQH_RLS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLS_BUS" as
/* $Header: pqrlsrhi.pkb 115.21 2004/02/18 12:06:25 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rls_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_role_id                     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< check_sshr_edit_roles >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure check_sshr_edit_roles (
        p_role_type_cd  varchar2,
        p_business_group_id number,
        p_enable_flag   varchar2
)
is
dummy varchar2(1) := 'N';
cursor c1 is
select 'Y'
from   pqh_roles
where  role_type_cd = decode(p_role_type_cd,'PQH_EXCL','PQH_INCL','PQH_EXCL')
and    enable_flag  = 'Y'
and    business_group_id = p_business_group_id;
--
cursor c2 is
select 'Y'
from   pqh_roles
where  role_type_cd = decode(p_role_type_cd,'PQH_EXCL','PQH_INCL','PQH_EXCL')
and    enable_flag  = 'Y'
and    business_group_id is null;
--
begin
--   message('Fired'||:PQH_ROLES.role_type_cd||'  BG: '||:PQH_ROLES.business_group_id);pause;

  if p_role_type_cd in ('PQH_EXCL','PQH_INCL') and
     p_enable_flag = 'Y' then
     if NVL(p_business_group_id,-1) = -1  then
	open  c2;
        fetch c2 into dummy;
        close c2;
     else
	open  c1;
        fetch c1 into dummy;
        close c1;
     end if;
--  message('Dummy  ' ||dummy);pause;
     if dummy = 'Y' then -- other record is found
      -- throw message

	hr_utility.set_message(8302,'PQH_SSHR_BOTH_EDIT_PRFL_ERR');
    hr_utility.raise_error;

     end if;
  end if;
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_role_id                              in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         ,pqh_roles rls
     where
       rls.role_id = p_role_id
       and pbg.business_group_id = rls.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'role_id'
    ,p_argument_value     => p_role_id
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
  hr_utility.set_location(' Leaving:'|| l_proc,20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_role_id                              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         ,pqh_roles rls
     where
       rls.role_id = p_role_id
       and pbg.business_group_id = rls.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'role_id'
    ,p_argument_value     => p_role_id
    );
  --
  if ( nvl(pqh_rls_bus.g_role_id,hr_api.g_number)
       = p_role_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_rls_bus.g_legislation_code;
    hr_utility.set_location(l_proc,20);
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
    hr_utility.set_location(l_proc,0);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_rls_bus.g_role_id           := p_role_id;
    pqh_rls_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc,40);
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
--    has been populated with the updated values the user would like the
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
  (p_effective_date               in date,
   p_rec in pqh_rls_shd.g_rec_type
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
  IF NOT pqh_rls_shd.api_updating
      (p_role_id                              => p_rec.role_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER','HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ',l_proc);
     fnd_message.set_token('STEP ','5');
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
-- |------< chk_role_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   role_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_role_id(p_role_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rls_shd.api_updating
    (p_role_id                => p_role_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_role_id,hr_api.g_number)
     <>  pqh_rls_shd.g_old_rec.role_id) then
    --
    -- raise error as PK has changed
    --
    pqh_rls_shd.constraint_error('PQH_ROLES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_role_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_rls_shd.constraint_error('PQH_ROLES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_role_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enable_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   role_id PK of record being inserted or updated.
--   enable_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_enable_flag(p_role_id                in number,
                            p_enable_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enable_flag';
  l_api_updating boolean;
  --

CURSOR csr_role_positions IS
SELECT count(*)
FROM pqh_position_roles_v
WHERE role_id = p_role_id;

CURSOR csr_role_name IS
SELECT role_name
FROM pqh_roles
WHERE role_id = p_role_id;

l_posn_count     NUMBER(15) := 0;
l_role_name      pqh_roles.role_name%TYPE;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rls_shd.api_updating
    (p_role_id                => p_role_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enable_flag
      <> nvl(pqh_rls_shd.g_old_rec.enable_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enable_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enable_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(8302,'PQH_INVALID_ENABLE_FLAG');
      hr_utility.raise_error;
      --
    end if;
/*
    --
    --  check if the role is disabled and if there are any positions attached to the role
    -- display an error message
    --
     if NVL(p_enable_flag,N') = 'N' then

        OPEN  csr_role_positions;
          FETCH csr_role_positions INTO l_posn_count;
        CLOSE csr_role_positions;

        if NVL(l_posn_count,0) > 0 then
           --
           -- get the role name for token
           --
              OPEN csr_role_name;
                FETCH csr_role_name INTO l_role_name;
              CLOSE csr_role_name;

              --
              -- raise error as posn attached to the role
              --
              hr_utility.set_message(8302,'PQH_ROLE_ENABLE_FLAG');
              hr_utility.set_message_token('ROLENAME',p_role_name);
              hr_utility.raise_error;
              --
        end if;  -- for posn > 0

     end if; -- role is disabled

*/

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,0);
  --
end chk_enable_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_role_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   role_id PK of record being inserted or updated.
--   role_type_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_role_type_cd(p_role_id                in number,
                            p_role_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_rls_shd.api_updating
    (p_role_id                => p_role_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_role_type_cd
      <> nvl(pqh_rls_shd.g_old_rec.role_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_role_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_ROLE_TYPE',
           p_lookup_code    => p_role_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'PQH_INVALID_ROLE_TYPE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,0);
  --
end chk_role_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_role_assignment >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   role_id PK of record being inserted or updated.
--   role_type_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_role_assignment(p_role_id                in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_type_cd';
  l_role_assigned    boolean := FALSE;
  l_role_assign_count  number(25) :=0;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
    --
   begin
      select count(*) into  l_role_assign_count
      from per_people_extra_info pei
      where pei.information_type='PQH_ROLE_USERS'
      and pei.pei_information3=p_role_id;

      if l_role_assign_count >0 then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
        hr_utility.raise_error;
      end if;
      --
   end;
  --
  hr_utility.set_location('Leaving:'||l_proc,0);
  --
end chk_role_assignment;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--
Procedure chk_role_name (p_role_id                in number,
                         p_role_name              in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_name';
  --
l_dummy   varchar2(1);

cursor csr_role_name is
select 'X'
from pqh_roles
where role_name = p_role_name
  and role_id <> nvl(p_role_id,0);

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_role_name;
   fetch csr_role_name into l_dummy;
  close csr_role_name;

    if nvl(l_dummy ,'Y') = 'X' then
      --
       hr_utility.set_message(8302,'PQH_DUPLICATE_ROLE_NAME');
       hr_utility.raise_error;
      --
    end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,0);
  --
end chk_role_name;
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--
Procedure chk_role_delete (p_role_id                in number ) is
  --
  l_proc         varchar2(72) := g_package||'chk_role_delete';

--
l_cnt_templates              number(9);
l_cnt_positions              number(9);
l_cnt_users                  number(9);
l_cnt_routing_lists          number(9);
--
cursor csr_cnt_templates is
select count(*)
from pqh_role_templates
where role_id = NVL(p_role_id,0)
  and nvl(enable_flag,'N') = 'Y';
--
cursor csr_cnt_positions is
select count(*)
from pqh_position_roles_v
where role_id = NVL(p_role_id,0);
--
cursor csr_cnt_users is
select count(*)
from pqh_role_users_v
where role_id = NVL(p_role_id,0);
--
cursor csr_cnt_routing_lists is
select count(*)
from pqh_routing_list_members
where role_id = NVL(p_role_id,0);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_cnt_templates;
   fetch csr_cnt_templates into l_cnt_templates;
  close csr_cnt_templates;
  --
  open csr_cnt_positions;
   fetch csr_cnt_positions into l_cnt_positions;
  close csr_cnt_positions;
  --
  open csr_cnt_users;
   fetch csr_cnt_users into l_cnt_users;
  close csr_cnt_users;
  --
  open csr_cnt_routing_lists;
   fetch csr_cnt_routing_lists into l_cnt_routing_lists;
  close csr_cnt_routing_lists;
  --
    if nvl(l_cnt_templates ,0) <> 0 then
      --
       hr_utility.set_message(8302,'PQH_DELETE_ROLE');
       hr_utility.set_message_token('ENTITY','Templates');
       hr_utility.raise_error;
      --
    end if;
  --
    if nvl(l_cnt_positions ,0) <> 0 then
      --
       hr_utility.set_message(8302,'PQH_DELETE_ROLE');
       hr_utility.set_message_token('ENTITY','Positions');
       hr_utility.raise_error;
      --
    end if;
  --
    if nvl(l_cnt_users ,0) <> 0 then
      --
       hr_utility.set_message(8302,'PQH_DELETE_ROLE');
       hr_utility.set_message_token('ENTITY','Users');
       hr_utility.raise_error;
      --
    end if;
  --
    if nvl(l_cnt_routing_lists ,0) <> 0 then
      --
       hr_utility.set_message(8302,'PQH_DELETE_ROLE');
       hr_utility.set_message_token('ENTITY','Routing Lists');
       hr_utility.raise_error;
      --
    end if;
  --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_role_delete;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_for_pending_txns >---------------------------|
-- ---------------------------------------------------------------------------
--
--
Procedure chk_for_pending_txns(p_role_id 	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_for_pending_txns';
  l_api_updating boolean;
  l_bus_grp_name varchar2(240);
  --
  cursor c_txn_cats(p_role_id number) is
  select distinct ptc.transaction_category_id, ptc.name transaction_category,
         ptc.business_group_id
  from pqh_routing_list_members rlm, pqh_routing_categories rct,
       pqh_transaction_categories ptc
  where rlm.routing_list_id =  rct.routing_list_id
  and rlm.role_id = p_role_id
  and rct.transaction_category_id=ptc.transaction_category_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    for r_txn_cat in c_txn_cats(p_role_id)
    loop
      --
      if nvl(pqh_tct_bus.chk_active_transaction_exists(r_txn_cat.transaction_category_id),'N')
            = 'Y' then
         --
         hr_utility.set_message(8302,'PQH_CANT_DEL_RLS_PNDG_TXN');
         hr_utility.set_message_token('TRANSACTION_CATEGORY', r_txn_cat.transaction_category);
         if (r_txn_cat.business_group_id is not null) then
           l_bus_grp_name := hr_general.DECODE_ORGANIZATION(r_txn_cat.business_group_id);
         else
           l_bus_grp_name := hr_general.decode_lookup('PQH_TCT_SCOPE', 'GLOBAL');
         end if;
         --
         hr_utility.set_message_token('BUSINESS_GROUP', l_bus_grp_name);
         --
         hr_utility.raise_error;
      end if;
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_for_pending_txns;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_user_pending_txns >---------------------------|
-- ---------------------------------------------------------------------------
--
--
Procedure chk_user_pending_txns(p_role_id  in number,
				p_user_id 	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_user_pending_txns';
  l_api_updating boolean;
  --
  cursor c_txn_cats(p_role_id number, p_user_id number) is
  select distinct transaction_category_id
  from pqh_routing_list_members rlm, pqh_routing_categories rct
  where (rlm.routing_list_id =  rct.routing_list_id
  and rlm.user_id = p_user_id
  and rlm.role_id = p_role_id)
  or (rct.override_user_id = p_user_id and rct.override_role_id = p_role_id) ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    for r_txn_cat in c_txn_cats(p_role_id, p_user_id)
    loop
      --
      if nvl(pqh_tct_bus.chk_active_transaction_exists(r_txn_cat.transaction_category_id),'N')
            = 'Y' then
         hr_utility.set_message(8302,'PQH_CANT_DEL_USR_PNDG_TXN');
         hr_utility.raise_error;
      end if;
      --
    end loop;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_user_pending_txns;
--

-- mvankada
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--     are all valid this procedure will end normally and processing will
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
procedure chk_ddf
  ( p_rec in pqh_rls_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --

   if ((p_rec.role_id is not null) and (
    nvl(pqh_rls_shd.g_old_rec.information_category,hr_api.g_varchar2) <>
    nvl(p_rec.information_category,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information1,hr_api.g_varchar2) <>
    nvl(p_rec.information1,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information2,hr_api.g_varchar2) <>
    nvl(p_rec.information2,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information3,hr_api.g_varchar2) <>
    nvl(p_rec.information3,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information4,hr_api.g_varchar2) <>
    nvl(p_rec.information4,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information5,hr_api.g_varchar2) <>
    nvl(p_rec.information5,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information6,hr_api.g_varchar2) <>
    nvl(p_rec.information6,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information7,hr_api.g_varchar2) <>
    nvl(p_rec.information7,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information8,hr_api.g_varchar2) <>
    nvl(p_rec.information8,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information9,hr_api.g_varchar2) <>
    nvl(p_rec.information9,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information10,hr_api.g_varchar2) <>
    nvl(p_rec.information10,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information11,hr_api.g_varchar2) <>
    nvl(p_rec.information11,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information12,hr_api.g_varchar2) <>
    nvl(p_rec.information12,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information13,hr_api.g_varchar2) <>
    nvl(p_rec.information13,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information14,hr_api.g_varchar2) <>
    nvl(p_rec.information14,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information15,hr_api.g_varchar2) <>
    nvl(p_rec.information15,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information16,hr_api.g_varchar2) <>
    nvl(p_rec.information16,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information17,hr_api.g_varchar2) <>
    nvl(p_rec.information17,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information18,hr_api.g_varchar2) <>
    nvl(p_rec.information18,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information19,hr_api.g_varchar2) <>
    nvl(p_rec.information19,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information20,hr_api.g_varchar2) <>
    nvl(p_rec.information20,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information21,hr_api.g_varchar2) <>
    nvl(p_rec.information21,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information22,hr_api.g_varchar2) <>
    nvl(p_rec.information22,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information23,hr_api.g_varchar2) <>
    nvl(p_rec.information23,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information24,hr_api.g_varchar2) <>
    nvl(p_rec.information24,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information25,hr_api.g_varchar2) <>
    nvl(p_rec.information25,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information26,hr_api.g_varchar2) <>
    nvl(p_rec.information26,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information27,hr_api.g_varchar2) <>
    nvl(p_rec.information27,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information28,hr_api.g_varchar2) <>
    nvl(p_rec.information28,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information29,hr_api.g_varchar2) <>
    nvl(p_rec.information29,hr_api.g_varchar2) or
    nvl(pqh_rls_shd.g_old_rec.information30,hr_api.g_varchar2) <>
    nvl(p_rec.information30,hr_api.g_varchar2)))
    or
    (p_rec.role_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update,the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PQH'
      ,p_descflex_name      => 'Roles Developer DF'
      ,p_attribute_category => p_rec.information_category
      ,p_attribute1_name    => 'INFORMATION1'
      ,p_attribute1_value   => p_rec.information1
      ,p_attribute2_name    => 'INFORMATION2'
      ,p_attribute2_value   => p_rec.information2
      ,p_attribute3_name    => 'INFORMATION3'
      ,p_attribute3_value   => p_rec.information3
      ,p_attribute4_name    => 'INFORMATION4'
      ,p_attribute4_value   => p_rec.information4
      ,p_attribute5_name    => 'INFORMATION5'
      ,p_attribute5_value   => p_rec.information5
      ,p_attribute6_name    => 'INFORMATION6'
      ,p_attribute6_value   => p_rec.information6
      ,p_attribute7_name    => 'INFORMATION7'
      ,p_attribute7_value   => p_rec.information7
      ,p_attribute8_name    => 'INFORMATION8'
      ,p_attribute8_value   => p_rec.information8
      ,p_attribute9_name    => 'INFORMATION9'
      ,p_attribute9_value   => p_rec.information9
      ,p_attribute10_name   => 'INFORMATION10'
      ,p_attribute10_value  => p_rec.information10
      ,p_attribute11_name   => 'INFORMATION11'
      ,p_attribute11_value  => p_rec.information11
      ,p_attribute12_name   => 'INFORMATION12'
      ,p_attribute12_value  => p_rec.information12
      ,p_attribute13_name   => 'INFORMATION13'
      ,p_attribute13_value  => p_rec.information13
      ,p_attribute14_name   => 'INFORMATION14'
      ,p_attribute14_value  => p_rec.information14
      ,p_attribute15_name   => 'INFORMATION15'
      ,p_attribute15_value  => p_rec.information15
      ,p_attribute16_name   => 'INFORMATION16'
      ,p_attribute16_value  => p_rec.information16
      ,p_attribute17_name   => 'INFORMATION17'
      ,p_attribute17_value  => p_rec.information17
      ,p_attribute18_name   => 'INFORMATION18'
      ,p_attribute18_value  => p_rec.information18
      ,p_attribute19_name   => 'INFORMATION19'
      ,p_attribute19_value  => p_rec.information19
      ,p_attribute20_name   => 'INFORMATION20'
      ,p_attribute20_value  => p_rec.information20
      ,p_attribute21_name   => 'INFORMATION21'
      ,p_attribute21_value  => p_rec.information21
      ,p_attribute22_name   => 'INFORMATION22'
      ,p_attribute22_value  => p_rec.information22
      ,p_attribute23_name   => 'INFORMATION23'
      ,p_attribute23_value  => p_rec.information23
      ,p_attribute24_name   => 'INFORMATION24'
      ,p_attribute24_value  => p_rec.information24
      ,p_attribute25_name   => 'INFORMATION25'
      ,p_attribute25_value  => p_rec.information25
      ,p_attribute26_name   => 'INFORMATION26'
      ,p_attribute26_value  => p_rec.information26
      ,p_attribute27_name   => 'INFORMATION27'
      ,p_attribute27_value  => p_rec.information27
      ,p_attribute28_name   => 'INFORMATION28'
      ,p_attribute28_value  => p_rec.information28
      ,p_attribute29_name   => 'INFORMATION29'
      ,p_attribute29_value  => p_rec.information29
      ,p_attribute30_name   => 'INFORMATION30'
      ,p_attribute30_value  => p_rec.information30
      );
  end if;

  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_ddf;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call all supporting business operations
  --
  chk_role_id
  (p_role_id          => p_rec.role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_role_id          => p_rec.role_id,
   p_enable_flag         => p_rec.enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number =>p_rec.object_version_number);
  --
  chk_role_type_cd
  (p_role_id          => p_rec.role_id,
   p_role_type_cd         => p_rec.role_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_role_name
  (p_role_id          => p_rec.role_id,
   p_role_name        => p_rec.role_name);
  --
  --
  if  p_rec.business_group_id is not null then		-- ** For Global Roles **
      hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  --
  -- mvankada
  -- Developer Descriptive Flex Check
  -- ================================
  --
  pqh_rls_bus.chk_ddf(p_rec => p_rec);
  --
  check_sshr_edit_roles  (
    p_role_type_cd      => p_rec.role_type_cd,
    p_business_group_id => p_rec.business_group_id,
    p_enable_flag       => p_rec.enable_flag );
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                         in pqh_rls_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call all supporting business operations
  --
  chk_role_id
  (p_role_id          => p_rec.role_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enable_flag
  (p_role_id          => p_rec.role_id,
   p_enable_flag         =>p_rec .enable_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_role_type_cd
  (p_role_id          => p_rec.role_id,
   p_role_type_cd         => P_rec.role_type_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_role_name
  (p_role_id          => p_rec.role_id,
   p_role_name        => p_rec.role_name);
  --
  --
  if  p_rec.business_group_id is not null then		-- ** For Global Roles **
      hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec                       => p_rec
    );
  --
  --

  -- mvankada

  -- Developer Descriptive Flex Check
  -- ================================
  --
  pqh_rls_bus.chk_ddf(p_rec => p_rec);
  --
  check_sshr_edit_roles  (
    p_role_type_cd      => p_rec.role_type_cd,
    p_business_group_id => p_rec.business_group_id,
    p_enable_flag       => p_rec.enable_flag );
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_rls_shd.g_rec_type
  ,p_effective_date		  in date
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Call all supporting business operations
  --
/*  Commented to allow role deletion and the other data
  chk_role_delete
  (p_role_id          => p_rec.role_id );
  --
  chk_role_assignment
  (p_role_id          =>p_rec.role_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
End delete_validate;
--
end pqh_rls_bus;

/
