--------------------------------------------------------
--  DDL for Package Body OTA_SRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_SRT_BUS" as
/* $Header: otsrtrhi.pkb 115.3 2003/05/19 07:56:51 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_srt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_supplied_resource_id        number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_supplied_resource_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups pbg
         , ota_suppliable_resources tsr
     where tsr.supplied_resource_id = p_supplied_resource_id
       and pbg.business_group_id = tsr.business_group_id;
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
    ,p_argument           => 'supplied_resource_id'
    ,p_argument_value     => p_supplied_resource_id
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
        => nvl(p_associated_column1,'SUPPLIED_RESOURCE_ID')
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
  (p_supplied_resource_id                 in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , ota_suppliable_resources tsr
     where tsr.supplied_resource_id = p_supplied_resource_id
       and pbg.business_group_id = tsr.business_group_id;
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
    ,p_argument           => 'supplied_resource_id'
    ,p_argument_value     => p_supplied_resource_id
    );
  --
  --
  if (( nvl(ota_srt_bus.g_supplied_resource_id, hr_api.g_number)
       = p_supplied_resource_id)
  and ( nvl(ota_srt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_srt_bus.g_legislation_code;
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
    ota_srt_bus.g_supplied_resource_id        := p_supplied_resource_id;
    ota_srt_bus.g_language                    := p_language;
    ota_srt_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_srt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_srt_shd.api_updating
      (p_supplied_resource_id              => p_rec.supplied_resource_id
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
-- |---------------------------< check_unique_name >----------------------------|
-- ----------------------------------------------------------------------------
procedure check_unique_name (
  p_business_group_id	   number default null,
  p_supplied_resource_id  number,
  p_language	  varchar2,
  p_name	  varchar2,
  p_resource_type varchar2 default null
) is
----------------
l_business_group_id ota_suppliable_resources.business_group_id%type ;
l_resource_type ota_suppliable_resources.resource_type%type ;

cursor csr_tsr_bsg_type is
        select business_group_id,resource_type
        from ota_suppliable_resources
        where supplied_resource_id = p_supplied_resource_id ;

cursor csr_tsr is
	select tsr.supplied_resource_id
	from ota_suppliable_resources tsr, ota_suppliable_resources_tl srt
	where tsr.business_group_id = l_business_group_id
	and srt.supplied_resource_id = tsr.supplied_resource_id
	and srt.language = p_language
	and (p_supplied_resource_id is null or p_supplied_resource_id <> srt.supplied_resource_id)
        and srt.name = p_name
        and tsr.resource_type = l_resource_type;
--
l_tsr_exists	boolean;

--
l_dummy		number ;
--
l_proc  varchar2(72) := g_package||'check_unique_name';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
if p_business_group_id is null or p_resource_type is null then
  open csr_tsr_bsg_type ;
    fetch csr_tsr_bsg_type into l_business_group_id, l_resource_type ;
  close csr_tsr_bsg_type ;
else
  l_business_group_id := p_business_group_id ;
  l_resource_type     := p_resource_type ;
end if;
--
hr_api.mandatory_arg_error(g_package,'business_group',l_business_group_id);
--
open csr_tsr;
fetch csr_tsr into l_dummy;
l_tsr_exists := csr_tsr%found;
close csr_tsr;
--
if l_tsr_exists then
	-- constraint_error2('resource_already_exists');
         fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
         fnd_message.raise_error;
end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end check_unique_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_srt_shd.g_rec_type
  ,p_supplied_resource_id         in number
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
  ota_srt_bus.set_security_group_id(p_supplied_resource_id) ;
  --
  -- Validate Dependent Attributes
  check_unique_name(p_supplied_resource_id => p_supplied_resource_id
                   ,p_name                 => p_rec.name
                   ,p_language             => p_rec.language
                   ) ;
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
  ,p_rec                          in ota_srt_shd.g_rec_type
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
  ota_srt_bus.set_security_group_id(p_rec.supplied_resource_id) ;
  --
  -- Validate Dependent Attributes
  check_unique_name(p_supplied_resource_id => p_rec.supplied_resource_id
                   ,p_name                 => p_rec.name
                   ,p_language             => p_rec.language
                   ) ;
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
  (p_rec                          in ota_srt_shd.g_rec_type
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
end ota_srt_bus;

/
