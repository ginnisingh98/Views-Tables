--------------------------------------------------------
--  DDL for Package Body GHR_NLA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NLA_BUS" as
/* $Header: ghnlarhi.pkb 120.1.12010000.1 2009/03/26 10:12:16 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_nla_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_noac_la_id >------|
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
--   noac_la_id PK of record being inserted or updated.
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
Procedure chk_noac_la_id(p_noac_la_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_noac_la_id';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_noac_la_id,hr_api.g_number)
     <>  ghr_nla_shd.g_old_rec.noac_la_id) then
    --
    -- raise error as PK has changed
    --
    ghr_nla_shd.constraint_error('GHR_NOAC_LAS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_noac_la_id is not null then
      --
      -- raise error as PK is not null
      --
      ghr_nla_shd.constraint_error('GHR_NOAC_LAS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_noac_la_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_nature_of_action_id >------|
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
--   p_noac_la_id PK
--   p_nature_of_action_id ID of FK column
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
Procedure chk_nature_of_action_id (p_noac_la_id          in number,
                            p_nature_of_action_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_nature_of_action_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ghr_nature_of_actions a
    where  a.nature_of_action_id = p_nature_of_action_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ghr_nla_shd.api_updating
     (p_noac_la_id            => p_noac_la_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_nature_of_action_id,hr_api.g_number)
     <> nvl(ghr_nla_shd.g_old_rec.nature_of_action_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if nature_of_action_id value exists in ghr_nature_of_actions table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ghr_nature_of_actions
        -- table.
        --
        ghr_nla_shd.constraint_error('GHR_NOAC_LAS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_nature_of_action_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enabled_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   enabled_flag Value of lookup code.
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
Procedure chk_enabled_flag(p_noac_la_id                in number,
                            p_enabled_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_enabled_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enabled_flag
      <> nvl(ghr_nla_shd.g_old_rec.enabled_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enabled_flag,
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
end chk_enabled_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_valid_second_lac_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   valid_second_lac_flag Value of lookup code.
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
Procedure chk_valid_second_lac_flag(p_noac_la_id                in number,
                            p_valid_second_lac_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_valid_second_lac_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_valid_second_lac_flag
      <> nvl(ghr_nla_shd.g_old_rec.valid_second_lac_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_valid_second_lac_flag,
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
end chk_valid_second_lac_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_valid_first_lac_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   valid_first_lac_flag Value of lookup code.
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
Procedure chk_valid_first_lac_flag(p_noac_la_id                in number,
                            p_valid_first_lac_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72);
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_valid_first_lac_flag';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_valid_first_lac_flag
      <> nvl(ghr_nla_shd.g_old_rec.valid_first_lac_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_valid_first_lac_flag,
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
end chk_valid_first_lac_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_date_from >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mandatory date_from is entered
--   If the date_to parameter is not null then this procedure checks that it
--   is greater than or equal to the p_date_from
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   date_from  date from
--   date_to    date to
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

Procedure chk_date_from (   p_noac_la_id                  in number,
                            p_date_from                   in date,
                            p_date_to                     in date,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_date_from';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                  => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_date_from
      <> nvl(ghr_nla_shd.g_old_rec.date_from,hr_api.g_date)
      or not l_api_updating) then
    --
    -- check if value of date_from is not null
    --
     hr_api.mandatory_arg_error
       (p_api_name        =>  l_proc
       ,p_argument        =>  'date_from'
       ,p_argument_value  =>  p_date_from
       );
   end if;
  --
  --  if date_to is not null then we check that date_to is
  --  greater than or equal to date_from
  --
      if p_date_to is not null then
        if trunc(p_date_from) > trunc(p_date_to) then
          hr_utility.set_message(8301,'GHR_38196_TO_DATE_LESSER');
          hr_utility.raise_error;
        end if;
      end if;


  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_date_from;
--
-- ----------------------------------------------------------------------------
-- |------< chk_unique_act_lac_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the combination of nature_of_action_id
--   and lac_lookup_code is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   nature_of_action_id
--   lac_lookup_code
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

Procedure chk_unique_act_lac_cd (   p_noac_la_id          in number,
                            p_nature_of_action_id         in number,
                            p_lac_lookup_code             in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72) ;
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
   cursor c1 is
     select null
     from ghr_noac_las a
     where a.nature_of_action_id = p_nature_of_action_id
       and a.lac_lookup_code           = p_lac_lookup_code;
  --
Begin
  --
  l_proc  := g_package||'chk_unique_act_lac_cd';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if (l_api_updating
      and ( p_nature_of_action_id
      <> nvl(ghr_nla_shd.g_old_rec.nature_of_action_id,hr_api.g_number)
          or
          p_lac_lookup_code
      <> nvl(ghr_nla_shd.g_old_rec.lac_lookup_code,hr_api.g_varchar2)
          )
      or not l_api_updating) then
    --
    -- check if the combination of action_id and lac_lookup_code already exits
    --
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  --
      open c1;
       --
  --
  hr_utility.set_location('Entering:'||l_proc, 16);
  --
       fetch c1 into l_dummy;
  --
  hr_utility.set_location('Entering:'||l_proc, 17);
  --
       if c1%found then
        --
        close c1;
        --
  --
  hr_utility.set_location('Entering:'||l_proc, 18);
  --
        -- raise error as the combination already exists
        --
          hr_utility.set_message(8301,'GHR_NOAC_LAC_DUPLICATE');
          hr_utility.raise_error;
       end if;
       --
      close c1;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,25);
  --
end chk_unique_act_lac_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_lac_lookup_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   noac_la_id PK of record being inserted or updated.
--   lac_lookup_code Value of lookup code.
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
Procedure chk_lac_lookup_code(p_noac_la_id                in number,
                            p_lac_lookup_code             in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc varchar2(72) ;
  l_api_updating boolean;
  --
Begin
  --
  l_proc := g_package||'chk_lac_lookup_code';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ghr_nla_shd.api_updating
    (p_noac_la_id                => p_noac_la_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_lac_lookup_code
      <> nvl(ghr_nla_shd.g_old_rec.lac_lookup_code,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'GHR_US_LEGAL_AUTHORITY',
           p_lookup_code    => p_lac_lookup_code,
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
end chk_lac_lookup_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_nla_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc := g_package||'insert_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info;
  --
  -- Call all supporting business operations
  --
  chk_noac_la_id
  (p_noac_la_id          => p_rec.noac_la_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nature_of_action_id
  (p_noac_la_id          => p_rec.noac_la_id,
   p_nature_of_action_id          => p_rec.nature_of_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enabled_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_enabled_flag         => p_rec.enabled_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_second_lac_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_valid_second_lac_flag         => p_rec.valid_second_lac_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_first_lac_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_valid_first_lac_flag         => p_rec.valid_first_lac_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_date_from
  (p_noac_la_id                => p_rec.noac_la_id,
   p_date_from                 => p_rec.date_from,
   p_date_to                   => p_rec.date_to,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_unique_act_lac_cd
   (p_noac_la_id                => p_rec.noac_la_id,
    p_nature_of_action_id       => p_rec.nature_of_action_id,
    p_lac_lookup_code           => p_rec.lac_lookup_code,
    p_object_version_number     => p_rec.object_version_number);
  --
  chk_lac_lookup_code
    (p_noac_la_id                => p_rec.noac_la_id,
     p_lac_lookup_code           => p_rec.lac_lookup_code,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_nla_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc varchar2(72);
--
Begin
  l_proc := g_package||'update_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Set up the CLIENT_INFO
  --
  ghr_utility.set_client_info;
  --
  -- Call all supporting business operations
  --
  chk_noac_la_id
  (p_noac_la_id          => p_rec.noac_la_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_nature_of_action_id
  (p_noac_la_id          => p_rec.noac_la_id,
   p_nature_of_action_id          => p_rec.nature_of_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enabled_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_enabled_flag         => p_rec.enabled_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_second_lac_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_valid_second_lac_flag         => p_rec.valid_second_lac_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_valid_first_lac_flag
  (p_noac_la_id          => p_rec.noac_la_id,
   p_valid_first_lac_flag         => p_rec.valid_first_lac_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_date_from
  (p_noac_la_id                => p_rec.noac_la_id,
   p_date_from                 => p_rec.date_from,
   p_date_to                   => p_rec.date_to,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_unique_act_lac_cd
   (p_noac_la_id                => p_rec.noac_la_id,
    p_nature_of_action_id       => p_rec.nature_of_action_id,
    p_lac_lookup_code           => p_rec.lac_lookup_code,
    p_object_version_number     => p_rec.object_version_number);
  --
  chk_lac_lookup_code
    (p_noac_la_id                => p_rec.noac_la_id,
     p_lac_lookup_code           => p_rec.lac_lookup_code,
     p_effective_date            => p_effective_date,
     p_object_version_number     => p_rec.object_version_number);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_nla_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) ;
--
Begin
  l_proc := g_package||'delete_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ghr_nla_bus;

/
