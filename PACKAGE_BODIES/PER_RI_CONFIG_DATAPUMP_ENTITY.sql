--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_DATAPUMP_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_DATAPUMP_ENTITY" AS
/* $Header: perridpe.pkb 120.8.12010000.4 2008/12/16 10:29:43 psengupt ship $ */

  g_config_effective_date        date         := TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_config_effective_end_date    date         := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
  g_package                      varchar2(30) := 'per_ri_config_datapump_entity.';


  /* --------------------------------------------------------------------------
  -- Name      : create_enterprise_batch_lines
  -- Purpose   : This procedure creates enterprise batch lines records in the
  --             data pump tables which would be loaded by the enterprise
  --             structures configuration loader program for a specified
  --             configuration.
  -- Arguments : p_configuration_code
  --             p_batch_header_id
  -------------------------------------------------------------------------- */

  PROCEDURE create_enterprise_batch_lines(p_configuration_code          in varchar2
                                         ,p_batch_header_id             in number
                                         ,p_multiple_config_upload      in boolean default FALSE
                                         ,p_technical_summary_mode      in boolean default FALSE
                                         ,p_org_ent_tab in out nocopy
                                             per_ri_config_tech_summary.org_ent_tab
                                         ,p_org_ent_class_tab in out nocopy
                                             per_ri_config_tech_summary.org_ent_class_tab
                                         ,p_org_hierarchy_tab in out nocopy
                                             per_ri_config_tech_summary.org_hierarchy_tab
                                         ,p_profile_dpe_ent_tab in out nocopy
                                             per_ri_config_tech_summary.profile_dpe_ent_tab) IS

  cursor csr_config_enterprise (cp_configuration_code in varchar2) IS
    select configuration_code,
           config_information_id,
           config_sequence,
           config_information_category,
           per_ri_config_utilities.return_config_entity_name(enterprise_name),
           enterprise_name, -- for other processing
           enterprise_short_name,
           enterprise_headquarter_country,
           enterprise_primary_industry,
           enterprise_location_id
      from per_ri_config_enterprise_v
     where configuration_code = cp_configuration_code;

  l_configuration_code            per_ri_config_information.configuration_code%type;
  l_config_information_id         per_ri_config_information.config_information_id%type;
  l_config_sequence               per_ri_config_information.config_sequence%type;
  l_config_information_category   per_ri_config_information.config_information_category%type;
  l_enterprise_name               per_ri_config_information.config_information1%type;
  l_enterprise_name_original      per_ri_config_information.config_information1%type;
  l_enterprise_short_name         per_ri_config_information.config_information1%type;
  l_enterprise_hq_country         per_ri_config_information.config_information1%type;
  l_hr_enterprise_primary_indust  per_ri_config_information.config_information1%type;
  l_enterprise_location_id        per_ri_config_information.config_information1%type;

  l_business_group_country_code   per_business_groups.name%type;
  l_business_group_name           per_business_groups.name%type;
  l_ent_location_code             per_ri_config_locations.description%type; -- fix for 4457389


  l_hr_legal_mand_org_info_types  boolean;
  l_ent_count                     number(10) := 0;
  l_profile_dpe_ent_count         number(10) := 0;
  l_ent_class_count               number(10) := 0;
  l_org_hierarchy_count           number(10) := 0;
  l_proc                          varchar2(72) := g_package ||'create_enterprise_batch_lines';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_multi_tenancy                 boolean := false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  l_country_selected              varchar2(50);
  l_selected_country_code         varchar2(10);
  l_selected_country_name         varchar2(50);
  l_enterprise_id                 number(9);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;
    BEGIN
    select enterprise_id into l_enterprise_id from per_ent_security_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_enterprise_id := null;
    END;

    select legislation_code into l_selected_country_code from
     per_business_groups where business_group_id =
        fnd_profile.value('PER_BUSINESS_GROUP_ID');

   select name into l_selected_country_name from per_business_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
    open csr_config_enterprise(p_configuration_code);

    fetch csr_config_enterprise into
                l_configuration_code,
                l_config_information_id,
                l_config_sequence,
                l_config_information_category,
                l_enterprise_name,
                l_enterprise_name_original,
                l_enterprise_short_name,
                l_enterprise_hq_country,
                l_hr_enterprise_primary_indust,
                l_enterprise_location_id;

    if csr_config_enterprise%FOUND then
      hr_utility.set_location(l_proc, 20);

      -- decide on business group for enterprise
      l_business_group_country_code  := per_ri_config_utilities.get_enterprise_bg_name
                                (p_configuration_code      => p_configuration_code
                                ,p_enterprise_name         => l_enterprise_name_original);

      hr_utility.trace('l_business_group_country_code = ' || l_business_group_country_code);
      hr_utility.set_location(l_business_group_country_code, 93000);
      hr_utility.set_location(l_selected_country_code, 94000);
          IF l_business_group_country_code = l_selected_country_code AND
            l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
              AND l_enterprise_id IS NOT NULL
               THEN
               hr_utility.set_location('BG Matches', 91000);
               l_business_group_name := l_selected_country_name;
          ELSE
               l_business_group_name := per_ri_config_utilities.get_enterprise_short_name
                                (p_configuration_code => p_configuration_code)
                             || ' ' || l_business_group_country_code || per_ri_config_main.g_bg_name_suffix_string;
          END IF;
      hr_utility.trace('l_business_group_name = ' || l_business_group_name);
      hr_utility.set_location(l_business_group_name, 92000);
      l_ent_location_code   :=  per_ri_config_utilities.get_config_location_code
                                       (p_configuration_code  => p_configuration_code
                                       ,p_location_id         => l_enterprise_location_id);
      -- get entity name for multiple configuration
      --
      hr_utility.trace('l_ent_location_code = ' || l_ent_location_code);
      hr_utility.set_location(l_proc, 30);
      if NOT (p_technical_summary_mode) then
--        if l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0' then
--            l_business_group_name := per_ri_config_utilities.get_business_group_name;
--        end if;
        hrdpp_create_organization.insert_batch_lines
                         (p_batch_id                     => p_batch_header_id
                         ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                => 30
                         ,p_effective_date               => g_config_effective_date
                         ,p_date_from                    => g_config_effective_date
                         ,p_data_pump_business_grp_name  => l_business_group_name
                         ,p_name                         => l_enterprise_name
                         ,p_location_code                => l_ent_location_code
                         ,p_internal_external_flag       => 'INT'
                         ,p_org_user_key                 => l_enterprise_name || SYSDATE);

        hr_utility.set_location(l_proc, 40);

        hrdpp_update_organization.insert_batch_lines
                           (p_batch_id                       => p_batch_header_id
                           ,p_link_value                     => per_ri_config_main.g_global_dp_link_value
                           ,p_user_sequence                  => 40
                           ,p_effective_date                 => g_config_effective_date
                           ,p_date_from                      => g_config_effective_date
                           ,p_data_pump_business_grp_name    => l_business_group_name
                           ,p_language_code                  => hr_api.userenv_lang
                           ,p_organization_name              => l_enterprise_name
                           ,p_location_code                  => l_ent_location_code);
    else
      p_org_ent_tab(l_ent_count).effective_date         := g_config_effective_date;
      p_org_ent_tab(l_ent_count).date_from              := g_config_effective_date;
      p_org_ent_tab(l_ent_count).business_grp_name      := l_business_group_name;
      p_org_ent_tab(l_ent_count).name                   := l_enterprise_name;
      p_org_ent_tab(l_ent_count).location_code          := l_ent_location_code;
      p_org_ent_tab(l_ent_count).internal_external_flag := 'INT';

      l_ent_count  := l_ent_count + 1;

    end if;

      l_log_message := 'Created ENTERPRISE ' || l_enterprise_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 50);

      --
      -- Create HR_LEGAL classification for corporate LE
      -- For all Localizations where no mandatory org info is defined.
      -- and this classification is visible.
      --
      if per_ri_config_utilities.check_org_class_lookup_tag
                                               (p_legislation_code => l_business_group_country_code
                                               ,p_lookup_code      => 'HR_LEGAL')
            and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'HR_LEGAL') then
        hr_utility.trace('l_mandatory_org_info_types = ' || 'TRUE');
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'HR_LEGAL'
                             ,p_organization_name            => l_enterprise_name
                             ,p_language_code                => hr_api.userenv_lang);
        else
          p_org_ent_class_tab(l_ent_class_count).effective_date    := g_config_effective_date;
          p_org_ent_class_tab(l_ent_class_count).date_from         := g_config_effective_date;
          p_org_ent_class_tab(l_ent_class_count).business_grp_name := l_business_group_name;
          p_org_ent_class_tab(l_ent_class_count).org_classif_code  := 'HR_LEGAL';
          p_org_ent_class_tab(l_ent_class_count).organization_name := l_enterprise_name;

          l_ent_class_count  := l_ent_class_count + 1;

        end if;
        hr_utility.set_location(l_proc, 60);
        l_log_message := 'Created CLASSIFICATION HR_LEGAL ' || l_enterprise_name;
        per_ri_config_utilities.write_log(p_message => l_log_message);
      end if;

      hr_utility.set_location(l_proc, 70);

      --also create organization structure hierarchy batch line
      if NOT (p_technical_summary_mode) then
        hrdpp_create_organization_stru.insert_batch_lines
                        (p_batch_id                       => p_batch_header_id
                        --,p_data_pump_business_grp_name    => l_business_group_name
                        ,p_data_pump_business_grp_name    => null
                        ,p_link_value                     => per_ri_config_main.g_global_dp_link_value
                        ,p_user_sequence                  => 60
                        ,p_effective_date                 => g_config_effective_date
                        ,p_name                           => substr(l_enterprise_name,1,30)-- name of the hierarchy same
                        ,p_primary_structure_flag         => 'N'
                        ,p_position_control_structure_f   => 'N'
                        ,p_org_structure_user_key         => p_configuration_code || ' ' || l_enterprise_name
                                                             || ' Structure');
      else
        p_org_hierarchy_tab(l_org_hierarchy_count).name    := substr(l_enterprise_name,1,30);
      end if;

      l_log_message := 'Created HIERARCHY STRUCTURE ' || l_enterprise_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);

      if NOT (p_technical_summary_mode) then
        hrdpp_create_org_structure_ver.insert_batch_lines
                        (p_batch_id                       => p_batch_header_id
                        --,p_data_pump_business_grp_name    => l_business_group_name
                        ,p_data_pump_business_grp_name    => null
                        ,p_link_value                     => per_ri_config_main.g_global_dp_link_value
                        ,p_user_sequence                  => 70
                        ,p_effective_date                 => g_config_effective_date
                        ,p_date_from                      => g_config_effective_date
                        ,p_version_number                 => 1
                        ,p_topnode_pos_ctrl_enabled_fla   => 'N'
                        ,p_org_str_version_user_key       =>  p_configuration_code || ' ' || l_enterprise_name
                                                             || ' Version'
                        ,p_org_structure_user_key         =>  p_configuration_code || ' ' || l_enterprise_name
                                                             || ' Structure');
      else
        -- just populate varsion
        p_org_hierarchy_tab(l_org_hierarchy_count).org_structure_version_id    := 1;
      end if;

      l_log_message := 'Created HIERARCHY VERSION ' || to_char(1);
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 80);
    else
      null; -- report error
    end if;

    close csr_config_enterprise;

    -- Create BIS profile option
    --BIS_PRIMARY_RATE_TYPE
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'BIS'
                         ,p_profile_name         => 'BIS_PRIMARY_CURRENCY_CODE'
                         ,p_profile_option_value => 'USD'); -- change it to enter bg currency
    else
      p_profile_dpe_ent_tab(l_profile_dpe_ent_count).level                 := 1001;
      p_profile_dpe_ent_tab(l_profile_dpe_ent_count).level_value           := 0;
      p_profile_dpe_ent_tab(l_profile_dpe_ent_count).level_value_app       := 'BIS';
      p_profile_dpe_ent_tab(l_profile_dpe_ent_count).profile_name          := 'BIS_PRIMARY_CURRENCY_CODE';
      p_profile_dpe_ent_tab(l_profile_dpe_ent_count).profile_option_value  := 'USD';

      l_profile_dpe_ent_count  := l_profile_dpe_ent_count + 1;

    end if;
    l_log_message := 'Created PROFILE_OPTION ' || 'BIS_PRIMARY_RATE_TYPE';
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 60);
    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_enterprise_batch_lines;


  /* --------------------------------------------------------------------------
  -- Name      : create_oper_comp_batch_lines
  -- Purpose   : This procedure creates oper comp batch lines records in the
  --             data pump tables which would be loaded by the enterprise
  --             structures configuration loader program for a specified
  --             configuration.
  -- Arguments : p_configuration_code
  --             p_batch_header_id
  -------------------------------------------------------------------------- */

  PROCEDURE create_oper_comp_batch_lines(p_configuration_code in varchar2
                                        ,p_batch_header_id    in number
                                        ,p_multiple_config_upload in boolean default FALSE
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_org_oc_tab in out nocopy
                                             per_ri_config_tech_summary.org_oc_tab
                                        ,p_org_oc_class_tab in out nocopy
                                             per_ri_config_tech_summary.org_oc_class_tab
                                        ,p_org_hierarchy_ele_oc_tab in out nocopy
                                             per_ri_config_tech_summary.org_hierarchy_ele_oc_tab) IS

  cursor csr_config_oper_comp (cp_configuration_code in varchar2) IS
    select configuration_code,
           config_information_id,
           config_sequence,
           config_information_category,
           per_ri_config_utilities.return_config_entity_name(operating_company_name),
           operating_company_name,
           operating_company_short_name,
           operating_company_hq_country,
           operating_company_location_id
      from per_ri_config_oper_comp_v
     where configuration_code = cp_configuration_code;

  l_configuration_code            per_ri_config_information.configuration_code%type;
  l_config_information_id         per_ri_config_information.config_information_id%type;
  l_config_sequence               per_ri_config_information.config_sequence%type;
  l_config_information_category   per_ri_config_information.config_information_category%type;
  l_operating_company_name        per_ri_config_information.config_information1%type;
  l_operating_company_name_orig   per_ri_config_information.config_information1%type;
  l_operating_company_short_name  per_ri_config_information.config_information1%type;
  l_operating_company_hq_country  per_ri_config_information.config_information1%type;
  l_operating_comp_location_id    per_ri_config_information.config_information1%type;

  l_business_group_country_code   per_business_groups.name%type;
  l_business_group_name           per_business_groups.name%type;
  l_oc_location_code              per_ri_config_locations.description%type; -- fix for 4457389
  l_enterprise_name               per_ri_config_information.config_information1%type;

  l_oc_count                      number(10) := 0;
  l_oc_class_count                number(10) := 0;
  l_org_hierarchy_ele_oc_count    number(10) := 0;
  l_proc                          varchar2(72) := g_package ||'create_oper_comp_batch_lines';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_multi_tenancy                 boolean := false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  l_selected_country_code         varchar2(10);
  l_selected_country_name         varchar2(50);
  l_enterprise_id                 number(9);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;

    BEGIN
    select enterprise_id into l_enterprise_id from per_ent_security_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_enterprise_id := null;
    END;

    select legislation_code into l_selected_country_code from
     per_business_groups where business_group_id =
        fnd_profile.value('PER_BUSINESS_GROUP_ID');

   select name into l_selected_country_name from per_business_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

    open csr_config_oper_comp(p_configuration_code);

    loop
      fetch csr_config_oper_comp into
                  l_configuration_code,
                  l_config_information_id,
                  l_config_sequence,
                  l_config_information_category,
                  l_operating_company_name,
                  l_operating_company_name_orig,
                  l_operating_company_short_name,
                  l_operating_company_hq_country,
                  l_operating_comp_location_id;

      exit when csr_config_oper_comp%NOTFOUND;
      if csr_config_oper_comp%FOUND then
        hr_utility.set_location(l_proc, 20);

        hr_utility.trace('l_operating_company_name = ' || l_operating_company_name);
        l_business_group_country_code  := per_ri_config_utilities.get_oc_bg_name
                                                 (p_configuration_code      => p_configuration_code
                                                 ,p_operating_company_name  => l_operating_company_name_orig);
      hr_utility.set_location(l_business_group_country_code, 93000);
      hr_utility.set_location(l_selected_country_code, 94000);
          IF l_business_group_country_code = l_selected_country_code AND
            l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
               AND l_enterprise_id IS NOT NULL
               THEN
               hr_utility.set_location('BG Matches', 91000);
               l_business_group_name := l_selected_country_name;
          ELSE
               l_business_group_name := per_ri_config_utilities.get_enterprise_short_name
                                (p_configuration_code => p_configuration_code)
                             || ' ' || l_business_group_country_code || per_ri_config_main.g_bg_name_suffix_string;
          END IF;
      hr_utility.trace('l_business_group_name = ' || l_business_group_name);

        l_oc_location_code            :=  per_ri_config_utilities.get_config_location_code
                                         (p_configuration_code  => p_configuration_code
                                         ,p_location_id         => l_operating_comp_location_id);

        hr_utility.trace('l_business_group_country_code = ' || l_business_group_country_code);
        hr_utility.trace('l_business_group_name = ' || l_business_group_name);
        hr_utility.trace('l_oc_location_code = ' || l_oc_location_code);

        if NOT (p_technical_summary_mode) then
--          if l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0' then
--               l_business_group_name := per_ri_config_utilities.get_business_group_name;
--          end if;
          hrdpp_create_organization.insert_batch_lines
                           (p_batch_id                     => p_batch_header_id
                           ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                           ,p_user_sequence                => 30
                           ,p_effective_date               => g_config_effective_date
                           ,p_date_from                    => g_config_effective_date
                           ,p_data_pump_business_grp_name  => l_business_group_name
                           ,p_language_code                => hr_api.userenv_lang
                           ,p_name                         => l_operating_company_name
                           ,p_internal_external_flag       => 'INT'
                           ,p_location_code                => l_oc_location_code
                           ,p_org_user_key                 => l_operating_company_name || SYSDATE);


          hr_utility.set_location(l_proc, 30);

          hrdpp_update_organization.insert_batch_lines
                           (p_batch_id                     => p_batch_header_id
                           ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                           ,p_user_sequence                => 40
                           ,p_effective_date               => g_config_effective_date
                           ,p_date_from                    => g_config_effective_date
                           ,p_data_pump_business_grp_name  => l_business_group_name
                           ,p_language_code                => hr_api.userenv_lang
                           ,p_organization_name            => l_operating_company_name
                           ,p_location_code                => l_oc_location_code);
        else
          p_org_oc_tab(l_oc_count).effective_date         := g_config_effective_date;
          p_org_oc_tab(l_oc_count).date_from              := g_config_effective_date;
          p_org_oc_tab(l_oc_count).business_grp_name      := l_business_group_name;
          p_org_oc_tab(l_oc_count).name                   := l_operating_company_name;
          p_org_oc_tab(l_oc_count).location_code          := l_oc_location_code;
          p_org_oc_tab(l_oc_count).internal_external_flag := 'INT';

          l_oc_count  := l_oc_count + 1;
        end if;


        l_log_message := 'Created OPERATING COMPANY ' || l_operating_company_name;
        per_ri_config_utilities.write_log(p_message => l_log_message);
        hr_utility.set_location(l_proc, 40);

        -- create org hierarchy elements
        --
        l_enterprise_name    := per_ri_config_utilities.get_enterprise_name
                                                 (p_configuration_code => p_configuration_code);
        if NOT (p_technical_summary_mode) then
          hrdpp_create_hierarchy_element.insert_batch_lines
                         (p_batch_id                     => p_batch_header_id
                         ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                => 80
                         ,p_effective_date               => g_config_effective_date
                         ,p_date_from                    => g_config_effective_date
                         ,p_data_pump_business_grp_name  => null
                         --,p_data_pump_business_grp_name  => l_business_group_name
                         ,p_view_all_orgs                => 'Y'
                         ,p_end_of_time                  => null
                         ,p_hr_installed                 => null
                         ,p_pa_installed                 => null
                         ,p_pos_control_enabled_flag     => null
                         ,p_warning_raised               => null
                         ,p_parent_organization_name     => l_enterprise_name
                         ,p_child_organization_name      => l_operating_company_name
                         ,p_language_code                => hr_api.userenv_lang
                         ,p_org_str_version_user_key     =>  p_configuration_code || ' ' || l_enterprise_name
                                                             || ' Version'
                        -- ,p_security_profile_name        => l_business_group_name);
                         ,p_security_profile_name        => null);

        else
          p_org_hierarchy_ele_oc_tab(l_org_hierarchy_ele_oc_count).org_structure_version_id  := 1;
          p_org_hierarchy_ele_oc_tab(l_org_hierarchy_ele_oc_count).parent_organization_name  := l_enterprise_name;
          p_org_hierarchy_ele_oc_tab(l_org_hierarchy_ele_oc_count).child_organization_name  := l_operating_company_name;

          l_org_hierarchy_ele_oc_count := l_org_hierarchy_ele_oc_count + 1 ;
        end if;

        l_log_message := 'Created HIERARCHY ELEMENT ENTERPRISE ' || l_enterprise_name || ' ' || l_operating_company_name;
        per_ri_config_utilities.write_log(p_message => l_log_message);
        --
        -- Create HR_LEGAL classification
        -- For all Localizations where no mandatory org info is defined.
        -- and this classification is visible.
        --
        if per_ri_config_utilities.check_org_class_lookup_tag
                                                       (p_legislation_code => l_business_group_country_code
                                                       ,p_lookup_code      => 'HR_OPC')
           and NOT per_ri_config_utilities.mandatory_org_info_types
                                           (p_legislation_code     => l_business_group_country_code
                                           ,p_org_classification   => 'HR_OPC') then
          if NOT (p_technical_summary_mode) then
             hrdpp_create_org_classificatio.insert_batch_lines
                              (p_batch_id                     => p_batch_header_id
                              ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                              ,p_user_sequence                => 50
                              ,p_effective_date               => g_config_effective_date
                              ,p_data_pump_business_grp_name  => l_business_group_name
                              ,p_org_classif_code             => 'HR_OPC'
                              ,p_organization_name            => l_operating_company_name
                              ,p_language_code                => hr_api.userenv_lang);

          else
            p_org_oc_class_tab(l_oc_class_count).effective_date    := g_config_effective_date;
            p_org_oc_class_tab(l_oc_class_count).date_from         := g_config_effective_date;
            p_org_oc_class_tab(l_oc_class_count).business_grp_name := l_business_group_name;
            p_org_oc_class_tab(l_oc_class_count).org_classif_code  := 'HR_OPC';
            p_org_oc_class_tab(l_oc_class_count).organization_name := l_operating_company_name;

            l_oc_class_count  := l_oc_class_count + 1;

          end if;
           hr_utility.set_location(l_proc, 50);
           l_log_message := 'Created CLASSIFICATION HR_OPC ' || l_operating_company_name;
           per_ri_config_utilities.write_log(p_message => l_log_message);
        end if;
      end if;
    end loop;
    close csr_config_oper_comp;
    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_oper_comp_batch_lines;

  /* --------------------------------------------------------------------------
  -- Name      : create_le_batch_lines
  -- Purpose   : This procedure creates leagl entity batch lines records in the
  --             data pump tables which would be loaded by the enterprise
  --             structures configuration loader program for a specified
  --             configuration.
  -- Arguments : p_configuration_code
  --             p_batch_header_id
  -------------------------------------------------------------------------- */

  PROCEDURE create_le_batch_lines (p_configuration_code in varchar2
                                  ,p_batch_header_id     in number
                                  ,p_multiple_config_upload in boolean default FALSE
                                  ,p_technical_summary_mode in boolean default FALSE
                                  ,p_org_le_tab in out nocopy
                                             per_ri_config_tech_summary.org_le_tab
                                  ,p_org_le_class_tab in out nocopy
                                             per_ri_config_tech_summary.org_le_class_tab
                                  ,p_org_hierarchy_ele_le_tab in out nocopy
                                             per_ri_config_tech_summary.org_hierarchy_ele_le_tab) IS

  cursor csr_config_legal_entity (cp_configuration_code in varchar2) IS
    select configuration_code,
           config_information_id,
           config_sequence,
           config_information_category,
           per_ri_config_utilities.return_config_entity_name(legal_entity_name),
           legal_entity_name,
           legal_entity_short_name,
           legal_entity_country,
           legal_entity_parent_oper_comp,
           legal_entity_location_id
      from per_ri_config_legal_entity_v
     where configuration_code = cp_configuration_code;

  l_configuration_code            per_ri_config_information.configuration_code%type;
  l_config_information_id         per_ri_config_information.config_information_id%type;
  l_config_sequence               per_ri_config_information.config_sequence%type;
  l_config_information_category   per_ri_config_information.config_information_category%type;
  l_enterprise_name               per_ri_config_information.config_information1%type;
  l_legal_entity_name             per_ri_config_information.config_information1%type;
  l_legal_entity_name_original     per_ri_config_information.config_information1%type;
  l_legal_entity_short_name       per_ri_config_information.config_information1%type;
  l_legal_entity_country          per_ri_config_information.config_information1%type;
  l_le_parent_oper_comp           per_ri_config_information.config_information1%type;
  l_legal_entity_location_id      per_ri_config_information.config_information1%type;


  l_le_count                      number(10) := 0;
  l_le_class_count                number(10) := 0;
  l_org_hierarchy_ele_le_count    number(10) := 0;
  l_proc                          varchar2(72) := g_package ||'create_le_batch_lines';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  l_business_group_country_code   per_business_groups.name%type;
  l_business_group_name           per_business_groups.name%type;
  l_le_location_code              per_ri_config_locations.description%type; -- fix for 4457389
  l_mandatory_org_info_types      boolean default true;
  l_multi_tenancy                 boolean := false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  l_selected_country_code         varchar2(10);
  l_selected_country_name         varchar2(50);
  l_enterprise_id                 number(9);

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
  l_sec_group_id := fnd_global.security_group_id;
  if l_multi_tenancy then
      l_system_model := hr_multi_tenancy_pkg.get_system_model;
  end if;

    BEGIN
    select enterprise_id into l_enterprise_id from per_ent_security_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_enterprise_id := null;
    END;

    select legislation_code into l_selected_country_code from
     per_business_groups where business_group_id =
        fnd_profile.value('PER_BUSINESS_GROUP_ID');

   select name into l_selected_country_name from per_business_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

  open csr_config_legal_entity(p_configuration_code);

  l_enterprise_name    := per_ri_config_utilities.get_enterprise_name
                                                 (p_configuration_code => p_configuration_code);
  loop
    fetch csr_config_legal_entity into
                l_configuration_code,
                l_config_information_id,
                l_config_sequence,
                l_config_information_category,
                l_legal_entity_name,
                l_legal_entity_name_original,
                l_legal_entity_short_name,
                l_legal_entity_country,
                l_le_parent_oper_comp,
                l_legal_entity_location_id;

    exit when csr_config_legal_entity%NOTFOUND;
    hr_utility.set_location(l_proc, 20);

    hr_utility.trace('l_legal_entity_name = ' || l_legal_entity_name);
    hr_utility.trace('l_legal_entity_country = ' || l_legal_entity_country);

    l_business_group_country_code  := per_ri_config_utilities.get_le_bg_name
                                             (p_configuration_code      => p_configuration_code
                                             ,p_legal_entity_name       => l_legal_entity_name_original);
      hr_utility.set_location(l_business_group_country_code, 93000);
      hr_utility.set_location(l_selected_country_code, 94000);
          IF l_business_group_country_code = l_selected_country_code AND
            l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
              AND l_enterprise_id IS NOT NULL
               THEN
               hr_utility.set_location('BG Matches', 91000);
               l_business_group_name := l_selected_country_name;
          ELSE
               l_business_group_name := per_ri_config_utilities.get_enterprise_short_name
                                (p_configuration_code => p_configuration_code)
                             || ' ' || l_business_group_country_code || per_ri_config_main.g_bg_name_suffix_string;
          END IF;
    hr_utility.trace('l_business_group_name = ' || l_business_group_name);

    l_le_location_code   :=  per_ri_config_utilities.get_config_location_code
                                       (p_configuration_code  => p_configuration_code
                                       ,p_location_id         => l_legal_entity_location_id);
    hr_utility.trace('l_legal_entity_location_id = ' || l_legal_entity_location_id);
    hr_utility.set_location(l_proc, 30);

    if NOT (p_technical_summary_mode) then
--      if l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0' then
--           l_business_group_name := per_ri_config_utilities.get_business_group_name;
--      end if;
      hrdpp_create_organization.insert_batch_lines
                         (p_batch_id                     => p_batch_header_id
                         ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                => 30
                         ,p_effective_date               => g_config_effective_date
                         ,p_date_from                    => g_config_effective_date
                         ,p_data_pump_business_grp_name  => l_business_group_name
                         ,p_name                         => l_legal_entity_name
                         ,p_location_code                => l_le_location_code
                         ,p_internal_external_flag       => 'INT'
                         ,p_org_user_key                 => l_legal_entity_name || SYSDATE);


      hrdpp_update_organization.insert_batch_lines
                         (p_batch_id                       => p_batch_header_id
                         ,p_link_value                     => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                  => 40
                         ,p_effective_date                 => g_config_effective_date
                         ,p_date_from                      => g_config_effective_date
                         ,p_data_pump_business_grp_name    => l_business_group_name
                         ,p_language_code                  => hr_api.userenv_lang
                         ,p_organization_name              => l_legal_entity_name
                         ,p_location_code                  => l_le_location_code);
      hr_utility.set_location(l_proc, 40);
    else
      p_org_le_tab(l_le_count).effective_date         := g_config_effective_date;
      p_org_le_tab(l_le_count).date_from              := g_config_effective_date;
      p_org_le_tab(l_le_count).business_grp_name      := l_business_group_name;
      p_org_le_tab(l_le_count).name                   := l_legal_entity_name;
      p_org_le_tab(l_le_count).location_code          := l_le_location_code;
      p_org_le_tab(l_le_count).internal_external_flag := 'INT';

      l_le_count  := l_le_count + 1;
    end if;

    l_log_message := 'Created LEGAL ENTITY ' || l_legal_entity_name;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    --
    -- Create CC classification
    -- For all localization if no mandatory org info is defined.
    -- and this classification is visible.
    --
    if per_ri_config_utilities.check_org_class_lookup_tag
                                               (p_legislation_code => l_business_group_country_code
                                               ,p_lookup_code      => 'CC')
      and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'CC') then
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'CC'
                             ,p_organization_name            => l_legal_entity_name
                             ,p_language_code                => hr_api.userenv_lang);

        else
          p_org_le_class_tab(l_le_class_count).effective_date    := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).date_from         := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).business_grp_name := l_business_group_name;
          p_org_le_class_tab(l_le_class_count).org_classif_code  := 'CC';
          p_org_le_class_tab(l_le_class_count).organization_name := l_legal_entity_name;

          l_le_class_count  := l_le_class_count + 1;

        end if;
      hr_utility.set_location(l_proc, 50);
      l_log_message := 'Created CLASSIFICATION CC ' || l_legal_entity_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    --
    -- Create HR_LEGAL_EMPLOYER classification
    -- For all localization if no mandatory org info is defined.
    -- and this classification is visible.
    --
    if per_ri_config_utilities.check_org_class_lookup_tag
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_lookup_code          => 'HR_LEGAL_EMPLOYER')
       and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'HR_LEGAL_EMPLOYER') then
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'HR_LEGAL_EMPLOYER'
                             ,p_organization_name            => l_legal_entity_name
                             ,p_language_code                => hr_api.userenv_lang);
        else
          p_org_le_class_tab(l_le_class_count).effective_date    := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).date_from         := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).business_grp_name := l_business_group_name;
          p_org_le_class_tab(l_le_class_count).org_classif_code  := 'HR_LEGAL_EMPLOYER';
          p_org_le_class_tab(l_le_class_count).organization_name := l_legal_entity_name;

          l_le_class_count  := l_le_class_count + 1;

        end if;

      hr_utility.set_location(l_proc, 60);
      l_log_message := 'Created CLASSIFICATION HR_LEGAL_EMPLOYER ' || l_legal_entity_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    --
    -- Create FR_SOCIETE classification
    -- For FR localization if no mandatory org info is defined.
    -- and this classification is visible.
    --
    if l_business_group_country_code = 'FR' and
                            per_ri_config_utilities.check_org_class_lookup_tag
                                                      (p_legislation_code => l_business_group_country_code
                                                      ,p_lookup_code      => 'FR_SOCIETE')
      and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'FR_SOCIETE') then
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'FR_SOCIETE'
                             ,p_organization_name            => l_legal_entity_name
                             ,p_language_code                => hr_api.userenv_lang);

        else
          p_org_le_class_tab(l_le_class_count).effective_date    := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).date_from         := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).business_grp_name := l_business_group_name;
          p_org_le_class_tab(l_le_class_count).org_classif_code  := 'FR_SOCIETE';
          p_org_le_class_tab(l_le_class_count).organization_name := l_legal_entity_name;

          l_le_class_count  := l_le_class_count + 1;

        end if;
      hr_utility.set_location(l_proc, 70);
      l_log_message := 'Created CLASSIFICATION FR_SOCIETE ' || l_legal_entity_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    --
    -- Create IN_COMPANY classification
    -- For IN localization if no mandatory org info is defined.
    -- and this classification is visible.
    --

    if l_business_group_country_code = 'IN'  and
                            per_ri_config_utilities.check_org_class_lookup_tag
                                                      (p_legislation_code => l_business_group_country_code
                                                      ,p_lookup_code      => 'IN_COMPANY')
       and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'IN_COMPANY')then
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'IN_COMPANY'
                             ,p_organization_name            => l_legal_entity_name
                             ,p_language_code                => hr_api.userenv_lang);

        else
          p_org_le_class_tab(l_le_class_count).effective_date    := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).date_from         := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).business_grp_name := l_business_group_name;
          p_org_le_class_tab(l_le_class_count).org_classif_code  := 'IN_COMPANY';
          p_org_le_class_tab(l_le_class_count).organization_name := l_legal_entity_name;

          l_le_class_count  := l_le_class_count + 1;

        end if;
      hr_utility.set_location(l_proc, 80);
      l_log_message := 'Created CLASSIFICATION IN_COMPANY ' || l_legal_entity_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    --
    -- Create HR_LEGAL classification
    -- For all Localizations where no mandatory org info is defined.
    -- and this classification is visible.
    --
    if per_ri_config_utilities.check_org_class_lookup_tag
                                                      (p_legislation_code => l_business_group_country_code
                                                      ,p_lookup_code      => 'HR_LEGAL')
      and NOT per_ri_config_utilities.mandatory_org_info_types
                                          (p_legislation_code     => l_business_group_country_code
                                          ,p_org_classification   => 'HR_LEGAL') then
        if NOT (p_technical_summary_mode) then
          hrdpp_create_org_classificatio.insert_batch_lines
                             (p_batch_id                     => p_batch_header_id
                             ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                             ,p_user_sequence                => 50
                             ,p_effective_date               => g_config_effective_date
                             ,p_data_pump_business_grp_name  => l_business_group_name
                             ,p_org_classif_code             => 'HR_LEGAL'
                             ,p_organization_name            => l_legal_entity_name
                             ,p_language_code                => hr_api.userenv_lang);
        else
          p_org_le_class_tab(l_le_class_count).effective_date    := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).date_from         := g_config_effective_date;
          p_org_le_class_tab(l_le_class_count).business_grp_name := l_business_group_name;
          p_org_le_class_tab(l_le_class_count).org_classif_code  := 'HR_LEGAL';
          p_org_le_class_tab(l_le_class_count).organization_name := l_legal_entity_name;

          l_le_class_count  := l_le_class_count + 1;

        end if;

      hr_utility.set_location(l_proc, 90);
      l_log_message := 'Created CLASSIFICATION HR_LEGAL ' || l_legal_entity_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    --
    -- create org hierarchy elements
    --
    if NOT (p_technical_summary_mode) then
      hrdpp_create_hierarchy_element.insert_batch_lines
                         (p_batch_id                     => p_batch_header_id
                         ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                => 90
                         ,p_effective_date               => g_config_effective_date
                         ,p_date_from                    => g_config_effective_date
                         ,p_data_pump_business_grp_name  => null
                         --,p_data_pump_business_grp_name  => l_business_group_name
                         ,p_view_all_orgs                => 'Y'
                         ,p_end_of_time                  => null
                         ,p_hr_installed                 => null
                         ,p_pa_installed                 => null
                         ,p_pos_control_enabled_flag     => null
                         ,p_warning_raised               => null
                         ,p_parent_organization_name     => per_ri_config_utilities.return_config_entity_name
                                                              (l_le_parent_oper_comp)
                         ,p_child_organization_name      => l_legal_entity_name
                         ,p_language_code                => hr_api.userenv_lang
                         ,p_org_str_version_user_key     =>  p_configuration_code || ' ' || l_enterprise_name
                                                             || ' Version'
                         --,p_security_profile_name        => l_business_group_name);
                         ,p_security_profile_name        => null);
    else
      p_org_hierarchy_ele_le_tab(l_org_hierarchy_ele_le_count).org_structure_version_id  := 1;
      p_org_hierarchy_ele_le_tab(l_org_hierarchy_ele_le_count).parent_organization_name  := per_ri_config_utilities.return_config_entity_name
                                                                                             (l_le_parent_oper_comp);
      p_org_hierarchy_ele_le_tab(l_org_hierarchy_ele_le_count).child_organization_name   := l_legal_entity_name;

      l_org_hierarchy_ele_le_count := l_org_hierarchy_ele_le_count + 1 ;
    end if;

    l_log_message := 'Created HIERARCHY ELEMENT OPERATING_COMPANY ' || l_le_parent_oper_comp || ' ' || l_legal_entity_name;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    hr_utility.set_location(l_proc, 100);
    end loop;
    close csr_config_legal_entity;

    hr_utility.set_location(' Leaving:'|| l_proc, 110);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_le_batch_lines;

  /* --------------------------------------------------------------------------
  -- Name      : create_locations_batch_lines
  -- Purpose   : This procedure creates locations batch lines records in the
  --             data pump tables which would be loaded by the enterprise
  --             structures configuration loader program for a specified
  --             configuration.
  -- Arguments : p_configuration_code
  --             p_batch_header_id
  -------------------------------------------------------------------------- */
  PROCEDURE create_locations_batch_lines(p_configuration_code in varchar2
                                        ,p_batch_header_id     in number
                                        ,p_multiple_config_upload in boolean default FALSE
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_location_tab in out nocopy
                                             per_ri_config_tech_summary.location_tab) IS

  cursor csr_config_location(cp_configuration_code in varchar2) IS
  select configuration_code,
         configuration_context,
         location_id,
         location_code,
         description,
         style,
         address_line_1,
         address_line_2,
         address_line_3,
         town_or_city,
         country,
         postal_code,
         region_1,
         region_2,
         region_3,
         telephone_number_1,
         telephone_number_2,
         telephone_number_3,
         loc_information13,
         loc_information14,
         loc_information15,
         loc_information16,
         loc_information17,
         loc_information18,
         loc_information19,
         loc_information20,
         object_version_number
  from   per_ri_config_locations
  where  configuration_code  = cp_configuration_code;

    -- Get the Country Code when style is generic
  CURSOR csr_get_country_code(cp_country_name in varchar2) IS
    SELECT territory_code
      FROM fnd_territories_vl
     WHERE territory_short_name = cp_country_name;

  l_configuration_code            per_ri_config_locations.configuration_code%type;
  l_configuration_context         per_ri_config_locations.configuration_context%type;
  l_location_id                   per_ri_config_locations.location_id%type;
  l_location_code                 per_ri_config_locations.description%type; -- fix for 4457389
  l_description                   per_ri_config_locations.description %type;
  l_style                         per_ri_config_locations.style%type;
  l_address_line_1                per_ri_config_locations.address_line_1%type;
  l_address_line_2                per_ri_config_locations.address_line_2%type;
  l_address_line_3                per_ri_config_locations.address_line_3%type;
  l_town_or_city                  per_ri_config_locations.town_or_city%type;
  l_country                       per_ri_config_locations.country%type;
  l_postal_code                   per_ri_config_locations.postal_code%type;
  l_region_1                      per_ri_config_locations.region_1%type;
  l_region_2                      per_ri_config_locations.region_2%type;
  l_region_3                      per_ri_config_locations.region_3%type;
  l_telephone_number_1            per_ri_config_locations.telephone_number_1%type;
  l_telephone_number_2            per_ri_config_locations.telephone_number_2%type;
  l_telephone_number_3            per_ri_config_locations.telephone_number_3%type;
  l_loc_information13             per_ri_config_locations.loc_information13%type;
  l_loc_information14             per_ri_config_locations.loc_information14%type;
  l_loc_information15             per_ri_config_locations.loc_information15%type;
  l_loc_information16             per_ri_config_locations.loc_information16%type;
  l_loc_information17             per_ri_config_locations.loc_information17%type;
  l_loc_information18             per_ri_config_locations.loc_information18%type;
  l_loc_information19             per_ri_config_locations.loc_information19%type;
  l_loc_information20             per_ri_config_locations.loc_information20%type;
  l_object_version_number         per_ri_config_locations.object_version_number%type;

  l_locations_count                number(10) := 0;
  l_proc                          varchar2(72) := g_package || 'create_locations_batch_lines';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_config_location(p_configuration_code);
    LOOP
      fetch csr_config_location into
                       l_configuration_code,
                       l_configuration_context,
                       l_location_id,
                       l_location_code,
                       l_description,
                       l_style,
                       l_address_line_1,
                       l_address_line_2,
                       l_address_line_3,
                       l_town_or_city,
                       l_country,
                       l_postal_code,
                       l_region_1,
                       l_region_2,
                       l_region_3,
                       l_telephone_number_1,
                       l_telephone_number_2,
                       l_telephone_number_3,
                       l_loc_information13,
                       l_loc_information14,
                       l_loc_information15,
                       l_loc_information16,
                       l_loc_information17,
                       l_loc_information18,
                       l_loc_information19,
                       l_loc_information20,
                       l_object_version_number;

      exit when csr_config_location%NOTFOUND;
      l_location_code := per_ri_config_utilities.return_config_entity_name(l_location_code);

      if l_style = 'GENERIC' then

       OPEN csr_get_country_code(l_country);
       FETCH csr_get_country_code into l_country;
       CLOSE csr_get_country_code;

      end if;

      hr_utility.trace( 'l_location_code = ' || l_location_code);
      hr_utility.trace( 'l_style = ' || l_style);
      if NOT (p_technical_summary_mode) then
             hrdpp_create_location.insert_batch_lines
                                (p_batch_id                => p_batch_header_id
                                ,p_effective_date          => g_config_effective_date
                                ,p_link_value              => per_ri_config_main.g_global_dp_link_value
                                ,p_user_sequence           => 10
                                ,p_location_code           => l_location_code
                                ,p_description             => l_description
                                ,p_address_line_1          => l_address_line_1
                                ,p_address_line_2          => l_address_line_2
                                ,p_address_line_3          => l_address_line_3
                                ,p_bill_to_site_flag       => 'Y'
                                ,p_country                 => l_country
                                ,p_in_organization_flag    => 'Y'
                                ,p_postal_code             => l_postal_code
                                ,p_receiving_site_flag     => 'Y'
                                ,p_region_1                => l_region_1
                                ,p_region_2                => l_region_2
                                ,p_region_3                => l_region_3
                                ,p_ship_to_site_flag       => 'Y'
                                ,p_style                   => l_style
                                ,p_telephone_number_1      => l_telephone_number_1
                                ,p_telephone_number_2      => l_telephone_number_2
                                ,p_telephone_number_3      => l_telephone_number_3
                                ,p_town_or_city            => l_town_or_city
                                ,p_loc_information13       => l_loc_information13
                                ,p_loc_information14       => l_loc_information14
                                ,p_loc_information15       => l_loc_information15
                                ,p_loc_information16       => l_loc_information16
                                ,p_loc_information17       => l_loc_information17
                                ,p_loc_information18       => l_loc_information18
                                ,p_loc_information19       => l_loc_information19
                                ,p_loc_information20       => l_loc_information20
                                ,p_location_user_key       => l_location_code
                                ,p_ship_to_location_code   => l_location_code);
      else
        p_location_tab(l_locations_count).location_code         := l_location_code;
        p_location_tab(l_locations_count).description           := l_description;
        p_location_tab(l_locations_count).address_line_1        :=  l_address_line_1;
        p_location_tab(l_locations_count).address_line_2        :=  l_address_line_2;
        p_location_tab(l_locations_count).address_line_3        :=  l_address_line_3;
        p_location_tab(l_locations_count).bill_to_site_flag     := 'Y';
        p_location_tab(l_locations_count).country               := l_country;
        p_location_tab(l_locations_count).in_organization_flag  :=  'Y';
        p_location_tab(l_locations_count).postal_code           :=  l_postal_code;
        p_location_tab(l_locations_count).receiving_site_flag   := 'Y';
        p_location_tab(l_locations_count).region_1              := l_region_1;
        p_location_tab(l_locations_count).region_2              := l_region_2;
        p_location_tab(l_locations_count).region_3              := l_region_3;
        p_location_tab(l_locations_count).ship_to_site_flag     :=  'Y';
        p_location_tab(l_locations_count).style                 :=  l_style;
        p_location_tab(l_locations_count).telephone_number_1    :=  l_telephone_number_1;
        p_location_tab(l_locations_count).telephone_number_2    :=  l_telephone_number_2;
        p_location_tab(l_locations_count).telephone_number_3    :=  l_telephone_number_3;
        p_location_tab(l_locations_count).town_or_city          :=  l_town_or_city;
        p_location_tab(l_locations_count).loc_information13     :=  l_loc_information13;
        p_location_tab(l_locations_count).loc_information14     :=  l_loc_information14;
        p_location_tab(l_locations_count).loc_information15     :=  l_loc_information15;
        p_location_tab(l_locations_count).loc_information16     :=  l_loc_information16;
        p_location_tab(l_locations_count).loc_information17     :=  l_loc_information17;
        p_location_tab(l_locations_count).loc_information18     :=  l_loc_information18;
        p_location_tab(l_locations_count).loc_information19     :=  l_loc_information19;
        p_location_tab(l_locations_count).loc_information20     :=  l_loc_information20;
        p_location_tab(l_locations_count).ship_to_location_code :=  l_location_code;

       l_locations_count := l_locations_count + 1;
      end if;

      l_log_message := 'Created LOCATION ' || l_location_code;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 40);
    END LOOP;
    close csr_config_location;
    hr_utility.set_location(' Leaving :' || l_proc, 50);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;
  END create_locations_batch_lines;


  /* --------------------------------------------------------------------------
  -- Name      : create_bg_batch_lines
  -- Purpose   : This procedure creates business groups batch lines records in
  --             data pump tables which would be loaded by the enterprise
  --             structures configuration loader program for a specified
  --             configuration.
  -- Arguments : p_configuration_code
  --             p_batch_header_id
  --             p_country_tab_out
  -------------------------------------------------------------------------- */

  PROCEDURE create_bg_batch_lines(p_batch_header_id           in number
                                 ,p_configuration_code        in varchar2
                                 ,p_country_tab_out           in out nocopy country_tab
                                 ,p_multiple_config_upload in boolean default FALSE
                                 ,p_technical_summary_mode in boolean default FALSE
                                 ,p_bg_tab in out nocopy
                                             per_ri_config_tech_summary.bg_tab
                                 ,p_sg_tab in out nocopy
                                             per_ri_config_tech_summary.sg_tab
                                 ,p_post_install_tab in out nocopy
                                             per_ri_config_tech_summary.post_install_tab
                                 ,p_int_bg_resp_tab             in out nocopy
                                             per_ri_config_fnd_hr_entity.int_bg_resp_tab) IS

  cursor csr_config_business_groups(cp_configuration_code in varchar2) IS
    select distinct configuration_code,
           per_ri_config_utilities.business_group_decision(configuration_code,country_code)
      from per_ri_config_country_v
     where configuration_code = cp_configuration_code;

  -- Bugfix 4133935
  -- Need the enterprise BG country
  cursor csr_config_information(cp_configuration_code in varchar2) IS
    select config_information3 country_code
      from per_ri_config_information
     where configuration_code = cp_configuration_code
       and config_information_category = 'CONFIG ENTERPRISE';

  l_configuration_code            per_ri_config_information.configuration_code%type;
  l_bg_country_name               per_ri_config_information.config_information1%type;
  l_enterprise_bg_country_code    per_ri_config_information.config_information2%type;
  l_business_group_name           hr_all_organization_units.name%type;
  l_batch_header_id               number(15);
  l_legislation_code              per_business_groups.legislation_code%type;
  l_job_flex_stru_code            varchar2(30);
  l_position_flex_stru_code       varchar2(30);
  l_grade_flex_stru_code          varchar2(30);
  l_group_flex_stru_code          varchar2(30);
  l_cost_flex_stru_code           varchar2(30);
  l_security_group_name           varchar2(30) default 'STANDARD';
  l_competence_flex_stru_code     varchar2(30);
  l_currency_code                 varchar2(30);
  l_currecny_flag                 varchar2(30);
  l_country_tab                   country_tab;

  l_bg_count                      number(8) := 0;
  l_sg_count                      number(8) := 0;
  l_int_bg_resp_count             number(8) := 0;
  l_post_install_count            number(8) := 0;
  l_proc                          varchar2(72) := g_package || 'create_bg_batch_lines';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  l_per_post_install              boolean;
  l_pay_post_install              boolean;

  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  l_country_selected              PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPe;
  l_enterprise_id                 number(9);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    select legislation_code into l_country_selected from per_business_groups
      where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;

    hr_utility.set_location('Sec Group Id Is '||fnd_global.security_group_id, 95000);
    IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
      THEN
       hr_utility.set_location('Inside the if ', 96000);
       select security_group_name into l_security_group_name
        from fnd_security_groups_tl
        where security_group_id = fnd_global.security_group_id
        and   language = userenv('LANG');
      hr_utility.set_location('Sec Group Name Is '|| l_security_group_name, 97000);
    END IF;

    BEGIN
    select enterprise_id into l_enterprise_id from per_ent_security_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_enterprise_id := null;
    END;
    hr_utility.set_location('The Legislation Code is '|| l_country_selected, 43);


    open csr_config_business_groups(p_configuration_code);

    -- bugfix 4133935
    open csr_config_information(p_configuration_code);
    fetch csr_config_information into
          l_enterprise_bg_country_code;
    --

    loop
    fetch csr_config_business_groups into
               l_configuration_code,
               l_bg_country_name;

    exit when csr_config_business_groups%NOTFOUND;

    l_business_group_name := per_ri_config_utilities.get_enterprise_short_name
                                (p_configuration_code => p_configuration_code)
                             || ' ' || l_bg_country_name || per_ri_config_main.g_bg_name_suffix_string;

    hr_utility.set_location('The name selected is '|| l_bg_country_name, 44)    ;

    if l_bg_country_name = 'INT' then
      l_legislation_code := 'BF'; -- For Burkina Faso
    else
      l_legislation_code := l_bg_country_name;
    end if;

    if l_bg_country_name = 'INT' then
      l_currency_code := 'USD'; --  chnage it out corporate LE bg currency.
    else
      l_currency_code := per_ri_config_utilities.get_country_currency
                                           (p_legislation_code => l_bg_country_name);
    end if;

    -- For those BG legislations that do not have a currency code defined
    -- i.  Default the currency code for the legislation defined
    --     at the Enterprise
    -- ii. If a currency code does not exist for the BG legislation at the
    --     Enterprise, default to USD
    if l_currency_code is null then
      l_currency_code := per_ri_config_utilities.get_country_currency
                                          (p_legislation_code => l_enterprise_bg_country_code);
    end if;

    if l_currency_code is null then
      l_currency_code := 'USD';
    end if;

    l_job_flex_stru_code :=  per_ri_config_utilities.get_bg_job_keyflex_name
                                       (p_configuration_code   => p_configuration_code
                                       ,p_bg_country_code      => l_bg_country_name);
    hr_utility.trace('Job Name ' || l_job_flex_stru_code);

    l_position_flex_stru_code :=  per_ri_config_utilities.get_bg_pos_keyflex_name
                                       (p_configuration_code   => p_configuration_code
                                       ,p_bg_country_code      => l_bg_country_name);

    hr_utility.trace('Position Name ' || l_position_flex_stru_code);
    l_grade_flex_stru_code :=  per_ri_config_utilities.get_bg_grd_keyflex_name
                                       (p_configuration_code   => p_configuration_code
                                       ,p_bg_country_code      => l_bg_country_name);

    hr_utility.trace('Grade Name ' || l_grade_flex_stru_code);

    hr_utility.trace('l_legislation_code = ' || l_legislation_code);

    l_currecny_flag  := per_ri_config_utilities.check_currency_enabled (p_legislation_code  => l_legislation_code);
    hr_utility.trace('l_currecny_flag = ' || l_currecny_flag);
    if l_currecny_flag = 'X' then
      per_ri_config_utilities.enable_country_currency (p_legislation_code  => l_legislation_code);
      hr_utility.trace('l_currecny_flag = ' || l_currecny_flag);
    end if;

   IF l_bg_country_name = l_country_selected AND
     l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
       AND l_enterprise_id IS NOT NULL
        THEN
               hr_utility.set_location('The BG has to be skipped', 90000);
          ELSE
    if NOT (p_technical_summary_mode) then

      hrdpp_create_business_group.insert_batch_lines
                         (p_batch_id                   => p_batch_header_id
                         ,p_link_value                   => per_ri_config_main.g_global_dp_link_value
                         ,p_user_sequence                => 20
                         ,p_effective_date             => g_config_effective_date
                         ,p_language_code              => hr_api.userenv_lang
                         ,p_date_from                  => g_config_effective_date
                         ,p_name                       => l_business_group_name
                         ,p_type                       => null
                         ,p_internal_external_flag     => 'INT'
                         ,p_short_name                 => l_business_group_name
                         ,p_emp_gen_method             => 'A'
                         ,p_app_gen_method             => 'A'
                         ,p_cwk_gen_method             => 'A'
                         ,p_legislation_code           => l_legislation_code
                         ,p_currency_code              => l_currency_code
                         ,p_fiscal_year_start          => null
                         ,p_min_work_age               => null
                         ,p_max_work_age               => null
                         ,p_location_code              => null
                         ,p_org_user_key               => l_business_group_name || sysdate
                         ,p_grade_flex_stru_code       => l_grade_flex_stru_code
                         ,p_group_flex_stru_code       => per_ri_config_main.g_global_pea_structure_name
                         ,p_job_flex_stru_code         => l_job_flex_stru_code
                         ,p_cost_flex_stru_code        => per_ri_config_main.g_global_cst_structure_name
                         ,p_position_flex_stru_code    => l_position_flex_stru_code
                         ,p_security_group_name        => l_security_group_name
                         ,p_competence_flex_stru_code  => per_ri_config_main.g_global_cmp_structure_name);
   else
    hr_utility.set_location('Entering into the other tab as well ', 89);
    p_bg_tab(l_bg_count).effective_date := g_config_effective_date;
    p_bg_tab(l_bg_count).language_code          :=  hr_api.userenv_lang;
    p_bg_tab(l_bg_count).date_from              :=  g_config_effective_date;
    p_bg_tab(l_bg_count).name                   :=  l_business_group_name;
    p_bg_tab(l_bg_count).type                   :=  null;
    p_bg_tab(l_bg_count).internal_external_flag :=  'INT';
    p_bg_tab(l_bg_count).short_name             :=  l_business_group_name;
    p_bg_tab(l_bg_count).emp_gen_method         :=  'A';
    p_bg_tab(l_bg_count).app_gen_method         :=  'A';
    p_bg_tab(l_bg_count).cwk_gen_method         :=  'A';
    p_bg_tab(l_bg_count).legislation_code       :=  l_legislation_code;
    p_bg_tab(l_bg_count).currency_code          :=  l_currency_code;
    p_bg_tab(l_bg_count).fiscal_year_start      :=  null;
    p_bg_tab(l_bg_count).min_work_age           :=  null;
    p_bg_tab(l_bg_count).max_work_age           :=  null ;
    p_bg_tab(l_bg_count).location_code          :=  null;
    p_bg_tab(l_bg_count).grade_flex_stru_code    :=  l_grade_flex_stru_code;
    p_bg_tab(l_bg_count).group_flex_stru_code  :=  per_ri_config_main.g_global_pea_structure_name;
    p_bg_tab(l_bg_count).job_flex_stru_code     :=  l_job_flex_stru_code;
    p_bg_tab(l_bg_count).cost_flex_stru_code    :=  per_ri_config_main.g_global_cst_structure_name;
    p_bg_tab(l_bg_count).position_flex_stru_code:=  l_position_flex_stru_code;
    p_bg_tab(l_bg_count).security_group_name    :=  l_security_group_name;
    p_bg_tab(l_bg_count).competence_flex_stru_code  :=  per_ri_config_main.g_global_cmp_structure_name;

    l_bg_count := l_bg_count +1 ;

    -- also populate secuity profiles table
    p_sg_tab(l_sg_count).security_group_name          :=  l_business_group_name;
    p_sg_tab(l_sg_count).business_group_name          :=  l_business_group_name;

    l_sg_count := l_sg_count +1 ;

    -- determine post install steps for PER and PAY
    if per_ri_config_utilities.check_selected_product
                                        (p_configuration_code => p_configuration_code
                                        ,p_product_name      => 'PER') then
      l_per_post_install := per_ri_config_utilities.legislation_support
                                               (p_legislation_code        => l_legislation_code
                                               ,p_application_short_name  => 'PER');
      if l_per_post_install or l_legislation_code = 'BF' then
        p_post_install_tab(l_post_install_count).legislation_code      := l_legislation_code;
        p_post_install_tab(l_post_install_count).applicaton_short_name := 'PER';

        l_post_install_count := l_post_install_count + 1 ;
      end if;
    end if;

    if per_ri_config_utilities.check_selected_product
                                        (p_configuration_code => p_configuration_code
                                        ,p_product_name       => 'PAY') then
      l_per_post_install := per_ri_config_utilities.legislation_support
                                               (p_legislation_code        => l_legislation_code
                                               ,p_application_short_name  => 'PAY');
      if l_per_post_install then
        p_post_install_tab(l_post_install_count).legislation_code      := l_legislation_code;
        p_post_install_tab(l_post_install_count).applicaton_short_name := 'PAY';

        l_post_install_count := l_post_install_count + 1 ;
      end if;
    end if;
  end if;
END IF;

    l_log_message := 'Created BUSINESS GROUP ' || l_business_group_name;
    per_ri_config_utilities.write_log(p_message => l_log_message);
    hr_utility.set_location(l_proc, 40);

    p_country_tab_out(csr_config_business_groups%ROWCOUNT).territory_code := l_legislation_code;

    p_int_bg_resp_tab(csr_config_business_groups%ROWCOUNT).security_profile_name := l_business_group_name;

    end loop;
    close csr_config_business_groups;
    close csr_config_information;

    hr_utility.set_location(' Leaving:'|| l_proc, 50);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_bg_batch_lines;



END per_ri_config_datapump_entity;

/
