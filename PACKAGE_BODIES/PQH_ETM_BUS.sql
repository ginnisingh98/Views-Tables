--------------------------------------------------------
--  DDL for Package Body PQH_ETM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ETM_BUS" as
/* $Header: pqetmrhi.pkb 115.4 2002/11/27 23:43:21 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_etm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_ent_minutes_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ent_minutes_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_ent_minutes etm
     where etm.ent_minutes_id = p_ent_minutes_id
       and pbg.business_group_id = etm.business_group_id;
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
    ,p_argument           => 'ent_minutes_id'
    ,p_argument_value     => p_ent_minutes_id
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
        => nvl(p_associated_column1,'ENT_MINUTES_ID')
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
  (p_ent_minutes_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_de_ent_minutes etm
     where etm.ent_minutes_id = p_ent_minutes_id
       and pbg.business_group_id (+) = etm.business_group_id;
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
    ,p_argument           => 'ent_minutes_id'
    ,p_argument_value     => p_ent_minutes_id
    );
  --
  if ( nvl(pqh_etm_bus.g_ent_minutes_id, hr_api.g_number)
       = p_ent_minutes_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_etm_bus.g_legislation_code;
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
    pqh_etm_bus.g_ent_minutes_id              := p_ent_minutes_id;
    pqh_etm_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pqh_etm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_etm_shd.api_updating
      (p_ent_minutes_id                    => p_rec.ent_minutes_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  IF nvl(p_rec.ENT_MINUTES_CD, hr_api.g_varchar2) <>
     nvl(pqh_etm_shd.g_old_rec.ENT_MINUTES_CD, hr_api.g_varchar2) THEN
      hr_utility.set_message(8302, 'DE_PQH_NONUPD_ENT_CD');
      fnd_message.raise_error;
    END IF;

IF nvl(p_rec.TARIFF_GROUP_CD, hr_api.g_varchar2) <>
     nvl(pqh_etm_shd.g_old_rec.TARIFF_GROUP_CD, hr_api.g_varchar2) THEN
      hr_utility.set_message(8302, 'DE_PQH_NONUPD_TARIFF_CD');
      fnd_message.raise_error;
    END IF;


  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_TFF_CD_HR_LOOKUP >---------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_TFF_CD_HR_LOOKUP
(p_rec   in pqh_ETM_shd.g_rec_type) is
--
Cursor c_TFF_CD_HR_LOOKUP is
Select  '1'
  from  hr_lookups
 Where  LOOKUP_TYPE  = 'DE_PQH_TARIFF_GROUP_TYPE'
 AND    LOOKUP_CODE  = p_rec.Tariff_group_CD;

L_status Varchar2(1);
l_proc     varchar2(1000) := g_package || 'UNIQUE_ENT_MIN_TFF_CD';
Begin
hr_utility.set_location(l_proc, 10);
Open c_TFF_CD_HR_LOOKUP;
Fetch c_TFF_CD_HR_LOOKUP into L_status;
If c_TFF_CD_HR_LOOKUP%notfound  Then
   hr_utility.set_message(8302, 'DE_PQH_TARIFF_CODE');
   Close c_TFF_CD_HR_LOOKUP;
   fnd_message.raise_error;
End If;
Close c_TFF_CD_HR_LOOKUP;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_ENT_MINUTES.Tariff_group_CD'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_TFF_CD_HR_LOOKUP;

-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_unique_ENT_Desc >-----------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_unique_ENT_Desc
(p_rec   in pqh_ETM_shd.g_rec_type) is
--
Cursor c_unique_ENT_Desc is
Select  '1'
from   PQH_DE_ENT_MINUTES
Where  DESCRIPTION     = p_rec.DESCRIPTION
and    Business_group_id = p_rec.Business_group_id ;

L_status Varchar2(1);
l_proc     varchar2(1000) := g_package || 'UNIQUE_unique_ENT_Desc';
Begin
hr_utility.set_location(l_proc, 10);
Open c_unique_ENT_Desc;
Fetch c_unique_ENT_Desc into L_status;
If c_unique_ENT_Desc%found  Then
   hr_utility.set_message(8302, 'DE_PQH_unique_ENT_Desc');
   Close c_unique_ENT_Desc;
   fnd_message.raise_error;
End If;
Close c_unique_ENT_Desc;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_ENT_MINUTES.DESCRIPTION'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_unique_ENT_Desc;

-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_ENT_MIN_TFF_CD >------------------------------|
-- ----------------------------------------------------------------------------

Procedure Chk_ENT_MIN_TFF_CD
(p_rec   in pqh_ETM_shd.g_rec_type) is
--
Cursor c_ENT_MIN_TFF_CD is
Select  '1'
  from  PQH_DE_ENT_MINUTES
 Where  ENT_MINUTES_CD  = p_rec.ENT_MINUTES_CD
 AND    Tariff_group_CD = p_rec.Tariff_group_CD;

L_status Varchar2(1);
l_proc     varchar2(1000) := g_package || 'UNIQUE_ENT_MIN_TFF_CD';
Begin
hr_utility.set_location(l_proc, 10);
Open c_ENT_MIN_TFF_CD;
Fetch c_ENT_MIN_TFF_CD into L_status;
If c_ENT_MIN_TFF_CD%found  Then
   hr_utility.set_message(8302, 'PQH_DE_ENT_MINUTES_DUP');
   Close c_ENT_MIN_TFF_CD;
   fnd_message.raise_error;
End If;
Close c_ENT_MIN_TFF_CD;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_ENT_MINUTES.ENT_MINUTES_CD'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Chk_ENT_MIN_TFF_CD;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- Validate Important Attributes

If p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_etm_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
end if;

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
Chk_TFF_CD_HR_LOOKUP(P_REC);
Chk_ENT_MIN_TFF_CD (P_Rec);
Chk_unique_ENT_Desc(P_Rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_etm_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- Validate Important Attributes
If p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_etm_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
end if;

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --

  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

Chk_TFF_CD_HR_LOOKUP(P_REC);
Chk_unique_ENT_Desc(P_Rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_etm_shd.g_rec_type
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
end pqh_etm_bus;

/
