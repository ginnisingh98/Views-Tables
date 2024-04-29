--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_MAIN" AS
/* $Header: perricmn.pkb 120.4.12010000.8 2009/08/31 08:36:00 psengupt ship $ */

  g_config_effective_date     date          := TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_config_effective_end_date date          := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
  g_package                   varchar2(30)  := 'per_ri_config_main.';

  PROCEDURE create_technical_summary (p_errbuff                     out nocopy varchar2
                                     ,p_retcode                     out nocopy number
                                     ,p_configuration_code          in varchar2
                                     ,p_technical_summary_mode      in boolean default false
                                     ,p_user_clob                   in out nocopy clob
                                     ,p_resp_clob                   out nocopy clob
                                     ,p_location_clob               out nocopy clob
                                     ,p_bg_clob                     out nocopy clob
                                     ,p_sg_clob                     out nocopy clob
                                     ,p_int_hrms_clob               out nocopy clob
                                     ,p_key_str_clob                out nocopy clob
                                     ,p_key_seg_clob                out nocopy clob
                                     ,p_site_profile_clob           out nocopy clob
                                     ,p_profile_apps_clob           out nocopy clob
                                     ,p_profile_resp_clob           out nocopy clob
                                     ,p_organization_clob           out nocopy clob
                                     ,p_org_class_clob              out nocopy clob
                                     ,p_org_class_for_pv_clob       out nocopy clob
                                     ,p_org_hierarchy_ele_clob      out nocopy clob
			             ,p_str_seg_for_pv_clob         out nocopy clob
                                     ,p_org_hier_ele_for_pv_clob    out nocopy clob
                                     ,p_org_hierarchy_clob          out nocopy clob
                                     ,p_post_install_clob           out nocopy clob
                                     ,p_kf_job_str_clob             out nocopy clob
                                     ,p_kf_job_rv_str_clob          out nocopy clob
                                     ,p_kf_job_no_rv_str_clob       out nocopy clob
                                     ,p_kf_pos_str_clob             out nocopy clob
                                     ,p_kf_pos_rv_str_clob          out nocopy clob
                                     ,p_kf_pos_no_rv_str_clob       out nocopy clob
                                     ,p_kf_grd_str_clob             out nocopy clob
                                     ,p_kf_cmp_str_clob             out nocopy clob
                                     ,p_kf_grp_str_clob             out nocopy clob
                                     ,p_kf_cost_str_clob            out nocopy clob
                                     ,p_kf_job_seg_clob             out nocopy clob
                                     ,p_kf_job_rv_seg_clob          out nocopy clob
                                     ,p_kf_job_no_rv_seg_clob       out nocopy clob
                                     ,p_kf_pos_seg_clob             out nocopy clob
                                     ,p_kf_pos_rv_seg_clob          out nocopy clob
                                     ,p_kf_grd_seg_clob             out nocopy clob
                                     ,p_kf_grd_no_rv_seg_clob       out nocopy clob
                                     ,p_kf_grd_rv_seg_clob          out nocopy clob
                                     ,p_kf_grp_seg_clob             out nocopy clob
                                     ,p_kf_cmp_seg_clob             out nocopy clob
                                     ,p_kf_cost_seg_clob            out nocopy clob
                                     ,p_kf_pos_no_rv_seg_clob       out nocopy clob) IS

      cursor csr_config_business_groups(cp_configuration_code in varchar2) IS
    select distinct configuration_code,
           per_ri_config_utilities.business_group_decision(configuration_code,country_code)
      from per_ri_config_country_v
     where configuration_code = cp_configuration_code;

  l_proc                          varchar2(72) := g_package || 'create_technical_summary';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_batch_header_id               number(15);
  l_batch_name                    hr_pump_batch_headers.batch_name%type;
  l_errbuf                        varchar2(240);
  l_retcode                       number(15);
  l_job_defined                   boolean default FALSE;
  l_pos_defined                   boolean default FALSE;
  l_grd_defined                   boolean default FALSE;

  l_jp_rv_defined                 boolean default FALSE;
  l_grd_rv_defined                boolean default FALSE;
  l_country_tab                   per_ri_config_datapump_entity.country_tab;
  l_security_profile_tab          per_ri_config_fnd_hr_entity.security_profile_tab;
  l_int_bg_resp_tab               per_ri_config_fnd_hr_entity.int_bg_resp_tab;

  l_errbuf_msg                    varchar2(240);
  l_retcode_msg                   number(15);
  l_fresh_installed               boolean;
  l_data_pump_exception           boolean;

  l_enterprise_short_name         per_ri_config_information.config_information1%type;
  not_fresh_install               EXCEPTION;
  data_pump_load_failure          EXCEPTION;

  l_user_tab                      per_ri_config_tech_summary.user_tab;
  l_resp_tab                      per_ri_config_tech_summary.resp_tab;
  l_hrms_resp_tab                 per_ri_config_tech_summary.hrms_resp_tab;
  l_hrms_misc_resp_tab            per_ri_config_tech_summary.hrms_misc_resp_tab;
  l_profile_tab                   per_ri_config_tech_summary.profile_tab;
  l_profile_apps_tab              per_ri_config_tech_summary.profile_apps_tab;
  l_profile_dpe_ent_tab           per_ri_config_tech_summary.profile_dpe_ent_tab;

  l_location_tab                  per_ri_config_tech_summary.location_tab;
  l_bg_tab                        per_ri_config_tech_summary.bg_tab;
  l_sg_tab                        per_ri_config_tech_summary.sg_tab;
  l_post_install_tab              per_ri_config_tech_summary.post_install_tab;
  l_org_ent_tab                   per_ri_config_tech_summary.org_ent_tab;

  l_org_hierarchy_tab             per_ri_config_tech_summary.org_hierarchy_tab;
  l_org_hierarchy_ele_oc_tab      per_ri_config_tech_summary.org_hierarchy_ele_oc_tab;
  l_org_hierarchy_ele_le_tab      per_ri_config_tech_summary.org_hierarchy_ele_le_tab;

  l_org_oc_tab                    per_ri_config_tech_summary.org_oc_tab;
  l_org_le_tab                    per_ri_config_tech_summary.org_le_tab;

  l_org_ent_class_tab             per_ri_config_tech_summary.org_ent_class_tab;
  l_org_oc_class_tab              per_ri_config_tech_summary.org_oc_class_tab;
  l_org_le_class_tab              per_ri_config_tech_summary.org_le_class_tab;

  l_kf_job_tab                    per_ri_config_tech_summary.kf_job_tab;
  l_kf_pos_tab                    per_ri_config_tech_summary.kf_pos_tab;
  l_kf_grd_tab                    per_ri_config_tech_summary.kf_grd_tab;

  l_kf_job_seg_tab                per_ri_config_tech_summary.kf_job_seg_tab;
  l_kf_pos_seg_tab                per_ri_config_tech_summary.kf_pos_seg_tab;
  l_kf_grd_seg_tab                per_ri_config_tech_summary.kf_grd_seg_tab;

  l_kf_grp_tab                    per_ri_config_tech_summary.kf_grp_tab;
  l_kf_cmp_tab                    per_ri_config_tech_summary.kf_cmp_tab;
  l_kf_cost_tab                   per_ri_config_tech_summary.kf_cost_tab;
  l_kf_grp_seg_tab                per_ri_config_tech_summary.kf_grp_seg_tab;
  l_kf_cmp_seg_tab                per_ri_config_tech_summary.kf_cmp_seg_tab;
  l_kf_cost_seg_tab               per_ri_config_tech_summary.kf_cost_seg_tab;

  l_kf_job_no_rv_tab              per_ri_config_tech_summary.kf_job_no_rv_tab;
  l_kf_job_no_rv_seg_tab          per_ri_config_tech_summary.kf_job_no_rv_seg_tab;

  l_kf_job_rv_tab                 per_ri_config_tech_summary.kf_job_rv_tab;
  l_kf_job_rv_seg_tab             per_ri_config_tech_summary.kf_job_rv_seg_tab;

  l_kf_pos_no_rv_tab              per_ri_config_tech_summary.kf_pos_no_rv_tab;
  l_kf_pos_no_rv_seg_tab          per_ri_config_tech_summary.kf_pos_no_rv_seg_tab;

  l_kf_pos_rv_tab                 per_ri_config_tech_summary.kf_pos_rv_tab;
  l_kf_pos_rv_seg_tab             per_ri_config_tech_summary.kf_pos_rv_seg_tab;

  l_kf_grd_no_rv_tab              per_ri_config_tech_summary.kf_grd_no_rv_tab;
  l_kf_grd_no_rv_seg_tab          per_ri_config_tech_summary.kf_grd_no_rv_seg_tab;

  l_kf_grd_rv_tab                 per_ri_config_tech_summary.kf_grd_rv_tab;
  l_kf_grd_rv_seg_tab             per_ri_config_tech_summary.kf_grd_rv_seg_tab;

  l_int_hrms_setup_tab            per_ri_config_tech_summary.int_hrms_setup_tab;

  l_kf_job_clob                   clob;
  l_kf_job_rv_clob                clob;
  l_kf_job_no_rv_clob             clob;
  l_kf_pos_clob                   clob;
  l_kf_pos_rv_clob                clob;
  l_kf_pos_no_rv_clob             clob;
  l_kf_grd_clob                   clob;
  l_kf_grd_rv_clob                clob;
  l_kf_grd_no_rv_clob             clob;
  l_kf_cmp_clob                   clob;
  l_kf_grp_clob                   clob;
  l_kf_cost_clob                  clob;
  l_kf_job_seg_clob               clob;
  l_kf_job_rv_seg_clob            clob;
  l_kf_job_no_rv_seg_clob         clob;
  l_kf_pos_seg_clob               clob;
  l_kf_pos_rv_seg_clob            clob;
  l_kf_grd_seg_clob               clob;
  l_kf_grd_no_rv_seg_clob         clob;
  l_kf_grd_rv_seg_clob            clob;
  l_kf_grp_seg_clob               clob;
  l_kf_cmp_seg_clob               clob;
  l_kf_cost_seg_clob              clob;
  l_kf_pos_no_rv_seg_clob         clob;

  l_more_profile_resp_tab         per_ri_config_tech_summary.profile_resp_tab;
  l_more_int_profile_resp_tab     per_ri_config_tech_summary.profile_resp_tab;
  l_hrms_resp_main_tab            per_ri_config_tech_summary.hrms_resp_tab;

  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  number(10);
  l_enterprise_id                 number(10);
  l_bg_count                      number(10);
  l_configuration_code            varchar2(50);
  l_bg_country_name               varchar2(50);

  PRAGMA Exception_Init(not_fresh_install, -20001);
  PRAGMA Exception_Init(data_pump_load_failure, -20002);

  BEGIN


    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace('Starting Time = ' || to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS'));

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

    -- Set global variable for loader program mode
    g_technical_summary_mode := p_technical_summary_mode;

    if g_technical_summary_mode then
      hr_utility.trace('Technical Summary Mode');
    end if;

    l_job_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'JOB');

    l_pos_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'POSITION');

    l_grd_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'GRADE');

    l_jp_rv_defined    :=  per_ri_config_utilities.regional_variance_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_rv_type             => 'JP');

    l_grd_rv_defined    :=  per_ri_config_utilities.regional_variance_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_rv_type             => 'GRD');

    hr_utility.set_location(l_proc, 20);

    -- populate enterprise short name global variable
    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);
    --

    --
    -- create HRMS_USER super user
    --
    per_ri_config_fnd_def_entity.create_user(p_technical_summary_mode  => p_technical_summary_mode
                                            ,p_user_tab                => l_user_tab);

    p_user_clob := per_ri_config_tech_summary.get_user_sql (l_user_tab);

    hr_utility.set_location(l_proc, 30);

    --
    -- attach default responsibility
    --
    per_ri_config_fnd_def_entity.attach_default_responsibility
                                  (p_configuration_code       => p_configuration_code
                                  ,p_technical_summary_mode => p_technical_summary_mode
                                  ,p_resp_tab => l_resp_tab
                                  );

    hr_utility.set_location(l_proc, 40);

    --
    -- set site level profile options
    --
    per_ri_config_fnd_def_entity.create_site_profile_options
                                   (p_configuration_code       => p_configuration_code
                                   ,p_technical_summary_mode   => p_technical_summary_mode
                                   ,p_profile_tab              => l_profile_tab);

    --p_site_profile_clob := per_ri_config_tech_summary.get_profile_sql (l_profile_tab);
    -- to be called after enterprise_line

    --
    -- set aplication level profile options
    --
    per_ri_config_fnd_hr_entity.create_application_level_resp
                                   (p_configuration_code        => p_configuration_code
                                   ,p_technical_summary_mode    => p_technical_summary_mode
                                   ,p_profile_apps_tab          => l_profile_apps_tab);

    hr_utility.set_location(l_proc, 50);
    --
    -- add hrms responsibilities to created user.
    --
    per_ri_config_fnd_hr_entity.create_hrms_responsibility
                                   (p_configuration_code        => p_configuration_code
                                   ,p_security_profile_tab      => l_security_profile_tab
                                   ,p_technical_summary_mode    => p_technical_summary_mode
                                   ,p_hrms_resp_tab             => l_hrms_resp_tab);


    hr_utility.set_location(l_proc, 60);

    --
    -- add hrms misc responsibilities to created user.
    --
    per_ri_config_utilities.assign_misc_responsibility
                                   (p_configuration_code        => p_configuration_code
                                   ,p_technical_summary_mode    => p_technical_summary_mode
                                   ,p_hrms_misc_resp_tab        => l_hrms_misc_resp_tab);


    hr_utility.set_location(l_proc, 65);

    --
    -- Take Decision on the creation of flexfield structures
    --

    l_bg_count := 0;
    open csr_config_business_groups(p_configuration_code);
    loop
    fetch csr_config_business_groups into
               l_configuration_code,
               l_bg_country_name;
    if csr_config_business_groups%NOTFOUND then
      --close csr_config_business_groups;
      exit;
    end if;
      l_bg_count := l_bg_count + 1;
    end loop;
    close csr_config_business_groups;

    hr_utility.set_location('BG Count is : '|| l_bg_count, 45);


  IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
     AND l_enterprise_id IS NOT NULL AND l_bg_count=1 then
         hr_utility.set_location('No flex structures required', 11);
   ELSE

    per_ri_config_fnd_hr_entity.create_global_grp_cmp_cost_kf
                                  (p_configuration_code          => p_configuration_code
                                  ,p_technical_summary_mode      => p_technical_summary_mode
                                  ,p_kf_grp_tab                  => l_kf_grp_tab
                                  ,p_kf_cmp_tab                  => l_kf_cmp_tab
                                  ,p_kf_cost_tab                 => l_kf_cost_tab
                                  ,p_kf_grp_seg_tab              => l_kf_grp_seg_tab
                                  ,p_kf_cmp_seg_tab              => l_kf_cmp_seg_tab
                                  ,p_kf_cost_seg_tab             => l_kf_cost_seg_tab
                                  );
    hr_utility.set_location(l_proc, 70);


    --
    -- make decisions about job, positions and grades
    --

    --jobs/positions not defined
    if NOT l_job_defined and NOT l_pos_defined then
      hr_utility.trace('Jobs/Positions NOT defined');
      --
      -- create global jobs and positions
      --
      per_ri_config_fnd_hr_entity.create_global_job_pos_kf
                                  (p_configuration_code          => p_configuration_code
                                  ,p_technical_summary_mode      => p_technical_summary_mode
                                  ,p_kf_job_tab                  => l_kf_job_tab
                                  ,p_kf_pos_tab                  => l_kf_pos_tab
                                  ,p_kf_job_seg_tab              => l_kf_job_seg_tab
                                  ,p_kf_pos_seg_tab              => l_kf_pos_seg_tab
                                  );
      hr_utility.set_location(l_proc, 80);
    end if;

    --when positions not defined - this case comes when
    -- user has selected only job in RV section.

    if NOT l_pos_defined then
      hr_utility.trace('Positions NOT defined');
      --
      -- create global positions
      --
      per_ri_config_fnd_hr_entity.create_global_pos_kf
                                   (p_configuration_code       => p_configuration_code
                                   ,p_technical_summary_mode   => p_technical_summary_mode
                                   ,p_kf_pos_tab               => l_kf_pos_tab
                                   ,p_kf_pos_seg_tab           => l_kf_pos_seg_tab
                                   );
      hr_utility.set_location(l_proc, 85);
    end if;
    --grades are not defined
    if NOT l_grd_defined then
      hr_utility.trace('Grades NOT defined');
      --
      -- create global grades
      --
      per_ri_config_fnd_hr_entity.create_global_grd_kf
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_grd_tab                  => l_kf_grd_tab
                                   ,p_kf_grd_seg_tab              => l_kf_grd_seg_tab
                                   );
      hr_utility.set_location(l_proc, 90);
    end if;

    -- jobs defined (including RVs)
    if l_job_defined or l_jp_rv_defined then
      hr_utility.trace('Jobs defined');
      --
      -- create jobs with no rvs
      --
      per_ri_config_fnd_hr_entity.create_jobs_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_job_no_rv_tab            => l_kf_job_no_rv_tab
                                   ,p_kf_job_no_rv_seg_tab        => l_kf_job_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 100);
      -- create jobs with rvs
      --
      per_ri_config_fnd_hr_entity.create_jobs_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_job_rv_tab               => l_kf_job_rv_tab
                                   ,p_kf_job_rv_seg_tab           => l_kf_job_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 110);
    end if;

    -- Positions defined (including RVs)
    if l_pos_defined or (l_pos_defined and l_jp_rv_defined) then -- fix for 4522666
      hr_utility.trace('Positions IS defined');
      --
      -- create positions with no rvs
      --
      per_ri_config_fnd_hr_entity.create_positions_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_pos_no_rv_tab            => l_kf_pos_no_rv_tab
                                   ,p_kf_pos_no_rv_seg_tab        => l_kf_pos_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 120);
      --
      -- create positions with rvs
      --
      per_ri_config_fnd_hr_entity.create_positions_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_pos_rv_tab               => l_kf_pos_rv_tab
                                   ,p_kf_pos_rv_seg_tab           => l_kf_pos_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 130);
    end if;

    -- Grades defined (including RVs)
    if l_grd_defined or l_grd_rv_defined then
      hr_utility.trace('Grades IS defined');
      --
      -- create grades with no rvs
      --
      per_ri_config_fnd_hr_entity.create_grades_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_grd_no_rv_tab            => l_kf_grd_no_rv_tab
                                   ,p_kf_grd_no_rv_seg_tab        => l_kf_grd_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 140);
      --
      -- create grades with rvs
      --
      per_ri_config_fnd_hr_entity.create_grades_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_kf_grd_rv_tab               => l_kf_grd_rv_tab
                                   ,p_kf_grd_rv_seg_tab           => l_kf_grd_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 150);
    end if;

     -- Get Keyflex and Segments
    p_key_str_clob :=  per_ri_config_tech_summary.get_keyflex_structure_sql
                         (p_kf_job_tab                => l_kf_job_tab
                         ,p_kf_job_rv_tab             => l_kf_job_rv_tab
                         ,p_kf_job_no_rv_tab          => l_kf_job_no_rv_tab
                         ,p_kf_pos_tab                => l_kf_pos_tab
                         ,p_kf_pos_rv_tab             => l_kf_pos_rv_tab
                         ,p_kf_pos_no_rv_tab          => l_kf_pos_no_rv_tab
                         ,p_kf_grd_tab                => l_kf_grd_tab
                         ,p_kf_grd_rv_tab             => l_kf_grd_rv_tab
                         ,p_kf_grd_no_rv_tab          => l_kf_grd_no_rv_tab
                         ,p_kf_cmp_tab                => l_kf_cmp_tab
                         ,p_kf_grp_tab                => l_kf_grp_tab
                         ,p_kf_cost_tab               => l_kf_cost_tab
                         ,p_kf_job_str_clob           => l_kf_job_clob
                         ,p_kf_job_rv_str_clob        => l_kf_job_rv_clob
                         ,p_kf_job_no_rv_str_clob     => l_kf_job_no_rv_clob
                         ,p_kf_pos_str_clob           => l_kf_pos_clob
                         ,p_kf_pos_rv_str_clob        => l_kf_pos_rv_clob
                         ,p_kf_pos_no_rv_str_clob     => l_kf_pos_no_rv_clob
                         ,p_kf_cmp_str_clob           => l_kf_cmp_clob
                         ,p_kf_grd_str_clob           => l_kf_grd_clob
                         ,p_kf_grp_str_clob           => l_kf_grp_clob
                         ,p_kf_cost_str_clob          => l_kf_cost_clob
                         );


    p_key_seg_clob := per_ri_config_tech_summary.get_keyflex_segment_sql
                         (p_kf_job_seg_tab            => l_kf_job_seg_tab
                         ,p_kf_job_rv_seg_tab         => l_kf_job_rv_seg_tab
                         ,p_kf_job_no_rv_seg_tab      => l_kf_job_no_rv_seg_tab
                         ,p_kf_pos_seg_tab            => l_kf_pos_seg_tab
                         ,p_kf_pos_rv_seg_tab         => l_kf_pos_rv_seg_tab
                         ,p_kf_pos_no_rv_seg_tab      => l_kf_pos_no_rv_seg_tab
                         ,p_kf_grd_seg_tab            => l_kf_grd_seg_tab
                         ,p_kf_grd_rv_seg_tab         => l_kf_grd_rv_seg_tab
                         ,p_kf_grd_no_rv_seg_tab      => l_kf_grd_no_rv_seg_tab
                         ,p_kf_grp_seg_tab            => l_kf_grp_seg_tab
                         ,p_kf_cmp_seg_tab            => l_kf_cmp_seg_tab
                         ,p_kf_cost_seg_tab           => l_kf_cost_seg_tab
                         ,p_kf_job_seg_clob           => l_kf_job_seg_clob
                         ,p_kf_job_rv_seg_clob        => l_kf_job_rv_seg_clob
                         ,p_kf_job_no_rv_seg_clob     => l_kf_job_no_rv_seg_clob
                         ,p_kf_pos_seg_clob           => l_kf_pos_seg_clob
                         ,p_kf_pos_rv_seg_clob        => l_kf_pos_rv_seg_clob
                         ,p_kf_pos_no_rv_seg_clob     => l_kf_pos_no_rv_seg_clob
                         ,p_kf_grd_seg_clob           => l_kf_grd_seg_clob
                         ,p_kf_grd_rv_seg_clob        => l_kf_grd_rv_seg_clob
                         ,p_kf_grd_no_rv_seg_clob     => l_kf_grd_no_rv_seg_clob
                         ,p_kf_grp_seg_clob           => l_kf_grp_seg_clob
                         ,p_kf_cmp_seg_clob           => l_kf_cmp_seg_clob
                         ,p_kf_cost_seg_clob          => l_kf_cost_seg_clob
                          );

    p_kf_job_str_clob         := l_kf_job_clob;
    p_kf_pos_str_clob         := l_kf_pos_clob;
    p_kf_pos_rv_str_clob      := l_kf_pos_rv_clob;
    p_kf_pos_no_rv_str_clob   := l_kf_pos_no_rv_clob;
    p_kf_grd_str_clob         := l_kf_grd_clob;
    p_kf_cmp_str_clob         := l_kf_cmp_clob;
    p_kf_grp_str_clob         := l_kf_grp_clob;
    p_kf_cost_str_clob        := l_kf_cost_clob;
    p_kf_job_seg_clob         := l_kf_job_seg_clob;
    p_kf_job_rv_seg_clob      := l_kf_job_rv_seg_clob;
    p_kf_job_no_rv_seg_clob   := l_kf_job_no_rv_seg_clob;
    p_kf_pos_seg_clob         := l_kf_pos_seg_clob;
    p_kf_pos_rv_seg_clob      := l_kf_pos_rv_seg_clob;
    p_kf_pos_no_rv_seg_clob   := l_kf_pos_no_rv_seg_clob;
    p_kf_grd_seg_clob         := l_kf_grd_seg_clob;
    p_kf_grd_no_rv_seg_clob   := l_kf_grd_no_rv_seg_clob;
    p_kf_grd_rv_seg_clob      := l_kf_grd_rv_seg_clob;
    p_kf_grp_seg_clob         := l_kf_grp_seg_clob;
    p_kf_cmp_seg_clob         := l_kf_cmp_seg_clob;
    p_kf_cost_seg_clob        := l_kf_cost_seg_clob;

    hr_utility.set_location(l_proc, 170);

  END IF;
    --
    -- create locations
    --
    per_ri_config_datapump_entity.create_locations_batch_lines
                                       (p_configuration_code           => p_configuration_code
                                       ,p_batch_header_id              => l_batch_header_id
                                       ,p_technical_summary_mode       => p_technical_summary_mode
                                       ,p_location_tab                 => l_location_tab
                                       );

    p_location_clob := per_ri_config_tech_summary.get_locations_sql (p_location_tab => l_location_tab) ;


    hr_utility.set_location(l_proc, 180);


    --
    -- create business groups
    --
    per_ri_config_datapump_entity.create_bg_batch_lines
                                (p_batch_header_id           => l_batch_header_id
                                ,p_configuration_code        => p_configuration_code
                                ,p_country_tab_out           => l_country_tab
                                ,p_technical_summary_mode    => p_technical_summary_mode
                                ,p_bg_tab                    => l_bg_tab
                                ,p_sg_tab                    => l_sg_tab
                                ,p_post_install_tab          => l_post_install_tab
                                ,p_int_bg_resp_tab           => l_int_bg_resp_tab);

    p_bg_clob := per_ri_config_tech_summary.get_business_grp_sql (p_business_grp_tab => l_bg_tab);

    p_sg_clob:=  per_ri_config_tech_summary.get_security_profile_sql(
                                       p_security_profile_tab => l_sg_tab
                                     );
    p_post_install_clob :=  per_ri_config_tech_summary.get_post_install_sql(
                                        p_post_install_tab        =>l_post_install_tab
                                     );
    hr_utility.set_location(l_proc, 190);
    --
    -- create enterprise orgs and related classifications
    --
    per_ri_config_datapump_entity.create_enterprise_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => p_technical_summary_mode
                                        ,p_org_ent_tab                 => l_org_ent_tab
                                        ,p_org_ent_class_tab           => l_org_ent_class_tab
                                        ,p_org_hierarchy_tab           => l_org_hierarchy_tab
                                        ,p_profile_dpe_ent_tab       => l_profile_dpe_ent_tab);


    p_org_hierarchy_clob := per_ri_config_tech_summary.get_org_hierarchy_sql(
                                        p_org_hierarchy_tab  => l_org_hierarchy_tab
                                        );

    p_site_profile_clob := per_ri_config_tech_summary.get_profile_sql (
                                         p_profile_tab          => l_profile_tab
                                        ,p_profile_dpe_ent_tab  => l_profile_dpe_ent_tab
                                        );
    hr_utility.set_location(l_proc, 200);

    --
    -- create operating companies orgs and related classifications
    --
    per_ri_config_datapump_entity.create_oper_comp_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => p_technical_summary_mode
                                        ,p_org_oc_tab                  =>  l_org_oc_tab
                                        ,p_org_oc_class_tab            => l_org_oc_class_tab
                                        ,p_org_hierarchy_ele_oc_tab    => l_org_hierarchy_ele_oc_tab);
    hr_utility.set_location(l_proc, 200);
    hr_utility.set_location(l_proc, 210);

    --
    -- create legal entities orgs and related classifications
    --
    per_ri_config_datapump_entity.create_le_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => p_technical_summary_mode
                                        ,p_org_le_tab                  =>  l_org_le_tab
                                        ,p_org_le_class_tab            => l_org_le_class_tab
                                        ,p_org_hierarchy_ele_le_tab    => l_org_hierarchy_ele_le_tab);

    hr_utility.set_location(l_proc, 220);

    p_organization_clob := per_ri_config_tech_summary.get_org_sql
                                        (p_org_ent_tab           => l_org_ent_tab
                                        ,p_org_oc_tab            => l_org_oc_tab
                                        ,p_org_le_tab            => l_org_le_tab);

    p_org_class_clob  := per_ri_config_tech_summary.get_org_class_sql
                                        (p_org_ent_class_tab     => l_org_ent_class_tab
                                        ,p_org_oc_class_tab      => l_org_oc_class_tab
                                        ,p_org_le_class_tab      => l_org_le_class_tab
                                        );
    p_org_class_for_pv_clob := per_ri_config_tech_summary.get_org_class_sql_for_pv
                                        (p_org_ent_tab           => l_org_ent_tab
                                        ,p_org_oc_tab            => l_org_oc_tab
                                        ,p_org_le_tab            => l_org_le_tab
                                        ,p_org_ent_class_tab     => l_org_ent_class_tab
                                        ,p_org_oc_class_tab      => l_org_oc_class_tab
                                        ,p_org_le_class_tab      => l_org_le_class_tab
                                        );

    p_org_hierarchy_ele_clob :=  per_ri_config_tech_summary.get_org_hierarchy_ele_sql (
                                     p_org_hierarchy_ele_oc_tab  =>  l_org_hierarchy_ele_oc_tab
                                    ,p_org_hierarchy_ele_le_tab  => l_org_hierarchy_ele_le_tab
                                  );

    p_org_hier_ele_for_pv_clob := per_ri_config_tech_summary.get_org_hier_ele_sql_for_pv (
                                     p_org_hierarchy_ele_oc_tab  =>  l_org_hierarchy_ele_oc_tab
                                    ,p_org_hierarchy_ele_le_tab  => l_org_hierarchy_ele_le_tab
                                  );


    p_str_seg_for_pv_clob := per_ri_config_tech_summary.get_keyflex_str_seg_sql_for_pv
                                  (p_kf_job_tab                  => l_kf_job_tab
				  ,p_kf_job_rv_tab 		 => l_kf_job_rv_tab
				  ,p_kf_job_no_rv_tab 	         => l_kf_job_no_rv_tab
				  ,p_kf_pos_tab 		 => l_kf_pos_tab
				  ,p_kf_pos_rv_tab 		 => l_kf_pos_rv_tab
				  ,p_kf_pos_no_rv_tab 		 => l_kf_pos_no_rv_tab
				  ,p_kf_grd_tab 		 => l_kf_grd_tab
				  ,p_kf_grd_rv_tab 		 => l_kf_grd_rv_tab
				  ,p_kf_grd_no_rv_tab 		 => l_kf_grd_no_rv_tab
				  ,p_kf_cmp_tab 		 => l_kf_cmp_tab
				  ,p_kf_grp_tab 		 => l_kf_grp_tab
				  ,p_kf_cost_tab 		 => l_kf_cost_tab
				  ,p_kf_job_seg_tab 		 => l_kf_job_seg_tab
                                  ,p_kf_job_rv_seg_tab           => l_kf_job_rv_seg_tab
                                  ,p_kf_job_no_rv_seg_tab 	 => l_kf_job_no_rv_seg_tab
                                  ,p_kf_pos_seg_tab              => l_kf_pos_seg_tab
                                  ,p_kf_pos_rv_seg_tab           => l_kf_pos_rv_seg_tab
                                  ,p_kf_pos_no_rv_seg_tab 	 => l_kf_pos_no_rv_seg_tab
                                  ,p_kf_grd_seg_tab              => l_kf_grd_seg_tab
                                  ,p_kf_grd_rv_seg_tab           => l_kf_grd_rv_seg_tab
                                  ,p_kf_grd_no_rv_seg_tab        => l_kf_grd_no_rv_seg_tab
                                  ,p_kf_grp_seg_tab              => l_kf_grp_seg_tab
                                  ,p_kf_cmp_seg_tab              => l_kf_cmp_seg_tab
                                  ,p_kf_cost_seg_tab             => l_kf_cost_seg_tab
				  );

    hr_utility.set_location(l_proc, 230);

    per_ri_config_utilities.create_more_hrms_resps
            (p_configuration_code         => p_configuration_code
            ,p_security_profile_tab       => l_security_profile_tab
            ,p_int_bg_resp_tab            => l_int_bg_resp_tab
            ,p_technical_summary_mode     => p_technical_summary_mode
            ,p_hrms_resp_main_tab         => l_hrms_resp_main_tab
            ,p_more_profile_resp_tab      => l_more_profile_resp_tab
            ,p_more_int_profile_resp_tab  => l_more_int_profile_resp_tab);

    if l_more_profile_resp_tab.count > 0 THEN
       p_profile_resp_clob := per_ri_config_tech_summary.get_profile_resp_sql(l_more_profile_resp_tab);
    end if;

    p_resp_clob := per_ri_config_tech_summary.get_resp_sql
                                   (p_resp_tab                  =>l_resp_tab
                                   ,p_hrms_resp_tab             =>l_hrms_resp_main_tab
                                   ,p_hrms_misc_resp_tab        =>l_hrms_resp_tab);

    -- Security Group Removal Chnages
    --per_ri_config_utilities.create_security_profile_assign
    --            (p_security_profile_tab                      =>  l_security_profile_tab);

    hr_utility.set_location(' Leaving:'|| l_proc, 250);

    per_ri_config_utilities.submit_int_payroll_request
                (errbuf                      => l_errbuf
                ,retcode                     => l_retcode
                ,p_country_tab               => l_country_tab
                ,p_technical_summary_mode    => p_technical_summary_mode
                ,p_int_hrms_setup_tab        => l_int_hrms_setup_tab
                );

    p_int_hrms_clob := per_ri_config_tech_summary.get_int_hrms_setup_sql
                                  (p_int_hrms_setup_tab      => l_int_hrms_setup_tab);

    hr_utility.set_location(l_proc, 240);

    rollback;

    hr_utility.trace('Ending Time = ' || to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS'));
    hr_utility.set_location(' Leaving:'|| l_proc, 300);

  EXCEPTION
    --when not_fresh_install then
    --per_ri_config_utilities.write_log(p_message => l_log_message);
      --raise;
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_technical_summary;


  PROCEDURE load_enterprise_configuration (p_errbuff                out nocopy varchar2
                                          ,p_retcode                out nocopy number
                                          ,p_configuration_code     in varchar2) IS

  cursor csr_bg_ids(c_batch_id in number) IS
    select unique_key_id from hr_pump_batch_line_user_keys
      where batch_line_id in (select batch_line_id from hr_pump_batch_lines
        where batch_id = c_batch_id and api_module_id = (select api_module_id
         from hr_api_modules where module_name = 'CREATE_BUSINESS_GROUP'));

    cursor csr_config_business_groups(cp_configuration_code in varchar2) IS
    select distinct configuration_code,
           per_ri_config_utilities.business_group_decision(configuration_code,country_code)
      from per_ri_config_country_v
     where configuration_code = cp_configuration_code;


  l_proc                          varchar2(72) := g_package || 'load_enterprise_configuration';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_batch_header_id               number(15);
  l_batch_name                    hr_pump_batch_headers.batch_name%type;
  l_errbuf                        varchar2(240);
  l_retcode                       number(15);
  l_job_defined                   boolean default FALSE;
  l_pos_defined                   boolean default FALSE;
  l_grd_defined                   boolean default FALSE;

  l_jp_rv_defined                 boolean default FALSE;
  l_grd_rv_defined                boolean default FALSE;
  l_country_tab                   per_ri_config_datapump_entity.country_tab;
  l_security_profile_tab          per_ri_config_fnd_hr_entity.security_profile_tab;
  l_int_bg_resp_tab               per_ri_config_fnd_hr_entity.int_bg_resp_tab;

  l_errbuf_msg                    varchar2(240);
  l_retcode_msg                   number(15);
  l_fresh_installed               boolean;
  l_data_pump_exception           boolean;

  l_enterprise_short_name         per_ri_config_information.config_information1%type;
  not_fresh_install               EXCEPTION;
  data_pump_load_failure          EXCEPTION;

  l_technical_summary_mode        boolean default false;
  l_user_tab                      per_ri_config_tech_summary.user_tab;
  l_resp_tab                      per_ri_config_tech_summary.resp_tab;
  l_hrms_resp_tab                 per_ri_config_tech_summary.hrms_resp_tab;
  l_hrms_misc_resp_tab            per_ri_config_tech_summary.hrms_misc_resp_tab;
  l_profile_tab                   per_ri_config_tech_summary.profile_tab;
  l_profile_apps_tab              per_ri_config_tech_summary.profile_apps_tab;
  l_profile_dpe_ent_tab           per_ri_config_tech_summary.profile_dpe_ent_tab;

  l_location_tab                  per_ri_config_tech_summary.location_tab;
  l_bg_tab                        per_ri_config_tech_summary.bg_tab;
  l_sg_tab                        per_ri_config_tech_summary.sg_tab;
  l_post_install_tab              per_ri_config_tech_summary.post_install_tab;
  l_org_ent_tab                   per_ri_config_tech_summary.org_ent_tab;
  l_org_hierarchy_tab             per_ri_config_tech_summary.org_hierarchy_tab;
  l_org_hierarchy_ele_oc_tab      per_ri_config_tech_summary.org_hierarchy_ele_oc_tab;
  l_org_hierarchy_ele_le_tab      per_ri_config_tech_summary.org_hierarchy_ele_le_tab;
  l_org_oc_tab                    per_ri_config_tech_summary.org_oc_tab;
  l_org_le_tab                    per_ri_config_tech_summary.org_le_tab;
  l_org_ent_class_tab             per_ri_config_tech_summary.org_ent_class_tab;
  l_org_oc_class_tab              per_ri_config_tech_summary.org_oc_class_tab;
  l_org_le_class_tab              per_ri_config_tech_summary.org_le_class_tab;
  l_kf_job_tab                    per_ri_config_tech_summary.kf_job_tab;
  l_kf_pos_tab                    per_ri_config_tech_summary.kf_pos_tab;
  l_kf_grd_tab                    per_ri_config_tech_summary.kf_grd_tab;
  l_kf_job_seg_tab                per_ri_config_tech_summary.kf_job_seg_tab;
  l_kf_pos_seg_tab                per_ri_config_tech_summary.kf_pos_seg_tab;
  l_kf_grd_seg_tab                per_ri_config_tech_summary.kf_grd_seg_tab;
  l_kf_grp_tab                    per_ri_config_tech_summary.kf_grp_tab;
  l_kf_cmp_tab                    per_ri_config_tech_summary.kf_cmp_tab;
  l_kf_cost_tab                   per_ri_config_tech_summary.kf_cost_tab;
  l_kf_grp_seg_tab                per_ri_config_tech_summary.kf_grp_seg_tab;
  l_kf_cmp_seg_tab                per_ri_config_tech_summary.kf_cmp_seg_tab;
  l_kf_cost_seg_tab               per_ri_config_tech_summary.kf_cost_seg_tab;
  l_kf_job_no_rv_tab              per_ri_config_tech_summary.kf_job_no_rv_tab;
  l_kf_job_no_rv_seg_tab          per_ri_config_tech_summary.kf_job_no_rv_seg_tab;
  l_kf_job_rv_tab                 per_ri_config_tech_summary.kf_job_rv_tab;
  l_kf_job_rv_seg_tab             per_ri_config_tech_summary.kf_job_rv_seg_tab;
  l_kf_pos_no_rv_tab              per_ri_config_tech_summary.kf_pos_no_rv_tab;
  l_kf_pos_no_rv_seg_tab          per_ri_config_tech_summary.kf_pos_no_rv_seg_tab;
  l_kf_pos_rv_tab                 per_ri_config_tech_summary.kf_pos_rv_tab;
  l_kf_pos_rv_seg_tab             per_ri_config_tech_summary.kf_pos_rv_seg_tab;
  l_kf_grd_no_rv_tab              per_ri_config_tech_summary.kf_grd_no_rv_tab;
  l_kf_grd_no_rv_seg_tab          per_ri_config_tech_summary.kf_grd_no_rv_seg_tab;
  l_kf_grd_rv_tab                 per_ri_config_tech_summary.kf_grd_rv_tab;
  l_kf_grd_rv_seg_tab             per_ri_config_tech_summary.kf_grd_rv_seg_tab;
  l_int_hrms_setup_tab            per_ri_config_tech_summary.int_hrms_setup_tab;

  l_more_profile_resp_tab         per_ri_config_tech_summary.profile_resp_tab;
  l_more_int_profile_resp_tab     per_ri_config_tech_summary.profile_resp_tab;
  l_hrms_resp_main_tab            per_ri_config_tech_summary.hrms_resp_tab;

  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  l_bg_id                         number(10);
  l_label                         varchar2(50);
  l_old_sec_group_id              number(10);
  l_enterprise_id                 number(10);
  l_err_buf                       varchar2(4000);
  l_ret_code                      number(10);
  l_configuration_code            varchar2(50);
  l_bg_country_name               varchar2(50);
  l_bg_count                      number(10);

  PRAGMA Exception_Init(not_fresh_install, -20001);
  PRAGMA Exception_Init(data_pump_load_failure, -20002);

  BEGIN


    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace('Starting Time = ' || to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS'));

    --Check Whether multiTenancy is enabled or not
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
    hr_utility.set_location('Enterprise Id is ' || l_enterprise_id, 78);
    hr_utility.set_location('BEFORE SEC GROUP ID IS : '||fnd_global.security_group_id, 78);
    l_old_sec_group_id := fnd_global.security_group_id;
    BEGIN
     select 'C::'||enterprise_label into l_label from per_ent_security_groups
     where security_group_id = fnd_global.security_group_id;
    hr_utility.set_location('Sec Group Id is '||fnd_global.security_group_id, 100)   ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_label := null;
    END;


    -- Check if this database is freshly installed
    l_fresh_installed := per_ri_config_utilities.check_fresh_installation;

    if NOT l_fresh_installed
          and fnd_profile.value('PER_RI_LOAD_OVERRIDE') = 'N' then

      l_log_message := '<<----------------------ATTENTION------------------------------>>';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      l_log_message := 'This database got some entities setup done after it is freshly installed';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      l_log_message := 'Loader Program Can not Continue';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      l_log_message := 'Exiting...' ;
      per_ri_config_utilities.write_log(p_message => l_log_message);

      l_log_message := '<<----------------------ATTENTION------------------------------>>';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      raise not_fresh_install;
    end if;

    -- Check PER_RI_LOAD_OVERRIDE
    if  fnd_profile.value('PER_RI_LOAD_OVERRIDE') = 'Y'
         and NOT l_fresh_installed then
      l_log_message := 'This database got some entities setup done after it is freshly installed';
      l_log_message := l_log_message || '..Some of the entities loading might fail';
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);

    l_job_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'JOB');

    l_pos_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'POSITION');

    l_grd_defined := per_ri_config_utilities.jpg_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_seg_type            => 'GRADE');

    l_jp_rv_defined    :=  per_ri_config_utilities.regional_variance_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_rv_type             => 'JP');

    l_grd_rv_defined    :=  per_ri_config_utilities.regional_variance_defined
                            (p_configuration_code  => p_configuration_code
                            ,p_rv_type             => 'GRD');

    hr_utility.set_location(l_proc, 20);

    -- populate enterprise short name global variable
    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);
    --

    --
    -- create HRMS_USER super user
    --


    per_ri_config_fnd_def_entity.create_user(p_technical_summary_mode  => l_technical_summary_mode
                                            ,p_user_tab                => l_user_tab);

    --
    -- attach default responsibility
    --
    per_ri_config_fnd_def_entity.attach_default_responsibility
                                  (p_configuration_code       => p_configuration_code
                                  ,p_technical_summary_mode => l_technical_summary_mode
                                  ,p_resp_tab => l_resp_tab
                                  );
    hr_utility.set_location(l_proc, 40);

    --
    -- set site level profile options
    --
    per_ri_config_fnd_def_entity.create_site_profile_options
                                   (p_configuration_code       => p_configuration_code
                                   ,p_technical_summary_mode   => l_technical_summary_mode
                                   ,p_profile_tab              => l_profile_tab);

    --
    -- set aplication level profile options
    --
    per_ri_config_fnd_hr_entity.create_application_level_resp
                                   (p_configuration_code        => p_configuration_code
                                   ,p_technical_summary_mode    => l_technical_summary_mode
                                   ,p_profile_apps_tab          => l_profile_apps_tab);
    hr_utility.set_location(l_proc, 50);
    --
    -- add hrms responsibilities to created user.
    --
    per_ri_config_fnd_hr_entity.create_hrms_responsibility
                                   (p_configuration_code        => p_configuration_code
                                   ,p_security_profile_tab      => l_security_profile_tab
                                   ,p_technical_summary_mode    => l_technical_summary_mode
                                   ,p_hrms_resp_tab             => l_hrms_resp_tab);

    hr_utility.set_location(l_proc, 60);

    --
    -- add hrms misc responsibilities to created user.
    --
    per_ri_config_utilities.assign_misc_responsibility
                                   (p_configuration_code        => p_configuration_code
                                   ,p_technical_summary_mode    => l_technical_summary_mode
                                   ,p_hrms_misc_resp_tab        => l_hrms_misc_resp_tab);


    hr_utility.set_location(l_proc, 65);

    --
    --  Take Decision on the creation of flexfields
    --

    l_bg_count := 0;
    open csr_config_business_groups(p_configuration_code);
    loop
    fetch csr_config_business_groups into
               l_configuration_code,
               l_bg_country_name;

    exit when csr_config_business_groups%NOTFOUND;
      l_bg_count := l_bg_count + 1;
    end loop;
    close csr_config_business_groups;
    hr_utility.set_location('BG Count is : '|| l_bg_count, 45);

   IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
     AND l_enterprise_id IS NOT NULL AND l_bg_count=1 then
         hr_utility.set_location('No flex structures required', 11);
   ELSE

    per_ri_config_fnd_hr_entity.create_global_grp_cmp_cost_kf
                                  (p_configuration_code          => p_configuration_code
                                  ,p_technical_summary_mode      => l_technical_summary_mode
                                  ,p_kf_grp_tab                  => l_kf_grp_tab
                                  ,p_kf_cmp_tab                  => l_kf_cmp_tab
                                  ,p_kf_cost_tab                 => l_kf_cost_tab
                                  ,p_kf_grp_seg_tab              => l_kf_grp_seg_tab
                                  ,p_kf_cmp_seg_tab              => l_kf_cmp_seg_tab
                                  ,p_kf_cost_seg_tab             => l_kf_cost_seg_tab
                                  );

    hr_utility.set_location(l_proc, 70);


    --
    -- make decisions about job, positions and grades
    --

    --jobs/positions not defined
    if NOT l_job_defined and NOT l_pos_defined then
      hr_utility.trace('Jobs/Positions NOT defined');
      --
      -- create global jobs and positions
      --
      per_ri_config_fnd_hr_entity.create_global_job_pos_kf
                                  (p_configuration_code          => p_configuration_code
                                  ,p_technical_summary_mode      => l_technical_summary_mode
                                  ,p_kf_job_tab                  => l_kf_job_tab
                                  ,p_kf_pos_tab                  => l_kf_pos_tab
                                  ,p_kf_job_seg_tab              => l_kf_job_seg_tab
                                  ,p_kf_pos_seg_tab              => l_kf_pos_seg_tab
                                  );
      hr_utility.set_location(l_proc, 80);
    end if;

    --when positions not defined - this case comes when
    --user has selected only job in RV section.

    if NOT l_pos_defined then
      hr_utility.trace('Positions NOT defined');
      --
      -- create global positions
      --
      per_ri_config_fnd_hr_entity.create_global_pos_kf
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_pos_tab                  => l_kf_pos_tab
                                   ,p_kf_pos_seg_tab              => l_kf_pos_seg_tab
                                   );
      hr_utility.set_location(l_proc, 85);
    end if;
    --grades are not defined
    if NOT l_grd_defined then
      hr_utility.trace('Grades NOT defined');
      --
      -- create global grades
      --
      per_ri_config_fnd_hr_entity.create_global_grd_kf
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_grd_tab                  => l_kf_grd_tab
                                   ,p_kf_grd_seg_tab              => l_kf_grd_seg_tab
                                   );
      hr_utility.set_location(l_proc, 90);
    end if;

    -- jobs defined (including RVs)
    if l_job_defined or l_jp_rv_defined then
      hr_utility.trace('Jobs defined');
      --
      -- create jobs with no rvs
      --
      per_ri_config_fnd_hr_entity.create_jobs_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_job_no_rv_tab            => l_kf_job_no_rv_tab
                                   ,p_kf_job_no_rv_seg_tab        => l_kf_job_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 100);
      -- create jobs with rvs
      --
      per_ri_config_fnd_hr_entity.create_jobs_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_job_rv_tab               => l_kf_job_rv_tab
                                   ,p_kf_job_rv_seg_tab           => l_kf_job_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 110);
    end if;

    -- Positions defined (including RVs)
    if l_pos_defined or (l_pos_defined and l_jp_rv_defined) then -- fix for 4522666
      hr_utility.trace('Positions IS defined');
      --
      -- create positions with no rvs
      --
      per_ri_config_fnd_hr_entity.create_positions_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_pos_no_rv_tab            => l_kf_pos_no_rv_tab
                                   ,p_kf_pos_no_rv_seg_tab        => l_kf_pos_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 120);
      --
      -- create positions with rvs
      --
      per_ri_config_fnd_hr_entity.create_positions_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_pos_rv_tab               => l_kf_pos_rv_tab
                                   ,p_kf_pos_rv_seg_tab           => l_kf_pos_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 130);

    end if;

    -- Grades defined (including RVs)
    if l_grd_defined or l_grd_rv_defined then
      hr_utility.trace('Grades IS defined');
      --
      -- create grades with no rvs
      --
      per_ri_config_fnd_hr_entity.create_grades_no_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_grd_no_rv_tab            => l_kf_grd_no_rv_tab
                                   ,p_kf_grd_no_rv_seg_tab        => l_kf_grd_no_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 140);
      --
      -- create grades with rvs
      --
      per_ri_config_fnd_hr_entity.create_grades_rv_keyflex
                                   (p_configuration_code          => p_configuration_code
                                   ,p_technical_summary_mode      => l_technical_summary_mode
                                   ,p_kf_grd_rv_tab               => l_kf_grd_rv_tab
                                   ,p_kf_grd_rv_seg_tab           => l_kf_grd_rv_seg_tab
                                   );
      hr_utility.set_location(l_proc, 150);
    end if;
    END IF;


    --
    -- create batch header
    l_batch_name      := substr(p_configuration_code || ' ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),1,80);

    hr_utility.set_location(l_proc, 160);
    l_batch_header_id := hr_pump_utils.create_batch_header
                                   (p_batch_name => l_batch_name);
    hr_utility.set_location(l_batch_name, 1990);
    hr_utility.set_location(l_batch_header_id, 2000);
    hr_utility.set_location(l_proc, 170);
    --
    -- create locations
    --
    per_ri_config_datapump_entity.create_locations_batch_lines
                                       (p_configuration_code           => p_configuration_code
                                       ,p_batch_header_id              => l_batch_header_id
                                       ,p_technical_summary_mode       => l_technical_summary_mode
                                       ,p_location_tab                 => l_location_tab
                                       );
    hr_utility.set_location(l_proc, 180);

   IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
     AND l_enterprise_id IS NOT NULL
      THEN
    hr_utility.set_location('DP is getting run before hand ', 76);
    BEGIN
      --
      -- run data pump to load hrms entities into schema
      --
      hr_data_pump.main (errbuf             => l_errbuf
                        ,retcode            => l_retcode
                        ,p_batch_id         => l_batch_header_id
                        ,p_validate         => 'N'
                        ,p_pap_group_id     => null);

      l_data_pump_exception := per_ri_config_utilities.check_data_pump_exception(p_patch_header_id  => l_batch_header_id);
      if l_data_pump_exception then
        per_ri_config_utilities.write_data_pump_exception_log(p_patch_header_id  => l_batch_header_id);
        raise data_pump_load_failure;
      end if;

    EXCEPTION
      when data_pump_load_failure then
        hr_utility.set_location(l_proc, 221);
        hr_utility.raise_error;
        commit;
      when others then
        hr_utility.set_location(l_proc, 222);
        p_errbuff     :=  'Error cooured in loading datapump records';
        p_retcode     :=  2;

        l_error_message := 'Error in ' || l_proc;
        --hr_utility.trace(l_error_message || '-' || sqlerrm);
        hr_utility.set_location(' Leaving:'|| l_proc, 500);
        hr_utility.raise_error;
        commit;
    END;

    l_batch_name      := substr(p_configuration_code || 'second' || ' ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),1,80);

    hr_utility.set_location(l_proc, 160);
    l_batch_header_id := hr_pump_utils.create_batch_header
                                   (p_batch_name => l_batch_name);

  END IF;


    --
    -- create business groups
    --

    per_ri_config_datapump_entity.create_bg_batch_lines
                                (p_batch_header_id           => l_batch_header_id
                                ,p_configuration_code        => p_configuration_code
                                ,p_country_tab_out           => l_country_tab
                                ,p_technical_summary_mode    => l_technical_summary_mode
                                ,p_bg_tab                    => l_bg_tab
                                ,p_sg_tab                    => l_sg_tab
                                ,p_post_install_tab          => l_post_install_tab
                                ,p_int_bg_resp_tab           => l_int_bg_resp_tab);

    hr_utility.set_location(l_proc, 190);

   IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
     AND l_enterprise_id IS NOT NULL
      THEN
    hr_utility.set_location('DP is getting run before hand ', 76);
    BEGIN
      hr_multi_tenancy_pkg.set_context('ENT');
      --
      -- run data pump to load hrms entities into schema
      --
      hr_data_pump.main (errbuf             => l_errbuf
                        ,retcode            => l_retcode
                        ,p_batch_id         => l_batch_header_id
                        ,p_validate         => 'N'
                        ,p_pap_group_id     => null);

      l_data_pump_exception := per_ri_config_utilities.check_data_pump_exception(p_patch_header_id  => l_batch_header_id);
      if l_data_pump_exception then
        per_ri_config_utilities.write_data_pump_exception_log(p_patch_header_id  => l_batch_header_id);
        raise data_pump_load_failure;
      end if;

    EXCEPTION
      when data_pump_load_failure then
        hr_utility.set_location(l_proc, 221);
        hr_utility.raise_error;
        commit;
      when others then
        hr_utility.set_location(l_proc, 222);
        p_errbuff     :=  'Error cooured in loading datapump records';
        p_retcode     :=  2;

        l_error_message := 'Error in ' || l_proc;
        --hr_utility.trace(l_error_message || '-' || sqlerrm);
        hr_utility.set_location(' Leaving:'|| l_proc, 500);
        hr_utility.raise_error;
        commit;
    END;


    hr_utility.set_location('Sec Group Id is '||fnd_global.security_group_id, 100);

    open csr_bg_ids(l_batch_header_id);
    loop
    fetch csr_bg_ids into
               l_bg_id;
    exit when csr_bg_ids%NOTFOUND;


EXECUTE IMMEDIATE 'begin hr_multi_tenant_install.initialize_orgs(errbuf  =>  :1
                                           ,retcode => :2
                                           ,p_enterprise_id => :3
                                           ,p_organization_id => :4); end;'
                      USING out l_err_buf, out l_ret_code, l_enterprise_id, l_bg_id;


    hr_utility.set_location('The label method has been called ', 90);

--     BEGIN
--        hr_utility.set_location('Before the first execute', 10);
--        EXECUTE IMMEDIATE 'UPDATE hr_all_organization_units
--                         SET    hr_enterprise = char_to_label(''HR_ENTERPRISE_POLICY'', :1)
--                       WHERE  organization_id = :2'
--                       USING l_label, l_bg_id;
--        hr_utility.set_location('After the first execute', 10);
--
--        EXECUTE Immediate 'UPDATE hr_organization_information
--                        SET hr_enterprise = char_to_label(''HR_ENTERPRISE_POLICY'',:1 )
--                      WHERE organization_id = :2'
--                      USING l_label
--                           ,l_bg_id;
--        hr_utility.set_location('After the second execute', 10);
--        EXECUTE IMMEDIATE 'UPDATE    per_number_generation_controls
--                         SET    hr_enterprise = char_to_label(''HR_ENTERPRISE_POLICY'', :1)
--                       WHERE    business_group_id = :2'
--                       USING    l_label
--  			       ,l_bg_id;
--        hr_utility.set_location('After the third execute', 10);
--        EXECUTE IMMEDIATE 'UPDATE hr_all_organization_units_tl
--                         SET    hr_enterprise = char_to_label(''HR_ENTERPRISE_POLICY'', :1)
--                       WHERE  organization_id = :2'
--                       USING l_label, l_bg_id;
--        hr_utility.set_location('After the fourth execute', 10);
--     END;

    end loop;
    close csr_bg_ids;

    /*fnd_global.set_security_group_id_context(security_group_id
                                            => l_old_sec_group_id);*/
    hr_multi_tenancy_pkg.set_context(l_label);
    hr_utility.set_location('After change the Sec group id is : ' ||
                        fnd_global.security_group_id, 90);

    l_batch_name      := substr(p_configuration_code || 'third' || ' ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'),1,80);

    hr_utility.set_location(l_proc, 160);
    l_batch_header_id := hr_pump_utils.create_batch_header
                                   (p_batch_name => l_batch_name);
    hr_utility.set_location(l_batch_name, 1990);
    hr_utility.set_location(l_batch_header_id, 2000);
    hr_utility.set_location(l_proc, 170);

END IF;
    --
    -- create enterprise orgs and related classifications
    --
    per_ri_config_datapump_entity.create_enterprise_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => l_technical_summary_mode
                                        ,p_org_ent_tab                 => l_org_ent_tab
                                        ,p_org_ent_class_tab           => l_org_ent_class_tab
                                        ,p_org_hierarchy_tab           => l_org_hierarchy_tab
                                        ,p_profile_dpe_ent_tab       => l_profile_dpe_ent_tab);
    hr_utility.set_location(l_proc, 200);



    --
    -- create operating companies orgs and related classifications
    --
    per_ri_config_datapump_entity.create_oper_comp_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => l_technical_summary_mode
                                        ,p_org_oc_tab                  =>  l_org_oc_tab
                                        ,p_org_oc_class_tab            => l_org_oc_class_tab
                                        ,p_org_hierarchy_ele_oc_tab    => l_org_hierarchy_ele_oc_tab);
    hr_utility.set_location(l_proc, 210);

    --
    -- create legal entities orgs and related classifications
    --
    per_ri_config_datapump_entity.create_le_batch_lines
                                        (p_configuration_code          => p_configuration_code
                                        ,p_batch_header_id             => l_batch_header_id
                                        ,p_technical_summary_mode      => l_technical_summary_mode
                                        ,p_org_le_tab                  =>  l_org_le_tab
                                        ,p_org_le_class_tab            => l_org_le_class_tab
                                        ,p_org_hierarchy_ele_le_tab    => l_org_hierarchy_ele_le_tab);
    hr_utility.set_location(l_proc, 220);





    BEGIN
      --
      -- run data pump to load hrms entities into schema
      --
      hr_data_pump.main (errbuf             => l_errbuf
                        ,retcode            => l_retcode
                        ,p_batch_id         => l_batch_header_id
                        ,p_validate         => 'N'
                        ,p_pap_group_id     => null);

      l_data_pump_exception := per_ri_config_utilities.check_data_pump_exception(p_patch_header_id  => l_batch_header_id);
      if l_data_pump_exception then
        per_ri_config_utilities.write_data_pump_exception_log(p_patch_header_id  => l_batch_header_id);
        raise data_pump_load_failure;
      end if;

    EXCEPTION
      when data_pump_load_failure then
        hr_utility.set_location(l_proc, 221);
        hr_utility.raise_error;
        commit;
      when others then
        hr_utility.set_location(l_proc, 222);
        p_errbuff     :=  'Error cooured in loading datapump records';
        p_retcode     :=  2;

        l_error_message := 'Error in ' || l_proc;
        --hr_utility.trace(l_error_message || '-' || sqlerrm);
        hr_utility.set_location(' Leaving:'|| l_proc, 500);
        hr_utility.raise_error;
        commit;
    END;

    hr_utility.set_location(l_proc, 230);


    per_ri_config_utilities.create_more_hrms_resps
                (p_configuration_code         => p_configuration_code
                ,p_security_profile_tab       => l_security_profile_tab
                ,p_int_bg_resp_tab            => l_int_bg_resp_tab
                --,p_technical_summary_mode    =>  l_technical_summary_mode
                ,p_hrms_resp_main_tab         => l_hrms_resp_main_tab
                ,p_more_profile_resp_tab      => l_more_profile_resp_tab
                ,p_more_int_profile_resp_tab  => l_more_int_profile_resp_tab);

    hr_utility.set_location(' Leaving:'|| l_proc, 250);

    -- Security Group Removal Changes
    --
    --per_ri_config_utilities.create_security_profile_assign
                --(p_security_profile_tab                      =>  l_security_profile_tab);

    hr_utility.set_location(' Leaving:'|| l_proc, 250);

    per_ri_config_utilities.submit_int_payroll_request
                (errbuf                      => l_errbuf
                ,retcode                     => l_retcode
                ,p_country_tab               => l_country_tab
                ,p_technical_summary_mode    => l_technical_summary_mode
                ,p_int_hrms_setup_tab        => l_int_hrms_setup_tab
                );
    hr_utility.set_location(l_proc, 240);

    per_ri_config_utilities.update_configuration_status(p_configuration_code);

    --
    -- Enable Multiple Security Group process
    --
    -- commented code in this process call.
    per_ri_config_utilities.submit_enable_mult_sg_process
                (errbuf      => l_errbuf_msg
                ,retcode    => l_retcode_msg);


    commit;

    hr_utility.trace('Ending Time = ' || to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS'));
    hr_utility.set_location(' Leaving:'|| l_proc, 300);



  EXCEPTION
    --when not_fresh_install then
    --per_ri_config_utilities.write_log(p_message => l_log_message);
      --raise;
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END load_enterprise_configuration;

END per_ri_config_main;

/
