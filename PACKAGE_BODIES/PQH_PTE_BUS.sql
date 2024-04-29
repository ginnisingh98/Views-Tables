--------------------------------------------------------
--  DDL for Package Body PQH_PTE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTE_BUS" as
/* $Header: pqpterhi.pkb 115.11 2002/12/12 23:13:54 sgoyal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_pte_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ptx_extra_info_id >------|
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
--   ptx_extra_info_id PK of record being inserted or updated.
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
Procedure chk_ptx_extra_info_id(p_ptx_extra_info_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptx_extra_info_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_pte_shd.api_updating
    (p_ptx_extra_info_id                => p_ptx_extra_info_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ptx_extra_info_id,hr_api.g_number)
     <>  pqh_pte_shd.g_old_rec.ptx_extra_info_id) then
    --
    -- raise error as PK has changed
    --
    pqh_pte_shd.constraint_error('PQH_PTX_EXTRA_INFO_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ptx_extra_info_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_pte_shd.constraint_error('PQH_PTX_EXTRA_INFO_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ptx_extra_info_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_transaction_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ptx_extra_info_id PK
--   p_position_transaction_id ID of FK column
--   p_object_version_number object version number
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
Procedure chk_position_transaction_id (p_ptx_extra_info_id          in number,
                            p_position_transaction_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_transaction_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pqh_position_transactions a
    where  a.position_transaction_id = p_position_transaction_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_pte_shd.api_updating
     (p_ptx_extra_info_id            => p_ptx_extra_info_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_position_transaction_id,hr_api.g_number)
     <> nvl(pqh_pte_shd.g_old_rec.position_transaction_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if position_transaction_id value exists in pqh_position_transactions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_position_transactions
        -- table.
        --
        pqh_pte_shd.constraint_error('PQH_PTX_EXTRA_INFO_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_position_transaction_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_information_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ptx_extra_info_id PK
--   p_information_type ID of FK column
--   p_object_version_number object version number
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
Procedure chk_information_type (p_ptx_extra_info_id          in number,
                            p_information_type          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_information_type';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_position_info_types a
    where  a.information_type = p_information_type;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_pte_shd.api_updating
     (p_ptx_extra_info_id            => p_ptx_extra_info_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_information_type,hr_api.g_varchar2)
     <> nvl(pqh_pte_shd.g_old_rec.information_type,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if information_type value exists in per_position_info_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pqh_ptx_info_types
        -- table.
        --
        hr_utility.set_message(800, 'PQH_INVALID_POS_INFO_TYPE');
        hr_utility.set_message_token('POS_INFO_TYPE',p_information_type );
        hr_utility.raise_error;
        -- pqh_pte_shd.constraint_error('PQH_PTX_EXTRA_INFO_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_information_type;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_pte_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
  l_ptx_rec         pqh_position_transactions%rowtype;
--
  cursor c_ptx(p_position_transaction_id number) is
  select *
  from pqh_position_transactions
  where position_transaction_id = p_position_transaction_id;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_ptx(p_rec.position_transaction_id);
  fetch c_ptx into l_ptx_rec;
  --
  -- Validate Position Id
  --
  if c_ptx%notfound then
    close c_ptx;
    hr_utility.set_message(800, 'HR_INV_POSN_TRAN');
    hr_utility.raise_error;
  end if;
  --
  close c_ptx;
  --
  -- Call all supporting business operations
  --
  chk_ptx_extra_info_id
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_transaction_id
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_information_type
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_information_type          => p_rec.information_type,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  --
  -- Validate Seasonal Dates for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_SEASONAL')  then
  	if (nvl(l_ptx_rec.seasonal_flag,'N') = 'N' )then
  	  -- Cannot add Seasonal dates to PTX Extra Info if seasonal_flag<>'Y'
      hr_utility.set_message(800, 'HR_INV_POI_SEASONAL');
	  hr_utility.raise_error;
  	end if;
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Overlap Dates for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_OVERLAP')  then
  	if ( l_ptx_rec.overlap_period is null )then
  	  -- Cannot add Overlap dates to PTX Extra Info if overlap_period is null
    	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP');
	  hr_utility.raise_error;
  	end if;
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Reservation Info for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_RESERVED')  then
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Reservation end date should be later than reservation start date
  	  hr_utility.set_message(800, 'HR_INV_POI_RESERVED_DATES');
	  hr_utility.raise_error;
  	end if;
  	if (p_rec.information6 <= 0) then
  	  -- Reservation end date should be later than reservation start date
  	  hr_utility.set_message(800, 'HR_INV_POI_RESERVED_FTE');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_pte_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_ptx_extra_info_id
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_position_transaction_id
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_position_transaction_id          => p_rec.position_transaction_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_information_type
  (p_ptx_extra_info_id          => p_rec.ptx_extra_info_id,
   p_information_type          => p_rec.information_type,
   p_object_version_number => p_rec.object_version_number);
  --
 --
  --
  -- Validate Seasonal Dates for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_SEASONAL')  then
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_SEASONAL_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Overlap Dates for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_OVERLAP')  then
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Overlap end date should be later than overlap start date
  	  hr_utility.set_message(800, 'HR_INV_POI_OVERLAP_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
  -- Validate Reservation Info for PTX Extra Info
  --
  if (p_rec.information_type = 'PER_RESERVED')  then
  	if (p_rec.information3 > p_rec.information4) then
  	  -- Reservation end date should be later than reservation start date
  	  hr_utility.set_message(800, 'HR_INV_POI_RESERVED_DATES');
	  hr_utility.raise_error;
  	end if;
  end if;
  --
   --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_pte_shd.g_rec_type) is
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
end pqh_pte_bus;

/
