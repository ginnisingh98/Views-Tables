--------------------------------------------------------
--  DDL for Package Body HR_H2PI_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_UPLOAD" AS
/* $Header: hrh2piul.pkb 120.0 2005/05/31 00:41:59 appldev noship $*/

g_package  VARCHAR2(33) := '  hr_h2pi_upload.';
--
-- --------------------------------------------------------------------------------
-- Description: Procedure to upload data into a H2PI data tables using
--              XML to SQL Utility (XSU).
-- --------------------------------------------------------------------------------
--
    procedure insert_xml_into_table   (p_table_name in varchar2,
                                     p_locator    in clob) is

    l_saveCtx       DBMS_XMLSave.CtxType;
    l_rows          number(15);
    l_length        number(15);
    l_proc          varchar2(73) := g_package || 'insert_xml_into_table';

    BEGIN
        hr_utility.set_location('Entering:'|| l_proc, 10);
        if dbms_lob.getlength(p_locator) > length('</' || p_table_name|| '>') + length('<?xml version = ''1.0''?') + 10 then
            l_saveCtx := DBMS_XMLSave.newContext(p_table_name);
            DBMS_XMLSave.setDateFormat(l_saveCtx,null);
            l_rows := DBMS_XMLSave.insertXML(l_saveCtx,p_locator);
            DBMS_XMLSave.closeContext(l_saveCtx);
        end if;
      --
        hr_utility.set_location('Leaving:'|| l_proc, 20);
    END insert_xml_into_table;

    function get_clob_locator (p_table_name in varchar2) return clob is

      TYPE l_clob_rec_type is RECORD
        (table_name  varchar2(30),
         xmldoc      clob);

      l_clob_rec l_clob_rec_type;
      l_xmldoc_loc  clob;
      l_proc        varchar2(73) := g_package || 'get_clob_locator';

      BEGIN
          hr_utility.set_location('Entering:'|| l_proc, 10);

          l_clob_rec.table_name := p_table_name;
          l_clob_rec.xmldoc  :=  null;
          l_xmldoc_loc := l_clob_rec.xmldoc;
          hr_utility.set_location('Leaving:'|| l_proc, 20);
          return l_xmldoc_loc;

      EXCEPTION
         when no_data_found then
             null;
         when others then
             null;
      END;

    /*
    FUNCTION  get_from_business_group_id RETURN NUMBER IS

    g_package  VARCHAR2(33) := '  hr_h2pi_bg_upload.';
    l_from_business_group_id NUMBER(15);
    l_proc  VARCHAR2(72) := g_package||'get_from_business_group_id';

    BEGIN
      hr_utility.set_location('Entering:'|| l_proc, 10);
      l_from_business_group_id := hr_h2pi_map.get_from_id
                          (p_table_name => 'HR_ALL_ORGANIZATION_UNITS',
                           p_to_id      => hr_h2pi_upload.g_to_business_group_id);
      IF l_from_business_group_id  = -1 THEN
        hr_utility.set_location(l_proc, 20);
        hr_h2pi_error.data_error
                            (p_from_id => hr_h2pi_upload.g_to_business_group_id,
                             p_table_name    => 'HR_H2PI_BG_AND_GRE',
                             p_message_level => 'FATAL',
                             p_message_name  => 'HR_289241_MAPPING_ID_MISSING');
      END IF;

      hr_utility.set_location('Leaving:'|| l_proc, 30);
      RETURN l_from_business_group_id;
    END;
    */

    FUNCTION  get_from_client_id RETURN NUMBER IS

    g_package  VARCHAR2(33) := '  hr_h2pi_upload.';
    l_from_client_id VARCHAR2(60);
    l_proc  VARCHAR2(72) := g_package||'get_from_client_id';

    BEGIN
      hr_utility.set_location('Entering:'|| l_proc, 10);
      -- special case of getting from client id
      l_from_client_id := hr_h2pi_map.get_from_id
                          (p_table_name => 'CLIENT_ID',
                           p_to_id      => hr_h2pi_upload.g_to_business_group_id);
      IF l_from_client_id  = -1 THEN
        hr_utility.set_location(l_proc, 20);
        hr_h2pi_error.data_error
                            (p_from_id => hr_h2pi_upload.g_to_business_group_id,
                             p_table_name    => 'HR_H2PI_BG_AND_GRE',
                             p_message_level => 'FATAL',
                             p_message_name  => 'HR_289241_MAPPING_ID_MISSING');
      END IF;

      hr_utility.set_location('Leaving:'|| l_proc, 30);
      RETURN l_from_client_id;
    END;


    procedure upload (p_errbuf     OUT NOCOPY VARCHAR2,
                      p_retcode    OUT NOCOPY NUMBER,
                      p_file_name  IN  VARCHAR2) IS

        l_fp            UTL_FILE.file_type;
        l_line          varchar2(32767);
        l_text          varchar2(32767);

        l_xmldoc        clob;
        l_rows          number(15);
        l_file_name     varchar2(30):= 'h2i_upload';
        l_dest_clob_loc clob;
        l_proc          varchar2(72) := g_package||'upload';

        e_in_upload EXCEPTION ;
        PRAGMA  Exception_Init(e_in_upload, -20001);
        l_message varchar2(240);
        --

    BEGIN
      hr_utility.set_location('Entering:'|| l_proc, 10);

      -- check for previous incomplete uploads
      /*
      BEGIN
          if check_incomplete_upload  then
              RAISE e_in_upload;
          end if;
      EXCEPTION
          when e_in_upload then
              fnd_message.set_name('PER','HR_289277_INCOMPLETE_UPLOAD');
              --l_message := fnd_message.get_string('PER','HR_289277_INCOMPLETE_UPLOAD');
              --fnd_file.put_line(FND_FILE.LOG,l_message);
              fnd_message.raise_error;
      END;
      */

      l_fp := UTL_FILE.fopen(FND_PROFILE.VALUE('PER_H2PI_DATA_UPLOAD_DIRECTORY'),p_file_name,'r');

      --
      -- FOR HR_H2PI_EMPLOYEES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_EMPLOYEES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location(l_proc, 20);
      <<hr_h2pi_employees>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_EMPLOYEES>')
            OR (l_text = '<HR_H2PI_EMPLOYEES/>') then
                exit ;
        end if;
      end loop hr_h2pi_employees;
      --
      insert_xml_into_table('HR_H2PI_EMPLOYEES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ADDRESSES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ADDRESSES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 30);
      <<hr_h2pi_addresses>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ADDRESSES>')
            OR (l_text = '<HR_H2PI_ADDRESSES/>') then
                exit ;
        end if;
      end loop hr_h2pi_addresses;
      --
      insert_xml_into_table('HR_H2PI_ADDRESSES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_LOCATIONS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_LOCATIONS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 40);
      <<hr_h2pi_locations>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_LOCATIONS>')
            OR (l_text = '<HR_H2PI_LOCATIONS/>') then
                exit ;
        end if;
      end loop hr_h2pi_addresses;
      --
      insert_xml_into_table('HR_H2PI_LOCATIONS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ASSIGNMENTS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ASSIGNMENTS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 50);
      <<hr_h2pi_assignments>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ASSIGNMENTS>')
            OR (l_text = '<HR_H2PI_ASSIGNMENTS/>') then
                exit ;
        end if;
      end loop hr_h2pi_addresses;
      --
      insert_xml_into_table('HR_H2PI_ASSIGNMENTS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);

      --
      -- FOR HR_H2PI_PAY_BASES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_PAY_BASES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 60);
      <<hr_h2pi_pay_bases>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_PAY_BASES>')
            OR (l_text = '<HR_H2PI_PAY_BASES/>') then
                exit ;
        end if;
      end loop hr_h2pi_pay_bases;
      --
      insert_xml_into_table('HR_H2PI_PAY_BASES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);

      --
      -- FOR HR_H2PI_HR_ORGANIZATIONS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_HR_ORGANIZATIONS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 70);
      <<hr_h2pi_HR_organizations>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if l_text = '</HR_H2PI_HR_ORGANIZATIONS>' then exit ; end if;
        if (l_text = '</HR_H2PI_HR_ORGANIZATIONS>')
            OR (l_text = '<HR_H2PI_HR_ORGANIZATIONS/>') then
                exit ;
        end if;
      end loop hr_h2pi_hr_organizations;
      --
      insert_xml_into_table('HR_H2PI_HR_ORGANIZATIONS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);


      --
      -- FOR HR_H2PI_PAYROLLS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_PAYROLLS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 80);
      <<hr_h2pi_payrolls>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_PAYROLLS>')
            OR (l_text = '<HR_H2PI_PAYROLLS/>') then
                exit ;
        end if;
      end loop hr_h2pi_payrolls;
      --
      insert_xml_into_table('HR_H2PI_PAYROLLS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);


      --
      -- FOR HR_H2PI_ELEMENT_TYPES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ELEMENT_TYPES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 90);
      <<hr_h2pi_element_types>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ELEMENT_TYPES>')
            OR (l_text = '<HR_H2PI_ELEMENT_TYPES/>') then
                exit ;
        end if;
      end loop hr_h2pi_element_types;
      --
      insert_xml_into_table('HR_H2PI_ELEMENT_TYPES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_INPUT_VALUES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_INPUT_VALUES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 100);
      <<hr_h2pi_input_values>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_INPUT_VALUES>')
            OR (l_text = '<HR_H2PI_INPUT_VALUES/>') then
                exit ;
        end if;
      end loop hr_h2pi_input_values;
      --
      insert_xml_into_table('HR_H2PI_INPUT_VALUES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ELEMENT_LINKS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ELEMENT_LINKS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      hr_utility.set_location('Entering:'|| l_proc,110);
      --
      <<hr_h2pi_element_links>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ELEMENT_LINKS>')
            OR (l_text = '<HR_H2PI_ELEMENT_LINKS/>') then
                exit ;
        end if;
      end loop hr_h2pi_element_links;
      --
      insert_xml_into_table('HR_H2PI_ELEMENT_LINKS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_BG_AND_GRE table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_BG_AND_GRE');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 120);
      <<hr_h2pi_bg_and_gre>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_BG_AND_GRE>')
            OR (l_text = '<HR_H2PI_BG_AND_GRE/>') then
                exit ;
        end if;
      end loop hr_h2pi_bg_and_gre;
      --
      insert_xml_into_table('HR_H2PI_BG_AND_GRE',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      --
      -- FOR HR_H2PI_ORG_PAYMENT_METHODS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ORG_PAYMENT_METHODS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 130);
      <<hr_h2pi_org_payment_methods>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ORG_PAYMENT_METHODS>')
            OR (l_text = '<HR_H2PI_ORG_PAYMENT_METHODS/>') then
                exit ;
        end if;
      end loop hr_h2pi_org_payment_methods;
      --
      insert_xml_into_table('HR_H2PI_ORG_PAYMENT_METHODS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_PATCH_STATUS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_PATCH_STATUS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 140);
      <<hr_h2pi_patch_status>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_PATCH_STATUS>')
            OR (l_text = '<HR_H2PI_PATCH_STATUS/>') then
                exit ;
        end if;
      end loop hr_h2pi_patch_status;
      --
      insert_xml_into_table('HR_H2PI_PATCH_STATUS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_FEDERAL_TAX_RULES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_FEDERAL_TAX_RULES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 150);
      <<hr_h2pi_federal_tax_rules>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_FEDERAL_TAX_RULES>')
            OR (l_text = '<HR_H2PI_FEDERAL_TAX_RULES/>') then
                exit ;
        end if;
      end loop hr_h2pi_federal_tax_rules;
      --
      insert_xml_into_table('HR_H2PI_FEDERAL_TAX_RULES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_STATE_TAX_RULES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_STATE_TAX_RULES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 160);
      <<hr_h2pi_state_tax_rules>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_STATE_TAX_RULES>')
            OR (l_text = '<HR_H2PI_STATE_TAX_RULES/>') then
                exit ;
        end if;
      end loop hr_h2pi_state_tax_rules;
      --
      insert_xml_into_table('HR_H2PI_STATE_TAX_RULES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_COUNTY_TAX_RULES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_COUNTY_TAX_RULES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 170);
      <<hr_h2pi_county_tax_rules>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_COUNTY_TAX_RULES>')
            OR (l_text = '<HR_H2PI_COUNTY_TAX_RULES/>') then
                exit ;
        end if;
      end loop hr_h2pi_county_tax_rules;
      --
      insert_xml_into_table('HR_H2PI_COUNTY_TAX_RULES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_CITY_TAX_RULES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_CITY_TAX_RULES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 180);
      <<hr_h2pi_city_tax_rules>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_CITY_TAX_RULES>')
            OR (l_text = '<HR_H2PI_CITY_TAX_RULES/>') then
                exit ;
        end if;
      end loop hr_h2pi_city_tax_rules;
      --
      insert_xml_into_table('HR_H2PI_CITY_TAX_RULES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ORGANIZATION_CLASS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ORGANIZATION_CLASS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 190);
      <<hr_h2pi_organization_class>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ORGANIZATION_CLASS>')
            OR (l_text = '<HR_H2PI_ORGANIZATION_CLASS/>') then
                exit ;
        end if;
      end loop hr_h2pi_organization_class;
      --
      insert_xml_into_table('HR_H2PI_ORGANIZATION_CLASS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_PERIODS_OF_SERVICE table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_PERIODS_OF_SERVICE');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 200);
      <<hr_h2pi_periods_of_service>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_PERIODS_OF_SERVICE>')
            OR (l_text = '<HR_H2PI_PERIODS_OF_SERVICE/>') then
                exit ;
        end if;
      end loop hr_h2pi_periods_of_service;
      --
      insert_xml_into_table('HR_H2PI_PERIODS_OF_SERVICE',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --
      --
      -- FOR HR_H2PI_SALARIES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_SALARIES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 210);
      <<hr_h2pi_salaries>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_SALARIES>')
            OR (l_text = '<HR_H2PI_SALARIES/>') then
                exit ;
        end if;
      end loop hr_h2pi_salaries;
      --
      insert_xml_into_table('HR_H2PI_SALARIES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ORGANIZATION_INFO table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ORGANIZATION_INFO');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 220);
      <<hr_h2pi_organization_info>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ORGANIZATION_INFO>')
            OR (l_text = '<HR_H2PI_ORGANIZATION_INFO/>') then
                exit ;
        end if;
      end loop hr_h2pi_organization_info;
      --
      insert_xml_into_table('HR_H2PI_ORGANIZATION_INFO',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_COST_ALLOCATIONS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_COST_ALLOCATIONS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 230);
      <<hr_h2pi_cost_allocations>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_COST_ALLOCATIONS>')
            OR (l_text = '<HR_H2PI_COST_ALLOCATIONS/>') then
                exit ;
        end if;
      end loop hr_h2pi_cost_allocations;
      --
      insert_xml_into_table('HR_H2PI_COST_ALLOCATIONS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_PAYMENT_METHODS table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_PAYMENT_METHODS');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 240);
      <<hr_h2pi_payment_methods>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_PAYMENT_METHODS>')
            OR (l_text = '<HR_H2PI_PAYMENT_METHODS/>') then
                exit ;
        end if;
      end loop hr_h2pi_payment_methods;
      --
      insert_xml_into_table('HR_H2PI_PAYMENT_METHODS',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ELEMENT_NAMES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ELEMENT_NAMES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 250);
      <<hr_h2pi_element_names>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if (l_text = '</HR_H2PI_ELEMENT_NAMES>')
            OR (l_text = '<HR_H2PI_ELEMENT_NAMES/>') then
                exit ;
        end if;
      end loop hr_h2pi_element_names;
      --
      insert_xml_into_table('HR_H2PI_ELEMENT_NAMES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ELEMENT_ENTRIES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ELEMENT_ENTRIES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      hr_utility.set_location('Entering:'|| l_proc, 260);
      <<hr_h2pi_element_entries>>
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if l_text = '</HR_H2PI_ELEMENT_ENTRIES>' then exit ; end if;
        if (l_text = '</HR_H2PI_ELEMENT_ENTRIES>')
            OR (l_text = '<HR_H2PI_ELEMENT_ENTRIES/>') then
                exit ;
        end if;
      end loop hr_h2pi_element_entries;
      --
      insert_xml_into_table('HR_H2PI_ELEMENT_ENTRIES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_ELEMENT_ENTRY_VALUES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_ELEMENT_ENTRY_VALUES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      <<hr_h2pi_element_entry_values>>
      hr_utility.set_location('Entering:'|| l_proc, 270);
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if l_text = '</HR_H2PI_ELEMENT_ENTRY_VALUES>' then exit ; end if;
        if (l_text = '</HR_H2PI_ELEMENT_ENTRY_VALUES>')
            OR (l_text = '<HR_H2PI_ELEMENT_ENTRY_VALUES/>') then
                exit ;
        end if;
      end loop hr_h2pi_element_entry_values;
      --
      insert_xml_into_table('HR_H2PI_ELEMENT_ENTRY_VALUES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --


      --
      -- FOR HR_H2PI_US_MODIFIED_GEOCODES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_US_MODIFIED_GEOCODES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      <<hr_h2pi_us_modified_geocodes>>
      hr_utility.set_location('Entering:'|| l_proc, 280);
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if l_text = '</HR_H2PI_US_MODIFIED_GEOCODES>' then exit ; end if;
        if (l_text = '</HR_H2PI_US_MODIFIED_GEOCODES>')
            OR (l_text = '<HR_H2PI_US_MODIFIED_GEOCODES/>') then
                exit ;
        end if;
      end loop HR_H2PI_US_MODIFIED_GEOCODES;
      --
      insert_xml_into_table('HR_H2PI_US_MODIFIED_GEOCODES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --

      --
      -- FOR HR_H2PI_US_CITY_NAMES table.
      --
      l_dest_clob_loc := get_clob_locator('HR_H2PI_US_CITY_NAMES');
      dbms_lob.createtemporary(l_dest_clob_loc,TRUE);
      --
      <<HR_H2PI_US_CITY_NAMES>>
      hr_utility.set_location('Entering:'|| l_proc, 290);
      loop
        utl_file.get_line(l_fp,l_line);
        l_text := l_line;
        if l_text is not null then
           dbms_lob.writeappend(l_dest_clob_loc,length(l_text),l_text);
        end if;
        if l_text = '</HR_H2PI_US_CITY_NAMES>' then exit ; end if;
        if (l_text = '</HR_H2PI_US_CITY_NAMES>')
            OR (l_text = '<HR_H2PI_US_CITY_NAMES/>') then
                exit ;
        end if;
      end loop HR_H2PI_US_CITY_NAMES;
      --
      insert_xml_into_table('HR_H2PI_US_CITY_NAMES',l_dest_clob_loc);
      DBMS_LOB.FREETEMPORARY(l_dest_clob_loc);
      --
      utl_file.fclose(l_fp);

      --commit;
      hr_utility.set_location('Leaving:'|| l_proc, 300);

    EXCEPTION
        WHEN UTL_FILE.INVALID_PATH THEN
            fnd_message.set_name('PER','HR_52089_NOT_OPEN_FILE');
            fnd_message.set_token('FILENAME',p_file_name);
            fnd_message.raise_error;
        WHEN UTL_FILE.INVALID_OPERATION THEN
            fnd_message.set_name('PER','HR_52089_NOT_OPEN_FILE');
            fnd_message.set_token('FILENAME',p_file_name);
            fnd_message.raise_error;

    END upload;

END hr_h2pi_upload ;

/
