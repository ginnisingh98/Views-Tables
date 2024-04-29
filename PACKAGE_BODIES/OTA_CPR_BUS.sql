--------------------------------------------------------
--  DDL for Package Body OTA_CPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPR_BUS" as
/* $Header: otcprrhi.pkb 120.2 2006/10/09 11:33:40 sschauha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cpr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_activity_version_id         number         default null;
g_prerequisite_course_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_activity_version_id                  in number
  ,p_prerequisite_course_id               in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_course_prerequisites cpr
     where cpr.activity_version_id = p_activity_version_id
       and cpr.prerequisite_course_id = p_prerequisite_course_id
       and pbg.business_group_id = cpr.business_group_id;
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'prerequisite_course_id'
    ,p_argument_value     => p_prerequisite_course_id
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
        => nvl(p_associated_column1,'ACTIVITY_VERSION_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'PREREQUISITE_COURSE_ID')
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
  ,p_prerequisite_course_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_course_prerequisites cpr
     where cpr.activity_version_id = p_activity_version_id
       and cpr.prerequisite_course_id = p_prerequisite_course_id
       and pbg.business_group_id = cpr.business_group_id;
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'prerequisite_course_id'
    ,p_argument_value     => p_prerequisite_course_id
    );
  --
  if (( nvl(ota_cpr_bus.g_activity_version_id, hr_api.g_number)
       = p_activity_version_id)
  and ( nvl(ota_cpr_bus.g_prerequisite_course_id, hr_api.g_number)
       = p_prerequisite_course_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_cpr_bus.g_legislation_code;
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
    ota_cpr_bus.g_activity_version_id         := p_activity_version_id;
    ota_cpr_bus.g_prerequisite_course_id      := p_prerequisite_course_id;
    ota_cpr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in ota_cpr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_cpr_shd.api_updating
      (p_activity_version_id               => p_rec.activity_version_id
      ,p_prerequisite_course_id            => p_rec.prerequisite_course_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--   The activity version id and prerequisite course id must form a unique key.
--
--   This procedure checks whether the prerequisite course has already been
--   attached to the destination course

Procedure check_unique_key
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
  ) is
  --
  l_exists varchar2(1);
  l_proc   varchar2(72) := g_package||'check_unique_key';
  --
  cursor sel_unique_key is
    select 'Y'
      from OTA_COURSE_PREREQUISITES cpr
     where cpr.activity_version_id = p_activity_version_id
       and cpr.prerequisite_course_id = p_prerequisite_course_id;
--
Begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  Open sel_unique_key;
  fetch sel_unique_key into l_exists;
  --
  if sel_unique_key%found then
    close sel_unique_key;

    fnd_message.set_name('OTA', 'OTA_443707_DUP_CRS_PREREQ');
    fnd_message.raise_error;
  end if;
  close sel_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
  Exception
  WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_COURSE_PREREQUISITES.activity_version_id',
                    p_associated_column2    => 'OTA_COURSE_PREREQUISITES.prerequisite_course_id')
                                                              THEN
                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End check_unique_key;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_prereq_course_expiry >----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates the expiry date of prerequisite course
--   Prerequisite course end date must be greater than or equal to sysdate
--
Procedure check_prereq_course_expiry
  (
   p_prerequisite_course_id in number
  ) is
  --
  cursor get_prereq_crs_end_date is
    select nvl(end_date, trunc(sysdate))
    from OTA_ACTIVITY_VERSIONS oav
    where oav.activity_version_id = p_prerequisite_course_id;

  l_prereq_crs_end_date OTA_ACTIVITY_VERSIONS.END_DATE%TYPE;
  l_proc                  varchar2(72) := g_package||'check_prereq_course_expiry';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  Open get_prereq_crs_end_date;
  fetch get_prereq_crs_end_date into l_prereq_crs_end_date;
  close get_prereq_crs_end_date;

  If ( l_prereq_crs_end_date < trunc(sysdate) ) Then
    fnd_message.set_name('OTA', 'OTA_443751_PREREQ_CRS_EXPIRED');
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_COURSE_PREREQUISITES.prerequisite_course_id')
                                           THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
End check_prereq_course_expiry;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_course_start_date >-----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates the start date of prerequisite and destination courses
--   Prerequisite course start date must be less than or equal to destination
--   course start date.
--
Procedure check_course_start_date
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
  ) is
  --
  cursor get_course_start_date(p_crs_id in number) is
    select nvl(start_date, trunc(sysdate))
      from OTA_ACTIVITY_VERSIONS oav
     where oav.activity_version_id = p_crs_id;

  l_dest_course_start_date OTA_ACTIVITY_VERSIONS.START_DATE%TYPE;
  l_prereq_course_start_date OTA_ACTIVITY_VERSIONS.START_DATE%TYPE;
  l_proc                  varchar2(72) := g_package||'check_course_start_date';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  Open get_course_start_date(p_activity_version_id);
  fetch get_course_start_date into l_dest_course_start_date;
  close get_course_start_date;

  Open get_course_start_date(p_prerequisite_course_id);
  fetch get_course_start_date into l_prereq_course_start_date;
  close get_course_start_date;

  If ( l_prereq_course_start_date > l_dest_course_start_date ) Then
    fnd_message.set_name('OTA', 'OTA_443708_CRS_PREREQ_ST_DT_GR');
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN
               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_COURSE_PREREQUISITES.activity_version_id',
                    p_associated_column2    => 'OTA_COURSE_PREREQUISITES.prerequisite_course_id')
                                           THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
End check_course_start_date;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_valid_classes_available >-----------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates whether prerequisite course contains valid classes or not.
--   Course should have associated offering and valid classes. Valid classes
--   include classes  whose class type is SCHEDULED or SELFPACED and whose
--   class status is not Cancelled and which are not expired
--
Procedure check_valid_classes_available
  (p_prerequisite_course_id in number
  ) is
  --
  cursor get_valid_classes is
    select 'Y'
      from OTA_EVENTS oev
     where oev.ACTIVITY_VERSION_ID = p_prerequisite_course_id
           and (oev.EVENT_TYPE = 'SCHEDULED' or oev.EVENT_TYPE = 'SELFPACED')
	   and oev.EVENT_STATUS <> 'A'
	   and nvl(trunc(oev.course_end_date), trunc(sysdate)) >= trunc(sysdate);

  l_proc                  varchar2(72) := g_package||'check_valid_classes_available';
  l_flag varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  Open get_valid_classes;
  fetch get_valid_classes into l_flag;

  If ( get_valid_classes%notfound ) Then
    close get_valid_classes;

    fnd_message.set_name('OTA', 'OTA_443709_CRS_PREREQ_NOVLDCLS');
    fnd_message.raise_error;
  End If;
  close get_valid_classes;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_COURSE_PREREQUISITES.prerequisite_course_id')
                                           THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
End check_valid_classes_available;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_course_chaining >------------------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates whether specifying prerequisite course for a course results in
--   course chaining or not.
--
Procedure check_course_chaining
  (
   p_activity_version_id in number
  ,p_prerequisite_course_id in number
  ) is
  --
  cursor is_course_chained is
    select 'Y'
    from OTA_COURSE_PREREQUISITES cpr
    where cpr.PREREQUISITE_COURSE_ID = p_activity_version_id
	  and cpr.PREREQUISITE_COURSE_ID in
	      (select PREREQUISITE_COURSE_ID
	       from ota_course_prerequisites
	       start with ACTIVITY_VERSION_ID = p_prerequisite_course_id
	       connect by prior PREREQUISITE_COURSE_ID = ACTIVITY_VERSION_ID);

  l_proc                  varchar2(72) := g_package||'check_course_chaining';
  l_flag varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  if ( p_activity_version_id = p_prerequisite_course_id ) then
    fnd_message.set_name('OTA', 'OTA_443727_CRS_PREREQ_CHAINING');
    fnd_message.raise_error;
  else
	  Open is_course_chained;
	  fetch is_course_chained into l_flag;

	  If ( is_course_chained%found ) Then
	    close is_course_chained;

	    fnd_message.set_name('OTA', 'OTA_443727_CRS_PREREQ_CHAINING');
	    fnd_message.raise_error;
	  End If;
	  close is_course_chained;
  end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);

  Exception
  WHEN app_exception.application_exception THEN

               IF hr_multi_message.exception_add(
                    p_associated_column1    => 'OTA_COURSE_PREREQUISITES.activity_version_id',
                    p_associated_column2    => 'OTA_COURSE_PREREQUISITES.prerequisite_course_id')
                                           THEN

                   hr_utility.set_location(' Leaving:'||l_proc, 22);
                   RAISE;

               END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 25);
  --
End check_course_chaining;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cpr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes

  check_unique_key( p_rec.activity_version_id
                  , p_rec.prerequisite_course_id );

--  check_valid_classes_available( p_rec.prerequisite_course_id ); --Bug 4452700

  check_prereq_course_expiry( p_rec.prerequisite_course_id );

  check_course_start_date( p_rec.activity_version_id
                         , p_rec.prerequisite_course_id );

  check_course_chaining( p_rec.activity_version_id
                       , p_rec.prerequisite_course_id );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cpr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cpr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
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
  (p_rec                          in ota_cpr_shd.g_rec_type
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
end ota_cpr_bus;

/
