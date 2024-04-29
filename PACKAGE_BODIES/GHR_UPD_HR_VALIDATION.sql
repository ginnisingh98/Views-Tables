--------------------------------------------------------
--  DDL for Package Body GHR_UPD_HR_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_UPD_HR_VALIDATION" AS
/* $Header: ghuhrval.pkb 120.12 2007/09/25 06:13:36 utokachi noship $ */
  TYPE structure_type  IS RECORD (
                            name        VARCHAR2(80),
                            index_from  INTEGER,
                            count       INTEGER
                          );
  TYPE structure_table IS TABLE OF structure_type INDEX BY BINARY_INTEGER;
  TYPE column_type     IS RECORD (
                            name        VARCHAR2(80),
                            value       VARCHAR2(1)
                          );
  TYPE column_table    IS TABLE OF column_type INDEX BY BINARY_INTEGER;
  structures             structure_table;
  column_defs            column_table;
  structure_rows         INTEGER := 0;
  column_rows            INTEGER := 0;
  structures_loaded      BOOLEAN := FALSE;
  cur_structure          INTEGER := 0;
--
  FUNCTION get_structure_index(p_structure_name IN VARCHAR2) RETURN INTEGER IS
  -- Lookup for a structure name, returns index if found, otherwise -1
    result   INTEGER;
  BEGIN
    result := -1;
    FOR I IN 1..structure_rows LOOP
      IF structures(i).name = p_structure_name THEN
        result := I;
      END IF;
      EXIT WHEN result <> -1;
    END LOOP;
    RETURN result;
  END;
--
  FUNCTION get_column_index(p_structure_index IN INTEGER, p_column_name IN VARCHAR2)
  -- Lookup for a column name in a structure, returns index if found, otherwise -1
  RETURN INTEGER IS
    result  INTEGER;
  BEGIN
    result := -1;
    FOR i IN structures(p_structure_index).index_from..
              structures(p_structure_index).index_from+
                structures(p_structure_index).count
    LOOP
      IF column_defs(i).name = p_column_name THEN
        result := i;
      END IF;
      EXIT WHEN result <> -1;
    END LOOP;
    RETURN result;
  END;
--
  PROCEDURE set_structure(p_structure_name         IN VARCHAR2)
  -- Procedure to store structures for validation
  IS
    i   INTEGER;
  BEGIN
    IF NOT structures_loaded THEN
      structure_rows := structure_rows + 1;
      i := structure_rows;
      structures(i).name := p_structure_name;
      structures(i).count          := 0;
      IF i = 1 THEN
        structures(i).index_from     := 1;
      ELSE
        structures(i).index_from     := structures(i-1).index_from +
                                        structures(i-1).count;
      END IF;
    ELSE
      cur_structure := get_structure_index(p_structure_name);
    END IF;
  END set_structure;
--
  PROCEDURE set_column(p_record_structure_name  IN VARCHAR2,
                          p_record_structure_value IN VARCHAR2)
  -- Procedure to store column (name and value) for validation
  IS
    i   INTEGER;
  BEGIN
    IF NOT structures_loaded THEN
      column_rows := column_rows + 1;
      column_defs(column_rows).name    := p_record_structure_name;
      column_defs(column_rows).value   := SUBSTR( RTRIM(LTRIM(p_record_structure_value)),1,1);
      structures(structure_rows).count := structures(structure_rows).count + 1;
    ELSE
      i := get_column_index(cur_structure, p_record_structure_name);
      column_defs(i).value := SUBSTR( RTRIM(LTRIM(p_record_structure_value)),1,1);
    END IF;
  END set_column;
--
  PROCEDURE end_structures IS
  BEGIN
    IF NOT structures_loaded THEN
      structures_loaded := TRUE;
    END IF;
  END;
--
  FUNCTION get_form_item_name
    RETURN VARCHAR2 IS
  BEGIN
    -- Because forms can not directly read this global variable we need
    -- to write just a little function on the server to return the value!!
    RETURN(ghr_upd_hr_validation.form_item_name);
    --
  END get_form_item_name;
  --
  PROCEDURE set_form_item_name(p_value IN VARCHAR2) IS
  BEGIN
    ghr_upd_hr_validation.form_item_name := p_value;
    --
  END set_form_item_name;
  --
  -- Sundar Bug 4582970 - Added 3 parameters for benefits eit validation
  PROCEDURE check_required(p_pa_requests_type            IN ghr_pa_requests%ROWTYPE
                          ,p_asg_non_sf52_type           IN ghr_api.asg_non_sf52_type
                          ,p_per_group1_type             IN ghr_api.per_group1_type
                          ,p_per_uniformed_services_type IN ghr_api.per_uniformed_services_type
                          ,p_per_retained_grade_type     IN ghr_api.per_retained_grade_type
                          ,p_per_sep_retire_type         IN ghr_api.per_sep_retire_type
                          ,p_per_probations_type         IN ghr_api.per_probations_type
                          ,p_pos_grp1_type               IN ghr_api.pos_grp1_type
                          ,p_pos_grp2_type               IN ghr_api.pos_grp2_type
                          ,p_within_grade_increase_type  IN ghr_api.within_grade_increase_type
                          ,p_government_awards_type      IN ghr_api.government_awards_type
                          ,p_government_payroll_type     IN ghr_api.government_payroll_type
                          ,p_performance_appraisal_type  IN ghr_api.performance_appraisal_type
                          ,p_recruitment_bonus_type      IN ghr_api.recruitment_bonus_type
                          ,p_relocation_bonus_type       IN ghr_api.relocation_bonus_type
						  ,p_student_loan_repay_type	 IN ghr_api.student_loan_repay_type
						   --Pradeep
						  ,p_mddds_special_pay           IN ghr_api.mddds_special_pay_type
						  ,p_premium_pay_ind           IN ghr_api.premium_pay_ind_type
                          ,p_per_conversions_type        IN ghr_api.per_conversions_type
                          ,p_conduct_performance_type    IN ghr_api.conduct_performance_type
						  ,p_thrift_savings_plan         IN ghr_api.thrift_saving_plan
						  ,p_per_benefit_info            IN ghr_api.per_benefit_info_type
						  ,p_per_scd_info_type           IN ghr_api.per_scd_info_type
                          ) IS

    l_proc varchar2(72) := g_package||'check_required';

    struct_index   INTEGER;
    column_index   INTEGER;

    cursor cur_rpm (p_first_noa_id  IN NUMBER
                   ,p_second_noa_id IN NUMBER) IS
      SELECT distinct
             UPPER(pdf.record_structure_name)     record_structure_name
            ,UPPER(pdf.record_structure_col_name) record_structure_col_name
            ,pdf.name                             prompt
            ,pdf.form_block_name
            ,pdf.form_field_name
      FROM   ghr_pa_data_fields       pdf
            ,ghr_noa_fam_proc_methods fpm
            ,ghr_families             fam
            ,ghr_noa_families         naf
      WHERE (naf.nature_of_action_id = p_first_noa_id
          OR naf.nature_of_action_id = p_second_noa_id)
      AND    fam.noa_family_code = naf.noa_family_code
      AND    fam.required_flag = 'Y'
      AND    fam.noa_family_code = fpm.noa_family_code
      AND    fpm.required_flag = 'Y'
      AND    fpm.pa_data_field_id = pdf.pa_data_field_id
      -- Bug#3941541 Added the date condition to get the family.
      AND    p_pa_requests_type.effective_date BETWEEN NVL(naf.start_date_active,p_pa_requests_type.effective_date)
                                                   and NVL(naf.end_date_active,p_pa_requests_type.effective_date);

      cursor c_exemp is
      select ppf.effective_start_date effective_start_date
      from   per_people_f      ppf,
             per_person_types  ppt
      where ppf.person_id          = p_pa_requests_type.person_id
      and   ppf.person_type_id     = ppt.person_type_id
      and   ppt.SYSTEM_PERSON_TYPE = 'EX_EMP'
      and   ppf.effective_start_date > p_pa_requests_type.effective_date;

    l_null_list VARCHAR2(2000);
    l_at_least_one_null BOOLEAN := FALSE;
    l_exists            BOOLEAN := FALSE;
    l_exemp_start_date  date;

    l_exemp_award_date     DATE;
    l_award_date           DATE;

    l_rpa_eff_date         DATE;
    l_asg_end_date         DATE;
    l_position_id          NUMBER;

    PROCEDURE first_set_form_item_name(p_form_item_name IN VARCHAR2) IS
    BEGIN

      IF  ghr_upd_hr_validation.form_item_name IS NULL
        AND  p_form_item_name <> '.' THEN
        ghr_upd_hr_validation.form_item_name := p_form_item_name;
      END IF;

    END first_set_form_item_name;

    PROCEDURE check_null(p_value      IN VARCHAR2
                        ,p_prompt     IN VARCHAR2
                        ,p_block_name IN VARCHAR2
                        ,p_item_name  IN VARCHAR2
                        ,p_null_list  IN OUT NOCOPY  VARCHAR2
                        ,p_null       IN OUT NOCOPY  BOOLEAN) IS
     l_new_line varchar2(1) := substr('
',1,1);
    BEGIN
      IF p_value IS NULL THEN
        p_null := TRUE;
        IF p_null_list IS NULL THEN
          p_null_list := p_prompt;
        ELSE
          p_null_list := SUBSTR(p_null_list || ',' || l_new_line || p_prompt, 1 , 1900);
        END IF;
        first_set_form_item_name(p_block_name || '.' ||p_item_name);
      END IF;
    END check_null;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 1);
    --
    ghr_upd_hr_validation.form_item_name := null;
    -- I would like to have done this dynamically but I couldn't work out how and I was running
    -- out of time!!!!
    FOR cur_rpm_rec IN cur_rpm(p_pa_requests_type.first_noa_id,
                               p_pa_requests_type.second_noa_id)
    LOOP
       struct_index := get_structure_index(cur_rpm_rec.record_structure_name);
       IF struct_index <> -1 THEN
         column_index := get_column_index(struct_index, cur_rpm_rec.record_structure_col_name);
         IF column_index <> -1 THEN
           check_null(column_defs(column_index).value, cur_rpm_rec.prompt, cur_rpm_rec.form_block_name,
                      cur_rpm_rec.form_field_name, l_null_list, l_at_least_one_null);
         ELSE
           hr_utility.set_message(8301,'GHR_38235_INV_REC_STRUC_COL');
           fnd_message.set_token('RECORD_STRUCTURE_NAME',cur_rpm_rec.record_structure_name);
           fnd_message.set_token('RECORD_STRUCTURE_COL_NAME',cur_rpm_rec.record_structure_col_name);
           hr_utility.raise_error;
         END IF;
       ELSE
         hr_utility.set_message(8301,'GHR_38236_INV_REC_STRUC_NAME');
         fnd_message.set_token('RECORD_STRUCTURE_NAME',cur_rpm_rec.record_structure_name);
         hr_utility.raise_error;
       END IF;
    END LOOP;

    hr_utility.set_location(l_proc, 90);

    IF l_at_least_one_null THEN
      hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
      fnd_message.set_token('REQUIRED_LIST',l_null_list);
      hr_utility.raise_error;
    END IF;

    IF p_government_awards_type.date_exemp_award is not null then
       l_exemp_award_date := fnd_date.canonical_to_date(p_government_awards_type.date_exemp_award);
       l_award_date       := fnd_date.canonical_to_date(p_government_awards_type.date_award_earned);

       get_rpa_info(p_pa_requests_type.pa_request_id,l_asg_end_date,l_rpa_eff_date,l_position_id);

--Bug 2837169

       IF l_rpa_eff_date <> l_asg_end_date THEN
         hr_utility.set_message(8301, 'GHR_38835_EFF_DT_EQUAL_SEP_DT');
         hr_utility.raise_error;
        END IF;
--End of Bug 2837169

       IF l_award_date IS NOT NULL THEN
          IF l_exemp_award_date < l_award_date THEN
             hr_utility.set_message(8301, 'GHR_38806_EXEMP_AWD_AWD_EARNED');
             hr_utility.raise_error;
          END IF;
       END IF;
       -- Bug#2835007 Added NOAC 848
       IF nvl(p_pa_requests_type.first_noa_code,'@@') in ('846','847','848','872') then
          hr_utility.set_message(8301, 'GHR_38809_EXEMP_AWD_INV_NOA');
          hr_utility.raise_error;
       END IF;
    END IF;

    IF p_government_awards_type.date_exemp_award is not null THEN
       for c_exemp_rec in c_exemp loop
       l_exemp_start_date := c_exemp_rec.effective_start_date;
       l_exists := TRUE;
       exit;
       end loop;
       IF NOT l_exists THEN
          hr_utility.set_message(8301, 'GHR_38809_EXEMP_AWD_INV_NOA');
          hr_utility.raise_error;
       ELSE
          IF l_exemp_award_date <  l_asg_end_date THEN
             hr_utility.set_message(8301, 'GHR_38807_EXEMP_AWD_EQUAL_SEP');
             hr_utility.raise_error;
          END IF;
       END IF;
     END IF;

  END check_required;
  --
  PROCEDURE check_insertion_values(p_pa_requests_type IN ghr_pa_requests%ROWTYPE) IS
  --
  l_proc varchar2(72) := g_package||'check_insertion_values';
  BEGIN
    -- This procedure just checks that if insertion values should have been entered they
    -- have been. It assumes that all insertion values are required!
    -- It is also a bit of a sneaky check in that all it checks is if there are '__'
    -- (underscores) left in the description then we are missing insertion values
    -- It does not directly check what segments are defined for a given NOAC/LAC and then check
    -- if those segments have been entered. Hence this solution is a bit crude but it is quick!
    --
    hr_utility.set_location('Entering:'||l_proc, 1);
    --
    IF p_pa_requests_type.first_noa_desc IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.first_noa_desc,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38238_1ST_NOA_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    IF p_pa_requests_type.first_action_la_desc1 IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.first_action_la_desc1,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38239_1ST_LA1_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    IF p_pa_requests_type.first_action_la_desc2 IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.first_action_la_desc2,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38240_1ST_LA2_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    IF p_pa_requests_type.second_noa_desc IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.second_noa_desc,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38241_2ND_NOA_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    IF p_pa_requests_type.second_action_la_desc1 IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.second_action_la_desc1,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38242_2ND_LA1_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    IF p_pa_requests_type.second_action_la_desc2 IS NOT NULL THEN
      IF INSTR(p_pa_requests_type.second_action_la_desc2,'__') <> 0 THEN
        hr_utility.set_message(8301,'GHR_38243_2ND_LA2_INSERT_REQD');
        hr_utility.raise_error;
      END IF;
    END IF;
    --
    hr_utility.set_location('Leaving:'||l_proc, 40);
    --
  END check_insertion_values;
  --
  PROCEDURE main_validation(p_pa_requests_type            IN ghr_pa_requests%ROWTYPE
                         ,p_asg_non_sf52_type           IN ghr_api.asg_non_sf52_type
                         ,p_asg_nte_dates_type          IN ghr_api.asg_nte_dates_type
                         ,p_per_group1_type             IN ghr_api.per_group1_type
                         ,p_per_uniformed_services_type IN ghr_api.per_uniformed_services_type
                         ,p_per_retained_grade_type     IN ghr_api.per_retained_grade_type
                         ,p_per_sep_retire_type         IN ghr_api.per_sep_retire_type
                         ,p_per_probations_type         IN ghr_api.per_probations_type
                         ,p_pos_grp1_type               IN ghr_api.pos_grp1_type
                         ,p_pos_grp2_type               IN ghr_api.pos_grp2_type
                         ,p_within_grade_increase_type  IN ghr_api.within_grade_increase_type
                         ,p_government_awards_type      IN ghr_api.government_awards_type
                         ,p_government_payroll_type     IN ghr_api.government_payroll_type
                         ,p_performance_appraisal_type  IN ghr_api.performance_appraisal_type
                         ,p_recruitment_bonus_type      IN ghr_api.recruitment_bonus_type
                         ,p_relocation_bonus_type       IN ghr_api.relocation_bonus_type
						  ,p_student_loan_repay_type     IN ghr_api.student_loan_repay_type
                          --Pradeep
                         ,p_mddds_special_pay           IN ghr_api.mddds_special_pay_type
                         ,p_premium_pay_ind             IN ghr_api.premium_pay_ind_type
                         ,p_per_conversions_type        IN ghr_api.per_conversions_type
                         ,p_conduct_performance_type    IN ghr_api.conduct_performance_type
						  -- Sundar Bug 4582970 Added for Benefits EIT validation
						  ,p_thrift_savings_plan         IN ghr_api.thrift_saving_plan
						  ,p_per_benefit_info            IN ghr_api.per_benefit_info_type
						  ,p_per_scd_info_type           IN ghr_api.per_scd_info_type
                           ) IS
    l_proc varchar2(72) := g_package||'main_validation';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 1);
    --
    set_structure('PA_REQUESTS_TYPE');
    set_column('ACADEMIC_DISCIPLINE',           p_pa_requests_type.academic_discipline);
    set_column('ADITIONAL_INFO_PERSON_ID',      p_pa_requests_type.additional_info_person_id);
    set_column('ADITIONAL_INFO_TEL_NUMBER',     p_pa_requests_type.additional_info_tel_number);
    set_column('ANNUITANT_INDICATOR',           p_pa_requests_type.annuitant_indicator);
    set_column('ANNUITANT_INDICATOR_DESC',      p_pa_requests_type.annuitant_indicator_desc);
    set_column('APPROPRIATION_CODE1',           p_pa_requests_type.appropriation_code1);
    set_column('APPROPRIATION_CODE2',           p_pa_requests_type.appropriation_code2);
    set_column('AUTHORIZED_BY_PERSON_ID',       p_pa_requests_type.authorized_by_person_id);
    set_column('AUTHORIZED_BY_TITLE',           p_pa_requests_type.authorized_by_title);
----GPPA Update Req. for 891, 892 to bypass
     if p_pa_requests_type.first_noa_code  in ('891','892') Then
      set_column('AWARD_AMOUNT',                hr_api.g_number);
      set_column('AWARD_UOM',                   hr_api.g_varchar2);
----GPPA End
    else
      set_column('AWARD_AMOUNT',                p_pa_requests_type.award_amount);
      set_column('AWARD_UOM',                   p_pa_requests_type.award_uom);
    end if;
    set_column('BARGAINING_UNIT_STATUS',        p_pa_requests_type.bargaining_unit_status);
    set_column('CITIZENSHIP',                   p_pa_requests_type.citizenship);
    set_column('CONCURRENCE_DATE',              p_pa_requests_type.concurrence_date);
    set_column('DUTY_STATION_CODE',             p_pa_requests_type.duty_station_code);
    set_column('DUTY_STATION_DESC',             p_pa_requests_type.duty_station_desc);
    set_column('EDUCATION_LEVEL',               p_pa_requests_type.education_level);
    set_column('EFFECTIVE_DATE',                p_pa_requests_type.effective_date);
    set_column('EMPLOYEE_DATE_OF_BIRTH',        p_pa_requests_type.employee_date_of_birth);
    set_column('EMPLOYEE_FIRST_NAME',           p_pa_requests_type.employee_first_name);
    set_column('EMPLOYEE_LAST_NAME',            p_pa_requests_type.employee_last_name);
    set_column('EMPLOYEE_MIDDLE_NAMES',         p_pa_requests_type.employee_middle_names);
    set_column('EMPLOYEE_NATIONAL_IDENTIFIER',  p_pa_requests_type.employee_national_identifier);
    set_column('FEGLI',                         p_pa_requests_type.fegli);
    set_column('FEGLI_DESC',                    p_pa_requests_type.fegli_desc);
    -- Start Bug 1379280
    -- Assigning hr_api.g_varchar2 to First Legal Authority fields

    hr_utility.set_location('effe date ....'||to_char(p_pa_requests_type.effective_date,'DD/MM/YYYY'),9999);

    -- to avoid getting required error message for NOACs 840-847,849
     if (p_pa_requests_type.first_noa_code  in ('840','841','842','843',
                                                 '844','845','846','847','848',
						 '886','887','889')) --removed 885 and 886 for bug 5676626
                                             --Added 886 for Bug # 6127577
     OR (p_pa_requests_type.first_noa_code  in ('849') and
       p_pa_requests_type.effective_date > to_date('2007/01/06','YYYY/MM/DD'))then --bug 5482191
      set_column('FIRST_ACTION_LA_CODE1',         hr_api.g_varchar2);
      set_column('FIRST_ACTION_LA_CODE2',         hr_api.g_varchar2);
      set_column('FIRST_ACTION_LA_DESC1',         hr_api.g_varchar2);
      set_column('FIRST_ACTION_LA_DESC2',         hr_api.g_varchar2);
    else
    set_column('FIRST_ACTION_LA_CODE1',         p_pa_requests_type.first_action_la_code1);
    set_column('FIRST_ACTION_LA_CODE2',         p_pa_requests_type.first_action_la_code2);
    set_column('FIRST_ACTION_LA_DESC1',         p_pa_requests_type.first_action_la_desc1);
    set_column('FIRST_ACTION_LA_DESC2',         p_pa_requests_type.first_action_la_desc2);
    end if;
    -- End Bug 1379280
    set_column('FIRST_NOA_CODE',                p_pa_requests_type.first_noa_code);
    set_column('FIRST_NOA_DESC',                p_pa_requests_type.firsT_noa_desc);
    set_column('FLSA_CATEGORY',                 p_pa_requests_type.flsa_category);
    set_column('FORWARDING_ADDRESS_LINE1',      p_pa_requests_type.forwarding_address_line1);
    set_column('FORWARDING_ADDRESS_LINE2',      p_pa_requests_type.forwarding_address_line2);
    set_column('FORWARDING_ADDRESS_LINE3',      p_pa_requests_type.forwarding_address_line3);
    set_column('FORWARDING_COUNTRY_SHORT_NAME', p_pa_requests_type.forwarding_country_short_name);
    set_column('FORWARDING_POSTAL_CODE',        p_pa_requests_type.forwarding_postal_code);
    set_column('FORWARDING_REGION_2',           p_pa_requests_type.forwarding_region_2);
    set_column('FORWARDING_TOWN_OR_CITY',       p_pa_requests_type.forwarding_town_or_city);
    set_column('FROM_ADJ_BASIC_PAY',            p_pa_requests_type.from_adj_basic_pay);
    set_column('FROM_BASIC_PAY',                p_pa_requests_type.from_basic_pay);
    set_column('FROM_GRADE_OR_LEVEL',           p_pa_requests_type.from_grade_or_level);
    set_column('FROM_LOCALITY_ADJ',             p_pa_requests_type.from_locality_adj);
    set_column('FROM_OCC_CODE',                 p_pa_requests_type.from_occ_code);
    set_column('FROM_OTHER_PAY_AMOUNT',         p_pa_requests_type.from_other_pay_amount);
    set_column('FROM_PAY_BASIS',                p_pa_requests_type.from_pay_basis);
    set_column('FROM_PAY_PLAN',                 p_pa_requests_type.from_pay_plan);
    set_column('FROM_POSITION_ORG_LINE1',       p_pa_requests_type.from_position_org_line1);
    set_column('FROM_POSITION_ORG_LINE2',       p_pa_requests_type.from_position_org_line2);
    set_column('FROM_POSITION_ORG_LINE3',       p_pa_requests_type.from_position_org_line3);
    set_column('FROM_POSITION_ORG_LINE4',       p_pa_requests_type.from_position_org_line4);
    set_column('FROM_POSITION_ORG_LINE5',       p_pa_requests_type.from_position_org_line5);
    set_column('FROM_POSITION_ORG_LINE6',       p_pa_requests_type.from_position_org_line6);
    set_column('FROM_POSITION_NUMBER',          p_pa_requests_type.from_position_number);
    set_column('FROM_POSITION_SEQ_NO',          p_pa_requests_type.from_position_seq_no);
    set_column('FROM_POSITION_TITLE',           p_pa_requests_type.from_position_title);
    set_column('FROM_STEP_OR_RATE',             p_pa_requests_type.from_step_or_rate);
    set_column('FROM_TOTAL_SALARY',             p_pa_requests_type.from_total_salary);
    set_column('FUNCTIONAL_CLASS',              p_pa_requests_type.functional_class);
    set_column('NOA_FAMILY_CODE',               p_pa_requests_type.noa_family_code);
    set_column('PART_TIME_HOURS',               p_pa_requests_type.part_time_hours);
    set_column('PAY_RATE_DETERMINANT',          p_pa_requests_type.pay_rate_determinant);
    set_column('POSITION_OCCUPIED',             p_pa_requests_type.position_occupied);
    set_column('PROPOSED_EFFECTIVE_ASAP_FLAG',  p_pa_requests_type.proposed_effective_asap_flag);
    set_column('PROPOSED_EFFECTIVE_DATE',       p_pa_requests_type.proposed_effective_date);
    set_column('REQUESTED_BY_PERSON_ID',        p_pa_requests_type.requested_by_person_id);
    set_column('REQUESTED_BY_TITLE',            p_pa_requests_type.requested_by_title);
    set_column('REQUESTED_DATE',                p_pa_requests_type.requested_date);
    set_column('REQUESTING_OFFICE_REMARKS_DESC',p_pa_requests_type.requesting_office_remarks_desc);
    set_column('REQUESTING_OFFICE_REMARKS_FLAG',p_pa_requests_type.requesting_office_remarks_flag);
    set_column('REQUEST_NUMBER',                p_pa_requests_type.request_number);
    set_column('RESIGN_AND_RETIRE_REASON_DESC', p_pa_requests_type.resign_and_retire_reason_desc);
    set_column('RETIREMENT_PLAN',               p_pa_requests_type.retirement_plan);
    set_column('RETIREMENT_PLAN_DESC',          p_pa_requests_type.retirement_plan_desc);
    set_column('SECOND_ACTION_LA_CODE1',        p_pa_requests_type.second_action_la_code1);
    set_column('SECOND_ACTION_LA_CODE2',        p_pa_requests_type.second_action_la_code2);
    set_column('SECOND_ACTION_LA_DESC1',        p_pa_requests_type.second_action_la_desc1);
    set_column('SECOND_ACTION_LA_DESC2',        p_pa_requests_type.second_action_la_desc2);
    set_column('SECOND_NOA_CODE',               p_pa_requests_type.second_noa_code);
    set_column('SECOND_NOA_DESC',               p_pa_requests_type.second_noa_desc);
    set_column('SERVICE_COMP_DATE',             p_pa_requests_type.service_comp_date);
    set_column('SUPERVISORY_STATUS',            p_pa_requests_type.supervisory_status);
    set_column('TENURE',                        p_pa_requests_type.tenure);
    set_column('TO_ADJ_BASIC_PAY',              p_pa_requests_type.to_adj_basic_pay);
    set_column('TO_BASIC_PAY',                  p_pa_requests_type.to_basic_pay);
    set_column('TO_GRADE_OR_LEVEL',             p_pa_requests_type.to_grade_or_level);
    set_column('TO_LOCALITY_ADJ',               p_pa_requests_type.to_locality_adj);
    set_column('TO_OCC_CODE',                   p_pa_requests_type.to_occ_code);
    set_column('TO_OTHER_PAY_AMOUNT',           p_pa_requests_type.to_other_pay_amount);
    set_column('TO_PAY_BASIS',                  p_pa_requests_type.to_pay_basis);
    set_column('TO_PAY_PLAN',                   p_pa_requests_type.to_pay_plan);
-- Rohini
    set_column('TO_ORGANIZATION_ID',            p_pa_requests_type.to_organization_id);
-- Rohini
    set_column('TO_POSITION_ORG_LINE1',         p_pa_requests_type.to_position_org_line1);
    set_column('TO_POSITION_ORG_LINE2',         p_pa_requests_type.to_position_org_line2);
    set_column('TO_POSITION_ORG_LINE3',         p_pa_requests_type.to_position_org_line3);
    set_column('TO_POSITION_ORG_LINE4',         p_pa_requests_type.to_position_org_line4);
    set_column('TO_POSITION_ORG_LINE5',         p_pa_requests_type.to_position_org_line5);
    set_column('TO_POSITION_ORG_LINE6',         p_pa_requests_type.to_position_org_line6);
    set_column('TO_POSITION_NUMBER',            p_pa_requests_type.to_position_number);
    set_column('TO_POSITION_SEQ_NO',            p_pa_requests_type.to_position_seq_no);
    set_column('TO_POSITION_TITLE',             p_pa_requests_type.to_position_title);
    set_column('TO_STEP_OR_RATE',               p_pa_requests_type.to_step_or_rate);
    set_column('TO_TOTAL_SALARY',               p_pa_requests_type.to_total_salary);
    set_column('VETERANS_PREFERENCE',           p_pa_requests_type.veterans_preference);
    set_column('VETERANS_PREF_FOR_RIF',         p_pa_requests_type.veterans_pref_for_rif);
    set_column('VETERANS_STATUS',               p_pa_requests_type.veterans_status);
    set_column('WORK_SCHEDULE',                 p_pa_requests_type.work_schedule);
    set_column('WORK_SCHEDULE_DESC',            p_pa_requests_type.work_schedule_desc);
    set_column('YEAR_DEGREE_ATTAINED',          p_pa_requests_type.year_degree_attained);
    -- End of PA_REQUESTS_TYPE structure
    set_structure('ASG_NON_SF52_TYPE');
    set_column('DATE_ARR_PERSONNEL_OFFICE',     p_asg_non_sf52_type.date_arr_personnel_office);
    set_column('NON_DISC_AGMT_STATUS',          p_asg_non_sf52_type.non_disc_agmt_status);
    set_column('PARTTIME_INDICATOR',            p_asg_non_sf52_type.parttime_indicator);
    set_column('QUALIFICATION_STANDARD_WAIVER', p_asg_non_sf52_type.qualification_standard_waiver);
    -- End of ASG_NON_SF52_TYPE
    set_structure('PER_GROUP1_TYPE');
    set_column('APPOINTMENT_TYPE',              p_per_group1_type.appointment_type);
    set_column('TYPE_OF_EMPLOYMENT',            p_per_group1_type.type_of_employment);
    set_column('RACE_NATIONAL_ORIGIN',          p_per_group1_type.race_national_origin);
    set_column('ORG_APPOINTMENT_AUTH_CODE1',    p_per_group1_type.org_appointment_auth_code1);
    set_column('ORG_APPOINTMENT_AUTH_CODE2',    p_per_group1_type.org_appointment_auth_code2);
    set_column('HANDICAP_CODE',                 p_per_group1_type.handicap_code);
    -- Rohini
   set_column('AGENCY_CODE_TRANSFER_FROM',      p_per_group1_type.agency_code_transfer_from);
    -- End of PER_GROUP1_TYPE
    set_structure('PER_UNIFORMED_SERVICES_TYPE');
    set_column('CREDITABLE_MILITARY_SERVICE',
      p_per_uniformed_services_type.creditable_military_service);
    -- End of PER_UNIFORMED_SERVICES_TYPE
    set_structure('PER_RETAINED_GRADE_TYPE');

   IF NOT ( p_pa_requests_type.first_noa_code = '890' AND
           p_pa_requests_type.input_pay_rate_determinant in ('A','B','E','F','U','V') ) THEN
         hr_utility.set_location('Input Pay Rate Determinant  ' ||  p_pa_requests_type.input_pay_rate_determinant, 99999);
         hr_utility.set_location('First Noa Code              ' ||  p_pa_requests_type.first_noa_code, 99999);
    set_column('DATE_FROM',                     hr_api.g_date);
    set_column('DATE_TO',                       hr_api.g_date);
    set_column('RETAIN_GRADE',                  hr_api.g_varchar2);
    set_column('RETAIN_STEP_OR_RATE',           hr_api.g_varchar2);
    set_column('RETAIN_PAY_PLAN',               hr_api.g_varchar2);
    set_column('RETAIN_PAY_TABLE_ID',           hr_api.g_number);
    set_column('RETAIN_LOCALITY_PERCENT',       hr_api.g_number);
    set_column('RETAIN_PAY_BASIS',              hr_api.g_varchar2);
    set_column('PERSON_EXTRA_INFO_ID' ,         hr_api.g_number);
   ELSE
    set_column('DATE_FROM',                     p_per_retained_grade_type.date_from);
    set_column('DATE_TO',                       p_per_retained_grade_type.date_to);
    set_column('RETAIN_GRADE',                  p_per_retained_grade_type.retain_grade);
    set_column('RETAIN_STEP_OR_RATE',           p_per_retained_grade_type.retain_step_or_rate);
    set_column('RETAIN_PAY_PLAN',               p_per_retained_grade_type.retain_pay_plan);
    set_column('RETAIN_PAY_TABLE_ID',           p_per_retained_grade_type.retain_pay_table_id);
    set_column('RETAIN_LOCALITY_PERCENT',       p_per_retained_grade_type.retain_locality_percent);
    set_column('RETAIN_PAY_BASIS',              p_per_retained_grade_type.retain_pay_basis);

 -- Rohini
set_column('PERSON_EXTRA_INFO_ID' ,         p_per_retained_grade_type.person_extra_info_id);
  -- Rohini
    END IF;
    -- End of PER_RETAINED_GRADE_TYPE
    set_structure('PER_SEP_RETIRE_TYPE');
    set_column('FERS_COVERAGE',                 p_per_sep_retire_type.fers_coverage);
    set_column('PREV_RETIREMENT_COVERAGE',      p_per_sep_retire_type.prev_retirement_coverage);
    set_column('FROZEN_SERVICE',                p_per_sep_retire_type.frozen_service);
    set_column('AGENCY_CODE_TRANSFER_TO',       p_per_sep_retire_type.agency_code_transfer_to);
    -- End of PER_SEP_RETIRE_TYPE
    set_structure('PER_PROBATIONS_TYPE');
    set_column('DATE_PROB_TRIAL_PERIOD_BEGIN',  p_per_probations_type.date_prob_trial_period_begin);
    set_column('DATE_PROB_TRIAL_PERIOD_ENDS',   p_per_probations_type.date_prob_trial_period_ends);
    set_column('DATE_SPVR_MGR_PROB_ENDS',       p_per_probations_type.date_spvr_mgr_prob_ends);
    set_column('SPVR_MGR_PROB_COMPLETION',      p_per_probations_type.spvr_mgr_prob_completion);
    set_column('DATE_SES_PROB_EXPIRES',         p_per_probations_type.date_ses_prob_expires);
    -- End of PER_PROBATIONS_TYPE
    set_structure('POS_GRP1_TYPE');
    set_column('PERSONNEL_OFFICE_ID',           p_pos_grp1_type.personnel_office_id);
    set_column('POSITION_WORKING_TITLE',        p_pos_grp1_type.position_working_title);
    set_column('PAYROLL_OFFICE_ID',             p_pos_grp1_type.payroll_office_id);
    -- End of POS_GRP1_TYPE
    set_structure('POS_GRP2_TYPE');
    set_column('KEY_EMERGENCY_ESSENTIAL',       p_pos_grp2_type.key_emergency_essential);
    -- End of POS_GRP2_TYPE
    set_structure('WITHIN_GRADE_INCREASE_TYPE');
    set_column('P_DATE_WGI_DUE',                p_within_grade_increase_type.p_date_wgi_due);
    set_column('P_DATE_WGI_POSTPONE_EFFECTIVE',
      p_within_grade_increase_type.p_date_wgi_postpone_effective);
    -- End of WITHIN_GRADE_INCREASE_TYPE
    set_structure('GOVERNMENT_AWARDS_TYPE');
    set_column('AWARD_AGENCY',                  p_government_awards_type.award_agency);
    set_column('AWARD_TYPE',                    p_government_awards_type.award_type);
    set_column('PERCENTAGE',                    p_government_awards_type.percentage);
    set_column('GROUP_AWARD',                   p_government_awards_type.group_award);
    set_column('TANGIBLE_BENEFIT_DOLLARS',      p_government_awards_type.tangible_benefit_dollars);
    -- End of GOVERNMENT_AWARDS_TYPE
    set_structure('GOVERNMENT_PAYROLL_TYPE');
    set_column('PAYROLL_TYPE',                  p_government_payroll_type.payroll_type);
    -- End of GOVERNMENT_PAYROLL_TYPE
    set_structure('PERFORMANCE_APPRAISAL_TYPE');
    set_column('RATING_REC',                    p_performance_appraisal_type.rating_rec);
    set_column('RATING_REC_PATTERN',            p_performance_appraisal_type.rating_rec_pattern);
    set_column('RATING_REC_LEVEL',              p_performance_appraisal_type.rating_rec_level);
    set_column('DATE_APPR_ENDS',                p_performance_appraisal_type.date_appr_ends);
    -- End of PERFORMANCE_APPRAISAL_TYPE
    set_structure('RECRUITMENT_BONUS_TYPE');
    set_column('P_DATE_RECRUIT_EXP',            p_recruitment_bonus_type.p_date_recruit_exp);
    -- End of RECRUITMENT_BONUS_TYPE
    set_structure('RELOCATION_BONUS_TYPE');
    set_column('P_DATE_RELOC_EXP',              p_relocation_bonus_type.p_date_reloc_exp);
    -- End of RELOCATION_BONUS_TYPE

    -- STUDENT LOAN REPAYMENT
    set_structure('STUDENT_LOAN_REPAY_TYPE');
    set_column('P_AMOUNT',                      p_student_loan_repay_type.p_amount);
    set_column('P_REPAY_SCHEDULE',              p_student_loan_repay_type.p_repay_schedule);
    set_column('P_REVIEW_DATE',                 p_student_loan_repay_type.p_review_date);
    -- END OF STUDENT LOAN REPAY STRUCTURE

     --MDDDS_SPECIAL_PAY_TYPE
     set_structure('MDDDS_SPECIAL_PAY_TYPE');
     set_column('Full_Time_Status', p_mddds_special_pay.Full_Time_Status);
     set_column('Length_of_Service', p_mddds_special_pay.Length_of_Service);
     set_column('Scarce_Specialty', p_mddds_special_pay.Scarce_Specialty);
     set_column('Specialty_or_Board_Cert', p_mddds_special_pay.Specialty_or_Board_Cert);
     set_column('Geographic_Location', p_mddds_special_pay.Geographic_Location);
     set_column('Exceptional_Qualifications', p_mddds_special_pay.Exceptional_Qualifications);
     set_column('Executive_Position', p_mddds_special_pay.Executive_Position);
     set_column('Dentist_Post_Graduate_Training', p_mddds_special_pay.Dentist_Post_Graduate_Training);
     set_column('Amount', p_mddds_special_pay.Amount);
     set_column('mddds_special_pay_date', p_mddds_special_pay.mddds_special_pay_date);
     set_column('premium_pay_ind',p_mddds_special_pay.premium_pay_ind);
     -- END OF MDDDS_SPECIAL_PAY_TYPE

     -- PREMIUM_PAY_IND_TYPE
     set_structure('PREMIUM_PAY_IND_TYPE');
     set_column('premium_pay_ind',p_premium_pay_ind.premium_pay_ind);
     -- END OF PREMIUM_PAY_IND_TYPE

    set_structure('PER_CONVERSIONS_TYPE');
    set_column('DATE_CONV_CAREER_BEGINS',       p_per_conversions_type.date_conv_career_begins);
    set_column('DATE_CONV_CAREER_DUE',          p_per_conversions_type.date_conv_career_due);
    set_column('DATE_RECMD_CONV_BEGINS',        p_per_conversions_type.date_recmd_conv_begins);
    set_column('DATE_RECMD_CONV_DUE',           p_per_conversions_type.date_recmd_conv_due);
    set_column('DATE_VRA_CONV_DUE',             p_per_conversions_type.date_vra_conv_due);
    -- End of PER_CONVERSIONS_TYPE
    set_structure('CONDUCT_PERFORMANCE_TYPE');
    set_column('ADVERSE_ACTION_NOAC',           p_conduct_performance_type.adverse_action_noac);
    set_column('CAUSE_OF_DISC_ACTION',          p_conduct_performance_type.cause_of_disc_action);
    set_column('DATE_OF_ADVERSE_ACTION',        p_conduct_performance_type.date_of_adverse_action);
    set_column('DAYS_SUSPENDED',                p_conduct_performance_type.days_suspended);
    set_column('DATE_SUSPENSION_OVER_30',       p_conduct_performance_type.date_suspension_over_30);
    set_column('DATE_SUSPENSION_UNDER_30',      p_conduct_performance_type.date_suspension_under_30);
    set_column('PIP_ACTION_TAKEN',              p_conduct_performance_type.pip_action_taken);
    set_column('PIP_BEGIN_DATE',                p_conduct_performance_type.pip_begin_date);
    set_column('PIP_END_DATE',                  p_conduct_performance_type.pip_end_date);
    set_column('PIP_EXTENSIONS',                p_conduct_performance_type.pip_extensions);
    set_column('PIP_LENGTH',                    p_conduct_performance_type.pip_length);
    -- End of CONDUCT_PERFORMANCE_TYPE
    end_structures;
    --
    check_required(p_pa_requests_type
                  ,p_asg_non_sf52_type
                  ,p_per_group1_type
                  ,p_per_uniformed_services_type
                  ,p_per_retained_grade_type
                  ,p_per_sep_retire_type
                  ,p_per_probations_type
                  ,p_pos_grp1_type
                  ,p_pos_grp2_type
                  ,p_within_grade_increase_type
                  ,p_government_awards_type
                  ,p_government_payroll_type
                  ,p_performance_appraisal_type
                  ,p_recruitment_bonus_type
                  ,p_relocation_bonus_type
                  ,p_student_loan_repay_type
                  --Pradeep
                  ,p_mddds_special_pay
				  ,p_premium_pay_ind
                  ,p_per_conversions_type
                  ,p_conduct_performance_type
				  ,p_thrift_savings_plan
				  ,p_per_benefit_info
				  ,p_per_scd_info_type
                  );

    --
    hr_utility.set_location(l_proc, 10);
    --
    check_insertion_values(p_pa_requests_type);
    --
    hr_utility.set_location('Leaving:'||l_proc, 40);
    --
  END main_validation;

--
  FUNCTION get_exemp_award_date(p_pa_request_id IN NUMBER) RETURN DATE IS
  CURSOR cur_exemp_award IS
  select fnd_date.canonical_to_date(rei_information11)  rei_information11
  from ghr_pa_request_extra_info
  where pa_request_id = p_pa_request_id
  and information_type = 'GHR_US_PAR_AWARDS_BONUS';

  BEGIN
   FOR cur_exemp_award_rec IN cur_exemp_award LOOP
    RETURN(cur_exemp_award_rec.rei_information11);
   END LOOP;
   RETURN(Null);
  END get_exemp_award_date;

--
PROCEDURE get_rpa_info(p_pa_request_id IN NUMBER,
                       p_asg_end_date  OUT NOCOPY  DATE,
                       p_rpa_eff_date  OUT NOCOPY  DATE,
                       p_position_id   OUT NOCOPY  NUMBER) IS


 l_person_id per_people_f.person_id%TYPE;

 CURSOR cur_rpa_data IS
 select effective_date, person_id, to_position_id
 from ghr_pa_requests
 where pa_request_id = p_pa_request_id;

/****AVR Commented. 27-FEB-2003
 CURSOR cur_asg_end_date IS
 select effective_end_date
 from per_assignments_f
 where person_id = l_person_id
 and p_rpa_eff_date
 between effective_start_date and effective_end_date;
*****/

l_date     date;

cursor cur_asg_end_date is
select ppf.effective_end_date effective_end_date,
       ppt.system_person_type system_person_type
from   per_people_f      ppf,
       per_person_types  ppt
where ppf.person_id           = l_person_id
and   ppf.person_type_id      = ppt.person_type_id
and   ppf.effective_end_date >= p_rpa_eff_date
and   ppt.SYSTEM_PERSON_TYPE > 'APL'
order by ppf.effective_start_date;

BEGIN

  FOR cur_rpa_data_rec IN cur_rpa_data LOOP
    p_rpa_eff_date := cur_rpa_data_rec.effective_date;
    l_person_id    := cur_rpa_data_rec.person_id;
    p_position_id  := cur_rpa_data_rec.to_position_id;
  END LOOP;

  FOR cur_asg_end_date_rec IN cur_asg_end_date LOOP
   if cur_asg_end_date_rec.system_person_type = 'EX_EMP' then
      exit;
   else
      l_date := cur_asg_end_date_rec.effective_end_date;
   end if;
  END LOOP;
   p_asg_end_date := l_date;

END get_rpa_info;

-- JH Bug 2983738 Position Hiring Status Changes.
Procedure to_posn_not_active(p_position_id         in number
                            ,p_effective_date      in date
                            ,p_hiring_status       OUT NOCOPY varchar
                            ,p_hiring_status_start_date OUT NOCOPY date)
IS

CURSOR c_posn IS
 select pst.shared_type_name, apf.effective_start_date
 from   HR_ALL_POSITIONS_F apf, PER_SHARED_TYPES pst
 where  apf.position_id = p_position_id
 and    apf.availability_status_id <> 1
 and    apf.effective_end_date >= p_effective_date
 and    pst.lookup_type = 'POSITION_AVAILABILITY_STATUS'
 and    pst.shared_type_id = apf.availability_status_id;

/*
select shared_type_name, shared_type_id
from per_shared_types
where lookup_type = 'POSITION_AVAILABILITY_STATUS'
*/

BEGIN

 FOR c_posn_rec IN c_posn LOOP
   p_hiring_status := c_posn_rec.shared_type_name;
   p_hiring_status_start_date := c_posn_rec.effective_start_date;
 END LOOP;

END to_posn_not_active;

--
END ghr_upd_hr_validation;

/
