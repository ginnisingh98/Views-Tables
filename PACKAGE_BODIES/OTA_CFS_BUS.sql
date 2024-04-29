--------------------------------------------------------
--  DDL for Package Body OTA_CFS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CFS_BUS" as
/* $Header: otcfsrhi.pkb 120.2 2005/08/24 09:49 dhmulia noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cfs_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_conference_server_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_conference_server_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_conference_servers_b cfs
     where cfs.conference_server_id = p_conference_server_id
       and pbg.business_group_id = cfs.business_group_id;
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
    ,p_argument           => 'conference_server_id'
    ,p_argument_value     => p_conference_server_id
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
        => nvl(p_associated_column1,'CONFERENCE_SERVER_ID')
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
  (p_conference_server_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_conference_servers_b cfs
     where cfs.conference_server_id = p_conference_server_id
       and pbg.business_group_id = cfs.business_group_id;
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
    ,p_argument           => 'conference_server_id'
    ,p_argument_value     => p_conference_server_id
    );
  --
  if ( nvl(ota_cfs_bus.g_conference_server_id, hr_api.g_number)
       = p_conference_server_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_cfs_bus.g_legislation_code;
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
    ota_cfs_bus.g_conference_server_id        := p_conference_server_id;
    ota_cfs_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_error_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_error_message
  (
   p_error_appl             varchar2
  ,p_error_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_error_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add error message with the following text.
  --
  fnd_message.set_name      ( p_error_appl     ,p_error_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_error_message;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in ota_cfs_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.conference_server_id is not null)  and (
    nvl(ota_cfs_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_cfs_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.conference_server_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CONFERENCE_SERVERS'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  ,p_rec in ota_cfs_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_cfs_shd.api_updating
      (p_conference_server_id              => p_rec.conference_server_id
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
-- -----------------------< CHECK_UNIQUE >----------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the conference server name(ignoring case).
--
procedure CHECK_UNIQUE (
	P_NAME					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
      P_CONFERENCE_SERVER_ID                   in number

	) is
	--
	W_PROC						varchar2 (72)
		:= G_PACKAGE || 'CHECK_UNIQUE';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Do not perform the uniqueness check unless inserting, or updating
	--	with a value different from the current value (and not just changing
	--	case)
	--
		--
		if (not UNIQUE_CFS_NAME (
				P_NAME 		         =>  P_NAME,
				P_BUSINESS_GROUP_ID      =>  P_BUSINESS_GROUP_ID,
                       P_CONFERENCE_SERVER_ID   => P_CONFERENCE_SERVER_ID    )) then
                fnd_message.set_name('OTA','OTA_443914_CFS_UNIQUE');
			    fnd_message.raise_error;
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_CONFERENCE_SERVERS_B.BUSINESS_GROUP_ID',
	    p_associated_column2    => 'OTA_CONFERENCE_SERVERS_B.CONFERENCE_SERVER_ID')
	   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;

end CHECK_UNIQUE;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< UNIQUE_CFS_NAME >-----------------------------
-- ----------------------------------------------------------------------------
--
--	Returns TRUE if the event has a title which is unique within its
--	business group. If the event id is not null, then the check avoids
--	comparing the title against itself. Titles are compared regardless
--	of case.
--
--
--
function UNIQUE_CFS_NAME (
	P_NAME 	     in	varchar2,
	P_BUSINESS_GROUP_ID  in	number,
        P_CONFERENCE_SERVER_ID in number
	) return boolean is
--
	W_PROC varchar2 (72)
		:= G_PACKAGE || 'UNIQUE_CFS_NAME';
	v_name_is_unique				boolean;
	--
	cursor C1 is
		SELECT 1
            FROM OTA_CONFERENCE_SERVERS_B CFS,
                 OTA_CONFERENCE_SERVERS_TL CFT
		WHERE CFT.NAME  = P_NAME
            AND   CFS.CONFERENCE_SERVER_ID = CFT.CONFERENCE_SERVER_ID
            AND   CFT.LANGUAGE= USERENV('LANG')
		AND   CFS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
                AND (  CFS.CONFERENCE_SERVER_ID <> P_CONFERENCE_SERVER_ID or
                      P_CONFERENCE_SERVER_ID IS NULL ) ;

/* for Bug 4570526 */
cursor csr_name
IS
select name
from ota_conference_servers_tl cft where
cft.conference_server_id = P_CONFERENCE_SERVER_ID
and CFT.LANGUAGE= USERENV('LANG');

    l_num number(10);
    l_name ota_conference_servers_tl.name%type;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check arguments
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
	 	'P_NAME',
		P_NAME);
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_BUSINESS_GROUP_ID',
		P_BUSINESS_GROUP_ID);
	--
	--	Unique ?
	--
      /* For bug 4570526 */
      if  p_conference_server_id is not null then
	For i in csr_name
	Loop
	   l_name := i.name;
	end loop;
      end if;

     if upper(p_name) <> nvl(upper(l_name),upper(p_name)) or
       p_conference_server_id is null then
	open C1;
	fetch C1
	  into l_num;
	v_name_is_unique := C1%notfound;
	close C1;
     end if;
	--
	HR_UTILITY.SET_LOCATION (W_PROC, 10);
	return v_name_is_unique;
	--
end UNIQUE_CFS_NAME;

procedure VALIDITY_CHECKS (
	P_REC				     in out nocopy OTA_CFS_SHD.G_REC_TYPE
    ,p_name                  in varchar2
	) is

Begin
        CHECK_UNIQUE (
    	p_name,
	    p_rec.business_group_id,
	    p_rec.CONFERENCE_SERVER_ID
	    );


end VALIDITY_CHECKS ;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_conf_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This conference server may not be deleted if child rows in
--   ota_conferences exist.
--
Procedure check_if_conf_exists
  (
   p_conference_server_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_conf_exists';
  --
  cursor sel_conf_exists is
    select 'Y'
      from ota_conferences              cfr
     where cfr.conference_server_id = p_conference_server_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_conf_exists;
  fetch sel_conf_exists into v_exists;
  --
  if sel_conf_exists%found then
    --
    close sel_conf_exists;
    --
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt            =>  'OTA_443745_CFS_NO_DELETE'
                      );
    --
  end if;
  --
  close sel_conf_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_conf_exists;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_cfs_shd.g_rec_type
  ,p_name                in varchar2

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
    ,p_associated_column1 => ota_cfs_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

   VALIDITY_CHECKS (P_REC =>	P_REC,
                    p_name => p_name );

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  ota_cfs_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_cfs_shd.g_rec_type
  ,p_name                         in varchar2
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
    ,p_associated_column1 => ota_cfs_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  VALIDITY_CHECKS (P_REC =>	P_REC,
                    p_name => p_name );

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
  ota_cfs_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_cfs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
    check_if_conf_exists( p_conference_server_id => p_rec.conference_server_id );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_cfs_bus;

/
