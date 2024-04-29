--------------------------------------------------------
--  DDL for Package Body HR_INT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INT_BUS" as
/* $Header: hrintrhi.pkb 115.0 2004/01/09 01:40 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_int_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_integration_id              number         default null;
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
  (p_rec in hr_int_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_int_shd.api_updating
      (p_integration_id                    => p_rec.integration_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.integration_key, hr_api.g_varchar2) <>
       nvl(hr_int_shd.g_old_rec.integration_key
           ,hr_api.g_varchar2
           ) then
      hr_api.argument_changed_error
        (p_api_name   => l_proc
        ,p_argument   => 'INTEGRATION_KEY'
        ,p_base_table => hr_int_shd.g_tab_nam
        );
  end if;


End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_INTEGRATION_KEY>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures integration key is not null and unique.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_integration_key
-- Post Success:
--   Processing continues if integration key is not null and unique
--
-- Post Failure:
--   An application error is raised if integration key is null or exists
--   already in table.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_integration_key
  (p_integration_key     in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_INTEGRATION_KEY';
  l_key     varchar2(1) ;
  cursor csr_name is
         select null
           from hr_ki_integrations
          where  integration_key = p_integration_key;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'INTEGRATION_KEY'
  ,p_argument_value     => p_integration_key
  );

  hr_utility.set_location('Validating:'||l_proc,20);
    open csr_name;
    fetch csr_name into l_key;
    if (csr_name%found)
    then
      close csr_name;
      fnd_message.set_name('PER','PER_449965_INT_IN_KEY_DUP');
      fnd_message.raise_error;
    end if;
    close csr_name;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.INTEGRATION_KEY'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_integration_key;

-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_SYNCHED>----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures synched is set to 'Y' for URL and 'N' for SSO and
--   ECX type of integrations.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_synched
--   p_url
-- Post Success:
--   Processing continues if synched is set to 'Y' for URL and 'N' for SSO and
--   ECX type of integrations.
--
-- Post Failure:
--   An application error is raised for invalid value of synched.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_synched
  (p_synched     in out nocopy varchar2
  ,p_url  in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_synched';

--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

  if p_url is not null then
     p_synched := 'Y';
  else
     p_synched := 'N';
  end if;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.SYNCHED'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_synched;

-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_SYNCHED_UPD>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures synched is set to 'Y' for URL and 'Y' or 'N'
--   for SSO and ECX type of integrations.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_synched
--   p_url
-- Post Success:
--   Processing continues if synched is set to 'Y' for URL and 'Y' or 'N'
--   for SSO and ECX type of integrations.
--
-- Post Failure:
--   An application error is raised for invalid value of synched.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_synched_upd
  (p_synched     in varchar2
  ,p_url  in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_synched_upd';

--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'SYNCHED'
  ,p_argument_value     => p_synched
  );

  hr_utility.set_location('Validating:'||l_proc,20);

  if upper(p_synched) ='Y' or upper(p_synched)='N' then

        if (upper(p_synched) ='N' and p_url is not null ) then
            --For URL type of integration synched should be Y
            fnd_message.set_name('PER', 'PER_449973_INT_URL_SYND_INVAL');
            fnd_message.raise_error;
        end if;

  else
          fnd_message.set_name('PER', 'PER_449974_INT_SYNCHED_INVAL');
          fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.SYNCHED'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_synched_upd;

-- ----------------------------------------------------------------------------
-- |-------------------------------<CHK_SSO_DETAILS>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if the ecx details values are valid
--   are not duplicated in hr_ki_integration table
--   provided they are not null.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_insert
--   p_ext_application_id
--   p_application_name
--   p_application_type
--   p_application_url
--   p_logout_url
--   p_user_field
--   p_password_field
--   p_authentication_needed

--
-- Post Success:
--   Processing continues if ecx details are not null and are present in ecx
--   views and not duplicated in hr_ki_integration table.
--
-- Post Failure:
--   An application error is raised if ecx details are invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_SSO_DETAILS
  (
    p_insert in varchar2
   ,p_ext_application_id in number
   ,p_application_name in varchar2
   ,p_application_type in varchar2
   ,p_application_url  in varchar2
   ,p_logout_url       in varchar2
   ,p_user_field       in varchar2
   ,p_password_field   in varchar2
   ,p_authentication_needed in varchar2
   ,p_integration_id in number
  ) IS
--
  l_proc        varchar2(72) := g_package || 'CHK_SSO_DETAILS';

  l_key_sso     varchar2(1) ;
  l_key_sso_upd     varchar2(1) ;

  cursor csr_sso is
         select null
           from hr_ki_integrations
          where
          application_name=p_application_name
          and application_type=p_application_type
          and application_url=p_application_url
          and logout_url=p_logout_url
          and user_field=p_user_field
          and password_field=p_password_field
          and authentication_needed=p_authentication_needed;

  cursor csr_sso_upd is
         select null
           from hr_ki_integrations
          where
          application_name=p_application_name
          and application_type=p_application_type
          and application_url=p_application_url
          and logout_url=p_logout_url
          and user_field=p_user_field
          and password_field=p_password_field
          and authentication_needed=p_authentication_needed
          and integration_id<>p_integration_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with record validation when the
-- Multiple Message List does not already contain an errors
-- associated with the party_name
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
       ,p_associated_column1 => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
  ) then


          --For insert mode ext_application_id must be null
          if(p_insert ='insert') then
                if(p_ext_application_id is not null) then
                fnd_message.set_name('PER','PER_449976_INT_SSO_ID_INVALID');
                fnd_message.raise_error;
                end if;
          end if;

         --If any ofthe SSO parameters are not null then validate SSO details

          if ( p_application_name is not null
                or p_application_type is not null
                or p_application_url is not null
                or p_logout_url is not null
                or p_user_field is not null
                or p_password_field  is not null
                or p_authentication_needed is not null
                )then

                  if (p_application_name is  null
                      or p_application_type is  null
                      or p_application_url is null
                      or p_logout_url is null
                      or p_user_field is null
                      or p_password_field  is null
                      or p_authentication_needed is null
                    ) then
                      fnd_message.set_name('PER','PER_449977_INT_SSO_COL_INVALID');
                      fnd_message.raise_error;
                    end if;
            end if;

          hr_utility.set_location('Validating:'||l_proc,20);

          --for only URL case
          --all SSO details will be null so this IF condition!

          if ( p_application_name is not null
                or p_application_type is not null
                or p_application_url is not null
                or p_logout_url is not null
                or p_user_field is not null
                or p_password_field  is not null
                or p_authentication_needed is not null
                )then

            hr_utility.set_location('Validating combination'||l_proc,30);
           --
           --Check if SSO combination already exists in the hr_ki_integrations table.
           --
           if(p_insert ='insert') then
                    open csr_sso;
                    fetch csr_sso into l_key_sso;
                    if (csr_sso%found)
                    then
                      close csr_sso;
                      fnd_message.set_name('PER','PER_449978_INT_SSO_DT_DUPLI');
                      fnd_message.raise_error;
                    end if;
                    close csr_sso;
           else
                    open csr_sso_upd;
                    fetch csr_sso_upd into l_key_sso_upd;
                    if (csr_sso_upd%found)
                    then
                      close csr_sso_upd;
                      fnd_message.set_name('PER','PER_449978_INT_SSO_DT_DUPLI');
                      fnd_message.raise_error;
                    end if;
                    close csr_sso_upd;
           end if;

          end if;
  end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_SSO_DETAILS;
-- ----------------------------------------------------------------------------
-- |---------------------< CHK_EXT_APPLICATION_ID_UPD>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures external application id is present in
--   hr_ki_ext_applications and it is not duplicated in hr_ki_integrations
--   table.
--   If earlier procedure is used for update validation then error will be
--   thrown even if id is unique and not null as earlier query
--   does not have addtional p_ext_application_id condition in the cursor.
--   We can not combine these 2 methods as p_integration_id is not
--   available at the time of insert_validation
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_ext_application_id
--   p_integration_id
-- Post Success:
--   Processing continues if ext_application_id is valid.
--
-- Post Failure:
--   An application error is raised if if ext_application_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_EXT_APPLICATION_ID_UPD
  (p_ext_application_id     in number
  ,p_integration_id         in number
  ) IS
--
  l_proc        varchar2(72) := g_package || 'CHK_EXT_APPLICATION_ID_UPD';
  l_key         varchar2(1) ;
  l_key_app     varchar2(1) ;
  cursor csr_name is
         select null
          from hr_ki_ext_applications
          where  ext_application_id = p_ext_application_id;
  cursor csr_app is
         select null
          from hr_ki_integrations
          where  ext_application_id = p_ext_application_id
          and integration_id<>p_integration_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
       ,p_associated_column1 => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
  ) then

          if p_ext_application_id is not null then

          hr_utility.set_location('Validating ID:'||l_proc,20);

            open csr_name;
            fetch csr_name into l_key;
            if (csr_name%notfound)
            then
              close csr_name;
              fnd_message.set_name('PER','PER_449970_INT_EXT_ID_ABSENT');
              fnd_message.raise_error;
            end if;
            close csr_name;

            --Now check if ext_application_id is already present in the
            --hr_ki_integrations table

          hr_utility.set_location('Validating ID in Integrations table:'||l_proc,30);
            open csr_app;
            fetch csr_app into l_key_app;
            if (csr_app%found)
            then
              close csr_app;
              fnd_message.set_name('PER','PER_449971_INT_EXT_ID_DUPLI');
              fnd_message.raise_error;
            end if;
            close csr_app;

        end if;

  end if;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_EXT_APPLICATION_ID_UPD;

-- ----------------------------------------------------------------------------
-- |-------------------------------<CHK_ECX_DETAILS>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if the ecx details values are present in the ecx
--   views and are not duplicated in hr_ki_integration table
--   provided they are not null.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   ,p_party_type
--   ,p_party_name
--   ,p_party_site_name
--   ,p_transaction_type
--   ,p_transaction_subtype
--   ,p_standard_code
--   ,p_ext_trans_type
--   ,p_ext_trans_subtype
--   ,p_trans_direction
--
-- Post Success:
--   Processing continues if ecx details are not null and are present in ecx
--   views and not duplicated in hr_ki_integration table.
--
-- Post Failure:
--   An application error is raised if ecx details are invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_ECX_DETAILS
  (
   p_party_type in       varchar2
  ,p_party_name in       varchar2
  ,p_party_site_name   in   varchar2
  ,p_transaction_type  in   varchar2
  ,p_transaction_subtype in  varchar2
  ,p_standard_code      in  varchar2
  ,p_ext_trans_type     in  varchar2
  ,p_ext_trans_subtype  in  varchar2
  ,p_trans_direction    in  varchar2
  ,p_integration_id     in number
  ) IS
--
  l_proc        varchar2(72) := g_package || 'CHK_ECX_DETAILS';

  l_key_ecx     varchar2(1) ;
  l_key_ecx_upd     varchar2(1) ;

  cursor csr_ecx is
         select null
           from hr_ki_integrations
          where party_type=p_party_type
          and party_name=p_party_name
          and party_site_name=p_party_site_name
          and transaction_type=p_transaction_type
          and transaction_subtype=p_transaction_subtype
          and standard_code=p_standard_code
          and ext_trans_type=p_ext_trans_type
          and ext_trans_subtype=p_ext_trans_subtype
          and trans_direction=p_trans_direction;

  cursor csr_ecx_upd is
         select null
           from hr_ki_integrations
          where party_type=p_party_type
          and party_name=p_party_name
          and party_site_name=p_party_site_name
          and transaction_type=p_transaction_type
          and transaction_subtype=p_transaction_subtype
          and standard_code=p_standard_code
          and ext_trans_type=p_ext_trans_type
          and ext_trans_subtype=p_ext_trans_subtype
          and trans_direction=p_trans_direction
          and integration_id<>p_integration_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with record validation when the
-- Multiple Message List does not already contain an errors
-- associated with the party_name
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_INTEGRATIONS.PARTY_NAME'
       ,p_associated_column1 => 'HR_KI_INTEGRATIONS.PARTY_NAME'
  ) then

          --If any ofthe ECX parameters are not null then validate ECX details
          if ( p_party_type is not null
                or p_party_name is not null
                or p_party_site_name is not null
                or p_transaction_type is not null
                or p_transaction_subtype is not null
                or p_standard_code  is not null
                or p_ext_trans_type is not null
                or p_ext_trans_subtype is not null
                or p_trans_direction is not null )then

                  if (p_party_type is  null
                      or p_party_name is  null
                      or p_party_site_name is null
                      or p_transaction_type is null
                      or p_transaction_subtype is null
                      or p_standard_code  is null
                      or p_ext_trans_type is null
                      or p_ext_trans_subtype is null
                      or p_trans_direction is null
                    ) then
                      fnd_message.set_name('PER','PER_449967_INT_ECX_COL_INVALID');
                      fnd_message.raise_error;
                    end if;
            end if;

          hr_utility.set_location('Validating:'||l_proc,20);

          if ( p_party_type is not null
                and p_party_name is not null
                and p_party_site_name is not null
                and p_transaction_type is not null
                and p_transaction_subtype is not null
                and p_standard_code  is not null
                and p_ext_trans_type is not null
                and p_ext_trans_subtype is not null
                and p_trans_direction is not null )then

            hr_utility.set_location('Validating combination'||l_proc,30);
           --
           --Check if ECX combination already exists in the hr_ki_integrations table.
           --
           --For insert use csr_ecx cursor since integration_id will be null
           --For update use csr_ecx_upd cursor
                if p_integration_id is null then
                    open csr_ecx;
                    fetch csr_ecx into l_key_ecx;
                    if (csr_ecx%found)
                    then
                      close csr_ecx;
                      fnd_message.set_name('PER','PER_449969_INT_ECX_DT_DUPLI');
                      fnd_message.raise_error;
                    end if;
                    close csr_ecx;
                 else
                    open csr_ecx_upd;
                    fetch csr_ecx_upd into l_key_ecx_upd;
                    if (csr_ecx_upd%found)
                    then
                      close csr_ecx_upd;
                      fnd_message.set_name('PER','PER_449969_INT_ECX_DT_DUPLI');
                      fnd_message.raise_error;
                    end if;
                    close csr_ecx_upd;
                 end if;
          end if;
  end if;

  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.PARTY_NAME'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_ECX_DETAILS;


-- ----------------------------------------------------------------------------
-- |--------------------------< CHK_INTEGRATION_RECORD>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that for simple URL integrations ECX details and
--   SSO columns are null and for ECX integration SSO and url columns
--   are null and for SSO integration ECX and url columns are null.
--   We will not consider field_name1.. and field_value1.. columns
--   in the validation.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_url
--   p_ext_application_id
--   p_party_type
--   p_party_name
--   p_party_site_name
--   p_transaction_type
--   p_transaction_subtype
--   p_standard_code
--   p_ext_trans_type
--   p_ext_trans_subtype
--   p_trans_direction
--   p_application_name
--   p_application_type
--   p_application_url
--   p_logout_url
--   p_user_field
--   p_password_field
--   p_authentication_needed
--
-- Post Success:
--   Processing continues if conditions specified as above are valid.
--
-- Post Failure:
--   An application error is raised if conditions specified as above are invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_INTEGRATION_RECORD
  (p_url     in varchar2
  ,p_ext_application_id in number
  ,p_application_name in varchar2
  ,p_application_type in varchar2
  ,p_application_url  in varchar2
  ,p_logout_url       in varchar2
  ,p_user_field       in varchar2
  ,p_password_field   in varchar2
  ,p_authentication_needed in varchar2
  ,p_party_type in       varchar2
  ,p_party_name in       varchar2
  ,p_party_site_name   in   varchar2
  ,p_transaction_type  in   varchar2
  ,p_transaction_subtype in  varchar2
  ,p_standard_code      in  varchar2
  ,p_ext_trans_type     in  varchar2
  ,p_ext_trans_subtype  in  varchar2
  ,p_trans_direction    in  varchar2
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_INTEGRATION_RECORD';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);


--At least one column out of url,ext_application_id and ecx column should
-- be not null

          if (p_application_name is null
          and p_application_name is null
          and p_application_type is null
          and p_application_url  is null
          and p_logout_url       is null
          and p_user_field       is null
          and p_password_field   is null
          and p_authentication_needed is null
          and p_url is null
          and p_party_type is  null
          and p_party_name is  null
          and p_party_site_name is  null
          and p_transaction_type is null
          and p_transaction_subtype is null
          and p_standard_code  is null
          and p_ext_trans_type is null
          and p_ext_trans_subtype is null
          and p_trans_direction is null
         ) then
                  fnd_message.set_name('PER', 'PER_449966_INT_MAN_COL_NULL');
                  fnd_message.raise_error;
         end if;

         hr_utility.set_location('Validating extAppId:'||l_proc,20);

         --for SSO type of integrations url and ecx details should be null

          if (p_ext_application_id is not null
          or p_application_name is not null
          or p_application_type is not null
          or p_application_url  is not null
          or p_logout_url       is not null
          or p_user_field       is not null
          or p_password_field   is not null
          or p_authentication_needed   is not null

          )then
                if (p_url is not null
                    or p_party_type is not null
                    or p_party_name is not null
                    or p_party_site_name is not null
                    or p_transaction_type is not null
                    or p_transaction_subtype is not null
                    or p_standard_code  is not null
                    or p_ext_trans_type is not null
                    or p_ext_trans_subtype is not null
                    or p_trans_direction is not null
                    ) then

                  fnd_message.set_name('PER', 'PER_449975_INT_U_E_S_INVALID');
                  fnd_message.raise_error;
                end if;

          end if;


          hr_utility.set_location('Validating ECX:'||l_proc,30);
          --
          --for ECX type of integrations url and SSO details
          --should be null


          if (p_party_type is not null
              and p_party_name is not null
              and p_party_site_name is not null
              and p_transaction_type is not null
              and p_transaction_subtype is not null
              and p_standard_code  is not null
              and p_ext_trans_type is not null
              and p_ext_trans_subtype is not null
              and p_trans_direction is not null) then

                if (p_url is not null or p_ext_application_id is not null
                or p_application_name is not null
                or p_application_type is not null
                or p_application_url  is not null
                or p_logout_url       is not null
                or p_user_field       is not null
                or p_password_field   is not null
                ) then
                  fnd_message.set_name('PER', 'PER_449975_INT_U_E_S_INVALID');
                  fnd_message.raise_error;
                end if;

          end if;

         hr_utility.set_location('Validating URL:'||l_proc,40);
         --
         --for simple URL type of integrations ,SSO details
         --and ecx details should be null


         if p_url is not null then

                if (p_ext_application_id is not null
                    or p_application_name is not null
                    or p_application_type is not null
                    or p_application_url  is not null
                    or p_logout_url       is not null
                    or p_user_field       is not null
                    or p_password_field   is not null
                    or p_party_type is not null
                    or p_party_name is not null
                    or p_party_site_name is not null
                    or p_transaction_type is not null
                    or p_transaction_subtype is not null
                    or p_standard_code  is not null
                    or p_ext_trans_type is not null
                    or p_ext_trans_subtype is not null
                    or p_trans_direction is not null
                    ) then
                  fnd_message.set_name('PER', 'PER_449975_INT_U_E_S_INVALID');
                  fnd_message.raise_error;
                end if;

          end if;



  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS.URL'
    ,p_associated_column2 => 'HR_KI_INTEGRATIONS.EXT_APPLICATION_ID'
    ,p_associated_column3 => 'HR_KI_INTEGRATIONS.PARTY_NAME'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End CHK_INTEGRATION_RECORD;

-- ----------------------------------------------------------------------------
-- -------------------------------< CHK_DELETE>--------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a delete occurs only if there are no child
--   rows for a record in hr_ki_integrations. The tables that contain child
--   rows are hr_ki_integrations_tl,hr_ki_topic_integrations,hr_ki_options.
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_integration_id

-- Post Success:
--   Processing continues if there are no child records.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
  (p_integration_id                        in number
  )
  is
  --
  -- Declare local variables
  --
  l_proc              varchar2(72) :=  g_package||'chk_delete';
  l_exists            varchar2(1);
  l_exists_ext        varchar2(1);
  l_exists_ti         varchar2(1);
  l_exists_tl         varchar2(1);
  --
  --  Cursor to check that if maintenance rows exists.
  --
  cursor csr_maintenance_option is
    select null
      from hr_ki_options
     where integration_id = p_integration_id;

  cursor csr_maintenance_ti is
    select null
      from hr_ki_topic_integrations
     where integration_id = p_integration_id;

  cursor csr_maintenance_tl is
    select null
      from hr_ki_integrations_tl
     where integration_id = p_integration_id;

  cursor csr_maintenance_extapp is
     select null from hr_ki_integrations inte,hr_ki_ext_applications ext
      where inte.integration_id=p_integration_id
        and  inte.ext_application_id=ext.ext_application_id;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Can always execute the cursor as chk_delete
  -- will only be called for delete validation
  -- from within the row handler.
  --
  open csr_maintenance_option;
  fetch csr_maintenance_option into l_exists;
  if csr_maintenance_option%found then
    close csr_maintenance_option;
    fnd_message.set_name('PER', 'PER_449979_INT_OPT_MAIN_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_option;

  open csr_maintenance_extapp;
  fetch csr_maintenance_extapp into l_exists_ext;
  if csr_maintenance_extapp%found then
    close csr_maintenance_extapp;
    fnd_message.set_name('PER', 'PER_449982_INT_EXT_MAIN_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_extapp;

  hr_utility.set_location('Checking for Topic Integrations:'|| l_proc, 20);
  open csr_maintenance_ti;
  fetch csr_maintenance_ti into l_exists_ti;
  if csr_maintenance_ti%found then
    close csr_maintenance_ti;
    fnd_message.set_name('PER', 'PER_449980_INT_TOIN_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_ti;

  hr_utility.set_location('Checking for TL:'|| l_proc, 30);
  open csr_maintenance_tl;
  fetch csr_maintenance_tl into l_exists_tl;
  if csr_maintenance_tl%found then
    close csr_maintenance_tl;
    fnd_message.set_name('PER', 'PER_449981_INT_TL_EXIST');
    fnd_message.raise_error;
  end if;
  close csr_maintenance_tl;

  hr_utility.set_location(' Leaving:'|| l_proc, 40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
          (p_associated_column1 => 'HR_KI_INTEGRATIONS.integration_id'
          ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in out nocopy hr_int_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  CHK_INTEGRATION_KEY
  (
   p_integration_key  => p_rec.integration_key
  );

  CHK_INTEGRATION_RECORD
  (p_url =>p_rec.url
  ,p_ext_application_id=>p_rec.ext_application_id
  ,p_application_name  => p_rec.application_name
  ,p_application_type => p_rec.application_type
  ,p_application_url  => p_rec.application_url
  ,p_logout_url       => p_rec.logout_url
  ,p_user_field       => p_rec.user_field
  ,p_password_field   => p_rec.password_field
  ,p_authentication_needed =>  p_rec.authentication_needed
  ,p_party_type =>p_rec.party_type
  ,p_party_name =>p_rec.party_name
  ,p_party_site_name =>p_rec.party_site_name
  ,p_transaction_type =>p_rec.transaction_type
  ,p_transaction_subtype =>p_rec.transaction_subtype
  ,p_standard_code =>p_rec.standard_code
  ,p_ext_trans_type =>p_rec.ext_trans_type
  ,p_ext_trans_subtype =>p_rec.ext_trans_subtype
  ,p_trans_direction =>p_rec.trans_direction
   );

  CHK_SSO_DETAILS
  (
   p_insert                 => 'insert'
  ,p_ext_application_id     => p_rec.ext_application_id
  ,p_application_name       => p_rec.application_name
  ,p_application_type       => p_rec.application_type
  ,p_application_url        => p_rec.application_url
  ,p_logout_url             => p_rec.logout_url
  ,p_user_field             => p_rec.user_field
  ,p_password_field         => p_rec.password_field
  ,p_authentication_needed  =>  p_rec.authentication_needed
  ,p_integration_id         => null
  );

  CHK_ECX_DETAILS
  (
   p_party_type =>p_rec.party_type
  ,p_party_name =>p_rec.party_name
  ,p_party_site_name =>p_rec.party_site_name
  ,p_transaction_type =>p_rec.transaction_type
  ,p_transaction_subtype =>p_rec.transaction_subtype
  ,p_standard_code =>p_rec.standard_code
  ,p_ext_trans_type =>p_rec.ext_trans_type
  ,p_ext_trans_subtype =>p_rec.ext_trans_subtype
  ,p_trans_direction =>p_rec.trans_direction
  ,p_integration_id         => null
   );

  chk_synched
  (
   p_synched => p_rec.synched
  ,p_url =>p_rec.url
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_int_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  CHK_INTEGRATION_RECORD
  (p_url =>p_rec.url
  ,p_ext_application_id=>p_rec.ext_application_id
  ,p_application_name  => p_rec.application_name
  ,p_application_type => p_rec.application_type
  ,p_application_url  => p_rec.application_url
  ,p_logout_url       => p_rec.logout_url
  ,p_user_field       => p_rec.user_field
  ,p_password_field   => p_rec.password_field
  ,p_authentication_needed =>  p_rec.authentication_needed
  ,p_party_type =>p_rec.party_type
  ,p_party_name =>p_rec.party_name
  ,p_party_site_name =>p_rec.party_site_name
  ,p_transaction_type =>p_rec.transaction_type
  ,p_transaction_subtype =>p_rec.transaction_subtype
  ,p_standard_code =>p_rec.standard_code
  ,p_ext_trans_type =>p_rec.ext_trans_type
  ,p_ext_trans_subtype =>p_rec.ext_trans_subtype
  ,p_trans_direction =>p_rec.trans_direction
   );

  CHK_EXT_APPLICATION_ID_UPD
  (
   p_ext_application_id=>p_rec.ext_application_id
   ,p_integration_id   =>p_rec.integration_id
  );

  CHK_SSO_DETAILS
  (
   p_insert                 => 'update'
  ,p_ext_application_id     => p_rec.ext_application_id
  ,p_application_name       => p_rec.application_name
  ,p_application_type       => p_rec.application_type
  ,p_application_url        => p_rec.application_url
  ,p_logout_url             => p_rec.logout_url
  ,p_user_field             => p_rec.user_field
  ,p_password_field         => p_rec.password_field
  ,p_authentication_needed  =>  p_rec.authentication_needed
  ,p_integration_id         => p_rec.integration_id
  );

  CHK_ECX_DETAILS
  (
   p_party_type =>p_rec.party_type
  ,p_party_name =>p_rec.party_name
  ,p_party_site_name =>p_rec.party_site_name
  ,p_transaction_type =>p_rec.transaction_type
  ,p_transaction_subtype =>p_rec.transaction_subtype
  ,p_standard_code =>p_rec.standard_code
  ,p_ext_trans_type =>p_rec.ext_trans_type
  ,p_ext_trans_subtype =>p_rec.ext_trans_subtype
  ,p_trans_direction =>p_rec.trans_direction
  ,p_integration_id         => p_rec.integration_id
   );

  chk_synched_upd
  (
   p_synched => p_rec.synched
  ,p_url =>p_rec.url
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
  (p_rec                          in hr_int_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  CHK_DELETE
  (
  p_integration_id =>p_rec.integration_id
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_int_bus;

/
