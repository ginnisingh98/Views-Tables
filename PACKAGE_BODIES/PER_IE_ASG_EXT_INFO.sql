--------------------------------------------------------
--  DDL for Package Body PER_IE_ASG_EXT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IE_ASG_EXT_INFO" AS
/* $Header: perieeit.pkb 120.0.12010000.1 2008/09/30 13:02:41 rsahai noship $ */

PROCEDURE CREATE_IE_ASG_EXT_INFO(P_ASSIGNMENT_ID  NUMBER
					,P_INFORMATION_TYPE		VARCHAR2
					,P_AEI_ATTRIBUTE_CATEGORY	VARCHAR2
					,P_AEI_INFORMATION_CATEGORY   VARCHAR2
					,P_AEI_INFORMATION1      VARCHAR2
					,P_AEI_INFORMATION2      VARCHAR2
					,P_AEI_INFORMATION3      VARCHAR2
					,P_AEI_INFORMATION4      VARCHAR2
					,P_AEI_INFORMATION5      VARCHAR2
					)
IS

CURSOR cur_ppsn_number IS
SELECT DISTINCT NATIONAL_IDENTIFIER
FROM per_all_assignments_f paaf, per_all_people_f papf
WHERE paaf.assignment_id = P_ASSIGNMENT_ID
AND paaf.person_id = papf.person_id;

l_ppsn_number per_all_people_f.national_identifier%type;

CURSOR cur_check_ppsn is
SELECT NVL(instr(substr(P_AEI_INFORMATION1,1,length(l_ppsn_number)),l_ppsn_number),0) check_ppsn
FROM dual;

l_check_ppsn number;

BEGIN

 IF P_AEI_INFORMATION_CATEGORY = 'IE_ASG_OVERRIDE' THEN
	 OPEN cur_ppsn_number;
	 FETCH cur_ppsn_number INTO l_ppsn_number;
	 CLOSE cur_ppsn_number;

	 OPEN cur_check_ppsn;
	 FETCH cur_check_ppsn INTO l_check_ppsn;
	 CLOSE cur_check_ppsn;

	 IF l_check_ppsn = 0 THEN
	   hr_utility.set_message(800,'HR_IE_PPSN_OVERRIDE');
	   hr_utility.raise_error;
	 END IF;
 END IF;
END;

PROCEDURE UPDATE_IE_ASG_EXT_INFO(P_ASSIGNMENT_EXTRA_INFO_ID  NUMBER
					,P_AEI_ATTRIBUTE_CATEGORY	VARCHAR2
					,P_AEI_INFORMATION_CATEGORY   VARCHAR2
					,P_AEI_INFORMATION1      VARCHAR2
					,P_AEI_INFORMATION2      VARCHAR2
					,P_AEI_INFORMATION3      VARCHAR2
					,P_AEI_INFORMATION4      VARCHAR2
					,P_AEI_INFORMATION5      VARCHAR2
					)
IS

CURSOR cur_ppsn_number IS
SELECT DISTINCT NATIONAL_IDENTIFIER
FROM per_all_assignments_f paaf, per_all_people_f papf, per_assignment_extra_info paei
WHERE paei.assignment_extra_info_id = p_assignment_extra_info_id
and paei.aei_information_category = p_aei_information_category
AND paaf.assignment_id = paei.assignment_id
AND paaf.person_id = papf.person_id;

l_ppsn_number per_all_people_f.national_identifier%type;

CURSOR cur_check_ppsn is
SELECT NVL(instr(substr(P_AEI_INFORMATION1,1,length(l_ppsn_number)),l_ppsn_number),0) check_ppsn
FROM dual;

l_check_ppsn number;

BEGIN
 IF P_AEI_INFORMATION_CATEGORY = 'IE_ASG_OVERRIDE' THEN
	 OPEN cur_ppsn_number;
	 FETCH cur_ppsn_number INTO l_ppsn_number;
	 CLOSE cur_ppsn_number;

	 OPEN cur_check_ppsn;
	 FETCH cur_check_ppsn INTO l_check_ppsn;
	 CLOSE cur_check_ppsn;

	 IF l_check_ppsn = 0 THEN
	   hr_utility.set_message(800,'HR_IE_PPSN_OVERRIDE');
	   hr_utility.raise_error;
	 END IF;
 END IF;
END;

END PER_IE_ASG_EXT_INFO;

/
