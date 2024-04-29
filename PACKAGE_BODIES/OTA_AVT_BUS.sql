--------------------------------------------------------
--  DDL for Package Body OTA_AVT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AVT_BUS" as
/* $Header: otavtrhi.pkb 120.0 2005/05/29 07:02:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_avt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_activity_version_id         number         default null;
g_language                    varchar2(4)    default null;
--
-- The following global vaiables are only to be used by the
-- validate_translation function.
--
g_activity_id                 number default null;
g_business_group_id           number default null;

--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_activity_version_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_activity_versions avt
         -- , ota_activity_definitions tad
     where avt.activity_version_id = p_activity_version_id
       -- and tad.activity_id = avt.activity_id
       and pbg.business_group_id = avt.business_group_id;
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
    ,p_argument           => 'activity_version_id'
    ,p_argument_value     => p_activity_version_id
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
        => nvl(p_associated_column1,'ACTIVITY_VERSION_ID')
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
  (p_activity_version_id                  in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_activity_versions tav
        -- , ota_activity_definitions tad
     where tav.activity_version_id = p_activity_version_id
       -- and pbg.business_group_id =  tad.business_group_id
       and pbg.business_group_id = tav.business_group_id ;
       -- and tad.activity_id = tav.activity_id
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
    ,p_argument           => 'activity_version_id'
    ,p_argument_value     => p_activity_version_id
    );
  --
  --
  if (( nvl(ota_avt_bus.g_activity_version_id, hr_api.g_number)
       = p_activity_version_id)
  and ( nvl(ota_avt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_avt_bus.g_legislation_code;
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
    ota_avt_bus.g_activity_version_id         := p_activity_version_id;
    ota_avt_bus.g_language                    := p_language;
    ota_avt_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_avt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_avt_shd.api_updating
      (p_activity_version_id               => p_rec.activity_version_id
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
  ,p_rec                          in ota_avt_shd.g_rec_type
  ,p_activity_version_id          in number
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
  ota_avt_bus.set_security_group_id(p_activity_version_id) ;
  --
  -- Validate Dependent Attributes
/*
  check_unique_version_name(p_activity_version_id => p_activity_version_id
                           ,p_version_name    => p_rec.version_name
                           ,p_language        => p_rec.language ) ;
*/
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
  ,p_rec                          in ota_avt_shd.g_rec_type
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
  ota_avt_bus.set_security_group_id(p_rec.activity_version_id) ;
  --
  -- Validate Dependent Attributes
/*
  check_unique_version_name(p_activity_version_id  => p_rec.activity_version_id
                           ,p_version_name         => p_rec.version_name
                           ,p_language             => p_rec.language );
*/
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
  (p_rec                          in ota_avt_shd.g_rec_type
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
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_business_group_id              in number
  ,p_activity_id                    in number
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_business_group_id     := p_business_group_id;
  g_activity_id           := p_activity_id ;

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
  (p_activity_version_id            in number
  ,p_language                       in varchar2
  ,p_version_name                   in varchar2
  ,p_description		    in varchar2
  ,p_intended_audience		    in varchar2
  ,p_objectives                     in varchar2
  ,p_keywords                       in varchar2
  ,p_business_group_id              in number default null
  ,p_activity_id                    in number default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';

  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
 /*
  check_unique_version_name
    ( p_activity_version_id         => p_activity_version_id
    , p_activity_id                 => Nvl(p_activity_id,g_activity_id)
    , p_business_group_id           => Nvl(p_business_group_id,g_business_group_id)
    , p_language                    => p_language
    , p_version_name                => p_version_name
    );
    */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END Validate_translation;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_unique_version_name >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--
Procedure check_unique_version_name
  (
   p_business_group_id in number default null
  ,p_activity_id       in number default null
  ,p_version_name      in varchar2
  ,p_activity_version_id in number
  ,p_language          in varchar2
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_name';
  --
  v_business_group_id number;
  v_activity_id number;
  --
  cursor get_activity is
  select tad.business_group_id, tad.activity_id
  from   ota_activity_definitions tad
        ,ota_activity_versions tav
  where  tav.activity_version_id = p_activity_version_id
  and    tav.activity_id = tad.activity_id ;
  --
  cursor sel_unique_key is
select 'Y'
from ota_activity_versions  tav
,    ota_activity_versions_tl avt
where avt.version_name = p_version_name
and   avt.activity_version_id = tav.activity_version_id
and   avt.language = p_language
and   tav.activity_id = v_activity_id
and (p_activity_version_id is null or
    (p_activity_version_id is not null and
     avt.activity_version_id <> p_activity_version_id)) ;

  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_business_group_id is null or p_activity_id is null then
     open get_activity;
     fetch get_activity into v_business_group_id, v_activity_id ;
     close get_activity;
  else
     v_business_group_id := p_business_group_id;
  end if;
  --
  Open  sel_unique_key;
  fetch sel_unique_key into v_exists;
  --
  if sel_unique_key%found then
    --
    close sel_unique_key;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    --call_error_message( p_error_appl           =>   'OTA'
    --                  , p_error_txt          =>  'OTA_13301_TAV_DUPLICATE'
    --                 );
    fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
    fnd_message.raise_error;
    --
  end if;
  --
  close sel_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_unique_version_name;
--
--
end ota_avt_bus;

/
