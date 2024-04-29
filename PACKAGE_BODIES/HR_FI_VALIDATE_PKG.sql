--------------------------------------------------------
--  DDL for Package Body HR_FI_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_VALIDATE_PKG" AS
/* $Header: pefivald.pkb 120.18.12010000.3 2009/04/13 11:15:58 rsengupt ship $ */

 PROCEDURE VALIDATE
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
   ) IS

    l_type		varchar2(1) := NULL;
    l_field		varchar2(300) := NULL;
    l_valid_date	varchar2(10);
    l_date		date;

    CURSOR c_type IS
    SELECT 'Y'
    FROM   per_person_types ppt
    WHERE  ppt.system_person_type like 'EMP%'
    AND    ppt.person_type_Id = p_person_type_id;

  BEGIN
    l_type := NULL;
     OPEN c_type;
     FETCH c_type INTO l_type;
     CLOSE c_type;


      --Validate not null fields
      IF l_type IS NOT NULL THEN
	IF p_national_identifier  IS NULL or p_national_identifier = hr_api.g_varchar2 THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','PIN');
	END IF;
      END IF;

      IF l_field IS NOT NULL AND fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') THEN
	fnd_message.set_name('PER', 'HR_376603_FI_MANDATORY_MSG');
        fnd_message.set_token('NAME',l_field, translate => true );
        hr_utility.raise_error;
      END IF;
      IF p_date_of_birth   IS NOT NULL  AND p_per_information8   IS NOT NULL  THEN
		BEGIN
		   l_date:= fnd_date.canonical_to_date(p_per_information8);
	           IF  p_date_of_birth >= l_date THEN
	                fnd_message.set_name('PER', 'HR_376609_FI_INVALID_DATE');
	                hr_utility.raise_error;
	           END IF;
		EXCEPTION
			WHEN OTHERS THEN
			NULL;
		END ;
      END IF;
  END VALIDATE;

  --Procedure for validating person
  PROCEDURE person_validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
  ) IS
  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
      --
      validate
      (p_person_type_id             =>  p_person_type_id
      ,p_first_name                 =>  p_first_name
      ,p_national_identifier        =>  p_national_identifier
      ,p_date_of_birth              =>  p_date_of_birth
      ,p_per_information8           =>  p_per_information8);
	  --
	END IF;
  END person_validate;

    --Procedure for validating applicant
  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
    ) IS
l_person_type_id   number ;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
       --
       per_per_bus.chk_person_type
         (p_person_type_id    => l_person_type_id
         ,p_business_group_id => p_business_group_id
         ,p_expected_sys_type => 'APL');
	   --
       validate
         (p_person_type_id             =>  l_person_type_id
         ,p_first_name                 =>  p_first_name
         ,p_national_identifier        =>  p_national_identifier
         ,p_date_of_birth              =>  p_date_of_birth
         ,p_per_information8           =>  p_per_information8
         );
     END IF;
  END applicant_validate;

  --Procedure for validating employee
  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
    ) IS
  l_person_type_id   number ;
  BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
       --
       per_per_bus.chk_person_type
      (p_person_type_id    => l_person_type_id
      ,p_business_group_id => p_business_group_id
      ,p_expected_sys_type => 'EMP'
      );
      validate
      (p_person_type_id             =>  l_person_type_id
      ,p_first_name                 =>  p_first_name
      ,p_national_identifier        =>  p_national_identifier
      ,p_date_of_birth              =>  p_date_of_birth
      ,p_per_information8           =>  p_per_information8
       );
    END IF;
  END employee_validate;

   --Procedure for validating contact/cwk
  PROCEDURE contact_cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_date_of_birth                  in      date     default null
  ,p_per_information8               in      varchar2 default null
    ) IS
l_person_type_id   number ;
  BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
       --
       per_per_bus.chk_person_type
       (p_person_type_id    => l_person_type_id
       ,p_business_group_id => p_business_group_id
       ,p_expected_sys_type => 'OTHER'
       );
      validate
      (p_person_type_id             =>  l_person_type_id
      ,p_first_name                 =>  p_first_name
      ,p_national_identifier        =>  p_national_identifier
      ,p_date_of_birth              =>  p_date_of_birth
      ,p_per_information8           =>  p_per_information8
      );
	END IF;
  END contact_cwk_validate;

   --Procedure for validating qualification insertion
PROCEDURE qual_insert_validate
  (p_business_group_id              in      number
  ,p_qua_information_category       in      varchar2 default null
  ,p_person_id                      in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  ) IS
      l_count 	    NUMBER;
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
    IF substr(p_qua_information1,1,1) not in ('0','1','2','3','4','5','6','7','9')  OR  substr(p_qua_information1,2,1) not in ('0','1','2','3','4','5','6','7','8','9') THEN
        fnd_message.set_name('PER', 'HR_376605_FI_EDUCATION_CODE');
        hr_utility.raise_error;
    END IF;

    IF p_qua_information1 is not null and length(p_qua_information1) not in (2,6) THEN
        fnd_message.set_name('PER', 'HR_376608_FI_EC_INVALID_LENGTH');
        hr_utility.raise_error;
    END IF;
    validate_number(p_qua_information1,NULL,'HR_376605_FI_EDUCATION_CODE');
    IF p_qua_information2 ='Y' THEN
	select count(*)
	into l_count
	from  per_qualifications pq
        where pq.business_group_id   = p_business_group_id
	and pq.person_id    =   p_person_id
	and pq.qua_information_category='FI'
	and pq.qua_information2='Y';
        IF l_count > 0 then
	      fnd_message.set_name('PER', 'HR_376606_FI_PREFERRED_LEVEL');
	        hr_utility.raise_error;
        END IF;
    END IF ;
   END IF;
  END qual_insert_validate;

   --Procedure for validating qualification Update
PROCEDURE qual_update_validate
  (p_qua_information_category       in      varchar2 default null
  ,p_qualification_id               in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  ) IS
      l_count		        NUMBER;
      l_person_id    		NUMBER;
      l_business_group_id     	NUMBER;

    CURSOR c_person_id IS
    SELECT person_id,business_group_id
    FROM   per_qualifications
    WHERE  qualification_id = p_qualification_id;

  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
    IF substr(p_qua_information1,1,1) not in ('0','1','2','3','4','5','6','7','9')  OR  substr(p_qua_information1,2,1) not in ('0','1','2','3','4','5','6','7','8','9') THEN
        fnd_message.set_name('PER', 'HR_376605_FI_EDUCATION_CODE');
        hr_utility.raise_error;
    END IF;
    validate_number(p_qua_information1,NULL,'HR_376605_FI_EDUCATION_CODE');
    IF p_qua_information1 is not null and length(p_qua_information1) not in (2,6) THEN
        fnd_message.set_name('PER', 'HR_376608_FI_EC_INVALID_LENGTH');
        hr_utility.raise_error;
    END IF;
    IF p_qua_information2 ='Y' THEN
	 l_person_id := NULL;
	 OPEN c_person_id;
         FETCH c_person_id INTO l_person_id,l_business_group_id;
         CLOSE c_person_id;

	select count(*)
	into l_count
	from  per_qualifications pq
        where pq.business_group_id   = l_business_group_id
	and pq.person_id    =   l_person_id
        and pq.qualification_id <> p_qualification_id
	and pq.qua_information_category='FI'
	and pq.qua_information2='Y';

        IF l_count > 0 then
	      fnd_message.set_name('PER', 'HR_376606_FI_PREFERRED_LEVEL');
	        hr_utility.raise_error;
        END IF;

    END IF;
   END IF;
  END qual_update_validate ;



-- Procedure for Organisation Local Units

--___________________________________________VALIDATE_CREATE_ORG_INF_____________________________________________

PROCEDURE validate_create_org_inf
  (p_effective_date             IN	DATE
  ,p_org_info_type_code		IN	VARCHAR2
  ,p_organization_id		IN	NUMBER
  ,p_org_information1		IN	VARCHAR2 DEFAULT null
  ,p_org_information2		IN	VARCHAR2 DEFAULT null
  ,p_org_information3		IN	VARCHAR2 DEFAULT null
  ,p_org_information4		IN	VARCHAR2 DEFAULT null
  ,p_org_information5		IN	VARCHAR2 DEFAULT null
  ,p_org_information6		IN	VARCHAR2 DEFAULT null
  ,p_org_information7		IN	VARCHAR2 DEFAULT null
  ,p_org_information8		IN	VARCHAR2 DEFAULT null
  ,p_org_information9		IN	VARCHAR2 DEFAULT null
  ) IS
	l_length					NUMBER;
	l_pipn_length					NUMBER ;

	l_last_two_digits				VARCHAR2(2);
	l_eleventh_digit				VARCHAR2(1) ;
	l_calculated_eleventh_digit			VARCHAR2(1);
	l_warning					VARCHAR2(50);
	l_return					VARCHAR2(50);
	l_field						VARCHAR2(300) := NULL;

	l_business_group_id				hr_organization_units.business_group_id%TYPE;
	l_org_information1				hr_organization_information.org_information1%TYPE;
	l_pension_type					hr_organization_information.org_information1%TYPE;
	l_pension_grp					hr_organization_information.org_information1%TYPE;

	l_session_date					DATE ;
	l_count						NUMBER ;

	INVALID_POLICY_NUMBER_FORMAT			EXCEPTION;
	INVALID_Y_NUMBER_FORMAT				EXCEPTION;
	INVALID_PP_CUSTOMER_NUM_FORMAT			EXCEPTION;
/*	INVALID_PIP_NUMBER_FORMAT			EXCEPTION;*/
	UNIQUE_LOCAL_UNITS				EXCEPTION;
	UNIQUE_Y_NUMBER					EXCEPTION;
	UNIQUE_DEPT_CODE 				EXCEPTION;
	UNIQUE_GROUP_CODE 				EXCEPTION;
	UNIQUE_PENSION_TYPE 				EXCEPTION;
	UNIQUE_PENSION_INS_NUM 				EXCEPTION;
	UNIQUE_LU_PENSION_INS_NUM 			EXCEPTION;
	UNIQUE_LE_LC						EXCEPTION;
	UNIQUE_LE_AP					EXCEPTION;
	UNIQUE_LU_AP					EXCEPTION;
	INVALID_DATE					EXCEPTION;
	INVALID_TYEL_GROUP				EXCEPTION;
	UNIQUE_PENSION_USER_PT EXCEPTION;
	UNIQUE_PG_DTLS_PG EXCEPTION;



CURSOR  getbgid
IS
	SELECT 	 business_group_id
	FROM 	 hr_organization_units
	WHERE 	 organization_id = p_organization_id;

CURSOR  orglocalunit
IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_units o , hr_organization_information hoi ,fnd_sessions s
	WHERE 	o.organization_id = hoi.organization_id
	AND 	hoi.org_information_context = 'CLASS'
	AND 	hoi.org_information1 = 'FI_LOCAL_UNIT'
	AND	o.business_group_id = l_business_group_id
	AND  TO_CHAR(o.organization_id) IN
			(
			SELECT	hoinf.org_information1
			FROM	hr_organization_units org, hr_organization_information hoinf , fnd_sessions s
			WHERE	org.business_group_id = l_business_group_id
			AND	org.organization_id = hoinf.organization_id
			AND	hoinf.org_information_context = 'FI_LOCAL_UNITS'
			AND 	s.session_id = userenv('sessionid')
			AND 	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
			)
	AND 	s.session_id = userenv('sessionid')
	AND 	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
	AND	o.organization_id = p_org_information1;


CURSOR getynumber
IS
	SELECT  count(*)
	FROM	hr_organization_information hoi, hr_organization_units ou ,fnd_sessions s
	WHERE	(hoi.org_information_context = 'FI_LEGAL_EMPLOYER_DETAILS' or
		 hoi.org_information_context = 'FI_EXTERNAL_COMPANY_DETAILS')
	AND	ou.organization_id = hoi.organization_id
	AND	ou.organization_id <> nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1  = p_org_information1 ;

CURSOR c_ins_group_code IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_TYPES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2;

CURSOR c_ins_tyel_pt IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_TYPES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
       AND 	hoi.org_information2 IS null
       AND 	hoi.org_information3 IS null;


CURSOR c_ins_dept_code IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_DEPARTMENT_CODES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information3 =  p_org_information3
	AND	hoi.org_information1 =  p_org_information1;

CURSOR c_ins_le_lc IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_DEPARTMENT_CODES')
	AND 	ou.organization_id = hoi.organization_id
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2 ;


CURSOR c_ins_pp_ins_num IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information6 =  p_org_information6 ;


CURSOR c_ins_lu_pp_ins_num IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_LU_PENSION_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1 ;


CURSOR c_ins_le_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_ACCIDENT_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information1) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information1) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY'))));

CURSOR c_ins_lu_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_LU_ACCIDENT_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information1) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information1) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY'))));

CURSOR c_ins_pp_user_pt	IS
	SELECT COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	trim(hoi.org_information9) =  trim(p_org_information9) ;


CURSOR c_pg_dtls_pg IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_GROUP_DETAILS')
	AND 	ou.organization_id = hoi.organization_id
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2 ;


 BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
       --

	OPEN 	getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE 	getbgid;

	IF   p_org_info_type_code = 'FI_LOCAL_UNITS'
	THEN
		OPEN orglocalunit;
			FETCH  orglocalunit INTO l_count;
		CLOSE orglocalunit;
		IF l_count > 0
		THEN
			RAISE UNIQUE_LOCAL_UNITS ;
		END IF ;


	END IF ;
	IF p_org_info_type_code = 'FI_LOCAL_UNIT_DETAILS'
	THEN  -- LOCAL_UNIT_DETAILS

		validate_number(p_org_information1,hr_general.decode_lookup('FI_FORM_LABELS','SUB_DISBURSEMENT'));
		validate_number(p_org_information2,hr_general.decode_lookup('FI_FORM_LABELS','LOCAL_UNIT_NUMBER'));
		validate_number(p_org_information4,hr_general.decode_lookup('FI_FORM_LABELS','EMP_ORG_MEMBERSHIP'));

	END IF ; -- end of LOCAL_UNIT_DETAILS
--------------------------- Y-Number Unique Bug ----------------------------

	IF p_org_info_type_code = 'FI_EXTERNAL_COMPANY_DETAILS'
	THEN
		--              For Y-Number			--
		IF p_org_information1 IS NOT NULL
		THEN


		OPEN getynumber;
			FETCH  getynumber INTO l_count;
		CLOSE getynumber;
		IF l_count > 0
		THEN
			RAISE UNIQUE_Y_NUMBER ;
		END IF ;

			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE  INVALID_Y_NUMBER_FORMAT;
			END IF ; -- end of  length
		END IF;
		--              End Of For Y-Number		--
	END IF;
--------------------------- Y-Number Unique Bug ----------------------------

	IF p_org_info_type_code = 'FI_LEGAL_EMPLOYER_DETAILS'
	THEN  -- LEGAL_EMPLOYER_DETAILS
		--              For Y-Number			--
	IF p_org_information1 IS NOT NULL
		THEN
		OPEN getynumber;
			FETCH  getynumber INTO l_count;
		CLOSE getynumber;
		IF l_count > 0
		THEN
			RAISE UNIQUE_Y_NUMBER ;
		END IF ;

			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE  INVALID_Y_NUMBER_FORMAT;
			END IF ; -- end of  length
		END IF;
		--              End Of For Y-Number		--

	-- 3900118 To validate whole number
		validate_number(p_org_information6,hr_general.decode_lookup('FI_FORM_LABELS','EMP_ORG_MEMBERSHIP'));
	-- 3900118 To validate whole number



	END IF ;  -- end of LEGAL_EMPLOYER_DETAILS

	IF p_org_info_type_code = 'FI_EXTERNAL_COMPANY_DETAILS'
	THEN  -- FI_EXTERNAL_COMPANY_DETAILS
		--              For Y-Number			--
		IF p_org_information1 IS NOT NULL THEN
			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE INVALID_Y_NUMBER_FORMAT;
			END IF ;
		END IF;
		--              End Of For Y-Number		--
		--              For PIN			--
		IF p_org_information2 IS NOT NULL
		THEN
			BEGIN
				select EFFECTIVE_DATE into l_session_date from fnd_sessions where SESSION_ID = userenv('SESSIONID');
				l_return := hr_ni_chk_pkg.validate_national_identifier(p_org_information2,null,null,'WHEN-VALIDATE-RECORD',null,l_business_group_id,'FI',l_session_date,l_warning,null,null,null);
			EXCEPTION
				WHEN OTHERS
				THEN
				fnd_message.set_name('PAY', 'HR_FI_INVALID_NATIONAL_ID');
				hr_utility.raise_error;
			END ;
		END IF;
		--              End Of PIN		--
	END IF ; -- end of FI_EXTERNAL_COMPANY_DETAILS

	IF p_org_info_type_code = 'FI_PENSION_TYPES'
		THEN  -- FI_PENSION_TYPES


			IF p_org_information1 ='TYEL' THEN

				IF (( p_org_information2 IS NULL AND p_org_information3 IS NOT NULL )
				OR
				( p_org_information2 IS NOT NULL AND p_org_information3 IS NULL ))
				THEN

					RAISE INVALID_TYEL_GROUP	;
					-- Group Code
					validate_number(p_org_information2,hr_general.decode_lookup('FI_FORM_LABELS','GROUP_CODE'),'HR_376633_FI_WHOLE_NUMBER');


				END IF;

				IF ( p_org_information2 IS NULL AND p_org_information3 IS NULL )
				THEN

					OPEN  c_ins_tyel_pt;
					FETCH   c_ins_tyel_pt INTO l_count;
					CLOSE  c_ins_tyel_pt;
					IF l_count > 0	THEN
						RAISE UNIQUE_PENSION_TYPE ;
					END IF ;

				END IF;


					IF ( p_org_information2 IS NOT NULL  )
					THEN

					OPEN c_ins_group_code;
					FETCH  c_ins_group_code INTO l_count;
					CLOSE c_ins_group_code;
					IF l_count > 0	THEN
						RAISE UNIQUE_GROUP_CODE ;
					END IF ;

					END IF;


			END IF;

	END IF;

	IF p_org_info_type_code = 'FI_PENSION_DEPARTMENT_CODES'
		THEN  -- FI_PENSION_DEPARTMENT_CODES
			-- Department Code
			validate_number(p_org_information3,hr_general.decode_lookup('FI_FORM_LABELS','DEPARTMENT_CODE'),'HR_376633_FI_WHOLE_NUMBER');

			OPEN c_ins_dept_code;
			FETCH  c_ins_dept_code INTO l_count;
			CLOSE c_ins_dept_code;
			IF l_count > 0	THEN
				RAISE UNIQUE_DEPT_CODE ;
			END IF ;

			OPEN c_ins_le_lc;
			FETCH  c_ins_le_lc INTO l_count;
			CLOSE c_ins_le_lc;
			IF l_count > 0	THEN
				RAISE UNIQUE_LE_LC ;
			END IF ;

	END IF;

	IF p_org_info_type_code = 'FI_PENSION_GROUP_DETAILS' 	THEN

		OPEN c_pg_dtls_pg;
		FETCH  c_pg_dtls_pg INTO l_count;
		CLOSE c_pg_dtls_pg;
		IF l_count > 0	THEN
			RAISE UNIQUE_PG_DTLS_PG ;
		END IF ;

	END IF;


	IF p_org_info_type_code = 'FI_PENSION_PROVIDERS' THEN


			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;

			--              For Pension Provider Customer number		--
			IF p_org_information8 IS NOT NULL
			THEN
				IF (  (LENGTH(p_org_information8) =11) AND (SUBSTR(p_org_information8,9,1)='-')     )
				THEN -- length
					IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information8,'DDDDDDDD-DD')='0'
					THEN
						RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
					ELSE
						l_last_two_digits := substr(p_org_information8,10,2);
						IF l_last_two_digits <> '00'
						THEN
							RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
						END IF;
					END IF ;
				ELSE
					RAISE  INVALID_PP_CUSTOMER_NUM_FORMAT;
				END IF ; -- end of  length
			END IF;
			--              End Of For Pension Provider Customer number	--

		OPEN c_ins_pp_ins_num;
		FETCH  c_ins_pp_ins_num INTO l_count;
		CLOSE c_ins_pp_ins_num;
		IF l_count > 0	THEN
			RAISE UNIQUE_PENSION_INS_NUM ;
		END IF ;

		OPEN c_ins_pp_user_pt;
		FETCH  c_ins_pp_user_pt INTO l_count;
		CLOSE c_ins_pp_user_pt;
		IF l_count > 0	THEN
			RAISE UNIQUE_PENSION_USER_PT ;
		END IF ;


		--		Pension Insurance Policy Number			--
/* Commented for FI leg changes 2008 - bug fix 7600677
		IF p_org_information6 IS NOT NULL
		THEN
			l_pipn_length := LENGTH (p_org_information6);
			IF SUBSTR(p_org_information6,3,1) = '-'
			THEN  -- FIRST FORMAT NN-NNNNNNNT
				IF(   (l_pipn_length >=8) AND   (l_pipn_length <=11)  )
				THEN  -- Length between 8 to 11
					IF l_pipn_length = 8
					THEN		   --   46-1234M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF  l_pipn_length = 9
					THEN		   --   46-12345M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;

					ELSIF l_pipn_length = 10
					THEN		   --     46-123456M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;

					ELSIF l_pipn_length = 11
					THEN		   --    46-1234567M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
							END IF;
						END IF;


				ELSE	-- length less than 8 or greater than 11 wrong format
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF; -- end of -- Length between 8 to 11
			ELSE
				IF SUBSTR(p_org_information6,5,1) = '-'
				THEN  -- SECOND FORMAT  NNNN-NNNNT
					IF l_pipn_length = 10
					THEN		   --    1234-5678M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DDDD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSE
						RAISE INVALID_PIP_NUMBER_FORMAT;
					END IF;
				ELSE  -- Wrong format so raise error
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF ;
			END IF;  -- end of format check
		END IF ;	*/

		--		End Of Pension Insurance Policy Number		--


	END IF;


	IF p_org_info_type_code = 'FI_LU_PENSION_PROVIDERS' THEN

		OPEN c_ins_lu_pp_ins_num;
		FETCH  c_ins_lu_pp_ins_num INTO l_count;
		CLOSE c_ins_lu_pp_ins_num;
		IF l_count > 0	THEN
			RAISE UNIQUE_LU_PENSION_INS_NUM ;
		END IF ;

	--		Pension Insurance Policy Number			--
/* Commenting for FI leg changes 2008 - bug fix 7600677
		IF p_org_information1 IS NOT NULL
		THEN
			l_pipn_length := LENGTH (p_org_information1);
			IF SUBSTR(p_org_information1,3,1) = '-'
			THEN  -- FIRST FORMAT NN-NNNNNNNT
				IF(   (l_pipn_length >=8) AND   (l_pipn_length <=11)  )
				THEN  -- Length between 8 to 11
					IF l_pipn_length = 8
					THEN		   --   46-1234M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF  l_pipn_length = 9
					THEN		   --   46-12345M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 10
					THEN		   --     46-123456M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 11
					THEN		   --    46-1234567M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					END IF;
				ELSE	-- length less than 8 or greater than 11 wrong format
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF; -- end of -- Length between 8 to 11
			ELSE
				IF SUBSTR(p_org_information1,5,1) = '-'
				THEN  -- SECOND FORMAT  NNNN-NNNNT
					IF l_pipn_length = 10
					THEN		   --    1234-5678M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSE
						RAISE INVALID_PIP_NUMBER_FORMAT;
					END IF;
				ELSE   -- Wrong format so raise error
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF ;
			END IF;  -- end of format check
		END IF ; */
	--		End Of Pension Insurance Policy Number

	--              For Pension Provider Customer number		--
			IF p_org_information2 IS NOT NULL
			THEN
				IF (  (LENGTH(p_org_information2) =11) AND (SUBSTR(p_org_information2,9,1)='-')     )
				THEN -- length
					IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information2,'DDDDDDDD-DD')='0'
					THEN
						RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
					ELSE
						l_last_two_digits := substr(p_org_information2,10,2);
						IF l_last_two_digits <> '00'
						THEN
							RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
						END IF;
					END IF ;
				ELSE
					RAISE  INVALID_PP_CUSTOMER_NUM_FORMAT;
				END IF ; -- end of  length
			END IF;
			--              End Of For Pension Provider Customer number	--


	END IF;


	IF p_org_info_type_code = 'FI_ACCIDENT_PROVIDERS' THEN

			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;



			OPEN  c_ins_le_ap_dtls ;
			FETCH   c_ins_le_ap_dtls  INTO l_count;
			CLOSE  c_ins_le_ap_dtls ;
			IF l_count > 0	THEN
				RAISE UNIQUE_LE_AP ;
			END IF ;
              /* Commenting the validation for Accident Insurance Policy Number for  Enhancement 2008-2009 */
	      /* Please refer Bug 8425533 for further details    */

		/*	--              For Accident Insurance Policy Number		--

		IF p_org_information4 IS NOT NULL
		THEN
			IF (  (LENGTH(p_org_information4) =13) AND (SUBSTR(p_org_information4,4,1)='-')  AND   (SUBSTR(p_org_information4,12,1)='-')   )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information4,'DDD-DDDDDDD-X')='0'
				THEN
					RAISE  INVALID_POLICY_NUMBER_FORMAT;
				END IF;
			ELSE
				RAISE  INVALID_POLICY_NUMBER_FORMAT;
			END IF ;
		END IF;
		--              End Of  Accident Insurance Policy Number	--

            */
	END IF;

	IF p_org_info_type_code = 'FI_LU_ACCIDENT_PROVIDERS' THEN

			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;

			OPEN  c_ins_lu_ap_dtls ;
			FETCH   c_ins_lu_ap_dtls  INTO l_count;
			CLOSE  c_ins_lu_ap_dtls ;
			IF l_count > 0	THEN
				RAISE UNIQUE_LU_AP ;
			END IF ;

	     /* Commenting the validation for Accident Insurance Policy Number for  Enhancement 2008-2009 */
	      /* Please refer Bug 8425533 for further details    */

			--              For Accident Insurance Policy Number		--
	    /*

		IF p_org_information3 IS NOT NULL
		THEN
			IF (  (LENGTH(p_org_information3) =13) AND (SUBSTR(p_org_information3,4,1)='-')  AND   (SUBSTR(p_org_information3,12,1)='-')   )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information3,'DDD-DDDDDDD-X')='0'
				THEN
					RAISE  INVALID_POLICY_NUMBER_FORMAT;
				END IF;
			ELSE
				RAISE  INVALID_POLICY_NUMBER_FORMAT;
			END IF ;
		END IF;
		--              End Of  Accident Insurance Policy Number	--

		*/


	END IF;
  END IF;


EXCEPTION
		WHEN INVALID_POLICY_NUMBER_FORMAT
		THEN

			l_field := hr_general.decode_lookup('FI_FORM_LABELS','ACC_INS_POLICY');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

		WHEN INVALID_Y_NUMBER_FORMAT
		THEN

			l_field := hr_general.decode_lookup('FI_FORM_LABELS','Y_NUMBER');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

		WHEN INVALID_PP_CUSTOMER_NUM_FORMAT
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','PEN_PROV_CUST');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

/*		WHEN INVALID_PIP_NUMBER_FORMAT - bug fix 7600677
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','PEN_INS_POLICY');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;*/

		WHEN UNIQUE_LOCAL_UNITS
		THEN

			fnd_message.set_name('PER', 'HR_376614_FI_UNIQUE_LOCAL_UNIT');
		        hr_utility.raise_error;

		WHEN UNIQUE_Y_NUMBER
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','Y_NUMBER');
			fnd_message.set_name('PER', 'HR_376613_FI_UNIQUE_MSG');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;
		WHEN UNIQUE_DEPT_CODE
		THEN

			fnd_message.set_name('PAY', 'HR_376630_FI_UNIQUE_DEPT_CODE');
		        hr_utility.raise_error;

		WHEN UNIQUE_GROUP_CODE
		THEN

			fnd_message.set_name('PAY', 'HR_376632_FI_UNIQUE_GROUP_CODE');
		        hr_utility.raise_error;

		WHEN UNIQUE_PENSION_TYPE
		THEN

			fnd_message.set_name('PAY', 'HR_376647_FI_UNIQ_PENSION_TYPE');
		        hr_utility.raise_error;

		WHEN UNIQUE_LE_LC
		THEN

			fnd_message.set_name('PAY', 'HR_376631_FI_UNIQUE_LE_LC');
		        hr_utility.raise_error;


		WHEN UNIQUE_LE_AP
		THEN

			fnd_message.set_name('PAY', 'HR_376638_FI_UNIQUE_ACC_PROV');
		        hr_utility.raise_error;
		WHEN UNIQUE_LU_AP
		THEN

			fnd_message.set_name('PAY', 'HR_376645_FI_LU_UNIQ_ACC_PROV');
		        hr_utility.raise_error;
		WHEN INVALID_DATE
		THEN

			fnd_message.set_name('PAY', 'HR_376639_FI_VALID_DATE');
		        hr_utility.raise_error;

		WHEN INVALID_TYEL_GROUP
		THEN

			fnd_message.set_name('PAY', 'HR_376648_FI_TEL_GROUP_DTLS');
		        hr_utility.raise_error;

		WHEN UNIQUE_PENSION_INS_NUM
		THEN
			fnd_message.set_name('PAY', 'HR_376650_FI_UNIQ_PEN_INS_NUM');
		        hr_utility.raise_error;

		WHEN UNIQUE_LU_PENSION_INS_NUM
		THEN
			fnd_message.set_name('PAY', 'HR_376651_FI_LU_PEN_INS_NUM');
		        hr_utility.raise_error;

		WHEN UNIQUE_PG_DTLS_PG
		THEN
			fnd_message.set_name('PAY', 'HR_376649_FI_LEL_TAEL_GROUP');
		        hr_utility.raise_error;

		WHEN UNIQUE_PENSION_USER_PT
		THEN
			fnd_message.set_name('PAY', 'HR_376654_FI_LE_TEL_GROUP_DTLS');
		        hr_utility.raise_error;


 END validate_create_org_inf;

--___________________________________________END OF VALIDATE_CREATE_ORG_INF_____________________________________________

 PROCEDURE validate_update_org_inf
  (p_effective_date             IN	DATE
  ,p_org_info_type_code		IN	VARCHAR2
  ,p_org_information_id		IN 	NUMBER
  ,p_org_information1		IN	VARCHAR2 DEFAULT null
  ,p_org_information2		IN	VARCHAR2 DEFAULT null
  ,p_org_information3		IN	VARCHAR2 DEFAULT null
  ,p_org_information4		IN	VARCHAR2 DEFAULT null
  ,p_org_information5		IN	VARCHAR2 DEFAULT null
  ,p_org_information6		IN	VARCHAR2 DEFAULT null
  ,p_org_information7		IN	VARCHAR2 DEFAULT null
  ,p_org_information8		IN	VARCHAR2 DEFAULT null
  ,p_org_information9		IN	VARCHAR2 DEFAULT null
  ) IS

	l_length					NUMBER ;
	l_pipn_length					NUMBER ;
	l_count						NUMBER ;

	l_last_two_digits				VARCHAR2(2);
	l_eleventh_digit				VARCHAR2(1) ;
	l_calculated_eleventh_digit			VARCHAR2(1);
	l_warning					VARCHAR2(50);
	l_return					VARCHAR2(50);
	l_field						VARCHAR2(300) := NULL;


	l_business_group_id				hr_organization_units.business_group_id%TYPE;
	l_organization_id				hr_organization_information.organization_id%TYPE;
	l_org_information1				hr_organization_information.org_information1%TYPE;
	l_pension_type					hr_organization_information.org_information1%TYPE;
	l_pension_grp					hr_organization_information.org_information1%TYPE;

	l_session_date					DATE ;

	INVALID_POLICY_NUMBER_FORMAT			EXCEPTION;
	INVALID_Y_NUMBER_FORMAT				EXCEPTION;
	INVALID_PP_CUSTOMER_NUM_FORMAT			EXCEPTION;
/*	INVALID_PIP_NUMBER_FORMAT			EXCEPTION; */
	UNIQUE_LOCAL_UNITS				EXCEPTION;
	UNIQUE_Y_NUMBER					EXCEPTION;
	UNIQUE_DEPT_CODE 				EXCEPTION;
	UNIQUE_GROUP_CODE 				EXCEPTION;
	UNIQUE_PENSION_TYPE 				EXCEPTION;
	UNIQUE_PENSION_INS_NUM 				EXCEPTION;
	UNIQUE_LU_PENSION_INS_NUM 			EXCEPTION;
	UNIQUE_LE_LC						EXCEPTION;
	UNIQUE_LE_AP					EXCEPTION;
	UNIQUE_LU_AP					EXCEPTION;
	INVALID_DATE					EXCEPTION;
	INVALID_TYEL_GROUP				EXCEPTION;
	UNIQUE_PENSION_USER_PT EXCEPTION;
	UNIQUE_PG_DTLS_PG EXCEPTION;

CURSOR	getbgid
IS
	SELECT	business_group_id
	FROM	hr_organization_units
	where	organization_id = l_organization_id;

CURSOR	getorgid
IS
	SELECT	organization_id
	FROM 	hr_organization_information
	WHERE 	org_information_id = p_org_information_id;

CURSOR	orglocalunit
IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_units o , hr_organization_information hoi  ,fnd_sessions s
	WHERE 	o.organization_id = hoi.organization_id
	AND 	hoi.org_information_context = 'CLASS'
	AND 	hoi.org_information1 = 'FI_LOCAL_UNIT'
	AND	o.business_group_id = l_business_group_id
	AND 	TO_CHAR(o.organization_id) IN
				(
				SELECT	hoinf.org_information1
				FROM	hr_organization_units org, hr_organization_information hoinf ,fnd_sessions s
				WHERE	org.business_group_id = l_business_group_id
				AND	org.organization_id = hoinf.organization_id
				AND	org.organization_id <> l_organization_id
				AND	hoinf.org_information_context = 'FI_LOCAL_UNITS'
				AND 	s.session_id = userenv('sessionid')
				AND 	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
				)
	AND	s.session_id = userenv('sessionid')
	AND	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
	AND	o.organization_id = p_org_information1;

CURSOR getynumber
IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_LEGAL_EMPLOYER_DETAILS' or
		 hoi.org_information_context = 'FI_EXTERNAL_COMPANY_DETAILS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id <> nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1  = p_org_information1 ;

CURSOR c_upd_group_code IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_TYPES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2
	AND	hoi.org_information_id <> p_org_information_id	;

	CURSOR c_upd_tyel_pt  IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_TYPES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information_id <> p_org_information_id
	AND        hoi.org_information2 IS NULL
	AND        hoi.org_information3 IS NULL;

CURSOR c_upd_dept_code IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_DEPARTMENT_CODES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information3 =  p_org_information3
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information_id <> p_org_information_id	;

CURSOR c_upd_le_lc IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_DEPARTMENT_CODES')
	AND 	ou.organization_id = hoi.organization_id
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2
	AND	hoi.org_information_id <> p_org_information_id	;

CURSOR c_upd_pp_ins_num IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_PROVIDERS')
	AND	ou.business_group_id = l_business_group_id
	AND 	ou.organization_id = hoi.organization_id
	AND	hoi.org_information6 =  p_org_information6
	AND	hoi.org_information_id <> p_org_information_id	;

	CURSOR  c_upd_pp_user_pt IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_PROVIDERS')
	AND	ou.business_group_id = l_business_group_id
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	trim(hoi.org_information9) =  trim(p_org_information9)
	AND	hoi.org_information_id <> p_org_information_id	;


CURSOR  c_upd_lu_pp_ins_num IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_LU_PENSION_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information_id <> p_org_information_id	;


CURSOR c_upd_le_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_ACCIDENT_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information1) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information1) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY'))))
	AND	hoi.org_information_id <> p_org_information_id	;

CURSOR c_upd_lu_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_LU_ACCIDENT_PROVIDERS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information1) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information1) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information1) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information1) AND
	nvl(fnd_date.canonical_to_date(p_org_information2),to_date('31/12/4712','DD/MM/YYYY'))))
	AND	hoi.org_information_id <> p_org_information_id	;




CURSOR c_upd_pg_dtls_pg IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_organization_units ou
	WHERE 	(hoi.org_information_context = 'FI_PENSION_GROUP_DETAILS')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	hoi.org_information1 =  p_org_information1
	AND	hoi.org_information2 =  p_org_information2
	AND	hoi.org_information_id <> p_org_information_id	;

 BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
       --
	OPEN	getorgid;
		FETCH  getorgid INTO  l_organization_id;
	CLOSE	getorgid;

	OPEN 	getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE 	getbgid;

	IF   p_org_info_type_code = 'FI_LOCAL_UNITS'
	THEN
		OPEN orglocalunit;
			FETCH  orglocalunit INTO l_count;
		CLOSE orglocalunit;
		IF l_count > 0
		THEN
			fnd_message.set_name('PER', 'Update');
		        hr_utility.raise_error;

			RAISE UNIQUE_LOCAL_UNITS ;
		END IF ;

	END IF;
--------------------------- Y-Number Unique Bug ----------------------------

	IF p_org_info_type_code = 'FI_EXTERNAL_COMPANY_DETAILS'
	THEN
		--              For Y-Number			--
		IF p_org_information1 IS NOT NULL
		THEN
		OPEN getynumber;
			FETCH  getynumber INTO l_count;
		CLOSE getynumber;
		IF l_count > 0
		THEN
			RAISE UNIQUE_Y_NUMBER ;
		END IF ;

			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE  INVALID_Y_NUMBER_FORMAT;
			END IF ; -- end of  length
		END IF;
	--              End Of For Y-Number		--

	END IF;
--------------------------- Y-Number Unique Bug ----------------------------

	IF p_org_info_type_code = 'FI_LOCAL_UNIT_DETAILS'
	THEN  -- LOCAL_UNIT_DETAILS

		validate_number(p_org_information1,hr_general.decode_lookup('FI_FORM_LABELS','SUB_DISBURSEMENT'));
		validate_number(p_org_information2,hr_general.decode_lookup('FI_FORM_LABELS','LOCAL_UNIT_NUMBER'));
		validate_number(p_org_information4,hr_general.decode_lookup('FI_FORM_LABELS','EMP_ORG_MEMBERSHIP'));


	END IF ; -- end of LOCAL_UNIT_DETAILS

	IF p_org_info_type_code = 'FI_LEGAL_EMPLOYER_DETAILS'
	THEN  -- LEGAL_EMPLOYER_DETAILS

	--              For Y-Number			--
		IF p_org_information1 IS NOT NULL
		THEN
		OPEN getynumber;
			FETCH  getynumber INTO l_count;
		CLOSE getynumber;
		IF l_count > 0
		THEN
			RAISE UNIQUE_Y_NUMBER ;
		END IF ;

			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE  INVALID_Y_NUMBER_FORMAT;
			END IF ; -- end of  length
		END IF;
	--              End Of For Y-Number		--
		--
	-- 3900118 To validate whole number
		validate_number(p_org_information6,hr_general.decode_lookup('FI_FORM_LABELS','EMP_ORG_MEMBERSHIP'));
	-- 3900118 To validate whole number

	END IF ;  -- end of LEGAL_EMPLOYER_DETAILS

	IF p_org_info_type_code = 'FI_EXTERNAL_COMPANY_DETAILS'
	THEN  -- FI_EXTERNAL_COMPANY_DETAILS

	--              For Y-Number			--
		IF p_org_information1 IS NOT NULL
		THEN
			IF (  (LENGTH(p_org_information1) =9) AND (SUBSTR(p_org_information1,8,1)='-')     )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDDDDD-X')='0'
				THEN
					RAISE INVALID_Y_NUMBER_FORMAT;
				END IF ;
			ELSE
				RAISE INVALID_Y_NUMBER_FORMAT;
			END IF ;
		END IF;
	--              End Of For Y-Number		--

	--              For PIN			--

		IF p_org_information2 IS NOT NULL
		THEN
			BEGIN
				SELECT  EFFECTIVE_DATE INTO  l_session_date FROM  fnd_sessions WHERE  SESSION_ID = userenv('SESSIONID');
				l_return :=hr_ni_chk_pkg.validate_national_identifier(p_org_information2,null,null,'WHEN-VALIDATE-RECORD',null,l_business_group_id,'FI',l_session_date,l_warning,null,null,null);
			EXCEPTION
				WHEN OTHERS
				THEN
					fnd_message.set_name('PAY', 'HR_FI_INVALID_NATIONAL_ID');
					hr_utility.raise_error;
			END ;
		END IF;
	--              End Of PIN		--
	END IF; -- end of FI_EXTERNAL_COMPANY_DETAILS

	IF p_org_info_type_code = 'FI_PENSION_TYPES'
		THEN  -- FI_PENSION_TYPES


			IF p_org_information1='TYEL' THEN

				IF (( p_org_information2 IS NULL AND p_org_information3 IS NOT NULL )
				OR
				( p_org_information2 IS NOT NULL AND p_org_information3 IS NULL ))
				THEN

					RAISE INVALID_TYEL_GROUP	;
					-- Group Code
					validate_number(p_org_information2,hr_general.decode_lookup('FI_FORM_LABELS','GROUP_CODE'),'HR_376633_FI_WHOLE_NUMBER');


				END IF;

				IF ( p_org_information2 IS NULL AND p_org_information3 IS NULL )
				THEN

					OPEN  c_upd_tyel_pt;
					FETCH   c_upd_tyel_pt INTO l_count;
					CLOSE  c_upd_tyel_pt;
					IF l_count > 0	THEN
						RAISE UNIQUE_PENSION_TYPE ;
					END IF ;


				END IF;

				IF ( p_org_information2 IS NOT NULL  )
					THEN

					OPEN c_upd_group_code;
					FETCH  c_upd_group_code INTO l_count;
					CLOSE c_upd_group_code;
					IF l_count > 0	THEN
						RAISE UNIQUE_GROUP_CODE ;
					END IF ;

				END IF;


			END IF;

	END IF;

	IF p_org_info_type_code = 'FI_PENSION_DEPARTMENT_CODES'
		THEN  -- FI_PENSION_DEPARTMENT_CODES
		IF p_org_information3 IS NOT NULL THEN
			-- Department Code
			validate_number(p_org_information3,hr_general.decode_lookup('FI_FORM_LABELS','DEPARTMENT_CODE'),'HR_376633_FI_WHOLE_NUMBER');

			OPEN c_upd_dept_code;
			FETCH  c_upd_dept_code INTO l_count;
			CLOSE c_upd_dept_code;
			IF l_count > 0	THEN
				RAISE UNIQUE_DEPT_CODE ;
			END IF ;

			OPEN c_upd_le_lc;
			FETCH  c_upd_le_lc INTO l_count;
			CLOSE c_upd_le_lc;
			IF l_count > 0	THEN
				RAISE UNIQUE_LE_LC ;
			END IF ;


		END IF;
	END IF;


	IF p_org_info_type_code = 'FI_PENSION_GROUP_DETAILS' 	THEN

		OPEN c_upd_pg_dtls_pg;
		FETCH  c_upd_pg_dtls_pg INTO l_count;
		CLOSE c_upd_pg_dtls_pg;
		IF l_count > 0	THEN
			RAISE UNIQUE_PG_DTLS_PG ;
		END IF ;

	END IF;


	IF p_org_info_type_code = 'FI_PENSION_PROVIDERS' THEN


			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;



			--              For Pension Provider Customer number		--
			IF p_org_information8 IS NOT NULL
			THEN
				IF (  (LENGTH(p_org_information8) =11) AND (SUBSTR(p_org_information8,9,1)='-')     )
				THEN -- length
					IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information8,'DDDDDDDD-DD')='0'
					THEN
						RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
					ELSE
						l_last_two_digits := substr(p_org_information8,10,2);
						IF l_last_two_digits <> '00'
						THEN
							RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
						END IF;
					END IF ;
				ELSE
					RAISE  INVALID_PP_CUSTOMER_NUM_FORMAT;
				END IF ; -- end of  length
			END IF;
			--              End Of For Pension Provider Customer number	--



		OPEN c_upd_pp_ins_num;
		FETCH  c_upd_pp_ins_num INTO l_count;
		CLOSE c_upd_pp_ins_num;
		IF l_count > 0	THEN
			RAISE UNIQUE_PENSION_INS_NUM ;
		END IF ;

		OPEN c_upd_pp_user_pt;
		FETCH  c_upd_pp_user_pt INTO l_count;
		CLOSE c_upd_pp_user_pt;
		IF l_count > 0	THEN
			RAISE UNIQUE_PENSION_USER_PT ;
		END IF ;



	--		Pension Insurance Policy Number			--
/* Bug fix 7600677
		IF p_org_information6 IS NOT NULL
		THEN
			l_pipn_length := LENGTH (p_org_information6);
			IF SUBSTR(p_org_information6,3,1) = '-'
			THEN  -- FIRST FORMAT NN-NNNNNNNT
				IF(   (l_pipn_length >=8) AND   (l_pipn_length <=11)  )
				THEN  -- Length between 8 to 11
					IF l_pipn_length = 8
					THEN		   --   46-1234M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF  l_pipn_length = 9
					THEN		   --   46-12345M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 10
					THEN		   --     46-123456M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 11
					THEN		   --    46-1234567M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DD-DDDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					END IF;
				ELSE	-- length less than 8 or greater than 11 wrong format
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF; -- end of -- Length between 8 to 11
			ELSE
				IF SUBSTR(p_org_information6,5,1) = '-'
				THEN  -- SECOND FORMAT  NNNN-NNNNT
					IF l_pipn_length = 10
					THEN		   --    1234-5678M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information6,'DDDD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSE
						RAISE INVALID_PIP_NUMBER_FORMAT;
					END IF;
				ELSE   -- Wrong format so raise error
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF ;
			END IF;  -- end of format check
		END IF ; */
	--		End Of Pension Insurance Policy Number

	END IF;

	IF p_org_info_type_code = 'FI_LU_PENSION_PROVIDERS' THEN

		OPEN c_upd_lu_pp_ins_num;
		FETCH  c_upd_lu_pp_ins_num INTO l_count;
		CLOSE c_upd_lu_pp_ins_num;

		IF l_count > 0	THEN
			RAISE UNIQUE_LU_PENSION_INS_NUM ;
		END IF ;

	--		Pension Insurance Policy Number			--
/* Bug fix - 7600677
		IF p_org_information1 IS NOT NULL
		THEN
			l_pipn_length := LENGTH (p_org_information1);
			IF SUBSTR(p_org_information1,3,1) = '-'
			THEN  -- FIRST FORMAT NN-NNNNNNNT
				IF(   (l_pipn_length >=8) AND   (l_pipn_length <=11)  )
				THEN  -- Length between 8 to 11
					IF l_pipn_length = 8
					THEN		   --   46-1234M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF  l_pipn_length = 9
					THEN		   --   46-12345M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 10
					THEN		   --     46-123456M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSIF l_pipn_length = 11
					THEN		   --    46-1234567M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DD-DDDDDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					END IF;
				ELSE	-- length less than 8 or greater than 11 wrong format
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF; -- end of -- Length between 8 to 11
			ELSE
				IF SUBSTR(p_org_information1,5,1) = '-'
				THEN  -- SECOND FORMAT  NNNN-NNNNT
					IF l_pipn_length = 10
					THEN		   --    1234-5678M
						IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information1,'DDDD-DDDDX')='0'
						THEN
							RAISE  INVALID_PIP_NUMBER_FORMAT;
						END IF;
					ELSE
						RAISE INVALID_PIP_NUMBER_FORMAT;
					END IF;
				ELSE   -- Wrong format so raise error
					RAISE INVALID_PIP_NUMBER_FORMAT;
				END IF ;
			END IF;  -- end of format check
		END IF ;  */
	--		End Of Pension Insurance Policy Number

	--              For Pension Provider Customer number		--
			IF p_org_information2 IS NOT NULL
			THEN
				IF (  (LENGTH(p_org_information2) =11) AND (SUBSTR(p_org_information2,9,1)='-')     )
				THEN -- length
					IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information2,'DDDDDDDD-DD')='0'
					THEN
						RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
					ELSE
						l_last_two_digits := substr(p_org_information2,10,2);
						IF l_last_two_digits <> '00'
						THEN
							RAISE INVALID_PP_CUSTOMER_NUM_FORMAT;
						END IF;
					END IF ;
				ELSE
					RAISE  INVALID_PP_CUSTOMER_NUM_FORMAT;
				END IF ; -- end of  length
			END IF;
			--              End Of For Pension Provider Customer number	--

	END IF;


	IF p_org_info_type_code = 'FI_ACCIDENT_PROVIDERS' THEN


			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;


			OPEN  c_upd_le_ap_dtls ;
			FETCH   c_upd_le_ap_dtls  INTO l_count;
			CLOSE  c_upd_le_ap_dtls ;
			IF l_count > 0	THEN
				RAISE UNIQUE_LE_AP ;
			END IF ;

	    /* Commenting the validation for Accident Insurance Policy Number for  Enhancement 2008-2009 */
	      /* Please refer Bug 8425533 for further details    */

		/*		--              For Accident Insurance Policy Number		--
		IF p_org_information4 IS NOT NULL
		THEN
			IF (  (LENGTH(p_org_information4) =13) AND (SUBSTR(p_org_information4,4,1)='-')  AND   (SUBSTR(p_org_information4,12,1)='-')   )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information4,'DDD-DDDDDDD-X')='0'
				THEN
					RAISE  INVALID_POLICY_NUMBER_FORMAT;
				END IF;
			ELSE
				RAISE  INVALID_POLICY_NUMBER_FORMAT;
			END IF ;
		END IF;
	--              End Of  Accident Insurance Policy Number	--
	       */ -- End

	END IF;


	IF p_org_info_type_code = 'FI_LU_ACCIDENT_PROVIDERS' THEN


			IF p_org_information2	IS NOT NULL THEN

				IF fnd_date.canonical_to_date(p_org_information2) < fnd_date.canonical_to_date(p_org_information1) THEN
					RAISE INVALID_DATE ;
				END IF;

			END IF;


			OPEN  c_upd_lu_ap_dtls ;
			FETCH   c_upd_lu_ap_dtls  INTO l_count;
			CLOSE  c_upd_lu_ap_dtls ;
			IF l_count > 0	THEN
				RAISE UNIQUE_LU_AP ;
			END IF ;
               /* Commenting the validation for Accident Insurance Policy Number for  Enhancement 2008-2009 */
	      /* Please refer Bug 8425533 for further details    */
		/*		--              For Accident Insurance Policy Number		--
		IF p_org_information3 IS NOT NULL
		THEN
			IF (  (LENGTH(p_org_information3) =13) AND (SUBSTR(p_org_information3,4,1)='-')  AND   (SUBSTR(p_org_information3,12,1)='-')   )
			THEN -- length
				IF HR_NI_CHK_PKG.CHK_NAT_ID_FORMAT(p_org_information3,'DDD-DDDDDDD-X')='0'
				THEN
					RAISE  INVALID_POLICY_NUMBER_FORMAT;
				END IF;
			ELSE
				RAISE  INVALID_POLICY_NUMBER_FORMAT;
			END IF ;
		END IF;
	--              End Of  Accident Insurance Policy Number	--
		*/ -- End

	END IF;

  END IF;

EXCEPTION
		WHEN INVALID_POLICY_NUMBER_FORMAT
		THEN

			l_field := hr_general.decode_lookup('FI_FORM_LABELS','ACC_INS_POLICY');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

		WHEN INVALID_Y_NUMBER_FORMAT
		THEN

			l_field := hr_general.decode_lookup('FI_FORM_LABELS','Y_NUMBER');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

		WHEN INVALID_PP_CUSTOMER_NUM_FORMAT
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','PEN_PROV_CUST');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;

/*		WHEN INVALID_PIP_NUMBER_FORMAT
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','PEN_INS_POLICY');
			fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error; */

		WHEN UNIQUE_LOCAL_UNITS
		THEN
			fnd_message.set_name('PER', 'HR_376614_FI_UNIQUE_LOCAL_UNIT');
		        hr_utility.raise_error;

		WHEN UNIQUE_Y_NUMBER
		THEN
			l_field := hr_general.decode_lookup('FI_FORM_LABELS','Y_NUMBER');
			fnd_message.set_name('PER', 'HR_376613_FI_UNIQUE_MSG');
		        fnd_message.set_token('NAME',l_field, translate => true );
		        hr_utility.raise_error;
		WHEN UNIQUE_DEPT_CODE
		THEN

			fnd_message.set_name('PAY', 'HR_376630_FI_UNIQUE_DEPT_CODE');
		        hr_utility.raise_error;

		WHEN UNIQUE_GROUP_CODE
		THEN

			fnd_message.set_name('PAY', 'HR_376632_FI_UNIQUE_GROUP_CODE');
		        hr_utility.raise_error;

		WHEN UNIQUE_PENSION_TYPE
		THEN

			fnd_message.set_name('PAY', 'HR_376647_FI_UNIQ_PENSION_TYPE');
		        hr_utility.raise_error;


		WHEN UNIQUE_LE_LC
		THEN

			fnd_message.set_name('PAY', 'HR_376631_FI_UNIQUE_LE_LC');
		        hr_utility.raise_error;

		WHEN UNIQUE_LE_AP
		THEN

			fnd_message.set_name('PAY', 'HR_376638_FI_UNIQUE_ACC_PROV');
		        hr_utility.raise_error;

		WHEN UNIQUE_LU_AP
		THEN

			fnd_message.set_name('PAY', 'HR_376645_FI_LU_UNIQ_ACC_PROV');
		        hr_utility.raise_error;

		WHEN INVALID_DATE
		THEN

			fnd_message.set_name('PAY', 'HR_376639_FI_VALID_DATE');
		        hr_utility.raise_error;

		WHEN INVALID_TYEL_GROUP
		THEN

			fnd_message.set_name('PAY', 'HR_376648_FI_TEL_GROUP_DTLS');
		        hr_utility.raise_error;


		WHEN UNIQUE_PENSION_INS_NUM
		THEN
			fnd_message.set_name('PAY', 'HR_376650_FI_UNIQ_PEN_INS_NUM');
		        hr_utility.raise_error;

		WHEN UNIQUE_LU_PENSION_INS_NUM
		THEN
			fnd_message.set_name('PAY', 'HR_376651_FI_LU_PEN_INS_NUM');
		        hr_utility.raise_error;


		WHEN UNIQUE_PG_DTLS_PG
		THEN
			fnd_message.set_name('PAY', 'HR_376649_FI_LEL_TAEL_GROUP');
		        hr_utility.raise_error;

		WHEN UNIQUE_PENSION_USER_PT
		THEN
			fnd_message.set_name('PAY', 'HR_376654_FI_LE_TEL_GROUP_DTLS');
		        hr_utility.raise_error;

 END validate_update_org_inf;

 --- End Of validate_update_org_inf


PROCEDURE  CREATE_ASG_VALIDATE
(
  p_scl_segment12                IN      VARCHAR2  DEFAULT  NULL
 ,p_effective_date		 IN	 DATE
 ,p_person_id                    IN      NUMBER
 ,p_organization_id              IN      NUMBER )
 IS

	l_yes_or_no		VARCHAR2(10);
	l_count			NUMBER ;

	UNIQUE_RPT_ASG		EXCEPTION ;
	l_business_group_id	hr_organization_units.business_group_id%TYPE;
	l_le			hr_organization_units.organization_id%type;

 CURSOR  getbgid
 IS
	SELECT	business_group_id
	FROM	hr_organization_units
	WHERE	organization_id = p_organization_id;

		CURSOR  get_rpt_asg ( p_le NUMBER )
		IS
		SELECT hsc.segment12
		FROM HR_ORGANIZATION_UNITS o1
		,HR_ORGANIZATION_INFORMATION hoi1
		,HR_ORGANIZATION_INFORMATION hoi2
		,PER_ALL_ASSIGNMENTS_F paa
		,HR_SOFT_CODING_KEYFLEX hsc
		WHERE o1.business_group_id =l_business_group_id
		and o1.organization_id = hoi1.organization_id
		and hoi1.org_information_context = 'CLASS'
		and hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND nvl(hoi2.organization_id,-999) =  p_le
		and hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		and o1.organization_id = hoi2.org_information1
		and paa.person_id =p_person_id
		AND    p_effective_date  BETWEEN paa.effective_start_date AND paa.effective_end_date
		and paa.SOFT_CODING_KEYFLEX_ID=hsc.SOFT_CODING_KEYFLEX_ID
		and o1.organization_id = hsc.segment2;


		CURSOR csr_le  IS
		SELECT hoi3.organization_id
		FROM HR_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = p_organization_id
		AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';




BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
	OPEN  getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE  getbgid;

	IF upper(p_scl_segment12) = 'Y'
	THEN

		OPEN csr_le;
		FETCH csr_le INTO l_le;
		CLOSE csr_le ;


		OPEN  get_rpt_asg(l_le);
		LOOP
			FETCH  get_rpt_asg INTO  l_yes_or_no;
			EXIT  WHEN  get_rpt_asg%NOTFOUND;
			IF l_yes_or_no = upper(p_scl_segment12)
			THEN
				RAISE UNIQUE_RPT_ASG ;
			END IF ;
		END LOOP ;
		CLOSE  get_rpt_asg;
	END IF ;
  END IF;

EXCEPTION
	WHEN UNIQUE_RPT_ASG
	THEN
		fnd_message.set_name('PER', 'HR_376610_FI_UNIQUE_RPT_ASG');
		hr_utility.raise_error;

END CREATE_ASG_VALIDATE;

-- End OF Create_Asg_validate

PROCEDURE  UPDATE_ASG_VALIDATE
(
 p_segment2			IN	VARCHAR2
,p_segment12			IN	VARCHAR2
,p_effective_date		IN	DATE
,p_assignment_id		IN	NUMBER)
IS

	l_person_id		NUMBER;
	l_count			NUMBER;
	l_yes_or_no		VARCHAR2(10);
	UNIQUE_RPT_ASG		EXCEPTION ;
	l_business_group_id	hr_organization_units.business_group_id%TYPE;
	l_le			hr_organization_units.organization_id%type;

CURSOR	getbgid
IS
	SELECT	business_group_id
	FROM	per_all_assignments_f
	where	assignment_id = p_assignment_id;


		CURSOR  get_rpt_asg ( p_le NUMBER )
		IS
		SELECT hsc.segment12
		FROM HR_ORGANIZATION_UNITS o1
		,HR_ORGANIZATION_INFORMATION hoi1
		,HR_ORGANIZATION_INFORMATION hoi2
		,PER_ALL_ASSIGNMENTS_F paa
		,HR_SOFT_CODING_KEYFLEX hsc
		WHERE o1.business_group_id =l_business_group_id
		and o1.organization_id = hoi1.organization_id
		and hoi1.org_information_context = 'CLASS'
		and hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND nvl(hoi2.organization_id,-999) =  p_le
		and hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		and o1.organization_id = hoi2.org_information1
		and paa.person_id =l_person_id
		and paa.assignment_id <>  p_assignment_id
		AND     p_effective_date  BETWEEN paa.effective_start_date AND paa.effective_end_date
		and paa.SOFT_CODING_KEYFLEX_ID=hsc.SOFT_CODING_KEYFLEX_ID
		and o1.organization_id = hsc.segment2;


	CURSOR csr_le  IS
		SELECT hoi3.organization_id
		FROM HR_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		WHERE  o1.business_group_id =l_business_group_id
		AND hoi1.organization_id = o1.organization_id
		AND hoi1.organization_id = p_segment2
		AND hoi1.org_information1 = 'FI_LOCAL_UNIT'
		AND hoi1.org_information_context = 'CLASS'
		AND o1.organization_id = hoi2.org_information1
		AND hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		AND hoi2.organization_id =  hoi3.organization_id
		AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';



CURSOR	c_person
IS
	SELECT	person_id
	FROM	per_all_assignments_f a
	WHERE	a.assignment_id = p_assignment_id
	AND    p_effective_date BETWEEN a.effective_start_date AND a.effective_end_date;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
	OPEN  c_person;
	LOOP
		FETCH  c_person INTO  l_person_id;
		EXIT ;
	END LOOP ;
	CLOSE  c_person;

	OPEN  getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE  getbgid;

	IF upper(p_segment12) = 'Y'
	THEN

		OPEN csr_le;
		FETCH csr_le INTO l_le;
		CLOSE csr_le ;

		OPEN  get_rpt_asg(l_le);
		LOOP
			FETCH  get_rpt_asg INTO  l_yes_or_no;
			EXIT  WHEN  get_rpt_asg%NOTFOUND;
			IF l_yes_or_no = upper(p_segment12)
			THEN
				RAISE UNIQUE_RPT_ASG ;
			END IF ;
		END  LOOP  ;
	CLOSE  get_rpt_asg;

	END IF ;
  END IF;
EXCEPTION
	WHEN UNIQUE_RPT_ASG
	THEN
		fnd_message.set_name('PER', 'HR_376610_FI_UNIQUE_RPT_ASG');
		hr_utility.raise_error;

END UPDATE_ASG_VALIDATE ;

-- End Of UPDATE_ASG_VALIDATE

  --Procedure for validating Termination.
 PROCEDURE  UPDATE_TERMINATION_VALIDATE
  (p_leaving_reason                 IN	    VARCHAR2
  )IS
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
     --
     IF p_leaving_reason IS NULL THEN
        fnd_message.set_name('PER', 'HR_376603_FI_MANDATORY_MSG');
        fnd_message.set_token('NAME',hr_general.decode_lookup('FI_FORM_LABELS','L_REASON'), translate => true );
        hr_utility.raise_error;
      END IF;
   END IF;
END UPDATE_TERMINATION_VALIDATE ;



----
--   Validation While creating the Classifications for Organization

 PROCEDURE  CREATE_ORG_CLASS_VALIDATE
  (P_ORGANIZATION_ID                IN	    NUMBER
  ,P_ORG_INFORMATION1               IN      VARCHAR2
  )IS

	l_internal_external_flag	hr_organization_units.INTERNAL_EXTERNAL_FLAG%type;
	EXT_COMP_EXCEPTION		exception;
	PEN_PROV_EXCEPTION		exception;
	ACC_PROV_EXCEPTION		exception;

	PROV_TAX_EXCEPTION		exception;



CURSOR	get_int_or_ext_flag
IS
	SELECT	INTERNAL_EXTERNAL_FLAG
	FROM	HR_ORGANIZATION_UNITS
	WHERE	ORGANIZATION_ID = P_ORGANIZATION_ID;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
    --
	OPEN  get_int_or_ext_flag;
		FETCH  get_int_or_ext_flag INTO  l_internal_external_flag;
	CLOSE  get_int_or_ext_flag;

	IF l_internal_external_flag = 'INT'
	THEN
		IF  P_ORG_INFORMATION1 = 'FI_EXTERNAL_COMPANY'
		THEN
			RAISE EXT_COMP_EXCEPTION;
		-- FOR PENSION PROVIDER

		ELSIF P_ORG_INFORMATION1 = 'FR_PENSION'
		THEN
			RAISE PEN_PROV_EXCEPTION;
		-- FOR ACCIDENT PROVIDERS

		ELSIF P_ORG_INFORMATION1 = 'ACCIDENT'
		THEN
			RAISE ACC_PROV_EXCEPTION;
		ELSIF P_ORG_INFORMATION1 = 'PROV_TAX_OFFICE'
		THEN
			RAISE PROV_TAX_EXCEPTION;

		END IF;
	END IF ;
  END IF;
EXCEPTION
		WHEN EXT_COMP_EXCEPTION
		THEN
			fnd_message.set_name('PER', 'HR_376615_FI_EXT_COMPANY');
		        hr_utility.raise_error;
		WHEN PEN_PROV_EXCEPTION
		THEN
			fnd_message.set_name('PAY', 'HR_376628_FI_PEN_PROVIDER');
		        hr_utility.raise_error;
       		WHEN ACC_PROV_EXCEPTION
		THEN
			fnd_message.set_name('PAY', 'HR_376629_FI_ACC_INS_PROVIDER');
		        hr_utility.raise_error;

       		WHEN PROV_TAX_EXCEPTION
		THEN
			fnd_message.set_name('PAY', 'HR_376635_FI_PROV_TAX_OFFICE');
		        hr_utility.raise_error;


END CREATE_ORG_CLASS_VALIDATE;
---


/*
	PROCEDURE NAME	: VALIDATE_NUMBER
	PARAMATERS	: p_number	-- Number to be Validated.
			  p_token	-- Token to be displayed in MSG
			  p_message	-- Message to be called

	PURPOSE		: To validate the Number whether it is whole number or not.
			  To call ur own specific message pass use VALIDATE_NUMBER(XXX,'token','MSG')
			  To use the message already available i.e.. Invalid format use VALIDATE_NUMBER(XXX,'token',NULL)
			  Dont pass VALIDATE_NUMBER(XXX,NULL,NULL)
	ERRORS HANDLED	: Raise ERROR if No is not an whole number
*/


PROCEDURE VALIDATE_NUMBER
  (p_number		IN	VARCHAR2
  ,p_token		IN	VARCHAR2
  ,p_message		IN	VARCHAR2 DEFAULT NULL
  ) IS

  BEGIN
	IF p_number IS NOT NULL
	THEN
		IF instr(p_number,'.') <> '0'
		THEN
			IF p_token IS NOT NULL AND  p_message IS NULL
			THEN
				fnd_message.set_name('PER', 'HR_376612_FI_INVALID_FORMAT');
			        fnd_message.set_token('NAME',p_token, translate => true );
			        hr_utility.raise_error;
			ELSIF  p_message IS NOT NULL
			THEN
				fnd_message.set_name('PER', p_message);
			        fnd_message.set_token('NAME',p_token, translate => true );
			        hr_utility.raise_error;
			END IF ;

		END IF;
	END IF;

  END VALIDATE_NUMBER;

 PROCEDURE PERSON_ABSENCE_CREATE
  (
   p_business_group_id            IN number
  ,p_abs_information_category     IN varchar2
  ,p_person_id                    IN Number
  ,p_date_start                   IN Date
  ,p_date_end                     IN Date
  ,p_abs_information1             IN Varchar2 default NULL
  ,p_abs_information2             IN Varchar2 default NULL
  ,p_abs_information3             IN Varchar2 default NULL
  ,p_abs_information4             IN Varchar2 default NULL
  ,p_abs_information5             IN Varchar2 default NULL
  ) IS

  cursor get_start_date(p_person_id number) is
  select min(effective_start_date)
  from per_all_people_f
  where person_id=p_person_id;
  l_start_date date;

  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
      --
	  -- get the values of the person_id profile
      fnd_profile.put('PER_PERSON_ID',p_person_id);
  	  if p_abs_information_category='FI_F' THEN
	   OPEN get_start_date(p_person_id);
	   FETCH get_start_date into l_start_date;
	   CLOSE get_start_date;

	   if fnd_date.canonical_to_date(p_abs_information1) < l_start_date THEN
	       fnd_message.set_name('PAY', 'HR_376663_FI_MATERNITY_DATE');
	       hr_utility.raise_error;
	   END IF;
	  END IF;
    END IF;

  END PERSON_ABSENCE_CREATE;

  PROCEDURE PERSON_ABSENCE_UPDATE
  (
   p_absence_attendance_id        IN Number
  ,p_abs_information_category     IN varchar2
  ,p_date_start                   IN Date
  ,p_date_end                     IN Date
  ,p_abs_information1             IN Varchar2 default NULL
  ,p_abs_information2             IN Varchar2 default NULL
  ,p_abs_information3             IN Varchar2 default NULL
  ,p_abs_information4             IN Varchar2 default NULL
  ,p_abs_information5             IN Varchar2 default NULL
  ) IS

  cursor get_start_date(l_person_id number) is
  select min(effective_start_date)
  from per_all_people_f
  where person_id=l_person_id;

  cursor get_person_id(p_absence_attendance_id in number) is
	select person_id
        from   per_absence_attendances
        where  absence_attendance_id =p_absence_attendance_id;

  l_start_date date;
  l_person_id              number;

  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'FI') THEN
      --
	  open get_person_id(p_absence_attendance_id);
  	  fetch get_person_id into l_person_id;
	  close get_person_id;

	  -- get the values of the person_id profile
	  fnd_profile.put('PER_PERSON_ID',l_person_id);

	  if p_abs_information_category='FI_F' THEN
	   OPEN get_start_date(l_person_id);
	   FETCH get_start_date into l_start_date;
	   CLOSE get_start_date;

	   if fnd_date.canonical_to_date(p_abs_information1) < l_start_date THEN
	       fnd_message.set_name('PAY', 'HR_376663_FI_MATERNITY_DATE');
	       hr_utility.raise_error;
	   END IF;
	  END IF;
    END IF;
  END PERSON_ABSENCE_UPDATE;

END HR_FI_VALIDATE_PKG;

/
