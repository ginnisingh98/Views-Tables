--------------------------------------------------------
--  DDL for Package Body HR_KI_INTEGRATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_INTEGRATIONS_API" as
/* $Header: hrintapi.pkb 115.1 2004/01/28 23:31:04 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_INTEGRATIONS_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_INTEGRATION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_integration
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_integration_key               in     varchar2
  ,p_party_type                    in     varchar2 default null
  ,p_party_name                    in     varchar2 default null
  ,p_party_site_name               in     varchar2 default null
  ,p_transaction_type              in     varchar2 default null
  ,p_transaction_subtype           in     varchar2 default null
  ,p_standard_code                 in     varchar2 default null
  ,p_ext_trans_type                in     varchar2 default null
  ,p_ext_trans_subtype             in     varchar2 default null
  ,p_trans_direction               in     varchar2 default null
  ,p_url                           in     varchar2 default null
  ,p_partner_name                  in     varchar2
  ,p_service_name                  in     varchar2
  ,p_ext_application_id            in     number   default null
  ,p_application_name              in     varchar2 default null
  ,p_application_type              in     varchar2 default null
  ,p_application_url               in     varchar2 default null
  ,p_logout_url                    in     varchar2 default null
  ,p_user_field                    in     varchar2 default null
  ,p_password_field                in     varchar2 default null
  ,p_authentication_needed         in     varchar2 default null
  ,p_field_name1                   in     varchar2 default null
  ,p_field_value1                  in     varchar2 default null
  ,p_field_name2                   in     varchar2 default null
  ,p_field_value2                  in     varchar2 default null
  ,p_field_name3                   in     varchar2 default null
  ,p_field_value3                  in     varchar2 default null
  ,p_field_name4                   in     varchar2 default null
  ,p_field_value4                  in     varchar2 default null
  ,p_field_name5                   in     varchar2 default null
  ,p_field_value5                  in     varchar2 default null
  ,p_field_name6                   in     varchar2 default null
  ,p_field_value6                  in     varchar2 default null
  ,p_field_name7                   in     varchar2 default null
  ,p_field_value7                  in     varchar2 default null
  ,p_field_name8                   in     varchar2 default null
  ,p_field_value8                  in     varchar2 default null
  ,p_field_name9                   in     varchar2 default null
  ,p_field_value9                  in     varchar2 default null
  ,p_integration_id                out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_integration';
  l_integration_id      number;
  l_language_code       varchar2(30);
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_integration;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code       := p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_integrations_bk1.create_integration_b
      (
      p_language_code                 =>     l_language_code
     ,p_integration_key               =>     p_integration_key
     ,p_party_type                    =>     p_party_type
     ,p_party_name                    =>     p_party_name
     ,p_party_site_name               =>     p_party_site_name
     ,p_transaction_type              =>     p_transaction_type
     ,p_transaction_subtype           =>     p_transaction_subtype
     ,p_standard_code                 =>     p_standard_code
     ,p_ext_trans_type                =>     p_ext_trans_type
     ,p_ext_trans_subtype             =>     p_ext_trans_subtype
     ,p_trans_direction               =>     p_trans_direction
     ,p_url                           =>     p_url
     ,p_partner_name                  =>     p_partner_name
     ,p_service_name                  =>     p_service_name
     ,p_ext_application_id            =>     p_ext_application_id
     ,p_application_name              =>     p_application_name
     ,p_application_type              =>     p_application_type
     ,p_application_url               =>     p_application_url
     ,p_logout_url                    =>     p_logout_url
     ,p_user_field                    =>     p_user_field
     ,p_password_field                =>     p_password_field
     ,p_authentication_needed         =>     p_authentication_needed
     ,p_field_name1                   =>     p_field_name1
     ,p_field_value1                  =>     p_field_value1
     ,p_field_name2                   =>     p_field_name2
     ,p_field_value2                  =>     p_field_value2
     ,p_field_name3                   =>     p_field_name3
     ,p_field_value3                  =>     p_field_value3
     ,p_field_name4                   =>     p_field_name4
     ,p_field_value4                  =>     p_field_value4
     ,p_field_name5                   =>     p_field_name5
     ,p_field_value5                  =>     p_field_value5
     ,p_field_name6                   =>     p_field_name6
     ,p_field_value6                  =>     p_field_value6
     ,p_field_name7                   =>     p_field_name7
     ,p_field_value7                  =>     p_field_value7
     ,p_field_name8                   =>     p_field_name8
     ,p_field_value8                  =>     p_field_value8
     ,p_field_name9                   =>     p_field_name9
     ,p_field_value9                  =>     p_field_value9
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_int_ins.ins
     (
      p_integration_key               =>     p_integration_key
     ,p_party_type                    =>     p_party_type
     ,p_party_name                    =>     p_party_name
     ,p_party_site_name               =>     p_party_site_name
     ,p_transaction_type              =>     p_transaction_type
     ,p_transaction_subtype           =>     p_transaction_subtype
     ,p_standard_code                 =>     p_standard_code
     ,p_ext_trans_type                =>     p_ext_trans_type
     ,p_ext_trans_subtype             =>     p_ext_trans_subtype
     ,p_trans_direction               =>     p_trans_direction
     ,p_url                           =>     p_url
     ,p_ext_application_id            =>     p_ext_application_id
     ,p_application_name              =>     p_application_name
     ,p_application_type              =>     p_application_type
     ,p_application_url               =>     p_application_url
     ,p_logout_url                    =>     p_logout_url
     ,p_user_field                    =>     p_user_field
     ,p_password_field                =>     p_password_field
     ,p_authentication_needed         =>     p_authentication_needed
     ,p_field_name1                   =>     p_field_name1
     ,p_field_value1                  =>     p_field_value1
     ,p_field_name2                   =>     p_field_name2
     ,p_field_value2                  =>     p_field_value2
     ,p_field_name3                   =>     p_field_name3
     ,p_field_value3                  =>     p_field_value3
     ,p_field_name4                   =>     p_field_name4
     ,p_field_value4                  =>     p_field_value4
     ,p_field_name5                   =>     p_field_name5
     ,p_field_value5                  =>     p_field_value5
     ,p_field_name6                   =>     p_field_name6
     ,p_field_value6                  =>     p_field_value6
     ,p_field_name7                   =>     p_field_name7
     ,p_field_value7                  =>     p_field_value7
     ,p_field_name8                   =>     p_field_name8
     ,p_field_value8                  =>     p_field_value8
     ,p_field_name9                   =>     p_field_name9
     ,p_field_value9                  =>     p_field_value9
     ,p_integration_id                =>     l_integration_id
     ,p_object_version_number         =>     l_object_version_number
      );



  hr_itl_ins.ins_tl(
       p_language_code            => l_language_code
      ,p_integration_id           => l_integration_id
      ,p_partner_name             => p_partner_name
      ,p_service_name             => p_service_name
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_integrations_bk1.create_integration_a
      (
      p_language_code                 =>     l_language_code
     ,p_integration_key               =>     p_integration_key
     ,p_party_type                    =>     p_party_type
     ,p_party_name                    =>     p_party_name
     ,p_party_site_name               =>     p_party_site_name
     ,p_transaction_type              =>     p_transaction_type
     ,p_transaction_subtype           =>     p_transaction_subtype
     ,p_standard_code                 =>     p_standard_code
     ,p_ext_trans_type                =>     p_ext_trans_type
     ,p_ext_trans_subtype             =>     p_ext_trans_subtype
     ,p_trans_direction               =>     p_trans_direction
     ,p_url                           =>     p_url
     ,p_partner_name                  =>     p_partner_name
     ,p_service_name                  =>     p_service_name
     ,p_application_name              =>     p_application_name
     ,p_application_type              =>     p_application_type
     ,p_application_url               =>     p_application_url
     ,p_logout_url                    =>     p_logout_url
     ,p_user_field                    =>     p_user_field
     ,p_password_field                =>     p_password_field
     ,p_authentication_needed         =>     p_authentication_needed
     ,p_field_name1                   =>     p_field_name1
     ,p_field_value1                  =>     p_field_value1
     ,p_field_name2                   =>     p_field_name2
     ,p_field_value2                  =>     p_field_value2
     ,p_field_name3                   =>     p_field_name3
     ,p_field_value3                  =>     p_field_value3
     ,p_field_name4                   =>     p_field_name4
     ,p_field_value4                  =>     p_field_value4
     ,p_field_name5                   =>     p_field_name5
     ,p_field_value5                  =>     p_field_value5
     ,p_field_name6                   =>     p_field_name6
     ,p_field_value6                  =>     p_field_value6
     ,p_field_name7                   =>     p_field_name7
     ,p_field_value7                  =>     p_field_value7
     ,p_field_name8                   =>     p_field_name8
     ,p_field_value8                  =>     p_field_value8
     ,p_field_name9                   =>     p_field_name9
     ,p_field_value9                  =>     p_field_value9
     ,p_integration_id                =>     l_integration_id
     ,p_ext_application_id            =>     p_ext_application_id
     ,p_object_version_number         =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_integration'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_integration_id         := l_integration_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_integration;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_integration_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_integration_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_integration;


-- ----------------------------------------------------------------------------
-- |--------------------------< validate_integration >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_integration
  (p_validate                      in     boolean  default false
  ,p_integration_id                in     number
  ,p_object_version_number         in out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'validate_integration';
  l_object_version_number number := p_object_version_number;

  cursor csr_ecx (cur_party_type in varchar2
                  ,cur_party_name in varchar2
                  ,cur_party_site_name in varchar2
                  ,cur_transaction_type in varchar2
                  ,cur_transaction_subtype in varchar2
                  ,cur_standard_code in varchar2
                  ,cur_ext_trans_type in varchar2
                  ,cur_ext_trans_subtype in varchar2
                  ,cur_trans_direction in varchar2
                )

  is
         select null from ecx_tp_headers_v h,ecx_tp_details_v d
          where h.tp_header_id=d.tp_header_id
          and h.party_type=cur_party_type
          and h.party_name=cur_party_name
          and h.party_site_name=cur_party_site_name
          and d.transaction_type=cur_transaction_type
          and d.transaction_subtype=cur_transaction_subtype
          and d.standard_code=cur_standard_code
          and d.ext_type=cur_ext_trans_type
          and d.ext_subtype=cur_ext_trans_subtype
          and d.transaction_direction=cur_trans_direction;
  l_key_ecx     varchar2(1) ;
  cursor csr_name is
         select
                 SYNCHED
                ,PARTY_TYPE
                ,PARTY_NAME
                ,PARTY_SITE_NAME
                ,TRANSACTION_TYPE
                ,TRANSACTION_SUBTYPE
                ,STANDARD_CODE
                ,EXT_TRANS_TYPE
                ,EXT_TRANS_SUBTYPE
                ,TRANS_DIRECTION
                ,URL
                ,EXT_APPLICATION_ID
                ,APPLICATION_NAME
                ,APPLICATION_TYPE
                ,APPLICATION_URL
                ,LOGOUT_URL
                ,USER_FIELD
                ,PASSWORD_FIELD
                ,AUTHENTICATION_NEEDED
                ,FIELD_NAME1
                ,FIELD_VALUE1
                ,FIELD_NAME2
                ,FIELD_VALUE2
                ,FIELD_NAME3
                ,FIELD_VALUE3
                ,FIELD_NAME4
                ,FIELD_VALUE4
                ,FIELD_NAME5
                ,FIELD_VALUE5
                ,FIELD_NAME6
                ,FIELD_VALUE6
                ,FIELD_NAME7
                ,FIELD_VALUE7
                ,FIELD_NAME8
                ,FIELD_VALUE8
                ,FIELD_NAME9
                ,FIELD_VALUE9

           from hr_ki_integrations
          where  integration_id = p_integration_id
          and object_version_number = p_object_version_number;

   l_synched                       varchar2(1);
   l_party_type                    varchar2(240);
   l_party_name                    varchar2(360);
   l_party_site_name               varchar2(904);
   l_transaction_type              varchar2(100);
   l_transaction_sub_type          varchar2(100);
   l_standard_code                 varchar2(30);
   l_ext_trans_type                varchar2(100);
   l_ext_trans_sub_type            varchar2(100);
   l_trans_direction               varchar2(20);
   l_url                           varchar2(2000);
   l_ext_application_id            number(15,0);
   l_app_code                      varchar2(80);
   l_apptype                       varchar2(80);
   l_appurl                        varchar2(1000);
   l_logout_url                    varchar2(1000);
   l_userfld                       varchar2(80);
   l_pwdfld                        varchar2(80);
   l_authused                      varchar2(80);
   l_fname1                        varchar2(80);
   l_fval1                         varchar2(1000);
   l_fname2                        varchar2(80);
   l_fval2                         varchar2(1000);
   l_fname3                        varchar2(80);
   l_fval3                         varchar2(1000);
   l_fname4                        varchar2(80);
   l_fval4                         varchar2(1000);
   l_fname5                        varchar2(80);
   l_fval5                         varchar2(1000);
   l_fname6                        varchar2(80);
   l_fval6                         varchar2(1000);
   l_fname7                        varchar2(80);
   l_fval7                         varchar2(1000);
   l_fname8                        varchar2(80);
   l_fval8                         varchar2(1000);
   l_fname9                        varchar2(80);
   l_fval9                         varchar2(1000);

   lv_sqlcode NUMBER;
   lv_sqlerrm VARCHAR2(240);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint validate_integration;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;


  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_integrations_bk4.validate_integration_b
      (
      p_integration_id                 =>     p_integration_id
     ,p_object_version_number          =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'validate_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('Start:'|| l_proc, 20);
  OPEN csr_name;
  FETCH csr_name INTO l_synched,l_party_type,l_party_name,
        l_party_site_name,l_transaction_type,l_transaction_sub_type,
        l_standard_code,l_ext_trans_type,l_ext_trans_sub_type,
        l_trans_direction,l_url,l_ext_application_id,l_app_code,
        l_apptype,l_appurl,l_logout_url,l_userfld,l_pwdfld,l_authused,
        l_fname1,l_fval1,l_fname2,l_fval2,l_fname3,l_fval3,l_fname4,l_fval4,
        l_fname5,l_fval5,l_fname6,l_fval6,l_fname7,l_fval7,l_fname8,
        l_fval8,l_fname9,l_fval9;
  if (csr_name%notfound) then
    CLOSE csr_name;
     fnd_message.set_name('PER','PER_449991_INT_API_IOID_INVAL');
     fnd_message.raise_error;
  end if;
  CLOSE csr_name;

  hr_utility.set_location('Check for p_synched:'|| l_proc, 30);
  If l_synched='N' then
       --Check if it is SSO with ext-application-id null
       if (l_ext_application_id is null and l_app_code is not null
        and l_apptype is not null and l_appurl is not null
        and l_logout_url is not null and l_userfld is not null and
        l_pwdfld  is not null and l_authused is not null) then

        hr_utility.set_location('Registering in SSO:'|| l_proc, 40);

        --Call register to create entry in SSO
        begin

         hr_eap_ins.register(
             p_app_code       =>  l_app_code
            ,p_apptype        =>  l_apptype
            ,p_appurl         =>  l_appurl
            ,p_logout_url     =>  l_logout_url
            ,p_userfld        =>  l_userfld
            ,p_pwdfld         =>  l_pwdfld
            ,p_authused       =>  l_authused
            ,p_fname1         =>  l_fname1
            ,p_fval1          =>  l_fval1
            ,p_fname2         =>  l_fname2
            ,p_fval2          =>  l_fval2
            ,p_fname3         =>  l_fname3
            ,p_fval3          =>  l_fval3
            ,p_fname4         =>  l_fname4
            ,p_fval4          =>  l_fval4
            ,p_fname5         =>  l_fname5
            ,p_fval5          =>  l_fval5
            ,p_fname6         =>  l_fname6
            ,p_fval6          =>  l_fval6
            ,p_fname7         =>  l_fname7
            ,p_fval7          =>  l_fval7
            ,p_fname8         =>  l_fname8
            ,p_fval8          =>  l_fval8
            ,p_fname9         =>  l_fname9
            ,p_fval9          =>  l_fval9
            ,p_ki_app_id      =>  l_ext_application_id
         );
        exception
        when others then
          lv_sqlcode := SQLCODE;
          lv_sqlerrm := SQLERRM;
             IF (lv_sqlcode = -6550 and
             instr(lv_sqlerrm,'WWSSO_PSTORE_EX.PSTORE_ADD_APPLICATION') > 0) THEN
                 fnd_message.set_name('PER','PER_449993_INT_API_SSO_GRANT');
                 fnd_message.raise_error;
             else
                 fnd_message.set_name('PER','PER_449994_INT_API_SSO_EX');
                 fnd_message.raise_error;

            end if;
        end;
        --update integration table with synched set to Y
        --and newly generated ext_application_id

        hr_utility.set_location('Updating integration:'|| l_proc, 50);
          hr_int_upd.upd
             (
              p_synched                       =>     'Y'
             ,p_ext_application_id            =>     l_ext_application_id
             ,p_integration_id                =>     p_integration_id
             ,p_object_version_number         =>     p_object_version_number
             );

        --if ext_application_id is not null then synched should Y
        --update_integration will be updating first SSO and then
        --integration with SYNCHED set to Y

        elsif (
        l_app_code is null
        or l_apptype is null or l_appurl is null
        or l_logout_url is null or l_userfld is null or
        l_pwdfld  is null or l_authused is null

        ) then
         --Throw Error
         --

                 fnd_message.set_name('PER','PER_449989_INT_API_SSO_INVAL');
                 fnd_message.raise_error;

        --This is case when SSO application is already created
        --and SSO data is updated through loaders then synched will be N
        --Call update_integration_api to synch integration table and sso schema
        elsif(
        l_ext_application_id is not null
        and l_app_code is not null
        and l_apptype is not null and l_appurl is not null
        and l_logout_url is not null and l_userfld is not null and
        l_pwdfld is not null and l_authused is not null
        ) then

        HR_KI_INTEGRATIONS_API.update_integration
        (
         p_source_type                   => 'SSO'
        ,p_target_type                   => 'SSO'
        ,p_integration_id                =>  p_integration_id
        ,p_application_name              =>  l_app_code
        ,p_application_type              =>  l_apptype
        ,p_application_url               =>  l_appurl
        ,p_logout_url                    =>  l_logout_url
        ,p_user_field                    =>  l_userfld
        ,p_password_field                =>  l_pwdfld
        ,p_authentication_needed         =>  l_authused
        ,p_field_name1                   =>  l_fname1
        ,p_field_value1                  =>  l_fval1
        ,p_field_name2                   =>  l_fname2
        ,p_field_value2                  =>  l_fval2
        ,p_field_name3                   =>  l_fname3
        ,p_field_value3                  =>  l_fval3
        ,p_field_name4                   =>  l_fname4
        ,p_field_value4                  =>  l_fval4
        ,p_field_name5                   =>  l_fname5
        ,p_field_value5                  =>  l_fval5
        ,p_field_name6                   =>  l_fname6
        ,p_field_value6                  =>  l_fval6
        ,p_field_name7                   =>  l_fname7
        ,p_field_value7                  =>  l_fval7
        ,p_field_name8                   =>  l_fname8
        ,p_field_value8                  =>  l_fval8
        ,p_field_name9                   =>  l_fname9
        ,p_field_value9                  =>  l_fval9
        ,p_object_version_number         =>  p_object_version_number
        );
        --if it is ECX integration then validate against ECX schema

        elsif(l_party_type is not null and l_party_name is not null
        and l_party_site_name is not null and l_transaction_type is not null
        and l_transaction_sub_type is not null and l_standard_code is not null
        and l_ext_trans_type is not null and l_ext_trans_sub_type is not null
        and l_trans_direction is not null
        ) then

            hr_utility.set_location('Validate against ECX:'|| l_proc, 60);

             open csr_ecx(l_party_type,l_party_name,l_party_site_name,
             l_transaction_type,l_transaction_sub_type,l_standard_code,
             l_ext_trans_type,l_ext_trans_sub_type,l_trans_direction
             );
             fetch csr_ecx into l_key_ecx;
             if (csr_ecx%notfound)
             then
               close csr_ecx;
               fnd_message.set_name('PER','PER_449992_INT_API_ECXDT_ABS');
               fnd_message.raise_error;
             else
             --update integration table with synched set to Y

                close csr_ecx;

                hr_utility.set_location('ECX Update integrations:'|| l_proc, 70);

                hr_int_upd.upd
                (
                p_synched                       =>     'Y'
               ,p_integration_id                =>     p_integration_id
               ,p_object_version_number         =>     p_object_version_number
                );
             end if;


        end if;

  end if;
  hr_utility.set_location('Before after user hook:'|| l_proc, 80);

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_integrations_bk4.validate_integration_a
      (
      p_integration_id                =>     p_integration_id
     ,p_ext_application_id            =>     l_ext_application_id
     ,p_object_version_number         =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'validate_integration'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  -- p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to validate_integration;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 100);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to validate_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 110);
    raise;
end validate_integration;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_INTEGRATION >--------------------------|
-- ----------------------------------------------------------------------------

procedure UPDATE_INTEGRATION
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_integration_id                in     number
  ,p_source_type                   in     varchar2
  ,p_target_type                   in     varchar2
  ,p_party_type                    in     varchar2 default hr_api.g_varchar2
  ,p_party_name                    in     varchar2 default hr_api.g_varchar2
  ,p_party_site_name               in     varchar2 default hr_api.g_varchar2
  ,p_transaction_type              in     varchar2 default hr_api.g_varchar2
  ,p_transaction_subtype           in     varchar2 default hr_api.g_varchar2
  ,p_standard_code                 in     varchar2 default hr_api.g_varchar2
  ,p_ext_trans_type                in     varchar2 default hr_api.g_varchar2
  ,p_ext_trans_subtype             in     varchar2 default hr_api.g_varchar2
  ,p_trans_direction               in     varchar2 default hr_api.g_varchar2
  ,p_url                           in     varchar2 default hr_api.g_varchar2
  ,p_partner_name                  in     varchar2 default hr_api.g_varchar2
  ,p_service_name                  in     varchar2 default hr_api.g_varchar2
  ,p_application_name              in     varchar2 default hr_api.g_varchar2
  ,p_application_type              in     varchar2 default hr_api.g_varchar2
  ,p_application_url               in     varchar2 default hr_api.g_varchar2
  ,p_logout_url                    in     varchar2 default hr_api.g_varchar2
  ,p_user_field                    in     varchar2 default hr_api.g_varchar2
  ,p_password_field                in     varchar2 default hr_api.g_varchar2
  ,p_authentication_needed         in     varchar2 default hr_api.g_varchar2
  ,p_field_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_field_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_field_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'UPDATE_INTEGRATION';
  l_language_code       varchar2(30);
  l_object_version_number number := p_object_version_number;
  lv_sqlcode NUMBER;
  lv_sqlerrm VARCHAR2(240);


  cursor csr_extid is
     select inte.ext_application_id,ext.external_application_id
     from
     hr_ki_integrations inte,
     hr_ki_ext_applications ext
     where inte.integration_id=p_integration_id
     and  inte.ext_application_id=ext.ext_application_id;

  cursor csr_getsso_info is
     select  APPLICATION_NAME,APPLICATION_TYPE,APPLICATION_URL
     ,LOGOUT_URL,USER_FIELD,PASSWORD_FIELD,AUTHENTICATION_NEEDED,
     FIELD_NAME1,FIELD_VALUE1,FIELD_NAME2,FIELD_VALUE2,FIELD_NAME3,
     FIELD_VALUE3,FIELD_NAME4,FIELD_VALUE4,FIELD_NAME5,FIELD_VALUE5,
     FIELD_NAME6,FIELD_VALUE6,FIELD_NAME7,FIELD_VALUE7,FIELD_NAME8,
     FIELD_VALUE8,FIELD_NAME9 ,FIELD_VALUE9
     from
     hr_ki_integrations
     where integration_id=p_integration_id;


  l_extid varchar2(80);
  l_error number(15);
  l_ext_application_id number(15) := null;
  l_temp_ext_application_id number(15) := null;
  l_synched varchar2(1);

  l_app_code   varchar2(80)   := p_application_name;
  l_apptype    varchar2(80)   := p_application_type;
  l_appurl     varchar2(1000) := p_application_url;
  l_logout_url varchar2(1000) := p_logout_url;
  l_userfld    varchar2(80)   := p_user_field;
  l_pwdfld     varchar2(80)   := p_password_field;
  l_authused   varchar2(80)   := p_authentication_needed;
  l_fname1     varchar2(80)   := p_field_name1;
  l_fval1      varchar2(100)  := p_field_value1;
  l_fname2     varchar2(80)   := p_field_name2;
  l_fval2      varchar2(100)  := p_field_value2;
  l_fname3     varchar2(80)   := p_field_name3;
  l_fval3      varchar2(100)  := p_field_value3;
  l_fname4     varchar2(80)   := p_field_name4;
  l_fval4      varchar2(100)  := p_field_value4;
  l_fname5     varchar2(80)   := p_field_name5;
  l_fval5      varchar2(100)  := p_field_value5;
  l_fname6     varchar2(80)   := p_field_name6;
  l_fval6      varchar2(100)  := p_field_value6;
  l_fname7     varchar2(80)   := p_field_name7;
  l_fval7      varchar2(100)  := p_field_value7;
  l_fname8     varchar2(80)   := p_field_name8;
  l_fval8      varchar2(100)  := p_field_value8;
  l_fname9     varchar2(80)   := p_field_name9;
  l_fval9      varchar2(100)  := p_field_value9;

  l_url        varchar2(2000) := p_url;

  l_party_type           varchar2(240) := p_party_type;
  l_party_name           varchar2(360) := p_party_name;
  l_party_site_name      varchar2(904) := p_party_site_name;
  l_transaction_type     varchar2(100) := p_transaction_type;
  l_transaction_sub_type varchar2(100) := p_transaction_subtype;
  l_standard_code        varchar2(30)  := p_standard_code;
  l_ext_trans_type       varchar2(100) := p_ext_trans_type;
  l_ext_trans_sub_type   varchar2(100) := p_ext_trans_subtype;
  l_trans_direction      varchar2(20)  := p_trans_direction;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_INTEGRATION;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_integrations_bk2.UPDATE_INTEGRATION_b
      (
      p_language_code                 =>     l_language_code
     ,p_source_type                   =>     p_source_type
     ,p_target_type                   =>     p_target_type
     ,p_party_type                    =>     p_party_type
     ,p_party_name                    =>     p_party_name
     ,p_party_site_name               =>     p_party_site_name
     ,p_transaction_type              =>     p_transaction_type
     ,p_transaction_subtype           =>     p_transaction_subtype
     ,p_standard_code                 =>     p_standard_code
     ,p_ext_trans_type                =>     p_ext_trans_type
     ,p_ext_trans_subtype             =>     p_ext_trans_subtype
     ,p_trans_direction               =>     p_trans_direction
     ,p_url                           =>     p_url
     ,p_partner_name                  =>     p_partner_name
     ,p_service_name                  =>     p_service_name
     ,p_application_name              =>     p_application_name
     ,p_application_type              =>     p_application_type
     ,p_application_url               =>     p_application_url
     ,p_logout_url                    =>     p_logout_url
     ,p_user_field                    =>     p_user_field
     ,p_password_field                =>     p_password_field
     ,p_authentication_needed         =>     p_authentication_needed
     ,p_field_name1                   =>     p_field_name1
     ,p_field_value1                  =>     p_field_value1
     ,p_field_name2                   =>     p_field_name2
     ,p_field_value2                  =>     p_field_value2
     ,p_field_name3                   =>     p_field_name3
     ,p_field_value3                  =>     p_field_value3
     ,p_field_name4                   =>     p_field_name4
     ,p_field_value4                  =>     p_field_value4
     ,p_field_name5                   =>     p_field_name5
     ,p_field_value5                  =>     p_field_value5
     ,p_field_name6                   =>     p_field_name6
     ,p_field_value6                  =>     p_field_value6
     ,p_field_name7                   =>     p_field_name7
     ,p_field_value7                  =>     p_field_value7
     ,p_field_name8                   =>     p_field_name8
     ,p_field_value8                  =>     p_field_value8
     ,p_field_name9                   =>     p_field_name9
     ,p_field_value9                  =>     p_field_value9
     ,p_integration_id                =>     p_integration_id
     ,p_object_version_number         =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INTEGRATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  if ((p_source_type is null or p_source_type <> 'SSO' and
  p_source_type <> 'URL' and p_source_type <> 'ECX')
  or (p_target_type is null or p_target_type <> 'SSO'
  and p_target_type <> 'URL' and p_target_type <> 'ECX')
  ) then
      fnd_message.set_name('PER','PER_449988_INT_API_STTT_INVL');
      fnd_message.raise_error;
  end if;
  if (p_source_type = 'SSO') then
    --make sure that ext_application_id is valid
    --and it exists for the integration_id passed in
    --hr_ki_integrations and hr_ki_ext_applications table
    open csr_extid;
    fetch csr_extid into l_ext_application_id,l_extid;
    if (csr_extid%notfound) then
      close csr_extid;
      fnd_message.set_name('PER','PER_449990_INT_API_EXID_INVL');
      fnd_message.raise_error;
    end if;
    close csr_extid;
  end if;

  if (p_target_type = 'SSO') then

  --Target type will be SSO in 2 cases ,
  --(1)For SSO to SSO:check if user enters null
  --(2)and for (URL or ECX) to SSO he must enter mandatory SSO parameters

    if(p_source_type = 'SSO') then
                if (p_application_name    is null
                     or p_application_type    is null
                     or p_application_url     is null
                     or p_logout_url is null
                     or p_user_field    is null
                     or p_password_field     is null
                     or p_authentication_needed   is null )
                     then
                  fnd_message.set_name('PER','PER_0000_INT_API_SSO_INVAL');
                  fnd_message.raise_error;
            end if;

            --user is trying to update some of the SSO columns,he may not pass
            --the columns which he does not want to update,get these columns from
            --database otherwise we will  be passing g_varchar2 values to
            --hr_sso_utl.PSTORE_MODIFY_APP_INFO procedure


                 open csr_getsso_info;
                 fetch csr_getsso_info into l_app_code,l_apptype,l_appurl,
                 l_logout_url,l_userfld,l_pwdfld,l_authused,
                 l_fname1,l_fval1,l_fname2,l_fval2,l_fname3,l_fval3,l_fname4,
                 l_fval4,l_fname5,l_fval5,l_fname6,l_fval6,l_fname7,l_fval7,
                 l_fname8,l_fval8,l_fname9,l_fval9;
                 close csr_getsso_info;

                 if(p_application_name <> hr_api.g_varchar2) then l_app_code := p_application_name;end if;
                 if(p_application_type <> hr_api.g_varchar2) then l_apptype := p_application_type;end if;
                 if(p_application_url <> hr_api.g_varchar2) then l_appurl := p_application_url;end if;
                 if(p_logout_url <> hr_api.g_varchar2) then l_logout_url := p_logout_url;end if;
                 if(p_user_field <> hr_api.g_varchar2) then l_userfld := p_user_field;end if;
                 if(p_password_field <> hr_api.g_varchar2) then l_pwdfld := p_password_field;end if;
                 if(p_authentication_needed <> hr_api.g_varchar2) then l_authused := p_authentication_needed;end if;
                 if(p_field_name1 <> hr_api.g_varchar2) then l_fname1 := p_field_name1;end if;
                 if(p_field_value1 <> hr_api.g_varchar2) then l_fval1:=p_field_value1;end if;
                 if(p_field_name2 <> hr_api.g_varchar2) then l_fname2:=p_field_name2;end if;
                 if(p_field_value2 <> hr_api.g_varchar2) then l_fval2:=p_field_value2;end if;
                 if(p_field_name3 <> hr_api.g_varchar2) then l_fname3:=p_field_name3;end if;
                 if(p_field_value3 <> hr_api.g_varchar2) then l_fval3:=p_field_value3;end if;
                 if(p_field_name4 <> hr_api.g_varchar2) then l_fname4:=p_field_name4;end if;
                 if(p_field_value4 <> hr_api.g_varchar2) then l_fval4:=p_field_value4;end if;
                 if(p_field_name5 <> hr_api.g_varchar2) then l_fname5:=p_field_name5;end if;
                 if(p_field_value5 <> hr_api.g_varchar2) then l_fval5:=p_field_value5;end if;
                 if(p_field_name6 <> hr_api.g_varchar2) then l_fname6:=p_field_name6;end if;
                 if(p_field_value6 <> hr_api.g_varchar2) then l_fval6:=p_field_value6;end if;
                 if(p_field_name7 <> hr_api.g_varchar2) then l_fname7:=p_field_name7;end if;
                 if(p_field_value7 <> hr_api.g_varchar2) then l_fval7:=p_field_value7;end if;
                 if(p_field_name8 <> hr_api.g_varchar2) then l_fname8:=p_field_name8;end if;
                 if(p_field_value8 <> hr_api.g_varchar2) then l_fval8:=p_field_value8;end if;
                 if(p_field_name9 <> hr_api.g_varchar2) then l_fname9:=p_field_name9;end if;
                 if(p_field_value9 <> hr_api.g_varchar2) then l_fval9:=p_field_value9;end if;

    else
            if (p_application_name    is null or p_application_name =hr_api.g_varchar2
                 or p_application_type    is null or p_application_type =hr_api.g_varchar2
                 or p_application_url     is null or p_application_url =hr_api.g_varchar2
                 or p_logout_url is null or p_logout_url =hr_api.g_varchar2
                 or p_user_field    is null or p_user_field =hr_api.g_varchar2
                 or p_password_field     is null or p_password_field =hr_api.g_varchar2
                 or p_authentication_needed   is null or p_authentication_needed =hr_api.g_varchar2
                 ) then
              fnd_message.set_name('PER','PER_0000_INT_API_SSO_INVAL');
              fnd_message.raise_error;
            end if;
    end if;
  end if;
  if (p_source_type = p_target_type and p_source_type = 'SSO')then
    hr_eap_upd.update_sso_details(
                 p_ext_application_id =>  l_ext_application_id
                ,p_app_code           =>  l_app_code
                ,p_apptype            =>  l_apptype
                ,p_appurl             =>  l_appurl
                ,p_logout_url         =>  l_logout_url
                ,p_userfld            =>  l_userfld
                ,p_pwdfld             =>  l_pwdfld
                ,p_authused           =>  l_authused
                ,p_fname1             =>  l_fname1
                ,p_fval1              =>  l_fval1
                ,p_fname2             =>  l_fname2
                ,p_fval2              =>  l_fval2
                ,p_fname3             =>  l_fname3
                ,p_fval3              =>  l_fval3
                ,p_fname4             =>  l_fname4
                ,p_fval4              =>  l_fval4
                ,p_fname5             =>  l_fname5
                ,p_fval5              =>  l_fval5
                ,p_fname6             =>  l_fname6
                ,p_fval6              =>  l_fval6
                ,p_fname7             =>  l_fname7
                ,p_fval7              =>  l_fval7
                ,p_fname8             =>  l_fname8
                ,p_fval8              =>  l_fval8
                ,p_fname9             =>  l_fname9
                ,p_fval9              =>  l_fval9);

  elsif (p_source_type = 'SSO') then

    --SSO to URL or SSO to ECX type

    --delete the application from SSO and then
    -- from hr_ki_ext_applications

    hr_eap_del.delete_sso_details(p_sso_id => l_extid);


  elsif (p_target_type = 'SSO') then

  --set all the default SSO values to null
  --otherwise they will be updated by hr_api.g_varchar2
    if (l_fname1 =hr_api.g_varchar2) then l_fname1:=null; end if;
    if (l_fval1  =hr_api.g_varchar2) then l_fval1 :=null; end if;
    if (l_fname2 =hr_api.g_varchar2) then l_fname2:=null; end if;
    if (l_fval2  =hr_api.g_varchar2) then l_fval2 :=null; end if;
    if (l_fname3 =hr_api.g_varchar2) then l_fname3:=null; end if;
    if (l_fval3  =hr_api.g_varchar2) then l_fval3 :=null; end if;
    if (l_fname4 =hr_api.g_varchar2) then l_fname4:=null; end if;
    if (l_fval4  =hr_api.g_varchar2) then l_fval4 :=null; end if;
    if (l_fname5 =hr_api.g_varchar2) then l_fname5:=null; end if;
    if (l_fval5  =hr_api.g_varchar2) then l_fval5 :=null; end if;
    if (l_fname6 =hr_api.g_varchar2) then l_fname6:=null; end if;
    if (l_fval6  =hr_api.g_varchar2) then l_fval6 :=null; end if;
    if (l_fname7 =hr_api.g_varchar2) then l_fname7:=null; end if;
    if (l_fval7  =hr_api.g_varchar2) then l_fval7 :=null; end if;
    if (l_fname8 =hr_api.g_varchar2) then l_fname8:=null; end if;
    if (l_fval8  =hr_api.g_varchar2) then l_fval8 :=null; end if;
    if (l_fname9 =hr_api.g_varchar2) then l_fname9:=null; end if;
    if (l_fval9  =hr_api.g_varchar2) then l_fval9 :=null; end if;
    begin
    hr_eap_ins.register(
                  p_app_code       =>  p_application_name
                 ,p_apptype        =>  p_application_type
                 ,p_appurl         =>  p_application_url
                 ,p_logout_url     =>  p_logout_url
                 ,p_userfld        =>  p_user_field
                 ,p_pwdfld         =>  p_password_field
                 ,p_authused       =>  p_authentication_needed
                 ,p_fname1         =>  l_fname1
                 ,p_fval1          =>  l_fval1
                 ,p_fname2         =>  l_fname2
                 ,p_fval2          =>  l_fval2
                 ,p_fname3         =>  l_fname3
                 ,p_fval3          =>  l_fval3
                 ,p_fname4         =>  l_fname4
                 ,p_fval4          =>  l_fval4
                 ,p_fname5         =>  l_fname5
                 ,p_fval5          =>  l_fval5
                 ,p_fname6         =>  l_fname6
                 ,p_fval6          =>  l_fval6
                 ,p_fname7         =>  l_fname7
                 ,p_fval7          =>  l_fval7
                 ,p_fname8         =>  l_fname8
                 ,p_fval8          =>  l_fval8
                 ,p_fname9         =>  l_fname9
                 ,p_fval9          =>  l_fval9
                 ,p_ki_app_id      =>  l_temp_ext_application_id);

    l_ext_application_id := l_temp_ext_application_id;
        exception
        when others then
          lv_sqlcode := SQLCODE;
          lv_sqlerrm := SQLERRM;
             IF (lv_sqlcode = -6550 and
             instr(lv_sqlerrm,'WWSSO_PSTORE_EX.PSTORE_ADD_APPLICATION') > 0) THEN
                 fnd_message.set_name('PER','PER_0000_INT_API_SSO_GRANT');
                 fnd_message.raise_error;
             else
                 fnd_message.set_name('PER','PER_0000_INT_API_SSO_EX');
                 fnd_message.raise_error;

            end if;
        end;

  end if;

  --Set all the other type of integration parameters to null
  --For ECX (URL and SSO null)
  --For URL (ECX and SSO null)
  --For SSO (URL and ECX null)
  if (p_target_type <> 'URL') then
    l_url := null;
  end if;
  if(p_target_type <> 'ECX')then
    l_party_type           := null;
    l_party_name           := null;
    l_party_site_name      := null;
    l_transaction_type     := null;
    l_transaction_sub_type := null;
    l_standard_code        := null;
    l_ext_trans_type       := null;
    l_ext_trans_sub_type   := null;
    l_trans_direction      := null;
  end if;
  if(p_target_type <> 'SSO')then
    l_ext_application_id := null;
    l_app_code   := null;
    l_apptype    := null;
    l_appurl     := null;
    l_logout_url := null;
    l_userfld    := null;
    l_pwdfld     := null;
    l_authused   := null;
    l_fname1     := null;
    l_fval1      := null;
    l_fname2     := null;
    l_fval2      := null;
    l_fname3     := null;
    l_fval3      := null;
    l_fname4     := null;
    l_fval4      := null;
    l_fname5     := null;
    l_fval5      := null;
    l_fname6     := null;
    l_fval6      := null;
    l_fname7     := null;
    l_fval7      := null;
    l_fname8     := null;
    l_fval8      := null;
    l_fname9     := null;
    l_fval9      := null;
  end if;

--Set the l_synched parameter.

  if (p_target_type = 'ECX') then
    l_synched := 'N';
  else
    l_synched := 'Y';
  end if;
--
-- update the integration table
--

  hr_int_upd.upd
     (
      p_integration_id                =>     p_integration_id
     ,p_ext_application_id            =>     l_ext_application_id
     ,p_synched                       =>     l_synched
     ,p_party_type                    =>     l_party_type
     ,p_party_name                    =>     l_party_name
     ,p_party_site_name               =>     l_party_site_name
     ,p_transaction_type              =>     l_transaction_type
     ,p_transaction_subtype           =>     l_transaction_sub_type
     ,p_standard_code                 =>     l_standard_code
     ,p_ext_trans_type                =>     l_ext_trans_type
     ,p_ext_trans_subtype             =>     l_ext_trans_sub_type
     ,p_trans_direction               =>     l_trans_direction

     ,p_url                           =>     l_url

     ,p_application_name              =>     l_app_code
     ,p_application_type              =>     l_apptype
     ,p_application_url               =>     l_appurl
     ,p_logout_url                    =>     l_logout_url
     ,p_user_field                    =>     l_userfld
     ,p_password_field                =>     l_pwdfld
     ,p_authentication_needed         =>     l_authused

     ,p_field_name1                   =>     l_fname1
     ,p_field_value1                  =>     l_fval1
     ,p_field_name2                   =>     l_fname2
     ,p_field_value2                  =>     l_fval2
     ,p_field_name3                   =>     l_fname3
     ,p_field_value3                  =>     l_fval3
     ,p_field_name4                   =>     l_fname4
     ,p_field_value4                  =>     l_fval4
     ,p_field_name5                   =>     l_fname5
     ,p_field_value5                  =>     l_fval5
     ,p_field_name6                   =>     l_fname6
     ,p_field_value6                  =>     l_fval6
     ,p_field_name7                   =>     l_fname7
     ,p_field_value7                  =>     l_fval7
     ,p_field_name8                   =>     l_fname8
     ,p_field_value8                  =>     l_fval8
     ,p_field_name9                   =>     l_fname9
     ,p_field_value9                  =>     l_fval9

     ,p_object_version_number         =>     p_object_version_number
      );
--
-- update the integration_tl table
--
  hr_itl_upd.upd_tl(
       p_language_code           =>  l_language_code
      ,p_integration_id          =>  p_integration_id
      ,p_partner_name            =>  p_partner_name
      ,p_service_name            =>  p_service_name
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_integrations_bk2.update_integration_a
      (
      p_language_code                 =>     l_language_code
     ,p_source_type                   =>     p_source_type
     ,p_target_type                   =>     p_target_type
     ,p_party_type                    =>     p_party_type
     ,p_party_name                    =>     p_party_name
     ,p_party_site_name               =>     p_party_site_name
     ,p_transaction_type              =>     p_transaction_type
     ,p_transaction_subtype           =>     p_transaction_subtype
     ,p_standard_code                 =>     p_standard_code
     ,p_ext_trans_type                =>     p_ext_trans_type
     ,p_ext_trans_subtype             =>     p_ext_trans_subtype
     ,p_trans_direction               =>     p_trans_direction
     ,p_url                           =>     p_url
     ,p_partner_name                  =>     p_partner_name
     ,p_service_name                  =>     p_service_name
     ,p_application_name              =>     p_application_name
     ,p_application_type              =>     p_application_type
     ,p_application_url               =>     p_application_url
     ,p_logout_url                    =>     p_logout_url
     ,p_user_field                    =>     p_user_field
     ,p_password_field                =>     p_password_field
     ,p_authentication_needed         =>     p_authentication_needed
     ,p_field_name1                   =>     p_field_name1
     ,p_field_value1                  =>     p_field_value1
     ,p_field_name2                   =>     p_field_name2
     ,p_field_value2                  =>     p_field_value2
     ,p_field_name3                   =>     p_field_name3
     ,p_field_value3                  =>     p_field_value3
     ,p_field_name4                   =>     p_field_name4
     ,p_field_value4                  =>     p_field_value4
     ,p_field_name5                   =>     p_field_name5
     ,p_field_value5                  =>     p_field_value5
     ,p_field_name6                   =>     p_field_name6
     ,p_field_value6                  =>     p_field_value6
     ,p_field_name7                   =>     p_field_name7
     ,p_field_value7                  =>     p_field_value7
     ,p_field_name8                   =>     p_field_name8
     ,p_field_value8                  =>     p_field_value8
     ,p_field_name9                   =>     p_field_name9
     ,p_field_value9                  =>     p_field_value9
     ,p_integration_id                =>     p_integration_id
     ,p_ext_application_id            =>     l_ext_application_id
     ,p_object_version_number         =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INTEGRATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --

  --  p_object_version_number  := p_object_version_number;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_INTEGRATION;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_INTEGRATION;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_INTEGRATION;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_INTEGRATION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_integration
  (
   P_VALIDATE                 in boolean         default false
  ,P_SSO_ENABLED              in boolean         default false
  ,P_INTEGRATION_ID           in number
  ,P_OBJECT_VERSION_NUMBER    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_integration';
  cursor csr_extid is
     select ext.external_application_id,ext.ext_application_id from
      hr_ki_integrations inte,
      hr_ki_ext_applications ext
      where inte.integration_id=p_integration_id
      and  inte.ext_application_id=ext.ext_application_id;

  l_extid varchar2(80);
  l_error number(15);
  l_eap_id number(15);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_integration;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_integrations_bk3.delete_integration_b
      (
       p_sso_enabled            => p_sso_enabled
      ,p_integration_id         => p_integration_id
      ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  if (p_sso_enabled) then
     --delete the sso application first
      open csr_extid;
      fetch csr_extid into l_extid,l_eap_id;
      if (csr_extid%notfound) then
         close csr_extid;
         fnd_message.set_name('PER','PER_0000_INT_API_EXID_INVL');
         fnd_message.raise_error;
      end if;
      close csr_extid;

    --delete the application from SSO and then
    -- from hr_ki_ext_applications

    hr_eap_del.delete_sso_details(p_sso_id => l_extid);

  end if;


 --delete record from TL table
 hr_int_shd.lck
      (
      p_integration_id          => p_integration_id
     ,p_object_version_number   => p_object_version_number
     );

 hr_itl_del.del_tl(
      p_integration_id          => p_integration_id
      );


 hr_int_del.del
     (
      p_integration_id          => p_integration_id
     ,p_object_version_number   => p_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_integrations_bk3.delete_integration_a
      (
       p_sso_enabled            => p_sso_enabled
      ,p_integration_id         => p_integration_id
      ,p_object_version_number  => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_integration'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_integration;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_integration;
end HR_KI_INTEGRATIONS_API;

/
