--------------------------------------------------------
--  DDL for Package Body GHR_GEN_RPA_NPA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_GEN_RPA_NPA" AS
/* $Header: ghgenpa.pkb 120.1.12010000.10 2009/08/31 06:15:12 managarw ship $ */
-- Package scope variables for RPA
l_rpa_misc_fields t_rpa_misc_fields_rec;
l_rpa_report_tags t_report_tags_rec;

-- Package scope variables for NPA
l_npa_report_tags t_report_tags_rec;
l_npa_misc_fields t_npa_misc_fields_rec;

l_remarks t_remarks_rec;
l_new_line_sep VARCHAR2(10);

PROCEDURE Generate_RPA(p_pa_request_id  ghr_pa_requests.pa_request_id%type,  p_view_type VARCHAR2, p_xml_string OUT NOCOPY CLOB) IS
	CURSOR cur_RPA(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT
	FAM.NAME ACTION_REQUESTED
	,PA_REQUEST_ID
	,REQUEST_NUMBER
	,ADDITIONAL_INFO_TEL_NUMBER
	,DECODE(PROPOSED_EFFECTIVE_ASAP_FLAG,'Y','ASAP',TO_CHAR(PROPOSED_EFFECTIVE_DATE,'MM-DD-YYYY')) PROPOSED_EFFECTIVE_DATE
	,REQUESTED_BY_TITLE ACTION_REQUESTED_BY_TITLE
	,REQUESTED_DATE ACTION_REQUESTED_DATE
	,AUTHORIZED_BY_TITLE
	,CONCURRENCE_DATE
	,EMPLOYEE_LAST_NAME E_LAST_NAME
	,EMPLOYEE_FIRST_NAME
	,NVL(EMPLOYEE_MIDDLE_NAMES, '')  EMPLOYEE_MIDDLE_NAME
	,EMPLOYEE_NATIONAL_IDENTIFIER SS_NUMBER
	,EMPLOYEE_DATE_OF_BIRTH
	,NVL(GHR_UPD_HR_VALIDATION.GET_EXEMP_AWARD_DATE(PA_REQUEST_ID),EFFECTIVE_DATE) EFFECTIVE_DATE
	,DECODE(LENGTH(NVL(FIRST_NOA_CODE, '')), 4, SUBSTR(FIRST_NOA_CODE, 2, 3), FIRST_NOA_CODE) FIRST_NOA_CODE
	,GHR_PA_REQUESTS.NOA_FAMILY_CODE
	,FIRST_NOA_DESC
	,FIRST_ACTION_LA_CODE1
	,FIRST_ACTION_LA_CODE2
	,FIRST_ACTION_LA_DESC1
	,FIRST_ACTION_LA_DESC2
	,FROM_POSITION_ID
	,FROM_POSITION_TITLE
	,FROM_POSITION_NUMBER || DECODE(FROM_POSITION_NUMBER, NULL, NULL, ' - ')|| TO_CHAR(FROM_POSITION_SEQ_NO) FROM_POSITION_NUMBER
	,FROM_PAY_PLAN
	,FROM_OCC_CODE
	,FROM_GRADE_OR_LEVEL
	,FROM_STEP_OR_RATE
	,FROM_TOTAL_SALARY
	,FROM_PAY_BASIS
	,FROM_BASIC_PAY
	,FROM_LOCALITY_ADJ
	,FROM_ADJ_BASIC_PAY
	,FROM_OTHER_PAY_AMOUNT
	,FROM_POSITION_ORG_LINE1
	,FROM_POSITION_ORG_LINE2
	,FROM_POSITION_ORG_LINE3
	,FROM_POSITION_ORG_LINE4
	,FROM_POSITION_ORG_LINE5
	,FROM_POSITION_ORG_LINE6
	,SECOND_ACTION_LA_CODE1
	,SECOND_ACTION_LA_CODE2
	,SECOND_ACTION_LA_DESC1
	,SECOND_ACTION_LA_DESC2
	,SECOND_NOA_ID
	,DECODE(LENGTH(NVL(SECOND_NOA_CODE, '')), 4, SUBSTR(SECOND_NOA_CODE, 2, 3), SECOND_NOA_CODE) SECOND_NOA_CODE
	,SECOND_NOA_DESC
	,TO_POSITION_TITLE
	,TO_POSITION_NUMBER || DECODE(TO_POSITION_NUMBER, NULL, NULL, ' - ')|| TO_CHAR(TO_POSITION_SEQ_NO) TO_POSITION_NUMBER
	,TO_PAY_PLAN
	,TO_OCC_CODE
	,TO_GRADE_OR_LEVEL
	,TO_STEP_OR_RATE
	,TO_TOTAL_SALARY
	,TO_AVAILABILITY_PAY
	,TO_AUO_PREMIUM_PAY_INDICATOR
	,TO_AU_OVERTIME
	,AWARD_AMOUNT
	,AWARD_UOM
	,TO_PAY_BASIS
	,TO_BASIC_PAY
	,TO_LOCALITY_ADJ
	,TO_ADJ_BASIC_PAY
	,TO_OTHER_PAY_AMOUNT
	,TO_POSITION_ORG_LINE1
	,TO_POSITION_ORG_LINE2
	,TO_POSITION_ORG_LINE3
	,TO_POSITION_ORG_LINE4
	,TO_POSITION_ORG_LINE5
	,TO_POSITION_ORG_LINE6
	,TO_POSITION_ID
	,VETERANS_PREFERENCE
	,TENURE
	--,AGENCY_USE
	,VETERANS_PREF_FOR_RIF
	,FEGLI
	,ANNUITANT_INDICATOR
	,PAY_RATE_DETERMINANT
	,RETIREMENT_PLAN
	,SERVICE_COMP_DATE
	,WORK_SCHEDULE
	,PART_TIME_HOURS
	,POSITION_OCCUPIED
	,FLSA_CATEGORY
	,APPROPRIATION_CODE1 || ' | ' || APPROPRIATION_CODE2 APPROPRIATION_CODE
	,BARGAINING_UNIT_STATUS
	,DUTY_STATION_ID
	,DUTY_STATION_CODE
	,DUTY_STATION_DESC
	,EDUCATION_LEVEL
	,YEAR_DEGREE_ATTAINED
	,ACADEMIC_DISCIPLINE
	,FUNCTIONAL_CLASS
	,CITIZENSHIP
	,VETERANS_STATUS
	,SUPERVISORY_STATUS
	,REQUESTING_OFFICE_REMARKS_FLAG REQUESTING_OFFICE_REMARKS_FLAG
	,REQUESTING_OFFICE_REMARKS_DESC REQUESTING_OFFICE_REMARKS_D
	,RESIGN_AND_RETIRE_REASON_DESC
	,EFFECTIVE_DATE RETIRE_EFFECTIVE_DATE
	,FORWARDING_ADDRESS_LINE1 || ' '
	|| FORWARDING_ADDRESS_LINE2 || ' '
	|| FORWARDING_ADDRESS_LINE3 FORWARDING_ADDRESS1
	,FORWARDING_TOWN_OR_CITY || ' ' ||  FORWARDING_REGION_2 || '  ' ||  FORWARDING_POSTAL_CODE  FORWARDING_CITY
	,NULL A
	,PERSON_ID
	,EMPLOYEE_ASSIGNMENT_ID
	,ADDITIONAL_INFO_PERSON_ID
	,REQUESTED_BY_PERSON_ID
	,AUTHORIZED_BY_PERSON_ID
	,APPROVING_OFFICIAL_FULL_NAME
	,APPROVING_OFFICIAL_WORK_TITLE
	,APPROVAL_DATE
	,NOTEPAD
	,ALTERED_PA_REQUEST_ID
	FROM GHR_PA_REQUESTS, GHR_FAMILIES FAM
	WHERE
	PA_REQUEST_ID = c_pa_request_id
	AND GHR_PA_REQUESTS.NOA_FAMILY_CODE = FAM.NOA_FAMILY_CODE;

	CURSOR c_remarks(c_pa_request_id GHR_PA_REMARKS.pa_request_id%type) IS
	SELECT
     pre.description,
     pre.pa_request_id,
     remk.code remark_code
	FROM
     ghr_pa_remarks pre,
     ghr_remarks remk
     WHERE  remk.remark_id = pre.remark_id
	 AND pre.pa_request_id = c_pa_request_id;

	CURSOR c_person_name(p_person_id NUMBER, p_effective_date DATE) IS
	   SELECT per1.first_name||' '|| DECODE(per1.middle_names,NULL,'NMN',SUBSTR(per1.middle_names,1,1)||'. ') || per1.last_name person_name
	   from per_all_people_f per1
	   where per1.person_id = p_person_id
	   and    NVL(p_effective_date,TRUNC(sysdate))  between per1.effective_start_date and per1.effective_end_date;

	CURSOR c_agency_use(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information3
	,rei_information4
	,rei_information5
	,rei_information6
	,rei_information7
	,rei_information8
	FROM ghr_pa_request_extra_info
	WHERE information_type = 'GHR_US_PAR_GEN_AGENCY_DATA'
	AND  pa_request_id = c_pa_request_id;

   CURSOR C_CNT_SIGS (p_pa_request_id NUMBER, p_effective_date DATE) IS
   SELECT COUNT(*)  cnt
   FROM GHR_PA_ROUTING_HISTORY PRH,
        PER_PEOPLE_F PER,
        PER_ASSIGNMENTS_F ASG,
        PER_POSITION_EXTRA_INFO PG1
   WHERE PRH.pa_request_id = p_pa_request_id
     AND (PRH.personnelist_flag = 'Y' OR PRH.approver_flag = 'Y')
     AND PRH.user_name_employee_id = PER.person_id
     AND PRH.LAST_UPDATE_DATE = (SELECT MAX(P.last_update_date)
                                 FROM GHR_PA_ROUTING_HISTORY P
                                 WHERE P.pa_request_id = PRH.pa_request_id
                                   AND (P.personnelist_flag = 'Y' OR P.approver_flag = 'Y')
                                   AND P.user_name_employee_id = PRH.user_name_employee_id)
     AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN PER.effective_start_date AND PER.effective_end_date
     AND PER.person_id = ASG.person_id (+)
     AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN ASG.effective_start_date AND ASG.effective_end_date
     AND ASG.primary_flag (+) = 'Y'
     AND ASG.position_id = PG1.position_id (+)
     AND PG1.information_type (+) = 'GHR_US_POS_GRP1';


	 CURSOR C_SIGNATURES (p_pa_request_id ghr_pa_requests.pa_request_id%type, p_effective_date DATE) IS
	   SELECT PG1.POEI_INFORMATION4 Office_Symbol,
			  PER.LAST_NAME || ', ' || PER.FIRST_NAME || ' ' || PER.MIDDLE_NAMES  FULL_NAME,
			  TO_CHAR(PRH.LAST_UPDATE_DATE, 'MM-DD-YYYY') LAST_UPDATE_DATE
	   FROM GHR_PA_ROUTING_HISTORY PRH,
			PER_PEOPLE_F PER,
			PER_ASSIGNMENTS_F ASG,
			PER_POSITION_EXTRA_INFO PG1
	   WHERE PRH.pa_request_id = p_pa_request_id
		 AND (PRH.personnelist_flag = 'Y' OR PRH.approver_flag = 'Y')
		 AND PRH.user_name_employee_id = PER.person_id
		 AND PRH.LAST_UPDATE_DATE = (SELECT MAX(P.last_update_date)
									 FROM GHR_PA_ROUTING_HISTORY P
									 WHERE P.pa_request_id = PRH.pa_request_id
									   AND (P.personnelist_flag = 'Y' OR P.approver_flag = 'Y')
									   AND P.user_name_employee_id = PRH.user_name_employee_id)
		 AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN PER.effective_start_date AND PER.effective_end_date
		 AND PER.person_id = ASG.person_id (+)
		 AND NVL(p_effective_date, TRUNC(sysdate)) BETWEEN ASG.effective_start_date AND ASG.effective_end_date
		 AND ASG.primary_flag (+) = 'Y'
		 AND ASG.position_id = PG1.position_id (+)
		 AND PG1.information_type (+) = 'GHR_US_POS_GRP1'
	   ORDER BY PRH.LAST_UPDATE_DATE DESC;

	l_pa_request_rec ghr_pa_requests%rowtype;
	l_pa_request_rec_out ghr_pa_requests%rowtype;
	l_cnt_sigs NUMBER;
	l_signature_rec t_signature_rec;
	l_rem_ctr NUMBER;
BEGIN
	l_new_line_sep := '
	';
	-- Bug 4249583
	l_rpa_misc_fields.DELETE;
	l_rpa_report_tags.DELETE;
	-- End Bug 4249583
	-- Get RPA values
	FOR l_RPA IN cur_RPA(p_pa_request_id) LOOP
			l_pa_request_rec.pa_request_id := 	l_RPA.pa_request_id;
			l_pa_request_rec.request_number := 	l_RPA.request_number;
			l_pa_request_rec.additional_info_tel_number := l_RPA.additional_info_tel_number;
			l_pa_request_rec.proposed_effective_date := l_RPA.proposed_effective_date;
			l_pa_request_rec.requested_by_title := l_RPA.action_requested_by_title;
			l_pa_request_rec.requested_date := l_RPA.action_requested_date;
			l_pa_request_rec.authorized_by_title := l_RPA.authorized_by_title;
			l_pa_request_rec.concurrence_date := l_RPA.concurrence_date;
			l_pa_request_rec.employee_last_name := l_RPA.e_last_name;
			l_pa_request_rec.employee_first_name := l_RPA.employee_first_name;
			l_pa_request_rec.employee_middle_names := l_RPA.employee_middle_name;
			l_pa_request_rec.employee_national_identifier := l_RPA.ss_number;
			l_pa_request_rec.employee_date_of_birth := l_RPA.employee_date_of_birth;
			l_pa_request_rec.effective_date := l_RPA.effective_date;
			l_pa_request_rec.first_noa_code := l_RPA.first_noa_code;
			l_pa_request_rec.noa_family_code := l_RPA.noa_family_code;
			l_pa_request_rec.first_noa_desc := l_RPA.first_noa_desc;
			l_pa_request_rec.first_action_la_code1 := l_RPA.first_action_la_code1;
			l_pa_request_rec.first_action_la_code2 := l_RPA.first_action_la_code2;
			l_pa_request_rec.first_action_la_desc1 := l_RPA.first_action_la_desc1;
			l_pa_request_rec.first_action_la_desc2 := l_RPA.first_action_la_desc2;
			l_pa_request_rec.from_position_id := l_RPA.from_position_id;
			l_pa_request_rec.from_position_title := l_RPA.from_position_title;
			l_pa_request_rec.from_position_number := l_RPA.from_position_number;
			l_pa_request_rec.from_pay_plan := l_RPA.from_pay_plan;
			l_pa_request_rec.from_occ_code := l_RPA.from_occ_code;
			l_pa_request_rec.FROM_GRADE_OR_LEVEL := l_RPA.FROM_GRADE_OR_LEVEL;
			l_pa_request_rec.FROM_STEP_OR_RATE := l_RPA.FROM_STEP_OR_RATE;
			l_pa_request_rec.FROM_TOTAL_SALARY := l_RPA.FROM_TOTAL_SALARY;
			l_pa_request_rec.FROM_PAY_BASIS := l_RPA.FROM_PAY_BASIS;
			l_pa_request_rec.FROM_BASIC_PAY := l_RPA.FROM_BASIC_PAY;
			l_pa_request_rec.FROM_LOCALITY_ADJ := l_RPA.FROM_LOCALITY_ADJ;
			l_pa_request_rec.FROM_ADJ_BASIC_PAY := l_RPA.FROM_ADJ_BASIC_PAY;
			l_pa_request_rec.FROM_OTHER_PAY_AMOUNT := l_RPA.FROM_OTHER_PAY_AMOUNT;
			l_pa_request_rec.FROM_POSITION_ORG_LINE1 := l_RPA.FROM_POSITION_ORG_LINE1;
			l_pa_request_rec.FROM_POSITION_ORG_LINE2 := l_RPA.FROM_POSITION_ORG_LINE2;
			l_pa_request_rec.FROM_POSITION_ORG_LINE3 := l_RPA.FROM_POSITION_ORG_LINE3;
			l_pa_request_rec.FROM_POSITION_ORG_LINE4 := l_RPA.FROM_POSITION_ORG_LINE4;
			l_pa_request_rec.FROM_POSITION_ORG_LINE5 := l_RPA.FROM_POSITION_ORG_LINE5;
			l_pa_request_rec.FROM_POSITION_ORG_LINE6 := l_RPA.FROM_POSITION_ORG_LINE6;
			l_pa_request_rec.SECOND_ACTION_LA_CODE1 := l_RPA.SECOND_ACTION_LA_CODE1;
			l_pa_request_rec.SECOND_ACTION_LA_CODE2 := l_RPA.SECOND_ACTION_LA_CODE2;
			l_pa_request_rec.SECOND_ACTION_LA_DESC1 := l_RPA.SECOND_ACTION_LA_DESC1;
			l_pa_request_rec.SECOND_ACTION_LA_DESC2 := l_RPA.SECOND_ACTION_LA_DESC2;
			l_pa_request_rec.SECOND_NOA_ID := l_RPA.SECOND_NOA_ID;
			l_pa_request_rec.SECOND_NOA_CODE := l_RPA.SECOND_NOA_CODE;
			l_pa_request_rec.SECOND_NOA_DESC := l_RPA.SECOND_NOA_DESC;
			l_pa_request_rec.TO_POSITION_TITLE := l_RPA.TO_POSITION_TITLE;
			l_pa_request_rec.TO_POSITION_NUMBER := l_RPA.TO_POSITION_NUMBER;
			l_pa_request_rec.TO_PAY_PLAN := l_RPA.TO_PAY_PLAN;
			l_pa_request_rec.TO_OCC_CODE := l_RPA.TO_OCC_CODE;
			l_pa_request_rec.TO_GRADE_OR_LEVEL := l_RPA.TO_GRADE_OR_LEVEL;
			l_pa_request_rec.TO_STEP_OR_RATE := l_RPA.TO_STEP_OR_RATE;
			l_pa_request_rec.TO_TOTAL_SALARY := l_RPA.TO_TOTAL_SALARY;
			l_pa_request_rec.TO_AVAILABILITY_PAY := l_RPA.TO_AVAILABILITY_PAY;
			l_pa_request_rec.TO_AUO_PREMIUM_PAY_INDICATOR := l_RPA.TO_AUO_PREMIUM_PAY_INDICATOR;
			l_pa_request_rec.TO_AU_OVERTIME := l_RPA.TO_AU_OVERTIME;
			l_pa_request_rec.AWARD_AMOUNT := l_RPA.AWARD_AMOUNT;
			l_pa_request_rec.AWARD_UOM := l_RPA.AWARD_UOM;
			l_pa_request_rec.TO_PAY_BASIS := l_RPA.TO_PAY_BASIS;
			l_pa_request_rec.TO_BASIC_PAY := l_RPA.TO_BASIC_PAY;
			l_pa_request_rec.TO_LOCALITY_ADJ := l_RPA.TO_LOCALITY_ADJ;
			l_pa_request_rec.TO_ADJ_BASIC_PAY := l_RPA.TO_ADJ_BASIC_PAY;
			l_pa_request_rec.TO_OTHER_PAY_AMOUNT := l_RPA.TO_OTHER_PAY_AMOUNT;
			l_pa_request_rec.TO_POSITION_ORG_LINE1 := l_RPA.TO_POSITION_ORG_LINE1;
			l_pa_request_rec.TO_POSITION_ORG_LINE2 := l_RPA.TO_POSITION_ORG_LINE2;
			l_pa_request_rec.TO_POSITION_ORG_LINE3 := l_RPA.TO_POSITION_ORG_LINE3;
			l_pa_request_rec.TO_POSITION_ORG_LINE4 := l_RPA.TO_POSITION_ORG_LINE4;
			l_pa_request_rec.TO_POSITION_ORG_LINE5 := l_RPA.TO_POSITION_ORG_LINE5;
			l_pa_request_rec.TO_POSITION_ORG_LINE6 := l_RPA.TO_POSITION_ORG_LINE6;
			l_pa_request_rec.TO_POSITION_ID := l_RPA.TO_POSITION_ID;
			l_pa_request_rec.VETERANS_PREFERENCE := l_RPA.VETERANS_PREFERENCE;
			l_pa_request_rec.TENURE := l_RPA.TENURE;
			l_pa_request_rec.VETERANS_PREF_FOR_RIF := l_RPA.VETERANS_PREF_FOR_RIF;
			l_pa_request_rec.FEGLI := l_RPA.FEGLI;
			l_pa_request_rec.ANNUITANT_INDICATOR := l_RPA.ANNUITANT_INDICATOR;
			l_pa_request_rec.PAY_RATE_DETERMINANT := l_RPA.PAY_RATE_DETERMINANT;
			l_pa_request_rec.RETIREMENT_PLAN := l_RPA.RETIREMENT_PLAN;
			l_pa_request_rec.SERVICE_COMP_DATE := l_RPA.SERVICE_COMP_DATE;
			l_pa_request_rec.WORK_SCHEDULE := l_RPA.WORK_SCHEDULE;
			l_pa_request_rec.PART_TIME_HOURS := l_RPA.PART_TIME_HOURS;
			l_pa_request_rec.POSITION_OCCUPIED := l_RPA.POSITION_OCCUPIED;
			l_pa_request_rec.FLSA_CATEGORY := l_RPA.FLSA_CATEGORY;
--			l_pa_request_rec.APPROPRIATION_CODE := l_RPA.APPROPRIATION_CODE;
			l_pa_request_rec.BARGAINING_UNIT_STATUS := l_RPA.BARGAINING_UNIT_STATUS;
			l_pa_request_rec.DUTY_STATION_ID := l_RPA.DUTY_STATION_ID;
			l_pa_request_rec.DUTY_STATION_CODE := l_RPA.DUTY_STATION_CODE;
			l_pa_request_rec.DUTY_STATION_DESC := l_RPA.DUTY_STATION_DESC;
			l_pa_request_rec.EDUCATION_LEVEL := l_RPA.EDUCATION_LEVEL;
			l_pa_request_rec.YEAR_DEGREE_ATTAINED := l_RPA.YEAR_DEGREE_ATTAINED;
			l_pa_request_rec.ACADEMIC_DISCIPLINE := l_RPA.ACADEMIC_DISCIPLINE;
			l_pa_request_rec.FUNCTIONAL_CLASS := l_RPA.FUNCTIONAL_CLASS;
			l_pa_request_rec.CITIZENSHIP := l_RPA.CITIZENSHIP;
			l_pa_request_rec.VETERANS_STATUS := l_RPA.VETERANS_STATUS;
			l_pa_request_rec.SUPERVISORY_STATUS := l_RPA.SUPERVISORY_STATUS;
			l_pa_request_rec.REQUESTING_OFFICE_REMARKS_DESC := l_RPA.REQUESTING_OFFICE_REMARKS_D;
--			l_pa_request_rec.REQUESTING_OFFICE_REMARKS_FLAG := l_RPA.REQUESTING_OFFICE_REMARKS_FLAG;
			l_pa_request_rec.RESIGN_AND_RETIRE_REASON_DESC := l_RPA.RESIGN_AND_RETIRE_REASON_DESC;
-- Retire effective date
-- FORWARDING_CITY
			l_pa_request_rec.PERSON_ID := l_RPA.PERSON_ID;
			l_pa_request_rec.EMPLOYEE_ASSIGNMENT_ID := l_RPA.EMPLOYEE_ASSIGNMENT_ID;
			l_pa_request_rec.ADDITIONAL_INFO_PERSON_ID := l_RPA.ADDITIONAL_INFO_PERSON_ID;
			l_pa_request_rec.REQUESTED_BY_PERSON_ID := l_RPA.REQUESTED_BY_PERSON_ID;
			l_pa_request_rec.AUTHORIZED_BY_PERSON_ID := l_RPA.AUTHORIZED_BY_PERSON_ID;
			l_pa_request_rec.APPROVING_OFFICIAL_FULL_NAME := l_RPA.APPROVING_OFFICIAL_FULL_NAME;
			l_pa_request_rec.APPROVING_OFFICIAL_WORK_TITLE := l_RPA.APPROVING_OFFICIAL_WORK_TITLE;
			l_pa_request_rec.APPROVAL_DATE := l_RPA.APPROVAL_DATE;
			l_pa_request_rec.NOTEPAD := l_RPA.NOTEPAD;
			l_pa_request_rec.ALTERED_PA_REQUEST_ID := l_RPA.ALTERED_PA_REQUEST_ID;

		-- If Manager is viewing, then need to hide SSN and DOB
	IF p_view_type = 'MGR' THEN
		l_pa_request_rec.EMPLOYEE_NATIONAL_IDENTIFIER := NULL;
		l_pa_request_rec.EMPLOYEE_DATE_OF_BIRTH := NULL;
	END IF;

	CondPrinting_RPA(l_pa_request_rec,l_pa_request_rec_out);

/* Start --  Bug:7610341*/
IF l_pa_request_rec_out.approval_date > l_pa_request_rec_out.effective_date and l_pa_request_rec.first_noa_code not in ('001','002') then
    l_pa_request_rec_out.approval_date := l_pa_request_rec_out.effective_date;
end if;
/* End -- Bug:7610341  */

	-- Prepare XML with l_pa_request_rec_out
	-- Bug 4257449
	IF l_pa_request_rec_out.first_noa_code = '818'  OR l_pa_request_rec_out.second_noa_code = '818' THEN
	-- End Bug 4257449
--	IF l_pa_request_rec_out.first_noa_code IN ('818' ,'819')
--		OR l_pa_request_rec_out.second_noa_code IN ('818' ,'819') THEN
		IF l_pa_request_rec_out.from_total_salary IS NOT NULL THEN
			l_rpa_misc_fields(1).from_tot_sal_or_awd := to_char(l_pa_request_rec_out.from_total_salary) || '%';
		END IF;
		IF l_pa_request_rec_out.to_total_salary IS NOT NULL THEN
			l_rpa_misc_fields(1).to_tot_sal_or_awd := to_char(l_pa_request_rec_out.to_total_salary) || '%';
		END IF;
	ELSE
		IF l_pa_request_rec_out.from_total_salary IS NOT NULL THEN
			l_rpa_misc_fields(1).from_tot_sal_or_awd := '$' || LTRIM(to_char(l_pa_request_rec_out.from_total_salary,'9G999G999D99'));
		END IF;
		IF l_pa_request_rec_out.to_total_salary IS NOT NULL THEN
/*Start : Bug 6458088 */
		 IF NVL(l_pa_request_rec_out.AWARD_UOM,'M')='M' THEN
		 /*Start: bug 7579682*/
			IF l_pa_request_rec_out.first_noa_code = '827' OR l_pa_request_rec_out.second_noa_code = '827' THEN
				l_rpa_misc_fields(1).to_tot_sal_or_awd := l_pa_request_rec_out.to_total_salary || '%';
			ELSE
				l_rpa_misc_fields(1).to_tot_sal_or_awd := '$' || LTRIM(to_char(l_pa_request_rec_out.to_total_salary,'9G999G999D99'));
			END IF;
		 /*End: bug 7579682*/
		 ELSE
		        l_rpa_misc_fields(1).to_tot_sal_or_awd := LTRIM(to_char(l_pa_request_rec_out.to_total_salary,'9G999G999')) || ' Hours';
		 END IF;
/*End : Bug 6458088 */
		END IF;
	END IF;

	l_rpa_misc_fields(1).action_requested := l_RPA.action_requested;
	l_rpa_misc_fields(1).appropriation_code := l_RPA.appropriation_code;
	l_rpa_misc_fields(1).from_position_org_lines := l_pa_request_rec_out.from_position_org_line1 || l_new_line_sep ||
													l_pa_request_rec_out.from_position_org_line2 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line3 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line4 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line5 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line6 ;

	l_rpa_misc_fields(1).to_position_org_lines :=   l_pa_request_rec_out.to_position_org_line1 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line2 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line3 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line4 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line5|| l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line6 ;

	FOR l_additional_info IN c_person_name(l_pa_request_rec_out.ADDITIONAL_INFO_PERSON_ID,l_pa_request_rec_out.effective_date) LOOP
			l_rpa_misc_fields(1).additional_info_name :=  	l_additional_info.person_name;
	END LOOP;

	FOR l_additional_info IN c_person_name(l_pa_request_rec_out.REQUESTED_BY_PERSON_ID,l_pa_request_rec_out.effective_date) LOOP
			l_rpa_misc_fields(1).requested_by :=  	l_additional_info.person_name;
	END LOOP;

	FOR l_additional_info IN c_person_name(l_pa_request_rec_out.AUTHORIZED_BY_PERSON_ID,l_pa_request_rec_out.effective_date) LOOP
			l_rpa_misc_fields(1).authorized_by :=  l_additional_info.person_name;
	END LOOP;

	IF l_pa_request_rec_out.employee_last_name IS NOT NULL
	THEN
	  l_rpa_misc_fields(1).employee_name := l_pa_request_rec_out.employee_last_name || ', ' || l_pa_request_rec_out.employee_first_name || ' ' ||NVL(l_pa_request_rec_out.employee_middle_names,'NMN');
	ELSE
	  l_rpa_misc_fields(1).employee_name := l_pa_request_rec_out.employee_first_name || ' ' || NVL(l_pa_request_rec_out.employee_middle_names,'NMN') ;
	END IF;

	FOR l_agency_use IN c_agency_use(l_pa_request_rec_out.pa_request_id) LOOP
		l_rpa_misc_fields(1).agency_code_use := l_agency_use.rei_information3;
		l_rpa_misc_fields(1).agency_data40 := l_agency_use.rei_information4;
		l_rpa_misc_fields(1).agency_data41 := l_agency_use.rei_information5;
		l_rpa_misc_fields(1).agency_data42 := l_agency_use.rei_information6;
		l_rpa_misc_fields(1).agency_data43 := l_agency_use.rei_information7;
		l_rpa_misc_fields(1).agency_data44 := l_agency_use.rei_information8;
	END LOOP;

	IF l_pa_request_rec_out.veterans_pref_for_rif = 'Y' THEN
		l_rpa_misc_fields(1).veterance_preference_for_rif_y := 'X';
	ELSIF l_pa_request_rec_out.veterans_pref_for_rif = 'N' THEN
		l_rpa_misc_fields(1).veterance_preference_for_rif_n := 'X';
	END IF;

	IF l_pa_request_rec_out.requesting_office_remarks_flag = 'Y' THEN
		l_rpa_misc_fields(1).requesting_office_rem_flag_y := 'X';
	ELSIF l_pa_request_rec_out.requesting_office_remarks_flag = 'N' THEN
		l_rpa_misc_fields(1).requesting_office_rem_flag_n := 'X';
	END IF;

	FOR l_cnt_sigs_rec IN C_CNT_SIGS(l_pa_request_rec_out.pa_request_id, l_pa_request_rec_out.effective_date) LOOP
		l_cnt_sigs := l_cnt_sigs_rec.cnt;
	END LOOP;

	IF l_cnt_sigs > 6 THEN
		l_cnt_sigs := 6;
	END IF;

	FOR r_signatures IN c_signatures(l_pa_request_rec_out.pa_request_id, l_pa_request_rec_out.effective_date) LOOP
       IF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 1 THEN
          l_signature_rec(1).office_signature     := r_signatures.full_name;
          l_signature_rec(1).office_date		:= r_signatures.last_update_date;
          l_signature_rec(1).office_function	:= r_signatures.Office_Symbol;
       ELSIF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 2 THEN
		  l_signature_rec(2).office_signature    := r_signatures.full_name;
		  l_signature_rec(2).office_date		 := r_signatures.last_update_date;
		  l_signature_rec(2).office_function	 := r_signatures.Office_Symbol;
       ELSIF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 3 THEN
		  l_signature_rec(3).office_signature    := r_signatures.full_name;
		  l_signature_rec(3).office_date		 := r_signatures.last_update_date;
		  l_signature_rec(3).office_function	 := r_signatures.Office_Symbol;
       ELSIF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 4 THEN
		  l_signature_rec(4).office_signature    := r_signatures.full_name;
		  l_signature_rec(4).office_date		 := r_signatures.last_update_date;
		  l_signature_rec(4).office_function	 := r_signatures.Office_Symbol;
       ELSIF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 5 THEN
		  l_signature_rec(5).office_signature    := r_signatures.full_name;
		  l_signature_rec(5).office_date		 := r_signatures.last_update_date;
		  l_signature_rec(5).office_function	 := r_signatures.Office_Symbol;
       ELSIF l_cnt_sigs - c_signatures%ROWCOUNT + 1 = 6 THEN
		  l_signature_rec(6).office_signature    := r_signatures.full_name;
		  l_signature_rec(6).office_date		 := r_signatures.last_update_date;
		  l_signature_rec(6).office_function	 := r_signatures.Office_Symbol;
       END IF;
       EXIT WHEN c_signatures%ROWCOUNT = 6;
    END LOOP;


	l_rpa_misc_fields(1).forwarding_city := l_RPA.forwarding_city;
	l_rpa_misc_fields(1).remarks_concat := NULL;
	l_rem_ctr := 1;
	-- Populating Remarks
	FOR l_remarks_rec IN c_remarks(l_pa_request_rec_out.pa_request_id) LOOP
		l_remarks(l_rem_ctr).remark_code := l_remarks_rec.remark_code;
		l_remarks(l_rem_ctr).remarks_desc := l_remarks_rec.description;
		l_rpa_misc_fields(1).remarks_concat := l_rpa_misc_fields(1).remarks_concat || l_remarks(l_rem_ctr).remark_code || ' : ' || l_remarks(l_rem_ctr).remarks_desc || l_new_line_sep;
		l_rem_ctr := (l_rem_ctr) + 1;
	END LOOP;

	-- Populate RPA Tags
	Populate_RPAtags(l_pa_request_rec_out,l_rpa_misc_fields,l_signature_rec);

	WritetoXML('RPA', p_xml_string);

	END LOOP;


END Generate_RPA;

PROCEDURE Populate_RPAtags(p_pa_request_rec IN ghr_pa_requests%ROWTYPE,
							p_rpa_misc_fields t_rpa_misc_fields_rec,
							p_signature_rec t_signature_rec) IS
l_ctr NUMBER;
BEGIN
l_ctr := 1;
l_rpa_report_tags.DELETE;
-- Start populating Part A

l_rpa_report_tags(l_ctr).tag_name := 'ActsReq';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).action_requested;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ReqNo';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.request_number;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'InfoName';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).additional_info_name;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'InfoPhon';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.additional_info_tel_number;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ProEfDat';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.proposed_effective_date,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ActReq';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).requested_by || l_new_line_sep || p_pa_request_rec.requested_by_title;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ActDate';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.requested_date,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthBy';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).authorized_by || l_new_line_sep || p_pa_request_rec.authorized_by_title;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthDate';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.concurrence_date,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

-- End of Part A

-- Start populating Part B
l_rpa_report_tags(l_ctr).tag_name := 'PrepName';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).employee_name;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'SSN';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.employee_national_identifier;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DOB';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.employee_date_of_birth,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'EffDate';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.effective_date,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeA';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_noa_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ActionA';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_noa_desc;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeAA';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_noa_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ActionBB';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_noa_desc;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeC';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_code1;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthD';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_desc1;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeCC';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_code1;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthDD';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_desc1;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeE';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_code2;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthF';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_desc2;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'CodeEE';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_code2;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AuthFF';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_desc2;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrPosTle';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_title;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrPosNo';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_number;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToPosTle';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_title;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToPosNo';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_number;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmPayPl';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_pay_plan;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmOcCod';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_occ_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmGrade';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_grade_or_level;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmStep';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_step_or_rate;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmSalry';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).from_tot_sal_or_awd;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FrmPyBas';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_pay_basis;
l_ctr := l_ctr + 1;

IF p_pa_request_rec.from_basic_pay IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'FrmBasPy';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_basic_pay,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.from_locality_adj IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'FrmLocAj';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_locality_adj,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.from_adj_basic_pay IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'FrmAdjPy';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_adj_basic_pay,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.from_other_pay_amount IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'FrmOthr';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_other_pay_amount,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

l_rpa_report_tags(l_ctr).tag_name := 'ToPayPl';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_pay_plan;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToOcCod';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_occ_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToGrade';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_grade_or_level;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToStep';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_step_or_rate;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToSalry';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).to_tot_sal_or_awd;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ToPyBas';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_pay_basis;
l_ctr := l_ctr + 1;

IF p_pa_request_rec.to_basic_pay IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'ToBasPy';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_basic_pay,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.to_locality_adj IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'ToLocAj';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_locality_adj,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.to_adj_basic_pay IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'ToAdjPy';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_adj_basic_pay,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

IF p_pa_request_rec.to_other_pay_amount IS NOT NULL THEN
	l_rpa_report_tags(l_ctr).tag_name := 'ToOthr';
	l_rpa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_other_pay_amount,'9G999G999D99'));
	l_ctr := l_ctr + 1;
END IF;

l_rpa_report_tags(l_ctr).tag_name := 'FromName';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).from_position_org_lines;
l_ctr := l_ctr + 1;

/*l_rpa_report_tags(l_ctr).tag_name := 'FromLoc';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_org_line6;
l_ctr := l_ctr + 1;
*/
l_rpa_report_tags(l_ctr).tag_name := 'ToName';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).to_position_org_lines;
l_ctr := l_ctr + 1;

/*l_rpa_report_tags(l_ctr).tag_name := 'ToLoc';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_org_line6;
l_ctr := l_ctr + 1;
*/
-- Populating Employee Data

l_rpa_report_tags(l_ctr).tag_name := 'VetPref';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.veterans_preference;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'Tenure';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.tenure;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AgyUsCd';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_code_use;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'VetPrefY';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).veterance_preference_for_rif_y;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'VetPrefN';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).veterance_preference_for_rif_n;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FEGLICod';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.fegli;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FEGLI';
l_rpa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_FEGLI', p_pa_request_rec.fegli);
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AnnCode';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.annuitant_indicator;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AnnIndic';
l_rpa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_ANNUITANT_INDICATOR', p_pa_request_rec.annuitant_indicator);
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'PRDCode';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.pay_rate_determinant;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'RetireCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.retirement_plan;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'RetirePl';
l_rpa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_RETIREMENT_PLAN', p_pa_request_rec.retirement_plan);
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'SrvCmDat';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.service_comp_date,'MM-DD-YYYY');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'WrkSchCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.work_schedule;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'WrkSched';
l_rpa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_WORK_SCHEDULE', p_pa_request_rec.work_schedule);
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'PTHours';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.part_time_hours);
l_ctr := l_ctr + 1;

-- Populating Position Data


l_rpa_report_tags(l_ctr).tag_name := 'PosOccCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.position_occupied;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'FLSACode';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.flsa_category;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'Approp';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).appropriation_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'BargUnit';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.bargaining_unit_status;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DyStaCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.duty_station_code;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DutyStat';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.duty_station_desc;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AgyData';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_data40;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DataA';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_data41;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DataB';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_data42;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DataC';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_data43;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DataD';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).agency_data44;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'EdLevel';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.education_level;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'DegAttan';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.year_degree_attained);
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AcdDiscp';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.academic_discipline;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'funcClas';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.functional_class;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'Citzship';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.citizenship;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'VetStaCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.veterans_status;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'SupvStCd';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.supervisory_status;
l_ctr := l_ctr + 1;


--- Populating Part C
IF p_signature_rec IS NOT NULL THEN
	IF p_signature_rec.COUNT >= 1 THEN

		l_rpa_report_tags(l_ctr).tag_name := 'OfcA';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(1).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigA';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(1).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateA';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(1).office_date;
		l_ctr := l_ctr + 1;
	END IF;

	IF p_signature_rec.COUNT >=2 THEN

		l_rpa_report_tags(l_ctr).tag_name := 'OfcB';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(2).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigB';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(2).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateB';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(2).office_date;
		l_ctr := l_ctr + 1;
	END IF;

	IF p_signature_rec.COUNT >=3 THEN

		l_rpa_report_tags(l_ctr).tag_name := 'OfcC';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(3).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigC';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(3).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateC';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(3).office_date;
		l_ctr := l_ctr + 1;
	END IF;

	IF p_signature_rec.COUNT >=4 THEN
		l_rpa_report_tags(l_ctr).tag_name := 'OfcD';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(4).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigD';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(4).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateD';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(4).office_date;
		l_ctr := l_ctr + 1;
	END IF;


	IF p_signature_rec.COUNT >=5 THEN
		l_rpa_report_tags(l_ctr).tag_name := 'OfcE';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(5).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigE';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(5).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateE';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(5).office_date;
		l_ctr := l_ctr + 1;
	END IF;


	IF p_signature_rec.COUNT = 6  THEN
		l_rpa_report_tags(l_ctr).tag_name := 'OfcF';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(6).office_function;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'SigF';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(6).office_signature;
		l_ctr := l_ctr + 1;

		l_rpa_report_tags(l_ctr).tag_name := 'DateF';
		l_rpa_report_tags(l_ctr).par_field_value := p_signature_rec(6).office_date;
		l_ctr := l_ctr + 1;
	END IF;
END IF;



l_rpa_report_tags(l_ctr).tag_name := 'AppvDate';
l_rpa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.approval_date,'DD-MON-RRRR');
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'AppOffName';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.approving_official_full_name;
l_ctr := l_ctr + 1;


-- Populating Part D
l_rpa_report_tags(l_ctr).tag_name := 'ReqOffRmkY';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).requesting_office_rem_flag_y;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'ReqOffRmkN';
l_rpa_report_tags(l_ctr).par_field_value := p_rpa_misc_fields(1).requesting_office_rem_flag_n;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'Remarks';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.requesting_office_remarks_desc;
l_ctr := l_ctr + 1;


-- Reason for Retire and rehire

l_rpa_report_tags(l_ctr).tag_name := 'Reason';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.resign_and_retire_reason_desc;
l_ctr := l_ctr + 1;

/*l_rpa_report_tags(l_ctr).tag_name := 'ResgnDat';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.resign_and_retire_reason_desc;
l_ctr := l_ctr + 1;

l_rpa_report_tags(l_ctr).tag_name := 'SignDate';
l_rpa_report_tags(l_ctr).par_field_value := p_pa_request_rec.resign_and_retire_reason_desc;
l_ctr := l_ctr + 1; */

l_rpa_report_tags(l_ctr).tag_name := 'FrwdAdd';
l_rpa_report_tags(l_ctr).par_field_value := l_rpa_misc_fields(1).forwarding_city;
l_ctr := l_ctr + 1;

-- Remarks
l_rpa_report_tags(l_ctr).tag_name := 'RemarkSF';
l_rpa_report_tags(l_ctr).par_field_value := '<![CDATA[' ||l_rpa_misc_fields(1).remarks_concat||']]>';
l_ctr := l_ctr + 1;



END Populate_RPAtags;

PROCEDURE WritetoXML(p_report_name IN VARCHAR2,
		     p_xml_string OUT NOCOPY CLOB) IS
l_xml_header VARCHAR2(400);
l_xml_string VARCHAR2(4000);
l_audit_log_dir varchar2(200);
l_file_name varchar2(50);
p_l_fp UTL_FILE.FILE_TYPE;
BEGIN
    DBMS_LOB.CREATETEMPORARY(p_xml_string,FALSE,DBMS_LOB.CALL);
    DBMS_LOB.OPEN(p_xml_string,dbms_lob.lob_readwrite);
    l_xml_string := '<?xml version="1.0" encoding="UTF-8"?>';
    DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);
	l_xml_string :=  l_new_line_sep || '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">';
	DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);
	l_xml_string := l_new_line_sep || '<fields>';
	DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);

	IF p_report_name = 'RPA' THEN
		FOR ctr_rec IN l_rpa_report_tags.FIRST .. l_rpa_report_tags.LAST LOOP
		   IF l_rpa_report_tags(ctr_rec).tag_name <> 'RemarkSF' THEN
			IF INSTR(l_rpa_report_tags(ctr_rec).par_field_value,'&') > 0 THEN
				l_rpa_report_tags(ctr_rec).par_field_value := REPLACE(l_rpa_report_tags(ctr_rec).par_field_value,'&','&amp;');
			END IF;
			IF INSTR(l_rpa_report_tags(ctr_rec).par_field_value,'>') > 0 THEN
				l_rpa_report_tags(ctr_rec).par_field_value := REPLACE(l_rpa_report_tags(ctr_rec).par_field_value,'>','&gt;');
			END IF;
			IF INSTR(l_rpa_report_tags(ctr_rec).par_field_value,'<') > 0 THEN
				l_rpa_report_tags(ctr_rec).par_field_value := REPLACE(l_rpa_report_tags(ctr_rec).par_field_value,'<','&lt;');
			END IF;
			IF INSTR(l_rpa_report_tags(ctr_rec).par_field_value,'"') > 0 THEN
				l_rpa_report_tags(ctr_rec).par_field_value := REPLACE(l_rpa_report_tags(ctr_rec).par_field_value,'"','&quot;');
			END IF;
			IF INSTR(l_rpa_report_tags(ctr_rec).par_field_value,'''') > 0 THEN
				l_rpa_report_tags(ctr_rec).par_field_value := REPLACE(l_rpa_report_tags(ctr_rec).par_field_value,'''','&#39;');
			END IF;
		   END IF;
			l_xml_string :=  '<field name="' || l_rpa_report_tags(ctr_rec).tag_name || '"><value>' || l_rpa_report_tags(ctr_rec).par_field_value || '</value></field>';
			DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);
		END LOOP;
	ELSIF p_report_name = 'NPA' THEN
		FOR ctr_rec IN l_npa_report_tags.FIRST .. l_npa_report_tags.LAST LOOP
		    IF l_npa_report_tags(ctr_rec).tag_name <> 'RemarkSF' THEN
			IF INSTR(l_npa_report_tags(ctr_rec).par_field_value,'&') > 0 THEN
				l_npa_report_tags(ctr_rec).par_field_value := REPLACE(l_npa_report_tags(ctr_rec).par_field_value,'&','&amp;');
			END IF;
			IF INSTR(l_npa_report_tags(ctr_rec).par_field_value,'>') > 0 THEN
				l_npa_report_tags(ctr_rec).par_field_value := REPLACE(l_npa_report_tags(ctr_rec).par_field_value,'>','&gt;');
			END IF;
			IF INSTR(l_npa_report_tags(ctr_rec).par_field_value,'<') > 0 THEN
				l_npa_report_tags(ctr_rec).par_field_value := REPLACE(l_npa_report_tags(ctr_rec).par_field_value,'<','&lt;');
			END IF;
			IF INSTR(l_npa_report_tags(ctr_rec).par_field_value,'"') > 0 THEN
				l_npa_report_tags(ctr_rec).par_field_value := REPLACE(l_npa_report_tags(ctr_rec).par_field_value,'"','&quot;');
			END IF;
			IF INSTR(l_npa_report_tags(ctr_rec).par_field_value,'''') > 0 THEN
				l_npa_report_tags(ctr_rec).par_field_value := REPLACE(l_npa_report_tags(ctr_rec).par_field_value,'''','&#39;');
			END IF;
		    END IF;
			l_xml_string := '<field name="' || l_npa_report_tags(ctr_rec).tag_name || '"><value>' || l_npa_report_tags(ctr_rec).par_field_value || '</value></field>';
			DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);
		END LOOP;
	END IF;
	l_xml_string := l_new_line_sep || '</fields></xfdf>';
	DBMS_LOB.WRITEAPPEND(p_xml_string, length(l_xml_string), l_xml_string);
END;

PROCEDURE CondPrinting_RPA(p_pa_request_rec_in IN ghr_pa_requests%rowtype,
                       p_pa_request_rec_out OUT NOCOPY ghr_pa_requests%rowtype)
IS
  l_tmp_auo_amount      VARCHAR2(30);
  l_tmp_availability    VARCHAR2(30);
  l_auo_amount          ghr_pa_requests.to_au_overtime%TYPE;
  l_availability_amt    ghr_pa_requests.to_availability_pay%TYPE;
  l_multi_error         BOOLEAN;
  l_auo_premium_pay_indicator ghr_pa_requests.to_auo_premium_pay_indicator%TYPE;
  l_ppi_percentage            ghr_premium_pay_indicators.ppi_percentage%TYPE;
  l_mddds_special_pay_amount ghr_pa_requests.to_total_salary%TYPE;
  l_to_avail_pay ghr_pa_requests.to_availability_pay%TYPE;
  l_to_au_overtime ghr_pa_requests.to_au_overtime%TYPE;
  l_to_organization_id per_assignments_f.organization_id%TYPE;

  CURSOR c_percentage_ppi(p_ppi_code ghr_premium_pay_indicators.code%TYPE) IS
	SELECT ppi.ppi_percentage
      FROM ghr_premium_pay_indicators ppi
     WHERE code = p_ppi_code;

  CURSOR get_mddds_amount(p_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information11 amount
	FROM   ghr_pa_request_extra_info
	WHERE  pa_request_id = p_pa_request_id
	AND    information_type='GHR_US_PAR_MD_DDS_PAY';
BEGIN
	p_pa_request_rec_out := p_pa_request_rec_in;

	-- From Side Conditions
	IF p_pa_request_rec_in.first_noa_code IN ('350','355') OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code IN ('350','355')) THEN
		p_pa_request_rec_out.first_action_la_code1 := NULL;
		p_pa_request_rec_out.first_action_la_desc1 := NULL;
		p_pa_request_rec_out.first_action_la_code2 := NULL;
		p_pa_request_rec_out.first_action_la_desc2 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '878' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '878') THEN
		p_pa_request_rec_out.from_position_title := NULL;
		p_pa_request_rec_out.from_position_number := NULL;
		p_pa_request_rec_out.from_pay_plan := NULL;
		p_pa_request_rec_out.from_occ_code := NULL;
		p_pa_request_rec_out.from_grade_or_level := NULL;
		p_pa_request_rec_out.from_step_or_rate := NULL;
		p_pa_request_rec_out.from_total_salary := NULL;
		p_pa_request_rec_out.from_total_salary := NULL;
		p_pa_request_rec_out.from_basic_pay := NULL;
--		p_pa_request_rec_out.from_locality_adj := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_pay_basis := NULL;
		p_pa_request_rec_out.from_position_org_line1 := NULL;
		p_pa_request_rec_out.from_position_org_line2 := NULL;
		p_pa_request_rec_out.from_position_org_line3 := NULL;
		p_pa_request_rec_out.from_position_org_line4 := NULL;
		p_pa_request_rec_out.from_position_org_line5 := NULL;
		p_pa_request_rec_out.from_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '819' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '819') THEN
		ghr_api.retrieve_element_entry_value(
             p_element_name           => 'Availability Pay',
             p_input_value_name       => 'Amount',
             p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
             p_effective_date         => p_pa_request_rec_in.effective_date - 1,
             p_value                  => l_tmp_availability,
             p_multiple_error_flag    => l_multi_error);
         l_availability_amt := TO_NUMBER(NVL(l_tmp_availability, '0'));
		 p_pa_request_rec_out.from_total_salary := l_availability_amt; -- Verify this

         IF (NVL(l_to_avail_pay, 0) > 0 AND l_availability_amt = 0)
         THEN
            p_pa_request_rec_out.from_total_salary := NULL;
			p_pa_request_rec_out.from_basic_pay := NULL;
			p_pa_request_rec_out.from_locality_adj := NULL;
			p_pa_request_rec_out.from_other_pay_amount := NULL;
         END IF;

	END IF;

	IF p_pa_request_rec_in.first_noa_code = '818' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '818') THEN
		ghr_api.retrieve_element_entry_value(
             p_element_name           => 'AUO',
             p_input_value_name       => 'Amount',
             p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
             p_effective_date         => p_pa_request_rec_in.effective_date - 1,
             p_value                  => l_tmp_auo_amount,
             p_multiple_error_flag    => l_multi_error);
         l_auo_amount := TO_NUMBER(NVL(l_tmp_auo_amount, '0'));
         IF (NVL(l_to_au_overtime, 0) > 0 AND l_auo_amount = 0)   -- Granting/Initiating
         THEN
            p_pa_request_rec_out.from_total_salary := NULL;
			p_pa_request_rec_out.from_basic_pay := NULL;
			p_pa_request_rec_out.from_locality_adj := NULL;
			p_pa_request_rec_out.from_other_pay_amount := NULL;
			p_pa_request_rec_out.from_pay_basis := NULL;
			p_pa_request_rec_out.from_position_org_line1 := NULL;
			p_pa_request_rec_out.from_position_org_line2 := NULL;
			p_pa_request_rec_out.from_position_org_line3 := NULL;
			p_pa_request_rec_out.from_position_org_line4 := NULL;
			p_pa_request_rec_out.from_position_org_line5 := NULL;
			p_pa_request_rec_out.from_position_org_line6 := NULL;
         END IF;

		 ghr_api.retrieve_element_entry_value(
			p_element_name           => 'AUO',
			p_input_value_name       => 'Premium Pay Ind',
			p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
			p_effective_date         => p_pa_request_rec_in.effective_date - 1,
			p_value                  => l_auo_premium_pay_indicator,
			p_multiple_error_flag    => l_multi_error);

		IF l_auo_premium_pay_indicator IS NOT NULL THEN
			l_ppi_percentage := 0;
			FOR l_percentage_ppi IN c_percentage_ppi(l_auo_premium_pay_indicator) LOOP
				l_ppi_percentage := l_percentage_ppi.ppi_percentage;
			END LOOP;
			p_pa_request_rec_out.from_total_salary := l_ppi_percentage;
		ELSE
			p_pa_request_rec_out.from_total_salary := 0;
		END IF;

		IF 	p_pa_request_rec_in.to_auo_premium_pay_indicator IS NOT NULL THEN
			l_ppi_percentage := 0;
			FOR l_percentage_ppi IN c_percentage_ppi(p_pa_request_rec_in.to_auo_premium_pay_indicator) LOOP
				l_ppi_percentage := l_percentage_ppi.ppi_percentage;
			END LOOP;
			p_pa_request_rec_out.to_total_salary := l_ppi_percentage;
		ELSE
			p_pa_request_rec_out.to_total_salary := 0;
		END IF;
	END IF;

	-- To Side Conditions

	IF 	p_pa_request_rec_in.noa_family_code IN ('NON_PAY_DUTY_STATUS', 'SEPARATION') THEN
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
			p_pa_request_rec_out.to_total_salary := NULL;
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
			p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773', '825') OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code IN ('772', '773', '825')) THEN
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('817','825', '878','850') OR
		( p_pa_request_rec_in.first_noa_code IN('001','002') AND p_pa_request_rec_in.second_noa_code IN ( '817','850' )) THEN
			p_pa_request_rec_out.to_pay_plan := NULL;
			p_pa_request_rec_out.to_occ_code := NULL;
			p_pa_request_rec_out.to_grade_or_level := NULL;
			p_pa_request_rec_out.to_step_or_rate := NULL;
			p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772','773','850') OR
		( p_pa_request_rec_in.first_noa_code IN('001','002') AND p_pa_request_rec_in.second_noa_code IN ('850' )) THEN
			p_pa_request_rec_out.to_total_salary := NULL;
	END IF;

	IF p_pa_request_rec_in.noa_family_code = ('GHR_STUDENT_LOAN') THEN
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773', '818', '819', '825', '878','850') OR
		( p_pa_request_rec_out.first_noa_code IN('001','002') AND p_pa_request_rec_out.second_noa_code IN ('817','850' ) ) THEN
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.noa_family_code = 'AWARD' OR
		(p_pa_request_rec_in.first_noa_code IN ('001','002') AND
		p_pa_request_rec_in.second_noa_code IN
		   ( '815','816','817','825','840', '841','842','843','844','845','846','847','848','849','878','879','850')) THEN
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '818' THEN
		p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773')
		OR  p_pa_request_rec_in.noa_family_code = 'NON_PAY_DUTY_STATUS'
		OR  (NVL(p_pa_request_rec_in.second_noa_code, '***') = '825')
		OR  (p_pa_request_rec_in.noa_family_code = 'SEPARATION' AND p_pa_request_rec_in.first_noa_code <> '352') THEN
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('818', '825', '878') THEN
		p_pa_request_rec_out.pay_rate_determinant := NULL;
	END IF;

	IF p_pa_request_rec_in.work_schedule NOT IN ('P', 'Q', 'R', 'S', 'T') THEN
		p_pa_request_rec_out.part_time_hours := NULL;
	END IF;

	IF p_pa_request_rec_in.flsa_category = '999' THEN
		p_pa_request_rec_out.flsa_category := NULL;
	END IF;

	IF p_pa_request_rec_in.from_position_id IS NULL THEN
		p_pa_request_rec_out.from_adj_basic_pay := NULL;
		p_pa_request_rec_out.from_basic_pay := NULL;
		p_pa_request_rec_out.from_grade_or_level := NULL;
		p_pa_request_rec_out.from_locality_adj := NULL;
		p_pa_request_rec_out.from_occ_code := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_pay_basis := NULL;
		p_pa_request_rec_out.from_pay_plan := NULL;
		p_pa_request_rec_out.from_position_title := NULL;
		p_pa_request_rec_out.from_step_or_rate := NULL;
	ELSE
		IF p_pa_request_rec_in.from_locality_adj = 0 THEN
			p_pa_request_rec_out.from_locality_adj := NULL;
		END IF;
		IF p_pa_request_rec_in.from_other_pay_amount = 0 THEN
			p_pa_request_rec_out.from_other_pay_amount := NULL;
		END IF;
	END IF;

	IF p_pa_request_rec_in.to_position_id IS NULL THEN
		p_pa_request_rec_out.to_adj_basic_pay := NULL;
		p_pa_request_rec_out.to_basic_pay := NULL;
		p_pa_request_rec_out.to_grade_or_level := NULL;
		p_pa_request_rec_out.to_locality_adj := NULL;
		p_pa_request_rec_out.to_occ_code := NULL;
		p_pa_request_rec_out.to_other_pay_amount := NULL;
		p_pa_request_rec_out.to_pay_basis := NULL;
		p_pa_request_rec_out.to_pay_plan := NULL;
		p_pa_request_rec_out.to_position_title := NULL;
		p_pa_request_rec_out.to_step_or_rate := NULL;
	ELSE
		IF p_pa_request_rec_in.to_locality_adj = 0 THEN
			p_pa_request_rec_out.to_locality_adj := NULL;
		END IF;
		IF p_pa_request_rec_in.to_other_pay_amount = 0 THEN
			p_pa_request_rec_out.to_other_pay_amount := NULL;
		END IF;
	END IF;



	IF p_pa_request_rec_in.award_amount IS NOT NULL
		AND NVL(p_pa_request_rec_in.first_noa_code,'0') NOT IN ('818','819') THEN
--Bug 6458088			IF NVL(p_pa_request_rec_in.award_uom,'X') = 'M' THEN
			p_pa_request_rec_out.to_total_salary := p_pa_request_rec_in.award_amount;
--Bug 6458088			END IF;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '819' THEN
		p_pa_request_rec_out.to_total_salary := NVL(p_pa_request_rec_in.to_availability_pay,0);
	END IF;

	IF p_pa_request_rec_in.first_noa_code='850' OR
		( p_pa_request_rec_in.first_noa_code IN ('001','002') and p_pa_request_rec_in.second_noa_code ='850' ) THEN
	   FOR get_mddds_amount_rec IN get_mddds_amount(p_pa_request_rec_in.pa_request_id)
	   LOOP
		l_mddds_special_pay_amount := get_mddds_amount_rec.amount;
	   END LOOP;
	   p_pa_request_rec_out.to_total_salary := NVL(l_mddds_special_pay_amount,0);
	END IF;

	IF p_pa_request_rec_in.first_noa_code='002' AND p_pa_request_rec_in.second_noa_code='790' THEN
		 ghr_pa_requests_pkg.get_rei_org_lines(
          p_pa_request_id       => p_pa_request_rec_in.pa_request_id,
          p_organization_id     => l_to_organization_id,
          p_position_org_line1  => p_pa_request_rec_out.to_position_org_line1,
          p_position_org_line2  => p_pa_request_rec_out.to_position_org_line2,
          p_position_org_line3  => p_pa_request_rec_out.to_position_org_line3,
          p_position_org_line4  => p_pa_request_rec_out.to_position_org_line4,
          p_position_org_line5  => p_pa_request_rec_out.to_position_org_line5,
          p_position_org_line6  => p_pa_request_rec_out.to_position_org_line6);
	END IF;

END CondPrinting_RPA;


/**************************** NPA Start ******************************************/


PROCEDURE Generate_NPA(p_pa_request_id  ghr_pa_requests.pa_request_id%type, p_view_type VARCHAR2, p_xml_string OUT NOCOPY CLOB) IS

CURSOR cur_NPA(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT
	 PERSON_ID,
	 EMPLOYEE_LAST_NAME ,
	 EMPLOYEE_FIRST_NAME ,
	 NVL(EMPLOYEE_MIDDLE_NAMES, 'NMN')  EMPLOYEE_MIDDLE_NAME
	,EMPLOYEE_NATIONAL_IDENTIFIER SS_NUMBER
	,EMPLOYEE_DATE_OF_BIRTH
	,EMPLOYEE_ASSIGNMENT_ID
	,NVL(GHR_UPD_HR_VALIDATION.GET_EXEMP_AWARD_DATE(PA_REQUEST_ID),EFFECTIVE_DATE)  EFFECTIVE_DATE
	,NOA_FAMILY_CODE
	,DECODE(LENGTH(NVL(FIRST_NOA_CODE, '')), 4, SUBSTR(FIRST_NOA_CODE, -3), FIRST_NOA_CODE) FIRST_NOA_CODE
	,FIRST_NOA_DESC
	,FIRST_ACTION_LA_CODE1
	,FIRST_ACTION_LA_CODE2
	,FIRST_ACTION_LA_DESC1
	,FIRST_ACTION_LA_DESC2
	,SECOND_ACTION_LA_CODE1
	,SECOND_ACTION_LA_CODE2
	,SECOND_ACTION_LA_DESC1
	,SECOND_ACTION_LA_DESC2
	,DECODE(LENGTH(NVL(SECOND_NOA_CODE, '')), 4, SUBSTR(SECOND_NOA_CODE, -3), SECOND_NOA_CODE) SECOND_NOA_CODE
	,SECOND_NOA_DESC
	,FROM_POSITION_ID
	,FROM_POSITION_NUMBER || DECODE(FROM_POSITION_NUMBER, NULL, NULL, ' - ')|| TO_CHAR(FROM_POSITION_SEQ_NO) FROM_POSITION_NUMBER
	,FROM_POSITION_TITLE
	,FROM_PAY_PLAN
	,FROM_OCC_CODE
	,FROM_GRADE_OR_LEVEL
	,FROM_STEP_OR_RATE
	,FROM_TOTAL_SALARY
	,FROM_PAY_BASIS
	,TO_NUMBER(FROM_BASIC_PAY) FROM_BASIC_PAY
	,FROM_LOCALITY_ADJ
	,FROM_ADJ_BASIC_PAY
	,FROM_OTHER_PAY_AMOUNT
	,FROM_POSITION_ORG_LINE1
	,FROM_POSITION_ORG_LINE2
	,FROM_POSITION_ORG_LINE3
	,FROM_POSITION_ORG_LINE4
	,FROM_POSITION_ORG_LINE5
	,FROM_POSITION_ORG_LINE6
	,FROM_AGENCY_CODE
	,FROM_AGENCY_DESC
	,TO_POSITION_ID
	,TO_POSITION_TITLE
	,TO_POSITION_NUMBER || DECODE(TO_POSITION_NUMBER, NULL, NULL, ' - ')|| TO_CHAR(TO_POSITION_SEQ_NO) TO_POSITION_NUMBER
	,TO_PAY_PLAN
	,TO_OCC_CODE
	,TO_GRADE_OR_LEVEL
	,TO_STEP_OR_RATE
	,TO_TOTAL_SALARY
	,TO_AUO_PREMIUM_PAY_INDICATOR
	,TO_AU_OVERTIME
	,TO_AVAILABILITY_PAY
	,AWARD_AMOUNT
	,AWARD_UOM
	,TO_PAY_BASIS
	,TO_BASIC_PAY
	,TO_LOCALITY_ADJ
	,TO_ADJ_BASIC_PAY
	,TO_OTHER_PAY_AMOUNT
	,TO_POSITION_ORG_LINE1
	,TO_POSITION_ORG_LINE2
	,TO_POSITION_ORG_LINE3
	,TO_POSITION_ORG_LINE4
	,TO_POSITION_ORG_LINE5
	,TO_POSITION_ORG_LINE6
	,VETERANS_PREFERENCE
	,TENURE
	,VETERANS_PREF_FOR_RIF
	,FEGLI
	,FEGLI_DESC
	,ANNUITANT_INDICATOR
	,ANNUITANT_INDICATOR_DESC
	,PAY_RATE_DETERMINANT
	,RETIREMENT_PLAN
	,RETIREMENT_PLAN_DESC
	,SERVICE_COMP_DATE
	,WORK_SCHEDULE
	,WORK_SCHEDULE_DESC
	,PART_TIME_HOURS
	,POSITION_OCCUPIED
	,FLSA_CATEGORY
	,APPROPRIATION_CODE1 || ' | ' ||  APPROPRIATION_CODE2 APPROPRIATION_CODE
	,BARGAINING_UNIT_STATUS
	,DUTY_STATION_CODE
	,DUTY_STATION_DESC
	,EMPLOYEE_DEPT_OR_AGENCY
	,AGENCY_CODE
	,PERSONNEL_OFFICE_ID
	,SF50_APPROVAL_DATE SF50_APPROVAL_DATE
	,SF50_APPROVING_OFCL_FULL_NAME
	,SF50_APPROVING_OFCL_WORK_TITLE
	,APPROVING_OFFICIAL_FULL_NAME
	,APPROVING_OFFICIAL_WORK_TITLE
	,APPROVAL_DATE APPROVAL_DATE
	,PA_REQUEST_ID
	,PA_NOTIFICATION_ID
	,SECOND_NOA_ID
	,ALTERED_PA_REQUEST_ID
	FROM GHR_PA_REQUESTS PAR
	WHERE PA_REQUEST_ID = c_pa_request_id;


	CURSOR c_remarks(c_pa_request_id GHR_PA_REMARKS.pa_request_id%type) IS
	SELECT
     pre.description,
     pre.pa_request_id,
     remk.code remark_code
	FROM
     ghr_pa_remarks pre,
     ghr_remarks remk
     WHERE  remk.remark_id = pre.remark_id
	 AND pre.pa_request_id = c_pa_request_id;

	CURSOR c_agency_use(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information3
	,rei_information4
	,rei_information5
	,rei_information6
	,rei_information7
	,rei_information8
	FROM ghr_pa_request_extra_info
	WHERE information_type = 'GHR_US_PAR_GEN_AGENCY_DATA'
	AND  pa_request_id = c_pa_request_id;

	l_pa_request_rec ghr_pa_requests%rowtype;
	l_pa_request_rec_out ghr_pa_requests%rowtype;
	l_cnt_sigs NUMBER;
	l_signature_rec t_signature_rec;
	l_rem_ctr NUMBER;
BEGIN
	l_new_line_sep := '
	';
	l_npa_report_tags.DELETE;
	l_npa_misc_fields.DELETE;
	-- Get RPA values

	FOR l_NPA IN cur_NPA(p_pa_request_id) LOOP
		l_pa_request_rec.PERSON_ID := l_NPA.PERSON_ID;
		l_pa_request_rec.EMPLOYEE_LAST_NAME := l_NPA.EMPLOYEE_LAST_NAME;
		l_pa_request_rec.EMPLOYEE_FIRST_NAME := l_NPA.EMPLOYEE_FIRST_NAME;
		l_pa_request_rec.PERSON_ID := l_NPA.PERSON_ID;
		l_pa_request_rec.EMPLOYEE_LAST_NAME := l_NPA.EMPLOYEE_LAST_NAME;
		l_pa_request_rec.EMPLOYEE_MIDDLE_NAMES := l_NPA.EMPLOYEE_MIDDLE_NAME;
		l_pa_request_rec.EMPLOYEE_NATIONAL_IDENTIFIER := l_NPA.SS_NUMBER;
		l_pa_request_rec.EMPLOYEE_DATE_OF_BIRTH := l_NPA.EMPLOYEE_DATE_OF_BIRTH;
		l_pa_request_rec.EMPLOYEE_ASSIGNMENT_ID := l_NPA.EMPLOYEE_ASSIGNMENT_ID;
		l_pa_request_rec.EFFECTIVE_DATE := l_NPA.EFFECTIVE_DATE;
		l_pa_request_rec.NOA_FAMILY_CODE := l_NPA.NOA_FAMILY_CODE;
		l_pa_request_rec.FIRST_NOA_CODE := l_NPA.FIRST_NOA_CODE;
		l_pa_request_rec.FIRST_NOA_DESC := l_NPA.FIRST_NOA_DESC;
		l_pa_request_rec.FIRST_ACTION_LA_CODE1 := l_NPA.FIRST_ACTION_LA_CODE1;
		l_pa_request_rec.FIRST_ACTION_LA_CODE2 := l_NPA.FIRST_ACTION_LA_CODE2;
		l_pa_request_rec.FIRST_ACTION_LA_DESC1 := l_NPA.FIRST_ACTION_LA_DESC1;
		l_pa_request_rec.FIRST_ACTION_LA_DESC2 := l_NPA.FIRST_ACTION_LA_DESC2;
		l_pa_request_rec.SECOND_ACTION_LA_CODE1 := l_NPA.SECOND_ACTION_LA_CODE1;
		l_pa_request_rec.SECOND_ACTION_LA_CODE2 := l_NPA.SECOND_ACTION_LA_CODE2;
		l_pa_request_rec.SECOND_ACTION_LA_DESC1 := l_NPA.SECOND_ACTION_LA_DESC1;
		l_pa_request_rec.SECOND_ACTION_LA_DESC2 := l_NPA.SECOND_ACTION_LA_DESC2;
		l_pa_request_rec.SECOND_NOA_CODE := l_NPA.SECOND_NOA_CODE;
		l_pa_request_rec.SECOND_NOA_DESC := l_NPA.SECOND_NOA_DESC;
		l_pa_request_rec.FROM_POSITION_ID := l_NPA.FROM_POSITION_ID;
		l_pa_request_rec.FROM_POSITION_NUMBER := l_NPA.FROM_POSITION_NUMBER;
		l_pa_request_rec.FROM_POSITION_TITLE := l_NPA.FROM_POSITION_TITLE;
		l_pa_request_rec.FROM_PAY_PLAN := l_NPA.FROM_PAY_PLAN;
		l_pa_request_rec.FROM_OCC_CODE := l_NPA.FROM_OCC_CODE;
		l_pa_request_rec.FROM_GRADE_OR_LEVEL := l_NPA.FROM_GRADE_OR_LEVEL;
		l_pa_request_rec.FROM_STEP_OR_RATE := l_NPA.FROM_STEP_OR_RATE;
		l_pa_request_rec.FROM_TOTAL_SALARY := l_NPA.FROM_TOTAL_SALARY;
		l_pa_request_rec.FROM_PAY_BASIS := l_NPA.FROM_PAY_BASIS;
		l_pa_request_rec.FROM_BASIC_PAY := l_NPA.FROM_BASIC_PAY;
		l_pa_request_rec.FROM_LOCALITY_ADJ := l_NPA.FROM_LOCALITY_ADJ;
		l_pa_request_rec.FROM_ADJ_BASIC_PAY := l_NPA.FROM_ADJ_BASIC_PAY;
		l_pa_request_rec.FROM_OTHER_PAY_AMOUNT := l_NPA.FROM_OTHER_PAY_AMOUNT;
		l_pa_request_rec.FROM_POSITION_ORG_LINE1 := l_NPA.FROM_POSITION_ORG_LINE1;
		l_pa_request_rec.FROM_POSITION_ORG_LINE2 := l_NPA.FROM_POSITION_ORG_LINE2;
		l_pa_request_rec.FROM_POSITION_ORG_LINE3 := l_NPA.FROM_POSITION_ORG_LINE3;
		l_pa_request_rec.FROM_POSITION_ORG_LINE4 := l_NPA.FROM_POSITION_ORG_LINE4;
		l_pa_request_rec.FROM_POSITION_ORG_LINE5 := l_NPA.FROM_POSITION_ORG_LINE5;
		l_pa_request_rec.FROM_POSITION_ORG_LINE6 := l_NPA.FROM_POSITION_ORG_LINE6;
		l_pa_request_rec.FROM_AGENCY_CODE := l_NPA.FROM_AGENCY_CODE;
		l_pa_request_rec.FROM_AGENCY_DESC := l_NPA.FROM_AGENCY_DESC;
		l_pa_request_rec.TO_POSITION_ID := l_NPA.TO_POSITION_ID;
		l_pa_request_rec.TO_POSITION_TITLE := l_NPA.TO_POSITION_TITLE;
		l_pa_request_rec.TO_POSITION_NUMBER := l_NPA.TO_POSITION_NUMBER;
		l_pa_request_rec.TO_PAY_PLAN := l_NPA.TO_PAY_PLAN;
		l_pa_request_rec.TO_OCC_CODE := l_NPA.TO_OCC_CODE;
		l_pa_request_rec.TO_GRADE_OR_LEVEL := l_NPA.TO_GRADE_OR_LEVEL;
		l_pa_request_rec.TO_STEP_OR_RATE := l_NPA.TO_STEP_OR_RATE;
		l_pa_request_rec.TO_TOTAL_SALARY := l_NPA.TO_TOTAL_SALARY;
		l_pa_request_rec.TO_AUO_PREMIUM_PAY_INDICATOR := l_NPA.TO_AUO_PREMIUM_PAY_INDICATOR;
		l_pa_request_rec.TO_AU_OVERTIME := l_NPA.TO_AU_OVERTIME;
		l_pa_request_rec.TO_AVAILABILITY_PAY := l_NPA.TO_AVAILABILITY_PAY;
		l_pa_request_rec.AWARD_AMOUNT := l_NPA.AWARD_AMOUNT;
		l_pa_request_rec.AWARD_UOM := l_NPA.AWARD_UOM;
		l_pa_request_rec.TO_PAY_BASIS := l_NPA.TO_PAY_BASIS;
		l_pa_request_rec.TO_BASIC_PAY := l_NPA.TO_BASIC_PAY;
		l_pa_request_rec.TO_LOCALITY_ADJ := l_NPA.TO_LOCALITY_ADJ;
		l_pa_request_rec.TO_ADJ_BASIC_PAY := l_NPA.TO_ADJ_BASIC_PAY;
		l_pa_request_rec.TO_OTHER_PAY_AMOUNT := l_NPA.TO_OTHER_PAY_AMOUNT;
		l_pa_request_rec.TO_POSITION_ORG_LINE1 := l_NPA.TO_POSITION_ORG_LINE1;
		l_pa_request_rec.TO_POSITION_ORG_LINE2 := l_NPA.TO_POSITION_ORG_LINE2;
		l_pa_request_rec.TO_POSITION_ORG_LINE3 := l_NPA.TO_POSITION_ORG_LINE3;
		l_pa_request_rec.TO_POSITION_ORG_LINE4 := l_NPA.TO_POSITION_ORG_LINE4;
		l_pa_request_rec.TO_POSITION_ORG_LINE5 := l_NPA.TO_POSITION_ORG_LINE5;
		l_pa_request_rec.TO_POSITION_ORG_LINE6 := l_NPA.TO_POSITION_ORG_LINE6;
		l_pa_request_rec.VETERANS_PREFERENCE := l_NPA.VETERANS_PREFERENCE;
		l_pa_request_rec.TENURE := l_NPA.TENURE;
		l_pa_request_rec.VETERANS_PREF_FOR_RIF := l_NPA.VETERANS_PREF_FOR_RIF;
		l_pa_request_rec.FEGLI := l_NPA.FEGLI;
		l_pa_request_rec.FEGLI_DESC := l_NPA.FEGLI_DESC;
		l_pa_request_rec.ANNUITANT_INDICATOR := l_NPA.ANNUITANT_INDICATOR;
		l_pa_request_rec.ANNUITANT_INDICATOR_DESC := l_NPA.ANNUITANT_INDICATOR_DESC;
		l_pa_request_rec.PAY_RATE_DETERMINANT := l_NPA.PAY_RATE_DETERMINANT;
		l_pa_request_rec.RETIREMENT_PLAN := l_NPA.RETIREMENT_PLAN;
		l_pa_request_rec.RETIREMENT_PLAN_DESC := l_NPA.RETIREMENT_PLAN_DESC;
		l_pa_request_rec.SERVICE_COMP_DATE := l_NPA.SERVICE_COMP_DATE;
		l_pa_request_rec.WORK_SCHEDULE := l_NPA.WORK_SCHEDULE;
		l_pa_request_rec.WORK_SCHEDULE_DESC := l_NPA.WORK_SCHEDULE_DESC;
		l_pa_request_rec.PART_TIME_HOURS := l_NPA.PART_TIME_HOURS;
		l_pa_request_rec.POSITION_OCCUPIED := l_NPA.POSITION_OCCUPIED;
		l_pa_request_rec.FLSA_CATEGORY := l_NPA.FLSA_CATEGORY;
		l_pa_request_rec.BARGAINING_UNIT_STATUS := l_NPA.BARGAINING_UNIT_STATUS;
		l_pa_request_rec.DUTY_STATION_CODE := l_NPA.DUTY_STATION_CODE;
		l_pa_request_rec.DUTY_STATION_DESC := l_NPA.DUTY_STATION_DESC;
		l_pa_request_rec.EMPLOYEE_DEPT_OR_AGENCY := l_NPA.EMPLOYEE_DEPT_OR_AGENCY;
		l_pa_request_rec.AGENCY_CODE := NVL(l_NPA.AGENCY_CODE,l_NPA.FROM_AGENCY_CODE); --Bug#8291918
		l_pa_request_rec.PERSONNEL_OFFICE_ID := l_NPA.PERSONNEL_OFFICE_ID;
		l_pa_request_rec.SF50_APPROVING_OFCL_FULL_NAME := l_NPA.SF50_APPROVING_OFCL_FULL_NAME;
		l_pa_request_rec.SF50_APPROVING_OFCL_WORK_TITLE := l_NPA.SF50_APPROVING_OFCL_WORK_TITLE;
		l_pa_request_rec.APPROVING_OFFICIAL_FULL_NAME := l_NPA.APPROVING_OFFICIAL_FULL_NAME;
		l_pa_request_rec.APPROVING_OFFICIAL_WORK_TITLE := l_NPA.APPROVING_OFFICIAL_WORK_TITLE;
		l_pa_request_rec.PA_REQUEST_ID := l_NPA.PA_REQUEST_ID;
		l_pa_request_rec.PA_NOTIFICATION_ID := l_NPA.PA_NOTIFICATION_ID;
		l_pa_request_rec.SECOND_NOA_ID := l_NPA.SECOND_NOA_ID;
		l_pa_request_rec.ALTERED_PA_REQUEST_ID := l_NPA.ALTERED_PA_REQUEST_ID;
		l_pa_request_rec.SF50_APPROVAL_DATE := l_NPA.SF50_APPROVAL_DATE;
		l_pa_request_rec.APPROVAL_DATE := l_NPA.APPROVAL_DATE; -- Bug:7610341

	CondPrinting_NPA(l_pa_request_rec,l_pa_request_rec_out);

	-- If Manager is viewing, then need to hide SSN and DOB
	IF p_view_type = 'MGR' THEN
		l_pa_request_rec_out.EMPLOYEE_NATIONAL_IDENTIFIER := NULL;
		l_pa_request_rec_out.EMPLOYEE_DATE_OF_BIRTH := NULL;
	END IF;


/* Start --  Bug:7610341*/
	IF l_pa_request_rec.first_noa_code NOT IN ('001','002') THEN
		IF l_pa_request_rec_out.sf50_approval_date > l_pa_request_rec_out.effective_date THEN
		    l_pa_request_rec_out.sf50_approval_date := l_pa_request_rec_out.effective_date;
		END IF;
	ELSE
		l_pa_request_rec_out.sf50_approval_date := l_pa_request_rec_out.APPROVAL_DATE;
	END IF;
/* End -- Bug:7610341  */

	-- Prepare XML with l_pa_request_rec_out
	-- Bug 4257449
	IF l_pa_request_rec_out.first_noa_code = '818' OR l_pa_request_rec_out.second_noa_code = '818'  THEN
	-- End Bug 4257449
--		OR l_pa_request_rec_out.second_noa_code IN ('818' ,'819') THEN
		IF l_pa_request_rec_out.from_total_salary IS NOT NULL THEN
			l_npa_misc_fields(1).from_tot_sal_or_awd := to_char(l_pa_request_rec_out.from_total_salary) || '%';
		END IF;
		IF l_pa_request_rec_out.to_total_salary IS NOT NULL THEN
			l_npa_misc_fields(1).to_tot_sal_or_awd := to_char(l_pa_request_rec_out.to_total_salary) || '%';
		END IF;
	ELSE
		IF l_pa_request_rec_out.from_total_salary IS NOT NULL THEN
			l_npa_misc_fields(1).from_tot_sal_or_awd := '$' || LTRIM(to_char(l_pa_request_rec_out.from_total_salary,'9G999G999D99'));
		END IF;
		IF l_pa_request_rec_out.to_total_salary IS NOT NULL THEN
/*Start : Bug 6458088 */
		 IF NVL(l_pa_request_rec_out.AWARD_UOM,'M')='M' THEN
		 /*Start: bug 7579682*/
			IF l_pa_request_rec_out.first_noa_code = '827' OR l_pa_request_rec_out.second_noa_code = '827' THEN
				l_npa_misc_fields(1).to_tot_sal_or_awd := l_pa_request_rec_out.to_total_salary || '%';
			ELSE
				l_npa_misc_fields(1).to_tot_sal_or_awd := '$' || LTRIM(to_char(l_pa_request_rec_out.to_total_salary,'9G999G999D99'));
			END IF;
		 /*End: bug 7579682*/
		 ELSE
	        	l_npa_misc_fields(1).to_tot_sal_or_awd := LTRIM(to_char(l_pa_request_rec_out.to_total_salary,'9G999G999')) || ' Hours';
	     END IF;
/*End : Bug 6458088 */
		END IF;
	END IF;

	l_npa_misc_fields(1).appropriation_code := l_NPA.appropriation_code;
	l_npa_misc_fields(1).from_position_org_lines := l_pa_request_rec_out.from_position_org_line1 || l_new_line_sep ||
													l_pa_request_rec_out.from_position_org_line2 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line3 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line4 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line5 || l_new_line_sep||
													l_pa_request_rec_out.from_position_org_line6;

	l_npa_misc_fields(1).to_position_org_lines :=   l_pa_request_rec_out.to_position_org_line1 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line2 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line3 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line4 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line5 || l_new_line_sep||
													l_pa_request_rec_out.to_position_org_line6;

	IF l_pa_request_rec_out.employee_last_name IS NOT NULL
	THEN
	  l_npa_misc_fields(1).employee_name := l_pa_request_rec_out.employee_last_name || ', ' || l_pa_request_rec_out.employee_first_name || ' ' ||NVL(l_pa_request_rec_out.employee_middle_names,'NMN');
	ELSE
	  l_npa_misc_fields(1).employee_name := l_pa_request_rec_out.employee_first_name || ' ' || NVL(l_pa_request_rec_out.employee_middle_names,'NMN') ;
	END IF;

	FOR l_agency_use IN c_agency_use(l_pa_request_rec_out.pa_request_id) LOOP
		l_npa_misc_fields(1).agency_code_use := l_agency_use.rei_information3;
		l_npa_misc_fields(1).agency_data40 := l_agency_use.rei_information4;
		l_npa_misc_fields(1).agency_data41 := l_agency_use.rei_information5;
		l_npa_misc_fields(1).agency_data42 := l_agency_use.rei_information6;
		l_npa_misc_fields(1).agency_data43 := l_agency_use.rei_information7;
		l_npa_misc_fields(1).agency_data44 := l_agency_use.rei_information8;
	END LOOP;

	IF l_pa_request_rec_out.veterans_pref_for_rif = 'Y' THEN
		l_npa_misc_fields(1).veterance_preference_for_rif_y := 'X';
	ELSIF l_pa_request_rec_out.veterans_pref_for_rif = 'N' THEN
		l_npa_misc_fields(1).veterance_preference_for_rif_n := 'X';
	END IF;

	IF l_pa_request_rec_out.to_position_id IS NULL THEN
	    l_npa_misc_fields(1).emp_dept_or_agency := l_pa_request_rec_out.from_agency_desc;
	ELSE
		l_npa_misc_fields(1).emp_dept_or_agency := l_pa_request_rec_out.employee_dept_or_agency;
	END IF;

	l_rpa_misc_fields(1).remarks_concat := NULL;
	l_rem_ctr := 1;
	-- Populating Remarks
	FOR l_remarks_rec IN c_remarks(l_pa_request_rec_out.pa_request_id) LOOP
		l_remarks(l_rem_ctr).remark_code := l_remarks_rec.remark_code;
		l_remarks(l_rem_ctr).remarks_desc := l_remarks_rec.description;
		l_npa_misc_fields(1).remarks_concat := l_npa_misc_fields(1).remarks_concat || l_remarks(l_rem_ctr).remarks_desc || l_new_line_sep;
		l_rem_ctr := (l_rem_ctr) + 1;
	END LOOP;

	-- Populate RPA Tags
	Populate_NPAtags(l_pa_request_rec_out,l_npa_misc_fields);
	WritetoXML('NPA', p_xml_string);
	END LOOP;


END Generate_NPA;



PROCEDURE CondPrinting_NPA(p_pa_request_rec_in IN ghr_pa_requests%rowtype,
                       p_pa_request_rec_out OUT NOCOPY ghr_pa_requests%rowtype)
IS
  l_tmp_auo_amount      VARCHAR2(30);
  l_tmp_availability    VARCHAR2(30);
  l_auo_amount          ghr_pa_requests.to_au_overtime%TYPE;
  l_availability_amt    ghr_pa_requests.to_availability_pay%TYPE;
  l_multi_error         BOOLEAN;
  l_auo_premium_pay_indicator ghr_pa_requests.to_auo_premium_pay_indicator%TYPE;
  l_ppi_percentage            ghr_premium_pay_indicators.ppi_percentage%TYPE;
  l_mddds_special_pay_amount ghr_pa_requests.to_total_salary%TYPE;
  l_to_avail_pay ghr_pa_requests.to_availability_pay%TYPE;
  l_to_au_overtime ghr_pa_requests.to_au_overtime%TYPE;
  l_to_organization_id per_assignments_f.organization_id%TYPE;
  l_pos_ei_data per_position_extra_info%rowtype;
  l_poi   VARCHAR2(30);

  CURSOR c_percentage_ppi(p_ppi_code ghr_premium_pay_indicators.code%TYPE) IS
	SELECT ppi.ppi_percentage
      FROM ghr_premium_pay_indicators ppi
     WHERE code = p_ppi_code;

  CURSOR get_mddds_amount(p_pa_request_id ghr_pa_requests.pa_request_id%type) IS
	SELECT rei_information11 amount
	FROM   ghr_pa_request_extra_info
	WHERE  pa_request_id = p_pa_request_id
	AND    information_type='GHR_US_PAR_MD_DDS_PAY';
BEGIN
	p_pa_request_rec_out := p_pa_request_rec_in;

/*Bug 6489839 . This code is not required for correction action.
	-- If it's a correction action, then call populate_corrected_sf52
	IF p_pa_request_rec_in.first_noa_code = '002' THEN
		ghr_corr_canc_sf52.populate_corrected_sf52(p_pa_request_rec_in.pa_request_id, p_pa_request_rec_in.first_noa_code);
		p_pa_request_rec_out := ghr_corr_canc_sf52.sf52_corr_rec;
	END IF;
*/

	-- From Side Conditions
	IF p_pa_request_rec_in.first_noa_code IN ('350','355') OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code IN ('350','355')) THEN
		p_pa_request_rec_out.first_action_la_code1 := NULL;
		p_pa_request_rec_out.first_action_la_desc1 := NULL;
		p_pa_request_rec_out.first_action_la_code2 := NULL;
		p_pa_request_rec_out.first_action_la_desc2 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '878' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '878') THEN
		p_pa_request_rec_out.from_position_title := NULL;
		p_pa_request_rec_out.from_position_number := NULL;
		p_pa_request_rec_out.from_pay_plan := NULL;
		p_pa_request_rec_out.from_occ_code := NULL;
		p_pa_request_rec_out.from_grade_or_level := NULL;
		p_pa_request_rec_out.from_step_or_rate := NULL;
		p_pa_request_rec_out.from_total_salary := NULL;
		p_pa_request_rec_out.from_total_salary := NULL;
		p_pa_request_rec_out.from_basic_pay := NULL;
--		p_pa_request_rec_out.from_locality_adj := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_pay_basis := NULL;
		p_pa_request_rec_out.from_position_org_line1 := NULL;
		p_pa_request_rec_out.from_position_org_line2 := NULL;
		p_pa_request_rec_out.from_position_org_line3 := NULL;
		p_pa_request_rec_out.from_position_org_line4 := NULL;
		p_pa_request_rec_out.from_position_org_line5 := NULL;
		p_pa_request_rec_out.from_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '819' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '819') THEN
		ghr_api.retrieve_element_entry_value(
             p_element_name           => 'Availability Pay',
             p_input_value_name       => 'Amount',
             p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
             p_effective_date         => p_pa_request_rec_in.effective_date - 1,
             p_value                  => l_tmp_availability,
             p_multiple_error_flag    => l_multi_error);
         l_availability_amt := TO_NUMBER(NVL(l_tmp_availability, '0'));
		 p_pa_request_rec_out.from_total_salary := l_availability_amt;

         IF (NVL(l_to_avail_pay, 0) > 0 AND l_availability_amt = 0)
         THEN
            p_pa_request_rec_out.from_total_salary := NULL;
			p_pa_request_rec_out.from_basic_pay := NULL;
			p_pa_request_rec_out.from_locality_adj := NULL;
			p_pa_request_rec_out.from_other_pay_amount := NULL;
         END IF;

	END IF;

	IF p_pa_request_rec_in.first_noa_code = '818' OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '818') THEN
		ghr_api.retrieve_element_entry_value(
             p_element_name           => 'AUO',
             p_input_value_name       => 'Amount',
             p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
             p_effective_date         => p_pa_request_rec_in.effective_date - 1,
             p_value                  => l_tmp_auo_amount,
             p_multiple_error_flag    => l_multi_error);
         l_auo_amount := TO_NUMBER(NVL(l_tmp_auo_amount, '0'));

		 IF (NVL(l_to_au_overtime, 0) > 0 AND l_auo_amount = 0)
         THEN
            p_pa_request_rec_out.from_total_salary := NULL;
			p_pa_request_rec_out.from_basic_pay := NULL;
			p_pa_request_rec_out.from_locality_adj := NULL;
			p_pa_request_rec_out.from_other_pay_amount := NULL;
			p_pa_request_rec_out.from_pay_basis := NULL;
			p_pa_request_rec_out.from_position_org_line1 := NULL;
			p_pa_request_rec_out.from_position_org_line2 := NULL;
			p_pa_request_rec_out.from_position_org_line3 := NULL;
			p_pa_request_rec_out.from_position_org_line4 := NULL;
			p_pa_request_rec_out.from_position_org_line5 := NULL;
			p_pa_request_rec_out.from_position_org_line6 := NULL;
         END IF;

		 ghr_api.retrieve_element_entry_value(
			p_element_name           => 'AUO',
			p_input_value_name       => 'Premium Pay Ind',
			p_assignment_id          => p_pa_request_rec_in.employee_assignment_id,
			p_effective_date         => p_pa_request_rec_in.effective_date - 1,
			p_value                  => l_auo_premium_pay_indicator,
			p_multiple_error_flag    => l_multi_error);

		IF l_auo_premium_pay_indicator IS NOT NULL THEN
			l_ppi_percentage := 0;
			FOR l_percentage_ppi IN c_percentage_ppi(l_auo_premium_pay_indicator) LOOP
				l_ppi_percentage := l_percentage_ppi.ppi_percentage;
			END LOOP;
			p_pa_request_rec_out.from_total_salary := l_ppi_percentage;
		ELSE
			p_pa_request_rec_out.from_total_salary := 0;
		END IF;

		IF 	p_pa_request_rec_in.to_auo_premium_pay_indicator IS NOT NULL THEN
			l_ppi_percentage := 0;
			FOR l_percentage_ppi IN c_percentage_ppi(p_pa_request_rec_in.to_auo_premium_pay_indicator) LOOP
				l_ppi_percentage := l_percentage_ppi.ppi_percentage;
			END LOOP;
			p_pa_request_rec_out.to_total_salary := l_ppi_percentage;
		ELSE
			p_pa_request_rec_out.to_total_salary := 0;
		END IF;
	END IF;

	-- To Side Conditions

	IF 	p_pa_request_rec_in.noa_family_code IN ('NON_PAY_DUTY_STATUS', 'SEPARATION') THEN
			p_pa_request_rec_out.to_position_title := NULL;
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
			p_pa_request_rec_out.to_total_salary := NULL;
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
			p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773', '825') OR
		(p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code IN ('772', '773', '825')) THEN
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('817','825', '878','850') OR
		( p_pa_request_rec_in.first_noa_code IN('001','002') AND p_pa_request_rec_in.second_noa_code IN ( '817','850' )) THEN
			p_pa_request_rec_out.to_pay_plan := NULL;
			p_pa_request_rec_out.to_occ_code := NULL;
			p_pa_request_rec_out.to_grade_or_level := NULL;
			p_pa_request_rec_out.to_step_or_rate := NULL;
			p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772','773','850') OR
		( p_pa_request_rec_in.first_noa_code IN('001','002') AND p_pa_request_rec_in.second_noa_code IN ('850' )) THEN
			p_pa_request_rec_out.to_total_salary := NULL;
	END IF;

	IF p_pa_request_rec_in.noa_family_code = ('GHR_STUDENT_LOAN') THEN
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773', '818', '819', '825', '878','850') OR
		( p_pa_request_rec_out.first_noa_code IN('001','002') AND p_pa_request_rec_out.second_noa_code IN ('817','850' ) ) THEN
			p_pa_request_rec_out.to_basic_pay := NULL;
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_adj_basic_pay := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.noa_family_code = 'AWARD' OR
		(p_pa_request_rec_in.first_noa_code IN ('001','002') AND
		p_pa_request_rec_in.second_noa_code IN
		   ( '815','816','817','825','840', '841','842','843','844','845','846','847','848','849','878','879','850')
		   OR p_pa_request_rec_in.second_noa_code like '3%') THEN
			p_pa_request_rec_out.to_locality_adj := NULL;
			p_pa_request_rec_out.to_other_pay_amount := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '818' THEN
		p_pa_request_rec_out.to_pay_basis := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('772', '773')
		OR  p_pa_request_rec_in.noa_family_code = 'NON_PAY_DUTY_STATUS'
		OR  (NVL(p_pa_request_rec_in.second_noa_code, '***') = '825')
		OR  (p_pa_request_rec_in.noa_family_code = 'SEPARATION' AND p_pa_request_rec_in.first_noa_code <> '352') THEN
			p_pa_request_rec_out.to_position_org_line1 := NULL;
			p_pa_request_rec_out.to_position_org_line2 := NULL;
			p_pa_request_rec_out.to_position_org_line3 := NULL;
			p_pa_request_rec_out.to_position_org_line4 := NULL;
			p_pa_request_rec_out.to_position_org_line5 := NULL;
			p_pa_request_rec_out.to_position_org_line6 := NULL;
	END IF;

	IF p_pa_request_rec_in.first_noa_code IN ('818', '825', '878') THEN
		p_pa_request_rec_out.annuitant_indicator := NULL;
	END IF;

	IF NVL(p_pa_request_rec_in.work_schedule,p_pa_request_rec_out.work_schedule) NOT IN ('P', 'Q', 'R', 'S', 'T') THEN
		p_pa_request_rec_out.part_time_hours := NULL;
	END IF;

	IF NVL(p_pa_request_rec_in.flsa_category,p_pa_request_rec_out.work_schedule) = '999' THEN
		p_pa_request_rec_out.flsa_category := NULL;
	END IF;

	IF NVL(p_pa_request_rec_in.from_position_id,p_pa_request_rec_out.from_position_id) IS NULL THEN
		p_pa_request_rec_out.from_adj_basic_pay := NULL;
		p_pa_request_rec_out.from_basic_pay := NULL;
		p_pa_request_rec_out.from_grade_or_level := NULL;
		p_pa_request_rec_out.from_locality_adj := NULL;
		p_pa_request_rec_out.from_occ_code := NULL;
		p_pa_request_rec_out.from_other_pay_amount := NULL;
		p_pa_request_rec_out.from_pay_basis := NULL;
		p_pa_request_rec_out.from_pay_plan := NULL;
		p_pa_request_rec_out.from_position_title := NULL;
		p_pa_request_rec_out.from_step_or_rate := NULL;
	ELSE
		IF p_pa_request_rec_in.from_locality_adj = 0 THEN
			p_pa_request_rec_out.from_locality_adj := NULL;
		END IF;
		IF p_pa_request_rec_in.from_other_pay_amount = 0 THEN
			p_pa_request_rec_out.from_other_pay_amount := NULL;
		END IF;
	END IF;

	IF NVL(p_pa_request_rec_in.to_position_id,p_pa_request_rec_out.to_position_id) IS NULL THEN
		p_pa_request_rec_out.to_adj_basic_pay := NULL;
		p_pa_request_rec_out.to_basic_pay := NULL;
		p_pa_request_rec_out.to_grade_or_level := NULL;
		p_pa_request_rec_out.to_locality_adj := NULL;
		p_pa_request_rec_out.to_occ_code := NULL;
		p_pa_request_rec_out.to_other_pay_amount := NULL;
		p_pa_request_rec_out.to_pay_basis := NULL;
		p_pa_request_rec_out.to_pay_plan := NULL;
		p_pa_request_rec_out.to_position_title := NULL;
		p_pa_request_rec_out.to_step_or_rate := NULL;
	ELSE
		IF p_pa_request_rec_in.to_locality_adj = 0 THEN
			p_pa_request_rec_out.to_locality_adj := NULL;
		END IF;
		IF p_pa_request_rec_in.to_other_pay_amount = 0 THEN
			p_pa_request_rec_out.to_other_pay_amount := NULL;
		END IF;
	END IF;

	IF NVL(p_pa_request_rec_in.award_amount,p_pa_request_rec_out.award_amount) IS NOT NULL
		AND NVL(p_pa_request_rec_in.first_noa_code,'0') NOT IN ('818','819') THEN
--Bug 6458088		IF NVL(p_pa_request_rec_in.award_uom,'X') = 'M' THEN
			p_pa_request_rec_out.to_total_salary := p_pa_request_rec_in.award_amount;
--Bug 6458088			END IF;
	END IF;

	IF p_pa_request_rec_in.first_noa_code = '819' THEN
		p_pa_request_rec_out.to_total_salary := NVL(p_pa_request_rec_in.to_availability_pay,0);
	END IF;

	IF p_pa_request_rec_in.first_noa_code='850' OR
		( p_pa_request_rec_in.first_noa_code IN ('001','002') and p_pa_request_rec_in.second_noa_code ='850' ) THEN
	   FOR get_mddds_amount_rec IN get_mddds_amount(p_pa_request_rec_in.pa_request_id)
	   LOOP
		l_mddds_special_pay_amount := get_mddds_amount_rec.amount;
	   END LOOP;
	   p_pa_request_rec_out.to_total_salary := NVL(l_mddds_special_pay_amount,0);
	END IF;

	IF p_pa_request_rec_in.first_noa_code='002' AND p_pa_request_rec_in.second_noa_code='790' THEN
		 ghr_pa_requests_pkg.get_rei_org_lines(
          p_pa_request_id       => p_pa_request_rec_in.pa_request_id,
          p_organization_id     => l_to_organization_id,
          p_position_org_line1  => p_pa_request_rec_out.to_position_org_line1,
          p_position_org_line2  => p_pa_request_rec_out.to_position_org_line2,
          p_position_org_line3  => p_pa_request_rec_out.to_position_org_line3,
          p_position_org_line4  => p_pa_request_rec_out.to_position_org_line4,
          p_position_org_line5  => p_pa_request_rec_out.to_position_org_line5,
          p_position_org_line6  => p_pa_request_rec_out.to_position_org_line6);
	END IF;

	IF (p_pa_request_rec_in.first_noa_code = '790'
    OR (p_pa_request_rec_in.first_noa_code = '002' AND p_pa_request_rec_in.second_noa_code = '790')
    OR (p_pa_request_rec_in.first_noa_code = '001' AND p_pa_request_rec_in.second_noa_code = '790') ) THEN
		 ghr_history_fetch.fetch_positionei
        (p_position_id    =>   p_pa_request_rec_in.to_position_id,
         p_information_type => 'GHR_US_POS_GRP1',
         p_date_effective   =>  p_pa_request_rec_in.effective_date,
         p_pos_ei_data       =>  l_pos_ei_data
        );
		l_poi := l_pos_ei_data.poei_information3;
		IF p_pa_request_rec_out.personnel_office_id IS NOT NULL THEN
			p_pa_request_rec_out.personnel_office_id := l_poi;
		END IF;
	END IF;
END CondPrinting_NPA;


PROCEDURE Populate_NPAtags(p_pa_request_rec IN ghr_pa_requests%ROWTYPE,
							p_npa_misc_fields t_npa_misc_fields_rec) IS
l_ctr NUMBER;
BEGIN
	l_ctr := 1;
	l_npa_report_tags.DELETE;
	-- Start populating Part A
	l_npa_report_tags(l_ctr).tag_name := 'PrepName';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).employee_name;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'SSN';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.employee_national_identifier;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DOB';
	l_npa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.employee_date_of_birth,'MM-DD-YYYY');
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'EffDate';
	l_npa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.effective_date,'MM-DD-YYYY');
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeA';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_noa_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ActionA';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_noa_desc;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeAA';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_noa_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ActionBB';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_noa_desc;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeC';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_code1;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AuthD';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_desc1;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeCC';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_code1;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AuthDD';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_desc1;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeE';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_code2;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AuthF';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.first_action_la_desc2;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'CodeEE';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_code2;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AuthFF';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.second_action_la_desc2;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrPosTle';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_title;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrPosNo';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_number;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToPosTle';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_title;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToPosNo';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_number;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmPayPl';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_pay_plan;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmOcCod';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_occ_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmGrade';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_grade_or_level;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmStep';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_step_or_rate;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmSalry';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).from_tot_sal_or_awd;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FrmPyBas';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_pay_basis;
	l_ctr := l_ctr + 1;

	IF p_pa_request_rec.from_basic_pay IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'FrmBasPy';
	--	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_basic_pay;
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_basic_pay,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.from_locality_adj IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'FrmLocAj';
	--	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_locality_adj;
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_locality_adj,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.from_adj_basic_pay IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'FrmAdjPy';
	--	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_adj_basic_pay;
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_adj_basic_pay,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.from_other_pay_amount IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'FrmOthr';
	--	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_other_pay_amount;
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.from_other_pay_amount,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	l_npa_report_tags(l_ctr).tag_name := 'ToPayPl';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_pay_plan;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToOcCod';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_occ_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToGrade';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_grade_or_level;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToStep';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_step_or_rate;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToSalry';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).to_tot_sal_or_awd;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'ToPyBas';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_pay_basis;
	l_ctr := l_ctr + 1;

	IF p_pa_request_rec.to_basic_pay IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'ToBasPy';
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_basic_pay,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.to_locality_adj IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'ToLocAj';
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_locality_adj,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.to_adj_basic_pay IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'ToAdjPy';
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_adj_basic_pay,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	IF p_pa_request_rec.to_other_pay_amount IS NOT NULL THEN
		l_npa_report_tags(l_ctr).tag_name := 'ToOthr';
		l_npa_report_tags(l_ctr).par_field_value := '$' || LTRIM(to_char(p_pa_request_rec.to_other_pay_amount,'9G999G999D99'));
		l_ctr := l_ctr + 1;
	END IF;

	l_npa_report_tags(l_ctr).tag_name := 'FromName';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).from_position_org_lines;
	l_ctr := l_ctr + 1;

/*	l_npa_report_tags(l_ctr).tag_name := 'FromLoc';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.from_position_org_line6;
	l_ctr := l_ctr + 1; */

	l_npa_report_tags(l_ctr).tag_name := 'ToName';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).to_position_org_lines;
	l_ctr := l_ctr + 1;

/*	l_npa_report_tags(l_ctr).tag_name := 'ToLoc';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.to_position_org_line6;
	l_ctr := l_ctr + 1; */

	-- Populating Employee Data

	l_npa_report_tags(l_ctr).tag_name := 'VetPref';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.veterans_preference;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'Tenure';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.tenure;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AgyUsCd';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_code_use;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'VetPrefY';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).veterance_preference_for_rif_y;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'VetPrefN';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).veterance_preference_for_rif_n;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FEGLICod';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.fegli;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FEGLI';
	l_npa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_FEGLI', p_pa_request_rec.fegli);
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AnnCode';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.annuitant_indicator;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AnnIndic';
	l_npa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_ANNUITANT_INDICATOR', p_pa_request_rec.annuitant_indicator);
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'PRDCode';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.pay_rate_determinant;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'RetireCd';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.retirement_plan;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'RetirePl';
	l_npa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_RETIREMENT_PLAN', p_pa_request_rec.retirement_plan);
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'SrvCmDat';
	l_npa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.service_comp_date,'MM-DD-YYYY');
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'WrkSchCd';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.work_schedule;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'WrkSched';
	l_npa_report_tags(l_ctr).par_field_value := hr_general.decode_lookup('GHR_US_WORK_SCHEDULE', p_pa_request_rec.work_schedule);
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'PTHours';
	l_npa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.part_time_hours);
	l_ctr := l_ctr + 1;

	-- Populating Position Data


	l_npa_report_tags(l_ctr).tag_name := 'PosOccCd';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.position_occupied;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'FLSACode';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.flsa_category;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'Approp';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).appropriation_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'BargUnit';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.bargaining_unit_status;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DyStaCd';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.duty_station_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DutyStat';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.duty_station_desc;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AgyData';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_data40;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DataA';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_data41;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DataB';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_data42;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DataC';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_data43;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'DataD';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).agency_data44;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'EmpDeptAgncy';
	l_npa_report_tags(l_ctr).par_field_value := p_npa_misc_fields(1).emp_dept_or_agency;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AgencyCode';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.agency_code;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'POID';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.personnel_office_id;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'AppvDate';
	l_npa_report_tags(l_ctr).par_field_value := to_char(p_pa_request_rec.sf50_approval_date,'MM-DD-YYYY');
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'SF50AprvName';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.sf50_approving_ofcl_full_name;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'SF50AprvWrkTitle';
	l_npa_report_tags(l_ctr).par_field_value := p_pa_request_rec.sf50_approving_ofcl_work_title;
	l_ctr := l_ctr + 1;

	l_npa_report_tags(l_ctr).tag_name := 'RemarkSF';
	l_npa_report_tags(l_ctr).par_field_value := '<![CDATA['|| p_npa_misc_fields(1).remarks_concat ||']]>';
	l_ctr := l_ctr + 1;

END Populate_NPAtags;

PROCEDURE Get_Template(p_program_name fnd_lobs.program_name%type, p_template OUT NOCOPY BLOB)
IS
CURSOR c_get_template(c_program_name fnd_lobs.program_name%type) IS
	SELECT FILE_DATA
	FROM FND_LOBS
	WHERE PROGRAM_NAME = c_program_name order by file_id desc;
BEGIN
	FOR l_get_template IN c_get_template(p_program_name) LOOP
		p_template := l_get_template.FILE_DATA;
		exit;
	END LOOP;

END Get_Template;

PROCEDURE Debug(p_id NUMBER, p_statement VARCHAR2)
IS
l_message_name ghr_process_log.message_name%type;
l_log_text             ghr_process_log.log_text%type;
BEGIN
	-- Add code here if debugging has to be done..
	NULL;
END Debug;



END GHR_GEN_RPA_NPA;

/
