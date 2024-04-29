--------------------------------------------------------
--  DDL for Package Body PER_CN_SHARED_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_SHARED_INFO" AS
/*REM $Header: pecnshin.pkb 120.0.12010000.5 2010/05/26 17:02:17 dduvvuri noship $ */

FUNCTION get_lookup_meaning(p_code IN VARCHAR2, p_type IN VARCHAR2)
 RETURN VARCHAR2
 IS

  CURSOR get_meaning IS
  select meaning from fnd_lookup_values
  where lookup_type = p_type
  and enabled_flag = 'Y'
  and lookup_code = p_code
  and language = userenv('lang')
  order by lookup_code;

l_meaning fnd_lookup_values.meaning%type;

 BEGIN

  OPEN get_meaning;
  FETCH get_meaning INTO l_meaning;
  CLOSE get_meaning;

  IF p_type IN ('CN_MINISTRY_LABELS','CN_SOE_LABELS') THEN
    l_meaning := REPLACE(l_meaning,' ','_');
  END IF;

  return l_meaning;

 END get_lookup_meaning ;

Function cn_get_doc_details
(p_person_id IN NUMBER,
 p_date IN DATE,
 p_type IN VARCHAR2
)
RETURN VARCHAR2
IS
 /* define all cursors and variables */
 l_val VARCHAR2(1);
 l_cin varchar2(100);
 l_hk NUMBER;
 l_tw NUMBER;
 l_passport VARCHAR2(100);
 l_doc_type VARCHAR2(100);
 l_doc_num  VARCHAR2(100);

 CURSOR c_check_person(p_person_id IN NUMBER,p_date IN DATE) IS
 SELECT '1'
 FROM PER_ALL_PEOPLE_F
 WHERE PERSON_ID = p_person_id
 AND p_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

 CURSOR c_get_cit_ident_no(p_person_id IN NUMBER,p_date IN DATE) IS
 SELECT NATIONAL_IDENTIFIER
 FROM PER_ALL_PEOPLE_F
 WHERE PERSON_ID = p_person_id
 AND p_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

 CURSOR c_get_pass_no(p_person_id IN NUMBER) IS
 SELECT PEI_INFORMATION1 A, PEI_INFORMATION2 B
 FROM PER_PEOPLE_EXTRA_INFO
 WHERE PERSON_ID = p_person_id
 AND INFORMATION_TYPE = 'PER_PASS_INFO_CN'
 AND PEI_INFORMATION_CATEGORY = 'PER_PASS_INFO_CN'
 ORDER BY A;

 CURSOR c_get_passport_no(p_person_id IN NUMBER) IS
 SELECT PEI_INFORMATION2
 FROM PER_PEOPLE_EXTRA_INFO
 WHERE PERSON_ID = p_person_id
 AND INFORMATION_TYPE = 'PER_PASSPORT_INFO_CN'
 AND PEI_INFORMATION_CATEGORY = 'PER_PASSPORT_INFO_CN';

BEGIN

l_hk := 0;
l_tw := 0;

/* No need to check if the person is effective on the date provided because
   the input date is always the effective start date of the person.*/

    OPEN c_get_cit_ident_no(p_person_id , p_date);
    FETCH c_get_cit_ident_no INTO l_cin;
    /* At any point of time only 1 CIN is available to the person */
    IF l_cin IS NULL THEN
        CLOSE c_get_cit_ident_no;
        /* Search for Pass Information. There can be multiple pass information */
        /* First check for HongKong Pass Info and if not present check for Taiwanese Pass Info */
        FOR itr in c_get_pass_no(p_person_id) LOOP
           IF itr.A = 'PHM' THEN
              l_hk := 1;
              l_doc_type := get_lookup_meaning('PASS_HK_MACAO','CN_AUDIT_DATA');
              l_doc_num := itr.B;
              EXIT;
           ELSIF itr.A = 'PTR' THEN
              l_tw := 1;
              l_doc_type := get_lookup_meaning('PASS_TAIWAN','CN_AUDIT_DATA');
              l_doc_num := itr.B;
              EXIT;
           ELSE
              NULL;
           END IF;
        END LOOP;
        IF l_hk = 1 OR l_tw = 1 THEN
	     IF p_type='TYPE' then
	       RETURN l_doc_type;
	     ELSE
	       RETURN l_doc_num;
	     END IF;

        ELSE
             /* Search for Passport Information. Assume only 1 passport information is available */
             OPEN c_get_passport_no(p_person_id);
             FETCH c_get_passport_no INTO l_passport;
             IF c_get_passport_no%notfound THEN
                 CLOSE c_get_passport_no;
                 l_doc_type := NULL;
                 l_doc_num := NULL;
                 return NULL;
             ELSE
                 CLOSE c_get_passport_no;
                 l_doc_type := get_lookup_meaning('PASSPORT','CN_AUDIT_DATA');
                 l_doc_num := l_passport;
                 IF p_type='TYPE' then
	           RETURN l_doc_type;
	         ELSE
	           RETURN l_doc_num;
	         END IF;
             END IF;
        END IF;
    ELSE
        /* Citizen Identification Number found .*/
        CLOSE c_get_cit_ident_no;
        l_doc_type := get_lookup_meaning('CIN','CN_AUDIT_DATA');
        l_doc_num := l_cin;
          IF p_type='TYPE' then
	     RETURN l_doc_type;
	  ELSE
	     RETURN l_doc_num;
	  END IF;
    END IF;

RETURN NULL;
END cn_get_doc_details;

/* Function to get parent organization id */
Function get_parent_org_id
(p_organization_id IN NUMBER
)
RETURN NUMBER IS
CURSOR c_parent_org_id IS
SELECT  POSE.organization_id_parent organization_id
   FROM   per_org_structure_elements POSE
         ,per_organization_structures POS
         ,per_org_structure_versions POSV
  WHERE   POSV.org_structure_version_id = POSE.org_structure_version_id
    AND   POS.primary_structure_flag='Y'
    AND   POS.organization_structure_id = POSV.organization_structure_id
    AND   POSE.organization_id_child      = p_organization_id
    AND   EXISTS (SELECT 1
                    FROM hr_organization_information info
                   WHERE info.org_information1		= 'HR_ORG'
                     AND info.org_information_context	= 'CLASS'
                     AND info.organization_id = POSE.organization_id_parent
                     AND info.org_information2		= 'Y');
    /* Need to understand Primary_Structure_Flag importance and what if the parent is a non-HR org */
    /* Can we pass BG id from Fin Responsibility */

l_parent_org_id NUMBER;

BEGIN

  OPEN c_parent_org_id;
  FETCH c_parent_org_id INTO l_parent_org_id;
  CLOSE c_parent_org_id;

  RETURN l_parent_org_id;
END get_parent_org_id;

Function get_cadre_job_details(p_person_id IN NUMBER , p_date IN DATE)
return VARCHAR2 IS

CURSOR get_anal_cri_id
IS
   select ANALYSIS_CRITERIA_ID
   from PER_PERSON_ANALYSES
   where person_id = p_person_id
   and business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
   and p_date between date_from and nvl(date_to,to_date('31-12-4712','dd-mm-yyyy'))
   order by date_from desc;

CURSOR get_details(p_anal_cri_id IN NUMBER) IS
   select per_cn_shared_info.get_lookup_meaning(segment1,'CN_CADRE_JOB_CLASS')  from PER_ANALYSIS_CRITERIA
   where ANALYSIS_CRITERIA_ID = p_anal_cri_id
   and enabled_flag = 'Y'
   and ID_FLEX_NUM = (select ID_FLEX_NUM
                      from FND_ID_FLEX_STRUCTURES_VL
                      where ID_FLEX_CODE='PEA' and
                      ID_FLEX_STRUCTURE_CODE = 'PER_JOB_CLASS_INFO_CN'
                     );
l_cad_job_class varchar2(1000);
l_cri_id NUMBER;

BEGIN

OPEN get_anal_cri_id;
FETCH get_anal_cri_id INTO l_cri_id;
CLOSE get_anal_cri_id;

IF l_cri_id IS NOT NULL THEN
   OPEN get_details(l_cri_id);
   FETCH get_details INTO l_cad_job_class;
   CLOSE get_details;
ELSE
   return NULL;
END IF;

return l_cad_job_class;

END get_cadre_job_details;

Function get_tech_post_details(p_person_id IN NUMBER , p_date IN DATE)
return VARCHAR2 IS

CURSOR get_anal_cri_id
IS
   select ANALYSIS_CRITERIA_ID
   from PER_PERSON_ANALYSES
   where person_id = p_person_id
   and business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
   and p_date between date_from and nvl(date_to,to_date('31-12-4712','dd-mm-yyyy'))
   order by date_from desc;

CURSOR get_details(p_anal_cri_id IN NUMBER) IS
   select per_cn_shared_info.get_lookup_meaning(segment1,'CN_TECH_TITLE')  from PER_ANALYSIS_CRITERIA
   where ANALYSIS_CRITERIA_ID = p_anal_cri_id
   and enabled_flag = 'Y'
   and ID_FLEX_NUM = (select ID_FLEX_NUM
                      from FND_ID_FLEX_STRUCTURES_VL
                      where ID_FLEX_CODE='PEA' and
                      ID_FLEX_STRUCTURE_CODE = 'PER_TECH_PROF_POST_CN'
                     );

l_cri_id NUMBER;
l_tech_post_detail VARCHAR2(1000);

BEGIN

OPEN get_anal_cri_id;
FETCH get_anal_cri_id INTO l_cri_id;
CLOSE get_anal_cri_id;

IF l_cri_id IS NOT NULL THEN
    OPEN get_details(l_cri_id);
    FETCH get_details INTO l_tech_post_detail ;
    CLOSE get_details;
ELSE
    return NULL;
END IF;

return l_tech_post_detail;

END get_tech_post_details;

END per_cn_shared_info;

/
