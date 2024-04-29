--------------------------------------------------------
--  DDL for Package Body PAY_FR_DADS_ESTAB_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_DADS_ESTAB_COMP" AS
/* $Header: pyfrdesc.pkb 120.1 2006/01/30 05:27:02 aparkes noship $ */

  ------------------------------------------------------------------------
    -- Archive data procedure---
    ------------------------------------------------------------------------
    -- This procedure is to be called for archiving all structures
    PROCEDURE archive_data(p_payroll_action_id NUMBER,
                           p_rubric_name       VARCHAR2,
                           p_message_type      VARCHAR2,
                           p_org_id            NUMBER,
                           p_lookup_type       VARCHAR2,
                           p_file_value        VARCHAR2,
                           p_message_text      VARCHAR2,
                           p_extra_information VARCHAR2 DEFAULT NULL,
                           p_usage             VARCHAR2)
    IS
    --
    l_action_info_id NUMBER;
    l_ovn NUMBER;
    l_user_value fnd_lookup_values.meaning%type;
    --
    BEGIN
    --
    IF p_lookup_type is not null THEN
       l_user_value := hr_general.decode_lookup(p_lookup_type,p_file_value);
    END IF;
    --
    pay_action_information_api.create_action_information (
            p_action_information_id       =>  l_action_info_id
          , p_action_context_id           =>  p_payroll_action_id
          , p_action_context_type         =>  'PA'
          , p_object_version_number       =>  l_ovn
          , p_action_information_category =>  'FR_DADS_FILE_DATA'
          , p_action_information1         =>  p_rubric_name
          , p_action_information2         =>  p_message_type
          , p_action_information3         =>  p_org_id
          , p_action_information4         =>  p_file_value
          , p_action_information5         =>  l_user_value
          , p_action_information6         =>  p_message_text
          , p_action_information7         =>  p_extra_information
          , p_action_information9         =>  p_usage);
    --
    EXCEPTION
      WHEN OTHERS THEN raise;
  END archive_data;
  -------------------------------------------------------------------------------------
  -- Archive report Data Procedure
  -------------------------------------------------------------------------------------
  -- This procedure is to be called from S10 and S20 procedures
  -- for archiving CRE establishment name in FR_DADS_REPORT_DATA structure
  PROCEDURE archive_report_data(p_payroll_action_id NUMBER,
                                p_section_name VARCHAR2,
                                p_sort_order NUMBER,
                                p_org_id NUMBER,
                                p_cre_org_name VARCHAR2,
                                p_report_code VARCHAR2)
  IS
  --
  l_action_info_id NUMBER;
  l_ovn NUMBER;
  --
  BEGIN
  --
  pay_action_information_api.create_action_information (
          p_action_information_id       =>  l_action_info_id
        , p_action_context_id           =>  p_payroll_action_id
        , p_action_context_type         =>  'PA'
        , p_object_version_number       =>  l_ovn
        , p_action_information_category =>  'FR_DADS_REPORT_DATA'
        , p_action_information1         =>  p_section_name
        , p_action_information2         =>  p_sort_order
        , p_action_information3         =>  p_org_id
        , p_action_information4         =>  p_report_code
        , p_action_information5         =>  p_cre_org_name);
  --
  EXCEPTION
      WHEN OTHERS THEN raise;
  END archive_report_data;
  --
  -----------------------------------------------------------------------------------
  --         ISSUING ESTABLISHMENT INFORMATION PROCEDURE
  -----------------------------------------------------------------------------------
 PROCEDURE S10_00_issue_estab(p_param_reference          IN VARCHAR2,
                              p_param_issuing_estab_id  IN NUMBER,
                              p_param_business_group_id IN NUMBER,
                              p_payroll_action_id       IN NUMBER,
                              p_cre_info_issue          OUT NOCOPY g_cre_info_issue%TYPE)
    IS
      --
      l_siren              hr_organization_information.org_information1%TYPE ;
      l_nic                varchar2(7) ;
      l_name               hr_all_organization_units_tl.name%TYPE ;
      l_name_comp          hr_all_organization_units_tl.name%TYPE ;
      l_location           hr_all_organization_units.location_id%TYPE ;
      l_complement         hr_locations_all.address_line_2%TYPE ;
      l_street_and_number  hr_locations_all.address_line_1%TYPE ;
      l_insee              hr_locations_all.region_2%TYPE ;
      l_small_town         hr_locations_all.region_3%TYPE ;
      l_postal_code        hr_locations_all.postal_code%TYPE ;
      l_town               hr_locations_all.town_or_city%TYPE ;
      l_country_code       varchar2(30) ;
      l_country_name       fnd_territories.nls_territory%TYPE;
      l_software           varchar2(20) ;
      l_provider           varchar2(10) ;
      l_version            varchar2(20) ;
      l_service_code       varchar2(4) ;
      l_live_send_code     varchar2(4) ;
      l_test_send_code     varchar2(4) ;
      l_norm               varchar2(30) ;
      l_table_code         varchar2(30) ;
      l_cre_estab_id       hr_organization_information.organization_id%TYPE ;
      l_cre_siren          hr_organization_information.org_information1%TYPE ;
      l_cre_nic            varchar2(7) ;
      l_cre_media          hr_organization_information.org_information1%TYPE ;
      l_address_to_use     hr_organization_information.org_information2%TYPE ;
      l_value              fnd_new_messages.message_text%type;
      l_error_type         hr_lookups.meaning%type;
      l_error              hr_lookups.meaning%type;
      l_warning            hr_lookups.meaning%type;
      l_cre_estab_name     hr_all_organization_units_tl.name%TYPE;
      l_location_name      hr_locations_all_tl.location_code%TYPE;
      --
      Cursor csr_get_S10_G00 is
      Select hoi_issue_comp.org_information1   SIREN_issue_estab,
             substr(hoi_issue_estab.org_information2, length(hoi_issue_estab.org_information2)-4, 5)  NIC_issue_estab,
             hou_issue_estab_tl.name           name_issue_estab,
       	     hou_issue_estab.location_id       location_id,
	     hloc_issue_estab_tl.location_code location_name,
             --
             hloc_issue_estab.address_line_2  addr_compl_issue_estab,
             hloc_issue_estab.address_line_1  addr_nstreet_issue_estab,
             hloc_issue_estab.region_2        addr_insee_issue_estab,
             hloc_issue_estab.region_3        addr_town_issue_estab,
             hloc_issue_estab.postal_code     addr_zip_issue_estab,
             hloc_issue_estab.town_or_city    addr_towncity_issue_estab,
             -- (Afnor codes)                 addr_cntrycode_issue_estab ,
             ft_issue_estab.nls_territory     addr_cntryname_issue_estab,
             --
             '02'                              Send_code_live,
             '01'                              Send_code_test,
             --
	     hoi_cre_comp_tl.name              name_cre_comp,
             hoi_cre_comp.org_information1     SIREN_cre_estab,
             substr(hoi_cre_estab.org_information2, length(hoi_cre_estab.org_information2)-4, 5) NIC_cre_estab,
             hoi_cre_dads.org_information1     type_media_cre_estab,
             hoi_cre_dads.org_information2     address_cre_estab,
	     hoi_cre_estab.organization_id     cre_estab_org_id,
             hou_cre_estab_tl.name             name_cre_estab
             --
      From hr_all_organization_units        hou_issue_estab,
           hr_all_organization_units_tl     hou_issue_estab_tl,
           hr_all_organization_units_tl     hou_cre_estab_tl,
           hr_all_organization_units_tl     hoi_cre_comp_tl,
           hr_organization_information      hoi_issue_estab_cre,
           hr_organization_information      hoi_issue_estab,
           hr_organization_information      hoi_issue_comp,
           hr_locations_all                 hloc_issue_estab,
	   hr_locations_all_tl              hloc_issue_estab_tl,
           --
           hr_organization_information      hoi_cre_estab,
           hr_organization_information      hoi_cre_comp,
           hr_organization_information      hoi_cre_dads,
           --
           fnd_territories                  ft_issue_estab
           --
      Where hou_issue_estab.organization_id = p_param_issuing_estab_id
        and hou_issue_estab.business_group_id = p_param_business_group_id
        --
        and hou_issue_estab_tl.organization_id = hou_issue_estab.organization_id
        and hou_issue_estab_tl.language = userenv('LANG')
        --
        and hoi_issue_estab.organization_id(+) = hou_issue_estab.organization_id
        and hoi_issue_estab.org_information_context(+) = 'FR_ESTAB_INFO'
        and hoi_issue_comp.organization_id(+) = hoi_issue_estab.org_information1
        and hoi_issue_comp.org_information_context(+) = 'FR_COMP_INFO'
        --
        and hloc_issue_estab.location_id(+)= hou_issue_estab.location_id
        and hloc_issue_estab.style(+) ='FR'
        --
        and ft_issue_estab.territory_code(+) = hloc_issue_estab.country
        --
        and hloc_issue_estab_tl.location_id(+) = hou_issue_estab.location_id
        and hloc_issue_estab_tl.language(+) = userenv('LANG')
        --
        and hoi_issue_estab_cre.organization_id(+)= hou_issue_estab.organization_id
        and hoi_issue_estab_cre.org_information_context(+) = 'FR_DADS_ISSUE_CRE_INFO'
        and hoi_cre_estab.organization_id(+) = hoi_issue_estab_cre.org_information1
        and hoi_cre_estab.org_information_context(+) = 'FR_ESTAB_INFO'
        and hoi_cre_comp.organization_id(+) = hoi_cre_estab.org_information1
        and hoi_cre_comp.org_information_context(+) = 'FR_COMP_INFO'
        and hoi_cre_comp_tl.organization_id(+) = hoi_cre_comp.organization_id
        and hoi_cre_comp_tl.language(+) = userenv('LANG')
        --
        and hoi_cre_dads.organization_id(+) = hoi_issue_estab_cre.org_information1
        and hoi_cre_dads.org_information_context(+) = 'FR_DADS_CRE_INFO'
        and hou_cre_estab_tl.organization_id(+) = hoi_issue_estab_cre.org_information1
        and hou_cre_estab_tl.language(+) = userenv('LANG');
        --
      BEGIN
      /* Initialising the local variables */
      l_software           := 'Oracle Payroll';
      l_provider           := 'Oracle';
      l_version            := '11.5.9';
      l_service_code       := '40';
      l_norm               := 'V7R00';
      l_table_code         := 'ISO/IEC 8859';
      /* End of Initialising the local variables */

        -- Call and fetch cursor
        OPEN csr_get_S10_G00;
        FETCH csr_get_S10_G00 INTO l_siren ,
                                   l_nic ,
                                   l_name ,
                                   l_location,
				   l_location_name,
                                   l_complement ,
                                   l_street_and_number,
                                   l_insee ,
                                   l_small_town ,
                                   l_postal_code,
                                   l_town ,
                                   l_country_name ,
                                   l_live_send_code ,
                                   l_test_send_code,
				   l_name_comp,
                                   l_cre_siren ,
                                   l_cre_nic ,
                                   l_cre_media,
                                   l_address_to_use,
				   l_cre_estab_id,
                                   l_cre_estab_name;
        CLOSE csr_get_S10_G00;
        -- Populate table for cre information
	g_cre_info_issue.cre_estab_id := l_cre_estab_id;
        g_cre_info_issue.cre_name := l_name_comp;
        g_cre_info_issue.cre_siren := l_cre_siren;
        g_cre_info_issue.cre_nic := l_cre_nic ;
        g_cre_info_issue.cre_media := l_cre_media;
        g_cre_info_issue.address_to_use := l_address_to_use;
        --
        -- Archive CRE estab name
        IF l_cre_estab_name IS NOT NULL THEN
           archive_report_data(
                      p_payroll_action_id => p_payroll_action_id,
                      p_section_name      => 'S10',
                      p_sort_order        => 1,
                      p_org_id            => p_param_issuing_estab_id,
                      p_cre_org_name      => l_cre_estab_name,
                      p_report_code       => 'S10_CRE_ESTAB_NAME');
        END IF;
        -- Getting the error messages
        l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
        l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');
        -- SIREN Number
  	IF l_siren is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
               'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.001.001'), null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
          -- Archive SIREN number
          archive_data(
  	       p_payroll_action_id => p_payroll_action_id
  	      ,p_rubric_name       => 'S10.G01.00.001.001'
  	      ,p_message_type      => l_error_type
  	      ,p_org_id            => p_param_issuing_estab_id
  	      ,p_lookup_type       => null
  	      ,p_file_value        => l_siren
              ,p_message_text      => l_value
              ,p_usage             => 'M');
          --
  	--NIC Origin Establishment
  	IF l_nic is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
               'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.001.002'), null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive NIC Origin Establishment
  	archive_data(
  	        p_payroll_action_id => p_payroll_action_id
  	       ,p_rubric_name       => 'S10.G01.00.001.002'
  	       ,p_message_type      => l_error_type
  	       ,p_org_id            => p_param_issuing_estab_id
  	       ,p_lookup_type       => null
  	       ,p_file_value        => l_nic
               ,p_message_text      => l_value
               ,p_usage             => 'M');
          --
  	-- Name of the Establishment
  	IF l_name is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
               ('FR_DADS_RUBRICS','S10.G01.00.002'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive Name of the Establishment
  	archive_data(
  	        p_payroll_action_id => p_payroll_action_id
  	       ,p_rubric_name       => 'S10.G01.00.002'
  	       ,p_message_type      => l_error_type
  	       ,p_org_id            => p_param_issuing_estab_id
  	       ,p_lookup_type       => null
  	       ,p_file_value        => l_name
               ,p_message_text      => l_value
               ,p_usage             => 'M');
     	-- First check the location
  	IF l_location is null THEN
	  l_error_type := l_error;
	  l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
	               'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
                    ('FR_DADS_RUBRICS','S10.G01.00.003.006.M'), null);
  	  -- Archive Nature and Name of the Street
	   archive_data(
	    	p_payroll_action_id => p_payroll_action_id
	    	,p_rubric_name       => 'S10.G01.00.003.006'
	    	,p_message_type      => l_error_type
	    	,p_org_id            => p_param_issuing_estab_id
	    	,p_lookup_type       => null
	    	,p_file_value        => l_street_and_number
	        ,p_message_text      => l_value
	        ,p_usage             => 'C');
  	  --
  	  -- Archive the remaining mandatory rubrics, i.e. zip code and town_or_city
  	  -- Archive zip code with null error and value
  	  archive_data(
	  	  p_payroll_action_id => p_payroll_action_id
	  	 ,p_rubric_name       => 'S10.G01.00.003.010'
	  	 ,p_message_type      => null
	  	 ,p_org_id            => p_param_issuing_estab_id
	  	 ,p_lookup_type       => null
	  	 ,p_file_value        => null
	  	 ,p_message_text      => null
	  	 ,p_usage             => 'M');
  	  -- Archive town_or_city with null error and value
  	  archive_data(
	  	   p_payroll_action_id => p_payroll_action_id
	  	  ,p_rubric_name       => 'S10.G01.00.003.012'
	  	  ,p_message_type      => null
	  	  ,p_org_id            => p_param_issuing_estab_id
	  	  ,p_lookup_type       => null
	  	  ,p_file_value        => null
	  	  ,p_message_text      => null
	  	  ,p_usage             => 'M');

  	ELSE -- if location is not null
  	   -- Archive address complement
           l_error_type:=null;
           l_value:=null;
           archive_data(
  	          p_payroll_action_id => p_payroll_action_id
  	         ,p_rubric_name       => 'S10.G01.00.003.001'
  	         ,p_message_type      => l_error_type
  	         ,p_org_id            => p_param_issuing_estab_id
  	         ,p_lookup_type       => null
  	         ,p_file_value        => l_complement
  	         ,p_message_text      => l_value
  	         ,p_usage             => 'O');
  	   -- Nature and Name of the Street
  	   IF l_street_and_number is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
               'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.003.006'), null);
           ELSE
             l_error_type := null;
             l_value := null;
  	   END IF;
  	  -- Archive Nature and Name of the Street
  	  archive_data(
  	        p_payroll_action_id => p_payroll_action_id
  	       ,p_rubric_name       => 'S10.G01.00.003.006'
  	       ,p_message_type      => l_error_type
  	       ,p_org_id            => p_param_issuing_estab_id
  	       ,p_lookup_type       => null
  	       ,p_file_value        => l_street_and_number
               ,p_message_text      => l_value
               ,p_usage             => 'C');
  	  --
  	  -- Archive INSEE code
         l_error_type:=null;
         l_value:=null;
  	  archive_data(
  	        p_payroll_action_id => p_payroll_action_id
  	       ,p_rubric_name       => 'S10.G01.00.003.007'
  	       ,p_message_type      => l_error_type
  	       ,p_org_id            => p_param_issuing_estab_id
  	       ,p_lookup_type       => null
  	       ,p_file_value        => l_insee
               ,p_message_text      => l_value
               ,p_usage             => 'O');
  	  --
  	  -- Name of the Town
  	  IF upper(l_small_town) = upper(l_town) THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
               null, null, null);
             -- making the value of 'TOWN' as null
             -- for bug 3550604
             l_small_town := null;
          ELSE
             l_error_type := null;
             l_value := null;
  	  END IF;
  	  -- Archive name of town
  	  archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.003.009'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_small_town
                ,p_message_text      => l_value
                ,p_usage             => 'C');
  	  --
  	  -- Zip Code
  	  IF l_postal_code is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
              'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.003.010'), null);
          ELSE
             l_error_type := null;
             l_value := null;
  	  END IF;
  	  -- Archive zip code
  	  archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.003.010'
  	        ,p_message_type      =>  l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_postal_code
                ,p_message_text      => l_value
                ,p_usage             => 'M');
  	  --
  	  -- City
  	  IF l_town <> upper(l_town) THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
               null, null, null);
  	  ELSIF l_town is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
               'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.003.012'), null);
          ELSE
             l_error_type := null;
             l_value := null;
  	  END IF;
  	  -- Archive City
  	  archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.003.012'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_town
                ,p_message_text      => l_value
                ,p_usage             => 'M');
           --
  	  /* Afnor Codes
  	  -- Country Code
  	  IF l_country_code = 'FR' THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
               'VALUE1: '||hr_general.decode_lookup
	       ('FR_DADS_RUBRICS','S10.G01.00.003.013'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	  END IF;
  	  -- Archive country code
  	  archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.003.013'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_country_code
                ,p_message_text      => l_value
                ,p_usage             =>);
  	  --
  	  */
  	  -- Country Name
  	  IF l_country_name is not null and l_country_code = 'FR' THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
               'VALUE1: '||hr_general.decode_lookup
               ('FR_DADS_RUBRICS','S10.G01.00.003.014'), null, null);
          ELSIF l_country_name is null AND l_country_code is not null AND l_country_code <> 'FR' THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
               ('FR_DADS_RUBRICS','S10.G01.00.003.014'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	  END IF;
  	  -- Archive country name
  	  archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.003.014'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_country_name
                ,p_message_text      => l_value
                ,p_usage             => 'C');
          --
        END IF; -- Check for location
  	-- Internal Reference
  	IF p_param_reference is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.004'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive internal reference
  	archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.004'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => p_param_reference
                ,p_message_text      => l_value
                ,p_usage             => 'M');
          --
          -- Archive software name
           l_error_type:=null;
           l_value:=null;
          archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.005'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_software
                ,p_message_text      => l_value
                ,p_usage             => 'O');
          --
          -- Archive provider name
          l_error_type:=null;
          l_value:=null;
          archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.006'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_provider
                ,p_message_text      => l_value
                ,p_usage             => 'O');
          --
          -- Archive version number
           l_error_type:=null;
           l_value:=null;
          archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.007'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_version
                ,p_message_text      => l_value
                ,p_usage             => 'O');
          --
  	-- Service Code
  	IF l_service_code is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.009'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive service code
  	archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.009'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => 'FR_DADS_SERVICE_CODE'
  	        ,p_file_value        => l_service_code
                ,p_message_text      => l_value
                ,p_usage             => 'M');
  	--
  	-- Norm
  	IF l_norm is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.011'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive norm
  	archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.011'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_norm
                ,p_message_text      => l_value
                ,p_usage             => 'M');
  	--
  	-- Character Table Code
  	IF l_table_code is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.012'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive character table code
  	archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.012'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => null
  	        ,p_file_value        => l_table_code
                ,p_message_text      => l_value
                ,p_usage             => 'M');
  	--
  	-- Live Send Code
  	IF l_live_send_code is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.010'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive live send code
  	archive_data(
  	         p_payroll_action_id => p_payroll_action_id
  	        ,p_rubric_name       => 'S10.G01.00.010'
  	        ,p_message_type      => l_error_type
  	        ,p_org_id            => p_param_issuing_estab_id
  	        ,p_lookup_type       => 'FR_DADS_SEND_CODE'
  	        ,p_file_value        => l_live_send_code
                ,p_message_text      => l_value
                ,p_usage             => 'M');
  	--
  	-- Test Send Code
  	IF l_test_send_code is null THEN
             l_error_type := l_error;
             l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
               'VALUE1: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.010'), null, null);
          ELSE
             l_error_type := null;
             l_value := null;
  	END IF;
  	-- Archive test send code
          archive_data(
  		 p_payroll_action_id => p_payroll_action_id
  		,p_rubric_name       => 'S10.G01.00.010'
  		,p_message_type      => l_error_type
  		,p_org_id            => p_param_issuing_estab_id
  		,p_lookup_type       => 'FR_DADS_SEND_CODE'
  		,p_file_value        => l_test_send_code
  	        ,p_message_text      => l_value
  	        ,p_usage             => 'M');
  	--
  	-- SIREN, NIC, Type of Media, Address for CRE
  	IF l_cre_estab_name is not null THEN
  	   IF l_cre_siren is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
  	      'VALUE1: '||l_name_comp,  'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.013.001'), null);
           ELSE
               l_error_type:= null;
               l_value:=null;
           end if;
           -- Archive CRE information
           archive_data(
  	            p_payroll_action_id => p_payroll_action_id
  	           ,p_rubric_name       => 'S10.G01.00.013.001'
  	           ,p_message_type      => l_error_type
  	           ,p_org_id            => p_param_issuing_estab_id
  	           ,p_lookup_type       => null
  	           ,p_file_value        => l_cre_siren
  	           ,p_message_text      => l_value
  	           ,p_usage             => 'C');
  	   IF l_cre_nic is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
              'VALUE1: '||l_cre_estab_name,  'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.013.002'), null);
           ELSE
               l_error_type:= null;
               l_value:=null;
           END IF;
           -- For l_cre_nic
  	   archive_data(
  	            p_payroll_action_id => p_payroll_action_id
  	           ,p_rubric_name       => 'S10.G01.00.013.002'
  	           ,p_message_type      => l_error_type
  	           ,p_org_id            => p_param_issuing_estab_id
  	           ,p_lookup_type       => null
  	           ,p_file_value        => l_cre_nic
                   ,p_message_text      => l_value
                   ,p_usage             => 'C');
  	   IF l_cre_media is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
              'VALUE1: '||l_cre_estab_name,  'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.014'), null);
           ELSE
               l_error_type:= null;
               l_value:=null;
           END IF;
           -- For l_cre_media
  	   archive_data(
  	            p_payroll_action_id => p_payroll_action_id
  	           ,p_rubric_name       => 'S10.G01.00.014'
  	           ,p_message_type      => l_error_type
  	           ,p_org_id            => p_param_issuing_estab_id
  	           ,p_lookup_type       => 'FR_DADS_CRE_TYPE_MEDIA'
  	           ,p_file_value        => l_cre_media
  	           ,p_message_text      => l_value
  	           ,p_usage             => 'C');
           IF l_address_to_use is null AND l_cre_media = '03' THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
              'VALUE1: '||l_cre_estab_name,  'VALUE2: '||hr_general.decode_lookup
  	            ('FR_DADS_RUBRICS','S10.G01.00.015'), null);
           ELSIF l_cre_media = '05' AND l_address_to_use is not null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75184_CRE_DATA',
                                    null, null, null);
           ELSE
              l_error_type:= null;
              l_value :=null;
  	   END IF;
  	   -- For l_address_to_use
  	   archive_data(
  	            p_payroll_action_id => p_payroll_action_id
  	           ,p_rubric_name       => 'S10.G01.00.015'
  	           ,p_message_type      => l_error_type
  	           ,p_org_id            => p_param_issuing_estab_id
  	           ,p_lookup_type       => null
  	           ,p_file_value        => l_address_to_use
                   ,p_message_text      => l_value
                   ,p_usage             => 'C');
             --
  	END IF;
     --
     EXCEPTION
         WHEN OTHERS THEN raise;
     --
    END S10_00_issue_estab;
  --
  -----------------------------------------------------------------------------------
    --         ISSUING ESTABLISHMENT PERSON INFORMATION PROCEDURE
  -----------------------------------------------------------------------------------
  --
PROCEDURE S10_01_issue_person(p_issuing_estab_id    IN NUMBER,
  			      p_payroll_action_id   IN NUMBER)
  IS
    --
        l_person             hr_organization_information.org_information1%TYPE ;
        l_domain_code        hr_organization_information.org_information2%TYPE ;
        l_media_type         hr_organization_information.org_information3%TYPE ;
        l_address_to_use     hr_organization_information.org_information4%TYPE ;
        l_count              number;
        l_name               hr_all_organization_units_tl.name%TYPE ;
        l_value              fnd_new_messages.message_text%type;
        l_error_type         hr_lookups.meaning%type;
        l_error              hr_lookups.meaning%type;
        l_warning            hr_lookups.meaning%type;
        --
        cursor csr_get_S10_G01 is
        select hoi_issue_estab_cre.org_information1 person_g01,
             hou_issue_estab_tl.name  name_issue_estab,
             hoi_issue_estab_cre.org_information2 domain_code_g01,
             hoi_issue_estab_cre.org_information3 type_media_g01,
             hoi_issue_estab_cre.org_information4 address_g01
        from hr_organization_information hoi_issue_estab_cre,
             hr_all_organization_units_tl     hou_issue_estab_tl
        where hoi_issue_estab_cre.organization_id = p_issuing_estab_id
          and hoi_issue_estab_cre.org_information_context = 'FR_DADS_CONTACT_INFO'
          and hou_issue_estab_tl.organization_id = p_issuing_estab_id
          and hou_issue_estab_tl.language = userenv('LANG');
        --
      BEGIN
      /* Initialising the local variables */
      l_count              :=0;
      /* End of Initialising the local variables */

      --
      -- Getting the error messages
       l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
       l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');
       --
       -- Loop through 3 times as it is a multi-record EIT
       FOR issue_person_rec in csr_get_S10_G01 LOOP
         l_count := l_count+1;
         l_person := issue_person_rec.person_g01;
         l_name := issue_person_rec.name_issue_estab;
         l_domain_code := issue_person_rec.domain_code_g01;
         l_media_type := issue_person_rec.type_media_g01;
         l_address_to_use := issue_person_rec.address_g01;
         -- Name of person answering queries
         IF l_person is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
                 'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
    	            ('FR_DADS_RUBRICS','S10.G01.01.001.M'), null);
	 ELSIF (substr(l_person, 1,2) = 'M.' OR substr(l_person, 1,2) = 'M '
	     OR substr(l_person, 1,2) = 'MR' OR substr(l_person, 1,2) = 'Mr'
	     OR substr(l_person, 1,3) = 'MME' OR substr(l_person, 1,3) = 'Mme'
	     OR substr(l_person, 1,3) = 'MLE' OR substr(l_person, 1,3) = 'Mle') THEN
               l_error_type := l_warning;
               l_value := pay_fr_general.get_payroll_message('PAY_75176_NO_TITLE',
                 null, null, null);
         ELSE
               l_error_type := null;
               l_value := null;
         END IF;
         -- Archive name of person
         archive_data(
             p_payroll_action_id => p_payroll_action_id
            ,p_rubric_name       => 'S10.G01.01.001'
            ,p_message_type      => l_error_type
            ,p_org_id            => p_issuing_estab_id
            ,p_lookup_type       => null
            ,p_file_value        => l_person
            ,p_message_text      => l_value
            ,p_usage             => 'M');
         --
         -- Domain Code
         IF l_domain_code is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
                 'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
    	            ('FR_DADS_RUBRICS','S10.G01.01.002.M'), null);
         ELSE
               l_error_type := null;
               l_value := null;
         END IF;
         -- Archive domain code
         archive_data(
             p_payroll_action_id => p_payroll_action_id
            ,p_rubric_name       => 'S10.G01.01.002'
            ,p_message_type      => l_error_type
            ,p_org_id            => p_issuing_estab_id
            ,p_lookup_type       => 'FR_DADS_DOMAIN_CODE'
            ,p_file_value        => l_domain_code
            ,p_message_text      => l_value
            ,p_usage             => 'M');
         --
         -- Type of Media to use for Enquiries
         IF l_media_type is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
                 'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
    	            ('FR_DADS_RUBRICS','S10.G01.01.003.M'), null);
         ELSE
               l_error_type := null;
               l_value := null;
         END IF;
         -- Archive Type of Media to use for Enquiries
         archive_data(
             p_payroll_action_id => p_payroll_action_id
            ,p_rubric_name       => 'S10.G01.01.003'
            ,p_message_type      => l_error_type
            ,p_org_id            => p_issuing_estab_id
            ,p_lookup_type       => 'FR_DADS_CONTACT_TYPE_MEDIA'
            ,p_file_value        => l_media_type
            ,p_message_text      => l_value
            ,p_usage             => 'M');
         --
         -- Address to use
         IF l_address_to_use is null THEN
               l_error_type := l_error;
               l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
                 'VALUE1:'||l_name, 'VALUE2: '||hr_general.decode_lookup
    	            ('FR_DADS_RUBRICS','S10.G01.01.004.M'), null);
         ELSE
               l_error_type := null;
               l_value := null;
         END IF;
         -- Archive Address to use
         archive_data(
             p_payroll_action_id => p_payroll_action_id
            ,p_rubric_name       => 'S10.G01.01.004'
            ,p_message_type      => l_error_type
            ,p_org_id            => p_issuing_estab_id
            ,p_lookup_type       => null
            ,p_file_value        => l_address_to_use
            ,p_message_text      => l_value
            ,p_usage             => 'M');
         --
         IF l_count = 3 THEN
           EXIT;
         END IF;
       END LOOP;
   --
   EXCEPTION
      WHEN OTHERS THEN raise;
   --
  END S10_01_issue_person;
  --
  --
  -----------------------------------------------------------------------------------
    --         COMPANY INFORMATION PROCEDURE
  -----------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------
 PROCEDURE S20_comp_info(p_company_id        IN NUMBER,
                         p_cre_info_issue    IN g_cre_info_issue%TYPE,
                         p_dads_start_date   IN DATE,
                         p_dads_end_date     IN DATE,
                         p_payroll_action_id IN NUMBER)
  IS
  --
    l_siren_comp             hr_organization_information.org_information1%TYPE;
    l_name_comp              hr_all_organization_units_tl.name%TYPE;
    l_location               hr_all_organization_units.location_id%TYPE;
    l_location_name          hr_locations_all_tl.location_code%TYPE;
    l_cal_year               varchar2(10);
    l_partition_number       varchar2(4);
    l_currency_type          varchar2(5);
    l_NIC_HQ_estab           varchar2(7);
    l_name_estab             hr_all_organization_units_tl.name%TYPE;
    l_hq_addr_complement     hr_locations_all.address_line_2%TYPE;
    l_hq_addr_nn_street      hr_locations_all.address_line_1%TYPE;
    l_hq_addr_insee_code     hr_locations_all.region_2%TYPE;
    l_hq_addr_town           hr_locations_all.region_3%TYPE;
    l_hq_addr_zip_code       hr_locations_all.postal_code%TYPE ;
    l_hq_addr_town_city      hr_locations_all.town_or_city%TYPE;
    l_hq_addr_country_code   varchar2(30);
    l_hq_addr_country_name   fnd_territories.nls_territory%TYPE;
    l_NIC_fisc_estab         varchar2(7);
    l_fisc_location          hr_all_organization_units.location_id%TYPE;
    l_fisc_location_name     hr_locations_all_tl.location_code%TYPE;
    l_name_fisc_estab        hr_all_organization_units_tl.name%TYPE;
    l_fisc_addr_complement   hr_locations_all.address_line_2%TYPE;
    l_fisc_addr_nn_street    hr_locations_all.address_line_1%TYPE;
    l_fisc_addr_insee_code   hr_locations_all.region_2%TYPE ;
    l_fisc_addr_town         hr_locations_all.region_3%TYPE ;
    l_fisc_addr_zip_code     hr_locations_all.postal_code%TYPE ;
    l_fisc_addr_town_city    hr_locations_all.town_or_city%TYPE;
    l_fisc_addr_country_code varchar2(30);
    l_fisc_addr_country_name fnd_territories.nls_territory%TYPE;
    l_cre_siren              hr_organization_information.org_information1%TYPE;
    l_cre_nic                varchar2(7);
    l_cre_media              hr_organization_information.org_information1%TYPE;
    l_cre_estab_id           hr_organization_information.organization_id%TYPE;
    l_cre_estab_name         hr_all_organization_units_tl.name%TYPE;
    l_addr_to_use            hr_organization_information.org_information2%TYPE;
    l_pension_stmt_addr      hr_organization_information.org_information1%TYPE;
    l_pension_stmt_sort1     hr_organization_information.org_information2%TYPE;
    l_pension_stmt_sort2     hr_organization_information.org_information3%TYPE;
    l_periodicity_code_live  varchar2(5);
    l_periodicity_code_test  varchar2(5);
    l_hq_estab_id            hr_organization_information.organization_id%TYPE;
    l_fisc_estab_id          hr_organization_information.organization_id%TYPE;
    l_value                  fnd_new_messages.message_text%type;
    l_error_type             hr_lookups.meaning%type;
    l_error                  hr_lookups.meaning%type;
    l_warning                hr_lookups.meaning%type;
    --
    -- Cursor for fetching S20 information
    cursor csr_S20_G01_00(p_company_id       number,
                          p_cre_estab_id_chr varchar2) is
    select hoi_comp.org_information1          siren_comp,
           hou_comp_tl.name                   name_comp,
           hou_hq_estab_tl.name               name_hq_estab,
           hou_hq_estab.location_id           location_id,
           hloc_hq_tl.location_code           location_name,
           to_char(p_dads_end_date,'YYYY')    cal_year,
           hoi_hq_estab.organization_id       hq_estab_id,
           substr(hoi_hq_estab.org_information2,
                  length(hoi_hq_estab.org_information2)-4, 5) NIC_HQ_estab,
           hloc_hq.address_line_2             hq_addr_complement,
           hloc_hq.address_line_1             hq_addr_nn_street,
           hloc_hq.region_2                   hq_addr_insee_code,
           hloc_hq.region_3                   hq_addr_town,
           hloc_hq.postal_code                hq_addr_zip_code,
           hloc_hq.town_or_city               hq_addr_town_city,/*
              (Afnor codes)                   hq_addr_country_code,*/
           ft_hq.nls_territory                hq_addr_country_name,
           hoi_fisc_estab.organization_id     fisc_estab_id,
           substr(hoi_fisc_estab.org_information2,
                  length(hoi_fisc_estab.org_information2)-4, 5) NIC_fisc_estab,
           hloc_fisc_estab.location_id        fisc_location_id,
           hloc_fisc_estab_tl.location_code   fisc_location_name,
           hou_fisc_estab_tl.name             name_fisc_estab,
           hloc_fisc_estab.address_line_2     fisc_addr_complement,
           hloc_fisc_estab.address_line_1     fisc_addr_nn_street,
           hloc_fisc_estab.region_2           fisc_addr_insee_code,
           hloc_fisc_estab.region_3           fisc_addr_town,
           hloc_fisc_estab.postal_code        fisc_addr_zip_code,
           hloc_fisc_estab.town_or_city       fisc_addr_town_city,/*
              (Afnor Codes)                   fisc_addr_country_code,*/
           ft_fisc_estab.nls_territory        fisc_addr_country_name,
           hoi_cre_estab.organization_id      cre_estab_id,
           hou_cre_estab_tl.name              cre_name,
           decode(hoi_comp.org_information17
                 ,p_cre_estab_id_chr,null
                 ,hoi_cre_comp.org_information1)  cre_siren,
           decode(hoi_comp.org_information17
                 ,p_cre_estab_id_chr,null
                 ,substr(hoi_cre_estab.org_information2
                        ,length(hoi_cre_estab.org_information2)-4, 5)) cre_nic,
           decode(hoi_comp.org_information17
                 ,p_cre_estab_id_chr,null
                 ,hoi_cre_dads.org_information1)  cre_media,
           decode(hoi_comp.org_information17
                 ,p_cre_estab_id_chr,null
                 ,hoi_cre_dads.org_information2)  addr_to_use,
           hoi_comp_pen_stmt.org_information1 pension_stmt_addr,
           hoi_comp_pen_stmt.org_information2 pension_stmt_sort1,
           hoi_comp_pen_stmt.org_information3 pension_stmt_sort2,
           'AOO'                              periodicity_code_test
    from hr_all_organization_units_tl     hou_comp_tl,
         hr_all_organization_units_tl     hou_hq_estab_tl,
         hr_all_organization_units_tl     hou_fisc_estab_tl,
         hr_all_organization_units_tl     hou_cre_estab_tl,
         hr_organization_information      hoi_comp,
         hr_organization_information      hoi_comp_pen_stmt,
         hr_organization_information      hoi_hq_estab,
         hr_organization_information      hoi_fisc_estab,
         hr_all_organization_units        hou_hq_estab,
         hr_all_organization_units        hou_fisc_estab,
         hr_locations_all                 hloc_hq,
         hr_locations_all                 hloc_fisc_estab,
         fnd_territories                  ft_hq,
         fnd_territories                  ft_fisc_estab,
         hr_locations_all_tl              hloc_hq_tl,
         hr_locations_all_tl              hloc_fisc_estab_tl,
         hr_organization_information      hoi_cre_estab,
         hr_organization_information      hoi_cre_comp,
         hr_organization_information      hoi_cre_dads
    where hou_comp_tl.organization_id = p_company_id
      and hou_comp_tl.language = userenv('LANG')
      and hoi_comp.organization_id = hou_comp_tl.organization_id
      and hoi_comp.org_information_context = 'FR_COMP_INFO'
      and hou_hq_estab.organization_id(+) = hoi_hq_estab.organization_id
      and hoi_hq_estab.organization_id(+) = hoi_comp.org_information5
      and hoi_hq_estab.org_information_context(+) = 'FR_ESTAB_INFO'
      and hloc_hq.location_id(+) = hou_hq_estab.location_id
      and hloc_hq.style(+) = 'FR'
      and ft_hq.territory_code(+) = hloc_hq.country
      and hloc_hq_tl.location_id(+) = hou_hq_estab.location_id
      and hloc_hq_tl.language(+) = userenv('LANG')
      and hou_hq_estab_tl.organization_id(+) = hou_hq_estab.organization_id
      and hou_hq_estab_tl.language(+) = userenv('LANG')
      and hou_fisc_estab.organization_id(+) = hoi_fisc_estab.organization_id
      and hoi_fisc_estab.organization_id(+) = hoi_comp.org_information16
      and hoi_fisc_estab.org_information_context(+) = 'FR_ESTAB_INFO'
      and hou_fisc_estab_tl.organization_id(+) = hou_fisc_estab.organization_id
      and hou_fisc_estab_tl.language(+) = userenv('LANG')
      and hloc_fisc_estab.location_id(+) = hou_fisc_estab.location_id
      and hloc_fisc_estab.style(+) = 'FR'
      and ft_fisc_estab.territory_code(+) = hloc_fisc_estab.country
      and hloc_fisc_estab_tl.location_id(+) = hou_fisc_estab.location_id
      and hloc_fisc_estab_tl.language(+) = userenv('LANG')
      and hoi_cre_estab.organization_id(+) = hoi_comp.org_information17
      and hoi_cre_estab.org_information_context(+) = 'FR_ESTAB_INFO'
      and hoi_cre_comp.organization_id(+) = hoi_cre_estab.org_information1
      and hoi_cre_comp.org_information_context(+) = 'FR_COMP_INFO'
      and hou_cre_estab_tl.organization_id(+) = hoi_cre_estab.organization_id
      and hou_cre_estab_tl.language(+) = userenv('LANG')
      and hoi_cre_dads.organization_id(+) = hoi_cre_estab.organization_id
      and hoi_cre_dads.org_information_context(+) = 'FR_DADS_CRE_INFO'
      and hoi_comp_pen_stmt.organization_id(+) = hou_comp_tl.organization_id
      and hoi_comp_pen_stmt.org_information_context(+) =
                                                   'FR_DADS_COMP_PENSION_STMT';
    --
  BEGIN
  /* Initialising the local variables */
  l_partition_number       := '11';
  l_currency_type          :='EUR';
  /* End of Initialising the local variables */

  --
    OPEN csr_S20_G01_00(p_company_id, to_char(p_cre_info_issue.cre_estab_id));
    FETCH csr_S20_G01_00 INTO l_siren_comp,
                              l_name_comp,
                              l_name_estab,
                              l_location,
			      l_location_name,
                              l_cal_year,
                              l_hq_estab_id,
                              l_NIC_HQ_estab,
                              l_hq_addr_complement,
                              l_hq_addr_nn_street,
                              l_hq_addr_insee_code,
                              l_hq_addr_town,
                              l_hq_addr_zip_code,
                              l_hq_addr_town_city,
                              l_hq_addr_country_name,
                              l_fisc_estab_id,
                              l_NIC_fisc_estab,
                              l_fisc_location,
			      l_fisc_location_name,
                              l_name_fisc_estab,
                              l_fisc_addr_complement,
                              l_fisc_addr_nn_street,
                              l_fisc_addr_insee_code,
                              l_fisc_addr_town,
                              l_fisc_addr_zip_code,
                              l_fisc_addr_town_city,
                              l_fisc_addr_country_name,
			      l_cre_estab_id,
			      l_cre_estab_name,
                              l_cre_siren,
                              l_cre_nic,
                              l_cre_media,
                              l_addr_to_use,
                              l_pension_stmt_addr,
                              l_pension_stmt_sort1,
                              l_pension_stmt_sort2,
                              l_periodicity_code_test;
    CLOSE  csr_S20_G01_00;
    -- Archive CRE estab name
    IF l_cre_estab_name IS NOT NULL THEN
      archive_report_data(
               p_payroll_action_id => p_payroll_action_id,
               p_section_name      => 'S20',
               p_sort_order        => 1,
               p_org_id            => p_company_id,
               p_cre_org_name      => l_cre_estab_name,
               p_report_code       => 'S10_CRE_ESTAB_NAME');
    END IF;
    -- if the fiscal and HQ establishments are same
    -- do not archive the address for the fiscal establishment
    IF l_fisc_estab_id = l_hq_estab_id THEN
       l_fisc_addr_complement := null;
       l_fisc_addr_nn_street := null;
       l_fisc_addr_insee_code :=null;
       l_fisc_addr_town := null;
       l_fisc_addr_zip_code := null;
       l_fisc_addr_town_city := null;
       l_fisc_addr_country_code := null;
       l_fisc_addr_country_name := null;
    END IF;
    -- Fetch periodicity code in case of live file
    IF (to_char(p_dads_start_date,'DD/MM') = '01/01' and to_char(p_dads_end_date,'DD/MM') = '31/12')
      OR (to_char(p_dads_start_date,'DD/MM') = '01/04' and to_char(p_dads_end_date,'DD/MM') = '31/03')
    THEN
       l_periodicity_code_live :='A00';
    ELSE
       l_periodicity_code_live :='EVE';
    END IF;
     -- Getting the error messages
    l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
    l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');
    -- SIREN Number
    IF l_siren_comp is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_comp, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.001'), null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_siren_comp
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    -- Name of Company
    IF l_name_comp is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.002'), null, null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_name_comp
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    -- Calendar Year
    IF l_cal_year is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.003'), null, null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.003'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_cal_year
     ,p_message_text      => l_value
     ,p_usage             => 'M');

    -- The values comes from the concurrent process.
    -- Passing in a null value to the archive and
    -- removing the exception validation
    -- Declaration Nature Code
    /*IF l_decl_nature_code is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.001'), null, null);
       ELSE
         l_error_type := null;
         l_value := null;
    END IF;*/
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.004.001'
     ,p_message_type      => null
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => null
     ,p_message_text      => null
     ,p_usage             => 'M');

    -- Declaration Type Code
    /*IF l_decl_type_code is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.002'), null, null);
    ELSIF (l_decl_nature_code = '02' OR l_decl_nature_code = '01') AND
           l_decl_type_code = '55' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.001'),
         'VALUE2:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.002'), null);
    ELSIF l_decl_nature_code = '05' AND l_decl_type_code <> '55' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.001'),
         'VALUE2:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.004.002'), null);
    ELSE
         l_error_type := null;
         l_value := null;
    END IF;*/
    /* Adding dummy error message and error_type as ERROR,
    inorder to retrieve the rubric in Exceptions Report */
    l_error_type := l_error;
    l_value := 'Dummy Error Message';
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.004.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => null
     ,p_message_text      => l_value
     ,p_usage             =>'M');

    -- Partition Number
    IF l_partition_number is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.005'), null, null);
       ELSE
         l_error_type := null;
         l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.005'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_PARTITION_NUMBER'
     ,p_file_value        => l_partition_number
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    /* The value is based upon the Declaration type code.  Hence it should also
    be written where declaration type codes are being archived
    -- Calendar Year to which salaries are attached
    IF (l_cal_year_sal is null AND
                         (l_decl_type_code = 52 OR l_decl_type_code = 53)) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.003'), null, null);
    ELSIF ((l_decl_type_code <> 52 AND l_decl_type_code <> 53) AND
                                     l_cal_year_sal is not null) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75183_RBR_SUPP',
         null, null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;*/
    -- Archiving the value of the calendar year for
    -- the item 'Calendar year to which salaries are attached'
    -- to be retrieved conditionallly as per declaration type
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.006'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_cal_year
     ,p_message_text      => l_value
     ,p_usage             => 'C');

    -- Currency Type
    IF l_currency_type is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         'VALUE1:'||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.007'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.007'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_currency_type
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    -- NIC of Headquarters Establishment
    IF l_hq_estab_id is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_comp, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.008.M'), null);
    ELSIF l_NIC_HQ_estab is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_estab, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.008'), null);
    ELSE
       l_error_type:=NULL;
       l_value:=NULL;
    end if;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.008'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_NIC_HQ_estab
     ,p_message_text      => l_value
     ,p_extra_information => l_name_estab -- to store name of hq estab
     ,p_usage             => 'M');
    IF l_location is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_estab, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.009.006.M'), null);
       archive_data(
                p_payroll_action_id => p_payroll_action_id
                ,p_rubric_name       => 'S20.G01.00.009.006'
                ,p_message_type      => l_error_type
                ,p_org_id            => p_company_id
                ,p_lookup_type       => null
                ,p_file_value        => l_hq_addr_nn_street
                ,p_message_text      => l_value
                ,p_usage             => 'C');
       -- Archive the remaining mandatory rubrics, i.e. zip code and town_or_city
       -- Archive zip code with null error and value
       archive_data(
       p_payroll_action_id => p_payroll_action_id
      ,p_rubric_name       => 'S20.G01.00.009.010'
      ,p_message_type      => null
      ,p_org_id            => p_company_id
      ,p_lookup_type       => null
      ,p_file_value        => null
      ,p_message_text      => null
      ,p_usage             => 'M');
       -- Archive town_or_city with null error and value
       archive_data(
        p_payroll_action_id => p_payroll_action_id
       ,p_rubric_name       => 'S20.G01.00.009.012'
       ,p_message_type      => null
       ,p_org_id            => p_company_id
       ,p_lookup_type       => null
       ,p_file_value        => null
       ,p_message_text      => null
       ,p_usage             => 'M');
       --
    ELSE
     --Address Complement
     l_error_type:=NULL;
     l_value:=NULL;
      archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_complement
     ,p_message_text      => l_value
     ,p_usage             => 'O');
    -- Nature and Name of the Street
    IF l_hq_addr_nn_street is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.009.006'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.006'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_nn_street
     ,p_message_text      => l_value
     ,p_usage             => 'C');
    -- Insee code of the town
    l_error_type:=NULL;
    l_value:=NULL;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.007'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_insee_code
     ,p_message_text      => l_value
     ,p_usage             => 'O');
    -- Name of the Town
    IF upper(l_hq_addr_town) = upper(l_hq_addr_town_city) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
         null, null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.009'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_town
     ,p_message_text      => l_value
     ,p_usage             => 'C');
    -- Zip Code
    IF l_hq_addr_zip_code is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.009.010'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.010'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_zip_code
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    -- City
    IF l_hq_addr_town_city <> upper(l_hq_addr_town_city) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
         null, null, null);
    ELSIF l_hq_addr_town_city is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.009.012'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.012'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_town_city
     ,p_message_text      => l_value
     ,p_usage             => 'M');

    /* Afnor Codes
    -- Country Code
    IF l_hq_addr_country_code = 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
         'VALUE1: '||hr_general.decode_lookup
	  ('FR_DADS_RUBRICS','S20.G01.00.009.013'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.013'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_country_code
     ,p_message_text      => l_value
     ,p_usage             =>);     */

    -- Country Name
    IF l_hq_addr_country_name is not null and l_hq_addr_country_name = 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
         'VALUE1: '||hr_general.decode_lookup
	  ('FR_DADS_RUBRICS','S20.G01.00.009.014'), null, null);
    ELSIF l_hq_addr_country_name is null AND
        (l_hq_addr_country_code is not null AND l_hq_addr_country_code
         <> 'FR') THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
             'VALUE1: '||hr_general.decode_lookup
             ('FR_DADS_RUBRICS','S20.G01.00.009.014'), null, null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.009.014'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_hq_addr_country_name
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  end if;-- check for location
 -- SIRET of Fiscal Establishment
  IF l_name_fisc_estab is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_comp, 'VALUE2: '||hr_general.decode_lookup
         ('FR_DADS_RUBRICS','S20.G01.00.010.M'), null);
        archive_data(
            p_payroll_action_id => p_payroll_action_id
            ,p_rubric_name       => 'S20.G01.00.010'
            ,p_message_type      => l_error_type
            ,p_org_id            => p_company_id
            ,p_lookup_type       => null
            ,p_file_value        => l_NIC_fisc_estab
            ,p_message_text      => l_value
            ,p_usage             => 'M');
        -- GO TO S20.G01.00.014.001
   ELSE
     -- NIC of the Fiscal Establishment
     IF l_fisc_estab_id <> l_hq_estab_id and l_NIC_fisc_estab is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_fisc_estab, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.010'), null);
     elsif l_fisc_estab_id = l_hq_estab_id and l_NIC_fisc_estab is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
       'S20.G01.00.010'), null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     end if;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.010'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_NIC_fisc_estab
     ,p_message_text      => l_value
     ,p_usage             => 'M');

      --Fiscal Establishment Name
      IF l_fisc_estab_id = l_hq_estab_id AND l_name_fisc_estab is not null THEN
         l_error_type := l_error;
            l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
	    'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
	    'S20.G01.00.011'), null, null);
      ELSE
         l_error_type := null;
         l_value := null;
      END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.011'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_name_fisc_estab
     ,p_message_text      => l_value
     ,p_usage             => 'C');

  -- Location
  IF l_fisc_location is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
     'VALUE1:'||l_name_fisc_estab, 'VALUE2: '||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S20.G01.00.012.006.M'), null);
     archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.006'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_nn_street
     ,p_message_text      => l_value
     ,p_usage             => 'C');
     -- Archive mandatory rubrics
     -- Zip code
     archive_data(
           p_payroll_action_id => p_payroll_action_id
          ,p_rubric_name       => 'S20.G01.00.012.010'
          ,p_message_type      => null
          ,p_org_id            => p_company_id
          ,p_lookup_type       => null
          ,p_file_value        => null
          ,p_message_text      => null
          ,p_usage             => 'M');
     -- town or city
     archive_data(
           p_payroll_action_id => p_payroll_action_id
          ,p_rubric_name       => 'S20.G01.00.012.012'
          ,p_message_type      => null
          ,p_org_id            => p_company_id
          ,p_lookup_type       => null
          ,p_file_value        => null
          ,p_message_text      => null
          ,p_usage             => 'M');
     --
  ELSE  -- Location is not null

    --Address Complement
    l_error_type:=NULL;
    l_value:=NULL;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_complement
     ,p_message_text      => l_value
     ,p_usage             => 'O');

   -- Nature and name of the street
   IF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_nn_street is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_fisc_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.012.006'), null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_nn_street is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
       'S20.G01.00.012.006'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.006'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_nn_street
     ,p_message_text      => l_value
     ,p_usage             => 'C');

    --insee code
     l_error_type := null;
      l_value := null;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.007'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_insee_code
     ,p_message_text      => l_value
     ,p_usage             => 'O');

    -- Name of the Town
    IF l_fisc_estab_id <> l_hq_estab_id AND upper(l_fisc_addr_town) = upper(l_fisc_addr_town_city) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
         null, null, null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_town is not null THEN
         l_error_type := l_error;
         l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
	 'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
	 'S20.G01.00.012.009'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.009'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_town
     ,p_message_text      => l_value
     ,p_usage             => 'C');

    --Zip Code
    IF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_zip_code is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_fisc_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.012.010'), null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_zip_code is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
       'S20.G01.00.012.010'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.010'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_zip_code
     ,p_message_text      => l_value
     ,p_usage             => 'M');

    --City
    IF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_town is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_fisc_location_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.012.012'), null);
    ELSIF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_town_city <> upper(l_fisc_addr_town_city) THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
         null, null, null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_town_city is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
       'S20.G01.00.012.012'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.012'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_town_city
     ,p_message_text      => l_value
     ,p_usage             => 'M');
    /* Afnors Code
    -- Country Code

    IF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_country_code = 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
       'VALUE1: '||hr_general.decode_lookup
       ('FR_DADS_RUBRICS','S20.G01.00.012.013'), null, null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_country_code is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
       'S20.G01.00.012.013'), null, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.013'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_country_code
     ,p_message_text      => l_value
     ,p_usage             =>);
    */
    -- Country Name
    IF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_country_name is not null
          AND l_fisc_addr_country_code = 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
       'VALUE1: '||hr_general.decode_lookup
       ('FR_DADS_RUBRICS','S20.G01.00.012.014'), null, null);
    ELSIF l_fisc_estab_id <> l_hq_estab_id AND l_fisc_addr_country_name is null AND
        (l_fisc_addr_country_code is not null AND l_fisc_addr_country_code
         <> 'FR') THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
             'VALUE1: '||hr_general.decode_lookup
             ('FR_DADS_RUBRICS','S20.G01.00.012.014'), null, null);
    ELSIF l_fisc_estab_id = l_hq_estab_id AND l_fisc_addr_country_name is not null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75185_COUN_EST',
       'VALUE1: '||hr_general.decode_lookup
       ('FR_DADS_RUBRICS','S20.G01.00.012.014'), null, null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
   archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.012.014'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_fisc_addr_country_name
     ,p_message_text      => l_value
     ,p_usage             => 'C');
   END IF;--check for location of fiscal establishment
  END IF;--for skipping to s20.G01.00.014.001

  -- SIREN, NIC, Type of Media, Address for CRE
  IF l_cre_estab_id is not null and  l_cre_estab_id <> g_cre_info_issue.cre_estab_id THEN
     IF l_cre_siren is NULL then
       l_error_type:= l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_name_comp, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.014.001'), null);
     else
        l_error_type:=NULL;
         l_value :=NULL;
     end if;
     archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.014.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_cre_siren
     ,p_message_text      => l_value
     ,p_usage             => 'C');

     IF l_cre_nic is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_cre_estab_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.014.002'), null);
     else
       l_error_type:=NULL;
         l_value  :=NULL;
     END IF;
      archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.014.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_cre_nic
     ,p_message_text      => l_value
     ,p_usage             => 'C');

      IF l_cre_media is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_cre_estab_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.015'), null);
      else
       l_error_type := NULL;
       l_value :=NULL;
     end if;
     archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.015'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_CRE_TYPE_MEDIA'
     ,p_file_value        => l_cre_media
     ,p_message_text      => l_value
     ,p_usage             => 'C');
     IF l_addr_to_use is null and l_cre_media='03' THEN
       l_error_type:= l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
         'VALUE1:'||l_cre_estab_name, 'VALUE2: '||hr_general.decode_lookup
           ('FR_DADS_RUBRICS','S20.G01.00.016'), null);
      elsif l_cre_media ='05' and l_addr_to_use is NOT NULL then
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75184_CRE_DATA',
           null, null, null);
     ELSE
       l_error_type := null;
       l_value := null;
     END IF;
   archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.016'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => l_addr_to_use
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  ELSIF l_cre_siren is null AND l_cre_nic is  null AND l_cre_media is null
                                             AND l_addr_to_use is null THEN
    IF g_cre_info_issue.cre_siren is null AND g_cre_info_issue.cre_nic is null
      AND g_cre_info_issue.cre_media is null AND g_cre_info_issue.address_to_use is null THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75186_CRE_DET',
           null, null, null);
     archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.014.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => g_cre_info_issue.cre_siren
     ,p_message_text      => l_value
     ,p_usage             => 'C');
   END IF;
  ELSIF l_cre_siren is not null AND l_cre_nic is not null AND l_cre_media is not null
                                             AND l_addr_to_use is not null then
    IF l_cre_estab_id = g_cre_info_issue.cre_estab_id THEN
           l_error_type := l_error;
           l_value := pay_fr_general.get_payroll_message('PAY_75182_CRE_S10',
                 null, null, null);
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.014.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => null
     ,p_file_value        => null
     ,p_message_text      => l_value
     ,p_usage             => 'C');
    END IF;
 end if;
  l_error_type:=NULL;
  l_value:=NULL;
  archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.017.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_COMP_PENSION_ADDR'
     ,p_file_value        => l_pension_stmt_addr
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.017.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_SORT_ORDER'
     ,p_file_value        => l_pension_stmt_sort1
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.017.003'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_SORT_ORDER'
     ,p_file_value        => l_pension_stmt_sort2
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  -- Test Periodicity Code
  IF l_periodicity_code_test is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
       'VALUE1:'||hr_general.decode_lookup
         ('FR_DADS_RUBRICS','S20.G01.00.018'), null, null);
  ELSE
    l_error_type := null;
    l_value := null;
  END IF;
  archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.018'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_PERIOD_CODE'
     ,p_file_value        => l_periodicity_code_test
     ,p_message_text      => l_value
     ,p_extra_information => '01' -- extra info for retrieving
     ,p_usage             => 'M');
  -- Live Periodicity Code
  IF l_periodicity_code_live is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
       'VALUE1:'||hr_general.decode_lookup
         ('FR_DADS_RUBRICS','S20.G01.00.018'), null, null);
  ELSE
    l_error_type := null;
    l_value := null;
  END IF;
  archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S20.G01.00.018'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_company_id
     ,p_lookup_type       => 'FR_DADS_PERIOD_CODE'
     ,p_file_value        => l_periodicity_code_live
     ,p_message_text      => l_value
     ,p_extra_information => '02' -- extra info for retrieving
     ,p_usage             => 'M');
   --
   EXCEPTION
      WHEN OTHERS THEN raise;
   --
  END S20_comp_info;
  --
  -----------------------------------------------------------------------------------
    --        INSEE ESTABLISHMENT INFORMATION PROCEDURE
  -----------------------------------------------------------------------------------
  PROCEDURE S80_insee_estab (p_estab_id          IN NUMBER,
                             p_payroll_action_id IN NUMBER,
                             p_dads_end_date     IN DATE)
  IS
  --
    l_effective_date          Date;
    l_estab_siren             hr_organization_information.org_information1%TYPE ;
    l_estab_nic               varchar2(7) ;
    l_estab_name              hr_all_organization_units_tl.name%TYPE ;
    l_estab_addr_complement   hr_locations_all.address_line_2%TYPE ;
    l_estab_addr_nn_street    hr_locations_all.address_line_1%TYPE ;
    l_estab_addr_insee_code   hr_locations_all.region_2%TYPE ;
    l_estab_addr_town         hr_locations_all.region_3%TYPE ;
    l_estab_addr_zip_code     hr_locations_all.postal_code%TYPE ;
    l_estab_addr_town_city    hr_locations_all.town_or_city%TYPE ;
    l_estab_addr_country_code varchar2(30) ;
    l_estab_addr_country_name fnd_territories.nls_territory%TYPE ;
    l_estab_headcount_3112    number ;
    l_estab_salary_tax_code   hr_organization_information.org_information3%TYPE ;
    l_assg_action_id          number;
    l_value                   fnd_new_messages.message_text%type;
    l_error_type              hr_lookups.meaning%type;
    l_error                   hr_lookups.meaning%type;
    l_warning                 hr_lookups.meaning%type;
    l_estab_location          hr_all_organization_units.location_id%TYPE;
    l_location_name           hr_locations_all_tl.location_code%TYPE;
    l_name_comp               hr_all_organization_units_tl.name%TYPE  ;
    --
    -- Cursor for s80 data
    cursor csr_S80_G01_00 is
    select hoi_estab_comp.org_information1    SIREN_estab,
           substr (hoi_estab.org_information2, length(hoi_estab.org_information2)-4,5)  NIC_estab,
           hou_estab_tl.name                  name_estab,
	   hoi_estab_comp_tl.name            company_name,
	   hou_estab.location_id              location_id,
	   hloc_estab_tl.location_code        location_name,
           --
           hloc_estab.address_line_2          addr_compl_estab,
           hloc_estab.address_line_1          addr_nstreet_estab,
           hloc_estab.region_2                addr_insee_estab,
           hloc_estab.region_3                addr_town_estab,
           hloc_estab.postal_code             addr_zip_estab,
           hloc_estab.town_or_city            addr_towncity_estab,
           -- (Afnor codes)                   addr_cntrycode_estab ,
           ft_estab.nls_territory             addr_cntryname_estab,
           --
           decode(hoi_sal_tax.org_information3,null, '02', '100', '02', '01') estab_salary_tax_code
           --
    from hr_all_organization_units     hou_estab,
         hr_all_organization_units_tl  hou_estab_tl,
         hr_organization_information   hoi_estab,
         hr_organization_information   hoi_estab_comp,
         hr_all_organization_units_tl  hoi_estab_comp_tl,
         --
         hr_locations_all              hloc_estab,
	 hr_locations_all_tl           hloc_estab_tl,
	 fnd_territories               ft_estab,
         --
         hr_organization_information   hoi_sal_tax
         --
    where hou_estab.organization_id = p_estab_id
      and hou_estab_tl.organization_id = hou_estab.organization_id
      and hou_estab_tl.language = userenv('LANG')
      --
      and hoi_estab_comp_tl.organization_id(+) = hoi_estab_comp.organization_id
      and hoi_estab_comp_tl.language(+) = userenv('LANG')
      --
      and hoi_estab.organization_id(+) = hou_estab_tl.organization_id
      and hoi_estab.org_information_context(+) = 'FR_ESTAB_INFO'
      and hoi_estab_comp.organization_id(+) = hoi_estab.org_information1
      and hoi_estab_comp.org_information_context(+) = 'FR_COMP_INFO'
      --
      and hloc_estab.location_id(+) = hou_estab.location_id
      and hloc_estab.style(+) ='FR'
      --
      and ft_estab.territory_code(+) = hloc_estab.country
      --
      and hloc_estab_tl.location_id(+) = hloc_estab.location_id
      and hloc_estab_tl.language(+) = userenv('LANG')
      --
      and hoi_sal_tax.organization_id(+) = hou_estab.organization_id
      and hoi_sal_tax.org_information_context(+) = 'FR_ESTAB_SALARY_TAX_LIABILITY';
      --
    -- Cursor for headcount for 'active' employees
    -- Get all employees with their categories and
    -- part-time percentage as archived for S41
    Cursor csr_emp_headcount(c_effective_date DATE) IS
    Select pai_part.action_information4 part_pct
          from pay_action_information pai_part,
               pay_assignment_actions pasac,
               per_all_assignments_f  pasg
         where pai_part.action_information_category = 'FR_DADS_FILE_DATA'
           and pai_part.action_context_id = pasac.assignment_action_id
           and pai_part.action_context_type = 'AAP'
           and pai_part.action_information1 ='S41.G01.00.020'
           and pai_part.action_information8 = (Select max(pai_sub.action_information8)
	                                       from pay_action_information pai_sub
	                                       where pai_sub.action_information_category = 'FR_DADS_FILE_DATA'
	                                       and pai_sub.action_context_type = 'AAP'
	                                       and pai_sub.action_context_id = pasac.assignment_action_id
                                               and pai_sub.action_information1 ='S41.G01.00.020')
           and pasg.establishment_id = p_estab_id
           and c_effective_date between
                    pasg.effective_start_date and pasg.effective_end_date
           and pasg.assignment_id = pasac.assignment_id
           and pasac.payroll_action_id = p_payroll_action_id;
     --
  begin
  /* Initialising the local variables */
  l_estab_headcount_3112    :=0 ;
  /* End of Initialising the local variables */

  --
    l_effective_date := to_date('31-12-'||to_char(p_dads_end_date, 'YYYY'), 'DD-MM-YYYY');
    --
    OPEN csr_S80_G01_00;
    FETCH csr_S80_G01_00 INTO l_estab_siren,
                          l_estab_nic,
                          l_estab_name ,
			  l_name_comp,
			  l_estab_location,
			  l_location_name,
                          l_estab_addr_complement,
                          l_estab_addr_nn_street,
                          l_estab_addr_insee_code,
                          l_estab_addr_town,
                          l_estab_addr_zip_code,
                          l_estab_addr_town_city ,
                          l_estab_addr_country_name ,
                          l_estab_salary_tax_code;
    CLOSE csr_S80_G01_00;
    --
    -- Calculate headcount as on 31/12
    FOR emp_count_rec IN csr_emp_headcount(l_effective_date) LOOP
      IF emp_count_rec.part_pct IS NOT NULL THEN
        -- Add the percentage of part-time
	-- as obtained from the data archived for S41
        l_estab_headcount_3112 := l_estab_headcount_3112 + emp_count_rec.part_pct/10000;
      ELSE
        -- consider them full time employees and increment by 1
        l_estab_headcount_3112 := l_estab_headcount_3112 +1;
      END IF;
    END LOOP;
-- Validation for S80
   -- Getting the error messages
   l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
   l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');
  -- SIREN Number
  IF l_estab_siren is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
     'VALUE1:'||l_name_comp, 'VALUE2:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S80.G01.00.001.001'), null);
   ELSE
     l_error_type := null;
     l_value := null;
   END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S80.G01.00.001.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_estab_id
     ,p_lookup_type       => null
     ,p_file_value        => l_estab_siren
     ,p_message_text      => l_value
     ,p_usage             => 'M');
  --NIC of the Establishment
  IF l_estab_nic is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
     'VALUE1:'||l_estab_name, 'VALUE2:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S80.G01.00.001.002'), null);
  ELSE
     l_error_type := null;
     l_value := null;
  END IF;
    archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S80.G01.00.001.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_estab_id
     ,p_lookup_type       => null
     ,p_file_value        => l_estab_nic
     ,p_message_text      => l_value
     ,p_usage             => 'M');
   --Establishment Name
   l_error_type := null;
   l_value := null;
   archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S80.G01.00.002'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_estab_id
     ,p_lookup_type       => null
     ,p_file_value        => l_estab_name
     ,p_message_text      => l_value
     ,p_usage             => 'C');
  --First Check Location
  IF l_estab_location is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
     'VALUE1:'||l_estab_name, 'VALUE2: '||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S80.G01.00.003.006.M'), null);
       archive_data(
	    	p_payroll_action_id => p_payroll_action_id
	    	,p_rubric_name       => 'S80.G01.00.003.006'
	    	,p_message_type      => l_error_type
	    	,p_org_id            => p_estab_id
	    	,p_lookup_type       => null
	    	,p_file_value        => l_estab_addr_nn_street
	        ,p_message_text      => l_value
	        ,p_usage             => 'C');
     -- Archive mandatory rubrics
     -- Zip code
     archive_data(
           p_payroll_action_id => p_payroll_action_id
          ,p_rubric_name       => 'S80.G01.00.003.010'
          ,p_message_type      => null
          ,p_org_id            => p_estab_id
          ,p_lookup_type       => null
          ,p_file_value        => null
          ,p_message_text      => null
          ,p_usage             => 'M');
     -- town or city
     archive_data(
           p_payroll_action_id => p_payroll_action_id
          ,p_rubric_name       => 'S80.G01.00.003.012'
          ,p_message_type      => null
          ,p_org_id            => p_estab_id
          ,p_lookup_type       => null
          ,p_file_value        => null
          ,p_message_text      => null
          ,p_usage             => 'M');
     --
  ELSE
     --Address Complement
     l_error_type:=NULL;
     l_value:=NULL;
      archive_data(
      p_payroll_action_id => p_payroll_action_id
     ,p_rubric_name       => 'S80.G01.00.003.001'
     ,p_message_type      => l_error_type
     ,p_org_id            => p_estab_id
     ,p_lookup_type       => null
     ,p_file_value        => l_estab_addr_complement
     ,p_message_text      => l_value
     ,p_usage             => 'O');
     -- Nature and Name of the Street
     IF l_estab_addr_nn_street is null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
	'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S80.G01.00.003.006'), null);
     ELSE
       l_error_type := null;
       l_value := null;
     END IF;
       archive_data(
         p_payroll_action_id => p_payroll_action_id
        ,p_rubric_name       => 'S80.G01.00.003.006'
        ,p_message_type      => l_error_type
        ,p_org_id            => p_estab_id
        ,p_lookup_type       => null
        ,p_file_value        => l_estab_addr_nn_street
        ,p_message_text      => l_value
        ,p_usage             => 'C');
      -- Insee code of the town
         l_error_type:=NULL;
         l_value:=NULL;
         archive_data(
           p_payroll_action_id => p_payroll_action_id
           ,p_rubric_name       => 'S80.G01.00.003.007'
           ,p_message_type      => l_error_type
           ,p_org_id            => p_estab_id
           ,p_lookup_type       => null
           ,p_file_value        => l_estab_addr_insee_code
           ,p_message_text      => l_value
           ,p_usage             => 'O');
       -- Name of the Town
       IF upper(l_estab_addr_town) = upper(l_estab_addr_town_city) THEN
          l_error_type := l_error;
	  l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
          null, null, null);
       ELSE
          l_error_type := null;
          l_value := null;
       END IF;
          archive_data(
             p_payroll_action_id => p_payroll_action_id
             ,p_rubric_name       => 'S80.G01.00.003.009'
             ,p_message_type      => l_error_type
             ,p_org_id            => p_estab_id
             ,p_lookup_type       => null
             ,p_file_value        => l_estab_addr_town
             ,p_message_text      => l_value
             ,p_usage             => 'C');
       -- Zip Code
       IF l_estab_addr_zip_code is null THEN
          l_error_type := l_error;
          l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
            'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
            ('FR_DADS_RUBRICS','S80.G01.00.003.010'), null);
       ELSE
          l_error_type := null;
          l_value := null;
       END IF;
          archive_data(
            p_payroll_action_id => p_payroll_action_id
           ,p_rubric_name       => 'S80.G01.00.003.010'
           ,p_message_type      => l_error_type
           ,p_org_id            => p_estab_id
           ,p_lookup_type       => null
           ,p_file_value        => l_estab_addr_zip_code
           ,p_message_text      => l_value
           ,p_usage             => 'M');
       -- City
       IF l_estab_addr_town_city <> upper(l_estab_addr_town_city) THEN
          l_error_type := l_error;
	  l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
	  null, null, null);
       ELSIF l_estab_addr_town_city is null THEN
          l_error_type := l_error;
	  l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
	  'VALUE1:'||l_location_name, 'VALUE2: '||hr_general.decode_lookup
	  ('FR_DADS_RUBRICS','S80.G01.00.003.012'), null);
       ELSE
          l_error_type := null;
          l_value := null;
       END IF;
          archive_data(
            p_payroll_action_id => p_payroll_action_id
           ,p_rubric_name       => 'S80.G01.00.003.012'
           ,p_message_type      => l_error_type
           ,p_org_id            => p_estab_id
           ,p_lookup_type       => null
           ,p_file_value        => l_estab_addr_town_city
           ,p_message_text      => l_value
           ,p_usage             => 'M');
     /* Afnor Codes
     -- Country Code
     IF l_estab_addr_country_name = 'FR' THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
	'VALUE1: '||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S80.G01.00.003.013'), null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;
        archive_data(
          p_payroll_action_id => p_payroll_action_id
         ,p_rubric_name       => 'S80.G01.00.003.013'
         ,p_message_type      => l_error_type
         ,p_org_id            => p_estab_id
         ,p_lookup_type       => null
         ,p_file_value        => l_estab_addr_country_code
         ,p_message_text      => l_value
         ,p_usage             =>);     */
    -- Country Name
    IF l_estab_addr_country_name is not null and l_estab_addr_country_code = 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
                         'VALUE1: '||hr_general.decode_lookup
                        ('FR_DADS_RUBRICS','S80.G01.00.003.014'), null, null);
    ELSIF l_estab_addr_country_name is null AND l_estab_addr_country_code is not null
          AND l_estab_addr_country_code <> 'FR' THEN
       l_error_type := l_error;
       l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
                        'VALUE1:'||hr_general.decode_lookup
                        ('FR_DADS_RUBRICS','S80.G01.00.003.014'), null, null);
    ELSE
       l_error_type := null;
       l_value := null;
    END IF;
      archive_data(
        p_payroll_action_id => p_payroll_action_id
       ,p_rubric_name       => 'S80.G01.00.003.014'
       ,p_message_type      => l_error_type
       ,p_org_id            => p_estab_id
       ,p_lookup_type       => null
       ,p_file_value        => l_estab_addr_country_name
       ,p_message_text      => l_value
       ,p_usage             => 'C');
  END IF; -- Checking Location
  -- Head Count
  IF l_estab_headcount_3112 is null then
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
     'S80.G01.00.004'), null, null);
  ELSE
     l_error_type := null;
     l_value := null;
  END IF;
     archive_data(
       p_payroll_action_id => p_payroll_action_id
      ,p_rubric_name       => 'S80.G01.00.004'
      ,p_message_type      => l_error_type
      ,p_org_id            => p_estab_id
      ,p_lookup_type       => null
      ,p_file_value        => l_estab_headcount_3112
      ,p_message_text      => l_value
      ,p_usage             => 'M');
  -- Code Salary Tax
  IF l_estab_salary_tax_code is null then
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
     'S80.G01.00.005'), null, null);
  ELSIF l_estab_salary_tax_code <> '01' AND l_estab_salary_tax_code <> '02'
        AND l_estab_salary_tax_code is not null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
     'VALUE1: '||l_estab_name, 'VALUE2:'||hr_general.decode_lookup ('FR_DADS_RUBRICS',
     'S80.G01.00.005.M'), null);
  ELSE
     l_error_type := null;
     l_value := null;
  END IF;
     archive_data(
       p_payroll_action_id => p_payroll_action_id
      ,p_rubric_name       => 'S80.G01.00.005'
      ,p_message_type      => l_error_type
      ,p_org_id            => p_estab_id
      ,p_lookup_type       => 'FR_DADS_SAL_TAX_CODE'
      ,p_file_value        => l_estab_salary_tax_code
      ,p_message_text      => l_value
      ,p_usage             => 'M');
    --
    EXCEPTION
      WHEN OTHERS THEN raise;
    --
  END S80_insee_estab;
  --------------------------------------------------------------------------------------------
END;

/
