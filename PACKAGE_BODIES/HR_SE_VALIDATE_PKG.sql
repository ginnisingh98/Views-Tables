--------------------------------------------------------
--  DDL for Package Body HR_SE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SE_VALIDATE_PKG" AS
/* $Header: pesevald.pkb 120.24 2007/07/12 14:02:29 rravi noship $ */


  PROCEDURE validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
   ) AS

    l_field         varchar2(300) := NULL;
    l_valid_date    varchar2(10);
    l_type          VARCHAR2(1) := NULL;
    CURSOR c_type IS
    SELECT 'Y'
    FROM   per_person_types ppt
    WHERE  ppt.person_type_Id = p_person_type_id
    AND    ppt.system_person_type like 'EMP%';

  BEGIN
    l_type := NULL;
     OPEN c_type;
     FETCH c_type INTO l_type;
     CLOSE c_type;


      --Validate not null fields

      IF l_type IS NOT NULL THEN
               IF p_first_name    IS NULL THEN
                    l_field := hr_general.decode_lookup('SE_FORM_LABELS','FIRST_NAME');

		      IF l_field IS NOT NULL THEN
			        fnd_message.set_name('PER', 'HR_377202_SE_MANDATORY_MSG');
			        fnd_message.set_token('NAME',l_field, translate => true );
			        hr_utility.raise_error;
		      END IF;

               END IF;

	      IF p_national_identifier  IS NULL or p_national_identifier = hr_api.g_varchar2 THEN

	   	      l_field := hr_general.decode_lookup('SE_FORM_LABELS','PIN');

		      IF l_field IS NOT NULL AND fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') THEN
			        fnd_message.set_name('PER', 'HR_377202_SE_MANDATORY_MSG');
			        fnd_message.set_token('NAME',l_field, translate => true );
			        hr_utility.raise_error;
		      END IF;

      	      END IF;
      END IF;


  END;

  --Procedure for validating person
  PROCEDURE person_validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ) AS
  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --
      validate
      (p_person_type_id             =>  p_person_type_id
      ,p_first_name                 =>  p_first_name
      ,p_national_identifier        =>  p_national_identifier
      );
	END IF;
  END person_validate;

    --Procedure for validating applicant
  PROCEDURE applicant_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
    ) AS
l_person_type_id   number ;
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --
    per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'APL'
    );
    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_first_name                 =>  p_first_name
    ,p_national_identifier        =>  p_national_identifier
     );
   END IF;
  END applicant_validate;

  --Procedure for validating employee
  PROCEDURE employee_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
    ) AS
  l_person_type_id   number ;
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
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
     );
   END IF;
  END employee_validate;

   --Procedure for validating contact/cwk
  PROCEDURE contact_cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
    ) AS
l_person_type_id   number ;
  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
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
    );
   END IF;
  END contact_cwk_validate;

--___________________________________________VALIDATE_CREATE_ORG_INF_____________________________________________

PROCEDURE validate_create_org_inf
  (p_org_info_type_code		IN	VARCHAR2
  ,p_organization_id		IN	NUMBER
  ,p_org_information1		IN	VARCHAR2 DEFAULT null
  ,p_org_information2		IN	VARCHAR2 DEFAULT null
  ,p_org_information3		IN	VARCHAR2 DEFAULT null
  ,p_org_information4		IN	VARCHAR2 DEFAULT null
  ,p_org_information5		IN	VARCHAR2 DEFAULT null
  ,p_org_information6		IN	VARCHAR2 DEFAULT null
  ,p_org_information7		IN  VARCHAR2 DEFAULT null
  ,p_org_information8		IN  VARCHAR2 DEFAULT null
  ,p_org_information9		IN  VARCHAR2 DEFAULT null
  ,p_org_information10		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information11		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information12		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information13		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information14		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information15		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information16		IN  VARCHAR2 DEFAULT null
  ) IS

	l_business_group_id				hr_organization_units.business_group_id%TYPE;
	l_count						NUMBER ;
	l_field						VARCHAR2(300) := NULL;
	l_org_information1				hr_organization_information.org_information1%TYPE;
	l_main_lc_status				hr_organization_information.org_information6%TYPE;

	UNIQUE_AST_NUMBER				EXCEPTION;
	UNIQUE_ORG_NUMBER				EXCEPTION;
	UNIQUE_MAIN_LOCAL_UNIT				EXCEPTION;
	UNIQUE_LOCAL_UNITS				EXCEPTION;
	UNIQUE_LE_AP					EXCEPTION;
	INVALID_DATE					EXCEPTION;
	INVALID_TAX					EXCEPTION;
	INVALID_YEAR					EXCEPTION;
	INVALID_DECIMAL					EXCEPTION;

	ENTER_ALL					EXCEPTION;
	ENTER_GROUP_BY					EXCEPTION;
	INVALID_CATEGORY				EXCEPTION;
	INVALID_UPDATE					EXCEPTION;
	INVALID_INSURANCE_NUMBER			EXCEPTION;
	INVALID_VALUE					EXCEPTION;
	INVALID_INSURANCE_DECIMAL			EXCEPTION;
	UNIQUE_YEAR              			EXCEPTION;
	INVALID_MEMBERSHIP_NUMBER			EXCEPTION;
	INVALID_MEMBERSHIP_DECIMAL			EXCEPTION;
	INVALID_WORK_NUMBER				EXCEPTION;
	INVALID_WORK_DECIMAL				EXCEPTION;
	INVALID_ASSOCIATION_NUMBER			EXCEPTION;
	INVALID_ASSOCIATION_DECIMAL			EXCEPTION;
	INVALID_AGREEMENT_NUMBER			EXCEPTION;
	INVALID_AGREEMENT_DECIMAL			EXCEPTION;
	INVALID_AGREEMENT_NUM				EXCEPTION;


	l_token varchar2(300);
	l_number number;
	CURSOR  getbgid IS
	SELECT 	 business_group_id
	FROM 	 hr_all_organization_units
	WHERE 	 organization_id = p_organization_id;
/*
	CURSOR  orglocalunit IS
		select	o.organization_id
		from	hr_organization_units o , hr_organization_information hoi  ,  FND_SESSIONS s
		where	o.organization_id = hoi.organization_id
		and	hoi.org_information_context = 'CLASS'
		and	hoi.org_information1 = 'SE_LOCAL_UNIT'
		and to_char(o.organization_id) in
				(
				select hoinf.org_information1
				from hr_organization_units org, hr_organization_information hoinf
				where org.business_group_id = l_business_group_id
				and org.organization_id = hoinf.organization_id
				and hoinf.org_information_context = 'SE_LOCAL_UNITS'
				)
		and	s.session_id = userenv('sessionid')
		and	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		ORDER BY o.name;
*/
CURSOR  orglocalunit IS
	select	o.organization_id
		from	hr_organization_units o ,
				hr_organization_information hoi,
			 hr_organization_information hoinf,
				FND_SESSIONS s
		where	o.organization_id = hoi.organization_id
		and o.business_group_id = l_business_group_id
		and	hoi.org_information_context = 'CLASS'
		and	hoi.org_information1 = 'SE_LOCAL_UNIT'
		and hoinf.org_information_context = 'SE_LOCAL_UNITS'
		and to_char(o.organization_id) = hoinf.org_information1
		and to_char(hoi.organization_id)  = hoinf.org_information1
		and	s.session_id = userenv('sessionid')
		and	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		ORDER BY o.name;
/*
	CURSOR  ast_number IS
	select count(hoi2.org_information1)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information1 = p_org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  IN
	(select hoi3.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.organization_id = p_organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'   ) );
*/



CURSOR FIND_LEGAL_EMPLOYER IS
		select hoi3.organization_id
		from HR_ALL_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		WHERE  o1.business_group_id =l_business_group_id
		and hoi1.organization_id = o1.organization_id
		and hoi1.organization_id = p_organization_id
		and hoi1.org_information1 = 'SE_LOCAL_UNIT'
		and hoi1.org_information_context = 'CLASS'
		and o1.organization_id = hoi2.org_information1
		and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
		and hoi2.organization_id =  hoi3.organization_id
		and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
        and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';

        L_LEGAL_EMPLOYER NUMBER;
	CURSOR  ast_number IS
	select count(hoi2.org_information1)
    from HR_ALL_ORGANIZATION_UNITS o1
		      , HR_ORGANIZATION_INFORMATION hoi1
		      , HR_ORGANIZATION_INFORMATION hoi2
		      , HR_ORGANIZATION_INFORMATION hoi3
		      , HR_ORGANIZATION_INFORMATION hoi4
		      WHERE o1.business_group_id =l_business_group_id
		      and hoi1.organization_id = o1.organization_id
		      and hoi1.org_information1 = 'SE_LOCAL_UNIT'
		      and hoi1.org_information_context = 'CLASS'
		      and o1.organization_id = hoi2.organization_id
		      and hoi2.org_information1 = p_org_information1
		      and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
		      and hoi2.organization_id =   hoi4.org_information1
		      and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		      and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		      and hoi4.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
		      and hoi4.organization_id =  hoi3.organization_id
      and hoi4.organization_id = L_LEGAL_EMPLOYER;

/*	CURSOR  main_lc IS
	select count(hoi2.org_information6)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  IN
	(select hoi3.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.organization_id = p_organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'   ) );*/

CURSOR  main_lc IS
	select count(hoi2.org_information6)
     from HR_ALL_ORGANIZATION_UNITS o1
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_ORGANIZATION_INFORMATION hoi3
      , HR_ORGANIZATION_INFORMATION hoi4
      WHERE o1.business_group_id =l_business_group_id
      and hoi1.organization_id = o1.organization_id
      and hoi1.org_information1 = 'SE_LOCAL_UNIT'
      and hoi1.org_information_context = 'CLASS'
      and o1.organization_id = hoi2.organization_id
      and hoi2.org_information6 = 'Y'
      and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
      and hoi2.organization_id =   hoi4.org_information1
      and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
      and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
      and hoi4.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
      and hoi4.organization_id =  hoi3.organization_id
      and hoi4.organization_id = L_LEGAL_EMPLOYER;

 /*
CURSOR  main_lc_le IS
	select count(hoi2.org_information6)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  = p_organization_id );
*/
CURSOR  main_lc_le IS select count(hoi2.org_information6)
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	, HR_ORGANIZATION_INFORMATION hoi4
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and o1.organization_id = hoi3.org_information1
	and hoi3.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi3.organization_id =  hoi4.organization_id
	and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi4.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi4.organization_id  = p_organization_id ;

/*
	CURSOR  ast_number_le IS
	select count(hoi2.org_information1)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and hoi2.org_information1 in
	(select hoi2.org_information1
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.organization_id  = P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
        )
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  = p_organization_id);
*/
	CURSOR  ast_number_le IS
	select count(hoi2.org_information1)
from HR_ALL_ORGANIZATION_UNITS o1
, HR_ORGANIZATION_INFORMATION hoi1
, HR_ORGANIZATION_INFORMATION hoi2
, HR_ORGANIZATION_INFORMATION hoi3
, HR_ORGANIZATION_INFORMATION hoi4
, HR_ORGANIZATION_INFORMATION hoi5
WHERE o1.business_group_id =l_business_group_id
and hoi1.organization_id = o1.organization_id
and hoi1.org_information1 = 'SE_LOCAL_UNIT'
and hoi1.org_information_context = 'CLASS'
and o1.organization_id = hoi2.organization_id
and hoi2.organization_id  <> p_org_information1
and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
and o1.organization_id = hoi3.org_information1
and hoi3.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
and hoi3.organization_id =  hoi4.organization_id
and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
and hoi4.org_information1 = 'HR_LEGAL_EMPLOYER'
AND hoi4.organization_id  = p_organization_id
and hoi5.organization_id  = p_org_information1
and hoi5.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
and hoi2.org_information1 = hoi5.org_information1;

		CURSOR tax_lc(l_param1 varchar2,l_param2 number) IS
			select count(hoi1.org_information1)
			from HR_ALL_ORGANIZATION_UNITS o1
		      , HR_ORGANIZATION_INFORMATION hoi1
		      , HR_ORGANIZATION_INFORMATION hoi2
		      WHERE o1.business_group_id =l_business_group_id
		      and o1.organization_id=hoi1.organization_id
		      and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
		      and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
		      and hoi2.ORG_INFORMATION_CONTEXT='SE_TAX_DECLARATION_DETAILS'
		      and hoi2.organization_id =  hoi1.organization_id
		      and hoi2.org_information1=l_param1
		      and hoi2.org_information2=l_param2
		      and hoi2.organization_id = p_organization_id;

CURSOR absence_cat_limit(l_param1 varchar2) IS
select count(hoi1.org_information1)
from HR_ALL_ORGANIZATION_UNITS o1
, HR_ORGANIZATION_INFORMATION hoi1
, HR_ORGANIZATION_INFORMATION hoi2
WHERE o1.business_group_id =l_business_group_id
and o1.organization_id=hoi1.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi2.ORG_INFORMATION_CONTEXT='SE_ABSENCE_CATEGORY_LIMIT'
and hoi2.organization_id =  hoi1.organization_id
and hoi2.org_information1=l_param1
and hoi2.organization_id = p_organization_id;

	CURSOR  org_number IS
	select count(hoi2.org_information2)
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information_context = 'CLASS'
	and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	and o1.organization_id = hoi2.organization_id
	and hoi1.organization_id = hoi2.organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS'
	and hoi2.org_information2 = p_org_information2;

	CURSOR  main_lc_status IS
	select hoi2.org_information6
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi1.organization_id = hoi2.organization_id
	and o1.organization_id = p_org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS';


	CURSOR c_ins_le_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_all_organization_units ou
	WHERE 	(hoi.org_information_context = 'SE_COMPANY_MILEAGE_RATES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(p_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information4) between  fnd_date.canonical_to_date(hoi.org_information4) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information4) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information4) between  fnd_date.canonical_to_date(p_org_information4) AND
	nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information4),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information4) AND
	nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY'))));

CURSOR csr_global(csr_v_global VARCHAR2 )IS
SELECT nvl(global_value,0) FROM ff_globals_f,
	FND_SESSIONS s
	WHERE GLOBAL_NAME=csr_v_global --'SE_EMPLOYER_TAX_PERC'
	AND legislation_code='SE'
	and s.effective_date --p_effective_date
	BETWEEN effective_start_date AND
	effective_end_date
	AND s.session_id=userenv('sessionid');

CURSOR csr_agreement_meaning(csr_v_lookup_code varchar2) is
SELECT
trim(meaning)
FROM hr_lookups
WHERE lookup_type='SE_AGREEMENT_CODE'
AND lookup_code=TRIM(csr_v_lookup_code);


l_global_value NUMBER;
l_agreement_meaning varchar2(50);

CURSOR csr_year IS
SELECT count(*)
FROM   hr_organization_information hoi, hr_organization_units ou, fnd_sessions s
WHERE  hoi.org_information_context = 'SE_STD_WORK_DETAILS'
AND    ou.organization_id = hoi.organization_id
AND    ou.organization_id = nvl (p_organization_id, 0)
AND    ou.business_group_id = l_business_group_id
AND    hoi.org_information1 = p_org_information1
AND    s.session_id = userenv ('sessionid')
AND    s.effective_date BETWEEN ou.date_from AND nvl (ou.date_to, TO_DATE ('31/12/4712', 'DD/MM/YYYY'));


BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --
	OPEN 	getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE 	getbgid;

	IF   p_org_info_type_code = 'SE_LOCAL_UNITS'  THEN
		OPEN  orglocalunit;
			LOOP
			FETCH  orglocalunit into l_org_information1;
			EXIT  WHEN  orglocalunit%NOTFOUND;
				IF  l_org_information1 = p_org_information1 then
					RAISE UNIQUE_LOCAL_UNITS ;
				END IF ;
			END LOOP;
		CLOSE orglocalunit;



			OPEN ast_number_le;
				FETCH  ast_number_le INTO l_count;
			CLOSE ast_number_le;
			IF l_count > 0	THEN
				RAISE UNIQUE_AST_NUMBER ;
			END IF ;

			OPEN main_lc_status;
			FETCH  main_lc_status INTO l_main_lc_status;
			CLOSE main_lc_status;

			IF l_main_lc_status ='Y' then
				OPEN main_lc_le;
				FETCH  main_lc_le INTO l_count;
				CLOSE main_lc_le;
				IF l_count > 0	THEN
					RAISE UNIQUE_MAIN_LOCAL_UNIT ;
				END IF ;
			END IF;


	ELSIF p_org_info_type_code = 'SE_LOCAL_UNIT_DETAILS' THEN
		-- validate for presence of Decimals in AST Number
		validate_number(p_org_information1,hr_general.decode_lookup('SE_FORM_LABELS','AST'));
		-- validate for Uniqness of AST Number within a Legal Employer
		IF p_org_information1 IS NOT NULL THEN
			OPEN FIND_LEGAL_EMPLOYER;
			FETCH  FIND_LEGAL_EMPLOYER INTO L_LEGAL_EMPLOYER;
			CLOSE FIND_LEGAL_EMPLOYER;


			OPEN ast_number;
			FETCH  ast_number INTO l_count;
			CLOSE ast_number;
			IF l_count > 0	THEN
				RAISE UNIQUE_AST_NUMBER ;
			END IF ;
		END IF;

		-- validate for presence of Decimals in CFAR Number
		validate_number(p_org_information2,hr_general.decode_lookup('SE_FORM_LABELS','CFAR'));

		IF p_org_information6 ='Y' THEN
			OPEN FIND_LEGAL_EMPLOYER;
			FETCH  FIND_LEGAL_EMPLOYER INTO L_LEGAL_EMPLOYER;
			CLOSE FIND_LEGAL_EMPLOYER;

			OPEN main_lc;
			FETCH  main_lc INTO l_count;
			CLOSE main_lc;
			IF l_count > 0	THEN
				RAISE UNIQUE_MAIN_LOCAL_UNIT ;
			END IF ;
		END IF;



	ELSIF p_org_info_type_code = 'SE_LEGAL_EMPLOYER_DETAILS' THEN
		-- validate for presence of Decimals in Confederation Number
		validate_number(p_org_information1,hr_general.decode_lookup('SE_FORM_LABELS','CONFD'));
		-- validate for presence of Decimals in Organization Number
		validate_number(p_org_information2,hr_general.decode_lookup('SE_FORM_LABELS','ORG'));

		-- validate for Uniqness of Organization Number within a Legal Employer
		IF p_org_information2 IS NOT NULL THEN
			OPEN org_number;
			FETCH  org_number INTO l_count;
			CLOSE org_number;
			IF l_count > 0	THEN
				RAISE UNIQUE_ORG_NUMBER ;
			END IF ;
			IF  length(p_org_information6) <7 THEN
				RAISE INVALID_INSURANCE_NUMBER;
			END IF;

			IF instr(p_org_information6,'.')>0 THEN
				RAISE INVALID_INSURANCE_DECIMAL;
			END IF;
			--Membership Number
			IF  length(p_org_information9) <7 THEN
				RAISE INVALID_MEMBERSHIP_NUMBER;
			END IF;
			IF instr(p_org_information9,'.')>0 THEN
					RAISE INVALID_MEMBERSHIP_DECIMAL;
			END IF;

		END IF;
	ELSIF p_org_info_type_code ='SE_SALARY_STRUCTURE' THEN
		--Working Site Number
		IF  length(p_org_information1) <3 THEN
			RAISE INVALID_WORK_NUMBER;
		END IF;
		IF instr(p_org_information1,'.')>0 THEN
			RAISE INVALID_WORK_DECIMAL;
		END IF;
		--Association Number
		IF  length(p_org_information2) <2 THEN
			RAISE INVALID_ASSOCIATION_NUMBER;
		END IF;
		IF instr(p_org_information2,'.')>0 THEN
			RAISE INVALID_ASSOCIATION_DECIMAL;
		END IF;
		--Agreement Number
		OPEN csr_agreement_meaning(p_org_information3);
			FETCH csr_agreement_meaning INTO l_agreement_meaning;
		CLOSE csr_agreement_meaning;
		BEGIN
		l_number:=to_number(l_agreement_meaning);
		EXCEPTION
		WHEN OTHERS THEN
			RAISE INVALID_AGREEMENT_NUM;
		END;
/*		IF  translate(l_agreement_meaning,'_0123456789.','_') IS NOT NULL THEN
			RAISE INVALID_AGREEMENT_NUM;
		END IF;*/

		IF  length(l_agreement_meaning) <>3 THEN
			RAISE INVALID_AGREEMENT_NUMBER;
		END IF;
		IF instr(l_agreement_meaning,'.')>0 THEN
			RAISE INVALID_AGREEMENT_DECIMAL;
		END IF;

	ELSIF p_org_info_type_code = 'SE_COMPANY_MILEAGE_RATES' THEN

		IF fnd_date.canonical_to_date(p_org_information5) < fnd_date.canonical_to_date(p_org_information4) THEN
			RAISE INVALID_DATE ;
		END IF;

		OPEN  c_ins_le_ap_dtls ;
			FETCH   c_ins_le_ap_dtls  INTO l_count;
		CLOSE  c_ins_le_ap_dtls ;
		IF l_count > 0	THEN
			RAISE UNIQUE_LE_AP ;
		END IF ;

	ELSIF p_org_info_type_code='SE_TAX_DECLARATION_DETAILS' THEN
		IF (p_org_information2 <= 0) OR (p_org_information2 > 4712) THEN
			RAISE INVALID_YEAR;
		END IF;
		IF instr(p_org_information2,'.')>0 THEN
			RAISE INVALID_DECIMAL;
		END IF;
			OPEN tax_lc(p_org_information1,p_org_information2);
			FETCH  tax_lc INTO l_count;
			CLOSE tax_lc;
			IF l_count > 0	THEN
				RAISE INVALID_TAX ;
			END IF ;


		OPEN csr_global('SE_COMPANY_PERC_MAX');
			FETCH csr_global INTO l_global_value;
		CLOSE csr_global;


		IF p_org_information10>l_global_value THEN
			RAISE INVALID_VALUE ;
		END IF;
		l_global_value:=null;

		OPEN csr_global('SE_EXT_COMPANY_PERC_MAX');
			FETCH csr_global INTO l_global_value;
		CLOSE csr_global;

		IF p_org_information12>l_global_value THEN
			RAISE INVALID_VALUE ;
		END IF;

	ELSIF  p_org_info_type_code='SE_ABSENCE_CATEGORY_LIMIT' THEN
		OPEN  absence_cat_limit(p_org_information1);
			FETCH absence_cat_limit INTO l_count;
		CLOSE absence_cat_limit;
		IF l_count>0 THEN
			RAISE INVALID_CATEGORY;
		END IF;
	ELSIF p_org_info_type_code='SE_INSURANCE_NUMBER' THEN
		IF  length(p_org_information1) <7 THEN
			RAISE INVALID_INSURANCE_NUMBER;
		END IF;
		IF instr(p_org_information1,'.')>0 THEN
			RAISE INVALID_INSURANCE_DECIMAL;
		END IF;
	ELSIF p_org_info_type_code='SE_SOE_ELEMENT_ADD_DETAILS' THEN
	--   hr_utility.trace_on(null,'vetri');
	--   hr_utility.trace('Joined    ==> ' );
	--   hr_utility.set_location(' p_org_information3 ' ||p_org_information3 ,10);
	--   hr_utility.set_location(' p_org_information4 '||p_org_information4 ,10);
	--   hr_utility.set_location(' p_org_information5 '||p_org_information5 ,10);
	--   hr_utility.set_location(' p_org_information6 '||p_org_information6 ,10);
	--   hr_utility.set_location(' p_org_information7 '||p_org_information7 ,10);
	--   hr_utility.set_location(' p_org_information8 '||p_org_information8 ,10);
	--   hr_utility.set_location(' p_org_information9 '||p_org_information9 ,10);
	--   hr_utility.set_location(' p_org_information10 '||p_org_information10 ,10);

		IF p_org_information5 ='I'
		 THEN
		    IF p_org_information7 IS NULL
		    or p_org_information8 is NULL
		    or p_org_information9 IS NULL
		    or p_org_information10 IS NULL
		    THEN
		      Raise ENTER_ALL;
		    END IF;
		END IF;
		IF p_org_information4='O'
		THEN
		        IF p_org_information6 is null
		        then
		            RAISE ENTER_GROUP_BY;
		        END IF;
		END IF;

        ELSIF p_org_info_type_code= 'SE_STD_WORK_DETAILS' THEN
	  OPEN  csr_year;
			FETCH csr_year INTO l_count;
	  CLOSE csr_year;
	  IF l_count > 0   THEN
			RAISE UNIQUE_YEAR;
	  END IF;

	END IF ;
  END IF;
EXCEPTION
		WHEN ENTER_GROUP_BY THEN
	            fnd_message.set_name('PER','HR_377202_SE_MANDATORY_MSG');
			l_token := hr_general.decode_lookup('SE_FORM_LABELS','GBP');
	            fnd_message.set_token('NAME',l_token, translate => true );
	            hr_utility.raise_error;

		WHEN ENTER_ALL THEN
	           fnd_message.set_name('PER','HR_377202_SE_MANDATORY_MSG');
			l_token := hr_general.decode_lookup('SE_FORM_LABELS','UNIT') || ','||
			hr_general.decode_lookup('SE_FORM_LABELS','UP') || ','||
			hr_general.decode_lookup('SE_FORM_LABELS','AMT')|| ','||
			hr_general.decode_lookup('SE_FORM_LABELS','GBU');
	           fnd_message.set_token('NAME',l_token, translate => true );
	           hr_utility.raise_error;
		WHEN UNIQUE_AST_NUMBER THEN
			fnd_message.set_name('PER', 'HR_377206_SE_UNIQUE_AST_NUMBER');
		        hr_utility.raise_error;

			WHEN UNIQUE_ORG_NUMBER THEN
			fnd_message.set_name('PER', 'HR_377214_SE_UNIQUE_ORG_NUMBER');
		        hr_utility.raise_error;

			WHEN UNIQUE_MAIN_LOCAL_UNIT THEN
			fnd_message.set_name('PER', 'HR_377208_SE_MAIN_LOCAL_UNIT');
		        hr_utility.raise_error;

			WHEN UNIQUE_LOCAL_UNITS THEN
			fnd_message.set_name('PER', 'HR_377210_SE_UNIQUE_LOCAL_UNIT');
		        hr_utility.raise_error;

		WHEN UNIQUE_LE_AP
		THEN
			fnd_message.set_name('PAY', 'HR_377227_SE_LE_UNIQ_MILE_RATE');
		        hr_utility.raise_error;

		WHEN INVALID_DATE
			THEN
			fnd_message.set_name('PAY', 'HR_377228_SE_VALID_DATE');
		        hr_utility.raise_error;

		WHEN INVALID_TAX
			THEN
			fnd_message.set_name('PAY', 'HR_377234_SE_TAX_DECL');
			hr_utility.raise_error;

		WHEN INVALID_YEAR
			THEN
			fnd_message.set_name('PAY', 'HR_377236_SE_INVALID_YEAR');
			hr_utility.raise_error;

		WHEN INVALID_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377237_SE_INVALID_DECIMAL');
			hr_utility.raise_error;
		WHEN INVALID_CATEGORY
			THEN
			fnd_message.set_name('PAY', 'HR_377240_SE_INVALID_CATEGORY');
			hr_utility.raise_error;
		WHEN INVALID_UPDATE
			THEN
			fnd_message.set_name('PAY', 'HR_377241_SE_INVALID_UPDATE');
			hr_utility.raise_error;
		WHEN INVALID_INSURANCE_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377248_SE_INVALID_INSURANCE');
			hr_utility.raise_error;
		WHEN INVALID_VALUE
			THEN
			fnd_message.set_name('PAY', 'HR_377249_SE_INVALID_VALUE');
			fnd_message.set_token('X',to_char(l_global_value));
			hr_utility.raise_error;
		WHEN INVALID_INSURANCE_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377250_SE_INVALID_INS_DECIM');
			hr_utility.raise_error;
                WHEN UNIQUE_YEAR
		        THEN
			fnd_message.set_name('PER', 'HR_377270_SE_STD_WORK_YEAR');
			hr_utility.raise_error;
		WHEN INVALID_MEMBERSHIP_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377263_SE_INVALID_MEMBER');
			hr_utility.raise_error;
		WHEN INVALID_MEMBERSHIP_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377264_SE_INVALID_MEM_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_WORK_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377265_SE_INVALID_WORK');
			hr_utility.raise_error;
		WHEN INVALID_WORK_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377266_SE_INVALID_WOR_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_ASSOCIATION_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377267_SE_INVALID_ASSOCIAT');
			hr_utility.raise_error;
		WHEN INVALID_ASSOCIATION_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377268_SE_INVALID_ASS_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377261_SE_AGREEMENT_CODE');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377269_SE_INVALID_AGR_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_NUM
			THEN
			fnd_message.set_name('PAY', 'HR_377271_SE_AGREEMENT_NUMBER');
			hr_utility.raise_error;


 END validate_create_org_inf;


--___________________________________________END OF VALIDATE_CREATE_ORG_INF_____________________________________________

--___________________________________________VALIDATE_UPDATE_ORG_INF_____________________________________________
 PROCEDURE validate_update_org_inf
  (p_org_info_type_code		IN	VARCHAR2
  ,p_org_information_id		IN 	NUMBER
  ,p_org_information1		IN	VARCHAR2 DEFAULT null
  ,p_org_information2		IN	VARCHAR2 DEFAULT null
  ,p_org_information3		IN	VARCHAR2 DEFAULT null
  ,p_org_information4		IN	VARCHAR2 DEFAULT null
  ,p_org_information5		IN	VARCHAR2 DEFAULT null
  ,p_org_information6		IN	VARCHAR2 DEFAULT null
  ,p_org_information7		IN  VARCHAR2 DEFAULT null
  ,p_org_information8		IN  VARCHAR2 DEFAULT null
  ,p_org_information9		IN  VARCHAR2 DEFAULT null
  ,p_org_information10		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information11		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information12		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information13		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information14		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information15		IN  VARCHAR2 DEFAULT NULL
  ,p_org_information16		IN  VARCHAR2 DEFAULT null
  ) IS

	l_count						NUMBER ;
	l_business_group_id				hr_organization_units.business_group_id%TYPE;
	l_org_information1				hr_organization_information.org_information1%TYPE;
	l_field						VARCHAR2(300) := NULL;
	l_organization_id				hr_organization_information.organization_id%TYPE;
	l_main_lc_status				hr_organization_information.org_information6%TYPE;

l_token varchar2(300);
l_prev_holiday_start					varchar2(30);
l_prev_holiday_end					varchar2(30);
l_prev_Accounting_start					varchar2(30);
l_prev_Accounting_end					varchar2(30);
l_number						number;

	UNIQUE_AST_NUMBER				EXCEPTION;
	UNIQUE_ORG_NUMBER				EXCEPTION;
	UNIQUE_MAIN_LOCAL_UNIT				EXCEPTION;
	UNIQUE_LOCAL_UNITS				EXCEPTION;
	UNIQUE_LE_AP					EXCEPTION;
	INVALID_DATE					EXCEPTION;
	INVALID_TAX					EXCEPTION;
	INVALID_YEAR					EXCEPTION;
	INVALID_DECIMAL					EXCEPTION;
	ENTER_ALL					EXCEPTION;
	ENTER_GROUP_BY					EXCEPTION;
	INVALID_CATEGORY				EXCEPTION;
	INVALID_UPDATE					EXCEPTION;
	INVALID_INSURANCE_NUMBER			EXCEPTION;
	INVALID_VALUE					EXCEPTION;
	INVALID_INSURANCE_DECIMAL			EXCEPTION;
	UNIQUE_YEAR              			EXCEPTION;
	INVALID_MEMBERSHIP_NUMBER			EXCEPTION;
	INVALID_MEMBERSHIP_DECIMAL			EXCEPTION;
	INVALID_WORK_NUMBER				EXCEPTION;
	INVALID_WORK_DECIMAL				EXCEPTION;
	INVALID_ASSOCIATION_NUMBER			EXCEPTION;
	INVALID_ASSOCIATION_DECIMAL			EXCEPTION;
	INVALID_AGREEMENT_NUMBER			EXCEPTION;
	INVALID_AGREEMENT_DECIMAL			EXCEPTION;
	INVALID_AGREEMENT_NUM				EXCEPTION;
	CURSOR	getbgid IS
	SELECT	business_group_id
	FROM	hr_all_organization_units
	where	organization_id = l_organization_id;

	CURSOR	getorgid IS
		SELECT	organization_id
		FROM 	hr_organization_information
		WHERE 	org_information_id = p_org_information_id;

/*
	CURSOR	orglocalunit IS
		SELECT 	o.organization_id
		FROM 	hr_organization_units o , hr_organization_information hoi  ,  FND_SESSIONS s
		WHERE 	 o.organization_id = hoi.organization_id
		AND 	hoi.org_information_context = 'CLASS'
		AND 	hoi.org_information1 = 'SE_LOCAL_UNIT'
		AND 	to_char(o.organization_id) IN
					(
					SELECT	hoinf.org_information1
					FROM	hr_organization_units org, hr_organization_information hoinf
					WHERE	org.business_group_id = l_business_group_id
					AND	org.organization_id = hoinf.organization_id
					AND	org.organization_id <> l_organization_id
					AND	hoinf.org_information_context = 'SE_LOCAL_UNITS'
					)
		AND	s.session_id = userenv('sessionid')
		AND	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		ORDER BY o.name;
		*/

CURSOR	orglocalunit IS select	o.organization_id
		from	hr_organization_units o ,
				hr_organization_information hoi,
			 hr_organization_information hoinf,
				FND_SESSIONS s
		where	o.organization_id = hoi.organization_id
		and o.business_group_id = l_business_group_id
		and	hoi.org_information_context = 'CLASS'
		and	hoi.org_information1 = 'SE_LOCAL_UNIT'
		and hoinf.org_information_context = 'SE_LOCAL_UNITS'
		AND	hoinf.organization_id <> l_organization_id
		and to_char(o.organization_id) = hoinf.org_information1
		and	s.session_id = userenv('sessionid')
		and	s.effective_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		ORDER BY o.name;
/*
	CURSOR  ast_number IS
	select count(hoi2.org_information1)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information1 = p_org_information1
	and hoi2.organization_id  <> l_organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  IN
	(select hoi3.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.organization_id = l_organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'   ) );
	*/
CURSOR FIND_LEGAL_EMPLOYER IS
		select hoi3.organization_id
		from HR_ALL_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		WHERE  o1.business_group_id =l_business_group_id
		and hoi1.organization_id = o1.organization_id
		and hoi1.organization_id = l_organization_id
		and hoi1.org_information1 = 'SE_LOCAL_UNIT'
		and hoi1.org_information_context = 'CLASS'
		and o1.organization_id = hoi2.org_information1
		and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
		and hoi2.organization_id =  hoi3.organization_id
		and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
        and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';

        L_LEGAL_EMPLOYER NUMBER;
	CURSOR  ast_number IS
	select count(hoi2.org_information1)
    from HR_ALL_ORGANIZATION_UNITS o1
		      , HR_ORGANIZATION_INFORMATION hoi1
		      , HR_ORGANIZATION_INFORMATION hoi2
		      , HR_ORGANIZATION_INFORMATION hoi3
		      , HR_ORGANIZATION_INFORMATION hoi4
		      WHERE o1.business_group_id =l_business_group_id
		      and hoi1.organization_id = o1.organization_id
		      and hoi1.org_information1 = 'SE_LOCAL_UNIT'
		      and hoi1.org_information_context = 'CLASS'
		      and o1.organization_id = hoi2.organization_id
		      and hoi2.org_information1 = p_org_information1
              and hoi2.organization_id  <> l_organization_id
		      and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
		      and hoi2.organization_id =   hoi4.org_information1
		      and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		      and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		      and hoi4.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
		      and hoi4.organization_id =  hoi3.organization_id
      and hoi4.organization_id = L_LEGAL_EMPLOYER;


/*
	CURSOR  main_lc IS
	select count(hoi2.org_information6)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.organization_id  <> l_organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi3.organization_id  IN
	(select hoi3.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.organization_id = l_organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'   ) );

*/	CURSOR  main_lc IS
	select count(hoi2.org_information6)
      from HR_ALL_ORGANIZATION_UNITS o1
      , HR_ORGANIZATION_INFORMATION hoi1
      , HR_ORGANIZATION_INFORMATION hoi2
      , HR_ORGANIZATION_INFORMATION hoi3
      , HR_ORGANIZATION_INFORMATION hoi4
      WHERE o1.business_group_id =l_business_group_id
      and hoi1.organization_id = o1.organization_id
      and hoi1.org_information1 = 'SE_LOCAL_UNIT'
      and hoi1.org_information_context = 'CLASS'
      and o1.organization_id = hoi2.organization_id
      and hoi2.org_information6 = 'Y'
	  and hoi2.organization_id  <> l_organization_id
      and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
      and hoi2.organization_id =   hoi4.org_information1
      and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
      and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
      and hoi4.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
      and hoi4.organization_id =  hoi3.organization_id
      and hoi4.organization_id = L_LEGAL_EMPLOYER;
/*

CURSOR  main_lc_le IS
	select count(hoi2.org_information6)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	and hoi2.org_information_id <> p_org_information_id
	AND hoi3.organization_id  = l_organization_id );*/
CURSOR  main_lc_le IS select count(hoi2.org_information6)
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	, HR_ORGANIZATION_INFORMATION hoi4
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.org_information6 = 'Y'
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and o1.organization_id = hoi3.org_information1
	and hoi3.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi3.org_information_id <> p_org_information_id
	and hoi3.organization_id =  hoi4.organization_id
	and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi4.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi4.organization_id  = l_organization_id ;
/*
	CURSOR  ast_number_le IS
	select count(hoi2.org_information1)
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.organization_id  <> P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
	and hoi2.org_information1 in
	(select hoi2.org_information1
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi2.organization_id  = P_ORG_INFORMATION1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
        )
	and  hoi1.organization_id in
	(select hoi1.organization_id
	from HR_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	, HR_ORGANIZATION_INFORMATION hoi3
	WHERE  o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
	and hoi2.organization_id =  hoi3.organization_id
	and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
	and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
	and hoi2.org_information_id <> p_org_information_id
	AND hoi3.organization_id  = l_organization_id);
*/
	CURSOR  ast_number_le IS
	select count(hoi2.org_information1)
			from HR_ALL_ORGANIZATION_UNITS o1
			, HR_ORGANIZATION_INFORMATION hoi1
			, HR_ORGANIZATION_INFORMATION hoi2
			, HR_ORGANIZATION_INFORMATION hoi3
			, HR_ORGANIZATION_INFORMATION hoi4
			, HR_ORGANIZATION_INFORMATION hoi5
			WHERE o1.business_group_id =l_business_group_id
			and hoi1.organization_id = o1.organization_id
			and hoi1.org_information1 = 'SE_LOCAL_UNIT'
			and hoi1.org_information_context = 'CLASS'
			and o1.organization_id = hoi2.organization_id
			and hoi2.organization_id  <> p_org_information1
			and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
			and o1.organization_id = hoi3.org_information1
			and hoi3.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
			and hoi3.org_information_id <> p_org_information_id
			and hoi3.organization_id =  hoi4.organization_id
			and hoi4.ORG_INFORMATION_CONTEXT='CLASS'
			and hoi4.org_information1 = 'HR_LEGAL_EMPLOYER'
			AND hoi4.organization_id  = l_organization_id
			and to_char(hoi5.organization_id)  = p_org_information1
			and hoi5.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS'
        	and hoi2.org_information1 = hoi5.org_information1;

		CURSOR tax_lc(l_param1 varchar2,l_param2 number) IS
		        select count(hoi1.org_information1)
		        from HR_ALL_ORGANIZATION_UNITS o1
		        ,HR_ORGANIZATION_INFORMATION hoi1
		        ,HR_ORGANIZATION_INFORMATION hoi2
		        WHERE o1.business_group_id =l_business_group_id
		        and o1.organization_id=hoi1.organization_id
		        and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
		        and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
		        and hoi2.ORG_INFORMATION_CONTEXT='SE_TAX_DECLARATION_DETAILS'
		        and hoi2.organization_id =  hoi1.organization_id
		        and hoi2.org_information1=l_param1
		        and hoi2.org_information2=l_param2
		        and hoi2.organization_id = l_organization_id
			and hoi2.org_information_id <> p_org_information_id;

CURSOR absence_cat_limit(l_param1 varchar2) IS
select count(hoi1.org_information1)
from HR_ALL_ORGANIZATION_UNITS o1
,HR_ORGANIZATION_INFORMATION hoi1
,HR_ORGANIZATION_INFORMATION hoi2
WHERE o1.business_group_id =l_business_group_id
and o1.organization_id=hoi1.organization_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
and hoi2.ORG_INFORMATION_CONTEXT='SE_ABSENCE_CATEGORY_LIMIT'
and hoi2.organization_id =  hoi1.organization_id
and hoi2.org_information1=l_param1
and hoi2.organization_id = l_organization_id
and hoi2.org_information_id <> p_org_information_id;

	CURSOR  org_number IS
	select count(hoi2.org_information2)
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi1.organization_id = hoi2.organization_id
	and hoi2.org_information2 = p_org_information2
	and o1.organization_id <> l_organization_id
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS';

	CURSOR  main_lc_status IS
	select hoi2.org_information6
	from HR_ALL_ORGANIZATION_UNITS o1
	, HR_ORGANIZATION_INFORMATION hoi1
	, HR_ORGANIZATION_INFORMATION hoi2
	WHERE o1.business_group_id =l_business_group_id
	and hoi1.organization_id = o1.organization_id
	and hoi1.org_information1 = 'SE_LOCAL_UNIT'
	and hoi1.org_information_context = 'CLASS'
	and o1.organization_id = hoi2.organization_id
	and hoi1.organization_id = hoi2.organization_id
	and o1.organization_id = p_org_information1
	and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNIT_DETAILS';




CURSOR c_upd_le_ap_dtls IS
	SELECT 	COUNT(*)
	FROM 	hr_organization_information hoi, hr_all_organization_units ou
	WHERE 	(hoi.org_information_context = 'SE_COMPANY_MILEAGE_RATES')
	AND 	ou.organization_id = hoi.organization_id
	AND 	ou.organization_id = nvl(l_organization_id , 0)
	AND	ou.business_group_id = l_business_group_id
	AND	 (( fnd_date.canonical_to_date(p_org_information4) between  fnd_date.canonical_to_date(hoi.org_information4) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(hoi.org_information4) AND
	nvl(fnd_date.canonical_to_date(hoi.org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( fnd_date.canonical_to_date(hoi.org_information4) between  fnd_date.canonical_to_date(p_org_information4) AND
	nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY')))
	OR  ( nvl(fnd_date.canonical_to_date(hoi.org_information5),to_date('31/12/4712','DD/MM/YYYY')) between  fnd_date.canonical_to_date(p_org_information4) AND
	nvl(fnd_date.canonical_to_date(p_org_information5),to_date('31/12/4712','DD/MM/YYYY'))))
	AND	hoi.org_information_id <> p_org_information_id	;

CURSOR c_legal IS
SELECT ORG_INFORMATION1,ORG_INFORMATION2,
ORG_INFORMATION3,ORG_INFORMATION4
FROM hr_organization_information
WHERE org_information_id=p_org_information_id;

CURSOR csr_global(csr_v_global VARCHAR2 )IS
SELECT nvl(global_value,0) FROM ff_globals_f,
	FND_SESSIONS s
	WHERE GLOBAL_NAME=csr_v_global --'SE_EMPLOYER_TAX_PERC'
	AND legislation_code='SE'
	and s.effective_date --p_effective_date
	BETWEEN effective_start_date AND
	effective_end_date
	AND s.session_id=userenv('sessionid');

CURSOR csr_agreement_meaning(csr_v_lookup_code varchar2) is
SELECT
trim(meaning)
FROM hr_lookups
WHERE lookup_type='SE_AGREEMENT_CODE'
AND lookup_code=TRIM(csr_v_lookup_code);

l_global_value NUMBER;
l_agreement_meaning varchar2(50);

CURSOR csr_year IS
SELECT count(*)
FROM   hr_organization_information hoi, hr_organization_units ou, fnd_sessions s
WHERE  hoi.org_information_context = 'SE_STD_WORK_DETAILS'
AND    ou.organization_id = hoi.organization_id
AND    ou.organization_id = nvl (l_organization_id, 0)
AND    ou.business_group_id = l_business_group_id
AND    hoi.org_information1 = p_org_information1
AND    hoi.org_information_id <> p_org_information_id
AND    s.session_id = userenv ('sessionid')
AND    s.effective_date BETWEEN ou.date_from AND nvl (ou.date_to, TO_DATE ('31/12/4712', 'DD/MM/YYYY'));

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --

	 OPEN	getorgid;
		FETCH  getorgid INTO  l_organization_id;
	CLOSE	getorgid;


	OPEN 	getbgid;
		FETCH  getbgid INTO  l_business_group_id;
	CLOSE 	getbgid;

	IF   p_org_info_type_code = 'SE_LOCAL_UNITS'  THEN
		OPEN  orglocalunit;
			LOOP
			FETCH  orglocalunit into l_org_information1;
			EXIT  WHEN  orglocalunit%NOTFOUND;
				IF  l_org_information1 = p_org_information1 then
					RAISE UNIQUE_LOCAL_UNITS ;
				END IF ;
			END LOOP;
		CLOSE orglocalunit;

			OPEN ast_number_le;
				FETCH  ast_number_le INTO l_count;
			CLOSE ast_number_le;
			IF l_count > 0	THEN
				RAISE UNIQUE_AST_NUMBER ;
			END IF ;

			OPEN main_lc_status;
			FETCH  main_lc_status INTO l_main_lc_status;
			CLOSE main_lc_status;

			IF l_main_lc_status ='Y' then
				OPEN main_lc_le;
				FETCH  main_lc_le INTO l_count;
				CLOSE main_lc_le;
				IF l_count > 0	THEN
					RAISE UNIQUE_MAIN_LOCAL_UNIT ;
				END IF ;
			END IF;



	ELSIF p_org_info_type_code = 'SE_LOCAL_UNIT_DETAILS' THEN
		-- validate for presence of Decimals in AST Number
		validate_number(p_org_information1,hr_general.decode_lookup('SE_FORM_LABELS','AST'));
		-- validate for Uniqness of AST Number within a Legal Employer


		IF p_org_information1 IS NOT NULL THEN
			OPEN FIND_LEGAL_EMPLOYER;
			FETCH  FIND_LEGAL_EMPLOYER INTO L_LEGAL_EMPLOYER;
			CLOSE FIND_LEGAL_EMPLOYER;

			OPEN ast_number;
			FETCH  ast_number INTO l_count;
			CLOSE ast_number;
			IF l_count > 0	THEN
				RAISE UNIQUE_AST_NUMBER ;
			END IF ;
		END IF;

		-- validate for presence of Decimals in CFAR Number
		validate_number(p_org_information2,hr_general.decode_lookup('SE_FORM_LABELS','CFAR'));

		IF p_org_information6 ='Y' THEN
			OPEN FIND_LEGAL_EMPLOYER;
			FETCH  FIND_LEGAL_EMPLOYER INTO L_LEGAL_EMPLOYER;
			CLOSE FIND_LEGAL_EMPLOYER;

			OPEN main_lc;
			FETCH  main_lc INTO l_count;
			CLOSE main_lc;
			IF l_count > 0	THEN
				RAISE UNIQUE_MAIN_LOCAL_UNIT ;
			END IF ;
		END IF;


	ELSIF p_org_info_type_code = 'SE_LEGAL_EMPLOYER_DETAILS' THEN
		-- validate for presence of Decimals in Confederation Number
		validate_number(p_org_information1,hr_general.decode_lookup('SE_FORM_LABELS','CONFD'));
		-- validate for presence of Decimals in Organization Number
		validate_number(p_org_information2,hr_general.decode_lookup('SE_FORM_LABELS','ORG'));

		-- validate for Uniqness of Organization Number within a Legal Employer
		IF p_org_information2 IS NOT NULL THEN
			OPEN org_number;
			FETCH  org_number INTO l_count;
			CLOSE org_number;
			IF l_count > 0	THEN
				RAISE UNIQUE_ORG_NUMBER ;
			END IF ;
			IF  length(p_org_information6) <7 THEN
				RAISE INVALID_INSURANCE_NUMBER;
			END IF;

		END IF;

		IF instr(p_org_information6,'.')>0 THEN
				RAISE INVALID_INSURANCE_DECIMAL;
		END IF;
		--Membership Number
		IF  length(p_org_information9) <7 THEN
			RAISE INVALID_MEMBERSHIP_NUMBER;
		END IF;
		IF instr(p_org_information9,'.')>0 THEN
				RAISE INVALID_MEMBERSHIP_DECIMAL;
		END IF;

	ELSIF p_org_info_type_code ='SE_SALARY_STRUCTURE' THEN
		--Working Site Number
		IF  length(p_org_information1) <3 THEN
			RAISE INVALID_WORK_NUMBER;
		END IF;
		IF instr(p_org_information1,'.')>0 THEN
			RAISE INVALID_WORK_DECIMAL;
		END IF;
		--Association Number
		IF  length(p_org_information2) <2 THEN
			RAISE INVALID_ASSOCIATION_NUMBER;
		END IF;
		IF instr(p_org_information2,'.')>0 THEN
			RAISE INVALID_ASSOCIATION_DECIMAL;
		END IF;
		--Agreement Number
		OPEN csr_agreement_meaning(p_org_information3);
			FETCH csr_agreement_meaning INTO l_agreement_meaning;
		CLOSE csr_agreement_meaning;

		BEGIN
		l_number:=to_number(l_agreement_meaning);
		EXCEPTION
		WHEN OTHERS THEN
			RAISE INVALID_AGREEMENT_NUM;
		END;
		/*IF  translate(l_agreement_meaning,'_0123456789.','_') IS NOT NULL THEN
			RAISE INVALID_AGREEMENT_NUM;
		END IF;*/

		IF  length(l_agreement_meaning) <>3 THEN
			RAISE INVALID_AGREEMENT_NUMBER;
		END IF;
		IF instr(l_agreement_meaning,'.')>0 THEN
			RAISE INVALID_AGREEMENT_DECIMAL;
		END IF;


	ELSIF p_org_info_type_code = 'SE_COMPANY_MILEAGE_RATES' THEN

		IF fnd_date.canonical_to_date(p_org_information5) < fnd_date.canonical_to_date(p_org_information4) THEN
			RAISE INVALID_DATE ;
		END IF;

		OPEN  c_upd_le_ap_dtls ;
			FETCH   c_upd_le_ap_dtls  INTO l_count;
		CLOSE  c_upd_le_ap_dtls ;
		IF l_count > 0	THEN
			RAISE UNIQUE_LE_AP ;
		END IF ;
	ELSIF p_org_info_type_code='SE_TAX_DECLARATION_DETAILS' THEN
		IF (p_org_information2 <= 0) OR (p_org_information2 > 4712) THEN
			RAISE INVALID_YEAR;
		END IF;

		IF instr(p_org_information2,'.')>0 THEN
			RAISE INVALID_DECIMAL;
		END IF;

			OPEN tax_lc(p_org_information1,p_org_information2);
			FETCH  tax_lc INTO l_count;
			CLOSE tax_lc;
			IF l_count > 0	THEN
				RAISE INVALID_TAX ;
			END IF ;

		OPEN csr_global('SE_COMPANY_PERC_MAX');
			FETCH csr_global INTO l_global_value;
		CLOSE csr_global;


		IF p_org_information10>l_global_value THEN
			RAISE INVALID_VALUE ;
		END IF;
		l_global_value:=null;

		OPEN csr_global('SE_EXT_COMPANY_PERC_MAX');
			FETCH csr_global INTO l_global_value;
		CLOSE csr_global;

		IF p_org_information12>l_global_value THEN
			RAISE INVALID_VALUE ;
		END IF;

	ELSIF  p_org_info_type_code='SE_ABSENCE_CATEGORY_LIMIT' THEN
		OPEN  absence_cat_limit(p_org_information1);
			FETCH absence_cat_limit INTO l_count;
		CLOSE absence_cat_limit;
		IF l_count>0 THEN
			RAISE INVALID_CATEGORY;
		END IF;
	ELSIF p_org_info_type_code='SE_HOLIDAY_YEAR_DEFN' THEN
		IF p_org_information5 ='Y'   THEN
			OPEN c_legal;
				FETCH c_legal INTO l_prev_holiday_start,l_prev_holiday_end,
				l_prev_Accounting_start,l_prev_Accounting_end;
			CLOSE c_legal;

			IF p_org_information1<>l_prev_holiday_start OR p_org_information2<> l_prev_holiday_end
			OR p_org_information3<>l_prev_Accounting_start OR p_org_information4<> l_prev_Accounting_end THEN
              			Raise INVALID_UPDATE;
			END IF;

		END IF;
	ELSIF p_org_info_type_code='SE_INSURANCE_NUMBER' THEN
		IF  length(p_org_information1) <7 THEN
			RAISE INVALID_INSURANCE_NUMBER;
		END IF;
		IF instr(p_org_information1,'.')>0 THEN
			RAISE INVALID_INSURANCE_DECIMAL;
		END IF;

	ELSIF p_org_info_type_code='SE_SOE_ELEMENT_ADD_DETAILS' THEN
		IF p_org_information5 ='I'
		THEN
			IF p_org_information7 IS NULL
			or p_org_information8 is NULL
			or p_org_information9 IS NULL
			or p_org_information10 IS NULL
			THEN
			      Raise ENTER_ALL;
			END IF;
		 END IF;
		IF p_org_information4='O'
		THEN
		        IF p_org_information6 is null
		        THEN
		            RAISE ENTER_GROUP_BY;
		        END IF;
		END IF;
	 ELSIF p_org_info_type_code= 'SE_STD_WORK_DETAILS' THEN
	  OPEN  csr_year;
			FETCH csr_year INTO l_count;
	  CLOSE csr_year;
	  IF l_count > 0   THEN
			RAISE UNIQUE_YEAR;
	  END IF;

	END IF ;
  END IF;
EXCEPTION

	WHEN ENTER_GROUP_BY THEN
	            fnd_message.set_name('PER','HR_377202_SE_MANDATORY_MSG');
			l_token := hr_general.decode_lookup('SE_FORM_LABELS','GBP');
	            fnd_message.set_token('NAME',l_token, translate => true );
	            hr_utility.raise_error;

    	WHEN ENTER_ALL THEN
	           fnd_message.set_name('PER','HR_377202_SE_MANDATORY_MSG');
			l_token := hr_general.decode_lookup('SE_FORM_LABELS','UNIT') || ','||
			hr_general.decode_lookup('SE_FORM_LABELS','UP') || ','||
			hr_general.decode_lookup('SE_FORM_LABELS','AMT') || ','||
			hr_general.decode_lookup('SE_FORM_LABELS','GBU');
	           fnd_message.set_token('NAME',l_token, translate => true );
	           hr_utility.raise_error;
	WHEN UNIQUE_AST_NUMBER THEN

			fnd_message.set_name('PER', 'HR_377206_SE_UNIQUE_AST_NUMBER');
		        hr_utility.raise_error;

		WHEN UNIQUE_ORG_NUMBER THEN
			fnd_message.set_name('PER', 'HR_377214_SE_UNIQUE_ORG_NUMBER');
		        hr_utility.raise_error;


		WHEN UNIQUE_MAIN_LOCAL_UNIT THEN
			fnd_message.set_name('PER', 'HR_377208_SE_MAIN_LOCAL_UNIT');
		        hr_utility.raise_error;

		WHEN UNIQUE_LOCAL_UNITS THEN
			fnd_message.set_name('PER', 'HR_377210_SE_UNIQUE_LOCAL_UNIT');
		        hr_utility.raise_error;
		WHEN UNIQUE_LE_AP
		THEN
			fnd_message.set_name('PAY', 'HR_377227_SE_LE_UNIQ_MILE_RATE');
		        hr_utility.raise_error;

		WHEN INVALID_DATE
			THEN
			fnd_message.set_name('PAY', 'HR_377228_SE_VALID_DATE');
		        hr_utility.raise_error;
		WHEN INVALID_TAX
			THEN
			fnd_message.set_name('PAY', 'HR_377234_SE_TAX_DECL');
			hr_utility.raise_error;

		WHEN INVALID_YEAR
			THEN
			fnd_message.set_name('PAY', 'HR_377236_SE_INVALID_YEAR');
			hr_utility.raise_error;

		WHEN INVALID_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377237_SE_INVALID_DECIMAL');
			hr_utility.raise_error;
		WHEN INVALID_CATEGORY
			THEN
			fnd_message.set_name('PAY', 'HR_377240_SE_INVALID_CATEGORY');
			hr_utility.raise_error;
		WHEN INVALID_UPDATE
			THEN
			fnd_message.set_name('PAY', 'HR_377241_SE_INVALID_UPDATE');
			hr_utility.raise_error;
		WHEN INVALID_INSURANCE_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377248_SE_INVALID_INSURANCE');
			hr_utility.raise_error;
		WHEN INVALID_VALUE
			THEN
			fnd_message.set_name('PAY', 'HR_377249_SE_INVALID_VALUE');
			fnd_message.set_token('X',to_char(l_global_value));
			hr_utility.raise_error;
		WHEN INVALID_INSURANCE_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377250_SE_INVALID_INS_DECIM');
			hr_utility.raise_error;
		WHEN UNIQUE_YEAR
		        THEN
			fnd_message.set_name('PER', 'HR_377270_SE_STD_WORK_YEAR');
			hr_utility.raise_error;
		WHEN INVALID_MEMBERSHIP_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377263_SE_INVALID_MEMBER');
			hr_utility.raise_error;
		WHEN INVALID_MEMBERSHIP_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377264_SE_INVALID_MEM_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_WORK_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377265_SE_INVALID_WORK');
			hr_utility.raise_error;
		WHEN INVALID_WORK_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377266_SE_INVALID_WOR_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_ASSOCIATION_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377267_SE_INVALID_ASSOCIAT');
			hr_utility.raise_error;
		WHEN INVALID_ASSOCIATION_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377268_SE_INVALID_ASS_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_NUMBER
			THEN
			fnd_message.set_name('PAY', 'HR_377261_SE_AGREEMENT_CODE');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_DECIMAL
			THEN
			fnd_message.set_name('PAY', 'HR_377269_SE_INVALID_AGR_DECIM');
			hr_utility.raise_error;
		WHEN INVALID_AGREEMENT_NUM
			THEN
			fnd_message.set_name('PAY', 'HR_377271_SE_AGREEMENT_NUMBER');
			hr_utility.raise_error;



 END validate_update_org_inf;

 --- End Of validate_update_org_inf



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
			IF p_token IS NOT NULL
			THEN
				fnd_message.set_name('PER', 'HR_377207_SE_INVALID_FORMAT');
			        fnd_message.set_token('NAME',p_token, translate => true );
			        hr_utility.raise_error;
			ELSE
				fnd_message.set_name('PER', p_message);
			        hr_utility.raise_error;
			END IF ;

		END IF;
	END IF;

  END VALIDATE_NUMBER;

------------------inserted code
--   Validation While creating the Classifications for Organization

 PROCEDURE  CREATE_ORG_CLASS_VALIDATE
  (P_ORGANIZATION_ID                IN	    NUMBER
  ,P_ORG_INFORMATION1               IN      VARCHAR2
  )IS

	l_internal_external_flag	hr_organization_units.INTERNAL_EXTERNAL_FLAG%type;
	INT_EXT_EXCEPTION		exception;

CURSOR	get_int_or_ext_flag
IS
	SELECT	INTERNAL_EXTERNAL_FLAG
	FROM	HR_all_ORGANIZATION_UNITS
	WHERE	ORGANIZATION_ID = P_ORGANIZATION_ID;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --
	OPEN  get_int_or_ext_flag;
		FETCH  get_int_or_ext_flag INTO  l_internal_external_flag;
	CLOSE  get_int_or_ext_flag;

	IF l_internal_external_flag = 'INT'
	THEN
		IF  P_ORG_INFORMATION1 = 'SE_SOC_SEC_OFFICE'
		THEN
			RAISE INT_EXT_EXCEPTION;
		END IF;
	END IF ;
  END IF;
EXCEPTION
		WHEN INT_EXT_EXCEPTION
		THEN
			fnd_message.set_name('PER', 'HR_377211_SE_SOC_SEC_OFFICE');
		        hr_utility.raise_error;
END CREATE_ORG_CLASS_VALIDATE;
---


PROCEDURE  CREATE_ASG_VALIDATE
( p_scl_segment5                 IN      VARCHAR2  DEFAULT  NULL
 ,p_scl_segment6                 IN      VARCHAR2  DEFAULT  NULL
 ) is

	VALID_NOTIFY_DATE		EXCEPTION ;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --

	IF (p_scl_segment5 IS NOT NULL AND p_scl_segment5 <> hr_api.g_varchar2)
	    AND (p_scl_segment6 IS NOT NULL AND p_scl_segment6 <> hr_api.g_varchar2) THEN
		IF fnd_date.canonical_to_date(p_scl_segment5) >=  fnd_date.canonical_to_date(p_scl_segment6) THEN
			RAISE VALID_NOTIFY_DATE ;
		END IF;

	END IF;

  END IF;
EXCEPTION
	WHEN VALID_NOTIFY_DATE
	THEN
		fnd_message.set_name('PER', 'HR_377212_SE_VALID_NOTIFY_DATE');
		hr_utility.raise_error;

END CREATE_ASG_VALIDATE;

-- End OF Create_Asg_validate

PROCEDURE  UPDATE_ASG_VALIDATE
(
 p_segment5			IN	VARCHAR2
,p_segment6			IN	VARCHAR2
 ) IS

	VALID_NOTIFY_DATE		EXCEPTION ;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SE') THEN
    --

	IF (p_segment5 IS NOT NULL AND p_segment5 <> hr_api.g_varchar2)
	    AND (p_segment6 IS NOT NULL AND p_segment6 <> hr_api.g_varchar2) THEN
		IF fnd_date.canonical_to_date(p_segment5) >=  fnd_date.canonical_to_date(p_segment6) THEN
			RAISE VALID_NOTIFY_DATE ;
		END IF;

	END IF;
	--
  END IF;

EXCEPTION
	WHEN VALID_NOTIFY_DATE 	THEN
		fnd_message.set_name('PER', 'HR_377212_SE_VALID_NOTIFY_DATE');
		hr_utility.raise_error;

END UPDATE_ASG_VALIDATE ;

-- End Of UPDATE_ASG_VALIDATE

END hr_se_validate_pkg;


/
