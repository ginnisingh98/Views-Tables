--------------------------------------------------------
--  DDL for Package Body PAY_FR_DADS_EMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_DADS_EMP_PKG" as
/* $Header: pyfrdems.pkb 120.1 2006/03/16 10:29 aparkes noship $ */
g_package  varchar2(50);  -- Global package name
g_param_issuing_estab_id per_all_assignments_f.establishment_id%type;
g_param_company_id hr_organization_information.organization_id%type;
g_param_estab_id hr_organization_information.organization_id%type;
g_effective_date  Date;
g_assign_action_id pay_payroll_actions.payroll_action_id%type;
g_param_business_group_id  hr_organization_information.organization_id%type;
g_param_reference VARCHAR2(100);
g_param_start_date Date;

----------------------------------
--  --
--Private procedures
----------------------------------
--
Function fr_rolling_balance_pro (p_assignment_id in number,
                                 p_balance_name in varchar2,
                                 p_balance_start_date in date,
                                 p_balance_end_date in date) return number;

PROCEDURE archive_data(p_rubric_name       VARCHAR2,
                           p_message_type      VARCHAR2,
                           p_id            NUMBER,
                           p_lookup_type       VARCHAR2,
                           p_file_value        VARCHAR2,
                           p_message_text      VARCHAR2,
                           p_id2               VARCHAR2,
                           p_rubric_type       VARCHAR2);
----------------
--Public Procedures
----------------

procedure execS30_G01_00(p_assact_id IN Number
                        ,p_issuing_estab_id  IN Number
                        ,p_org_id IN Number
                        ,p_estab_id IN Number
                        ,p_business_Group_id IN Number
                        ,p_reference IN Varchar2
                        ,p_start_date IN Date
                        ,p_effective_date IN Date)
 is
--
Cursor cur_emp_data(p_org_id varchar2) is
Select  Distinct NATIONAL_IDENTIFIER  SS_Number --S30.G01.00.001 	SS Number --expections report also needs it
      , DECODE(SEX, 'F', DECODE(NVL(NVL(PER_INFORMATION1, PREVIOUS_LAST_NAME), '-1'), '-1', LAST_NAME,NVL(PER_INFORMATION1, PREVIOUS_LAST_NAME))
                  , 'M', NVL(PREVIOUS_LAST_NAME,LAST_NAME), LAST_NAME) Birth_Name--S30.G01.00.002  	Birth Name
      , ppf.first_name first_name
      , ppf.MIDDLE_NAMES	middle_names --Christian_Names--S30.G01.00.003 Christian Names
      , ppf.KNOWN_AS preferred_name   --First Name generally used--S30.G01.00.005
      , DECODE(SEX, 'F', DECODE(NVL(PER_INFORMATION1, PREVIOUS_LAST_NAME), LAST_NAME, NULL,LAST_NAME)
                  , 'M', DECODE( PREVIOUS_LAST_NAME, LAST_NAME, NULL, LAST_NAME)) Name--Name S30.G01.00.004/Nickname S30.G01.00.006
      , ppf.title Title, ppf.sex sex, ppf.Marital_status  marital_status--Title S30.G01.00.007
      , ppf.full_name full_name --used in exception report
      , pa.address_line2 Complement      --Address (complement) S30.G01.00.008.001
      , pa.address_line1 Street          --Nature and name of the street S30.G01.00.008.006
      , pa.region_2 INSEE_code --	INSEE Code of the town S30.G01.00.008.007
      , pa.region_3 Small_Town --	Name of the town --S30.G01.00.008.009
      ,	pa.postal_code Postal_code --Zip Code S30.G01.00.008.010
      , upper(pa.town_or_city) Town	--Town S30.G01.00.008.012
      , null Country_Code  --	Country Code -- null for the timebeing
      , ft_tl.territory_short_name Country_name --Country Name S30.G01.00.008.014
      ,	Null tot_address --Total Address Code --to be left void for the time being
      , to_char(ppf.date_of_birth,'DDMMYYYY') Date_of_birth	--Date of Birth S30.G01.00.009
      , ppf.Town_of_birth Town_of_birth	--Town of Birth S30.G01.00.010
      , ppf.region_of_birth  region_of_birth --Birth_code  --Region_of_birth  --Birth Department Code S30.G01.00.011 region_of_birth
      , ft1_tl.territory_short_name country_of_birth_name --Town of Birth S30.G01.00.010 need this for validation and expections report
      , ppf.country_of_birth country_of_birth --Town of Birth S30.G01.00.010 need this for validation and expections report
      , ppf.nationality Nationality   --	Nationality S30.G01.00.013.013
      , ppf.person_id person_id-- used to send as a parameter to s41 structure.
      , paf.location_id location_id--used to send as a parameter in s41 Structure
      , paf.assignment_id  assignment_id -- assignment_id , p_id
      , ppf.employee_number employee_number -- this will be the id2 column
  From  per_all_people_f ppf
       , per_all_assignments_f paf
       , pay_assignment_actions paa
       , per_addresses pa
       , fnd_territories ft
       , fnd_territories_tl ft_tl
       , fnd_territories ft1
       , fnd_territories_tl ft1_tl
       , hr_organization_information org_est
       , per_periods_of_service pps
 Where paa.assignment_action_id = g_assign_action_id
   And paf.assignment_id = paa.assignment_id
   And paf.establishment_id = org_est.organization_id
   And org_est.org_information1 = p_org_id
   And paf.person_id = ppf.person_id
   And pps.person_id = paf.person_id
   And pa.person_id(+) = ppf.person_id
   And pa.style(+) = 'FR'
   And ((g_effective_date between paf.effective_start_date and paf.effective_end_date)
        Or (pps.actual_termination_date
                 between paf.effective_start_date and paf.effective_end_date))
   And nvl(ft.territory_code, 'FR') = nvl(pa.country, 'FR')
   And ppf.country_of_birth = ft1.territory_code(+)

   And ft_tl.territory_code (+) = ft.territory_code
   And ft_tl.language (+) = userenv('LANG')

   And ft1_tl.territory_code (+) = ft1.territory_code
   And ft1_tl.language (+) = userenv('LANG');
--
 l_emp_rec  cur_emp_data%rowtype;
 l_name    VARCHAR2(250);
 l_person_id per_all_people_f.person_id%type;
 l_address_id per_addresses.address_id%type;
 l_location_id per_all_assignments_f.location_id%type;

 p_id Number;
 l_id2 per_all_people_f.employee_number%type;
 l_pactid pay_payroll_actions.payroll_action_id%type;

 -- Local Variable Declaration for Exceptions
 l_value                  fnd_new_messages.message_text%type;
 l_error_type             hr_lookups.meaning%type;
 l_error                  hr_lookups.meaning%type;
 l_warning                hr_lookups.meaning%type;
 l_ss_number              per_all_people_f.NATIONAL_IDENTIFIER%type;
 l_mandatory              varchar2(1);
 l_conditional            varchar2(1);
 l_optional               varchar2(1);
 l_nationality            fnd_lookup_values.meaning%type;
 --checks whether any employee is there in a establishment
 l_emp_found              boolean;

Begin
g_package  := '  pay_fr_dads_emp_pkg.';  -- Global package name
-- Initializing the local variables
 l_mandatory     := 'M';
 l_conditional   := 'C';
 l_optional      := 'O';
--
-- Getting the error messages
 -- hr_utility.trace_on(null, 'SA_DADS');
  hr_utility.set_location('S30 Entering:'||p_org_id,1);

  l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
  l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');

  p_id := p_org_id;
--Initialize the globals
--
  g_param_issuing_estab_id := p_issuing_estab_id;
  g_param_company_id := p_org_id;
  g_param_estab_id := p_estab_id;
  g_param_business_group_id := p_business_Group_id;
  g_param_reference := p_reference;
  g_param_start_date := p_start_date;
  g_effective_date := p_effective_date;

  hr_utility.set_location('S30 g_param_issuing_estab_id:'||g_param_issuing_estab_id,1);
  hr_utility.set_location('S30 g_param_company_id:'||g_param_company_id,1);

  g_assign_action_id := p_assact_id;
  l_emp_found := FALSE;

  For l_emp_rec In cur_emp_data(p_org_id)
   Loop
    Exit when cur_emp_data%notfound;
    l_id2 := l_emp_rec.employee_number;
    l_emp_found := TRUE;

    l_ss_number := l_emp_rec.ss_number;
    IF l_emp_rec.ss_number is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.001'), null);
    ELSIF ( substr(l_emp_rec.ss_number, 1, 1) = '7' or substr(l_emp_rec.ss_number, 1, 1) = '8') THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message
      ('PAY_75181_SS_TEMP','VALUE1:'||l_emp_rec.full_name, 'VALUE2:'|| l_emp_rec.person_id
      , null);
    /* This has to be finalised by Heather */
   ELSIF instr (upper(l_emp_rec.ss_number), 'X') > 0 THEN
      l_ss_number := replace(l_emp_rec.ss_number, 'X', '9');
      l_error_type := l_warning;
      l_value := pay_fr_general.get_payroll_message('PAY_75189_SS_INCMP',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'|| l_emp_rec.ss_number, null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;

   -- SS number
    archive_data(p_rubric_name => 'S30.G01.00.001'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => l_ss_number
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   l_person_id := l_emp_rec.person_id;
   hr_utility.set_location('S30 Person_id:'||l_person_id,112);
   l_location_id := l_emp_rec.location_id;

   -- Birth name
   IF l_emp_rec.birth_name is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.002'), null, null);
   ELSE
      l_error_type := null;
      l_value := null;
   hr_utility.set_location('S30 l_value:'||l_value,113);
   END IF;
   archive_data( p_rubric_name => 'S30.G01.00.002'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => l_emp_rec.birth_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   l_name := l_emp_rec.first_name||' '||l_emp_rec.middle_names;

   -- Given Christian names
    IF ((l_emp_rec.first_name is null)
       and (l_emp_rec.middle_names is null)) THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA','VALUE1:'
      ||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.003'), null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S30.G01.00.003'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => l_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Name
     archive_data( p_rubric_name => 'S30.G01.00.004'
                  ,p_message_type => Null
                  ,p_id => p_id
                  ,p_lookup_type => Null
                  ,p_file_value => l_emp_rec.name
                  ,p_message_text => Null
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);


   If ((l_emp_rec.preferred_name <> l_emp_rec.first_name)
       And (l_emp_rec.preferred_name Is Not Null)) Then
      If (l_emp_rec.preferred_name = l_emp_rec.middle_names) Then
          -- First name generally used
          archive_data(
                p_rubric_name => 'S30.G01.00.005'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => l_emp_rec.preferred_name
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
      Else
          -- Nickname
          archive_data(
                p_rubric_name => 'S30.G01.00.006'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => l_emp_rec.preferred_name
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
      End If;
   End If;

   If ((l_emp_rec.Title Is not Null)
       And (l_emp_rec.Title  = 'MISS' OR l_emp_rec.Title  = 'MR.' OR l_emp_rec.Title  = 'MRS.')) Then
      -- Title
      archive_data(
                p_rubric_name => 'S30.G01.00.007'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => 'TITLE'
                ,p_file_value => l_emp_rec.Title
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
/* First checks whether the title is not null and then the other checks are made.*/
 Elsif l_emp_rec.Title Is not Null THEN
      If (l_emp_rec.sex = 'M') Then
        -- Title
        archive_data(
                p_rubric_name => 'S30.G01.00.007'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => 'TITLE'
                ,p_file_value => 'MR.'
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

      Elsif (l_emp_rec.marital_status = 'S') Then
        -- Title
        archive_data(
                p_rubric_name => 'S30.G01.00.007'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => 'TITLE'
                ,p_file_value => 'MISS'
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
      Else
        -- Title
        archive_data(
                p_rubric_name => 'S30.G01.00.007'
                ,p_message_type => Null
                ,p_id => p_id
                ,p_lookup_type => 'TITLE'
                ,p_file_value => 'MRS.'
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
      End if;
   /* If title is null, then error message is archived */
   ELSIF l_emp_rec.title is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S30.G01.00.007'), null, null);
        archive_data( p_rubric_name => 'S30.G01.00.007'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => null
                ,p_file_value => null
                ,p_message_text => l_value
          		,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
   End if;

   -- Employee Address Complement
      archive_data(p_rubric_name => 'S30.G01.00.008.001'
                  ,p_message_type => Null
                  ,p_id => p_id
                  ,p_lookup_type => NULL
                  ,p_file_value => l_emp_rec.Complement
                  ,p_message_text => Null
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_optional);

   -- Employee Address street
   IF l_emp_rec.street is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.006'), null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;
   archive_data(p_rubric_name => 'S30.G01.00.008.006'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => NULL
                ,p_file_value => l_emp_rec.Street
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

   archive_data(p_rubric_name => 'S30.G01.00.008.007'
                  ,p_message_type => Null
                  ,p_id => p_id
                  ,p_lookup_type => NULL
                  ,p_file_value => l_emp_rec.INSEE_code
                  ,p_message_text => Null
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);

   -- Town
   IF upper(l_emp_rec.small_town ) = upper(l_emp_rec.town) THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
      null, null, null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;


   archive_data(p_rubric_name => 'S30.G01.00.008.009'
                 ,p_message_type => l_error_type
                 ,p_id => p_id
                 ,p_lookup_type => NULL
                 ,p_file_value => l_emp_rec.small_town
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_conditional);

   -- Postal Code
   IF l_emp_rec.postal_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.010'), null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;
   archive_data(p_rubric_name => 'S30.G01.00.008.010'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => NULL
                ,p_file_value => l_emp_rec.postal_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- City
   IF l_emp_rec.town is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.012'), null);
   ELSIF l_emp_rec.town <> upper(l_emp_rec.town) THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
      null, null, null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;
   archive_data(
                p_rubric_name => 'S30.G01.00.008.012'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => NULL
                ,p_file_value => l_emp_rec.town
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Country Code
   IF l_emp_rec.country_code = 'FR'
      AND l_emp_rec.country_code is not null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
      'VALUE1: '||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.013'), null, null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;

   archive_data(p_rubric_name => 'S30.G01.00.008.013'
                 ,p_message_type => l_error_type
                 ,p_id => p_id
                 ,p_lookup_type => NULL
                 ,p_file_value => l_emp_rec.country_code
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_conditional);

   -- Country Name
   IF l_emp_rec.country_name is not null and l_emp_rec.country_code = 'FR' THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
      'VALUE1: '||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.014'), null, null);
   ELSIF l_emp_rec.country_name is null AND l_emp_rec.country_code is not null
     AND l_emp_rec.country_code <> 'FR' THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.008.014'), null, null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;

   --IF l_emp_rec.country_name is not null and l_emp_rec.country_code <> 'FR' THEN
     archive_data(p_rubric_name => 'S30.G01.00.008.014'
                 ,p_message_type => l_error_type
                 ,p_id => p_id
                 ,p_lookup_type => NULL
                 ,p_file_value => l_emp_rec.country_name
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_conditional);
--   End If;

  archive_data(p_rubric_name => 'S30.G01.00.008.015'
                 ,p_message_type => Null
                 ,p_id => p_id
                 ,p_lookup_type => NULL
                 ,p_file_value => l_emp_rec.tot_address
                 ,p_message_text => Null
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_conditional);

   -- Date of birth
   IF l_emp_rec.date_of_birth is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.009'), null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;

   archive_data( p_rubric_name => 'S30.G01.00.009'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => NULL
                ,p_file_value => l_emp_rec.date_of_birth
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Town of birth
   IF (l_emp_rec.town_of_birth is null
      AND l_emp_rec.country_of_birth = 'FR') THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.010'), null);
      -- #3553740 Deleted the archiving procedure call.  Since, it is archived again after this if loop.
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;

   archive_data(p_rubric_name => 'S30.G01.00.010'
                  ,p_message_type => l_error_type
                  ,p_id => p_id
                  ,p_lookup_type => NULL
                  ,p_file_value => l_emp_rec.town_of_birth
                  ,p_message_text => l_value
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);

  If (l_emp_rec.country_of_birth <> 'FR' And l_emp_rec.country_of_birth Is not Null) Then
      -- Birth department code
	   /*IF l_emp_rec.region_of_birth is null THEN
	      l_error_type := l_error;
	      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
	      'VALUE1:'||hr_general.decode_lookup
	      ('FR_DADS_RUBRICS','S30.G01.00.011'), null, null);
	   ELSE
	      l_error_type := Null;
	      l_value := Null;
	   END IF;*/
      l_error_type := Null;
	  l_value := Null;

      archive_data(p_rubric_name => 'S30.G01.00.011'
                  ,p_message_type => l_error_type
                  ,p_id => p_id
                  ,p_lookup_type => 'FR_DADS_BIRTH_DEPT_CODE'
                  ,p_file_value => 99
                  ,p_message_text => l_value
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);

   Elsif (l_emp_rec.country_of_birth = 'FR') Then
      -- Birth department code
      IF (l_emp_rec.region_of_birth is null) THEN
         l_error_type := l_error;
         l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
           'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
	   ('FR_DADS_RUBRICS','S30.G01.00.011.M'), null);
      ELSE
	 l_error_type := Null;
	 l_value := Null;
      END IF;
      archive_data(
                p_rubric_name => 'S30.G01.00.011'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type =>'FR_DEPARTMENT'
                ,p_file_value => l_emp_rec.region_of_birth
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
/* Adding one more validation for checking whether country of birth is null or not */
   Elsif (l_emp_rec.country_of_birth is null) Then
           -- Birth department code
	   IF (l_emp_rec.region_of_birth is null) THEN
	      l_error_type := l_error;
	      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
	      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
	      ('FR_DADS_RUBRICS','S30.G01.00.011.M'), null);
	   ELSE
	      l_error_type := Null;
	      l_value := Null;
	   END IF;
           archive_data(p_rubric_name => 'S30.G01.00.011'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => Null
                ,p_file_value => Null
                ,p_message_text => l_value
        		,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
   End If;
   -- Birth country
   IF l_emp_rec.country_of_birth is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.012'), null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;
   archive_data(p_rubric_name => 'S30.G01.00.012'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type => NULL
                ,p_file_value => l_emp_rec.country_of_birth_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Nationality
   IF l_emp_rec.nationality is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_rec.full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S30.G01.00.013'), null);
   ELSE
      l_error_type := Null;
      l_value := Null;
   END IF;
   l_nationality := hr_general.decode_lookup('NATIONALITY', l_emp_rec.nationality);
   archive_data(p_rubric_name => 'S30.G01.00.013'
                ,p_message_type => l_error_type
                ,p_id => p_id
                ,p_lookup_type =>'NATIONALITY'
                ,p_file_value => l_nationality
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   hr_utility.set_location('S30 person:'||l_person_id||':'||l_emp_rec.assignment_id,9999);
   execS41_G01_00(p_person_id => l_person_id
                 ,p_assignment_id => l_emp_rec.assignment_id
                 ,p_org_id => p_org_id);

 End loop;

 If (l_emp_found = FALSE) Then
   FND_FILE.PUT_LINE(FND_FILE.LOG, pay_fr_general.get_payroll_message('PAY_75195_DADS',null));
 End If;

Exception
When others then
  hr_utility.set_location('S30 sqlerrm:'||sqlerrm,9999);
  Raise;
End EXECS30_G01_00;
--

----------------------------------
-- S41 Structure --
----------------------------------
Procedure execS41_G01_00(p_person_id IN NUMBER
                        ,p_assignment_id IN Number
                        ,p_org_id IN varchar2) is


--Cursors for Start and end reason codes
--These cursors will take care of change in Employee Category
--and Professional Status Code History


Cursor csr_25 Is
   select scl.segment2  emp_cat
         , greatest(to_date('01-' ||to_number(to_char(asg.effective_start_date, 'MM')) ||'-'
                                  ||to_number(to_char(asg.effective_start_date, 'YYYY'))
                                  || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
                   ,g_param_start_date)  start_date
         ,least(asg.effective_end_date, g_effective_date) end_date
         ,paa.assignment_action_id
         ,org_est.org_information1
   from  per_all_assignments_f  asg
         ,pay_assignment_actions paa
         ,hr_soft_coding_keyflex scl
         ,hr_organization_information org_est
   where paa.assignment_action_id = g_assign_action_id
     and asg.effective_end_date  >= g_param_start_date
     and asg.effective_start_date <= g_effective_date
     and asg.assignment_id = paa.assignment_id
     and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
     and asg.establishment_id = org_est.organization_id
     and org_est.org_information1  = p_org_id
     and asg.person_id = p_person_id
     and org_est.ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO'
     Order By Start_Date;

Cursor csr_23 (c_end_date date, c_param_start_date date) Is
  select scl.segment16 prof_code
         , greatest(to_date('01-' ||to_number(to_char(asg.effective_start_date, 'MM')) ||'-'
                                  ||to_number(to_char(asg.effective_start_date, 'YYYY'))
                                  || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
                   ,c_param_start_date)  start_date
         ,asg.effective_start_date effective_start_date
         ,least(asg.effective_end_date, c_end_date) end_date
         ,paa.assignment_action_id
         ,org_est.org_information1
   from  per_all_assignments_f  asg
         ,pay_assignment_actions paa
         ,hr_soft_coding_keyflex scl
         ,hr_organization_information org_est
   where  paa.assignment_action_id = g_assign_action_id
     and asg.effective_start_date  >= c_param_start_date
     and asg.effective_start_date <= c_end_date
     and asg.assignment_id = paa.assignment_id
     and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
     and asg.establishment_id = org_est.organization_id
     and org_est.org_information1  = p_org_id
     and asg.person_id = p_person_id
     and org_est.ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO'
     Order By effective_start_date, Start_Date;


  l_csr_25_rec csr_25%ROWTYPE;

 --Complementory Pension Provider change history
  Cursor Csr_35 Is
   select  distinct pee.entry_information1 pen_cat
         , greatest(to_date('01-' ||to_number(to_char(pee.effective_start_date, 'MM')) ||'-'
                                  ||to_number(to_char(pee.effective_start_date, 'YYYY'))
                                  || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
                   ,g_param_start_date)  start_date
          ,greatest(pee.effective_start_date, g_param_start_date) asg_start_date
          ,least(pee.effective_end_Date, g_effective_date) end_date
 from pay_element_entries_f pee
      ,per_all_assignments_f asg
      ,hr_organization_information org_est
      ,pay_assignment_actions paa
 where paa.assignment_action_id = g_assign_action_id
   and pee.assignment_id = asg.assignment_id
   and asg.assignment_id = paa.assignment_id
   and asg.establishment_id = org_est.organization_id
   and org_est.org_information1  = p_org_id
   and asg.person_id = p_person_id
   and pee.entry_information_category = 'FR_PENSION INFORMATION'
   and pee.effective_start_date <= g_effective_date
   and pee.effective_start_date >= g_param_start_date
   order by start_date;

 l_csr_35_rec csr_35%ROWTYPE;
 --End Complementory Pension Provider change history

 -- Change of Activity or Work Contract
 --Process type changes
 --previously the cursor has a join with assignment table.
 --Now, the cursor has a join with payroll actions table
Cursor csr_process (c_start_date date) IS
select distinct pac.context_value process_type
      ,nvl(paa_date.start_date, (ppa.date_earned - to_number(to_char(ppa.date_earned, 'DD')) + 1)) calc_start_date
      ,nvl(paa_date.end_date, ppa.date_earned) end_date
  from pay_action_contexts pac
      ,ff_contexts fc
      ,pay_assignment_actions paa
      ,pay_assignment_actions paa_date
      ,pay_payroll_actions ppa
 where pac.assignment_id = paa.assignment_id
   and pac.assignment_action_id = paa.assignment_action_id
   and fc.context_id = pac.context_id
   and fc.context_name = 'SOURCE_TEXT'
   and paa.assignment_id = p_assignment_id
   and ppa.payroll_action_id = paa.payroll_action_id
   and paa_date.assignment_id = paa.assignment_id
   and paa.source_action_id = paa_date.assignment_action_id
   and ppa.date_earned between c_start_date and g_effective_date
   order by calc_start_date;

 --Contract Type Changes
  Cursor csr_contract (c_end_date date, c_param_start_date date) Is
  select distinct pcf.ctr_information2 contract
         , pcf.status status
	 , pcf.contract_id contract_id
         , asg.effective_start_date start_date
         , least(pcf.effective_end_date, c_end_date) end_date
    from pay_assignment_actions paa
        ,per_all_assignments_f  asg
        ,per_contracts_f pcf
        ,hr_organization_information org_est
   where paa.assignment_action_id = g_assign_action_id
    and org_est.org_information1  = p_org_id
     and asg.person_id = p_person_id
     and asg.assignment_id = paa.assignment_id
     and asg.establishment_id = org_est.organization_id
     and pcf.contract_id = asg.contract_id
     and asg.effective_start_date <= c_end_date
     and asg.effective_start_date >= c_param_start_date
     and asg.effective_start_date between pcf.effective_start_date
                                      and pcf.effective_end_date
     Order by start_date;


 --cursor for assignment category
 Cursor csr_asg_cat (c_end_date date, c_param_start_date date) IS
    Select asg.employment_category category
         , greatest(to_date('01-' ||to_number(to_char(asg.effective_start_date, 'MM')) ||'-'
                                  ||to_number(to_char(asg.effective_start_date, 'YYYY'))
                                  || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
                   ,c_param_start_date)  start_date
          ,asg.effective_start_date asg_start_date
          ,least(asg.effective_end_date,c_end_date) asg_end_date
    From pay_assignment_actions paa
        ,per_all_assignments_f  asg
        ,hr_organization_information org_est
   where paa.assignment_action_id = g_assign_action_id
     and asg.effective_start_date <= c_end_date
     and asg.effective_start_date >= c_param_start_date
     and asg.assignment_id = paa.assignment_id
     and asg.establishment_id = org_est.organization_id
     and org_est.org_information1  = p_org_id
     and asg.person_id = p_person_id
     And asg.assignment_id = paa.assignment_id
   Order by asg_start_date;


--Cursors for Start and end reason codes

--This cursor will take care of establishment change of the person.
--Cursor 19 Establishment Changes
   -- Mutation in another establishment in the company  Get the prior establishmentid
   Cursor csr_19(p_person_id number) IS
  (select asg.establishment_id, org_est.org_information1 company_id
         ,asg.effective_start_date start_date,  'FIRST' type
    from  pay_assignment_actions paa
         ,per_all_assignments_f  asg
         ,hr_organization_information org_est
   where  paa.assignment_action_id = g_assign_action_id
     and  asg.assignment_id = paa.assignment_id
     and  asg.person_id = p_person_id
     and  asg.effective_end_date   >= g_param_start_date-1
     and  asg.effective_start_date <= g_param_start_date-1
     and  asg.establishment_id = org_est.ORGANIZATION_ID
     and  org_est.ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO')
   union all
     -- Get all the changes in company id
  (select asg.establishment_id, org_est.org_information1 company_id
        ,asg.effective_start_date start_date, 'HIST' type
    from pay_assignment_actions paa
        ,per_all_assignments_f  asg
        ,hr_organization_information org_est
   where  paa.assignment_action_id = g_assign_action_id
     and  asg.assignment_id = paa.assignment_id
     and  asg.person_id = p_person_id
     and  asg.effective_end_date   >= g_param_start_date
     and  asg.effective_start_date <= g_effective_date
     and  asg.establishment_id = org_est.ORGANIZATION_ID
     and  org_est.ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO')
   ORDER by type, start_date;

  l_csr_19_rec csr_19%ROWTYPE;

--Cursors for other data
--NIC of the assignment Establishment...
Cursor csr_NIC(p_person_id Number, p_org_id Varchar2) IS
Select asg.effective_start_date start_date, asg.establishment_id
     , substr(org_est.org_information2,length(org_est.org_information2)-4, 5)
  From pay_assignment_actions paa
        ,per_all_assignments_f  asg
       ,hr_organization_information org_est
 Where paa.assignment_action_id = g_assign_action_id
   and asg.assignment_id = paa.assignment_id
   and asg.person_id = p_person_id
   And asg.effective_start_date >= g_param_start_date
   And asg.effective_start_date <= g_effective_date
   And asg.establishment_id = org_est.ORGANIZATION_ID
   And org_est.org_information1 = p_org_id
   And org_est.ORG_INFORMATION_CONTEXT = 'FR_ESTAB_INFO'
  Order by start_date desc;

--Or can use the following cursor which fetches work accident along with NIC
/*Cursor csr41_estab_data(p_person_id Number, p_org_id Varchar2) IS
   Select Distinct org_est.org_information3 hrorg
          ,org_est.org_information4 risk_code_month_hours
          ,org_est.org_information5 order_number
          ,org_est.org_information6 section_code
          ,org_est.org_information7 office_code
          ,org_est.ORG_INFORMATION_CONTEXT  information_context
          ,substr(org_est.org_information2,length(org_est.org_information2)-4, 5) siret_number
      -- all Work accident info details
          ,asg.establishment_id estab_id--
          ,asg.location_id asg_location
          ,hla.location_id est_location
/* Getting the issuing establishment Name
          ,hou_issue_estab_tl.name           issue_estab_name
	  ,hloc_asg_estab_tl.location_code   location_name
	  ,asg_estab_tl.name                 asg_estab_name
  From  per_all_assignments_f  asg
       ,pay_assignment_actions paa
       ,hr_organization_information org_est
       ,hr_all_organization_units hou
       ,hr_locations_all hla
       ,hr_locations_all_tl hloc_asg_estab_tl
-- Getting the Establishment Name
       ,hr_all_organization_units_tl     hou_issue_estab_tl
-- Getting the Assignment Establishment's Name
       ,hr_all_organization_units        asg_estab_tl
 Where paa.assignment_action_id = g_assign_action_id
   and asg.person_id = p_person_id
   And asg.effective_end_date between g_param_start_date and  g_effective_date
   And asg.assignment_id = paa.assignment_id
   And asg.establishment_id = org_est.ORGANIZATION_ID
   And hla.location_id(+) = hou.location_id
   And asg.establishment_id = org_est.ORGANIZATION_ID
   And hou.organization_id(+) = org_est.ORGANIZATION_ID
   And org_est.ORG_INFORMATION_CONTEXT In ('FR_ESTAB_WORK_ACCIDENT', 'FR_ESTAB_INFO')
   --
   and hloc_asg_estab_tl.location_id(+) = asg.location_id
   and hloc_asg_estab_tl.language(+) = userenv('LANG')
   --
   AND hou_issue_estab_tl.organization_id = org_est.organization_id
   AND hou_issue_estab_tl.language = userenv('LANG')
   --
   AND asg.establishment_id = asg_estab_tl.organization_id (+);
   */

 Cursor csr41_estab_data(p_effective_date Date) IS
   Select distinct paa.assignment_action_id
          ,org_est.org_information3 hrorg
          ,org_est.org_information4 risk_code_month_hours
          ,org_est.org_information5 order_number
          ,org_est.org_information6 section_code
          ,org_est.org_information7 office_code
          ,org_est.ORG_INFORMATION_CONTEXT  information_context
          ,substr(org_est.org_information2,length(org_est.org_information2)-4, 5) siret_number
          ,asg.establishment_id estab_id
          ,asg.location_id asg_location
          ,hla.location_id est_location
          ,hou_issue_estab_tl.name issue_estab_name
	      ,hloc_asg_estab_tl.location_code   location_name
       	  ,asg_estab_tl.name asg_estab_name
  From  pay_assignment_actions paa
       ,per_all_assignments_f  asg
       ,hr_organization_information org_est
       ,hr_locations_all hla
       ,hr_locations_all_tl hloc_asg_estab_tl
       ,hr_all_organization_units_tl hou_issue_estab_tl
       ,hr_all_organization_units asg_estab_tl
       ,hr_all_organization_units hou
 Where paa.assignment_action_id = g_assign_action_id
   And paa.assignment_id = asg.assignment_id
   And asg.person_id = p_person_id
   And asg.establishment_id = org_est.ORGANIZATION_ID
   And hla.location_id(+) = hou.location_id
   And asg.establishment_id = org_est.ORGANIZATION_ID
   And hou.organization_id(+) = org_est.ORGANIZATION_ID
   And org_est.ORG_INFORMATION_CONTEXT In ('FR_ESTAB_WORK_ACCIDENT', 'FR_ESTAB_INFO')
   and hloc_asg_estab_tl.location_id(+) = asg.location_id
   and hloc_asg_estab_tl.language(+) = userenv('LANG')
   AND hou_issue_estab_tl.organization_id = org_est.organization_id
   AND hou_issue_estab_tl.language(+) = userenv('LANG')
   AND asg.establishment_id = asg_estab_tl.organization_id (+)
   and asg.effective_start_date <= p_effective_date;

 l_csr41_estab_data csr41_estab_data%rowtype;
--

--Cursor to fetch all date tracked data of the S41 structure
Cursor fetch_date_trk_41(p_effective_date DATE) Is
Select pj.Name job_name --job Flex field as given in assedic report
     , pj.job_definition_id job_definition_id
     , pj.job_id job_id
     , pj.job_information1 pcs_code -- Open issue, Now fetching as mentioned in assedic report, issue is closed and all the characters are retreived
     , decode(pc.type,'APPRENTICESHIP','05','YOUNG_PERSON','06',
                    decode(pc.ctr_information2
                     ,'FIXED_TERM','02','PERMANENT','01',Null)) contract_type --Work Contract Code
     , pc.type contract_type_1 -- used to validate seasonal worker for activity type code
     , sck.SEGMENT16  prof_status_code --Professional Status Code
     , sck.SEGMENT14  border_worker -- used to determine border worker code
     , sck.SEGMENT12  detache --used to determine border worker code
     , pc.type act_type--Used for activity type code (Seasonal Worker has not been defined in seed yet)
     , paf.employee_number person_number -- employee number
     , asg.normal_hours norm_asg_hours-- Used for Percentage of part_time
     , asg.frequency asg_frequency-- Used for Percentage of part_time
     -- added for time analysis
     , pc.ctr_information13 ctr_frequency -- Used for Percentage of part_time -- need to check whether its monthly or not
     , pc.ctr_information12 ctr_units --  used in percentage part time calculation
     , pc.ctr_information11 norm_ctr_hours -- Used for Percentage of part_time
     --
     , asg.effective_start_date
     , asg.employment_category emp_cat -- Used for activity_type_code and percentage of part_time
     , paf.full_name Name
     , pca.CAG_INFORMATION1 col_aggr_code --S41.G01.00.016
     , asg.assignment_id assignment_id -- used for fetch conventional classfication --S41.G01.00.017
     /*     DECODE(SEX, 'F', DECODE(NVL(PER_INFORMATION1, PREVIOUS_LAST_NAME), LAST_NAME, NULL,LAST_NAME)                  , 'M', DECODE( PREVIOUS_LAST_NAME, LAST_NAME, NULL, LAST_NAME)) Name --Getting the employee full name*/
  From per_all_assignments_f asg
     ,pay_assignment_actions paa
     , per_jobs pj
     , per_all_people_f paf
     , per_contracts_f pc
     , HR_SOFT_CODING_KEYFLEX sck
     , hr_organization_information org_est
     , per_collective_agreements pca
 Where paa.assignment_action_id = g_assign_action_id
   and asg.person_id = paf.person_id
   And asg.person_id = p_person_id
   And asg.assignment_id = paa.assignment_id
   And org_est.org_information1 = p_org_id
   And asg.establishment_id = org_est.organization_id
   And p_effective_date between asg.effective_start_date
                         And   asg.effective_end_date
   And asg.job_id = pj.job_id(+)
   And asg.SOFT_CODING_KEYFLEX_ID = sck.SOFT_CODING_KEYFLEX_ID
   And asg.contract_id=pc.contract_id(+)
   And asg.COLLECTIVE_AGREEMENT_ID = pca.COLLECTIVE_AGREEMENT_ID(+)
   And nvl(pca.CAG_INFORMATION_CATEGORY, 'FR') = 'FR'
 Order By asg.effective_start_date Desc;

--l_date_trk_41_rec  fetch_date_trk_41%rowtype;
--
--
-- Cursor to fetch the pension information....
--
Cursor fetch_pension_info(p_date Date) Is
Select pef.entry_information1 pension_info--Used in employment cat code
  From pay_element_entries_f pef
     , pay_element_links_f pel
     , pay_element_types_f pet
     , per_all_assignments_f asg
     , hr_organization_information org_est
     ,pay_assignment_actions paa
 Where paa.assignment_action_id = g_assign_action_id
   and pef.assignment_id = asg.assignment_id
   and paa.assignment_id = asg.assignment_id
   And asg.person_id = p_person_id
   And asg.establishment_id = org_est.organization_id
   And org_est.org_information1 = p_org_id
   And pef.entry_information_category = 'FR_PENSION INFORMATION'
   And p_date Between pef.effective_start_date
                            And  pef.effective_end_date
   And pef.element_link_id = pel.element_link_id
   And pel.element_type_id = pet.Element_type_id
   And pet.element_name = 'FR_PENSION'
 Order By  pef.effective_start_date Desc;

--
--Cursor to determine assignment location details
 Cursor csr_asg_loc(p_asg_location Number) Is
  Select hla.address_line_2 complement
       ,hla.address_line_1 street_name
       ,hla.region_2 insee_code
       ,hla.region_3 small_town
       ,hla.postal_code zip_code
       ,upper(hla.town_or_city) town
       ,hla.country country_code
       ,ft_tl.territory_short_name country_name
  From hr_locations_all hla
      ,fnd_territories ft
      ,fnd_territories_tl ft_tl
 Where location_id = p_asg_location
   And ft.territory_code = hla.country
   And ft_tl.territory_code (+) = ft.territory_code
   And ft_tl.language (+) = userenv('LANG');

l_csr_asg_loc csr_asg_loc%rowtype;

--Cursor to determine dates and leaving reasons of a person
  Cursor get_person_dtl IS
   Select pps.Date_start start_date
         ,pps.Actual_termination_date term_date
         ,pps.Final_process_date final_date
         ,pps.Leaving_reason leav_reason
     From  per_periods_of_service pps
          ,per_all_assignments_f  asg
          ,hr_organization_information org_est
          ,pay_assignment_actions paa
    Where paa.assignment_action_id = g_assign_action_id
      and org_est.org_information1  = p_org_id
      And pps.person_id = asg.person_id
      And asg.person_id = p_person_id
      and asg.assignment_id = paa.assignment_id
      And asg.establishment_id = org_est.organization_id
      And pps.date_start between asg.effective_start_date and asg.effective_end_date;



--Cursor to determine user_table values
--
--
cursor c_assignment_cursor is
select assignment_id
      ,greatest(g_param_start_date,effective_start_date) effective_start_date
      ,least(g_effective_date, effective_end_date) effective_end_date
  from per_all_assignments_f paf
 where person_id = p_person_id
   And g_effective_date Between effective_start_date And effective_end_date;

c_assignment c_assignment_cursor%rowtype;

--Cursor for multiple employer
 Cursor get_multi_emp(p_effective_date DATE) Is
 Select pef.element_entry_id element_entry_id
   From pay_element_entries_f pef
       ,pay_element_links_f pel
       ,pay_element_types_f pet
  Where pef.assignment_id = p_assignment_id
    And pef.element_link_id = pel.element_link_id
    And pel.element_type_id = pet.Element_type_id
    And pet.element_name = 'FR_MULTIPLE_EMPLOYER'
    And p_effective_date Between pet.effective_start_date
                             And pet.effective_end_date
    And p_effective_date Between pef.effective_end_date
                             And pef.effective_end_date;


--Cursor to fetch Conventional Classification.....S41.G01.00.017

  Cursor csr_fetch_conv_class(p_assignment_id per_all_assignments_f.assignment_id%type
                             ,p_effective_date DATE
                             ,p_per_id   Number)
  Is
    Select gqual.segment_attribute_type  qualifier
          ,substr(CAGR.segment1,1,60) conv_classfication
  from
    per_all_assignments_f        asg
   ,per_cagr_grades_def          cagr
   ,fnd_id_flex_segments         seg
   ,fnd_segment_attribute_values gqual
  where  asg.assignment_id        = p_assignment_id
   and   asg.cagr_grade_def_id    = CAGR.cagr_grade_def_id (+)
   and   gqual.id_flex_num(+)     = CAGR.id_flex_num
   and   gqual.id_flex_code(+)    = 'CAGR'
   and   gqual.attribute_value(+) = 'Y'
   and   seg.id_flex_code         = 'CAGR'
   and   seg.id_flex_num          = asg.cagr_id_flex_num
   and   seg.application_id       = p_per_id
   and   gqual.application_id     = p_per_id
   and   seg.application_column_name = gqual.application_column_name
   and   p_effective_date between asg.effective_start_date and asg.effective_end_date
   and   gqual.application_column_name = 'SEGMENT1'
   and   gqual.segment_attribute_type = 'COEFFICIENT'
  order by seg.segment_num;

-- Fetch the product Id
  cursor csr_get_per_id is
  select application_id
  from fnd_application
  where application_short_name = 'PER';
--
-- New cursor is defined to get all the payroll periods
-- as part of Time Analysis Changes.
Cursor csr_get_per_dates(p_effective_date DATE) Is
select ptp.end_date
      ,ptp.start_date
  from pay_action_interlocks  pai
     , pay_assignment_actions paa
     , pay_payroll_actions ppa
     , per_time_periods ptp
 where pai.locking_action_id    = g_assign_action_id
   and paa.assignment_action_id = pai.locked_action_id
   and ppa.payroll_action_id    = paa.payroll_action_id
   and ptp.payroll_id = ppa.payroll_id
   and ptp.start_date > g_param_start_date
   and ptp.end_date < p_effective_date
 Order By ptp.start_date desc;
--
  type t_asg_org is record(
        start_date         date,
        end_date           date,
        start_reason       Varchar2(25),
        end_reason         Varchar2(25)) ;

  Type hist_tab IS TABLE of t_asg_org INDEX BY BINARY_INTEGER;
  l_hist hist_tab;

--Local Variables....
-- #3587152
l_ss_base                                        NUMBER;
l_ss_base_retro                                  NUMBER;
l_ss_disabled_base                               NUMBER;
l_ss_disabled_base_retro                         NUMBER;
l_ss_excess_base                                 NUMBER;
l_ss_part_time_base                              NUMBER;
l_ss_part_time_base_retro                        NUMBER;
l_ss_apprenticeship_base                         NUMBER;
l_ss_base_above_smic                             NUMBER;
l_ss_base_above_smic_retro                       NUMBER;
l_ta_ss_band_retro                               NUMBER;
l_ta_ss_disabled_band_retro                      NUMBER;
l_ta_ss_part_time_band_retro                     NUMBER;
l_ta_ss_band_under_limit                         NUMBER;
l_ta_ss_band_under_limit_retro                   NUMBER;
l_ta_ss_band_above_smic_retro                    NUMBER;
-- #3587152

l_ta_ss_band                                     NUMBER;
l_ta_ss_disabled_band                            NUMBER;
l_ta_ss_part_time_band                           NUMBER;
l_subject_to_csg                                 NUMBER;
l_subject_to_csg_excess                          NUMBER;
l_subject_to_crds                                NUMBER;
l_subject_to_salary_tax                          NUMBER;
l_subject_to_salary_tax_excess                   NUMBER;
l_benefit_food                                   NUMBER;
l_benefit_housing                                NUMBER;
l_benefit_car                                    NUMBER;
l_benefit_other                                  NUMBER;
l_prof_expense_lump_sums                         NUMBER;
l_actual_prof_expenses                           NUMBER;
l_prof_exp_pd_by_comp                            NUMBER;
l_reimb_nprof_exp                                NUMBER;
l_taxable_income                                 NUMBER;
l_gross_sbase_sec                                NUMBER;
l_gross_sbase_sec_sign                           VARCHAR2(1);
l_cap_ssec_base                                  NUMBER;
l_cap_ssec_base_sign                             VARCHAR2(1);
l_csg_base                                       NUMBER;
l_csg_base_sign                                  VARCHAR2(1);
l_fiscal_base                                    NUMBER;
l_fiscal_base_sign                               VARCHAR2(1);
l_fringe_benefits                                NUMBER;
l_fringe_benefits_sign                           VARCHAR2(1);
l_professional_expenses                          NUMBER;
l_professional_expenses_sign                     VARCHAR2(1);
l_taxable_income_sign                            VARCHAR2(1);


l_work_hr_org                                    hr_organization_information.org_information3%type;
l_work_risk_code                                 hr_organization_information.org_information4%type;
l_temp_work_risk_code                            hr_organization_information.org_information4%type;
l_work_order_number                              hr_organization_information.org_information5%type;
l_work_section_code                              hr_organization_information.org_information6%type;
l_work_office_code                               hr_organization_information.org_information7%type;

l_param_start_date                               DATE;
l_effective_date                                 DATE;

l_payroll_action_id                              pay_assignment_actions.payroll_action_id%type;
l_counter                                        NUMBER;
l_flag                                           BOOLEAN;
l_097_exists                                     NUMBER;
l_date_start                                     DATE;
l_act_dt                                         DATE;
l_final_date                                     DATE;
l_month                                          NUMBER;
l_year                                           NUMBER;
l_date                                           DATE;
l_multi_employr_code                             VARCHAR2(10);
l_positive_offset                                Varchar2(10);
l_job_id                                         number;
l_job_definition_id                              number;
l_job_name                                       per_jobs.name%type;
l_pcs_code                                       VARCHAR2(50);
l_eff_job_date                                   DATE;
l_leav_reason                                    per_periods_of_service.leaving_reason%type;

l_percentage_part_time                           NUMBER;
l_emp_month_hours                                NUMBER;
l_estab_monthly_hours                            NUMBER;
l_est_location                                   hr_locations_all.location_id%type;
l_asg_location                                   hr_locations_all.location_id%type;
l_bal_start_date                                 DATE;
l_value                                          fnd_new_messages.message_text%type;
l_unused_number                                  NUMBER;
l_first_row                                      BOOLEAN;
l_old_value                                      VARCHAR2(250);
l_old_value_1                                    VARCHAR2(250);
l_old_coy                                        hr_organization_information.organization_id%type;
l_old_est                                        hr_organization_information.organization_id%type;
l_work_acc_rate                                  pay_user_column_instances_f.value%type;
l_siret_number                                   VARCHAR2(10);
l_estab_id                                       per_all_assignments_f.establishment_id%type;
l_element_entry_id                               pay_element_entries_f.element_entry_id%type;
l_contract_type                                  VARCHAR2(50);
l_contract_type_1                                per_contracts_f.type%type;
l_prof_code                                      HR_SOFT_CODING_KEYFLEX.segment16%type;
l_border_worker                                  HR_SOFT_CODING_KEYFLEX.segment12%type;
l_detache                                        HR_SOFT_CODING_KEYFLEX.segment14%type;
l_act_type                                       per_contracts_f.type%type;
l_norm_hours                                     NUMBER;
l_frequency                                      per_all_assignments_f.frequency%type;
l_employment_cat                                 per_all_assignments_f.employment_category%type;
l_person_number                                  per_all_people_f.employee_number%type;
l_act_typ_val                                    pay_user_column_instances_f.value%type;
l_act_typ_code                                   VARCHAR2(10);
l_pension_info                                   pay_element_entries_f.entry_information1%type;
l_pen_agirc_val                                  pay_user_column_instances_f.value%type;
l_emp_cat_code                                   VARCHAR2(10);
l_col_aggr_code                                  VARCHAR2(4);
l_pension_code                                   NUMBER;
l_subject_to_crds_sign                           VARCHAR2(1);
l_benefit_food_sign                              VARCHAR2(1);
l_benefit_housing_sign                           VARCHAR2(1);
l_benefit_car_sign                               VARCHAR2(1);
l_benefit_other_sign                             VARCHAR2(1);
l_prof_expense_lump_sums_sign                    VARCHAR2(1);
l_actual_prof_expenses_sign                      VARCHAR2(1);
l_prof_exp_pd_by_comp_sign                       VARCHAR2(1);
l_reimb_nprof_exp_sign                           VARCHAR2(1);
l_assignment_id                                  per_all_assignments_f.assignment_id%type;
l_id2                                            VARCHAR2(30);

--Used in determining reason code 21....
l_21_con_old                                     Varchar2(250); --contract category-- proration is feasible
l_21_con_status                                  per_contracts_f.status%type; --contract status -proration is feasible
l_21_status_old                                  Varchar2(250); --contract status-- proration is feasible
l_21_cat_old                                     Varchar2(250); -- employee category -- proration feasible only if its parttime.
l_21_cipdz_old                                   varchar2(250); --CIPDZ Value -- proration feasible only if its parttime.
l_21_ptype_old                                   Varchar2(250); --Process Type -- proration is feasible.
l_conventional_classification                    Varchar2(250);
l_per_id                                         Number;
l_cipdz_value                                    varchar2(250);
--Names
l_issue_estab_name                               hr_all_organization_units_tl.name%type;
l_emp_full_name                                  per_all_people_f.full_name%type;
l_country_code                                   Varchar2(30);
l_location_name                                  hr_locations_all_tl.location_code%type;

--Variable to hold the last payroll run date, which has been executed just before the dads period
c_end_date                                       date;
c_start_date                                     date;

 -- Local Variable Declaration for Exceptions
l_error_type             hr_lookups.meaning%type;
l_error                  hr_lookups.meaning%type;
l_warning                hr_lookups.meaning%type;
l_asg_estab_name         hr_all_organization_units_tl.name%type;
l_mandatory              varchar2(1);
l_conditional            varchar2(1);
l_optional               varchar2(1);

l_id2_num                Number;

l_tbl_count Number;

--Variables to hold the values for S41.G01.00.021, S41.G01.00.022, S41.G01.00.023
l_num_hrs  Number;
l_num_hrs_emp Number;
l_num_hrs_latest Number;
l_mth_023 varchar2(2);
-- variables added for time analysis changes
l_ctr_frequency     per_contracts_f.ctr_information13%type;
l_norm_ctr_hours    per_contracts_f.ctr_information11%type;
l_ctr_units         per_contracts_f.ctr_information12%type;
l_023_ss_base                                        NUMBER;
l_023_ss_base_retro                                  NUMBER;
l_023_ss_disabled_base                               NUMBER;
l_023_ss_disabled_base_retro                         NUMBER;
l_023_ss_excess_base                                 NUMBER;
l_023_ss_part_time_base                              NUMBER;
l_023_ss_part_time_base_retro                        NUMBER;
l_023_ss_apprenticeship_base                         NUMBER;
l_023_ss_base_above_smic                             NUMBER;
l_023_ss_base_above_smic_retro                       NUMBER;
l_023_gross_sbase_sec                                NUMBER;
l_hourly_smic_rate                                   NUMBER;
l_session_id                                         fnd_sessions.session_id%type;

--temp Variables used to sort pl/sql table...
tmp_start_date  Date;
tmp_start_reason Varchar2(10);
tmp_end_date  Date;
tmp_end_reason Varchar2(10);

k Number;


--Variable to track pension category change...
l_pen_cat_val Varchar2(10);
l_emp_cat_rs_code Varchar2(10);

BEGIN
-- Initializing the local variables
-- #3587152
l_ss_base                         := 0;
l_ss_base_retro                   := 0;
l_ss_disabled_base                := 0;
l_ss_disabled_base_retro          := 0;
l_ss_excess_base                  := 0;
l_ss_part_time_base               := 0;
l_ss_part_time_base_retro         := 0;
l_ss_apprenticeship_base          := 0;
l_ss_base_above_smic              := 0;
l_ss_base_above_smic_retro        := 0;
l_ta_ss_band_retro                := 0;
l_ta_ss_disabled_band_retro       := 0;
l_ta_ss_part_time_band_retro      := 0;
l_ta_ss_band_under_limit          := 0;
l_ta_ss_band_under_limit_retro    := 0;
l_ta_ss_band_above_smic_retro     := 0;
-- #3587152

l_ta_ss_band                      := 0;
l_ta_ss_disabled_band             := 0;
l_ta_ss_part_time_band            := 0;
l_subject_to_csg                  := 0;
l_subject_to_csg_excess           := 0;
l_subject_to_crds                 := 0;
l_subject_to_salary_tax           := 0;
l_subject_to_salary_tax_excess    := 0;
l_benefit_food                    := 0;
l_benefit_housing                 := 0;
l_benefit_car                     := 0;
l_benefit_other                   := 0;
l_prof_expense_lump_sums          := 0;
l_actual_prof_expenses            := 0;
l_prof_exp_pd_by_comp             := 0;
l_reimb_nprof_exp                 := 0;
l_taxable_income                  := 0;
l_gross_sbase_sec                 := 0;
l_cap_ssec_base                   := 0;
l_csg_base                        := 0;
l_fiscal_base                     := 0;
l_fringe_benefits                 := 0;
l_professional_expenses           := 0;
l_097_exists                      := 0;
l_mandatory                       := 'M';
l_conditional                     := 'C';
l_optional                        := 'O';
-- variables initialized for time analysis
l_023_ss_base                     := 0;
l_023_ss_base_retro               := 0;
l_023_ss_disabled_base            := 0;
l_023_ss_disabled_base_retro      := 0;
l_023_ss_excess_base              := 0;
l_023_ss_part_time_base           := 0;
l_023_ss_part_time_base_retro     := 0;
l_023_ss_apprenticeship_base      := 0;
l_023_ss_base_above_smic          := 0;
l_023_ss_base_above_smic_retro    := 0;
l_023_gross_sbase_sec             := 0;
l_hourly_smic_rate                := 0;
--
  hr_utility.set_location('S41 p_assact_id:'||g_assign_action_id,10);
  l_hist.DELETE;
  l_assignment_id := p_assignment_id;
  l_tbl_count := 1;

-- Reson 095 and 097 is fetched from the sql below
-- 095: this is done only when there is a employee who has atd
-- between st and end dates of dads report dates

   For get_person_rec In get_person_dtl
   Loop
     l_date_start := get_person_rec.start_date;
     l_act_dt := get_person_rec.term_date;
     l_final_date := get_person_rec.final_date;
     l_leav_reason := hr_general.decode_lookup('LEAV_REAS', get_person_rec.leav_reason);
   End Loop;

   hr_utility.set_location('S41 g_param_start_date 97:'||g_param_start_date,10);

   If l_date_start < g_param_start_date Then
      l_hist(l_tbl_count).start_date := g_param_start_date;
      l_hist(l_tbl_count).start_reason := '097';
      hr_utility.set_location('S41 g_param_start_date 97:'||g_param_start_date,10);
      l_tbl_count := l_tbl_count + 1;
   End If;

--end for reason 97

--035:Pension Category change....
-- The following code is changed owing to requirements change
-- mentioned in bug#3285375
-- This will record changes for reason code 25 and reason code 35 is outscoped...

l_first_row := TRUE;
 For csr_35_rec in csr_35 Loop
  Exit when csr_35%notfound;
    if l_first_row = TRUE THEN
       -- record the first row for pen cat
     l_hist(l_tbl_count).start_date := greatest(csr_35_rec.start_date, l_date_start);
     l_hist(l_tbl_count).start_reason := '025';
     l_first_row := FALSE;
       -- store the comparison value for pen_cat
     l_old_value := csr_35_rec.pen_cat;
     IF(l_hist(l_tbl_count).start_date <> l_date_start) Then
        l_tbl_count := l_tbl_count + 1;
     End IF;
  elsif l_old_value <> csr_35_rec.pen_cat THEN
    -- the stored value has changed - record this in the history
     Begin
       l_pen_cat_val := hruserdt.get_table_value (
                                              g_param_business_group_id,
                                             'FR_APEC_AGIRC',
                                             'AGIRC' ,
                                              csr_35_rec.pen_cat,
                                              g_effective_date);
     Exception
     When Others then
       hr_utility.set_location('S41 FR_APEC_AGIRC Failed:'||sqlerrm,1113);
     End;

     If l_pen_cat_val = 'Y' Then
       If csr_35_rec.pen_cat = '222' Then -- Article 36
           l_emp_cat_rs_code := '02';
        Else
          l_emp_cat_rs_code := '01';
        End If;
       Else
         l_emp_cat_rs_code := '04';
       End If;

     If ((l_emp_cat_rs_code = '01')
          Or (l_emp_cat_rs_code = '02')
          Or (l_emp_cat_rs_code = '04')) Then
        l_hist(l_tbl_count).start_date := greatest(csr_35_rec.start_date, l_date_start);
        l_hist(l_tbl_count).start_reason := '025';
       -- and store the new comparison value
        l_old_value := csr_35_rec.pen_cat;
        l_tbl_count := l_tbl_count + 1;
     end if;
  end if;
 End loop;--

--Change in employee Category and professional status code
-- The following code is commented owing to requirements change
-- mentioned in bug#3285375
/*l_first_row := TRUE;
 For csr_25_rec in csr_25 Loop
 Exit when csr_25%notfound;
       if l_first_row = TRUE THEN
       -- record the first row for emp cat
       l_hist(l_tbl_count).start_date := greatest(csr_25_rec.start_date, l_date_start);
       l_hist(l_tbl_count).start_reason := '025';
       l_first_row := FALSE;
       -- store the comparison value for emp_cat
       l_old_value := csr_25_rec.emp_cat;
       IF(l_hist(l_tbl_count).start_date <> l_date_start) Then
          l_tbl_count := l_tbl_count + 1;
       End If;
      elsif l_old_value <> csr_25_rec.emp_cat THEN
       -- the stored value has changed - record this in the history
       l_hist(l_tbl_count).start_date := greatest(csr_25_rec.start_date, l_date_start);
       l_hist(l_tbl_count).start_reason := '025';
       -- and store the new comparison value
       l_old_value := csr_25_rec.emp_cat;
       l_tbl_count := l_tbl_count + 1;
      end if;
 End loop;
*/
--Get the last but one date for getting the values
BEGIN
   select max(effective_start_date)
     into l_param_start_date
     from per_all_assignments_f
    where assignment_id = p_assignment_id
      and effective_start_date < g_param_start_date;
    IF l_param_start_date IS NULL THEN
       l_param_start_date := g_param_start_date;
    END IF;
EXCEPTION
WHEN OTHERS THEN
   l_param_start_date := g_param_start_date;
END;

--Change in professional status code
l_first_row := TRUE;
 IF l_act_dt is not null and l_act_dt <= g_effective_date then
    c_end_date := l_act_dt;
 else
    c_end_date := g_effective_date;
 end if;
  For csr_23_rec in csr_23 (c_end_date, l_param_start_date) Loop
   Exit when csr_23%notfound;
-- Since we are taking the previous values, we don't add the first record of the cursor into the pl/sql table
   if l_first_row = TRUE THEN
      -- record the first row prof code
--     l_hist(l_tbl_count).start_date := greatest(csr_23_rec.start_date, l_date_start);
--     l_hist(l_tbl_count).start_reason := '023';
     -- store the comparison value for prof_code
     l_first_row := FALSE;
     l_old_value := csr_23_rec.prof_code;
--       IF(l_hist(l_tbl_count).start_date <> l_date_start) Then
--          l_tbl_count := l_tbl_count + 1;
--       End If;
-- Since professional status code is null, it is also added inthe if clause
   elsif ((l_old_value <> csr_23_rec.prof_code
               OR (l_old_value IS NULL AND csr_23_rec.prof_code IS NOT NULL)
               OR (l_old_value IS NOT NULL AND csr_23_rec.prof_code IS NULL))
     and csr_23_rec.start_date >= g_param_start_date) THEN
       -- the stored value has changed - record this in the history
     l_hist(l_tbl_count).start_date := greatest(csr_23_rec.start_date, l_date_start);
     l_hist(l_tbl_count).start_reason := '023';
     l_old_value := csr_23_rec.prof_code;
     l_tbl_count := l_tbl_count + 1;
-- If the start date is before dads period start date, it is just replaced with the old value
   elsif ((l_old_value <> csr_23_rec.prof_code
               OR (l_old_value IS NULL AND csr_23_rec.prof_code IS NOT NULL)
               OR (l_old_value IS NOT NULL AND csr_23_rec.prof_code IS NULL))
         and csr_23_rec.start_date < g_param_start_date) THEN
     -- the stored value has changed - record this in the history
     l_old_value := csr_23_rec.prof_code;
   End If;
 End loop;
--

-- Assignment Category, Process Type and Contract changes....
-- Need to make changes for the FR_CIPDZ table and check individually for these changes
-- Also for the cursor to look for payroll periods
-- Assignment Category, Process Type and Contract changes....
l_first_row := TRUE;
BEGIN
   select max(ppa.date_earned)
     into c_start_date
     from pay_assignment_actions paa
         ,pay_payroll_actions ppa
    where paa.assignment_id = p_assignment_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and ppa.date_earned < g_param_start_date
      and ppa.action_status = 'C'
      and ppa.action_type In ('R', 'Q');
   IF c_start_date is null THEN
      c_start_date := g_param_start_date;
   END IF;
EXCEPTION
WHEN OTHERS THEN
c_start_date := g_param_start_date;
END;
For csr_process_rec in csr_process (c_start_date) Loop
 Exit when csr_process%notfound;
   if l_first_row = TRUE THEN
     l_21_ptype_old := csr_process_rec.process_type;
     l_first_row := FALSE;
   elsif l_21_ptype_old <> csr_process_rec.process_type
     and csr_process_rec.calc_start_date >= g_param_start_date THEN
     -- the stored value has changed - record this in the history
     l_hist(l_tbl_count).start_date := greatest(csr_process_rec.calc_start_date, l_date_start);
     l_hist(l_tbl_count).start_reason := '021';
      -- and store the new comparison value
     l_21_ptype_old := csr_process_rec.process_type;
     l_tbl_count := l_tbl_count + 1;
   elsif l_21_ptype_old <> csr_process_rec.process_type
     and csr_process_rec.calc_start_date < g_param_start_date THEN
     l_21_ptype_old := csr_process_rec.process_type;
   end if;
 End loop;

l_first_row := TRUE;
 IF l_act_dt is not null and l_act_dt <= g_effective_date then
    c_end_date := l_act_dt;
 else
    c_end_date := g_effective_date;
 end if;

 For csr_contract_rec in csr_contract (c_end_date, l_param_start_date) Loop
    Exit when csr_contract%notfound;
    if l_first_row = TRUE THEN
       -- record the first row for emp cat
--       l_hist(l_tbl_count).start_date := greatest(csr_contract_rec.start_date, l_date_start);
--       l_hist(l_tbl_count).start_reason := '021';
       l_first_row := FALSE;
       -- store the comparison value for emp_cat
        l_21_con_old  := csr_contract_rec.contract_id;
        l_21_con_status := csr_contract_rec.status;
--       IF(l_hist(l_tbl_count).start_date <> l_date_start) Then
--          l_tbl_count := l_tbl_count + 1;
--       End If;
    elsif l_21_con_old <> csr_contract_rec.contract_id THEN
       begin
          select status
            into l_21_con_status
            from per_contracts_f
           where contract_id = l_21_con_old
             and csr_contract_rec.start_date between effective_Start_date
                                      and effective_end_Date;
       exception
       when others then
          l_21_con_status := NULL;
       end;
       IF  csr_contract_rec.status <> l_21_con_status
       AND csr_contract_rec.start_date >= g_param_start_date THEN
          -- the stored value has changed - record this in the history
          l_hist(l_tbl_count).start_date := csr_contract_rec.start_date;
          l_hist(l_tbl_count).start_reason := '021';
          -- and store the new comparison value
          l_21_con_old  := csr_contract_rec.contract_id;
          l_21_con_status := csr_contract_rec.status;
          l_tbl_count := l_tbl_count + 1;
       ELSIF  csr_contract_rec.status <> l_21_con_status
       AND csr_contract_rec.start_date < g_param_start_date THEN
          -- and store the new comparison value
          l_21_con_old  := csr_contract_rec.contract_id;
       end if;
   END IF;
 End loop;

 l_first_row := TRUE;
 IF l_act_dt is not null and l_act_dt <= g_effective_date then
    c_end_date := l_act_dt;
 else
    c_end_date := g_effective_date;
 end if;
 For csr_asg_cat_rec in csr_asg_cat (c_end_date, l_param_start_date) Loop
    Exit when csr_asg_cat%notfound;
    IF csr_asg_cat_rec.category IS NOT NULL THEN
       BEGIN
          l_cipdz_value := hruserdt.get_table_value (g_param_business_group_id,
                                                    'FR_CIPDZ',
                                                    'CIPDZ' ,
                                                    csr_asg_cat_rec.category,
                                                    csr_asg_cat_rec.asg_end_date);
       EXCEPTION
       WHEN OTHERS THEN
          l_cipdz_value := NULL;
          hr_utility.set_location('obtaining cipdz value Failed:'||sqlerrm,50);
       END;
    ELSE
       l_cipdz_value := NULL;
    END IF;
-- Since we are taking the previous values, we don't add the first record of the cursor into the pl/sql table
    if l_first_row = TRUE THEN
       -- record the first row for emp cat
--      If (csr_asg_cat_rec.category <> 'P') Then
--       l_hist(l_tbl_count).start_date := greatest(csr_asg_cat_rec.start_date,l_date_start);
--      Else
--       l_hist(l_tbl_count).start_date := greatest(csr_asg_cat_rec.asg_start_date,l_date_start);
--      End If;

--       l_hist(l_tbl_count).start_reason := '021';
       l_first_row := FALSE;
       -- store the comparison value for emp_cat
        l_21_cat_old := csr_asg_cat_rec.category;
	l_21_cipdz_old := l_cipdz_value;
      --  l_tbl_count := l_tbl_count + 1;
-- Since assignment category code is null, it is also added inthe if clause
-- When there is change from any other value other than p, then no run proration occurs.
-- Hence, we use payroll month's start date
    Else
-- When there is change from any other value to P or from P to any other value, then run proration occurs.
-- Hence, we use assignment start date.
     if ((l_21_cat_old <> csr_asg_cat_rec.category
               OR (l_21_cat_old IS NULL AND csr_asg_cat_rec.category IS NOT NULL)
               OR (l_21_cat_old IS NOT NULL AND csr_asg_cat_rec.category IS NULL)
	      )
                   And (substr(l_21_cipdz_old, 1, 1) = 'P'
                        Or substr(l_cipdz_value, 1, 1) = 'P')
                   And csr_asg_cat_rec.asg_start_date >= g_param_start_date)   THEN
       -- the stored value has changed - record this in the history
       l_hist(l_tbl_count).start_date := greatest(csr_asg_cat_rec.asg_start_date,l_date_start);
       l_hist(l_tbl_count).start_reason := '021';
       -- and store the new comparison value
       l_21_cat_old  := csr_asg_cat_rec.category;
       l_21_cipdz_old := l_cipdz_value;
       l_tbl_count := l_tbl_count + 1;
      elsif  ((l_21_cat_old  <>  csr_asg_cat_rec.category
                     OR (l_21_cat_old IS NULL AND csr_asg_cat_rec.category IS NOT NULL)
               OR (l_21_cat_old IS NOT NULL AND csr_asg_cat_rec.category IS NULL)
	     )
                   And (substr(l_21_cipdz_old, 1, 1) <> 'P'
                        Or substr(l_cipdz_value, 1, 1) <> 'P')
              And csr_asg_cat_rec.asg_start_date >= g_param_start_date) THEN
       -- the stored value has changed - record this in the history
       l_hist(l_tbl_count).start_date :=   greatest(csr_asg_cat_rec.start_date,l_date_start);
       l_hist(l_tbl_count).start_reason := '021';
       l_tbl_count := l_tbl_count + 1;
       l_21_cat_old  := csr_asg_cat_rec.category;
       l_21_cipdz_old := l_cipdz_value;
-- If the start date is before dads period start date, it is just replaced with the old value
     elsif ((l_21_cat_old <> csr_asg_cat_rec.category
               OR (l_21_cat_old IS NULL AND csr_asg_cat_rec.category IS NOT NULL)
               OR (l_21_cat_old IS NOT NULL AND csr_asg_cat_rec.category IS NULL))
           and csr_asg_cat_rec.asg_start_date < g_param_start_date) THEN
           l_21_cat_old := csr_asg_cat_rec.category;
     	   l_21_cipdz_old := l_cipdz_value;
      end if;
  End if;
 End loop;
--

   -- Overwrite with 019 (mutation in another estab in the company)
   --

   BEGIN
     open csr_19(p_person_id);
     l_old_coy := null;
     l_old_est := null;
     LOOP
       fetch csr_19 into l_csr_19_rec;
       exit when csr_19%NOTFOUND;
       if l_csr_19_rec.type = 'FIRST' THEN
         -- record the company and estab the person was in before the date range
         -- this may not exist
         l_old_coy := l_csr_19_rec.company_id;
         l_old_est  := l_csr_19_rec.establishment_id;
       elsif l_old_coy is null THEN
         -- the asg joined on or after the start date - this is a csr_001 type
         -- record the new company and estab and continue
         l_old_coy := l_csr_19_rec.company_id;
         l_old_est  := l_csr_19_rec.establishment_id;
       elsif l_old_coy = l_csr_19_rec.company_id and l_old_est <> l_csr_19_rec.establishment_id
         THEN
         -- the coy has not changed, the estab has, this is a type 19
         l_hist(l_tbl_count).start_date := l_csr_19_rec.start_date;
         l_hist(l_tbl_count).start_reason := '019';
         -- and store the new comparison value
         l_old_est  := l_csr_19_rec.establishment_id;
         l_tbl_count := l_tbl_count + 1;
       else -- the company has changed -
         l_old_coy := l_csr_19_rec.company_id;
         l_old_est  := l_csr_19_rec.establishment_id;
       end if;
     END LOOP;
     EXCEPTION
     when others then null;
   END;
   Close csr_19;

   If l_date_start >= g_param_start_date Then
      l_hist(l_tbl_count).start_date := l_date_start;
      l_hist(l_tbl_count).start_reason := '001';
      l_tbl_count := l_tbl_count + 1;
      hr_utility.set_location('S41 g_param_start_date 01:'||g_param_start_date,10);
   End if;

 -- First the bubble sorting is done.  Then the termination details are added to the last pl/sql record.
 hr_utility.set_location('Before Bubble sort' ,8888);

 For i in l_hist.first..l_hist.last
 Loop
  If  l_hist.exists(i) Then
   hr_utility.set_location('l_hist(i).start_date: '||l_hist(i).start_date,99);
   hr_utility.set_location('l_hist(i).start_reason: '||l_hist(i).start_reason,99);
  end if;
 End LOOP;

 --Bubble sort for all the start dates collected from the cursors above....
 Begin
   For i in l_hist.first..l_hist.last
   Loop
     For j in l_hist.first..(l_hist.last - i)
     Loop
       k := l_hist.Next(j);
       If (l_hist(k).start_date < l_hist(j).start_date) Then
          tmp_start_date := l_hist(j).start_date;
          tmp_start_reason := l_hist(j).start_reason;
          l_hist(j).start_date := l_hist(k).start_date;
          l_hist(j).start_reason :=   l_hist(k).start_reason;
          l_hist(k).start_date := tmp_start_date;
          l_hist(k).start_reason := tmp_start_reason;

          tmp_end_date := l_hist(j).end_date;
          tmp_end_reason := l_hist(j).end_reason;
          l_hist(j).end_date := l_hist(k).end_date;
          l_hist(j).end_reason :=   l_hist(k).end_reason;
          l_hist(k).end_date := tmp_end_date;
          l_hist(k).end_reason := tmp_end_reason;
       End If;
     End Loop;
   End Loop;
 Exception
 When Others Then
  hr_utility.set_location('SORT LOOP:'|| sqlerrm,8888);
 End;

   -- adjust for termination and other reasons
   -- Use l_leav_reason for leaving reason and l_act_date for actual termination date
   -- retrived in query for 95 and 97
   --
  hr_utility.set_location('Fetching termination details' ,8888);
  -- l_leav_reason is not a mandatory field.  Hence, leave reason not null check is taken off and actual term. date check is kept
  If l_act_dt Is Not Null and l_act_dt <= g_effective_date Then
    l_counter := l_hist.LAST;
    -- Flag is used to check whether the termination details are added to the pl/sql table or not
    l_flag := TRUE;
    l_tbl_count := l_hist.PRIOR(l_counter);
    while l_flag = TRUE AND l_hist.EXISTS(l_counter)
    LOOP
       IF l_hist.EXISTS(l_tbl_count) THEN
          IF l_hist(l_counter).start_date = l_hist(l_tbl_count).start_date THEN
             IF (l_hist(l_tbl_count).start_reason <= l_hist(l_counter).start_reason) THEN
   	        l_counter := l_tbl_count;
 	     END IF;
             l_tbl_count := l_hist.PRIOR(l_tbl_count);
	  ELSE
             l_hist(l_counter).end_date := l_act_dt;
     	     l_hist(l_counter).end_reason := l_leav_reason;
	     l_flag := FALSE;
	  END IF;
       ELSE
          l_hist(l_counter).end_date := l_act_dt;
     	  l_hist(l_counter).end_reason := l_leav_reason;
	  l_flag := FALSE;
       END IF;
    END LOOP;
   --
  End If;
   --
 --First delete the lower priority records and then add the end date and end reasons to the records
 BEGIN
   l_counter := l_hist.LAST;
   l_counter := l_hist.PRIOR(l_counter);
   While l_counter is not null
   LOOP
      IF l_hist.EXISTS(l_counter) THEN
         If(l_hist.exists(l_hist.next(l_counter))) Then
            If (l_hist(l_counter).start_date = l_hist(l_hist.Next(l_counter)).start_date) Then
               hr_utility.set_location('ADJUST_HISTORY :'||l_hist(l_counter).start_reason||':'||l_hist(l_hist.Next(l_counter)).start_reason ,5555);
               If (l_hist(l_counter).start_reason > l_hist(l_hist.Next(l_counter)).start_reason) Then
                  l_hist.Delete(l_counter);
                  hr_utility.set_location('ADJUST_HISTORY DELETED:'||l_counter,6666);
               ElsIf (l_hist(l_counter).start_reason <= l_hist(l_hist.Next(l_counter)).start_reason) Then
                  l_hist.Delete(l_hist.Next(l_counter));
                  hr_utility.set_location('ADJUST_HISTORY DELETED 1:'||l_counter,6666);
               End If;
            End If;
         End if;
      END IF;
    l_counter := l_hist.PRIOR(l_counter);
    END LOOP;
 Exception
 When Others Then
  hr_utility.set_location('DELETING LOWER PRIORITY RECORDS:'|| sqlerrm,8888);
 End;
--
--
   --
   -- adjust the history...set the end dates for the reasons which are other than
   -- termination
 hr_utility.set_location('After Bubble sort' ,8888);
 Begin
   l_counter := l_hist.LAST;
   While l_counter is not null
   -- This ending reason is related to the next starting reason
   LOOP
    If (l_hist(l_counter).end_date Is Null) Then
     If l_hist.Exists(l_hist.NEXT(l_counter)) Then
      If (l_hist(l_hist.NEXT(l_counter)).start_date <> l_date_start) Then
        l_hist(l_counter).end_date :=  l_hist(l_hist.NEXT(l_counter)).start_date - 1;
        If ((l_hist(l_counter).end_date < l_hist(l_counter).start_date) Or
            (l_hist(l_counter).end_date < g_param_start_date)
           ) Then
           l_hist(l_counter).end_date :=  g_effective_date;
        End if;
        l_hist(l_counter).end_reason :=  '0'||to_char(l_hist(l_hist.NEXT(l_counter)).start_reason +1);
      End if;
     Else
      l_hist(l_counter).end_date :=  g_effective_date;
      l_hist(l_counter).end_reason :=  '098';
     End If;
    End If;
     l_counter := l_hist.PRIOR(l_counter);
   END LOOP;
 Exception
 When Others Then
  hr_utility.set_location('ADJUST_HISTORY:'|| sqlerrm,8888);
 End;

 hr_utility.set_location('After History Adjust' ,8888);
--Delete duplicate periods... The Duplication occurs if there are more than one
--Reason code on a given day...Reason code which is lesser takes precedence.
Begin
 l_counter := l_hist.LAST;
 -- The last record should be deleted if it satisfies the given conditions
 IF l_hist.EXISTS(l_counter) THEN
    If ((l_hist(l_counter).start_date < l_date_start) Or
        (l_hist(l_counter).end_date > g_effective_date) Or
        (l_hist(l_counter).end_date is NUll) Or
        (l_hist(l_counter).end_date <= l_hist(l_counter).start_date) Or
        (l_hist(l_counter).end_date <= g_param_start_date)
        ) Then
        l_hist.Delete(l_counter);
        hr_utility.set_location('ADJUST_HISTORY deleting anamolous records:'||l_counter,5555);
   end if;
 END IF;

 l_counter := l_hist.PRIOR(l_counter);
 While l_counter is not null
 LOOP
   If ((l_hist(l_counter).start_date < l_date_start) Or
       (l_hist(l_counter).end_date > g_effective_date) Or
       (l_hist(l_counter).end_date is NUll) Or
       (l_hist(l_counter).end_date <= l_hist(l_counter).start_date) Or
       (l_hist(l_counter).end_date <= g_param_start_date)
      ) Then
      l_hist.Delete(l_counter);
      hr_utility.set_location('ADJUST_HISTORY deleting anamolous records:'||l_counter,5555);
   end if;
 l_counter := l_hist.PRIOR(l_counter);
 END LOOP;

 Exception
 When Others Then
  hr_utility.set_location('DELETE WHERE END DATE IS NOT PROPER:'|| sqlerrm,8888);
 End;

-- Checking for Isolated sums
 If l_final_date >= g_param_start_date Then
     l_month := to_number(to_char(g_param_start_date, 'mm'));
     l_year  := to_number(to_char(g_param_start_date, 'yyyy'));
     l_bal_start_date := to_date('01-' ||l_month ||'-'||l_year || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss');
     l_unused_number := 0;
     l_unused_number := fr_rolling_balance_pro (p_assignment_id => l_assignment_id,
                       		                           p_balance_name => 'FR_ISOLATED_SUMS',
                   	                                   p_balance_start_date => l_bal_start_date,
      		                                           p_balance_end_date => g_effective_date);
    If l_unused_number > 0 Then
       l_tbl_count := l_hist.LAST;
       IF l_tbl_count IS NULL THEN
          l_tbl_count := 1;
       ELSE
          l_tbl_count := l_tbl_count + 1;
       END IF;

      l_year := to_number(to_char(g_param_start_date, 'yyyy'));
      l_hist(l_tbl_count).start_date := to_date('01-01-'||l_year || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss');
      l_hist(l_tbl_count).start_reason := '095';
      -- As per functional doc. end date should also be 0101
      l_hist(l_tbl_count).end_date := to_date('01-01-'||l_year || ' 00:00:00', 'dd-mm-yyyy hh24:mi:ss');
      l_hist(l_tbl_count).end_reason := '096';
      l_tbl_count :=  l_tbl_count + 1;
      hr_utility.set_location('S41 g_param_start_date 01:'||g_param_start_date,10);
    End If;
 End If;

   --
   --
   -- Getting the error messages
   l_error := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E');
   l_warning := hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W');

 --
 hr_utility.set_location('L_HIST COUNT:'||l_hist.count, 117);

 For i in l_hist.first..l_hist.last
 Loop
  If  l_hist.exists(i) Then
   hr_utility.set_location('l_hist(i).start_date: '||l_hist(i).start_date,99);
   hr_utility.set_location('l_hist(i).start_reason: '||l_hist(i).start_reason,99);
   hr_utility.set_location('l_hist(i).end_date: '||l_hist(i).end_date,99);
   hr_utility.set_location('l_hist(i).end_reason: '||l_hist(i).end_reason,99);
  end if;
 End LOOP;

 hr_utility.set_location('Before looping in S41 DATA' ,8888);
  l_counter := l_hist.FIRST;
  l_id2_num := 0;
  Begin
  While l_counter is not null
  LOOP
   If  l_hist.exists(l_counter) Then
    --Need to be edited for exceptions report validation
    --Start of the Period for the Situation
     l_id2_num := l_id2_num + 1;
     l_id2 := p_org_id||l_id2_num;

     IF  l_hist(l_counter).start_reason = '095'
         and l_act_dt >= g_param_start_date THEN
         l_param_start_date := l_act_dt;
     ELSIF  l_hist(l_counter).start_reason = '095'
            and l_act_dt < g_param_start_date THEN
         l_param_start_date := g_param_start_date;
     ELSIF  (l_hist(l_counter).start_date Is Not NUll And
         l_hist(l_counter).start_date >= g_param_start_date) Then
         l_param_start_date := l_hist(l_counter).start_date;
     ElsIF  l_hist(l_counter).start_date Is NUll Then
         l_param_start_date := g_param_start_date;
         l_hist(l_counter).start_date := g_param_start_date;
     End If;

     IF  l_hist(l_counter).end_reason = '096' THEN
         l_effective_date := g_effective_date;
     ELSIF  (l_hist(l_counter).end_date Is Not NUll And
         l_hist(l_counter).end_date <= g_effective_date) Then
         l_effective_date := l_hist(l_counter).end_date;
     ElsIF  (l_hist(l_counter).end_date Is NUll) Then
         l_effective_date := g_effective_date;
         l_hist(l_counter).end_date := g_effective_date;
     End If;

     IF l_hist(l_counter).start_date is null THEN
        l_error_type := l_error;
        l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
	       'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.001'),
                 	null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;

        archive_data( p_rubric_name => 'S41.G01.00.001'
                     ,p_message_type => l_error_type
                     ,p_id => p_org_id
                     ,p_lookup_type => Null
                     ,p_file_value => to_char(l_hist(l_counter).start_date,'DDMM')
                     ,p_message_text => l_value
                     ,p_id2 => l_id2
                     ,p_rubric_type => l_mandatory);

     -- Reason Code for Start Period
     IF l_hist(l_counter).start_reason is null THEN
        l_error_type := l_error;
    	l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
             	'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.002'),
            	null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;

     archive_data( p_rubric_name => 'S41.G01.00.002'
                 ,p_message_type => l_error_type
                 ,p_id => p_org_id
                 ,p_lookup_type => 'FR_DADS_START_REASON'
                 ,p_file_value => l_hist(l_counter).start_reason
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_mandatory);

     --End of the Period for the Situation
     IF l_hist(l_counter).start_date is null THEN
        l_error_type := l_error;
    	l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
         	'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.003'),
             	null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;
     archive_data( p_rubric_name => 'S41.G01.00.003'
                 ,p_message_type => l_error_type
                 ,p_id => p_org_id
                 ,p_lookup_type => Null
                 ,p_file_value => to_char(l_hist(l_counter).end_date,'DDMM')
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_mandatory);

     -- Reason Code for End Period
     IF l_hist(l_counter).end_reason is null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
	'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.004'),
	null, null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;
	       archive_data( p_rubric_name => 'S41.G01.00.004'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_END_REASON'
                ,p_file_value => l_hist(l_counter).end_reason
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

 --

     hr_utility.set_location('S41 csr41_estab_data:'||p_person_id,110);
 --Fetch the Data for Estab. NIC and Work Accident related data.
     --Need to be edited for exceptions report validation
   Begin
   For l_csr41_estab_data In csr41_estab_data(l_effective_date)
   Loop
     hr_utility.set_location('S41 person_id:'||p_person_id,113);
      If l_csr41_estab_data.asg_location Is not Null Then
        l_asg_location := l_csr41_estab_data.asg_location;
      End If;

      If l_csr41_estab_data.information_Context = 'FR_ESTAB_INFO' THEN
        l_siret_number :=  l_csr41_estab_data.siret_number ;
        l_estab_id := l_csr41_estab_data.estab_id;
        l_estab_monthly_hours := l_csr41_estab_data.risk_code_month_hours;
        l_asg_estab_name := l_csr41_estab_data.asg_estab_name;
        l_issue_estab_name := l_csr41_estab_data.issue_estab_name;
        l_est_location := l_csr41_estab_data.est_location;
        l_location_name := l_csr41_estab_data.location_name;
      Elsif  l_csr41_estab_data.information_Context = 'FR_ESTAB_WORK_ACCIDENT' THEN
        l_work_hr_org := l_csr41_estab_data.hrorg;
	-- #3553829 Assigning the value to a temporary variable
        l_temp_work_risk_code := l_csr41_estab_data.risk_code_month_hours;
        l_work_order_number :=l_csr41_estab_data.order_number;
        l_work_section_code := l_csr41_estab_data.section_code;
        l_work_office_code := l_csr41_estab_data.office_code;
      End if;

     If (l_work_hr_org Is not Null) Then
        l_work_risk_code := l_csr41_estab_data.risk_code_month_hours;
     End If;

   End Loop;
   Exception
   When Others then
       hr_utility.set_location('S41 csr41_estab_data Failed:'||sqlerrm,110);
   End;

   -- #3553829 If l_work_risk_code does not have a value then, assign the work risk code value that has been stored in temp variable
   IF l_work_risk_code IS NULL THEN
      l_work_risk_code := l_temp_work_risk_code;
   END IF;

   hr_utility.set_location('S41 g_param_business_group_id:'||g_param_business_group_id,100);
   hr_utility.set_location('S41 l_est_location:'||l_est_location,101);
   hr_utility.set_location('S41 l_asg_location:'||l_asg_location,102);
   hr_utility.set_location('S41 l_issue_estab_name :'||l_issue_estab_name ,103);
   hr_utility.set_location('S41 l_location_name :'||l_location_name ,104);
   hr_utility.set_location('S41 l_asg_estab_name :'||l_asg_estab_name ,105);
   hr_utility.set_location('S41 l_siret_number   :'||l_siret_number,109);
   hr_utility.set_location('S41 l_estab_id:'||l_estab_id,108);
   hr_utility.set_location('S41 l_estab_monthly_hours:'||l_estab_monthly_hours,107);
   hr_utility.set_location('S41 l_work_hr_org:'||l_work_hr_org,106);
   hr_utility.set_location('S41 l_work_risk_code:'||l_work_risk_code,110);
   hr_utility.set_location('S41 l_work_order_number:'||l_work_order_number,111);
   hr_utility.set_location('S41 l_work_section_code:'||l_work_section_code,112);
   hr_utility.set_location('S41 l_work_office_code:'||l_work_office_code,113);
   hr_utility.set_location('S41 l_work_risk_code:'||l_work_risk_code,114);

   begin
   --Bug 3756137
   If l_work_risk_code = '99999' then
      l_work_acc_rate := l_work_risk_code;
   --Bug 3756137
   elsif l_work_risk_code Is not NULl then
    l_work_acc_rate := hruserdt.get_table_value (g_param_business_group_id,
                                                'FR_WORK_ACCIDENT_RATES',
                                                'RATE' ,
                                                l_work_risk_code,
                                                l_effective_date);
   End If;
   Exception
   When Others then
     hr_utility.set_location('S41 FR_WORK_ACCIDENT_RATES Failed:'||sqlerrm,110);
   end;

     -- NIC of the Assignment Establishment
    hr_utility.set_location('S41 out of the fitst cursor',114);
     IF l_siret_number is null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
	'VALUE1:'||l_issue_estab_name, 'VALUE2:'||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S41.G01.00.005'), null);
     ELSE
        l_error_type := null;
        l_value := null;
     END IF;
   hr_utility.set_location('S41 l_siret_number:'||l_siret_number,112);

   g_param_estab_id := l_estab_id;

   archive_data( p_rubric_name => 'S41.G01.00.005'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_siret_number
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Work Accident Section Code
   IF l_work_section_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_issue_estab_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.025'), null);
   ELSIF l_work_section_code = '98' THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
      'VALUE1:'|| hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.025'), 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.025.M'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
   hr_utility.set_location('S41 l_work_section_code:'||l_work_section_code,112);
   archive_data( p_rubric_name => 'S41.G01.00.025'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_work_section_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   -- Work Accident Risk Code
   IF l_work_risk_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_issue_estab_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.026'), null);
   -- Bug #3756137
   ELSIF length(l_work_risk_code) > 5 then
      l_error_type := l_warning;
      l_value := pay_fr_general.get_payroll_message('PAY_75095_DADS_WORK_ACC_CODE1',
      'VALUE1:'|| l_work_risk_code, null, null);
      l_work_risk_code := substr(l_work_risk_code, 1, 5);
   ELSIF length(l_work_risk_code) < 5 then
      l_error_type := l_warning;
      l_value := pay_fr_general.get_payroll_message('PAY_75096_DADS_WORK_ACC_CODE2',
      'VALUE1:'|| l_work_risk_code, null, null);
   -- Bug #3756137
   ELSIF l_work_risk_code = '98888' THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75191_INCOMPAT_DATA',
      'VALUE1:'|| hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.026'), 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.025.M'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
   begin
   -- Bug #3756137
   if l_work_risk_code in ('98888', '99999') then
      archive_data( p_rubric_name => 'S41.G01.00.026'
                  ,p_message_type => l_error_type
                  ,p_id => p_org_id
                  ,p_lookup_type => 'FR_DADS_WORK_ACC_RISK_CODE'
                  ,p_file_value => l_work_risk_code
                  ,p_message_text => l_value
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_mandatory);
   else
      archive_data( p_rubric_name => 'S41.G01.00.026'
                  ,p_message_type => l_error_type
                  ,p_id => p_org_id
                  ,p_lookup_type => 'FR_WORK_ACCIDENT_RISK_CODE'
                  ,p_file_value => l_work_risk_code
                  ,p_message_text => l_value
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_mandatory);
   end if;
   -- Bug #3756137
   Exception
   When Others then
     hr_utility.set_location('S41 FR_WORK_ACCIDENT_RISK_CODE Failed:'||sqlerrm,1112);
   end;

   -- Office Work Accident Code
   IF l_work_office_code is not null AND l_work_office_code <> 'B' THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
      'VALUE1:'||l_issue_estab_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.027.M'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;

  Begin
    archive_data( p_rubric_name => 'S41.G01.00.027'
                   ,p_message_type => l_error_type
                   ,p_id => p_org_id
                   ,p_lookup_type => 'FR_DADS_OFFICE_WA_CODE'
                   ,p_file_value => l_work_office_code
                   ,p_message_text => l_value
                   ,p_id2 => l_id2
                   ,p_rubric_type => l_conditional);

  Exception
   When Others then
     hr_utility.set_location('S41 FR_DADS_OFFICE_WA_CODE Failed:'||sqlerrm,1112);
  end;

   -- Work Accident Rate
   IF l_work_acc_rate is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_issue_estab_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.028'), null);
    ELSE
      l_error_type := null;
      l_value := null;
    END IF;
   archive_data( p_rubric_name => 'S41.G01.00.028'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => NULL
                ,p_file_value => l_work_acc_rate
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

 --
 --Query to fetch code for Multiple employers
 -- Query for multiple employers
 --Item:S41.G01.00.008
 For get_emp_rec in get_multi_emp(l_effective_date)
 Loop
  l_element_entry_id := get_emp_rec.element_entry_id;
 End Loop;

 If l_element_entry_id Is Not Null Then
    l_multi_employr_code := '02';
 Else
    l_multi_employr_code := '03';
 End If;
 --Need to be edited for exceptions report validation
-- Multiple Employers Code
IF l_multi_employr_code is null THEN
   l_error_type := l_error;
   l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
   'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.008'),
   null, null);
ELSE
   l_error_type := null;
   l_value := null;
END IF;
 Begin

 archive_data( p_rubric_name => 'S41.G01.00.008'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_MULTIPLE_EMPLOYER_CODE'
                ,p_file_value => l_multi_employr_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
  Exception
   When Others then
     hr_utility.set_location('S41 FR_DADS_MULTIPLE_EMPLOYER_CODE Failed:'||sqlerrm,1112);
  end;

--
 -- Positive Offset
 --Item:S41.G01.00.009
 l_positive_offset := '01';
  IF l_positive_offset is null THEN
    l_error_type := l_error;
    l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
    'VALUE1:'||hr_general.decode_lookup('FR_DADS_RUBRICS','S41.G01.00.009'),
    null, null);
ELSE
   l_error_type := null;
   l_value := null;
END IF;

 begin
  archive_data( p_rubric_name => 'S41.G01.00.009'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_POSITIVE_OFFSET'
                ,p_file_value => l_positive_offset
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

  Exception
  When Others then
     hr_utility.set_location('S41 FR_DADS_POSITIVE_OFFSET Failed:'||sqlerrm,1112);
  end;
  hr_utility.set_location('S41 FR_DADS_POSITIVE_OFFSET Inserted',113);
 --
 --Job Nature and INSCEE PCS Code
 --Item:S41.G01.00.010 --following the same as Assedic Attestation Report
 --Item:S41.G01.00.011 --Open Issue, Now following the same as Assedic Attestation Report
 --Work Contract Code and Professtional Status Code
 --Item:S41.G01.00.012
 --Item:S41.G01.00.014
 --Employee Number
 --Item:S41.G01.00.019
    l_first_row := True;
    Begin
     For l_date_trk_41_rec In fetch_date_trk_41(l_effective_date)
     Loop
      Exit when fetch_date_trk_41%NotFound;
      If l_first_row = True Then
       l_job_name := l_date_trk_41_rec.job_name ;
       /* Bug #3815632 */
       l_job_id   := l_date_trk_41_rec.job_id;
       l_job_definition_id   := l_date_trk_41_rec.job_definition_id;
       if l_job_definition_id is not null then
          l_job_name := per_fr_report_utilities.get_job_names
                                                (p_job_id => l_job_id,
                                                 p_job_definition_id => l_job_definition_id,
						 p_report_name => 'DADS');
       end if;
       /* Bug #3815632 */
       l_pcs_code := l_date_trk_41_rec.pcs_code;
       l_contract_type := l_date_trk_41_rec.contract_type;
       --
       l_contract_type_1 := l_date_trk_41_rec.contract_type_1;
       --
       l_prof_code := l_date_trk_41_rec.prof_status_code;
       l_border_worker := l_date_trk_41_rec.border_worker;
       l_detache := l_date_trk_41_rec.detache;
       l_act_type := l_date_trk_41_rec.act_type;
       l_person_number := l_date_trk_41_rec.person_number;
       -- modified for time analysis
       l_norm_hours := l_date_trk_41_rec.norm_asg_hours;
       l_frequency := l_date_trk_41_rec.asg_frequency;
       l_ctr_frequency := l_date_trk_41_rec.ctr_frequency;
       l_norm_ctr_hours := l_date_trk_41_rec.norm_ctr_hours;
       l_ctr_units      := l_date_trk_41_rec.ctr_units;
       --
       l_employment_cat := l_date_trk_41_rec.emp_cat;
       l_emp_full_name := l_date_trk_41_rec.name;
       l_col_aggr_code := l_date_trk_41_rec.col_aggr_code;
       l_first_row := False;
      End if;
     End loop;
   Exception
   When Others Then
      hr_utility.set_location('S41 fetch_date_trk_41 Failed:'||sqlerrm,11011);
   End;

 --Need to be edited for exceptions report validation
  -- Job Nature
   IF l_job_name is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.010'), null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S41.G01.00.010'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => NULL
                ,p_file_value => l_job_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

  hr_utility.set_location('S41 l_job_name:'||l_job_name,113);
   -- Category Code
   IF l_job_name is not null AND l_pcs_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_job_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.011.M'), null);
   ELSE
   --3311942 call the procedure to get the valid pcs code
      per_fr_d2_pkg. get_pcs_code (p_report_qualifier  => 'DADS'
                                  ,p_job_name          => l_job_name
				  ,p_pcs_code          => l_pcs_code
				  ,p_effective_date    => l_effective_date);
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S41.G01.00.011'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type =>  NULL
                ,p_file_value => l_pcs_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   hr_utility.set_location('S41 l_pcs_code:'||l_pcs_code,113);
   -- Work Contract Code
   IF l_contract_type is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.012'), null, null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S41.G01.00.012'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type =>  'FR_DADS_WORK_CONTRACT_CODE'
                ,p_file_value => l_contract_type
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

     hr_utility.set_location('S41 l_contract_type:'||l_contract_type,113);
   -- Professional Status Code
   IF l_prof_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
      'VALUE1:'||l_emp_full_name, 'VALUE2:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.014'), null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S41.G01.00.014'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_PROF_STATUS_CODE'
                ,p_file_value => l_prof_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

   hr_utility.set_location('S41 l_prof_code:'||l_prof_code,113);
   archive_data( p_rubric_name => 'S41.G01.00.019'
                   ,p_message_type => NULL
                   ,p_id => p_org_id
                   ,p_lookup_type => Null
                   ,p_file_value => l_person_number
                   ,p_message_text => Null
                   ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);

   hr_utility.set_location('S41 l_person_number:'||l_person_number,113);
 --
 l_act_typ_val := NULL;
 --Activity Type Code
 --Item:S41.G01.00.013
 hr_utility.set_location('S41 l_employment_cat:'||l_employment_cat,113);
-- If ((l_employment_cat is not null) and (l_employment_cat <> '06')) Then
 If ((l_employment_cat is not null) and (l_contract_type_1 <> 'SEASONAL')) Then
   Begin
    l_act_typ_val := hruserdt.get_table_value (g_param_business_group_id,
                                               'FR_CIPDZ',
                                               'CIPDZ' ,
                                               l_employment_cat,
                                               l_effective_date);
   Exception
   When Others then
     hr_utility.set_location('S41 l_act_typ_val Failed:'||sqlerrm,1115);
  end;


   IF substr(l_act_typ_val,1,1) = 'C' Then
      l_act_typ_code := '01';
   --Bug#3344918
   Elsif  substr(l_act_typ_val,1,1) = 'P' Then
      l_act_typ_code := '02';
   Elsif  substr(l_act_typ_val,1,1) = 'I' Then
      l_act_typ_code := '04';
   Elsif  substr(l_act_typ_val,1,1) = 'D' Then
      l_act_typ_code := '05';
   Else
      l_act_typ_code := '03';
   End If;
-- Elsif l_employment_cat = '06' Then
 Elsif l_contract_type_1 = 'SEASONAL' Then
   l_act_typ_code := '06';
 hr_utility.set_location('S41 l_act_typ_code:'||l_act_typ_code,113);
 End If;
  -- #3553847 previously the validation was there within the above if statement.  Now, it has been taken down.
    -- Activity Type Code
   IF l_act_typ_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.013'), null, null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
 --

    archive_data( p_rubric_name => 'S41.G01.00.013'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_ACTIVITY_TYPE_CODE'
                ,p_file_value => l_act_typ_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
 --
 -- Added for time analysis
  If l_ctr_units = 'HOUR' Then
     l_frequency := l_ctr_frequency;
     l_norm_hours := fnd_number.canonical_to_number(l_norm_ctr_hours);
  End If;
 --
 --Percentage Part Time
 --Item:S41.G01.00.020
 If (l_act_typ_val Is not Null And substr(l_act_typ_val,1,1) = 'P') Then

    If l_frequency <> 'M' Then
    l_emp_month_hours := PAY_FR_GENERAL.convert_hours(p_effective_date => l_effective_date
                             ,p_business_group_id => g_param_business_group_id
                             ,p_assignment_id  => l_assignment_id
                             ,p_hours          => l_norm_hours
                             ,p_from_freq_code => l_frequency
                             ,p_to_freq_code   => 'M');
   Else
   l_emp_month_hours := l_norm_hours;
   End If;
   -- #3542081
   l_percentage_part_time := round((l_emp_month_hours/l_estab_monthly_hours) * 10000);
 End If;

 -- #3553872 previously the validation was there within the above if statement.  Now, it has been taken down.
 -- Percentage of Part Time
 IF l_act_typ_code = '02' AND l_percentage_part_time is null THEN
    l_error_type := l_error;
    l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
    'VALUE1:'||hr_general.decode_lookup
    ('FR_DADS_RUBRICS','S41.G01.00.020'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;

 archive_data( p_rubric_name => 'S41.G01.00.020'
                  ,p_message_type => l_error_type
                  ,p_id => p_org_id
                  ,p_lookup_type => NULL
                  ,p_file_value => l_percentage_part_time
                  ,p_message_text => l_value
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);
    hr_utility.set_location('S41 l_percentage_part_time:'||l_percentage_part_time,113);
 --
 --Employee Category Code
 --Item:S41.G01.00.015


  For i in fetch_pension_info(l_effective_date)
  Loop
  l_first_row := True;
  Exit When fetch_pension_info%NotFound;
   If l_first_row = True Then
    l_pension_info := i.pension_info;
    l_first_row := False;
   End If;
  End Loop;


  Begin
  l_pen_agirc_val := hruserdt.get_table_value (g_param_business_group_id,
                                             'FR_APEC_AGIRC',
                                             'AGIRC' ,
                                              l_pension_info,
                                              l_effective_date);
  Exception
   When Others then
     hr_utility.set_location('S41 FR_APEC_AGIRC Failed:'||sqlerrm,1113);
  end;


  If l_pen_agirc_val = 'Y' Then
    If l_pension_info = '222' Then -- Article 36
       l_emp_cat_code := '02';
    Else
       l_emp_cat_code := '01';
    End If;
  Else
    l_emp_cat_code := '04';
  End If;

   -- Employee Category Code
   IF l_emp_cat_code is null THEN
      l_error_type := l_error;
      l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
      'VALUE1:'||hr_general.decode_lookup
      ('FR_DADS_RUBRICS','S41.G01.00.015'), null, null);
   ELSE
      l_error_type := null;
      l_value := null;
   END IF;
   archive_data( p_rubric_name => 'S41.G01.00.015'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_EMP_CAT_CODE'
                ,p_file_value => l_emp_cat_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

  hr_utility.set_location('S41 l_emp_cat_code:'||l_emp_cat_code,114);
 --Collective Agreement Code
 --Item:S41.G01.00.016
 --Hard code it to 301

   archive_data( p_rubric_name => 'S41.G01.00.016'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_col_aggr_code
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  hr_utility.set_location('S41 l_collective_aggremenet_code:'||l_col_aggr_code,114);
 --

 -- get the PER application ID
 --
 open csr_get_per_id;
 fetch csr_get_per_id into l_per_id;
 close csr_get_per_id;
 --


 --Conventional Classfication
 --Item:S41.G01.00.017
 --Need to confirm
 --
 -- Conventional Classification

  l_conventional_classification := Null;

  For i in csr_fetch_conv_class( l_assignment_id
                                ,l_effective_date
                                ,l_per_id)
  Loop
   If i.qualifier = 'COEFFICIENT' Then
    l_conventional_classification := i.conv_classfication;
   End If;
  End Loop;


   IF l_conventional_classification Is Null Then
    l_value := null;
    archive_data( p_rubric_name => 'S41.G01.00.017'
                 ,p_message_type => l_error_type
                 ,p_id => p_org_id
                 ,p_lookup_type => 'FR_DADS_CAGR_CONV_CLASS'
                 ,p_file_value => '01'
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_mandatory);
  Else
    archive_data( p_rubric_name => 'S41.G01.00.017'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_conventional_classification
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);
  End If;

 --Basic Pension
 --Item:S41.G01.00.018
 --Hard code it to 200

 l_pension_code := 200;

 -- Basic Pension Organisation Code

 IF l_pension_code is null THEN
    l_error_type := l_error;
    l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
    'VALUE1:'||hr_general.decode_lookup
    ('FR_DADS_RUBRICS','S41.G01.00.018'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;
 archive_data( p_rubric_name => 'S41.G01.00.018'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_pension_code)
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

  hr_utility.set_location('S41 to_char(l_pension_code):'||to_char(l_pension_code),114);
  -- #3542645 border worker will be 1 if border worker value is Yes or 2 when detache has some value
  IF l_border_worker = 'Y' THEN
     l_border_worker := '01';
  ELSIF l_detache IS NOT NULL THEN
     l_border_worker := '02';
  ELSE
     l_border_worker := NULL;
  END IF;
-- Code for Work Abroad
IF l_border_worker <> '01' AND l_border_worker <> '02' AND l_border_worker is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
       'VALUE1:'||l_issue_estab_name, 'VALUE2: '||hr_general.decode_lookup
         ('FR_DADS_RUBRICS','S41.G01.00.034.M'), null);
END IF;

 archive_data( p_rubric_name => 'S41.G01.00.034'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_WORK_CODE'
                ,p_file_value => l_border_worker
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
 --
  hr_utility.set_location('S41 l_border_worker:'||l_border_worker,114);
  --
  -- Time Analysis Changes
  -- Item ID :   S41.G01.00.021
  l_num_hrs := fr_rolling_balance_pro (p_assignment_id ,
                                           'FR_ACTUAL_HRS_WORKED_DADSU',
                                           l_param_start_date,
                                          l_effective_date);

  l_value := Null;
  archive_data( p_rubric_name => 'S41.G01.00.021'
               ,p_message_type => l_error_type
               ,p_id => p_org_id
               ,p_lookup_type => Null
               ,p_file_value => l_num_hrs
               ,p_message_text => l_value
               ,p_id2 => l_id2
               ,p_rubric_type => l_conditional);
  --
  -- Item ID :   S41.G01.00.022
  l_num_hrs_emp := fr_rolling_balance_pro (p_assignment_id ,
                                           'FR_CONTRACTUAL_HRS_DADSU',
                                           l_param_start_date,
                                          l_effective_date);

  archive_data( p_rubric_name => 'S41.G01.00.022'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_num_hrs_emp
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
  --
  -- Item ID :   S41.G01.00.023
  hr_utility.set_location('p_assignment_id'||p_assignment_id, 22);
  hr_utility.set_location('l_param_start_date'||l_param_start_date, 22);
  hr_utility.set_location('l_effective_date'||l_effective_date, 22);
  hr_utility.set_location('l_act_dt'||l_act_dt, 22);
  --
  l_num_hrs_latest :=  fr_rolling_balance_pro
                        (p_assignment_id ,
                        'FR_HOURS_PAID_DADSU',
                        l_param_start_date,
                        l_effective_date);

  hr_utility.set_location('l_num_hrs_latest'||l_num_hrs_latest, 22);

  -- need to find the last month where l_num_hrs_latest>= 60
  -- if the person has resigned or l_num_hrs_latest < 1200
  if (l_num_hrs_latest < 1200)  or (l_act_dt < l_effective_date) then
     hr_utility.set_location('Find latest month', 22);
     /* 4172068 checking whether a record exists in fnd_sessions table */
     select count(session_id)
       into l_session_id
       from fnd_sessions
      where session_id = userenv('sessionid');
     if l_session_id > 0 then
        -- find the SMIC rate
        l_hourly_smic_rate := to_number(pay_balance_pkg.run_db_item('FR_HOURLY_SMIC_RATE', null, 'FR'));
     else
        /* 4172068 insert a record only if there is no record exists in fnd_sessions table */
        -- insert a row into fnd_sessions for the DBI value to be retrieved
        Insert into fnd_sessions (session_id, effective_date) values(userenv('sessionid'), sysdate);
        -- find the SMIC rate
        l_hourly_smic_rate := to_number(pay_balance_pkg.run_db_item('FR_HOURLY_SMIC_RATE', null, 'FR'));
        -- delete the row from fnd_sessions
        Delete from fnd_sessions where session_id = userenv('sessionid');
     end if;
     /* 4172068 */
     --
     For i in csr_get_per_dates(l_effective_date)
     Loop
       l_num_hrs_latest :=  fr_rolling_balance_pro
                              (p_assignment_id ,
                              'FR_HOURS_PAID_DADSU',
                              i.start_date,
                              i.end_date);
       l_023_ss_base := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_BASE',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_BASE_RETRO',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_disabled_base := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_DISABLED_BASE',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_disabled_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_DISABLED_BASE_RETRO',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_excess_base := fr_rolling_balance_pro (p_assignment_id,
                                                'FR_SS_EXCESS_BASE',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_part_time_base := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_PART_TIME_BASE',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_part_time_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_PART_TIME_BASE_RETRO',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_apprenticeship_base := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_APPRENTICESHIP_BASE',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_base_above_smic := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_BASE_ABOVE_SMIC',
                                                i.start_date,
                                                i.end_date);

       l_023_ss_base_above_smic_retro := fr_rolling_balance_pro (p_assignment_id ,
                                                'FR_SS_BASE_ABOVE_SMIC_RETRO',
                                                i.start_date,
                                                i.end_date);
       l_023_gross_sbase_sec    := l_023_ss_base + l_023_ss_base_retro + l_023_ss_disabled_base
                                 + l_023_ss_disabled_base_retro + l_023_ss_excess_base
                                 + l_023_ss_part_time_base + l_023_ss_part_time_base_retro
			         + l_023_ss_apprenticeship_base + l_023_ss_base_above_smic
			         + l_023_ss_base_above_smic_retro;

       If (l_num_hrs_latest >= 60)
           or (l_023_gross_sbase_sec > (l_hourly_smic_rate * 60)) then
         l_mth_023 := to_char(i.end_date, 'MM');
       End If;
     End Loop;
  else
     hr_utility.set_location('Latest month is null', 22);
     l_mth_023 := null;
  end if;
  hr_utility.set_location('l_mth_023: '||l_mth_023, 22);
  archive_data( p_rubric_name => 'S41.G01.00.023'
               ,p_message_type => l_error_type
               ,p_id => p_org_id
               ,p_lookup_type => Null
               ,p_file_value => l_mth_023
               ,p_message_text => l_value
               ,p_id2 => l_id2
               ,p_rubric_type => l_conditional);

  -- end of Time analysis changes
  --
  -- Item ID :   S41.G01.00.029

  l_ss_base := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_BASE_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_disabled_base := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_DISABLED_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_disabled_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_DISABLED_BASE_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_excess_base := fr_rolling_balance_pro (p_assignment_id,
                                         'FR_SS_EXCESS_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_part_time_base := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_PART_TIME_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_part_time_base_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_PART_TIME_BASE_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_apprenticeship_base := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_APPRENTICESHIP_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_base_above_smic := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_BASE_ABOVE_SMIC',
                                         l_param_start_date,
                                         l_effective_date);

  l_ss_base_above_smic_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SS_BASE_ABOVE_SMIC_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.030.001

  l_ta_ss_band := fr_rolling_balance_pro(p_assignment_id ,
                                         'FR_TA_SS_BAND',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_band_retro := fr_rolling_balance_pro(p_assignment_id ,
                                         'FR_TA_SS_BAND_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_disabled_band := fr_rolling_balance_pro(p_assignment_id ,
                                         'FR_TA_SS_DISABLED_BAND',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_disabled_band_retro := fr_rolling_balance_pro(p_assignment_id ,
                                         'FR_TA_SS_DISABLED_BAND_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_part_time_band := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TA_SS_PART_TIME_BAND',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_part_time_band_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TA_SS_PART_TIME_BAND_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_band_under_limit := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TA_SS_BAND_UNDER_LIMIT',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_band_under_limit_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TA_SS_BAND_UNDER_LIMIT_RETRO',
                                         l_param_start_date,
                                         l_effective_date);

  l_ta_ss_band_above_smic_retro := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TA_SS_BAND_ABOVE_SMIC_RETRO',
                                         l_param_start_date,
                                         l_effective_date);


  -- Item ID :   S41.G01.00.032.001
 --Changed it as per bug#3297601
  l_subject_to_csg                    := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_CSG_BASE',
                                         l_param_start_date,
                                         l_effective_date);

 --Changed it as per bug#3297601
  l_subject_to_csg_excess             := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_CSG_EXCESS_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.033.001

 --Changed it as per bug#3297601
  l_subject_to_crds                  := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_CRDS_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.035.001

 --Changed it as per bug#3279601
  l_subject_to_salary_tax             := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SALARY_TAX_BASE',
                                         l_param_start_date,
                                         l_effective_date);

 --Changed it as per bug#3279601
  l_subject_to_salary_tax_excess      := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_SALARY_TAX_EXCESS_BASE',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.038

  l_benefit_food                      := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_BENEFIT_FOOD',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.039

  l_benefit_housing                   := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_BENEFIT_HOUSING',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.040

  l_benefit_car                       := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_BENEFIT_CAR',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.041

  l_benefit_other                     := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_BENEFIT_OTHER',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.045

  l_prof_expense_lump_sums            := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_PROF_EXPENSE_LUMP_SUMS',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.046
  l_actual_prof_expenses              := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_ACTUAL_PROF_EXPENSES',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.047

  l_prof_exp_pd_by_comp       := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_PROF_EXPENSES_PD_BY_COMPANY',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.048
  l_reimb_nprof_exp   := fr_rolling_balance_pro (p_assignment_id  ,
                                         'FR_REIMBURSEMENT_NON_PROF_EXPENSES',
                                         l_param_start_date,
                                         l_effective_date);

  -- Item ID :   S41.G01.00.063.001
  l_taxable_income                    := fr_rolling_balance_pro (p_assignment_id ,
                                         'FR_TAXABLE_INCOME',
                                         l_param_start_date,
                                         l_effective_date);

  hr_utility.set_location('S41 After Rolling_Balance calculation:',115);

  -- #3587152 Subject to Social Security balances has been converted to Social Security balances
  l_gross_sbase_sec    := l_ss_base + l_ss_base_retro + l_ss_disabled_base + l_ss_disabled_base_retro
                                       + l_ss_excess_base + l_ss_part_time_base + l_ss_part_time_base_retro
				       + l_ss_apprenticeship_base + l_ss_base_above_smic + l_ss_base_above_smic_retro;

  hr_utility.set_location('S41 l_gross_sbase_sec:'||l_gross_sbase_sec,116);
   -- Gross Social Security Base
  IF l_gross_sbase_sec Is Null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.029.001'), null, null);
  ELSIF l_gross_sbase_sec < 0 THEN
     l_gross_sbase_sec_sign := 'N';
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.029.001'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;
  archive_data( p_rubric_name => 'S41.G01.00.029.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_gross_sbase_sec, '9999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);


  -- Item ID :   S41.G01.00.029.002
     -- Sign
     IF l_gross_sbase_sec_sign <> 'N' AND l_gross_sbase_sec_sign is not null THEN
        l_error_type := l_error;
    	l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
	     'VALUE1:', 'VALUE2: '||hr_general.decode_lookup
             	('FR_DADS_RUBRICS','S41.G01.00.029.002.M'), null);
     ELSE
	    l_error_type := null;
        l_value := null;
     END IF;

     archive_data( p_rubric_name => 'S41.G01.00.029.002'
                     ,p_message_type => l_error_type
                     ,p_id => p_org_id
                     ,p_lookup_type => Null
                     ,p_file_value => l_gross_sbase_sec_sign
                     ,p_message_text => l_value
                     ,p_id2 => l_id2
                     ,p_rubric_type => l_conditional);

  -- #3587152 Additional balances are added to the given calculation
  l_cap_ssec_base := l_ta_ss_band + l_ta_ss_band_retro + l_ta_ss_disabled_band + l_ta_ss_disabled_band_retro
                                  + l_ta_ss_part_time_band + l_ta_ss_part_time_band_retro + l_ta_ss_band_under_limit
				  + l_ta_ss_band_under_limit_retro + l_ta_ss_band_above_smic_retro;

  -- Capped Social Secuirty Base
  IF l_cap_ssec_base is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.030.001'), null, null);
  ELSIF l_cap_ssec_base < 0 THEN
     l_cap_ssec_base_sign := 'N';
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.030.001'), null, null);
  ELSE
    l_error_type := null;
    l_value := null;
  END IF;
  archive_data( p_rubric_name => 'S41.G01.00.030.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_cap_ssec_base, '9999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

-- Item ID :   S41.G01.00.030.002
    -- Sign
     IF l_cap_ssec_base_sign <> 'N' AND l_cap_ssec_base_sign is not null THEN
        l_error_type := l_error;
    	l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
	        'VALUE1:', 'VALUE2: '||hr_general.decode_lookup
           	('FR_DADS_RUBRICS','S41.G01.00.029.002.M'), null);
     ELSE
     	l_error_type := null;
    	l_value := null;
    END IF;

    archive_data( p_rubric_name => 'S41.G01.00.030.002'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_cap_ssec_base_sign
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  -- CSG Base
 l_csg_base := l_subject_to_csg + l_subject_to_csg_excess;
  IF l_csg_base is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.032.001'), null, null);
  ELSIF l_csg_base < 0 THEN
     l_csg_base_sign := 'N';
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.032.001'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;
  l_csg_base := l_subject_to_csg + l_subject_to_csg_excess;

  archive_data( p_rubric_name => 'S41.G01.00.032.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_csg_base, '9999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

-- Item ID :   S41.G01.00.032.002

    -- Sign
     IF l_csg_base_sign <> 'N' AND l_csg_base_sign is not null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
	'VALUE1:', 'VALUE2: '||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S41.G01.00.029.002.M'), null);
      ELSE
	l_error_type := null;
	l_value := null;
      END IF;
        archive_data( p_rubric_name => 'S41.G01.00.032.002'
                     ,p_message_type => l_error_type
                     ,p_id => p_org_id
                     ,p_lookup_type => Null
                     ,p_file_value => l_csg_base_sign
                     ,p_message_text => l_value
                     ,p_id2 => l_id2
                     ,p_rubric_type => l_conditional);

  -- #3587152 CRDS Base does includes FR_CSG_EXCESS_BASE also
    l_subject_to_crds := l_subject_to_crds + l_subject_to_csg_excess;

  -- CRDS Base
  IF l_subject_to_crds is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.033.001'), null, null);
  ELSIF l_subject_to_crds < 0 THEN
     l_subject_to_crds_sign := 'N';
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.033.001'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;
  archive_data( p_rubric_name => 'S41.G01.00.033.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_subject_to_crds, '9999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);


-- Item ID :   S41.G01.00.033.002
     -- Sign
     IF l_subject_to_crds_sign <> 'N' AND l_subject_to_crds_sign is not null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
	'VALUE1:', 'VALUE2: '||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S41.G01.00.029.002.M'), null);
      ELSE
	l_error_type := null;
	l_value := null;
      END IF;
     archive_data( p_rubric_name => 'S41.G01.00.033.002'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_subject_to_crds_sign
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  -- Fiscal Base
  l_fiscal_base := l_subject_to_salary_tax +l_subject_to_salary_tax_excess;
  IF l_fiscal_base is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.035.001'), null, null);
  ELSIF l_fiscal_base < 0 THEN
     l_fiscal_base_sign := 'N';
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.035.001'), null, null);
 ELSE
    l_error_type := null;
    l_value := null;
 END IF;

  archive_data( p_rubric_name => 'S41.G01.00.035.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_fiscal_base, '9999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

-- Item ID :   S41.G01.00.035.002
     -- Sign
     IF l_fiscal_base_sign <> 'N' AND l_fiscal_base_sign is not null THEN
        l_error_type := l_error;
	l_value := pay_fr_general.get_payroll_message('PAY_75192_VALID_VAL',
	'VALUE1:', 'VALUE2: '||hr_general.decode_lookup
	('FR_DADS_RUBRICS','S41.G01.00.029.002.M'), null);
      ELSE
	l_error_type := null;
	l_value := null;
      END IF;

     archive_data( p_rubric_name => 'S41.G01.00.035.002'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_fiscal_base_sign
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

-- Item ID :   S41.G01.00.038

  IF l_benefit_food > 0 THEN
     l_benefit_food_sign := 'N';
     archive_data( p_rubric_name => 'S41.G01.00.038'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_FRINGE_BENEFITS'
                ,p_file_value => l_benefit_food_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
  END IF;

-- Item ID :   S41.G01.00.039

  IF l_benefit_housing > 0 THEN
     l_benefit_housing_sign := 'L';
     archive_data( p_rubric_name => 'S41.G01.00.039'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_FRINGE_BENEFITS'
                ,p_file_value => l_benefit_housing_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
  END IF;

-- Item ID :   S41.G01.00.040

  IF l_benefit_car > 0 THEN
    l_benefit_car_sign := 'V';
    archive_data( p_rubric_name => 'S41.G01.00.040'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_FRINGE_BENEFITS'
                ,p_file_value => l_benefit_car_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

-- Item ID :   S41.G01.00.041

  IF l_benefit_other > 0 THEN
    l_benefit_other_sign := 'A';
    archive_data( p_rubric_name => 'S41.G01.00.041'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_FRINGE_BENEFITS'
                ,p_file_value => l_benefit_other_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

-- Item ID :   S41.G01.00.037.001

l_fringe_benefits  := l_benefit_food + l_benefit_housing + l_benefit_car
+ l_benefit_other;

  IF (l_fringe_benefits <> 0
       And l_fringe_benefits Is Not Null) THEN
    archive_data( p_rubric_name => 'S41.G01.00.037.001'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => NULL
                ,p_file_value => to_char(l_fringe_benefits, '9999999990D99')
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
   END IF;

-- Item ID :   S41.G01.00.037.002

  IF l_fringe_benefits < 0 THEN
     l_fringe_benefits_sign := 'N';
     archive_data( p_rubric_name => 'S41.G01.00.037.002'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_fringe_benefits_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

-- Item ID :   S41.G01.00.045

  IF l_prof_expense_lump_sums > 0 THEN
     l_prof_expense_lump_sums_sign := 'F';
     archive_data( p_rubric_name => 'S41.G01.00.045'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_PROF_EXPENSE'
                ,p_file_value => l_prof_expense_lump_sums_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

-- Item ID :   S41.G01.00.046

  IF l_actual_prof_expenses > 0  THEN
     l_actual_prof_expenses_sign := 'R';
     archive_data( p_rubric_name => 'S41.G01.00.046'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_PROF_EXPENSE'
                ,p_file_value => l_actual_prof_expenses_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

-- Item ID :   S41.G01.00.047

  IF l_prof_exp_pd_by_comp > 0 THEN
     l_prof_exp_pd_by_comp_sign := 'P';
     archive_data( p_rubric_name => 'S41.G01.00.047'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_PROF_EXPENSE'
                ,p_file_value => l_prof_exp_pd_by_comp_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

  -- Item ID :   S41.G01.00.048

  IF l_reimb_nprof_exp > 0 THEN
     l_reimb_nprof_exp_sign := 'D';
     archive_data( p_rubric_name => 'S41.G01.00.048'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => 'FR_DADS_PROF_EXPENSE'
                ,p_file_value => l_reimb_nprof_exp_sign
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

  END IF;

  -- Item ID :   S41.G01.00.044

  l_professional_expenses := l_prof_expense_lump_sums + l_actual_prof_expenses +
                              l_prof_exp_pd_by_comp +l_reimb_nprof_exp;

  IF (l_professional_expenses <> 0
       And l_professional_expenses Is Not Null) THEN
    archive_data( p_rubric_name => 'S41.G01.00.044'
                  ,p_message_type => NULL
                  ,p_id => p_org_id
                  ,p_lookup_type => Null
                  ,p_file_value => to_char(l_professional_expenses, '99999999990D99')
                  ,p_message_text => Null
                  ,p_id2 => l_id2
                  ,p_rubric_type => l_conditional);
  END IF;

  -- Item ID :   S41.G01.00.063.001
  -- Activity Salary
  IF l_taxable_income is null THEN
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
     'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
     'S41.G01.00.063.001'), null, null);
  ELSIF l_taxable_income_sign = 'N' THEN
     l_error_type := l_warning;
     l_value := pay_fr_general.get_payroll_message('PAY_75188_VAL_NEG',
     'VALUE1:'||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.063.001'), null, null);
  ELSE
    l_error_type := null;
    l_value := null;
  END IF;
  archive_data( p_rubric_name => 'S41.G01.00.063.001'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => to_char(l_taxable_income, '99999999990D99')
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);


  IF l_asg_location is null THEN
     -- #3553797 Added employee full name in the token.  Previously assignment establishment name was there in the token.
     l_error_type := l_error;
     l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
     'VALUE1:'||l_emp_full_name, 'VALUE2: '||hr_general.decode_lookup
     ('FR_DADS_RUBRICS','S41.G01.00.060.006.M'), null);
     archive_data( p_rubric_name => 'S41.G01.00.060.006'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => null
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);
  ELSE
-- Have commented because there is specific validation when both the locations are not equal
--  ELSIf (l_asg_location Is not Null And l_est_location <> l_asg_location) Then
  --Cursor for get location details of assignment--
     Open csr_asg_loc(l_asg_location);
     Fetch csr_asg_loc Into l_csr_asg_loc;
     Close csr_asg_loc;
     --Checking whether both the locations are equal or not
     If l_asg_location Is not Null Then
               --Complement
            archive_data( p_rubric_name => 'S41.G01.00.060.001'
                          ,p_message_type => NULL
                          ,p_id => p_org_id
                          ,p_lookup_type => Null
                          ,p_file_value => l_csr_asg_loc.complement
                          ,p_message_text => Null
                          ,p_id2 => l_id2
                          ,p_rubric_type => l_conditional);

	     -- Nature and name of the street
	     IF ((l_est_location <> l_asg_location) AND l_csr_asg_loc.street_name is null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
		'VALUE1:'||l_location_name, 'VALUE2:'||hr_general.decode_lookup
		('FR_DADS_RUBRICS','S41.G01.00.060.006'), null);
             ELSIF ((l_est_location = l_asg_location) AND l_csr_asg_loc.street_name is not null) THEN
	        l_error_type := l_error;
	        l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.006'), null, null);
	      ELSE
		l_error_type := null;
		l_value := null;
	      END IF;
     --Nature and name of street
     archive_data( p_rubric_name => 'S41.G01.00.060.006'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_csr_asg_loc.street_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

     --INSEE Code of Town
     archive_data( p_rubric_name => 'S41.G01.00.060.007'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_csr_asg_loc.insee_code
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

     --Name of the town
	     IF ((l_est_location = l_asg_location) AND l_csr_asg_loc.small_town is not null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.009'), null, null);
	     ELSIF ((l_est_location <> l_asg_location)
	          AND upper(l_csr_asg_loc.small_town) = upper(l_csr_asg_loc.town)) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75179_TWN_CITY',
		null, null, null);
	      ELSE
		l_error_type := null;
		l_value := null;
	      END IF;
     archive_data( p_rubric_name => 'S41.G01.00.060.009'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_csr_asg_loc.small_town
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

     --Zip Code
	     IF ((l_est_location <> l_asg_location) AND l_csr_asg_loc.zip_code is null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
		'VALUE1:'||l_location_name, 'VALUE2:'||hr_general.decode_lookup
		('FR_DADS_RUBRICS','S41.G01.00.060.010'), null);
	     ELSIF ((l_est_location = l_asg_location) AND l_csr_asg_loc.zip_code is not null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.010'), null, null);
	      ELSE
		l_error_type := null;
		l_value := null;
	      END IF;
     archive_data( p_rubric_name => 'S41.G01.00.060.010'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_csr_asg_loc.zip_code
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_mandatory);

      --Town
	     IF ((l_est_location <> l_asg_location) AND l_csr_asg_loc.town is null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75178_NO_DATA',
		'VALUE1:'||l_location_name, 'VALUE2:'||hr_general.decode_lookup
		('FR_DADS_RUBRICS','S41.G01.00.060.012'), null);
	     ELSIF ((l_est_location <> l_asg_location)
	            AND l_csr_asg_loc.town <> upper(l_csr_asg_loc.town)) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75177_CITY_UPR',
		null, null, null);
	     ELSIF ((l_est_location = l_asg_location) AND l_csr_asg_loc.town is not null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.012'), null, null);
	      ELSE
		l_error_type := null;
		l_value := null;
	      END IF;
       archive_data(p_rubric_name => 'S41.G01.00.060.012'
                 ,p_message_type => l_error_type
                 ,p_id => p_org_id
                 ,p_lookup_type => Null
                 ,p_file_value => l_csr_asg_loc.town
                 ,p_message_text => l_value
                 ,p_id2 => l_id2
                 ,p_rubric_type => l_mandatory);

     --Country Code
/*	     -- Country Code
	     IF ((l_est_location = l_asg_location) AND l_country_code is not null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.013'), null, null);
	     ELSIF ((l_est_location <> l_asg_location) AND l_country_code = 'FR') THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
		'VALUE1: '||hr_general.decode_lookup
		('FR_DADS_RUBRICS','S41.G01.00.060.013'), null, null);
	      ELSE
		l_error_type := null;
		l_value := null;
	      END IF;--COMMENT*/
     archive_data( p_rubric_name => 'S41.G01.00.060.013'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => Null
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

     --Country Name
	     IF ((l_est_location = l_asg_location) AND l_csr_asg_loc.country_name is not null) THEN
	        l_error_type := l_error;
		l_value := pay_fr_general.get_payroll_message('PAY_75180_OMIT_VAL',
		'VALUE1: '||hr_general.decode_lookup ('FR_DADS_RUBRICS',
		'S41.G01.00.060.014'), null, null);
	     ELSIF (l_est_location <> l_asg_location) THEN
	         IF l_csr_asg_loc.country_name is not null and l_country_code = 'FR' THEN
		    l_error_type := l_error;
		    l_value := pay_fr_general.get_payroll_message('PAY_75175_COUN_FRN',
		    'VALUE1: '||hr_general.decode_lookup
		    ('FR_DADS_RUBRICS','S41.G01.00.060.014'), null, null);
		 ELSIF l_csr_asg_loc.country_name is null AND l_country_code is not null
		     AND l_csr_asg_loc.country_code <> 'FR' THEN
		    l_error_type := l_error;
		    l_value := pay_fr_general.get_payroll_message('PAY_75174_NOT_FOUND',
		    'VALUE1:'||hr_general.decode_lookup
		    ('FR_DADS_RUBRICS','S41.G01.00.060.014'), null, null);
	         ELSE
   		    l_error_type := null;
		    l_value := null;
		 END IF;
	     END IF;
     archive_data( p_rubric_name => 'S41.G01.00.060.014'
                ,p_message_type => l_error_type
                ,p_id => p_org_id
                ,p_lookup_type => Null
                ,p_file_value => l_csr_asg_loc.country_name
                ,p_message_text => l_value
                ,p_id2 => l_id2
                ,p_rubric_type => l_conditional);

     --Total Address
     archive_data( p_rubric_name => 'S41.G01.00.060.015'
                ,p_message_type => NULL
                ,p_id => p_org_id
                ,p_lookup_type => Null  --Item:S41.G01.00.019
                ,p_file_value => NULL
                ,p_message_text => Null
                ,p_id2 => l_id2
                ,p_rubric_type => l_optional);
     END IF;
  End If;

     hr_utility.set_location('SAI S41 Leaving S41',116);
     hr_utility.set_location('S41 Reason end_reason:'||l_hist(l_counter).end_reason,50);
     hr_utility.set_location('S41 Reason end_date:'||l_hist(l_counter).end_date,50);
     hr_utility.set_location('S41 Reason start_reason:'||l_hist(l_counter).start_reason,51);
     hr_utility.set_location('S41 Reason start_date:'||l_hist(l_counter).start_date,52);
   End if;
    l_counter := l_hist.NEXT(l_counter);
  END LOOP;
 Exception
 when others then
  hr_utility.set_location('S41 Reason Codes:'||SQLERRM,109);
 End;
 l_hist.DELETE;
 hr_utility.set_location('S41 XXXXX Reached the end of the personid:'||p_person_id,7777);
Exception
When others then
  hr_utility.set_location('S41 sqlerrm:'||sqlerrm,1111);
  l_hist.DELETE;
  Raise;

END execS41_G01_00;
--

--

Function fr_rolling_balance_pro (p_assignment_id in number,
                                 p_balance_name in varchar2,
                                 p_balance_start_date in date,
                                 p_balance_end_date in date) return number
IS
Cursor csr_pro_def_bal_id IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
   WHERE  pdb.balance_type_id = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
   AND    pbt.balance_name = p_balance_name
   AND    pbd.database_item_suffix = '_ASG_PRO_RUN'
   AND    pdb.legislation_code = 'FR';
--
--
Cursor get_assign_actions IS
select ppa.payroll_action_id,
       nvl(paa_pro.end_date, ppa.date_earned) date_earned,
       to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                            paa.assignment_action_id),16)) assignment_action_id
from  pay_assignment_actions paa,
      pay_assignment_actions paa_pro,
      pay_payroll_actions    ppa
where paa.assignment_id = p_assignment_id
  and paa_pro.assignment_action_id (+) = paa.source_action_id
  and paa_pro.end_date(+) is not null
  and paa.end_date is null
  and ppa.payroll_action_id = paa.payroll_action_id
  and ppa.action_status = 'C'
  /* exclude reversal results and reversed run results */
  and ppa.action_type In ('R', 'Q', 'I')
  and NOT EXISTS
       (SELECT NULL
        FROM pay_payroll_actions     RPACT
        ,    pay_assignment_actions  RASSACT
        ,    pay_action_interlocks   RINTLK
        where paa.assignment_action_id = RINTLK.locked_action_id
        and   RINTLK.locking_action_id = RASSACT.assignment_action_id
        and   RPACT.payroll_action_id = RASSACT.payroll_action_id
        and   RPACT.action_type = 'V')
  and ((paa_pro.end_date between p_balance_start_date and p_balance_end_date)
     or (paa_pro.end_date is null and
         ppa.date_earned between p_balance_start_date and p_balance_end_date))
  and (ppa.action_type = 'I' or paa.source_action_id is not null)
group by ppa.payroll_action_id, nvl(paa_pro.end_date, ppa.date_earned);

l_defined_balance_id number;
l_value number;
l_proc  varchar2(72);

BEGIN
l_value := 0;
l_proc  := g_package||'.fr_rolling_balance';
   hr_utility.set_location('Entering:'|| l_proc,10);
   open csr_pro_def_bal_id;
   fetch csr_pro_def_bal_id into l_defined_balance_id;
   close csr_pro_def_bal_id;
   --
   For get_assign_rec In get_assign_actions
   Loop
     Begin
        l_value := l_value +pay_balance_pkg.get_value(p_defined_balance_id => l_defined_balance_id
                                                     ,p_assignment_action_id => get_assign_rec.assignment_action_id);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         l_value := 0;
       END;
       hr_utility.set_location(' BAL VAL='||l_value, 60);
     end loop;
     hr_utility.set_location(' FINAL BAL VAL='||l_value, 60);
   hr_utility.set_location(' Leaving:'||l_proc, 70);
   return l_value;

END fr_rolling_balance_pro ;

PROCEDURE archive_data(p_rubric_name       VARCHAR2,
                       p_message_type      VARCHAR2,
                       p_id                NUMBER,
                       p_lookup_type       VARCHAR2,
                       p_file_value        VARCHAR2,
                       p_message_text      VARCHAR2,
                       p_id2               VARCHAR2,
                       p_rubric_type       VARCHAR2) IS
   l_user_value     Varchar2(100);
   l_file_value     Varchar2(100);
   l_action_info_id        pay_action_information.action_information_id%TYPE;
   l_ovn                   pay_action_information.object_version_number%TYPE;
begin

 hr_utility.set_location('p_message_type:'||p_message_type,1234);
 If p_message_type IS NULL Then
  hr_utility.set_location('p_message_type1:'||p_message_type,1234);
    hr_utility.set_location('archive_data:'||p_rubric_name,555);
    l_file_value := p_file_value;
    hr_utility.set_location('l_file_value:'||l_file_value,555);
    If p_lookup_type Is Not Null Then
      l_user_value := hr_general.decode_lookup(p_lookup_type, p_file_value);
      If p_rubric_name = 'S30.G01.00.007' Then
        If l_file_value = 'MR.' Then
          l_file_Value := '01';
        Elsif l_file_value = 'MRS.' Then
          l_file_Value := '02';
        Elsif l_file_value = 'MISS' Then
          l_file_Value := '03';
        End If;
      End if;
    Else
      l_user_value := Null;
    End if;
    hr_utility.set_location('ARCHIVE_DATA:'||l_user_value,555);

    If p_rubric_name = 'S41.G01.00.005' Then
        pay_action_information_api.create_action_information( p_action_information_id       =>  l_action_info_id
                                                      ,p_action_context_id           =>  g_assign_action_id
                                                      ,p_action_context_type         =>  'AAP'
                                                      ,p_object_version_number       =>  l_ovn
                                                      ,p_action_information_category =>  'FR_DADS_FILE_DATA'
                                                      ,p_action_information1         =>  p_rubric_name
                                                      ,p_action_information2         =>  Null
                                                      ,p_action_information3         =>  p_id
                                                      ,p_action_information4         =>  l_file_value
                                                      ,p_action_information5         =>  l_user_value
                                                      ,p_action_information6         =>  Null
                                                      ,p_action_information7         =>  g_param_estab_id
                                                      ,p_action_information8         =>  p_id2
                                                      ,p_action_information9         =>  p_rubric_type);
    Else
       pay_action_information_api.create_action_information( p_action_information_id       =>  l_action_info_id
                                                      ,p_action_context_id           =>  g_assign_action_id
                                                      ,p_action_context_type         =>  'AAP'
                                                      ,p_object_version_number       =>  l_ovn
                                                      ,p_action_information_category =>  'FR_DADS_FILE_DATA'
                                                      ,p_action_information1         =>  p_rubric_name
                                                      ,p_action_information2         =>  Null
                                                      ,p_action_information3         =>  p_id
                                                      ,p_action_information4         =>  l_file_value
                                                      ,p_action_information5         =>  l_user_value
                                                      ,p_action_information6         =>  Null
                                                      ,p_action_information8         =>  p_id2
                                                      ,p_action_information9         =>  p_rubric_type);
  End if;
 Elsif (p_message_type = hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'W'))  Then
     hr_utility.set_location('p_message_type2:'||p_message_type,1234);
       pay_action_information_api.create_action_information( p_action_information_id       =>  l_action_info_id
                                                      ,p_action_context_id           =>  g_assign_action_id
                                                      ,p_action_context_type         =>  'AAP'
                                                      ,p_object_version_number       =>  l_ovn
                                                      ,p_action_information_category =>  'FR_DADS_FILE_DATA'
                                                      ,p_action_information1         =>  p_rubric_name
                                                      ,p_action_information2         =>  p_message_type
                                                      ,p_action_information3         =>  p_id
                                                      ,p_action_information4         =>  p_file_value
                                                      ,p_action_information5         =>  Null
                                                      ,p_action_information6         =>  p_message_text
                                                      ,p_action_information8         =>  p_id2
                                                      ,p_action_information9         =>  p_rubric_type);

 Elsif (p_message_type = hr_general.decode_lookup('FR_DADS_ERROR_TYPE', 'E'))  Then
    hr_utility.set_location('p_message_type3:'||p_message_type,1234);
   pay_action_information_api.create_action_information( p_action_information_id       =>  l_action_info_id
                                                      ,p_action_context_id           =>  g_assign_action_id
                                                      ,p_action_context_type         =>  'AAP'
                                                      ,p_object_version_number       =>  l_ovn
                                                      ,p_action_information_category =>  'FR_DADS_FILE_DATA'
                                                      ,p_action_information1         =>  p_rubric_name
                                                      ,p_action_information2         =>  p_message_type
                                                      ,p_action_information3         =>  p_id
                                                      ,p_action_information4         =>  null
                                                      ,p_action_information5         =>  null
                                                      ,p_action_information6         =>  p_message_text
                                                      ,p_action_information8         =>  p_id2
                                                      ,p_action_information9         =>  p_rubric_type);
 End If;
Exception
When others then
 hr_utility.set_location('ARCHIVE_DATA EXP:'||p_rubric_name||':'||sqlerrm,556);
End archive_data;

--

End PAY_FR_DADS_EMP_PKG;

/
