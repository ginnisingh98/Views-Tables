--------------------------------------------------------
--  DDL for Package Body BEN_PUM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PUM_BUS" as
/* $Header: bepumrhi.pkb 120.0 2005/05/28 11:26:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pum_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pop_up_messages_id >------|
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
--   pop_up_messages_id PK of record being inserted or updated.
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
Procedure chk_pop_up_messages_id(p_pop_up_messages_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pop_up_messages_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pop_up_messages_id,hr_api.g_number)
     <>  ben_pum_shd.g_old_rec.pop_up_messages_id) then
    --
    -- raise error as PK has changed
    --
    ben_pum_shd.constraint_error('BEN_POP_UP_MESSAGES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pop_up_messages_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pum_shd.constraint_error('BEN_POP_UP_MESSAGES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pop_up_messages_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_formula_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pop_up_messages_id PK of record being inserted or updated.
--   no_formula_flag Value of lookup code.
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
Procedure chk_no_formula_flag(p_pop_up_messages_id                in number,
                            p_no_formula_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_formula_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_formula_flag
      <> nvl(ben_pum_shd.g_old_rec.no_formula_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_formula_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_formula_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_no_formula_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_formula_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_formula_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Id is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pop_up_messages_id PK of record being inserted or updated.
--   formula_id Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_formula_id(p_pop_up_messages_id              in number,
                             p_formula_id                  in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_formula_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_formula_id
    and    ff.formula_type_id in ( -508, -520, -521,-522,-523,-524,-525)
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) =
               p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
               pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id          => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_formula_id,hr_api.g_number)
      <> ben_pum_shd.g_old_rec.formula_id
      or not l_api_updating)
      and p_formula_id is not null then
    --
    -- check if value of formula id is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_formula_id);
        fnd_message.set_token('TYPE_ID',-508);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_formula_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_function_name >------|
-- ----------------------------------------------------------------------------
Procedure chk_function_name(p_pop_up_messages_id         in number,
                             p_function_name              in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_function_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_form_functions_vl ff
    where  ff.function_name = p_function_name;
    /*     ff.application_id = 810 */
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id         => p_pop_up_messages_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_function_name,hr_api.g_varchar2)
      <> ben_pum_shd.g_old_rec.function_name
      or not l_api_updating)
      and p_function_name is not null then
    --
    -- check if value of function name is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        hr_utility.set_message(801,'FUNCTION_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_function_name;
--

-- ----------------------------------------------------------------------------
-- |------< chk_message >------|
-- ----------------------------------------------------------------------------
Procedure chk_message(p_pop_up_messages_id         in number,
                             p_message              in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_message';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_new_messages mes
    where  mes.message_name = p_message;
    /*     ff.application_id = 810 */
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id         => p_pop_up_messages_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_message,hr_api.g_varchar2)
      <> ben_pum_shd.g_old_rec.message
      or not l_api_updating)
      and p_message is not null then
    --
    -- check if value of function name is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        hr_utility.set_message(801,'MESSAGE_DOES_NOT_EXIST');
        hr_utility.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_message;

-- ----------------------------------------------------------------------------
-- |------< chk_block_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
Procedure chk_block_name(p_pop_up_messages_id                in number,
                            p_block_name               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_block_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_block_name
      <> nvl(ben_pum_shd.g_old_rec.block_name,hr_api.g_varchar2)
      or not l_api_updating)
      and p_block_name is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BLOCK',
           p_lookup_code    => p_block_name,
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
end chk_block_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_field_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
Procedure chk_field_name(p_pop_up_messages_id                in number,
                            p_field_name               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_field_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_field_name
      <> nvl(ben_pum_shd.g_old_rec.field_name,hr_api.g_varchar2)
      or not l_api_updating)
      and p_field_name is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FIELD',
           p_lookup_code    => p_field_name,
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
end chk_field_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_event_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
Procedure chk_event_name(p_pop_up_messages_id                in number,
                            p_event_name               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_event_name';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_event_name
      <> nvl(ben_pum_shd.g_old_rec.event_name,hr_api.g_varchar2)
      or not l_api_updating)
      and p_event_name is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EVENT',
           p_lookup_code    => p_event_name,
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
end chk_event_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_message_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
Procedure chk_message_type(p_pop_up_messages_id                in number,
                            p_message_type               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_message_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_message_type
      <> nvl(ben_pum_shd.g_old_rec.message_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_message_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MESSAGE_TYP',
           p_lookup_code    => p_message_type,
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
end chk_message_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_start_end_date >------|
-- ----------------------------------------------------------------------------
--
--
Procedure chk_start_end_date(p_pop_up_messages_id          in number,
                           p_start_date                  in date,
                           p_end_date                    in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_start_end_date';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id                => p_pop_up_messages_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_start_date > p_end_date
  then
      --
      -- raise error as does not exist as lookup
      --
      -- hr_utility.set_message(801,'BEN_9?????_START_END_DATE');
      -- changed the Message Name -- by -- ssarkar

      hr_utility.set_message(801,'BEN_92503_END_DT_GRTR_STRT_DT');
      hr_utility.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_start_end_date;

-- ---------------------------< Bug 3881942 >---------------------------------
-- |-----------< chk_blk_fld_evnt >----------|
-- ---------------------------------------------------------------------------
--
-- Description
-- This Procedure is to check that
--  1. If p_event_name is any of 'on-commit','key-exit','when-new-form-instance'
--     then
--     p_block_name is null and p_field_name is null.
--  2.If p_event_name is 'post-query'
--    then
--    p_field_name  is null.
--
Procedure chk_blk_fld_evnt(p_block_name in varchar2,
                           p_field_name in varchar2,
                           p_event_name in varchar2) is

--
l_proc  varchar2(72) := g_package||'chk_blk_fld_evnt';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,5);

  --
  if ( p_event_name in ('ON-COMMIT','KEY-EXIT','WHEN-NEW-FORM-INSTANCE') )
     and (p_block_name is not null or p_field_name is not null)
     then
     fnd_message.set_name('BEN','BEN_94071_BLK_FLD_EVNT');
     fnd_message.set_token('EVENT',hr_general.decode_lookup('BEN_EVENT',p_event_name));
     fnd_message.raise_error;
  end if;
--
  if (p_event_name = 'POST-QUERY') and (p_field_name is not null)
   then
   fnd_message.set_name('BEN','BEN_94072_FLD_EVNT');
   fnd_message.set_token('EVENT',hr_general.decode_lookup('BEN_EVENT',p_event_name));
   fnd_message.raise_error;
   end if;
--
   hr_utility.set_location('Leaving'||l_proc,10);
end chk_blk_fld_evnt ;
--
--

--
-- Bug No: 3942628
--
-- ----------------------------------------------------------------------------
-- |------< chk_pop_name >------|
-- ----------------------------------------------------------------------------
Procedure chk_pop_name(p_pop_up_messages_id         in number,
                       p_pop_name                   in varchar2,
                       p_effective_date             in date,
                       p_business_group_id          in number,
                       p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pop_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
cursor c1 is
  select null
   from   ben_pop_up_messages pum
   where  pum.business_group_id +0 = p_business_group_id
   and    pum.pop_up_messages_id <> nvl(p_pop_up_messages_id,-1)
   and    lower(pum.pop_name) = lower(p_pop_name);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pum_shd.api_updating
    (p_pop_up_messages_id         => p_pop_up_messages_id,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_pop_name,hr_api.g_varchar2)
      <> ben_pum_shd.g_old_rec.pop_name
      or not l_api_updating) then
    --
    -- Check if pop name is unique.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this pop-up name has already been used
        --
        fnd_message.set_name('BEN','BEN_94089_POP_NAME_UNIQ');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pop_name;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pum_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pop_up_messages_id
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_formula_flag
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_no_formula_flag         => p_rec.no_formula_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_formula_id
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_formula_id                  => p_rec.formula_id,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_function_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_function_name               => p_rec.function_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_message
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_message                     => p_rec.message,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_block_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_block_name                  => p_rec.block_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_field_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_field_name                  => p_rec.field_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_event_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_event_name                  => p_rec.event_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);

  --3881942
  chk_blk_fld_evnt
  (p_block_name                  => p_rec.block_name,
   p_field_name                  => p_rec.field_name,
   p_event_name                  => p_rec.event_name);

  --
  chk_message_type
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_message_type                => p_rec.message_type,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_start_end_date
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_start_date                  => p_rec.start_date,
   p_end_date                    => p_rec.end_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  -- Bug No: 3942628
  --
  chk_pop_name
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_pop_name                    => p_rec.pop_name,
   p_effective_date              => p_effective_date,
   p_business_group_id           => p_rec.business_group_id,
   p_object_version_number       => p_rec.object_version_number);
  -- Validate Bus Grp
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pum_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pop_up_messages_id
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_formula_flag
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_no_formula_flag         => p_rec.no_formula_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_formula_id
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_formula_id                  => p_rec.formula_id,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_function_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_function_name               => p_rec.function_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_message
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_message                     => p_rec.message,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_block_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_block_name                  => p_rec.block_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_field_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_field_name                  => p_rec.field_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_event_name
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_event_name                  => p_rec.event_name,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);

 -- 3881942
  chk_blk_fld_evnt
  (p_block_name                  => p_rec.block_name,
   p_field_name                  => p_rec.field_name,
   p_event_name                  => p_rec.event_name);

--
  chk_message_type
  (p_pop_up_messages_id         => p_rec.pop_up_messages_id,
   p_message_type                => p_rec.message_type,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_start_end_date
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_start_date                  => p_rec.start_date,
   p_end_date                    => p_rec.end_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  -- Bug No: 3942628
  --
  chk_pop_name
  (p_pop_up_messages_id          => p_rec.pop_up_messages_id,
   p_pop_name                    => p_rec.pop_name,
   p_effective_date              => p_effective_date,
   p_business_group_id           => p_rec.business_group_id,
   p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pum_shd.g_rec_type
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pop_up_messages_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pop_up_messages b
    where b.pop_up_messages_id      = p_pop_up_messages_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'pop_up_messages_id',
                             p_argument_value => p_pop_up_messages_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_pum_bus;

/
