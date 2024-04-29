--------------------------------------------------------
--  DDL for Package Body HR_NO_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NO_VALIDATE_PKG" AS
 /* $Header: penovald.pkb 120.25.12010000.2 2008/08/06 09:16:52 ubhat ship $ */

  PROCEDURE validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
   ) IS
    l_type          VARCHAR2(1) := NULL;

    l_field         varchar2(300) := NULL;
    l_valid_date    varchar2(10);
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
      --IF p_first_name    IS NULL THEN
      --  l_field := hr_general.decode_lookup('NO_FORM_LABELS','FIRST_NAME');
      --END IF;
      IF l_type IS NOT NULL THEN
	  IF p_national_identifier  IS NULL OR p_national_identifier = hr_api.g_varchar2 THEN
  	      IF l_field IS NULL THEN
    	      	l_field := hr_general.decode_lookup('NO_FORM_LABELS','NI');
      	       ELSE
        	  	l_field := l_field||', '||hr_general.decode_lookup('NO_FORM_LABELS','NI');
        	       END IF;
      	   END IF;

	   --Moved mandatory check for First Name here
	   IF p_first_name IS NULL OR p_first_name = hr_api.g_varchar2 THEN
          		l_field := hr_general.decode_lookup('NO_FORM_LABELS','FIRST_NAME');
                 END IF;
      END IF;

     /*Bug fix- 4570879 added an additional check fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION')IN ('ERROR','WARN')*/
      IF l_field IS NOT NULL AND fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION')IN ('ERROR','WARN') THEN
        fnd_message.set_name('PER', 'HR_376803_NO_MANDATORY_MSG');
        fnd_message.set_token('NAME',l_field, translate => true );
        hr_utility.raise_error;
      END IF;

  END;

  --Procedure for validating person
  PROCEDURE person_validate
  (p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ) IS
  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
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
    ) IS
l_person_type_id   number ;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
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
    ) IS
  l_person_type_id   number ;
  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
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
  PROCEDURE cwk_validate
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_first_name                     in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
    ) IS
l_person_type_id   number ;
  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
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
  END cwk_validate;

/* Bug Fix 4463101 */

/*
 PROCEDURE validate_create_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_organization_id			in	number
  ,p_org_information1		in	varchar2
  ) IS

*/

 PROCEDURE validate_create_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_organization_id			in	number
  ,p_org_information1		in	varchar2
  ,p_org_information2		in	varchar2
  ,p_org_information3		in	varchar2
  ,p_org_information4			in	varchar2
  ,p_org_information5			in	varchar2
  ,p_org_information6			in	varchar2
  ,p_org_information7			in	varchar2
  ,p_org_information8			in	varchar2
  ,p_org_information9			in	varchar2
  ,p_org_information10			in	varchar2
  ,p_org_information11			in	varchar2
  ,p_org_information12			in	varchar2
  ,p_org_information13			in	varchar2
  ,p_org_information14			in	varchar2
  ,p_org_information15			in	varchar2
  ,p_org_information16			in	varchar2
  ,p_org_information17			in	varchar2
  ,p_org_information18			in	varchar2
  ,p_org_information19			in	varchar2
  ,p_org_information20			in	varchar2
  ) IS


 l_org_information1  hr_organization_information.org_information1%TYPE;
 l_organization_id hr_organization_units.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;
 l_org_information_id  hr_organization_information.org_information_id%TYPE;
 l_org_info_type_code hr_organization_information.org_information_context%TYPE;
 l_org_id  hr_organization_information.org_information_id%TYPE;


/* Bug Fix 4463101 */

 l_curr_start_date	DATE;
 l_curr_end_date	DATE;
 l_start_date		DATE;
 l_end_date		DATE;
 l_overlap_status VARCHAR2(1);

 CURSOR csr_repoting_span IS
 SELECT 'Y'
 FROM   hr_organization_information hoi
 WHERE  hoi.organization_id             = p_organization_id
 AND    hoi.org_information_context     = 'NO_EOY_REPORTING_RULE_OVERRIDE'
 AND    hoi.org_information3            = p_org_information3
 AND    (to_number(hoi.org_information1) BETWEEN to_number(p_org_information1)
                                         AND to_number(nvl(p_org_information2,'4712'))
  OR    to_number(p_org_information1)    BETWEEN to_number(hoi.org_information1)
                                         AND to_number(nvl(hoi.org_information2,'4712')));
    --
 cursor getbgid is
	select business_group_id
		from hr_organization_units
		where organization_id = p_organization_id;

/* Performance Bug fix 4892110 - Changed the below cursor to parameterized cursor avoiding fnd_sessions table */
 cursor orgnum(s_eff_date date) is
      	     select orgif.org_information_id from hr_organization_information orgif,hr_organization_units ou
	     where  ( orgif.org_information_context = 'NO_LOCAL_UNIT_DETAILS' or orgif.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS')
             and ou.organization_id = orgif.organization_id
	     and ou.business_group_id = l_business_group_id
             and orgif.org_information1 = p_org_information1
             and s_eff_date between ou.date_from and nvl(ou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

/* Performance Bug fix 4892110 - Changed the below cursor to parameterized cursor avoiding fnd_sessions table */
 cursor orglocalunit(s_eff_date date) is
		select o.organization_id
		from hr_organization_units o , hr_organization_information hoi
		where o.organization_id = hoi.organization_id
		and o.business_group_id = l_business_group_id
		and hoi.org_information_context = 'CLASS'
		and hoi.org_information1 = 'NO_LOCAL_UNIT'
		and to_char(o.organization_id) in (
				select hoinf.org_information1
				from hr_organization_units org, hr_organization_information hoinf
				where org.business_group_id = l_business_group_id
				and org.organization_id = hoinf.organization_id
				and hoinf.org_information_context = 'NO_LOCAL_UNITS'
			)
		and o.organization_id = to_number(p_org_information1)
		and s_eff_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		order by o.name;

/* Bug Fix 4463101 */

	CURSOR	csr_get_exemption_lim_details (p_organization_id  NUMBER) IS
	SELECT  hoi.ORG_INFORMATION1	p_org_info1
		,hoi.ORG_INFORMATION2	p_org_info2
		,hoi.ORG_INFORMATION3	p_org_info3
	FROM	hr_organization_information	hoi
	WHERE	hoi.ORGANIZATION_ID = p_organization_id
	AND	hoi.ORG_INFORMATION_CONTEXT = 'NO_NI_EXEMPTION_LIMIT';

/*Pgopal - Bug 5341353 fix*/
	CURSOR csr_hourly_salaried IS
	SELECT
		hoi.org_information5 hourly_salaried
	FROM
		hr_organization_information hoi
	WHERE
		hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_ABSENCE_PAYMENT_DETAILS';

	CURSOR csr_pay_to_be_adjusted IS
	SELECT
		hoi.org_information5 pay_to_be_adjusted
	FROM
		hr_organization_information hoi
	WHERE
		hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_HOLIDAY_PAY_DETAILS';

	 -- Pension Validation Bug 6153601, Bug 6166346----
        CURSOR 	csr_pension_type_chk IS
	SELECT	hoi.ORG_INFORMATION1 pension_types
	FROM	hr_organization_information hoi
	WHERE	hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_PENSION_DETAILS';


	CURSOR 	csr_org_number_chk IS
	SELECT	hoi.ORG_INFORMATION2 org_number
	FROM	hr_organization_information hoi
	WHERE	hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_PENSION_DETAILS';

	Cursor csr_pension_type_provider_chk IS
	SELECT	hoi.org_information1,
    		hoi.org_information2
	FROM	hr_organization_information hoi
	WHERE	hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_PENSION_PROVIDER'
		AND hoi.org_information3 = p_org_information3
    		AND ( 	(fnd_date.canonical_to_date(hoi.org_information1) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
    		         AND fnd_date.canonical_to_date(hoi.org_information2) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
    		        )
        	 	OR fnd_date.canonical_to_date(hoi.org_information1) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
        		OR fnd_date.canonical_to_date(hoi.org_information2) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
        		OR (fnd_date.canonical_to_date(p_org_information1) BETWEEN fnd_date.canonical_to_date(hoi.org_information1) AND fnd_date.canonical_to_date(hoi.org_information2)
        		    AND fnd_date.canonical_to_date(p_org_information2) BETWEEN fnd_date.canonical_to_date(hoi.org_information1) AND fnd_date.canonical_to_date(hoi.org_information2)
        		    )
        	    );

      l_csr_pension_type_record csr_pension_type_chk%ROWTYPE;
      l_csr_org_number_record csr_org_number_chk%ROWTYPE;
      l_csr_pension_provider_chk  csr_pension_type_provider_chk%ROWTYPE;
      --

      l_hourly_salaried csr_hourly_salaried % rowtype;
      l_field VARCHAR2(300);
      l_pay_to_be_adjusted csr_pay_to_be_adjusted%ROWTYPE ;
      s_effective_date date;
 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
    --
  	/* Performance Bug fix 4892110 - Start */
	begin
	     SELECT effective_date INTO s_effective_date FROM fnd_sessions
	     WHERE session_id = userenv('sessionid');
	exception
	     WHEN OTHERS then
		  s_effective_date := null;
	end;
	/* Performance Bug fix 4892110 - End */

	open getbgid;
	fetch getbgid into l_business_group_id;
	close getbgid;

	IF p_org_info_type_code = 'NO_LOCAL_UNIT_DETAILS' OR p_org_info_type_code = 'NO_LEGAL_EMPLOYER_DETAILS'  THEN


 	/* BUG FIX 4103631 */
	if length(p_org_information1) <> 9 then
		fnd_message.set_name('PER','HR_376828_NO_INVALID_ORG_NUM');
		 fnd_message.raise_error;
	end if;
	/* BUG FIX 4103631 */

	open orgnum(s_effective_date);
	loop
		fetch  orgnum into l_org_information_id;
		exit when orgnum%NOTFOUND;

		-- fetch curr org_id , code--
		select organization_id,org_information_context,org_information1 into l_org_id, l_org_info_type_code,l_org_information1
		from hr_organization_information
		where org_information_id = l_org_information_id;

		-- ignore if same type and same organization_id --
		IF l_org_information1 = p_org_information1 THEN
			IF (l_organization_id = l_org_id) and (l_org_info_type_code <> p_org_info_type_code) then
			   null;
			ELSE
			 fnd_message.set_name('PER','HR_376805_NO_ORG_NUMBER_UNIQUE');
			 fnd_message.raise_error;
			END IF;
		END IF;
	end loop;
	close orgnum;
	ELSIF   p_org_info_type_code = 'NO_LOCAL_UNITS'  THEN
			open orglocalunit(s_effective_date);
			fetch orglocalunit into l_org_information1;
			IF orglocalunit%FOUND THEN
				fnd_message.set_name('PER','HR_376806_NO_LOCAL_UNIT_MSG');
				fnd_message.raise_error;
			END IF;
			close orglocalunit;



	--  Bug Fix 4463101 : check for ORG_INFORMATION_CONTEXT
	ELSIF  p_org_info_type_code = 'NO_NI_EXEMPTION_LIMIT' THEN

		-- converting ORG_INFORMATION1 and 2 into dates
		SELECT fnd_date.canonical_to_date(p_org_information2) INTO l_curr_start_date FROM DUAL ;
		SELECT fnd_date.canonical_to_date(p_org_information3) INTO l_curr_end_date FROM DUAL ;


		-- checking if start date is greater than the end date
		IF (l_curr_start_date > l_curr_end_date )
		   THEN
				fnd_message.set_name('PAY','PAY_376859_NO_DATE_EARLY');
				fnd_message.raise_error;

		ELSE

		-- commenting the validation below to allow exemption limit/economic aid to be entered for overlapping periods

/*			-- now checking with other records of exemption limits entered
			FOR csr_rec IN csr_get_exemption_lim_details ( p_organization_id ) LOOP

				-- converting ORG_INFORMATION1 and 2 into dates
				SELECT fnd_date.canonical_to_date(csr_rec.p_org_info2) INTO l_start_date FROM DUAL ;
				SELECT fnd_date.canonical_to_date(csr_rec.p_org_info3) INTO l_end_date FROM DUAL ;

				IF (l_curr_start_date BETWEEN l_start_date AND l_end_date ) OR
				   (l_curr_end_date BETWEEN l_start_date AND l_end_date ) OR
				   (l_start_date BETWEEN l_curr_start_date AND l_curr_end_date ) OR
				   (l_end_date BETWEEN l_curr_start_date AND l_curr_end_date )

					THEN
						fnd_message.set_name('PAY','PAY_376858_NO_EXEM_LIMIT_ERR');
						--fnd_message.set_token('START_DATE',l_curr_start_date);
						--fnd_message.set_token('END_DATE',l_curr_end_date);
						fnd_message.raise_error;
						EXIT ;
				END IF;

			END LOOP;
*/
			/* Bug Fix 4463136 */
			-- now checking for, the period between start date and end date should be a multiple of bimonthly period

			IF      (to_number(to_char(l_curr_start_date,'DD')) <> 1) OR
				(last_day(l_curr_end_date) <> l_curr_end_date) OR
				(mod(to_number(to_char(l_curr_start_date,'MM')),2) <> 1) OR
				(mod(to_number(to_char(l_curr_end_date,'MM')),2) <> 0)
			THEN

			-- raise error message
			fnd_message.set_name('PAY','PAY_376860_NO_DATE_BIMONTH');
			fnd_message.raise_error;

			END IF;

		END IF;

	/* End Bug Fix 4463101 */
	END IF;
    --
    -- Validations for EOY Report Override Rules
    --
    IF p_org_info_type_code = 'NO_EOY_REPORTING_RULE_OVERRIDE' THEN
        --
        IF to_number(p_org_information2) < to_number(p_org_information1) THEN
          hr_utility.set_message(801,'PAY_376896_NO_YEAR_RESTRICT');
          hr_utility.raise_error;
        END IF;
        --
        OPEN  csr_repoting_span;
        FETCH csr_repoting_span INTO l_overlap_status;
        CLOSE csr_repoting_span;
        --
        IF l_overlap_status = 'Y' THEN
            --
            fnd_message.set_name(801,'PAY_376893_NO_YEAR_EXISTS');
           	fnd_message.set_token('REP_CODE',p_org_information3);
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 IN ('BAL','BAL_CODE_CTX') AND p_org_information5 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376892_NO_BALANCE_MISSING');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 = 'RRV_ELEMENT' AND p_org_information6 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376889_NO_ELEMENT_MISSING');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 = 'PROCEDURE' AND p_org_information7 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376890_NO_PROCEDURE_ABSENT');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information14 = 'PROCEDURE' AND p_org_information15 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376891_NO_SUMMATION_PROC');
            fnd_message.raise_error;
        --
        END IF;
    --
    END IF;
 --
     /*Pgopal - Bug 5341353 fix - Start*/
    IF p_org_info_type_code = 'NO_HOLIDAY_PAY_DETAILS' THEN

              OPEN csr_hourly_salaried;
              FETCH csr_hourly_salaried
              INTO l_hourly_salaried;
              CLOSE csr_hourly_salaried;


              IF(NVL(p_org_information3,'N') = 'N'
               AND(p_org_information4 IS NOT NULL OR p_org_information5 IS NOT NULL)) THEN
                fnd_message.set_name('PER',   'HR_376899_NO_HOL_PAY_OVER_60');
                fnd_message.RAISE_ERROR;
              END IF;

              IF(NVL(p_org_information3,'N') = 'Y'
               AND p_org_information4 IS NULL) THEN
                l_field := hr_general.decode_lookup('NO_FORM_LABELS',   'HOL_PAY_OVER_60_FIXED_PERIOD');
                fnd_message.set_name('PER',   'HR_376803_NO_MANDATORY_MSG');
                fnd_message.set_token('NAME',   l_field,   TRANSLATE => TRUE);
                fnd_message.RAISE_ERROR;
              END IF;

              IF(NVL(p_org_information3,'N') = 'Y'
               AND p_org_information5 IS NULL AND NVL(l_hourly_salaried.hourly_salaried,'S') = 'S') THEN
                l_field := hr_general.decode_lookup('NO_FORM_LABELS',   'HOL_ADJUST');
                fnd_message.set_name('PER',   'HR_376803_NO_MANDATORY_MSG');
                fnd_message.set_token('NAME',   l_field,   TRANSLATE => TRUE);
                fnd_message.RAISE_ERROR;
              END IF;


              IF (NVL(l_hourly_salaried.hourly_salaried,'S') = 'H' AND p_org_information5 = 'Y' ) THEN
                fnd_message.set_name('PER',   'HR_376900_NO_HOL_PAY_TO_BE_ADJ');
                fnd_message.RAISE_ERROR;
              END IF ;

	ELSIF p_org_info_type_code = 'NO_ABSENCE_PAYMENT_DETAILS' THEN

              OPEN csr_pay_to_be_adjusted;
              FETCH csr_pay_to_be_adjusted
              INTO l_pay_to_be_adjusted;
              CLOSE csr_pay_to_be_adjusted;

              IF (NVL(p_org_information5,'S') = 'H' AND l_pay_to_be_adjusted.pay_to_be_adjusted = 'Y') THEN
                fnd_message.set_name('PER',   'HR_376900_NO_HOL_PAY_TO_BE_ADJ');
                fnd_message.RAISE_ERROR;
              END IF  ;
      END IF;
   /*Pgopal - Bug 5341353 fix - End*/

       /*Pgopal - Bug 5341353 fix - End*/
    -- Pension Validation Bug 6153601 , Bug 6166346----
      IF p_org_info_type_code = 'NO_PENSION_PROVIDER' THEN
        IF p_org_information8 > p_org_information9 THEN
            fnd_message.set_name('PER','PER_376920_NO_PEN_AGE_LMT_CHK');
            fnd_message.RAISE_ERROR;
        END IF;
        IF fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) then
            fnd_message.set_name('PER','PER_376921_NO_PEN_SD_ED_CHK');
    	    fnd_message.RAISE_ERROR;
   	    END IF;
        OPEN csr_pension_type_provider_chk;
            LOOP
               	FETCH csr_pension_type_provider_chk INTO l_csr_pension_provider_chk;
            	EXIT WHEN csr_pension_type_provider_chk%NOTFOUND;
            	CLOSE csr_pension_type_provider_chk;
            	fnd_message.set_name('PER','PER_376922_NO_PEN_PRV_UNIQUE');
            	fnd_message.RAISE_ERROR;
             END LOOP;
        CLOSE csr_pension_type_provider_chk;

	END IF;


    IF p_org_info_type_code =  'NO_PENSION_DETAILS' THEN
        IF	to_number(p_org_information2) < 0 THEN
            fnd_message.set_name('PER','PER_376923_NO_PEN_ORG_NUM');
            fnd_message.RAISE_ERROR;
        END IF;

    	OPEN 	csr_pension_type_chk;
        LOOP
        FETCH csr_pension_type_chk INTO l_csr_pension_type_record;
        EXIT WHEN csr_pension_type_chk%NOTFOUND;
    		IF l_csr_pension_type_record.pension_types = p_org_information1 then
    			CLOSE 	csr_pension_type_chk;
                fnd_message.set_name('PER','PER_376924_NO_PEN_TYPE_DUP');
                fnd_message.RAISE_ERROR;
    		End IF;
        END LOOP;
        CLOSE csr_pension_type_chk;

    	OPEN 	csr_org_number_chk;
        LOOP
        FETCH csr_org_number_chk INTO l_csr_org_number_record;
        EXIT WHEN csr_org_number_chk%NOTFOUND;
    		IF l_csr_org_number_record.org_number <> p_org_information2 then
    			CLOSE 	csr_org_number_chk;
                fnd_message.set_name('PER','PER_376925_NO_PEN_TYPE_ORG');
                fnd_message.RAISE_ERROR;
    		End IF;
        END LOOP;
        CLOSE csr_org_number_chk;
    END IF;
    --
   END IF;
 END validate_create_org_inf;


/* Bug Fix 4463101 */

/*

 PROCEDURE validate_update_org_inf
  (p_org_info_type_code			in	 varchar2
  ,p_org_information_id		in number
  ,p_org_information1		in	varchar2
  ) IS

*/

 PROCEDURE validate_update_org_inf
  (p_org_info_type_code			in	varchar2
  ,p_org_information_id			in	number
  ,p_org_information1			in	varchar2
  ,p_org_information2			in	varchar2
  ,p_org_information3			in	varchar2
  ,p_org_information4			in	varchar2
  ,p_org_information5			in	varchar2
  ,p_org_information6			in	varchar2
  ,p_org_information7			in	varchar2
  ,p_org_information8			in	varchar2
  ,p_org_information9			in	varchar2
  ,p_org_information10			in	varchar2
  ,p_org_information11			in	varchar2
  ,p_org_information12			in	varchar2
  ,p_org_information13			in	varchar2
  ,p_org_information14			in	varchar2
  ,p_org_information15			in	varchar2
  ,p_org_information16			in	varchar2
  ,p_org_information17			in	varchar2
  ,p_org_information18			in	varchar2
  ,p_org_information19			in	varchar2
  ,p_org_information20			in	varchar2
  ) IS


 l_org_information1  hr_organization_information.org_information1%TYPE;
 l_organization_id hr_organization_information.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;
 l_org_information_id  hr_organization_information.org_information_id%TYPE;
 l_org_info_type_code hr_organization_information.org_information_context%TYPE;
 l_org_id  hr_organization_information.org_information_id%TYPE;

/* Bug Fix 4463101 */

 l_curr_start_date	DATE;
 l_curr_end_date	DATE;
 l_start_date		DATE;
 l_end_date		DATE;
 l_overlap_status VARCHAR2(1);

 CURSOR csr_repoting_span(l_organization_id NUMBER) IS
 SELECT 'Y'
 FROM   hr_organization_information hoi
 WHERE  hoi.organization_id             = l_organization_id
 AND    hoi.org_information_context     = 'NO_EOY_REPORTING_RULE_OVERRIDE'
 AND    hoi.org_information3            = p_org_information3
 AND    hoi.org_information_id          <> p_org_information_id
 AND    (to_number(hoi.org_information1) BETWEEN to_number(p_org_information1)
                                         AND to_number(nvl(p_org_information2,'4712'))
  OR    to_number(p_org_information1)    BETWEEN to_number(hoi.org_information1)
                                         AND to_number(nvl(hoi.org_information2,'4712')));

 cursor getbgid is
	select business_group_id
		from hr_organization_units
		where organization_id = l_organization_id;

cursor getorgid is
	select organization_id
		from hr_organization_information
		where org_information_id = p_org_information_id;
/* Performance Bug fix 4892110 - Changed the below cursor to parameterized cursor avoiding fnd_sessions table */
 cursor orgnum(s_eff_date date) is
    	     select orgif.org_information_id from hr_organization_information orgif,hr_organization_units ou
	     where  ( orgif.org_information_context = 'NO_LOCAL_UNIT_DETAILS' or orgif.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS')
             and ou.organization_id = orgif.organization_id
	     and ou.business_group_id = l_business_group_id
             and orgif.org_information1 = p_org_information1
             and s_eff_date between ou.date_from and nvl(ou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

/* Performance Bug fix 4892110 - Changed the below cursor to parameterized cursor avoiding fnd_sessions table */
 cursor orglocalunit(s_eff_date date) is
		select o.organization_id
		from hr_organization_units o , hr_organization_information hoi
		where o.organization_id = hoi.organization_id
		and o.business_group_id = l_business_group_id
		and hoi.org_information_context = 'CLASS'
		and hoi.org_information1 = 'NO_LOCAL_UNIT'
		and to_char(o.organization_id) in (
				select hoinf.org_information1
				from hr_organization_units org, hr_organization_information hoinf
				where org.business_group_id = l_business_group_id
				and org.organization_id = hoinf.organization_id
				and org.organization_id <> l_organization_id
				and hoinf.org_information_context = 'NO_LOCAL_UNITS'
			)
		and o.organization_id = to_number(p_org_information1)
		and s_eff_date between o.date_from and nvl(o.date_to,to_date('31/12/4712','DD/MM/YYYY'))
		order by o.name;

/* Bug Fix 4463101 */

	CURSOR	csr_get_exemption_details (p_organization_id  NUMBER , p_org_information_id	  NUMBER) IS
	SELECT  hoi.ORG_INFORMATION1	p_org_info1
		,hoi.ORG_INFORMATION2	p_org_info2
		,hoi.ORG_INFORMATION3	p_org_info3
	FROM	hr_organization_information	hoi
	WHERE	hoi.ORGANIZATION_ID = p_organization_id
	AND	hoi.ORG_INFORMATION_CONTEXT = 'NO_NI_EXEMPTION_LIMIT'
	AND	hoi.ORG_INFORMATION_ID <> p_org_information_id;

/*Pgopal - Bug 5341353 fix*/
	CURSOR csr_hourly_salaried(p_organization_id NUMBER) IS
	SELECT
		hoi.org_information5 hourly_salaried
	FROM
		hr_organization_information hoi
	WHERE
		hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_ABSENCE_PAYMENT_DETAILS';

	CURSOR csr_pay_to_be_adjusted(p_organization_id NUMBER) IS
	SELECT
		hoi.org_information5 pay_to_be_adjusted
	FROM
		hr_organization_information hoi
	WHERE
		hoi.organization_id = p_organization_id
		AND hoi.org_information_context = 'NO_HOLIDAY_PAY_DETAILS';

    -- Pension Validation Bug 6153601 , Bug 6166346----
    CURSOR 	csr_pension_type_chk IS
	SELECT	hoi.ORG_INFORMATION1 pension_types
	FROM	hr_organization_information hoi
	WHERE	hoi.ORG_INFORMATION_ID = p_org_information_id
		AND hoi.org_information_context = 'NO_PENSION_DETAILS';


    CURSOR	csr_org_number_chk IS
	SELECT	hoi.ORG_INFORMATION2 org_number
	FROM	hr_organization_information hoi
	WHERE	hoi.ORG_INFORMATION_ID = p_org_information_id
		AND hoi.org_information_context = 'NO_PENSION_DETAILS';

    CURSOR  csr_pension_provider_date_chk IS
	SELECT	hoi.org_information1,
    		hoi.org_information2
	FROM	hr_organization_information hoi
	WHERE	hoi.org_information_id = p_org_information_id
		AND hoi.org_information_context = 'NO_PENSION_PROVIDER';

    Cursor csr_pension_type_provider_chk IS
	SELECT	hoi.org_information1,
    		hoi.org_information2,
    		hoi.org_information_id
	FROM	hr_organization_information hoi
	WHERE	hoi.organization_id = (   SELECT hoi1.organization_id
                                         FROM   hr_organization_information hoi1
                                         WHERE  hoi1.org_information_id = p_org_information_id
                                      )
		AND hoi.org_information_context = 'NO_PENSION_PROVIDER'
		AND hoi.org_information3 = p_org_information3
        AND ( 	(fnd_date.canonical_to_date(hoi.org_information1) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
    		         AND fnd_date.canonical_to_date(hoi.org_information2) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
    		        )
        	 	OR fnd_date.canonical_to_date(hoi.org_information1) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
        		OR fnd_date.canonical_to_date(hoi.org_information2) BETWEEN fnd_date.canonical_to_date(p_org_information1) AND fnd_date.canonical_to_date(p_org_information2)
        		OR (fnd_date.canonical_to_date(p_org_information1) BETWEEN fnd_date.canonical_to_date(hoi.org_information1) AND fnd_date.canonical_to_date(hoi.org_information2)
        		    AND fnd_date.canonical_to_date(p_org_information2) BETWEEN fnd_date.canonical_to_date(hoi.org_information1) AND fnd_date.canonical_to_date(hoi.org_information2)
        		    )
     	    )
        AND (   fnd_date.canonical_to_date(hoi.org_information1) <> fnd_date.canonical_to_date(p_org_information1)
                OR  fnd_date.canonical_to_date(hoi.org_information2) <> fnd_date.canonical_to_date(p_org_information2)
            );

      l_csr_pension_type_record         csr_pension_type_chk%ROWTYPE;
      l_csr_org_number_record           csr_org_number_chk%ROWTYPE;
      l_csr_pension_provider_chk        csr_pension_type_provider_chk%ROWTYPE;
      l_csr_pen_prov_date_chk           csr_pension_provider_date_chk%ROWTYPE;

      --

      l_hourly_salaried csr_hourly_salaried % rowtype;
      l_field VARCHAR2(300);
      l_pay_to_be_adjusted csr_pay_to_be_adjusted%ROWTYPE ;
      s_effective_date date;
 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
    --
	/* Performance Bug fix 4892110 - Start */
	begin
	     SELECT effective_date INTO s_effective_date FROM fnd_sessions
	     WHERE session_id = userenv('sessionid');
	exception
	     WHEN OTHERS then
		  s_effective_date := null;
	end;
	/* Performance Bug fix 4892110 - End */
	open getorgid;
	fetch getorgid into l_organization_id;
	close getorgid;

	open getbgid;
	fetch getbgid into l_business_group_id;
	close getbgid;

	IF p_org_info_type_code = 'NO_LOCAL_UNIT_DETAILS'  OR p_org_info_type_code = 'NO_LEGAL_EMPLOYER_DETAILS'  THEN

 	/* BUG FIX 4103631 */
	if length(p_org_information1) <> 9 then
		fnd_message.set_name('PER','HR_376828_NO_INVALID_ORG_NUM');
		 fnd_message.raise_error;
	end if;
	/* BUG FIX 4103631 */



	open orgnum (s_effective_date);
	loop
		fetch  orgnum into l_org_information_id;
		exit when orgnum%NOTFOUND;

		-- fetch curr org_id , code--
		select organization_id,org_information_context,org_information1
		into l_org_id, l_org_info_type_code,l_org_information1
		from hr_organization_information
		where org_information_id = l_org_information_id;

		-- ignore if same type and same organization_id --
		IF l_org_information1 = p_org_information1 THEN
			IF (l_organization_id = l_org_id) and (l_org_info_type_code <> p_org_info_type_code) then
			   null;

			-- Bug Fix 5370311 Start : ignore if same record is being updated
			ELSIF ( l_org_information_id = p_org_information_id ) THEN
			   NULL ;
			-- Bug Fix 5370311 End

			ELSE
			 fnd_message.set_name('PER','HR_376805_NO_ORG_NUMBER_UNIQUE');
			 fnd_message.raise_error;
			END IF;
		END IF;
	end loop;
	close orgnum;
	ELSIF   p_org_info_type_code = 'NO_LOCAL_UNITS'  THEN
			open orglocalunit (s_effective_date);
			fetch orglocalunit into l_org_information1;
			IF orglocalunit%FOUND THEN
				fnd_message.set_name('PER','HR_376806_NO_LOCAL_UNIT_MSG');
				fnd_message.raise_error;
			END IF;
			close orglocalunit;


	-- Bug Fix 4463101 : check for ORG_INFORMATION_CONTEXT
	ELSIF  p_org_info_type_code = 'NO_NI_EXEMPTION_LIMIT' THEN

		-- converting ORG_INFORMATION1 and 2 into dates
		SELECT fnd_date.canonical_to_date(p_org_information2) INTO l_curr_start_date FROM DUAL ;
		SELECT fnd_date.canonical_to_date(p_org_information3) INTO l_curr_end_date FROM DUAL ;


		-- checking if start date is greater than the end date
		IF (l_curr_start_date > l_curr_end_date )
		   THEN
				fnd_message.set_name('PAY','PAY_376859_NO_DATE_EARLY');
				fnd_message.raise_error;

		ELSE

		-- commenting the validation below to allow exemption limit/economic aid to be entered for overlapping periods
/*
			-- now checking with other records of exemption limits entered
			FOR csr_rec IN csr_get_exemption_details ( l_organization_id , p_org_information_id ) LOOP

				-- converting ORG_INFORMATION1 and 2 into dates
				SELECT fnd_date.canonical_to_date(csr_rec.p_org_info2) INTO l_start_date FROM DUAL ;
				SELECT fnd_date.canonical_to_date(csr_rec.p_org_info3) INTO l_end_date FROM DUAL ;

				IF (l_curr_start_date BETWEEN l_start_date AND l_end_date ) OR
				   (l_curr_end_date BETWEEN l_start_date AND l_end_date ) OR
				   (l_start_date BETWEEN l_curr_start_date AND l_curr_end_date ) OR
				   (l_end_date BETWEEN l_curr_start_date AND l_curr_end_date )

					THEN
						fnd_message.set_name('PAY','PAY_376858_NO_EXEM_LIMIT_ERR');
						--fnd_message.set_token('START_DATE',l_curr_start_date);
						--fnd_message.set_token('END_DATE',l_curr_end_date);
						fnd_message.raise_error;
						EXIT ;
				END IF;

			END LOOP;
*/
			/* Bug Fix 4463136 */
			-- now checking for, the period between start date and end date should be a multiple of bimonthly period

			IF      (to_number(to_char(l_curr_start_date,'DD')) <> 1) OR
				(last_day(l_curr_end_date) <> l_curr_end_date) OR
				(mod(to_number(to_char(l_curr_start_date,'MM')),2) <> 1) OR
				(mod(to_number(to_char(l_curr_end_date,'MM')),2) <> 0)
			THEN

			-- raise error message
			fnd_message.set_name('PAY','PAY_376860_NO_DATE_BIMONTH');
			fnd_message.raise_error;

			END IF;

		END IF;
	/* End Bug Fix 4463101 */


	END IF;
    --
    -- Validations on LE Override rules for EOY Audit Report
    --
    IF p_org_info_type_code = 'NO_EOY_REPORTING_RULE_OVERRIDE' THEN
        --
        IF to_number(p_org_information2) < to_number(p_org_information1) THEN
          hr_utility.set_message(801,'PAY_376896_NO_YEAR_RESTRICT');
          hr_utility.raise_error;
        END IF;
        --
        OPEN  csr_repoting_span(l_organization_id);
        FETCH csr_repoting_span INTO l_overlap_status;
        CLOSE csr_repoting_span;
        --
        IF l_overlap_status = 'Y' THEN
            --
            fnd_message.set_name(801,'PAY_376883_NO_YEAR_EXISTS');
           	fnd_message.set_token('REP_CODE',p_org_information3);
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 IN ('BAL','BAL_CODE_CTX') AND p_org_information5 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376892_NO_BALANCE_MISSING');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 = 'RRV_ELEMENT' AND p_org_information6 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376889_NO_ELEMENT_MISSING');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information4 = 'PROCEDURE' AND p_org_information7 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376890_NO_PROCEDURE_ABSENT');
            fnd_message.raise_error;
        --
        END IF;
        --
        IF p_org_information14 = 'PROCEDURE' AND p_org_information15 IS NULL THEN
            --
            fnd_message.set_name(801,'PAY_376891_NO_SUMMATION_PROC');
            fnd_message.raise_error;
        --
        END IF;
    --
    END IF;
 --

  /*Pgopal - Bug 5341353 fix - Start*/
    IF p_org_info_type_code = 'NO_HOLIDAY_PAY_DETAILS' THEN

              OPEN csr_hourly_salaried(l_organization_id);
              FETCH csr_hourly_salaried
              INTO l_hourly_salaried;
              CLOSE csr_hourly_salaried;


              IF(NVL(p_org_information3,'N') = 'N'
               AND(p_org_information4 IS NOT NULL OR p_org_information5 IS NOT NULL)) THEN
                fnd_message.set_name('PER',   'HR_376899_NO_HOL_PAY_OVER_60');
                fnd_message.RAISE_ERROR;
              END IF;

              IF(NVL(p_org_information3,'N') = 'Y'
               AND p_org_information4 IS NULL) THEN
                l_field := hr_general.decode_lookup('NO_FORM_LABELS',   'HOL_PAY_OVER_60_FIXED_PERIOD');
                fnd_message.set_name('PER',   'HR_376803_NO_MANDATORY_MSG');
                fnd_message.set_token('NAME',   l_field,   TRANSLATE => TRUE);
                fnd_message.RAISE_ERROR;
              END IF;

              IF(NVL(p_org_information3,'N') = 'Y'
               AND p_org_information5 IS NULL AND NVL(l_hourly_salaried.hourly_salaried,'S') = 'S') THEN
                l_field := hr_general.decode_lookup('NO_FORM_LABELS',   'HOL_ADJUST');
                fnd_message.set_name('PER',   'HR_376803_NO_MANDATORY_MSG');
                fnd_message.set_token('NAME',   l_field,   TRANSLATE => TRUE);
                fnd_message.RAISE_ERROR;

              END IF;


              IF (NVL(l_hourly_salaried.hourly_salaried,'S') = 'H' AND p_org_information5 = 'Y') THEN
                fnd_message.set_name('PER',   'HR_376900_NO_HOL_PAY_TO_BE_ADJ');
                fnd_message.RAISE_ERROR;
              END IF ;

	ELSIF p_org_info_type_code = 'NO_ABSENCE_PAYMENT_DETAILS' THEN

              OPEN csr_pay_to_be_adjusted(l_organization_id);
              FETCH csr_pay_to_be_adjusted
              INTO l_pay_to_be_adjusted;
              CLOSE csr_pay_to_be_adjusted;

              IF (NVL(p_org_information5,'S') = 'H' AND l_pay_to_be_adjusted.pay_to_be_adjusted = 'Y') THEN
                fnd_message.set_name('PER',   'HR_376900_NO_HOL_PAY_TO_BE_ADJ');
                fnd_message.RAISE_ERROR;
              END IF  ;

      END IF;
   /*Pgopal - Bug 5341353 fix - End*/

    -- Pension Validation Bug 6153601 , Bug 6166346----
      IF p_org_info_type_code = 'NO_PENSION_PROVIDER' THEN
        IF p_org_information8 > p_org_information9 THEN
            fnd_message.set_name('PER','PER_376920_NO_PEN_AGE_LMT_CHK');
            fnd_message.RAISE_ERROR;
        END IF;
        OPEN csr_pension_provider_date_chk;
            LOOP
    	        FETCH csr_pension_provider_date_chk INTO l_csr_pen_prov_date_chk;
                EXIT WHEN csr_pension_provider_date_chk%NOTFOUND;
                IF fnd_date.canonical_to_date(l_csr_pen_prov_date_chk.org_information1) > fnd_date.canonical_to_date(l_csr_pen_prov_date_chk.org_information2) THEN
            	    CLOSE csr_pension_provider_date_chk;
            	    fnd_message.set_name('PER','PER_376921_NO_PEN_SD_ED_CHK');
            	    fnd_message.RAISE_ERROR;
           	    END IF;
            END LOOP;
            CLOSE csr_pension_provider_date_chk;

        OPEN csr_pension_type_provider_chk;
            LOOP
    	        FETCH csr_pension_type_provider_chk INTO l_csr_pension_provider_chk;
                EXIT WHEN csr_pension_type_provider_chk%NOTFOUND;
                IF l_csr_pension_provider_chk.org_information_id <> p_org_information_id THEN
            	    CLOSE csr_pension_type_provider_chk;
            	    fnd_message.set_name('PER','PER_376922_NO_PEN_PRV_UNIQUE');
            	    fnd_message.RAISE_ERROR;
           	    END IF;
            END LOOP;
            CLOSE csr_pension_type_provider_chk;
      END IF;
      IF p_org_info_type_code =  'NO_PENSION_DETAILS' THEN
        IF	to_number(p_org_information2) < 0 THEN
            fnd_message.set_name('PER','PER_376923_NO_PEN_ORG_NUM');
            fnd_message.RAISE_ERROR;
        END IF;

        OPEN 	csr_pension_type_chk;
        LOOP
        FETCH csr_pension_type_chk INTO l_csr_pension_type_record;
            EXIT WHEN csr_pension_type_chk%NOTFOUND;
       		IF l_csr_pension_type_record.pension_types = p_org_information1 then
        			CLOSE 	csr_pension_type_chk;
                    fnd_message.set_name('PER','PER_376924_NO_PEN_TYPE_DUP');
                    fnd_message.RAISE_ERROR;
    	   	End IF;
        END LOOP;
        CLOSE csr_pension_type_chk;

	    OPEN 	csr_org_number_chk;
        LOOP
            FETCH csr_org_number_chk INTO l_csr_org_number_record;
            EXIT WHEN csr_org_number_chk%NOTFOUND;
        		IF l_csr_org_number_record.org_number <> p_org_information2 then
    			    CLOSE 	csr_org_number_chk;
                    fnd_message.set_name('PER','PER_376925_NO_PEN_TYPE_ORG');
                    fnd_message.RAISE_ERROR;
        		End IF;
         END LOOP;
         CLOSE csr_org_number_chk;
      END IF;
      --
   END IF;
 END validate_update_org_inf;

--Procedure for validating qualification insertion
PROCEDURE qual_insert_validate
  (p_business_group_id              in      number
  ,p_qualification_type_id          in      number
  ,p_qua_information_category       in      varchar2 default null
  ,p_person_id                      in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  ) IS
      l_count 	    NUMBER;
      l_nus2000_code NUMBER;

  BEGIN
    --
    -- Added for GSI Bug 5472781
    --
    IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
     --

      select information1 into l_nus2000_code
      from per_qualification_types
      where qualification_type_id = p_qualification_type_id;


      if p_qua_information1 <> l_nus2000_code then
		fnd_message.set_name('PER', 'HR_376822_NO_NUS2000_MISMATCH');
	        hr_utility.raise_error;
      end if;



    IF p_qua_information2 ='Y' THEN
	select count(*)
	into l_count
	from  per_qualifications pq
        where pq.business_group_id   = p_business_group_id
	and pq.person_id    =   p_person_id
	and pq.qua_information_category='NO'
	and pq.qua_information2='Y';
        IF l_count > 0 then
	        fnd_message.set_name('PER', 'HR_376812_NO_HIGHEST_LEVEL');
	        hr_utility.raise_error;
        END IF;
    END IF ;
   END IF;
  END qual_insert_validate;

--Procedure for validating qualification Update
PROCEDURE qual_update_validate
  (p_qua_information_category       in      varchar2 default null
  ,p_qualification_id               in      number
  ,p_qualification_type_id          in      number
  ,p_qua_information1               in      varchar2 default null
  ,p_qua_information2               in      varchar2 default null
  ) IS
      l_count		        NUMBER;
      l_person_id    		NUMBER;
      l_business_group_id     	NUMBER;
      l_nus2000_code	        NUMBER;

    CURSOR c_person_id IS
    SELECT person_id,business_group_id
    FROM   per_qualifications
    WHERE  qualification_id = p_qualification_id;

/*Bug fix 4950606 : Rewrote the select statement using cursor in qual_update_validate procedure.*/
CURSOR  c_information1 IS
SELECT
	information1
FROM
	per_qualification_types
WHERE
	qualification_type_id = p_qualification_type_id;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
    --
	OPEN c_information1;
	FETCH  c_information1 INTO l_nus2000_code ;
	CLOSE c_information1;

      if p_qua_information1 <> l_nus2000_code then
		fnd_message.set_name('PER', 'HR_376822_NO_NUS2000_MISMATCH');
	        hr_utility.raise_error;
      end if;



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
	and pq.qua_information_category='NO'
	and pq.qua_information2='Y';

        IF l_count > 0 then
	        fnd_message.set_name('PER', 'HR_376812_NO_HIGHEST_LEVEL');
	        hr_utility.raise_error;
        END IF;

   END IF;
  END IF;
END qual_update_validate ;


 -- Procedure to Validate the Organization Classification
 PROCEDURE validate_create_org_cat
  (p_organization_id		in	number
  ,p_org_information1           in      varchar2
    ) IS

 l_organization_id hr_organization_units.organization_id%TYPE;
 l_business_group_id hr_organization_units.business_group_id%TYPE;
 l_int_ext_flag hr_organization_units.internal_external_flag%TYPE;

 cursor getbgid is
	select business_group_id
		from hr_organization_units
		where organization_id = p_organization_id;

 cursor orgtype is
      	     select ou.internal_external_flag from hr_organization_units ou ,FND_SESSIONS s
	     where ou.organization_id= p_organization_id
	     and s.session_id = userenv('sessionid')
             and s.effective_date between ou.date_from and nvl(ou.date_to,to_date('31/12/4712','DD/MM/YYYY'));

  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
    --
	open getbgid;
	fetch getbgid into l_business_group_id;
	close getbgid;

	IF p_org_information1 = 'NO_SOC_SEC_OFFICE'  THEN

           open orgtype;
           fetch orgtype into l_int_ext_flag;
	   close orgtype;

	   if l_int_ext_flag='INT' then
		fnd_message.set_name('PER','HR_376818_NO_SOC_SEC');
        	fnd_message.raise_error;
           end if;

	END IF;
   END IF;
  END validate_create_org_cat;
 -----------------------------------------------------------------------------------------------
 --Procedures added to validate Contract End Date against Active Start Date for bug fix 3907853
  -----------------------------------------------------------------------------------------------

 PROCEDURE create_contract_validate
   (p_status                         in      varchar2
   ,p_effective_date		     in      date
   ,p_ctr_information_category       in      varchar2 default null
   ,p_ctr_information1               in      varchar2 default null
    )  IS

   l_active_start_date  date;

   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
       --
       IF p_status = 'A-ACTIVE' THEN
	     IF (p_ctr_information1 IS NOT NULL  AND p_ctr_information_category ='NO') THEN

		   IF (fnd_date.canonical_to_date(p_ctr_information1) < p_effective_date) THEN
   		     --
  		     fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
		     fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','CED'));
		     fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','ASD'));
		     hr_utility.raise_error;
		     --
		   END IF;
	     END IF;
       END IF;
     END IF;
   END create_contract_validate;

 PROCEDURE update_contract_validate
   (p_contract_id		     in      number   default null
   ,p_status                         in      varchar2
   ,p_effective_date		     in      date
   ,p_ctr_information_category       in      varchar2 default null
   ,p_ctr_information1               in      varchar2 default null
    )  IS

   l_active_start_date  date;

   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
       --
       IF p_status = 'A-ACTIVE' THEN
	     IF (p_ctr_information1 IS NOT NULL AND p_ctr_information_category ='NO') THEN

		   l_active_start_date := hr_contract_api.get_active_start_date (p_contract_id,p_effective_date,p_status);

		   IF (fnd_date.canonical_to_date(p_ctr_information1) < l_active_start_date) THEN
		     --
		     fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
		     fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','CED'));
		     fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','ASD'));
		     hr_utility.raise_error;
		     --
		   END IF;
	     END IF;
       END IF;
     END IF;
   END update_contract_validate;


 --------------------------------------------------------------------------------------------------------
 --Procedures added to validate 'Date Reported to Social Security' and 'Date Reported to Labor Inspection'
 --against 'Incident Date' for bug fix 3902280
  -------------------------------------------------------------------------------------------------------

 PROCEDURE workinc_validate
   (p_incident_date                 in     date
   ,p_inc_information_category      in     varchar2 default null
   ,p_inc_information1              in     varchar2 default null
   ,p_inc_information2              in     varchar2 default null
    )  IS

 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
     --
	   IF (p_inc_information1 IS NOT NULL AND p_inc_information_category ='NO' )THEN
		IF (fnd_date.canonical_to_date(p_inc_information1) < p_incident_date)
		 THEN
		  --
		  fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
		  fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','DATE_REPORTED_TO_SSO'));
		  fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','ID'));
		  hr_utility.raise_error;
		  --
		END IF;
	   END IF;

 	   IF (p_inc_information2 IS NOT NULL  AND p_inc_information_category ='NO') THEN
		IF (fnd_date.canonical_to_date(p_inc_information2) < p_incident_date)
		 THEN
		  --
		  fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
		  fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','DATE_REPORTED_TO_LIA'));
		  fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','ID'));
		  hr_utility.raise_error;
		  --
		END IF;
	   END IF;
   END IF;
 END workinc_validate;

 -----------------------------------------------------------------------------------------------------------
 --Add validation for 'Retirement Date' and 'Retirement Inquiry Sent'
 --against Hire Date of the Employee for bug fix 3907827.
 --Also to add validation for 'Retirement Age' against Actual Age of the Employee for bug fix 3907827.
 -----------------------------------------------------------------------------------------------------------

 PROCEDURE create_asg_validate
 ( p_scl_segment12                IN      VARCHAR2  DEFAULT  NULL
  ,p_scl_segment13                IN      VARCHAR2  DEFAULT  NULL
  ,p_scl_segment14                IN      VARCHAR2  DEFAULT  NULL
  ,p_effective_date		  IN	  DATE
  ,p_person_id			  IN	  NUMBER
   ) IS

  CURSOR get_person_details (p_person_id NUMBER) IS
  select papf.date_of_birth, papf.start_date
  from per_all_people_f papf
  where papf.per_information_category ='NO'
  and papf.PERSON_ID = p_person_id
  and p_effective_date BETWEEN  papf.EFFECTIVE_START_DATE and  papf.EFFECTIVE_END_DATE;

  l_dob			  date;
  l_start_date		  date;
  l_age			  number;

 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
     --
     open get_person_details(p_person_id);
     fetch get_person_details into l_dob,l_start_date;
     close get_person_details;

     l_age := TRUNC((p_effective_date - l_dob)/365);

     --GSI Bug 4584922
     IF (p_scl_segment14 <> hr_api.g_varchar2) THEN
       IF(l_age > p_scl_segment14 ) THEN
	     fnd_message.set_name('PER','HR_376821_NO_AGE_LESS');
	     fnd_message.set_token('AGE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RA'));
	     fnd_message.set_token('AGE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','AA'));
	     hr_utility.raise_error;

       END IF;
     END IF;

     --GSI Bug 4584922
     IF(p_scl_segment12 <> hr_api.g_varchar2) THEN
       IF( p_scl_segment12 <l_start_date) THEN
	     fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
	     fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RD'));
	     fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','HD'));
	     hr_utility.raise_error;
       END IF;
     END IF;

     --GSI Bug 4584922
     IF(p_scl_segment13 <> hr_api.g_varchar2) THEN
       IF( p_scl_segment13 <l_start_date) THEN
	     fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
	     fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RIS'));
	     fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','HD'));
	     hr_utility.raise_error;
       END IF;
     END IF;
   END IF;
 END create_asg_validate;

-------------------------------------------------------------------------------------------------------

 PROCEDURE update_asg_validate
 ( p_segment12                IN      VARCHAR2  DEFAULT  NULL
  ,p_segment13                IN      VARCHAR2  DEFAULT  NULL
  ,p_segment14                IN      VARCHAR2  DEFAULT  NULL
  ,p_effective_date	      IN      DATE
  ,p_assignment_id	      IN      NUMBER
   )  IS

  CURSOR get_person_details (p_assignment_id NUMBER) IS
  select papf.date_of_birth, papf.start_date
  from per_all_people_f papf, per_all_assignments_f paaf
  where papf.per_information_category ='NO'
  and paaf.PERSON_ID = papf.PERSON_ID
  and paaf.ASSIGNMENT_ID = p_assignment_id
  and p_effective_date BETWEEN  paaf.EFFECTIVE_START_DATE and  paaf.EFFECTIVE_END_DATE
  and p_effective_date BETWEEN  papf.EFFECTIVE_START_DATE and  papf.EFFECTIVE_END_DATE;

  l_dob			  date;
  l_start_date		  date;
  l_age			  number;

 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NO') THEN
     --
  open get_person_details(p_assignment_id);
  fetch get_person_details into l_dob,l_start_date;
  close get_person_details;

  l_age := TRUNC((p_effective_date - l_dob)/365);

--GSI Bug 4584922
IF(p_segment14 <> hr_api.g_varchar2) THEN
  IF(l_age > p_segment14 ) THEN
	fnd_message.set_name('PER','HR_376821_NO_AGE_LESS');
	fnd_message.set_token('AGE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RA'));
	fnd_message.set_token('AGE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','AA'));
	hr_utility.raise_error;

  END IF;
END IF;

--GSI Bug 4584922
IF(p_segment12 <> hr_api.g_varchar2) THEN
  IF( p_segment12 <l_start_date) THEN
	fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
	fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RD'));
	fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','HD'));
	hr_utility.raise_error;
  END IF;
END IF;

--GSI Bug 4584922
IF(p_segment13 <> hr_api.g_varchar2) THEN
  IF( p_segment13 <l_start_date) THEN
	fnd_message.set_name('PER','HR_376820_NO_DATE_EARLY');
	fnd_message.set_token('DATE1',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','RIS'));
	fnd_message.set_token('DATE2',hr_general.decode_fnd_comm_lookup('NO_FORM_LABELS','HD'));
	hr_utility.raise_error;
  END IF;
END IF;
 END IF;
 END update_asg_validate;


--------------------------------------------------------------------------------------------------

PROCEDURE CREATE_ELEMENT_ELE_CODE
  (p_information_type         IN VARCHAR2
  ,p_element_type_id          IN NUMBER
  ,p_eei_attribute_category   IN VARCHAR2
  ,p_eei_attribute1           IN VARCHAR2
  ,p_eei_attribute2           IN VARCHAR2
  ,p_eei_attribute3           IN VARCHAR2
  ,p_eei_attribute4           IN VARCHAR2
  ,p_eei_attribute5           IN VARCHAR2
  ,p_eei_attribute6           IN VARCHAR2
  ,p_eei_attribute7           IN VARCHAR2
  ,p_eei_attribute8           IN VARCHAR2
  ,p_eei_attribute9           IN VARCHAR2
  ,p_eei_attribute10          IN VARCHAR2
  ,p_eei_attribute11          IN VARCHAR2
  ,p_eei_attribute12          IN VARCHAR2
  ,p_eei_attribute13          IN VARCHAR2
  ,p_eei_attribute14          IN VARCHAR2
  ,p_eei_attribute15          IN VARCHAR2
  ,p_eei_attribute16          IN VARCHAR2
  ,p_eei_attribute17          IN VARCHAR2
  ,p_eei_attribute18          IN VARCHAR2
  ,p_eei_attribute19          IN VARCHAR2
  ,p_eei_attribute20          IN VARCHAR2
  ,p_eei_information_category IN VARCHAR2
  ,p_eei_information1         IN VARCHAR2
  ,p_eei_information2         IN VARCHAR2
  ,p_eei_information3         IN VARCHAR2
  ,p_eei_information4         IN VARCHAR2
  ,p_eei_information5         IN VARCHAR2
  ,p_eei_information6         IN VARCHAR2
  ,p_eei_information7         IN VARCHAR2
  ,p_eei_information8         IN VARCHAR2
  ,p_eei_information9         IN VARCHAR2
  ,p_eei_information10        IN VARCHAR2
  ,p_eei_information11        IN VARCHAR2
  ,p_eei_information12        IN VARCHAR2
  ,p_eei_information13        IN VARCHAR2
  ,p_eei_information14        IN VARCHAR2
  ,p_eei_information15        IN VARCHAR2
  ,p_eei_information16        IN VARCHAR2
  ,p_eei_information17        IN VARCHAR2
  ,p_eei_information18        IN VARCHAR2
  ,p_eei_information19        IN VARCHAR2
  ,p_eei_information20        IN VARCHAR2
  ,p_eei_information21        IN VARCHAR2
  ,p_eei_information22        IN VARCHAR2
  ,p_eei_information23        IN VARCHAR2
  ,p_eei_information24        IN VARCHAR2
  ,p_eei_information25        IN VARCHAR2
  ,p_eei_information26        IN VARCHAR2
  ,p_eei_information27        IN VARCHAR2
  ,p_eei_information28        IN VARCHAR2
  ,p_eei_information29        IN VARCHAR2
  ,p_eei_information30        IN VARCHAR2
) is

     CURSOR csr_get_ele_code( p_ele_type_id  NUMBER ) IS
     SELECT eei_information1, eei_information2
     FROM pay_element_type_extra_info petei
     WHERE petei.information_type='NO_ELEMENT_CODES'
     AND petei.element_type_id = p_ele_type_id ;

     CURSOR csr_get_le_details(p_le_id NUMBER) IS
     SELECT  hou.name  NAME
     FROM hr_organization_units   hou
         ,hr_organization_information   hoi
     WHERE hoi.organization_id = hou.organization_id
     AND   hoi.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS'
     AND   hou.organization_id = p_le_id;

     CURSOR csr_chk_element_eit_year IS
     SELECT 'Y', etei.eei_information3
     FROM  pay_element_type_extra_info etei
     WHERE etei.element_type_id          = p_element_type_id
     AND   etei.eei_information_category = 'NO_EOY_REPORTING_CODE_MAPPING'
     AND   ((to_number(etei.eei_information1)
           between  to_number(p_eei_information1) and to_number(nvl(p_eei_information2,'4712')))
     OR    (to_number(p_eei_information1)
           between  to_number(etei.eei_information1) and to_number(nvl(etei.eei_information2,'4712')))) ;
    --
     l_year_status           varchar2(1);
     l_overlap_code          pay_element_type_extra_info.eei_information3%TYPE;
     rec_get_ele_code	     csr_get_ele_code%ROWTYPE;
     rec_get_le_details	     csr_get_le_details%ROWTYPE;
    --
BEGIN
    --
      IF p_eei_information_category = 'NO_EOY_REPORTING_CODE_MAPPING' THEN
      -- Validation to ensure Year of Reporting(EOY) is different then what we already have in Extra Element Info DDF
	IF p_eei_information2 IS NOT NULL AND to_number(p_eei_information2) < to_number(p_eei_information1) THEN
	  hr_utility.set_message(800,'PAY_376896_NO_YEAR_RESTRICT');
          hr_utility.raise_error;
        END IF;
        --
        OPEN  csr_chk_element_eit_year;
        FETCH csr_chk_element_eit_year INTO l_year_status, l_overlap_code;
        CLOSE csr_chk_element_eit_year;
        --
        IF (l_year_status = 'Y') THEN
          hr_utility.set_message(801,'PAY_376893_NO_YEAR_EXISTS');
          fnd_message.set_token('REP_CODE',l_overlap_code); --p_eei_information3);
          hr_utility.raise_error;
         END IF;
        --
      -- Validation to check if single input value is mapped to more than one column in Extra Element Info DDF
        IF (p_eei_information4 = p_eei_information6 OR p_eei_information4 = p_eei_information8
        OR p_eei_information4 = p_eei_information10 OR p_eei_information4 = p_eei_information12
        OR p_eei_information4 = p_eei_information14 OR p_eei_information4 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
         END IF;
        --
        IF (p_eei_information6 = p_eei_information8  OR p_eei_information6 = p_eei_information10
        OR p_eei_information6 = p_eei_information12 OR p_eei_information6 = p_eei_information14
        OR p_eei_information6 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information8 = p_eei_information10 OR p_eei_information8 = p_eei_information12
        OR p_eei_information8 = p_eei_information14 OR p_eei_information8 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information10 = p_eei_information12 OR p_eei_information10 = p_eei_information14
        OR p_eei_information10 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information12 = p_eei_information14 OR p_eei_information12 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information14 = p_eei_information16) THEN
          hr_utility.set_message(810,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        -- Validation to check if input value is specified without a mapping column in Extra Element Info DDF
        IF (p_eei_information5 IS NULL and p_eei_information6 IS NOT NULL)
          OR (p_eei_information7 IS NULL and p_eei_information8 IS NOT NULL)
          OR (p_eei_information9 IS NULL and p_eei_information10 IS NOT NULL)
          OR (p_eei_information11 IS NULL and p_eei_information12 IS NOT NULL)
          OR (p_eei_information13 IS NULL and p_eei_information14 IS NOT NULL)
          OR (p_eei_information15 IS NULL and p_eei_information16 IS NOT NULL) THEN
          hr_utility.set_message(801,'PAY_376895_NO_COL_MAP_MISSING');
          hr_utility.raise_error;
        END IF;
      --
      END IF;
    --
    --
    --
      IF p_eei_information_category = 'NO_ELEMENT_CODES' THEN

      FOR  rec_get_ele_code IN csr_get_ele_code(p_element_type_id)
      LOOP
	      IF ( rec_get_ele_code.eei_information2 IS NOT NULL ) THEN

	        OPEN csr_get_le_details(to_number(rec_get_ele_code.eei_information2));
            FETCH csr_get_le_details INTO rec_get_le_details;
            CLOSE csr_get_le_details;

            IF( p_eei_information2 = rec_get_ele_code.eei_information2) THEN
                  hr_utility.set_message(801,'PAY_376882_NO_ELE_CODE_LE');
                  --fnd_message.set_token('LE',rec_get_ele_code.eei_information2);
                  fnd_message.set_token('LE',rec_get_le_details.name);
                  hr_utility.raise_error;
            ELSIF( p_eei_information2 IS NULL AND p_eei_information1 = rec_get_ele_code.eei_information1) THEN
                  hr_utility.set_message(801,'PAY_376882_NO_ELE_CODE_LE');
                  --fnd_message.set_token('LE',rec_get_ele_code.eei_information2);
                  fnd_message.set_token('LE',rec_get_le_details.name);
                  hr_utility.raise_error;
            END IF;
	      END IF;

	      IF( rec_get_ele_code.eei_information2 IS NULL ) THEN
            IF( p_eei_information2 IS NULL) THEN
                  hr_utility.set_message(801,'PAY_376883_NO_ELE_CODE_LE_GLOB');
                  hr_utility.raise_error;
            ELSIF( p_eei_information2 IS NOT NULL AND p_eei_information1 = rec_get_ele_code.eei_information1) THEN
                  hr_utility.set_message(801,'PAY_376883_NO_ELE_CODE_LE_GLOB');
                  hr_utility.raise_error;
            END IF;
	      END IF;

      END LOOP;

      --
      END IF;
--
END CREATE_ELEMENT_ELE_CODE;

--------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_ELEMENT_ELE_CODE
  (p_element_type_extra_info_id IN NUMBER
  ,p_eei_attribute_category     IN VARCHAR2
  ,p_eei_attribute1             IN VARCHAR2
  ,p_eei_attribute2             IN VARCHAR2
  ,p_eei_attribute3             IN VARCHAR2
  ,p_eei_attribute4             IN VARCHAR2
  ,p_eei_attribute5             IN VARCHAR2
  ,p_eei_attribute6             IN VARCHAR2
  ,p_eei_attribute7             IN VARCHAR2
  ,p_eei_attribute8             IN VARCHAR2
  ,p_eei_attribute9             IN VARCHAR2
  ,p_eei_attribute10            IN VARCHAR2
  ,p_eei_attribute11            IN VARCHAR2
  ,p_eei_attribute12            IN VARCHAR2
  ,p_eei_attribute13            IN VARCHAR2
  ,p_eei_attribute14            IN VARCHAR2
  ,p_eei_attribute15            IN VARCHAR2
  ,p_eei_attribute16            IN VARCHAR2
  ,p_eei_attribute17            IN VARCHAR2
  ,p_eei_attribute18            IN VARCHAR2
  ,p_eei_attribute19            IN VARCHAR2
  ,p_eei_attribute20            IN VARCHAR2
  ,p_eei_information_category   IN VARCHAR2
  ,p_eei_information1           IN VARCHAR2
  ,p_eei_information2           IN VARCHAR2
  ,p_eei_information3           IN VARCHAR2
  ,p_eei_information4           IN VARCHAR2
  ,p_eei_information5           IN VARCHAR2
  ,p_eei_information6           IN VARCHAR2
  ,p_eei_information7           IN VARCHAR2
  ,p_eei_information8           IN VARCHAR2
  ,p_eei_information9           IN VARCHAR2
  ,p_eei_information10          IN VARCHAR2
  ,p_eei_information11          IN VARCHAR2
  ,p_eei_information12          IN VARCHAR2
  ,p_eei_information13          IN VARCHAR2
  ,p_eei_information14          IN VARCHAR2
  ,p_eei_information15          IN VARCHAR2
  ,p_eei_information16          IN VARCHAR2
  ,p_eei_information17          IN VARCHAR2
  ,p_eei_information18          IN VARCHAR2
  ,p_eei_information19          IN VARCHAR2
  ,p_eei_information20          IN VARCHAR2
  ,p_eei_information21          IN VARCHAR2
  ,p_eei_information22          IN VARCHAR2
  ,p_eei_information23          IN VARCHAR2
  ,p_eei_information24          IN VARCHAR2
  ,p_eei_information25          IN VARCHAR2
  ,p_eei_information26          IN VARCHAR2
  ,p_eei_information27          IN VARCHAR2
  ,p_eei_information28          IN VARCHAR2
  ,p_eei_information29          IN VARCHAR2
  ,p_eei_information30          IN VARCHAR2
  ,p_object_version_number      IN NUMBER
  ) is

     CURSOR csr_get_element_type_id ( p_element_type_extra_info_id NUMBER )IS
     SELECT element_type_id
     FROM pay_element_type_extra_info petei
     WHERE petei.information_type='NO_ELEMENT_CODES'
     AND petei.element_type_extra_info_id = p_element_type_extra_info_id;

     CURSOR csr_get_ele_code_le_glob( p_ele_type_id  NUMBER
                                    ,p_ele_code VARCHAR2) IS
     SELECT eei_information1 , eei_information2
     FROM pay_element_type_extra_info petei
     WHERE petei.information_type='NO_ELEMENT_CODES'
     AND petei.element_type_id = p_ele_type_id
     AND petei.eei_information1 = p_ele_code;

     CURSOR csr_get_le_details(p_le_id NUMBER) IS
     SELECT  hou.name  NAME
     FROM hr_organization_units   hou
         ,hr_organization_information   hoi
     WHERE hoi.organization_id = hou.organization_id
     AND   hoi.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS'
     AND   hou.organization_id = p_le_id;

     CURSOR csr_get_element_type IS
     SELECT element_type_id
     FROM  pay_element_type_extra_info etei
     WHERE etei.information_type          ='NO_EOY_REPORTING_CODE_MAPPING'
     AND   etei.element_type_extra_info_id = p_element_type_extra_info_id;

     CURSOR csr_chk_element_eit_year(l_element_type_id NUMBER) IS
     SELECT 'Y', etei.eei_information3
     FROM  pay_element_type_extra_info etei
     WHERE etei.element_type_id            = l_element_type_id
     AND   etei.eei_information_category   = 'NO_EOY_REPORTING_CODE_MAPPING'
     AND   etei.element_type_extra_info_id <> p_element_type_extra_info_id
     AND   ((to_number(etei.eei_information1)
           between  to_number(p_eei_information1) and to_number(nvl(p_eei_information2,'4712')))
     OR    (to_number(p_eei_information1)
           between  to_number(etei.eei_information1) and to_number(nvl(etei.eei_information2,'4712')))) ;

     --
    l_year_status            varchar2(1);
    l_overlap_code           pay_element_type_extra_info.eei_information3%TYPE;
    rec_get_element_type     csr_get_element_type%ROWTYPE;
    rec_get_ele_code_le_glob csr_get_ele_code_le_glob%ROWTYPE;
    rec_get_element_type_id  csr_get_element_type_id%ROWTYPE;
    rec_get_le_details	     csr_get_le_details%ROWTYPE;

    l_element_type_id  NUMBER;
    --
BEGIN
--
      IF p_eei_information_category = 'NO_EOY_REPORTING_CODE_MAPPING' THEN
      -- Validation to ensure Year of Reporting(EOY) is different then what we already have in Extra Element Info DDF
        IF to_number(p_eei_information2) < to_number(p_eei_information1) THEN
          hr_utility.set_message(801,'PAY_376896_NO_YEAR_RESTRICT');
          hr_utility.raise_error;
        END IF;
        --
        OPEN  csr_get_element_type;
        FETCH csr_get_element_type INTO rec_get_element_type;
        CLOSE csr_get_element_type;
        --
        OPEN  csr_chk_element_eit_year(rec_get_element_type.element_type_id);
        FETCH csr_chk_element_eit_year INTO l_year_status, l_overlap_code;
        CLOSE csr_chk_element_eit_year;
        --
        IF (l_year_status = 'Y') THEN
          hr_utility.set_message(801,'PAY_376893_NO_YEAR_EXISTS');
          fnd_message.set_token('REP_CODE', l_overlap_code); --p_eei_information3);
          hr_utility.raise_error;
        END IF;
        --
        -- Validation to check if single input value is mapped to more than one column in Extra Element Info DDF
        IF (p_eei_information4 = p_eei_information6 OR p_eei_information4 = p_eei_information8
        OR p_eei_information4 = p_eei_information10 OR p_eei_information4 = p_eei_information12
        OR p_eei_information4 = p_eei_information14 OR p_eei_information4 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
         END IF;
        --
        IF (p_eei_information6 = p_eei_information8  OR p_eei_information6 = p_eei_information10
        OR p_eei_information6 = p_eei_information12 OR p_eei_information6 = p_eei_information14
        OR p_eei_information6 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information8 = p_eei_information10 OR p_eei_information8 = p_eei_information12
        OR p_eei_information8 = p_eei_information14 OR p_eei_information8 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information10 = p_eei_information12 OR p_eei_information10 = p_eei_information14
        OR p_eei_information10 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information12 = p_eei_information14 OR p_eei_information12 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        --
        IF (p_eei_information14 = p_eei_information16) THEN
          hr_utility.set_message(801,'PAY_376894_NO_DUP_INPUT_VALUE');
          hr_utility.raise_error;
        END IF;
        -- Validation to check if input value is specified without a mapping column in Extra Element Info DDF
        IF (p_eei_information5 IS NULL and p_eei_information6 IS NOT NULL)
          OR (p_eei_information7 IS NULL and p_eei_information8 IS NOT NULL)
          OR (p_eei_information9 IS NULL and p_eei_information10 IS NOT NULL)
          OR (p_eei_information11 IS NULL and p_eei_information12 IS NOT NULL)
          OR (p_eei_information13 IS NULL and p_eei_information14 IS NOT NULL)
          OR (p_eei_information15 IS NULL and p_eei_information16 IS NOT NULL) THEN
          hr_utility.set_message(801,'PAY_376895_NO_COL_MAP_MISSING');
          hr_utility.raise_error;
        END IF;
      --
      END IF;
    --
    -- EOY Report Validations @ Extra Element Info DDF
    --
      IF p_eei_information_category = 'NO_ELEMENT_CODES' THEN

      OPEN csr_get_element_type_id ( p_element_type_extra_info_id );
      FETCH csr_get_element_type_id INTO rec_get_element_type_id;
      CLOSE csr_get_element_type_id;

      l_element_type_id := rec_get_element_type_id.element_type_id;


	-- Validation to ensure element code once entered cannot be entered again on that Legal Employer or globally.
        OPEN  csr_get_ele_code_le_glob(l_element_type_id , p_eei_information1);
        FETCH csr_get_ele_code_le_glob INTO rec_get_ele_code_le_glob;

         IF ( csr_get_ele_code_le_glob%FOUND AND rec_get_ele_code_le_glob.eei_information2 is NOT NULL) THEN

	 OPEN csr_get_le_details(to_number(rec_get_ele_code_le_glob.eei_information2));
	 FETCH csr_get_le_details INTO rec_get_le_details;
	 CLOSE csr_get_le_details;

          hr_utility.set_message(801,'PAY_376882_NO_ELE_CODE_LE');
          --fnd_message.set_token('LE',rec_get_ele_code_le_glob.eei_information2);
	  fnd_message.set_token('LE',rec_get_le_details.name);
          hr_utility.raise_error;
         END IF;


         IF ( csr_get_ele_code_le_glob%FOUND AND rec_get_ele_code_le_glob.eei_information2 IS NULL) THEN
          hr_utility.set_message(801,'PAY_376883_NO_ELE_CODE_LE_GLOB');
          hr_utility.raise_error;
         END IF;

        CLOSE csr_get_ele_code_le_glob;

      --
      END IF;
--
END UPDATE_ELEMENT_ELE_CODE;

-----------------------------------------------------------------------------------------------

PROCEDURE update_ele_entry_bp
  ( p_effective_date		  IN	  DATE
   ) IS
   --
   CURSOR csr_get_session_id IS
   SELECT 1
   FROM fnd_sessions
   WHERE session_id = userenv('sessionid');
   --
   l_sess_row csr_get_session_id%ROWTYPE;
BEGIN
   --
   OPEN csr_get_session_id;
   FETCH csr_get_session_id INTO l_sess_row;
   IF csr_get_session_id%NOTFOUND THEN
        INSERT INTO fnd_sessions (session_id, effective_date)
        VALUES (userenv('sessionid'), trunc(p_effective_date));
   END IF;
   CLOSE csr_get_session_id;
   --
END;


PROCEDURE create_ele_entry_bp
 ( p_effective_date		  IN	  DATE
  ) IS
   --
   CURSOR csr_get_session_id IS
   SELECT 1
   FROM fnd_sessions
   WHERE session_id = userenv('sessionid');
   --
   l_sess_row csr_get_session_id%ROWTYPE;
BEGIN
   --
   OPEN csr_get_session_id;
   FETCH csr_get_session_id INTO l_sess_row;
   IF csr_get_session_id%NOTFOUND THEN
        INSERT INTO fnd_sessions (session_id, effective_date)
        VALUES (userenv('sessionid'), trunc(p_effective_date));
   END IF;
   CLOSE csr_get_session_id;
   --
END;

PROCEDURE update_ele_entry_ap
 ( p_effective_date		  IN	  DATE
   ) IS
BEGIN
  DELETE FROM fnd_sessions WHERE session_id = userenv('sessionid');
END;
--
PROCEDURE create_ele_entry_ap
 ( p_effective_date		  IN	  DATE
   ) IS
BEGIN
  DELETE FROM fnd_sessions WHERE session_id = userenv('sessionid');
END;

-----------------------------------------------------------------------------------------------


END hr_no_validate_pkg;

/
