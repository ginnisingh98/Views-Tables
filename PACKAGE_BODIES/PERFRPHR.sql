--------------------------------------------------------
--  DDL for Package Body PERFRPHR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PERFRPHR" AS
/* $Header: perfrphr.pkb 120.2 2006/07/31 07:18:45 nmuthusa noship $ */

/* ------------------------------------------------------------------------- */
/* CONVERT_UPPERCASE-Converts French Accents to english uppercase characters */
/* ------------------------------------------------------------------------- */
FUNCTION convert_uppercase(p_input_string varchar2)
RETURN varchar2 IS
--
l_output_string varchar2(2000);

-- converts the french accented characters to American English
-- in uppercase, used for direct deposit mag tape data
cursor c_uppercase(cp_input_string varchar2) is
select
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
 replace(
 replace(
replace(convert(upper(cp_input_string),'UTF8'),
           utl_raw.cast_to_varchar2(hextoraw('C380')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38A')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C387')),'C'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C389')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39C')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C399')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39B')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C394')),'O'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38F')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38E')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C388')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38B')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C382')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C592')),'OE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C386')),'AE'
          )
from dual;

begin

  open c_uppercase(p_input_string);
  fetch c_uppercase into l_output_string;
  if c_uppercase%NOTFOUND then
     l_output_string := p_input_string;
  end if;
  close c_uppercase;

  return l_output_string;

end convert_uppercase;

----------------------------
FUNCTION get_emp_total (p_effective_date    IN DATE,
                        p_est_id            IN NUMBER,
                        p_ent_id            IN NUMBER,
                        p_sex               IN VARCHAR2,
                        p_udt_column        IN VARCHAR2,
                        p_include_suspended IN VARCHAR2) RETURN NUMBER IS
--
CURSOR c_get_total IS
SELECT COUNT(asg.assignment_id)
FROM   per_all_assignments_f       asg,
       per_assignment_status_types ast,
       per_person_types_v pt,
       per_all_people_f            peo
WHERE  asg.establishment_id IN (SELECT hr2.organization_id
                                FROM   hr_organization_information hr1,
                                       hr_organization_information hr2
                                WHERE  hr1.organization_id  = p_ent_id
                                AND    hr1.org_information1 = hr2.org_information1
                                AND    hr1.org_information_context = hr2.org_information_context
                                AND    hr1.org_information_context = 'FR_ESTAB_INFO'
                                AND    p_ent_id IS NOT NULL
                                UNION
                                SELECT NVL(p_est_id,0)
                                FROM   DUAL
                                WHERE  p_ent_id IS NULL)
AND    NVL(peo.sex,'X') = NVL(p_sex,NVL(peo.sex,'X'))
AND    asg.person_id = peo.person_id
AND    ((ast.per_system_status = 'ACTIVE_ASSIGN' AND p_include_suspended = 'N') OR
        (ast.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN') AND p_include_suspended = 'Y'))
AND    asg.assignment_status_type_id = ast.assignment_status_type_id
AND    asg.primary_flag = 'Y'
AND    peo.person_type_id = pt.person_type_id
AND    'Y' = pefrusdt.get_table_value(peo.business_group_id
                                     ,'FR_USER_PERSON_TYPE'
                                     ,p_udt_column
                                     ,pt.user_person_type
                                     ,p_effective_date)
AND    p_effective_date >= asg.effective_start_date
AND    p_effective_date <= asg.effective_end_date
AND    p_effective_date >= peo.effective_start_date
AND    p_effective_date <= peo.effective_end_date
AND   (LEAST(asg.effective_end_date,peo.effective_end_date) > p_effective_date
       OR EXISTS (SELECT null
                  FROM   per_all_assignments_f       asg2,
                         per_assignment_status_types ast2,
                         per_person_types_v          pt2,
                         per_all_people_f            peo2
                  WHERE  asg2.establishment_id IN (SELECT hr2.organization_id
                                                   FROM   hr_organization_information hr1,
                                                          hr_organization_information hr2
                                                   WHERE  hr1.organization_id  = p_ent_id
                                                   AND    hr1.org_information1 = hr2.org_information1
                                                   AND    hr1.org_information_context = hr2.org_information_context
                                                   AND    hr1.org_information_context = 'FR_ESTAB_INFO'
                                                   AND    p_ent_id IS NOT NULL
                                                   UNION
                                                   SELECT NVL(p_est_id,0)
                                                   FROM   DUAL
                                                   WHERE  p_ent_id IS NULL)
                  AND    NVL(peo2.sex,'X') = NVL(p_sex,NVL(peo2.sex,'X'))
                  AND    asg2.person_id = peo.person_id
                  AND    asg2.person_id = peo2.person_id
                  AND    ((ast2.per_system_status = 'ACTIVE_ASSIGN' AND p_include_suspended = 'N') OR
                          (ast2.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN') AND p_include_suspended = 'Y'))
                  AND    asg2.assignment_status_type_id = ast2.assignment_status_type_id
                  AND    asg2.primary_flag = 'Y'
                  AND    peo2.person_type_id = pt2.person_type_id
                  AND    'Y' = pefrusdt.get_table_value(peo2.business_group_id
                                                        ,'FR_USER_PERSON_TYPE'
                                                        ,p_udt_column
                                                        ,pt2.user_person_type
                                                        ,p_effective_date)
                  AND    p_effective_date+1 >= asg2.effective_start_date
                  AND    p_effective_date+1 <= asg2.effective_end_date
                  AND    p_effective_date+1 >= peo2.effective_start_date
                  AND    p_effective_date+1 <= peo2.effective_end_date)
      );
--
l_total        NUMBER:=0;
--
BEGIN
  --
  OPEN c_get_total;
  FETCH c_get_total INTO l_total;
  CLOSE c_get_total;
  --
  RETURN l_total;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       CLOSE c_get_total;
       RETURN(0);
end get_emp_total;
----------------------------
PROCEDURE run_pre_hire (errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY NUMBER,
                        p_business_group_id IN NUMBER,
                        p_establishment_id  IN NUMBER,
                        p_person_id         IN NUMBER,
                        p_contact_name      IN VARCHAR2,
                        p_contact_telephone IN VARCHAR2,
                        p_fax               IN VARCHAR2,
                        p_email_address     IN VARCHAR2,
                        p_dads              IN VARCHAR2,
                        p_pmf5              IN VARCHAR2,
                      --p_prem              IN VARCHAR2,
                        p_date              IN VARCHAR2,
                        p_batch             IN VARCHAR2,
                        p_acknowledgement   IN VARCHAR2) IS
  --
  l_error             BOOLEAN;
  l_text              VARCHAR2(2967);
  l_error_text        VARCHAR2(300);
  l_trace             VARCHAR2(80);
  l_ent_total         NUMBER;
  l_est_total         NUMBER;
  l_french            VARCHAR2(80);
  l_nationality       VARCHAR2(80);
  l_fullname          per_all_people_f.full_name%type;
  l_medical           VARCHAR2(80);
  l_nationality_type  VARCHAR2(80);
  l_naf_meaning       VARCHAR2(80);
  l_coun_of_birth     VARCHAR2(80);
  l_urssaf_code       VARCHAR2(80);
  l_from_date         DATE;
  l_probation_period  VARCHAR2(30);
  l_working_hours     VARCHAR2(30);
  -- modified for numerical value error (bug#4106045)
  l_units_in_days     NUMBER;
  l_units_in_weeks    NUMBER;
  --
  l_identifier        VARCHAR2(80);
  l_date              DATE;
  l_monthly_hours     VARCHAR2(80);
  --
  CURSOR c_country (b_country_code IN VARCHAR2) IS
  SELECT UPPER(territory_short_name)
  FROM   fnd_territories_vl
  WHERE  territory_code = b_country_code;
  --
  CURSOR c_from_date (b_period_id IN NUMBER) IS
  SELECT date_start
  FROM   per_periods_of_service
  WHERE  period_of_service_id = b_period_id;
  --
  CURSOR c_appl_date (b_appl_id IN NUMBER) IS
  SELECT projected_hire_date
  FROM   per_applications
  WHERE  application_id = b_appl_id;
  --
  CURSOR c_urssaf_code (b_est_id IN NUMBER) IS
  SELECT UPPER(hoi2.org_information1)
  FROM   hr_organization_information hoi,
         hr_organization_information hoi2
  WHERE  hoi2.org_information_context = 'FR_URSSAF_CENTR_INFO'
  AND    hoi2.organization_id = hoi.org_information1
  AND    hoi.org_information_context = 'FR_ESTAB_URSSAF'
  AND    hoi.organization_id = b_est_id;
  --
  CURSOR c_app IS
  SELECT /*+index(OI1 HR_ORGANIZATION_INFORMATIO_FK2)*/
           ass.assignment_id                                         ass_id,
           ass.establishment_id                                      est_id,
           ass.organization_id                                       org_id,
           ass.person_id                                             person_id,
           ass.period_of_service_id,
           ass.application_id,
           UPPER(ass.time_normal_start)                              start_time,
           UPPER(OI1.ORG_INFORMATION2)                               siret,
           OI1.ORG_INFORMATION4                                      monthly_hours,
           UPPER(OI1.ORG_INFORMATION3)                                       naf_code,
           UPPER(ou1.name)                                           est_name,
           UPPER(loc.address_line_1)                                 loc_address1,
           UPPER(loc.address_line_2)                                 loc_address2,
           -- Added for bug #5240132
           UPPER(loc.address_line_3)                                 loc_address3,
	   --
           UPPER(loc.postal_code)                                    loc_postal,
           UPPER(loc.town_or_city)                                   loc_town,
           loc.telephone_number_1                                    loc_telephone,
           UPPER(NVL(peo.per_information1,peo.last_name))            nom_de_naiss,
           peo.last_name                                             nom_marital,
           UPPER(peo.first_name)                                     app_first_name,
           peo.full_name                                             app_full_name,
           peo.sex                                                   app_sex,
           peo.national_identifier                                   app_ni,
           DECODE(ass.period_of_service_id,
                  NULL,peo.applicant_number,peo.employee_number)     app_employee_number,
           peo.date_of_birth                                         app_dob,
           peo.nationality                                           app_nat_code,
           peo.title                                                 app_tit,
           peo.region_of_birth                                       app_dept_code,
           UPPER(peo.town_of_birth)                                  app_town_birth,
           peo.country_of_birth,
           adr.address_line1                                         app_address1,
           adr.address_line2                                         app_address2,
           -- Added for bug #5240132
           adr.address_line3                                         app_address3,
           --
           adr.postal_code                                           app_pos_code,
           adr.town_or_city                                          app_town,
           NVL(con.ctr_information6,to_char(ass.probation_period))   app_prob_period,
           DECODE(con.ctr_information6,NULL,ass.probation_unit
                                      ,con.ctr_information7)         app_prob_unit,
           -- modified for numerical value error (bug#4106045)
           decode(con.ctr_information12, 'HOUR', con.ctr_information13, ass.frequency) frequency,
           decode(con.ctr_information12, 'HOUR', con.ctr_information11, ass.normal_hours) app_hours,
           --
           -- modifying for bug#4083763
           --DECODE(con.ctr_information2,'FIXED_TERM','D','PERMANENT','I') app_contract_cat,
           DECODE(con.ctr_information2,'FIXED_TERM','1','PERMANENT','2','NEW_HIRE_CONTRACT','4', decode(OI1.ORG_INFORMATION8, 'Y', '3')) app_contract_cat,
           --
           TO_CHAR(fnd_date.canonical_to_date(con.ctr_information3),'DDMMYYYY') proposed_end_date,
           DECODE(hr_contract_api.get_active_end_date(con.contract_id,l_date,con.status),NULL
           ,TO_CHAR(fnd_date.canonical_to_date(con.ctr_information3),'DDMMYYYY')
           ,TO_CHAR(hr_contract_api.get_active_end_date(con.contract_id,l_date,con.status),'DDMMYYYY'))     con_end_date,
           ext.rowid                                                 row_id,
           ext.aei_information4                                      app_titulair,
           ext.aei_information5                                      app_status_before_hire,
           ext.aei_information6                                      app_training_level,
           ext.aei_information7                                      app_proposed_monthly_salary,
           ext.aei_information2                                      app_request_ni,
           ext.aei_information8                                      app_assedic,
           ext.aei_information9                                      app_pt_exon,
           ext.aei_information10                                     app_inform_mt,
           ext.aei_information1,
           DECODE(ext.aei_information13,'FRF','F','EUR','E')         ccy_code,
           DECODE(ext.aei_information10,'Y',p_contact_name,' ')      app_contact_name,       -- work initiative contract
           DECODE(ext.aei_information10,'Y',p_contact_telephone,' ') app_contact_telephone,  -- work initiative contract
           SUBSTR(job.job_information1,1,1)                          app_emp_code,
           SUBSTR(job.job_information1,2,2)                          app_qual_code,
           -- Added for bug #5240132
           OI1.org_information20				     app_corres_location_id
           --
    FROM   per_addresses             adr,
           per_contracts_f           con,
           per_jobs                  job,
           hr_locations_all          loc,
           hr_ALL_ORGANIZATION_UNITS OU1,
           HR_ORGANIZATION_INFORMATION OI1,
           per_assignment_extra_info ext,
           per_all_assignments_f     ass,
           per_all_people_f          peo
    WHERE  adr.person_id(+) = peo.person_id
    AND    adr.primary_flag(+) = 'Y'
    AND    con.contract_id(+) = ass.contract_id
    AND    l_date BETWEEN con.effective_start_date(+)
                      AND con.effective_end_date(+)
    AND    job.job_id(+) = ass.job_id
    AND    loc.location_id(+) = ou1.location_id
    AND    ass.establishment_id = ou1.organization_id
    AND    ext.aei_information11 = 'Y'
    AND    ass.assignment_id = ext.assignment_id
    AND    ext.information_type = 'FR_HIRING_DECLARATION'
    AND    ass.person_id = peo.person_id
    AND    l_date BETWEEN peo.effective_start_date AND peo.effective_end_date
    and    ass.establishment_id = p_establishment_id
    AND (l_date BETWEEN ass.effective_start_date AND  ass.effective_end_date)
    and OU1.ORGANIZATION_ID = OI1.ORGANIZATION_ID (+)
    AND OI1.ORG_INFORMATION_CONTEXT (+)  = 'FR_ESTAB_INFO'
  ORDER BY peo.last_name;



  CURSOR c_app_by_person IS
  SELECT /*+no_index(ass PER_ASSIGNMENTS_F_FK20)
         index(OI1 HR_ORGANIZATION_INFORMATIO_FK2) */
         ass.assignment_id                                         ass_id,
         ass.establishment_id                                      est_id,
         ass.organization_id                                       org_id,
         ass.person_id                                             person_id,
         ass.period_of_service_id,
         ass.application_id,
         UPPER(ass.time_normal_start)                              start_time,
         UPPER(OI1.ORG_INFORMATION2)                               siret,
         OI1.ORG_INFORMATION4                                      monthly_hours,
         UPPER(OI1.ORG_INFORMATION3)                                       naf_code,
         UPPER(ou1.name)                                           est_name,
         UPPER(loc.address_line_1)                                 loc_address1,
         UPPER(loc.address_line_2)                                 loc_address2,
	 -- Added for bug #5240132
	  UPPER(loc.address_line_3)                                 loc_address3,
	 --
         UPPER(loc.postal_code)                                    loc_postal,
         UPPER(loc.town_or_city)                                   loc_town,
         loc.telephone_number_1                                    loc_telephone,
         UPPER(NVL(peo.per_information1,peo.last_name))            nom_de_naiss,
         peo.last_name                                             nom_marital,
         UPPER(peo.first_name)                                     app_first_name,
         peo.full_name                                             app_full_name,
         peo.sex                                                   app_sex,
         peo.national_identifier                                   app_ni,
         DECODE(ass.period_of_service_id,
                NULL,peo.applicant_number,peo.employee_number)     app_employee_number,
         peo.date_of_birth                                         app_dob,
         peo.nationality                                           app_nat_code,
         peo.title                                                 app_tit,
         peo.region_of_birth                                       app_dept_code,
         UPPER(peo.town_of_birth)                                  app_town_birth,
         peo.country_of_birth,
         adr.address_line1                                         app_address1,
         adr.address_line2                                         app_address2,
	 -- Added for bug #5240132
         adr.address_line3                                         app_address3,
	 --
         adr.postal_code                                           app_pos_code,
         adr.town_or_city                                          app_town,
         NVL(con.ctr_information6,to_char(ass.probation_period))   app_prob_period,
         DECODE(con.ctr_information6,NULL,ass.probation_unit
                                    ,con.ctr_information7)         app_prob_unit,
         -- modified for numerical value error (bug#4106045)
	 decode(con.ctr_information12, 'HOUR', con.ctr_information13, ass.frequency) frequency,
	 decode(con.ctr_information12, 'HOUR', con.ctr_information11, ass.normal_hours) app_hours,
         --
         -- modifying for bug#4083763
	 --DECODE(con.ctr_information2,'FIXED_TERM','D','PERMANENT','I') app_contract_cat,
	 DECODE(con.ctr_information2,'FIXED_TERM','1','PERMANENT','2','NEW_HIRE_CONTRACT','4', decode(OI1.ORG_INFORMATION8, 'Y', '3')) app_contract_cat,
	 --
         TO_CHAR(fnd_date.canonical_to_date(con.ctr_information3),'DDMMYYYY') proposed_end_date,
         DECODE(hr_contract_api.get_active_end_date(con.contract_id,l_date,con.status),NULL
         ,TO_CHAR(fnd_date.canonical_to_date(con.ctr_information3),'DDMMYYYY')
         ,TO_CHAR(hr_contract_api.get_active_end_date(con.contract_id,l_date,con.status),'DDMMYYYY'))     con_end_date,
         ext.rowid                                                 row_id,
         ext.aei_information4                                      app_titulair,
         ext.aei_information5                                      app_status_before_hire,
         ext.aei_information6                                      app_training_level,
         ext.aei_information7                                      app_proposed_monthly_salary,
         ext.aei_information2                                      app_request_ni,
         ext.aei_information8                                      app_assedic,
         ext.aei_information9                                      app_pt_exon,
         ext.aei_information10                                     app_inform_mt,
         ext.aei_information1,
         DECODE(ext.aei_information13,'FRF','F','EUR','E')         ccy_code,
         DECODE(ext.aei_information10,'Y',p_contact_name,' ')      app_contact_name,       -- work initiative contract
         DECODE(ext.aei_information10,'Y',p_contact_telephone,' ') app_contact_telephone,  -- work initiative contract
         SUBSTR(job.job_information1,1,1)                          app_emp_code,
         SUBSTR(job.job_information1,2,2)                          app_qual_code,
         -- Added for bug #5240132
	 OI1.org_information20					   app_corres_location_id
	 --
  FROM   per_addresses             adr,
         per_contracts_f           con,
         per_jobs                  job,
         hr_locations_all          loc,
         hr_ALL_ORGANIZATION_UNITS OU1,
         HR_ORGANIZATION_INFORMATION OI1,
         per_assignment_extra_info ext,
         per_all_assignments_f     ass,
         per_all_people_f          peo
  WHERE  adr.person_id(+) = peo.person_id
  AND    adr.primary_flag(+) = 'Y'
  AND    con.contract_id(+) = ass.contract_id
  AND    l_date BETWEEN con.effective_start_date(+)
                    AND con.effective_end_date(+)
  AND    job.job_id(+) = ass.job_id
  AND    loc.location_id(+) = ou1.location_id
  AND    ass.establishment_id = ou1.organization_id
  AND    ext.aei_information11 = 'Y'
  AND    ass.assignment_id = ext.assignment_id
  AND    ext.information_type = 'FR_HIRING_DECLARATION'
  AND    ass.person_id = peo.person_id
  AND    l_date BETWEEN peo.effective_start_date AND peo.effective_end_date
  and    peo.person_id = p_person_id
  AND (l_date BETWEEN ass.effective_start_date AND  ass.effective_end_date)
  and OU1.ORGANIZATION_ID = OI1.ORGANIZATION_ID (+)
  AND OI1.ORG_INFORMATION_CONTEXT (+)  = 'FR_ESTAB_INFO'
  ORDER BY peo.last_name;

  -- Added for bug #5240132
  CURSOR c_estab_corres_addr (corres_loc_id IN NUMBER) IS
  SELECT  address_line_1,
	  address_line_2,
	  postal_code,
	  town_or_city,
	  telephone_number_1,
	  telephone_number_2
  FROM	  hr_locations_all
  WHERE   location_id = corres_loc_id;
  --
  r_app		c_app%ROWTYPE;
  -- Added for bug #5240132
  r_estab_addr	c_estab_corres_addr%ROWTYPE;
  --
  ----------------------------
  FUNCTION get_alternate_lookup (p_table_name IN VARCHAR2,
                                 p_col_name   IN VARCHAR2,
                                 p_row_value  IN VARCHAR2) RETURN VARCHAR2 IS
  --
  l_value VARCHAR2(80);
  --
  BEGIN
    --
    l_value := hruserdt.get_table_value
               (p_bus_group_id   => p_business_group_id
               ,p_table_name     => p_table_name
               ,p_col_name       => p_col_name
               ,p_row_value      => p_row_value
               ,p_effective_date => l_date);

    RETURN l_value;
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN NULL;
  END get_alternate_lookup;
  ----------------------------
  ----------------------------
  PROCEDURE write_error (p_field IN VARCHAR2) IS
  --
  BEGIN
    --
    l_trace := 'Writing to Error Log2';
    --
    IF l_error THEN
       NULL;
    ELSE
       -- Set up error text for this person
       fnd_message.set_name('PER','PER_74855_ASS_INV_RECORD');
       fnd_message.set_token('FULL_NAME',l_fullname);
       l_error_text := fnd_message.get;
       fnd_file.put_line(fnd_file.log,null);
       fnd_file.put_line(fnd_file.log,rpad('-',200,'-'));
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,REPLACE(l_error_text,fnd_global.local_chr(13),NULL));
    END IF;
    --
    fnd_file.put_line(FND_FILE.LOG,REPLACE(p_field,fnd_global.local_chr(13),NULL));
    --
    l_error := TRUE;
    --
  END write_error;
  ----------------------------
  PROCEDURE write_report (p_app        in c_app%rowtype,
                          p_first_time in varchar2) IS
  --
     procedure write_column (p_column in varchar2) is
     begin
       fnd_file.put(FND_FILE.LOG,upper(p_column)||': ');
     end write_column;
     --
     procedure write_field (p_field in varchar2) is
     begin
       fnd_file.put(FND_FILE.LOG,p_field||'    ');
     end write_field;
     --
     procedure seperator is
     begin
       fnd_file.put_line(fnd_file.log,null);
       fnd_file.put_line(fnd_file.log,rpad('-',200,'-'));
     end seperator;
     --
     procedure write_header is
     begin
       fnd_file.put_line(FND_FILE.LOG,NULL);
       seperator;
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','HEADER'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_IDENT_EMT'));
       write_field(l_identifier);
       write_column(fnd_message.get_string('PER','PER_74856_NULL_URSSAF'));
       write_field(l_urssaf_code);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_AR_PAR_LOT'));
       write_field(REPLACE(p_batch,'Y','O'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_FAX_AR_LOT'));
       write_field(p_fax);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_SUP_AR_LOT'));
       write_field(p_acknowledgement);
       write_column(fnd_message.get_string('PER','PER_74858_NULL_EMAIL'));
       write_field(p_email_address);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','D_CREATION'));
       write_field(TO_CHAR(sysdate,'DDMMYYYY'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','H_CREATION'));
       write_field(TO_CHAR(sysdate,'HHMI'));
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','EMPLOYER'));
       write_column(fnd_message.get_string('PER','PER_74860_NULL_SIRET'));
       write_field(p_app.siret);
       write_column(fnd_message.get_string('PER','PER_74859_NULL_NAF'));
       write_field(p_app.naf_code);
       write_column(fnd_message.get_string('PER','PER_74856_NULL_URSSAF'));
       write_field(l_urssaf_code);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_RAISON_SOC_1'));
       write_field(p_app.est_name);
       write_column(fnd_message.get_string('PER','PER_74861_NULL_ADDRESS1'));
       write_field(p_app.loc_address1);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(fnd_message.get_string('PER','PER_74862_NULL_ADDRESS2'));
       write_field(p_app.loc_address2);
       write_column(fnd_message.get_string('PER','PER_74863_NULL_POST_CODE'));
       write_field(p_app.loc_postal);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       -- Added for bug #5240132
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_CITY_EMP'));
       write_field(p_app.loc_town);
       --
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_TEL_EMP'));
       write_field(p_app.loc_telephone);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_FAX_EMP'));
       write_field(p_fax);
       -- Added for bug #5240132
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','CORRESPOND_ADR'));
       write_column(fnd_message.get_string('PER','PER_74861_NULL_ADDRESS1'));
       write_field(r_estab_addr.address_line_1);
       write_column(fnd_message.get_string('PER','PER_74862_NULL_ADDRESS2'));
       write_field(r_estab_addr.address_line_2);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(fnd_message.get_string('PER','PER_74863_NULL_POST_CODE'));
       write_field(r_estab_addr.postal_code);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_CITY_EMP'));
       write_field(r_estab_addr.town_or_city);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_TEL_EMP'));
       write_field(r_estab_addr.telephone_number_1);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_FAX_EMP'));
       write_field(r_estab_addr.telephone_number_2);
       --
     end write_header;
  --
  BEGIN
    IF p_first_time = 'Y' THEN
       l_trace := 'Writing report header';
       write_header;
    ELSE
       l_trace := 'Writing report body';
       fnd_file.put_line(FND_FILE.LOG,NULL);
       seperator;
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','EMPLOYEE'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','R_DOSSIER'));
       write_field(p_app.app_employee_number);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_NOM_PATRO_SAL'));
       write_field(p_app.nom_de_naiss);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_NOM_EPX_SAL'));
       write_field(p_app.nom_marital);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(fnd_message.get_string('PER','PER_74865_NULL_FIRST_NAME'));
       write_field(p_app.app_first_name);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_SEXE_SAL'));
       write_field(p_app.app_sex);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_SECU_SOC'));
       write_field(p_app.app_ni);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(fnd_message.get_string('PER','PER_74866_NULL_DOB'));
       write_field(p_app.app_dob);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_NATION_SAL'));
       write_field(l_nationality);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_LIEU_NAISS_SAL'));
       write_field(NVL(p_app.app_town_birth,l_coun_of_birth));
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(fnd_message.get_string('PER','PER_74867_NULL_COUNTRY'));
       write_field(l_coun_of_birth);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_ADR_SAL_1'));
       write_field(p_app.app_address1);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_ADR_SAL_2'));
       write_field(p_app.app_address2);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_POST_SAL'));
       write_field(p_app.app_pos_code);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_BUR_DIST_SAL'));
       write_field(p_app.app_town);
       write_column(fnd_message.get_string('PER','PER_74868_NULL_HIRE_DATE'));
       write_field(l_from_date);
       write_column(fnd_message.get_string('PER','PER_74883_START_TIME'));
       write_field(p_app.start_time);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,'---------------');
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','OTHER'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_MT_DCL'));
       write_field(l_medical);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_EFFECTIF_ETAB'));
       write_field(l_est_total);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_EFFECTIF_ENTR'));
       write_field(l_ent_total);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_EMPLOI'));
       write_field(p_app.app_emp_code);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_FORMATION'));
       write_field(p_app.app_training_level);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_QUALIF'));
       write_field(p_app.app_qual_code);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_AV_EMBAUCHE'));
       write_field(p_app.app_status_before_hire);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_JJ_ESSAI'));
       write_field(l_probation_period);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_HH_HEBDO'));
       write_field(l_working_hours);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','C_TYPE_CONTRAT'));
       write_field(p_app.app_contract_cat);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','D_FIN_CDD'));
       write_field(p_app.con_end_date);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','D_NON_EMBAUCHE'));
       write_field(p_app.proposed_end_date);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_SALAIRE_MM'));
       write_field(to_char(ROUND(p_app.app_proposed_monthly_salary)));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_HH_TRAVAIL'));
       write_field(l_monthly_hours);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,'---------------');
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','REGISTRATION'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_AGENT_TITU'));
       write_field(p_app.app_titulair);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,'---------------');
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','ADMIN'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_PREMIERE_EMB'));
       write_field('N');
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_CERTIF'));
       write_field(REPLACE(p_dads,'Y','O'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_CHOM'));
       write_field(p_app.app_assedic);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_IMMA'));
       write_field(p_app.app_request_ni);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_MT'));
       write_field(p_app.app_inform_mt);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_PMF5'));
       write_field(REPLACE(p_pmf5,'Y','O'));
       fnd_file.put_line(FND_FILE.LOG,NULL);
       -- Removed for bug#4083763
       --write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_PREM'));
       --write_field(REPLACE(p_prem,'Y','O'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','I_TP'));
       write_field(p_app.app_pt_exon);
       fnd_file.put_line(FND_FILE.LOG,NULL);
       fnd_file.put_line(FND_FILE.LOG,'---------------');
       fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('FR_DUE_FIELDS','CONTACT'));
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','L_NOM_RESP'));
       write_field(p_contact_name);
       write_column(hr_general.decode_lookup('FR_DUE_FIELDS','N_TEL_RESP'));
       write_field(p_contact_telephone);
    END IF;
  END write_report;
  ----------------------------
  PROCEDURE validate_header IS
  --
  l_error VARCHAR2(100);
  --
  BEGIN
    --
    IF l_urssaf_code IS NULL THEN
       write_error(p_field => fnd_message.get_string('PER','PER_74856_NULL_URSSAF'));
    END IF;
    IF p_acknowledgement = 'E' AND p_email_address IS NULL THEN
       write_error(p_field => fnd_message.get_string('PER','PER_74858_NULL_EMAIL'));
    END IF;
    --
  END validate_header;
  ----------------------------
  PROCEDURE validate_record (p_app IN c_app%ROWTYPE) IS
  --
  BEGIN
     --
     IF p_app.siret IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74860_NULL_SIRET'));
     END IF;
     --
     IF p_app.naf_code IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74859_NULL_NAF'));
     END IF;
     --
     IF p_app.loc_address1 IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74861_NULL_ADDRESS1'));
     END IF;
     --
     IF p_app.loc_postal IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74863_NULL_POST_CODE'));
     END IF;
     --
     IF p_app.loc_town IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74864_NULL_TOWN'));
     END IF;
     --
     IF p_app.app_first_name IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74865_NULL_FIRST_NAME'));
     END IF;
     --
     IF p_app.app_dob IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74866_NULL_DOB'));
     END IF;
     --
     IF l_coun_of_birth IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74867_NULL_COUNTRY'));
     END IF;
     --
     IF l_from_date IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74868_NULL_HIRE_DATE'));
     END IF;
     --
     IF p_app.start_time IS NULL THEN
        write_error(p_field => fnd_message.get_string('PER','PER_74883_START_TIME'));
     END IF;
     --
     IF p_app.app_nat_code IS NULL THEN
        write_error(p_field => hr_general.decode_lookup('FR_DUE_FIELDS','L_NATION_SAL'));
     END IF;
     --
     -- Added for bug#4083763
     -- as L_IDENT_EMT is manadatory
     IF l_identifier IS NULL THEN
        write_error(p_field => hr_general.decode_lookup('FR_DUE_FIELDS','L_IDENT_EMT'));
     END IF;
     --
  END validate_record;
----------------------------
/********************-----*==*==*----*************************/
/********************---*==MAIN==*---*************************/
/********************-----*==*==*----*************************/
BEGIN
   --
   l_date := fnd_date.canonical_to_date(p_date);
   IF p_person_id IS NULL AND p_establishment_id IS NULL THEN
      l_trace := 'Writing to error log1';
      fnd_file.put_line(FND_FILE.LOG,REPLACE(fnd_message.get_string('PER','PER_74857_NULL_PERSON_ESTAB'),fnd_global.local_chr(13),NULL));
      l_error := TRUE;
   END IF;
   --
   --FOR r_app IN c_app LOOP
       --
/*** Previous cursor was split into two cursors depending upon p_person_id ***/
/*** Bug 2662236 ***/

   IF p_person_id IS NULL THEN
      OPEN c_app;
   ELSE
      OPEN c_app_by_person;
   END IF;

   LOOP
      IF c_app%ISOPEN THEN
        FETCH c_app INTO r_app;
        EXIT WHEN c_app%NOTFOUND;
      ELSIF c_app_by_person%ISOPEN THEN
        FETCH c_app_by_person INTO r_app;
        EXIT WHEN c_app_by_person%NOTFOUND;
      END IF;
      -- Added for bug #5240132
      -- Get correspondence address of employer
      OPEN c_estab_corres_addr(r_app.app_corres_location_id);
      FETCH c_estab_corres_addr INTO r_estab_addr;
      CLOSE c_estab_corres_addr;
      --
       /* Reset variables */
       l_error            := FALSE;
       l_ent_total        := 0;
       l_est_total        := 0;
       l_from_date        := NULL;
       l_coun_of_birth    := NULL;
       l_fullname         := r_app.app_full_name;
       --
       IF (c_app%ISOPEN AND c_app%ROWCOUNT = 1) OR
          (c_app_by_person%ISOPEN AND c_app_by_person%ROWCOUNT = 1) THEN
          --
          l_identifier := 'ORACLEHRMS';
          --
          /* Get the URSSAF code for the establishment */
          OPEN c_urssaf_code(r_app.est_id);
          FETCH c_urssaf_code INTO l_urssaf_code;
          CLOSE c_urssaf_code;
          --
          /*If NAF code is more than 4 chars then strip out any non-alphanumerics*/
          IF length(r_app.naf_code) > 4 THEN
             r_app.naf_code := '*'||UPPER(r_app.naf_code);
             r_app.naf_code := REPLACE(TRANSLATE(r_app.naf_code,TRANSLATE(r_app.naf_code,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789','*'),'*'),'*',null);
          END IF;
          --
          l_trace := 'Validating Header';
          validate_header;
          --
          IF l_error THEN
             exit; --stop processing as header is invalid
          END IF;
          --
          write_report(r_app,'Y');
          l_trace := 'Writing header complete';
          --
       END IF;
       --
       /* Work out from which date to start counting(the actual hire date) from */
       IF r_app.period_of_service_id IS NULL THEN
          OPEN c_appl_date(r_app.application_id);
          FETCH c_appl_date INTO l_from_date;
          CLOSE c_appl_date;
       ELSE
          OPEN c_from_date(r_app.period_of_service_id);
          FETCH c_from_date INTO l_from_date;
          CLOSE c_from_date;
       END IF;
       --
       l_trace := 'Calculating establishment totals';
       /* Get the totals for enterprise and establishment */
       l_est_total := perfrphr.get_emp_total(p_effective_date   => l_from_date-1,
                                             p_est_id           => r_app.est_id,
                                             p_udt_column       => 'INCLUDE_DUE');
       l_ent_total := perfrphr.get_emp_total(p_effective_date   => l_from_date-1,
                                             p_ent_id           => r_app.est_id,
                                             p_udt_column       => 'INCLUDE_DUE');
       --
       /* Get the country of birth */
       OPEN c_country(r_app.country_of_birth);
       FETCH c_country INTO l_coun_of_birth;
       CLOSE c_country;
       --
       l_trace := 'Validating Record';
       /* Validate the record */
       validate_record(p_app => r_app); -- check for nulls;
       --
       IF l_error THEN   -- If no error write the record, otherwise go to next record
          null;
       ELSE
          --
          /* Get the medical code */
          l_medical := hr_general.decode_lookup(p_lookup_type => 'FR_WORK_MEDICAL_SERVICE',
                                                p_lookup_code => r_app.aei_information1);
          --
          IF l_medical IS NULL THEN
             l_medical := ' ';
          ELSE
             l_medical := 'MT'||r_app.aei_information1;
          END IF;
          --
          /* Get the nationality */
          l_nationality := hr_general.decode_lookup(p_lookup_type => 'NATIONALITY',
                                                    p_lookup_code => r_app.app_nat_code);
          --
          /* Get the nationality type */
          l_trace := 'Nationality - Alternate Lookup';
          l_french := get_alternate_lookup
                      (p_table_name     => 'NATIONALITY'
                      ,p_col_name       => 'DUE_NATIONALITY'
                      ,p_row_value      => r_app.app_nat_code);
          --
          IF l_french = 'FR' THEN
             l_nationality_type := 'F';
          ELSIF l_french = 'EU' THEN
                l_nationality_type := 'E';
          ELSIF l_french IS NULL AND l_nationality IS NULL THEN
                l_nationality_type := ' ';
          ELSE
                l_nationality_type := 'A';
          END IF;
          --
          /* Work out how many days make up a week/month/year then multiply that by the probation period value */
          l_trace := 'Calculating probation period';
          -- modified for numerical value error (bug#4106045)
          l_units_in_days := fnd_number.canonical_to_number(get_alternate_lookup
                             (p_table_name     => 'QUALIFYING_UNITS'
                             ,p_col_name       => 'DUE_UNITS_IN_DAYS'
                             ,p_row_value      => r_app.app_prob_unit));
          --
          IF l_units_in_days IS NULL THEN
             l_probation_period := NULL;
          ELSE
             -- modified for numerical value error (bug#4106045)
             l_probation_period := fnd_number.number_to_canonical(r_app.app_prob_period*l_units_in_days);
          END IF;
          --
          /* Work out how many weeks make up a day/week/month/year then multiply that by the normal working hours value */
          l_trace := 'Calculating normal working hours';
          -- modified for numerical value error (bug#4106045)
          l_units_in_weeks := fnd_number.canonical_to_number(get_alternate_lookup
                              (p_table_name     => 'FREQUENCY'
                              ,p_col_name       => 'DUE_FREQUENCY_IN_WEEKS'
                              ,p_row_value      => r_app.frequency));
          --
          IF l_units_in_weeks IS NULL THEN
             l_working_hours := NULL;
          ELSE
             -- modified for numerical value error (bug#4106045)
             l_working_hours := fnd_number.number_to_canonical(round(r_app.app_hours*l_units_in_weeks));
          END IF;
          --
          /*Get the NAF meaning*/
          l_naf_meaning := hr_general.decode_lookup(p_lookup_type => 'FR_NAF_CODE',
                                                    p_lookup_code => r_app.naf_code);
          --
          /*Get rid of characters from start_time field*/
          r_app.start_time := REPLACE(TRANSLATE(r_app.start_time,TRANSLATE(r_app.start_time,'0123456789','*'),'*'),'*',null);
          --
          /* Change all the Y's to O's - hard-coded translation for y (yes) */
          r_app.app_inform_mt := REPLACE(r_app.app_inform_mt,'Y','O');
          r_app.app_request_ni := REPLACE(r_app.app_request_ni,'Y','O');
          r_app.app_assedic := REPLACE(r_app.app_assedic,'Y','O');
          r_app.app_titulair := REPLACE(r_app.app_titulair,'Y','O');
          --
          l_trace := 'Monthly Hours';
          /* Round the monthly hours worked to nearest integer*/
          l_monthly_hours := ROUND(fnd_number.canonical_to_number(r_app.monthly_hours));
          --
	  l_trace := 'Building Output String';
          /* Build up the text string for output */
          l_text := RPAD(l_identifier,14)              -- Identification
                  ||RPAD('DUE',4)                      -- Text
                  ||RPAD(l_urssaf_code,3)              -- Code of URSSAF centre
                  ||RPAD(REPLACE(p_batch,'Y','O'),1)   -- I_AR_PAR_LOT
                  ||RPAD(NVL(p_fax,' '),11)            -- Employers fax number
                  ||RPAD(p_acknowledgement,1)          -- Type of Acknowledgement
                  ||RPAD(NVL(p_email_address,' '),30)  -- Employers email address
                  ||RPAD('912',8)                      -- Length of message
                  ||RPAD('100',3)                      -- Message version
                  ||RPAD(' ',2)                        -- Batch Process Error Code filled by URSSAF
                  ||RPAD(r_app.ass_id,15)              -- User defined assignment id
                  ||RPAD(TO_CHAR(l_date,'DDMMYYYY'),15) -- User defined l_date
                  ||RPAD(r_app.person_id,14)           -- User defined Person Id
                  ||TO_CHAR(sysdate,'DDMMYYYY')        -- Creation Date
                  ||TO_CHAR(sysdate,'HHMI')            -- Creation Hour
                  ||RPAD(l_urssaf_code,3)              -- Code of URSSAF attached to establishment
                  ||RPAD(r_app.siret,14)
                  ||'M'                                -- Moral (or Physical) Employer
                  ||RPAD(convert_uppercase(r_app.est_name),32)
                  ||RPAD(r_app.naf_code,4)
                  ||RPAD(convert_uppercase(r_app.loc_address1),32)
                  -- Modifying for bug #5240132
                   --||RPAD(convert_uppercase(NVL(r_app.loc_address2,' ')),32)
                  || RPAD(convert_uppercase(NVL((r_app.loc_address2||' ' || r_app.loc_address3),' ') ),32)
                  --
                  ||RPAD(r_app.loc_postal,5)
                  ||RPAD(convert_uppercase(r_app.loc_town),27)
                  ||RPAD(convert_uppercase(r_app.nom_de_naiss),32)
                  ||RPAD(convert_uppercase(r_app.app_first_name),32)
                  ||RPAD(NVL(r_app.app_ni,' '),13)
                  ||RPAD(TO_CHAR(r_app.app_dob,'DDMMYYYY'),8)
                  ||RPAD(convert_uppercase(NVL(r_app.app_town_birth,l_coun_of_birth)),24)
                  ||RPAD(convert_uppercase(l_coun_of_birth),20)
                  ||RPAD(TO_CHAR(l_from_date,'DDMMYYYY'),8)
                  ||RPAD(r_app.start_time,4)
                  ||RPAD(' ',5)                     -- R_DOSSIER Employee Number
                  ||RPAD(' ',2)                     --Acknowledgement of receipt return code (from URSSAF)
                  ||RPAD(NVL(l_naf_meaning,' '),70) --Type of activity of company
                  ||RPAD(' ',4)
                  ||RPAD(' ',4)                     --Title
                  ||RPAD(' ',32)                    --Employers Name
                  ||RPAD(NVL(r_app.loc_telephone,' '),11)
                  ||RPAD(NVL(p_fax,' '),11)         --Fax
                  -- Modifying for bug #5240132
                   --||RPAD(' ',32)                    --Employer correspondance address line1
       		  ||RPAD(convert_uppercase(NVL(r_estab_addr.address_line_1,' ')),32)
                   --||RPAD(' ',32)                    --Employer correspondance address line2
                  ||RPAD(convert_uppercase(NVL(r_estab_addr.address_line_2,' ')),32)
                   --||RPAD(' ',5)                     --Employer correspondance post code
                  ||RPAD(NVL(r_estab_addr.postal_code,' '),5)
                   --||RPAD(' ',27)                    --Employer correspondance distribution centre
                  ||RPAD(convert_uppercase(NVL(r_estab_addr.town_or_city,' ')),27)
                  --
                  ||'I'                             --Fixed value 'I' for email transmission
                  ||RPAD(' ',38)                    --Reserved by URSSAF
                  ||RPAD(convert_uppercase(r_app.nom_marital),32)
                  ||SUBSTR(r_app.app_sex,1,1)
                  ||RPAD(convert_uppercase(NVL(r_app.app_address1,' ')),32)
                  -- Modifying for bug #5240132
                   --||RPAD(convert_uppercase(NVL(r_app.app_address2,' ')),32)
  		  || RPAD(convert_uppercase(NVL((r_app.app_address2||' ' || r_app.app_address3),' ') ),32)
		  --
                  ||RPAD(NVL(r_app.app_pos_code,' '),5)
                  ||RPAD(convert_uppercase(NVL(r_app.app_town,' ')),27)  --Distribution Centre
                  ||RPAD(NVL(r_app.app_dept_code,' '),2)
                  ||RPAD(convert_uppercase(NVL(l_nationality,' ')),32)
                  ||RPAD(NVL(r_app.app_training_level,' '),1)
                  ||RPAD(NVL(r_app.app_emp_code,' '),1)
                  ||RPAD(NVL(r_app.app_qual_code,' '),1)
                  ||RPAD(NVL(r_app.app_contract_cat,' '),1)
                  ||RPAD(NVL(r_app.con_end_date,' '),8)
                  ||RPAD(NVL(r_app.proposed_end_date,' '),8)
                  ||RPAD(NVL(l_working_hours,' '),3)
                  ||RPAD(NVL(l_probation_period,' '),3)
                  ||RPAD(NVL(to_char(ROUND(r_app.app_proposed_monthly_salary)),' '),6)
                  ||RPAD(NVL(r_app.app_contact_name,' '),32)
                  ||RPAD(NVL(r_app.app_contact_telephone,' '),11)
                  ||RPAD(NVL(r_app.app_status_before_hire,' '),1)
                  ||RPAD(l_medical,10)
                  ||RPAD(NVL(l_monthly_hours,' '),4)                      -- Hours worked in a month
                  ||RPAD(' ',1)                                           -- Reserved by URSSAF
                  ||RPAD(l_est_total,5)
                  ||RPAD(l_ent_total,5)
                  ||l_nationality_type
                  ||RPAD(NVL(r_app.app_titulair,' '),1)
                  ||'M'                                                   -- Working Time Unit (Fixed): Month(M)
                  ||RPAD(NVL(r_app.ccy_code,' '),1)                       -- Currency code for monthly salary
                  ||RPAD(' ',2)                                           -- Reserved by URSSAF
                  ||'N'                                                   -- Indicates whether first employee within company
                  ||RPAD(' ',1)                                           -- Reserved by URSSAF
                  ||RPAD(NVL(REPLACE(p_dads,'Y','O'),' '),1)              -- I_certif
                  ||RPAD(' ',1)                                           -- Reserved by URSSAF
                  ||RPAD(NVL(r_app.app_assedic,' '),1)                    -- I_CHOM
                  ||RPAD(NVL(r_app.app_request_ni,' '),1)                 -- I_IMMA
                  ||RPAD(NVL(r_app.app_inform_mt,' '),1)                  -- I_MT
                  ||RPAD(NVL(REPLACE(p_pmf5,'Y','O'),' '),1)              -- I_PMF5
                  -- Removed for bug#4083763
                  --||RPAD(NVL(REPLACE(p_prem,'Y','O'),' '),1)            -- I_PREM
                  ||RPAD(' ',1)                                            -- for replacing the above column
                  --
                  ||RPAD(NVL(r_app.app_pt_exon,' '),1)                    -- I_TP
                  ||RPAD(' ',11);                                         -- Reserved by URSSAF
          --
          fnd_file.put_line(FND_FILE.OUTPUT,l_text);
          --
          write_report(r_app,'N');
          --
          l_trace := 'Updating per_assignment_extra_info';
          UPDATE per_assignment_extra_info
          SET    aei_information11 = 'N',
                 aei_information12 = fnd_date.date_to_canonical(sysdate)
          WHERE  rowid = r_app.row_id;
          --
       END IF; --l_error
       --
   END LOOP;
   IF c_app%ISOPEN THEN
      CLOSE c_app;
   ELSIF c_app_by_person%ISOPEN THEN
      CLOSE c_app_by_person;
   END IF;

   --
   retcode := 0 ;
   --
EXCEPTION
  WHEN OTHERS THEN
  retcode:=2;
  errbuf := l_trace||' '||SQLERRM;
  ROLLBACK;
END run_pre_hire;

end PERFRPHR;

/
