--------------------------------------------------------
--  DDL for Package Body PAY_CA_T4_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_T4_XML" as
/* $Header: pycat4xml.pkb 120.18.12010000.8 2010/01/06 12:23:35 sneelapa ship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package to build procedure used for generation of T4 pdf

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   04-APR-2005  ssouresr     115.0           Created
   12-OCT-2005  ssouresr     115.1           Using XML Publisher tags
   14-OCT-2005  ssouresr     115.3           Using live employee address plus
                                             various other formatting fixes
   17-OCT-2005  ssouresr     115.4           Added employer address line 3 and
                                             also changed the tags to prevent
                                             the generation of instructions when
                                             the report is run for employers
   18-OCT-2005  ssouresr     115.5           Employee's first name will contain
                                             15 characters only
   24-OCT-2005  ssouresr     115.6           Made Instructions Template optional
                                             and also added tag for CRA approval
                                             code
   02-NOV-2005  ssouresr     115.7           Removed temporary CRA code message
   04-NOV-2005  ssouresr     115.8           Added the CRA approval code RC-05-1122
   30-NOV-2005  ssouresr     115.9           Modified package to use the core procedure
                                             pay_core_files.write_to_magtape_lob
   19-APR-2006  ssouresr     115.10          Modified package to use the function
                                             get_IANA_charset to get the character set
   25-Jul-2006  ssmukher     115.11          Added code for implementing the
                                             QPIP/PPIP taxes.
   24-OCT-2006  meshah       115.12 5527030  commented the logic that would
                                             make the ppip earnings as null.
   15-Nov-2006  ssmukher     115.13 5661166  Added code to store Null when the
                                             value of lv_ppip_insurable_earnings
                                             is 0.
   11-Jan-2007  ssmukher     115.14 5753150  Modified the cra_code value to
                                             RC-06-1122 for year 2006.
   08-Oct-2007  amigarg      115.15 6434602  Added a condition for lv_sin if null
   18-Oct-2007  sapalani     115.16 6394992  Added other info codes 81- 85
   28-nov-2007  amigarg      115.17 6653661  Modified the cra_code value to
                                             RC-07-1122 for year 2007.

   30-nov-2007  sneelapa     115.18 6434613  Modified the procedure "fetch_t4_xml"
                                             uncommented the code for making
                                             lv_ppip_insurable_earnings NULL.

   16-SEP-2008  sneelapa      115.19 7392426  Modified fetch_t4_xml procedure,
                                             In the ELSE condition for "if lv_i = 1 then"
                                             Commented the code which is passing
                                             data for BOX55(lv_employees_ppip)
                                             and BOX56(lv_ppip_insurable_earnings).

   10-nov-2008  sneelapa    115.20 7541442  Modified create_xml_string,
                                              commented the code which is writng
                                              cra code in xml file.
   14-May-2009  sapalani    115.21 8500150  Modified get_asg_xml so that it will
                                            print instructions page type T4ERPAPER.
                                            Type T4ERPAPER means report is run
                                            with Employer option.
   28-Jul-2009  aneghosh    115.22 8635769  Replaced to_number with
                                            fnd_number.canonical_to_number

   09-Dec-2009  sneelapa    115.23 9135405  Added other info codes 66 - 69
                                            Modified CURSOR c_other_info_value.
   21-Dec-2009  sneelapa    115.24 7835218  Modified Logic for calculating EMPLOYEE
                                            Insurable Earnings -- lv_ei_insurable_earnings
                                            Added get_ei_earnings_display_flag function.
   06-Jan-2010  sneelapa    115.25 7835218  Modified Logic in get_ei_earnings_display_flag
                                            procedure.  BOX24 should display data if EMP
                                            works in more than one province, in prior version
																						condition was one of the Province should be QC.
*/

PROCEDURE store_other_information(p_aa_id in number,
                                  p_prov  in varchar2)
is

cursor c_other_info_value is
select substr(fdi.user_name,27,2) code,
       fai.value                  value
from ff_archive_items         fai,
     ff_database_items        fdi,
     ff_archive_item_contexts faic,
     ff_contexts              fc
where fai.user_entity_id  = fdi.user_entity_id
and   fai.archive_item_id = faic.archive_item_id
and   fc.context_id       = faic.context_id
and   fc.context_name     = 'JURISDICTION_CODE'
and   faic.context        = p_prov
and   fai.context1        = p_aa_id
and   nvl((trim(fai.value)),'0') <> '0'
and   fdi.user_name in (
'CAEOY_T4_OTHER_INFO_AMOUNT30_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT31_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT32_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT33_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT34_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT35_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT36_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT37_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT38_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT39_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT40_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT41_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT42_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT43_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT53_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT66_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT67_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT68_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT69_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT70_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT71_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT72_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT73_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT74_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT75_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT76_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT77_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT78_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT79_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT80_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT81_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT82_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT83_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT84_PER_JD_GRE_YTD',
'CAEOY_T4_OTHER_INFO_AMOUNT85_PER_JD_GRE_YTD')
order by substr(fdi.user_name,27,2);

lv_index  number;

begin
   g_other_info_list.delete;
   lv_index := 1;

   for rec in c_other_info_value loop

     g_other_info_list(lv_index).code   := rec.code;
     g_other_info_list(lv_index).amount := rec.value;
     lv_index := lv_index + 1;

   end loop;

end;


procedure get_other_information(p_index  in     number,
                                p_code   in out nocopy varchar2,
                                p_amount in out nocopy varchar2)
is
begin

  if g_other_info_list.exists(p_index) then

    p_code   := g_other_info_list(p_index).code;
    p_amount := g_other_info_list(p_index).amount;

  else

    p_code   := null;
    p_amount := null;

  end if;

end;

-- Added get_ei_earnings_display_flag for bug 7835218.

function get_ei_earnings_display_flag (p_aa_id   in    number)
return number is

lv_ei_display_flag			 number;
begin
    lv_ei_display_flag :=1;
    hr_utility.trace('get_ei_earnings_display_flag p_aa_id :' ||p_aa_id);
    begin
         select count(1) into lv_ei_display_flag
         from 	ff_archive_items fai,
              	ff_database_items fdi
         where fai.context1 = p_aa_id
           and 	fai.user_entity_id=fdi.user_entity_id
           and 	fdi.user_name='CAEOY_PROVINCE_OF_EMPLOYMENT';

    exception
          when others then
          lv_ei_display_flag :=1;
    end;

    hr_utility.trace('lv_ei_display_flag :' ||lv_ei_display_flag);

    return lv_ei_display_flag;

end get_ei_earnings_display_flag;

procedure get_asg_xml is

 l_header_xml          varchar2(32000);
 l_trailer_xml         varchar2(32000);

 l_aa_id number;
 l_pa_id number;
 l_print varchar2(240);
 l_prov  varchar2(240);
 l_type  varchar2(240);
 l_instructions  varchar2(240);

 l_output_location  varchar2(100);
 EOL                varchar2(10);

 l_iana_charset     fnd_lookup_values.tag%type;
 l_xml_version      varchar2(100);

 cursor c_get_params is
 select paa1.assignment_action_id, -- archiver asg action
        ppa1.payroll_action_id,    -- archiver pact
        pay_ca_t4_reg.get_parameter('TYPE',ppa.legislative_parameters),
        pay_ca_t4_reg.get_parameter('PRINT',ppa.legislative_parameters),
        pay_ca_t4_reg.get_parameter('INSTRUCTIONS',ppa.legislative_parameters),
        substr(paa.serial_number,1,2)
 from  pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_assignment_actions paa1,
       pay_payroll_actions ppa1
 where ppa.payroll_action_id = paa.payroll_action_id
 and ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
 and paa.assignment_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
 and fnd_number.canonical_to_number(substr(paa.serial_number,3,14)) = paa1.assignment_action_id
 and paa1.payroll_action_id = ppa1.payroll_action_id
 and ppa1.report_type   = 'T4'
 and ppa1.action_type   = 'X'
 and ppa1.action_status = 'C'
 and ppa1.effective_date = ppa.effective_date;

 begin
         hr_utility.trace('In get_asg_xml');

         EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);

         open c_get_params;
         fetch c_get_params into
           l_aa_id,
           l_pa_id,
           l_type,
           l_print,
           l_instructions,
           l_prov;
         close c_get_params;

          hr_utility.trace('l_aa_id ' ||l_aa_id);
          hr_utility.trace('l_pa_id ' ||l_pa_id);
          hr_utility.trace('l_type '  ||l_type);
          hr_utility.trace('l_print ' ||l_print);
          hr_utility.trace('l_prov ' ||l_prov);

          l_output_location := get_outfile;

          l_iana_charset    := get_IANA_charset;
          l_xml_version     := '<?xml version="1.0" encoding="'||l_iana_charset||'" ?>'|| EOL;

          l_header_xml  := l_xml_version ||
                           '<xapi:requestset xmlns:xapi="http://xmlns.oracle.com/oxp/xapi">'||EOL||
                           '<xapi:request>'||EOL||
                           '<xapi:delivery>'||EOL||
                           '<xapi:filesystem output="'||l_output_location||'" />'||EOL||
                           '</xapi:delivery>'||EOL||
                           '<xapi:document output-type="pdf">'||EOL||
                           '<xapi:template type="pdf" location="${templateName1}">'||EOL;

          pay_core_files.write_to_magtape_lob(l_header_xml);

          fetch_t4_xml(l_aa_id,
                       l_pa_id,
                       l_type,
                       l_print,
                       l_prov);

          if --((l_type = 'T4ERPAPER') or Bug 8500150
              (l_instructions is null) then

              l_trailer_xml := '</xapi:template>'||EOL||
                               '</xapi:document>'||EOL||
                               '</xapi:request>'||EOL||
                               '</xapi:requestset>'||EOL;
          else

              l_trailer_xml := '</xapi:template>'||EOL||
                               '<xapi:template type="pdf" location="${templateName2}">'||EOL||
                               '<xapi:data />'|| EOL||
                               '</xapi:template>'||EOL||
                               '</xapi:document>'||EOL||
                               '</xapi:request>'||EOL||
                               '</xapi:requestset>'||EOL;
          end if;

          pay_core_files.write_to_magtape_lob(l_trailer_xml);

    exception
          when others then
             hr_utility.trace('sqleerm ' || SQLERRM);
             raise;
    end;


procedure fetch_t4_xml(p_aa_id  number,
                       p_pa_id  number,
                       p_type   varchar2,
                       p_print  varchar2,
                       p_prov   varchar2) is

lv_max_cpp_earning	 number;
lv_max_ei_earning 	 number;
/* Added by ssmukher for PPIP tax implementation */
lv_max_ppip_earning 	 number;
lv_t4_slip_count         number;
lv_other_info_count      number;

lv_sin                   varchar2(20);

lv_employee_last_name    varchar2(200);
lv_employee_name         varchar2(200);
lv_employee_initial      varchar2(200);
lv_employee_address1     varchar2(200);
lv_employee_address2     varchar2(200);
lv_employee_address3     varchar2(200);
lv_employee_city         varchar2(200);
lv_employee_province     varchar2(200);
lv_employee_country      varchar2(200);
lv_employee_postal_code  varchar2(10);
lv_employee_address      varchar2(10000);
address                  pay_ca_rl1_reg.primaryaddress;
lv_person_id             number;

lv_cpp_qpp_exempt        varchar2(10);
lv_ei_exempt             varchar2(10);
lv_ppip_exempt           varchar2(10);
lv_employment_code       varchar2(200);
lv_rpp_dpsp_reg_no       varchar2(200);
lv_employment_income     varchar2(200);
lv_income_tax_deducted   varchar2(200);
lv_employees_cpp         varchar2(200);
lv_employees_qpp         varchar2(200);
lv_employees_ei          varchar2(200);
lv_employees_ppip        varchar2(200);
lv_rpp_contribution      varchar2(200);
lv_pension_adjustment    varchar2(200);
lv_ei_insurable_earnings varchar2(200);
lv_ei_display_flag			 number;
lv_ppip_insurable_earnings varchar2(200);
lv_cpp_qpp_earnings      varchar2(200);
lv_union_dues            varchar2(200);
lv_charitable_donations  varchar2(200);

lv_year                  varchar2(4);
lv_employer_name         varchar2(200);
lv_employer_business_no  varchar2(200);
lv_employer_address1     varchar2(200);
lv_employer_address2     varchar2(200);
lv_employer_address3     varchar2(200);
lv_employer_city         varchar2(200);
lv_employer_province     varchar2(200);
lv_employer_country      varchar2(200);
lv_employer_postal_code  varchar2(10);
lv_employer_address      varchar2(10000);
lv_gre_name              varchar2(100);

lv_other_code1           varchar2(3);
lv_other_amount1         varchar2(50);
lv_other_code2           varchar2(3);
lv_other_amount2         varchar2(50);
lv_other_code3           varchar2(3);
lv_other_amount3         varchar2(50);
lv_other_code4           varchar2(3);
lv_other_amount4         varchar2(50);
lv_other_code5           varchar2(3);
lv_other_amount5         varchar2(50);
lv_other_code6           varchar2(3);
lv_other_amount6         varchar2(50);
lv_code                  varchar2(3);
lv_amount                varchar2(50);

lv_i                     number;
lv_j                     number;
lv_k                     number;

l_employee_xml           varchar2(32767);

cursor cur_max_cpp_earning is
select information_value
from pay_ca_legislation_info
where information_type = 'MAX_CPP_EARNINGS'
and to_date(lv_year ||'/01/01','YYYY/MM/DD')
               between start_date and end_date;

cursor cur_max_ei_earning is
select information_value
from pay_ca_legislation_info
where information_type = 'MAX_EI_EARNINGS'
and to_date(lv_year ||'/01/01','YYYY/MM/DD')
               between start_date and end_date;

cursor cur_max_ppip_earning is
select information_value
from pay_ca_legislation_info
where information_type = 'MAX_PPIP_EARNINGS'
and to_date(lv_year ||'/01/01','YYYY/MM/DD')
               between start_date and end_date;

cursor cur_gre_name is
select name
from hr_all_organization_units hou,
     pay_assignment_actions    paa
where paa.assignment_action_id = p_aa_id
and   paa.tax_unit_id    = hou.organization_id;

begin
      lv_year :=
      pay_ca_archive_utils.get_archive_value(p_pa_id,
                        'CAEOY_TAXATION_YEAR');        -- year

      lv_employer_name :=
      pay_ca_archive_utils.get_archive_value(p_pa_id,
                        'CAEOY_EMPLOYER_NAME');        -- employer name

      if p_print = 'Y' then

         lv_employer_address1 :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_ADDRESS_LINE1');  -- employer address1

         lv_employer_address2 :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_ADDRESS_LINE2');  -- employer address2

         lv_employer_address3 :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_ADDRESS_LINE3');  -- employer address3

         lv_employer_city :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_CITY');  -- employer_city

         lv_employer_province :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_PROVINCE');  -- employer_province

         lv_employer_country :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_COUNTRY');  -- employer_country

         lv_employer_postal_code :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_POSTAL_CODE');  -- employer_postal_code


         if ((lv_employer_address2 is null) and
             (lv_employer_address3 is null)) then

             lv_employer_address := lv_employer_address1||'\r'||
                                    lv_employer_city||'  '||lv_employer_province||'  '||
                                    lv_employer_country||'  '||lv_employer_postal_code;

         else
             lv_employer_address := lv_employer_address1||'\r'||
                                    lv_employer_address2||' '||lv_employer_address3||'\r'||
                                    lv_employer_city||'  '||lv_employer_province||'  '||
                                    lv_employer_country||'  '||lv_employer_postal_code;
         end if;

      else

         open cur_gre_name;
         fetch cur_gre_name into lv_gre_name;
         close cur_gre_name;

      end if;


      if p_type = 'T4ERPAPER' then

         lv_employer_business_no   :=
         pay_ca_archive_utils.get_archive_value(p_pa_id,
                           'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER');  -- business number
      end if;

      lv_sin :=
      pay_ca_archive_utils.get_archive_value(p_aa_id,
                        'CAEOY_EMPLOYEE_SIN');        -- sin

      -- changes started for bug 6434602
      if lv_sin is null then
         lv_sin := '000000000';
      end if;
      -- changes ended for bug 6434602
      lv_sin := ltrim(rtrim(replace(lv_sin, ' ')));
      lv_sin := substr(lv_sin,1,3)||' '||substr(lv_sin,4,3)||' '||substr(lv_sin,7,3);

      lv_employee_name :=
      substr(pay_ca_archive_utils.get_archive_value(p_aa_id,
                        'CAEOY_EMPLOYEE_FIRST_NAME'),1,15); -- employee_name

      lv_employee_initial :=
      pay_ca_archive_utils.get_archive_value(p_aa_id,
                        'CAEOY_EMPLOYEE_INITIAL');    -- employee_initial

      if lv_employee_initial is not null then
         lv_employee_initial := upper(substr(lv_employee_initial,1,1));
      end if;

      lv_employee_last_name :=
      upper(pay_ca_archive_utils.get_archive_value(p_aa_id,
                        'CAEOY_EMPLOYEE_LAST_NAME'));  -- employee_last_name


      lv_person_id :=  fnd_number.canonical_to_number(pay_ca_archive_utils.get_archive_value(p_aa_id,
                                 'CAEOY_PERSON_ID'));

      address := pay_ca_rl1_reg.get_primary_address(lv_person_id, sysdate());

      lv_employee_address1    := substr(address.addr_line_1,1,44);
      lv_employee_address2    := substr(address.addr_line_2,1,44);
      lv_employee_address3    := substr(address.addr_line_3,1,44);
      lv_employee_city        := address.city;
      lv_employee_province    := address.province;
      lv_employee_postal_code := address.postal_code;
      lv_employee_country     := address.addr_line_5;

      if ((lv_employee_address2 is null) and
          (lv_employee_address3 is null)) then

         lv_employee_address := lv_employee_address1||'\r'||
                                lv_employee_city||'  '||lv_employee_province||'  '||
                                lv_employee_country||'  '||lv_employee_postal_code;
      else

         lv_employee_address := lv_employee_address1||'\r'||
                                lv_employee_address2||' '||lv_employee_address3||'\r'||
                                lv_employee_city||'  '||lv_employee_province||'  '||
                                lv_employee_country||'  '||lv_employee_postal_code;
      end if;


      lv_cpp_qpp_exempt :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_CPP_QPP_EXEMPT');      -- cpp_qpp_exempt

      lv_ei_exempt :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_EI_EXEMPT');           -- ei_exempt


      lv_employment_code :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_EMPLOYMENT_CODE');      -- employment_code

      lv_rpp_dpsp_reg_no :=
      pay_ca_archive_utils.get_archive_value(p_aa_id,
                        'CAEOY_T4_EMPLOYEE_REGISTRATION_NO'); -- rpp_dpsp_reg_no

      lv_employment_income :=
      pay_ca_archive_utils.get_archive_value(p_aa_id,p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_GROSS_EARNINGS_PER_JD_GRE_YTD');  -- employment_income

      if fnd_number.canonical_to_number(lv_employment_income) = 0 then
         lv_employment_income := null;
      end if;

      lv_income_tax_deducted :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_FED_WITHHELD_PER_JD_GRE_YTD');   -- income_tax_deducted

      if fnd_number.canonical_to_number(lv_income_tax_deducted) = 0 then
         lv_income_tax_deducted := null;
      end if;

      lv_employees_cpp :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_CPP_EE_WITHHELD_PER_JD_GRE_YTD');  -- employees_cpp

      if fnd_number.canonical_to_number(lv_employees_cpp) = 0 then
         lv_employees_cpp := null;
      end if;

      lv_employees_qpp :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_QPP_EE_WITHHELD_PER_JD_GRE_YTD');  -- employees_qpp

      if fnd_number.canonical_to_number(lv_employees_qpp) = 0 then
         lv_employees_qpp := null;
      end if;

      lv_employees_ei :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD');  -- employees_ei

      if fnd_number.canonical_to_number(lv_employees_ei) = 0 then
         lv_employees_ei := null;
      end if;

     /* Added by ssmukher for including PPIP  taxes */
      if p_prov = 'QC' then

         lv_ppip_exempt :=
         pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                          'JURISDICTION_CODE',
                          'CAEOY_PPIP_EXEMPT');           -- ppip_exempt

         lv_employees_ppip :=
         pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                           'JURISDICTION_CODE',
                           'CAEOY_PPIP_EE_WITHHELD_PER_JD_GRE_YTD');  -- employees_ppip

         if fnd_number.canonical_to_number(lv_employees_ppip) = 0 then
            lv_employees_ppip := null;
         end if;

         open cur_max_ppip_earning;
         fetch cur_max_ppip_earning
         into lv_max_ppip_earning;
         close cur_max_ppip_earning;

          lv_ppip_insurable_earnings :=
          pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                            'JURISDICTION_CODE',
                            'CAEOY_PPIP_EE_TAXABLE_PER_JD_GRE_YTD');  -- ppip_insurable_earnings

-- commented by sneelapa for bug 6434613
/*         if fnd_number.canonical_to_number(lv_ppip_insurable_earnings) = 0 then
               lv_ppip_insurable_earnings := null;
         end if;
*/

/* commenting the below logic as per bug 5527030

         if fnd_number.canonical_to_number(lv_ppip_insurable_earnings)  = 0 then
             lv_ppip_insurable_earnings := null;

         elsif fnd_number.canonical_to_number(lv_ppip_insurable_earnings) >= lv_max_ppip_earning then
             lv_ppip_insurable_earnings := null;

         elsif fnd_number.canonical_to_number(lv_employment_income) = fnd_number.canonical_to_number(lv_ppip_insurable_earnings) then
             lv_ppip_insurable_earnings := null;

         end if;

End changes for bug 5527030 */

	-- calling the commented code for bug 5527030 above,
	--	for resolving issue for bug 6434613
	--	changes for bug 6434613 starts here.

         if fnd_number.canonical_to_number(lv_ppip_insurable_earnings)  = 0 then
             lv_ppip_insurable_earnings := null;

         elsif fnd_number.canonical_to_number(lv_ppip_insurable_earnings) >= lv_max_ppip_earning then
             lv_ppip_insurable_earnings := null;

         elsif fnd_number.canonical_to_number(lv_employment_income) = fnd_number.canonical_to_number(lv_ppip_insurable_earnings) then
             lv_ppip_insurable_earnings := null;

         end if;
	--	changes for bug 6434613 ends here.

      else
           lv_ppip_exempt := NULL;
           lv_employees_ppip := NULL;
           lv_ppip_insurable_earnings := null;
      end if;

      lv_rpp_contribution :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_T4_BOX20_PER_JD_GRE_YTD');  -- rpp_contribution

      if fnd_number.canonical_to_number(lv_rpp_contribution) = 0 then
         lv_rpp_contribution := null;
      end if;

      lv_pension_adjustment :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_T4_BOX52_PER_JD_GRE_YTD');  -- pension_adjustment

      if fnd_number.canonical_to_number(lv_pension_adjustment) = 0 then
         lv_pension_adjustment := null;
      end if;

      lv_ei_insurable_earnings :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD');  -- ei_insurable_earnings

      open cur_max_ei_earning;
      fetch cur_max_ei_earning
      into lv_max_ei_earning;
      close cur_max_ei_earning;

-- Modification for bug 7835218 starts here.
			lv_ei_display_flag :=1;

			if get_ei_earnings_display_flag(p_aa_id) = 1 then
-- Added this IF condition to display EI Insurable Earnings in case
--  EMPLOYEE worked in QC and NON QC province in particular year.

-- Modification for bug 7835218 ends here.
        if fnd_number.canonical_to_number(lv_ei_insurable_earnings)  = 0 then
           lv_ei_insurable_earnings := null;

        elsif fnd_number.canonical_to_number(lv_ei_insurable_earnings) >= lv_max_ei_earning then
           lv_ei_insurable_earnings := null;

        elsif fnd_number.canonical_to_number(lv_employment_income) = fnd_number.canonical_to_number(lv_ei_insurable_earnings) then
           lv_ei_insurable_earnings := null;

        end if;
			end if; --	if lv_ei_display_flag = 1 then

-- Modification for bug 7835218 starts here.
        if fnd_number.canonical_to_number(lv_ei_insurable_earnings)  = 0 then
           lv_ei_insurable_earnings := null;
        end if;
-- Modification for bug 7835218 ends here.

      if p_prov =  'QC' then

         lv_cpp_qpp_earnings :=
         pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                           'JURISDICTION_CODE',
                           'CAEOY_QPP_EE_TAXABLE_PER_JD_GRE_YTD');
      else
         lv_cpp_qpp_earnings :=
         pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                           'JURISDICTION_CODE',
                           'CAEOY_CPP_EE_TAXABLE_PER_JD_GRE_YTD');
      end if;

      open cur_max_cpp_earning;
      fetch cur_max_cpp_earning
      into lv_max_cpp_earning;
      close cur_max_cpp_earning;

      if fnd_number.canonical_to_number(lv_cpp_qpp_earnings)  = 0 then
         lv_cpp_qpp_earnings := null;

      elsif fnd_number.canonical_to_number(lv_cpp_qpp_earnings) >= lv_max_cpp_earning then
         lv_cpp_qpp_earnings := null;

      elsif fnd_number.canonical_to_number(lv_employment_income) = fnd_number.canonical_to_number(lv_cpp_qpp_earnings) then
         lv_cpp_qpp_earnings := null;

      end if;

      lv_union_dues :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_T4_BOX44_PER_JD_GRE_YTD');  -- union_dues

      if fnd_number.canonical_to_number(lv_union_dues) = 0 then
         lv_union_dues := null;
      end if;

      lv_charitable_donations :=
      pay_ca_archive_utils.get_archive_value(p_aa_id, p_prov,
                        'JURISDICTION_CODE',
                        'CAEOY_T4_BOX46_PER_JD_GRE_YTD');  -- charitable_donations

      if fnd_number.canonical_to_number(lv_charitable_donations) = 0 then
         lv_charitable_donations := null;
      end if;

      store_other_information (p_aa_id, p_prov);

      lv_k             := 0;
      lv_t4_slip_count := ceil(g_other_info_list.count/6);

      if lv_t4_slip_count = 0 then
         lv_t4_slip_count := 1;
      end if;

      for lv_i in 1..lv_t4_slip_count
      loop

          lv_other_info_count := lv_i + lv_k;

          for lv_j in lv_other_info_count..(lv_other_info_count + 5)
          loop

              get_other_information (lv_j,
                                     lv_code,
                                     lv_amount);

              if lv_j = lv_other_info_count then

                 lv_other_code1   := lv_code;
                 lv_other_amount1 := lv_amount;

              elsif lv_j = (lv_other_info_count + 1) then

                 lv_other_code2   := lv_code;
                 lv_other_amount2 := lv_amount;

              elsif lv_j = (lv_other_info_count + 2) then

                 lv_other_code3   := lv_code;
                 lv_other_amount3 := lv_amount;

              elsif lv_j = (lv_other_info_count + 3) then

                 lv_other_code4   := lv_code;
                 lv_other_amount4 := lv_amount;

              elsif lv_j = (lv_other_info_count + 4) then

                 lv_other_code5   := lv_code;
                 lv_other_amount5 := lv_amount;

              elsif lv_j = (lv_other_info_count + 5) then

                 lv_other_code6   := lv_code;
                 lv_other_amount6 := lv_amount;

              end if;

          end loop;

          lv_k := lv_k + 5;

          if lv_i = 1 then

            l_employee_xml :=  create_xml_string(lv_employer_name,
                                                 lv_employer_business_no,
                                                 lv_employer_address,
                                                 lv_employee_name,
                                                 lv_employee_last_name,
                                                 lv_employee_initial,
                                                 lv_employee_address,
                                                 lv_sin,
                                                 lv_cpp_qpp_exempt,
                                                 lv_ei_exempt,
                                                 p_prov,
                                                 lv_employment_code,
                                                 lv_rpp_dpsp_reg_no,
                                                 lv_employment_income,
                                                 lv_employees_cpp,
                                                 lv_employees_qpp,
                                                 lv_employees_ei,
                                                 lv_rpp_contribution,
                                                 lv_pension_adjustment,
                                                 lv_income_tax_deducted,
                                                 lv_ei_insurable_earnings,
                                                 lv_cpp_qpp_earnings,
                                                 lv_union_dues,
                                                 lv_charitable_donations,
                                                 lv_other_code1,
                                                 lv_other_amount1,
                                                 lv_other_code2,
                                                 lv_other_amount2,
                                                 lv_other_code3,
                                                 lv_other_amount3,
                                                 lv_other_code4,
                                                 lv_other_amount4,
                                                 lv_other_code5,
                                                 lv_other_amount5,
                                                 lv_other_code6,
                                                 lv_other_amount6,
                                                 lv_year,
                                                 lv_ppip_exempt,
                                                 lv_employees_ppip,
                                                 lv_ppip_insurable_earnings,
                                                 lv_gre_name);


          else

            l_employee_xml := l_employee_xml ||
                                 create_xml_string(lv_employer_name,
                                                   lv_employer_business_no,
                                                   lv_employer_address,
                                                   lv_employee_name,
                                                   lv_employee_last_name,
                                                   lv_employee_initial,
                                                   lv_employee_address,
                                                   lv_sin,
                                                   '',
                                                   '',
                                                   p_prov,
                                                   lv_employment_code,
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   '',
                                                   lv_other_code1,
                                                   lv_other_amount1,
                                                   lv_other_code2,
                                                   lv_other_amount2,
                                                   lv_other_code3,
                                                   lv_other_amount3,
                                                   lv_other_code4,
                                                   lv_other_amount4,
                                                   lv_other_code5,
                                                   lv_other_amount5,
                                                   lv_other_code6,
                                                   lv_other_amount6,
                                                   lv_year,
                                                   lv_ppip_exempt,
                                                   --bug 7392426 fix start
                                                   --lv_employees_ppip,
                                                   '',
                                                   --lv_ppip_insurable_earnings,
                                                   '',
                                                   --bug 7392426 fix end
                                                   lv_gre_name);

          end if;

          lv_other_code1   := null;
          lv_other_amount1 := null;
          lv_other_code2   := null;
          lv_other_amount2 := null;
          lv_other_code3   := null;
          lv_other_amount3 := null;
          lv_other_code4   := null;
          lv_other_amount4 := null;
          lv_other_code5   := null;
          lv_other_amount5 := null;
          lv_other_code6   := null;
          lv_other_amount6 := null;

      end loop;

      pay_core_files.write_to_magtape_lob(l_employee_xml);

   exception
        when others then
           hr_utility.trace('sqleerm '|| sqlerrm);
           hr_utility.raise_error;
end;


function create_xml_string (p_employer_name       varchar2,
                            p_employer_bn         varchar2,
                            p_employer_addr       varchar2,
                            p_employee_name       varchar2,
                            p_employee_last_name  varchar2,
                            p_employee_init       varchar2,
                            p_employee_addr       varchar2,
                            p_sin                 varchar2,
                            p_cpp_qpp_exempt      varchar2,
                            p_ei_exempt           varchar2,
                            p_employment_prov     varchar2,
                            p_employment_code     varchar2,
                            p_registration_number varchar2,
                            p_employment_income   varchar2,
                            p_cpp_contributions   varchar2,
                            p_qpp_contributions   varchar2,
                            p_ei_contributions    varchar2,
                            p_rpp_contributions   varchar2,
                            p_pension_adjustment  varchar2,
                            p_tax_deducted        varchar2,
                            p_ei_earnings         varchar2,
                            p_cpp_qpp_earnings    varchar2,
                            p_union_dues          varchar2,
                            p_charitable_donations varchar2,
                            p_other_code1         varchar2,
                            p_other_amount1       varchar2,
                            p_other_code2         varchar2,
                            p_other_amount2       varchar2,
                            p_other_code3         varchar2,
                            p_other_amount3       varchar2,
                            p_other_code4         varchar2,
                            p_other_amount4       varchar2,
                            p_other_code5         varchar2,
                            p_other_amount5       varchar2,
                            p_other_code6         varchar2,
                            p_other_amount6       varchar2,
                            p_year                varchar2,
                            p_ppip_exempt         varchar2,
                            p_ppip_contributions  varchar2,
                            p_ppip_earnings       varchar2,
                            p_gre_name            varchar2)
return varchar2 is

l_single_xml       varchar2(32767);

begin

    l_single_xml :=
    '<xapi:data>'||fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    '<T4>'||fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employee_name, 'snm','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employee_last_name, 'gvn_nm','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employee_init, 'init','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employee_addr, 'empe_addr','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employer_name, 'empr_nm','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employer_addr, 'empr_addr','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_gre_name, 'gre','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employer_bn, 'bn','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_sin, 'sin','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_cpp_qpp_exempt, 'cpp_qpp_xmpt_cd','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ppip_exempt, 'ppip_xmpt_cd','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ei_exempt, 'ei_xmpt_cd','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_year, 'tx_yr','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employment_prov, 'empt_prov_cd','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employment_code, 'empt_cd','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_employment_income, 'empt_incamt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_registration_number, 'rpp_dpsp_rgst_nbr','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_cpp_contributions, 'cpp_cntrb_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_qpp_contributions, 'qpp_cntrb_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ei_contributions, 'empe_eip_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_rpp_contributions, 'rpp_cntrb_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_pension_adjustment, 'padj_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_tax_deducted, 'itx_ddct_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ei_earnings, 'ei_insu_ern_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_cpp_qpp_earnings, 'cpp_qpp_ern_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_union_dues, 'unn_dues_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_charitable_donations, 'chrty_dons_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ppip_contributions, 'ppip_cntrb_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_ppip_earnings, 'ppip_insu_ern_amt','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code1, 'oth_code1','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount1, 'oth_amnt1','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code2, 'oth_code2','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount2, 'oth_amnt2','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code3, 'oth_code3','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount3, 'oth_amnt3','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code4, 'oth_code4','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount4, 'oth_amnt4','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code5, 'oth_code5','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount5, 'oth_amnt5','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_code6, 'oth_code6','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    pay_ca_t4_mag.convert_2_xml(p_other_amount6, 'oth_amnt6','T','','Y')||
    fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    -- Commented below code by sneelapa for bug 7541442
    --pay_ca_t4_mag.convert_2_xml('RC-07-1122', 'cra_code','T','','Y')||
    --fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    '</T4>'||fnd_global.local_chr(13)||fnd_global.local_chr(10)||
    '</xapi:data>'||fnd_global.local_chr(13)||fnd_global.local_chr(10);

    hr_utility.trace('XML string :' ||l_single_xml);

    return l_single_xml;

    exception
          when others then
            hr_utility.trace('sqleerm ' || sqlerrm);
            hr_utility.raise_error;

end create_xml_string;


procedure get_header_xml
is
  l_header_xml_string varchar2(32000);

begin

    l_header_xml_string :=
        '<EMPLOYEES>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10);

/*    '<?xml version="1.0" encoding="UTF-8" ?>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10)||
        '<EMPLOYEES>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10);
 */
    pay_core_files.write_to_magtape_lob(l_header_xml_string);

end get_header_xml;


procedure get_trailer_xml
is
  l_trailer_xml_string varchar2(32000);

begin

    l_trailer_xml_string :=
        '</EMPLOYEES>'||
         fnd_global.local_chr(13)||fnd_global.local_chr(10);

    pay_core_files.write_to_magtape_lob(l_trailer_xml_string);

end get_trailer_xml;

function get_outfile return VARCHAR2 is
     TEMP_UTL varchar2(512);
     l_log    varchar2(100);
     l_out    varchar2(100);
begin
  hr_utility.trace('In get_out_file,g_temp_dir  ' ||g_temp_dir );

   if g_temp_dir  is null then
      -- use first entry of utl_file_dir as the g_temp_dir
       select translate(ltrim(value),',',' ')
        into TEMP_UTL
        from v$parameter
       where name = 'utl_file_dir';

      if (instr(TEMP_UTL,' ') > 0 and TEMP_UTL is not null) then
        select substrb(TEMP_UTL, 1, instr(TEMP_UTL,' ') - 1)
          into g_temp_dir
          from dual ;
      elsif (TEMP_UTL is not null) then
           g_temp_dir := TEMP_UTL;
      end if;

      if (TEMP_UTL is null or g_temp_dir is null ) then
         raise no_data_found;
      end if;
   end if;
   hr_utility.trace('In get_out_file,g_temp_dir  ' ||g_temp_dir );

   FND_FILE.get_names(l_log,l_out);

   l_out := g_temp_dir ||'/'||l_out;
   hr_utility.trace('In get_out_file,l_out  ' ||l_out );

   return l_out;

   exception
      when no_data_found then
         return null;
      when others then
         return null;
end get_outfile;

function get_IANA_charset return VARCHAR2 is
cursor csr_get_iana_charset is
select tag
from fnd_lookup_values
where lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
and lookup_code = SUBSTR(USERENV('LANGUAGE'),
                         INSTR(USERENV('LANGUAGE'), '.') + 1)
and language = 'US';

lv_iana_charset fnd_lookup_values.tag%type;

begin
    open csr_get_iana_charset;
        fetch csr_get_iana_charset into lv_iana_charset;
    close csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    return (lv_iana_charset);

end get_IANA_charset;


end pay_ca_t4_xml;

/
