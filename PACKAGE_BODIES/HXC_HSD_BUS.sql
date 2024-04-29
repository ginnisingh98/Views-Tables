--------------------------------------------------------
--  DDL for Package Body HXC_HSD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HSD_BUS" as
/* $Header: hxchsdrhi.pkb 120.3 2005/09/23 10:44:51 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_hsd_bus.';  -- Global package name
g_debug	   boolean	:= hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_object_id                   number         default null;
g_object_type                 varchar2(80)   default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_object_id                            in number
  ,p_object_type                          in varchar2
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_seeddata_by_level and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , hxc_seeddata_by_level hsd
      --   , EDIT_HERE table_name(s) 333
     where hsd.object_id = p_object_id
       and hsd.object_type = p_object_type;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  l_legislation_code  varchar2(150);
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'set_security_group_id';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_id'
    ,p_argument_value     => p_object_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_type'
    ,p_argument_value     => p_object_type
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'OBJECT_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'OBJECT_TYPE')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_object_id                            in     number
  ,p_object_type                          in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_seeddata_by_level and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hxc_seeddata_by_level hsd
      --   , EDIT_HERE table_name(s) 333
     where hsd.object_id = p_object_id
       and hsd.object_type = p_object_type;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'return_legislation_code';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_id'
    ,p_argument_value     => p_object_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_type'
    ,p_argument_value     => p_object_type
    );
  --
  if (( nvl(hxc_hsd_bus.g_object_id, hr_api.g_number)
       = p_object_id)
  and ( nvl(hxc_hsd_bus.g_object_type, hr_api.g_varchar2)
       = p_object_type)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hsd_bus.g_legislation_code;
    if g_debug then
	hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
	hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hxc_hsd_bus.g_object_id                   := p_object_id;
    hxc_hsd_bus.g_object_type                 := p_object_type;
    hxc_hsd_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
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
  (p_rec in hxc_hsd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_hsd_shd.api_updating
      (p_object_id                         => p_rec.object_id
      ,p_object_type                       => p_rec.object_type
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
End chk_non_updateable_args;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_hxc_required >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the p_hxc_required parameter has a
--   valid value i.e. it must be one of the the lookup codes corresponding
--   to the lookup type 'HXC_REQUIRED'.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_hxc_required
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised if p_hxc_required is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


Procedure chk_hxc_required
   (p_hxc_required in hxc_seeddata_by_level.hxc_required%TYPE
   ) IS

 Cursor c_chk_required
 IS
    Select 'Y'
	from hr_lookups hrl
	where hrl.lookup_type = 'HXC_REQUIRED'
	and hrl.lookup_code = p_hxc_required;

  l_dummy varchar2(1);
  l_proc        varchar2(72) := g_package||'chk_hxc_required';
Begin

  if p_hxc_required is null then
      hr_utility.set_message
         (809
         ,'HXC_HSD_INV_REQ_LEVEL'
         );
      hr_utility.raise_error;
  end if;

  Open c_chk_required;
  Fetch c_chk_required into l_dummy;

  if (c_chk_required%NOTFOUND) then
     Close c_chk_required;

      hr_utility.set_message
         (809
         ,'HXC_HSD_INV_REQ_LEVEL'
         );
      hr_utility.raise_error;

  end if;
  Close c_chk_required;


End chk_hxc_required;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_application_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the p_owner_application_id refers to
--   a valid application id.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_owner_application_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised if p_owner_application_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_application_id
    (p_owner_application_id  in   hxc_seeddata_by_level.owner_application_id%TYPE)
IS

  Cursor c_chk_application is
	select 'Y' from fnd_application
	where application_id = p_owner_application_id;

  l_dummy varchar2(1);
  l_proc        varchar2(72) := g_package||'chk_application_id';
Begin

  if p_owner_application_id is null then
      hr_utility.set_message
         (809
         ,'HXC_HSD_INV_APPL'
         );
      hr_utility.raise_error;
  end if;

	Open c_chk_application;
	Fetch c_chk_application into l_dummy;
	if (c_chk_application%NOTFOUND) then

		 Close c_chk_application;

		  hr_utility.set_message
			 (809
			 ,'HXC_HSD_INV_APPL'
			 );
		  hr_utility.raise_error;

	end if;
	Close c_chk_application;


End chk_application_id;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_object >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the p_object_type has a valid
--   value i.e. it must be one of the lookup codes corresponding to the
--   lookup type 'HXC_SEED_DATA_REFERENCE'. Also p_object_id must be a valid
--   object_id in the table corresponding to the p_object_type.

--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_object_id
--   p_object_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised p_object_id and p_object_type are invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_object
  (p_object_id         in hxc_seeddata_by_level.object_id%TYPE
  ,p_object_type       in hxc_seeddata_by_level.object_type%TYPE ) IS

	l_query varchar2(2000);

	TYPE get_value IS REF CURSOR; -- define REF CURSOR type
	c_get_value   get_value; -- declare cursor variable

	l_dummy number;
    l_proc     varchar2(72) := g_package || 'chk_object';
Begin

 if p_object_type is null then
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_type'
    ,p_argument_value     => p_object_type
    );
 end if;

 if p_object_id is null then
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_id'
    ,p_argument_value     => p_object_id
    );
 end if;

	--based on the object type, we shall get the query
	l_query := hxc_seeddata_pkg.get_query(p_object_type);
	if (l_query is null) then
		hr_utility.set_message
		(809
		,'HXC_HSD_INV_OBJ_TYP'
		);
		hr_utility.raise_error;
	end if;

	l_query := 'select 1 from ('||l_query||') where ID = :p_object_id';

	OPEN c_get_value FOR l_query USING p_object_id;
	FETCH c_get_value INTO l_dummy;
	IF (c_get_value%NOTFOUND) then
		CLOSE c_get_value;
		hr_utility.set_message
		(809
		,'HXC_HSD_INV_OBJ_ID'
		);
		hr_utility.raise_error;
	END IF;
	CLOSE c_get_value;

End chk_object;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_hsd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'insert_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
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
  --

  chk_object
	  (p_object_id    => p_rec.object_id
	  ,p_object_type  => p_rec.object_type );

  chk_application_id
		(p_owner_application_id => p_rec.owner_application_id);

  chk_hxc_required
	   (p_hxc_required => p_rec.hxc_required
	   ) ;


  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_hsd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
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
  chk_non_updateable_args
    (p_rec              => p_rec
    );

  chk_object
	  (p_object_id    => p_rec.object_id
	  ,p_object_type  => p_rec.object_type );

  chk_application_id
		(p_owner_application_id => p_rec.owner_application_id);


  chk_hxc_required
	   (p_hxc_required => p_rec.hxc_required
	   ) ;

  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_hsd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_hsd_bus;

/
