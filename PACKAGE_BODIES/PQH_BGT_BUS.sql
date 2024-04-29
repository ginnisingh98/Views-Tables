--------------------------------------------------------
--  DDL for Package Body PQH_BGT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_BUS" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 hmehta noship $ */
--
-- ----------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------+
--
g_package  varchar2(33)	:= '  pqh_bgt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budget_id >------|
-- ----------------------------------------------------------------------------+
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
--   budget_id PK of record being inserted or updated.
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
Procedure chk_budget_id(p_budget_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_budget_id,hr_api.g_number)
     <>  pqh_bgt_shd.g_old_rec.budget_id) then
    --
    -- raise error as PK has changed
    --
    pqh_bgt_shd.constraint_error('PQH_BUDGETS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_budget_id is not null then
      --
      -- raise error as PK is not null
      --
      pqh_bgt_shd.constraint_error('PQH_BUDGETS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_budget_id;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budget_unit3_id >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_budget_id PK
--   p_budget_unit3_id ID of FK column
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
-- CANNOT Change Budget UOM for budgets whose STATUS = FROZEN
--
Procedure chk_budget_unit3_id (p_budget_id          in number,
                              p_status               in varchar2,
                            p_budget_unit3_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit3_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_shared_types a
    where  a.shared_type_id = p_budget_unit3_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
      p_object_version_number   => p_object_version_number);
  --
  -- If STATUS = FROZEN and UOM is changed then ERROR as you cannot change
  -- UOM for FROZEN budgets
  --
  if (l_api_updating
     and nvl(p_budget_unit3_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit3_id,hr_api.g_number)) then

      -- UOM is changed
      --
       if NVL(p_status,'X') = 'FROZEN' then
          --
          hr_utility.set_message(8302,'PQH_BUDGET_UOM_CHANGED');
          hr_utility.raise_error;
          --
       end if;

  end if;
  --
  if (l_api_updating
     and nvl(p_budget_unit3_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit3_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit3_id is not null then
    --
    -- check if budget_unit3_id value exists in per_shared_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_shared_types
        -- table.
        --
        pqh_bgt_shd.constraint_error('PQH_BUDGETS_FK4');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_unit3_id;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budget_unit2_id >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_budget_id PK
--   p_budget_unit2_id ID of FK column
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
Procedure chk_budget_unit2_id (p_budget_id          in number,
                              p_status               in varchar2,
                            p_budget_unit2_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit2_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_shared_types a
    where  a.shared_type_id = p_budget_unit2_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
      p_object_version_number   => p_object_version_number);
  --
  -- If STATUS = FROZEN and UOM is changed then ERROR as you cannot change
  -- UOM for FROZEN budgets
  --
  if (l_api_updating
     and nvl(p_budget_unit2_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit2_id,hr_api.g_number)) then

      -- UOM is changed
      --
      --
       if NVL(p_status,'X') = 'FROZEN' then
          --
          --
          hr_utility.set_message(8302,'PQH_BUDGET_UOM_CHANGED');
          hr_utility.raise_error;
          --
       end if;

  end if;

  --
  if (l_api_updating
     and nvl(p_budget_unit2_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit2_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit2_id is not null then
    --
    -- check if budget_unit2_id value exists in per_shared_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_shared_types
        -- table.
        --
        pqh_bgt_shd.constraint_error('PQH_BUDGETS_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_unit2_id;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budget_unit1_id >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_budget_id PK
--   p_budget_unit1_id ID of FK column
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
Procedure chk_budget_unit1_id (p_budget_id          in number,
                              p_status               in varchar2,
                            p_budget_unit1_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit1_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_shared_types a
    where  a.shared_type_id = p_budget_unit1_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
      p_object_version_number   => p_object_version_number);
  --
  -- If STATUS = FROZEN and UOM is changed then ERROR as you cannot change
  -- UOM for FROZEN budgets
  --
  if (l_api_updating
     and nvl(p_budget_unit1_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit1_id,hr_api.g_number)) then

      -- UOM is changed
      --
      --
       if NVL(p_status,'X') = 'FROZEN' then
          --
          --
          hr_utility.set_message(8302,'PQH_BUDGET_UOM_CHANGED');
          hr_utility.raise_error;
          --
       end if;

  end if;

  --
  if (l_api_updating
     and nvl(p_budget_unit1_id,hr_api.g_number)
     <> nvl(pqh_bgt_shd.g_old_rec.budget_unit1_id,hr_api.g_number)
     or not l_api_updating) and
     p_budget_unit1_id is not null then
    --
    -- check if budget_unit1_id value exists in per_shared_types table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_shared_types
        -- table.
        --
        pqh_bgt_shd.constraint_error('PQH_BUDGETS_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_budget_unit1_id;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_pos_control_budget >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure checks that there does not exist a position control budget
--   in the same period for the same unit type
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_budget_id PK
--   p_budget_start_date
--   p_budget_end_date
--   budget unit id's
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
Procedure chk_pos_control_budget (p_budget_id         in number,
                                  p_business_group_id in number ,
                                  p_budget_unit1_id   in number,
                                  p_budget_unit2_id   in number,
                                  p_budget_unit3_id   in number,
                                  p_budgeted_entity_cd in varchar2,
                                  p_budget_start_date in date,
                                  p_budget_end_date   in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_pos_control_budget';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_bgt_unit1_type   varchar2(30);
  l_bgt_unit2_type   varchar2(30);
  l_bgt_unit3_type   varchar2(30);
  --
  l_unit1_type   varchar2(30);
  l_unit2_type   varchar2(30);
  l_unit3_type   varchar2(30);
  l_unit_desc    varchar2(80);
  l_units        varchar2(200);

  cursor c1 is
    select budget_unit1_id,budget_unit2_id,budget_unit3_id,budget_name,budget_start_date,budget_end_date
    from   pqh_budgets
    where  position_control_flag ='Y'
    and (business_group_id = p_business_group_id and business_group_id is not null)
    and budget_start_date <p_budget_end_date
    and budget_end_date>p_budget_start_date
    and budget_id <> nvl(p_budget_id,0);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_budget_unit1_id is not null then
     l_bgt_unit1_type := pqh_wks_budget.get_unit_type(p_budget_unit1_id);
  end if;
  if p_budget_unit2_id is not null then
     l_bgt_unit2_type := pqh_wks_budget.get_unit_type(p_budget_unit2_id);
  end if;
  if p_budget_unit3_id is not null then
     l_bgt_unit3_type := pqh_wks_budget.get_unit_type(p_budget_unit3_id);
  end if;
  if p_budgeted_entity_cd ='OPEN' then
     hr_utility.set_message(8302,'PQH_BGT_OPEN_CTRL');
     hr_utility.raise_error;
  end if;
  for i in c1 loop
      l_units := '' ;
      if i.budget_unit1_id is not null then
         l_unit1_type := pqh_wks_budget.get_unit_type(i.budget_unit1_id);
         l_unit_desc  := pqh_wks_budget.get_unit_desc(i.budget_unit1_id);
         l_units := l_unit_desc;
      end if;
      if i.budget_unit2_id is not null then
         l_unit2_type := pqh_wks_budget.get_unit_type(i.budget_unit2_id);
         l_unit_desc  := pqh_wks_budget.get_unit_desc(i.budget_unit2_id);
         l_units := l_units||','||l_unit_desc;
      end if;
      if i.budget_unit3_id is not null then
         l_unit3_type := pqh_wks_budget.get_unit_type(i.budget_unit3_id);
         l_unit_desc  := pqh_wks_budget.get_unit_desc(i.budget_unit3_id);
         l_units := l_units||','||l_unit_desc;
      end if;
      if (l_unit1_type = nvl(l_bgt_unit1_type,'-1')) or
         (l_unit1_type = nvl(l_bgt_unit2_type,'-1')) or
         (l_unit1_type = nvl(l_bgt_unit3_type,'-1')) or
         (nvl(l_unit2_type,'-2') = nvl(l_bgt_unit1_type,'-1')) or
         (nvl(l_unit2_type,'-2') = nvl(l_bgt_unit2_type,'-1')) or
         (nvl(l_unit2_type,'-2') = nvl(l_bgt_unit3_type,'-1')) or
         (nvl(l_unit3_type,'-2') = nvl(l_bgt_unit1_type,'-1')) or
         (nvl(l_unit3_type,'-2') = nvl(l_bgt_unit2_type,'-1')) or
         (nvl(l_unit3_type,'-2') = nvl(l_bgt_unit3_type,'-1')) then
         hr_utility.set_message(8302,'PQH_BGV_POS_CTRL');
         hr_utility.set_message_token('BUDGET_NAME',i.budget_name);
         hr_utility.set_message_token('START_DATE',i.budget_start_date);
         hr_utility.set_message_token('END_DATE',i.budget_end_date);
         hr_utility.set_message_token('UNITS',l_units);
         hr_utility.raise_error;
      end if;
  end loop;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pos_control_budget;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_period_set_name >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_budget_id PK
--   p_period_set_name ID of FK column
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
Procedure chk_period_set_name (p_budget_id          in number,
                            p_period_set_name          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_period_set_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_calendars a
    where  a.period_set_name = p_period_set_name;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
     (p_budget_id            => p_budget_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_period_set_name,hr_api.g_varchar2)
     <> nvl(pqh_bgt_shd.g_old_rec.period_set_name,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- check if period_set_name value exists in pay_calendars table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_calendars
        -- table.
        --
        pqh_bgt_shd.constraint_error('PQH_BUDGETS_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_period_set_name;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_transfer_to_gl >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   transfer_to_gl_flag Value of lookup code.
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
Procedure chk_transfer_to_gl(p_budget_id                in number,
                             p_gl_budget_name           in varchar2,
                             p_gl_set_of_books_id       in number,
                             p_budget_start_date        in date,
                             p_budget_end_date          in date,
                             p_effective_date           in date,
                             p_position_control_flag    in varchar2,
                             p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transfer_to_gl';
 -- l_api_updating boolean;
  l_dummy varchar2(30);
  l_gl_budget_rec     gl_budgets%ROWTYPE;
  l_gl_bgt_start_date date;
  l_gl_bgt_end_date   date;
  l_gl_budget_range   varchar2(30);
  l_budget_range      varchar2(30);
-- check if the budget is defined in gl_budgets and the budget
-- has been opened i.e latest_opened_year IS NOT NULL

CURSOR csr_gl_budgets_rec IS
SELECT *
FROM gl_budgets
WHERE budget_name = p_gl_budget_name ;

CURSOR csr_gl_budget_dates IS
SELECT start_date,end_date
FROM gl_budgets_v
WHERE budget_name = p_gl_budget_name ;

Cursor csr_set_of_books is
SELECT 'X'
FROM   gl_sets_of_books a
WHERE a.set_of_books_id = nvl(p_gl_set_of_books_id,-9999);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  /*  commented out nocopy by kmullapu  to remove limitation that  controlled budget name should be
    similar to GL budget name for transfering to GL. A controll Bugdted can be transfered
    to any GL budget provided that controll budget falls with in GL budget date range.
     As a result of this we will not be using transfer_to_gl_flag

     l_api_updating := pqh_bgt_shd.api_updating
         (p_budget_id                => p_budget_id,
     p_object_version_number    => p_object_version_number);

  if (l_api_updating
      and p_transfer_to_gl_flag <> nvl(pqh_bgt_shd.g_old_rec.transfer_to_gl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_transfer_to_gl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_transfer_to_gl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
  end if;
  */
  IF (p_gl_budget_name is not null)  THEN
      -- check if this Bugdet falls with in GL budget date Range and
      -- get the set_of_books_id for this budget
      IF nvl(p_position_control_flag,'N') = 'Y' THEN
         OPEN csr_gl_budget_dates;
         FETCH csr_gl_budget_dates INTO l_gl_bgt_start_date,l_gl_bgt_end_date;
         IF (csr_gl_budget_dates%FOUND) THEN
           IF (p_budget_start_date < l_gl_bgt_start_date OR
               p_budget_start_date >= l_gl_bgt_end_date) THEN
             -- GL budget doest not cover Control Budget range
            l_gl_budget_range := fnd_date.date_to_displaydate(l_gl_bgt_start_date)||' - '||fnd_date.date_to_displaydate(l_gl_bgt_end_date);
           l_budget_range := fnd_date.date_to_displaydate(p_budget_start_date)||' - '||fnd_date.date_to_displaydate(p_budget_end_date);
            hr_utility.set_message(8302,'PQH_GL_BUDGET_INVLD_DATE_RANGE');
            hr_utility.set_message_token('GL_BUDGET_DATE_RANGE',l_gl_budget_range);
            hr_utility.set_message_token('BUDGET_DATE_RANGE',l_budget_range);
            hr_utility.raise_error;
           END IF;
         ELSE
            -- budget Not defined in GL
               hr_utility.set_message(8302,'PQH_GL_BUDGET_INVALID');
               hr_utility.raise_error;
         END IF;
         OPEN csr_gl_budgets_rec;
         FETCH csr_gl_budgets_rec INTO l_gl_budget_rec;
         CLOSE csr_gl_budgets_rec;
         IF l_gl_budget_rec.budget_name IS NULL THEN
            -- budget Not defined in GL
            hr_utility.set_message(8302,'PQH_GL_BUDGET_INVALID');
            hr_utility.raise_error;
         ELSIF NVL(l_gl_budget_rec.status,'Z') = 'C' THEN
            -- GL Budget is already closed
            -- raise error
            hr_utility.set_message(8302,'PQH_GL_BUDGET_CLOSED');
            hr_utility.raise_error;
         ELSIF l_gl_budget_rec.latest_opened_year IS NULL THEN
            -- latest open year for the GL budget is null
            -- raise error
            hr_utility.set_message(8302,'PQH_GL_BUDGET_YEAR');
            hr_utility.raise_error;
            -- hmehta Changed set_of_books_id to ledger_id for bug4602435
         ELSIF l_gl_budget_rec.ledger_id <> p_gl_set_of_books_id THEN
            -- Budget set of books does not match with GL budget set of books
            -- raise error
            hr_utility.set_message(8302,'PQH_GL_SOB_DIFFERENT');
            hr_utility.raise_error;
         else
            open csr_set_of_books;
            fetch csr_set_of_books into l_dummy;
            if csr_set_of_books%notfound then
               hr_utility.set_message(8302,'PQH_INVALID_SET_OF_BOOKS');
               hr_utility.raise_error;
            end if;
         END IF;
      else
         -- Budget must be a Controlled budget to be marked transfer to gl
         -- raise error
         hr_utility.set_message(8302,'PQH_TRANSFER_TO_GL');
         hr_utility.raise_error;
      END IF;
   END IF;
   --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_transfer_to_gl;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_transfer_to_grants_flag >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   transfer_to_grants_flag Value of lookup code.
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
Procedure chk_transfer_to_grants_flag(p_budget_id               in number,
                                      p_transfer_to_grants_flag in varchar2,
                                      p_position_control_flag   in varchar2,
                                      p_effective_date          in date,
                                      p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_transfer_to_grants_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_transfer_to_grants_flag
      <> nvl(pqh_bgt_shd.g_old_rec.transfer_to_grants_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_transfer_to_grants_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_transfer_to_grants_flag,
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
  if nvl(p_transfer_to_grants_flag,'N') ='Y' then
     if nvl(p_position_control_flag,'N') ='N' then
        -- Budget must be a Controlled budget to be marked transfer to grants
        -- raise error
        hr_utility.set_message(8302,'PQH_TRANSFER_TO_GRANTS');
        hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_transfer_to_grants_flag;
--
-- ---------------------------------------------------------------------------+
-- |------< chk_status >------|
-- ---------------------------------------------------------------------------+
--
Procedure chk_status(p_budget_id                in number,
                     p_status               in varchar2,
                     p_effective_date              in date,
                     p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_status
      <> nvl(pqh_bgt_shd.g_old_rec.status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_status <> 'FROZEN' then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(8302,'PQH_INVAILD_BUDGET_STATUS');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_status;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budget_style_cd >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   budget_style_cd Value of lookup code.
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
Procedure chk_budget_style_cd(p_budget_id                in number,
                            p_budget_style_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_style_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_style_cd
      <> nvl(pqh_bgt_shd.g_old_rec.budget_style_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BUDGET_STYLE',
           p_lookup_code    => p_budget_style_cd,
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
end chk_budget_style_cd;
--
-- ----------------------------------------------------------------------------+
-- |------< chk_budgeted_entity_cd >------|
-- ----------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   budgeted_entity_cd Value of lookup code.
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
Procedure chk_budgeted_entity_cd(p_budget_id                in number,
                            p_budgeted_entity_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budgeted_entity_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budgeted_entity_cd
      <> nvl(pqh_bgt_shd.g_old_rec.budgeted_entity_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_budgeted_entity_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BUDGET_ENTITY',
           p_lookup_code    => p_budgeted_entity_cd,
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
end chk_budgeted_entity_cd;
--
-- ---------------------------------------------------------------------------+
-- |------< chk_budget_start_date >------|
-- ---------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   budget_start_date Value of lookup code.
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
Procedure chk_budget_start_date(p_budget_id                in number,
                            p_budget_start_date               in date,
                            p_budget_end_date               in date,
                            p_period_set_name          in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_start_date';
  l_api_updating boolean;
  l_min_budget_dt  date;
  l_min_wks_dt  date;
  l_min_cal_dt  date;
  l_cnt_periods    number(9);
  --
--
--
-- cursor to check if atleast one period exists

CURSOR cnt_periods IS
SELECT COUNT(*)
FROM per_time_periods
WHERE period_set_name = p_period_set_name
  AND start_date BETWEEN p_budget_start_date AND p_budget_end_date
  AND end_date BETWEEN p_budget_start_date AND p_budget_end_date ;

-- cursor to check start_date in per_time_periods table
CURSOR per_cal_start_dt_cur IS
SELECT MIN(start_date)
FROM  per_time_periods
WHERE period_set_name = p_period_set_name;

-- cursor to check in budget tables
CURSOR budget_date_cur IS
SELECT MIN(start_date)
FROM per_time_periods tp,
     pqh_budget_periods bpr,
     pqh_budget_details bdt,
     pqh_budget_versions bvr
WHERE time_period_id = bpr.start_time_period_id
  and bpr.budget_detail_id = bdt.budget_detail_id
  AND bdt.budget_version_id = bvr.budget_version_id
  and bvr.budget_id = p_budget_id;

 -- cursor to check in worksheet tables
CURSOR wks_date_cur IS
SELECT MIN(start_date)
FROM per_time_periods tp,
     pqh_worksheet_periods bpr,
     pqh_worksheet_details bdt,
     pqh_worksheets bvr
WHERE time_period_id = bpr.start_time_period_id
  and bpr.worksheet_detail_id = bdt.worksheet_detail_id
  AND bdt.worksheet_id = bvr.worksheet_id
  AND nvl(bvr.transaction_status,'PENDING') = 'PENDING'
  and bvr.budget_id = p_budget_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_start_date
      <> nvl(pqh_bgt_shd.g_old_rec.budget_start_date,hr_api.g_date)
      or not l_api_updating)
      and p_budget_start_date is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    OPEN budget_date_cur;
      FETCH budget_date_cur INTO l_min_budget_dt;
    CLOSE budget_date_cur;
    --
    OPEN wks_date_cur;
      FETCH wks_date_cur INTO l_min_wks_dt;
    CLOSE wks_date_cur;

    if (l_min_budget_dt IS NOT NULL)  THEN
        if (p_budget_start_date > l_min_budget_dt) THEN
          --
          -- raise error as does not exist as lookup
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_ST_DT');
          hr_utility.set_message_token('STARTDATE',to_char(l_min_budget_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
        end if;
    elsif (l_min_wks_dt IS NOT NULL) THEN
        if (p_budget_start_date > l_min_wks_dt) THEN
          --
          -- raise error as does not exist as lookup
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_ST_DT');
          hr_utility.set_message_token('STARTDATE',to_char(l_min_budget_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
        end if;

    end if;
    --
    -- check if start_date is less then end date
     if p_budget_start_date > p_budget_end_date then
      -- raise error as invalid date
       hr_utility.set_message(8302,'PQH_INVALID_END_DT');
       hr_utility.set_message_token('STARTDATE',to_char(p_budget_start_date,'DD-MM-RRRR'));
       hr_utility.set_message_token('ENDDATE',to_char(p_budget_end_date,'DD-MM-RRRR'));
       hr_utility.raise_error;
     end if;
    --
    --
    /*
       check if the budget_start_dt is >= the minimum date (start_date) in per_time_periods
       where period_set_name = period_set_name of the current budget
    */
      OPEN per_cal_start_dt_cur;
        FETCH per_cal_start_dt_cur INTO l_min_cal_dt;
      CLOSE per_cal_start_dt_cur;

      if p_budget_start_date < l_min_cal_dt then
          --
          hr_utility.set_message(8302,'PQH_BUDGET_ST_DT_CAL');
          hr_utility.set_message_token('CALSTART',to_char(l_min_cal_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
      end if;
    --
    --
    --
    -- check if atleast one period exists between the budget start and end date
       OPEN cnt_periods;
         FETCH cnt_periods INTO l_cnt_periods;
       CLOSE cnt_periods;

       IF NVL(l_cnt_periods,0) = 0 THEN
        -- error as no periods
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_DTS');
          hr_utility.raise_error;
          --
       END IF;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_start_date;
--
-- ---------------------------------------------------------------------------+
-- |------< chk_budget_end_date >------|
-- ---------------------------------------------------------------------------+
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   budget_end_date Value of lookup code.
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
Procedure chk_budget_end_date(p_budget_id                in number,
                            p_budget_start_date               in date,
                            p_budget_end_date               in date,
                            p_period_set_name          in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_end_date';
  l_api_updating boolean;
  l_max_budget_dt  date;
  l_max_wks_dt     date;
  l_max_cal_dt     date;
  l_cnt_periods    number(9);
  --
--
--
-- cursor to check if atleast one period exists

CURSOR cnt_periods IS
SELECT COUNT(*)
FROM per_time_periods
WHERE period_set_name = p_period_set_name
  AND start_date BETWEEN p_budget_start_date AND p_budget_end_date
  AND end_date BETWEEN p_budget_start_date AND p_budget_end_date ;
--

-- cursor to check end_date in per_time_periods table
CURSOR per_cal_end_dt_cur IS
SELECT MAX(end_date)
FROM per_time_periods
WHERE period_set_name = p_period_set_name;
  --
-- cursor to check in budget tables
CURSOR budget_date_cur IS
SELECT MIN(start_date)
FROM per_time_periods tp,
     pqh_budget_periods bpr,
     pqh_budget_details bdt,
     pqh_budget_versions bvr
WHERE time_period_id = bpr.start_time_period_id
  and bpr.budget_detail_id = bdt.budget_detail_id
  AND bdt.budget_version_id = bvr.budget_version_id
  and bvr.budget_id = p_budget_id;

 -- cursor to check in worksheet tables
CURSOR wks_date_cur IS
SELECT MIN(start_date)
FROM per_time_periods tp,
     pqh_worksheet_periods bpr,
     pqh_worksheet_details bdt,
     pqh_worksheets bvr
WHERE time_period_id = bpr.start_time_period_id
  and bpr.worksheet_detail_id = bdt.worksheet_detail_id
  AND bdt.worksheet_id = bvr.worksheet_id
  AND nvl(bvr.transaction_status,'PENDING') = 'PENDING'
  and bvr.budget_id = p_budget_id;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_budget_end_date
      <> nvl(pqh_bgt_shd.g_old_rec.budget_end_date,hr_api.g_date)
      or not l_api_updating)
      and p_budget_end_date is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    OPEN budget_date_cur;
      FETCH budget_date_cur INTO l_max_budget_dt;
    CLOSE budget_date_cur;
    --
    OPEN wks_date_cur;
      FETCH wks_date_cur INTO l_max_wks_dt;
    CLOSE wks_date_cur;

    if (l_max_budget_dt IS NOT NULL)  THEN
        if (p_budget_end_date < l_max_budget_dt) THEN
          --
          -- raise error as does not exist as lookup
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_END_DT');
          hr_utility.set_message_token('ENDDATE',to_char(l_max_budget_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
        end if;
    elsif (l_max_wks_dt IS NOT NULL) THEN
        if (p_budget_end_date < l_max_wks_dt) THEN
          --
          -- raise error as does not exist as lookup
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_END_DT');
          hr_utility.set_message_token('ENDDATE',to_char(l_max_budget_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
        end if;
    end if;
    --
    -- check if start_date is less then end date
     if p_budget_start_date > p_budget_end_date then
      -- raise error as invalid date
       hr_utility.set_message(8302,'PQH_INVALID_END_DT');
       hr_utility.set_message_token('STARTDATE',to_char(p_budget_start_date,'DD-MM-RRRR'));
       hr_utility.set_message_token('ENDDATE',to_char(p_budget_end_date,'DD-MM-RRRR'));
       hr_utility.raise_error;
     end if;
    --
    --
    /*
       check if the budget_end_dt is <= the maximum date (end_date) in per_time_periods
       where period_set_name = period_set_name of the current budget
    */
      OPEN per_cal_end_dt_cur;
        FETCH per_cal_end_dt_cur INTO l_max_cal_dt;
      CLOSE per_cal_end_dt_cur;

      if p_budget_end_date > l_max_cal_dt then
          --
          hr_utility.set_message(8302,'PQH_BUDGET_END_DT_CAL');
          hr_utility.set_message_token('CALENDT',to_char(l_max_cal_dt,'DD-MM-RRRR'));
          hr_utility.raise_error;
          --
      end if;
    --
    --
    -- check if atleast one period exists between the budget start and end date
       OPEN cnt_periods;
         FETCH cnt_periods INTO l_cnt_periods;
       CLOSE cnt_periods;

       IF NVL(l_cnt_periods,0) = 0 THEN
        -- error as no periods
          --
          hr_utility.set_message(8302,'PQH_INVALID_BUDGET_DTS');
          hr_utility.raise_error;
          --
       END IF;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_end_date;
--
-- ----------------------------------------------------------------------------+
-- |---------------------------< chk_budget_unit_id >----------------------------|
-- ----------------------------------------------------------------------------+
Procedure chk_budget_unit_id(p_budget_unit1_id               in number,
                             p_budget_unit2_id               in number,
                             p_budget_unit3_id               in number,
                             p_position_control_flag         in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit_id';

 cursor csr_lookup_cd(p_shared_type_id in number) is
 select system_type_cd
 from per_shared_types
 where shared_type_id = p_shared_type_id;

 l_system_type_cd1            VARCHAR2(50);
 l_system_type_cd2            VARCHAR2(50);
 l_system_type_cd3            VARCHAR2(50);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check for duplicate UOM
  -- compare 1 and 2

    if p_budget_unit1_id IS NOT NULL and p_budget_unit2_id IS NOT NULL then
      if p_budget_unit1_id = p_budget_unit2_id then
        -- we have duplicate so error message
        --
          hr_utility.set_message(8302,'PQH_DUPLICATE_UOM');
          hr_utility.raise_error;
        --

      end if;

      -- get the system_type_cd for both and compare the system_type_cd i.e lookup_cd
        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit1_id);
          FETCH csr_lookup_cd INTO l_system_type_cd1;
        CLOSE csr_lookup_cd;

        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit2_id);
          FETCH csr_lookup_cd INTO l_system_type_cd2;
        CLOSE csr_lookup_cd;

        if NVL(p_position_control_flag,'N') = 'Y' then
          -- compare the system_type_cd
           if l_system_type_cd1 = l_system_type_cd2 then
             -- we have duplicate lookup code for PC budget, so error message
             --
               hr_utility.set_message(8302,'PQH_DUP_SYSTEM_TYPE_CD');
               hr_utility.set_message_token('UNIT_ONE','Unit1');
               hr_utility.set_message_token('UNIT_TWO','Unit2');
               hr_utility.raise_error;
             --

           end if; -- end compare the system_type_cd for PC budget
        end if; -- p_position_control_flag is Y


    end if; -- either is null so no compare

  --
  -- compare 2 and 3

    if p_budget_unit2_id IS NOT NULL and p_budget_unit3_id IS NOT NULL then
      if p_budget_unit2_id = p_budget_unit3_id then
        -- we have duplicate so error message
        --
          hr_utility.set_message(8302,'PQH_DUPLICATE_UOM');
          hr_utility.raise_error;
        --

      end if;

      -- get the system_type_cd for both and compare the system_type_cd i.e lookup_cd
        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit2_id);
          FETCH csr_lookup_cd INTO l_system_type_cd2;
        CLOSE csr_lookup_cd;

        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit3_id);
          FETCH csr_lookup_cd INTO l_system_type_cd3;
        CLOSE csr_lookup_cd;

        if NVL(p_position_control_flag,'N') = 'Y' then
          -- compare the system_type_cd
           if l_system_type_cd2 = l_system_type_cd3 then
             -- we have duplicate lookup code for PC budget, so error message
             --
               hr_utility.set_message(8302,'PQH_DUP_SYSTEM_TYPE_CD');
               hr_utility.set_message_token('UNIT_ONE','Unit2');
               hr_utility.set_message_token('UNIT_TWO','Unit3');
               hr_utility.raise_error;
             --

           end if; -- end compare the system_type_cd for PC budget
        end if; -- p_position_control_flag is Y

    end if; -- either is null so no compare

  --
  -- compare 3 and 1

    if p_budget_unit3_id IS NOT NULL and p_budget_unit1_id IS NOT NULL then
      if p_budget_unit3_id = p_budget_unit1_id then
        -- we have duplicate so error message
        --
          hr_utility.set_message(8302,'PQH_DUPLICATE_UOM');
          hr_utility.raise_error;
        --

      end if;

      -- get the system_type_cd for both and compare the system_type_cd i.e lookup_cd
        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit3_id);
          FETCH csr_lookup_cd INTO l_system_type_cd3;
        CLOSE csr_lookup_cd;

        OPEN csr_lookup_cd(p_shared_type_id => p_budget_unit1_id);
          FETCH csr_lookup_cd INTO l_system_type_cd1;
        CLOSE csr_lookup_cd;

        if NVL(p_position_control_flag,'N') = 'Y' then
          -- compare the system_type_cd
           if l_system_type_cd3 = l_system_type_cd1 then
             -- we have duplicate lookup code for PC budget, so error message
             --
               hr_utility.set_message(8302,'PQH_DUP_SYSTEM_TYPE_CD');
               hr_utility.set_message_token('UNIT_ONE','Unit1');
               hr_utility.set_message_token('UNIT_TWO','Unit3');
               hr_utility.raise_error;
             --

           end if; -- end compare the system_type_cd for PC budget
        end if; -- p_position_control_flag is Y


    end if; -- either is null so no compare

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_unit_id;

--
-- ---------------------------------------------------------------------------+
-- |---------------------------< chk_budget_name >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure chk_budget_name (p_budget_id                in number,
                            p_budget_name               in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_name';
  --
l_dummy   varchar2(1) ;

 cursor csr_budget_name is
 select 'X'
 from pqh_budgets
 where budget_name = p_budget_name
   and budget_id <> nvl(p_budget_id,0);

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_budget_name;
   fetch csr_budget_name into l_dummy;
  close csr_budget_name;

    if nvl(l_dummy ,'Y') = 'X' then
      --
       hr_utility.set_message(8302,'PQH_DUPLICATE_BUDGET_NAME');
       hr_utility.raise_error;
      --
    end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_name;

--
-- ---------------------------------------------------------------------------+
-- |------< chk_budget_unit1_aggregate >------|
-- ---------------------------------------------------------------------------+
--
Procedure chk_budget_unit1_aggregate(p_budget_id          in number,
                            p_budget_unit1_id             in number,
                            p_budget_unit1_aggregate      in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit1_aggregate';
  l_api_updating boolean;
  l_uom_cd       varchar2(50);
  l_shared_type_name varchar2(50);

  cursor csr_unit is
  select a.system_type_cd,
         a.shared_type_name
  from   per_shared_types a
  where  a.shared_type_id = p_budget_unit1_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and
      (
       p_budget_unit1_aggregate
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit1_aggregate,hr_api.g_varchar2)
       or
       p_budget_unit1_id
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit1_id,hr_api.g_number)
       )
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BGT_UOM_AGGREGATE',
           p_lookup_code    => p_budget_unit1_aggregate,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if; -- invalid lookup
    --
    -- check if value is valid
    -- either both unit1_id and unit1_aggregate must be null or both not null
    --
      if (p_budget_unit1_id is not null and p_budget_unit1_aggregate is null     ) or
         (p_budget_unit1_id is null     and p_budget_unit1_aggregate is not null )then
        --
        -- invalid values
        --
           hr_utility.set_message(8302,'PQH_INVALID_UNIT_AGGREGATE');
           hr_utility.raise_error;
        --

      end if; -- both null or not null
      --
      -- if unit1 is money then aggregate must be Accumulate
      --
         if p_budget_unit1_id is not null then
           open csr_unit;
            fetch csr_unit into l_uom_cd, l_shared_type_name;
           close csr_unit;

            if l_uom_cd = 'MONEY' and p_budget_unit1_aggregate <> 'ACCUMULATE' then
             --
             -- invalid values
             --
                hr_utility.set_message(8302,'PQH_INVALID_AGGREGATE_VAL');
                hr_utility.set_message_token('UOM',l_shared_type_name);
                hr_utility.raise_error;
             --
            end if; -- invalid aggregate value for money
         end if; -- p_budget_unit1_id is not null

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_unit1_aggregate;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit2_aggregate >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_budget_unit2_aggregate(p_budget_id          in number,
                            p_budget_unit2_id             in number,
                            p_budget_unit2_aggregate      in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit2_aggregate';
  l_api_updating boolean;
  l_uom_cd       varchar2(50);
  l_shared_type_name varchar2(50);

  cursor csr_unit is
  select a.system_type_cd,
         a.shared_type_name
  from   per_shared_types a
  where  a.shared_type_id = p_budget_unit2_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and
      (
       p_budget_unit2_aggregate
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit2_aggregate,hr_api.g_varchar2)
       or
       p_budget_unit2_id
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit2_id,hr_api.g_number)
       )
      or ( not l_api_updating and p_budget_unit2_aggregate IS NOT NULL)) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BGT_UOM_AGGREGATE',
           p_lookup_code    => p_budget_unit2_aggregate,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if; -- invalid lookup
    --
    -- check if value is valid
    -- either both unit2_id and unit2_aggregate must be null or both not null
    --
      if (p_budget_unit2_id is not null and p_budget_unit2_aggregate is null     ) or
         (p_budget_unit2_id is null     and p_budget_unit2_aggregate is not null )then
        --
        -- invalid values
        --
           hr_utility.set_message(8302,'PQH_INVALID_UNIT_AGGREGATE');
           hr_utility.raise_error;
        --

      end if; -- both null or not null
      --
      -- if unit2 is money then aggregate must be Accumulate
      --
         if p_budget_unit2_id is not null then
           open csr_unit;
            fetch csr_unit into l_uom_cd, l_shared_type_name;
           close csr_unit;

            if l_uom_cd = 'MONEY' and p_budget_unit2_aggregate <> 'ACCUMULATE' then
             --
             -- invalid values
             --
                hr_utility.set_message(8302,'PQH_INVALID_AGGREGATE_VAL');
                hr_utility.set_message_token('UOM',l_shared_type_name);
                hr_utility.raise_error;
             --
            end if; -- invalid aggregate value for money
         end if; -- p_budget_unit2_id is not null





  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_unit2_aggregate;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_budget_unit3_aggregate >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_budget_unit3_aggregate(p_budget_id          in number,
                            p_budget_unit3_id             in number,
                            p_budget_unit3_aggregate      in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_budget_unit3_aggregate';
  l_api_updating boolean;
  l_uom_cd       varchar2(50);
  l_shared_type_name varchar2(50);

  cursor csr_unit is
  select a.system_type_cd,
         a.shared_type_name
  from   per_shared_types a
  where  a.shared_type_id = p_budget_unit3_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and
      (
       p_budget_unit3_aggregate
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit3_aggregate,hr_api.g_varchar2)
       or
       p_budget_unit3_id
        <> nvl(pqh_bgt_shd.g_old_rec.budget_unit3_id,hr_api.g_number)
       )
      or ( not l_api_updating and p_budget_unit3_aggregate IS NOT NULL)) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PQH_BGT_UOM_AGGREGATE',
           p_lookup_code    => p_budget_unit3_aggregate,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if; -- invalid lookup
    --
    -- check if value is valid
    -- either both unit3_id and unit3_aggregate must be null or both not null
    --
      if (p_budget_unit3_id is not null and p_budget_unit3_aggregate is null     ) or
         (p_budget_unit3_id is null     and p_budget_unit3_aggregate is not null )then
        --
        -- invalid values
        --
           hr_utility.set_message(8302,'PQH_INVALID_UNIT_AGGREGATE');
           hr_utility.raise_error;
        --

      end if; -- both null or not null
      --
      -- if unit3 is money then aggregate must be Accumulate
      --
         if p_budget_unit3_id is not null then
           open csr_unit;
            fetch csr_unit into l_uom_cd, l_shared_type_name;
           close csr_unit;

            if l_uom_cd = 'MONEY' and p_budget_unit3_aggregate <> 'ACCUMULATE' then
             --
             -- invalid values
             --
                hr_utility.set_message(8302,'PQH_INVALID_AGGREGATE_VAL');
                hr_utility.set_message_token('UOM',l_shared_type_name);
                hr_utility.raise_error;
             --
            end if; -- invalid aggregate value for money
         end if; -- p_budget_unit3_id is not null





  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_budget_unit3_aggregate;
--
-- ----------------------------------------------------------------------------
-- |------< chk_position_control_flag >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_position_control_flag(p_budget_id                in number,
                            p_position_control_flag               in varchar2,
                            p_budgeted_entity_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_position_control_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                   => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_position_control_flag
      <> nvl(pqh_bgt_shd.g_old_rec.position_control_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_position_control_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_position_control_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    --
/*
    -- commented out by sgoyal to make controlled budget span across any entity and
    -- not restricted by Position as entity.
    -- rest of things remain the same. At a given day we can have only one controlled
    -- budget for a BG and a unit type and it can have any entity.
    -- check if budgeted_entity_cd is POSITION for posn ctrl flag Y
    --
    if NVL(p_position_control_flag,'N') = 'Y' then
       if NVL(p_budgeted_entity_cd,'X') <> 'POSITION' then
         --
         -- raise error
         --
         hr_utility.set_message(8302,'PQH_INVALID_BDGT_ENTITY');
         hr_utility.raise_error;

       end if;
    end if; -- pos ctl flag Y
    --
    --
*/

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_position_control_flag;

--
--
-- ----------------------------------------------------------------------------
-- |------< chk_currency_code >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_currency_code (p_budget_id          in number,
                            p_currency_code          in varchar2,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_currency_code';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   fnd_currencies a
    where  a.currency_code = p_currency_code;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
     (p_budget_id            => p_budget_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_currency_code,hr_api.g_varchar2)
     <> nvl(pqh_bgt_shd.g_old_rec.currency_code,hr_api.g_varchar2)
     or not l_api_updating) and
     p_currency_code is not null  then
    --
    -- check if currency_code value exists in fnd_currencies table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in fnd_currencies
        -- table.
        --
        pqh_bgt_shd.constraint_error('PQH_BUDGETS_FK5');
        --
      end if;
      --
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_currency_code;

--
--
-- ----------------------------------------------------------------------------
-- |------< chk_psb_budget_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   budget_id PK of record being inserted or updated.
--   psb_budget_flag Value of lookup code.
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
Procedure chk_psb_budget_flag(p_budget_id               in number,
                              p_psb_budget_flag         in varchar2,
                              p_gl_budget_name          in varchar2,
                              p_effective_date          in date,
                              p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_psb_budget_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pqh_bgt_shd.api_updating
    (p_budget_id                => p_budget_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (p_psb_budget_flag <> nvl(pqh_bgt_shd.g_old_rec.psb_budget_flag,hr_api.g_varchar2)
      or p_gl_budget_name <> nvl(pqh_bgt_shd.g_old_rec.gl_budget_name,hr_api.g_varchar2))
      or not l_api_updating)
      and p_psb_budget_flag is not null then
  hr_utility.set_location('check is being fired'||l_proc, 7);
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_psb_budget_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
    if NVL(p_psb_budget_flag,'N') = 'Y' AND p_gl_budget_name is NULL  then
         --
         -- raise error
         --
         hr_utility.set_message(8302,'PQH_NOT_A_GL_BUDGET');
         hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_psb_budget_flag;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pqh_bgt_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_id
  (p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_id
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_budget_unit3_id          => p_rec.budget_unit3_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_id
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_budget_unit2_id          => p_rec.budget_unit2_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_id
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_budget_unit1_id          => p_rec.budget_unit1_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_period_set_name
  (p_budget_id          => p_rec.budget_id,
   p_period_set_name          => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfer_to_gl
  (p_budget_id             => p_rec.budget_id,
   p_gl_budget_name        => p_rec.gl_budget_name,
   p_gl_set_of_books_id    => p_rec.gl_set_of_books_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date       => p_rec.budget_end_date,
   p_position_control_flag => p_rec.position_control_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfer_to_grants_flag
  (p_budget_id               => p_rec.budget_id,
   p_transfer_to_grants_flag => p_rec.transfer_to_grants_flag,
   p_position_control_flag   => p_rec.position_control_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_status
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_style_cd
  (p_budget_id          => p_rec.budget_id,
   p_budget_style_cd         => p_rec.budget_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budgeted_entity_cd
  (p_budget_id          => p_rec.budget_id,
   p_budgeted_entity_cd         => p_rec.budgeted_entity_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_start_date
  (p_budget_id          => p_rec.budget_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date     => p_rec.budget_end_date,
   p_period_set_name     => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_end_date
  (p_budget_id          => p_rec.budget_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date     => p_rec.budget_end_date,
   p_period_set_name     => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_budget_unit_id
  (p_budget_unit1_id    => p_rec.budget_unit1_id,
   p_budget_unit2_id    => p_rec.budget_unit2_id,
   p_budget_unit3_id    => p_rec.budget_unit3_id,
   p_position_control_flag => p_rec.position_control_flag);
  --
 chk_budget_name
  (p_budget_id          => p_rec.budget_id,
   p_budget_name        => p_rec.budget_name );
  --
chk_budget_unit1_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit1_id         => p_rec.budget_unit1_id,
   p_budget_unit1_aggregate  => p_rec.budget_unit1_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
chk_budget_unit2_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit2_id         => p_rec.budget_unit2_id,
   p_budget_unit2_aggregate  => p_rec.budget_unit2_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
chk_budget_unit3_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit3_id         => p_rec.budget_unit3_id,
   p_budget_unit3_aggregate  => p_rec.budget_unit3_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
if nvl(p_rec.position_control_flag,'X') ='Y' then
   chk_pos_control_budget (p_budget_id         => p_rec.budget_id,
                           p_budgeted_entity_cd => p_rec.budgeted_entity_cd,
                           p_business_group_id => p_rec.business_group_id,
                           p_budget_unit1_id   => p_rec.budget_unit1_id,
                           p_budget_unit2_id   => p_rec.budget_unit2_id,
                           p_budget_unit3_id   => p_rec.budget_unit3_id,
                           p_budget_start_date => p_rec.budget_start_date,
                           p_budget_end_date   => p_rec.budget_end_date);
end if;
--
  chk_position_control_flag
  (p_budget_id             => p_rec.budget_id,
   p_position_control_flag => p_rec.position_control_flag,
   p_budgeted_entity_cd    => p_rec.budgeted_entity_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_currency_code
  (p_budget_id             => p_rec.budget_id,
   p_currency_code         => p_rec.currency_code,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_psb_budget_flag(p_budget_id              => p_rec.budget_id,
                      p_psb_budget_flag        => p_rec.psb_budget_flag,
                      p_gl_budget_name         => p_rec.gl_budget_name,
                      p_effective_date         => p_effective_date,
                      p_object_version_number  => p_rec.object_version_number);

  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pqh_bgt_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_budget_id
  (p_budget_id          => p_rec.budget_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit3_id
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_budget_unit3_id          => p_rec.budget_unit3_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit2_id
  (p_budget_id          => p_rec.budget_id,
   p_status             => p_rec.status,
   p_budget_unit2_id          => p_rec.budget_unit2_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_unit1_id
  (p_budget_id             => p_rec.budget_id,
   p_status                => p_rec.status,
   p_budget_unit1_id       => p_rec.budget_unit1_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_period_set_name
  (p_budget_id             => p_rec.budget_id,
   p_period_set_name       => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfer_to_gl
  (p_budget_id             => p_rec.budget_id,
   p_gl_budget_name        => p_rec.gl_budget_name,
   p_gl_set_of_books_id    => p_rec.gl_set_of_books_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date       => p_rec.budget_end_date,
   p_position_control_flag => p_rec.position_control_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_transfer_to_grants_flag
  (p_budget_id               => p_rec.budget_id,
   p_transfer_to_grants_flag => p_rec.transfer_to_grants_flag,
   p_position_control_flag   => p_rec.position_control_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_status
  (p_budget_id             => p_rec.budget_id,
   p_status                => p_rec.status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_style_cd
  (p_budget_id          => p_rec.budget_id,
   p_budget_style_cd         => p_rec.budget_style_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budgeted_entity_cd
  (p_budget_id          => p_rec.budget_id,
   p_budgeted_entity_cd         => p_rec.budgeted_entity_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_budget_start_date
  (p_budget_id          => p_rec.budget_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date     => p_rec.budget_end_date,
   p_period_set_name     => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_budget_end_date
  (p_budget_id          => p_rec.budget_id,
   p_budget_start_date     => p_rec.budget_start_date,
   p_budget_end_date     => p_rec.budget_end_date,
   p_period_set_name     => p_rec.period_set_name,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_budget_unit_id
  (p_budget_unit1_id    => p_rec.budget_unit1_id,
   p_budget_unit2_id    => p_rec.budget_unit2_id,
   p_budget_unit3_id    => p_rec.budget_unit3_id,
   p_position_control_flag => p_rec.position_control_flag);
  --
 chk_budget_name
  (p_budget_id          => p_rec.budget_id,
   p_budget_name        => p_rec.budget_name );
  --
chk_budget_unit1_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit1_id         => p_rec.budget_unit1_id,
   p_budget_unit1_aggregate  => p_rec.budget_unit1_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
chk_budget_unit2_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit2_id         => p_rec.budget_unit2_id,
   p_budget_unit2_aggregate  => p_rec.budget_unit2_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
chk_budget_unit3_aggregate
  (p_budget_id               => p_rec.budget_id,
   p_budget_unit3_id         => p_rec.budget_unit3_id,
   p_budget_unit3_aggregate  => p_rec.budget_unit3_aggregate,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_position_control_flag
  (p_budget_id             => p_rec.budget_id,
   p_position_control_flag => p_rec.position_control_flag,
   p_budgeted_entity_cd    => p_rec.budgeted_entity_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
if nvl(p_rec.position_control_flag,'X') = 'Y' then
   chk_pos_control_budget (p_budget_id         => p_rec.budget_id,
                           p_budgeted_entity_cd => p_rec.budgeted_entity_cd,
                           p_business_group_id => p_rec.business_group_id,
                           p_budget_unit1_id   => p_rec.budget_unit1_id,
                           p_budget_unit2_id   => p_rec.budget_unit2_id,
                           p_budget_unit3_id   => p_rec.budget_unit3_id,
                           p_budget_start_date => p_rec.budget_start_date,
                           p_budget_end_date   => p_rec.budget_end_date);
end if;
--
chk_currency_code
  (p_budget_id             => p_rec.budget_id,
   p_currency_code         => p_rec.currency_code,
   p_object_version_number => p_rec.object_version_number);
  --
chk_psb_budget_flag(p_budget_id              => p_rec.budget_id,
                    p_psb_budget_flag        => p_rec.psb_budget_flag,
                    p_gl_budget_name         => p_rec.gl_budget_name,
                    p_effective_date         => p_effective_date,
                    p_object_version_number  => p_rec.object_version_number);
--

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pqh_bgt_shd.g_rec_type
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
  (p_budget_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pqh_budgets b
    where b.budget_id      = p_budget_id
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
                             p_argument       => 'budget_id',
                             p_argument_value => p_budget_id);
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
end pqh_bgt_bus;

/
