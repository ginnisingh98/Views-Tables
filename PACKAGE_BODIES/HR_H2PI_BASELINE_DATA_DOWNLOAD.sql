--------------------------------------------------------
--  DDL for Package Body HR_H2PI_BASELINE_DATA_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_BASELINE_DATA_DOWNLOAD" AS
/* $Header: hrh2pipd.pkb 120.0 2005/05/31 00:40:58 appldev noship $ */

g_package  VARCHAR2(80)  := '   hr_h2pi_baseline_data_download.';
--
-- --------------------------------------------------------------------------------
-- Description: Procedure to download data from the H2PI views into a XML file
--
-- --------------------------------------------------------------------------------
--
    procedure download ( p_errbuf              OUT NOCOPY VARCHAR2,
                         p_retcode             OUT NOCOPY NUMBER,
                         p_business_group_id   IN  NUMBER,
                         p_client_id           IN  NUMBER) IS

        queryCtx      DBMS_XMLQuery.ctxType;
        xmlString1    CLOB := NULL;

        xmlString2    CLOB := NULL;
        dtdString     CLOB := NULL;
        --
        x varchar2(10000);
        y number(20);
        --
        l_request_id   NUMBER(15);
        lengthtoread   NUMBER(10);
        cloblength     NUMBER(20);
        l_query_string varchar2(10000);
        l_proc         varchar2(72) := g_package || 'download' ;
        l_xml_header   varchar2(80) := '<?xml version = ''1.0''?>';

    BEGIN
      hr_utility.set_location('Entering:'  || l_proc,10);

      l_request_id := hr_h2pi_download.get_request_id;

      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_EMPLOYEES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ADDRESSES/>');
      fnd_file.put_line(fnd_file.output,'');
      --
      -- For HR_H2PI_LOCATIONS_V VIEW
      --
      hr_utility.set_location(l_proc,60);
      l_query_string := 'select ' ||
                        '  last_upd_date,' ||
                        TO_CHAR(p_business_group_id)||'  business_group_id,'||
                        ' location_id, ' ||
                        ' location_code, ' ||
                        ' description, ' ||
                        ' address_line_1,' ||
                        ' address_line_2, ' ||
                        ' address_line_3, ' ||
                        ' town_or_city, ' ||
                        ' country, ' ||
                        ' postal_code, ' ||
                        ' region_1, ' ||
                        ' region_2, ' ||
                        ' region_3, ' ||
                        ' style, ' ||
                        ' inactive_date, ' ||
                        ' telephone_number_1, ' ||
                        ' telephone_number_2, ' ||
                        ' telephone_number_3, ' ||
                        ' loc_information13, ' ||
                        ' loc_information14, ' ||
                        ' loc_information15, ' ||
                        ' loc_information16, ' ||
                        ' loc_information17, ' ||
                        ' loc_information18, ' ||
                        ' loc_information19, ' ||
                        ' loc_information20, ' ||
                        ' attribute_category, ' ||
                        ' attribute1, ' ||
                        ' attribute2, ' ||
                        ' attribute3, ' ||
                        ' attribute4, ' ||
                        ' attribute5, ' ||
                        ' attribute6, ' ||
                        ' attribute7, ' ||
                        ' attribute8, ' ||
                        ' attribute9, ' ||
                        ' attribute10, ' ||
                        ' attribute11, ' ||
                        ' attribute12, ' ||
                        ' attribute13, ' ||
                        ' attribute14, ' ||
                        ' attribute15, ' ||
                        ' attribute16, ' ||
                        ' attribute17, ' ||
                        ' attribute18, ' ||
                        ' attribute19, ' ||
                        ' attribute20, ' ||
                        ' :q_client_id client_id ' ||
         ' from hr_h2pi_locations_v ' ||
         ' where ( business_group_id = :q_bg_id OR business_group_id is null)';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_LOCATIONS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,70);
      --

      --
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ASSIGNMENTS/>');
      fnd_file.put_line(fnd_file.output,'');

      -- Following is for Baseline data

      --
      -- For HR_H2PI_PAY_BASES_V VIEW
      --
      hr_utility.set_location(l_proc,100);
      queryCtx := DBMS_XMLQuery.newContext('select pay.*,:q_client_id client_id ' ||
                  ' from hr_h2pi_pay_bases_v pay ' ||
                  ' where business_group_id =  :q_bg_id ' );
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PAY_BASES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,110);
      --

      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_HR_ORGANIZATIONS/>');
      fnd_file.put_line(fnd_file.output,'');
      --
      -- For HR_H2PI_PAYROLLS_V VIEW
      --
      hr_utility.set_location(l_proc,140);
      queryCtx := DBMS_XMLQuery.newContext('select pay.*,:q_client_id client_id from hr_h2pi_payrolls_v pay where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PAYROLLS');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,150);
      --

      --
      -- For HR_H2PI_ELEMENT_TYPES_V VIEW
      --
      hr_utility.set_location(l_proc,160);
      queryCtx := DBMS_XMLQuery.newContext(
                  'select last_upd_date, element_type_id, ' ||
                  ' business_group_id, ' ||
                  ' element_name, processing_type, ' ||
                  ' effective_start_date, effective_end_date, ' ||
                  ' :q_client_id client_id, ' ||
                  ' legislation_code ' ||
                  ' from hr_h2pi_element_types_v ' ||
                  ' where business_group_id = :q_bg_id ' ||
                  ' union select et1.last_update_date, et1.element_type_id, ' ||
                  TO_CHAR(p_business_group_id) ||
                  ', et1.element_name, et1.processing_type, ' ||
                  ' et1.effective_start_date, et1.effective_end_date, ' ||
                  ' :q_client_id1 client_id, ' ||
                  ' et1.legislation_code ' ||
                  ' from pay_element_types_f et1 ' ||
                  ' where et1.business_group_id is null ' ||
                  '   and et1.legislation_code = ''US'' ' );
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_TYPES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id1',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,170);
      --

      --
      -- For HR_H2PI_INPUT_VALUES_V VIEW
      --
      hr_utility.set_location(l_proc,180);
      queryCtx := DBMS_XMLQuery.newContext(
                  'select iv.last_upd_date, ' ||
                  ' iv.business_group_id, ' ||
                  ' iv.element_type_id, iv.effective_start_date, ' ||
                  ' iv.effective_end_date, iv.input_value_id, ' ||
                  ' iv.name, iv.uom, ' ||
                  ' iv.mandatory_flag, iv.default_value, iv.lookup_type, ' ||
                  ' :q_client_id client_id, ' ||
                  ' iv.legislation_code ' ||
                  ' from hr_h2pi_input_values_v iv ' ||
                  ' where business_group_id =  :q_bg_id ' ||
                  ' union select et.last_update_date, ' ||
                  TO_CHAR(p_business_group_id) ||
                  ', et.element_type_id, iv.effective_start_date, ' ||
                  ' iv.effective_end_date, iv.input_value_id, ' ||
                  ' iv.name, iv.uom, ' ||
                  ' iv.mandatory_flag, iv.default_value, iv.lookup_type, ' ||
                  ' :q_client_id1 client_id, ' ||
                  ' iv.legislation_code ' ||
                  ' from pay_input_values_f iv, pay_element_types_f et ' ||
                  ' where et.element_type_id = iv.element_type_id ' ||
                  '   and iv.business_group_id is null ' ||
                  '   and iv.legislation_code = ''US'' ' ||
                  '   and iv.effective_start_date between ' ||
                  ' et.effective_start_date and et.effective_end_date ' );
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_INPUT_VALUES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id1',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,190);
      --

      --
      -- For HR_H2PI_ELEMENT_LINKS_V VIEW
      --
      hr_utility.set_location(l_proc,200);
      queryCtx := DBMS_XMLQuery.newContext(
                  'select el.last_update_date last_upd_date, ' ||
                  ' el.element_link_id, ' ||
                  ' el.business_group_id, el.effective_start_date, ' ||
                  ' el.effective_end_date, el.payroll_id, ' ||
                  ' el.cost_allocation_keyflex_id, el.element_type_id, ' ||
                  ' el.organization_id, el.location_id, el.pay_basis_id, ' ||
                  ' el.link_to_all_payrolls_flag, :q_client_id client_id ' ||
                  ' from pay_element_links_f el, ' ||
                  '      pay_element_types_f et ' ||
                  ' where el.business_group_id =  :q_bg_id ' ||
                  ' and  et.element_type_id = el.element_type_id ' ||
                  ' and (el.attribute2 = ''Y'' OR et.business_group_id IS NULL)');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_LINKS');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,210);
      --

      --
      -- For HR_H2PI_BG_AND_GRE_V VIEW
      --
      hr_utility.set_location(l_proc,220);
      queryCtx := DBMS_XMLQuery.newContext('select bg.*,:q_client_id client_id from hr_h2pi_bg_and_gre_v bg where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_BG_AND_GRE');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,230);
      --

      --
      -- For HR_H2PI_ORG_PAYMENT_METHODS_V VIEW
      --
      hr_utility.set_location(l_proc,240);
      queryCtx := DBMS_XMLQuery.newContext('select pmt.*,:q_client_id client_id from hr_h2pi_org_payment_methods_v pmt where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ORG_PAYMENT_METHODS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,260);
      --
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_PATCH_STATUS/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_FEDERAL_TAX_RULES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_STATE_TAX_RULES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_COUNTY_TAX_RULES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_CITY_TAX_RULES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ORGANIZATION_CLASS/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_PERIODS_OF_SERVICE/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_SALARIES/>');
      fnd_file.put_line(fnd_file.output,'');

      --
      -- For HR_H2PI_ORGANIZATION_INFO_V VIEW
      --
      hr_utility.set_location(l_proc,420);
      l_query_string := 'SELECT ogi.last_update_date last_upd_date, '||
                        'org.business_group_id, ogi.org_information_id, '||
                        'ogi.organization_id, ogi.org_information_context, '||
                        'ogi.org_information1, ogi.org_information2, '||
                        'ogi.org_information3, ogi.org_information4, '||
                        'ogi.org_information5, ogi.org_information6, '||
                        'ogi.org_information7, ogi.org_information8, '||
                        'ogi.org_information9, ogi.org_information10, '||
                        'ogi.org_information11, ogi.org_information12, '||
                        'ogi.org_information13, ogi.org_information14, '||
                        'ogi.org_information15, ogi.org_information16, '||
                        'ogi.org_information17, ogi.org_information18, '||
                        'ogi.org_information19, ogi.org_information20, '||
                        ':q_client_id client_id '||
                 'FROM hr_organization_units org, '||
                 '     hr_organization_information ogi, '||
                 '     hr_organization_information ogi2, '||
                 '     hr_org_info_types_by_class oitbc, '||
                 '     hr_org_information_types oit '||
                 'WHERE org.organization_id = ogi.organization_id '||
                 '  and ogi.organization_id = ogi2.organization_id '||
                 '  and ogi2.org_information_context = ''CLASS'' '||
                 '  and ogi2.org_information1 IN (''HR_BG'', ''HR_LEGAL'') '||
                 '  and ogi.org_information_context=oit.org_information_type '||
                 '  and ogi.org_information_context IN '||
       '(''Work Day Information'', ''1099R Magnetic Report Rules'', '||
       ' ''EEO-1 Filing'', ''Employer Identification'', '||
       ' ''Federal Tax Rules'', ''NACHA Rules'', '||
       ' ''SQWL Employer Rules 1'', ''SQWL Employer Rules 2'', '||
       ' ''SQWL GN Transmitter Rules'', ''SQWL SS Transmitter Rules'', '||
       ' ''PAY_US_STATE_WAGE_PLAN_INFO'', ''Costing Information'', '||
       ' ''Organization Name Alias'', ''Work Day Information'', '||
       ' ''Legal Entity Accounting'', ''Multiple Worksite Reporting'', '||
       ' ''TIAA-CREF Setup Codes'', ''VETS-100 Filing'', '||
       ' ''W2 Reporting Rules'') '||
       '  and oitbc.org_classification=ogi2.org_information1 '||
       '  and oitbc.org_information_type=oit.org_information_type '||
       '  and (oit.legislation_code is NULL or oit.legislation_code = ''US'')'||
       '  and oit.navigation_method = ''GS'' '||
       '  and org.business_group_id = :q_bg_id ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ORGANIZATION_INFO');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      hr_h2pi_download.write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,430);

      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_COST_ALLOCATIONS/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_PAYMENT_METHODS/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ELEMENT_NAMES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ELEMENT_ENTRIES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_ELEMENT_ENTRY_VALUES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_US_MODIFIED_GEOCODES/>');
      fnd_file.put_line(fnd_file.output,'');
      fnd_file.put_line(fnd_file.output,l_xml_header);
      fnd_file.put_line(fnd_file.output,'<HR_H2PI_US_CITY_NAMES/>');
      fnd_file.put_line(fnd_file.output,'');

    COMMIT;
    hr_utility.set_location('Leaving:'  || l_proc,580);
    END download ;

END hr_h2pi_baseline_data_download ;

/
