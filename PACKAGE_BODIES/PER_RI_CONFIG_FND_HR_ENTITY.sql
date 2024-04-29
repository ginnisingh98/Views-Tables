--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_FND_HR_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_FND_HR_ENTITY" AS
/* $Header: perrichd.pkb 120.4.12010000.3 2009/09/01 05:56:45 psengupt ship $ */

  g_config_effective_date       date          := TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_config_effective_end_date   date          := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
  g_package                     varchar2(30)  := 'per_ri_config_fnd_hr_entity.';


  /* --------------------------------------------------------------------------
  -- Name      : create_jobs_no_rv_keyflex
  -- Purpose   : This procedure creates jobs keyflex structures, segments and
  --             valuesets if no regional variance are not defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_jobs_no_rv_keyflex (p_configuration_code in varchar2
                                      ,p_technical_summary_mode in boolean default FALSE
                                      ,p_kf_job_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_no_rv_tab
                                      ,p_kf_job_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_no_rv_seg_tab) IS

  cursor csr_config_job_no_rv (cp_configuration_code in varchar2) IS
    select job_segment_name,
           job_segment_type,
           industry_attribute,
           CONFIG_SEQUENCE
      from per_ri_config_job_kf_seg_v
     where configuration_code = cp_configuration_code
       and industry_attribute = per_ri_config_main.g_global_fed_job_non_fed_att
       order by CONFIG_SEQUENCE;

  l_proc                         varchar2(72) := g_package || 'create_jobs_no_rv_keyflex';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);
  l_kf_job_no_rv_count           number(8) := 0;
  l_kf_job_no_rv_tab             per_ri_config_tech_summary.kf_job_no_rv_tab;
  l_kf_job_no_rv_seg_count       number(8) := 0;
  l_kf_job_no_rv_seg_tab         per_ri_config_tech_summary.kf_job_no_rv_seg_tab;

  l_kf_job_no_rv_valueset_tab    per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_job_segment_name             per_ri_config_information.config_information1%type;
  l_job_segment_type             per_ri_config_information.config_information1%type;
  l_industry_attribute           per_ri_config_information.config_information1%type;
  l_jobs_keyflex_number          number(9);
  l_job_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;

  l_valueset_name                fnd_flex_value_sets.flex_value_set_name%type;
  l_jobs_segment_count           number(9);
  l_jobs_segment_no              number(9);
  l_jobs_segment_count_fixed     number(9) := 0;
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;

  l_global_job_structure_name   fnd_id_flex_structures.id_flex_structure_code%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_global_job_structure_name   :=  per_ri_config_utilities.return_config_entity_name
                                                      (per_ri_config_main.g_global_job_structure_name);
    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                  (p_configuration_code => p_configuration_code);

    hr_utility.trace('l_enterprise_primary_industry = ' || l_enterprise_primary_industry);

    -- Create Global Jobs Key flex
    if NOT (p_technical_summary_mode) then
      l_jobs_keyflex_number  := per_ri_config_utilities.create_key_flexfield
                              (p_appl_short_name => 'PER'
                              ,p_flex_code       => 'JOB'
                              ,p_structure_code  => l_global_job_structure_name
                              ,p_structure_title => l_global_job_structure_name
                              ,p_description     => l_global_job_structure_name
                                                      || per_ri_config_main.g_description_suffix_string);

    else
      p_kf_job_no_rv_tab(l_kf_job_no_rv_count).appl_short_name    := 'PER';
      p_kf_job_no_rv_tab(l_kf_job_no_rv_count).flex_code          := 'JOB';
      p_kf_job_no_rv_tab(l_kf_job_no_rv_count).structure_code     := l_global_job_structure_name;
      p_kf_job_no_rv_tab(l_kf_job_no_rv_count).structure_title    := l_global_job_structure_name;
      p_kf_job_no_rv_tab(l_kf_job_no_rv_count).description        := l_global_job_structure_name
                                                             || per_ri_config_main.g_description_suffix_string;
      l_kf_job_no_rv_count := l_kf_job_no_rv_count + 1 ;
    end if;

    hr_utility.set_location(l_proc, 30);
    l_log_message := 'Created KEYFLEX PER JOB ' || l_global_job_structure_name;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
      hr_utility.set_location(l_proc, 20);
      -- create segments
      open csr_config_job_no_rv(p_configuration_code);
      l_jobs_segment_count := 0;
      LOOP
        fetch csr_config_job_no_rv into l_job_segment_name
                                       ,l_job_segment_type
                                       ,l_industry_attribute
                                       ,l_jobs_segment_no;

        exit when csr_config_job_no_rv%NOTFOUND;

        --
        -- create job flex segment
        --
        l_jobs_segment_count := csr_config_job_no_rv%ROWCOUNT;
        if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'JOB'
                        ,p_structure_code            => l_global_job_structure_name
                        ,p_segment_name              => l_job_segment_name
                        ,p_column_name               => 'SEGMENT' || l_jobs_segment_count
                        ,p_segment_number            => l_jobs_segment_no --l_jobs_segment_count
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_job_segment_name
                        ,p_segment_type              => l_job_segment_type
                        ,p_window_prompt             => l_job_segment_name);

        else
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).appl_short_name  := 'PER';
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).flex_code        := 'JOB';
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).structure_code   :=  l_global_job_structure_name;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_name     :=  l_job_segment_name;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).column_name      := 'SEGMENT' || l_jobs_segment_count;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_number   :=  l_jobs_segment_no;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).value_set        := null;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).lov_prompt       := l_job_segment_name;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_type     := l_job_segment_name;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).window_prompt    := l_job_segment_name;


          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_job_segment_type
                                 ,p_structure_code  => l_global_job_structure_name
                                 ,p_segment_name    => l_job_segment_name
                                 ,p_segment_number  => l_jobs_segment_no --l_jobs_segment_count
                                 ,p_valueset_tab    => l_kf_job_no_rv_valueset_tab);

          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_value_set_name
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_description
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_security_available
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_enable_longlist
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_format_type
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_maximum_size
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_precision
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_numbers_only
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_uppercase_only
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_min_value
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_max_value
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).max_value;

          l_kf_job_no_rv_seg_count := l_kf_job_no_rv_seg_count + 1 ;

        end if;
          l_log_message := 'Created KEYFLEX SEGMENT : PER JOB ' || l_job_segment_name;
          per_ri_config_utilities.write_log(p_message => l_log_message);
      END LOOP;
      close csr_config_job_no_rv;
    else
      hr_utility.set_location(l_proc, 100);
      hr_utility.trace('Jobs: Industry is US_GOVERNMENT');

      -- create only federal job segments with specified value segment name valuesets.
      -- First Segment 'Name' valueset '60 Characters'
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'JOB'
                        ,p_structure_code            => l_global_job_structure_name
                        ,p_segment_name              => 'Name'
                        ,p_column_name               => 'SEGMENT1'
                        ,p_segment_number            => 1
                        ,p_value_set                 => '60 Characters'
                        ,p_lov_prompt                => 'Name'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Name'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).flex_code        := 'JOB';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).structure_code   :=  l_global_job_structure_name;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_name     :=  'Name';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).column_name      := 'SEGMENT1';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_number   :=  1;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).value_set        := '60 Characters';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).lov_prompt       := 'Name';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_type     := 'Char';
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).window_prompt    := 'Name';


        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => '60 Characters'
                                 ,p_valueset_type => 'Char'
                                 ,p_structure_code  => l_global_job_structure_name
                                 ,p_segment_name    => 'Name'
                                 ,p_segment_number  => 1
                                 ,p_valueset_tab  => l_kf_job_no_rv_valueset_tab);

        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_value_set_name
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_description
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_security_available
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_enable_longlist
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_format_type
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_maximum_size
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_precision
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_numbers_only
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_uppercase_only
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_min_value
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_max_value
                         := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_job_no_rv_seg_count := l_kf_job_no_rv_seg_count + 1 ;
    end if;

      open csr_config_job_no_rv(p_configuration_code);

      --
      -- one segment is always defined for fedral
      --
      l_jobs_segment_count_fixed := per_ri_config_main.g_global_fed_job_seg_count;
      l_jobs_segment_count       := 0;
      LOOP
        fetch csr_config_job_no_rv into l_job_segment_name
                                       ,l_job_segment_type
                                       ,l_industry_attribute
                                       ,l_jobs_segment_no;
        exit when csr_config_job_no_rv%NOTFOUND;
        hr_utility.trace('l_jobs_segment_count = ' || to_char(l_jobs_segment_count));

        if l_industry_attribute = per_ri_config_main.g_global_fed_job_non_fed_att then

          l_jobs_segment_count := l_jobs_segment_count_fixed + csr_config_job_no_rv%ROWCOUNT;


          hr_utility.trace('l_jobs_segment_count = ' || to_char(l_jobs_segment_count));
          if NOT (p_technical_summary_mode) then
            per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'JOB'
                          ,p_structure_code            => l_global_job_structure_name
                          ,p_segment_name              => l_job_segment_name
                          ,p_column_name               => 'SEGMENT' || l_jobs_segment_count
                          ,p_segment_number            => l_jobs_segment_no --l_jobs_segment_count
                          ,p_value_set                 => null
                          ,p_lov_prompt                => l_job_segment_name
                          ,p_segment_type              => l_job_segment_type
                          ,p_window_prompt             => l_job_segment_name);

          else
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).appl_short_name  := 'PER';
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).flex_code        := 'JOB';
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).structure_code   :=  l_global_job_structure_name;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_name     :=  l_job_segment_name;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).column_name      := 'SEGMENT' || l_jobs_segment_count;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_number   :=  l_jobs_segment_no;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).value_set        := null;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).lov_prompt       := l_job_segment_name;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).segment_type     := l_job_segment_type;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).window_prompt    := l_job_segment_name;

            --create technical summary data for valueset
            per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                   ,p_valueset_type   => l_job_segment_type
                                   ,p_structure_code  => l_global_job_structure_name
                                   ,p_segment_name    => l_job_segment_name
                                   ,p_segment_number  => l_jobs_segment_no --l_jobs_segment_count
                                   ,p_valueset_tab    => l_kf_job_no_rv_valueset_tab);

            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_value_set_name
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_description
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).description;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_security_available
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).security_available;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_enable_longlist
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_format_type
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).format_type;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_maximum_size
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_precision
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).precision;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_numbers_only
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_uppercase_only
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_right_justify_zero_fill
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_min_value
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).min_value;
            p_kf_job_no_rv_seg_tab(l_kf_job_no_rv_seg_count).vs_max_value
                           := l_kf_job_no_rv_valueset_tab(l_value_set_tab_count).max_value;
            l_kf_job_no_rv_seg_count := l_kf_job_no_rv_seg_count + 1 ;
          end if;

          l_log_message := 'Created KEYFLEX SEGMENT : PER JOB ' || l_job_segment_name;
          per_ri_config_utilities.write_log(p_message => l_log_message);
        end if;
      END LOOP;
      close csr_config_job_no_rv;

    end if;
    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'JOB'
                       ,p_structure_code            => l_global_job_structure_name);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_jobs_no_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_positions_no_rv_keyflex
  -- Purpose   : This procedure creates positions keyflex structures, segments and
  --             valuesets if no regional variance are not defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_positions_no_rv_keyflex (p_configuration_code in varchar2
                                           ,p_technical_summary_mode in boolean default FALSE
                                           ,p_kf_pos_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_no_rv_tab
                                      ,p_kf_pos_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_no_rv_seg_tab) IS

  cursor csr_config_position_no_rv (cp_configuration_code in varchar2) IS
   select position_segment_name,
          position_segment_type,
          industry_attribute,
          CONFIG_SEQUENCE
      from per_ri_config_pos_kf_seg_v
     where configuration_code = cp_configuration_code
       and industry_attribute = per_ri_config_main.g_global_fed_pos_non_fed_att
       order by CONFIG_SEQUENCE;

  cursor csr_config_position_no_rv_cnt (cp_configuration_code in varchar2) IS
   select count(*)
      from per_ri_config_pos_kf_seg_v
     where configuration_code = cp_configuration_code
       and industry_attribute = per_ri_config_main.g_global_fed_pos_non_fed_att;

  l_proc                         varchar2(72) := g_package || 'create_positions_no_rv_keyflex';
  l_log_message                  varchar2(360);
  l_error_message                 varchar2(360);

  l_kf_pos_no_rv_count           number(8) := 0;
  l_kf_pos_no_rv_tab             per_ri_config_tech_summary.kf_pos_no_rv_tab;
  l_kf_pos_no_rv_seg_count       number(8) := 0;
  l_kf_pos_no_rv_seg_tab         per_ri_config_tech_summary.kf_pos_no_rv_seg_tab;

  l_kf_pos_no_rv_valueset_tab    per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_pos_segment_name             per_ri_config_information.config_information1%type;
  l_pos_segment_type             per_ri_config_information.config_information1%type;
  l_industry_attribute           per_ri_config_information.config_information1%type;
  l_pos_keyflex_number           number(9);
  l_pos_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;

  l_valueset_name                fnd_flex_value_sets.flex_value_set_name%type;
  l_pos_segment_count            number(9);
  l_pos_segment_no               number(9);
  l_pos_segment_count_fixed      number(9);
  l_position_no_rv_no_seg_count  number(9);
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;
  l_global_pos_structure_name    fnd_id_flex_structures.id_flex_structure_code%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_global_pos_structure_name := per_ri_config_utilities.return_config_entity_name
                                     (per_ri_config_main.g_global_pos_structure_name);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                  (p_configuration_code => p_configuration_code);

    hr_utility.trace('l_enterprise_primary_industry = ' || l_enterprise_primary_industry);

    -- Create Global Position Key flex
    if NOT (p_technical_summary_mode) then
      l_pos_keyflex_number  := per_ri_config_utilities.create_key_flexfield
                              (p_appl_short_Name => 'PER'
                              ,p_flex_code       => 'POS'
                              ,p_structure_code  => l_global_pos_structure_name
                              ,p_structure_title => l_global_pos_structure_name
                              ,p_description     => l_global_pos_structure_name
                                                           || per_ri_config_main.g_description_suffix_string);
    else
      p_kf_pos_no_rv_tab(l_kf_pos_no_rv_count).appl_short_name    := 'PER';
      p_kf_pos_no_rv_tab(l_kf_pos_no_rv_count).flex_code          := 'POS';
      p_kf_pos_no_rv_tab(l_kf_pos_no_rv_count).structure_code     := l_global_pos_structure_name;
      p_kf_pos_no_rv_tab(l_kf_pos_no_rv_count).structure_title    := l_global_pos_structure_name;
      p_kf_pos_no_rv_tab(l_kf_pos_no_rv_count).description        := l_global_pos_structure_name
                                                              || per_ri_config_main.g_description_suffix_string;
      l_kf_pos_no_rv_count := l_kf_pos_no_rv_count + 1 ;
    end if;


    hr_utility.set_location(l_proc, 30);
    l_log_message := 'Created KEYFLEX PER POS ' || l_global_pos_structure_name;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
      hr_utility.set_location(l_proc, 20);

      -- create segments
      open csr_config_position_no_rv(p_configuration_code);
      l_pos_segment_count := 0;
      LOOP
        fetch csr_config_position_no_rv into l_pos_segment_name
                                            ,l_pos_segment_type
                                            ,l_industry_attribute
                                            ,l_pos_segment_no;

        exit when csr_config_position_no_rv%NOTFOUND;

        -- Create Jobs Key Flex Segments
        l_pos_segment_count := csr_config_position_no_rv%ROWCOUNT;
        if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_global_pos_structure_name
                        ,p_segment_name              => l_pos_segment_name
                        ,p_column_name               => 'SEGMENT' || l_pos_segment_count
                        ,p_segment_number            => l_pos_segment_no
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_pos_segment_name
                        ,p_segment_type              => l_pos_segment_type
                        ,p_window_prompt             => l_pos_segment_name);
        else
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  l_pos_segment_name;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      := 'SEGMENT' || l_pos_segment_count;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  l_pos_segment_no;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := null;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := l_pos_segment_name;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     := l_pos_segment_type;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := l_pos_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_pos_segment_type
                                 ,p_structure_code  => l_global_pos_structure_name
                                 ,p_segment_name    => l_pos_segment_name
                                 ,p_segment_number  => l_pos_segment_no
                                 ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                         := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
        end if;

        per_ri_config_utilities.write_log(p_message => 'Created Global Position Key Flex Segment' || l_pos_segment_name);
        hr_utility.trace('Created Position Key Flex NO RV Segment: ' ||  l_pos_segment_name);
      END LOOP;
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            => l_global_pos_structure_name);
      end if;
    else
      hr_utility.set_location(l_proc, 100);
      hr_utility.trace('Positions: Industry is US_GOVERNMENT');

      -- create only federal job segments with specified value segment name valuesets.
      -- First Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_global_pos_structure_name
                        ,p_segment_name              => 'Position Title'
                        ,p_column_name               => 'SEGMENT1'
                        ,p_segment_number            => 1
                        ,p_value_set                 => 'GHR_US_POSITION_TITLE'
                        ,p_lov_prompt                => 'Position Title'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Position Title'
                        ,p_fed_seg_attribute         => 'Y');

      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  'Position Title';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT1';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  1;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := 'GHR_US_POSITION_TITLE';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := 'Position Title';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     := 'Char';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := 'Position Title';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POSITION_TITLE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => 'Position Title'
                               ,p_segment_number  => 1
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;


      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Position Title';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Second Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_global_pos_structure_name
                        ,p_segment_name              => 'Description'
                        ,p_column_name               => 'SEGMENT2'
                        ,p_segment_number            => 2
                        ,p_value_set                 => 'GHR_US_POS_DESC_NUM'
                        ,p_lov_prompt                => 'Description'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Description'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  'Description';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT2';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  2;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := 'GHR_US_POS_DESC_NUM';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := 'Description';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     := 'Char';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := 'Description';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POS_DESC_NUM'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => 'Description'
                               ,p_segment_number  => 2
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Description';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Third Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_global_pos_structure_name
                        ,p_segment_name              => 'Sequence'
                        ,p_column_name               => 'SEGMENT3'
                        ,p_segment_number            => 3
                        ,p_value_set                 => 'GHR_US_SEQUENCE_NUM'
                        ,p_lov_prompt                => 'Sequence'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Sequence'
                        ,p_fed_seg_attribute         => 'Y');

      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  'Sequence';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT3';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  3;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := 'GHR_US_POSITION_TITLE';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := 'Sequence';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     := 'Char';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := 'Sequence';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POSITION_TITLE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => 'Sequence'
                               ,p_segment_number  => 3
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Sequence';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      -- Fourth Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_global_pos_structure_name
                        ,p_segment_name              => 'Agency Code'
                        ,p_column_name               => 'SEGMENT4'
                        ,p_segment_number            => 4
                        ,p_value_set                 => 'GHR_US_AGENCY_CODE'
                        ,p_lov_prompt                => 'Agency Code'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Agency Code'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  'Agency Code';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT4';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  4;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := 'GHR_US_AGENCY_CODE';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := 'Agency Code';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     := 'Char';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := 'Agency Code';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_AGENCY_CODE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => 'Agency Code'
                               ,p_segment_number  => 4
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;


      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Agency Code';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      open csr_config_position_no_rv(p_configuration_code);

      --
      -- four segment is always defined for fedral
      --

      l_pos_segment_count_fixed := per_ri_config_main.g_global_fed_pos_seg_count;
      l_pos_segment_count       := 0;
      LOOP
        fetch csr_config_position_no_rv into l_pos_segment_name
                                       ,l_pos_segment_type
                                       ,l_industry_attribute
                                       ,l_pos_segment_no;
        exit when csr_config_position_no_rv%NOTFOUND;
        hr_utility.trace('l_pos_segment_count = ' || to_char(l_pos_segment_count));

        if l_industry_attribute = per_ri_config_main.g_global_fed_pos_non_fed_att then

          l_pos_segment_count := l_pos_segment_count_fixed + csr_config_position_no_rv%ROWCOUNT;


          hr_utility.trace('l_pos_segment_count = ' || to_char(l_pos_segment_count));

          if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.create_flex_segments
                                   (p_appl_short_Name           => 'PER'
                                   ,p_flex_code                 => 'POS'
                                   ,p_structure_code            => l_global_pos_structure_name
                                   ,p_segment_name              => l_pos_segment_name
                                   ,p_column_name               => 'SEGMENT' || l_pos_segment_count
                                   ,p_segment_number            => l_pos_segment_no
                                   ,p_value_set                 => null
                                   ,p_lov_prompt                => l_pos_segment_name
                                   ,p_segment_type              => l_pos_segment_type
                                   ,p_window_prompt             => l_pos_segment_name);
      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  l_pos_segment_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT' || l_pos_segment_count;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  l_pos_segment_no;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        :=  null;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       :=  l_pos_segment_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     :=  l_pos_segment_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    :=  l_pos_segment_name;

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                               ,p_valueset_type   => l_pos_segment_type
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => l_pos_segment_name
                               ,p_segment_number  => l_pos_segment_no
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;

          l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || l_pos_segment_name;
          per_ri_config_utilities.write_log(p_message => l_log_message);
        end if;
      END LOOP;
      close csr_config_position_no_rv;

      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            => l_global_pos_structure_name);
      end if;
    end if;

    --
    -- when no positions are defined, attach default segments to it.
    --
    open csr_config_position_no_rv_cnt(p_configuration_code);
    fetch csr_config_position_no_rv_cnt into l_position_no_rv_no_seg_count;

    hr_utility.trace('l_position_no_rv_no_seg_count = ' || l_position_no_rv_no_seg_count);
    if l_position_no_rv_no_seg_count = 0 then
      hr_utility.trace('Only Jobs are defined');
      -- In case when no positions are defined
      -- Attach default segments to it.
      -- FED case always Jobs and Positions defined.
      hr_utility.set_location(l_proc, 110);

       -- Create Position Key Flex Segments
       if NOT (p_technical_summary_mode) then
       per_ri_config_utilities.create_flex_segments
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            => l_global_pos_structure_name
                       ,p_segment_name              => 'Position Name'
                       ,p_column_name               => 'SEGMENT1'
                       ,p_segment_number            => 1
                       ,p_value_set                 => null
                       ,p_lov_prompt                => 'Position Name'
                      ,p_window_prompt             => 'Position Name');
      else
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).appl_short_name  := 'PER';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).flex_code        := 'POS';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).structure_code   :=  l_global_pos_structure_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_name     :=  'Position Name';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).column_name      :=  'SEGMENT1';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_number   :=  1;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).value_set        := 'GHR_US_POSITION_TITLE';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).lov_prompt       := 'Position Name';
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).segment_type     :=  null;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).window_prompt    := 'Position Name';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POSITION_TITLE'
                               ,p_valueset_type   => null
                               ,p_structure_code  => l_global_pos_structure_name
                               ,p_segment_name    => 'Position Name'
                               ,p_segment_number  => 1
                               ,p_valueset_tab    => l_kf_pos_no_rv_valueset_tab);

        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_value_set_name
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_description
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_security_available
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_enable_longlist
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_format_type
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_maximum_size
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_precision
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_numbers_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_uppercase_only
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_min_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_no_rv_seg_tab(l_kf_pos_no_rv_seg_count).vs_max_value
                       := l_kf_pos_no_rv_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_no_rv_seg_count := l_kf_pos_no_rv_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || per_ri_config_main.g_global_pos_structure_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            => l_global_pos_structure_name);
      end if;
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 40);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;


  END create_positions_no_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_grades_no_rv_keyflex
  -- Purpose   : This procedure creates jobs keyflex structures, segments and
  --             valuesets if no regional variance are not defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_grades_no_rv_keyflex (p_configuration_code in varchar2
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_kf_grd_no_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_no_rv_tab
                                        ,p_kf_grd_no_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_no_rv_seg_tab) IS

  cursor csr_config_grade_no_rv (cp_configuration_code in varchar2) IS
    select grade_segment_name,
           grade_segment_type,
           industry_attribute,
           CONFIG_SEQUENCE
      from per_ri_config_grade_kf_seg_v
     where configuration_code = cp_configuration_code
       and industry_attribute = per_ri_config_main.g_global_fed_grd_non_fed_att
       order by CONFIG_SEQUENCE;

  l_proc                         varchar2(72) := g_package || 'create_grades_no_rv_keyflex';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);
  l_kf_grd_no_rv_count           number(8) := 0;
  l_kf_grd_no_rv_tab             per_ri_config_tech_summary.kf_grd_no_rv_tab;

  l_kf_grd_no_rv_seg_count       number(8) := 0;
  l_kf_grd_no_rv_seg_tab         per_ri_config_tech_summary.kf_grd_no_rv_seg_tab;

  l_kf_grd_no_rv_valueset_tab    per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_grade_segment_name           per_ri_config_information.config_information1%type;
  l_grade_segment_type           per_ri_config_information.config_information1%type;
  l_industry_attribute           per_ri_config_information.config_information1%type;
  l_grade_keyflex_number         number(9);
  l_grade_structures_code        fnd_id_flex_structures.id_flex_structure_code%type;

  l_grade_segment_count          number(9) := 0;
  l_grade_segment_no             number(9) := 0;
  l_grade_segment_count_fixed    number(9) := 0;

  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;

  l_global_grd_structure_name    fnd_id_flex_structures.id_flex_structure_code%type;

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                  (p_configuration_code => p_configuration_code);
    hr_utility.trace('l_enterprise_primary_industry = ' || l_enterprise_primary_industry);

    l_global_grd_structure_name   :=  per_ri_config_utilities.return_config_entity_name
                                                      (per_ri_config_main.g_global_grd_structure_name);
    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
      hr_utility.set_location(l_proc, 20);
      -- Create Global Grades Key flex
      if NOT (p_technical_summary_mode) then
        l_grade_keyflex_number  := per_ri_config_utilities.create_key_flexfield
                                (p_appl_short_Name => 'PER'
                                ,p_flex_code       => 'GRD'
                                ,p_structure_code  => l_global_grd_structure_name
                                ,p_structure_title => l_global_grd_structure_name
                                ,p_description     => l_global_grd_structure_name
                                                             || per_ri_config_main.g_description_suffix_string);
      else
        p_kf_grd_no_rv_tab(l_kf_grd_no_rv_count).appl_short_name    := 'PER';
        p_kf_grd_no_rv_tab(l_kf_grd_no_rv_count).flex_code          := 'GRD';
        p_kf_grd_no_rv_tab(l_kf_grd_no_rv_count).structure_code     := l_global_grd_structure_name;
        p_kf_grd_no_rv_tab(l_kf_grd_no_rv_count).structure_title    := l_global_grd_structure_name;
        p_kf_grd_no_rv_tab(l_kf_grd_no_rv_count).description        := l_global_grd_structure_name
                                                             || per_ri_config_main.g_description_suffix_string;
        l_kf_grd_no_rv_count := l_kf_grd_no_rv_count + 1 ;
      end if;


      hr_utility.set_location(l_proc, 30);
      l_log_message := 'Created KEYFLEX PER GRD ' || l_global_grd_structure_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- create segments
      open csr_config_grade_no_rv(p_configuration_code);
      l_grade_segment_count := 0;
      hr_utility.set_location(l_proc, 40);
      LOOP
        fetch csr_config_grade_no_rv into l_grade_segment_name
                                         ,l_grade_segment_type
                                         ,l_industry_attribute
                                         ,l_grade_segment_no;
        exit when csr_config_grade_no_rv%NOTFOUND;

        -- Create Jobs Key Flex Segments
        l_grade_segment_count := csr_config_grade_no_rv%ROWCOUNT;
       if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'GRD'
                        ,p_structure_code            => l_global_grd_structure_name
                        ,p_segment_name              => l_grade_segment_name
                        ,p_column_name               => 'SEGMENT' || l_grade_segment_count
                        ,p_segment_number            => l_grade_segment_no
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_grade_segment_name
                        ,p_segment_type              => l_grade_segment_type
                        ,p_window_prompt             => l_grade_segment_name);

        else
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).appl_short_name  := 'PER';
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).flex_code        := 'GRD';
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).structure_code   :=  l_global_grd_structure_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_name     :=  l_grade_segment_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).column_name      := 'SEGMENT' || l_grade_segment_count;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_number   :=  l_grade_segment_no;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).value_set        :=  null;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).lov_prompt       := l_grade_segment_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_type     := l_grade_segment_type;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).window_prompt    := l_grade_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_grade_segment_type
                                 ,p_structure_code  => l_global_grd_structure_name
                                 ,p_segment_name    => l_grade_segment_name
                                 ,p_segment_number  => l_grade_segment_no
                                 ,p_valueset_tab    => l_kf_grd_no_rv_valueset_tab);

          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_value_set_name
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
      hr_utility.trace('VALUESETSET_NAME = ' ||  l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).value_set_name);
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_description
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_security_available
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_enable_longlist
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_format_type
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_maximum_size
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_precision
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_numbers_only
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_uppercase_only
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_min_value
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_max_value
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_grd_no_rv_seg_count := l_kf_grd_no_rv_seg_count + 1 ;
    end if;

        l_log_message := 'Created KEYFLEX SEGMENT : PER GRD ' || l_grade_segment_name;
        per_ri_config_utilities.write_log(p_message => l_log_message);
      END LOOP;
      hr_utility.set_location(l_proc, 50);
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            => l_global_grd_structure_name);
      end if;
      close csr_config_grade_no_rv;
    else
      hr_utility.set_location(l_proc, 100);
      hr_utility.trace('Grades: Industry is US_GOVERNMENT');

      -- create Global Jobs Key flex
      -- do not create grade flex field use US_FEDERAL_GRADE
      -- create only non federal segments

      open csr_config_grade_no_rv(p_configuration_code);

      -- some segments (2 for now) are always defined for fedral
      l_grade_segment_count_fixed := per_ri_config_main.g_global_fed_grd_seg_count;
      l_grade_segment_count       := 0;
      LOOP
        fetch csr_config_grade_no_rv into l_grade_segment_name
                                         ,l_grade_segment_type
                                         ,l_industry_attribute
                                         ,l_grade_segment_no;

        exit when csr_config_grade_no_rv%NOTFOUND;
        hr_utility.trace('l_grade_segment_count = ' || to_char(l_grade_segment_count));
        hr_utility.trace('p_structure_code = ' || per_ri_config_main.g_global_fed_grd_struct_name);

        if l_industry_attribute = per_ri_config_main.g_global_fed_grd_non_fed_att then

          l_grade_segment_count := l_grade_segment_count_fixed + csr_config_grade_no_rv%ROWCOUNT;


          hr_utility.trace('l_grade_segment_count = ' || to_char(l_grade_segment_count));


          if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'GRD'
                          ,p_structure_code            => per_ri_config_main.g_global_fed_grd_struct_name
                          ,p_segment_name              => l_grade_segment_name
                          ,p_column_name               => 'SEGMENT' || l_grade_segment_count
                          ,p_segment_number            => l_grade_segment_no
                          ,p_value_set                 => null
                          ,p_lov_prompt                => l_grade_segment_name
                          ,p_segment_type              => l_grade_segment_type
                          ,p_window_prompt             => l_grade_segment_name);
        else
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).appl_short_name  := 'PER';
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).flex_code        := 'GRD';
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).structure_code   :=  per_ri_config_main.g_global_fed_grd_struct_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_name     :=  l_grade_segment_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).column_name      :=  'SEGMENT' || l_grade_segment_count;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_number   :=  l_grade_segment_no;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).value_set        :=  null;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).lov_prompt       := l_grade_segment_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).segment_type     := l_grade_segment_type;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).window_prompt    := l_grade_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_grade_segment_type
                                 ,p_structure_code  => per_ri_config_main.g_global_fed_grd_struct_name
                                 ,p_segment_name    => l_grade_segment_name
                                 ,p_segment_number  => l_grade_segment_no
                                 ,p_valueset_tab    => l_kf_grd_no_rv_valueset_tab);

          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_value_set_name
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_description
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_security_available
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_enable_longlist
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_format_type
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_maximum_size
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_precision
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_numbers_only
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_uppercase_only
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_min_value
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_grd_no_rv_seg_tab(l_kf_grd_no_rv_seg_count).vs_max_value
                         := l_kf_grd_no_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_grd_no_rv_seg_count := l_kf_grd_no_rv_seg_count + 1 ;
        end if;


          l_log_message := 'Created KEYFLEX SEGMENT : PER GRD ' || l_grade_segment_name;
          per_ri_config_utilities.write_log(p_message => l_log_message);
        end if;
      END LOOP;
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            => per_ri_config_main.g_global_fed_grd_struct_name);
      end if;
      close csr_config_grade_no_rv;
    end if;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_grades_no_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_jobs_rv_keyflex
  -- Purpose   : This procedure creates jobs keyflex structures, segments and
  --             valuesets when regional variance are defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_jobs_rv_keyflex (p_configuration_code in varchar2
                                   ,p_technical_summary_mode in boolean default FALSE
                                   ,p_kf_job_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_rv_tab
                                   ,p_kf_job_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_rv_seg_tab) IS

    cursor csr_config_jobs_rv (cp_configuration_code in varchar2) IS
    select distinct per_ri_config_utilities.return_config_entity_name(rv.regional_variance_name),
           rv.regional_variance_name,  rv.REG_VARIANCE_COUNTRY_CODE
      from per_ri_config_jp_rv_v rv,
           per_ri_config_job_rv_seg_v seg
     where rv.configuration_code = cp_configuration_code
       and rv.configuration_code = seg.configuration_code
       and rv.regional_variance_name = seg.regional_variance_name
       and seg.global_structure_indicator = 'N';

    cursor csr_config_jobs_rv_seg (cp_configuration_code in varchar2
                                  ,cp_jobs_rv_name         in varchar2) IS
    select distinct segment_type
                   ,segment_name
                   ,CONFIG_SEQUENCE
      from per_ri_config_job_rv_seg_v
     where configuration_code        = cp_configuration_code
       and regional_variance_name    = cp_jobs_rv_name
       order by CONFIG_SEQUENCE;

  l_proc                        varchar2(72) := g_package || 'create_jobs_rv_keyflex';
  l_error_message               varchar2(360);
  l_kf_job_rv_count             number(8) := 0;
  l_kf_job_rv_tab               per_ri_config_tech_summary.kf_job_rv_tab;

  l_kf_job_rv_seg_count         number(8) := 0;
  l_kf_job_rv_seg_tab           per_ri_config_tech_summary.kf_job_rv_tab;

  l_jobs_rv_name                per_ri_config_information.config_information1%type;
  l_jobs_rv_name_orig           per_ri_config_information.config_information1%type;

  l_kf_job_rv_valueset_tab      per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_rv_jobs_segment_type        per_ri_config_information.config_information1%type;
  l_rv_jobs_segment_name        per_ri_config_information.config_information1%type;
  l_jobs_keyflex_number         number(9);
  l_jobs_structures_code        fnd_id_flex_structures.id_flex_structure_code%type;

  l_jobs_segment_count        number(9);
  l_jobs_segment_no           number(9);

  l_country_selected          varchar2(10);
  l_rv_country_code           varchar2(10);
  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    select legislation_code into l_country_selected from per_business_groups
      where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;

    open csr_config_jobs_rv(p_configuration_code);
    LOOP
      fetch csr_config_jobs_rv into l_jobs_rv_name,l_jobs_rv_name_orig,l_rv_country_code;

      exit when csr_config_jobs_rv%NOTFOUND;

      hr_utility.set_location(l_proc, 20);
    IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
        AND l_rv_country_code = l_country_selected THEN
         hr_utility.set_location('skip the creation of the flexfield structure', 90);
    ELSE
      -- Create Jobs RV Key flex
      if NOT (p_technical_summary_mode) then
        l_jobs_keyflex_number  := per_ri_config_utilities.create_key_flexfield
                           (p_appl_short_Name => 'PER'
                           ,p_flex_code       => 'JOB'
                           ,p_structure_code  => l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string
                           ,p_structure_title => l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string
                           ,p_description     => l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string
                                                               || per_ri_config_main.g_description_suffix_string);
      else
        p_kf_job_rv_tab(l_kf_job_rv_count).appl_short_name    := 'PER';
        p_kf_job_rv_tab(l_kf_job_rv_count).flex_code          := 'JOB';
        p_kf_job_rv_tab(l_kf_job_rv_count).structure_code     := l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string;
        p_kf_job_rv_tab(l_kf_job_rv_count).structure_title    := l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string;
        p_kf_job_rv_tab(l_kf_job_rv_count).description        := l_jobs_rv_name || per_ri_config_main.g_job_rv_struct_def_string
                                                                    ||  per_ri_config_main.g_description_suffix_string;
        l_kf_job_rv_count := l_kf_job_rv_count + 1 ;
    end if;

      per_ri_config_utilities.write_log(p_message => 'Created Jobs RV Keyflex ' || l_jobs_rv_name
                                                     || per_ri_config_main.g_job_rv_struct_def_string );
      hr_utility.trace('Created Jobs RV Keyflex ' || l_jobs_rv_name
                                                  || per_ri_config_main.g_job_rv_struct_def_string);

      open csr_config_jobs_rv_seg(p_configuration_code
                                 ,l_jobs_rv_name_orig);
      l_jobs_segment_count := 0;
      LOOP
        fetch csr_config_jobs_rv_seg into l_rv_jobs_segment_type
                                         ,l_rv_jobs_segment_name
                                         ,l_jobs_segment_no;
        exit when csr_config_jobs_rv_seg%NOTFOUND;

        -- Create Jobs Key Flex Segments
        l_jobs_segment_count := csr_config_jobs_rv_seg%ROWCOUNT;
        if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'JOB'
                        ,p_structure_code            => l_jobs_rv_name
                                                        || per_ri_config_main.g_job_rv_struct_def_string
                        ,p_segment_name              => l_rv_jobs_segment_name
                        ,p_column_name               => 'SEGMENT' || l_jobs_segment_count
                        ,p_segment_number            => l_jobs_segment_no --l_jobs_segment_count
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_rv_jobs_segment_name
                        ,p_segment_type              => l_rv_jobs_segment_type
                        ,p_window_prompt             => l_rv_jobs_segment_name);
        else
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).appl_short_name  := 'PER';
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).flex_code        := 'JOB';
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).structure_code   :=  l_jobs_rv_name
                                                                          || per_ri_config_main.g_job_rv_struct_def_string;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).segment_name     :=  l_rv_jobs_segment_name;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).column_name      :=  'SEGMENT' || l_jobs_segment_count;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).segment_number   :=  l_jobs_segment_no;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).value_set        :=  null;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).lov_prompt       := l_rv_jobs_segment_name;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).segment_type     := l_rv_jobs_segment_type;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).window_prompt    := l_rv_jobs_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_rv_jobs_segment_type
                                 ,p_structure_code  => l_jobs_rv_name
                                                       || per_ri_config_main.g_job_rv_struct_def_string
                                 ,p_segment_name    => l_jobs_rv_name
                                 ,p_segment_number  => l_jobs_segment_no
                                 ,p_valueset_tab    => l_kf_job_rv_valueset_tab);

          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_value_set_name
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_description
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_security_available
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_enable_longlist
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_format_type
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_maximum_size
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_precision
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_numbers_only
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_uppercase_only
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_min_value
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_job_rv_seg_tab(l_kf_job_rv_seg_count).vs_max_value
                         := l_kf_job_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_job_rv_seg_count := l_kf_job_rv_seg_count + 1 ;
        end if;

        per_ri_config_utilities.write_log(p_message => 'Created Grade Key Flex RV Segment' || l_rv_jobs_segment_name);
        hr_utility.trace('Created Job Key Flex RV Segment: ' ||  l_rv_jobs_segment_name);
      END LOOP;
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'JOB'
                       ,p_structure_code            => l_jobs_rv_name
                                                         || per_ri_config_main.g_job_rv_struct_def_string);
      end if;
      close csr_config_jobs_rv_seg;
    END IF;
    END LOOP;
    close csr_config_jobs_rv;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_jobs_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_positions_rv_keyflex
  -- Purpose   : This procedure creates positions keyflex structures, segments and
  --             valuesets when regional variance are not defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_positions_rv_keyflex (p_configuration_code in varchar2
                                        ,p_technical_summary_mode in boolean default FALSE
                                        ,p_kf_pos_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_rv_tab
                                        ,p_kf_pos_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_rv_seg_tab) IS

  cursor csr_config_positions_rv (cp_configuration_code in varchar2) IS
    select distinct per_ri_config_utilities.return_config_entity_name(regional_variance_name),
           regional_variance_name, REG_VARIANCE_COUNTRY_CODE
      from per_ri_config_jp_rv_v
     where configuration_code = cp_configuration_code
       and exists (select configuration_code
                     from per_ri_config_pos_rv_seg_v
                    where configuration_code   = cp_configuration_code);

    cursor csr_config_positions_rv_seg (cp_configuration_code in varchar2
                                       ,cp_positions_rv_name         in varchar2) IS
    select distinct segment_type
                   ,segment_name
                   ,CONFIG_SEQUENCE
      from per_ri_config_pos_rv_seg_v
     where configuration_code        = cp_configuration_code
       and regional_variance_name    = cp_positions_rv_name
       order by CONFIG_SEQUENCE;

  l_proc                         varchar2(72) := g_package || 'create_positions_rv_keyflex';
  l_error_message                varchar2(360);
  l_kf_pos_rv_count              number(8) := 0;
  l_kf_pos_rv_tab                per_ri_config_tech_summary.kf_pos_rv_tab;

  l_kf_pos_rv_seg_count          number(8) := 0;
  l_kf_pos_rv_seg_tab            per_ri_config_tech_summary.kf_pos_rv_tab;

  l_kf_pos_rv_valueset_tab       per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_positions_rv_name            per_ri_config_information.config_information1%type;
  l_positions_rv_name_orig       per_ri_config_information.config_information1%type;

  l_rv_positions_segment_type    per_ri_config_information.config_information1%type;
  l_rv_positions_segment_name    per_ri_config_information.config_information1%type;
  l_positions_keyflex_number     number(9);
  l_positions_structures_code    fnd_id_flex_structures.id_flex_structure_code%type;

  l_positions_segment_count        number(9);
  l_positions_segment_no           number(9);

  l_country_selected          varchar2(10);
  l_rv_country_code           varchar2(10);
  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    select legislation_code into l_country_selected from per_business_groups
      where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;

    open csr_config_positions_rv(p_configuration_code);
    LOOP
      fetch csr_config_positions_rv into l_positions_rv_name,l_positions_rv_name_orig,l_rv_country_code;

      exit when csr_config_positions_rv%NOTFOUND;

      hr_utility.set_location(l_proc, 20);
    IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
        AND l_rv_country_code = l_country_selected THEN
         hr_utility.set_location('skip the creation of the flexfield structure', 90);
    ELSE
      -- Create Jobs RV Key flex
      if NOT (p_technical_summary_mode) then
        l_positions_keyflex_number  := per_ri_config_utilities.create_key_flexfield
                           (p_appl_short_Name => 'PER'
                           ,p_flex_code       => 'POS'
                           ,p_structure_code  => l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string
                           ,p_structure_title => l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string
                           ,p_description     => l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string
                                                               || per_ri_config_main.g_description_suffix_string);

      else
        p_kf_pos_rv_tab(l_kf_pos_rv_count).appl_short_name    := 'PER';
        p_kf_pos_rv_tab(l_kf_pos_rv_count).flex_code          := 'POS';
        p_kf_pos_rv_tab(l_kf_pos_rv_count).structure_code     := l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string;
        p_kf_pos_rv_tab(l_kf_pos_rv_count).structure_title    := l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string;
        p_kf_pos_rv_tab(l_kf_pos_rv_count).description        := l_positions_rv_name || per_ri_config_main.g_pos_rv_struct_def_string
                                                                ||  per_ri_config_main.g_description_suffix_string;
        l_kf_pos_rv_count := l_kf_pos_rv_count + 1 ;
      end if;
      per_ri_config_utilities.write_log(p_message => 'Created Positions RV Keyflex ' || l_positions_rv_name
                                                     || per_ri_config_main.g_pos_rv_struct_def_string );
      hr_utility.trace('Created Positions RV Keyflex ' || l_positions_rv_name
                                                  || per_ri_config_main.g_pos_rv_struct_def_string);

      open csr_config_positions_rv_seg(p_configuration_code
                                      ,l_positions_rv_name_orig);
      l_positions_segment_count := 0;
      LOOP
        fetch csr_config_positions_rv_seg into l_rv_positions_segment_type
                                         ,l_rv_positions_segment_name
                                         ,l_positions_segment_no;
        exit when csr_config_positions_rv_seg%NOTFOUND;

        -- Create Jobs Key Flex Segments
        l_positions_segment_count := csr_config_positions_rv_seg%ROWCOUNT;
        if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            => l_positions_rv_name
                                                        || per_ri_config_main.g_pos_rv_struct_def_string
                        ,p_segment_name              => l_rv_positions_segment_name
                        ,p_column_name               => 'SEGMENT' || l_positions_segment_count
                        ,p_segment_number            => l_positions_segment_no
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_rv_positions_segment_name
                        ,p_segment_type              => l_rv_positions_segment_type
                        ,p_window_prompt             => l_rv_positions_segment_name);

        else
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).appl_short_name  := 'PER';
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).flex_code        := 'POS';
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).structure_code   :=  l_positions_rv_name
                                                                         || per_ri_config_main.g_pos_rv_struct_def_string;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).segment_name     :=  l_rv_positions_segment_name;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).column_name      := 'SEGMENT' || l_positions_segment_count;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).segment_number   :=  l_positions_segment_no;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).value_set        := null;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).lov_prompt       := l_rv_positions_segment_name;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).segment_type     := l_rv_positions_segment_type;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).window_prompt    := l_rv_positions_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_rv_positions_segment_type
                                 ,p_structure_code  => l_positions_rv_name
                                                       || per_ri_config_main.g_pos_rv_struct_def_string
                                 ,p_segment_name    => l_rv_positions_segment_name
                                 ,p_segment_number  => l_positions_segment_no
                                 ,p_valueset_tab    => l_kf_pos_rv_valueset_tab);

          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_value_set_name
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_description
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_security_available
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_enable_longlist
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_format_type
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_maximum_size
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_precision
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_numbers_only
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_uppercase_only
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_min_value
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_pos_rv_seg_tab(l_kf_pos_rv_seg_count).vs_max_value
                         := l_kf_pos_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_pos_rv_seg_count := l_kf_pos_rv_seg_count + 1 ;
    end if;
        per_ri_config_utilities.write_log(p_message => 'Created Positions Key Flex RV Segment' || l_rv_positions_segment_name);
        hr_utility.trace('Created Positions Key Flex RV Segment: ' ||  l_rv_positions_segment_name);
      END LOOP;
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                         (p_appl_short_Name           => 'PER'
                         ,p_flex_code                 => 'POS'
                         ,p_structure_code            =>  l_positions_rv_name
                                                          || per_ri_config_main.g_pos_rv_struct_def_string);
      end if;
      close csr_config_positions_rv_seg;
    END IF;
    END LOOP;
    close csr_config_positions_rv;
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_positions_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_grades_rv_keyflex
  -- Purpose   : This procedure creates grades keyflex structures, segments and
  --             valuesets when regional variance are not defined.
  --             and profiles options assigned to it.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_grades_rv_keyflex (p_configuration_code in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_kf_grd_rv_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_rv_tab
                                     ,p_kf_grd_rv_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grd_rv_seg_tab) IS

  cursor csr_config_grade_rv (cp_configuration_code in varchar2) IS
    select distinct per_ri_config_utilities.return_config_entity_name(regional_variance_name),
           regional_variance_name, REG_VARIANCE_COUNTRY_CODE
      from per_ri_config_grd_rv_v
     where configuration_code = cp_configuration_code;

    cursor csr_config_grade_rv_seg (cp_configuration_code in varchar2
                                   ,cp_grade_rv_name         in varchar2) IS
    select distinct segment_type
                   ,segment_name
                   ,CONFIG_SEQUENCE
      from per_ri_config_grd_rv_seg_v
     where configuration_code        = cp_configuration_code
       and regional_variance_name    = cp_grade_rv_name
       order by CONFIG_SEQUENCE;

  l_proc                      varchar2(72) := g_package || 'create_grades_rv_keyflex';
  l_error_message             varchar2(360);

  l_kf_grd_rv_count           number(8) := 0;
  l_kf_grd_rv_tab             per_ri_config_tech_summary.kf_grd_rv_tab;
  l_kf_grd_rv_seg_count       number(8) := 0;
  l_kf_grd_rv_seg_tab         per_ri_config_tech_summary.kf_grd_rv_tab;

  l_kf_grd_rv_valueset_tab    per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count       number(9) := 1;

  l_grade_rv_name               per_ri_config_information.config_information1%type;
  l_grade_rv_name_orig          per_ri_config_information.config_information1%type;

  l_rv_grade_segment_name       per_ri_config_information.config_information1%type;
  l_rv_grade_segment_type       per_ri_config_information.config_information1%type;
  l_grades_keyflex_number       number(9);
  l_grade_structures_code       fnd_id_flex_structures.id_flex_structure_code%type;

  l_grades_segment_count        number(9);
  l_grades_segment_no           number(9);

  l_country_selected          varchar2(10);
  l_rv_country_code           varchar2(10);
  l_multi_tenancy                 boolean default false;
  l_system_model                  varchar2(10) := 'N';
  l_sec_group_id                  varchar2(10);
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    select legislation_code into l_country_selected from per_business_groups
      where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

    l_multi_tenancy := hr_multi_tenancy_pkg.is_multi_tenant_system;
    l_sec_group_id := fnd_global.security_group_id;
    if l_multi_tenancy then
        l_system_model := hr_multi_tenancy_pkg.get_system_model;
    end if;

    open csr_config_grade_rv(p_configuration_code);
    LOOP
      fetch csr_config_grade_rv into l_grade_rv_name,l_grade_rv_name_orig,l_rv_country_code;

      exit when csr_config_grade_rv%NOTFOUND;

      -- Create Grades RV Key Flex
      hr_utility.set_location(l_proc, 20);
    IF l_multi_tenancy AND l_system_model = 'B' AND l_sec_group_id <> '0'
        AND l_rv_country_code = l_country_selected THEN
         hr_utility.set_location('skip the creation of the flexfield structure', 90);
    ELSE
      if NOT (p_technical_summary_mode) then
        l_grades_keyflex_number  :=
               per_ri_config_utilities.create_key_flexfield
                       (p_appl_short_Name => 'PER'
                       ,p_flex_code       => 'GRD'
                       ,p_structure_code  => l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string
                       ,p_structure_title => l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string
                       ,p_description     => l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string
                                                             || per_ri_config_main.g_description_suffix_string);

      else
        p_kf_grd_rv_tab(l_kf_grd_rv_count).appl_short_name    := 'PER';
        p_kf_grd_rv_tab(l_kf_grd_rv_count).flex_code          := 'GRD';
        p_kf_grd_rv_tab(l_kf_grd_rv_count).structure_code     := l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string;
        p_kf_grd_rv_tab(l_kf_grd_rv_count).structure_title    := l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string;
        p_kf_grd_rv_tab(l_kf_grd_rv_count).description        := l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string
                                                                   || per_ri_config_main.g_description_suffix_string;
        l_kf_grd_rv_count := l_kf_grd_rv_count + 1 ;
    end if;
      per_ri_config_utilities.write_log(p_message => 'Created Grades RV Keyflex '
                                                     || per_ri_config_main.g_grd_rv_struct_def_string );
      hr_utility.trace('Created Grades RV Keyflex ' || per_ri_config_main.g_grd_rv_struct_def_string);

      open csr_config_grade_rv_seg(p_configuration_code
                                  ,l_grade_rv_name_orig);
      l_grades_segment_count := 0;
      LOOP
        fetch csr_config_grade_rv_seg into l_rv_grade_segment_type
                                          ,l_rv_grade_segment_name
                                          ,l_grades_segment_no;
        exit when csr_config_grade_rv_seg%NOTFOUND;

        -- Create Jobs Key Flex Segments
        l_grades_segment_count := csr_config_grade_rv_seg%ROWCOUNT;
        if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'GRD'
                        ,p_structure_code            => l_grade_rv_name || per_ri_config_main.g_grd_rv_struct_def_string
                        ,p_segment_name              => l_rv_grade_segment_name
                        ,p_column_name               => 'SEGMENT' || l_grades_segment_count
                        ,p_segment_number            => l_grades_segment_no
                        ,p_value_set                 => null
                        ,p_lov_prompt                => l_rv_grade_segment_name
                        ,p_segment_type              => l_rv_grade_segment_type
                        ,p_window_prompt             => l_rv_grade_segment_name);
        else
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).appl_short_name  := 'PER';
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).flex_code        := 'GRD';
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).structure_code   :=  l_grade_rv_name
                                                                         || per_ri_config_main.g_grd_rv_struct_def_string;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).segment_name     :=  l_rv_grade_segment_name;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).column_name      := 'SEGMENT' || l_grades_segment_count;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).segment_number   :=  l_grades_segment_no;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).value_set        := null;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).lov_prompt       := l_rv_grade_segment_name;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).segment_type     := l_rv_grade_segment_type;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).window_prompt    := l_rv_grade_segment_name;

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => l_rv_grade_segment_type
                                 ,p_structure_code  => l_grade_rv_name
                                                       || per_ri_config_main.g_grd_rv_struct_def_string
                                 ,p_segment_name    => l_rv_grade_segment_name
                                 ,p_segment_number  => l_grades_segment_no
                                 ,p_valueset_tab    => l_kf_grd_rv_valueset_tab);

          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_value_set_name
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_description
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).description;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_security_available
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_enable_longlist
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_format_type
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_maximum_size
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_precision
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).precision;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_numbers_only
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_uppercase_only
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_right_justify_zero_fill
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_min_value
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_grd_rv_seg_tab(l_kf_grd_rv_seg_count).vs_max_value
                         := l_kf_grd_rv_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_grd_rv_seg_count := l_kf_grd_rv_seg_count + 1 ;
        end if;
        per_ri_config_utilities.write_log(p_message => 'Created Grade Key Flex RV Segment' || l_rv_grade_segment_name);
        hr_utility.trace('Created Job Key Flex RV Segment: ' ||  l_rv_grade_segment_name);
      END LOOP;
      close csr_config_grade_rv_seg;
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            =>  l_grade_rv_name
                                                        || per_ri_config_main.g_grd_rv_struct_def_string);
      end if;
    END IF;
    END LOOP;
    close csr_config_grade_rv;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_grades_rv_keyflex;

  /* --------------------------------------------------------------------------
  -- Name      : create_global_grp_cmp_cost_kf
  -- Purpose   : This procedure creates global People Group, Competence and
  --             Cost allocation key flex structures, segments and
  --             valuesets.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_global_grp_cmp_cost_kf (p_configuration_code in varchar2
                                          ,p_technical_summary_mode in boolean default FALSE
                                          ,p_kf_grp_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grp_tab
                                          ,p_kf_cmp_tab in out nocopy
                                               per_ri_config_tech_summary.kf_cmp_tab
                                          ,p_kf_cost_tab in out nocopy
                                               per_ri_config_tech_summary.kf_cost_tab
                                          ,p_kf_grp_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_grp_seg_tab
                                          ,p_kf_cmp_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_cmp_seg_tab
                                          ,p_kf_cost_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_cost_seg_tab) IS

  l_kf_grp_tab                per_ri_config_tech_summary.kf_grp_tab;
  l_kf_cmp_tab                per_ri_config_tech_summary.kf_cmp_tab;
  l_kf_cost_tab               per_ri_config_tech_summary.kf_cost_tab;

  l_kf_grp_seg_tab            per_ri_config_tech_summary.kf_grp_seg_tab;
  l_kf_cmp_seg_tab            per_ri_config_tech_summary.kf_cmp_seg_tab;
  l_kf_cost_seg_tab           per_ri_config_tech_summary.kf_cost_seg_tab;

  l_kf_grp_valueset_tab       per_ri_config_tech_summary.valueset_tab;
  l_kf_cmp_valueset_tab       per_ri_config_tech_summary.valueset_tab;
  l_kf_cost_valueset_tab      per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count       number(9) := 1;

  l_proc                      varchar2(72) := g_package || 'create_global_grp_cmp_cost_kf';
  l_error_message             varchar2(360);
  l_configuration_code        per_ri_config_information.configuration_code%type;
  l_people_group_fk_number    number(9);
  l_competence_fk_number      number(9);
  l_cost_allocation_number    number(9);

  l_enterprise_short_name     per_ri_config_information.configuration_code%type;

  l_grp_structures_code       fnd_id_flex_structures.id_flex_structure_code%type;
  l_cmp_structures_code       fnd_id_flex_structures.id_flex_structure_code%type;
  l_cost_structures_code      fnd_id_flex_structures.id_flex_structure_code%type;

  l_kf_grp_count              number(8) := 0;
  l_kf_cmp_count              number(8) := 0;
  l_kf_cost_count             number(8) := 0;

  l_kf_grp_seg_count          number(8) :=0;
  l_kf_cmp_seg_count          number(8) :=0;
  l_kf_cost_seg_count         number(8) :=0;
  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    --
    -- create people group key flex
    --
    l_grp_structures_code := per_ri_config_main.g_global_pea_structure_name;
    if NOT (p_technical_summary_mode) then
      l_people_group_fk_number  := per_ri_config_utilities.create_key_flexfield
                                     (p_appl_short_Name   => 'PAY'
                                     ,p_flex_code         => 'GRP'
                                     ,p_structure_code    => l_grp_structures_code
                                     ,p_structure_title   => l_grp_structures_code
                                     ,p_description       => l_grp_structures_code);

    else
      p_kf_grp_tab(l_kf_grp_count).appl_short_name    := 'PAY';
      p_kf_grp_tab(l_kf_grp_count).flex_code          := 'GRP';
      p_kf_grp_tab(l_kf_grp_count).structure_code     := l_grp_structures_code;
      p_kf_grp_tab(l_kf_grp_count).structure_title    := l_grp_structures_code;
      p_kf_grp_tab(l_kf_grp_count).description        := l_grp_structures_code;
    end if;

    hr_utility.trace('Created People Group Key Flex: ' || l_grp_structures_code );

    --
    -- create people group flex segments
    --
    if NOT (p_technical_summary_mode) then
    per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PAY'
                    ,p_flex_code                 => 'GRP'
                    ,p_structure_code            => l_grp_structures_code
                    ,p_segment_name              => 'People Group Name'
                    ,p_column_name               => 'SEGMENT1'
                    ,p_segment_number            => 1
                    ,p_value_set                 => null
                    ,p_lov_prompt                =>  'People Group'
                    ,p_window_prompt             =>  'People Group');

    else
      p_kf_grp_seg_tab(l_kf_grp_seg_count).appl_short_name  := 'PAY';
      p_kf_grp_seg_tab(l_kf_grp_seg_count).flex_code        := 'GRP';
      p_kf_grp_seg_tab(l_kf_grp_seg_count).structure_code   :=  l_grp_structures_code;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).segment_name     :=  'People Group Name';
      p_kf_grp_seg_tab(l_kf_grp_seg_count).column_name      :=  'SEGMENT1';
      p_kf_grp_seg_tab(l_kf_grp_seg_count).segment_number   :=  1;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).value_set        := null;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).lov_prompt       := 'People Group';
      p_kf_grp_seg_tab(l_kf_grp_seg_count).segment_type     := null;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).window_prompt    := 'People Group';

      --create technical summary data for valueset
      per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                             ,p_valueset_type   => null
                             ,p_structure_code  => l_grp_structures_code
                             ,p_segment_name    => 'People Group Name'
                             ,p_segment_number  => 1
                             ,p_valueset_tab    => l_kf_grp_valueset_tab);


      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_value_set_name
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).value_set_name;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_description
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).description;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_security_available
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).security_available;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_enable_longlist
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).enable_longlist;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_format_type
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).format_type;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_maximum_size
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).maximum_size;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_precision
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).precision;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_numbers_only
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).numbers_only;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_uppercase_only
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).uppercase_only;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_right_justify_zero_fill
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_min_value
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).min_value;
      p_kf_grp_seg_tab(l_kf_grp_seg_count).vs_max_value
                     := l_kf_grp_valueset_tab(l_value_set_tab_count).max_value;
      l_kf_grp_seg_count := l_kf_grp_seg_count + 1 ;
    end if;

    hr_utility.trace('Created People Group Key Flex Segment: ' || l_grp_structures_code);

    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PAY'
                       ,p_flex_code                 => 'GRP'
                       ,p_structure_code            => l_grp_structures_code);
    end if;



    --
    -- create competence key flex
    --
    l_cmp_structures_code := per_ri_config_main.g_global_cmp_structure_name;
    if NOT (p_technical_summary_mode) then
      l_competence_fk_number  := per_ri_config_utilities.create_key_flexfield
                                     (p_appl_short_Name   => 'PER'
                                     ,p_flex_code         => 'CMP'
                                     ,p_structure_code    => l_cmp_structures_code
                                     ,p_structure_title   => l_cmp_structures_code
                                     ,p_description       => l_cmp_structures_code);

    else
      p_kf_cmp_tab(l_kf_cmp_count).appl_short_name    := 'PER';
      p_kf_cmp_tab(l_kf_cmp_count).flex_code          := 'CMP';
      p_kf_cmp_tab(l_kf_cmp_count).structure_code     := l_cmp_structures_code;
      p_kf_cmp_tab(l_kf_cmp_count).structure_title    := l_cmp_structures_code;
      p_kf_cmp_tab(l_kf_cmp_count).description        := l_cmp_structures_code;
    end if;

    hr_utility.trace('Created Competence Group Key Flex: ' || l_cmp_structures_code);

    --
    -- create competence flex segments
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PER'
                    ,p_flex_code                 => 'CMP'
                    ,p_structure_code            => l_cmp_structures_code
                    ,p_segment_name              => 'Competence Name'
                    ,p_column_name               => 'SEGMENT1'
                    ,p_segment_number            => 1
                    ,p_value_set                 => null
                    ,p_lov_prompt                =>  'Competence Name'
                    ,p_window_prompt             =>  'Competence Name');
    else
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).appl_short_name  := 'PER';
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).flex_code        := 'CMP';
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).structure_code   := l_cmp_structures_code;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).segment_name     := 'Competence Name';
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).column_name      := 'SEGMENT1';
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).segment_number   := 1;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).value_set        := null;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).lov_prompt       := 'Competence Name';
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).segment_type     := null;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).window_prompt    := 'Competence Name';

      --create technical summary data for valueset
      per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                             ,p_valueset_type   => null
                             ,p_structure_code  => l_cmp_structures_code
                             ,p_segment_name    => 'Competence Name'
                             ,p_segment_number  => 1
                             ,p_valueset_tab    => l_kf_cmp_valueset_tab);

      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_value_set_name
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).value_set_name;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_description
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).description;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_security_available
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).security_available;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_enable_longlist
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).enable_longlist;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_format_type
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).format_type;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_maximum_size
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).maximum_size;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_precision
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).precision;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_numbers_only
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).numbers_only;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_uppercase_only
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).uppercase_only;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_right_justify_zero_fill
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_min_value
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).min_value;
      p_kf_cmp_seg_tab(l_kf_cmp_seg_count).vs_max_value
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).max_value;
      l_kf_cmp_seg_count := l_kf_cmp_seg_count + 1 ;
    end if;

    hr_utility.trace('Created Competence Key Flex Segment: l_cmp_structures_code' );

    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'CMP'
                       ,p_structure_code            => l_cmp_structures_code);
    end if;

    --
    -- create cost allocation key flex
    --
    l_cost_structures_code := per_ri_config_main.g_global_cst_structure_name;
    if NOT (p_technical_summary_mode) then
      l_cost_allocation_number  := per_ri_config_utilities.create_key_flexfield
                                     (p_appl_short_Name   => 'PAY'
                                     ,p_flex_code         => 'COST'
                                     ,p_structure_code    => l_cost_structures_code
                                     ,p_structure_title   => l_cost_structures_code
                                     ,p_description       => l_cost_structures_code);

    else
      p_kf_cost_tab(l_kf_cost_count).appl_short_name    := 'PAY';
      p_kf_cost_tab(l_kf_cost_count).flex_code          := 'COST';
      p_kf_cost_tab(l_kf_cost_count).structure_code     := l_cost_structures_code;
      p_kf_cost_tab(l_kf_cost_count).structure_title    := l_cost_structures_code;
      p_kf_cost_tab(l_kf_cost_count).description        := l_cost_structures_code;
    end if;

    hr_utility.trace('Created Cost Allocation Key Flex: ' || l_cost_structures_code);

    --
    -- create cost allocation flex segments
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PAY'
                    ,p_flex_code                 => 'COST'
                    ,p_structure_code            => l_cost_structures_code
                    ,p_segment_name              => 'Account'
                    ,p_column_name               => 'SEGMENT1'
                    ,p_segment_number            => 1
                    ,p_value_set                 => null
                    ,p_lov_prompt                =>  'Account'
                    ,p_window_prompt             =>  'Account');
    else
      p_kf_cost_seg_tab(l_kf_cost_seg_count).appl_short_name  := 'PAY';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).flex_code        := 'COST';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).structure_code   := l_cost_structures_code;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_name     := 'Account';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).column_name      := 'SEGMENT1';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_number   := 1;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).value_set        := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).lov_prompt       := 'Account';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_type     := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).window_prompt    := 'Account';

      --create technical summary data for valueset
      per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                             ,p_valueset_type   => null
                             ,p_structure_code  => l_cost_structures_code
                             ,p_segment_name    => 'Account'
                             ,p_segment_number  => 1
                             ,p_valueset_tab    => l_kf_cost_valueset_tab);

      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_value_set_name
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).value_set_name;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_description
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).description;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_security_available
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).security_available;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_enable_longlist
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).enable_longlist;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_format_type
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).format_type;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_maximum_size
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).maximum_size;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_precision
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).precision;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_numbers_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).numbers_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_uppercase_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).uppercase_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_right_justify_zero_fill
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_min_value
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).min_value;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_max_value
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).max_value;
      l_kf_cost_seg_count := l_kf_cost_seg_count + 1 ;
      hr_utility.trace('ENABLELONGLIST := ' || l_kf_cost_valueset_tab(l_value_set_tab_count).enable_longlist);
    end if;

    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PAY'
                    ,p_flex_code                 => 'COST'
                    ,p_structure_code            => l_cost_structures_code
                    ,p_segment_name              => 'Company'
                    ,p_column_name               => 'SEGMENT2'
                    ,p_segment_number            => 2
                    ,p_value_set                 => null
                    ,p_lov_prompt                =>  'Company'
                   ,p_window_prompt             =>  'Company');
    else
      p_kf_cost_seg_tab(l_kf_cost_seg_count).appl_short_name  := 'PAY';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).flex_code        := 'COST';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).structure_code   := l_cost_structures_code;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_name     := 'Company';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).column_name      := 'SEGMENT2';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_number   := 2;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).value_set        := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).lov_prompt       := 'Company';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_type     := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).window_prompt    := 'Company';

      --create technical summary data for valueset
      per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                             ,p_valueset_type   => null
                             ,p_structure_code  => l_cost_structures_code
                             ,p_segment_name    => 'Company'
                             ,p_segment_number  => 2
                             ,p_valueset_tab    => l_kf_cost_valueset_tab);

      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_value_set_name
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).value_set_name;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_description
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).description;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_security_available
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).security_available;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_enable_longlist
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).enable_longlist;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_format_type
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).format_type;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_maximum_size
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).maximum_size;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_precision
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).precision;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_numbers_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).numbers_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_uppercase_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).uppercase_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_right_justify_zero_fill
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_min_value
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).min_value;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_max_value
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).max_value;
      l_kf_cost_seg_count := l_kf_cost_seg_count + 1 ;
    end if;

    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PAY'
                    ,p_flex_code                 => 'COST'
                    ,p_structure_code            => l_cost_structures_code
                    ,p_segment_name              => 'Cost Center'
                    ,p_column_name               => 'SEGMENT3'
                    ,p_segment_number            => 3
                    ,p_value_set                 => null
                    ,p_lov_prompt                =>  'Cost Center'
                    ,p_window_prompt             =>  'Cost Center');

    else
      p_kf_cost_seg_tab(l_kf_cost_seg_count).appl_short_name  := 'PAY';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).flex_code        := 'COST';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).structure_code   := l_cost_structures_code;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_name     := 'Cost Center';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).column_name      := 'SEGMENT3';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_number   := 3;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).value_set        := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).lov_prompt       := 'Cost Center';
      p_kf_cost_seg_tab(l_kf_cost_seg_count).segment_type     := null;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).window_prompt    := 'Cost Center';

      --create technical summary data for valueset
      per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                             ,p_valueset_type   => null
                             ,p_structure_code  => l_cost_structures_code
                             ,p_segment_name    => 'Cost Center'
                             ,p_segment_number  => 3
                             ,p_valueset_tab    => l_kf_cost_valueset_tab);

      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_value_set_name
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).value_set_name;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_description
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).description;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_security_available
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).security_available;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_enable_longlist
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).enable_longlist;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_format_type
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).format_type;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_maximum_size
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).maximum_size;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_precision
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).precision;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_numbers_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).numbers_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_uppercase_only
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).uppercase_only;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_right_justify_zero_fill
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_min_value
                     := l_kf_cost_valueset_tab(l_value_set_tab_count).min_value;
      p_kf_cost_seg_tab(l_kf_cost_seg_count).vs_max_value
                     := l_kf_cmp_valueset_tab(l_value_set_tab_count).max_value;

      l_kf_cost_seg_count := l_kf_cost_seg_count + 1 ;
    end if;
    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PAY'
                       ,p_flex_code                 => 'COST'
                       ,p_structure_code            => l_cost_structures_code);
    end if;
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_global_grp_cmp_cost_kf;

  /* --------------------------------------------------------------------------
  -- Name      : create_global_job_pos_kf
  -- Purpose   : This procedure creates global jobs and positions keyflex structures,
  --             segments and valuesets when jobs/positions are not defined.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_global_job_pos_kf (p_configuration_code in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_kf_job_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_tab
                                     ,p_kf_pos_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_tab
                                     ,p_kf_job_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_job_seg_tab
                                     ,p_kf_pos_seg_tab in out nocopy
                                               per_ri_config_tech_summary.kf_pos_seg_tab) IS

  l_proc                         varchar2(72) := g_package || 'create_global_job_pos_kf';
  l_configuration_code           per_ri_config_information.configuration_code%type;
  l_jobs_fk_number               number(9);
  l_position_fk_number           number(9);

  l_enterprise_short_name        per_ri_config_information.configuration_code%type;

  l_job_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;
  l_pos_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;

  l_kf_job_tab                   per_ri_config_tech_summary.kf_job_tab;
  l_kf_pos_tab                   per_ri_config_tech_summary.kf_pos_tab;
  l_kf_job_count                 number(8) :=0;
  l_kf_pos_count                 number(8) :=0;

  l_kf_job_seg_tab               per_ri_config_tech_summary.kf_job_seg_tab;
  l_kf_pos_seg_tab               per_ri_config_tech_summary.kf_pos_seg_tab;
  l_kf_job_seg_count             number(8) :=0;
  l_kf_pos_seg_count             number(8) :=0;

  l_kf_job_valueset_tab          per_ri_config_tech_summary.valueset_tab;
  l_kf_pos_valueset_tab          per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);

    -- Create Global Jobs Key flex
    hr_utility.set_location(l_proc, 20);
    l_job_structures_code := per_ri_config_utilities.return_config_entity_name
                               (per_ri_config_main.g_global_job_structure_name);


    if NOT (p_technical_summary_mode) then
      l_jobs_fk_number  := per_ri_config_utilities.create_key_flexfield
                                     (p_appl_short_name   => 'PER'
                                     ,p_flex_code         => 'JOB'
                                     ,p_structure_code    => l_job_structures_code
                                     ,p_structure_title   => l_job_structures_code
                                     ,p_description       => l_job_structures_code);


    else
      p_kf_job_tab(l_kf_job_count).appl_short_name    := 'PER';
      p_kf_job_tab(l_kf_job_count).flex_code          := 'JOB';
      p_kf_job_tab(l_kf_job_count).structure_code     := l_job_structures_code;
      p_kf_job_tab(l_kf_job_count).structure_title    := l_job_structures_code;
      p_kf_job_tab(l_kf_job_count).description        := l_job_structures_code;
      l_kf_job_count := l_kf_job_count + 1 ;
    end if;

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                   (p_configuration_code => p_configuration_code);

    l_log_message := 'Created KEYFLEX PER JOB ' || l_job_structures_code;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    -- Create Position Key flex
    hr_utility.set_location(l_proc, 30);
    l_pos_structures_code :=  per_ri_config_utilities.return_config_entity_name
                               (per_ri_config_main.g_global_pos_structure_name);
    if NOT (p_technical_summary_mode) then
      l_position_fk_number  := per_ri_config_utilities.create_key_flexfield
                                   (p_appl_short_Name   => 'PER'
                                   ,p_flex_code         => 'POS'
                                   ,p_structure_code    => l_pos_structures_code
                                   ,p_structure_title   => l_pos_structures_code
                                   ,p_description       => l_pos_structures_code);
    else
      p_kf_pos_tab(l_kf_pos_count).appl_short_name    := 'PER';
      p_kf_pos_tab(l_kf_pos_count).flex_code          := 'POS';
      p_kf_pos_tab(l_kf_pos_count).structure_code     := l_pos_structures_code;
      p_kf_pos_tab(l_kf_pos_count).structure_title    := l_pos_structures_code;
      p_kf_pos_tab(l_kf_pos_count).description        := l_pos_structures_code;
      l_kf_pos_count := l_kf_pos_count + 1 ;
    end if;


    l_log_message := 'Created KEYFLEX PER POS ' || l_pos_structures_code;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    hr_utility.set_location(l_proc, 40);

    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
       hr_utility.set_location(l_proc, 50);

       -- Create Jobs Key Flex Segments

       if NOT (p_technical_summary_mode) then
         per_ri_config_utilities.create_flex_segments
                    (p_appl_short_Name           => 'PER'
                    ,p_flex_code                 => 'JOB'
                    ,p_structure_code            => l_job_structures_code
                    ,p_segment_name              => 'Job Name'
                    ,p_column_name               => 'SEGMENT1'
                    ,p_segment_number            => 1
                    ,p_value_set                 => null
                    ,p_lov_prompt                => 'Job Name'
                    ,p_window_prompt             => 'Job Name');
       else
         p_kf_job_seg_tab(l_kf_job_seg_count).appl_short_name  := 'PER';
         p_kf_job_seg_tab(l_kf_job_seg_count).flex_code        := 'JOB';
         p_kf_job_seg_tab(l_kf_job_seg_count).structure_code   := l_job_structures_code;
         p_kf_job_seg_tab(l_kf_job_seg_count).segment_name     :=  'Job Name';
         p_kf_job_seg_tab(l_kf_job_seg_count).column_name      := 'SEGMENT1';
         p_kf_job_seg_tab(l_kf_job_seg_count).segment_number   := 1;
         p_kf_job_seg_tab(l_kf_job_seg_count).value_set        := null;
         p_kf_job_seg_tab(l_kf_job_seg_count).lov_prompt       := 'Job Name';
         p_kf_job_seg_tab(l_kf_job_seg_count).segment_type     := null;
         p_kf_job_seg_tab(l_kf_job_seg_count).window_prompt    := 'Job Name';

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => null
                                 ,p_structure_code  => l_job_structures_code
                                 ,p_segment_name    => 'Job Name'
                                 ,p_segment_number  => 1
                                 ,p_valueset_tab    => l_kf_job_valueset_tab);

          p_kf_job_seg_tab(l_kf_job_seg_count).vs_value_set_name
                         := l_kf_job_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_description
                         := l_kf_job_valueset_tab(l_value_set_tab_count).description;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_security_available
                         := l_kf_job_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_enable_longlist
                         := l_kf_job_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_format_type
                         := l_kf_job_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_maximum_size
                         := l_kf_job_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_precision
                         := l_kf_job_valueset_tab(l_value_set_tab_count).precision;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_numbers_only
                         := l_kf_job_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_uppercase_only
                         := l_kf_job_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_right_justify_zero_fill
                         := l_kf_job_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_min_value
                         := l_kf_job_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_job_seg_tab(l_kf_job_seg_count).vs_max_value
                         := l_kf_job_valueset_tab(l_value_set_tab_count).max_value;
          l_kf_job_seg_count := l_kf_job_seg_count + 1 ;
       end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER JOB ' || 'Job Name';
      per_ri_config_utilities.write_log(p_message => l_log_message);

       -- Create Position Key Flex Segments
       if NOT (p_technical_summary_mode) then
         per_ri_config_utilities.create_flex_segments
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            => l_pos_structures_code
                       ,p_segment_name              => 'Position Name'
                       ,p_column_name               => 'SEGMENT1'
                       ,p_segment_number            => 1
                       ,p_value_set                 => null
                       ,p_lov_prompt                => 'Position Name'
                      ,p_window_prompt             => 'Position Name');
         else
           p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   := l_pos_structures_code;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Position Name';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT1';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   := 1;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := null;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Position Name';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := null;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Position Name';

           --create technical summary data for valueset
           per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => null
                                 ,p_structure_code  => l_pos_structures_code
                                 ,p_segment_name    => 'Position Name'
                                 ,p_segment_number  => 1
                                 ,p_valueset_tab    => l_kf_pos_valueset_tab);

           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
           l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
         end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || l_pos_structures_code;
      per_ri_config_utilities.write_log(p_message => l_log_message);

       hr_utility.set_location(l_proc, 60);
     else
       hr_utility.set_location(l_proc, 70);
       hr_utility.trace('Positions : Industry is US_GOVERNMENT');

      -- create only federal job segments with specified value segment name valuesets.
      -- First Segment 'Name' valueset '60 Characters'
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'JOB'
                        ,p_structure_code            => l_job_structures_code
                        ,p_segment_name              => 'Name'
                        ,p_column_name               => 'SEGMENT1'
                        ,p_segment_number            => 1
                        ,p_value_set                 => '60 Characters'
                        ,p_lov_prompt                => 'Name'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Name'
                        ,p_fed_seg_attribute         => 'Y');

      else
        p_kf_job_seg_tab(l_kf_job_seg_count).appl_short_name  := 'PER';
        p_kf_job_seg_tab(l_kf_job_seg_count).flex_code        := 'JOB';
        p_kf_job_seg_tab(l_kf_job_seg_count).structure_code   :=  l_job_structures_code;
        p_kf_job_seg_tab(l_kf_job_seg_count).segment_name     :=  'Name';
        p_kf_job_seg_tab(l_kf_job_seg_count).column_name      := 'SEGMENT1';
        p_kf_job_seg_tab(l_kf_job_seg_count).segment_number   :=  1;
        p_kf_job_seg_tab(l_kf_job_seg_count).value_set        :=  '60 Characters';
        p_kf_job_seg_tab(l_kf_job_seg_count).lov_prompt       := 'Name';
        p_kf_job_seg_tab(l_kf_job_seg_count).segment_type     := 'Char';
        p_kf_job_seg_tab(l_kf_job_seg_count).window_prompt    := 'Name';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_job_structures_code
                               ,p_segment_name    => 'Name'
                               ,p_segment_number  => 1
                               ,p_valueset_tab    => l_kf_job_valueset_tab);

        p_kf_job_seg_tab(l_kf_job_seg_count).vs_value_set_name
                       := l_kf_job_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_description
                       := l_kf_job_valueset_tab(l_value_set_tab_count).description;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_security_available
                       := l_kf_job_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_enable_longlist
                       := l_kf_job_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_format_type
                       := l_kf_job_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_maximum_size
                       := l_kf_job_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_precision
                       := l_kf_job_valueset_tab(l_value_set_tab_count).precision;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_numbers_only
                       := l_kf_job_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_uppercase_only
                       := l_kf_job_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_right_justify_zero_fill
                       := l_kf_job_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_min_value
                       := l_kf_job_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_job_seg_tab(l_kf_job_seg_count).vs_max_value
                       := l_kf_job_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_job_seg_count := l_kf_job_seg_count + 1 ;
      end if;

      -- create only federal position segments with specified value segment name valuesets.
      -- First Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            =>  l_pos_structures_code
                        ,p_segment_name              => 'Position Title'
                        ,p_column_name               => 'SEGMENT1'
                        ,p_segment_number            => 1
                        ,p_value_set                 => 'GHR_US_POSITION_TITLE'
                        ,p_lov_prompt                => 'Position Title'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Position Title'
                        ,p_fed_seg_attribute         => 'Y');

      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Position Title';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT1';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  1;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_POSITION_TITLE';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Position Title';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Position Title';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POSITION_TITLE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Position Title'
                               ,p_segment_number  => 1
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Position Title';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Second Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            =>  l_pos_structures_code
                        ,p_segment_name              => 'Description'
                        ,p_column_name               => 'SEGMENT2'
                        ,p_segment_number            => 2
                        ,p_value_set                 => 'GHR_US_POS_DESC_NUM'
                        ,p_lov_prompt                => 'Description'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Description'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Description';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT2';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  2;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_POS_DESC_NUM';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Description';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Description';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POS_DESC_NUM'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Description'
                               ,p_segment_number  => 2
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Description';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Third Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            =>  l_pos_structures_code
                        ,p_segment_name              => 'Sequence'
                        ,p_column_name               => 'SEGMENT3'
                        ,p_segment_number            => 3
                        ,p_value_set                 => 'GHR_US_SEQUENCE_NUM'
                        ,p_lov_prompt                => 'Sequence'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Sequence'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Sequence';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT3';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  3;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_SEQUENCE_NUM';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Sequence';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Sequence';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_SEQUENCE_NUM'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Sequence'
                               ,p_segment_number  => 3
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Sequence';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      -- Fourth Segment
      if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.create_flex_segments
                        (p_appl_short_Name           => 'PER'
                        ,p_flex_code                 => 'POS'
                        ,p_structure_code            =>  l_pos_structures_code
                        ,p_segment_name              => 'Agency Code'
                        ,p_column_name               => 'SEGMENT4'
                        ,p_segment_number            => 4
                        ,p_value_set                 => 'GHR_US_AGENCY_CODE'
                        ,p_lov_prompt                => 'Agency Code'
                        ,p_segment_type              => 'Char'
                        ,p_window_prompt             => 'Agency Code'
                        ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Agency Code';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT4';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  4;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_AGENCY_CODE';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Agency Code';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Agency Code';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_AGENCY_CODE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Agency Code'
                               ,p_segment_number  => 4
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Agency Code';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 90);
    end if;

    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'JOB'
                       ,p_structure_code            =>  l_job_structures_code);
    end if;

    --
    -- freeze and compile this flexfield
    --
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            =>  l_pos_structures_code);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_global_job_pos_kf;

  /* --------------------------------------------------------------------------
  -- Name      : create_global_pos_kf
  -- Purpose   : This procedure creates global positions keyflex structures,
  --             segments and valuesets when positions are not defined.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_global_pos_kf (p_configuration_code in varchar2
                                 ,p_technical_summary_mode in boolean default FALSE
                                 ,p_kf_pos_tab in out nocopy
                                           per_ri_config_tech_summary.kf_pos_tab
                                 ,p_kf_pos_seg_tab in out nocopy
                                           per_ri_config_tech_summary.kf_pos_seg_tab) IS

  l_proc                         varchar2(72) := g_package || 'create_global_pos_kf';
  l_configuration_code           per_ri_config_information.configuration_code%type;
  l_position_fk_number           number(9);

  l_enterprise_short_name        per_ri_config_information.configuration_code%type;

  l_pos_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);

  l_kf_pos_tab                   per_ri_config_tech_summary.kf_pos_tab;
  l_kf_pos_count                 number(8) :=0;
  l_kf_pos_seg_tab               per_ri_config_tech_summary.kf_pos_seg_tab;
  l_kf_pos_seg_count             number(8) :=0;

  l_kf_pos_valueset_tab          per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;


  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                   (p_configuration_code => p_configuration_code);

    -- Create Position Key flex
    hr_utility.set_location(l_proc, 20);

    l_pos_structures_code :=  per_ri_config_utilities.return_config_entity_name
                               (per_ri_config_main.g_global_pos_structure_name);
    if NOT (p_technical_summary_mode) then
      l_position_fk_number  := per_ri_config_utilities.create_key_flexfield
                                     (p_appl_short_Name   => 'PER'
                                     ,p_flex_code         => 'POS'
                                     ,p_structure_code    => l_pos_structures_code
                                     ,p_structure_title   => l_pos_structures_code
                                     ,p_description       => l_pos_structures_code);
     else
       p_kf_pos_tab(l_kf_pos_count).appl_short_name    := 'PER';
       p_kf_pos_tab(l_kf_pos_count).flex_code          := 'POS';
       p_kf_pos_tab(l_kf_pos_count).structure_code     := l_pos_structures_code;
       p_kf_pos_tab(l_kf_pos_count).structure_title    := l_pos_structures_code;
       p_kf_pos_tab(l_kf_pos_count).description        := l_pos_structures_code;
       l_kf_pos_count := l_kf_pos_count + 1 ;
    end if;

    l_log_message := 'Created KEYFLEX PER POS ' || l_pos_structures_code;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    hr_utility.set_location(l_proc, 30);

    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
       hr_utility.set_location(l_proc, 50);

       -- Create Position Key Flex Segments
       if NOT (p_technical_summary_mode) then
         per_ri_config_utilities.create_flex_segments
                         (p_appl_short_Name           => 'PER'
                         ,p_flex_code                 => 'POS'
                         ,p_structure_code            => l_pos_structures_code
                         ,p_segment_name              => 'Position Name'
                         ,p_column_name               => 'SEGMENT1'
                         ,p_segment_number            => 1
                         ,p_value_set                 => null
                         ,p_lov_prompt                => 'Position Name'
                        ,p_window_prompt             => 'Position Name');
         else
           p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   := l_pos_structures_code;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Position Name';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT1';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   := 1;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := null;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Position Name';
           p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := null;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Position Name';

           --create technical summary data for valueset
           per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => null
                                 ,p_structure_code  => l_pos_structures_code
                                 ,p_segment_name    => 'Position Name'
                                 ,p_segment_number  => 1
                                 ,p_valueset_tab    => l_kf_pos_valueset_tab);

           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
           p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                          := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
           l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
         end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || l_pos_structures_code;
      per_ri_config_utilities.write_log(p_message => l_log_message);

       hr_utility.set_location(l_proc, 60);
     else
       hr_utility.set_location(l_proc, 70);
       hr_utility.trace('Positions : Industry is US_GOVERNMENT');

      -- create only federal position segments with specified value segment name valuesets.
      -- First Segment
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'POS'
                          ,p_structure_code            =>  l_pos_structures_code
                          ,p_segment_name              => 'Position Title'
                          ,p_column_name               => 'SEGMENT1'
                          ,p_segment_number            => 1
                          ,p_value_set                 => 'GHR_US_POSITION_TITLE'
                          ,p_lov_prompt                => 'Position Title'
                          ,p_segment_type              => 'Char'
                          ,p_window_prompt             => 'Position Title'
                          ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Position Title';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT1';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  1;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_POSITION_TITLE';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Position Title';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Position Title';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POSITION_TITLE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Position Title'
                               ,p_segment_number  => 1
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Position Title';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Second Segment
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'POS'
                          ,p_structure_code            =>  l_pos_structures_code
                          ,p_segment_name              => 'Description'
                          ,p_column_name               => 'SEGMENT2'
                          ,p_segment_number            => 2
                          ,p_value_set                 => 'GHR_US_POS_DESC_NUM'
                          ,p_lov_prompt                => 'Description'
                          ,p_segment_type              => 'Char'
                          ,p_window_prompt             => 'Description'
                          ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Description';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT2';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  2;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_POS_DESC_NUM';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Description';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Description';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_POS_DESC_NUM'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Description'
                               ,p_segment_number  => 2
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Description';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      -- Third Segment
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'POS'
                          ,p_structure_code            =>  l_pos_structures_code
                          ,p_segment_name              => 'Sequence'
                          ,p_column_name               => 'SEGMENT3'
                          ,p_segment_number            => 3
                          ,p_value_set                 => 'GHR_US_SEQUENCE_NUM'
                          ,p_lov_prompt                => 'Sequence'
                          ,p_segment_type              => 'Char'
                          ,p_window_prompt             => 'Sequence'
                          ,p_fed_seg_attribute         => 'Y');

      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Sequence';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT3';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  3;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_SEQUENCE_NUM';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Sequence';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Sequence';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_SEQUENCE_NUM'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Sequence'
                               ,p_segment_number  => 3
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;
      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Sequence';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      -- Fourth Segment
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.create_flex_segments
                          (p_appl_short_Name           => 'PER'
                          ,p_flex_code                 => 'POS'
                          ,p_structure_code            =>  l_pos_structures_code
                          ,p_segment_name              => 'Agency Code'
                          ,p_column_name               => 'SEGMENT4'
                          ,p_segment_number            => 4
                          ,p_value_set                 => 'GHR_US_AGENCY_CODE'
                          ,p_lov_prompt                => 'Agency Code'
                          ,p_segment_type              => 'Char'
                          ,p_window_prompt             => 'Agency Code'
                          ,p_fed_seg_attribute         => 'Y');
      else
        p_kf_pos_seg_tab(l_kf_pos_seg_count).appl_short_name  := 'PER';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).flex_code        := 'POS';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).structure_code   :=  l_pos_structures_code;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_name     :=  'Agency Code';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).column_name      := 'SEGMENT4';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_number   :=  4;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).value_set        := 'GHR_US_AGENCY_CODE';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).lov_prompt       := 'Agency Code';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).segment_type     := 'Char';
        p_kf_pos_seg_tab(l_kf_pos_seg_count).window_prompt    := 'Agency Code';

        --create technical summary data for valueset
        per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => 'GHR_US_AGENCY_CODE'
                               ,p_valueset_type   => 'Char'
                               ,p_structure_code  => l_pos_structures_code
                               ,p_segment_name    => 'Agency Code'
                               ,p_segment_number  => 4
                               ,p_valueset_tab    => l_kf_pos_valueset_tab);

        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_value_set_name
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).value_set_name;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_description
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).description;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_security_available
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).security_available;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_enable_longlist
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).enable_longlist;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_format_type
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).format_type;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_maximum_size
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).maximum_size;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_precision
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).precision;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_numbers_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).numbers_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_uppercase_only
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).uppercase_only;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_right_justify_zero_fill
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_min_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).min_value;
        p_kf_pos_seg_tab(l_kf_pos_seg_count).vs_max_value
                       := l_kf_pos_valueset_tab(l_value_set_tab_count).max_value;
        l_kf_pos_seg_count := l_kf_pos_seg_count + 1 ;
      end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER POS ' || 'Agency Code';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 90);
    end if;

    --
    -- freeze and compile this flexfield
    --
    per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'POS'
                       ,p_structure_code            =>  l_pos_structures_code);

    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_global_pos_kf;

  /* --------------------------------------------------------------------------
  -- Name      : create_global_grd_kf
  -- Purpose   : This procedure creates grades keyflex structures, segments and
  --             valuesets when grades are not defined.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_global_grd_kf (p_configuration_code in varchar2
                                 ,p_technical_summary_mode in boolean default FALSE
                                  ,p_kf_grd_tab in out nocopy
                                     per_ri_config_tech_summary.kf_grd_tab
                                  ,p_kf_grd_seg_tab in out nocopy
                                     per_ri_config_tech_summary.kf_grd_seg_tab) IS

  l_proc                         varchar2(72) := g_package || 'create_global_grd_kf';
  l_log_message                  varchar2(360);
  l_kf_grd_tab                   per_ri_config_tech_summary.kf_grd_tab;
  l_kf_grd_count                 number(8) := 0;
  l_error_message                varchar2(360);
  l_kf_grd_seg_tab               per_ri_config_tech_summary.kf_grd_seg_tab;
  l_kf_grd_seg_count             number(8) := 0;

  l_configuration_code           per_ri_config_information.configuration_code%type;
  l_grade_number                 number(9);

  l_kf_grd_valueset_tab          per_ri_config_tech_summary.valueset_tab;
  l_value_set_tab_count          number(9) := 1;

  l_enterprise_short_name        per_ri_config_information.configuration_code%type;

  l_grd_structures_code          fnd_id_flex_structures.id_flex_structure_code%type;
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                   (p_configuration_code => p_configuration_code);

    l_enterprise_short_name := per_ri_config_utilities.get_enterprise_short_name(p_configuration_code);

    if l_enterprise_primary_industry <> 'US_GOVERNMENT' then
       hr_utility.set_location(l_proc, 20);
       -- Create Grade Key Flex
       l_grd_structures_code :=  per_ri_config_utilities.return_config_entity_name
                               (per_ri_config_main.g_global_grd_structure_name);
       if NOT (p_technical_summary_mode) then
         l_grade_number  := per_ri_config_utilities.create_key_flexfield
                                        (p_appl_short_Name   => 'PER'
                                        ,p_flex_code         => 'GRD'
                                        ,p_structure_code    => l_grd_structures_code
                                        ,p_structure_title   => l_grd_structures_code
                                        ,p_description       => l_grd_structures_code);

      else
        p_kf_grd_tab(l_kf_grd_count).appl_short_name    := 'PER';
        p_kf_grd_tab(l_kf_grd_count).flex_code          := 'GRD';
        p_kf_grd_tab(l_kf_grd_count).structure_code     := l_grd_structures_code;
        p_kf_grd_tab(l_kf_grd_count).structure_title    := l_grd_structures_code;
        p_kf_grd_tab(l_kf_grd_count).description        := l_grd_structures_code;

        l_kf_grd_count := l_kf_grd_count + 1 ;
      end if;
       l_log_message := 'Created KEYFLEX PER GRD ' || l_grd_structures_code;
       per_ri_config_utilities.write_log(p_message => l_log_message);

       -- Create Grade Key Flex Segments
       if NOT (p_technical_summary_mode) then
         per_ri_config_utilities.create_flex_segments
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            => l_grd_structures_code
                       ,p_segment_name              => 'Grade'
                       ,p_column_name               => 'SEGMENT1'
                       ,p_segment_number            => 1
                       ,p_value_set                 => null
                       ,p_lov_prompt                => 'Grade'
                       ,p_window_prompt             => 'Grade');
        else
          p_kf_grd_seg_tab(l_kf_grd_seg_count).appl_short_name  := 'PER';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).flex_code        := 'GRD';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).structure_code   := l_grd_structures_code;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_name     := 'Grade';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).column_name      := 'SEGMENT1';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_number   := 1;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).value_set        := null;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).lov_prompt       := 'Grade';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_type     := 'Grade';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).window_prompt    := 'Grade';

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => null
                                 ,p_structure_code  => l_grd_structures_code
                                 ,p_segment_name    => 'Grade'
                                 ,p_segment_number  => 1
                                 ,p_valueset_tab    => l_kf_grd_valueset_tab);

          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_value_set_name
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_description
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).description;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_security_available
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_enable_longlist
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_format_type
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_maximum_size
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_precision
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).precision;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_numbers_only
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_uppercase_only
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_right_justify_zero_fill
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_min_value
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_max_value
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).max_value;

          l_kf_grd_seg_count := l_kf_grd_seg_count + 1 ;
    end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER GRD ' || 'Grade';
      per_ri_config_utilities.write_log(p_message => l_log_message);

       if NOT (p_technical_summary_mode) then
         per_ri_config_utilities.create_flex_segments
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            => l_grd_structures_code
                       ,p_segment_name              => 'Level'
                       ,p_column_name               => 'SEGMENT2'
                       ,p_segment_number            => 2
                       ,p_value_set                 => null
                       ,p_lov_prompt                => 'Level'
                       ,p_window_prompt             => 'Level');
        else
          p_kf_grd_seg_tab(l_kf_grd_seg_count).appl_short_name  := 'PER';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).flex_code        := 'GRD';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).structure_code   := l_grd_structures_code;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_name     := 'Level';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).column_name      := 'SEGMENT2';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_number   := 2;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).value_set        := null;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).lov_prompt       := 'Level';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).segment_type     := 'Level';
          p_kf_grd_seg_tab(l_kf_grd_seg_count).window_prompt    := 'Level';

          --create technical summary data for valueset
          per_ri_config_utilities.create_valueset_ts_data(p_valueset_name   => null
                                 ,p_valueset_type   => null
                                 ,p_structure_code  => l_grd_structures_code
                                 ,p_segment_name    => 'Level'
                                 ,p_segment_number  => 2
                                 ,p_valueset_tab    => l_kf_grd_valueset_tab);

          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_value_set_name
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).value_set_name;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_description
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).description;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_security_available
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).security_available;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_enable_longlist
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).enable_longlist;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_format_type
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).format_type;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_maximum_size
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).maximum_size;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_precision
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).precision;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_numbers_only
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).numbers_only;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_uppercase_only
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).uppercase_only;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_right_justify_zero_fill
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).right_justify_zero_fill;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_min_value
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).min_value;
          p_kf_grd_seg_tab(l_kf_grd_seg_count).vs_max_value
                         := l_kf_grd_valueset_tab(l_value_set_tab_count).max_value;

          l_kf_grd_seg_count := l_kf_grd_seg_count + 1 ;
    end if;

      l_log_message := 'Created KEYFLEX SEGMENT : PER GRD ' || 'Level';
      per_ri_config_utilities.write_log(p_message => l_log_message);
      --
      -- freeze and compile this flexfield
      --
      if NOT (p_technical_summary_mode) then
        per_ri_config_utilities.freeze_and_compile_flexfield
                       (p_appl_short_Name           => 'PER'
                       ,p_flex_code                 => 'GRD'
                       ,p_structure_code            => l_grd_structures_code);
      end if;
    else
      -- Since GRD Keyflex and segments are already defined.
      Null;
    end if;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_global_grd_kf;

  /* --------------------------------------------------------------------------
  -- Name      : create_default_value_sets
  -- Purpose   : This procedure creates default valuests.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_default_value_sets (p_configuration_code in varchar2) IS

  l_proc                         varchar2(72) := g_package || 'create_default_value_sets';
  l_log_message	                 varchar2(360);
  l_error_message                 varchar2(360);

  l_security_available	         varchar2(1)    default 'N';
  l_enable_longlist		 varchar2(1)    default 'Y';
  l_format_type			 varchar2(1)    default 'C';
  l_maximum_size   		 number(9)      default 60;
  l_precision 			 number(2)      default null;
  l_numbers_only 		 varchar2(1)    default 'N';
  l_uppercase_only               varchar2(1)    default 'N';
  l_right_justify_zero_fill	 varchar2(1)    default 'N';
  l_min_value			 varchar2(150)  default null;
  l_max_value 			 varchar2(150)  default null;
  l_description                  varchar2(240);
  l_value_set_exists             boolean;

  BEGIN

   hr_utility.set_location('Entering:'|| l_proc, 10);

   fnd_flex_val_api.set_session_mode('customer_data');

   -- Create PER_RI_DEFAULT_GRADES
   l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => 'PER_RI_CONFIG_DEFAULT_GRADES');
   if not (l_value_set_exists) then
     hr_utility.set_location(l_proc, 20);
     l_description  := 'The default Grades Value Set is generated by Enterprise Structures Configuration '
                        || 'and used in Grade flexfield validation. This will initially be empty and can '
                        || 'be populated using the load reference data';
     fnd_flex_val_api.create_valueset_independent
                                      (value_set_name	                => 'PER_RI_CONFIG_DEFAULT_GRADES'
	                              ,description	                => l_description
	                              ,security_available               => l_security_available
	                              ,enable_longlist	                => l_enable_longlist
   	                              ,format_type	                => l_format_type
	                              ,maximum_size   	                => l_maximum_size
	                              ,precision 	                => l_precision
	                              ,numbers_only 	                => l_numbers_only
	                              ,uppercase_only                   => l_uppercase_only
	                              ,right_justify_zero_fill          => l_right_justify_zero_fill
	                              ,min_value		       => l_min_value
	                              ,max_value 	               => l_max_value);
    l_log_message := 'Created DEFAULT VALUESET ' || 'PER_RI_CONFIG_DEFAULT_GRADES';
    per_ri_config_utilities.write_log(p_message => l_log_message);
   end if;
   hr_utility.set_location(l_proc, 30);
   -- Create PER_RI_DEFAULT_GRADES
   l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => 'PER_RI_CONFIG_DEFAULT_LEVELS');
   if not (l_value_set_exists) then
     hr_utility.set_location(l_proc, 40);
     l_description  := 'The default Grades Level Value Set is generated by Enterprise Structures Configuration '
                        || 'and used in Grade flexfield validation. This will initially be empty and can '
                        || 'be populated using the load reference data';
     fnd_flex_val_api.create_valueset_independent
                                      (value_set_name            => 'PER_RI_CONFIG_DEFAULT_LEVELS'
                                      ,description              => l_description
                                      ,security_available       => l_security_available
                                      ,enable_longlist          => l_enable_longlist
                                      ,format_type              => l_format_type
                                      ,maximum_size             => l_maximum_size
                                      ,precision                => l_precision
                                      ,numbers_only             => l_numbers_only
                                      ,uppercase_only           => l_uppercase_only
                                      ,right_justify_zero_fill  => l_right_justify_zero_fill
                                      ,min_value                => l_min_value
                                      ,max_value                => l_max_value);
    l_log_message := 'Created DEFAULT VALUESET ' || 'PER_RI_CONFIG_DEFAULT_LEVELS';
   end if;
   hr_utility.set_location(l_proc, 50);

   -- Create PER_RI_DEFAULT_GRADES
   l_description  := 'The default Account Number Value Set is generated by Enterprise Structures Configuration '
                      || 'and used in Grade flexfield validation. This will initially be empty and can '
                      || 'be populated using the load reference data';
   l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => 'PER_RI_CONFIG_DEFAULT_ACCOUNT');
   if not (l_value_set_exists) then
     hr_utility.set_location(l_proc, 60);
     fnd_flex_val_api.create_valueset_independent
                                      (value_set_name            => 'PER_RI_CONFIG_DEFAULT_ACCOUNT'
                                      ,description              => l_description
                                      ,security_available       => l_security_available
                                      ,enable_longlist          => l_enable_longlist
                                      ,format_type              => l_format_type
                                      ,maximum_size             => l_maximum_size
                                      ,precision                => l_precision
                                      ,numbers_only             => l_numbers_only
                                      ,uppercase_only           => l_uppercase_only
                                      ,right_justify_zero_fill  => l_right_justify_zero_fill
                                      ,min_value                => l_min_value
                                      ,max_value                => l_max_value);
    l_log_message := 'Created DEFAULT VALUESET ' || 'PER_RI_CONFIG_DEFAULT_ACCOUNT';
   end if;
   hr_utility.set_location(l_proc, 70);
   -- Create PER_RI_DEFAULT_GRADES
   l_description  := 'The default Company Value Set is generated by Enterprise Structures Configuration '
                      || 'and used in Grade flexfield validation. This will initially be empty and can '
                      || 'be populated using the load reference data';
   l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => 'PER_RI_CONFIG_DEFAULT_COMPANY');
   if not (l_value_set_exists) then
     hr_utility.set_location(l_proc, 80);
     fnd_flex_val_api.create_valueset_independent
                                      (value_set_name            => 'PER_RI_CONFIG_DEFAULT_COMPANY'
                                      ,description              => l_description
                                      ,security_available       => l_security_available
                                      ,enable_longlist          => l_enable_longlist
                                      ,format_type              => l_format_type
                                      ,maximum_size             => l_maximum_size
                                      ,precision                => l_precision
                                      ,numbers_only             => l_numbers_only
                                      ,uppercase_only           => l_uppercase_only
                                      ,right_justify_zero_fill  => l_right_justify_zero_fill
                                      ,min_value                => l_min_value
                                      ,max_value                => l_max_value);
    l_log_message := 'Created DEFAULT VALUESET ' || 'PER_RI_CONFIG_DEFAULT_COMPANY';
   end if;
   hr_utility.set_location(l_proc, 90);
   -- Create PER_RI_DEFAULT_GRADES
   l_description  := 'The default Cost Center Value Set is generated by Enterprise Structures Configuration '
                      || 'and used in Grade flexfield validation. This will initially be empty and can '
                      || 'be populated using the load reference data';
   l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => 'PER_RI_CONFIG_DEFAULT_CC');
   if not (l_value_set_exists) then
     hr_utility.set_location(l_proc, 100);
     fnd_flex_val_api.create_valueset_independent
                                      (value_set_name            => 'PER_RI_CONFIG_DEFAULT_CC'
                                      ,description              => l_description
                                      ,security_available       => l_security_available
                                      ,enable_longlist          => l_enable_longlist
                                      ,format_type              => l_format_type
                                      ,maximum_size             => l_maximum_size
                                      ,precision                => l_precision
                                      ,numbers_only             => l_numbers_only
                                      ,uppercase_only           => l_uppercase_only
                                      ,right_justify_zero_fill  => l_right_justify_zero_fill
                                      ,min_value                => l_min_value
                                      ,max_value                => l_max_value);
    l_log_message := 'Created DEFAULT VALUESET ' || 'PER_RI_CONFIG_DEFAULT_CC';
   end if;

   hr_utility.set_location(' Leaving:'|| l_proc, 120);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;


  END create_default_value_sets;

  /* --------------------------------------------------------------------------
  -- Name      : create_hrms_responsibility
  -- Purpose   : This procedure creates hrms responsibilities and assign them to
  --             the super user created by the enterprise structures configuration
  --             loader program. Responsibilities attached are based on the product
  --             country selection list.
  -- Arguments : p_configuration_code
  --             p_security_profile_tab
  -------------------------------------------------------------------------- */

  PROCEDURE create_hrms_responsibility (p_configuration_code   in varchar2
                                       ,p_security_profile_tab in out nocopy security_profile_tab
                                       ,p_technical_summary_mode in boolean default FALSE
                                       ,p_hrms_resp_tab in out nocopy per_ri_config_tech_summary.hrms_resp_tab) IS

  cursor csr_get_country (cp_configuration_code in varchar2) IS
      select country_code
      from per_ri_config_country_v
     where configuration_code = cp_configuration_code
       and country_code in (select distinct territory_code
                              from per_ri_config_responsibility)
        and country_code in (select per_ri_config_utilities.business_group_decision
                                   (cp_configuration_code
                                   ,country_code)
                              from  per_ri_config_country_v where configuration_code = cp_configuration_code);

  /*
  cursor csr_get_country (cp_configuration_code in varchar2) IS
    select country_code
      from per_ri_config_country_v
     where configuration_code = cp_configuration_code
       and country_code in (select distinct territory_code
                                     from per_ri_config_responsibility);
  */

  cursor csr_get_product (cp_configuration_code in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code;

  cursor csr_get_responsibility (cp_territory_code in varchar2
                                ,cp_responsibility_application in varchar2) IS
    select distinct resp.responsibility_key,
           apps.application_short_name
      from fnd_application  apps,
           fnd_responsibility  resp,
           per_ri_config_responsibility con,
           per_ri_config_country_v      cont
     where apps.application_id = resp.application_id
       and con.responsibility_key = resp.responsibility_key
       and resp.responsibility_key = con.responsibility_key
       and resp.responsibility_key = con.responsibility_key
       and con.territory_code             = cp_territory_code
       and con.responsibility_application = cp_responsibility_application
       and con.territory_code = cont.country_code
       and cont.country_code in (select distinct territory_code
                                     from per_ri_config_responsibility);

  cursor csr_global_responsibility(cp_configuration_code in varchar2) IS
    select country_code
     from  per_ri_config_country_v con
    where con.configuration_code = cp_configuration_code
      and con.country_code not in (select distinct territory_code
                                     from per_ri_config_responsibility)
      and per_ri_config_utilities.business_group_decision
                                   (cp_configuration_code
                                   ,country_code)  <> 'INT' ;

  l_proc                         varchar2(72) := g_package || 'create_hrms_responsibility';
  l_error_message                 varchar2(360);
  l_country_code                 per_ri_config_information.config_information1%type;
  l_product_name                 per_ri_config_information.config_information1%type;
  l_fnd_application_short_name   varchar2(30);

  l_country_code_global          per_ri_config_information.config_information1%type;
  l_responsibility_key           varchar2(60);
  l_application_short_name       per_ri_config_information.configuration_code%type;
  l_assign_responsibility        varchar2(30);
  l_assign_global_responsibility boolean default FALSE;
  l_assign_global_resp_key       varchar2(60);
  l_assign_glb_resp_key_app_name varchar2(30);

  l_assign_determined_resp       varchar2(30);
  l_hr                           boolean default FALSE;
  l_hrms                         boolean default FALSE;
  l_benefits                     boolean default FALSE;
  l_self_service                 boolean default FALSE;

  l_business_group_name          per_business_groups.name%type;
  l_business_group_name_main     per_business_groups.name%type;
  l_business_group_name_global   per_business_groups.name%type;
  l_start_date                   varchar2(240) := to_char(per_ri_config_fnd_hr_entity.g_config_effective_date,'YYYY/MM/DD');
  l_end_date                     varchar2(240) := to_char(per_ri_config_fnd_hr_entity.g_config_effective_end_date,'YYYY/MM/DD');
  l_row_count                    number(9) default 0 ;
  l_earlier_row_count            number(9) default 0 ;

  l_configuration_user_name      fnd_user.user_name%type;

  l_hrms_resp_count              number(9) := 0;
  l_hrms_bgsgut_profile_resp_tab per_ri_config_tech_summary.profile_resp_tab;
  l_profile_resp_main_tab        per_ri_config_tech_summary.profile_resp_tab;

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_configuration_user_name :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                    (per_ri_config_main.g_configuration_user_name));
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

    hr_utility.set_location(l_proc, 30);

    --
    -- assign hrms self service responsibilities
    --

    if l_self_service then

      if NOT (p_technical_summary_mode) then
        fnd_user_resp_groups_api.load_row(
                      x_user_name       => l_configuration_user_name,
                      x_resp_key        => 'EMPLOYEE_DIRECT_ACCESS_V4.0',
                      x_app_short_name  => 'PER',
                      x_security_group  => 'STANDARD',
                      x_owner           => 'SEED',
                      x_start_date      =>  l_start_date,
                      x_end_date        =>  l_end_date,
                      x_description     => per_ri_config_main.g_description_string);
        hr_utility.trace('Assigned Responsibility: ' || 'EMPLOYEE_DIRECT_ACCESS');
        hr_utility.set_location(l_proc, 40);
      else
          p_hrms_resp_tab(l_hrms_resp_count).user_name      :=  l_configuration_user_name;
          p_hrms_resp_tab(l_hrms_resp_count).resp_key  := 'EMPLOYEE_DIRECT_ACCESS_V4';
          p_hrms_resp_tab(l_hrms_resp_count).app_short_name := 'PER';
          p_hrms_resp_tab(l_hrms_resp_count).security_group := 'STANDARD';
          p_hrms_resp_tab(l_hrms_resp_count).owner          := 'SEED';
          p_hrms_resp_tab(l_hrms_resp_count).start_date     := l_start_date;
          p_hrms_resp_tab(l_hrms_resp_count).end_date       := l_end_date;
          p_hrms_resp_tab(l_hrms_resp_count).description    := per_ri_config_main.g_description_string;

          l_hrms_resp_count := l_hrms_resp_count + 1 ;
      end if;

      if NOT (p_technical_summary_mode) then
        fnd_user_resp_groups_api.load_row(
                      x_user_name       => l_configuration_user_name,
                      x_resp_key        => 'LINE_MANAGER_ACCESS_V4.0',
                      x_app_short_name  => 'PER',
                      x_security_group  => 'STANDARD',
                      x_owner           => 'SEED',
                      x_start_date      =>  l_start_date,
                      x_end_date        =>  l_end_date,
                      x_description     => per_ri_config_main.g_description_string);
      else
          p_hrms_resp_tab(l_hrms_resp_count).user_name      :=  l_configuration_user_name;
          p_hrms_resp_tab(l_hrms_resp_count).resp_key  := 'LINE_MANAGER_ACCESS_V4';
          p_hrms_resp_tab(l_hrms_resp_count).app_short_name := 'PER';
          p_hrms_resp_tab(l_hrms_resp_count).security_group := 'STANDARD';
          p_hrms_resp_tab(l_hrms_resp_count).owner          := 'SEED';
          p_hrms_resp_tab(l_hrms_resp_count).start_date     := l_start_date;
          p_hrms_resp_tab(l_hrms_resp_count).end_date       := l_end_date;
          p_hrms_resp_tab(l_hrms_resp_count).description    := per_ri_config_main.g_description_string;

          l_hrms_resp_count := l_hrms_resp_count + 1 ;
      end if;
      hr_utility.trace('Assigned Responsibility: ' || 'LINE_MANAGER_DIRECT_ACCESS');
      hr_utility.set_location(l_proc, 50);
    end if;

    --decide on the responsibility to be assigned.

    hr_utility.set_location(l_proc, 60);
    l_assign_responsibility := 'PER';

    if l_hr and not l_hrms and not l_benefits then
      l_assign_responsibility := 'PER';
    end if;
    if l_hr and l_hrms and not l_benefits then
      l_assign_responsibility := 'HRMS';
    end if;
    if l_hr and l_hrms and l_benefits then
      l_assign_responsibility := 'SHRMS';
    end if;

    open csr_get_country(p_configuration_code);
    loop
      fetch csr_get_country into l_country_code;
      exit when csr_get_country%NOTFOUND;

      l_assign_determined_resp
               := per_ri_config_utilities.determine_country_resp
                                (p_country_code          => l_country_code
                                ,p_assign_responsibility => l_assign_responsibility);

      hr_utility.trace('l_assign_responsibility = ' || l_assign_responsibility);
      hr_utility.trace('l_assign_determined_resp = ' || l_assign_determined_resp);
      --open csr_get_responsibility(l_country_code
      --                           ,l_assign_responsibility);

      open csr_get_responsibility(l_country_code
                                 ,l_assign_determined_resp);
      loop
        fetch csr_get_responsibility into  l_responsibility_key
                                          ,l_fnd_application_short_name;

          exit when csr_get_responsibility%NOTFOUND;

          hr_utility.trace('l_country_code : ' || l_country_code);
          hr_utility.trace('l_responsibility_key : ' || l_responsibility_key);
          hr_utility.trace('l_fnd_application_short_name : ' || l_fnd_application_short_name);

          -- Security Group Removal Changes
          -- This is taken care by security_profile_assignment creation
          --assign responsibility
          /* fnd_user_resp_groups_api.load_row(
                                  x_user_name       => l_configuration_user_name,
                                  x_resp_key        => l_responsibility_key,
                                  x_app_short_name  => l_fnd_application_short_name,
                                  x_security_group  => 'STANDARD',
                                  x_owner           => 'SEED',
                                  x_start_date      =>  l_start_date,
                                  x_end_date        =>  l_end_date,
                                  x_description     => per_ri_config_main.g_description_string);
          hr_utility.trace('Assigned Responsibility:' || l_responsibility_key || ':' || l_fnd_application_short_name);
          */
          -- get business group name for given country code
          l_business_group_name_main := per_ri_config_utilities.get_enterprise_short_name
                                           (p_configuration_code => p_configuration_code)
                             || ' ' || l_country_code || per_ri_config_main.g_bg_name_suffix_string;

          per_ri_config_fnd_hr_entity.create_resp_level_profile
                                    (p_configuration_code       => p_configuration_code
                                    ,p_responsibility_key       => l_responsibility_key
                                    ,p_technical_summary_mode   => p_technical_summary_mode
                                    ,p_profile_resp_tab         => l_profile_resp_main_tab);
          -- this need special processing
          --once data is populated we need to populate this main table to show data.


          if NOT (p_technical_summary_mode) then
            p_security_profile_tab(csr_get_responsibility%ROWCOUNT + l_row_count).security_profile_name
                                                     := l_business_group_name_main;
            p_security_profile_tab(csr_get_responsibility%ROWCOUNT + l_row_count).responsibility_key
                                                     := l_responsibility_key;

          -- This procedure can be used to populate technical summary records.
          else
            --this table is also needed now for security group changes
            p_security_profile_tab(csr_get_responsibility%ROWCOUNT + l_row_count).security_profile_name
                                                     := l_business_group_name_main;
            p_security_profile_tab(csr_get_responsibility%ROWCOUNT + l_row_count).responsibility_key
                                                     := l_responsibility_key;
            --
            p_hrms_resp_tab(l_hrms_resp_count).user_name      := l_configuration_user_name;
            p_hrms_resp_tab(l_hrms_resp_count).resp_key       := l_responsibility_key;
            p_hrms_resp_tab(l_hrms_resp_count).app_short_name := null;
            p_hrms_resp_tab(l_hrms_resp_count).security_group := l_business_group_name_main;
            p_hrms_resp_tab(l_hrms_resp_count).owner          := null;
            p_hrms_resp_tab(l_hrms_resp_count).start_date     := l_start_date;
            p_hrms_resp_tab(l_hrms_resp_count).end_date       := l_end_date;
            p_hrms_resp_tab(l_hrms_resp_count).description    := per_ri_config_main.g_description_string;

            l_hrms_resp_count := l_hrms_resp_count + 1;
          end if;


          hr_utility.trace('l_business_group_name_main : ' || l_business_group_name_main);
          hr_utility.trace('l_responsibility_key : ' || l_responsibility_key);

          hr_utility.trace('l_row_count inside = ' || to_char(l_row_count));

      end loop;
      l_row_count := l_row_count + (csr_get_responsibility%ROWCOUNT);
      hr_utility.trace('l_row_count outside = ' || to_char(l_row_count));
      close csr_get_responsibility;
    end loop;
    close csr_get_country;

    --process gobal responsibility
    hr_utility.set_location('Entering:'|| l_proc, 210);
    l_assign_glb_resp_key_app_name  := 'PER';

    if l_hr and not l_hrms and not l_benefits then
      l_assign_global_resp_key  := 'GLOBAL HR MANAGER';
      l_assign_glb_resp_key_app_name  := 'PER';
    end if;

    if l_hr and l_hrms and not l_benefits then
      l_assign_global_resp_key  := 'GLOBAL_HRMS_MANAGER';
      l_assign_glb_resp_key_app_name  := 'PER';
    end if;

    if l_hr and l_hrms and l_benefits then
      l_assign_global_resp_key  := 'GLB_SHRMS_MANAGER';
      l_assign_glb_resp_key_app_name  := 'PER';
    end if;

    if l_hr and not l_hrms and l_benefits then
      l_assign_global_resp_key  := 'US_BEN_MANAGER';
      l_assign_glb_resp_key_app_name  := 'BEN';
    end if;

    hr_utility.set_location('Entering:'|| l_proc, 220);
    hr_utility.trace('l_assign_glb_resp_key_app_name : ' || l_assign_glb_resp_key_app_name);
    hr_utility.trace('l_assign_global_resp_key : ' || l_assign_global_resp_key);

    l_earlier_row_count := p_security_profile_tab.count + 1;
    hr_utility.trace('GLOBAL l_earlier_row_count : ' || l_earlier_row_count);

    open csr_global_responsibility(p_configuration_code);
    loop
      fetch csr_global_responsibility into l_country_code_global;
      exit when csr_global_responsibility%NOTFOUND;

      hr_utility.trace('Assigned Global Responsibility:' || l_assign_global_resp_key );

     -- get business group name for given country code
     -- business group name and security profile names are same
     l_business_group_name_global := per_ri_config_utilities.get_enterprise_short_name
                                           (p_configuration_code => p_configuration_code)
                             || ' ' || l_country_code_global || per_ri_config_main.g_bg_name_suffix_string;

      p_security_profile_tab(l_earlier_row_count).security_profile_name
                                                       := l_business_group_name_global;
      p_security_profile_tab(l_earlier_row_count).responsibility_key
                                                     := l_assign_global_resp_key;
      -- Populate the data for TS
      p_hrms_resp_tab(l_earlier_row_count).user_name      := l_configuration_user_name;
      p_hrms_resp_tab(l_earlier_row_count).resp_key       := l_assign_global_resp_key;
      p_hrms_resp_tab(l_earlier_row_count).app_short_name := null;
      p_hrms_resp_tab(l_earlier_row_count).security_group := null;
      p_hrms_resp_tab(l_earlier_row_count).owner          := null;
      p_hrms_resp_tab(l_earlier_row_count).start_date     := l_start_date;
      p_hrms_resp_tab(l_earlier_row_count).end_date       := l_end_date;
      p_hrms_resp_tab(l_earlier_row_count).description    := per_ri_config_main.g_description_string;

      l_earlier_row_count := 1 + l_earlier_row_count;
    end loop;
    close csr_global_responsibility;

    --assign global responsibility
     /* MSG Changes BEGIN
      /*     if NOT (p_technical_summary_mode) then
      fnd_user_resp_groups_api.load_row(
                          x_user_name       => l_configuration_user_name,
                          x_resp_key        => l_assign_global_resp_key,
                          x_app_short_name  => l_assign_glb_resp_key_app_name,
                          x_security_group  => 'STANDARD',
                          x_owner           => 'SEED',
                          x_start_date      =>  l_start_date,
                          x_end_date        =>  l_end_date,
                          x_description     => per_ri_config_main.g_description_string);
    else
      p_hrms_resp_tab(l_hrms_resp_count).user_name      := l_configuration_user_name;
      p_hrms_resp_tab(l_hrms_resp_count).resp_key       := l_assign_global_resp_key;
      p_hrms_resp_tab(l_hrms_resp_count).app_short_name := l_assign_glb_resp_key_app_name;
      p_hrms_resp_tab(l_hrms_resp_count).security_group := 'STANDARD';
      p_hrms_resp_tab(l_hrms_resp_count).owner          := 'SEED';
      p_hrms_resp_tab(l_hrms_resp_count).start_date     := l_start_date;
      p_hrms_resp_tab(l_hrms_resp_count).end_date       := l_end_date;
      p_hrms_resp_tab(l_hrms_resp_count).description    := per_ri_config_main.g_description_string;

      l_hrms_resp_count := l_hrms_resp_count + 1 ;
    end if;

     per_ri_config_fnd_hr_entity.create_resp_level_profile
                               (p_configuration_code      => p_configuration_code
                               ,p_responsibility_key      => l_assign_global_resp_key
                               ,p_technical_summary_mode  => p_technical_summary_mode
                               ,p_profile_resp_tab        => l_profile_resp_main_tab);

     -- get business group name for given country code
     l_business_group_name_global := per_ri_config_utilities.get_enterprise_short_name
                                           (p_configuration_code => p_configuration_code)
                             || ' ' || l_country_code_global || per_ri_config_main.g_bg_name_suffix_string;

     hr_utility.trace('Security Group Removal Changes');
     per_ri_config_fnd_hr_entity.create_bg_id_and_sg_id_profile
                                          (p_configuration_code         => p_configuration_code
                                          ,p_responsibility_key         => l_assign_global_resp_key
                                          ,p_responsibility_name        => l_assign_global_resp_name
                                          ,p_business_group_name        => l_business_group_name_global
                                          ,p_technical_summary_mode     => p_technical_summary_mode
                                          ,p_bg_sg_ut_profile_resp_tab  => l_hrms_bgsgut_profile_resp_tab);
    MSG Changes END */

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_hrms_responsibility;

  /* --------------------------------------------------------------------------
  -- Name      : create_application_level_resp
  -- Purpose   : This procedure creates application level profile options.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */
  PROCEDURE create_application_level_resp(p_configuration_code     in varchar2
                                         ,p_technical_summary_mode in boolean default FALSE
                                         ,p_profile_apps_tab       in out nocopy
                                                 per_ri_config_tech_summary.profile_apps_tab) IS


  cursor csr_get_product (cp_configuration_code in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code;

  l_product_name                 per_ri_config_information.config_information1%type;

  l_profile_apps_count           number(8) := 0;
  l_proc                         varchar2(72) := g_package || 'create_application_level_resp';
  l_log_message                  varchar2(360);
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_get_product(p_configuration_code);

    loop
      fetch csr_get_product into l_product_name;
      exit when csr_get_product%NOTFOUND;


      /* DGARG MSG Changes
      -- For each product selected set application level profile option
      -- ENABLE_SECURITY_GROUPS
      if l_product_name in ('PER','PAY','BEN') then
        hr_utility.trace('l_product_name ' || l_product_name);
        if NOT (p_technical_summary_mode) then
          per_ri_config_utilities.set_profile_option_value
                           (p_level                => 10002
                           ,p_level_value          => l_product_name
                           ,p_level_value_app      => l_product_name
                           ,p_profile_name         => 'ENABLE_SECURITY_GROUPS'
                           ,p_profile_option_value => 'Y');
        else
          p_profile_apps_tab(l_profile_apps_count).level                 := 1002;
          p_profile_apps_tab(l_profile_apps_count).level_value           := l_product_name;
          p_profile_apps_tab(l_profile_apps_count).level_value_app       := l_product_name;
          p_profile_apps_tab(l_profile_apps_count).profile_name          := 'ENABLE_SECURITY_GROUPS';
          p_profile_apps_tab(l_profile_apps_count).profile_option_value  := 'Y';

          l_profile_apps_count  := l_profile_apps_count + 1;

        end if;

        l_log_message := 'Created PROFILE_OPTION ENABLE_SECURITY_GROUPS ' || l_product_name;
        per_ri_config_utilities.write_log(p_message => l_log_message);
      end if;
      ** */
    end loop;
    close csr_get_product;

    /* DGARG - Multiple Security Groups Removal chnages
    --
    -- Set ENABLE_SECURITY_GROUPS all all HRMS application
    --
    for rec in ( select application_id
                    from   fnd_application
                    where hr_general.chk_application_id(application_id) = 'TRUE'
                    Order by Application_short_name)
      loop

        if fnd_profile.save ('ENABLE_SECURITY_GROUPS'
                          ,'Y'
                          ,'APPL'
                          ,rec.application_id ) then

          l_log_message := 'Setting the Enable Security Groups Profile to the application '
                           || rec.application_id;

        else
           l_log_message := 'The profile setting has errored out for application '
                           || rec.application_id;
        end if;
        per_ri_config_utilities.write_log(p_message => l_log_message);
        hr_utility.trace(l_log_message);
      end loop;
    --
    */

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_application_level_resp;
  /* --------------------------------------------------------------------------
  -- Name      : create_resp_level_profile
  -- Purpose   : This procedure creates application level profile options.
  -- Arguments : p_configuration_code
  --             p_responsibility_key
  -------------------------------------------------------------------------- */

  PROCEDURE create_resp_level_profile(p_configuration_code  in varchar2
                                     ,p_responsibility_key  in varchar2
                                     ,p_technical_summary_mode in boolean default FALSE
                                     ,p_profile_resp_tab    in out nocopy
                                                               per_ri_config_tech_summary.profile_resp_tab) IS


  cursor csr_get_product (cp_configuration_code in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code;

  cursor csr_get_resp_key_app (cp_responsibility_key in varchar2) IS
    select apps.application_short_name
      from fnd_responsibility resp,
           fnd_application    apps
     where apps.application_id = resp.application_id
       and resp.responsibility_key = cp_responsibility_key;

  l_application_short_name       fnd_application.application_short_name%type;
  l_hr_user_type                 varchar2(30);
  l_product_name                 varchar2(30);

  l_hr                           boolean default TRUE;
  l_hrms                         boolean default FALSE;
  l_profile_resp_count           number(8) := 0;

  l_proc                         varchar2(72) := g_package || 'create_resp_level_profile';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    -- only one row is there
    open csr_get_resp_key_app(p_responsibility_key);
    fetch csr_get_resp_key_app into l_application_short_name;
    close csr_get_resp_key_app;

    open csr_get_product(p_configuration_code);
    loop
      fetch csr_get_product into l_product_name;
      exit when csr_get_product%NOTFOUND;
      if l_product_name = 'PER' then
        l_hr := TRUE;
      end if;
      if l_product_name = 'PAY' then
        l_hrms := TRUE;
      end if;
    end loop;
    close csr_get_product;

    if l_hr and l_hrms then
       l_hr_user_type := 'INT';
    else
       l_hr_user_type := 'PER';
    end if;

    hr_utility.trace('p_responsibility_key ' || p_responsibility_key);
    hr_utility.trace('l_hr_user_type ' || l_hr_user_type);
    if NOT (p_technical_summary_mode) then
      per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10003
                         ,p_level_value          => p_responsibility_key
                         ,p_level_value_app      => l_application_short_name
                         ,p_profile_name         => 'HR_USER_TYPE'
                         ,p_profile_option_value => l_hr_user_type);
    else
      p_profile_resp_tab(l_profile_resp_count).level                 := 1003;
      p_profile_resp_tab(l_profile_resp_count).level_value           := p_responsibility_key;
      p_profile_resp_tab(l_profile_resp_count).level_value_app       := l_application_short_name;
      p_profile_resp_tab(l_profile_resp_count).profile_name          := 'HR_USER_TYPE';
      p_profile_resp_tab(l_profile_resp_count).profile_option_value  := l_hr_user_type;

      l_profile_resp_count  := l_profile_resp_count + 1;

    end if;


    hr_utility.trace('Created HR_USER_TYPE for '|| l_product_name);
    hr_utility.set_location('Leaving:'|| l_proc, 40);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_resp_level_profile;

  /* --------------------------------------------------------------------------
  -- Name      : create_bg_id_and_sg_id_profile
  -- Purpose   : This procedure creates profile option values for
  --             PER_BUSINESS_GROUP_ID
  --             PER_SECURITY_GROUP_ID
  --             HR_USER_TYPE
  -- Arguments : p_configuration_code
  --             p_responsibility_key
  --             p_business_group_name
  -------------------------------------------------------------------------- */

  PROCEDURE create_bg_id_and_sg_id_profile(p_configuration_code    in varchar2
                                          ,p_responsibility_key    in varchar2
                                          ,p_business_group_name   in varchar2
                                          ,p_technical_summary_mode  in boolean default FALSE
                                          ,p_bg_sg_ut_profile_resp_tab in out nocopy
                                                       per_ri_config_tech_summary.profile_resp_tab) IS


  cursor csr_get_resp_key_app (cp_responsibility_key in varchar2) IS
    select apps.application_short_name,resp.responsibility_id
      from fnd_responsibility resp,
           fnd_application    apps
     where apps.application_id = resp.application_id
       and resp.responsibility_key = cp_responsibility_key;

  cursor csr_bg_id (cp_business_group_name in varchar2) IS
    select business_group_id
      from per_business_groups
     where name = cp_business_group_name;

  cursor csr_sg_id (cp_business_group_name in varchar2) IS
    select security_profile_id
      from per_security_profiles
     where security_profile_name = cp_business_group_name;

  cursor csr_get_product (cp_configuration_code in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code;

  l_application_short_name       fnd_application.application_short_name%type;
  l_hr_user_type                 varchar2(30);
  l_product_name                 varchar2(30);

  l_bg_id                        varchar2(30);
  l_sg_id                        varchar2(30);
  l_responsibility_id            number(9);

  l_hr                           boolean default TRUE;
  l_hrms                         boolean default FALSE;

  l_profile_count                number(10) := 0;
  l_proc                         varchar2(72) := g_package || 'create_bg_id_and_sg_id_profile';
  l_error_message                varchar2(360);
  l_log_message                  varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if NOT (p_technical_summary_mode) then
      -- only one row is there
      open csr_get_resp_key_app(p_responsibility_key);
      fetch csr_get_resp_key_app into l_application_short_name,l_responsibility_id;
      close csr_get_resp_key_app;


      open csr_bg_id(p_business_group_name);
      fetch csr_bg_id into l_bg_id;
      close csr_bg_id;

      open csr_sg_id(p_business_group_name);
      fetch csr_sg_id into l_sg_id;
      close csr_sg_id;

      hr_utility.trace('l_responsibility_id ' || l_responsibility_id);
      hr_utility.trace('l_bg_id ' || l_bg_id);
      hr_utility.trace('l_sg_id ' || l_sg_id);
      hr_utility.trace('p_responsibility_key ' || p_responsibility_key);
      hr_utility.trace('p_business_group_name ' || p_business_group_name);

      --
      -- Create PER_BUSINESS_GROUP_ID
      --
      if fnd_profile.save ('PER_BUSINESS_GROUP_ID',
                        l_bg_id,
                        'RESP',
                        l_responsibility_id,
                        '800') then
        null;
      end if;
      l_log_message := 'Created Profile Option Value PER_BUSINESS_GROUP_ID ' || l_bg_id;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 20);

      --
      -- Create PER_SECURITY_PROFILE_ID
      --
      if fnd_profile.save ('PER_SECURITY_PROFILE_ID',
                        l_sg_id,
                        'RESP',
                        l_responsibility_id,
                        '800') then
        null;
      end if;
      l_log_message := 'Created Profile Option Value PER_SECURITY_PROFILE_ID ' || l_sg_id;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(l_proc, 30);

      open csr_get_product(p_configuration_code);
      loop
        fetch csr_get_product into l_product_name;
        exit when csr_get_product%NOTFOUND;
        if l_product_name = 'PER' then
          l_hr := TRUE;
        end if;
        if l_product_name = 'PAY' then
          l_hrms := TRUE;
        end if;
      end loop;
      close csr_get_product;

      if l_hr and l_hrms then
         l_hr_user_type := 'INT';
      else
         l_hr_user_type := 'PER';
      end if;
      --
      -- Create HR_USER_TYPE
      --
      if fnd_profile.save ('HR_USER_TYPE',
                        l_hr_user_type,
                        'RESP',
                        l_responsibility_id,
                        '800') then
        null;
      end if;
      l_log_message := 'Created Profile Option Value HR_USER_TYPE ' || l_hr_user_type;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.set_location(' Leaving:'|| l_proc, 50);

    else
      hr_utility.set_location(l_proc, 110);
      open csr_get_product(p_configuration_code);
      loop
        fetch csr_get_product into l_product_name;
        exit when csr_get_product%NOTFOUND;
        if l_product_name = 'PER' then
          l_hr := TRUE;
        end if;
        if l_product_name = 'PAY' then
          l_hrms := TRUE;
        end if;
      end loop;
      close csr_get_product;

      if l_hr and l_hrms then
         l_hr_user_type := 'INT';
      else
         l_hr_user_type := 'PER';
      end if;
      hr_utility.set_location(l_proc, 120);
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level                 := 10003;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value           := p_responsibility_key;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value_app       := 'PER';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_name          := 'PER_BUSINESS_GROUP_ID';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_option_value  := p_business_group_name;
      l_profile_count  := l_profile_count + 1;

      p_bg_sg_ut_profile_resp_tab(l_profile_count).level                 := 10003;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value           := p_responsibility_key;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value_app       := 'PER';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_name          := 'PER_SECURITY_PROFILE_ID';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_option_value  := p_business_group_name;
      l_profile_count  := l_profile_count + 1;

      p_bg_sg_ut_profile_resp_tab(l_profile_count).level                 := 10003;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value           := p_responsibility_key;
      p_bg_sg_ut_profile_resp_tab(l_profile_count).level_value_app       := 'PER';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_name          := 'HR_USER_TYPE';
      p_bg_sg_ut_profile_resp_tab(l_profile_count).profile_option_value  := l_hr_user_type;

      l_profile_count  := l_profile_count + 1;

      hr_utility.set_location(l_proc, 130);
    end if;
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_bg_id_and_sg_id_profile;

END per_ri_config_fnd_hr_entity;

/
