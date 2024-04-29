--------------------------------------------------------
--  DDL for Package Body OTA_BJT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BJT_BUS" as
/* $Header: otbjtrhi.pkb 120.0 2005/05/29 07:03:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_bjt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_booking_justification_id    number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_booking_justification_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         ,ota_bkng_justifications_b bjs
     where bjs.booking_justification_id = p_booking_justification_id
       and pbg.business_group_id = bjs.business_group_id;
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
    ,p_argument           => 'booking_justification_id'
    ,p_argument_value     => p_booking_justification_id
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
        => nvl(p_associated_column1,'BOOKING_JUSTIFICATION_ID')
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
  (p_booking_justification_id             in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ota_bkng_justifications_b bjs
     where bjs.booking_justification_id = p_booking_justification_id
       and pbg.business_group_id = bjs.business_group_id;
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
    ,p_argument           => 'booking_justification_id'
    ,p_argument_value     => p_booking_justification_id
    );
  --
  --
  if (( nvl(ota_bjt_bus.g_booking_justification_id, hr_api.g_number)
       = p_booking_justification_id)
  and ( nvl(ota_bjt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_bjt_bus.g_legislation_code;
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
    ota_bjt_bus.g_booking_justification_id    := p_booking_justification_id;
    ota_bjt_bus.g_language                    := p_language;
    ota_bjt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_bjt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_bjt_shd.api_updating
      (p_booking_justification_id          => p_rec.booking_justification_id
      ,p_language                          => p_rec.language
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
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_name >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_name
  (p_justification_text in varchar2
  ,p_booking_justification_id in number
) IS

l_business_group_id number;
l_exists number;
l_proc    varchar2(72) := g_package ||'.check_name';

     CURSOR csr_get_bg IS
       select business_group_id
       FROM ota_bkng_justifications_b
       WHERE booking_justification_id = p_booking_justification_id;

    CURSOR csr_get_name(p_business_group_id NUMBER) IS
       SELECT 1
       FROM ota_bkng_justifications_tl bjt,
                   ota_bkng_justifications_b bjs
       WHERE bjs.booking_justification_id = bjt.booking_justification_id
	     AND  bjs.business_group_id = p_business_group_id
	     AND bjt.justification_text = p_justification_text
	     AND bjt.language = USERENV('LANG')
	     AND bjt.booking_justification_id <> p_booking_justification_id ;
begin
hr_utility.set_location(' Entering :'||l_proc, 10);
    OPEN csr_get_bg;
    FETCH csr_get_bg INTO l_business_group_id;
    CLOSE csr_get_bg;

hr_utility.set_location(' Inside :'||l_proc, 20);
    IF l_business_group_id IS NOT NULL THEN
        OPEN csr_get_name(l_business_group_id);
	FETCH csr_get_name INTO l_exists;
	IF csr_get_name%FOUND THEN
		CLOSE csr_get_name;
		hr_utility.set_location(' Inside :'||l_proc, 30);
		fnd_message.set_name('OTA', 'OTA_443106_BJS_UNIQUE_NAME');
                fnd_message.raise_error;
	ELSE
	         hr_utility.set_location(' Inside :'||l_proc, 40);
		CLOSE csr_get_name;
	END IF;
     END IF;
  EXCEPTION
  WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_BOOKING_JUSTIFICATIONS_VL.JUSTIFICATION_TEXT') THEN

              hr_utility.set_location(' Leaving:'||l_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||l_proc, 94);
end chk_name;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ota_bjt_shd.g_rec_type
  ,p_booking_justification_id ota_bkng_justifications_b.booking_justification_id%TYPE
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
  ota_bjs_bus.set_security_group_id(p_booking_justification_id =>p_booking_justification_id);
  --
  -- Validate Dependent Attributes
  --
  chk_name( p_justification_text                   => p_rec.justification_text
			  ,p_booking_justification_id =>p_booking_justification_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ota_bjt_shd.g_rec_type
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
 ota_bjs_bus.set_security_group_id(p_booking_justification_id =>p_rec.booking_justification_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

   IF  p_rec.justification_text <> hr_api.g_varchar2 THEN
    chk_name( p_justification_text                   => p_rec.justification_text
			  ,p_booking_justification_id =>p_rec.booking_justification_id);
  END IF;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_bjt_shd.g_rec_type
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
end ota_bjt_bus;

/
