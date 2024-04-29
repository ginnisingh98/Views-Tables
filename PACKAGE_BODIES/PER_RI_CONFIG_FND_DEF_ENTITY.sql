--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_FND_DEF_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_FND_DEF_ENTITY" AS
/* $Header: perricfd.pkb 120.5.12010000.2 2009/01/29 10:14:06 sbrahmad ship $ */

  g_config_effective_date     DATE :=  TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_config_effective_end_date DATE :=  TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
  g_package                   varchar2(30)  := 'per_ri_config_fnd_def_entity.';


  /* --------------------------------------------------------------------------
  -- Name      : create_user
  -- Purpose   : This procedure creates super user for the enteprise structures
  --             configuration which would have all the responsibilities
  --             and profiles options assigned to it.
  -- Arguments : None
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_user (p_technical_summary_mode      in boolean default FALSE
                        ,p_user_tab in out nocopy
                                           per_ri_config_tech_summary.user_tab) IS

  cursor csr_find_user (cp_user_name in varchar2) IS
  select user_id
  from   fnd_user
  where  user_name = cp_user_name;

  l_users_count                   number(10) := 0;
  l_proc                          varchar2(72) := g_package ||'create_user';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_user_id                       fnd_user.user_id%type;
  l_user_name                     fnd_user.user_name%type;
  l_apps_sso                      varchar2(20);
  l_profile_defined               boolean;
  l_password                      varchar2(20) := 'welcome';

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_user_name := upper(per_ri_config_utilities.return_config_entity_name_pre
                       (per_ri_config_main.g_configuration_user_name));

    hr_utility.trace('l_user_name = ' || l_user_name);
    open csr_find_user(l_user_name);
    fetch csr_find_user into l_user_id;

    if NOT (p_technical_summary_mode) then
       if csr_find_user%NOTFOUND then
          fnd_profile.get_specific(
                       name_z      => 'APPS_SSO',
                       val_z      => l_apps_sso,
                       defined_z    => l_profile_defined);

          if (l_apps_sso <> 'PORTAL') AND (l_apps_sso <> 'SSWA') then
              l_password := 'welcome1';
          end if;
          fnd_user_pkg.createuser(
                          x_user_name            => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                      (per_ri_config_main.g_configuration_user_name)),

                          x_start_date           => per_ri_config_fnd_def_entity.g_config_effective_date,
                          x_owner                => 'CUST',
                          x_unencrypted_password => l_password );

         l_log_message := 'Created User ' ||  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                (per_ri_config_main.g_configuration_user_name));
            per_ri_config_utilities.write_log(p_message => l_log_message);
         hr_utility.set_location(l_proc, 20);
       else
         l_log_message := 'User Already Existing ';
         per_ri_config_utilities.write_log(p_message => l_log_message);
            hr_utility.set_location(l_proc, 30);
       end if;
    else
      p_user_tab(l_users_count).user_name         := upper(per_ri_config_utilities.return_config_entity_name_pre
                                                      (per_ri_config_main.g_configuration_user_name));
      p_user_tab(l_users_count).start_date        :=  per_ri_config_fnd_def_entity.g_config_effective_date;
      p_user_tab(l_users_count).description       := null;

      l_users_count := l_users_count + 1;
    end if;
    close csr_find_user;

    hr_utility.set_location(' Leaving:'|| l_proc, 40);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_user;

  /* --------------------------------------------------------------------------
  -- Name      : create_site_profile_options
  -- Purpose   : This procedure creates following site level profile options.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */


  PROCEDURE  create_site_profile_options(p_configuration_code   in varchar2
                                        ,p_technical_summary_mode      in boolean default FALSE
                                        ,p_profile_tab in out nocopy
                                                 per_ri_config_tech_summary.profile_tab) IS

  l_profile_count                number(10) := 0;
  l_proc                          varchar2(72) := g_package ||'create_site_profile_options';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    --HR_CROSS_BUSINESS_GROUP
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                           (p_level                => 10001
                           ,p_level_value          => 0
                           ,p_level_value_app      => 'PER'
			   ,p_profile_name         => 'HR_CROSS_BUSINESS_GROUP'
                           ,p_profile_option_value => 'Y');
    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'PER';
      p_profile_tab(l_profile_count).profile_name          := 'HR_CROSS_BUSINESS_GROUP';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;

    l_log_message := 'Created PROFILE_OPTION ' || 'HR_CROSS_BUSINESS_GROUP';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 20);

    /* DGARG - MSG Changes
    if (per_ri_config_utilities.check_selected_product
                               (p_configuration_code    => p_configuration_code
                               ,p_product_name          => 'PER')) then
      --ENABLE_SECURITY_GROUPS
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                           (p_level                => 10002
                           ,p_level_value          => 'PER'
                           ,p_level_value_app      => 'PER'
			   ,p_profile_name         => 'ENABLE_SECURITY_GROUPS'
                           ,p_profile_option_value => 'Y');

    else
      p_profile_tab(l_profile_count).level                 := 1002;
      p_profile_tab(l_profile_count).level_value           := 'PER';
      p_profile_tab(l_profile_count).level_value_app       := 'PER';
      p_profile_tab(l_profile_count).profile_name          := 'ENABLE_SECURITY_GROUPS';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;
      l_log_message := 'Created PROFILE_OPTION PER ' || 'ENABLE_SECURITY_GROUPS';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 30);
   end if;

   if (per_ri_config_utilities.check_selected_product
                               (p_configuration_code    => p_configuration_code
                               ,p_product_name          => 'PAY')) then
     --ENABLE_SECURITY_GROUPS
    if NOT (p_technical_summary_mode) then
     per_ri_config_utilities.set_profile_option_value
                          (p_level                => 10002
                          ,p_level_value          => 'PAY'
                          ,p_level_value_app      => 'PAY'
                          ,p_profile_name         => 'ENABLE_SECURITY_GROUPS'
                          ,p_profile_option_value => 'Y');

    else
      p_profile_tab(l_profile_count).level                 := 1002;
      p_profile_tab(l_profile_count).level_value           := 'PAY';
      p_profile_tab(l_profile_count).level_value_app       := 'PAY';
      p_profile_tab(l_profile_count).profile_name          := 'ENABLE_SECURITY_GROUPS';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;
     l_log_message := 'Created PROFILE_OPTION PAY ' || 'ENABLE_SECURITY_GROUPS';
     per_ri_config_utilities.write_log(p_message => l_log_message);
     hr_utility.set_location(l_proc, 30);
   end if;

    if (per_ri_config_utilities.check_selected_product
                               (p_configuration_code    => p_configuration_code
                               ,p_product_name          => 'BEN')) then
      --ENABLE_SECURITY_GROUPS
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                           (p_level                => 10002
                           ,p_level_value          => 'BEN'
                           ,p_level_value_app      => 'BEN'
                           ,p_profile_name         => 'ENABLE_SECURITY_GROUPS'
                           ,p_profile_option_value => 'Y');

    else
      p_profile_tab(l_profile_count).level                 := 1002;
      p_profile_tab(l_profile_count).level_value           := 'BEN';
      p_profile_tab(l_profile_count).level_value_app       := 'BEN';
      p_profile_tab(l_profile_count).profile_name          := 'ENABLE_SECURITY_GROUPS';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;
      l_log_message := 'Created PROFILE_OPTION BEN ' || 'ENABLE_SECURITY_GROUPS';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 30);
    end if;
    ** */
    --HR_SYNC_SINGLE_GL_ORG
    if NOT (p_technical_summary_mode) then
    per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'PER'
			 ,p_profile_name         => 'HR_SYNC_SINGLE_GL_ORG'
                         ,p_profile_option_value => 'Y');

    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'PER';
      p_profile_tab(l_profile_count).profile_name          := 'HR_SYNC_SINGLE_GL_ORG';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;
    l_log_message := 'Created PROFILE_OPTION ' || 'HR_SYNC_SINGLE_GL_ORG';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 40);

    --HR_GENERATE_GL_ORGS
    if NOT (p_technical_summary_mode) then
    per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'PER'
			 ,p_profile_name         => 'HR_GENERATE_GL_ORGS'
                         ,p_profile_option_value => 'CCHR');
    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'PER';
      p_profile_tab(l_profile_count).profile_name          := 'HR_GENERATE_GL_ORGS';
      p_profile_tab(l_profile_count).profile_option_value  := 'CCHR';

      l_profile_count  := l_profile_count + 1;

    end if;

    l_log_message := 'Created PROFILE_OPTION ' || 'HR_GENERATE_GL_ORGS';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 50);

    --BIS_PRIMARY_RATE_TYPE
    if NOT (p_technical_summary_mode) then
    per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'BIS'
			 ,p_profile_name         => 'BIS_PRIMARY_RATE_TYPE'
                         ,p_profile_option_value => 'Corporate');
    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'BIS';
      p_profile_tab(l_profile_count).profile_name          := 'BIS_PRIMARY_RATE_TYPE';
      p_profile_tab(l_profile_count).profile_option_value  := 'Corporate';

      l_profile_count  := l_profile_count + 1;

    end if;

    l_log_message := 'Created PROFILE_OPTION ' || 'BIS_PRIMARY_RATE_TYPE';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 60);

    --BIS_WORKFORCE_MEASUREMENT_TYPE
    if NOT (p_technical_summary_mode) then
    per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'BIS'
			 ,p_profile_name         => 'BIS_WORKFORCE_MEASUREMENT_TYPE'
                         ,p_profile_option_value => 'HEAD');
    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'BIS';
      p_profile_tab(l_profile_count).profile_name          := 'BIS_WORKFORCE_MEASUREMENT_TYPE';
      p_profile_tab(l_profile_count).profile_option_value  := 'HEAD';

      l_profile_count  := l_profile_count + 1;

    end if;

    l_log_message := 'Created PROFILE_OPTION ' || 'BIS_WORKFORCE_MEASUREMENT_TYPE';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 70);

    if (per_ri_config_utilities.check_selected_product
                               (p_configuration_code    => p_configuration_code
                               ,p_product_name          => 'SSHR')) then
      --HR_SELF_SERVICE_HR_LICENSED
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                           (p_level                => 10001
                           ,p_level_value          => 0
                           ,p_level_value_app      => 'PER'
                           ,p_profile_name         => 'HR_SELF_SERVICE_HR_LICENSED'
                           ,p_profile_option_value => 'Y');
    else
      p_profile_tab(l_profile_count).level                 := 1001;
      p_profile_tab(l_profile_count).level_value           := 0;
      p_profile_tab(l_profile_count).level_value_app       := 'PER';
      p_profile_tab(l_profile_count).profile_name          := 'HR_SELF_SERVICE_HR_LICENSED';
      p_profile_tab(l_profile_count).profile_option_value  := 'Y';

      l_profile_count  := l_profile_count + 1;

    end if;

      l_log_message := 'Created PROFILE_OPTION ' || 'HR_SELF_SERVICE_HR_LICENSED';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 80);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 90);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_site_profile_options;

  /* --------------------------------------------------------------------------
  -- Name      : attach_default_responsibility
  -- Purpose   : This procedure attaches default responsibilities to the  super
  --             user for the enteprise structures configuration.
  --             and profiles options assigned to it.
  -- Arguments : None
  --
  -------------------------------------------------------------------------- */
  PROCEDURE attach_default_responsibility
                         (p_configuration_code          in varchar2
                         ,p_technical_summary_mode      in boolean default FALSE
                         ,p_resp_tab in out nocopy
                                  per_ri_config_tech_summary.resp_tab) IS

  l_resp_count                   number(10) := 0;
  l_proc                         varchar2(72) := g_package ||'attach_default_responsibility';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);
  l_user_id                      fnd_user.user_id%type;
  l_start_date                   varchar2(240) := to_char(per_ri_config_fnd_def_entity.g_config_effective_date,'YYYY/MM/DD');
  l_end_date                     varchar2(240)
                                           := to_char(per_ri_config_fnd_def_entity.g_config_effective_end_date,'YYYY/MM/DD');
  cursor csr_get_product (cp_configuration_code in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code;

  l_hr                           boolean default FALSE;
  l_hrms                         boolean default FALSE;
  l_benefits                     boolean default FALSE;
  l_self_service                 boolean default FALSE;

  l_product_name                 per_ri_config_information.config_information1%type;
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if NOT (p_technical_summary_mode) then
      -- Attach System Administrator
      fnd_User_resp_groups_api.load_row(
                                x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                       (per_ri_config_main.g_configuration_user_name)),
                                x_resp_key        => 'SYSTEM_ADMINISTRATOR',
                                x_app_short_name  => 'SYSADMIN',
                                x_security_group  => 'STANDARD',
                                x_owner           => 'SEED',
                                x_start_date      => l_start_date,
                                x_end_date        => l_end_date,
                                x_description     => per_ri_config_main.g_description_string);
    else
        p_resp_tab(l_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                       (per_ri_config_main.g_configuration_user_name));
        p_resp_tab(l_resp_count).resp_key       := per_ri_config_utilities.get_responsibility_name('SYSTEM_ADMINISTRATOR');
        p_resp_tab(l_resp_count).app_short_name := 'SYSADMIN';
        p_resp_tab(l_resp_count).security_group := 'STANDARD';
        p_resp_tab(l_resp_count).owner          := 'SEED';
        p_resp_tab(l_resp_count).start_date     := l_start_date;
        p_resp_tab(l_resp_count).end_date       := l_end_date;
        p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

        l_resp_count := l_resp_count + 1 ;
    end if;

    hr_utility.set_location(l_proc, 20);
    l_log_message := 'Created RESPONSIBILITY ' || 'SYSTEM_ADMINISTRATOR';
    per_ri_config_utilities.write_log(p_message => l_log_message);

    -- Attach APPLICATION IMPLEMENTATION for iSetup
    if NOT (p_technical_summary_mode) then
    fnd_User_resp_groups_api.load_row(
                              x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name)),
                              x_resp_key        => 'APPLICATION IMPLEMENTATION',
                              x_app_short_name  => 'AZ',
                              x_security_group  => 'STANDARD',
                              x_owner           => 'SEED',
                              x_start_date      => l_start_date,
                              x_end_date        => l_end_date,
                              x_description     => per_ri_config_main.g_description_string);
    else
        p_resp_tab(l_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name));
        p_resp_tab(l_resp_count).resp_key       :=  per_ri_config_utilities.get_responsibility_name('APPLICATION IMPLEMENTATION');
        p_resp_tab(l_resp_count).app_short_name := 'AZ';
        p_resp_tab(l_resp_count).security_group := 'STANDARD';
        p_resp_tab(l_resp_count).owner          := 'SEED';
        p_resp_tab(l_resp_count).start_date     := l_start_date;
        p_resp_tab(l_resp_count).end_date       := l_end_date;
        p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

        l_resp_count := l_resp_count + 1 ;

    end if;
    hr_utility.set_location(l_proc, 40);
    l_log_message := 'Created RESPONSIBILITY ' || 'APPLICATION IMPLEMENTATION';
    per_ri_config_utilities.write_log(p_message => l_log_message);

    -- Attach FNDWF_USER_WEB_NEW for Payroll Process Workflow process
    -- Bugfix 4219794
    if NOT (p_technical_summary_mode) then
    fnd_User_resp_groups_api.load_row(
                              x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name)),
                              x_resp_key        => 'FNDWF_USER_WEB_NEW',
                              x_app_short_name  => 'FND',
                              x_security_group  => 'STANDARD',
                              x_owner           => 'SEED',
                              x_start_date      => l_start_date,
                              x_end_date        => l_end_date,
                              x_description     => per_ri_config_main.g_description_string);
    else
        p_resp_tab(l_resp_count).user_name      :=   upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name));
        p_resp_tab(l_resp_count).resp_key       :=  per_ri_config_utilities.get_responsibility_name('FNDWF_USER_WEB_NEW');
        p_resp_tab(l_resp_count).app_short_name := 'FND';
        p_resp_tab(l_resp_count).security_group := 'STANDARD';
        p_resp_tab(l_resp_count).owner          := 'SEED';
        p_resp_tab(l_resp_count).start_date     := l_start_date;
        p_resp_tab(l_resp_count).end_date       := l_end_date;
        p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

        l_resp_count := l_resp_count + 1 ;

    end if;
    hr_utility.set_location(l_proc, 40);
    l_log_message := 'Created RESPONSIBILITY ' || 'FNDWF_USER_WEB_NEW';
    per_ri_config_utilities.write_log(p_message => l_log_message);

    -- Attach AZ_ISETUP
    if NOT (p_technical_summary_mode) then
    fnd_User_resp_groups_api.load_row(
                              x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name)),
                              x_resp_key        => 'AZ_ISETUP',
                              x_app_short_name  => 'AZ',
                              x_security_group  => 'STANDARD',
                              x_owner           => 'SEED',
                              x_start_date      => l_start_date,
                              x_end_date        => l_end_date,
                              x_description     => per_ri_config_main.g_description_string);
    else
        p_resp_tab(l_resp_count).user_name      :=   upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name));
        p_resp_tab(l_resp_count).resp_key       :=  per_ri_config_utilities.get_responsibility_name('AZ_ISETUP');
        p_resp_tab(l_resp_count).app_short_name := 'AZ';
        p_resp_tab(l_resp_count).security_group := 'STANDARD';
        p_resp_tab(l_resp_count).owner          := 'SEED';
        p_resp_tab(l_resp_count).start_date     := l_start_date;
        p_resp_tab(l_resp_count).end_date       := l_end_date;
        p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

        l_resp_count := l_resp_count + 1 ;

    end if;
    hr_utility.set_location(l_proc, 40);
    l_log_message := 'Created RESPONSIBILITY ' || 'AZ_ISETUP';
    per_ri_config_utilities.write_log(p_message => l_log_message);

    -- Attach  HRMS_RI_WORKBENCH
    if NOT (p_technical_summary_mode) then
    fnd_User_resp_groups_api.load_row(
                              x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                                     (per_ri_config_main.g_configuration_user_name)),
                              x_resp_key        => 'HRMS_RI_WORKBENCH',
                              x_app_short_name  => 'PER',
                              x_security_group  => 'STANDARD',
                              x_owner           => 'SEED',
                              x_start_date      => l_start_date,
                              x_end_date        => l_end_date,
                              x_description     => per_ri_config_main.g_description_string);
    else
        p_resp_tab(l_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                       (per_ri_config_main.g_configuration_user_name));
        p_resp_tab(l_resp_count).resp_key       :=  per_ri_config_utilities.get_responsibility_name('HRMS_RI_WORKBENCH');
        p_resp_tab(l_resp_count).app_short_name := 'PER';
        p_resp_tab(l_resp_count).security_group := 'STANDARD';
        p_resp_tab(l_resp_count).owner          := 'SEED';
        p_resp_tab(l_resp_count).start_date     := l_start_date;
        p_resp_tab(l_resp_count).end_date       := l_end_date;
        p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

        l_resp_count := l_resp_count + 1 ;

    end if;
    hr_utility.set_location(l_proc, 50);
    l_log_message := 'Created RESPONSIBILITY ' || 'HRMS_RI_WORKBENCH';
    per_ri_config_utilities.write_log(p_message => l_log_message);

    hr_utility.set_location(' Leaving:'|| l_proc, 50);

    -- create data for technical summary for self-service responsibilities
    open csr_get_product(p_configuration_code);

    loop
      fetch csr_get_product into l_product_name;
      exit when csr_get_product%NOTFOUND;
      hr_utility.trace('l_product_name = ' || l_product_name);

      if l_product_name = 'PER' then
        l_hr := TRUE;
      end if;
      if l_product_name = 'PAY' then
        l_hrms := TRUE;
      end if;
      if l_product_name = 'BEN' then
        l_benefits := TRUE;
      end if;
      if l_product_name = 'SSHR' then
        l_self_service := TRUE;
      end if;
    end loop;

    close csr_get_product;

    --
    -- assign hrms self service responsibilities
    --

    if l_self_service and p_technical_summary_mode then

      -- EMPLOYEE_DIRECT_ACCESS_V4
      p_resp_tab(l_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                       (per_ri_config_main.g_configuration_user_name));
      p_resp_tab(l_resp_count).resp_key  := per_ri_config_utilities.get_responsibility_name('EMPLOYEE_DIRECT_ACCESS_V4.0');
      p_resp_tab(l_resp_count).app_short_name := 'PER';
      p_resp_tab(l_resp_count).security_group := 'STANDARD';
      p_resp_tab(l_resp_count).owner          := 'SEED';
      p_resp_tab(l_resp_count).start_date     := l_start_date;
      p_resp_tab(l_resp_count).end_date       := l_end_date;
      p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

       l_resp_count := l_resp_count + 1 ;

     -- LINE_MANAGER_ACCESS_V4
     p_resp_tab(l_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                       (per_ri_config_main.g_configuration_user_name));
     p_resp_tab(l_resp_count).resp_key  := per_ri_config_utilities.get_responsibility_name('LINE_MANAGER_ACCESS_V4.0');
     p_resp_tab(l_resp_count).app_short_name := 'PER';
     p_resp_tab(l_resp_count).security_group := 'STANDARD';
     p_resp_tab(l_resp_count).owner          := 'SEED';
     p_resp_tab(l_resp_count).start_date     := l_start_date;
     p_resp_tab(l_resp_count).end_date       := l_end_date;
     p_resp_tab(l_resp_count).description    := per_ri_config_main.g_description_string;

       l_resp_count := l_resp_count + 1 ;
    end if;

    hr_utility.set_location(l_proc, 30);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END attach_default_responsibility;

END per_ri_config_fnd_def_entity;

/
