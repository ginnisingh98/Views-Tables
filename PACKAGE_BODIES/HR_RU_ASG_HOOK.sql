--------------------------------------------------------
--  DDL for Package Body HR_RU_ASG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_ASG_HOOK" AS
/* $Header: peruexar.pkb 120.1 2006/09/20 13:33:57 mgettins noship $ */

 PROCEDURE validate_asg_upd_details(p_assignment_id     	IN   NUMBER
                               ,p_effective_date    		IN   DATE
                               ,p_datetrack_update_mode 	IN  VARCHAR2
                               ,p_assignment_status_type_id     IN   NUMBER
                               ,p_segment1          		IN  VARCHAR2
                               ,p_segment2          		IN  VARCHAR2
                               ,p_segment3          		IN  VARCHAR2
                               ,p_segment4          		IN  VARCHAR2
                               ,p_segment5          		IN  VARCHAR2
                               ,p_segment6          		IN  VARCHAR2
                               ,p_segment7          		IN  VARCHAR2
                               ,p_segment8          		IN  VARCHAR2
                               ,p_segment9          		IN  VARCHAR2
                               ,p_segment10         		IN  VARCHAR2
                               ,p_segment11         		IN  VARCHAR2
                               ,p_segment12         		IN  VARCHAR2
                               ,p_segment13         		IN  VARCHAR2
                               ,p_segment14         		IN  VARCHAR2
                               ,p_segment15         		IN  VARCHAR2
                               ) AS
 CURSOR c_min_start_date(p_assignment_id NUMBER) IS
   SELECT min(effective_start_date)
   FROM  per_all_assignments_f
   WHERE assignment_id = p_assignment_id;

  CURSOR c_asg_details(p_assignment_id NUMBER,p_effective_date DATE) IS
   SELECT person_id,effective_start_date,effective_end_date,business_group_id
   FROM per_all_assignments_f
   WHERE assignment_id = p_assignment_id
   AND p_effective_date between effective_start_date and effective_end_date;
  l_org_id NUMBER;
  l_asg_status VARCHAR2(1);
  l_cont_status VARCHAR2(1);
  l_eff_start_date DATE;
  l_eff_end_date   DATE;
  l_min_start_date DATE;
  l_person_id      NUMBER;
  l_business_group_id NUMBER;
  l_lookup_exists VARCHAR2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
  --
   OPEN c_asg_details(p_assignment_id,p_effective_date);
   FETCH c_asg_details INTO l_person_id,l_eff_start_date,l_eff_end_date,l_business_group_id;
   CLOSE c_asg_details;
   OPEN c_min_start_date(p_assignment_id);
   FETCH c_min_start_date INTO l_min_start_date;
   CLOSE c_min_start_date;
   IF p_datetrack_update_mode = 'UPDATE' THEN
     l_eff_start_date := p_effective_date;
   ELSIF p_datetrack_update_mode = 'UPDATE_CHANGE_INSERT' THEN
     l_eff_start_date := p_effective_date;
   ELSIF p_datetrack_update_mode = 'UPDATE_OVERRIDE' THEN
     l_eff_start_date := p_effective_date;
     l_eff_end_date   := hr_general.end_of_time;
   ELSE
     l_eff_start_date := l_eff_start_date;
     l_eff_end_date   := l_eff_end_date;
   END IF;
   IF p_segment1 <> hr_api.g_varchar2 THEN
     BEGIN
   	select distinct hou.organization_id
   	INTO l_org_id
   	from HR_ALL_ORGANIZATION_UNITS hou, HR_ALL_ORGANIZATION_UNITS_TL hout, HR_ORGANIZATION_INFORMATION hoi
   	where hou.organization_id   = hoi.organization_id
	AND   hou.organization_id      = hout.organization_id
	AND   hou.organization_id  = to_number(p_segment1)
	AND   hoi.org_information_context  = 'CLASS'
	AND   hoi.org_information1      = 'HR_LEGAL_EMPLOYER'
	AND   hoi.org_information2 = 'Y'
	AND   hout.language  = userenv('LANG')
	AND   p_effective_date  >= hou.date_from
	AND   p_effective_date  <=  NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','EMPLOYER'));
         hr_utility.raise_error;
     END;
   END IF;
   IF p_segment2 <> hr_api.g_varchar2 OR p_segment2 IS NULL THEN
    IF p_segment2 IS NOT NULL THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','EMP_TYPE'),
                                      p_segment2,
                                      'YES_NO',
                                      p_effective_date);
    END IF;
     IF nvl(p_segment2,'N') = 'N' THEN
       l_asg_status := hr_ru_utility.check_assign_category(l_eff_start_date
                                                          ,l_eff_end_date
                                                          ,p_assignment_id
                                                          ,l_person_id
                                                          ,l_business_group_id
                                                          );
       IF l_asg_status = 'Y' THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_EMP_TYPE');
		hr_utility.raise_error;
       END IF;
     END IF;
   END IF;
   IF p_segment3 <> hr_api.g_varchar2 THEN
      l_cont_status := hr_ru_utility.check_contract_number_unique(p_segment3
      								 ,p_assignment_id
      								 ,l_business_group_id
                                                                 );
       IF l_cont_status = 'Y' THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_CONTRACT_NUMBER');
		hr_utility.raise_error;
       END IF;
   END IF;
   IF p_segment4 <> hr_api.g_varchar2 THEN
     IF fnd_date.canonical_to_date(p_segment4) < l_min_start_date THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_ISSUE_DATE');
		hr_utility.raise_error;
     END IF;
   END IF;
   IF p_segment5 <> hr_api.g_varchar2 THEN
     IF fnd_date.canonical_to_date(p_segment5) < l_min_start_date THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_END_DATE');
		hr_utility.raise_error;
     END IF;
   END IF;
   IF p_segment6 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','CONT_LIMIT_REASON'),
                                      p_segment6,
                                      'RU_LIMITED_CONTRACT_REASON',
                                      p_effective_date);
   END IF;
  IF p_assignment_status_type_id <> hr_api.g_number THEN
   IF (p_assignment_status_type_id = 3 OR p_assignment_status_type_id = 8) AND
       p_segment7 IS NULL THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','TERM_REASON'));
         hr_utility.raise_error;
   END IF;
  END IF;
   IF p_segment7 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','END_REASON'),
                                      p_segment7,
                                      'LEAV_REAS',
                                      p_effective_date);
   END IF;
    IF p_segment8 <> hr_api.g_varchar2 THEN
   BEGIN
   	SELECT '1' INTO l_lookup_exists FROM hr_lookups WHERE lookup_type='RU_SPECIAL_WORK_CONDITIONS'
	AND lookup_code=p_segment8 AND enabled_flag='Y';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','SPECIAL_WORK_CONDITIONS'));
         hr_utility.raise_error;
     END;
   END IF;
   IF p_segment12 <> hr_api.g_varchar2 THEN
   BEGIN
   	SELECT '1' INTO l_lookup_exists FROM hr_lookups WHERE lookup_type='RU_LONG_SERVICE'
	AND lookup_code=p_segment12 AND enabled_flag='Y';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','LONG_SERVICE_REASON'));
         hr_utility.raise_error;
     END;
   END IF;
   IF p_segment9 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','TERRITORY_CONDITIONS'),
                                      p_segment9,
                                      'RU_TERRITORY_CONDITIONS',
                                      p_effective_date);
   END IF;
   IF p_segment10 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','RECORD_SERVICE_REASON'),
                                      p_segment10,
                                      'RU_CALC_RECORD_SERVICE',
                                      p_effective_date);
   END IF;
   IF p_segment14 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','UNINTERRUPTED_SERVICE_RECORD'),
                                      p_segment14,
                                      'YES_NO',
                                      p_effective_date);
   END IF;
   IF p_segment15 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','TOTAL_SERVICE_RECORD'),
                                      p_segment15,
                                      'YES_NO',
                                      p_effective_date);
   END IF;
  END IF;
 END validate_asg_upd_details;

 PROCEDURE validate_asg_create_details(p_person_id     	IN   NUMBER
                               ,p_effective_date    		IN   DATE
                               ,p_assignment_status_type_id     IN   NUMBER
                               ,p_scl_segment1          	IN  VARCHAR2
                               ,p_scl_segment2          	IN  VARCHAR2
                               ,p_scl_segment3          	IN  VARCHAR2
                               ,p_scl_segment4          	IN  VARCHAR2
                               ,p_scl_segment5          	IN  VARCHAR2
                               ,p_scl_segment6          	IN  VARCHAR2
                               ,p_scl_segment7          	IN  VARCHAR2
                               ,p_scl_segment8          	IN  VARCHAR2
                               ,p_scl_segment9          	IN  VARCHAR2
                               ,p_scl_segment10         	IN  VARCHAR2
                               ,p_scl_segment11         	IN  VARCHAR2
                               ,p_scl_segment12         	IN  VARCHAR2
                               ,p_scl_segment13         	IN  VARCHAR2
                               ,p_scl_segment14         	IN  VARCHAR2
                               ,p_scl_segment15         	IN  VARCHAR2
                               ) AS
  CURSOR c_person_details(p_person_id NUMBER,p_effective_date DATE) IS
   SELECT business_group_id
   FROM per_all_people_f
   WHERE person_id = p_person_id
   AND p_effective_date between effective_start_date and effective_end_date;
  l_org_id NUMBER;
  l_asg_status VARCHAR2(1);
  l_cont_status VARCHAR2(1);
  l_eff_start_date DATE;
  l_eff_end_date   DATE;
  l_person_id      NUMBER;
  l_business_group_id NUMBER;
  l_lookup_exists VARCHAR2(1);
BEGIN
 --
 -- Added for GSI Bug 5472781
 --
 IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
  --
  l_eff_start_date := p_effective_date;
  l_eff_end_date   := hr_general.end_of_time;
   OPEN c_person_details(p_person_id,p_effective_date);
   FETCH c_person_details INTO l_business_group_id;
   CLOSE c_person_details;
   IF p_scl_segment1 IS NOT NULL THEN
     BEGIN
   	select distinct hou.organization_id
   	INTO l_org_id
   	from HR_ALL_ORGANIZATION_UNITS hou, HR_ALL_ORGANIZATION_UNITS_TL hout, HR_ORGANIZATION_INFORMATION hoi
   	where hou.organization_id   = hoi.organization_id
	AND   hou.organization_id      = hout.organization_id
	AND   hou.organization_id  = to_number(p_scl_segment1)
	AND   hoi.org_information_context  = 'CLASS'
	AND   hoi.org_information1      = 'HR_LEGAL_EMPLOYER'
	AND   hoi.org_information2 = 'Y'
	AND   hout.language  = userenv('LANG')
	AND   p_effective_date  >= hou.date_from
	AND   p_effective_date  <=  NVL(hou.date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','EMPLOYER'));
         hr_utility.raise_error;
     END;
   END IF;
    IF p_scl_segment2 IS NOT NULL THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','EMP_TYPE'),
                                      p_scl_segment2,
                                      'YES_NO',
                                      p_effective_date);
    END IF;
     IF nvl(p_scl_segment2,'N') = 'N' THEN
       l_asg_status := hr_ru_utility.check_assign_category(l_eff_start_date
                                                          ,l_eff_end_date
                                                          ,NULL
                                                          ,p_person_id
                                                          ,l_business_group_id
                                                          );
       IF l_asg_status = 'Y' THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_EMP_TYPE');
		hr_utility.raise_error;
       END IF;
     END IF;
   IF p_scl_segment3 IS NOT NULL THEN
      l_cont_status := hr_ru_utility.check_contract_number_unique(p_scl_segment3
      								 ,NULL
      								 ,l_business_group_id
                                                                 );
       IF l_cont_status = 'Y' THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_CONTRACT_NUMBER');
		hr_utility.raise_error;
       END IF;
   END IF;
   IF p_scl_segment4 IS NOT NULL THEN
     IF fnd_date.canonical_to_date(p_scl_segment4) < p_effective_date THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_ISSUE_DATE');
		hr_utility.raise_error;
     END IF;
   END IF;
   IF p_scl_segment5 IS NOT NULL THEN
     IF fnd_date.canonical_to_date(p_scl_segment5) < p_effective_date THEN
		hr_utility.set_message(800, 'HR_RU_INVALID_END_DATE');
		hr_utility.raise_error;
     END IF;
   END IF;
   IF p_scl_segment6 IS NOT NULL THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','CONT_LIMIT_REASON'),
                                      p_scl_segment6,
                                      'RU_LIMITED_CONTRACT_REASON',
                                      p_effective_date);
   END IF;
   IF (p_assignment_status_type_id = 3 OR p_assignment_status_type_id = 8) AND
       p_scl_segment7 IS NULL THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','TERM_REASON'));
         hr_utility.raise_error;
   END IF;
   IF p_scl_segment7 IS NOT NULL THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','END_REASON'),
                                      p_scl_segment7,
                                      'LEAV_REAS',
                                      p_effective_date);
   END IF;
   IF p_scl_segment8 <> hr_api.g_varchar2 THEN
   BEGIN
   	SELECT '1' INTO l_lookup_exists FROM hr_lookups WHERE lookup_type='RU_SPECIAL_WORK_CONDITIONS'
	AND lookup_code=p_scl_segment8 AND enabled_flag='Y';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','SPECIAL_WORK_CONDITIONS'));
         hr_utility.raise_error;
     END;
   END IF;
   IF p_scl_segment12 <> hr_api.g_varchar2 THEN
   BEGIN
   	SELECT '1' INTO l_lookup_exists FROM hr_lookups WHERE lookup_type='RU_LONG_SERVICE'
	AND lookup_code=p_scl_segment12 AND enabled_flag='Y';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', hr_general.decode_lookup('RU_FORM_LABELS','LONG_SERVICE_REASON'));
         hr_utility.raise_error;
     END;
   END IF;
   IF p_scl_segment9 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','TERRITORY_CONDITIONS'),
                                      p_scl_segment9,
                                      'RU_TERRITORY_CONDITIONS',
                                      p_effective_date);
   END IF;
   IF p_scl_segment10 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','RECORD_SERVICE_REASON'),
                                      p_scl_segment10,
                                      'RU_CALC_RECORD_SERVICE',
                                      p_effective_date);
   END IF;
   IF p_scl_segment14 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','UNINTERRUPTED_SERVICE_RECORD'),
                                      p_scl_segment14,
                                      'YES_NO',
                                      p_effective_date);
   END IF;
   IF p_scl_segment15 <> hr_api.g_varchar2 THEN
     hr_ru_utility.check_lookup_value(hr_general.decode_lookup('RU_FORM_LABELS','TOTAL_SERVICE_RECORD'),
                                      p_scl_segment15,
                                      'YES_NO',
                                      p_effective_date);
   END IF;
  END IF;
 END validate_asg_create_details;
END hr_ru_asg_hook;

/
