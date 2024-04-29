--------------------------------------------------------
--  DDL for Package Body HR_DK_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DK_VALIDATE_PKG" AS
/* $Header: pedkvald.pkb 120.9.12010000.3 2009/05/22 12:51:45 rsahai ship $ */


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
    WHERE  ppt.system_person_type like 'EMP%'
    AND    ppt.person_type_Id = p_person_type_id;

  BEGIN
    --
    -- Added for GSI Bug 5472781
	--
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
      --
      l_type := NULL;
      OPEN c_type;
      FETCH c_type INTO l_type;
      CLOSE c_type;
      --
      --Validate not null fields
      --      IF p_first_name    IS NULL THEN
      --        l_field := hr_general.decode_lookup('DK_FORM_LABELS','FIRST_NAME');
      --      END IF;
      --
      IF l_type IS NOT NULL THEN
        IF p_national_identifier  IS NULL OR p_national_identifier = hr_api.g_varchar2 THEN
              IF l_field IS NULL THEN
              l_field := hr_general.decode_lookup('DK_FORM_LABELS','CPR');
              ELSE
                  l_field := l_field||', '||hr_general.decode_lookup('DK_FORM_LABELS','CPR');
              END IF;
        END IF;
	--Moved mandatory check for First Name here
	IF p_first_name IS NULL OR p_first_name = hr_api.g_varchar2 THEN
          l_field := hr_general.decode_lookup('DK_FORM_LABELS','FIRST_NAME');
        END IF;
      END IF;

     /*Added an additional check fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION')IN ('ERROR','WARN')*/
      IF l_field IS NOT NULL AND fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION')IN ('ERROR','WARN') THEN
        fnd_message.set_name('PER', 'HR_377002_DK_MANDATORY_MSG');
        fnd_message.set_token('NAME',l_field, translate => true );
        hr_utility.raise_error;
      END IF;
      --
    END IF;
    --
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
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
      --
      validate
        (p_person_type_id             =>  p_person_type_id
        ,p_first_name                 =>  p_first_name
        ,p_national_identifier        =>  p_national_identifier);
	  --
	END IF;
    --
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
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
      --
      per_per_bus.chk_person_type
       (p_person_type_id    => l_person_type_id
       ,p_business_group_id => p_business_group_id
       ,p_expected_sys_type => 'EMP');
	  --
      validate
        (p_person_type_id             =>  l_person_type_id
        ,p_first_name                 =>  p_first_name
        ,p_national_identifier        =>  p_national_identifier);
      --
	END IF;
	--
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
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
      --
      per_per_bus.chk_person_type
       (p_person_type_id    => l_person_type_id
       ,p_business_group_id => p_business_group_id
       ,p_expected_sys_type => 'OTHER');
	  --
      validate
       (p_person_type_id             =>  l_person_type_id
       ,p_first_name                 =>  p_first_name
       ,p_national_identifier        =>  p_national_identifier);
	  --
	END IF;
	--
  END contact_cwk_validate;

/* Bug Fix 4994922, added parameters p_org_information2 and p_org_information3 */
PROCEDURE validate_create_org_inf
  (p_org_info_type_code                 in      varchar2
  ,p_organization_id                    in      number
  ,p_org_information1                   in      varchar2
  ,p_org_information2                   in      varchar2
  ,p_org_information3                   in      varchar2
  ) IS

 l_org_information1  hr_organization_information.org_information1%TYPE;
 l_organization_id   hr_organization_units.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;

 /* Bug Fix 4994922, added record variable */
 l_sickpay_records l_rec;
 l_no_records      NUMBER ;
 l_index           NUMBER;
 l_sec27_reg       VARCHAR2(5);
 l_sec27_sd        DATE;
 l_sec27_ed        DATE;
 l_curr_sec27_sd   DATE;
 l_curr_sec27_ed   DATE;

 /* Bug 8293282 fix */
  l_effective_date  DATE;
 l_hol_acc_sd      DATE;
 l_hol_acc_ed      DATE;

 cursor getbgid is
        select business_group_id
        from hr_organization_units
        where organization_id = p_organization_id;

 cursor orgnum is
        select orgif.org_information1 from hr_organization_information orgif,hr_organization_units ou
        where  ( orgif.org_information_context = 'DK_SERVICE_PROVIDER_DETAILS' or orgif.org_information_context = 'DK_LEGAL_ENTITY_DETAILS')
        and    ou.organization_id = orgif.organization_id
        and    orgif.org_information1 = p_org_information1;

/* Bug Fix 4994922  added cursor csr_get_sickpay_defaults */
cursor csr_get_sickpay_defaults(p_business_group_id NUMBER) is
        select orgif.org_information1, orgif.org_information2, orgif.org_information3
	from   hr_organization_information orgif,hr_organization_units ou
        where  orgif.org_information_context = 'DK_SICKPAY_DEFAULTS'
        and    ou.business_group_id =  p_business_group_id
	and    ou.organization_id = p_organization_id
	and    ou.organization_id   = orgif.organization_id;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
    --
        open getbgid;
        fetch getbgid into l_business_group_id;
        close getbgid;

	IF p_org_info_type_code = 'DK_SERVICE_PROVIDER_DETAILS'  OR p_org_info_type_code = 'DK_LEGAL_ENTITY_DETAILS'  THEN
                open orgnum;
                fetch orgnum into l_org_information1;
                if l_org_information1 = p_org_information1 then
                        fnd_message.set_name('PER','HR_377005_DK_CVR_NUMBER_UNIQUE');
                        fnd_message.raise_error;
                end if;
                close orgnum;
        END IF;


	/* Bug Fix 4994922 */
	IF p_org_info_type_code = 'DK_SICKPAY_DEFAULTS' THEN

	    l_curr_sec27_sd := fnd_date.canonical_to_date(p_org_information2);
	    l_curr_sec27_ed := fnd_date.canonical_to_date(p_org_information3);

	    /* Check if Section 27 Registration start date is before end date */
	    IF l_curr_sec27_sd > l_curr_sec27_ed THEN
		fnd_message.set_name('PER','HR_377068_DK_SECTION27_DATES_E');
		fnd_message.raise_error;
	    END IF;

	    OPEN csr_get_sickpay_defaults(l_business_group_id);
	    FETCH csr_get_sickpay_defaults BULK COLLECT INTO l_sickpay_records;
	    CLOSE csr_get_sickpay_defaults;

	    l_no_records := l_sickpay_records.COUNT;
	    IF l_no_records = 0 THEN /* no sickpay default records found */
		  null;
	    ELSE
		  FOR l_index IN 1 .. l_no_records LOOP

		    l_sec27_reg := l_sickpay_records(l_index).value;
		    l_sec27_sd  := fnd_date.canonical_to_date(l_sickpay_records(l_index).date1);
		    l_sec27_ed  := fnd_date.canonical_to_date(l_sickpay_records(l_index).date2);

		    IF l_curr_sec27_sd BETWEEN l_sec27_sd AND l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    ELSIF l_curr_sec27_ed BETWEEN l_sec27_sd AND l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    ELSIF l_curr_sec27_sd <= l_sec27_sd AND l_curr_sec27_ed >= l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    END IF;

		  END LOOP;
	    END IF;
	END IF;
	IF p_org_info_type_code = 'DK_HOLIDAY_ENTITLEMENT_INFO' THEN

        select s.effective_date into l_effective_date from FND_SESSIONS s
            where s.session_id = userenv('sessionid');

        l_hol_acc_sd := trunc(l_effective_date,'YEAR');
        l_hol_acc_ed := last_day(trunc(l_effective_date,'YEAR'));

        IF l_effective_date BETWEEN l_hol_acc_sd AND l_hol_acc_ed THEN
            NULL;
		--fnd_message.set_name('PAY','PAY_377105_DK_HOL_ALL_RED_WARN');
    		--fnd_message.raise_error;
        ELSE
            fnd_message.set_name('PAY','PAY_377106_DK_HOL_ALL_RED_ERR');
    		fnd_message.raise_error;
        END IF;
    END IF;
  END IF;
END validate_create_org_inf;

 /* Bug Fix 4994922, added parameters p_org_information2 and p_org_information3 */
 PROCEDURE validate_update_org_inf
  (p_org_info_type_code         in       varchar2
  ,p_org_information_id         in       number
  ,p_org_information1           in       varchar2
  ,p_org_information2           in       varchar2
  ,p_org_information3           in       varchar2
  ) IS

 l_org_information1  hr_organization_information.org_information1%TYPE;
 l_organization_id hr_organization_information.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;

 /* Bug Fix 4994922, added record variable */
 l_sickpay_records l_rec;
 l_no_records      NUMBER ;
 l_index           NUMBER;
 l_sec27_reg       VARCHAR2(5);
 l_sec27_sd        DATE;
 l_sec27_ed        DATE;
 l_curr_sec27_sd   DATE;
 l_curr_sec27_ed   DATE;

  /* Bug 8293282 fix */
  l_effective_date  DATE;
 l_hol_acc_sd      DATE;
 l_hol_acc_ed      DATE;

 cursor getbgid is
 select business_group_id
 from hr_organization_units
 where organization_id = l_organization_id;

 cursor getorgid is
 select organization_id
 from hr_organization_information
 where org_information_id = p_org_information_id;

 cursor orgnum is
 select orgif.org_information1 from hr_organization_information orgif,hr_organization_units ou
 where  ( orgif.org_information_context = 'DK_SERVICE_PROVIDER_DETAILS' or orgif.org_information_context = 'DK_LEGAL_ENTITY_DETAILS')
 and ou.organization_id = orgif.organization_id
 and orgif.organization_id <> nvl(l_organization_id,0)
 and orgif.org_information1 = p_org_information1;

/* Bug Fix 4994922  added cursor csr_get_sickpay_defaults */
cursor csr_get_sickpay_defaults(p_business_group_id NUMBER, p_organization_id NUMBER) is
        select orgif.org_information1, orgif.org_information2, orgif.org_information3
	from   hr_organization_information orgif,hr_organization_units ou
        where  orgif.org_information_context = 'DK_SICKPAY_DEFAULTS'
        and    ou.business_group_id =  p_business_group_id
	and    ou.organization_id = p_organization_id
	and    ou.organization_id   = orgif.organization_id;


BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
     --
        open getorgid;
        fetch getorgid into l_organization_id;
        close getorgid;

        open getbgid;
        fetch getbgid into l_business_group_id;
        close getbgid;

        IF p_org_info_type_code = 'DK_SERVICE_PROVIDER_DETAILS'  OR p_org_info_type_code = 'DK_LEGAL_ENTITY_DETAILS'  THEN
                open orgnum;
                fetch orgnum into l_org_information1;
                if l_org_information1 = p_org_information1 then
                        fnd_message.set_name('PER','HR_377005_DK_CVR_NUMBER_UNIQUE');
                        fnd_message.raise_error;
                end if;
                close orgnum;
        END IF;

	/* Bug Fix 4994922 */
	IF p_org_info_type_code = 'DK_SICKPAY_DEFAULTS' THEN

	    l_curr_sec27_sd := fnd_date.canonical_to_date(p_org_information2);
	    l_curr_sec27_ed := fnd_date.canonical_to_date(p_org_information3);

	    /* Check if Section 27 Registration start date is before end date */
	    IF l_curr_sec27_sd > l_curr_sec27_ed THEN
		fnd_message.set_name('PER','HR_377068_DK_SECTION27_DATES_E');
		fnd_message.raise_error;
	    END IF;

	    OPEN csr_get_sickpay_defaults(l_business_group_id,l_organization_id);
	    FETCH csr_get_sickpay_defaults BULK COLLECT INTO l_sickpay_records;
	    CLOSE csr_get_sickpay_defaults;

	    l_no_records := l_sickpay_records.COUNT;
	    IF l_no_records = 0 THEN /* no sickpay default records found */
		null;
	    ELSE
		FOR l_index IN 1 .. l_no_records LOOP

		    l_sec27_reg := l_sickpay_records(l_index).value;
		    l_sec27_sd  := fnd_date.canonical_to_date(l_sickpay_records(l_index).date1);
		    l_sec27_ed  := fnd_date.canonical_to_date(l_sickpay_records(l_index).date2);

		    IF l_curr_sec27_sd BETWEEN l_sec27_sd AND l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    ELSIF l_curr_sec27_ed BETWEEN l_sec27_sd AND l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    ELSIF l_curr_sec27_sd <= l_sec27_sd AND l_curr_sec27_ed >= l_sec27_ed THEN
			fnd_message.set_name('PER','HR_377069_DK_SECTION27_OVERLAP');
			fnd_message.raise_error;
		    END IF;

		END LOOP;
	    END IF;

	END IF;
		IF p_org_info_type_code = 'DK_HOLIDAY_ENTITLEMENT_INFO' THEN

        select s.effective_date into l_effective_date from FND_SESSIONS s
            where s.session_id = userenv('sessionid');

        l_hol_acc_sd := trunc(l_effective_date,'YEAR');
        l_hol_acc_ed := last_day(trunc(l_effective_date,'YEAR'));

        IF l_effective_date BETWEEN l_hol_acc_sd AND l_hol_acc_ed THEN
            NULL;
		--fnd_message.set_name('PAY','PAY_377105_DK_HOL_ALL_RED_WARN');
    		--hr_utility.raise_error;--fnd_message.raise_error;
        ELSE
            fnd_message.set_name('PAY','PAY_377106_DK_HOL_ALL_RED_ERR');
    		fnd_message.raise_error;
        END IF;
     END IF;
  END IF;
END validate_update_org_inf;

  PROCEDURE validate_update_emp_asg
  (p_assignment_id                      in       number
  ,p_assignment_status_type_id          in number
  ,p_segment6           in      varchar2
  ,p_segment7           in      varchar2
  ,p_segment8           in      varchar2
  ,p_segment9           in      varchar2
  ) IS

  l_asg_start_date      date;
  l_field                       varchar2(200);

    cursor get_asg_creation_date is
            select creation_date from per_all_assignments_f where
           assignment_id = p_assignment_id;
  BEGIN
    --
    -- Added for GSI Bug 5472781
	--
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
      --
        IF p_assignment_status_type_id = 3 THEN
                IF p_segment6 IS NULL THEN
                        l_field := hr_general.decode_lookup('DK_FORM_LABELS','TR');
                        fnd_message.set_name('PER', 'HR_377002_DK_MANDATORY_MSG');
                        fnd_message.set_token('NAME',l_field, translate => true );
                        hr_utility.raise_error;
                END IF;

                IF p_segment7 IS NULL THEN
                        l_field := hr_general.decode_lookup('DK_FORM_LABELS','ND');
                        fnd_message.set_name('PER', 'HR_377002_DK_MANDATORY_MSG');
                        fnd_message.set_token('NAME',l_field, translate => true );
                        hr_utility.raise_error;
                END IF;

                IF p_segment8 IS NULL THEN
                        l_field := hr_general.decode_lookup('DK_FORM_LABELS','TD');
                        fnd_message.set_name('PER', 'HR_377002_DK_MANDATORY_MSG');
                        fnd_message.set_token('NAME',l_field, translate => true );
                        hr_utility.raise_error;
                END IF;
                IF p_segment9 IS NULL THEN
                        l_field := hr_general.decode_lookup('DK_FORM_LABELS','AD');
                        fnd_message.set_name('PER', 'HR_377002_DK_MANDATORY_MSG');
                        fnd_message.set_token('NAME',l_field, translate => true );
                        hr_utility.raise_error;
                END IF;

        ELSE
	  -- GSI Bug 4585094
                IF p_segment6 <> hr_api.g_varchar2 THEN
                        fnd_message.set_name('PER', 'HR_377009_DK_TR_INVALID');
                        hr_utility.raise_error;
                END IF;
	  -- GSI Bug 4585094
                IF p_segment7 <> hr_api.g_varchar2  THEN
                        fnd_message.set_name('PER', 'HR_377010_DK_ND_INVALID');
                        hr_utility.raise_error;
                END IF;
	  -- GSI Bug 4585094
                IF p_segment8 <> hr_api.g_varchar2 THEN
                        fnd_message.set_name('PER', 'HR_377011_DK_TD_INVALID');
                        hr_utility.raise_error;
                END IF;

        END IF;

        BEGIN
                OPEN get_asg_creation_date;
                FETCH get_asg_creation_date into l_asg_start_date;
                CLOSE get_asg_creation_date;
        EXCEPTION
                WHEN others THEN
                        null;
        END;

        -- Validation rule : notified date > assignment start date --
        if p_segment7 <> hr_api.g_varchar2  -- GSI Bug 4585094
	   and l_asg_start_date is not NULL then
                if fnd_date.canonical_to_date(p_segment7) < fnd_date.canonical_to_date(l_asg_start_date) then
                        fnd_message.set_name('PER', 'HR_377006_DK_NOTIFIED_DATE');
                        hr_utility.raise_error;
                end if;
        end if;
        -- Validation rule : Termination date >= notified date --
        if p_segment8 <> hr_api.g_varchar2 -- GSI Bug 4585094
	   and p_segment7 <> hr_api.g_varchar2 then
                if fnd_date.canonical_to_date(p_segment8) < fnd_date.canonical_to_date(p_segment7) then
                        fnd_message.set_name('PER', 'HR_377007_DK_TERM_DATE_ERR');
                        hr_utility.raise_error;
                end if;
        end if;
        -- Validation rule : Adjusted seniority date < notified date --
        if p_segment9 <> hr_api.g_varchar2 -- GSI Bug 4585094
 	   and p_segment7 <> hr_api.g_varchar2 then
                if fnd_date.canonical_to_date(p_segment9) >= fnd_date.canonical_to_date(p_segment7) then
                        fnd_message.set_name('PER', 'HR_377008_DK_ASD_ERR');
                        hr_utility.raise_error;
                end if;
        end if;

    END IF;
    --
  END validate_update_emp_asg;



 -- Procedure to Validate the Organization Classification
 PROCEDURE validate_create_org_cat
  (p_organization_id            in      number
  ,p_org_information1           in      varchar2
    ) IS

 l_organization_id hr_organization_units.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;
 l_int_ext_flag hr_organization_units.internal_external_flag%TYPE;
/* Added for bug fix 4227055 */
 l_sp                    hr_organization_units.organization_id%TYPE;

 SP_DATA_FOUND           EXCEPTION;

  cursor orgtype is
             select ou.internal_external_flag from hr_organization_units ou ,FND_SESSIONS s
             where ou.organization_id= p_organization_id
             and s.session_id = userenv('sessionid')
             and s.effective_date between ou.date_from and nvl(ou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

/* Added for bug fix 4227055 */
/* Not more than one Service Provider can be created in a Business Group */
--
  CURSOR get_sp( p_business_group_id hr_organization_units.business_group_id%TYPE) IS
          select count(hou.organization_id)
          from HR_ORGANIZATION_INFORMATION hoi
              ,HR_ORGANIZATION_UNITS hou
              ,FND_SESSIONS s
          where hoi.org_information_context ='CLASS'
          and hoi.org_information1 ='DK_SERVICE_PROVIDER'
          and hou.organization_id = hoi.organization_id
          and hou.BUSINESS_GROUP_ID = p_business_group_id
          and s.session_id = userenv('sessionid')
          and s.effective_date between hou.date_from and nvl(hou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

 CURSOR getbgid is
        select business_group_id
        from hr_organization_units
        where organization_id = p_organization_id;
--
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'DK') THEN
    --
        IF p_org_information1 = 'DK_PENSION_PROVIDER'  THEN

           open orgtype;
           fetch orgtype into l_int_ext_flag;
           close orgtype;

           if l_int_ext_flag='INT' then
                fnd_message.set_name('PER','HR_377013_DK_PENSION_PVDR');
                fnd_message.raise_error;
           end if;

        END IF;

        IF p_org_information1 = 'DK_SERVICE_PROVIDER'  THEN

           open orgtype;
           fetch orgtype into l_int_ext_flag;
           close orgtype;

           if l_int_ext_flag='INT' then
                fnd_message.set_name('PER','HR_377014_DK_SERVICE_PVDR');
                fnd_message.raise_error;
           end if;

           /* Added for bug fix 4227055 */

           OPEN getbgid;
           FETCH getbgid INTO l_business_group_id;
           CLOSE getbgid;

           OPEN get_sp(l_business_group_id);
           FETCH get_sp INTO l_sp;

           IF l_sp >1 THEN
                 RAISE  SP_DATA_FOUND;
           END IF;

           CLOSE get_sp;


        END IF;
  END IF;
EXCEPTION
    WHEN SP_DATA_FOUND THEN
        fnd_message.set_name('PER','HR_377035_DK_SP_UNIQUE');
        fnd_message.raise_error;



END validate_create_org_cat;


END hr_dk_validate_pkg;



/
