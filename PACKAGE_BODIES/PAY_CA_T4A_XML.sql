--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4A_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4A_XML" as
/* $Header: pycat4axml.pkb 120.0.12010000.5 2009/11/27 07:03:10 sapalani noship $ */

/*
   Copyright (c) Oracle Corporation 2009. All rights reserved

   Description : Package to build XML used for generation of T4A pdf

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   25-Aug-2009  sapalani    115.0  4932662  Initial Version
   09-Sep-2009  sapalani    115.2  4932662  Only first 2 characters of Footnote code
                                            should be reported in Box38. Inserted
                                            blank space between characters for
                                            proper alignment in the field in PDF.
   14-Sep-2009  sapalani    115.3  8899845  Business Number has to be reported
                                            only in the first slip. Also made
                                            changes to report only 2 characters
                                            for box38 in error report.
   27-Nov-2009  sapalani    115.4  9156528  Concatenated the address lines into
                                            one string with line breaks
                                            inbetween. This is reported under
                                            XML tag <emp_addr_X>.
*/


procedure get_asg_xml is

 l_aa_id            number;
 l_pa_id            number;

 EOL                varchar2(10);

 l_employee_xml     varchar2(32767);
 l_box61_xml        varchar2(200);
 l_year             varchar2(5);
 l_box16            varchar2(50);
 l_box18            varchar2(50);
 l_box20            varchar2(50);
 l_box22            varchar2(50);
 l_box24            varchar2(50);
 l_box26            varchar2(50);
 l_box27            varchar2(50);
 l_box28            varchar2(50);
 l_box30            varchar2(50);
 l_box32            varchar2(50);
 l_box34            varchar2(50);
 l_box36            varchar2(50);
 l_box40            varchar2(50);
 l_box42            varchar2(50);
 l_box46            varchar2(50);
 l_box12            varchar2(50);
 l_box38            varchar2(10);
 l_box13            varchar2(50);
 l_box14            varchar2(50);
 l_box61            varchar2(50);
 l_payer_nm         varchar2(200);
 l_last_nm          varchar2(150);
 l_first_nm         varchar2(150);
 l_init             varchar2(30);
 l_person_id        varchar2(30);

 address                  pay_ca_rl1_reg.primaryaddress;
 lv_employee_address1     varchar2(200);
 lv_employee_address2     varchar2(200);
 lv_employee_address3     varchar2(200);
 lv_employee_city         varchar2(200);
 lv_employee_province     varchar2(200);
 lv_employee_country      varchar2(200);
 lv_employee_postal_code  varchar2(10);
 l_emp_addr               varchar2(10000);

 l_organization_id  varchar2(50);
 l_gre_id           varchar2(50);
 l_location_id      varchar2(50);
 l_sort1            varchar2(200);
 l_sort2            varchar2(200);
 l_sort3            varchar2(200);
 l_sort             varchar2(1000);

 l_footnote_code1   varchar2(200) := '';
 l_footnote_value1  varchar2(30) := '';
 l_footnote_code2   varchar2(200) := '';
 l_footnote_value2  varchar2(30) := '';
 l_footnote_code3   varchar2(200) := '';
 l_footnote_value3  varchar2(30) := '';
 l_footnote_code4   varchar2(200) := '';
 l_footnote_value4  varchar2(30) := '';
 --l_fncodes          varchar2(1000);
 --l_fnvalues         varchar2(1000);

 --lv_negative_bal_flag varchar2(5);
 l_lang             varchar2(5);
 l_date             date;
 i                  number := 0;
 l_count            number := 0;
 l_msg_code         varchar2(30);
 l_err_msg          hr_lookups.meaning%TYPE;

 cursor c_get_params is
 select paa1.assignment_action_id, -- archiver asg action
        ppa1.payroll_action_id    -- archiver pact
 from  pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_assignment_actions paa1,
       pay_payroll_actions ppa1
 where ppa.payroll_action_id = paa.payroll_action_id
 and ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
 and paa.assignment_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
 and fnd_number.canonical_to_number(substr(paa.serial_number,1,14)) = paa1.assignment_action_id
 and paa1.payroll_action_id = ppa1.payroll_action_id
 and ppa1.report_type   = 'T4A'
 and ppa1.action_type   = 'X'
 and ppa1.action_status = 'C'
 and ppa1.effective_date = ppa.effective_date;

 /* T4A_FOOTNOTE */
  cursor c_t4a_footnote(p_assignment_action_id number) is
  select
         code,
         value
  from ( select decode(l_box38,'13',hl.lookup_code,
                       SUBSTR(fdi.user_name,11,5)||': '||
                       SUBSTR(pay_ca_t4a_reg.get_label('PAY_CA_T4A_FOOTNOTES',
                              hl.lookup_code, l_lang),1,46)) code,
                       to_number(fai.value) value
          from  hr_lookups HL,
                ff_database_items fdi,
                ff_archive_items fai
          where fai.user_entity_id=fdi.user_entity_id
                and fai.context1= p_assignment_action_id
                and fdi.user_name like 'CAEOY_T4A_BOX%_%_AMT_PER_GRE_YTD'
                and fai.value <> '0'
                and hl.lookup_type  = 'PAY_CA_T4A_FOOTNOTES'
                and decode(HL.LOOKUP_CODE,'10(BOX24)','10A',hl.lookup_code) =
                           SUBSTR(FDI.USER_NAME, 17, instr(fdi.user_name,'AMT') - 18 )
          union all
          select
                  decode(l_box38,'13',hl.lookup_code,
                          pay_ca_t4a_reg.get_label('PAY_CA_T4A_NONBOX_FOOTNOTES',
                                            hl.lookup_code, l_lang)),
                  to_number(pai.action_information5)
          from   pay_action_information pai,
                 hr_lookups hl
          where  pai.action_context_id = p_assignment_action_id
          and    hl.lookup_type    = 'PAY_CA_T4A_NONBOX_FOOTNOTES'
          and    hl.lookup_code   = pai.action_information4
          and    pai.action_information6 = 'T4A')
  where rownum < 5
  order by code;

  /* To get error message */
  cursor cur_get_meaning(p_lookup_code VARCHAR2) IS
  select
   meaning
  from
    hr_lookups
  where
   lookup_type = 'PAY_CA_MAG_EXCEPTIONS' and
   lookup_code = p_lookup_code;

  /* To get person language */
   cursor c_get_language(p_effective_date DATE) is
   select decode(correspondence_language,NULL,'US',correspondence_language)
   from per_all_people_f
   where person_id = to_number(pay_ca_archive_utils.get_archive_value(
                               l_aa_id, 'CAEOY_PERSON_ID'))
         and p_effective_date between effective_start_date and effective_end_date;

 begin
      hr_utility.trace('In get_asg_xml');

      EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);

      open c_get_params;
      fetch c_get_params into
        l_aa_id,
        l_pa_id;
      close c_get_params;

      if ( g_err_emp = 'Y' ) then
         l_aa_id := g_aa_id;
         l_pa_id := g_pa_id;
         l_msg_code := 'NEG';
      end if;

      hr_utility.trace('l_aa_id ' ||l_aa_id);
      hr_utility.trace('l_pa_id ' ||l_pa_id);

      l_year := pay_ca_archive_utils.get_archive_value(l_pa_id,
                        'CAEOY_TAXATION_YEAR');

      l_person_id := pay_ca_archive_utils.get_archive_value(l_aa_id,'CAEOY_PERSON_ID');

      address := pay_ca_rl1_reg.get_primary_address(l_person_id, sysdate());

      lv_employee_address1    := substr(address.addr_line_1,1,60);
      lv_employee_address2    := substr(address.addr_line_2,1,60);
      lv_employee_address3    := substr(address.addr_line_3,1,60);
      lv_employee_city        := substr(address.city,1,30);
      lv_employee_province    := address.province;
      lv_employee_postal_code := address.postal_code;
      lv_employee_country     := address.addr_line_5;


      if lv_employee_province = 'NF' then
         lv_employee_province := 'NL';
      end if;

      /* Added for bug 9156528 */
      if lv_employee_address1 is not null then
        l_emp_addr := lv_employee_address1||EOL;
      end if;
      if lv_employee_address2 is not null then
        l_emp_addr := l_emp_addr||lv_employee_address2||EOL;
      end if;
      if lv_employee_address3 is not null then
        l_emp_addr := l_emp_addr||lv_employee_address3||EOL;
      end if;

      l_emp_addr := l_emp_addr
                    || lv_employee_city || ' '
                    || lv_employee_province || ' '
                    || lv_employee_country || ' '
                    || lv_employee_postal_code;

     /* Commented for bug 9156528
     l_emp_addr := lv_employee_city || ' '
                    || lv_employee_province || ' '
                    || lv_employee_country || ' '
                    || lv_employee_postal_code;
       */
      l_last_nm := upper(substr(pay_ca_archive_utils.get_archive_value(l_aa_id ,
                                   'CAEOY_EMPLOYEE_LAST_NAME'),1,22));
      l_first_nm := substr(pay_ca_archive_utils.get_archive_value(l_aa_id ,
                                   'CAEOY_EMPLOYEE_FIRST_NAME'),1,12);
      l_init := substr(pay_ca_archive_utils.get_archive_value(l_aa_id ,
                                   'CAEOY_EMPLOYEE_INITIAL'),1,1);

      l_box16 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX16_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box16) = 0 ) then
          l_box16 := null;
      end if;

      l_box18 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX18_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box18) = 0 ) then
          l_box18 := null;
      end if;

      l_box20 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX20_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box20) = 0 ) then
          l_box20 := null;
      end if;

      l_box22 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_FED_WITHHELD_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box22) = 0 ) then
          l_box22 := null;
      end if;

      l_box24 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX24_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box24) = 0 ) then
          l_box24 := null;
      end if;

      l_box26 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX26_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box26) = 0 ) then
          l_box26 := null;
      end if;

      l_box27 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX27_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box27) = 0 ) then
          l_box27 := null;
      end if;

      l_box28 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX28_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box28) = 0 ) then
          l_box28 := null;
      end if;

      l_box30 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX30_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box30) = 0 ) then
          l_box30 := null;
      end if;

      l_box32 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX32_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box32) = 0 ) then
          l_box32 := null;
      end if;

      l_box34 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX34_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box34) = 0 ) then
          l_box34 := null;
      end if;

      l_box36 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_EMPLOYEE_REGISTRATION_NO');

      l_box40 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX40_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box40) = 0 ) then
          l_box40 := null;
      end if;

      l_box42 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX42_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box42) = 0 ) then
          l_box42 := null;
      end if;

      l_box46 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_BOX46_PER_GRE_YTD');
      if (fnd_number.canonical_to_number(l_box46) = 0 ) then
          l_box46 := null;
      end if;

      l_box12 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_EMPLOYEE_SIN');
      if l_box12 is null then
          l_box12 := '000000000';
      end if;
      l_box12 := substr(l_box12,1,3)||'  '||
                 substr(l_box12,4,3)||'  '||
                 substr(l_box12,7,3);

      l_box38 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_T4A_FOOTNOTE_CODE');

      /* l_box13 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER'); */

      l_box14 := pay_ca_archive_utils.get_archive_value(l_aa_id
                    ,'CAEOY_EMPLOYEE_NUMBER');

      l_box61 := pay_ca_archive_utils.get_archive_value(l_pa_id
                    ,'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER');

      /*l_organization_id := pay_ca_archive_utils.get_archive_value(l_pa_id
                              ,'CAEOY_T4_ORGANIZATION_ID'); */

      l_payer_nm := pay_ca_archive_utils.get_archive_value(l_pa_id
                    ,'CAEOY_EMPLOYER_NAME');

      --lv_negative_bal_flag := pay_ca_archive_utils.get_archive_value(l_aa_id ,
      --                            'CAEOY_T4A_NEGATIVE_BALANCE_EXISTS');

      l_date := ADD_MONTHS(TRUNC(TO_DATE(l_year,'YYYY'),'Y'), 12)-1;

      OPEN c_get_language(l_date);
      FETCH c_get_language INTO l_lang;
      CLOSE c_get_language;

      /*
      for c_t4a_footnote_rec in c_t4a_footnote(l_aa_id)
      loop
        l_count := c_t4a_footnote%rowcount;
        if l_count = 1 then
          l_footnote_code1 := c_t4a_footnote_rec.code;
          l_footnote_value1 := to_char(c_t4a_footnote_rec.value,'999G999G999D99');
          if (length(l_footnote_code1)>35) then
            l_fncodes   :=  substr(l_footnote_code1,1,35)||EOL||
                            substr(l_footnote_code1,36)||EOL;
            l_fnvalues  :=  l_footnote_value1||EOL||EOL;
          else
             l_fncodes  := l_footnote_code1||EOL;
             l_fnvalues := l_footnote_value1||EOL;
          end if;
        elsif l_count = 2 then
          l_footnote_code2 := c_t4a_footnote_rec.code;
          l_footnote_value2 := to_char(c_t4a_footnote_rec.value,'999G999G999D99');
          if (length(l_footnote_code2)>35) then
            l_fncodes   :=  l_fncodes||
                            substr(l_footnote_code2,1,35)||EOL||
                            substr(l_footnote_code2,36)||EOL;
            l_fnvalues  :=  l_fnvalues||l_footnote_value2||EOL||EOL;
          else
             l_fncodes  := l_fncodes||l_footnote_code2||EOL;
             l_fnvalues := l_fnvalues||l_footnote_value2||EOL;
          end if;
        elsif l_count = 3 then
          l_footnote_code3 := c_t4a_footnote_rec.code;
          l_footnote_value3 := to_char(c_t4a_footnote_rec.value,'999G999G999D99');
          if (length(l_footnote_code3)>35) then
            l_fncodes   :=  l_fncodes||
                            substr(l_footnote_code3,1,35)||EOL||
                            substr(l_footnote_code3,36)||EOL;
            l_fnvalues  :=  l_fnvalues||l_footnote_value3||EOL||EOL;
          else
             l_fncodes  := l_fncodes||l_footnote_code3||EOL;
             l_fnvalues := l_fnvalues||l_footnote_value3||EOL;
          end if;
        elsif l_count = 4 then
          l_footnote_code4 := c_t4a_footnote_rec.code;
          l_footnote_value4 := to_char(c_t4a_footnote_rec.value,'999G999G999D99');
          if (length(l_footnote_code4)>35) then
            l_fncodes   :=  l_fncodes||
                            substr(l_footnote_code4,1,35)||EOL||
                            substr(l_footnote_code4,36)||EOL;
            l_fnvalues  :=  l_fnvalues||l_footnote_value4||EOL||EOL;
          else
             l_fncodes  := l_fncodes||l_footnote_code4||EOL;
             l_fnvalues := l_fnvalues||l_footnote_value4||EOL;
          end if;
        end if;
      end loop;  */

      for c_t4a_footnote_rec in c_t4a_footnote(l_aa_id)
      loop
        l_count := c_t4a_footnote%rowcount;
        if l_count = 1 then
          l_footnote_code1 := c_t4a_footnote_rec.code;
          l_footnote_value1 := c_t4a_footnote_rec.value;
        elsif l_count = 2 then
          l_footnote_code2 := c_t4a_footnote_rec.code;
          l_footnote_value2 := c_t4a_footnote_rec.value;
        elsif l_count = 3 then
          l_footnote_code3 := c_t4a_footnote_rec.code;
          l_footnote_value3 := c_t4a_footnote_rec.value;
        elsif l_count = 4 then
          l_footnote_code4 := c_t4a_footnote_rec.code;
          l_footnote_value4 := c_t4a_footnote_rec.value;
        end if;
      end loop;

      hr_utility.trace('g_err_emp ='||g_err_emp);

      OPEN cur_get_meaning(l_msg_code);
      FETCH cur_get_meaning
      INTO  l_err_msg;
      CLOSE cur_get_meaning;

      if (g_err_emp <> 'Y' or g_err_emp is null ) then
        l_employee_xml := '<T4A>'||EOL;
        for i in 1..3
        loop
          if (i=1) then --Bug 8899845 - to report business number only in firs slip
            l_box61_xml := pay_ca_t4_mag.convert_2_xml(l_box61, 'box61_'||i,'T');
          else
            l_box61_xml := null;
          end if;

          l_employee_xml := l_employee_xml ||
                            pay_ca_t4_mag.convert_2_xml(l_year, 'year_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_last_nm, 'last_nm_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_first_nm, 'first_nm_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_init, 'init_'||i,'T')||
                            /* Commented for bug 9156528
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address1, 'addrline1_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address2, 'addrline2_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address3, 'addrline3_'||i,'T')||*/
                            pay_ca_t4_mag.convert_2_xml(l_emp_addr, 'emp_addr_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box16, 'box16_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box18, 'box18_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box20, 'box20_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box22, 'box22_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box24, 'box24_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box26, 'box26_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box27, 'box27_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box28, 'box28_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box30, 'box30_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box32, 'box32_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box34, 'box34_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box36, 'box36_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box40, 'box40_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box42, 'box42_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box46, 'box46_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box12, 'box12_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(substr(l_box38,1,1)||' '||substr(l_box38,2,1),
                                                        'box38_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box13, 'box13_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_box14, 'box14_'||i,'T')||l_box61_xml||
                            pay_ca_t4_mag.convert_2_xml(l_payer_nm, 'payer_nm_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code1, 'fncode1_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value1, 'fnvalue1_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code2, 'fncode2_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value2, 'fnvalue2_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code3, 'fncode3_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value3, 'fnvalue3_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code4, 'fncode4_'||i,'T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value4, 'fnvalue4_'||i,'T');

        end loop;
        l_employee_xml := trim(l_employee_xml)||'</T4A>'||EOL;
      else
                            l_employee_xml := '<FAILED_T4A>' || EOL||
                            pay_ca_t4_mag.convert_2_xml(l_year, 'year_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_last_nm, 'last_nm_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_first_nm, 'first_nm_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_init, 'init_f','T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address1, 'addrline1_f','T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address2, 'addrline2_f','T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_address3, 'addrline3_f','T')||
                            pay_ca_t4_mag.convert_2_xml(lv_employee_city, 'city_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box16, 'box16_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box18, 'box18_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box20, 'box20_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box22, 'box22_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box24, 'box24_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box26, 'box26_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box27, 'box27_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box28, 'box28_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box30, 'box30_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box32, 'box32_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box34, 'box34_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box36, 'box36_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box40, 'box40_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box42, 'box42_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box46, 'box46_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box12, 'box12_f','T')||
                            pay_ca_t4_mag.convert_2_xml(substr(l_box38,1,2), 'box38_f','T')|| --Bug 8899845
                            pay_ca_t4_mag.convert_2_xml(l_box13, 'box13_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box14, 'box14_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_box61, 'box61_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_payer_nm, 'payer_nm_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code1, 'fncode1_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value1, 'fnvalue1_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code2, 'fncode2_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value2, 'fnvalue2_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code3, 'fncode3_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value3, 'fnvalue3_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_code4, 'fncode4_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_footnote_value4, 'fnvalue4_f','T')||
                            pay_ca_t4_mag.convert_2_xml(l_err_msg, 'errmsg','T')||
                            '</FAILED_T4A>'||EOL;
      end if;
      pay_core_files.write_to_magtape_lob(l_employee_xml);
      hr_utility.trace(l_employee_xml);

    exception
          when others then
             hr_utility.trace('sqleerm ' || SQLERRM);
             raise;
end get_asg_xml;


procedure get_header_xml
is
  l_header_xml_string varchar2(100);

begin

    l_header_xml_string :=
        '<T4APAPER>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10);

    pay_core_files.write_to_magtape_lob(l_header_xml_string);

end get_header_xml;


procedure get_trailer_xml
is
  l_trailer_xml_string varchar2(100);

 cursor c_get_params is
 select paa1.assignment_action_id, -- archiver asg action
        ppa1.payroll_action_id    -- archiver pact
 from  pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_assignment_actions paa1,
       pay_payroll_actions ppa1
 where ppa.payroll_action_id = paa.payroll_action_id
 and ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
 and substr(paa.serial_number,29,1) = 'Y'
 --and paa.assignment_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
 and fnd_number.canonical_to_number(substr(paa.serial_number,1,14)) = paa1.assignment_action_id
 and paa1.payroll_action_id = ppa1.payroll_action_id
 and ppa1.report_type   = 'T4A'
 and ppa1.action_type   = 'X'
 and ppa1.action_status = 'C'
 and ppa1.effective_date = ppa.effective_date;

begin

    open c_get_params;
    loop
      fetch c_get_params into g_aa_id, g_pa_id;
      exit when c_get_params%notfound;
      g_err_emp := 'Y';
      get_asg_xml;
    end loop;

    l_trailer_xml_string :=
        '</T4APAPER>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10);

    pay_core_files.write_to_magtape_lob(l_trailer_xml_string);

end get_trailer_xml;

end pay_ca_t4a_xml;

/
