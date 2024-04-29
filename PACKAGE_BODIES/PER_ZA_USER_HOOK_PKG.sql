--------------------------------------------------------
--  DDL for Package Body PER_ZA_USER_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_USER_HOOK_PKG" AS
/* $Header: pezauhkp.pkb 120.0.12010000.12 2010/03/24 05:29:52 rbabla ship $ */
   --------------------
   -- Package variables
   --------------------
   g_package  varchar2(21) := 'per_za_user_hook_pkg.';
   --------------------------------------------------------------------------
   -- validate_race                                                        --
   --------------------------------------------------------------------------
   -- Description:
   --    Checks that a valid race has been entered for
   --    applicants, employees and contingent workers.
   -- Called from:
   --    validate_applicant
   --    validate_employee
   --    validate_cwk
   --    validate_person
   -- Person DDF segments used :
   --    SEGMENT            NAME
   --    -------            ----
   --    PER_INFORMATION4   Race
   --
   ---------------------------------------------------------------------------
   --                                                                       --
   ---------------------------------------------------------------------------
   PROCEDURE validate_race
   ( p_effective_date in date
   , p_person_type_id in number   default null
   , p_race_code      in varchar2 default null
   ) IS
      -- Cursors
      --
      CURSOR c_system_person_type
      IS
         SELECT typ.system_person_type
           FROM per_person_types typ
          WHERE typ.person_type_id     = p_person_type_id;
      -- Local Variables
      --
      l_proc               varchar2(40) := g_package||'validate_race';
      l_system_person_type per_person_types.system_person_type%TYPE;
   BEGIN

      -- The Race segment is mandatory for employees, applicants and
      -- contingent workers
      --
         -- Find the system person type
         --
         OPEN  c_system_person_type;
         FETCH c_system_person_type INTO l_system_person_type;
         CLOSE c_system_person_type;

         -- RACE is required for system person types
         -- of APL, EMP and CWK
         --
         IF l_system_person_type IN ('APL','EMP','CWK') THEN
            IF hr_multi_message.no_exclusive_error
               ( p_check_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION4'
               )
            THEN
              IF p_race_code IS NULL OR
                 p_race_code = 'N'   OR
                 hr_api.not_exists_in_hr_lookups
                    (p_effective_date => p_effective_date
                    ,p_lookup_type    => 'ZA_RACE'
                    ,p_lookup_code    => p_race_code
                    )
              THEN
                 fnd_message.set_name('PER', 'HR_ZA_MAND_SEG_RACE');
                 hr_multi_message.add
                   (p_associated_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION4'
                   );
              END IF;
            END IF;
         END IF;
   END validate_race;
   --------------------------------------------------------------------------
   -- validate_email_id                                                        --
   --------------------------------------------------------------------------
   -- Description:
   --    Checks that a valid email_id has been entered for
   --    applicants, employees and contingent workers.
   -- Called from:
   --    validate_applicant
   --    validate_employee
   --    validate_cwk
   --    validate_person
   -- Person fields used : EMAIL_ADDRESS
   --
   ---------------------------------------------------------------------------
   --                                                                       --
   ---------------------------------------------------------------------------
   procedure validate_email_id (p_email_id varchar2 ) is
         l_validate_flag boolean := true ;
    begin
      if p_email_id is not null and p_email_id <> hr_api.g_varchar2 then
        if length(p_email_id) >70 then
             fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
             fnd_message.set_token('FIELD', 'Email Address');
             fnd_message.set_token('LENGTH', '70');
             fnd_message.set_token('UNITS', 'characters');
             fnd_message.raise_error;
        elsif instr(p_email_id,'@') <= 0 or instr(p_email_id,'.') <= 0 then
             fnd_message.set_name('PER', 'HR_ZA_INVALID_CONTACT_EMAIL');
             fnd_message.set_token('CONTACT', '');
             fnd_message.raise_error;
        elsif validate_charcter_set(p_email_id,'FREETEXT') = false then
             fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
             fnd_message.set_token('FIELD', 'Email Address');
             fnd_message.raise_error;
        end if ;

      end if;
    end validate_email_id ;
   --------------------------------------------------------------------------
   -- validate_phone_number                                                        --
   --------------------------------------------------------------------------
   -- Description:
   --    Checks that a valid phone_number has been entered for
   --    applicants, employees and contingent workers.
   --
   ---------------------------------------------------------------------------
   --                                                                       --
   ---------------------------------------------------------------------------
   procedure validate_phone_no (  p_phone_type  in     varchar2,
                                  p_phone_number  in   varchar2) is
        l_phone_int number ;
    begin
      hr_utility.trace('p_phone_type='||p_phone_type);
      hr_utility.trace('p_phone_number='||p_phone_number);
      if p_phone_number is not null and p_phone_number <> hr_api.g_varchar2 then
         begin
             l_phone_int := to_number(p_phone_number);
         exception
            when others then
             fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
             fnd_message.set_token('FIELD', hr_general.decode_lookup('PHONE_TYPE', p_phone_type)||' phone number');
             fnd_message.raise_error;
         end;

         if p_phone_type in ('GRE') then
             if length(p_phone_number)<9 or length(p_phone_number)>11 then
	             fnd_message.set_name('PER', 'HR_ZA_INVALID_PH_NO');
                 fnd_message.set_token('FIELD', 'phone number');
  	             fnd_message.raise_error;
             end if;
         elsif p_phone_type in ('H1','H2','H3','W1','W2','W3','HF','WF') then
             if length(p_phone_number)<9 or length(p_phone_number)>11 then
	             fnd_message.set_name('PER', 'HR_ZA_INVALID_PH_NO');
	             fnd_message.set_token('FIELD', hr_general.decode_lookup('PHONE_TYPE', p_phone_type)||' phone number');
  	             fnd_message.raise_error;
             end if;
         elsif p_phone_type in ('M') then
             if length(p_phone_number)<10 or length(p_phone_number)>11 then
	             fnd_message.set_name('PER', 'HR_ZA_INVALID_MOBILE');
  	             fnd_message.raise_error;
             end if;
         end if;
     end if;
    end validate_phone_no;
-------------------------------------------------------------------------------
-- validate_applicant
-------------------------------------------------------------------------------
PROCEDURE validate_applicant
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_date_received
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type          default null
   )
AS
   ------------
   -- Variables
   ------------
   l_proc            varchar2(40) := g_package||'validate_applicant';
   l_person_type_id  per_all_people_f.person_type_id%type;

BEGIN
--   hr_utility.trace_on(null,'ZAUHK');
   hr_utility.trace('validate person');
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
      hr_utility.set_location(l_proc,1);

      -- Check/Find person type id
      --
      per_per_bus.chk_person_type
         ( p_person_type_id    => l_person_type_id
         , p_business_group_id => p_business_group_id
         , p_expected_sys_type => 'APL'
         );

      hr_utility.set_location(l_proc,2);

      -- Validate the person's race
      --
      validate_race
         ( p_effective_date => p_date_received
         , p_person_type_id => l_person_type_id
         , p_race_code      => p_per_information4
         );

      validate_email_id
         ( p_email_id => p_email_address);

      if p_per_information2 is not null and p_per_information2 <> hr_api.g_varchar2 then
      if length(p_per_information2)< 7 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_MIN_LENGTH');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.set_token('LENGTH', '7');
            fnd_message.set_token('UNITS', 'characters');
            fnd_message.raise_error;
      end if;
      if validate_charcter_set(p_per_information2,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.raise_error;
      end if;
      end if;

      -- Removing this validation, as it does not holds true for Nature of Person N
      -- where country of passport issue is Optional
      -- If Passport number is provided, then Country of Passport Issue
      -- must also be provided
      -- if p_per_information2 is not null and p_per_information10 is null then
      --           fnd_message.set_name('PAY', 'PY_ZA_ENTER_PASS_COUNTRY_ISSUE');
      --         fnd_message.raise_error;
      --end if ;

      if p_per_information10 is not null and p_per_information10 <> hr_api.g_varchar2 then
      if validate_charcter_set(p_per_information10,'ALPHA') = false  then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.raise_error;
      end if;

      if length(p_per_information10) > 3 then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.set_token('LENGTH', '3');
          fnd_message.set_token('UNITS', 'characters');
          fnd_message.raise_error;
      end if;
      end if;

      hr_utility.set_location(l_proc,3);
   END IF;
END validate_applicant;
-------------------------------------------------------------------------------
-- validate_employee
-------------------------------------------------------------------------------
PROCEDURE validate_employee
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_hire_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   )
AS
   ------------
   -- Variables
   ------------
   l_proc            varchar2(40) := g_package||'validate_employee';
   l_person_type_id  per_all_people_f.person_type_id%type;

BEGIN
--   hr_utility.trace_on(null,'ZAUHK');
--   hr_utility.trace('validate employee');
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
      hr_utility.set_location(l_proc,1);

      -- Check/Find person type id
      --
      per_per_bus.chk_person_type
         ( p_person_type_id    => l_person_type_id
         , p_business_group_id => p_business_group_id
         , p_expected_sys_type => 'EMP'
         );

      hr_utility.set_location(l_proc,2);

      -- Validate the person's race
      --
      validate_race
         ( p_effective_date => p_hire_date
         , p_person_type_id => l_person_type_id
         , p_race_code      => p_per_information4
         );

        -- TYE2010
        -- Validate email_address
      validate_email_id
         ( p_email_id => p_email_address);

      if p_per_information2 is not null and p_per_information2 <> hr_api.g_varchar2 then
      if length(p_per_information2)< 7 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_MIN_LENGTH');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.set_token('LENGTH', '7');
            fnd_message.set_token('UNITS', 'characters');
            fnd_message.raise_error;
      end if;
      if validate_charcter_set(p_per_information2,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.raise_error;
      end if;
      end if;

      -- Removing this validation, as it does not holds true for Nature of Person N
      -- where country of passport issue is Optional
      -- If Passport number is provided, then Country of Passport Issue
      -- must also be provided
      --if p_per_information2 is not null and p_per_information10 is null then
      --           fnd_message.set_name('PAY', 'PY_ZA_ENTER_PASS_COUNTRY_ISSUE');
      --         fnd_message.raise_error;
      --end if ;

      if p_per_information10 is not null and p_per_information10 <> hr_api.g_varchar2 then
      if validate_charcter_set(p_per_information10,'ALPHA') = false  then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.raise_error;
      end if;

      if length(p_per_information10) > 3 then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.set_token('LENGTH', '3');
          fnd_message.set_token('UNITS', 'characters');
          fnd_message.raise_error;
      end if;
      end if;

      hr_utility.set_location(l_proc,3);
   END IF;
END validate_employee;
-------------------------------------------------------------------------------
-- validate_cwk
-------------------------------------------------------------------------------
PROCEDURE validate_cwk
   ( p_business_group_id
        in per_all_people_f.business_group_id%type        default null
   , p_start_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type           default null
   , p_per_information_category
        in per_all_people_f.per_information_category%type default null
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type         default null
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   )
AS
   ------------
   -- Variables
   ------------
   l_proc            varchar2(40) := g_package||'validate_cwk';
   l_person_type_id  per_all_people_f.person_type_id%type;

BEGIN
--   hr_utility.trace_on(null,'ZAUHK');
   hr_utility.trace('validate person');
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
      hr_utility.set_location(l_proc,1);

      -- Check/Find person type id
      --
      per_per_bus.chk_person_type
         ( p_person_type_id    => l_person_type_id
         , p_business_group_id => p_business_group_id
         , p_expected_sys_type => 'CWK'
         );

      hr_utility.set_location(l_proc,2);

      -- Validate the person's race
      --
      validate_race
         ( p_effective_date => p_start_date
         , p_person_type_id => l_person_type_id
         , p_race_code      => p_per_information4
         );

        -- TYE2010
        -- Validate email_address
      validate_email_id
         ( p_email_id => p_email_address);

      if p_per_information2 is not null and p_per_information2 <> hr_api.g_varchar2 then
      if length(p_per_information2)< 7 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_MIN_LENGTH');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.set_token('LENGTH', '7');
            fnd_message.set_token('UNITS', 'characters');
            fnd_message.raise_error;
      end if;
      if validate_charcter_set(p_per_information2,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.raise_error;
      end if;
      end if;

      -- Removing this validation, as it does not holds true for Nature of Person N
      -- where country of passport issue is Optional
      -- If Passport number is provided, then Country of Passport Issue
      -- must also be provided
      --if p_per_information2 is not null and p_per_information10 is null then
      --           fnd_message.set_name('PAY', 'PY_ZA_ENTER_PASS_COUNTRY_ISSUE');
      --         fnd_message.raise_error;
      --end if ;

      if p_per_information10 is not null and p_per_information10 <> hr_api.g_varchar2 then
      if validate_charcter_set(p_per_information10,'ALPHA') = false  then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.raise_error;
      end if;

      if length(p_per_information10) > 3 then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.set_token('LENGTH', '3');
          fnd_message.set_token('UNITS', 'characters');
          fnd_message.raise_error;
      end if;
      end if;

      hr_utility.set_location(l_proc,3);
   END IF;
END validate_cwk;
-------------------------------------------------------------------------------
-- validate_person
-------------------------------------------------------------------------------
PROCEDURE validate_person
   ( p_person_id
        in per_all_people_f.person_id%type
   , p_effective_date
        in date
   , p_person_type_id
        in per_all_people_f.person_type_id%type
   , p_per_information_category
        in per_all_people_f.per_information_category%type
   , p_per_information2
        in per_all_people_f.per_information2%type         default null
   , p_per_information4
        in per_all_people_f.per_information4%type
   , p_per_information10
        in per_all_people_f.per_information10%type         default null
   , p_email_address
        in per_all_people_f.email_address%type         default null
   )
AS
   ---------
   -- Cursor
   ---------
   CURSOR c_person_person_type
   IS
      SELECT person_type_id
        FROM per_all_people_f
       WHERE person_id = p_person_id
         AND p_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;
   CURSOR c_person_race
   IS
      SELECT per_information4
        FROM per_all_people_f
       WHERE person_id = p_person_id
         AND p_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;
   ------------
   -- Variables
   ------------
   l_proc            varchar2(40) := g_package||'validate_person';
   l_person_type_id  per_all_people_f.person_type_id%type;
   l_person_race     per_all_people_f.per_information4%type;

BEGIN
--   hr_utility.trace_on(null,'ZAUHK');
--   hr_utility.trace('validate person');
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
      hr_utility.set_location(l_proc,1);

      -- If the person type id was not passed
      --
      IF p_person_type_id = hr_api.g_number THEN
         hr_utility.set_location(l_proc,2);
         -- Find the person's person type
         --
         OPEN  c_person_person_type;
         FETCH c_person_person_type INTO l_person_type_id;
         CLOSE c_person_person_type;
      ELSE
         hr_utility.set_location(l_proc,3);
         l_person_type_id := p_person_type_id;
      END IF;

      -- if the race field was not updated
      --
      IF p_per_information4 = hr_api.g_varchar2 THEN
         hr_utility.set_location(l_proc,4);
         -- find the person's race
         --
         OPEN  c_person_race;
         FETCH c_person_race INTO l_person_race;
         CLOSE c_person_race;
      ELSE
         hr_utility.set_location(l_proc,5);
         l_person_race := p_per_information4;
      END IF;

      -- Validate the person's race
      --
      validate_race
         ( p_effective_date => p_effective_date
         , p_person_type_id => l_person_type_id
         , p_race_code      => l_person_race
         );

        -- TYE2010
        -- Validate email_address
      validate_email_id
         ( p_email_id => p_email_address);

      hr_utility.set_location(l_proc,6);

      if p_per_information2 is not null and p_per_information2 <> hr_api.g_varchar2 then
      if length(p_per_information2)< 7 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_MIN_LENGTH');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.set_token('LENGTH', '7');
            fnd_message.set_token('UNITS', 'characters');
            fnd_message.raise_error;
      end if;
      if validate_charcter_set(p_per_information2,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.raise_error;
      end if;
      end if;

      -- Removing this validation, as it does not holds true for Nature of Person N
      -- where country of passport issue is Optional
      -- If Passport number is provided, then Country of Passport Issue
      -- must also be provided
      --if p_per_information2 is not null and p_per_information10 is null then
      --           fnd_message.set_name('PAY', 'PY_ZA_ENTER_PASS_COUNTRY_ISSUE');
      --         fnd_message.raise_error;
      --end if ;

      if p_per_information10 is not null and p_per_information10 <> hr_api.g_varchar2 then
      if validate_charcter_set(p_per_information10,'ALPHA') = false  then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.raise_error;
      end if;

      if length(p_per_information10) > 3 then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
          fnd_message.set_token('FIELD', 'Country of Passport Issue');
          fnd_message.set_token('LENGTH', '3');
          fnd_message.set_token('UNITS', 'characters');
          fnd_message.raise_error;
      end if;
      end if;

      hr_utility.set_location(l_proc,6);
   END IF;

END validate_person;

-------------------------------------------------------------------------------
-- validate_asg_extra_info
-------------------------------------------------------------------------------
-- Description:
--    Validates Assignment Extra Information for South Africa.
-- Called from:
--    CREATE_ASSIGNMENT_EXTRA_INFO and UPDATE_ASSIGNMENT_EXTRA_INFO APIs
-- Assignment EIT segments used :
--    SEGMENT            NAME
--    -------            ----
--    AEI_ATTRIBUTE2     Employee Trade Name
--    AEI_INFORMATION4   Nature of Person
--    AEI_ATTRIBUTE13    Payment Type
--    AEI_INFORMATION14  SARS Reporting Account Number
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_asg_extra_info (P_AEI_INFORMATION_CATEGORY in VARCHAR2
                                    , P_AEI_INFORMATION2 in VARCHAR2
                                    , P_AEI_INFORMATION4 in VARCHAR2
                                    , P_AEI_INFORMATION13 in VARCHAR2
                                    , P_AEI_INFORMATION14 in VARCHAR2) as
    begin
       IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
           IF P_AEI_INFORMATION_CATEGORY = 'ZA_SPECIFIC_INFO' THEN
                -- Employee Trade Name id mandatory if nature of person
                -- is in (D,E,F,G,H)
                IF P_AEI_INFORMATION4 in ('04','05','06','07','08') THEN
                      IF P_AEI_INFORMATION2 is null THEN
                          fnd_message.set_name('PAY', 'PY_ZA_ENTER_NAT_DEFGH_TRADE');
    	                  fnd_message.raise_error;
                      END IF;
                END IF;

                IF validate_charcter_set(P_AEI_INFORMATION2,'FREETEXT') = false then
                     fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                     fnd_message.set_token('FIELD', 'Employee Trading Name');
    	             fnd_message.raise_error;
                END IF;
                -- SARS Reporting Account Name is mandatory if Payment Type is
                -- 'Internal Account Transfer'
                IF P_AEI_INFORMATION13 = '1' THEN
                      IF P_AEI_INFORMATION14 is null THEN
                          fnd_message.set_name('PAY', 'PY_ZA_ENTER_REP_ACC_NO');
    	                    fnd_message.raise_error;
                      END IF;
                END IF;
           END IF;
       END IF;
    end validate_asg_extra_info;

-- Generic procedure to be called from
-- validate_person_address and validate_location_address
   procedure  validate_address (P_STYLE           in varchar2
                               ,P_ADDRESS_TYPE    in varchar2 default null
                               ,P_PRIMARY_FLAG    in varchar2 default null
                               ,P_UNIT_NUMBER     in varchar2 default null
					   		   ,P_COMPLEX         in varchar2 default null
							   ,P_STREET_NUMBER   in varchar2 default null
							   ,P_STREET_NAME     in varchar2 default null
							   ,P_SUBURB_DISTRICT in varchar2 default null
							   ,P_TOWN_OR_CITY    in varchar2 default null
							   ,P_POSTAL_CODE     in varchar2 default null
                               ,P_SAME_AS_RES_ADD in varchar2 default null
                               ,P_ADDRESS_LINE1   in varchar2 default null
                               ,P_ADDRESS_LINE2   in varchar2 default null
                               ,P_ADDRESS_LINE3   in varchar2 default null) as
   begin
   -- Primary address must be with 'South Africa' address style
   -- This will be assumed and reported as Postal Address of the person
   if P_PRIMARY_FLAG = 'Y' and p_style <> 'ZA' then
       fnd_message.set_name('PER','HR_ZA_PRIM_ADD_STYLE');
       fnd_message.raise_error;
   end if;

   if p_style in('ZA_SARS','ZA_GRE')  then
       -- ZA_SARS means Business / Residential address
       -- ZA_GRE  means Legal Entity address
       hr_utility.trace('Address Type='||P_ADDRESS_TYPE);
       hr_utility.trace('Primary Flag='||P_PRIMARY_FLAG);
       hr_utility.trace('Unit Number='||P_UNIT_NUMBER);
       hr_utility.trace('Complex='||P_COMPLEX);
       hr_utility.trace('Street Number='||P_STREET_NUMBER);
       hr_utility.trace('Street or Name of Farm='||P_STREET_NAME);
       hr_utility.trace('Suburb/District='||P_SUBURB_DISTRICT);
       hr_utility.trace('City/Town='||P_TOWN_OR_CITY);
       hr_utility.trace('Postal Code='||P_POSTAL_CODE);
       hr_utility.trace('Same as Res Address flag='||P_SAME_AS_RES_ADD);

       if P_SUBURB_DISTRICT is null and P_TOWN_OR_CITY is null then
            fnd_message.set_name('PER', 'HR_ZA_ENTER_DISTRICT_OR_TOWN');
            if p_style in('ZA_SARS') then
                fnd_message.set_token('LOCATION', 'Person Address');
            else
                fnd_message.set_token('LOCATION', 'Employer Address');
            end if;
            fnd_message.raise_error;
       end if ;

       if validate_charcter_set(P_UNIT_NUMBER,'ALPHANUM') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Unit Number');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_COMPLEX,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Complex');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_STREET_NUMBER,'ALPHANUM') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Street Number');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_STREET_NAME,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Street or Name of Farm');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_SUBURB_DISTRICT,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Suburb or District');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_TOWN_OR_CITY,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'City or Town');
    	      fnd_message.raise_error;
       elsif validate_charcter_set(P_POSTAL_CODE,'ALPHANUM') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Postal Code');
    	      fnd_message.raise_error;
       end if ;

       if p_style = 'ZA_GRE' then
           if length(P_POSTAL_CODE)<> 4 then
     	      fnd_message.set_name('PER', 'HR_ZA_INVALID_LENGTH');
	          fnd_message.set_token('FIELD', 'Postal Code');
	          fnd_message.set_token('LENGTH', '4');
	          fnd_message.set_token('UNITS', 'digits');
  	          fnd_message.raise_error;
           end if;
       end if;
   elsif p_style = 'ZA' then
        -- Postal Address
        if P_SAME_AS_RES_ADD is null or P_SAME_AS_RES_ADD = 'N' then
            if P_ADDRESS_LINE1 is null then
                fnd_message.set_name('PER', 'HR_ZA_NEW_ENTER_ADDRESS_LINE1');
                fnd_message.raise_error;
            end if;
            if P_POSTAL_CODE is null then
                fnd_message.set_name('PER', 'HR_ZA_NEW_ENTER_POSTAL_CODE');
                fnd_message.set_token('LOCATION', 'Postal Address');
                fnd_message.raise_error;
            end if;
        end if ;

        if validate_charcter_set(P_ADDRESS_LINE1,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Address Line 1');
    	      fnd_message.raise_error;
        elsif validate_charcter_set(P_ADDRESS_LINE2,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Address Line 2');
    	      fnd_message.raise_error;
        elsif validate_charcter_set(P_ADDRESS_LINE3,'FREETEXT') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Address Line 3');
    	      fnd_message.raise_error;
        elsif validate_charcter_set(P_POSTAL_CODE,'ALPHANUM') = false then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Postal Code');
    	      fnd_message.raise_error;
        end if;
   end if;
   end validate_address;

-------------------------------------------------------------------------------
-- validate_person_address
-------------------------------------------------------------------------------
-- Description:
--    Validates Personal address for Address Style 'South Africa'.
-- Called from:
--    CREATE_PERSON_ADDRESS and UPDATE_PERSON_ADDRESS APIs
-- Segments used :
--    AddressStyle = ZA
--    SEGMENT            NAME
--    -------            ----
--    ADDRESS_LINE1      Unit Number
--    ADDRESS_LINE2      Complex
--    ADDRESS_LINE3      Street Number
--    REGION1            Street or Name of Farm
--    REGION2            Suburb/District
--    TOWN_OR_CITY       City/Town
--    POSTAL_CODE        Postal Code
--    AddressStyle = ZA_POS
--    SEGMENT            NAME
--    -------            ----
--    REGION_1           Postal Address same as Residential Address
--    ADDRESS_LINE1      Address Line1
--    ADDRESS_LINE2      Address Line2
--    ADDRESS_LINE3      Address Line3
--    POSTAL_CODE        Postal Code
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_person_address (P_STYLE           in varchar2
                               ,P_ADDRESS_TYPE    in varchar2
                               ,P_PRIMARY_FLAG    in varchar2
                               ,P_ADDRESS_LINE1   in varchar2
                               ,P_ADDRESS_LINE2   in varchar2
                               ,P_ADDRESS_LINE3   in varchar2
                               ,P_TELEPHONE_NUMBER_1 in varchar2
                               ,P_REGION_1        in varchar2
                               ,P_REGION_2        in varchar2
							   ,P_TOWN_OR_CITY    in varchar2
							   ,P_POSTAL_CODE     in varchar2) as
   begin
       if p_style = 'ZA_SARS' then
           -- Residential or Business Address
           validate_address (P_STYLE           => P_STYLE
                            ,P_ADDRESS_TYPE    => P_ADDRESS_TYPE
                            ,P_UNIT_NUMBER     => P_ADDRESS_LINE1
							,P_COMPLEX         => P_ADDRESS_LINE2
							,P_STREET_NUMBER   => P_ADDRESS_LINE3
							,P_STREET_NAME     => P_REGION_1
							,P_SUBURB_DISTRICT => P_REGION_2
							,P_TOWN_OR_CITY    => P_TOWN_OR_CITY
							,P_POSTAL_CODE     => P_POSTAL_CODE
							,P_PRIMARY_FLAG    => P_PRIMARY_FLAG
                            );
       elsif p_style = 'ZA' then
           -- Postal Address
           validate_address (P_STYLE           => P_STYLE
                            ,P_ADDRESS_TYPE    => P_ADDRESS_TYPE
                            ,P_PRIMARY_FLAG    => P_PRIMARY_FLAG
                            ,P_SAME_AS_RES_ADD => P_REGION_2
                            ,P_ADDRESS_LINE1   => P_ADDRESS_LINE1
                            ,P_ADDRESS_LINE2   => P_ADDRESS_LINE2
                            ,P_ADDRESS_LINE3   => P_ADDRESS_LINE3
							,P_POSTAL_CODE     => P_POSTAL_CODE
                            );
       end if;
   end validate_person_address;

-------------------------------------------------------------------------------
-- validate_location_extra_info
-------------------------------------------------------------------------------
-- Description:
--    Validates Location EIT address for Address Style 'South Africa - SARS'.
-- Called from:
--    CREATE_LOCATION_EXTRA_INFO and UPDATE_LOCATION_EXTRA_INFO  APIs
--
--    AddressStyle = ZA_SARS
--    AddressType  = ZA_BUS
--    PrimaryFlag= 'N'
--    P_LEI_ATTRIBUTE_CATEGORY = ZA_SARS_ADDRESS
--
-- Segments used :
--
--    SEGMENT            NAME
--    -------            ----
--    P_LEI_INFORMATION1     Unit Number
--    P_LEI_INFORMATION2     Complex
--    P_LEI_INFORMATION3     Street Number
--    P_LEI_INFORMATION4     Street or Name of Farm
--    P_LEI_INFORMATION5     Suburb/District
--    P_LEI_INFORMATION6     City/Town
--    P_LEI_INFORMATION7     Postal Code
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_location_extra_info (
                               		P_LEI_INFORMATION_CATEGORY	in	varchar2,
                            		P_LEI_INFORMATION1		in	varchar2,
                            		P_LEI_INFORMATION2		in	varchar2,
                            		P_LEI_INFORMATION3		in	varchar2,
                            		P_LEI_INFORMATION4		in	varchar2,
                            		P_LEI_INFORMATION5		in	varchar2,
                            		P_LEI_INFORMATION6		in	varchar2,
                            		P_LEI_INFORMATION7		in	varchar2) as
    begin
        if P_LEI_INFORMATION_CATEGORY = 'ZA_SARS_ADDRESS' then
           validate_address (P_STYLE           => 'ZA_SARS'
                            ,P_ADDRESS_TYPE    => 'ZA_BUS'
                            ,P_UNIT_NUMBER     => P_LEI_INFORMATION1
							,P_COMPLEX         => P_LEI_INFORMATION2
							,P_STREET_NUMBER   => P_LEI_INFORMATION3
							,P_STREET_NAME     => P_LEI_INFORMATION4
							,P_SUBURB_DISTRICT => P_LEI_INFORMATION5
							,P_TOWN_OR_CITY    => P_LEI_INFORMATION6
							,P_POSTAL_CODE     => P_LEI_INFORMATION7
							,P_PRIMARY_FLAG    => 'N'
                            );
        end if;
    end validate_location_extra_info;
-------------------------------------------------------------------------------
-- validate_org_info
-------------------------------------------------------------------------------
-- Description:
--    Validate Organization Information
-- Called from:
--    CREATE_ORG_INFORMATION and UPDATE_ORG_INFORMATION
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    procedure validate_org_info (p_org_info_type_code IN  VARCHAR2
                                ,p_org_information1   IN  VARCHAR2
                                ,p_org_information2   IN  VARCHAR2
                                ,p_org_information3   IN  VARCHAR2
                                ,p_org_information4   IN  VARCHAR2
                                ,p_org_information5   IN  VARCHAR2
                                ,p_org_information6   IN  VARCHAR2
                                ,p_org_information7   IN  VARCHAR2
                                ,p_org_information8   IN  VARCHAR2
                                ,p_org_information9   IN  VARCHAR2
                                ,p_org_information10  IN  VARCHAR2
                                ,p_org_information11  IN  VARCHAR2
                                ,p_org_information12  IN  VARCHAR2
                                ,p_org_information13  IN  VARCHAR2
                                )as
   begin
           -- Org Info Type : ZA_GRE_TAX_FILE_ENTITY
           if p_org_info_type_code = 'ZA_GRE_TAX_FILE_ENTITY' then
                  if validate_charcter_set(p_org_information1,'ALPHA') = false then
                      fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                      fnd_message.set_token('FIELD', 'Contact Person');
    	              fnd_message.raise_error;
                  end if;

                  validate_phone_no(p_phone_type    => 'GRE'
                                  , p_phone_number  => p_org_information2);

                  validate_email_id (p_email_id => p_org_information3);

                  validate_address (P_STYLE   => 'ZA_GRE'
                            ,P_PRIMARY_FLAG    => null
                            ,P_UNIT_NUMBER     => p_org_information4
							,P_COMPLEX         => p_org_information5
							,P_STREET_NUMBER   => p_org_information6
							,P_STREET_NAME     => p_org_information7
							,P_SUBURB_DISTRICT => p_org_information8
							,P_TOWN_OR_CITY    => p_org_information9
							,P_POSTAL_CODE     => p_org_information10
                            );
            elsif p_org_info_type_code = 'ZA_LEGAL_ENTITY' then
                  if validate_charcter_set(p_org_information1,'FREETEXT') = false then
                      fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                      fnd_message.set_token('FIELD', 'Company Trading or Other Name');
    	              fnd_message.raise_error;
                  end if;

                  if validate_charcter_set(p_org_information13,'NUMERIC') = false then
                      fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                      fnd_message.set_token('FIELD', 'Trade Classification');
    	              fnd_message.raise_error;
                  end if;

                  if length(p_org_information13) > 4 then
     	             fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
	                 fnd_message.set_token('FIELD', 'Trade Classification');
	                 fnd_message.set_token('LENGTH', '4');
	                 fnd_message.set_token('UNITS', 'digits');
  	                 fnd_message.raise_error;
                  end if;
            end if;
    end validate_org_info;

-------------------------------------------------------------------------------
-- validate_charcter_set
-------------------------------------------------------------------------------
-- Description:
--    Validates Character Sets for South Africa.
--
---------------------------------------------------------------------------
--                                                                       --
---------------------------------------------------------------------------
    function validate_charcter_set (p_input_value in varchar2
                                   , p_mode in varchar2 ) return boolean as
         /*
         l_invalid_char      constant varchar2(1) := '~';
         l_root_alpha varchar2(52) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
         l_alpha varchar2(60)    := l_root_alpha || '- ,''';
         l_alphanum varchar2(70) := l_root_alpha || l_num || '- ,''';
         l_freetext varchar2(90) := l_root_alpha || l_num || ' -"\/?@&$!#+=;:,''().';
         */
         l_result boolean := true ;
         l_translated varchar2(1024);
         l_num varchar2(10)        := '0123456789' ;

         l_invalid_in_alphanum varchar2(100):= '~`!@#$%^&*()_+=|\[]{}<>":;?/.';
         l_invalid_in_alpha    varchar2(100):= '~`!@#$%^&*()_+=|\[]{}<>":;?/.0123456789';
    begin
        hr_utility.trace('Validating value : '||p_input_value||' as '||p_mode);
        if p_mode = 'NUMERIC' then
            l_translated := translate (p_input_value
                                     , '~' || l_num
                                     , '~');
            if l_translated is not null then
                 l_result := false;
            end if ;
        elsif p_mode = 'ALPHA' then
            l_translated := translate (p_input_value
                                     , l_invalid_in_alpha
                                     , lpad('~',length(l_invalid_in_alpha),'~'));
            if instr(l_translated,'~') >0 then
                 l_result := false;
            end if ;
       elsif p_mode = 'ALPHANUM' then
            l_translated := translate (p_input_value
                                     , l_invalid_in_alphanum
                                     , lpad('~',length(l_invalid_in_alphanum),'~'));
            if instr(l_translated,'~') >0 then
                 l_result := false;
            end if ;
       elsif p_mode = 'FREETEXT' then
           null;
           -- we will not validate for freetext
       end if;
        /*
        if p_mode = 'NUMERIC' then
            l_translated := translate (p_input_value
                                     , l_invalid_char || l_num
                                     , l_invalid_char);
            if l_translated is not null then
                 l_result := false;
            end if ;
        elsif p_mode = 'ALPHA' then
            l_translated := translate (p_input_value
                                     , l_invalid_char || l_alpha
                                     , l_invalid_char);
            if l_translated is not null then
                 l_result := false;
            end if ;
       elsif p_mode = 'ALPHANUM' then
            l_translated := translate (p_input_value
                                     , l_invalid_char || l_alphanum
                                     , l_invalid_char);
            if l_translated is not null then
                 l_result := false;
            end if ;
       elsif p_mode = 'FREETEXT' then
           l_translated := translate (p_input_value
                                     , l_invalid_char || l_freetext
                                     , l_invalid_char);
            if l_translated is not null then
                 l_result := false;
            end if ;
       end if;
       */

       hr_utility.trace('l_translated='||l_translated);
       return l_result ;
    end validate_charcter_set;

----------------------------------------------------------------------------
-- validate_create_per_payment
----------------------------------------------------------------------------
    procedure validate_create_per_payment   (P_EFFECTIVE_START_DATE        IN  DATE
                                            ,P_EFFECTIVE_END_DATE          IN  DATE
                                            ,P_ASSIGNMENT_ID               IN  NUMBER
                                            ,P_PERSONAL_PAYMENT_METHOD_ID  IN  NUMBER
                                            ,P_PPM_INFORMATION1            IN  VARCHAR2 DEFAULT NULL)
    is
    l_count NUMBER;
    begin
        l_count := 0;
        IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
            if P_PPM_INFORMATION1 in ('Y','0','7') then
                    select count(*)
                    into   l_count
                    from   pay_personal_payment_methods_f
                    where  assignment_id = P_ASSIGNMENT_ID
                    and    personal_payment_method_id <>P_PERSONAL_PAYMENT_METHOD_ID
                    and    effective_start_date <= P_EFFECTIVE_END_DATE and effective_end_date >= P_EFFECTIVE_START_DATE
                    and    PPM_INFORMATION_CATEGORY in ('ZA_ACB','ZA_CHEQUE','ZA_CREDIT TRANSFER','ZA_MANUAL PAYMENT')
                    and    nvl(PPM_INFORMATION1,'N') in ('Y','0','7');

                    if l_count > 0 then
                           fnd_message.set_name('PAY','PY_ZA_INV_PERS_PAYM_DDF');
                           fnd_message.raise_error;
                    end if;
            end if;
        end if;

    end validate_create_per_payment;

----------------------------------------------------------------------------
-- validate_update_per_payment
----------------------------------------------------------------------------
    procedure validate_update_per_payment  (P_EFFECTIVE_DATE              IN  DATE
                                           ,P_EFFECTIVE_START_DATE        IN  DATE
                                           ,P_EFFECTIVE_END_DATE          IN  DATE
                                           ,P_PERSONAL_PAYMENT_METHOD_ID  IN  NUMBER
                                           ,P_PPM_INFORMATION1            IN  VARCHAR2)
    is
    l_count NUMBER;
    l_assignment_id per_all_assignments_f.assignment_id%type;
    begin
        l_count := 0;
        IF hr_utility.chk_product_install('Oracle Human Resources', 'ZA') THEN
            select  assignment_id
            into    l_assignment_id
            from    pay_personal_payment_methods_f
            where   personal_payment_method_id = P_PERSONAL_PAYMENT_METHOD_ID
             and    P_EFFECTIVE_DATE between effective_start_date and effective_end_date;

            if P_PPM_INFORMATION1 in ('Y','0','7') then
                    select count(*)
                    into   l_count
                    from   pay_personal_payment_methods_f
                    where  assignment_id = l_assignment_id
                    and    personal_payment_method_id <>P_PERSONAL_PAYMENT_METHOD_ID
                    and    PPM_INFORMATION_CATEGORY in ('ZA_ACB','ZA_CHEQUE','ZA_CREDIT TRANSFER','ZA_MANUAL PAYMENT')
                    and    effective_start_date <= P_EFFECTIVE_END_DATE and effective_end_date >= P_EFFECTIVE_START_DATE
                    and    PPM_INFORMATION1 in ('Y','0','7');

                    if l_count > 0 then
                           fnd_message.set_name('PAY','PY_ZA_INV_PERS_PAYM_DDF');
                           fnd_message.raise_error;
                    end if;
            end if;
        end if;
     end validate_update_per_payment;


END per_za_user_hook_pkg;

/
