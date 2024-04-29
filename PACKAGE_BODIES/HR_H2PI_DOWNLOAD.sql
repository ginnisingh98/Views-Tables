--------------------------------------------------------
--  DDL for Package Body HR_H2PI_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_DOWNLOAD" AS
/* $Header: hrh2pidl.pkb 120.0 2005/05/31 00:38:49 appldev noship $ */

g_package  VARCHAR2(33)  := '   hr_h2pi_download.';
--
-- --------------------------------------------------------------------------------
-- Description: Local procedure to insert record into hr_h2pi_data_feed_hist table
--              once download a xml file is created and download is completed.
--              This table keeps records of all the downloads.
--
-- --------------------------------------------------------------------------------
--
    procedure record_extract_history (p_bg_id      in  number ,
                                      p_client_id  in  number,
                                      p_request_id in  number,
                                      p_start_date in  date,
                                      p_end_date   in  date) is

        l_business_group_name hr_all_organization_units.name%TYPE;
        l_proc           varchar2(72) := g_package || 'record_extract_history' ;
        begin
            hr_utility.set_location('Entering:'  || l_proc,10);
            select name
            into   l_business_group_name
            from   hr_all_organization_units
            where  organization_id = p_bg_id;
            insert into hr_h2pi_data_feed_hist
                (start_date,
                end_date,
                sequence_number,
                business_group_id,
                client_id,
                business_group_name,
                object_version_number,
                request_id,
                program_application_id,
                program_id,
                program_update_date)
            values
                (p_start_date,
                p_end_date,
                hr_h2pi_data_feed_hist_s.nextval,
                p_bg_id,
                p_client_id,
                l_business_group_name,
                1,
                p_request_id,
                null,
                null,
                sysdate);
            hr_utility.set_location('Leaving:' || l_proc,20);
         exception
            when no_data_found then
                hr_utility.set_location(l_proc || l_proc,30);
                fnd_message.set_name('PER','HR_6673_PO_EMP_NO_BG');
                fnd_message.raise_error;
    END record_extract_history;
--
--
-- --------------------------------------------------------------------------------
-- Description: Local function to get the values corresponding to ids for the DFF
--
-- --------------------------------------------------------------------------------
--

    FUNCTION get_value_from_id(p_org_information_id in number,
                               p_org_info_number    in number)  return varchar2 is

    CURSOR csr_org_info IS
      SELECT ogi.org_information_context context
             ,ogi.org_information1 ogi1
             ,ogi.org_information2 ogi2
             ,ogi.org_information3 ogi3
             ,ogi.org_information4 ogi4
             ,ogi.org_information5 ogi5
             ,ogi.org_information6 ogi6
             ,ogi.org_information7 ogi7
             ,ogi.org_information8 ogi8
             ,ogi.org_information9 ogi9
             ,ogi.org_information10 ogi10
             ,ogi.org_information11 ogi11
             ,ogi.org_information12 ogi12
             ,ogi.org_information13 ogi13
             ,ogi.org_information14 ogi14
             ,ogi.org_information15 ogi15
             ,ogi.org_information16 ogi16
             ,ogi.org_information17 ogi17
             ,ogi.org_information18 ogi18
             ,ogi.org_information19 ogi19
             ,ogi.org_information20 ogi20
      from   hr_organization_units org,
             hr_organization_information ogi,
             hr_organization_information ogi2,
             hr_org_info_types_by_class oitbc,
             hr_org_information_types oit
      where org.organization_id = ogi.organization_id
      and  ogi.organization_id = ogi2.organization_id
      and ogi2.org_information_context = 'CLASS'
      and ogi2.org_information1 IN ('HR_ORG', 'HR_LEGAL', 'HR_BG', 'HR_PAYEE', 'US_CARRIER', 'US_WC_CARRIER ')
      and ogi.org_information_context = oit.org_information_type
      and ogi.org_information_context IN ('Work Day Information',
                                          '1099R Magnetic Report Rules',
                                          'EEO-1 Filing',
                                          'Employer Identification',
                                          'Federal Tax Rules',
                                           'NACHA Rules',
                                           'SQWL Employer Rules 1',
                                           'SQWL Employer Rules 2',
                                           'SQWL GN Transmitter Rules',
                                           'SQWL SS Transmitter Rules',
                                           'PAY_US_STATE_WAGE_PLAN_INFO',
                                           'Costing Information',
                                           'Organization Name Alias',
                                           'Work Day Information',
                                           'Legal Entity Accounting',
                                           'Multiple Worksite Reporting',
                                           'TIAA-CREF Setup Codes',
                                           'VETS-100 Filing',
                                           'W2 Reporting Rules',
                                           'State Tax Rules',
                                           'Local Tax Rules')
      and oitbc.org_classification = ogi2.org_information1
      and oitbc.org_information_type = oit.org_information_type
      and (oit.legislation_code is NULL or oit.legislation_code = 'US')
      and  ogi.org_information_id = p_org_information_id;

    l_seg_id    	  VARCHAR2(100);
    l_seg_value 	  VARCHAR2(100);
    l_seg_desc  	  VARCHAR2(100);
    l_return_status BOOLEAN;

    TYPE t_org_info IS RECORD
         (column_seq_num  number
          ,column_name    varchar2(30)
         );

    TYPE tab_org_info IS TABLE OF t_org_info
       INDEX BY BINARY_INTEGER;

    CURSOR csr_flex_cols(p_context VARCHAR2) IS
      SELECT column_seq_num,
             application_column_name  col_name
      FROM   fnd_descr_flex_column_usages
      WHERE  application_id = 800
      AND    descriptive_flex_context_code = p_context
      ORDER BY column_seq_num;

     idx  NUMBER;
     i    NUMBER;
     l_proc           varchar2(72) := g_package || '.get_value_from_id' ;

  BEGIN
    hr_utility.set_location('Entering:'  || l_proc,10);
    FOR v_rec IN csr_org_info LOOP
      fnd_flex_descval.set_column_value('ORG_INFORMATION_CONTEXT', v_rec.context);
      fnd_flex_descval.set_column_value('ORG_INFORMATION1', v_rec.ogi1 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION2', v_rec.ogi2 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION3', v_rec.ogi3 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION4', v_rec.ogi4 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION5', v_rec.ogi5 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION6', v_rec.ogi6 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION7', v_rec.ogi7 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION8', v_rec.ogi8 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION9', v_rec.ogi9 );
      fnd_flex_descval.set_column_value('ORG_INFORMATION10', v_rec.ogi10);
      fnd_flex_descval.set_column_value('ORG_INFORMATION11', v_rec.ogi11);
      fnd_flex_descval.set_column_value('ORG_INFORMATION12', v_rec.ogi12);
      fnd_flex_descval.set_column_value('ORG_INFORMATION13', v_rec.ogi13);
      fnd_flex_descval.set_column_value('ORG_INFORMATION14', v_rec.ogi14);
      fnd_flex_descval.set_column_value('ORG_INFORMATION15', v_rec.ogi15);
      fnd_flex_descval.set_column_value('ORG_INFORMATION16', v_rec.ogi16);
      fnd_flex_descval.set_column_value('ORG_INFORMATION17', v_rec.ogi17);
      fnd_flex_descval.set_column_value('ORG_INFORMATION18', v_rec.ogi18);
      fnd_flex_descval.set_column_value('ORG_INFORMATION19', v_rec.ogi19);
      fnd_flex_descval.set_column_value('ORG_INFORMATION20', v_rec.ogi20);

      l_return_status := fnd_flex_descval.VALIDATE_DESCCOLS
            	  (
            	  appl_short_name         =>   'PER',
            	  desc_flex_name          =>   'Org Developer DF',
            	  values_or_ids           =>   'I'
            	  );

      i:=1;

      FOR v_org_info IN csr_flex_cols(v_rec.context) LOOP
        IF v_org_info.col_name = 'ORG_INFORMATION'||TO_CHAR(p_org_info_number) THEN
          idx := i;
          hr_utility.trace('Column Name : ' || v_org_info.col_name);
        END IF;
        i:=i+1;
      END LOOP;

      select fnd_flex_descval.segment_id(idx+1),
             fnd_flex_descval.segment_value(idx+1),
             fnd_flex_descval.segment_description(idx+1)
      into   l_seg_id,
             l_seg_value,
             l_seg_desc
      from   dual;

      return(l_seg_value);

      END LOOP;
      hr_utility.set_location('Leaving:'  || l_proc,90);
    END;
--
--
-- --------------------------------------------------------------------------------
-- Description: Local procedure to get the concurrent request id by calling
--              fnd_concurrent.get_request_status function.
--
-- --------------------------------------------------------------------------------
--
    function get_request_id return number is

        l_call_status BOOLEAN;
        l_request_id  number(15);
        l_rphase      varchar2(80);
        l_rstatus     varchar2(80);
        l_dphase      varchar2(80);
        l_dstatus     varchar2(80);
        l_message     varchar2(80);
        l_proc        varchar2(72) := g_package || 'get_request_id';
    BEGIN
        hr_utility.set_location('Entering:'  || l_proc,10);
        l_call_status := fnd_concurrent.get_request_status
                            (l_request_id,
                             'PER',
                             'H2PI_DOWNLOAD',
                             l_rphase,
                             l_rstatus,
                             l_dphase,
                             l_dstatus,
                             l_message);
       hr_utility.set_location('Leaving:' || l_proc,20);
       return l_request_id;
    EXCEPTION
      when others then
          hr_utility.set_location(l_proc,30);
          fnd_message.raise_error;
    END get_request_id;
--
-- --------------------------------------------------------------------------------
--

--
-- --------------------------------------------------------------------------------
-- Description: Procedure to write data into a file, in XML format as provided
--              by XML to SQL Utility (XSU).
-- --------------------------------------------------------------------------------
--
    procedure  write ( p_errbuf           out nocopy varchar2,
                       p_retcode          out nocopy number,
                       p_clob_to_write    clob ) is

        l_cloblength     number(30);
        l_counter        number(20);
        l_offset         number(20);
        l_lengthtoread   constant number:= 32767;
        l_string         varchar2(32767);

        l_length_done   number(30);
        l_new_position    number(10);

        l_proc           varchar2(72) := g_package || 'write' ;

    begin
        hr_utility.set_location('Entering:'  || l_proc,10);
        l_cloblength := dbms_lob.getlength(p_clob_to_write);
        l_offset := 0;
        l_new_position := 0;
        loop
            l_string := dbms_lob.substr(p_clob_to_write,l_lengthtoread, l_offset + 1);
            if length(l_string) > 32766 then
               l_new_position := instr(l_string,'</ROW>',-1)+ 5;
               l_string      := substr(l_string,1,l_new_position);
            else
              l_new_position := 32767;
            end if;
            fnd_file.put_line(fnd_file.output,l_string);
            l_offset := l_offset + l_new_position + 1;
            l_string := null;
            if ( (l_offset) >= l_cloblength ) then
                exit;
            end if;
        end loop;
        hr_utility.set_location('Leaving:'  || l_proc,20);
    end write;
--
-- --------------------------------------------------------------------------------
-- Description: Procedure to download data from the H2PI views into a XML file
--
-- --------------------------------------------------------------------------------
--
    procedure download ( p_errbuf              OUT NOCOPY VARCHAR2,
                         p_retcode             OUT NOCOPY NUMBER,
                         p_business_group_id   IN  NUMBER,
                         p_transfer_start_date IN  VARCHAR2,
                         p_transfer_end_date   IN  VARCHAR2,
                         p_client_id           IN  NUMBER) IS

        queryCtx      DBMS_XMLQuery.ctxType;
        xmlString1    CLOB := NULL;

        xmlString2    CLOB := NULL;
        dtdString     CLOB := NULL;
        --
        x varchar2(10000);
        y number(20);
        --
        l_start_date  CONSTANT DATE := fnd_date.canonical_to_date(p_transfer_start_date);
        l_end_date    CONSTANT DATE := fnd_date.canonical_to_date(p_transfer_end_date);
        l_request_id  NUMBER(15);
        lengthtoread  NUMBER(10);
        cloblength    NUMBER(20);
        l_query_string varchar2(10000);
        l_proc           varchar2(72) := g_package || 'download' ;

    BEGIN
      hr_utility.set_location('Entering:'  || l_proc,10);

      l_request_id := get_request_id;

      --
      -- For HR_H2PI_EMPLOYEES_V VIEW
      --
      hr_utility.set_location(l_proc,20);
      l_query_string := 'select emp.*, :q_client_id client_id from hr_h2pi_employees_v emp where business_group_id =  :q_bg_id and last_upd_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_EMPLOYEES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,30);
      --

      --
      -- For HR_H2PI_ADDRESSES_V VIEW
      --
      hr_utility.set_location(l_proc,40);
      l_query_string := 'select adr.last_upd_date, GREATEST(per.per_date, adr.date_from) date_from,adr.business_group_id, adr.address_id, adr.person_id, adr.style, ' ||
                        ' adr.date_to, adr.address_type, adr.address_line1, adr.address_line2, adr.address_line3, adr.town_or_city, adr.region_1, adr.region_2, ' ||
                        ' adr.region_3, adr.postal_code, adr.country, adr.telephone_number_1, adr.telephone_number_2, adr.telephone_number_3, adr.add_information13, ' ||
                        ' adr.add_information14, adr.add_information15, adr.add_information16, adr.add_information17, adr.add_information18, adr.add_information19, ' ||
                        ' adr.add_information20, adr.addr_attribute_category, adr.addr_attribute1, adr.addr_attribute2, adr.addr_attribute3, adr.addr_attribute4, ' ||
                        ' adr.addr_attribute5, adr.addr_attribute6, adr.addr_attribute7, adr.addr_attribute8, adr.addr_attribute9, adr.addr_attribute10, ' ||
                        ' adr.addr_attribute11, adr.addr_attribute12, adr.addr_attribute13, adr.addr_attribute14, adr.addr_attribute15, adr.addr_attribute16, ' ||
                        ' adr.addr_attribute17, adr.addr_attribute18, adr.addr_attribute19, adr.addr_attribute20, :q_client_id client_id ' ||
                        ' FROM hr_h2pi_addresses_v adr, ' ||
                        ' (select min(effective_start_date) per_date, person_id from per_all_people_f a, per_person_types b where b.system_person_type IN (''EMP'', ''EMP_APL'') ' ||
                        ' and   a.person_type_id = b.person_type_id group by person_id) per, per_all_people_f per2 ' ||
                        ' WHERE adr.person_id = per.person_id AND   per.person_id = per2.person_id ' ||
                        ' AND   per.per_date = per2.effective_start_date and adr.business_group_id = :q_bg_id and ( per2.last_update_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'')  ' ||
        ' OR per.person_id IN  (select adr1.person_id from hr_h2pi_addresses_v adr1  where adr1.business_group_id = :q_bg_id1 and adr1.last_upd_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
        ' group by adr1.person_id having count(*)> 0 )  )' ;

      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id1',p_business_group_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ADDRESSES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,50);
      --

      --
      -- For HR_H2PI_LOCATIONS_V VIEW
      --
      hr_utility.set_location(l_proc,60);
      l_query_string := 'select ' ||
                        '  last_upd_date,' ||
                         ' nvl(business_group_id,:q_bg_id1 )  business_group_id,  ' ||
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
               ' from hr_h2pi_locations_v where ( business_group_id =  :q_bg_id OR business_group_id is null ) ' ||
      ' and last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id1',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_LOCATIONS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,70);
      --

      --
      -- For HR_H2PI_ASSIGNMENTS_V VIEW
      --
      hr_utility.set_location(l_proc,80);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_assignments_v p1 where business_group_id =  :q_bg_id and effective_start_date >= ' ||
      ' ((select min(effective_start_date) from hr_h2pi_assignments_v p2 where p2.last_upd_date between ' ||
        ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
     ' and p2.assignment_id = p1.assignment_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ASSIGNMENTS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,90);
      --

      -- Following is for Baseline data

      --
      -- For HR_H2PI_PAY_BASES_V VIEW
      --
      hr_utility.set_location(l_proc,100);
      queryCtx := DBMS_XMLQuery.newContext('select pay.*,:q_client_id client_id from hr_h2pi_pay_bases_v pay where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PAY_BASES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,110);
      --

      --
      -- For HR_H2PI_HR_ORGANIZATIONS_V VIEW
      --
      hr_utility.set_location(l_proc,120);
      queryCtx := DBMS_XMLQuery.newContext('select org.*,:q_client_id client_id from hr_h2pi_hr_organizations_v org where business_group_id =  :q_bg_id and ' ||
      ' last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_HR_ORGANIZATIONS');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,130);
      --

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
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,150);
      --

      --
      -- For HR_H2PI_ELEMENT_TYPES_V VIEW
      --
      hr_utility.set_location(l_proc,160);
      queryCtx := DBMS_XMLQuery.newContext('select et.*,:q_client_id client_id from hr_h2pi_element_types_v et where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_TYPES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,170);
      --

      --
      -- For HR_H2PI_INPUT_VALUES_V VIEW
      --
      hr_utility.set_location(l_proc,180);
      queryCtx := DBMS_XMLQuery.newContext('select iv.*,:q_client_id client_id from hr_h2pi_input_values_v iv where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_INPUT_VALUES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,190);
      --

      --
      -- For HR_H2PI_ELEMENT_LINKS_V VIEW
      --
      hr_utility.set_location(l_proc,200);
      queryCtx := DBMS_XMLQuery.newContext('select el.*,:q_client_id client_id from hr_h2pi_element_links_v el where business_group_id =  :q_bg_id');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_LINKS');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
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
      write(x,y,xmlstring1);
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
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,260);
      --

      --
      -- For HR_H2PI_PATCH_STATUS_V VIEW
      --
      hr_utility.set_location(l_proc,270);
      queryCtx := DBMS_XMLQuery.newContext('select pat.*,:q_bg_id business_group_id,:q_client_id client_id from hr_h2pi_patch_status_v pat');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PATCH_STATUS');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,280);
      --

      --
      -- For HR_H2PI_FEDERAL_TAX_RULES_V VIEW
      --
      hr_utility.set_location(l_proc,290);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_federal_tax_rules_v  p1  where business_group_id =  :q_bg_id ' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_federal_tax_rules_v p2 where p2.last_upd_date between ' ||
         ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.emp_fed_tax_rule_id = p1.emp_fed_tax_rule_id ))' ;
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_FEDERAL_TAX_RULES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,300);
      --

      --
      -- For HR_H2PI_STATE_TAX_RULES_V VIEW
      --
      hr_utility.set_location(l_proc,310);
      l_query_string :=  'select p1.*,:q_client_id client_id from hr_h2pi_state_tax_rules_v p1 where business_group_id =  :q_bg_id' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_state_tax_rules_v p2 where p2.last_upd_date between ' ||
         ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.emp_state_tax_rule_id = p1.emp_state_tax_rule_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_STATE_TAX_RULES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,320);
      --


      --
      -- For HR_H2PI_COUNTY_TAX_RULES_V VIEW
      --
      hr_utility.set_location(l_proc,330);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_county_tax_rules_v p1 where business_group_id =  :q_bg_id' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_county_tax_rules_v p2 where p2.last_upd_date between ' ||
         ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.emp_county_tax_rule_id = p1.emp_county_tax_rule_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_COUNTY_TAX_RULES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,340);
      --

      --
      -- For HR_H2PI_CITY_TAX_RULES_V VIEW
      --
      hr_utility.set_location(l_proc,350);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_city_tax_rules_v p1 where business_group_id =  :q_bg_id' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_city_tax_rules_v p2 where p2.last_upd_date between ' ||
         ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.emp_city_tax_rule_id = p1.emp_city_tax_rule_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_CITY_TAX_RULES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,360);
      --

      --
      -- For HR_H2PI_ORGANIZATION_CLASS_V VIEW
      --
      hr_utility.set_location(l_proc,370);
      l_query_string := 'select org.*,:q_client_id client_id from hr_h2pi_organization_class_v org where business_group_id =  :q_bg_id and ' ||
      ' last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ORGANIZATION_CLASS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,380);
      --

      --
      -- For HR_H2PI_PERIODS_OF_SERVICE_V VIEW
      --

      hr_utility.set_location(l_proc,380);
      l_query_string := 'select pos.*,:q_client_id client_id from hr_h2pi_periods_of_service_v pos where business_group_id =  :q_bg_id and ' ||
      ' last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PERIODS_OF_SERVICE');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,390);
      --

      --
      -- For HR_H2PI_SALARIES_V VIEW
      --
      hr_utility.set_location(l_proc,400);
      l_query_string := 'select sal.*,:q_client_id client_id from hr_h2pi_salaries_v sal where business_group_id =  :q_bg_id and ' ||
     ' last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_SALARIES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,410);
      --

      --
      -- For HR_H2PI_ORGANIZATION_INFO_V VIEW
      --
      hr_utility.set_location(l_proc,420);
      l_query_string := 'select org.*,:q_client_id client_id from hr_h2pi_organization_info_v org where business_group_id =  :q_bg_id ' ||
     ' and last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      hr_utility.trace(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ORGANIZATION_INFO');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,430);
      --

      --
      -- For HR_H2PI_COST_ALLOCATIONS_V VIEW
      --
      hr_utility.set_location(l_proc,440);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_cost_allocations_v p1 where business_group_id =  :q_bg_id ' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_cost_allocations_v p2 where p2.last_upd_date between ' ||
         ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.cost_allocation_id = p1.cost_allocation_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_COST_ALLOCATIONS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,450);
      --


      --
      -- For HR_H2PI_PAYMENT_METHODS_V VIEW
      --
      hr_utility.set_location(l_proc,460);
      l_query_string := 'select p1.*,:q_client_id client_id from hr_h2pi_payment_methods_v p1 where business_group_id =  :q_bg_id ' ||
      ' and ( (p1.payee_type <> ''P'') OR (p1.payee_type IS NULL) )' ||
      ' and effective_start_date >= ((select min(effective_start_date) from hr_h2pi_payment_methods_v p2 where p2.last_upd_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.personal_payment_method_id = p1.personal_payment_method_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      --DBMS_XMLQuery.setBindValue(queryCtx,'q_payee_type','P');
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_PAYMENT_METHODS');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,470);
      --

      --
      -- For HR_H2PI_ELEMENT_NAMES_V VIEW
      --
      hr_utility.set_location(l_proc,480);
      l_query_string := 'select en.*,:q_client_id client_id from hr_h2pi_element_names_v en where business_group_id =  :q_bg_id and ' ||
      ' last_upd_date between to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss')  || ''', ''yyyy/mm/dd:hh24:mi:ss'') ';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_NAMES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,490);
      --

      --
      -- For HR_H2PI_ELEMENT_ENTRIES_V VIEW
      --
      hr_utility.set_location(l_proc,500);
      l_query_string := 'select p1.*, :q_client_id client_id from hr_h2pi_element_entries_v p1 where business_group_id =  :q_bg_id and ' ||
      ' effective_start_date >= ((select min(effective_start_date) from hr_h2pi_element_entries_v p2 where p2.last_upd_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.element_entry_id = p1.element_entry_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_ENTRIES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,510);
      --

      --
      -- For HR_H2PI_ELEMENT_ENTRY_VALUES_V VIEW
      --
      --
      hr_utility.set_location(l_proc,520);
      l_query_string := 'select p1.*, :q_client_id client_id from hr_h2pi_element_entry_values_v p1 where business_group_id =  :q_bg_id and ' ||
      ' effective_start_date >= ((select min(effective_start_date) from hr_h2pi_element_entry_values_v p2 where p2.last_upd_date between ' ||
      ' to_date(''' || to_char(l_start_date, 'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') and to_date(''' || to_char(l_end_date,   'yyyy/mm/dd:hh24:mi:ss') || ''', ''yyyy/mm/dd:hh24:mi:ss'') ' ||
      ' and p2.element_entry_id = p1.element_entry_id ))';
      queryCtx := DBMS_XMLQuery.newContext(l_query_string);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_ELEMENT_ENTRY_VALUES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,530);
      --

      --
      -- For HR_H2PI_US_MODIFIED_GEOCODES_V VIEW
      --
      hr_utility.set_location(l_proc,540);
      queryCtx := DBMS_XMLQuery.newContext('select geo.*, :q_bg_id business_group_id, :q_client_id client_id from hr_h2pi_us_modified_geocodes_v geo where patch_name = (select NVL(MAX(patch_name),''GEOCODE_1900_Q1'') FROM hr_h2pi_patch_status_v) ');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_US_MODIFIED_GEOCODES');
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,550);
      --

      --
      -- For HR_H2PI_US_CITIES_V VIEW
      --
      hr_utility.set_location(l_proc,560);
      queryCtx := DBMS_XMLQuery.newContext('select cit.*, :q_bg_id business_group_id, :q_client_id client_id from hr_h2pi_us_city_names_v cit');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_bg_id',p_business_group_id);
      DBMS_XMLQuery.setRowsetTag(queryCtx,'HR_H2PI_US_CITY_NAMES');
      DBMS_XMLQuery.setBindValue(queryCtx,'q_client_id',p_client_id);
      DBMS_XMLQuery.setMaxRows(queryCtx,99999999);
      xmlString1 := DBMS_XMLQuery.getXML(queryCtx);
      write(x,y,xmlstring1);
      DBMS_XMLQuery.closeContext(queryCtx);
      xmlString1 := null;
      hr_utility.set_location(l_proc,570);
      --

    record_extract_history(p_business_group_id,p_client_id,l_request_id,l_start_date, l_end_date);

    commit;
    hr_utility.set_location('Leaving:'  || l_proc,580);
    END download ;

END hr_h2pi_download ;

/
