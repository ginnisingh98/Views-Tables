--------------------------------------------------------
--  DDL for Package Body PQH_RSS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RSS_BUS" as
/* $Header: pqrssrhi.pkb 115.9 2002/12/13 13:57:40 joward noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rss_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_result_set_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_result_set_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_result_sets and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_result_sets rss
      --   , EDIT_HERE table_name(s) 333
     where rss.result_set_id = p_result_set_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'result_set_id'
    ,p_argument_value     => p_result_set_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'RESULT_SET_ID')
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
  (p_result_set_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_de_result_sets and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_de_result_sets rss
      --   , EDIT_HERE table_name(s) 333
     where rss.result_set_id = p_result_set_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'result_set_id'
    ,p_argument_value     => p_result_set_id
    );
  --
  if ( nvl(pqh_rss_bus.g_result_set_id, hr_api.g_number)
       = p_result_set_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_rss_bus.g_legislation_code;
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
    pqh_rss_bus.g_result_set_id               := p_result_set_id;
    pqh_rss_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_rss_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';

--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_rss_shd.api_updating
      (p_result_set_id                     => p_rec.result_set_id
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
IF nvl(p_rec.Grade_id, hr_api.g_number) <>
    nvl(pqh_RSS_shd.g_old_rec.Grade_id, hr_api.g_number) THEN
    hr_utility.set_message(8302, 'PQH_DE_NONUPD_GRADE_ID');
    fnd_message.raise_error;

  END IF;

End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Grade_id >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_Grade_id
  (p_rec   in pqh_rss_shd.g_rec_type) is
--
Cursor c_Grade_id is
Select  Grade_id
  from  per_grades
 Where  Grade_id = p_rec.Grade_id;
  l_Grade_id     PQH_DE_RESULT_SETS.Grade_id%TYPE;

 l_proc         varchar2(72) := g_package || 'Check_Grade_id';
Begin
hr_utility.set_location(l_proc, 10);
Open c_Grade_id;
Fetch c_Grade_id into l_Grade_id;
If c_Grade_id%notfound  Then
   hr_utility.set_message(8302, 'PQH_DE_Check_Grade_id');
   Close c_Grade_id;
   fnd_message.raise_error;
End If;
Close c_Grade_id;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_RESULT_SETS.Grade_id'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_Grade_id;
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_CIVIL_SERVANTS_Grade_id >---------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_CIVIL_SERVANTS_Grade_id
  (p_effective_date               in date ,
    p_rec   in pqh_rss_shd.g_rec_type) is
--
Cursor c_CIVIL_SERVANTS_Grade_id is
SELECT
  pg.NAME
FROM
  per_gen_hierarchy pgh,
  per_gen_hierarchy_versions pghv,
  per_gen_hierarchy_nodes pghn,
  PER_GEN_HIERARCHY_NODES pghn1      ,
  PER_GEN_HIERARCHY_NODES pghn2      ,
  PER_GEN_HIERARCHY_NODES pghn3   ,
  PER_GEN_HIERARCHY_NODES pghn4   ,
  PER_GEN_HIERARCHY_NODES pghn5   ,
  PER_GEN_HIERARCHY_NODES pghn6  ,
  PER_GRADES_VL pg
WHERE pgh.TYPE='REMUNERATION_REGULATION'
and pgh.HIERARCHY_ID=pghv.HIERARCHY_ID
and p_Effective_Date between pghv.Date_from and Nvl(pghv.Date_To,Trunc(Sysdate))
and pghv.HIERARCHY_VERSION_ID=pghn.HIERARCHY_VERSION_ID
and pghn.NODE_TYPE='PAY_GRADE'
and pghn.PARENT_HIERARCHY_NODE_ID   =  pghn1.HIERARCHY_NODE_ID
and pghn1.NODE_TYPE='TATIGKEIT'
and pghn1.PARENT_HIERARCHY_NODE_ID  =  pghn2.HIERARCHY_NODE_ID
and pghn2.PARENT_HIERARCHY_NODE_ID  =  pghn3.HIERARCHY_NODE_ID
and pghn3.PARENT_HIERARCHY_NODE_ID  =  pghn4.HIERARCHY_NODE_ID
and pghn4.PARENT_HIERARCHY_NODE_ID  =  pghn5.HIERARCHY_NODE_ID
and pghn5.PARENT_HIERARCHY_NODE_ID  =  pghn6.HIERARCHY_NODE_ID
and pghn6.ENTITY_ID     = 'BE'
and pg.GRADE_ID            =  pghn.ENTITY_ID
union all
select      pg.NAME
from
  per_gen_hierarchy pgh,
  per_gen_hierarchy_versions pghv,
  per_gen_hierarchy_nodes pghn,
  PER_GEN_HIERARCHY_NODES pghn1      ,
  PER_GEN_HIERARCHY_NODES pghn2      ,
  PER_GEN_HIERARCHY_NODES pghn3   ,
  PER_GEN_HIERARCHY_NODES pghn4   ,
  PER_GEN_HIERARCHY_NODES pghn5   ,
  PER_GEN_HIERARCHY_NODES pghn6  ,
  PER_GEN_HIERARCHY_NODES pghn7   ,
  PER_GRADES_VL pg
where  pgh.TYPE='REMUNERATION_REGULATION'
and pgh.HIERARCHY_ID=pghv.HIERARCHY_ID
and p_Effective_Date between pghv.Date_from and Nvl(pghv.Date_To,Trunc(Sysdate))
and pghv.HIERARCHY_VERSION_ID=pghn.HIERARCHY_VERSION_ID
and pghn.NODE_TYPE='PAY_GRADE'
and pghn.PARENT_HIERARCHY_NODE_ID   =  pghn1.HIERARCHY_NODE_ID
and pghn1.NODE_TYPE='TYPE_OF_SERVICE'
and pghn1.PARENT_HIERARCHY_NODE_ID  =  pghn2.HIERARCHY_NODE_ID
and pghn2.PARENT_HIERARCHY_NODE_ID  =  pghn3.HIERARCHY_NODE_ID
and pghn3.PARENT_HIERARCHY_NODE_ID  =  pghn4.HIERARCHY_NODE_ID
and pghn4.PARENT_HIERARCHY_NODE_ID  =  pghn5.HIERARCHY_NODE_ID
and pghn5.PARENT_HIERARCHY_NODE_ID  =  pghn6.HIERARCHY_NODE_ID
and pghn6.PARENT_HIERARCHY_NODE_ID  =  pghn7.HIERARCHY_NODE_ID
and pghn7.ENTITY_ID     = 'BE';

    l_CIVIL_SERVANTS_Grade_id    per_grades.name%TYPE;
    l_proc         varchar2(72) := g_package || 'Check_CIVIL_Grade_id';

Begin
hr_utility.set_location(l_proc, 10);
Open c_CIVIL_SERVANTS_Grade_id;
Fetch c_CIVIL_SERVANTS_Grade_id into l_CIVIL_SERVANTS_Grade_id;
If c_CIVIL_SERVANTS_Grade_id%notfound  Then
   hr_utility.set_message(8302, 'PQH_DE_CIVIL_SERVANTS_Grade_id');
   Close c_CIVIL_SERVANTS_Grade_id;
   fnd_message.raise_error;
End If;
Close c_CIVIL_SERVANTS_Grade_id;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_RESULT_SETS.Grade_id'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_CIVIL_SERVANTS_Grade_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_gradual_value_numbers >------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_gradual_value_numbers
  (p_rec   in pqh_rss_shd.g_rec_type) is
--
Cursor c_gradual_value_numbers is
Select  '1'
  from pqh_de_result_sets
 Where (GRADUAL_VALUE_NUMBER_FROM = p_rec.GRADUAL_VALUE_NUMBER_FROM
or GRADUAL_VALUE_NUMBER_FROM     = p_rec.GRADUAL_VALUE_NUMBER_to
or GRADUAL_VALUE_NUMBER_to       = p_rec.GRADUAL_VALUE_NUMBER_FROM
or GRADUAL_VALUE_NUMBER_to       = p_rec.GRADUAL_VALUE_NUMBER_to
or GRADUAL_VALUE_NUMBER_FROM between p_rec.GRADUAL_VALUE_NUMBER_FROM  and p_rec.GRADUAL_VALUE_NUMBER_to
or GRADUAL_VALUE_NUMBER_to between p_rec.GRADUAL_VALUE_NUMBER_FROM    and p_rec.GRADUAL_VALUE_NUMBER_to)
and result_set_id <> p_rec.result_set_id;

  l_gradual_value_numbers     PQH_DE_RESULT_SETS.GRADUAL_VALUE_NUMBER_FROM%TYPE;

 l_proc         varchar2(72) := g_package || 'Chk_gradual_value_numbers';

Begin
hr_utility.set_location(l_proc, 10);

if to_number(p_rec.GRADUAL_VALUE_NUMBER_FROM) < 0 or  to_number(p_rec.GRADUAL_VALUE_NUMBER_TO) < 0 then
 hr_utility.set_message(8302, 'PQH_DE_GRADUAL_NUM_NEG');
 fnd_message.raise_error;
End If;

if to_number(p_rec.GRADUAL_VALUE_NUMBER_FROM) > to_number(p_rec.GRADUAL_VALUE_NUMBER_TO)  then
 hr_utility.set_message(8302, 'PQH_DE_Gradual_value');
 fnd_message.raise_error;
End If;



Open c_gradual_value_numbers;
Fetch c_gradual_value_numbers into l_gradual_value_numbers;
If c_gradual_value_numbers%found  Then
   hr_utility.set_message(8302, 'PQH_DE_GRADUAL_EXIST');
   Close c_gradual_value_numbers;
   fnd_message.raise_error;
End If;
Close c_gradual_value_numbers;
Exception

when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_RESULT_SETS.GRADUAL_VALUE_NUMBER_FROM'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_gradual_value_numbers;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_rss_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  Chk_gradual_value_numbers(P_Rec);
 -- Chk_Grade_id(P_Rec);
  --
 -- Chk_CIVIL_SERVANTS_Grade_id(p_effective_date,P_Rec);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_rss_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  Chk_gradual_value_numbers(P_Rec);

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
  (p_rec                          in pqh_rss_shd.g_rec_type
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
end pqh_rss_bus;

/
