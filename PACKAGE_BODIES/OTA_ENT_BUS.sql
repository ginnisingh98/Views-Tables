--------------------------------------------------------
--  DDL for Package Body OTA_ENT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ENT_BUS" as
/* $Header: otentrhi.pkb 115.1 2003/04/24 17:25:58 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_ent_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_id                    number         default null;
g_language                    varchar2(4)    default null;
--
-- The following global vaiables are only to be used by the
-- validate_translation function.
--
g_parent_event_id             number default null;
g_business_group_id           number default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_business_group_id              in number
  ,p_parent_event_id                in number default null
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_business_group_id     := p_business_group_id;
  g_parent_event_id       := p_parent_event_id;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END set_translation_globals;
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
  (p_event_id          in number
  ,p_language                       in varchar2
  ,p_title                           in varchar2
  ,p_business_group_id              in number default null
  ,p_parent_event_id                in number default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';

  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  check_title_is_unique
    ( p_event_id                    => p_event_id
    , p_business_group_id           => Nvl(p_business_group_id,g_business_group_id)
    , p_language                    => p_language
    , p_title                       => p_title
    , p_parent_event_id             => Nvl(p_parent_event_id,g_parent_event_id)
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END Validate_translation;
--

function UNIQUE_EVENT_TITLE (
	P_TITLE					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_PARENT_EVENT_ID			     in	number,
	P_EVENT_ID				     in	number	default null,
	P_LANGUAGE                                   in varchar2
	) return boolean is
--
	W_PROC						 varchar2 (72)
		:= G_PACKAGE || 'UNIQUE_EVENT_TITLE';
	W_TITLE_IS_UNIQUE				boolean;
	l_dummy number(1);
	--
	cursor C1 is
		select 1
		  from OTA_EVENTS EVT, OTA_EVENTS_TL ENT
		  where EVT.BUSINESS_GROUP_ID	      = P_BUSINESS_GROUP_ID
		    and (    (P_PARENT_EVENT_ID      is null             )
		         or  (EVT.PARENT_EVENT_ID     = P_PARENT_EVENT_ID))
		    and upper (ENT.TITLE)	      = upper (P_TITLE)
		    and (    (P_EVENT_ID	     is null      )
		         or  (ENT.EVENT_ID	     <> P_EVENT_ID))
		    and ENT.EVENT_ID = EVT.EVENT_ID
		    and ENT.LANGUAGE = P_LANGUAGE ;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check arguments
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
	 	'P_TITLE',
		P_TITLE);
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_BUSINESS_GROUP_ID',
		P_BUSINESS_GROUP_ID);
	--
	--	Unique ?
	--
	open C1;
	fetch C1
	  into L_DUMMY;
	W_TITLE_IS_UNIQUE := C1%notfound;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (W_PROC, 10);
	return W_TITLE_IS_UNIQUE;
	--
end UNIQUE_EVENT_TITLE;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_TITLE_IS_UNIQUE >----------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the event title (ignoring case).
--
procedure CHECK_TITLE_IS_UNIQUE (
	P_TITLE					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_PARENT_EVENT_ID			     in number,
	P_EVENT_ID				     in	number	default null,
	P_LANGUAGE                                   in varchar2
	) is
	--

        --

	W_PROC						varchar2 (72)
		:= G_PACKAGE || 'CHECK_TITLE_IS_UNIQUE';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Do not perform the uniqueness check unless inserting, or updating
	--	with a value different from the current value (and not just changing
	--	case)
	--
	--	Check arguments
	--
 	--if (not (    (OTA_EVT_SHD.API_UPDATING (P_EVENT_ID, P_OBJECT_VERSION_NUMBER))
	  --       and (upper (P_TITLE) = upper (OTA_ENT_SHD.G_OLD_REC.TITLE)         ))) then
		--
		if (not UNIQUE_EVENT_TITLE (
				P_TITLE		     => P_TITLE,
				P_BUSINESS_GROUP_ID  => P_BUSINESS_GROUP_ID,
				P_PARENT_EVENT_ID    =>	P_PARENT_EVENT_ID,
				P_EVENT_ID	     =>	P_EVENT_ID ,
				P_LANGUAGE           => P_LANGUAGE )) then
                  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
                  fnd_message.raise_error;
		end if;
		--
	-- end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
end CHECK_TITLE_IS_UNIQUE;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< CHECK_TITLE >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the event title (ignoring case), by calling
--      check_title_is_unique
procedure CHECK_TITLE (
	P_REC			in	OTA_ENT_SHD.G_REC_TYPE,
	P_EVENT_ID		in	number default null
	) is
  --
  l_proc  varchar2(72) := g_package||'check_title';
  --
  -- Declare cursor
  --
  cursor csr_event is
    select evt.parent_event_id
          ,evt.business_group_id
    from ota_events evt
    where evt.event_id  = NVL(p_rec.event_id, p_event_id);
  --
  l_business_group_id  ota_events.business_group_id%TYPE;
  l_parent_event_id    ota_events.parent_event_id%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_event;
  --
  fetch csr_event into l_parent_event_id,l_business_group_id;
  --
  close csr_event;
  --
  check_title_is_unique
   (p_event_id                => Nvl(p_rec.event_id,p_event_id)
   ,p_parent_event_id         => l_parent_event_id
   ,p_business_group_id       => l_business_group_id
   ,p_language                => p_rec.language
   ,p_title                   => p_rec.title );

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End check_title;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_id                             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups pbg
           , ota_events evt
     where evt.event_id = p_event_id
     and   pbg.business_group_id = evt.business_group_id ;


  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'event_id'
    ,p_argument_value     => p_event_id
    );
  --
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
        => nvl(p_associated_column1,'EVENT_ID')
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
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_event_id                             in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ota_events_tl ent
         , ota_events evt
     where ent.event_id = p_event_id
       and ent.language = p_language
       and pbg.business_group_id = evt.business_group_id
       and evt.event_id = ent.event_id;
  --
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
    ,p_argument           => 'event_id'
    ,p_argument_value     => p_event_id
    );
  --
  --
  if (( nvl(ota_ent_bus.g_event_id, hr_api.g_number)
       = p_event_id)
  and ( nvl(ota_ent_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_ent_bus.g_legislation_code;
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
    ota_ent_bus.g_event_id                    := p_event_id;
    ota_ent_bus.g_language                    := p_language;
    ota_ent_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_ent_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_ent_shd.api_updating
      (p_event_id                          => p_rec.event_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ent_shd.g_rec_type
  ,p_event_id                     in number
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
  ota_ent_bus.set_security_group_id(p_event_id) ;
  --
  -- Validate Dependent Attributes
  CHECK_TITLE
            ( P_REC               => p_rec,
              P_EVENT_ID          => Nvl(p_rec.event_id,p_event_id)
            );
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
  ,p_rec                          in ota_ent_shd.g_rec_type
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
  ota_ent_bus.set_security_group_id(p_rec.event_id);
  --
  -- Validate Dependent Attributes
  --
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
  (p_rec                          in ota_ent_shd.g_rec_type
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
--
end ota_ent_bus;

/
