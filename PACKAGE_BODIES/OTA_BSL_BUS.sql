--------------------------------------------------------
--  DDL for Package Body OTA_BSL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BSL_BUS" as
/* $Header: otbslrhi.pkb 115.1 2003/04/24 17:27:36 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_bsl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_booking_status_type_id      number         default null;
g_language                    varchar2(4)    default null;
--
-- The following global variables are only to be used by the
-- validate_translation procedure
g_business_group_id number default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_business_group_id              in number
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_business_group_id     := p_business_group_id;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END set_translation_globals;
--
-- ----------------------------------------------------------------------------
-- --------------------------< CHECK_UNIQUE_NAME >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Check that a business status type name is unique within the
--      business group.
--
procedure CHECK_UNIQUE_NAME (
        P_BUSINESS_GROUP_ID                  in number,
        P_NAME                               in varchar2,
        P_Language                           in varchar2,
        P_BOOKING_STATUS_TYPE_ID             in number
        ) is
--
	W_PROCEDURE				varchar2 (72)
		:= G_PACKAGE || 'CHECK_UNIQUE_NAME';
	--
	V_UNIQUE				varchar (3);
	--
	cursor CSR_UNIQUE is
		select 'NO'
		  from OTA_BOOKING_STATUS_TYPES BST, OTA_BOOKING_STATUS_TYPES_TL BSTT
          WHERE upper (BSTT.NAME)      =	upper (P_NAME)
	 AND   BSTT.BOOKING_STATUS_TYPE_ID = BST.BOOKING_STATUS_TYPE_ID
	 AND   bstt.language = p_language
	 AND   (BSTT.BOOKING_STATUS_TYPE_ID <> P_BOOKING_STATUS_TYPE_ID OR P_BOOKING_STATUS_TYPE_ID IS NULL)
	 AND   (BST.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID OR  P_BUSINESS_GROUP_ID IS NULL);


begin
	--
	HR_UTILITY.SET_LOCATION ('Entering: ' || W_PROCEDURE, 5);
	--
	open CSR_UNIQUE;
	fetch CSR_UNIQUE
	  into V_UNIQUE;
	if(CSR_UNIQUE%notfound) then
		V_UNIQUE := 'YES';
	end if;
	close CSR_UNIQUE;
	--
	if (V_UNIQUE <> 'YES') then
         fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
         fnd_message.raise_error;
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving: ' || W_PROCEDURE, 10);
	--
end CHECK_UNIQUE_NAME;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< CHECK_UNIQUE_NAME >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the event title (ignoring case), by calling
--      check_title_is_unique
procedure CHECK_UNIQUE_NAME (
	P_REC				in	OTA_BSL_SHD.G_REC_TYPE,
	P_BOOKING_STATUS_TYPE_ID	in	number default null
	) is
  --
  l_proc  varchar2(72) := g_package||'check_unique_name';
  --
  -- Declare cursor
  --
  cursor csr_bstbsg is
    select bst.business_group_id
    from ota_booking_status_types bst
    where bst.booking_status_type_id  = NVL(p_rec.booking_status_type_id,p_booking_status_type_id);
  --
  l_business_group_id  ota_booking_status_types.business_group_id%TYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_bstbsg ;
  --
  fetch csr_bstbsg into l_business_group_id;
  --
  close csr_bstbsg;
  --
  check_unique_name
   (p_booking_status_type_id  => Nvl(p_rec.booking_status_type_id,p_booking_status_type_id)
   ,p_business_group_id       => l_business_group_id
   ,p_language                => p_rec.language
   ,p_name                    => p_rec.name );

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End check_unique_name;
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
  (p_booking_status_type_id          in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ,p_description                    in varchar2
  ,p_business_group_id              in number default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';

  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  check_unique_name
    ( p_booking_status_type_id      => p_booking_status_type_id
    , p_business_group_id           => Nvl(p_business_group_id,g_business_group_id)
    , p_language                    => p_language
    , p_name                        => p_name
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END Validate_translation;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_booking_status_type_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups pbg
          ,ota_booking_status_types bst
     where bst.booking_status_type_id = p_booking_status_type_id
     and pbg.business_group_id = bst.business_group_id ;
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
    ,p_argument           => 'booking_status_type_id'
    ,p_argument_value     => p_booking_status_type_id
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
        => nvl(p_associated_column1,'BOOKING_STATUS_TYPE_ID')
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
  (p_booking_status_type_id               in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , ota_booking_status_types_tl bstl
         , ota_booking_status_types bst
     where bstl.booking_status_type_id = p_booking_status_type_id
     and bstl.language = p_language
     and pbg.business_group_id = bst.business_group_id
     and bst.booking_status_type_id = bstl.booking_status_type_id ;
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
    ,p_argument           => 'booking_status_type_id'
    ,p_argument_value     => p_booking_status_type_id
    );
  --
  --
  if (( nvl(ota_bsl_bus.g_booking_status_type_id, hr_api.g_number)
       = p_booking_status_type_id)
  and ( nvl(ota_bsl_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_bsl_bus.g_legislation_code;
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
    ota_bsl_bus.g_booking_status_type_id      := p_booking_status_type_id;
    ota_bsl_bus.g_language                    := p_language;
    ota_bsl_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_bsl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_bsl_shd.api_updating
      (p_booking_status_type_id            => p_rec.booking_status_type_id
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
  ,p_rec                          in ota_bsl_shd.g_rec_type
  ,p_booking_status_type_id       in number
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

  ota_bsl_bus.set_security_group_id(p_booking_status_type_id) ;

  -- Validate Dependent Attributes
  check_unique_name(p_rec,p_booking_status_type_id);
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
  ,p_rec                          in ota_bsl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ota_bsl_bus.set_security_group_id(p_rec.booking_status_type_id) ;
  --
  -- Validate Dependent Attributes
  check_unique_name(p_rec);
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
  (p_rec                          in ota_bsl_shd.g_rec_type
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
end ota_bsl_bus;

/
