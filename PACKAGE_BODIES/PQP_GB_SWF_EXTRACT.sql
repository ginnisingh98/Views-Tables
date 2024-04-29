--------------------------------------------------------
--  DDL for Package Body PQP_GB_SWF_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_SWF_EXTRACT" AS
/* $Header: pqpgbswfex.pkb 120.0.12010000.20 2019/03/18 07:45:00 anmosing noship $ */

/*
   Data Return Type
   ----------------

-- Bug#12586059

   -- TYPE1A Single File for LA   (LEA_<LEA number>.<req_id>)
   -- TYPE1B Multiple File for LA (EST_<EST number>.<req_id>,...)
   TYPE1 Single File for LA   (LEA_<LEA number>.<req_id>)

-- Bug#12586059

   TYPE2  Single File for EST  (EST_<EST number>.<req_id>)
   TYPE3  Single File for LA   (LEA_<LEA number>.<req_id>)
   TYPE4  Single File for LA   (LEA_<LEA number>.<req_id>)

   Person Category
   ---------------
   1- Regular Teacher
   2- Agency Teacher
   3- Teaching Assistant
   4- Other Support Staff

*/

g_package    constant varchar2(20):= 'PQP_GB_SWF_EXTRACT.';

-- Parameters
g_census_year   number;
g_request_id    pay_payroll_actions.request_id%type;
g_output_dir    varchar2(400);
g_serial_number number;

-- Process Details
g_payroll_action_id  pay_payroll_actions.payroll_action_id%type;
g_census_date        date;
g_lea_number         number;
g_data_return_type   varchar2(10);
g_estab_number       varchar2(10);
g_exclude_absence    varchar2(3);
g_exclude_qual       varchar2(3);
g_iana_char_set      varchar2(30);
g_file_handle        utl_file.file_type;

-- LA Educational Psychologists Count
g_edu_psy_ft varchar2(100);
g_edu_psy_pt varchar2(100);
g_edu_psy_fte varchar2(100);

PROCEDURE WRITE_LINE(p_tag_type varchar2,p_tag_name varchar2,p_tag_value varchar2) AS
   l_proc constant varchar2(100):= g_package||'WRITE_LINE';
   l_data pay_action_information.action_information1%type;
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   IF p_tag_type = 'O' THEN -- Open Tag
      l_data:='<'||p_tag_name||'>';
      hr_utility.set_location('Writing : '||l_data,2);
   ELSIF p_tag_type = 'C' THEN -- Close Tag
      l_data:='</'||p_tag_name||'>';
      hr_utility.set_location('Writing : '||l_data,3);
   ELSIF p_tag_type = 'D' THEN -- Data Tag
      -- If the value is null do not display the tag
      IF (p_tag_value is null OR trim(p_tag_value) ='') THEN
         return;
         hr_utility.set_location(p_tag_name||' Value is null',4);
      END IF;
      -- Replace special characters with XML equivalents
      l_data := REPLACE (p_tag_value, '&', '&amp;');
      l_data := REPLACE (l_data, '<', '&lt;');
      l_data := REPLACE (l_data, '>', '&gt;');
      l_data := REPLACE (l_data, '''', '&apos;');
      l_data := REPLACE (l_data, '"', '&quot;');
      l_data:='<'||p_tag_name||'>'||l_data||'</'||p_tag_name||'>';

      hr_utility.set_location('Writing : '||l_data,5);
   END IF;

   utl_file.put_line(g_file_handle, l_data);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_LINE;

PROCEDURE PREPARE_FILE(p_lea_or_est_num number) AS
   l_file_name varchar2(50);
   l_proc    constant varchar2(100):= g_package||'PREPARE_FILE';
BEGIN
   hr_utility.trace('Entering: '||l_proc);

-- Bug#12586059

   -- IF g_data_return_type in ('TYPE1A','TYPE3','TYPE4') THEN
   IF g_data_return_type in ('TYPE1','TYPE3','TYPE4') THEN

-- Bug#12586059

      l_file_name := 'LEA_'||p_lea_or_est_num||'.'||g_request_id;

   ELSE
      l_file_name := 'EST_'||p_lea_or_est_num||'.'||g_request_id;
   END IF;
   g_file_handle := utl_file.fopen (g_output_dir ,l_file_name,'w');
   FND_FILE.PUT_LINE(fnd_file.log,'');
   FND_FILE.PUT_LINE(fnd_file.log,'Writing File:'||l_file_name);
   utl_file.put_line(g_file_handle, '<?xml version="1.0" encoding="'||g_iana_char_set||'"?>');
   WRITE_LINE('O','Message',null);

   hr_utility.trace('Leaving: '||l_proc);
END PREPARE_FILE;

PROCEDURE CLOSE_FILE AS
   l_proc constant varchar2(100):= g_package||'CLOSE_FILE';
BEGIN
   hr_utility.trace('Entering: '||l_proc);
   WRITE_LINE('C','Message',null);
   utl_file.fclose (g_file_handle);
   hr_utility.trace('Leaving: '||l_proc);
END CLOSE_FILE;

PROCEDURE WRITE_HEADER(p_est_number number) AS
   l_proc constant varchar2(100):= g_package||'WRITE_HEADER';

    cursor c_arc_pkg_version is
    select afv.version
      from ad_files af,
           ad_file_versions afv
     where af.file_id = afv.file_id
       and af.app_short_name = 'PQP'
       and af.subdir = 'patch/115/sql'
       and af.filename = 'pqpgbswfar.pkb'
  order by afv.file_version_id desc;

  l_version varchar2(100);

BEGIN
   hr_utility.trace('Entering: '||l_proc);

   WRITE_LINE('O','Header',null);
   WRITE_LINE('O','CollectionDetails',null);
   WRITE_LINE('D','Collection','School Workforce Census');
   -- WRITE_LINE('D','Term','AUT'); /* Bug#12856844 */
   WRITE_LINE('D','Year',g_census_year);
   WRITE_LINE('D','ReferenceDate',to_char(g_census_date,'YYYY-MM-DD'));
   WRITE_LINE('C','CollectionDetails',null);
   WRITE_LINE('O','Source',null);
   WRITE_LINE('D','SourceLevel','L');
   WRITE_LINE('D','LEA',g_lea_number);
   WRITE_LINE('D','Estab',p_est_number);
   WRITE_LINE('D','SoftwareCode','Oracle HRMS');
   open c_arc_pkg_version;
   fetch c_arc_pkg_version into l_version;
   close c_arc_pkg_version;
   WRITE_LINE('D','Release',l_version);
   WRITE_LINE('D','SerialNo',g_serial_number);
   WRITE_LINE('D','DateTime',to_char(sysdate,'YYYY-MM-DD')||'T'||to_char(sysdate,'HH:MM:SS'));
   WRITE_LINE('C','Source',null);
  /* WRITE_LINE('O','Content',null);
   WRITE_LINE('O','CBDSLevels',null);
   IF g_data_return_type <> 'TYPE4' THEN
      WRITE_LINE('D','CBDSLevel','Workforce');
   END IF;
   IF g_data_return_type = 'TYPE4' THEN
      WRITE_LINE('D','CBDSLevel','LA');
   END IF;
   WRITE_LINE('C','CBDSLevels',null);
   WRITE_LINE('C','Content',null);*/
   WRITE_LINE('C','Header',null);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_HEADER;

PROCEDURE WRITE_STAFF_DETAILS(p_person_id pay_action_information.action_information1%type,
                              p_person_category number)
AS
    cursor c_staff_details is
    select pai.action_information3 teacher_number,
           pai.action_information4 family_name,
           pai.action_information5 given_name,
           pai.action_information6 former_family_name,
           pai.action_information7 ni_number,
           pai.action_information8 gender,
           pai.action_information9 date_of_birth,
           pai.action_information10 ethnicity,
           pai.action_information11 disability,
           max(pai.action_information12)over() QTStatus,
           max(pai.action_information13)over() HLTAStatus,
           max(pai.action_information14)over() QTSRoute
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_STAFF_DETAILS'
       and pai.action_information1 = p_person_id;

   l_proc constant varchar2(100):= g_package||'WRITE_STAFF_DETAILS';
   l_HLTA_Status   varchar2(10);
   l_QT_Status     varchar2(10); -- Bug#12586059
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   FOR l_staff_rec in c_staff_details LOOP
      WRITE_LINE('O','StaffDetails',null);
      WRITE_LINE('D','TeacherNumber',l_staff_rec.teacher_number);
      WRITE_LINE('O','StaffMemberName',null);
      WRITE_LINE('D','PersonFamilyName',l_staff_rec.family_name);
      WRITE_LINE('O','GivenNames',null);
      WRITE_LINE('O','GivenName',null);
      WRITE_LINE('D','PersonGivenName',l_staff_rec.given_name);
      WRITE_LINE('C','GivenName',null);
      WRITE_LINE('C','GivenNames',null);
      WRITE_LINE('C','StaffMemberName',null);
      IF (p_person_category in (1,3)) THEN
         WRITE_LINE('O','FormerFamilyNames',null);
         WRITE_LINE('D','PersonFamilyName',l_staff_rec.former_family_name);
         WRITE_LINE('C','FormerFamilyNames',null);
      END IF;
      WRITE_LINE('D','NINumber',l_staff_rec.ni_number);
      WRITE_LINE('D','GenderCurrent',l_staff_rec.gender);
      WRITE_LINE('D','PersonBirthDate',l_staff_rec.date_of_birth);
      WRITE_LINE('D','Ethnicity',l_staff_rec.ethnicity);
      WRITE_LINE('D','Disability',l_staff_rec.disability);
      IF (p_person_category in (1,2,3)) THEN

-- Bug#12586059

	-- QT Status value changed from Yes/No to True/False
        --  WRITE_LINE('D','QTStatus',l_staff_rec.QTStatus);

      /*     Select decode(l_staff_rec.QTStatus,'Yes','True','No','False',null)
           into l_QT_Status
           from dual;

           WRITE_LINE('D','QTStatus',l_QT_Status);*/
if (l_staff_rec.QTStatus = 'N') then
						 WRITE_LINE('D','QTS','false');
elsif (l_staff_rec.QTStatus = 'Y') then
						 WRITE_LINE('D','QTS','true');
elsif (l_staff_rec.QTStatus = 'QTLSN') then
					   WRITE_LINE('D','QTLS','false');
elsif (l_staff_rec.QTStatus = 'QTLSY') then
					   WRITE_LINE('D','QTLS','true');
elsif (l_staff_rec.QTStatus = 'EYTSN') then
						 WRITE_LINE('D','EYTS','false');
elsif (l_staff_rec.QTStatus = 'EYTSY') then
						 WRITE_LINE('D','EYTS','true');
end if;
hr_utility.trace('l_staff_rec.QTStatus: '||l_staff_rec.QTStatus);

-- Bug#12586059

      END IF;
      IF (p_person_category in (1,3,4)) THEN
         --Fix for bug#9773083
	 --WRITE_LINE('D','HLTAStatus',l_staff_rec.HLTAStatus);
         --Fix for bug#9773083
   Select decode(l_staff_rec.HLTAStatus,'Yes','True','No','False',null)
          into l_HLTA_Status
   from dual;
	 WRITE_LINE('D','HLTAStatus',l_HLTA_Status);
      END IF;
      IF (p_person_category in (1,2)) THEN
         WRITE_LINE('D','QTSRoute',l_staff_rec.QTSRoute);
      END IF;
      WRITE_LINE('C','StaffDetails',null);
      EXIT; -- Do not want to display staff multiple times
   END LOOP;

   hr_utility.trace('Entering: '||l_proc);
END WRITE_STAFF_DETAILS;

PROCEDURE WRITE_CONTRACT_DETAILS(p_est_number pay_action_information.action_information11%type,
                                 p_person_id pay_action_information.action_information1%type,
                                 p_person_category number) AS

    cursor c_contract_details is
    select pai.assignment_id assignment_id,
           pai.action_information2 contract_type,
           pai.action_information3 contract_st_date,
           pai.action_information4 contract_end_date,
           pai.action_information5 post,
           pai.action_information6 arrival_date,
           pai.action_information7 daily_rate,
           pai.action_information8 destination,
           pai.action_information9 origin,
           pai.action_information10 la_school_level,
           pai.action_information11 est_number,
	   pai.action_information16 leaving_reason,
	   pai.action_information15 pay_review_date
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_CONTRACT_DETAILS'
       and pai.action_information1 = p_person_id
       and pai.action_information11 = nvl(p_est_number,pai.action_information11);

    cursor c_payment_details(cp_assignment_id pay_action_information.assignment_id%type) is
    select pai.action_information1 pay_scale,
           pai.action_information2 regional_pay_spine,
          -- pai.action_information3 spine_point,
		  pai.action_information3 salary_rate,
           pai.action_information4 minm_value,
		   pai.action_information5 maxm_value,
           pai.action_information6 safeguarded_salary,
		   pai.action_information15 pay_framework
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_PAYMENT_DETAILS'
       and pai.assignment_id = cp_assignment_id;

    cursor c_add_payment_details(cp_assignment_id pay_action_information.assignment_id%type) is
    select pai.action_information1 cat_of_add_payment,
           pai.action_information2 add_payment_amt,
           pai.action_information3 pay_start_date,
           pai.action_information4 pay_end_date
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_ADD_PAYMENT_DETAILS'
       and pai.assignment_id = cp_assignment_id;

    cursor c_hours_details(cp_assignment_id pay_action_information.assignment_id%type) is
    select pai.action_information1 hours_worked_per_week,
           pai.action_information2 fte_hours_per_week,
           pai.action_information3 weeks_per_year
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_HOURS_DETAILS'
       and pai.assignment_id = cp_assignment_id;

    cursor c_role_details(cp_assignment_id pay_action_information.assignment_id%type) is
    select pai.action_information1 role_identifier
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
       and pai.assignment_id = cp_assignment_id;

   l_proc constant varchar2(100):= g_package||'WRITE_CONTRACT_DETAILS';
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   WRITE_LINE('O','ContractOrServiceGroup',null);
   FOR l_contract_rec in c_contract_details LOOP
      WRITE_LINE('O','ContractOrService',null);
      WRITE_LINE('D','ContractType',l_contract_rec.contract_type);
      WRITE_LINE('D','ContractStart',l_contract_rec.contract_st_date);
      WRITE_LINE('D','ContractEnd',l_contract_rec.contract_end_date);
      WRITE_LINE('D','Post',l_contract_rec.post);
      IF (p_person_category in (1,2,3)) THEN
         WRITE_LINE('D','SchoolArrivalDate',l_contract_rec.arrival_date);
      END IF;
-- Bug 12906657
     -- IF (p_person_category in (2,3)) THEN
      IF (p_person_category = 2) THEN
-- Bug 12906657
         WRITE_LINE('D','DailyRate',l_contract_rec.daily_rate);
      END IF;
      IF (p_person_category in (1,2)) THEN
         WRITE_LINE('D','DestinationCode',l_contract_rec.destination);
      END IF;
      IF (p_person_category in (1,3)) THEN
         WRITE_LINE('D','Origin',l_contract_rec.origin);
      END IF;
WRITE_LINE('D','LeavingReason',l_contract_rec.leaving_reason);
	     WRITE_LINE('D','PayReviewDate',l_contract_rec.pay_review_date);
      WRITE_LINE('D','LASchoolLevel',l_contract_rec.la_school_level);
      -- WRITE_LINE('D','Estab',l_contract_rec.est_number);

         -- Start PostLevelDetails
         WRITE_LINE('O','PostLevelDetails',null);
         FOR l_payment_rec in c_payment_details(l_contract_rec.assignment_id) LOOP
            WRITE_LINE('O','Payments',null);
            IF (p_person_category in (1,2,3)) THEN
                WRITE_LINE('D','PayRange',l_payment_rec.pay_scale);
            END IF;
            /*IF (p_person_category in (1,2)) THEN
               WRITE_LINE('D','RegionPayRange',l_payment_rec.regional_pay_spine);
            END IF;*/
          /*  IF (p_person_category in (1,2)) THEN
               WRITE_LINE('D','SpinePoint',l_payment_rec.spine_point);
            END IF;  */
               	WRITE_LINE('D','PayFramework',l_payment_rec.pay_framework);
                WRITE_LINE('D','PayRangeMinimum',l_payment_rec.minm_value);
  				WRITE_LINE('D','PayRangeMaximum',l_payment_rec.maxm_value);
            IF (p_person_category in (1,2,3,4)) THEN

-- Bug#10106993

	      -- WRITE_LINE('D','SalaryAmount',l_payment_rec.salary_rate);
          --WRITE_LINE('D','TotalPay',l_payment_rec.salary_rate);
		    WRITE_LINE('D','BasePay',l_payment_rec.salary_rate);

-- Bug#10106993

	    END IF;
            IF (p_person_category in (1)) THEN
               WRITE_LINE('D','SafeguardedSalary',l_payment_rec.safeguarded_salary);
            END IF;
            WRITE_LINE('C','Payments',null);
         END LOOP;

         IF (p_person_category in (1,2,3)) THEN
             WRITE_LINE('O','AdditionalPayments',null);
             FOR l_add_payment_rec in c_add_payment_details(l_contract_rec.assignment_id) LOOP
                WRITE_LINE('O','AdditionalPayment',null);
                WRITE_LINE('D','PaymentType',l_add_payment_rec.cat_of_add_payment);
                WRITE_LINE('D','PaymentAmount',l_add_payment_rec.add_payment_amt);
               if l_add_payment_rec.cat_of_add_payment = 'TL3' then
                WRITE_LINE('D','PayStartDate',l_add_payment_rec.pay_start_date);
                WRITE_LINE('D','PayEndDate',l_add_payment_rec.pay_end_date);
              end if;
                WRITE_LINE('C','AdditionalPayment',null);
             END LOOP;
             WRITE_LINE('C','AdditionalPayments',null);
         END IF;

         IF (p_person_category in (1,2,3,4)) THEN
             FOR l_hours_rec in c_hours_details(l_contract_rec.assignment_id) LOOP
                WRITE_LINE('O','Hours',null);
                WRITE_LINE('D','HoursPerWeek',l_hours_rec.hours_worked_per_week);
                WRITE_LINE('D','FTEHours',l_hours_rec.fte_hours_per_week);
                WRITE_LINE('D','WeeksPerYear',l_hours_rec.weeks_per_year);
                WRITE_LINE('C','Hours',null);
             END LOOP;
         END IF;

         WRITE_LINE('C','PostLevelDetails',null);
         -- End PostLevelDetails

         -- Start Roles
         WRITE_LINE('O','Roles',null);
         FOR l_role_rec in c_role_details(l_contract_rec.assignment_id) LOOP
            WRITE_LINE('O','Role',null);
            WRITE_LINE('D','RoleIdentifier',l_role_rec.role_identifier);
            WRITE_LINE('C','Role',null);
         END LOOP;
         WRITE_LINE('C','Roles',null);
         -- End Roles

         WRITE_LINE('C','ContractOrService',null);
   END LOOP;
   WRITE_LINE('C','ContractOrServiceGroup',null);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_CONTRACT_DETAILS;

PROCEDURE WRITE_ABS_DETAILS(p_est_number pay_action_information.action_information6%type,
                            p_person_id pay_action_information.action_information1%type) AS

    cursor c_abs_details is
    select pai.action_information2 first_day,
           pai.action_information3 last_day,
           pai.action_information4 working_days_lost,
           pai.action_information5 abs_catagory,
           pai.action_information6 est_number
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_ABS_DETAILS'
       and pai.action_information1 = p_person_id
       and pai.action_information6 = nvl(p_est_number,pai.action_information6);

   l_proc constant varchar2(100):= g_package||'WRITE_ABS_DETAILS';
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   WRITE_LINE('O','Absences',null);
   FOR l_abs_rec in c_abs_details LOOP
      WRITE_LINE('O','Absence',null);
      WRITE_LINE('D','FirstDayOfAbsence',l_abs_rec.first_day);
      WRITE_LINE('D','LastDayOfAbsence',l_abs_rec.last_day);
      WRITE_LINE('D','WorkingDaysLost',l_abs_rec.working_days_lost);
      WRITE_LINE('D','AbsenceCategory',l_abs_rec.abs_catagory);
   --   WRITE_LINE('D','Estab',l_abs_rec.est_number);
      WRITE_LINE('C','Absence',null);
   END LOOP;
   WRITE_LINE('C','Absences',null);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_ABS_DETAILS;

PROCEDURE WRITE_QUAL_DETAILS(p_est_number pay_action_information.action_information6%type,
                             p_person_id pay_action_information.action_information1%type) AS


    cursor c_qual_details is
    select pai.action_information2 qual_code,
 -- Bug 12906657
           -- pai.action_information3 qual_verified,
           -- pai.action_information4 qual_subject1,
           -- pai.action_information5 qual_subject2,
           pai.action_information5 qual_verified,
	   pai.action_information3 qual_subject1,
	   pai.action_information4 qual_subject2,
	   pai.action_information7 class_of_deg, -- Bug 17063828
-- Bug 12906657
           pai.action_information6 est_number
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_QUAL_DETAILS'
       and pai.action_information1 = p_person_id
       and pai.action_information6 = nvl(p_est_number,pai.action_information6);

   l_proc constant varchar2(100):= g_package||'WRITE_QUAL_DETAILS';
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   WRITE_LINE('O','Qualifications',null);
   FOR l_qual_rec in c_qual_details LOOP
      WRITE_LINE('O','Qualification',null);
      WRITE_LINE('D','QualificationCode',l_qual_rec.qual_code);
	  WRITE_LINE('D','ClassOfDegree',l_qual_rec.class_of_deg);
      WRITE_LINE('O','Subjects',null);
if l_qual_rec.qual_subject1 is not null then
      WRITE_LINE('D','QualificationSubject',l_qual_rec.qual_subject1);
end if;
if l_qual_rec.qual_subject2 is not null then
     /* WRITE_LINE('C','Subjects',null);
      WRITE_LINE('O','Subjects',null);*/
      WRITE_LINE('D','QualificationSubject',l_qual_rec.qual_subject2);
end if;
      WRITE_LINE('C','Subjects',null);
-- Commented out for Bug#10106993
      -- WRITE_LINE('D','QualVerified',l_qual_rec.qual_verified);
-- Bug#10106993
   --   WRITE_LINE('D','Estab',l_qual_rec.est_number);
      WRITE_LINE('C','Qualification',null);
    END LOOP;
    WRITE_LINE('C','Qualifications',null);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_QUAL_DETAILS;

PROCEDURE WRITE_LA AS

   cursor c_edu_psy_ft is
   select COUNT(*) edu_psy_ft
     from pay_action_information pai,
          pay_assignment_actions paa
    where paa.payroll_action_id = g_payroll_action_id
      and paa.assignment_action_id = pai.action_context_id
      and pai.action_context_type = 'AAP'
      and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
      and pai.action_information1 = 'EPSY'
      and pai.action_information2 = 'F';

   cursor c_edu_psy_pt is
   select COUNT(*) edu_psy_pt
     from pay_action_information pai,
          pay_assignment_actions paa
    where paa.payroll_action_id = g_payroll_action_id
      and paa.assignment_action_id = pai.action_context_id
      and pai.action_context_type = 'AAP'
      and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
      and pai.action_information1 = 'EPSY'
      and pai.action_information2 = 'P';

   cursor c_edu_psy_fte is
   select sum(round(nvl(pai2.action_information7,0),1)) edu_psy_fte
     from pay_action_information pai,
          pay_action_information pai2,
          pay_assignment_actions paa
    where paa.payroll_action_id = g_payroll_action_id
      and paa.assignment_action_id = pai.action_context_id
      and pai.action_context_id = pai2.action_context_id
      and pai.action_information_category = 'GB_SWF_ROLE_DETAILS'
      and pai2.action_information_category = 'GB_SWF_HOURS_DETAILS'
      and pai.action_information1 = 'EPSY'
      and pai.action_information2 = 'P';

   l_proc constant varchar2(100):= g_package||'WRITE_LA';
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   OPEN c_edu_psy_ft;
   FETCH c_edu_psy_ft INTO g_edu_psy_ft;
   CLOSE c_edu_psy_ft;

   OPEN c_edu_psy_pt;
   FETCH c_edu_psy_pt INTO g_edu_psy_pt;
   CLOSE c_edu_psy_pt;

   OPEN c_edu_psy_fte;
   FETCH c_edu_psy_fte INTO g_edu_psy_fte;
   CLOSE c_edu_psy_fte;

   WRITE_LINE('O','LA',null);
   WRITE_LINE('O','EducationalPsychologists',null);
   WRITE_LINE('D','EdPsychsFT',nvl(g_edu_psy_ft,0));
   WRITE_LINE('D','EdPsychsPT',nvl(g_edu_psy_pt,0));
   WRITE_LINE('D','EdPsychsFTE',round(nvl(g_edu_psy_fte,0),1));
   WRITE_LINE('C','EducationalPsychologists',null);
   WRITE_LINE('C','LA',null);

   hr_utility.trace('Leaving: '||l_proc);
END WRITE_LA;

PROCEDURE XML_EXTRACT(errbuf          out nocopy varchar2
                     ,retcode         out nocopy varchar2
                     ,p_census_year   in number
                     ,p_request_id    in number
                     ,p_output_dir    in varchar2
                     ,p_serial_number in number
                     ) AS

    cursor c_process_details is
    select ppa.payroll_action_id
          ,pay_gb_eoy_archive.get_parameter(ppa.legislative_parameters,'LEA_NUM') lea_number
          ,pay_gb_eoy_archive.get_parameter(ppa.legislative_parameters,'CENSUS_DAY') census_date
          ,upper(pay_gb_eoy_archive.get_parameter(ppa.legislative_parameters,'DATA_RETURN_TYPE')) data_return_type
          ,NVL(pay_gb_eoy_archive.get_parameter(ppa.legislative_parameters,'ESTB_NUM'),'All') estab_number
          ,pay_gb_eoy_archive.get_parameter(ppa.legislative_parameters,'EXCLUDE_ABS') exclude_abs
          ,pay_gb_eoy_archive.get_parameter(legislative_parameters,'EXCLUDE_QUAL') exclude_qual
      from pay_payroll_actions ppa
     where ppa.request_id = p_request_id;

    cursor c_all_staff is
    select distinct pai.action_information1 person_id
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_STAFF_DETAILS';

    cursor c_all_eatab is
    select distinct pai.action_information2 est_number
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_STAFF_DETAILS';

    cursor c_estab_staff(cp_est_number pay_action_information.action_information2%type) is
    select distinct pai.action_information1 person_id
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_STAFF_DETAILS'
       and (
             (cp_est_number is null AND pai.action_information2 is null)
              OR
             (cp_est_number is not null AND pai.action_information2 = cp_est_number)
           );

    cursor c_person_category(cp_person_id pay_action_information.action_information1%type) is
    select min(pai.action_information14) person_category
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category = 'GB_SWF_CONTRACT_DETAILS'
       and pai.action_information1 = cp_person_id;

    cursor c_estab_staff_count is
    select pai.action_information2 est_number,
           count(distinct pai.action_information1) staff_count
      from pay_action_information pai,
           pay_assignment_actions paa
     where paa.payroll_action_id = g_payroll_action_id
       and paa.assignment_action_id = pai.action_context_id
       and pai.action_context_type = 'AAP'
       and pai.action_information_category ='GB_SWF_STAFF_DETAILS'
  group by pai.action_information2;

	CURSOR csr_get_utl_file_par IS
	SELECT value from v$parameter
	WHERE name = 'utl_file_dir';

    l_proc    constant varchar2(100):= g_package||'XML_EXTRACT';

    l_person_category number;
    l_estab_count     number:=0;

		l_path_exists boolean := false;
		l_utl_file_path_s VARCHAR2(4000);
		l_single_path_s VARCHAR2(4000);
		path_not_exists EXCEPTION;
		utl_file_dir_not_exists EXCEPTION;
BEGIN
   hr_utility.trace('Entering: '||l_proc);

   FND_FILE.PUT_LINE(fnd_file.log,'');
   FND_FILE.PUT_LINE(fnd_file.log,'Parameters:');
   FND_FILE.PUT_LINE(fnd_file.log,'         Census Year: '|| p_census_year);
   FND_FILE.PUT_LINE(fnd_file.log,'          Request Id: '|| p_request_id);
   FND_FILE.PUT_LINE(fnd_file.log,'          Output Dir: '|| p_output_dir);
   FND_FILE.PUT_LINE(fnd_file.log,'       Serial Number: '|| p_serial_number);

	 --BUG 29192758 - User entered path should exist in utl_file_dir in v$parameter
	 --which ensures that a directory obect is present for the same.
	 OPEN csr_get_utl_file_par;
	 FETCH csr_get_utl_file_par INTO l_utl_file_path_s;

		IF csr_get_utl_file_par%notfound
		THEN
			RAISE utl_file_dir_not_exists;
		END IF;
		CLOSE csr_get_utl_file_par;

		WHILE trim(l_utl_file_path_s) IS NOT NULL
			LOOP
					IF instr(trim(l_utl_file_path_s),',') > 0 THEN
						--Mutiple paths exist in utl_file_dir separated by comma(,)
						l_single_path_s := substrb(l_utl_file_path_s,1,instr(trim(l_utl_file_path_s),',')-1);
						l_utl_file_path_s := trim(substrb(l_utl_file_path_s,instr(trim(l_utl_file_path_s),',')+1));
					ELSE
						--Single path exists in utl_file_dir
						l_single_path_s := trim(l_utl_file_path_s);
						l_utl_file_path_s := '';
					END IF;
					IF l_single_path_s = trim(p_output_dir) THEN
						l_path_exists := true;
						EXIT;
					END IF;
			END LOOP;

	 IF l_path_exists = false THEN
		RAISE path_not_exists;
	 END IF;

   g_census_year := p_census_year;
   g_output_dir := p_output_dir;
   g_request_id := fnd_global.conc_request_id;
   g_serial_number := p_serial_number;

   -- Retrive the Process Details from pay_payroll_actions
   open c_process_details;
   fetch c_process_details into g_payroll_action_id,g_lea_number,g_census_date,
                                g_data_return_type,g_estab_number,g_exclude_absence,g_exclude_qual;
   close c_process_details;

   FND_FILE.PUT_LINE(fnd_file.log,'');
   FND_FILE.PUT_LINE(fnd_file.log,'Process Details:');
   FND_FILE.PUT_LINE(fnd_file.log,'   Payroll Action ID: '|| g_payroll_action_id);
   FND_FILE.PUT_LINE(fnd_file.log,'          LEA Number: '|| g_lea_number);
   FND_FILE.PUT_LINE(fnd_file.log,'         Census Date: '|| g_census_date);
   FND_FILE.PUT_LINE(fnd_file.log,'    Data Return Type: '|| g_data_return_type);

   -- Get IANA Encoding
   g_iana_char_set := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   IF g_iana_char_set is null THEN
      g_iana_char_set:='UTF-8';
   END IF;
   FND_FILE.PUT_LINE(fnd_file.log,'       IANA Encoding: '|| g_iana_char_set);

-- Bug#12586059

   -- IF g_data_return_type in ('TYPE1A','TYPE3','TYPE4') THEN
   IF g_data_return_type in ('TYPE1','TYPE3','TYPE4') THEN

-- Bug#12586059

      PREPARE_FILE(g_lea_number);
      -- Write Header
      WRITE_HEADER(null);

-- Bug#12586059

      -- IF g_data_return_type in ('TYPE1A','TYPE3') THEN
      IF g_data_return_type in ('TYPE1','TYPE3') THEN

-- Bug#12586059

	 -- Write Workforce Details
         WRITE_LINE('O','SchoolWorkforceMembers',null);
         FOR l_staff in c_all_staff LOOP
            WRITE_LINE('O','SchoolWorkforceMember',null);
            -- Find the person category
            OPEN c_person_category(l_staff.person_id);
            FETCH c_person_category into l_person_category;
            CLOSE c_person_category;
            WRITE_STAFF_DETAILS(l_staff.person_id,l_person_category);
            WRITE_CONTRACT_DETAILS(null,l_staff.person_id,l_person_category);
            IF (l_person_category <> 4) THEN
               WRITE_ABS_DETAILS(null,l_staff.person_id);
               WRITE_QUAL_DETAILS(null,l_staff.person_id);
            END IF;
            WRITE_LINE('C','SchoolWorkforceMember',null);
         END LOOP;
         WRITE_LINE('C','SchoolWorkforceMembers',null);
      END IF;
      IF g_data_return_type = 'TYPE4' THEN
         WRITE_LA();
      END IF;
      CLOSE_FILE();

-- Bug#12586059

    --  ELSIF g_data_return_type in ('TYPE1B','TYPE2') THEN
    ELSIF g_data_return_type = 'TYPE2' THEN

-- Bug#12586059

      FOR l_eatab in c_all_eatab LOOP
         PREPARE_FILE(l_eatab.est_number);
         -- Write Header
         WRITE_HEADER(l_eatab.est_number);
         -- Write Workforce Details
         WRITE_LINE('O','SchoolWorkforceMembers',null);
         FOR l_staff in c_estab_staff(l_eatab.est_number) LOOP
            WRITE_LINE('O','SchoolWorkforceMember',null);
            -- Find the person category
            OPEN c_person_category(l_staff.person_id);
            FETCH c_person_category into l_person_category;
            CLOSE c_person_category;
            WRITE_STAFF_DETAILS(l_staff.person_id,l_person_category);
            WRITE_CONTRACT_DETAILS(l_eatab.est_number,l_staff.person_id,l_person_category);
            IF (l_person_category <> 4) THEN
               WRITE_ABS_DETAILS(l_eatab.est_number,l_staff.person_id);
               WRITE_QUAL_DETAILS(l_eatab.est_number,l_staff.person_id);
            END IF;
            WRITE_LINE('C','SchoolWorkforceMember',null);
         END LOOP;
         WRITE_LINE('C','SchoolWorkforceMembers',null);
         CLOSE_FILE();
      END LOOP;
   END IF;

   -- Write Extract Summary
   FND_FILE.PUT_LINE(fnd_file.output,'Process Summary');
   FND_FILE.PUT_LINE(fnd_file.output,'---------------');
   FND_FILE.PUT_LINE(fnd_file.output,'                     Request ID: '|| g_request_id);
   FND_FILE.PUT_LINE(fnd_file.output,'                    Census Year: '|| g_census_year);
   FND_FILE.PUT_LINE(fnd_file.output,'                     LEA Number: '|| g_lea_number);
   FND_FILE.PUT_LINE(fnd_file.output,'               Data Return Type: '|| g_data_return_type);
   FND_FILE.PUT_LINE(fnd_file.output,'           Establishment Number: '|| g_estab_number);
   FND_FILE.PUT_LINE(fnd_file.output,'         Exclude Absence Module: '|| g_exclude_absence);
   FND_FILE.PUT_LINE(fnd_file.output,'   Exclude Qualification Module: '|| g_exclude_qual);
   FND_FILE.PUT_LINE(fnd_file.output,'');
   FND_FILE.PUT_LINE(fnd_file.output,'                     Output Dir: '|| g_output_dir);

-- Bug#12586059

 --  IF g_data_return_type in ('TYPE1A','TYPE3','TYPE4') then
   IF g_data_return_type in ('TYPE1','TYPE3','TYPE4') then

-- Bug#12586059

     FND_FILE.PUT_LINE(fnd_file.output,'                      File Name: '||'LEA_'||g_lea_number||'.'||g_request_id);

-- Bug#12586059

  -- ELSIF g_data_return_type in ('TYPE1B','TYPE2') then
   ELSIF g_data_return_type = 'TYPE2' then

-- Bug#12586059

      FND_FILE.PUT_LINE(fnd_file.output,'                   File Name(s): '||'EST_<estab_number>.'||g_request_id);
   END IF;
   FND_FILE.PUT_LINE(fnd_file.output,'');
   IF (g_data_return_type <> 'TYPE4') THEN
      FND_FILE.PUT_LINE(fnd_file.output,'  Establishement Number     No of Staff Processed');
      FND_FILE.PUT_LINE(fnd_file.output,'  ---------------------     ---------------------');

      FOR l_eatab_staff in c_estab_staff_count LOOP
         l_estab_count := l_estab_count + 1;
         FND_FILE.PUT(fnd_file.output, '                   '|| lpad(l_eatab_staff.est_number,4));
           IF  (l_eatab_staff.est_number is not null) then
              FND_FILE.PUT_LINE(fnd_file.output,'     '||l_eatab_staff.staff_count );
           ELSE
              FND_FILE.PUT_LINE(fnd_file.output,'         '||l_eatab_staff.staff_count );
           END IF;
      END LOOP;
      FND_FILE.PUT_LINE(fnd_file.output,'');
      FND_FILE.PUT_LINE(fnd_file.output,'');
      FND_FILE.PUT_LINE(fnd_file.output,'  Total No of Establishments processed: '|| l_estab_count);
   ELSE
      FND_FILE.PUT_LINE(fnd_file.output,'       Full Time Educational Psychologists Count: '|| nvl(g_edu_psy_ft,0));
      FND_FILE.PUT_LINE(fnd_file.output,'       Part Time Educational Psychologists Count: '|| nvl(g_edu_psy_pt,0));
      FND_FILE.PUT_LINE(fnd_file.output,'  Total FTE- part Time Educational Psychologists: '|| round(nvl(g_edu_psy_fte,0),1));
   END IF;
   hr_utility.trace('Leaving: '||l_proc);

EXCEPTION
	WHEN utl_file_dir_not_exists THEN
		errbuf:='No value exists for utl_file_dir.';
		retcode:=2;

	WHEN path_not_exists THEN
		errbuf:='Output Directory specified is invalid. Please Verify.';
		retcode:=2;

  WHEN utl_file.invalid_path THEN
      errbuf:='Output Directory specified is invalid. Please Verify.';
      retcode:=2;

  WHEN utl_file.invalid_operation THEN
      errbuf:='Unable to open the file in the directory specified';
      retcode:=2;

  WHEN utl_file.write_error THEN
      errbuf:='Unable to write to the file';
      retcode:=2;

   WHEN OTHERS THEN
      errbuf:=SQLERRM;
      retcode:=2;

END XML_EXTRACT;

END PQP_GB_SWF_EXTRACT;

/
