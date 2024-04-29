--------------------------------------------------------
--  DDL for Package Body GHR_CDT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CDT_BUS" as
/* $Header: ghcdtrhi.pkb 115.4 2003/01/30 19:25:13 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cdt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_compl_ca_detail_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_compl_ca_detail_id                   in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ghr_compl_ca_details and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ghr_compl_ca_details cdt
      --   , EDIT_HERE table_name(s) 333
     where cdt.compl_ca_detail_id = p_compl_ca_detail_id;
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
    ,p_argument           => 'compl_ca_detail_id'
    ,p_argument_value     => p_compl_ca_detail_id
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
  (p_compl_ca_detail_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ghr_compl_ca_details and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , ghr_compl_ca_details cdt
      --   , EDIT_HERE table_name(s) 333
     where cdt.compl_ca_detail_id = p_compl_ca_detail_id;
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
    ,p_argument           => 'compl_ca_detail_id'
    ,p_argument_value     => p_compl_ca_detail_id
    );
  --
  if ( nvl(ghr_cdt_bus.g_compl_ca_detail_id, hr_api.g_number)
       = p_compl_ca_detail_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ghr_cdt_bus.g_legislation_code;
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
    ghr_cdt_bus.g_compl_ca_detail_id          := p_compl_ca_detail_id;
    ghr_cdt_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ghr_cdt_shd.g_rec_type
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
  IF NOT ghr_cdt_shd.api_updating
      (p_compl_ca_detail_id                   => p_rec.compl_ca_detail_id
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

--
-----------------------------<chk_category>------------------------------
--
--

PROCEDURE chk_category(p_compl_ca_detail_id   in ghr_compl_ca_details.compl_ca_detail_id%TYPE,
		       p_category              in ghr_compl_ca_details.category%TYPE,
		       p_effective_date        in date,
		       p_object_version_number in number)

IS

l_proc	varchar2(72) := g_package||'chk_category';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The category value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_cdt_shd.api_updating(
					p_compl_ca_detail_id  => p_compl_ca_detail_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_cdt_shd.g_old_rec.category,hr_api.g_varchar2)
				<> nvl(p_category,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If category is not null then
--	Check if the category value exists in fnd_lookups
--	Where the look up type is 'GHR_US_CA_CATEGORIES'
--

	IF p_category is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type	=>    'GHR_US_CA_CATEGORIES',
			 p_lookup_code	=>	p_category
			) THEN

	-- Error: Invalid Subject to IA Action

               -- New Message

	       hr_utility.set_message(8301,'GHR_38704_INV_COMP_CATEGORY');
	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_category;

--
-----------------------------<chk_type>-------------------------------------
--
--
/*
PROCEDURE chk_type(p_compl_ca_detail_id   in ghr_compl_ca_details.compl_ca_detail_id%TYPE,
		   p_category              in ghr_compl_ca_details.category%TYPE,
                   p_type                  in ghr_compl_ca_details.type%TYPE,
		   p_effective_date        in date,
		   p_object_version_number in number)

IS

l_proc	varchar2(72) := g_package||'chk_type';
l_api_updating boolean;

l_monetary         varchar2(30) := '10'; -- Lookup code for 'Category' in fnd_common_lookups having Meaning Monetary
l_non_monetary     varchar2(30) := '20'; -- Lookup code for 'Category' in fnd_common_lookups having Meaning Non Monetary
l_lookup_type      varchar2(30);
BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The type value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_cdt_shd.api_updating(
					p_compl_ca_detail_id  => p_compl_ca_detail_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_cdt_shd.g_old_rec.type,hr_api.g_varchar2)
				<> nvl(p_type,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If type is not null then
--	If category value = '10' (Monetary) then check if the type value exists in fnd_lookups
--	Where the look up type is 'GHR_US_CA_TYPE_MONETARY'
--
--	If category value = '20' (Non Monetary) then check if the type value exists in fnd_lookups
--	Where the look up type is 'GHR_US_CA_TYPE_NON_MONETARY'
--
--

	IF p_type is NOT NULL THEN
           IF p_category = l_monetary then
             l_lookup_type := 'GHR_US_CA_TYPE_MONETARY';
           ELSIF p_category = l_non_monetary then
             l_lookup_type := 'GHR_US_CA_TYPE_NON_MONETARY';
           END IF;

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type	=>    l_lookup_type,
			 p_lookup_code	=>	p_type
			) THEN

	-- Error: Invalid Subject to IA Action

               -- New Message

	       hr_utility.set_message(8301,'GHR_38705_INV_COMP_TYPE');
	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_type;
*/

--
-----------------------------<chk_phase>-----------------------------------
--
--

PROCEDURE chk_phase(p_compl_ca_detail_id   in ghr_compl_ca_details.compl_ca_detail_id%TYPE,
		    p_phase                 in ghr_compl_ca_details.phase%TYPE,
		    p_effective_date        in date,
		    p_object_version_number in number)

IS

l_proc	varchar2(72) := g_package||'chk_phase';
l_api_updating boolean;


BEGIN

	hr_utility.set_location('Entering: '|| l_proc, 10);

-- Check Mandatory Parameters are set

	hr_api.mandatory_arg_error
		(p_api_name	 => l_proc,
         	p_argument       => 'effective date',
         	p_argument_value => p_effective_date
		);

--
-- Only Proceed with the validation if:
--
-- a) The current g_old_rec is current and
-- b) The phase value has changed
-- c) A record is being inserted.
--

	l_api_updating := ghr_cdt_shd.api_updating(
					p_compl_ca_detail_id  => p_compl_ca_detail_id,
					p_object_version_number	=> p_object_version_number);

	IF (l_api_updating
        AND
        ((nvl(ghr_cdt_shd.g_old_rec.phase,hr_api.g_varchar2)
				<> nvl(p_phase,hr_api.g_varchar2))))
        OR
	NOT l_api_updating THEN

--
	hr_utility.set_location(l_proc,20);
--
-- 	If phase is not null then
--	Check if the phase value exists in fnd_lookups
--	Where the look up type is 'GHR_US_CA_PHASES'
--

	IF p_phase is NOT NULL THEN

	   IF hr_api.not_exists_in_hr_lookups
			(p_effective_date	=>	p_effective_date,
			 p_lookup_type	=>    'GHR_US_CA_PHASES',
			 p_lookup_code	=>	p_phase
			) THEN

	-- Error: Invalid Subject to IA Action

               -- New Message

	       hr_utility.set_message(8301,'GHR_38706_INV_COMP_PHASE');
	       hr_utility.raise_error;
	   END IF;
	   hr_utility.set_location(l_proc,30);

	END IF;

     END IF;

     hr_utility.set_location('Leaving: '|| l_proc, 40);

END chk_phase;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ghr_cdt_shd.g_rec_type
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
  --

  chk_category(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
              ,p_category              => p_rec.category
              ,p_effective_date        => p_effective_date
              ,p_object_version_number => p_rec.object_version_number);
/*
  chk_type(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
          ,p_category              => p_rec.category
          ,p_type                  => p_rec.type
          ,p_effective_date        => p_effective_date
          ,p_object_version_number => p_rec.object_version_number);
*/

  chk_phase(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
           ,p_phase                 => p_rec.phase
           ,p_effective_date        => p_effective_date
           ,p_object_version_number => p_rec.object_version_number);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ghr_cdt_shd.g_rec_type
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
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

  --
  chk_category(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
              ,p_category              => p_rec.category
              ,p_effective_date        => p_effective_date
              ,p_object_version_number => p_rec.object_version_number);

/*
  chk_type(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
          ,p_category              => p_rec.category
          ,p_type                  => p_rec.type
          ,p_effective_date        => p_effective_date
          ,p_object_version_number => p_rec.object_version_number);
*/

  chk_phase(p_compl_ca_detail_id    => p_rec.compl_ca_detail_id
           ,p_phase                 => p_rec.phase
           ,p_effective_date        => p_effective_date
           ,p_object_version_number => p_rec.object_version_number);


  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ghr_cdt_shd.g_rec_type
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
end ghr_cdt_bus;

/
