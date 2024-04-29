--------------------------------------------------------
--  DDL for Package Body PER_FR_ELECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_ELECTION" as
/* $Header: pefrphmm.pkb 115.6 2003/08/04 03:17:59 abhaduri ship $ */
Procedure process(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
                  p_company_id    IN NUMBER,
                        p_establishment_id  IN NUMBER,
                        p_reporting_est_id  IN NUMBER,
                        p_effective_date    IN VARCHAR2) is
l_effective_date date;
--
l_est_head_title varchar2(1000);
l_est_head_underline varchar2(1000);
l_est_head_rec varchar2(1000);
l_est_head_log varchar2(1000);
--
l_person_title varchar2(1000);
l_person_underline varchar2(1000);
l_person_rec varchar2(1000);
l_person_log varchar2(1000);
--
l_rep_est_title varchar2(1000);
l_rep_est_underline varchar2(1000);
--
l_start_rec varchar2(1000);
l_est_footer_rec varchar2(1000);
l_end_rec varchar2(1000);
--
l_person_count number;
l_error_count number;
l_warning_count number;
l_error_flag varchar2(30);
l_warning_flag varchar2(30);
--
REPORTING_SIRET_LEN number := 14;
SIRET_LEN number := 14;
NAF_CODE_LEN number := 4;
ESTAB_NAME_LEN number := 50;
ADDRESS_LINE1_LEN number := 32;
ADDRESS_LINE2_LEN number := 32;
INSEE_CODE_LEN number := 5;
TOWN_LEN number := 26;
POSTAL_CODE_LEN number := 5;
CITY_LEN number := 26;
EMPLOYER_TYPE_LEN number := 1;
SS_NUMBER_LEN number := 13;
SS_KEY_LEN number := 2;
DATE_OF_BIRTH_LEN number := 6;
DEPARTMENT_OF_BIRTH_LEN number := 2;
PLACE_OF_BIRTH_LEN number := 26;
BIRTH_NAME_LEN number := 30;
FIRST_NAME_LEN number := 20;
LAST_NAME_LEN number := 30;
ELECTORAL_COLLEGE_LEN number := 1;
SECTION_LEN number := 1;
VOTING_PLACE_LEN number := 1;
--
REPORTING_SIRET varchar2(80);
SIRET varchar2(80);
NAF_CODE varchar2(80);
ESTAB_NAME varchar2(80);
ADDRESS_LINE2 varchar2(80);
ADDRESS_LINE1 varchar2(80);
INSEE_CODE varchar2(80);
TOWN varchar2(80);
POSTAL_CODE varchar2(80);
CITY varchar2(80);
EMPLOYER_TYPE varchar2(80);
SS_NUMBER varchar2(80);
SS_KEY varchar2(80);
DATE_OF_BIRTH varchar2(80);
DEPARTMENT_OF_BIRTH varchar2(80);
PLACE_OF_BIRTH varchar2(80);
BIRTH_NAME varchar2(80);
FIRST_NAME varchar2(80);
LAST_NAME varchar2(80);
ELECTORAL_COLLEGE varchar2(80);
SECTION varchar2(80);
VOTING_PLACE varchar2(80);
--
REPORTING_SIRET_LOG number;
SIRET_LOG number;
NAF_CODE_LOG number;
ESTAB_NAME_LOG number;
ADDRESS_LINE2_LOG number;
ADDRESS_LINE1_LOG number;
INSEE_CODE_LOG number;
TOWN_LOG number;
POSTAL_CODE_LOG number;
CITY_LOG number;
EMPLOYER_TYPE_LOG number;
SS_NUMBER_LOG number;
SS_KEY_LOG number;
DATE_OF_BIRTH_LOG number;
DEPARTMENT_OF_BIRTH_LOG number;
PLACE_OF_BIRTH_LOG number;
BIRTH_NAME_LOG number;
FIRST_NAME_LOG number;
LAST_NAME_LOG number;
ELECTORAL_COLLEGE_LOG number;
SECTION_LOG number;
VOTING_PLACE_LOG number;
--
Cursor get_reporting_establishment is
Select ORG_INFORMATION2 SIRET
From hr_organization_information
Where organization_id = p_reporting_est_id
and   org_information_context = 'FR_ESTAB_INFO';
--
Cursor get_establishments is
Select rpad(substr(ORG.NAME,1,ESTAB_NAME_LEN),ESTAB_NAME_LEN,' ') ESTAB_NAME
,      ORG.ORGANIZATION_ID ESTABLISHMENT_ID
,      EST.ORG_INFORMATION2 SIRET
,      rpad(nvl(substr(EST.ORG_INFORMATION3,1,NAF_CODE_LEN),' '),NAF_CODE_LEN,' ') NAF_CODE
,      decode(EST.ORG_INFORMATION7,'INDUSTRY','1',
                                   'COMMERCE','2',
                                   'AGRICULTURAL','3',
                                   'MANAGEMENT','5','4') SECTION
,        rpad(nvl(substr(LOC.ADDRESS_LINE_1,1,ADDRESS_LINE1_LEN),' '),ADDRESS_LINE1_LEN,' ') ADDRESS_LINE1
,        rpad(nvl(substr(LOC.ADDRESS_LINE_2,1,ADDRESS_LINE2_LEN),' '),ADDRESS_LINE2_LEN,' ') ADDRESS_LINE2
,        rpad(nvl(substr(LOC.REGION_2,1,INSEE_CODE_LEN),' '),INSEE_CODE_LEN,' ') INSEE_CODE
,        rpad(nvl(substr(LOC.REGION_3,1,TOWN_LEN),' '),TOWN_LEN,' ') TOWN
,        rpad(nvl(substr(LOC.POSTAL_CODE,1,POSTAL_CODE_LEN),' '),POSTAL_CODE_LEN,' ') POSTAL_CODE
,        rpad(nvl(substr(LOC.TOWN_OR_CITY,1,CITY_LEN),' '),CITY_LEN,' ') CITY
From hr_organization_information est
,    hr_all_organization_units org
,    hr_locations loc
Where ((p_establishment_id is not null
   And est.organization_id = p_establishment_id)
Or    (p_establishment_id is null
   And to_number(org_information1) = p_company_id))
And est.org_information_context = 'FR_ESTAB_INFO'
And org.organization_id = est.organization_id
And org.location_id = loc.location_id (+)
order by ORG.NAME;
--
Cursor get_person(p_establishment_id number) is
Select
 rpad(nvl(substr(per.NATIONAL_IDENTIFIER,1,SS_NUMBER_LEN),' '),SS_NUMBER_LEN,' ') SS_NUMBER
,rpad(nvl(substr(per.NATIONAL_IDENTIFIER,SS_NUMBER_LEN+1,SS_KEY_LEN),' '),SS_KEY_LEN,' ') SS_KEY
,  per.DATE_OF_BIRTH DATE_OF_BIRTH
,  rpad(nvl(substr(nvl(Per.PER_INFORMATION1,per.last_name),1,BIRTH_NAME_LEN) ,' '),BIRTH_NAME_LEN,' ') BIRTH_NAME
,  rpad(nvl(substr(Per.REGION_OF_BIRTH,1,DEPARTMENT_OF_BIRTH_LEN) ,' '),DEPARTMENT_OF_BIRTH_LEN,' ') DEPARTMENT_OF_BIRTH
,  rpad(nvl(substr(Per.TOWN_OF_BIRTH,1,PLACE_OF_BIRTH_LEN) ,' '),PLACE_OF_BIRTH_LEN,' ') PLACE_OF_BIRTH
,  rpad(nvl(substr(Per.FIRST_NAME,1,FIRST_NAME_LEN),' '),FIRST_NAME_LEN,' ') FIRST_NAME
,  rpad(nvl(substr(Per.LAST_NAME,1,LAST_NAME_LEN),' '),LAST_NAME_LEN,' ') LAST_NAME
,  nvl(SCL.SEGMENT2 ,' ') EMPLOYEE_CATEGORY
-- Modified to select contract as 'active' for CWK
,  decode(asg.assignment_type, 'C','A-ACTIVE', nvl(CON.STATUS ,' ')) CONTRACT_STATUS
,  rpad(nvl(substr(ADDR.ADDRESS_LINE1,1,ADDRESS_LINE1_LEN),' '),ADDRESS_LINE1_LEN,' ') ADDRESS_LINE1
,  rpad(nvl(substr(ADDR.ADDRESS_LINE2,1,ADDRESS_LINE2_LEN),' '),ADDRESS_LINE2_LEN,' ') ADDRESS_LINE2
,  rpad(nvl(substr(ADDR.REGION_2,1,INSEE_CODE_LEN),' '),INSEE_CODE_LEN,' ') INSEE_CODE
,  rpad(nvl(substr(ADDR.REGION_3,1,TOWN_LEN),' '),TOWN_LEN,' ') TOWN
,  rpad(nvl(substr(ADDR.POSTAL_CODE,1,POSTAL_CODE_LEN),' '),POSTAL_CODE_LEN,' ') POSTAL_CODE
,  rpad(nvl(substr(ADDR.TOWN_OR_CITY,1,CITY_LEN),' '),CITY_LEN,' ') CITY
,  nvl(Pei.PEI_INFORMATION1,' ') EXCLUDE_FLAG
,  nvl(substr(Pei.PEI_INFORMATION2,1,1),'1') ELECTORAL_COLLEGE
,  nvl(substr(Pei.PEI_INFORMATION3,1,1),'1') VOTING_PLACE
from per_all_people_f per
,    per_all_assignments_f asg
,    per_assignment_status_types ast
,    hr_soft_coding_keyflex scl
,    per_contracts_f con
,    per_addresses addr
,    per_people_extra_info pei
where asg.establishment_id = p_establishment_id
and   asg.primary_flag = 'Y'
and   l_effective_date
        between asg.effective_start_date and asg.effective_end_date
-- modified to include CWK's assignment
and   asg.assignment_type in  ('E','C')
and   asg.assignment_status_type_id = ast.assignment_status_type_id
-- modified to include CWK's assignment status
and   ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN', 'ACTIVE_CWK', 'SUSP_CWK_ASG')
and   asg.contract_id = con.contract_id(+)
and   l_effective_date
   between nvl(con.effective_start_date,l_effective_date)
   and     nvl(con.effective_end_date,l_effective_date)
and   asg.person_id = per.person_id
and   l_effective_date
        between per.effective_start_date and per.effective_end_date
and   asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id (+)
and   per.person_id = addr.person_id (+)
and   addr.primary_flag  (+) = 'Y'
and   per.person_id = pei.person_id(+)
and   pei.pei_information_category(+) = 'FR_WORKERS_ELECTION'
order by per.FULL_NAME;
--
function decode_lookup(p_lookup_type varchar2
                      ,p_lookup_code varchar2) return varchar2 is
begin
   return p_lookup_code;
end;
--
Procedure mandatory_check(p_field varchar2,p_value varchar2) is
Begin
        If replace(p_value,' ','') is null then
                Fnd_message.set_name('PER'
                                    ,'HR_7449_PLK_COLUMN_NULL');
                Fnd_message.set_token('COLUMN_NAME'
                                     ,p_field);
                fnd_file.put_line(FND_FILE.LOG,
                                        l_error_flag ||': '|| fnd_message.get);
                l_error_count := l_error_count + 1;
        end if;
end;
--
Procedure naf_code_check(p_field varchar2,p_value varchar2) is
Begin
        If substr(p_value,1,1) between '1' and '9'
        and substr(p_value,2,1) between '1' and '9'
        and substr(p_value,3,1) between '1' and '9'
        and substr(p_value,4,1) between 'A' and 'Z' then
                null;
        else
                Fnd_message.set_name('PER'
                                                ,'HR_7944_CHECK_FMT_BAD_FORMAT');
--
                fnd_file.put_line(FND_FILE.LOG,
                                        l_warning_flag ||': '|| fnd_message.get ||' : '||p_field);
                l_warning_count := l_warning_count + 1;
        end if;
end;
--
Procedure election_data_check(p_field varchar2
                             ,p_election_college varchar2
                             ,p_voting_place varchar2) is
Begin
        If p_election_college = '2' and p_voting_place = '2' then
                Fnd_message.set_name('PER','HR_7944_CHECK_FMT_BAD_FORMAT');
--
                fnd_file.put_line(FND_FILE.LOG,
                                        l_warning_flag ||': '|| fnd_message.get ||' : '||p_field);
                l_warning_count := l_warning_count + 1;
        end if;
end;
--
begin
l_effective_date := fnd_date.canonical_to_date(p_effective_date);
--
l_error_flag := decode_lookup('FR_WORKERS_ELECTION','ERROR');
l_warning_flag := decode_lookup('FR_WORKERS_ELECTION','WARNING');
l_error_count := 0;
l_warning_count := 0;
--
--
-- Reporting Establishment Data
REPORTING_SIRET := decode_lookup('FR_WORKERS_ELECTION','REPORTING_SIRET');
--
REPORTING_SIRET_LOG := greatest(length(REPORTING_SIRET),REPORTING_SIRET_LEN);
--
-- Establishment Heading Data
SIRET := decode_lookup('FR_WORKERS_ELECTION','SIRET');
NAF_CODE := decode_lookup('FR_WORKERS_ELECTION','NAF_CODE');
ESTAB_NAME := decode_lookup('FR_WORKERS_ELECTION','ESTAB_NAME');
ADDRESS_LINE2 := decode_lookup('FR_WORKERS_ELECTION','ADDRESS_LINE2');
ADDRESS_LINE1 := decode_lookup('FR_WORKERS_ELECTION','ADDRESS_LINE1');
INSEE_CODE := decode_lookup('FR_WORKERS_ELECTION','INSEE_CODE');
TOWN := decode_lookup('FR_WORKERS_ELECTION','TOWN');
POSTAL_CODE := decode_lookup('FR_WORKERS_ELECTION','POSTAL_CODE');
CITY := decode_lookup('FR_WORKERS_ELECTION','CITY');
EMPLOYER_TYPE := decode_lookup('FR_WORKERS_ELECTION','EMPLOYER_TYPE');
--
SIRET_LOG := greatest(length(SIRET),SIRET_LEN);
NAF_CODE_LOG := greatest(length(NAF_CODE),NAF_CODE_LEN);
ESTAB_NAME_LOG := greatest(length(ESTAB_NAME),ESTAB_NAME_LEN);
ADDRESS_LINE2_LOG := greatest(length(ADDRESS_LINE2),ADDRESS_LINE2_LEN);
ADDRESS_LINE1_LOG := greatest(length(ADDRESS_LINE1),ADDRESS_LINE1_LEN);
INSEE_CODE_LOG := greatest(length(INSEE_CODE),INSEE_CODE_LEN);
TOWN_LOG := greatest(length(TOWN),TOWN_LEN);
POSTAL_CODE_LOG := greatest(length(POSTAL_CODE),POSTAL_CODE_LEN);
CITY_LOG := greatest(length(CITY),CITY_LEN);
EMPLOYER_TYPE_LOG := greatest(length(EMPLOYER_TYPE),EMPLOYER_TYPE_LEN);
--
-- Person Heading Data
SS_NUMBER := decode_lookup('FR_WORKERS_ELECTION','SS_NUMBER');
SS_KEY := decode_lookup('FR_WORKERS_ELECTION','SS_KEY');
DATE_OF_BIRTH := decode_lookup('FR_WORKERS_ELECTION','DATE_OF_BIRTH');
DEPARTMENT_OF_BIRTH := decode_lookup('FR_WORKERS_ELECTION','DEPARTMENT_OF_BIRTH');
PLACE_OF_BIRTH := decode_lookup('FR_WORKERS_ELECTION','PLACE_OF_BIRTH');
BIRTH_NAME := decode_lookup('FR_WORKERS_ELECTION','BIRTH_NAME');
FIRST_NAME := decode_lookup('FR_WORKERS_ELECTION','FIRST_NAME');
LAST_NAME := decode_lookup('FR_WORKERS_ELECTION','LAST_NAME');
ELECTORAL_COLLEGE := decode_lookup('FR_WORKERS_ELECTION','ELECTORAL_COLLEGE');
SECTION := decode_lookup('FR_WORKERS_ELECTION','SECTION');
VOTING_PLACE := decode_lookup('FR_WORKERS_ELECTION','VOTING_PLACE');
--
SS_NUMBER_LOG := greatest(length(SS_NUMBER),SS_NUMBER_LEN);
SS_KEY_LOG := greatest(length(SS_KEY),SS_KEY_LEN);
DATE_OF_BIRTH_LOG := greatest(length(DATE_OF_BIRTH),DATE_OF_BIRTH_LEN);
DEPARTMENT_OF_BIRTH_LOG := greatest(length(DEPARTMENT_OF_BIRTH),DEPARTMENT_OF_BIRTH_LEN);
PLACE_OF_BIRTH_LOG := greatest(length(PLACE_OF_BIRTH),PLACE_OF_BIRTH_LEN);
BIRTH_NAME_LOG := greatest(length(BIRTH_NAME),BIRTH_NAME_LEN);
FIRST_NAME_LOG := greatest(length(FIRST_NAME),FIRST_NAME_LEN);
LAST_NAME_LOG := greatest(length(LAST_NAME),LAST_NAME_LEN);
ELECTORAL_COLLEGE_LOG := greatest(length(ELECTORAL_COLLEGE),ELECTORAL_COLLEGE_LEN);
SECTION_LOG := greatest(length(SECTION),SECTION_LEN);
VOTING_PLACE_LOG := greatest(length(VOTING_PLACE),VOTING_PLACE_LEN);
--
l_rep_est_title := rpad(REPORTING_SIRET,REPORTING_SIRET_LOG,' ');
l_rep_est_underline := rpad('-',REPORTING_SIRET_LOG,'-');
--
l_est_head_title := rpad(SIRET,SIRET_LOG,' ') || ' ' ||
                    rpad(NAF_CODE,NAF_CODE_LOG,' ') || ' ' ||
                    rpad(ESTAB_NAME,ESTAB_NAME_LOG,' ') || ' ' ||
                    rpad(ADDRESS_LINE2,ADDRESS_LINE2_LOG,' ') || ' ' ||
                    rpad(ADDRESS_LINE1,ADDRESS_LINE1_LOG,' ') || ' ' ||
                    rpad(INSEE_CODE,INSEE_CODE_LOG,' ') || ' ' ||
                    rpad(TOWN,TOWN_LOG,' ') || ' ' ||
                    rpad(POSTAL_CODE,POSTAL_CODE_LOG,' ') || ' ' ||
                    rpad(CITY,CITY_LOG,' ') || ' ' ||
                    rpad(EMPLOYER_TYPE,EMPLOYER_TYPE_LOG,' ');

--
l_est_head_underline := rpad('-',SIRET_LOG,'-') || ' ' ||
                          rpad('-',NAF_CODE_LOG,'-') || ' ' ||
                          rpad('-',ESTAB_NAME_LOG,'-') || ' ' ||
                          rpad('-',ADDRESS_LINE2_LOG,'-') || ' ' ||
                          rpad('-',ADDRESS_LINE1_LOG,'-') || ' ' ||
                          rpad('-',INSEE_CODE_LOG,'-') || ' ' ||
                          rpad('-',TOWN_LOG,'-') || ' ' ||
                          rpad('-',POSTAL_CODE_LOG,'-') || ' ' ||
                          rpad('-',CITY_LOG,'-') || ' ' ||
                          rpad('-',EMPLOYER_TYPE_LOG,'-');
--
l_person_title := rpad(SS_NUMBER,SS_NUMBER_LOG,' ') || ' ' ||
                        rpad(SS_KEY,SS_KEY_LOG,' ') || ' ' ||
                        rpad(DATE_OF_BIRTH,DATE_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(DEPARTMENT_OF_BIRTH,DEPARTMENT_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(PLACE_OF_BIRTH,PLACE_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(BIRTH_NAME,BIRTH_NAME_LOG,' ') || ' ' ||
                        rpad(FIRST_NAME,FIRST_NAME_LOG,' ') || ' ' ||
                        rpad(LAST_NAME,LAST_NAME_LOG,' ') || ' ' ||
                        rpad(ADDRESS_LINE2,ADDRESS_LINE2_LOG,' ') || ' ' ||
                        rpad(ADDRESS_LINE1,ADDRESS_LINE1_LOG,' ') || ' ' ||
                        rpad(INSEE_CODE,INSEE_CODE_LOG,' ') || ' ' ||
                        rpad(TOWN,TOWN_LOG,' ') || ' ' ||
                        rpad(POSTAL_CODE,POSTAL_CODE_LOG,' ') || ' ' ||
                        rpad(CITY,CITY_LOG,' ') || ' ' ||
                        rpad(ELECTORAL_COLLEGE,ELECTORAL_COLLEGE_LOG,' ') || ' ' ||
                        rpad(SECTION,SECTION_LOG,' ') || ' ' ||
                        rpad(VOTING_PLACE,VOTING_PLACE_LOG,' ');
--
l_person_underline := rpad('-',SS_NUMBER_LOG,'-') || ' ' ||
                        rpad('-',SS_KEY_LOG,'-') || ' ' ||
                        rpad('-',DATE_OF_BIRTH_LOG,'-') || ' ' ||
                        rpad('-',DEPARTMENT_OF_BIRTH_LOG,'-') || ' ' ||
                        rpad('-',PLACE_OF_BIRTH_LOG,'-') || ' ' ||
                        rpad('-',BIRTH_NAME_LOG,'-') || ' ' ||
                        rpad('-',FIRST_NAME_LOG,'-') || ' ' ||
                        rpad('-',LAST_NAME_LOG,'-') || ' ' ||
                        rpad('-',ADDRESS_LINE2_LOG,'-') || ' ' ||
                        rpad('-',ADDRESS_LINE1_LOG,'-') || ' ' ||
                        rpad('-',INSEE_CODE_LOG,'-') || ' ' ||
                        rpad('-',TOWN_LOG,'-') || ' ' ||
                        rpad('-',POSTAL_CODE_LOG,'-') || ' ' ||
                        rpad('-',CITY_LOG,'-') || ' ' ||
                        rpad('-',ELECTORAL_COLLEGE_LOG,'-') || ' ' ||
                        rpad('-',SECTION_LOG,'-') || ' ' ||
                        rpad('-',VOTING_PLACE_LOG,'-');
--
--
For rep_est in get_reporting_establishment loop
        l_start_rec := '0000000000000000000' ||
                            '000' ||
                            rpad(' ',1,' ') ||
                            substr(rep_est.SIRET,1,14) ||
                            rpad(' ',527,' ');
        Fnd_file.put_line(FND_FILE.OUTPUT,l_start_rec);

        Fnd_file.put_line(FND_FILE.LOG,null);
        Fnd_file.put_line(FND_FILE.LOG,l_rep_est_title);
        Fnd_file.put_line(FND_FILE.LOG,l_rep_est_underline);
        Fnd_file.put_line(FND_FILE.LOG, rpad(substr(rep_est.SIRET,1,14),REPORTING_SIRET_LOG,' '));

        -- Mandatory Validation
        -- reporting establishment SIRET

        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','SIRET')
                            , substr(rep_est.SIRET,1,14));
End loop;

--
--
For est in get_establishments loop
--
        L_est_head_rec := est.SIRET ||
                                rpad(' ',2,' ') ||
                              rpad(' ',3,' ') ||
                                '020' ||
                                est.SIRET ||
                                est.NAF_CODE ||
                                rpad(' ',56,' ') ||
                                est.ESTAB_NAME ||
                                est.ADDRESS_LINE2 ||
                                rpad(' ',1,' ') ||
                                est.ADDRESS_LINE1 ||
                                est.INSEE_CODE ||
                                rpad(' ',1,' ') ||
                                est.TOWN ||
                                est.POSTAL_CODE ||
                                rpad(' ',1,' ') ||
                                est.CITY ||
                                rpad(' ',86,' ') ||
                                rpad(' ',2,' ') ||
                                rpad(' ',201,' ');
--
        l_est_head_log := rpad(est.SIRET,SIRET_LOG,' ') || ' ' ||
                        rpad(est.NAF_CODE,NAF_CODE_LOG,' ') || ' ' ||
                        rpad(est.ESTAB_NAME,ESTAB_NAME_LOG,' ') || ' ' ||
                        rpad(est.ADDRESS_LINE2,ADDRESS_LINE2_LOG,' ') || ' ' ||
                        rpad(est.ADDRESS_LINE1,ADDRESS_LINE1_LOG,' ') || ' ' ||
                        rpad(est.INSEE_CODE,INSEE_CODE_LOG,' ') || ' ' ||
                        rpad(est.TOWN,TOWN_LOG,' ') || ' ' ||
                        rpad(est.POSTAL_CODE,POSTAL_CODE_LOG,' ') || ' ' ||
                        rpad(est.CITY,CITY_LOG,' ') || ' ' ||
                        rpad('  ',EMPLOYER_TYPE_LOG,' ');
--
--
-- process employees for this establishment (see below)

        l_person_count := 0;

        For per in get_person(est.establishment_id) loop


           -- check that the person meets the criteria
           -- 1. Active or Suspended employee or CWK assignment - handled in cursor
           -- 2. Person is 16 before 29th March 2002
           -- 3. Either contract status is Active
           --    OR employee category is DIRECTOR
           -- 4. Person is not explicitly excluded


        if (months_between(l_effective_date-1 , nvl(per.DATE_OF_BIRTH,to_date('01/01/1900','dd/mm/yyyy')))/12 >= 16
        and (substr(nvl(per.CONTRACT_STATUS,'XX'),1,2) = 'A-'
          or nvl(per.EMPLOYEE_CATEGORY,'XXXXXX') = 'DIRECTOR')
        and nvl(per.EXCLUDE_FLAG,'X') <> 'Y') then

           -- Output the establishment header record as long as the estab
           -- has at least one employee meeting the criteria

           if l_person_count = 0 then   -- 1st person being processed
                Fnd_file.put_line(FND_FILE.OUTPUT,l_est_head_rec);

                Fnd_file.put_line(FND_FILE.LOG,null);
                Fnd_file.put_line(FND_FILE.LOG,l_est_head_title);
                Fnd_file.put_line(FND_FILE.LOG,l_est_head_underline);
                Fnd_file.put_line(FND_FILE.LOG,l_est_head_log);

                -- Perform validation for the establishment
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','SIRET')
                            , est.SIRET);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','NAF_CODE')
                            , est.NAF_CODE);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','ESTAB_NAME')
                            , est.ESTAB_NAME);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','ADDRESS_LINE1')
                            , est.ADDRESS_LINE1);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','INSEE_CODE')
                            , est.INSEE_CODE);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','TOWN')
                            , est.TOWN);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','POSTAL_CODE')
                            , est.POSTAL_CODE);

        naf_code_check(decode_lookup('FR_WORKERS_ELECTION','NAF_CODE')
                            , est.NAF_CODE);


                Fnd_file.put_line(FND_FILE.LOG,null);
                Fnd_file.put_line(FND_FILE.LOG,l_person_title);
                Fnd_file.put_line(FND_FILE.LOG,l_person_underline);

           End if;

                l_person_rec :=
                        est.SIRET
                ||      rpad(' ',2,' ')
                ||      rpad(' ',3,' ')
                ||      '200'
                ||      rpad(' ',10,' ')
                ||      per.SS_NUMBER
                ||      per.SS_KEY
                ||      nvl(to_char(per.DATE_OF_BIRTH,'DDMMYY'),'      ')
                ||      per.DEPARTMENT_OF_BIRTH
                ||      rpad(' ',3,' ')
                ||      per.PLACE_OF_BIRTH
                ||      rpad(' ',3,' ')
                ||      Per.BIRTH_NAME
                ||      Per.FIRST_NAME
                ||      Per.LAST_NAME
                ||      Per.ADDRESS_LINE2
            ||  rpad(' ',1,' ')
                ||      Per.ADDRESS_LINE1
                ||      Per.INSEE_CODE
            ||  rpad(' ',1,' ')
                ||      Per.TOWN
                ||      Per.POSTAL_CODE
                ||      rpad(' ',1,' ')
                ||      Per.CITY
                ||      rpad(' ',232,' ')
                ||      Per.ELECTORAL_COLLEGE
                ||      Est.SECTION
                ||      Per.VOTING_PLACE
                ||      rpad(' ',33,' ');

                l_person_log :=
                        rpad(per.SS_NUMBER,SS_NUMBER_LOG,' ') || ' ' ||
                        rpad(per.SS_KEY,SS_KEY_LOG,' ') || ' ' ||
                        rpad(nvl(to_char(per.DATE_OF_BIRTH,'DDMMYY'),'      '),DATE_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(per.DEPARTMENT_OF_BIRTH,DEPARTMENT_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(per.PLACE_OF_BIRTH,PLACE_OF_BIRTH_LOG,' ') || ' ' ||
                        rpad(Per.BIRTH_NAME,BIRTH_NAME_LOG,' ') || ' ' ||
                        rpad(Per.FIRST_NAME,FIRST_NAME_LOG,' ') || ' ' ||
                        rpad(Per.LAST_NAME,LAST_NAME_LOG,' ') || ' ' ||
                        rpad(per.ADDRESS_LINE2,ADDRESS_LINE2_LOG,' ') || ' ' ||
                        rpad(per.ADDRESS_LINE1,ADDRESS_LINE1_LOG,' ') || ' ' ||
                        rpad(per.INSEE_CODE,INSEE_CODE_LOG,' ') || ' ' ||
                        rpad(per.TOWN,TOWN_LOG,' ') || ' ' ||
                        rpad(per.POSTAL_CODE,POSTAL_CODE_LOG,' ') || ' ' ||
                        rpad(per.CITY,CITY_LOG,' ') || ' ' ||
                        rpad(Per.ELECTORAL_COLLEGE,ELECTORAL_COLLEGE_LOG,' ') || ' ' ||
                        rpad(Est.SECTION,SECTION_LOG,' ') || ' ' ||
                        rpad(Per.VOTING_PLACE,VOTING_PLACE_LOG,' ');

        Fnd_file.put_line(FND_FILE.OUTPUT,l_person_rec);

                Fnd_file.put_line(FND_FILE.LOG,l_person_log);

        -- Perform mandataory checks for people

        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','SS_NUMBER')
                            , per.SS_NUMBER);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','SS_KEY')
                            , per.SS_KEY);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','DATE_OF_BIRTH')
                            , to_char(per.DATE_OF_BIRTH,'DDMMYY'));
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','BIRTH_DEPT')
                            , per.DEPARTMENT_OF_BIRTH);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','BIRTH_PLACE')
                            , per.PLACE_OF_BIRTH);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','FIRST_NAME')
                            , Per.FIRST_NAME);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','LAST_NAME')
                            , Per.LAST_NAME);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','ADDRESS_LINE1')
                            , per.ADDRESS_LINE1);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','INSEE_CODE')
                            , per.INSEE_CODE);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','TOWN')
                            , per.TOWN);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','POSTAL_CODE')
                            , per.POSTAL_CODE);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','ELECTORAL_COLLEGE')
                            , Per.ELECTORAL_COLLEGE);
        mandatory_check(decode_lookup('FR_WORKERS_ELECTION','VOTING_PLACE')
                            , per.VOTING_PLACE);

        election_data_check(decode_lookup('FR_WORKERS_ELECTION','WORKERS_ELECTION_DATA')
                           ,Per.ELECTORAL_COLLEGE
                           ,per.VOTING_PLACE);
--
                l_person_count := l_person_count + 1;

          End if;  -- check person meets criteria

        End loop;  -- Person Loop


-- Only print the footer if the establishment has > 0 people
        If l_person_count > 0 then

                l_est_footer_rec := Substr(est.SIRET,1,14)
                        ||      rpad(' ',2,' ')
                        ||      rpad(' ',3,' ')
                        ||      '300'
                        ||      rpad(' ',312,' ')
                        ||      lpad(to_char(l_person_count),6,'0')
                        ||      rpad(' ',224,' ');

        Fnd_file.put_line(FND_FILE.OUTPUT, l_est_footer_rec);

        End if;


end loop;  -- Establishment Loop


        l_end_rec := rpad('9',19,'9')
                ||      '990'
                ||      rpad(' ',542,' ');

        Fnd_file.put_line(FND_FILE.OUTPUT, l_end_rec);

        fnd_file.put_line(FND_FILE.LOG,null);
        fnd_file.put_line(FND_FILE.LOG,decode_lookup('FR_WORKERS_ELECTION','WARNING') || ' : ' ||
                                       to_char(l_warning_count));
        fnd_file.put_line(FND_FILE.LOG,decode_lookup('FR_WORKERS_ELECTION','ERROR') || ' : ' ||
                                       to_char(l_error_count));

  retcode := 0;
end;
end;

/
