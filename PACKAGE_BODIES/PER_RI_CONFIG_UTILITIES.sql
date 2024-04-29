--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_UTILITIES" AS
/* $Header: perriutl.pkb 120.7.12010000.3 2010/05/13 08:50:13 sravikum ship $ */
  g_package                      varchar2(30)  := 'per_ri_config_utilities.';
  g_config_effective_date        date          := TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_default_date_format varchar2(200) := 'RRRR/MM/DD';

  g_config_effective_end_date   date          := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));

  /* --------------------------------------------------------------------------
  -- Name      : jpg_defined
  -- Purpose   : This function returns if Jobs or Positions are defined for
  --              a given enterprise structures configuration.
  -- Arguments : p_configuration_code
  --             p_seg_type
  -------------------------------------------------------------------------- */

  FUNCTION jpg_defined (p_configuration_code  in varchar2
                      ,p_seg_type             in varchar2)
                             RETURN boolean IS
  cursor csr_job_seg_defined (cp_configuration_code   in varchar2) IS
    select count(*)
    from per_ri_config_job_kf_seg_v
    where configuration_code    = p_configuration_code;

  cursor csr_pos_seg_defined (cp_configuration_code   in varchar2) IS
    select count(*)
      from per_ri_config_pos_kf_seg_v
     where configuration_code    = p_configuration_code;

  cursor csr_grd_seg_defined (cp_configuration_code   in varchar2) IS
    select count(*)
      from per_ri_config_grade_kf_seg_v
     where configuration_code    = p_configuration_code;

  l_proc                          varchar2(72) := g_package || 'jpg_define';
  l_error_message                 varchar2(360);

  l_jobs_seg_count                number(2) default 0;
  l_positions_seg_count           number(2) default 0;
  l_grade_seg_count               number(2) default 0;

  l_jobs_seg                      boolean default FALSE;
  l_positions_seg                 boolean default FALSE;
  l_grade_seg                     boolean default FALSE;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_seg_type = 'JOB' then
      hr_utility.set_location(l_proc, 20);
      open csr_job_seg_defined(p_configuration_code);

      fetch csr_job_seg_defined into l_jobs_seg_count;

      if l_jobs_seg_count > 0 then
        l_jobs_seg := TRUE;
        hr_utility.trace('Jobs Defined');
        hr_utility.set_location(l_proc, 30);
      end if;
      close csr_job_seg_defined;
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
      return l_jobs_seg;
    end if;

    if p_seg_type = 'POSITION' then
      hr_utility.set_location(l_proc, 40);
      open csr_pos_seg_defined(p_configuration_code);

      fetch csr_pos_seg_defined into l_positions_seg_count;

      if l_positions_seg_count > 0 then
        l_positions_seg := TRUE;
        hr_utility.trace('Positions Defined');
        hr_utility.set_location(l_proc, 50);
      end if;
      close csr_pos_seg_defined;
      hr_utility.set_location(' Leaving:'|| l_proc, 120);
      return l_positions_seg;
    end if;

    if p_seg_type = 'GRADE' then
     hr_utility.set_location(l_proc, 80);
      open csr_grd_seg_defined(p_configuration_code);

      fetch csr_grd_seg_defined into l_grade_seg_count;

      if l_grade_seg_count > 0 then
        l_grade_seg := TRUE;
        hr_utility.set_location(l_proc, 90);
      end if;
      close csr_grd_seg_defined;
      hr_utility.trace('Grades Defined');
      hr_utility.set_location(' Leaving:'|| l_proc, 130);
      return l_grade_seg;
    end if;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END jpg_defined;

  /* --------------------------------------------------------------------------
  -- Name      : regional_variance_defined
  -- Purpose   : This function returns if regional variance is defined.
  --              a given enterprise structures configuration.
  -- Arguments : p_configuration_code
  --             p_rv_type
  -------------------------------------------------------------------------- */


  FUNCTION regional_variance_defined (p_configuration_code  in varchar2
                                     ,p_rv_type             in varchar2)
                             RETURN boolean IS

  cursor csr_jp_rv_defined (cp_configuration_code   in varchar2) IS
    select count(*)
      from per_ri_config_jp_rv_v
     where configuration_code    = p_configuration_code;

  cursor csr_grd_rv_defined (cp_configuration_code   in varchar2) IS
    select count(*)
      from per_ri_config_grd_rv_v
     where configuration_code    = p_configuration_code;

  l_proc                          varchar2(72) := g_package || 'regional_variance_defined';
  l_error_message                 varchar2(360);
  l_jp_rv_count                   number(2) default 0;
  l_grd_rv_count                  number(2) default 0;

  l_jp_rv                         boolean default FALSE;
  l_grd_rv                        boolean default FALSE;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_rv_type = 'JP' then
     hr_utility.set_location(l_proc, 20);
      open csr_jp_rv_defined(p_configuration_code);

      fetch csr_jp_rv_defined into l_jp_rv_count;

      if l_jp_rv_count > 0 then
        l_jp_rv := TRUE;
        hr_utility.set_location(l_proc, 30);
      end if;
      close csr_jp_rv_defined;

      if l_jp_rv then
        hr_utility.trace('JP Regional Variance Defined');
      else
        hr_utility.trace('JP Regional Variance NOT Defined');
      end if;
      return l_jp_rv;
    end if;

    if p_rv_type = 'GRD' then
     hr_utility.set_location(l_proc, 80);
      open csr_grd_rv_defined(p_configuration_code);

      fetch csr_grd_rv_defined into l_grd_rv_count;

      if l_grd_rv_count > 0 then
        l_grd_rv := TRUE;
        hr_utility.set_location(l_proc, 90);
      end if;
      close csr_grd_rv_defined;

      if l_grd_rv then
        hr_utility.trace('Grades Regional Variance Defined');
      else
        hr_utility.trace('Grades Regional Variance NOT Defined');
      end if;

      return l_grd_rv;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 30);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END;

  /* --------------------------------------------------------------------------
  -- Name      : get_bg_job_keyflex_name
  -- Purpose   : This function returns name of JOB KEYFLEX for a business group
  --             for a given configuration
  -- Arguments : p_configuration_code
  --             p_bg_country_code
  -------------------------------------------------------------------------- */

  FUNCTION get_bg_job_keyflex_name (p_configuration_code    in varchar2
                                   ,p_bg_country_code       in varchar2)
                        RETURN varchar2 IS


  cursor csr_job_rv (cp_configuration_code   in varchar2
                    ,cp_bg_country_code      in varchar2) IS
    select rv.regional_variance_name
      from per_ri_config_jp_rv_v rv,
           per_ri_config_job_rv_seg_v seg
     where rv.configuration_code = cp_configuration_code
       and rv.reg_variance_country_code = p_bg_country_code
       and rv.configuration_code = seg.configuration_code
       and rv.regional_variance_name = seg.regional_variance_name
       and seg.global_structure_indicator = 'N';

  l_proc                          varchar2(72) := g_package || 'get_bg_job_keyflex_name';
  l_error_message                 varchar2(360);

  l_regional_variance_name        per_ri_config_information.config_information1%type;
  l_job_key_flex_name             varchar2(30);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_job_rv(p_configuration_code
                   ,p_bg_country_code);
    fetch csr_job_rv into l_regional_variance_name;
    if csr_job_rv%FOUND then
      hr_utility.set_location(l_proc, 20);
      l_job_key_flex_name :=  per_ri_config_utilities.return_config_entity_name(l_regional_variance_name)
                              || per_ri_config_main.g_job_rv_struct_def_string;
    else
      hr_utility.set_location(l_proc, 30);
      l_job_key_flex_name :=   per_ri_config_utilities.return_config_entity_name
                                       (per_ri_config_main.g_global_job_structure_name);
    end if;
    hr_utility.set_location(' Leaving:' || l_proc, 20);
    return l_job_key_flex_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_bg_job_keyflex_name;

  /* --------------------------------------------------------------------------
  -- Name      : get_bg_pos_keyflex_name
  -- Purpose   : This function returns name of POS KEYFLEX for a business group
  --             for a given configuration
  -- Arguments : p_configuration_code
  --             p_bg_country_code
  -------------------------------------------------------------------------- */

  FUNCTION get_bg_pos_keyflex_name (p_configuration_code    in varchar2
                                   ,p_bg_country_code       in varchar2)
                        RETURN varchar2 IS


  cursor csr_pos_rv (cp_configuration_code   in varchar2
                    ,cp_bg_country_code      in varchar2) IS
    select regional_variance_name
      from per_ri_config_jp_rv_v
     where configuration_code        = p_configuration_code
       and reg_variance_country_code = p_bg_country_code
       and exists (select configuration_code
                     from per_ri_config_pos_rv_seg_v
                    where configuration_code   = cp_configuration_code);

  l_proc                          varchar2(72) := g_package || 'get_bg_pos_keyflex_name';
  l_error_message                 varchar2(360);

  l_regional_variance_name        per_ri_config_information.config_information1%type;
  l_pos_key_flex_name             varchar2(30);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_pos_rv(p_configuration_code
                   ,p_bg_country_code);
    fetch csr_pos_rv into l_regional_variance_name;
    if csr_pos_rv%FOUND then
      hr_utility.set_location(l_proc, 20);
      l_pos_key_flex_name := per_ri_config_utilities.return_config_entity_name(l_regional_variance_name)
                               || per_ri_config_main.g_pos_rv_struct_def_string;
    else
      hr_utility.set_location(l_proc, 30);
      l_pos_key_flex_name :=  per_ri_config_utilities.return_config_entity_name
                                (per_ri_config_main.g_global_pos_structure_name);
    end if;
    hr_utility.set_location(' Leaving:' || l_proc, 20);
    return l_pos_key_flex_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_bg_pos_keyflex_name;

  /* --------------------------------------------------------------------------
  -- Name      : check_selected_product
  -- Purpose   : This function returns if specified product selection is made
  --             for a given configuration
  -- Arguments : p_configuration_code
  --             p_product_name
  -------------------------------------------------------------------------- */

  FUNCTION check_selected_product(p_configuration_code    in varchar2
                                 ,p_product_name          in varchar2)
                        RETURN boolean IS


  cursor csr_get_product (cp_configuration_code in varchar2
                         ,cp_product_name       in varchar2) IS
    select product_name
      from per_ri_config_prod_selection_v
     where configuration_code = cp_configuration_code
       and product_name      = cp_product_name;

  l_proc                          varchar2(72) := g_package || 'check_selected_product';
  l_error_message                 varchar2(360);

  l_product_name        per_ri_config_information.config_information1%type;
  l_product_selected    boolean default FALSE;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_get_product(p_configuration_code
                        ,p_product_name);
    fetch csr_get_product into l_product_name;
    if csr_get_product%FOUND then
      hr_utility.set_location(l_proc, 20);
      l_product_selected := TRUE;
    else
      l_product_selected := FALSE;
      hr_utility.set_location(l_proc, 30);
    end if;
    hr_utility.set_location(' Leaving:' || l_proc, 20);
    close csr_get_product;
    return l_product_selected;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END check_selected_product;

  /* --------------------------------------------------------------------------
  -- Name      : get_bg_grd_keyflex_name
  -- Purpose   : This function returns name of GRD KEYFLEX for a business group
  --             for a given configuration
  -- Arguments : p_configuration_code
  --             p_bg_country_code
  -------------------------------------------------------------------------- */

  FUNCTION get_bg_grd_keyflex_name(p_configuration_code           in varchar2
                                  ,p_bg_country_code              in varchar2)
                        RETURN varchar2 IS


  cursor csr_grd_rv (cp_configuration_code   in varchar2
                    ,cp_bg_country_code      in varchar2) IS
    select per_ri_config_utilities.return_config_entity_name(regional_variance_name)
      from per_ri_config_grd_rv_v
     where configuration_code        = p_configuration_code
       and reg_variance_country_code = p_bg_country_code;

  l_proc                          varchar2(72) := g_package || 'get_bg_grd_keyflex_name';
  l_error_message                 varchar2(360);
  l_regional_variance_name        per_ri_config_information.config_information1%type;
  l_grd_key_flex_name             varchar2(30);
  l_enterprise_primary_industry   per_ri_config_information.config_information1%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                            (p_configuration_code => p_configuration_code);
    hr_utility.trace('l_enterprise_primary_industry = ' || l_enterprise_primary_industry);
    if l_enterprise_primary_industry <>  'US_GOVERNMENT' then
      open csr_grd_rv(p_configuration_code
                     ,p_bg_country_code);
      fetch csr_grd_rv into l_regional_variance_name;
      if csr_grd_rv%FOUND then
        hr_utility.set_location(l_proc, 20);
        l_grd_key_flex_name := l_regional_variance_name || per_ri_config_main.g_grd_rv_struct_def_string;
      else
        hr_utility.set_location(l_proc, 30);
        l_grd_key_flex_name :=   per_ri_config_utilities.return_config_entity_name
                                   (per_ri_config_main.g_global_grd_structure_name);
      end if;
      hr_utility.trace('Grade Key Flex Name : ' || l_grd_key_flex_name);
      hr_utility.set_location(' Leaving:' || l_proc, 20);
    else
      hr_utility.set_location(l_proc, 40);
      l_grd_key_flex_name :=  per_ri_config_main.g_global_fed_grd_struct_name;
    end if;

    hr_utility.trace('l_grd_key_flex_name = ' || l_grd_key_flex_name);

    hr_utility.set_location(' Leaving:'|| l_proc, 60);

    return l_grd_key_flex_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_bg_grd_keyflex_name;

  /* --------------------------------------------------------------------------
  -- Name      : get_enterprise_short_name
  -- Purpose   : This function returns name of enterpise short name
  --             for a given configuration
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION get_enterprise_short_name (p_configuration_code    in varchar2)
                        RETURN varchar2 IS

  cursor csr_get_enterprise_short_name
                  (cp_configuration_code            in varchar2) IS
    select enterprise_short_name
      from per_ri_config_enterprise_v
    where  configuration_code    = p_configuration_code;

  l_enterprise_short_name   per_ri_config_information.config_information1%type;
  l_proc            varchar2(72) := g_package || 'get_enterprise_short_name';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_get_enterprise_short_name(p_configuration_code);

    fetch csr_get_enterprise_short_name into
               l_enterprise_short_name;
    if csr_get_enterprise_short_name%NOTFOUND then
        hr_utility.set_location('Entering:'|| l_proc, 20);
    end if;

    close csr_get_enterprise_short_name;

    hr_utility.set_location(' Leaving:'|| l_proc, 30);

    -- Working on this issue
    if g_enterprise_short_name is NULL then
      g_enterprise_short_name := l_enterprise_short_name;
    end if;

    -- Always set this value
    g_enterprise_short_name := l_enterprise_short_name;
    return l_enterprise_short_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END;

  /* --------------------------------------------------------------------------
  -- Name      : get_enterprise_name
  -- Purpose   : This function returns enterprise name for a given configuration
  -- Arguments : p_configuration_code
  --             p_bg_country_code
  -------------------------------------------------------------------------- */

  FUNCTION get_enterprise_name(p_configuration_code    in varchar2)
                        RETURN varchar2 IS

  cursor csr_get_enterprise_name(cp_configuration_code            in varchar2) IS
    select per_ri_config_utilities.return_config_entity_name(enterprise_name)
      from per_ri_config_enterprise_v
     where configuration_code    = p_configuration_code;

  l_enterprise_name               per_ri_config_information.config_information1%type;
  l_proc                          varchar2(72) := g_package || 'get_enterprise_name';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_get_enterprise_name(p_configuration_code);

    fetch csr_get_enterprise_name into
                 l_enterprise_name;
    if csr_get_enterprise_name%NOTFOUND then
      hr_utility.set_location('Entering:'|| l_proc, 20);
    end if;

    close csr_get_enterprise_name;

    hr_utility.trace('l_enterprise_name = ' || l_enterprise_name);
    hr_utility.set_location(' Leaving:'|| l_proc, 30);

    return l_enterprise_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END;

  /* --------------------------------------------------------------------------
  -- Name      : get_ent_primary_industry
  -- Purpose   : This function returns name enterprise primary industry
  --             for a given configuration
  -- Arguments : get_ent_primary_industry
  --
  -------------------------------------------------------------------------- */

  FUNCTION get_ent_primary_industry(p_configuration_code    in varchar2)
                        RETURN varchar2 IS

  cursor csr_get_ent_industry(cp_configuration_code            in varchar2) IS
    select enterprise_primary_industry
      from per_ri_config_enterprise_v
     where configuration_code    = p_configuration_code;

  l_enterprise_primary_industry    per_ri_config_information.config_information1%type;

  l_proc                          varchar2(72) := g_package || 'get_ent_primary_industry';
  l_error_message                 varchar2(360);
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_get_ent_industry(p_configuration_code);

    fetch csr_get_ent_industry into l_enterprise_primary_industry;
    if csr_get_ent_industry%NOTFOUND then
      hr_utility.set_location(l_proc, 20);
    end if;

    close csr_get_ent_industry;

    hr_utility.trace('l_enterprise_primary_industry = ' || l_enterprise_primary_industry);
    hr_utility.set_location(' Leaving:'|| l_proc, 30);

    return l_enterprise_primary_industry;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_ent_primary_industry;

  /* --------------------------------------------------------------------------
  -- Name      : business_group_decision
  -- Purpose   : This function decision about the business group based unon the
  --             'Business Group' creation logic for a given configuration
  -- Arguments : p_configuration_code
  --             p_country_code
  --             p_number_of_employees
  --             p_payroll_to_process_employees
  --             p_hr_support_for_this_country
  -------------------------------------------------------------------------- */

  FUNCTION business_group_decision(p_configuration_code           in varchar2 default null
                                  ,p_country_code                 in varchar2
                                  ,p_number_of_employees          in varchar2 default null
                                  ,p_payroll_to_process_employees in varchar2 default null
                                  ,p_hr_support_for_this_country  in varchar2 default null)
                          RETURN varchar2 IS

  cursor csr_config_business_groups(cp_configuration_code in varchar2
                                    ,cp_country_code       in varchar2) IS
  select configuration_code,
         country_code,
         number_of_employees,
         payroll_to_process_employees,
         hr_support_for_this_country
    from per_ri_config_country_v
   where country_code       = cp_country_code
     and configuration_code = cp_configuration_code;

  l_configuration_code            per_ri_config_information.configuration_code%type;
  l_country_code                  per_ri_config_information.config_information1%type;
  l_number_of_employees           per_ri_config_information.config_information1%type;
  l_payroll_to_process_employees  per_ri_config_information.config_information1%type;
  l_hr_support_for_this_country   per_ri_config_information.config_information1%type;
  l_business_group_decision       per_ri_config_information.config_information1%type;
  l_called_from_ui                boolean default FALSE;

  l_proc                          varchar2(72) := g_package || 'business_group_decision';
  l_error_message                 varchar2(360);

  BEGIN

    hr_utility.set_location('Entering: '|| l_proc, 10);

    if (p_number_of_employees is not null)
          and (p_payroll_to_process_employees is not null)
          and (p_hr_support_for_this_country is not null) then
      l_called_from_ui := TRUE;
    end if;

    if NOT l_called_from_ui then
      open csr_config_business_groups(p_configuration_code
                                    ,p_country_code);
      fetch csr_config_business_groups into
                 l_configuration_code,
                 l_country_code,
                 l_number_of_employees,
                 l_payroll_to_process_employees,
                 l_hr_support_for_this_country;
    else
      l_configuration_code              := null;
      l_country_code                    := p_country_code;
      l_number_of_employees             := p_number_of_employees;
      l_payroll_to_process_employees    := p_payroll_to_process_employees;
      l_hr_support_for_this_country     := p_hr_support_for_this_country;
    end if;

    if l_country_code = 'US' then
      l_business_group_decision := 'US';
    else
      if l_payroll_to_process_employees = 'N' then
        if l_number_of_employees <= 100 then
          l_business_group_decision := 'INT';
        else
          if (per_ri_config_utilities.legislation_support(l_country_code, 'PER')) = TRUE then
            l_business_group_decision := l_country_code;
          else
            if (l_hr_support_for_this_country = 'Y' ) then
              l_business_group_decision := l_country_code;
            else
              l_business_group_decision := 'INT';
            end if;
          end if;
        end if;
      else
        if (per_ri_config_utilities.legislation_support(l_country_code, 'PAY')) = TRUE then
          l_business_group_decision := l_country_code;
        else
          -- revisit it
          -- l_business_group_decision := 'INT';
          l_business_group_decision := l_country_code;
        end if;
      end if;
    end if;

    hr_utility.trace('l_country_code = ' || l_country_code);
    hr_utility.trace('l_business_group_decision = ' || l_business_group_decision);
    if NOT l_called_from_ui then
      close csr_config_business_groups;
    end if;

    hr_utility.set_location(' Leaving: '|| l_proc, 20);

    if NOT l_called_from_ui then
      return l_business_group_decision;
    else
       return per_ri_config_utilities.get_country_display_name
                              (p_territory_code    => l_business_group_decision);
    end if;

    return l_business_group_decision;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END business_group_decision;

  /* --------------------------------------------------------------------------
  -- Name      : legislation_support
  -- Purpose   : This function returns if HRMS support that legislation
  -- Arguments : p_legislation_code
  --             p_application_short_name
  -------------------------------------------------------------------------- */

  FUNCTION legislation_support(p_legislation_code       in varchar2
                              ,p_application_short_name in varchar2) RETURN BOOLEAN IS

  cursor csr_legislation_support(cp_legislation_code in varchar2
                                  ,cp_application_short_name in varchar2) IS
    select legislation_code
      from hr_legislation_installations
    where  legislation_code       = cp_legislation_code
      and  application_short_name = cp_application_short_name;

  l_legislation_code              hr_legislation_installations.legislation_code%type;
  l_application_short_name        hr_legislation_installations.application_short_name%type;
  l_legislation_support           BOOLEAN;

  l_proc                          varchar2(72) := g_package || 'legislation_support';
  l_error_message                 varchar2(360);

    BEGIN

      hr_utility.set_location('Entering:'|| l_proc, 10);

      open csr_legislation_support(p_legislation_code
                                  ,p_application_short_name);
      fetch csr_legislation_support into
                 l_legislation_code;
      if csr_legislation_support%FOUND then
         l_legislation_support := TRUE;
      else
          l_legislation_support := FALSE;
      end if;

      close csr_legislation_support;
      hr_utility.trace('l_legislation_code = ' || l_legislation_code);
      hr_utility.set_location(' Leaving:'|| l_proc, 30);

      return l_legislation_support;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END legislation_support;

  /* --------------------------------------------------------------------------
  -- Name      : set_profile_option_value
  -- Purpose   : This procedure sets the profile option values for a specified
  --             level (SITE, APPLICATION, RESPOSIBILITY or USER).
  -- Arguments : p_level
  --             p_level_value
  --             p_profile_name
  --             p_profile_name
  --             p_profile_option_value
  --             p_custom_mode
  --             p_owner
  -------------------------------------------------------------------------- */

  PROCEDURE set_profile_option_value(p_level                in number
                                    ,p_level_value          in varchar2
                                    ,p_level_value_app      in varchar2
                                    ,p_profile_name         in varchar2
                                    ,p_profile_option_value in varchar2
                                    ,p_custom_mode          in varchar2 DEFAULT 'FORCE'
                                    ,p_owner                in varchar2 DEFAULT 'CUSTOM') IS

  app_id                          number := 0;
  profo_id                        number := 0;
  levval_id                       number := 0;
  lapp_id                         number := null;
  f_luby                          number;  -- entity owner in file
  f_ludate                        date := sysdate;    -- entity update date in file
  found                           varchar2(1);

  l_proc                          varchar2(72) := g_package || 'set_profile_option_value';
  l_error_message                 varchar2(360);

  BEGIN
     hr_utility.set_location('Entering:'|| l_proc, 10);
     hr_utility.trace('p_level:'|| p_level);
     if (p_level = '10001') then
       levval_id := 0;
     elsif (p_level = '10002') then
       select application_id into levval_id
       from   fnd_application
       where  application_short_name = p_level_value;
     elsif (p_level = '10003') then
       select application_id into lapp_id
       from   fnd_application
       where  application_short_name = p_level_value_app;

       select responsibility_id into levval_id
       from   fnd_responsibility
       where  application_id = lapp_id
       and    responsibility_key = p_level_value;
     elsif (p_level = '10005') then
       select server_id into levval_id
       from fnd_nodes
       where node_name = p_level_value;
     elsif (p_level = '10006') then
       select organization_id into levval_id
       from hr_operating_units
       where name = p_level_value;
     else
       select user_id into levval_id
       from   fnd_user
       where  user_name = p_level_value;
     end if;

     select profile_option_id, application_id
     into   profo_id, app_id
     from   fnd_profile_options
     where  profile_option_name = p_profile_name;

     f_luby := fnd_load_util.owner_id(p_owner);

     begin
       --
       -- This section should never perform updates to existing
       -- data unless CUSTOM_MODE is equal to FORCE
       --

      if (p_level = '10003') then
       select 'Y' into found
       from   FND_PROFILE_OPTION_VALUES
       where  PROFILE_OPTION_ID = profo_id
       and    APPLICATION_ID = app_id
       and    LEVEL_ID = 10003
       and    LEVEL_VALUE_APPLICATION_ID = lapp_id
       and    LEVEL_VALUE = levval_id;
       hr_utility.trace('Found Record..' || lapp_id || ' ' || levval_id);
      else
       select 'Y' into found
       from   FND_PROFILE_OPTION_VALUES
       where  PROFILE_OPTION_ID = profo_id
       and    APPLICATION_ID = app_id
       and    LEVEL_ID = to_number(p_level)
       and    LEVEL_VALUE = levval_id;
      end if;

       if (p_custom_mode = 'FORCE') then
         update fnd_profile_option_values
         set   profile_option_value = p_profile_option_value,
               last_update_date = f_ludate,
               last_updated_by = f_luby,
               last_update_login = 0
         where application_id = app_id
           and profile_option_id = profo_id
           and level_id = to_number(p_level)
           and nvl(level_value_application_id, 1) =
                   decode(p_level, '10003', lapp_id, 1)
           and level_value = levval_id;
       end if;
     exception
       when no_data_found then
         hr_utility.trace('Creating Profile Option Value..');
         insert into fnd_profile_option_values (
           application_id,
           profile_option_id,
           level_id,
           level_value,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           profile_option_value,
           level_value_application_id )
         values (
           app_id,
           profo_id,
           to_number(p_level),
           levval_id,
           f_ludate,
           f_luby,
           f_ludate,
           f_luby,
           0,
           p_profile_option_value,
           decode(p_level, '10003', lapp_id, null));
     end;
   end;

  /* --------------------------------------------------------------------------
  -- Name      : create_key_flexfield
  -- Purpose   : This function create a given KEYFLEX structure and returns
  --             a number
  -- Arguments : p_appl_short_name
  --             p_flex_code
  --             p_structure_code
  --             p_structure_title
  --             p_description
  --             p_view_name
  --             p_freeze_flag
  --             p_enabled_flag
  --             p_cross_val_flag
  --             p_freeze_rollup_flag
  --             p_dynamic_insert_flag
  --             p_shorthand_enabled_flag
  --             p_shorthand_prompt
  --             p_shorthand_length
  --             p_application_short_name
  -------------------------------------------------------------------------- */


  FUNCTION create_key_flexfield
                      (p_appl_short_Name         in varchar2
                      ,p_flex_code               in varchar2
                      ,p_structure_code          in varchar2
                      ,p_structure_title         in varchar2
                      ,p_description             in varchar2
                      ,p_view_name               in varchar2 default null
                      ,p_freeze_flag             in varchar2 default 'N'
                      ,p_enabled_flag            in varchar2 default 'Y'
                      ,p_cross_val_flag          in varchar2 default 'N'
                      ,p_freeze_rollup_flag      in varchar2 default 'N'
                      ,p_dynamic_insert_flag     in varchar2 default 'Y'
                      ,p_shorthand_enabled_flag  in varchar2 default 'N'
                      ,p_shorthand_prompt        in varchar2 default null
                      ,p_shorthand_length        in number   default null)
                                                     RETURN NUMBER IS

  l_flexfield                    fnd_flex_key_api.flexfield_type;
  l_structure                    fnd_flex_key_api.structure_type;
  l_application_id	         number(15);
  l_proc                         varchar2(80) := g_package || 'create_key_flexfield';
  l_log_message                  varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    fnd_flex_key_api.set_session_mode('customer_data');

    l_flexfield := fnd_flex_key_api.find_flexfield
                                (appl_short_name         => p_appl_short_name
                                ,flex_code               => p_flex_code );

    hr_utility.set_location(l_proc, 20);

    BEGIN
      l_structure := fnd_flex_key_api.find_structure
           (flexfield              => l_flexfield,
             structure_code         => p_structure_code );

      return l_structure.structure_number;
      hr_utility.set_location('Entering:'|| l_proc, 30);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 40);
          l_structure:=fnd_flex_key_api.new_structure
          		    (flexfield             => l_flexfield,
                            structure_code         => p_structure_code,
                            structure_title        => p_structure_title,
                            description            => p_description,
                            view_name              => p_view_name,
                            freeze_flag            => p_freeze_flag,
                            enabled_flag           => p_enabled_flag,
                            segment_separator      => '.',
                            cross_val_flag         => p_cross_val_flag,
                            freeze_rollup_flag     => p_freeze_rollup_flag,
                            dynamic_insert_flag    => p_dynamic_insert_flag,
                            shorthand_enabled_flag => p_shorthand_enabled_flag,
                            shorthand_prompt       => p_shorthand_prompt,
                            shorthand_length       => p_shorthand_length);

          SELECT application_id
          INTO l_application_id
          FROM FND_APPLICATION
          WHERE application_short_name = p_appl_short_name;

          SELECT NVL(MAX(ifs.id_flex_num),0) + 1
	    INTO l_structure.structure_number
	    FROM fnd_id_flex_structures ifs
           WHERE ifs.application_id = l_application_id
	     AND ifs.id_flex_code = p_flex_code
	     AND ifs.id_flex_num < 101;

          fnd_flex_key_api.add_structure
                   ( flexfield              => l_flexfield,
                     structure              => l_structure );

          RETURN l_structure.structure_number;
      END;

      hr_utility.set_location(' Leaving:'|| l_proc, 100);

    END create_key_flexfield;

  /* --------------------------------------------------------------------------
  -- Name      : create_flex_segments
  -- Purpose   : This procedure create flexfiled  returns if HRMS support that legislation
  -- Arguments : p_appl_short_name
  --             p_flex_code
  --             p_structure_code
  --             p_segment_name
  --             p_column_name
  --             p_segment_number
  --             p_enabled_flag
  --             p_displayed_flag
  --             p_indexed_flag
  --             p_value_set
  --             p_display_size
  --             p_description_size
  --             p_concat_size
  --             p_lov_prompt
  --             p_window_prompt
  --             p_segment_type
  --             p_fed_seg_attribute
  -------------------------------------------------------------------------- */

  PROCEDURE create_flex_segments
                   (p_appl_Short_Name           in varchar2
                   ,p_flex_code                 in varchar2
                   ,p_structure_code            in varchar2
                   ,p_segment_name              in varchar2
                   ,p_column_name               in varchar2
                   ,p_segment_number            in varchar2
                   ,p_enabled_flag              in varchar2 default 'Y'
                   ,p_displayed_flag            in varchar2 default 'Y'
                   ,p_indexed_flag              in varchar2 default 'Y'
                   ,p_value_set                 in varchar2
                   ,p_display_size              in number   default 60
                   ,p_description_size          in number   default 60
                   ,p_concat_size               in number   default 60
                   ,p_lov_prompt                in varchar2
                   ,p_window_prompt             in varchar2
                   ,p_segment_type              in varchar2 default 'CHAR'
                   ,p_fed_seg_attribute         in varchar2 default 'N') IS

  l_flexfield                    fnd_flex_key_api.flexfield_type;
  l_structure                    fnd_flex_key_api.structure_type;
  l_application_id		 number(15);
  l_flex_num			 number(15);
  l_segment                      fnd_flex_key_api.segment_type;
  l_valueset_seq                 number(9);
  l_valueset_name                fnd_flex_value_sets.flex_value_set_name%type;

  l_proc                         varchar2(80) := g_package || 'create_flex_segments';
  l_log_message                  varchar2(360);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    fnd_flex_key_api.set_session_mode('customer_data');

    l_flexfield := fnd_flex_key_api.find_flexfield
                                (appl_short_name         => p_appl_short_name
                                ,flex_code               => p_flex_code );

    hr_utility.set_location(l_proc, 20);

    l_structure := fnd_flex_key_api.find_structure
                                  (flexfield              => l_flexfield
                                  ,structure_code         => p_structure_code );
    BEGIN
      hr_utility.trace(p_segment_name);
      l_segment := fnd_flex_key_api.find_segment
                                      (flexfield              => l_flexfield
                                      ,structure              => l_structure
                                      ,segment_name           => p_segment_name);
      hr_utility.set_location('Entering:'|| l_proc, 30);
    EXCEPTION
      when no_data_found then

        if p_fed_seg_attribute = 'N' then
          --
          -- create flex segment value set
          --
          select per_ri_config_vsets_number_s.nextval into l_valueset_seq from sys.dual;
          l_valueset_seq := p_segment_number;
          l_valueset_name  :=  p_structure_code || ' ' || p_segment_name
                                                 || ' ' || l_valueset_seq;

          hr_utility.trace('l_valueset_name = ' || l_valueset_name);
          per_ri_config_utilities.create_valueset(p_valueset_name => l_valueset_name
                                               ,p_valueset_type => p_segment_type);
        end if;
        hr_utility.set_location('Entering:'|| l_proc, 40);
        hr_utility.trace('p_segment_number = ' || to_char(p_segment_number));

        -- valueset name is always passed when p_fed_seg_attribute = 'Y'
        if p_fed_seg_attribute = 'Y' then
          l_valueset_name := p_value_set;
        end if;

        l_segment:= fnd_flex_key_api.new_segment
                      (flexfield                      => l_flexfield
                      ,structure                      => l_structure
                      ,segment_name                   => p_segment_name
                      ,description                    => null
                      ,column_name                    => p_column_name
                      ,segment_number                 => p_segment_number
                      ,enabled_flag                   => p_enabled_flag
                      ,displayed_flag                 => p_displayed_flag
                      ,indexed_flag                   => p_indexed_flag
                      ,value_set                      => l_valueset_name
                      ,default_type                   => null
                      ,default_value                  => null
                      ,required_flag                  => 'N'
                      ,security_flag                  => 'N'
                      ,display_size                   => p_display_size
                      ,description_size               => p_description_size
                      ,concat_size                    => p_concat_size
                      ,lov_prompt                     => p_lov_prompt
                      ,window_prompt                  => p_window_prompt);

        hr_utility.set_location(l_proc, 100);

        hr_utility.trace(p_segment_name);
        BEGIN
          hr_utility.set_location(l_proc, 110);
            fnd_flex_key_api.add_segment(flexfield               => l_flexfield
                                        ,structure               => l_structure
                                        ,segment                 => l_segment);
            --
            --assign qualifiers for CMP and COST KF.
            --

            if p_flex_code = 'CMP' and p_appl_short_name = 'PER' then
              hr_utility.trace('Assigning Qualifiers 111');
              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'Default Attribute',
                                   enable_flag           => 'Y');
              hr_utility.trace('Assigned Qualifier CMP : Default Attribute');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'Others',
                                   enable_flag           => 'Y');
            end if;

            if p_flex_code = 'COST' and p_appl_short_name = 'PAY' then
              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'ASSIGNMENT',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : ASSIGNMENT');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'BALANCING',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : BALANCING');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'ELEMENT',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : ELEMENT');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'ELEMENT ENTRY',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : ELEMENT ENTRY');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'ORGANIZATION',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : ORGANIZATION');

              fnd_flex_key_api.assign_qualifier(flexfield  => l_flexfield,
                                   structure             => l_structure,
                                   segment               => l_segment,
                                   flexfield_qualifier   => 'PAYROLL',
                                   enable_flag           => 'Y');
              hr_utility.trace('assigned qualifier COST : PAYROLL');
            end if;

        EXCEPTION
          when others then
            hr_utility.trace(substr(fnd_flex_key_api.message,1,256));
      END;

    END;

  END create_flex_segments;
  /* --------------------------------------------------------------------------
  -- Name      : write_log
  -- Purpose   : This function write logfile for enterprise structures configuration
  --             loader program.
  -- Arguments : p_message
  --             p_write_to_log_flag
  -------------------------------------------------------------------------- */


  PROCEDURE write_log(p_message    in varchar2
                     ,p_write_to_log_flag in boolean default TRUE) IS

    l_proc            varchar2(72) := g_package || 'write_log';

    BEGIN

      hr_utility.trace(p_message);
      if p_write_to_log_flag then
         fnd_file.put_line(fnd_file.log, p_message);
      end if;
  END write_log;

  /* --------------------------------------------------------------------------
  -- Name      : get_le_bg_name
  -- Purpose   : This function returns name of LE business group for a given
  --             configuration
  -- Arguments : p_configuration_code
  --             p_legal_entity_name
  -------------------------------------------------------------------------- */

  FUNCTION get_le_bg_name(p_configuration_code          in varchar2
                         ,p_legal_entity_name           in varchar2)
                        RETURN varchar2 IS

  cursor csr_le_bg_name(cp_configuration_code      in varchar2
                       ,cp_legal_entity_name       in varchar2) IS
    select legal_entity_country
      from per_ri_config_legal_entity_v
    where  configuration_code   = cp_configuration_code
     and   legal_entity_name    = cp_legal_entity_name;

  l_le_business_group_name         per_ri_config_information.config_information1%type;
  l_legal_entity_country_name      per_ri_config_information.config_information1%type;

  l_proc                          varchar2(72) := g_package || 'get_le_bg_name';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_le_bg_name(p_configuration_code
                       ,p_legal_entity_name);
    loop
      fetch csr_le_bg_name into l_legal_entity_country_name;
      exit when csr_le_bg_name%NOTFOUND;
      l_le_business_group_name := per_ri_config_utilities.business_group_decision
                                                 (p_configuration_code
                                                 ,l_legal_entity_country_name);

      hr_utility.trace('l_legal_entity_country_name = ' || l_legal_entity_country_name);
      hr_utility.trace('l_le_business_group_name = ' || l_le_business_group_name);
    end loop;
    close csr_le_bg_name;
    hr_utility.set_location(' Leaving:'|| l_proc, 10);
    return l_le_business_group_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_le_bg_name;


  /* --------------------------------------------------------------------------
  -- Name      : get_oc_bg_name
  -- Purpose   : This function returns name of OC business group for a given
  --             configuration
  -- Arguments : p_configuration_code
  --             p_legal_entity_name
  -------------------------------------------------------------------------- */

  FUNCTION get_oc_bg_name(p_configuration_code      in varchar2
                         ,p_operating_company_name    in varchar2) RETURN varchar2 IS

  cursor csr_oct_bg_name(cp_configuration_code      in varchar2
                        ,cp_operating_company_name  in varchar2) IS
    select operating_company_hq_country
      from per_ri_config_oper_comp_v
    where  configuration_code        = cp_configuration_code
     and   operating_company_name    = cp_operating_company_name;

  l_oc_business_group_name         per_ri_config_information.config_information1%type;
  l_operating_company_hq_country   per_ri_config_information.config_information1%type;

  l_proc                          varchar2(72) := g_package || 'get_oc_bg_name';
  l_error_message                 varchar2(360);
  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_oct_bg_name(p_configuration_code
                         ,p_operating_company_name);
    -- if country selected is not there put that in international, if int is not created then put it for hq bg
    loop
      fetch csr_oct_bg_name into l_operating_company_hq_country;
      exit when csr_oct_bg_name%NOTFOUND;
      l_oc_business_group_name := per_ri_config_utilities.business_group_decision
                                                 (p_configuration_code
                                                 ,l_operating_company_hq_country);

      hr_utility.trace('l_operating_company_hq_country = ' || l_operating_company_hq_country);
      hr_utility.trace('l_oc_business_group_name = ' || l_oc_business_group_name);
    end loop;
    close csr_oct_bg_name;
    hr_utility.set_location(' Leaving:'|| l_proc, 10);
    return l_oc_business_group_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_oc_bg_name;

  /* --------------------------------------------------------------------------
  -- Name      : get_enterprise_bg_name
  -- Purpose   : This function returns name of enterprise business group for a
  --              given configuration.
  -- Arguments : p_configuration_code
  --             p_enterprise_name
  -------------------------------------------------------------------------- */
  FUNCTION get_enterprise_bg_name(p_configuration_code      in varchar2
                                 ,p_enterprise_name         in varchar2) RETURN varchar2 IS

  cursor csr_ent_bg_name(cp_configuration_code     in varchar2
                        ,cp_enterprise_name        in varchar2) IS
    select enterprise_headquarter_country
      from per_ri_config_enterprise_v
    where  configuration_code = cp_configuration_code
      and  enterprise_name    = cp_enterprise_name;

  l_business_group_name        per_ri_config_information.config_information1%type;
  l_enterprise_hq_country  per_ri_config_information.config_information1%type;

  l_proc            varchar2(72) := g_package || 'get_enterprise_bg_name';
  l_error_message                 varchar2(360);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_ent_bg_name(p_configuration_code
                        ,p_enterprise_name);
    loop
      fetch csr_ent_bg_name into
                 l_enterprise_hq_country;
      exit when csr_ent_bg_name%NOTFOUND;
      l_business_group_name := per_ri_config_utilities.business_group_decision
                                                 (p_configuration_code
                                                 ,l_enterprise_hq_country);

      hr_utility.trace('l_enterprise_hq_country = ' || l_enterprise_hq_country);
      hr_utility.trace('l_business_group_name = ' || l_business_group_name);
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      return l_business_group_name;
    end loop;
    close csr_ent_bg_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_enterprise_bg_name;

  /* --------------------------------------------------------------------------
  -- Name      : get_config_location_code
  -- Purpose   : This function returns location code for a location id
  -- Arguments : p_legislation_code
  --             p_application_short_name
  -------------------------------------------------------------------------- */

  FUNCTION get_config_location_code(p_configuration_code      in varchar2
                            ,p_location_id             in number)
                        RETURN varchar2 IS

  cursor csr_location(cp_configuration_code     in varchar2
                     ,cp_location_id            in number) IS
    select location_code
      from per_ri_config_locations
    where  configuration_code  = cp_configuration_code
      and  location_id         = cp_location_id;

  l_location_code        per_ri_config_information.config_information1%type;

  l_proc            varchar2(72) := g_package || 'get_config_location_code';
  l_error_message                 varchar2(360);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_location(p_configuration_code
                      ,p_location_id);
    loop
      fetch csr_location into l_location_code;
      exit when csr_location%NOTFOUND;
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      return per_ri_config_utilities.return_config_entity_name(l_location_code);
    end loop;
    close csr_location;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_config_location_code;

  /* --------------------------------------------------------------------------
  -- Name      : mandatory_org_info_types
  -- Purpose   : This function returns if any mandatory org info types are
  --             are defined for given legilsationa and org class.
  -- Arguments : p_legislation_code
  --             p_org_classification
  -------------------------------------------------------------------------- */

  FUNCTION mandatory_org_info_types(p_legislation_code    in varchar2
                                   ,p_org_classification  in varchar2)
                        RETURN BOOLEAN IS

  cursor csr_mandatory_org_info_types(cp_legislation_code     in varchar2
                                     ,cp_org_classification   in varchar2) IS
    select 'X'
      from hr_org_info_types_by_class class,
           hr_org_information_types  type
     where class.org_information_type = type.org_information_type
       and class.mandatory_flag = 'Y'
       and type.legislation_code = cp_legislation_code
       and class.org_classification = cp_org_classification;

  l_proc                          varchar2(72) := g_package || 'mandatory_org_info_types_defined';
  l_error_message                 varchar2(360);
  l_defined                       boolean default TRUE;
  l_found                         varchar2(1);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_mandatory_org_info_types(p_legislation_code
                                     ,p_org_classification);
    fetch csr_mandatory_org_info_types into l_found;
    if  csr_mandatory_org_info_types%FOUND then
        hr_utility.trace('Mandatory Org Info Types ARE defined for ' || p_legislation_code);
        l_defined :=  TRUE;
    else
        hr_utility.trace('Mandatory Org Info Types NOT defined for ' || p_legislation_code);
        l_defined :=  FALSE;
    end if;
    close csr_mandatory_org_info_types;

    hr_utility.trace('p_legislation_code =  ' || p_legislation_code);
    hr_utility.set_location(' Leaving:'|| l_proc, 10);

    return l_defined;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END mandatory_org_info_types;

  /* --------------------------------------------------------------------------
  -- Name      : check_currency_enabled
  -- Purpose   : This function returns if currecny is enabled.
  -- Arguments : p_legislation_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION check_currency_enabled(p_legislation_code  in varchar2)
                        RETURN varchar2 IS

  cursor csr_country_currency(cp_legislation_code     in varchar2) IS
    select enabled_flag
      from fnd_currencies
     where issuing_territory_code = cp_legislation_code;

  l_proc            varchar2(72) := g_package || 'check_currency_enabled';
  l_error_message                 varchar2(360);
  l_enabled_flag    varchar2(30);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_country_currency(p_legislation_code);
    fetch csr_country_currency into l_enabled_flag;
    if  csr_country_currency%FOUND then
        hr_utility.trace('l_enabled_flag = ' || l_enabled_flag);
    else
        hr_utility.trace('l_enabled_flag NOT DEFIINED ');
    end if;
    close csr_country_currency;

    hr_utility.set_location(' Leaving:'|| l_proc, 20);

    return l_enabled_flag;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END check_currency_enabled;


  /* --------------------------------------------------------------------------
  -- Name      : get_country_currency
  -- Purpose   : This function returns county currency.
  -- Arguments : p_legislation_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION get_country_currency(p_legislation_code  in varchar2)
                        RETURN varchar2 IS

  cursor csr_country_currency(cp_legislation_code     in varchar2) IS
    select currency_code
      from pay_leg_setup_defaults
     where legislation_code = cp_legislation_code;

  l_proc            varchar2(72) := g_package || 'get_country_currency';
  l_error_message                 varchar2(360);
  l_currency_code   varchar2(30);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_country_currency(p_legislation_code);
    fetch csr_country_currency into l_currency_code;
    if  csr_country_currency%FOUND then
        hr_utility.trace('l_currency_code = ' || l_currency_code);
    else
        hr_utility.trace('l_currency_code NOT DEFIINED ');
    end if;
    close csr_country_currency;

    hr_utility.set_location(' Leaving:'|| l_proc, 20);

    return l_currency_code;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_country_currency;

  /* --------------------------------------------------------------------------
  -- Name      : enable_country_currency
  -- Purpose   : This procedure enables currecny of a given legislation.
  -- Arguments : p_legislation_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE enable_country_currency(p_legislation_code  in varchar2) IS

  cursor csr_country_currency(cp_legislation_code     in varchar2) IS
    select currency_code
      from pay_leg_setup_defaults
     where legislation_code = cp_legislation_code;

  l_proc            varchar2(72) := g_package || 'enable_country_currency';
  l_currency_code   varchar2(30);
  l_error_message                 varchar2(360);

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('p_legislation_code = '|| p_legislation_code);

    open csr_country_currency(p_legislation_code);
    fetch csr_country_currency into l_currency_code;
    if  csr_country_currency%FOUND then
        update fnd_currencies set enabled_flag = 'Y' where currency_code = l_currency_code;
        hr_utility.trace('Enabled Currecny = ' || l_currency_code);
    else
        hr_utility.trace('l_currency_code NOT DEFIINED ');
    end if;
    close csr_country_currency;

    hr_utility.set_location(' Leaving:'|| l_proc, 20);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END enable_country_currency;

  /* --------------------------------------------------------------------------
  -- Name      : create_valueset
  -- Purpose   : This procedure creates a value set
  -- Arguments : p_valueset_name
  --             p_valueset_type
  -------------------------------------------------------------------------- */

  PROCEDURE create_valueset(p_valueset_name           in varchar2
                           ,p_valueset_type           in varchar2) IS

  l_proc                         varchar2(72) := g_package || 'create_valueset';
  l_error_message                 varchar2(360);
  l_log_message                  varchar2(360);

  l_security_available           varchar2(1)    default 'N';
  l_enable_longlist              varchar2(1)    default 'Y';
  l_format_type                  varchar2(1)    default 'C';
  l_maximum_size                 number(9)      default 60;
  l_precision                    number(2)      default null;
  l_numbers_only                 varchar2(1)    default 'N';
  l_uppercase_only               varchar2(1)    default 'N';
  l_right_justify_zero_fill      varchar2(1)    default 'N';
  l_min_value                    varchar2(150)  default null;
  l_max_value                    varchar2(150)  default null;
  l_description                  varchar2(240);
  l_value_set_exists             boolean;

  l_valueset_seq                 number(9);
  l_valueset_name                fnd_flex_value_sets.flex_value_set_name%type;

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    fnd_flex_val_api.set_session_mode('customer_data');

    if p_valueset_type = 'CHAR' then
      l_format_type   := 'C';
      l_maximum_size  := 60;
    elsif  p_valueset_type = 'NUMBER' then
      l_format_type   := 'N';
      l_maximum_size  := 15;
    elsif p_valueset_type = 'CHARLOV' then
      l_format_type   := 'C';
      l_maximum_size  := 60;
    elsif p_valueset_type = 'NUMLOV' then
      l_format_type   := 'N';
      l_maximum_size  := 15;
    elsif p_valueset_type = 'DATE' then
      l_format_type   := 'D';
      l_maximum_size  := 20;
    else
      l_format_type   := 'C';
      l_maximum_size  := 60;
    end if;

    -- Create Character Value Set
    l_description  := 'This value set is generated by Enterprise Structures Configuration '
                      || 'This will initially be empty and can '
                      || 'be populated using the load reference data';

    l_valueset_name := p_valueset_name;
    l_value_set_exists := fnd_flex_val_api.valueset_exists(value_set => l_valueset_name);

    hr_utility.set_location(l_proc, 20);
    if not (l_value_set_exists) then
      hr_utility.set_location(l_proc, 20);
      fnd_flex_val_api.create_valueset_independent
                                       (value_set_name                 => p_valueset_name
                                       ,description                    => l_description
                                       ,security_available             => l_security_available
                                       ,enable_longlist                => l_enable_longlist
                                       ,format_type                    => l_format_type
                                       ,maximum_size                   => l_maximum_size
                                       ,precision                      => l_precision
                                       ,numbers_only                   => l_numbers_only
                                       ,uppercase_only                 => l_uppercase_only
                                       ,right_justify_zero_fill        => l_right_justify_zero_fill
                                       ,min_value                      => l_min_value
                                       ,max_value                      => l_max_value);
      l_log_message := 'Created VALUESET ' || p_valueset_name;
      per_ri_config_utilities.write_log(p_message => l_log_message);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 30);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  End create_valueset;

  /* --------------------------------------------------------------------------
  -- Name      : check_org_class_lookup_tag
  -- Purpose   : This function returns if org class lookup tag is enabled.
  -- Arguments : p_legislation_code
  --             p_lookup_code
  -------------------------------------------------------------------------- */

  FUNCTION check_org_class_lookup_tag(p_legislation_code  in varchar2
                                     ,p_lookup_code       in varchar2)
                        RETURN boolean IS
  cursor csr_org_class(cp_lookup_code            in varchar2) IS
    select tag
      from fnd_lookup_values
    where  lookup_type      = 'ORG_CLASS'
      and  lookup_code      = cp_lookup_code
      and  language         = hr_api.userenv_lang;

  l_tag       fnd_lookup_values.tag%type;
  l_enabled   boolean default false;
  l_plus_tag  varchar2(30);

  l_proc            varchar2(72) := g_package || 'check_org_class_lookup_tag';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_lookup_code = 'IN_COMPANY' then
      l_enabled := FALSE;
      return l_enabled;
    end if;

    open csr_org_class(p_lookup_code);
    fetch csr_org_class into l_tag;
    if l_tag is null then
       l_enabled := TRUE;
    end if;
    l_plus_tag   := '+' || p_legislation_code;

    if l_tag is NOT NULL and instr(l_tag,l_plus_tag)> 0 then
       hr_utility.set_location(l_proc, 30);
       l_enabled := TRUE;
    end if;
    close csr_org_class;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
    return l_enabled;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END check_org_class_lookup_tag;

  /* --------------------------------------------------------------------------
  -- Name      : get_selected_country_list
  -- Purpose   : This function returns name of selected country.
  -- Arguments : p_configuration_code
  --             p_config_info_category
  --             p_reg_var_name
  --             p_selected_list
  -------------------------------------------------------------------------- */

  PROCEDURE get_selected_country_list(p_configuration_code  varchar2
                                     ,p_config_info_category varchar2
                                     ,p_reg_var_name varchar2
                                     ,p_country_list out nocopy varchar2
                                     ,p_selected_list out nocopy varchar2) IS

  cursor get_country_list IS
    select distinct per_ri_config_utilities.business_group_decision(configuration_code, config_information1) BusinessGroup
      from per_ri_config_information pci
     where config_information_category = 'CONFIG COUNTRY'
       and configuration_code = p_configuration_code;

  cursor get_country_name(p_territory_code varchar2) IS
    select territory_short_name
      from fnd_territories_vl
     where territory_code = p_territory_code;

  cursor get_selected_list IS
    select distinct config_information2
      from per_ri_config_information pci
     where configuration_code = p_configuration_code
       and config_information_category = p_config_info_category
       and config_information1 <>  p_reg_var_name;

  l_ret_string         varchar2(10000);
  l_country_name       varchar2(100);
  l_business_group     varchar2(60);

  l_proc               varchar2(72) := g_package || 'get_selected_country_list';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    FOR i in get_country_list LOOP
      open get_country_name(i.businessgroup);
      fetch get_country_name into l_country_name;
      hr_utility.trace('l_country_name = ' ||  l_country_name);
      l_business_group := i.BusinessGroup;
      if get_country_name%NOTFOUND then
        l_business_group := 'INT';
        l_country_name := 'International';
      end if;
      close get_country_name;

      l_ret_string := l_ret_string || '^' || l_business_group ||'-' || l_country_name;
      hr_utility.trace('l_ret_string = ' ||  l_ret_string);
    END LOOP;

    p_country_list := ltrim(l_ret_string,',');
    hr_utility.trace('p_country_list = ' || p_country_list);
    FOR i in  get_selected_list LOOP
      p_selected_list := p_selected_list ||'^' || i.config_information2;
    END LOOP;

    p_selected_list := ltrim(p_selected_list,',');
  hr_utility.trace('p_selected_list = ' || p_selected_list);
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_selected_country_list;


  /* --------------------------------------------------------------------------
  -- Name      : get_display_country_list
  -- Purpose   : This function returns country list to be displayed.
  -- Arguments : p_configuration_code
  --             p_reg_var_name
  --             p_config_info_category
  -------------------------------------------------------------------------- */

  FUNCTION get_display_country_list(p_configuration_code varchar2
                                   ,p_reg_var_name varchar2
                                   ,p_config_info_category varchar2)
                         RETURN varchar2 IS
  cursor get_selected_country IS
    select distinct config_information2 business_group
    from per_ri_config_information pci
   where configuration_code = p_configuration_code
     and config_information_category = p_config_info_category
     and config_information1 = p_reg_var_name;

  cursor get_bg_display_name(p_territory_code varchar2) IS
    select territory_short_name
     from fnd_territories_vl
    where territory_code = p_territory_code;

  l_bg_name         varchar2(100);
  l_ret_string      varchar2(2000);
  l_proc            varchar2(72) := g_package || 'get_display_country_list';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    for i in get_selected_country loop
      open get_bg_display_name(i.business_group);
         fetch get_bg_display_name into l_bg_name;
         hr_utility.trace(i.business_group || '-' || l_bg_name);
         if (get_bg_display_name%notfound) then
             l_bg_name := 'International';
         end if;
         l_ret_string := l_ret_string || ',' || l_bg_name;
       close get_bg_display_name;
     end loop;
    hr_utility.trace('l_ret_string = ' || l_ret_string);
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
    return ltrim(l_ret_string,',');

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_display_country_list;

  /* --------------------------------------------------------------------------
  -- Name      : get_country_list
  -- Purpose   : This function returns country list.
  -- Arguments : p_configuration_code
  --             p_reg_var_name
  --             p_config_info_category
  -------------------------------------------------------------------------- */

  FUNCTION get_country_list(p_configuration_code varchar2
                           ,p_reg_var_name varchar2
                           ,p_config_info_category varchar2)
                       RETURN varchar2 IS

  cursor get_selected_list IS
    select config_information2 country
      from per_ri_config_information pci
     where configuration_code = p_configuration_code
       and config_information_category = p_config_info_category
       and config_information1 = p_reg_var_name;

  l_proc            varchar2(72) := g_package || 'jpg_define';
  l_ret_string varchar2(2000);
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    FOR i in get_selected_list LOOP
      l_ret_string := l_ret_string || ',' || i.country;
    end loop;
    hr_utility.trace('l_ret_string = ' || l_ret_string);
    hr_utility.set_location(' Leaving:'|| l_proc, 10);
    return ltrim(l_ret_string,',');
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_country_list;

  /* --------------------------------------------------------------------------
  -- Name      : freeze_and_compile_flexfield
  -- Purpose   : This function freeze and compile a given keyflex.
  -- Arguments : p_appl_short_Name
  --             p_flex_code
  --             p_structure_code
  -------------------------------------------------------------------------- */

  PROCEDURE freeze_and_compile_flexfield
                       (p_appl_short_Name           in varchar2
                       ,p_flex_code                 in varchar2
                       ,p_structure_code            in varchar2) IS

  cursor flex_num_cursor IS
   select fifs.id_flex_num
     from fnd_application fa, fnd_id_flex_structures_vl fifs
    where fa.application_short_name = p_appl_short_name
      and fa.application_id = fifs.application_id
      and fifs.id_flex_code = p_flex_code
      and fifs.id_flex_structure_code = p_structure_code;

  l_proc                    varchar2(72) := g_package || 'freeze_and_compile_flexfield';
  l_error_message           varchar2(360);
  l_log_message             varchar2(360);
  l_flexfield               fnd_flex_key_api.flexfield_type;
  l_structure               fnd_flex_key_api.structure_type;
  l_new_structure           fnd_flex_key_api.structure_type;
  l_id_flex_num             fnd_id_flex_structures_vl.id_flex_num%type;
  l_request_id              number(9);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open flex_num_cursor;
    fetch flex_num_cursor into l_id_flex_num;
    close flex_num_cursor;

    fnd_flex_key_api.set_session_mode('customer_data');

    l_flexfield := fnd_flex_key_api.find_flexfield
                               (appl_short_name         => p_appl_short_name
                               ,flex_code               => p_flex_code );

    hr_utility.set_location(l_proc, 20);

    l_structure := fnd_flex_key_api.find_structure
                                (flexfield              => l_flexfield
                                ,structure_code         => p_structure_code );

    hr_utility.set_location(l_proc, 30);

    --
    -- freeze flexfield
    --
    l_new_structure := l_structure;

    l_new_structure.freeze_flag := 'Y';

    hr_utility.set_location('Entering:'|| l_proc, 30);

    fnd_flex_key_api.modify_structure(l_flexfield, l_structure,l_new_structure);

    --
    -- compile flexfield
    --
    fnd_global.apps_initialize(user_id      =>  fnd_global.user_id,
                               resp_id      =>  fnd_global.resp_id,
                               resp_appl_id => fnd_global.resp_appl_id,
                               security_group_id => fnd_global.security_group_id);

    l_request_id := fnd_request.submit_request(
			              'FND',
 			              'FDFCMPK',
			              'Compile Key Flexfield',
    			              NULL, --start_time (varchar2)
    			              FALSE, --sub_request
                                      'K', --
    			              p_appl_short_name,
			              p_flex_code,
			              l_id_flex_num,
                                      chr(0), '', '', '', '', '',
			              '', '', '', '', '', '', '', '', '', '',
			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '',
    			              '', '', '', '', '', '', '', '', '', '');

    l_log_message := 'Submitted Concurrent Request to Compile KEY FLEX ' ||  p_appl_short_name
                            || ' ' || p_flex_code || ' ' || p_structure_code;
    per_ri_config_utilities.write_log(p_message => l_log_message);

    hr_utility.set_location(' Leaving:'|| l_proc, 50);

  EXCEPTION
    when others then
      null;
      -- Ignore for now  FOR TESTING
      --l_error_message := 'Error in ' || l_proc;
      --hr_utility.trace(l_error_message || '-' || sqlerrm);
      --hr_utility.set_location(' Leaving:'|| l_proc, 500);
      --hr_utility.raise_error;

  END freeze_and_compile_flexfield;


  /* --------------------------------------------------------------------------
  -- Name      : get_country_display_name
  -- Purpose   : This function returns country display name.
  -- Arguments : p_territory_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION get_country_display_name(p_territory_code          in varchar2)
                        RETURN varchar2 IS

  cursor csr_country(cp_territory_code in varchar2) IS
    select territory_short_name
      from fnd_territories_vl
     where territory_code = p_territory_code;

  l_territory_short_name        fnd_territories_vl.territory_short_name%type;
  l_proc                        varchar2(72) := g_package || 'get_country_display_name';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_territory_code = 'INT' then
        hr_utility.set_location(' Leaving:'|| l_proc, 30);
       return 'International';
    else
      open csr_country(p_territory_code);
      loop
        fetch csr_country into l_territory_short_name;
        exit when csr_country%NOTFOUND;
        hr_utility.set_location(' Leaving:'|| l_proc, 40);
      end loop;
      return l_territory_short_name;
    end if;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_country_display_name;


  /* --------------------------------------------------------------------------
  -- Name      : submit_int_payroll_request
  -- Purpose   : This procedure submit a concurrent request for running International
  --             Payroll process for a specified legislation when HRMs does not
  --             PER/PAY support.
  -- Arguments : errbuf
  --             retcode
  --             p_country_tab
  -------------------------------------------------------------------------- */

  PROCEDURE submit_int_payroll_request
                (errbuf                      out nocopy varchar2
                ,retcode                     out nocopy number
                ,p_country_tab               in  per_ri_config_datapump_entity.country_tab
                ,p_technical_summary_mode in boolean default FALSE
                ,p_int_hrms_setup_tab in out nocopy
                                             per_ri_config_tech_summary.int_hrms_setup_tab) IS

  l_proc                          varchar2(72) := g_package || 'submit_int_payroll_request';
  l_log_message                   varchar2(360);
  l_int_hrms_setup_count          number(8) := 0;
  l_int_hrms_setup_tab            per_ri_config_tech_summary.int_hrms_setup_tab;
  l_request_id                    number(9);
  l_legislation_code              varchar2(30);
  l_currency_code                 varchar2(30);
  l_tax_start_date                date;
  l_error_message                 varchar2(360);

  cursor csr_defaults (cp_legislation_code   in varchar2) IS
    select legislation_code,
           currency_code,
           tax_start_date
      from pay_leg_setup_defaults
    where  legislation_code = cp_legislation_code;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_country_tab.count > 0 THEN
      for i in p_country_tab.first ..
              p_country_tab.last LOOP
        l_legislation_code := p_country_tab(i).territory_code;
        hr_utility.trace('p_country_tab.element = ' || l_legislation_code);
        if l_legislation_code <>  'INT' then

          if NOT (per_ri_config_utilities.legislation_support(l_legislation_code, 'PAY'))
             and  NOT (per_ri_config_utilities.legislation_support(l_legislation_code, 'PER')) then

            open csr_defaults(l_legislation_code);

            fetch csr_defaults into l_legislation_code,l_currency_code,l_tax_start_date;
            --
            -- Submit 'International HRMS Setup' concurernt request
            --
            if NOT (p_technical_summary_mode) then
              l_request_id := fnd_request.submit_request
                                         (application => 'PAY'
                                         ,program     => 'PYINTSTU'
                                         ,description => 'Enterprise Structures Configuration'
                                         ,sub_request => FALSE
                                         ,argument1   => l_legislation_code
                                         ,argument2   => l_currency_code
                                         ,argument3   => to_char(l_tax_start_date,'RRRR/MM/DD')
                                         ,argument4   => 'N'
                                         ,argument5   => null);
             else
               p_int_hrms_setup_tab(l_int_hrms_setup_count).legislation_code    := l_legislation_code;
               p_int_hrms_setup_tab(l_int_hrms_setup_count).currency_code       := l_currency_code;
               p_int_hrms_setup_tab(l_int_hrms_setup_count).tax_start_date      := l_tax_start_date;
               p_int_hrms_setup_tab(l_int_hrms_setup_count).install_tax_unit    := 'N';

               l_int_hrms_setup_count := l_int_hrms_setup_count + 1 ;
            end if;
            close csr_defaults;
            l_log_message := 'Created International Payroll run CONCURRENT REQUEST for ' || l_legislation_code;
            per_ri_config_utilities.write_log(p_message => l_log_message);
          end if;
        end if;
      END LOOP;
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 40);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END submit_int_payroll_request;


  /* --------------------------------------------------------------------------
  -- Name      : create_security_profile_assign
  -- Purpose   : This procedure create security profile assignments.
  -- Arguments : p_security_profile_tab
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_security_profile_assign(
                      p_security_profile_tab       in per_ri_config_fnd_hr_entity.security_profile_tab) IS

  cursor csr_user IS
    select user_id
      from fnd_user
     where user_name  = upper(per_ri_config_utilities.return_config_entity_name_pre
                                           (per_ri_config_main.g_configuration_user_name));

  cursor csr_responsibility(cp_responsibility_kay in varchar2) IS
    select application_id, responsibility_id
      from fnd_responsibility
     where responsibility_key    = cp_responsibility_kay;

  cursor csr_business_group(cp_business_group_name in varchar2) IS
    select business_group_id,security_group_id
      from per_business_groups
     where name   = cp_business_group_name;

  cursor csr_security_profiles (cp_security_profile_name varchar2)IS
    select security_profile_id
      from per_security_profiles
     where security_profile_name = cp_security_profile_name;

  l_sec_profile_assignment_id    per_sec_profile_assignments.sec_profile_assignment_id%type;
  l_user_id                      per_sec_profile_assignments.user_id%type;
  l_security_group_id            per_sec_profile_assignments.security_group_id%type;
  l_business_group_id            per_sec_profile_assignments.business_group_id%type;
  l_security_profile_id          per_sec_profile_assignments.security_profile_id%type;
  l_responsibility_id            per_sec_profile_assignments.responsibility_id%type;
  l_responsibility_application_i per_sec_profile_assignments.responsibility_application_id%type;

  l_security_profile_name        per_business_groups.name%type;
  l_responsibility_key           fnd_responsibility_vl.responsibility_name%type;
  l_ovn                          number(9);
  l_proc                         varchar2(72) := g_package || 'create_security_profile_assign';
  l_log_message                  varchar2(360);
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

--  open csr_user;
--  fetch csr_user into l_user_id;
--  close csr_user;
--
--  if p_security_profile_tab.count > 0 then
--    for i in p_security_profile_tab.first ..
--             p_security_profile_tab.last LOOP
--      l_security_profile_name := p_security_profile_tab(i).security_profile_name;
--
--
--     l_responsibility_key := p_security_profile_tab(i).responsibility_key;
--
--        open csr_business_group(l_security_profile_name);
--        fetch csr_business_group into l_business_group_id,
--                                      l_security_group_id;
--        close csr_business_group;
--
--        open csr_security_profiles(l_security_profile_name);
--        fetch csr_security_profiles into l_security_profile_id;
--        close csr_security_profiles;
--
--        open csr_responsibility(l_responsibility_key);
--        fetch csr_responsibility into l_responsibility_application_i,l_responsibility_id;
--        close csr_responsibility;
--
--       hr_utility.trace('11 l_user_id = ' || l_user_id);
--       hr_utility.trace('11 l_business_group_id = ' || l_business_group_id);
--       hr_utility.trace('11 l_responsibility_id = ' || l_responsibility_id);
--       hr_utility.trace('11 p_responsibility_application_i = ' || l_responsibility_application_i);
--
--       per_sec_profile_asg_api.create_security_profile_asg
--                        (p_validate                     => false
--                        ,p_sec_profile_assignment_id    => l_sec_profile_assignment_id
--                        ,p_user_id                      => l_user_id
--                        ,p_security_group_id            => l_security_group_id
--                        ,p_business_group_id            => l_business_group_id
 --                       --,p_business_group_id          => null
--                        ,p_security_profile_id          => l_security_profile_id
--                        ,p_responsibility_id            => l_responsibility_id
--                        ,p_responsibility_application_i => l_responsibility_application_i
--                        ,p_start_date                   => g_config_effective_date
 --                       ,p_end_date                     => null
--                        ,p_object_version_number        => l_ovn);
--       hr_utility.trace('l_sec_profile_assignment_id = ' || l_sec_profile_assignment_id);
--       hr_utility.trace('l_user_id = ' || l_user_id);
--       hr_utility.trace('l_sec_profile_assignment_id = ' || l_sec_profile_assignment_id);
--       hr_utility.trace('l_business_group_id = ' || l_business_group_id);
--       hr_utility.trace('l_responsibility_id = ' || l_responsibility_id);
--       hr_utility.trace('p_responsibility_application_i = ' || l_responsibility_application_i);
--
--       l_log_message := 'Created Security Profile Assignment ' || l_business_group_id;
--       per_ri_config_utilities.write_log(p_message => l_log_message);
--
--      end loop;
--    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 100);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);


  END create_security_profile_assign;

  /* --------------------------------------------------------------------------
  -- Name      : update_configuration_status
  -- Purpose   : This procedure to update configuration status to 'LOADED' once
  --             LOader Program has loaded all the data without any issues.
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE update_configuration_status(p_configuration_code    in varchar2) IS

  l_proc                         varchar2(72) := g_package || 'update_configuration_status';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);

  l_configuration_code           per_ri_configurations_vl.configuration_code%type;
  l_configuration_type           per_ri_configurations_vl.configuration_type%type;
  l_configuration_status         per_ri_configurations_vl.configuration_status%type;
  l_configuration_name           per_ri_configurations_vl.configuration_name%type;
  l_configuration_description    per_ri_configurations_vl.configuration_description%type;
  l_object_version_number        per_ri_configurations_vl.object_version_number%type;

  cursor csr_configuration(cp_configuration_code   in varchar2) IS
    select configuration_code,
           configuration_type,
           configuration_status,
           configuration_name,
           configuration_description,
           object_version_number
    from per_ri_configurations_vl
    where configuration_code    = p_configuration_code;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_configuration(p_configuration_code);

    fetch csr_configuration into   l_configuration_code
                                  ,l_configuration_type
                                  ,l_configuration_status
                                  ,l_configuration_name
                                  ,l_configuration_description
                                  ,l_object_version_number;

    hr_utility.trace('l_object_version_number before =' || l_object_version_number);
    if csr_configuration%FOUND then
      hr_utility.set_location(' Leaving:'|| l_proc, 20);
      per_ri_configuration_api.update_configuration
                      (p_configuration_code            => l_configuration_code
                      ,p_configuration_type            => l_configuration_type
                      ,p_configuration_status          => 'LOADED'
                      ,p_configuration_name            => l_configuration_name
                      ,p_configuration_description     => l_configuration_description
                      ,p_language_code                 =>  hr_api.userenv_lang
                      ,p_effective_date                =>  null
                      ,p_object_version_number         => l_object_version_number);
      hr_utility.trace('l_object_version_number after =' || l_object_version_number);
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);

  END update_configuration_status;


  /* --------------------------------------------------------------------------
  -- Name      : determine_country_resp
  -- Purpose   : This function determines responsibility
  -- Arguments : l_country_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION determine_country_resp(p_country_code          in varchar2
                                ,p_assign_responsibility in varchar2)
                        RETURN varchar2 IS

  l_proc                          varchar2(72) := g_package || 'determine_country_resp';
  l_error_message                 varchar2(360);
  l_country_code                  per_ri_config_information.config_information1%type;
  l_responsibility_application    per_ri_config_responsibility.responsibility_application%type;
  l_assign_responsibility         varchar2(30);
  l_shrms                         boolean;
  l_hrms                          boolean;
  l_hr                            boolean;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_shrms := per_ri_config_utilities.responsibility_exists
                            (p_country_code              => p_country_code
                            ,p_assign_responsibility     => 'SHRMS');
    if l_shrms then
       return 'SHRMS';
    end if;

    l_hrms := per_ri_config_utilities.responsibility_exists
                            (p_country_code              => p_country_code
                            ,p_assign_responsibility     => 'HRMS');
    if l_hrms then
       return 'HRMS';
    end if;

    l_hr := per_ri_config_utilities.responsibility_exists
                              (p_country_code              => p_country_code
                              ,p_assign_responsibility     => 'PER');
    if l_hr then
       return 'PER';
    end if;

    return 'PER'; -- return PER is can not make a decision
    hr_utility.set_location(' Leaving:'|| l_proc, 30);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END determine_country_resp;

  /* --------------------------------------------------------------------------
  -- Name      : get_enterprise_short_name
  -- Purpose   : This function returns if responsibility can be assiged of enterpise short name
  --             for a given configuration
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  FUNCTION responsibility_exists(p_country_code          in varchar2
                                ,p_assign_responsibility in varchar2)
                        RETURN boolean IS

  cursor csr_responsibility
                  (cp_country_code            in varchar2
                  ,cp_assign_responsibility   in varchar2) IS
    select responsibility_application
      from per_ri_config_responsibility
     where territory_code  = cp_country_code
       and responsibility_application = cp_assign_responsibility;

  l_proc                          varchar2(72) := g_package || 'responsibility_exists';
  l_error_message                 varchar2(360);
  l_country_code                  per_ri_config_information.config_information1%type;
  l_responsibility_application    per_ri_config_responsibility.responsibility_application%type;
  l_assign_responsibility         varchar2(30);
  l_resp_exists                   boolean default FALSE;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_responsibility(p_country_code
                           ,p_assign_responsibility);
    fetch csr_responsibility into l_responsibility_application;
    if csr_responsibility%FOUND then
      l_resp_exists :=  TRUE;
      hr_utility.trace('Responsibility exists' || p_country_code );
      hr_utility.trace('Responsibility exists' || p_assign_responsibility );
    else
      l_resp_exists :=  FALSE;
      hr_utility.trace('Responsibility exists' || p_country_code );
      hr_utility.trace('Responsibility does not exists' || p_assign_responsibility );
    end if;
    close csr_responsibility;
    return l_resp_exists;

    hr_utility.set_location(' Leaving:'|| l_proc, 30);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END;


  /* --------------------------------------------------------------------------
  -- Name      : submit_enable_msg_process
  -- Purpose   : This procedure submit a concurrent request for running
  --             Enable Multiple Security Group process
  -- Arguments : errbuf
  --             retcode
  -------------------------------------------------------------------------- */

  PROCEDURE submit_enable_mult_sg_process
                (errbuf                      out nocopy varchar2
                ,retcode                     out nocopy number) IS

  l_proc                          varchar2(72) := g_package || 'submit_enable_mult_sg_process';
  l_log_message                   varchar2(360);
  l_request_id                    number(9);
  l_error_message                 varchar2(360);

  l_legislation_code              varchar2(30);
  l_currency_code                 varchar2(30);
  l_tax_start_date                date;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    -- Remove site level profile option
    --PER_SECURITY_PROFILE_ID
    per_ri_config_utilities.set_profile_option_value
                         (p_level                => 10001
                         ,p_level_value          => 0
                         ,p_level_value_app      => 'PER'
                         ,p_profile_name         => 'PER_SECURITY_PROFILE_ID'
                         ,p_profile_option_value => NULL);


    --Commented for Multiple Security Group Removal Changes
    -- /* DGARG
    -- Submit 'submit_enable_msg_process' concurernt request
    --
    --l_request_id := fnd_request.submit_request
                               --(application => 'PER'
                               --,program     => 'HRSECGRP'
                               --,description => 'Enterprise Structures Configuration'
                               --,sub_request => FALSE);
    --hr_utility.trace('l_request_id = ' || to_char(l_request_id));
    --l_log_message := 'Created Enable Multiple Security Group process';
    --l_log_message := 'Created Enable Multiple Security Group process';
    --per_ri_config_utilities.write_log(p_message => l_log_message);

    --
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END submit_enable_mult_sg_process;

  /* --------------------------------------------------------------------------
  -- Name      : check_fresh_installation
  -- Purpose   : This function checks if this database is having some data which
  --             can interfere with loader program.
  -------------------------------------------------------------------------- */

  FUNCTION check_fresh_installation
                             RETURN boolean IS
  cursor csr_bg_data IS
    select name
    from per_business_groups
    where name     <> 'Setup Business Group';

  l_proc                          varchar2(72) := g_package || 'check_fresh_installation';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_name                          per_business_groups.name%type;
  l_fresh_installed               boolean default FALSE;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_bg_data;
    fetch csr_bg_data into l_name;
    if csr_bg_data%FOUND then
       l_fresh_installed := FALSE;
       hr_utility.trace('l_fresh_installed = ' || 'FALSE');
    else
       l_fresh_installed := TRUE;
       hr_utility.trace('l_fresh_installed = ' || 'TRUE');
    end if;

    return l_fresh_installed;

    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END check_fresh_installation;


  /* --------------------------------------------------------------------------
  -- Name      : write_data_pump_exception_log
  -- Purpose   : This procedure write exceptions from datapump if datapump batch
  --             is not able to load successfully.
  -- Arguments : p_patch_header_id
  -------------------------------------------------------------------------- */

  PROCEDURE write_data_pump_exception_log
                (p_patch_header_id           in number) IS

  l_proc                          varchar2(72) := g_package || 'write_data_pump_exception_log';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  l_exception_text                hr_pump_batch_exceptions.exception_text%type;

  cursor csr_dp_exception(cp_patch_header_id           in number) IS
    select exception_text
    from hr_pump_batch_exceptions
    where source_id   in ( select batch_line_id
                             from  hr_pump_batch_lines
                           where batch_id = cp_patch_header_id);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_dp_exception(p_patch_header_id);
    fetch csr_dp_exception into l_exception_text;
    if csr_dp_exception%FOUND then
      l_log_message := 'Error occured in loading datapump records';
      per_ri_config_utilities.write_log(p_message => l_log_message);

      l_log_message := l_exception_text;
      per_ri_config_utilities.write_log(p_message => l_log_message);
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END write_data_pump_exception_log;

  /* --------------------------------------------------------------------------
  -- Name      : check_data_pump_exception
  -- Purpose   : This procedure check if datapump load has any exception
  --             while processing a batch
  -- Arguments : p_patch_header_id
  -------------------------------------------------------------------------- */

  FUNCTION check_data_pump_exception(p_patch_header_id    in number)
                return boolean IS

  l_proc                          varchar2(72) := g_package || 'check_data_pump_exception';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);
  l_exception                     boolean default FALSE;
  l_exception_text                hr_pump_batch_exceptions.exception_text%type;

  cursor csr_dp_exception(cp_patch_header_id           in number) IS
    select exception_text
    from hr_pump_batch_exceptions
    where source_id   in ( select batch_line_id
                             from  hr_pump_batch_lines
                           where batch_id = cp_patch_header_id);
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_dp_exception(p_patch_header_id);
    fetch csr_dp_exception into l_exception_text;
    if csr_dp_exception%FOUND then
      l_exception  := TRUE;
    else
      l_exception := FALSE;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
    return l_exception;
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END check_data_pump_exception;

  /* --------------------------------------------------------------------------
  -- Name      : assign_misc_responsibility
  -- Purpose   : This procedure assign misc responsibilities to user.
  --             while processing a batch
  -- Arguments : p_configuration_code
  -------------------------------------------------------------------------- */

  PROCEDURE assign_misc_responsibility
                (p_configuration_code           in varchar2
                ,p_technical_summary_mode in boolean default FALSE
                ,p_hrms_misc_resp_tab in out nocopy per_ri_config_tech_summary.hrms_misc_resp_tab) IS

  l_proc                          varchar2(72) := g_package || 'assign_misc_responsibility';
  l_log_message                   varchar2(360);
  l_error_message                 varchar2(360);

  l_hrms_misc_resp_count          number(9) := 0;
  l_enterprise_primary_industry  per_ri_config_information.config_information1%type;
  l_start_date                   varchar2(240) := to_char(per_ri_config_utilities.g_config_effective_date,'YYYY/MM/DD');
  l_end_date                     varchar2(240) := to_char(per_ri_config_utilities.g_config_effective_end_date,'YYYY/MM/DD');

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    if NOT (p_technical_summary_mode) then
      fnd_user_resp_groups_api.load_row(
                    x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                           (per_ri_config_main.g_configuration_user_name)),
                    x_resp_key        => 'GLB_SHRMS_MANAGER',
                    x_app_short_name  => 'PER',
                    x_security_group  => 'STANDARD',
                    x_owner           => 'SEED',
                    x_start_date      =>  l_start_date,
                    x_end_date        =>  l_end_date,
                    x_description     => per_ri_config_main.g_description_string);
      else
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).user_name      :=  upper(per_ri_config_utilities.return_config_entity_name_pre
                                                                          (per_ri_config_main.g_configuration_user_name));
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).resp_key  := 'GLB_SHRMS_MANAGER';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).app_short_name := 'PER';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).security_group := 'STANDARD';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).owner          := 'SEED';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).start_date     := l_start_date;
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).end_date       := l_end_date;
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).description    := per_ri_config_main.g_description_string;

          l_hrms_misc_resp_count := l_hrms_misc_resp_count + 1 ;
      end if;
    hr_utility.trace('Assigned Responsibility: ' || 'GLB_SHRMS_MANAGER');
    hr_utility.set_location(l_proc, 20);

    l_enterprise_primary_industry := per_ri_config_utilities.get_ent_primary_industry
                                                  (p_configuration_code => p_configuration_code);

    if l_enterprise_primary_industry = 'US_GOVERNMENT' then
      if NOT (p_technical_summary_mode) then
        fnd_user_resp_groups_api.load_row(
                      x_user_name       => upper(per_ri_config_utilities.return_config_entity_name_pre
                                             (per_ri_config_main.g_configuration_user_name)),
                      x_resp_key        => 'US_GOV_HR_MANAGER',
                      x_app_short_name  => 'GHR',
                      x_security_group  => 'STANDARD',
                      x_owner           => 'SEED',
                      x_start_date      =>  l_start_date,
                      x_end_date        =>  l_end_date,
                      x_description     => per_ri_config_main.g_description_string);
      else
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).user_name      :=   upper(per_ri_config_utilities.return_config_entity_name_pre
                                                                              (per_ri_config_main.g_configuration_user_name));
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).resp_key  := 'US_GOV_HR_MANAGER';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).app_short_name := 'GHR';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).security_group := 'STANDARD';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).owner          := 'SEED';
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).start_date     := l_start_date;
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).end_date       := l_end_date;
          p_hrms_misc_resp_tab(l_hrms_misc_resp_count).description    := per_ri_config_main.g_description_string;

          l_hrms_misc_resp_count := l_hrms_misc_resp_count + 1 ;
      end if;
      hr_utility.trace('Assigned Responsibility: ' || 'US_GOV_HR_MANAGER');
      hr_utility.set_location(l_proc, 20);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 100);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END assign_misc_responsibility;

  /* --------------------------------------------------------------------------
  -- Name      : return_config_entity_name
  -- Purpose   : This function returns name of entity depanding upon
  --             if multiple configuration upload is enabled.
  -- Arguments : entity_name
  --
  -------------------------------------------------------------------------- */

  FUNCTION return_config_entity_name(entity_name       in varchar2)
                        RETURN varchar2 IS


  l_entity_name                  per_ri_config_information.config_information1%type;
  l_multiple_config_upload       varchar2(20);

  l_proc          varchar2(72) := g_package || 'return_config_entity_name';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('per_ri_config_utilities.g_enterprise_short_name = ' || per_ri_config_utilities.g_enterprise_short_name );
    l_multiple_config_upload := fnd_profile.value('PER_RI_LOAD_OVERRIDE');

    if l_multiple_config_upload = 'Y' then
        l_entity_name := entity_name || ' ' || per_ri_config_utilities.g_enterprise_short_name;
    else
      l_entity_name := entity_name;
    end if;

    --hr_utility.set_location(' Leaving:'|| l_proc, 30);

    return l_entity_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END return_config_entity_name;


  /* --------------------------------------------------------------------------
  -- Name      : return_config_entity_name_pre
  -- Purpose   : This function returns name (prefixed) of entity depanding upon
  --             if multiple configuration upload is enabled.
  -- Arguments : entity_name
  --
  -------------------------------------------------------------------------- */

  FUNCTION return_config_entity_name_pre(entity_name       in varchar2)
                        RETURN varchar2 IS


  l_entity_name                  per_ri_config_information.config_information1%type;
  l_multiple_config_upload       varchar2(20);

  l_proc          varchar2(72) := g_package || 'return_config_entity_name_pre';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('per_ri_config_utilities.g_enterprise_short_name = ' || per_ri_config_utilities.g_enterprise_short_name );

    l_multiple_config_upload := fnd_profile.value('PER_RI_LOAD_OVERRIDE');

    if l_multiple_config_upload = 'Y' then
        l_entity_name := per_ri_config_utilities.g_enterprise_short_name || ' ' || entity_name;
    else
      l_entity_name := entity_name;
    end if;

    --hr_utility.set_location(' Leaving:'|| l_proc, 30);

    return l_entity_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END return_config_entity_name_pre;

  FUNCTION get_location_prompt(p_style       in varchar2
                              ,p_app_column_name  in varchar2)
                        RETURN varchar2 IS

  l_user_column_name             varchar2(200);
  l_proc                         varchar2(72) := g_package || 'get_location_prompt';

  cursor csr_get_prm(cp_style          in varchar2
                     ,cp_app_col_name in varchar2) IS
    select form_left_prompt
    from fnd_descr_flex_col_usage_vl
    where descriptive_flexfield_name= 'Address Location'
    and   descriptive_flex_context_code = cp_style
    and   application_column_name       = cp_app_col_name;

  BEGIN
    hr_utility.set_location(' Entering :'|| l_proc, 30);
    hr_utility.set_location(' Style :'|| p_style,40);

    open csr_get_prm(p_style,p_app_column_name);

    fetch csr_get_prm into l_user_column_name;
    if(csr_get_prm%FOUND) then
      --hr_utility.set_location(' Leaving :'|| l_proc, 50);
      close csr_get_prm;
      return l_user_column_name;
    else
      --hr_utility.set_location(' Leaving :'|| l_proc, 50);
      close csr_get_prm;
      return null;
    end if;


  END get_location_prompt;


  /* --------------------------------------------------------------------------
  -- Name      : create_valueset_ts_data
  -- Purpose   : This procedure creates a value set data for technical summary
  -- Arguments : p_valueset_name
  --             p_valueset_type
                 p_fed_seg_attribute
                 p_valueset_tab
  -------------------------------------------------------------------------- */

  PROCEDURE create_valueset_ts_data(p_valueset_name   in varchar2
                           ,p_valueset_type           in varchar2
                           ,p_structure_code          in varchar2
                           ,p_segment_name            in varchar2
                           ,p_segment_number          in varchar2
                           ,p_fed_seg_attribute       in varchar2 default 'N'
                           ,p_valueset_tab            in out nocopy
                                                        per_ri_config_tech_summary.valueset_tab) IS

  l_proc                         varchar2(72) := g_package || 'create_valueset_ts_data';
  l_error_message                varchar2(360);
  l_log_message                  varchar2(360);

  l_security_available           varchar2(1)    default 'N';
  l_enable_longlist              varchar2(1)    default 'Y';
  l_format_type                  varchar2(1)    default 'C';
  l_maximum_size                 number(9)      default 60;
  l_precision                    number(2)      default null;
  l_numbers_only                 varchar2(1)    default 'N';
  l_uppercase_only               varchar2(1)    default 'N';
  l_right_justify_zero_fill      varchar2(1)    default 'N';
  l_min_value                    varchar2(150)  default null;
  l_max_value                    varchar2(150)  default null;
  l_description                  varchar2(240);
  l_value_set_exists             boolean;

  l_value_set_count              number(9) := 1 ;
  l_valueset_seq                 number(9);
  l_valueset_name                fnd_flex_value_sets.flex_value_set_name%type;

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    if p_fed_seg_attribute = 'N' then
      --
      -- create flex segment value set
      --
      --select per_ri_config_vsets_number_s.nextval into l_valueset_seq from sys.dual;
      l_valueset_seq   := p_segment_number;

      l_valueset_name  :=  p_structure_code || ' ' || p_segment_name
                                             || ' ' || l_valueset_seq;

      hr_utility.trace('l_valueset_name = ' || l_valueset_name);
    end if;

    -- valueset name is always passed when p_fed_seg_attribute = 'Y'
    if p_fed_seg_attribute = 'Y' then
      l_valueset_name := p_valueset_name;
    end if;

    if p_valueset_type = 'CHAR' then
      l_format_type   := 'C';
      l_maximum_size  := 60;
    elsif  p_valueset_type = 'NUMBER' then
      l_format_type   := 'N';
      l_maximum_size  := 15;
    elsif p_valueset_type = 'CHARLOV' then
      l_format_type   := 'C';
      l_maximum_size  := 60;
    elsif p_valueset_type = 'NUMLOV' then
      l_format_type   := 'N';
      l_maximum_size  := 15;
    elsif p_valueset_type = 'DATE' then
      l_format_type   := 'D';
      l_maximum_size  := 20;
    else
      l_format_type   := 'C';
      l_maximum_size  := 60;
    end if;

    -- Create Character Value Set
    l_description  := 'This value set is generated by Enterprise Structures Configuration '
                      || 'This will initially be empty and can '
                      || 'be populated using the load reference data';

    hr_utility.set_location(l_proc, 20);
    p_valueset_tab(l_value_set_count).value_set_name          := l_valueset_name;
    p_valueset_tab(l_value_set_count).description             := l_description;
    p_valueset_tab(l_value_set_count).security_available      := l_security_available;
    p_valueset_tab(l_value_set_count).enable_longlist         := l_enable_longlist;
    p_valueset_tab(l_value_set_count).format_type             := l_format_type;
    p_valueset_tab(l_value_set_count).maximum_size            := l_maximum_size;
    p_valueset_tab(l_value_set_count).precision               := l_precision;
    p_valueset_tab(l_value_set_count).numbers_only            := l_numbers_only;
    p_valueset_tab(l_value_set_count).uppercase_only          := l_uppercase_only;
    p_valueset_tab(l_value_set_count).right_justify_zero_fill := l_right_justify_zero_fill;
    p_valueset_tab(l_value_set_count).min_value               := l_min_value;
    p_valueset_tab(l_value_set_count).max_value               := l_max_value;

    l_value_set_count  := l_value_set_count + 1;

    l_log_message := 'Created VALUESET ' || p_valueset_name;

    hr_utility.set_location(' Leaving:'|| l_proc, 30);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  End create_valueset_ts_data;

  /* --------------------------------------------------------------------------
  -- Name      : create_more_hrms_resps
  -- Purpose   : This procedure create security profile assignments.
  -- Arguments : create_sg_assignments
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_more_hrms_resps
                     (p_configuration_code       in varchar2
                     ,p_security_profile_tab     in per_ri_config_fnd_hr_entity.security_profile_tab
                     ,p_int_bg_resp_tab          in per_ri_config_fnd_hr_entity.int_bg_resp_tab
                     ,p_technical_summary_mode   in boolean default FALSE
                     ,p_hrms_resp_main_tab
                                                 in out nocopy per_ri_config_tech_summary.hrms_resp_tab
                     ,p_more_profile_resp_tab
                                              in out nocopy per_ri_config_tech_summary.profile_resp_tab
                     ,p_more_int_profile_resp_tab
                                              in out nocopy per_ri_config_tech_summary.profile_resp_tab) IS

  l_security_profile_name        per_business_groups.name%type;
  l_responsibility_key           fnd_responsibility_vl.responsibility_name%type;
  l_ovn                          number(9);
  l_hrms_resp_profile_resp_tab   per_ri_config_tech_summary.profile_resp_tab;
  l_int_resp_profile_resp_tab    per_ri_config_tech_summary.profile_resp_tab;
  l_proc                         varchar2(72) := g_package || 'create_more_hrms_resps';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);
  l_main_bgsgut_profile_resp_tab per_ri_config_tech_summary.profile_resp_tab;
  l_int_bgsgut_profile_resp_tab  per_ri_config_tech_summary.profile_resp_tab;

  l_main_bgsgut_profile_resp_ct      number(8) := 0;
  l_int_bgsgut_profile_resp_ct       number(8) := 0;
  l_profile_resp_temp_count          number(9) := 1;
  l_more_profile_resp_tab_count      number(9) := 0;
  l_hrms_resp_main_count             number(9) := 0;

  l_hrms_resp_one_tab              per_ri_config_tech_summary.hrms_resp_tab;

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    l_main_bgsgut_profile_resp_ct := 0;
    if p_security_profile_tab.count > 0 then
      for i in p_security_profile_tab.first ..
               p_security_profile_tab.last LOOP

          l_security_profile_name := p_security_profile_tab(i).security_profile_name;
          l_responsibility_key := p_security_profile_tab(i).responsibility_key;

          hr_utility.trace('l_security_profile_name := ' || l_security_profile_name);
          hr_utility.trace('l_responsibility_key := ' || l_responsibility_key);
          hr_utility.trace('before loop l_more_profile_resp_tab_count ' || l_more_profile_resp_tab_count );
          per_ri_config_utilities.create_resp_and_profile
                     (p_configuration_code        => p_configuration_code
                     ,p_security_profile_name     => l_security_profile_name
                     ,p_responsibility_key        => l_responsibility_key
                     ,p_technical_summary_mode    => p_technical_summary_mode
                     ,p_bg_sg_ut_profile_resp_tab => l_main_bgsgut_profile_resp_tab
                     ,p_hrms_resp_one_tab         => l_hrms_resp_one_tab);

          -- Populate data for ts resp tables
          if l_hrms_resp_one_tab.count > 0 THEN
            for l in l_hrms_resp_one_tab.first ..
              l_hrms_resp_one_tab.last loop

              --new date for responsibility population
              p_hrms_resp_main_tab(l_hrms_resp_main_count).user_name      := l_hrms_resp_one_tab(l).user_name;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).resp_key       := l_hrms_resp_one_tab(l).resp_key;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).app_short_name := l_hrms_resp_one_tab(l).app_short_name;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).security_group := l_hrms_resp_one_tab(l).security_group;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).owner          := l_hrms_resp_one_tab(l).owner;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).start_date     := l_hrms_resp_one_tab(l).start_date;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).end_date       := l_hrms_resp_one_tab(l).end_date;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).description    := l_hrms_resp_one_tab(l).description;

              l_hrms_resp_main_count := 1 + l_hrms_resp_main_count;
            end loop;
          end if;

          if l_main_bgsgut_profile_resp_tab.count > 0 THEN
            for j in l_main_bgsgut_profile_resp_tab.first ..
              l_main_bgsgut_profile_resp_tab.last loop

              hr_utility.trace('l_more_profile_resp_tab_count ' || l_more_profile_resp_tab_count );

              if l_main_bgsgut_profile_resp_tab(j).profile_name = 'PER_BUSINESS_GROUP_ID' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_main_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_main_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_main_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_main_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_main_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;
              if l_main_bgsgut_profile_resp_tab(j).profile_name = 'PER_SECURITY_PROFILE_ID' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_main_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_main_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_main_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_main_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_main_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;

              if l_main_bgsgut_profile_resp_tab(j).profile_name = 'HR_USER_TYPE' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_main_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_main_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_main_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_main_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_main_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;
            end loop;
          end if;
      end loop;
    end if;

    -- Process International BGs responsibilities
    hr_utility.set_location(l_proc, 20);
    l_int_bgsgut_profile_resp_ct := 0;
    if p_int_bg_resp_tab.count > 0 then
      for i in p_int_bg_resp_tab.first ..
               p_int_bg_resp_tab.last LOOP

          l_security_profile_name := p_int_bg_resp_tab(i).security_profile_name;
          -- l_responsibility_key is null at this point
          l_responsibility_key := p_int_bg_resp_tab(i).responsibility_key;


          hr_utility.trace('l_security_profile_name ' || l_security_profile_name);

          if l_security_profile_name like '%INT BG' then

            -- all International BG's to get copy of GLB_SHRMS_MANAGER responsibility
            l_responsibility_key := 'GLB_SHRMS_MANAGER';

            per_ri_config_utilities.create_resp_and_profile
                     (p_configuration_code        => p_configuration_code
                     ,p_security_profile_name     => l_security_profile_name
                     ,p_responsibility_key        => l_responsibility_key
                     ,p_technical_summary_mode    => p_technical_summary_mode
                     ,p_bg_sg_ut_profile_resp_tab => l_int_bgsgut_profile_resp_tab
                     ,p_hrms_resp_one_tab         => l_hrms_resp_one_tab);

          -- Populate data for ts resp tables
          if l_hrms_resp_one_tab.count > 0 THEN
            for k in l_hrms_resp_one_tab.first ..
              l_hrms_resp_one_tab.last loop

              --new date for responsibility population
              p_hrms_resp_main_tab(l_hrms_resp_main_count).user_name      := l_hrms_resp_one_tab(k).user_name;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).resp_key       := l_hrms_resp_one_tab(k).resp_key;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).app_short_name := l_hrms_resp_one_tab(k).app_short_name;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).security_group := l_hrms_resp_one_tab(k).security_group;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).owner          := l_hrms_resp_one_tab(k).owner;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).start_date     := l_hrms_resp_one_tab(k).start_date;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).end_date       := l_hrms_resp_one_tab(k).end_date;
              p_hrms_resp_main_tab(l_hrms_resp_main_count).description    := l_hrms_resp_one_tab(k).description;

              l_hrms_resp_main_count := 1 + l_hrms_resp_main_count;
            end loop;
          end if;

          if l_int_bgsgut_profile_resp_tab.count > 0 THEN
            for j in l_int_bgsgut_profile_resp_tab.first ..
              l_int_bgsgut_profile_resp_tab.last loop


              if l_int_bgsgut_profile_resp_tab(j).profile_name = 'PER_BUSINESS_GROUP_ID' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_int_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_int_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_int_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_int_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_int_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;

              if l_int_bgsgut_profile_resp_tab(j).profile_name = 'PER_SECURITY_PROFILE_ID' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_int_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_int_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_int_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_int_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_int_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;

              if l_int_bgsgut_profile_resp_tab(j).profile_name = 'HR_USER_TYPE' then
                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level
                                := l_int_bgsgut_profile_resp_tab(j).level;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value
                        := l_int_bgsgut_profile_resp_tab(j).level_value;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).level_value_app
                        := l_int_bgsgut_profile_resp_tab(j).level_value_app;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_name
                        := l_int_bgsgut_profile_resp_tab(j).profile_name;

                p_more_profile_resp_tab(l_more_profile_resp_tab_count).profile_option_value
                        := l_int_bgsgut_profile_resp_tab(j).profile_option_value;

                l_more_profile_resp_tab_count := 1 + l_more_profile_resp_tab_count;
              end if;

            end loop;
          end if;
        end if;
      end loop;
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 100);
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);


  END create_more_hrms_resps;



  /* --------------------------------------------------------------------------
  -- Name      : create_responsibility
  -- Purpose   : This procedure creates responsibility
  -- Arguments : p_configuration_code
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_responsibility
             (p_app_short_name            in fnd_application.application_short_name%type
             ,p_resp_key                  in fnd_responsibility_vl.responsibility_name%type
             ,p_responsibility_id       in fnd_responsibility.responsibility_id%type
             ,p_responsibility_name       in fnd_responsibility_tl.responsibility_name%type
             ,p_owner                     in varchar2
             ,p_data_group_app_short_name in fnd_application.application_short_name%type
             ,p_data_group_name           in fnd_data_groups_standard_view.data_group_name%type
             ,p_menu_name                 in fnd_menus.menu_name%type
             ,p_start_date                in varchar2
             ,p_end_date                  in varchar2
             ,p_description               in varchar2
             ,p_group_app_short_name      in fnd_application.application_short_name%type
             ,p_request_group_name        in fnd_request_groups.request_group_name%type
             ,p_version                   in varchar2
             ,p_web_host_name             in fnd_responsibility.web_host_name%type
             ,p_web_agent_name            in fnd_responsibility.web_agent_name%type) IS

  l_proc                          varchar2(72) := g_package || 'create_responsibility';
  l_error_message                 varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace('x_responsibility_name := ' || p_responsibility_name);
    hr_utility.trace('x_resp_key := ' || p_resp_key);

    -- create responsibility only when if specified resposibility does not exists
    -- this case would happen when loader program is running into non-multiple configuration
    -- load mode.
    if NOT (fnd_function_security.responsibility_exists(responsibility_key => p_resp_key)) then
      fnd_responsibility_pkg.load_row
             (x_app_short_name		  => p_app_short_name
             ,x_resp_key                  => p_resp_key
             ,x_responsibility_id         => null
             ,x_responsibility_name       => p_responsibility_name
             ,x_owner                     => 'CUSTOM'
             ,x_data_group_app_short_name => p_data_group_app_short_name
             ,x_data_group_name           => p_data_group_name
             ,x_menu_name                 => p_menu_name
             ,x_start_date                => p_start_date
             ,x_end_date                  => null
             ,x_description               => p_description
             ,x_group_app_short_name      => p_group_app_short_name
             ,x_request_group_name        => p_request_group_name
             ,x_version                   => p_version
             ,x_web_host_name             => p_web_host_name
             ,x_web_agent_name            => p_web_agent_name);
    end if;

    hr_utility.set_location(' Leaving:'|| l_proc, 100);

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END create_responsibility;

  /* --------------------------------------------------------------------------
  -- Name      : create_resp_and_profile
  -- Purpose   : This procedure create responsibility after making copy of the
  --             seeded responsibility, assign responsibility to user,
  --             assign PER_BUSINESS_GROUP_ID,PER_SECURITY_PROLFILE_ID
  --             profile option values.
  -- Arguments : p_configuration_code
  --             p_security_profile_name
  --             p_responsibility_key
  --             p_technical_summary_mode
  --             p_bg_sg_ut_profile_resp_tab
  --             p_hrms_resp_one_tab
  --
  -------------------------------------------------------------------------- */

  PROCEDURE create_resp_and_profile
                     (p_configuration_code        in varchar2
                     ,p_security_profile_name     in varchar2
                     ,p_responsibility_key        in varchar2
                     ,p_technical_summary_mode    in boolean default FALSE
                     ,p_bg_sg_ut_profile_resp_tab in out nocopy
                                                       per_ri_config_tech_summary.profile_resp_tab
                     ,p_hrms_resp_one_tab in out nocopy
                                                       per_ri_config_tech_summary.hrms_resp_tab) IS

  cursor csr_user IS
    select user_name
      from fnd_user
     where user_name  = upper(per_ri_config_utilities.return_config_entity_name_pre
                                           (per_ri_config_main.g_configuration_user_name));

  cursor csr_responsibility(cp_responsibility_kay in varchar2) IS
    select application_id, responsibility_id
      from fnd_responsibility
     where responsibility_key    = cp_responsibility_kay;

  cursor csr_responsibility_name(cp_responsibility_kay in varchar2) IS
    select responsibility_name
      from fnd_responsibility_vl
     where responsibility_key    = cp_responsibility_kay;

  cursor csr_application(cp_application_id  in number) IS
    select application_short_name
      from fnd_application
     where application_id    = cp_application_id;

  cursor csr_business_group(cp_business_group_name in varchar2) IS
    select security_group_id
      from per_business_groups
     where name   = cp_business_group_name;

  cursor csr_security_profiles (cp_security_profile_name varchar2)IS
    select security_profile_id
      from per_security_profiles
     where security_profile_name = cp_security_profile_name;

  cursor csr_security_group_name(cp_security_group_id  in number) IS
    select security_group_name,security_group_key
      from fnd_security_groups_vl
     where security_group_id    = cp_security_group_id;

  l_user_name                    fnd_user.user_name%type;
  l_security_group_id            fnd_security_groups.security_group_id%type;
  l_business_group_id            per_business_groups.business_group_id%type;
  l_business_group_name          per_business_groups.name%type;
  l_security_profile_id          per_sec_profile_assignments.security_profile_id%type;
  l_responsibility_id            per_sec_profile_assignments.responsibility_id%type;
  l_responsibility_application_i per_sec_profile_assignments.responsibility_application_id%type;

  l_security_group_name          fnd_security_groups_vl.security_group_name%type;
  l_security_group_key           fnd_security_groups_vl.security_group_key%type;
  l_application_short_name       fnd_application.application_short_name%type;

  l_security_profile_name        per_business_groups.name%type;
  l_responsibility_key           fnd_responsibility_vl.responsibility_name%type;
  l_ts_responsibility_key        fnd_responsibility_vl.responsibility_name%type;
  l_ts_new_responsibility_name   fnd_responsibility_vl.responsibility_name%type;
  l_ts_responsibility_name       fnd_responsibility_vl.responsibility_name%type;
  l_ts_new_resp_key              fnd_responsibility_vl.responsibility_name%type;
  l_ovn                          number(9);

  l_proc                         varchar2(72) := g_package || 'create_resp_and_profile';
  l_log_message                  varchar2(360);
  l_error_message                varchar2(360);

  l_bg_sg_ut_profile_resp_tab    per_ri_config_tech_summary.profile_resp_tab;
  l_new_app_short_name           fnd_application.application_short_name%type;
  l_new_resp_key                 fnd_responsibility_vl.responsibility_name%type;
  l_new_responsibility_id        fnd_responsibility.responsibility_id%type;
  l_new_responsibility_name      fnd_responsibility_tl.responsibility_name%type;
  l_new_owner                    varchar2(120);
  l_new_data_group_app_name      fnd_application.application_short_name%type;
  l_new_data_group_name          fnd_data_groups_standard_view.data_group_name%type;
  l_new_data_group_id            fnd_data_groups_standard_view.data_group_name%type;
  l_new_menu_name                fnd_menus.menu_name%type;
  l_new_start_date               varchar2(240); -- must be varchar
  l_new_end_date                 varchar2(240); -- must be varchar
  l_new_description              varchar2(240);
  l_new_group_app_short_name     fnd_application.application_short_name%type;
  l_new_request_group_name       fnd_request_groups.request_group_name%type;
  l_new_request_group_id         fnd_request_groups.request_group_name%type;
  l_new_version                  fnd_responsibility.version%type;
  l_new_web_host_name            fnd_responsibility.web_host_name%type;
  l_new_web_agent_name           fnd_responsibility.web_agent_name%type;
  l_legilsation_code             per_business_groups.legislation_code%type;
  l_hrms_resp_one_count          number(9) := 0;

  cursor csr_new_responsibility(cp_new_responsibility_key in varchar) IS
     select  apps.application_short_name application_short_name,
             resp.responsibility_key responsibility_key,
             responsibility_id responsibility_id,
             responsibility_name responsibility_name,
             resp.data_group_id,
             menus.menu_name menu_name,
             to_char(start_date,'YYYY/MM/DD'),
             end_date,
             resp.description description,
             request_group_id,
             resp.version version,
             resp.web_host_name web_host_name,
             resp.web_agent_name web_agent_name
       from fnd_responsibility_vl  resp,
            fnd_application_vl apps,
            fnd_menus menus
      where resp.application_id = apps.application_id
      and   resp.menu_id = menus.menu_id
      and   resp.responsibility_key = cp_new_responsibility_key;

  cursor csr_requests_groups(cp_new_request_group_id in number) IS
    select request_group_name, apps.application_short_name
      from fnd_request_groups req,
           fnd_application apps
     where request_group_id    = cp_new_request_group_id
       and req.application_id  = apps.application_id;

  cursor csr_data_groups(cp_new_data_group_id in number,
                         cp_new_app_short_name in varchar2) IS
    select dg.data_group_name, a.application_short_name
     from  fnd_data_group_units dgu,
           fnd_data_groups dg,
           fnd_application a
     where dgu.data_group_id = dg.data_group_id
       and dg.data_group_id = cp_new_data_group_id
       and dgu.application_id = a.application_id
       and a.application_short_name = cp_new_app_short_name;


  l_start_date        varchar2(240) := to_char(per_ri_config_utilities.g_config_effective_date,'YYYY/MM/DD');
  l_end_date          varchar2(240) := to_char(per_ri_config_utilities.g_config_effective_end_date,'YYYY/MM/DD');

  BEGIN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    if NOT (p_technical_summary_mode) then
      open csr_user;
      fetch csr_user into l_user_name;
      close csr_user;

      l_security_profile_name := p_security_profile_name;
      l_responsibility_key    := p_responsibility_key;

      hr_utility.trace('l_security_profile_name := ' || l_security_profile_name);
      hr_utility.trace('l_responsibility_key := ' || l_responsibility_key);

      open csr_business_group(l_security_profile_name);
      fetch csr_business_group into l_security_group_id;
      close csr_business_group;

      open csr_security_profiles(l_security_profile_name);
      fetch csr_security_profiles into l_security_profile_id;
      close csr_security_profiles;

      hr_utility.trace('l_security_profile_id := ' || l_security_profile_id);

      open csr_responsibility(l_responsibility_key);
      fetch csr_responsibility into l_responsibility_application_i,l_responsibility_id;
      close csr_responsibility;
      hr_utility.trace('l_responsibility_key := ' || l_responsibility_key);

      open csr_application(l_responsibility_application_i);
      fetch csr_application into l_application_short_name;
      close csr_application;
      hr_utility.trace('l_application_short_name := ' || l_application_short_name);

      open csr_security_group_name(l_security_group_id);
      fetch csr_security_group_name into l_security_group_name, l_security_group_key;
      close csr_security_group_name;

      hr_utility.trace('l_security_group_id := ' || l_security_group_id);
      hr_utility.trace('l_security_group_key := ' || l_security_group_key);
      hr_utility.trace('l_start_date := ' || l_start_date);
      hr_utility.trace('l_end_date := ' || l_end_date);

      -- Create a copy of the responsibility and assign it to user.
      -- we can not share responsibility level profile options for
      -- different user.

      open csr_new_responsibility(l_responsibility_key);
      fetch csr_new_responsibility into l_new_app_short_name,
                                        l_new_resp_key,
                                        l_new_responsibility_id,
                                        l_new_responsibility_name,
                                        l_new_data_group_id,
                                        l_new_menu_name,
                                        l_new_start_date,
                                        l_new_end_date,
                                        l_new_description,
                                        l_new_request_group_id,
                                        l_new_version,
                                        l_new_web_host_name,
                                        l_new_web_agent_name;
      close csr_new_responsibility;

      open csr_requests_groups(l_new_request_group_id);
      fetch csr_requests_groups into l_new_request_group_name, l_new_group_app_short_name;
      close csr_requests_groups;

      hr_utility.trace('l_new_request_group_name := ' || l_new_request_group_name);

      hr_utility.trace('l_new_app_short_name := ' || l_new_app_short_name);
      hr_utility.trace('l_new_data_group_id := ' || l_new_data_group_id);

      open csr_data_groups(l_new_data_group_id,l_new_app_short_name);
      fetch csr_data_groups into l_new_data_group_name, l_new_data_group_app_name;
      close csr_data_groups;

      l_new_responsibility_name := per_ri_config_utilities.return_config_entity_name(l_new_responsibility_name);
      l_new_resp_key := upper(per_ri_config_utilities.return_config_entity_name(l_new_resp_key)); -- Fix for bug 9706310

      hr_utility.trace('l_new_resp_key ' || l_new_resp_key);
      hr_utility.trace('l_new_responsibility_name ' ||  l_new_responsibility_name);

      -- Modify GLB key names to country specific keys
      if l_new_resp_key like 'GLB_%' then
        -- extract legislation code
        l_legilsation_code  := substr(l_security_profile_name,length(l_security_profile_name)-4,2);
        l_new_resp_key := replace(l_new_resp_key,'GLB',l_legilsation_code);

        --append legislation code
        l_new_responsibility_name :=  l_legilsation_code || ' ' || l_new_responsibility_name;
      end if;

      -- this takes care of HR and HRMS resps
      if l_new_resp_key like 'GLOBAL%' then
        -- extract legislation code
        hr_utility.trace('in GLobal Resp');
        l_legilsation_code  := substr(l_security_profile_name,length(l_security_profile_name)-4,2);
        l_new_resp_key := replace(l_new_resp_key,'GLOBAL',l_legilsation_code);

        --append legislation code
        l_new_responsibility_name :=  l_legilsation_code || ' '  || l_new_responsibility_name;
      end if;

      per_ri_config_utilities.create_responsibility
                            (p_app_short_name            => l_new_app_short_name
                            ,p_resp_key                  => l_new_resp_key
                            ,p_responsibility_id         => l_new_responsibility_id
                            ,p_responsibility_name       => l_new_responsibility_name
                            ,p_owner                     => l_new_owner
                            ,p_data_group_app_short_name => l_new_data_group_app_name
                            ,p_data_group_name           => l_new_data_group_name
                            ,p_menu_name                 => l_new_menu_name
                            ,p_start_date                => l_new_start_date
                            ,p_end_date                  => l_new_end_date
                            ,p_description               => l_new_description
                            ,p_group_app_short_name      => 'PER'
                            ,p_request_group_name        => l_new_request_group_name
                            ,p_version                   => l_new_version
                            ,p_web_host_name             => l_new_web_host_name
                            ,p_web_agent_name            => l_new_web_agent_name);

     -- assign this responsibility to the user
     fnd_user_resp_groups_api.load_row(
                 x_user_name       => l_user_name,
                 x_resp_key        => l_new_resp_key,
                 x_app_short_name  => l_new_app_short_name,
                 x_security_group  => l_security_group_key,
                 x_owner           => 'SEED',
                 x_start_date      => l_start_date,
                 x_end_date        => l_end_date,
                 x_description     => 'Created by Enterprise Structure Configuration');

     hr_utility.trace('Assigned Responsibility: ' || l_new_resp_key || ' ' || l_security_group_name);
     hr_utility.set_location(l_proc, 40);

     per_ri_config_fnd_hr_entity.create_bg_id_and_sg_id_profile
                                       (p_configuration_code          => p_configuration_code
                                       ,p_responsibility_key          => l_new_resp_key
                                       ,p_business_group_name         => l_security_profile_name
                                       ,p_technical_summary_mode      => p_technical_summary_mode
                                       ,p_bg_sg_ut_profile_resp_tab   => l_bg_sg_ut_profile_resp_tab);

     else

      -- security profile name and business group name is same
      -- get the name of new responsibility key and respobnsibility name

      l_user_name := upper(per_ri_config_utilities.return_config_entity_name_pre
                       (per_ri_config_main.g_configuration_user_name));
      l_security_profile_name := p_security_profile_name;
      l_responsibility_key    := p_responsibility_key;

      open csr_responsibility_name(l_responsibility_key);
      fetch csr_responsibility_name into l_ts_responsibility_name;
      close csr_responsibility_name;

      l_ts_new_responsibility_name := per_ri_config_utilities.return_config_entity_name(l_ts_responsibility_name);
      l_ts_new_resp_key := per_ri_config_utilities.return_config_entity_name(p_responsibility_key);

      -- Modify GLB key names to country specific keys
      if (l_ts_new_resp_key like 'GLB_%') and (p_security_profile_name not like '%INT BG') then
        -- extract legislation code
        l_legilsation_code  := substr(p_security_profile_name,length(l_security_profile_name)-4,2);
        l_ts_new_resp_key := replace(l_ts_new_resp_key,'GLB',l_legilsation_code);

        --append legislation code
        l_ts_new_responsibility_name :=  l_legilsation_code || ' ' || l_ts_new_responsibility_name;
      end if;

      -- this takes care of HR and HRMS resps
      -- Modify GLB key names to country specific keys
      if (l_ts_new_resp_key like 'GLOBAL%') and (p_security_profile_name not like '%INT BG') then
        -- extract legislation code
        l_legilsation_code  := substr(p_security_profile_name,length(l_security_profile_name)-4,2);
        l_ts_new_resp_key := replace(l_ts_new_resp_key,'GLOBAL',l_legilsation_code);

        --append legislation code
        l_ts_new_responsibility_name :=  l_legilsation_code || ' ' || l_ts_new_responsibility_name;
      end if;

      per_ri_config_fnd_hr_entity.create_bg_id_and_sg_id_profile
                                   (p_configuration_code          => p_configuration_code
                                   ,p_responsibility_key          => l_ts_new_resp_key
                                   ,p_business_group_name         => p_security_profile_name
                                   ,p_technical_summary_mode      => p_technical_summary_mode
                                   ,p_bg_sg_ut_profile_resp_tab   => l_bg_sg_ut_profile_resp_tab);

     -- modify the responsibility key to name to be displayed in TS data
     l_bg_sg_ut_profile_resp_tab(0).level_value := l_ts_new_responsibility_name;
     l_bg_sg_ut_profile_resp_tab(1).level_value := l_ts_new_responsibility_name;
     l_bg_sg_ut_profile_resp_tab(2).level_value := l_ts_new_responsibility_name;

     p_bg_sg_ut_profile_resp_tab := l_bg_sg_ut_profile_resp_tab; -- three rows

     --new date for responsibility population
     p_hrms_resp_one_tab(l_hrms_resp_one_count).user_name      := l_user_name;
     p_hrms_resp_one_tab(l_hrms_resp_one_count).resp_key       := l_ts_new_responsibility_name;
     p_hrms_resp_one_tab(l_hrms_resp_one_count).app_short_name := 'PER';
     p_hrms_resp_one_tab(l_hrms_resp_one_count).security_group := p_security_profile_name;
     p_hrms_resp_one_tab(l_hrms_resp_one_count).owner          := 'SEED';
     p_hrms_resp_one_tab(l_hrms_resp_one_count).start_date     := l_start_date;
     p_hrms_resp_one_tab(l_hrms_resp_one_count).end_date       := l_end_date;
     p_hrms_resp_one_tab(l_hrms_resp_one_count).description    := per_ri_config_main.g_description_string;
     --
     hr_utility.set_location(' Leaving:'|| l_proc, 100);
   end if;
  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);

  END create_resp_and_profile;

  /* --------------------------------------------------------------------------
  -- Name      : get_responsibility_name
  -- Purpose   : This function returns name of responsibility from the key
  -- Arguments : p_responsibility_key
  --
  -------------------------------------------------------------------------- */

  FUNCTION get_responsibility_name (p_responsibility_key    in varchar2)
                        RETURN varchar2 IS

  cursor csr_responsibility_key
                  (cp_responsibility_key            in varchar2) IS
    select responsibility_name
      from fnd_responsibility_vl
    where  responsibility_key    = cp_responsibility_key;

  l_responsibility_name   fnd_responsibility_vl.responsibility_name%type;

  l_proc                     varchar2(72) := g_package || 'get_responsibility_name';
  l_error_message            varchar2(360);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    open csr_responsibility_key(p_responsibility_key);

    fetch csr_responsibility_key into
               l_responsibility_name;
    if csr_responsibility_key%NOTFOUND then
        hr_utility.trace('Responsibility not found');
        l_responsibility_name := p_responsibility_key;
    end if;

    close csr_responsibility_key;

    hr_utility.set_location(' Leaving:'|| l_proc, 30);

    return l_responsibility_name;

  EXCEPTION
    when others then
      l_error_message := 'Error in ' || l_proc;
      hr_utility.trace(l_error_message || '-' || sqlerrm);
      hr_utility.set_location(' Leaving:'|| l_proc, 500);
      hr_utility.raise_error;

  END get_responsibility_name;

-------------------------------------------------------------------------------
-- This Function returns the business group name through which the user has
-- logged in to the system.
-------------------------------------------------------------------------------
 FUNCTION get_business_group_name
    RETURN varchar2 IS

   cursor bg_name IS
    select name from per_business_groups
     where business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

   l_bg_name      varchar2(50);

  BEGIN

    hr_utility.set_location('Entering get_business_group_name ' , 10);

    open  bg_name;
    fetch bg_name into l_bg_name;
    close bg_name;

    return l_bg_name;

  END get_business_group_name;

END per_ri_config_utilities;

/
