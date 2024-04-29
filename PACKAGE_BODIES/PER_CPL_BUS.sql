--------------------------------------------------------
--  DDL for Package Body PER_CPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPL_BUS" as
/* $Header: pecplrhi.pkb 120.0.12000000.2 2007/05/30 12:19:15 arumukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cpl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_competence_id               number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_competence_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- Amended on 23-Dec-2002 by meburton
  -- Get the PER_BUSINESS_GROUPS

  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_competences cpn
         , per_competences_tl cpl
     where cpl.competence_id     = p_competence_id
     and   pbg.business_group_id = cpn.business_group_id
     and   cpl.competence_id     = cpn.competence_id;
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
    ,p_argument           => 'competence_id'
    ,p_argument_value     => p_competence_id
    );
  --
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
        => nvl(p_associated_column1,'COMPETENCE_ID')
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
  (p_competence_id                        in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  -- amended on 23-Dec-2002 added join to per_compentence table
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_competences_tl cpl
         , per_competences    cpn
      where cpl.competence_id   = p_competence_id
      and cpl.language          = p_language
      and cpl.competence_id     = cpn.competence_id
      and pbg.business_group_id = cpn.competence_id;
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
    ,p_argument           => 'competence_id'
    ,p_argument_value     => p_competence_id
    );
  --
  --
  if (( nvl(per_cpl_bus.g_competence_id, hr_api.g_number)
       = p_competence_id)
  and ( nvl(per_cpl_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cpl_bus.g_legislation_code;
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
    per_cpl_bus.g_competence_id               := p_competence_id;
    per_cpl_bus.g_language                    := p_language;
    per_cpl_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in per_cpl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_cpl_shd.api_updating
      (p_competence_id                     => p_rec.competence_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
   --
  hr_utility.set_location(l_proc, 6);
  --

  --
End chk_non_updateable_args;
--
-------------------------------------------------------------------------------
-------------------------------< chk_alias >-----------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--
--   - Validates that it is unique within the table as per the constraint
--     it replaces (PER_COMPETENCES_UK3)
--
--  Pre_conditions:
--    None
--
--  In Arguments:
--    p_alias
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- name is not unique
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
--
procedure chk_alias
(p_competence_id	     in	     per_competences_tl.competence_id%TYPE
,p_language                  in      per_competences_tl.language%TYPE
,p_competence_alias          in      per_competences_tl.competence_alias%TYPE
)
is
--
	l_exists             varchar2(1);
	l_api_updating	     boolean;
  	l_proc               varchar2(72)  :=  g_package||'chk_alias';
	--
	-- Cursor to check if competence_alias is unique
        --
	cursor csr_chk_alias is
	  select 'x'
 	  from per_competences_tl pct
	  where (( p_competence_id is null)
	        or (p_competence_id <> pct.competence_id)
		)
          and language = p_language
	  and competence_alias = p_competence_alias;

	--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for name has changed
  --
  l_api_updating := per_cpl_shd.api_updating
         (p_competence_id	   => p_competence_id
         ,p_language               => p_language);
  --
  if (  (l_api_updating and (per_cpl_shd.g_old_rec.competence_alias
		        <> nvl(p_competence_alias,hr_api.g_varchar2))
         ) or
        (NOT l_api_updating)
      ) then
     --
     -- check if alias is unique
     --
     open csr_chk_alias;
     fetch csr_chk_alias into l_exists;
     if csr_chk_alias%found then
       hr_utility.set_location(l_proc, 3);
       -- alias is not unique
       close csr_chk_alias;
       fnd_message.set_name('PER','HR_52700_ALIAS_NOT_UNIQUE');
       fnd_message.raise_error;
     end if;
     close csr_chk_alias;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end chk_alias;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_cpl_shd.g_rec_type
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
  -- Name is a key flex field and will be handled by the definitions table
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."

  per_cpl_bus.chk_alias
    ( p_competence_id         => p_rec.competence_id
    , p_language              => p_rec.language
    , p_competence_alias      => p_rec.competence_alias
    );

  -- Validate Dependent Attributes
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
  ,p_rec                          in per_cpl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."

  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec                       => p_rec
    );
  --
  per_cpl_bus.chk_alias
    ( p_competence_id         => p_rec.competence_id
    , p_language              => p_rec.language
    , p_competence_alias      => p_rec.competence_alias
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cpl_shd.g_rec_type
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the MLS widget.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure validate_translation
  ( competence_id            in     NUMBER
  , language                 in     VARCHAR2
  , competence_alias         in     VARCHAR2
  , behavioural_indicator    in     VARCHAR2
  , description              in     VARCHAR2
  ) IS
begin
  per_cpl_bus.chk_alias
    ( p_competence_id        => competence_id
    , p_language             => language
    , p_competence_alias     => competence_alias
    );
end;
--
end per_cpl_bus;

/
