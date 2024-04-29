--------------------------------------------------------
--  DDL for Package Body PQH_PTI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTI_BUS" as
/* $Header: pqptirhi.pkb 120.2 2005/10/12 20:18:49 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_pti_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_information_type >------|
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
--   information_type PK of record being inserted or updated.
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
Procedure chk_information_type(p_information_type                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_information_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_pti_shd.api_updating
    (p_information_type                => p_information_type,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_information_type,hr_api.g_number)
     <>  pqh_pti_shd.g_old_rec.information_type) then
    --
    -- raise error as PK has changed
    --
    pqh_pti_shd.constraint_error('PQH_PTX_INFO_TYPES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_information_type is not null then
      --
      -- raise error as PK is not null
      --
      pqh_pti_shd.constraint_error('PQH_PTX_INFO_TYPES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_information_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_multiple_occurences_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   information_type PK of record being inserted or updated.
--   multiple_occurences_flag Value of lookup code.
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
Procedure chk_multiple_occurences_flag(p_information_type                in number,
                            p_multiple_occurences_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_multiple_occurences_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_pti_shd.api_updating
    (p_information_type                => p_information_type,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_multiple_occurences_flag
      <> nvl(pqh_pti_shd.g_old_rec.multiple_occurences_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_multiple_occurences_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_multiple_occurences_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_active_inactive_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   information_type PK of record being inserted or updated.
--   active_inactive_flag Value of lookup code.
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
Procedure chk_active_inactive_flag(p_information_type                in number,
                            p_active_inactive_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_active_inactive_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_pti_shd.api_updating
    (p_information_type                => p_information_type,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_active_inactive_flag
      <> nvl(pqh_pti_shd.g_old_rec.active_inactive_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_active_inactive_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_active_inactive_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_pti_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_information_type
  (p_information_type          => p_rec.information_type,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_multiple_occurences_flag
  (p_information_type          => p_rec.information_type,
   p_multiple_occurences_flag         => p_rec.multiple_occurences_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_active_inactive_flag
  (p_information_type          => p_rec.information_type,
   p_active_inactive_flag         => p_rec.active_inactive_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_pti_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_information_type
  (p_information_type          => p_rec.information_type,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_multiple_occurences_flag
  (p_information_type          => p_rec.information_type,
   p_multiple_occurences_flag         => p_rec.multiple_occurences_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_active_inactive_flag
  (p_information_type          => p_rec.information_type,
   p_active_inactive_flag         => p_rec.active_inactive_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_pti_shd.g_rec_type
                         ,p_effective_date in date) is
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
end pqh_pti_bus;

/
