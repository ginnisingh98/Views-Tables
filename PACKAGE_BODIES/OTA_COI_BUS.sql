--------------------------------------------------------
--  DDL for Package Body OTA_COI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_COI_BUS" as
/* $Header: otcoirhi.pkb 120.3 2005/08/12 02:46 pchandra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_coi_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_chat_id                     number         default null;
g_object_id                   number         default null;
g_object_type                 varchar2(30)   default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_chat_id                              in number
  ,p_object_id                            in number
  ,p_object_type                          in varchar2
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ,p_associated_column3                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ota_chat_obj_inclusions and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_chat_obj_inclusions coi
      --   , EDIT_HERE table_name(s) 333
     where coi.chat_id = p_chat_id
       and coi.object_id = p_object_id
       and coi.object_type = p_object_type;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'chat_id'
    ,p_argument_value     => p_chat_id
    );
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
        => nvl(p_associated_column1,'CHAT_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'OBJECT_ID')
      ,p_associated_column3
        => nvl(p_associated_column3,'OBJECT_TYPE')
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
  (p_chat_id                              in     number
  ,p_object_id                            in     number
  ,p_object_type                          in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ota_chat_obj_inclusions and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ota_chat_obj_inclusions coi
      --   , EDIT_HERE table_name(s) 333
     where coi.chat_id = p_chat_id
       and coi.object_id = p_object_id
       and coi.object_type = p_object_type;
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
    ,p_argument           => 'chat_id'
    ,p_argument_value     => p_chat_id
    );
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
  if (( nvl(ota_coi_bus.g_chat_id, hr_api.g_number)
       = p_chat_id)
  and ( nvl(ota_coi_bus.g_object_id, hr_api.g_number)
       = p_object_id)
  and ( nvl(ota_coi_bus.g_object_type, hr_api.g_varchar2)
       = p_object_type)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_coi_bus.g_legislation_code;
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
    ota_coi_bus.g_chat_id                     := p_chat_id;
    ota_coi_bus.g_object_id                   := p_object_id;
    ota_coi_bus.g_object_type                 := p_object_type;
    ota_coi_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_coi_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_coi_shd.api_updating
      (p_chat_id                           => p_rec.chat_id
      ,p_object_id                         => p_rec.object_id
      ,p_object_type                       => p_rec.object_type
      ,p_object_version_number             => p_rec.object_version_number
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
-- |---------------------------< check_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--   The module version and module category must form a unique key.
--
Procedure check_unique_key
  (
   p_chat_id in  number
  ,p_object_id   in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_key';
  --
  cursor sel_unique_key is
    select 'Y'
      from OTA_CHAT_OBJ_INCLUSIONS  coi
     where coi.chat_id = p_chat_id
       and coi.object_id   = p_object_id
       and coi.object_type = 'C';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_unique_key;
  fetch sel_unique_key into v_exists;
  --
  if sel_unique_key%found then
    close sel_unique_key;

    fnd_message.set_name('OTA', 'OTA_13676_DCI_DUPLICATE');
    fnd_message.raise_error;
  end if;
  close sel_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CHAT_OBJ_INCLUSIONS.chat_id',
                    p_associated_column2    => 'OTA_CHAT_OBJ_INCLUSIONS.object_id')
                                                              THEN
                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
End check_unique_key;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_chat_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure check_chat_category_dates
  (
   p_chat_id           in    number
  , p_object_id        in number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR csr_cat_start_end_date is
    SELECT
      start_date_active,
      nvl(end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
    FROM  ota_category_usages
    WHERE category_usage_id =p_object_id;

   CURSOR csr_chat_start_end_date IS
     SELECT start_date_active,
                      nvl(end_date_active, to_date ('31-12-4712', 'DD-MM-YYYY'))
    FROM ota_chats_b
    WHERE chat_id = p_chat_id;


   --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'check_category_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;
  l_chat_start_date date;
  l_chat_end_date   date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1   => 'OTA_CHATS_B.START_DATE_ACTIVE'
          ,p_check_column2   => 'OTA_CHATS_B.END_DATE_ACTIVE'
          ,p_associated_column1   => 'OTA_CHATS_B.START_DATE_ACTIVE'
          ,p_associated_column2   => 'OTA_CHATS_B.END_DATE_ACTIVE'
        ) THEN
     --
     OPEN csr_cat_start_end_date;
     FETCH csr_cat_start_end_date into l_cat_start_date, l_cat_end_date;

     OPEN csr_chat_start_end_date;
     FETCH csr_chat_start_end_date into l_chat_start_date, l_chat_end_date;

     IF csr_cat_start_end_date%FOUND  AND csr_chat_start_end_date%FOUND THEN
        CLOSE csr_cat_start_end_date;
	 CLOSE csr_chat_start_end_date;
        IF ( l_cat_start_date > l_chat_start_date
             or l_cat_end_date < l_chat_end_date
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_443833_CHT_OUT_OF_CAT_DATE');
	  fnd_message.raise_error;
          --
        End IF;
     ELSE
         CLOSE csr_cat_start_end_date;
	 CLOSE csr_chat_start_end_date;
     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_CHATS_B.START_DATE_ACTIVE'
                 ,p_associated_column2   => 'OTA_CHATS_B.END_DATE_ACTIVE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End check_chat_category_dates;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_multiple_primary_ctgr >---------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   There can be only one primary category for a chat..
--
Procedure check_multiple_primary_ctgr
  (
   p_chat_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_multiple_primary_ctgr';
  v_exists                varchar2(1);
  cursor sel_multiple_primary is
  select 'Y'
  from OTA_CHAT_OBJ_INCLUSIONS coi
  where coi.chat_id = p_chat_id
  and coi.primary_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_multiple_primary;
  fetch sel_multiple_primary into v_exists;
  --
  if sel_multiple_primary%found then
    close sel_multiple_primary;

   fnd_message.set_name('OTA', 'OTA_13676_DCI_DUPLICATE');
    fnd_message.raise_error;
  end if;
  close sel_multiple_primary;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

Exception
WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CHAT_OBJ_INCLUSIONS.PRIMARY_FLAG')

                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
End check_multiple_primary_ctgr;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_if_primary_category >-----------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check if th category chat already has a primary category.
--   This category cannot be deleted.
--
Procedure check_if_primary_category
  (
    p_chat_id  in  number
   ,p_object_id    in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_primary_category';
  v_exists                varchar2(1);
  cursor sel_primary_category is
  select 'Y'
  from OTA_CHAT_OBJ_INCLUSIONS coi
  where coi.chat_id = p_chat_id
  and   coi.object_id = p_object_id
  and coi.primary_flag = 'Y';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open sel_primary_category;
  fetch sel_primary_category into v_exists;
  --
  if sel_primary_category%found then
    close sel_primary_category;

    fnd_message.set_name('OTA', 'OTA_443941_CHT_DEL_PRIMARY');
    fnd_message.raise_error;
  end if;
  close sel_primary_category;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CHAT_OBJ_INCLUSIONS.PRIMARY_FLAG')

                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
End check_if_primary_category;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_start_end_dates >-----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Startdate must be less than, or equal to, enddate.
--
Procedure check_start_end_dates
  (
   p_start_date     in     date
  ,p_end_date       in     date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_start_end_dates';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_start_end_dates(  p_start_date, p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_CHAT_OBJ_INCLUSIONS.START_DATE_ACTIVE'
                    ,p_associated_column2    => 'OTA_CHAT_OBJ_INCLUSIONS.END_DATE_ACTIVE')
                                           THEN

                   hr_utility.set_location(' Leaving:'||v_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||v_proc, 25);
  --
End check_start_end_dates;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_chat_id                      in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_rec                          in ota_coi_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
   check_unique_key( p_chat_id
                    , p_object_id );

   if p_rec.primary_flag = 'Y' then
        check_multiple_primary_ctgr(p_chat_id);
      check_chat_category_dates(p_chat_id       => p_rec.chat_id
                             , p_object_id => p_rec.object_id);
  end if;

  check_start_end_dates(p_rec.start_date_active
                       ,p_rec.end_date_active);

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
  ,p_rec                          in ota_coi_shd.g_rec_type
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
  (p_rec                          in ota_coi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --     check_if_primary_category(p_rec.chat_id, p_rec.object_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_coi_bus;

/
