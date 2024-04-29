--------------------------------------------------------
--  DDL for Package Body IRC_SEEKER_VAC_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEEKER_VAC_MATCHING_PKG" 
/* $Header: irjsmtch.pkb 120.8.12010000.9 2010/04/15 13:42:26 avarri ship $ */
AS

-- ----------------------------------------------------------------------------
-- CURSORS
-- ----------------------------------------------------------------------------

-- ***************************************************************************
-- Outer Cursor to find Job Seekers requiring an email (one of three)
-- ***************************************************************************
CURSOR csr_seekers_for_email
       -- If p_send_all_matching_jobs_now is not null, any relevant vacancies
       -- will be sent immediately.
       (p_ignore_seeker_matching_freq IN VARCHAR2 DEFAULT null)
IS
  SELECT inp.person_id
  ,      per.party_id
       , to_number(inp.matching_job_freq) show_jobs_since
       , FND_PROFILE.value_specific('ICX_LANGUAGE',usr.user_id) lang_pref
  FROM  irc_notification_preferences inp
  ,     per_all_people_f per
  ,     fnd_user usr
  WHERE inp.matching_jobs='Y'
  and   per.person_id=inp.person_id
  and   trunc(sysdate) between per.effective_start_date and per.effective_end_date
  AND (mod (trunc(sysdate) - trunc(inp.last_update_date)
             ,to_number (inp.matching_job_freq)) = 0
          OR p_ignore_seeker_matching_freq = 'Y'
        )
  and usr.employee_id = inp.person_id;
-- ***************************************************************************
-- Middle Cursor to get the criteria entered by the Job Seeker (two of three)
-- ***************************************************************************
CURSOR csr_seeker_criteria_for_email
         (p_seeker_details  IN g_seeker_rec_type)
IS
  SELECT isc.search_criteria_id
       , isc.object_id
       , p_seeker_details.party_id party_id
       , isc.distance_to_location
       , isc.geocode_country
       , isc.geocode_location
       , isc.location
       , isc.employee
       , isc.contractor
       , isc.employment_category
       , isc.keywords
       , isc.travel_percentage
       , isc.min_salary
       , isc.salary_currency
       , isc.salary_period
       , isc.match_competence
       , isc.match_qualification
       , isc.job_title
       , isc.department
       , isc.work_at_home
       , isc.attribute1
       , isc.attribute2
       , isc.attribute3
       , isc.attribute4
       , isc.attribute5
       , isc.attribute6
       , isc.attribute7
       , isc.attribute8
       , isc.attribute9
       , isc.attribute10
       , isc.attribute11
       , isc.attribute12
       , isc.attribute13
       , isc.attribute14
       , isc.attribute15
       , isc.attribute16
       , isc.attribute17
       , isc.attribute18
       , isc.attribute19
       , isc.attribute20
       , isc.attribute21
       , isc.attribute22
       , isc.attribute23
       , isc.attribute24
       , isc.attribute25
       , isc.attribute26
       , isc.attribute27
       , isc.attribute28
       , isc.attribute29
       , isc.attribute30
       , isc.isc_information1
       , isc.isc_information2
       , isc.isc_information3
       , isc.isc_information4
       , isc.isc_information5
       , isc.isc_information6
       , isc.isc_information7
       , isc.isc_information8
       , isc.isc_information9
       , isc.isc_information10
       , isc.isc_information11
       , isc.isc_information12
       , isc.isc_information13
       , isc.isc_information14
       , isc.isc_information15
       , isc.isc_information16
       , isc.isc_information17
       , isc.isc_information18
       , isc.isc_information19
       , isc.isc_information20
       , isc.isc_information21
       , isc.isc_information22
       , isc.isc_information23
       , isc.isc_information24
       , isc.isc_information25
       , isc.isc_information26
       , isc.isc_information27
       , isc.isc_information28
       , isc.isc_information29
       , isc.isc_information30
       , isc.geometry
       , isc.location_id
       , p_seeker_details.show_jobs_since
       , per.current_employee_flag
  FROM
         irc_search_criteria isc
      ,  per_all_people_f per
   WHERE isc.object_type in ( 'PERSON' ,'WPREF')
     AND isc.object_id =  p_seeker_details.person_id
     AND isc.use_for_matching = 'Y'
     AND per.person_id=isc.object_id
     AND trunc(sysdate) between per.effective_start_date and per.effective_end_date;

-- ***************************************************************************
-- Outer Cursor to find open vacancies
-- ***************************************************************************
--
CURSOR csr_vacancies_needing_seekers
       (p_ignore_seeker_matching_freq IN VARCHAR2 DEFAULT null)
IS
  SELECT
         isc.search_criteria_id
       , isc.object_id  vacancy_id
       , isc.distance_to_location
       , isc.location
       , isc.employee
       , isc.contractor
       , isc.employment_category
       , isc.keywords
       , isc.travel_percentage
       , isc.max_salary
       , isc.salary_currency
       , isc.salary_period
       , isc.match_competence
       , isc.match_qualification
       , isc.min_qual_level
       , isc.max_qual_level
       , isc.department
       , isc.professional_area
       , isc.work_at_home
       , isc.attribute1
       , isc.attribute2
       , isc.attribute3
       , isc.attribute4
       , isc.attribute5
       , isc.attribute6
       , isc.attribute7
       , isc.attribute8
       , isc.attribute9
       , isc.attribute10
       , isc.attribute11
       , isc.attribute12
       , isc.attribute13
       , isc.attribute14
       , isc.attribute15
       , isc.attribute16
       , isc.attribute17
       , isc.attribute18
       , isc.attribute19
       , isc.attribute20
       , isc.attribute21
       , isc.attribute22
       , isc.attribute23
       , isc.attribute24
       , isc.attribute25
       , isc.attribute26
       , isc.attribute27
       , isc.attribute28
       , isc.attribute29
       , isc.attribute30
       , isc.isc_information1
       , isc.isc_information2
       , isc.isc_information3
       , isc.isc_information4
       , isc.isc_information5
       , isc.isc_information6
       , isc.isc_information7
       , isc.isc_information8
       , isc.isc_information9
       , isc.isc_information10
       , isc.isc_information11
       , isc.isc_information12
       , isc.isc_information13
       , isc.isc_information14
       , isc.isc_information15
       , isc.isc_information16
       , isc.isc_information17
       , isc.isc_information18
       , isc.isc_information19
       , isc.isc_information20
       , isc.isc_information21
       , isc.isc_information22
       , isc.isc_information23
       , isc.isc_information24
       , isc.isc_information25
       , isc.isc_information26
       , isc.isc_information27
       , isc.isc_information28
       , isc.isc_information29
       , isc.isc_information30
       , loc.geometry
       , loc.country
       , vac.location_id
       , loc.derived_locale
       , vac.business_group_id
       , vac.name
       , vac.recruiter_id
       , vac.primary_posting_id
   FROM
        irc_search_criteria     isc
      , per_all_vacancies vac
      , hr_locations_all loc
   WHERE isc.object_type = 'VACANCY'
     AND isc.object_id = vac.vacancy_id
     AND vac.location_id = loc.location_id (+)
     AND vac.status='APPROVED'
     -- we can only send to vacancies with recruiters, so
     -- do not select any that do not have one with a login
     AND vac.recruiter_id is not null
     AND trunc(sysdate) between vac.date_from and nvl(vac.date_to,sysdate);

-- ***************************************************************************
-- Cursor to find job seekers requiring a general email
-- ***************************************************************************
    CURSOR csr_seekers_for_notes
    IS
    SELECT /*+ FULL (inp) INDEX(PER PER_PEOPLE_F_PK)  */
           per.person_id
         , per.email_address
         , per.first_name
         , per.last_name
      FROM irc_notification_preferences inp
         , per_all_people_f per
       WHERE  inp.person_id =  per.person_id
       and inp.receive_info_mail ='Y'
       and trunc(sysdate) between per.effective_start_date and per.effective_end_date;

-- ----------------------------------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------------------------------

--
--
-- -------------------------------------------------------------------------
-- |------------------------<  get_location_match >------------------------|
-- -------------------------------------------------------------------------
/* internal function to return 1 if there is a location match or 0 if there
  is not */

FUNCTION get_location_match
  ( p_location_to_match   IN  varchar2,
    p_location_id         IN  hr_locations_all.LOCATION_ID%TYPE)
RETURN number
IS
  l_location_to_match VARCHAR2(240);
  l_return    NUMBER;
BEGIN
  l_return := 0;

  if p_location_to_match IS NULL
  THEN
    l_return := 1;
  ELSE
    select count(*) into l_return from hr_locations_all loc
    where LOC.location_id = p_location_id
    AND catsearch(loc.derived_locale, p_location_to_match, null) > 0;
  END IF;
  --

  RETURN l_return;

EXCEPTION
WHEN OTHERS then
  -- If there is an exception, no point in raising it - just send back 0
  -- The calling code then won't select that job as suitable.
  RETURN 0;
END get_location_match;
--
--
-- -------------------------------------------------------------------------
-- |-----------------------< convert_vacancy_amount >----------------------|
-- -------------------------------------------------------------------------
--
FUNCTION convert_vacancy_amount
        (p_from_currency       IN VARCHAR2
        ,p_to_currency         IN VARCHAR2
        ,p_amount              IN NUMBER
        ,p_conversion_date     IN DATE
        ,p_business_group_id   IN NUMBER
        ,p_processing_type     IN VARCHAR2)
RETURN NUMBER
IS
  l_rate_type VARCHAR2(30);
  l_amount    NUMBER;
BEGIN
/* This function will definitely be slow
   Possible ways of speeding it up are :
     - Add a cache
     - Hit the GL tables directly.
   The issue with point2 is that that there is no guarentee any currency will be
   held.  By going via the HR api, the user should have entered which currencies
   will be held for which business groups.
   Definitely isn't ideal and needs performance testing.
*/
  --
  l_rate_type := hr_currency_pkg.get_rate_type (
                    p_business_group_id   => p_business_group_id
                  , p_conversion_date     => p_conversion_date
                  , p_processing_type     => p_processing_type);


  l_amount := hr_currency_pkg.convert_amount
                   ( p_from_currency   => p_from_currency
                    ,p_to_currency     => p_to_currency
                    ,p_conversion_date => p_conversion_date
                    , p_amount         => p_amount
                    , p_rate_type      => l_rate_type
                   );
  RETURN l_amount;

EXCEPTION
WHEN OTHERS then
  -- If there is an exception, no point in raising it - just send back 0
  -- The calling code then won't select that job as suitable.
  RETURN 0;
END convert_vacancy_amount;
--
--
-- -------------------------------------------------------------------------
-- |----------------------< Remove_Html_Tags >-----------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION remove_html_tags
  ( p_html_string  in   varchar2
  )
RETURN varchar2
IS
  in_html                    BOOLEAN  := FALSE;
  tempchar                   VARCHAR2(1);
  l_return_string            VARCHAR2(500);
BEGIN
  --
  -- If the length of the brief description is more than 500 chars, then remove the tags.
  --
  for i in 1 .. length(p_html_string) loop
    tempchar := substr( p_html_string, i, 1 );
    if in_html then
      if tempchar = '>' then
        in_html := FALSE;
      end if;
    else
      if tempchar = '<' then
        in_html := TRUE;
      end if;
    end if;
    if not in_html and tempchar <> '>' then
      l_return_string := l_return_string || tempchar;
    end if;
  end loop;
--
  RETURN l_return_string;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN l_return_string;
--
END remove_html_tags;
--
--
-- -------------------------------------------------------------------------
-- |----------------------< get_seeker_html_msg_body >---------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_seeker_html_msg_body
  ( p_posting_details_tab      g_posting_details_tab_type
  , p_person_id                number )
RETURN varchar2
IS
  -- Size of the html text should be based on the size that WF can take
  -- This is set in irc_notification_helper_pkg.set_v2_attributes
  -- We define 8 packets of 1950 chars each minus 1 hence the size
  -- of the varchar2 is set to 15599
  --
  l_job_html                 VARCHAR2(15599);
  l_job_html_end             VARCHAR2(2000);
  l_return_job_html          VARCHAR2(15599);
  l_brief_description_v      VARCHAR2(700) default '';
  l_apps_fwk_agent           VARCHAR2(2000);
  l_job_content              VARCHAR2(15599);
  l_length                   NUMBER;
  l_available_size           NUMBER := 13500;
  l_break                    VARCHAR2(10) := '<BR>';
  l_function_name fnd_profile_option_values.profile_option_value%type;
--
BEGIN
  --
  IF (irc_utilities_pkg.is_internal_person(p_person_id,trunc(sysdate))='TRUE') THEN
    l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT',0,0,0,0,0)
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_function_name := get_job_notification_function('Y');
  ELSE
    l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_function_name := get_job_notification_function('N');
  END IF;
  --commented in bug fix 6004149.
  --l_function_name := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');

  -- Loop through the suitable jobs and and list them.
  l_job_html := fnd_message.get_string('PER','IRC_EMAIL_SEEKERS_INTRODUCTION') || l_break;
  l_job_html_end := l_break || l_break || '<p align="center">' || get_conclusion_msg(
                                 p_message_text  => fnd_message.get_string('PER','IRC_EMAIL_SEEKERS_CONCLUSION')
                                ,p_person_id     => p_person_id
                                ,p_action        => 'UJ')||'</p>';
  --
  FOR counter IN 1 .. p_posting_details_tab.count LOOP
    --
    -- Need to select the CLOB now as it couldn't be used with a distinct
    -- in the main cursor.
    l_brief_description_v  := null;
    l_job_content          := null;
    l_length               := 0;
    SELECT substr(brief_description,1,500), length(brief_description)
      INTO l_brief_description_v, l_length
      FROM irc_posting_contents_tl
     WHERE posting_content_id = p_posting_details_tab(counter).posting_content_id
       AND language = userenv('LANG');
    --
    IF (l_length > 0) THEN
      IF (l_length > 500) then
        l_brief_description_v := remove_html_tags (l_brief_description_v) || ' ...';
      END IF;
     --
    ELSE
      l_brief_description_v := '';
    END IF;
    --
    l_job_content := l_break || '<a HREF="'
               ||   l_apps_fwk_agent
               ||   '/OA_HTML/OA.jsp?OAFunc='
               ||   l_function_name
               ||   '&p_svid='||to_char(p_posting_details_tab(counter).object_id)
               ||   '&p_spid='||to_char(p_posting_details_tab(counter).posting_content_id)
               ||   '">'
               ||   replace(p_posting_details_tab(counter).name,'<',fnd_global.local_chr(38)||'lt;')
               ||   '</a> ' || l_break
               ||   fnd_global.local_chr(38)||'nbsp; '
               ||   fnd_global.local_chr(38)||'nbsp;'
               ||   fnd_global.local_chr(38)||'nbsp;'
               ||   fnd_global.local_chr(38)||'nbsp;'
               ||   l_brief_description_v ||  l_break ;
   --
   IF (l_available_size > 0 ) THEN
      l_available_size := l_available_size - length(l_job_html);
      --
      IF ( l_available_size  >=  length(l_job_content) ) THEN
        l_job_html := l_job_html || l_job_content ;
      ELSE
        l_available_size := 0;
      END IF;
      --
   END IF;
   --
   IF (l_available_size = 0) THEN
     l_job_html := l_job_html || l_break || fnd_message.get_string('PER','IRC_412602_MOREJOBS_EXIST_TXT') || l_break;
     EXIT;
   END IF;
  --
  END LOOP;
  --
  l_return_job_html := l_job_html || l_job_html_end;
  --
  RETURN l_return_job_html;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN l_return_job_html;
END get_seeker_html_msg_body;
--
--
-- -------------------------------------------------------------------------
-- |----------------------< get_seeker_text_msg_body >---------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_seeker_text_msg_body
  ( p_posting_details_tab      g_posting_details_tab_type
  , p_person_id                number)
RETURN varchar2
IS
  -- Size of the html text should be based on the size that WF can take
  -- This is set in irc_notification_helper_pkg.set_v2_attributes
  -- We define 8 packets of 1950 chars each minus 1 hence the size
  -- of the varchar2 is set to 15599
  --
  l_job_text                 VARCHAR2(15599);
  l_job_text_end             VARCHAR2(2000);
  l_return_job_text          VARCHAR2(15599);
  l_brief_description_v      VARCHAR2(700) default '';
  l_apps_fwk_agent           VARCHAR2(2000);
  l_job_content              VARCHAR2(15599);
  l_length                   NUMBER;
  l_available_size           NUMBER := 13500;
  l_new_line                 VARCHAR2(10) := '\n';
  l_function_name fnd_profile_option_values.profile_option_value%type;
  --
BEGIN
  --
  IF (irc_utilities_pkg.is_internal_person(p_person_id,trunc(sysdate))='TRUE') THEN
    l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT',0,0,0,0,0)
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_function_name := get_job_notification_function('Y');
  ELSE
    l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_function_name := get_job_notification_function('N');
  END IF;
  --commented in bug fix 6004149.
  --l_function_name := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');
  -- Loop through the suitable jobs and and list them.
  l_job_text := fnd_message.get_string('PER','IRC_EMAIL_SEEKERS_INTRO_TEXT') || l_new_line;
  l_job_text_end := l_new_line ||get_conclusion_msg(
                           p_message_text  =>fnd_message.get_string('PER','IRC_412619_JOB_CONCL_TEXT')
                          ,p_person_id     =>p_person_id
                          ,p_action        =>'UJ');
  --
  FOR counter IN 1 .. p_posting_details_tab.count LOOP
    --
    l_brief_description_v  := null;
    l_job_content          := null;
    l_length               := 0;
    SELECT substr(brief_description,1,500), length(brief_description)
      INTO l_brief_description_v, l_length
      FROM irc_posting_contents_tl
     WHERE posting_content_id = p_posting_details_tab(counter).posting_content_id
       AND language = userenv('LANG');
    --
    IF (l_length > 0) THEN
       l_brief_description_v := remove_html_tags (l_brief_description_v) || ' ...';
       l_brief_description_v := replace(l_brief_description_v,fnd_global.local_chr(38)||'nbsp;',' ');
    ELSE
      l_brief_description_v := '';
    END IF;
    --
    l_job_content := l_new_line ||p_posting_details_tab(counter).name || l_new_line
               ||   l_apps_fwk_agent
               ||   '/OA_HTML/OA.jsp?OAFunc='
               ||   l_function_name
               ||   '&p_svid='||to_char(p_posting_details_tab(counter).object_id)
               ||   '&p_spid='||to_char(p_posting_details_tab(counter).posting_content_id)
               ||   l_new_line  || l_brief_description_v ||  l_new_line;
    --
    IF (l_available_size > 0 ) THEN
      l_available_size := l_available_size - length(l_job_text);
      --
      IF ( l_available_size  >= length(l_job_content) ) THEN
        l_job_text := l_job_text || l_job_content ;
      ELSE
        l_available_size := 0;
      END IF;
      --
    END IF;
   --
   IF (l_available_size = 0) THEN
     l_job_text := l_job_text || l_new_line || fnd_message.get_string('PER','IRC_412602_MOREJOBS_EXIST_TXT') || l_new_line;
     EXIT;
   END IF;
  --
  END LOOP;
  --
  l_return_job_text := l_job_text||l_job_text_end;
  --
  RETURN l_return_job_text;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN l_return_job_text;
END get_seeker_text_msg_body;
--
--
-- -------------------------------------------------------------------------
-- |--------------------< get_recruiter_html_msg_body >--------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_recruiter_html_msg_body
  ( p_seeker_details_tab       g_seeker_details_tab_type )
RETURN varchar2
IS
  l_amount                   BINARY_INTEGER  default 240;
  l_seeker_html                 VARCHAR2(30000);
  l_new_html varchar2(30000);
  l_url varchar2(4000);
  l_max_length number;
BEGIN
  l_url:=fnd_profile.value('APPS_FRAMEWORK_AGENT');
  if substr(l_url,-1,1)<>'/' then
    l_url:=l_url||'/';
  end if;
  if fnd_profile.value('ICX_PREFIX') is not null then
    l_url:=l_url||fnd_profile.value('ICX_PREFIX')||'/OA_HTML/';
  else
    l_url:=l_url||'OA_HTML/';
  end if;
  l_url:=l_url||'OA.jsp?OAFunc='||fnd_profile.value('IRC_SUITABLE_SEEKERS_URL')
        ||fnd_global.local_chr(38)||'addBreadCrumb=Y'||fnd_global.local_chr(38)||'retainAM=Y'||fnd_global.local_chr(38)||'p_sprty=';
  -- Loop through the suitable jobs and and list them.
  l_seeker_html := fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_INTRO')
              || '<BR>';
  --
  l_max_length:=30000-(length(l_seeker_html)+4+length(fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_CONCLUSION')));
  FOR counter IN 1 .. p_seeker_details_tab.count LOOP
    l_new_html:= '<BR><a HREF="'||l_url||p_seeker_details_tab(counter).person_id||'">'
               ||       replace(ltrim(p_seeker_details_tab(counter).full_name,chr(0)),'<',fnd_global.local_chr(38)||'lt;')
               ||       '</a>'
               ||       '<BR>';
    if(length(l_seeker_html)+length(l_new_html)<=l_max_length) then
      l_seeker_html := l_seeker_html||l_new_html;
    else
      log_message('too many matching seekers');
    end if;
  END LOOP;
  --
  l_seeker_html := l_seeker_html || '<BR>' ||
              fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_CONCLUSION');
  RETURN l_seeker_html;
END get_recruiter_html_msg_body;
--
--
-- -------------------------------------------------------------------------
-- |--------------------< get_recruiter_text_msg_body >--------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_recruiter_text_msg_body
  ( p_seeker_details_tab       g_seeker_details_tab_type )
RETURN varchar2
IS
  l_amount                   BINARY_INTEGER  default 240;
  l_seeker_text              VARCHAR2(30000);
  l_new_text              VARCHAR2(30000);
  l_url varchar2(4000);
  l_max_length number;
BEGIN
  l_url:=fnd_profile.value('APPS_FRAMEWORK_AGENT');
  if substr(l_url,-1,1)<>'/' then
    l_url:=l_url||'/';
  end if;
  if fnd_profile.value('ICX_PREFIX') is not null then
    l_url:=l_url||fnd_profile.value('ICX_PREFIX')||'/OA_HTML/';
  else
    l_url:=l_url||'OA_HTML/';
  end if;
  l_url:=l_url||'OA.jsp?OAFunc='||fnd_profile.value('IRC_SUITABLE_SEEKERS_URL')
        ||fnd_global.local_chr(38)||'addBreadCrumb=Y'||fnd_global.local_chr(38)||'retainAM=Y'||fnd_global.local_chr(38)||'p_sprty=';
  -- Loop through the suitable jobs and and list them.
  l_seeker_text := fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_INTRO')
              || '\n';
  --
  l_max_length:=30000-(length(l_seeker_text)+4+length(fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_CONCLUSION')));
  FOR counter IN 1 .. p_seeker_details_tab.count LOOP
    l_new_text :=   '\n'||ltrim(p_seeker_details_tab(counter).full_name,chr(0))
               ||   '\n'||l_url||p_seeker_details_tab(counter).person_id
               ||       '\n';
    if(length(l_seeker_text)+length(l_new_text)<=l_max_length) then
      l_seeker_text := l_seeker_text||l_new_text;
    else
      log_message('too many matching seekers');
    end if;
  END LOOP;
  --
  l_seeker_text := l_seeker_text || '\n' ||
              fnd_message.get_string('PER','IRC_EMAIL_RECRUITER_CONCLUSION');
  RETURN l_seeker_text;
END get_recruiter_text_msg_body;
--
--
--
-- -------------------------------------------------------------------------
-- |--------------------< get_int_rec_site >-------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_int_rec_site
  ( p_vacancy_id       per_all_vacancies.vacancy_id%type )
RETURN varchar2
IS
  l_int_site   irc_all_recruiting_sites.internal%type;
BEGIN

  SELECT 'Y' INTO l_int_site
  FROM  DUAL
  WHERE EXISTS ( SELECT 1
                 FROM  per_all_vacancies              vac   ,
                       per_recruitment_activity_for   praf  ,
                       per_recruitment_activities     pra   ,
                       irc_all_recruiting_sites       site
                 WHERE
                     vac.vacancy_id = praf.vacancy_id
                 AND praf.recruitment_activity_id = pra.recruitment_activity_id
                 AND trunc(sysdate) between pra.date_start and nvl(pra.date_end,sysdate)
                 AND pra.recruiting_site_id     = site.recruiting_site_id
                 AND vac.vacancy_id = p_vacancy_id
                 AND site.internal = 'Y'    );

  RETURN l_int_site;

  EXCEPTION
    WHEN OTHERS THEN
     l_int_site := 'N';
      RETURN l_int_site;
END get_int_rec_site;
--
--
-- -------------------------------------------------------------------------
-- |--------------------< get_ext_rec_site >-------------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_ext_rec_site
  ( p_vacancy_id       per_all_vacancies.vacancy_id%type )
RETURN varchar2
IS
  l_ext_site   irc_all_recruiting_sites.external%type;
BEGIN

  SELECT 'Y' INTO l_ext_site
  FROM  DUAL
  WHERE EXISTS ( SELECT 1
                 FROM  per_all_vacancies              vac   ,
                       per_recruitment_activity_for   praf  ,
                       per_recruitment_activities     pra   ,
                       irc_all_recruiting_sites       site
                 WHERE
                     vac.vacancy_id = praf.vacancy_id
                 AND praf.recruitment_activity_id = pra.recruitment_activity_id
                 AND trunc(sysdate) between pra.date_start and nvl(pra.date_end,sysdate)
                 AND pra.recruiting_site_id     = site.recruiting_site_id
                 AND vac.vacancy_id = p_vacancy_id
                 AND site.external = 'Y'    );

  RETURN l_ext_site;

  EXCEPTION
    WHEN OTHERS THEN
     l_ext_site := 'N';
      RETURN l_ext_site;
END get_ext_rec_site;
--
--
-- -------------------------------------------------------------------------
-- |--------------------< get_job_notification_function >------------------|
-- -------------------------------------------------------------------------
--
--Bug 6004149. To generate different urls for internal and external candidates
--the profile value at corresponding resp levels are taken.Please note that
--even if customer uses custom resps for internal and external candidates,
--whatever value is set for IRC:Job Notification Url at the below resps,
--that value will be used to generate the url for vacancy details.

FUNCTION get_job_notification_function
  ( p_is_internal     IN  varchar2)
RETURN varchar2
IS
  CURSOR csr_get_resp_id (resp_key varchar2)
    IS
    SELECT responsibility_id
      FROM fnd_responsibility
      WHERE responsibility_key = resp_key;

  l_resp_key    fnd_responsibility.responsibility_key%type;
  l_resp_id     fnd_responsibility.responsibility_id%type;
  l_function_name fnd_profile_option_values.profile_option_value%type;
BEGIN

  if(lower(p_is_internal) = 'y')
  then
    l_resp_key := 'IRC_EMP_CANDIDATE';
  else
    l_resp_key := 'IRC_EXT_CANDIDATE';
  end if;

  open csr_get_resp_id(l_resp_key);
  fetch csr_get_resp_id into l_resp_id ;
  close csr_get_resp_id;

  l_function_name := fnd_profile.value_specific
                             (name              => 'IRC_JOB_NOTIFICATION_URL'
                             ,responsibility_id => l_resp_id);
  return l_function_name;

  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        l_function_name := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');
        return l_function_name;
END get_job_notification_function;
--
-- ----------------------------------------------------------------------------
-- PROCEDURES
-- ----------------------------------------------------------------------------
--
-- -------------------------------------------------------------------------
-- |----------------------------< log_message >----------------------------|
-- -------------------------------------------------------------------------
--
  PROCEDURE log_message
           ( p_message IN VARCHAR2
           , p_type    IN VARCHAR2 DEFAULT 'B'
           )
  IS
  BEGIN
     fnd_file.put_line(which => fnd_file.log,
                       buff  => p_message);
     if fnd_global.conc_request_id <> -1 then
     -- log is additionally written out via FND_FILE,
     -- for visibility from view SRS window.
         fnd_file.put_line(which => fnd_file.output,
                           buff  => 'REQ'||p_message);
    /*hr_utility.trace_on('F','REQID');
    hr_utility.trace('FRED');
    hr_utility.trace_off;
*/
    end if;
  END log_message;

--
-- -------------------------------------------------------------------------
-- |------------------< email_suitable_vacs_to_seekers >-------------------|
-- -------------------------------------------------------------------------
--
  PROCEDURE email_suitable_vacs_to_seekers
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
             , p_ignore_seeker_matching_freq  IN VARCHAR2 DEFAULT 'N'
             , p_ignore_job_age               IN VARCHAR2 DEFAULT 'N'
            )
  IS
    l_sql     VARCHAR2(30000);
    l_cursor  NUMBER;
    l_row     NUMBER;
    l_matching_flex VARCHAR2(240);
        l_last_value VARCHAR2(240);
    l_matching_values VARCHAR2(240);
    l_attribute VARCHAR2(14);
    seeker_criteria_match_vac_rec g_posting_details_rec_type;
    matching_values_tbl dbms_sql.varchar2_table;

    l_posting_details_tab  g_posting_details_tab_type;
    l_message_subject      VARCHAR2(240);
    l_base_url             VARCHAR2(250);
    --
    l_counter NUMBER DEFAULT 0;
    l_amount NUMBER;
    --
    l_id  NUMBER;
    e_no_base_url   EXCEPTION;
    l_dft_lang varchar2(100);
    l_current_lang varchar2(100);
    l_proc VARCHAR2(35) default '.email_suitable_vacs_to_seekers';

    /*Cursor to get NLS Language for the existing session language*/
    cursor get_nls_lang (p_dft_lang varchar2) is
      select NLS_LANGUAGE
        from fnd_languages_vl
       where language_code = p_dft_lang;

  BEGIN
    hr_utility.set_location('Entering'||l_proc, 10);

    -- If the base URL isn't set up,  it is futile performing a job search
    -- as the URL for the seekers to click on won't work.
    --
    l_base_url := fnd_profile.value('IRC_JOB_NOTIFICATION_URL');
    IF l_base_url IS NULL THEN
      hr_utility.set_location('base_url is null', 20);
      fnd_message.set_name('PER','IRC_412056_NO_EMAIL_JOB_URL');
      RAISE e_no_base_url;
    END IF;

    l_matching_flex := fnd_profile.value('IRC_SEARCH_CRITERIA_SM');

    --
    -- ***************************************************************************
    -- Inner SQL to match the Job Seeker criteria to Vacancies
    -- ***************************************************************************
    --
    l_sql:='SELECT DISTINCT
            ipc_tl.posting_content_id
          , ipc_tl.job_title
          , ipc_tl.name
          , icrit_vac.object_id
       FROM
            irc_search_criteria     icrit_vac
          , irc_posting_contents    ipc
          , irc_posting_contents_tl ipc_tl
          , per_recruitment_activity_for praf
          , per_recruitment_activities pra
          , irc_all_recruiting_sites site
          , per_all_vacancies vac
          , hr_locations_all loc
        WHERE
             icrit_vac.object_type = ''VACANCY''
         AND icrit_vac.object_id = vac.vacancy_id
         AND vac.location_id = loc.location_id(+)
         AND vac.vacancy_id = praf.vacancy_id
         AND praf.recruitment_activity_id = pra.recruitment_activity_id
         AND pra.posting_content_id = ipc.posting_content_id
         AND ipc.posting_content_id = ipc_tl.posting_content_id
     AND ipc_tl.language=userenv(''LANG'')
     AND vac.status=''APPROVED''
     AND sysdate between vac.date_from and nvl(vac.date_to,sysdate)
     AND sysdate between pra.date_start and nvl(pra.date_end,sysdate)
     AND site.recruiting_site_id=pra.recruiting_site_id
     AND ((site.internal=''Y'' and :current_employee=''Y'')
        OR(site.external=''Y'' and :current_employee=''N''))';
     -- And no applicant assignment has ever existed for the vacancy
     l_sql:= l_sql||'    AND NOT EXISTS
             (select 1
                from per_all_people_f ppf
                    ,per_all_assignments_f paaf
               where paaf.vacancy_id = icrit_vac.object_id
                 and paaf.person_id=ppf.person_id
                 and ppf.party_id  = :party_id
                 and trunc(sysdate) between
                 ppf.effective_start_date and ppf.effective_end_date)';

     -- Employee and Contractor Match
     l_sql:= l_sql||'    AND (   icrit_vac.employee   = :employee
              OR icrit_vac.contractor = :contractor
             )';
     -- travel percentage : Assume no Seeker value means they can travel and
     --                     no vac value means no travel is involved
     l_sql:= l_sql||'    AND  NVL(:travel_percentage,100)
                  >= NVL(icrit_vac.travel_percentage,0)';
     -- Min/Max Salary
     l_sql:= l_sql||'    AND (  (:salary_currency
                     = icrit_vac.salary_currency
                          AND :min_salary
                              <= icrit_vac.max_salary
                 )
                OR (:salary_currency is null)
                OR (:min_salary is null)
                OR (icrit_vac.salary_currency is null)
                OR (icrit_vac.max_salary is null)
                OR (:salary_currency
                                    <>icrit_vac.salary_currency
                   AND icrit_vac.max_salary >=
                          irc_seeker_vac_matching_pkg.convert_vacancy_amount
                              (:salary_currency
                              ,icrit_vac.salary_currency
                              ,:min_salary
                              ,sysdate
                              ,vac.business_group_id
                              ,''P''
                              )
                   )
             )';
    -- Job Age
     l_sql:= l_sql||'    AND (ipc.last_update_date >=
                       (sysdate - :show_jobs_since)
              OR :p_ignore_job_age = ''Y''
             )';
    -- Job Title Match
    --   NOTE: name is a placeholder for a multi column index so it is used
    --         to cover job_title description etc.
    l_sql:= l_sql||'     AND ( :job_title IS NULL
              OR contains(ipc_tl.name,nvl(:job_title,''123Sys_Def321'') ) > 0
             )';
    -- Department Match
    --   NOTE: name is a placeholder for a multi column index so it is used
    --         to cover job_title org_description etc.
    l_sql:= l_sql||'     AND ( :department IS NULL
              OR contains(ipc_tl.name,nvl(:department,''123Sys_Def321'') ) > 0
             )';
    -- Employment Category
    l_sql:= l_sql||'     AND ( nvl(:employment_category,''EITHER'') = ''EITHER''
               OR icrit_vac.employment_category = ''EITHER''
               OR :employment_category
                  = icrit_vac.employment_category)';
    -- Keyword Match
    l_sql:= l_sql||'    AND (:keywords is null
             or contains (ipc_tl.name,nvl(:keywords,''321Sys_Def123''),1)>0)';
    -- Location Keyword Match
    l_sql:= l_sql||'  AND  irc_seeker_vac_matching_pkg.get_location_match(:location,vac.location_id) > 0';
    -- Location Distance Match
    l_sql:= l_sql||'  AND (
                               (    :distance_to_location IS NOT NULL
                                 AND loc.geometry IS NOT NULL
                                 AND :longitude IS NOT NULL
                                 AND locator_within_distance
                                 ( loc.geometry
                                  , mdsys.sdo_geometry(2001,8307,mdsys.sdo_point_type(:longitude,:latitude,null),null,null)
                                  ,  ''distance=''
                                    || :distance_to_location
                                    ||'' units=MILE''
                                 ) = ''TRUE''
                               )
                            OR (     :distance_to_location IS NULL
                                 AND :geocode_location IS NULL
                                 AND (
                                       (    :geocode_country IS NOT NULL
                                         AND loc.country = :geocode_country
                                       )
                                     )
                                )
                           OR (     :distance_to_location IS NULL
                                 AND :longitude IS NULL
                                 AND :geocode_country IS NULL
                              )
                          ) ';
    -- location_id match
    l_sql:= l_sql||'   AND ((:location_id is not null
            and vac.location_id=:location_id)
            or (:location_id is null))';
    -- derived locale exact match
    l_sql:= l_sql||'   AND (( exists (select 1 from irc_location_criteria_values irc_lcv
            where loc.derived_locale=irc_lcv.derived_locale
            and irc_lcv.search_criteria_id=:search_criteria_id))
            or (not exists (select 1 from irc_location_criteria_values irc_lcv
            where irc_lcv.search_criteria_id=:search_criteria_id)))';
    -- Competence Match
    l_sql:= l_sql||'      AND (:match_competence = ''N''
               OR
                 irc_skills_matching_pkg.vacancy_match_percent
                   ( :person_id
                   , icrit_vac.object_id
                   ) <>''-1''  -- This means all essential skills are matched
              )';
    -- Qualification
    l_sql:= l_sql||'      AND (:match_qualification = ''N''
               OR
                exists (SELECT 1
                          FROM per_qualifications qual
                             , per_qualification_types qty
                         WHERE qual.qualification_type_id
                             = qty.qualification_type_id
                           AND qual.person_id
                               = :person_id
                           AND qty.rank
                               BETWEEN NVL(icrit_vac.min_qual_level,0)
                                   AND NVL(icrit_vac.max_qual_level,qty.rank)
                       )
              )';
    -- Professional Area
    l_sql:= l_sql||'   AND (( exists (select 1 from irc_prof_area_criteria_values irc_pacv
            where icrit_vac.professional_area=irc_pacv.professional_area
            and irc_pacv.search_criteria_id=:search_criteria_id))
            or (not exists (select 1 from irc_prof_area_criteria_values irc_pacv
            where irc_pacv.search_criteria_id=:search_criteria_id)))';
    -- Work At Home Area
    l_sql:= l_sql||'      AND (icrit_vac.work_at_home = ''POSSIBLY''
                 OR :work_at_home IS NULL
                 OR icrit_vac.work_at_home IS NULL
                 OR icrit_vac.work_at_home
                             = :work_at_home
              )';

    l_last_value := ltrim(substr(l_matching_flex,LENGTH(l_matching_flex)-1,LENGTH(l_matching_flex)),'|');
    l_matching_values := l_matching_flex;
    l_counter := 0;

        -- Dynamically add in the Flex attributes matching based on the profile.
    while (l_matching_values IS NOT NULL)
    LOOP
          IF (l_last_value = l_matching_values)
          THEN
            l_attribute := 'ATTRIBUTE'||l_matching_values;
            l_matching_values := NULL;
          ELSE
            l_attribute := 'ATTRIBUTE'||substr(l_matching_values,1,instr(l_matching_values, '|')-1);
             l_matching_values := ltrim(ltrim(l_matching_values,substr(l_matching_values,1,instr(l_matching_values, '|')-1)),'|');
          END IF;

          -- populate the matching_values_tbl so that we can bind in the critiera in
          -- the inner loop.
      matching_values_tbl(l_counter) := l_attribute;
      l_sql:= l_sql||'   AND ((icrit_vac.'||lower(l_attribute)||
                         ' IS NULL AND :'||l_attribute||
                                         ' IS NULL) OR lower(icrit_vac.'||l_attribute||') = :'||lower(l_attribute)||')  ';
      l_counter := l_counter + 1;

    END LOOP;

    -- USE DBMS SQL so that we can parse the SQL once and bind in the criteria many
        -- times in the inner loop, saving parse time compared to NDS.
    l_cursor := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE (c             => l_cursor,
                        statement     => l_sql,
                        language_flag => dbms_sql.native);

    /*Save existing session language to restore after sending notifications*/
    open get_nls_lang(userenv('LANG'));
    fetch get_nls_lang into l_dft_lang;
    close get_nls_lang;

    --
    -- ************************************************************
    -- Loop through all the job seekers eligible for an email today
    -- ************************************************************
    FOR seeker_rec IN csr_seekers_for_email
         (p_ignore_seeker_matching_freq => p_ignore_seeker_matching_freq) LOOP
      --
      -- Clear the table as now we need to build up a new record for
      -- a different (or the first) job seeker
      --
      begin
      hr_utility.set_location('person_id:'
                             ||seeker_rec.person_id, 20);
      hr_utility.set_location('lang_pref:'
                             ||seeker_rec.lang_pref, 20);

      /*change the session language if the user lang is differ from current lang*/
      open get_nls_lang(userenv('LANG'));
      fetch get_nls_lang into l_current_lang;
      close get_nls_lang;

      if (l_current_lang <> seeker_rec.lang_pref) then
        DBMS_SESSION.SET_NLS('NLS_LANGUAGE',seeker_rec.lang_pref);
      end if;
      l_posting_details_tab.delete;
      l_counter := 0;
--dbms_output.put_line('Processing Person:'||seeker_rec.person_id);
      --
      -- By having two more cursors instead of one, one email can
      -- easily be produced containing jobs for all the seekers
      -- criteria.  The only drawback (which can be overcome if
      -- necessary) is that the same job can appear multiple times.
      -- For Phase 1 this is deemed to be acceptable.
      -- ********************************************************
      -- Get a list of all the job seeker search criteria
      -- ********************************************************
      FOR seeker_criteria_rec IN csr_seeker_criteria_for_email
         (p_seeker_details  => seeker_rec) LOOP
        --
        -- ********************************************************
        -- Get a list of all the suitable jobs for the job seeker
        -- ********************************************************
        -- And no applicant assignment has ever existed for the vacancy
--dbms_output.put_line('   Processing Search Criteria:'||seeker_criteria_rec.search_criteria_id);

        -- define the posting_content_id column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 1,
        column      => seeker_criteria_match_vac_rec.posting_content_id);

        -- define the job_title column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 2,
        column      => seeker_criteria_match_vac_rec.job_title,
        column_size => 240);

        -- define the name column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 3,
        column      => seeker_criteria_match_vac_rec.name,
        column_size => 240);

        -- define the object_id column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 4,
        column      => seeker_criteria_match_vac_rec.object_id);

/*
dbms_output.put_line('     BINDS person_id:'||seeker_criteria_rec.object_id);
dbms_output.put_line('     BINDS party_id:'||seeker_rec.party_id);
dbms_output.put_line('     BINDS employee:'||seeker_criteria_rec.employee);
dbms_output.put_line('     BINDS contractor:'||seeker_criteria_rec.contractor);
dbms_output.put_line('     BINDS travel_percentage:'||seeker_criteria_rec.travel_percentage);
dbms_output.put_line('     BINDS salary_currency:'||seeker_criteria_rec.salary_currency);
dbms_output.put_line('     BINDS min_salary:'||seeker_criteria_rec.min_salary);
dbms_output.put_line('     BINDS show_jobs_since:'||seeker_criteria_rec.show_jobs_since);
dbms_output.put_line('     BINDS job_title:'||seeker_criteria_rec.job_title);
dbms_output.put_line('     BINDS department:'||seeker_criteria_rec.department);
dbms_output.put_line('     BINDS employment_category:'||seeker_criteria_rec.employment_category);
dbms_output.put_line('     BINDS keywords:'||seeker_criteria_rec.keywords);
dbms_output.put_line('     BINDS work_at_home:'||seeker_criteria_rec.work_at_home);
dbms_output.put_line('     BINDS location:'||seeker_criteria_rec.location);
dbms_output.put_line('     BINDS longitude:'||seeker_criteria_rec.geometry.sdo_point.x);
dbms_output.put_line('     BINDS latitude:'||seeker_criteria_rec.geometry.sdo_point.y);
dbms_output.put_line('     BINDS distance_to_location:'||seeker_criteria_rec.distance_to_location);
dbms_output.put_line('     BINDS location_id:'||seeker_criteria_rec.location_id);
dbms_output.put_line('     BINDS search_criteria_id:'||seeker_criteria_rec.search_criteria_id);
dbms_output.put_line('     BINDS p_ignore_job_age:'||p_ignore_job_age);
dbms_output.put_line('     BINDS match_qualification:'||seeker_criteria_rec.match_qualification);
dbms_output.put_line('     BINDS match_competence:'||seeker_criteria_rec.match_competence);
*/

        -- supply binds (bind by name)
        dbms_sql.bind_variable(
        l_cursor, 'person_id', seeker_criteria_rec.object_id);
        dbms_sql.bind_variable(
        l_cursor, 'current_employee', nvl(seeker_criteria_rec.current_employee_flag,'N'));
        dbms_sql.bind_variable(
        l_cursor, 'party_id', seeker_rec.party_id);
        dbms_sql.bind_variable(
        l_cursor, 'employee', seeker_criteria_rec.employee);
        dbms_sql.bind_variable(
        l_cursor, 'contractor', seeker_criteria_rec.contractor);
        dbms_sql.bind_variable(
        l_cursor, 'travel_percentage', seeker_criteria_rec.travel_percentage);
        dbms_sql.bind_variable(
        l_cursor, 'salary_currency', seeker_criteria_rec.salary_currency);
        dbms_sql.bind_variable(
        l_cursor, 'min_salary', seeker_criteria_rec.min_salary);
        dbms_sql.bind_variable(
        l_cursor, 'show_jobs_since', seeker_criteria_rec.show_jobs_since);
        dbms_sql.bind_variable(
        l_cursor, 'job_title', seeker_criteria_rec.job_title);
        dbms_sql.bind_variable(
        l_cursor, 'department', seeker_criteria_rec.department);
        dbms_sql.bind_variable(
        l_cursor, 'employment_category', seeker_criteria_rec.employment_category);
        if seeker_criteria_rec.keywords is null then
          dbms_sql.bind_variable(
          l_cursor, 'keywords', to_char(null));
        else
          dbms_sql.bind_variable(
          l_cursor, 'keywords', irc_query_parser_pkg.query_parser(seeker_criteria_rec.keywords));
        end if;
        dbms_sql.bind_variable(
        l_cursor, 'work_at_home', seeker_criteria_rec.work_at_home);
        dbms_sql.bind_variable(
        l_cursor, 'location', seeker_criteria_rec.location);
        dbms_sql.bind_variable(
        l_cursor, 'longitude', seeker_criteria_rec.geometry.sdo_point.x);
        dbms_sql.bind_variable(
        l_cursor, 'latitude', seeker_criteria_rec.geometry.sdo_point.y);
        dbms_sql.bind_variable(
        l_cursor, 'distance_to_location', seeker_criteria_rec.distance_to_location);
        -- Newly added for geocode_location, geocode_country start
        dbms_sql.bind_variable(
        l_cursor, 'geocode_location', seeker_criteria_rec.geocode_location);
        dbms_sql.bind_variable(
        l_cursor, 'geocode_country', seeker_criteria_rec.geocode_country);
        -- Newly added for geocode_location, geocode_country end
        dbms_sql.bind_variable(
        l_cursor, 'location_id', seeker_criteria_rec.location_id);
        dbms_sql.bind_variable(
        l_cursor, 'search_criteria_id', seeker_criteria_rec.search_criteria_id);
        dbms_sql.bind_variable(
        l_cursor, 'p_ignore_job_age', p_ignore_job_age);
        dbms_sql.bind_variable(
        l_cursor, 'match_qualification', seeker_criteria_rec.match_qualification);
        dbms_sql.bind_variable(
        l_cursor, 'match_competence', seeker_criteria_rec.match_competence);

        for ct in 0..matching_values_tbl.count-1 loop
          IF (matching_values_tbl(ct)= 'ATTRIBUTE1')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE1', lower(seeker_criteria_rec.attribute1));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE2')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE2', lower(seeker_criteria_rec.attribute2));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE3')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE3', lower(seeker_criteria_rec.attribute3));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE4')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE4', lower(seeker_criteria_rec.attribute4));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE5')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE5', lower(seeker_criteria_rec.attribute5));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE6')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE6', lower(seeker_criteria_rec.attribute6));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE7')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE7', lower(seeker_criteria_rec.attribute7));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE8')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE8', lower(seeker_criteria_rec.attribute8));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE9')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE9', lower(seeker_criteria_rec.attribute9));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE10')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE10', lower(seeker_criteria_rec.attribute10));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE11')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE11', lower(seeker_criteria_rec.attribute11));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE12')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE12', lower(seeker_criteria_rec.attribute12));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE13')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE13', lower(seeker_criteria_rec.attribute13));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE14')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE14', lower(seeker_criteria_rec.attribute14));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE15')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE15', lower(seeker_criteria_rec.attribute15));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE16')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE16', lower(seeker_criteria_rec.attribute16));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE17')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE17', lower(seeker_criteria_rec.attribute17));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE18')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE18', lower(seeker_criteria_rec.attribute18));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE19')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE19', lower(seeker_criteria_rec.attribute19));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE20')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE20', lower(seeker_criteria_rec.attribute20));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE21')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE21', lower(seeker_criteria_rec.attribute21));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE22')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE22', lower(seeker_criteria_rec.attribute22));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE23')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE23', lower(seeker_criteria_rec.attribute23));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE24')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE24', lower(seeker_criteria_rec.attribute24));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE25')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE25', lower(seeker_criteria_rec.attribute25));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE26')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE26', lower(seeker_criteria_rec.attribute26));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE27')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE27', lower(seeker_criteria_rec.attribute27));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE28')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE28', lower(seeker_criteria_rec.attribute28));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE29')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE29', lower(seeker_criteria_rec.attribute29));

          ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE30')
          THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE30', lower(seeker_criteria_rec.attribute30));
          END IF;
        end loop;

        -- execute the cursor
        l_row := DBMS_SQL.EXECUTE (c => l_cursor);

        -- while there is data to fetch
        WHILE DBMS_SQL.FETCH_ROWS (c => l_cursor) <> 0
        LOOP
          -- define the posting_content_id column
          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 1,
          value      => seeker_criteria_match_vac_rec.posting_content_id);

          -- define the job_title column
          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 2,
          value      => seeker_criteria_match_vac_rec.job_title);

          -- define the name column
          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 3,
          value      => seeker_criteria_match_vac_rec.name);

          -- define the object_id column
          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 4,
          value      => seeker_criteria_match_vac_rec.object_id);

          -- Counter for all the seekers search criteria suitable jobs
          -- (which is why csr_seeker_vacancies_for_email%rowcount
          --   can't be used)
          l_counter := l_counter + 1;
          --
          -- Build up a table containing all the suitable vacancies
          --
          l_posting_details_tab(l_counter)
            := seeker_criteria_match_vac_rec;
          --
          hr_utility.set_location('vacancy_id:'
                           ||seeker_criteria_match_vac_rec.object_id, 30);

--dbms_output.put_line('    Person:'||seeker_criteria_rec.object_id||' FOR VAC:'||seeker_criteria_match_vac_rec.object_id||'>'||seeker_criteria_match_vac_rec.name);
        END LOOP;
      --
      END LOOP; -- seeker_criteria_rec / csr_seeker_criteria_for_email
      --
      -- ************************************************************
      -- Send an e-mail to the job seeker with suitable jobs
      -- ************************************************************
      IF l_posting_details_tab.count > 0 THEN
        -- Send the notification if any suitable vacancies have been found
        hr_utility.set_location('sending notification:',50);
--dbms_output.put_line('    Person:'||seeker_rec.person_id||' Has Matches');
        --
       l_message_subject := fnd_message.get_string('PER','IRC_EMAIL_SEEKERS_SUBJECT');
         l_id :=
           irc_notification_helper_pkg.send_notification
                    ( p_person_id  => seeker_rec.person_id
                    , p_subject   => l_message_subject
                    , p_html_body => get_seeker_html_msg_body
                               ( p_posting_details_tab =>l_posting_details_tab
                               , p_person_id => seeker_rec.person_id )
                    , p_text_body => get_seeker_text_msg_body
                               ( p_posting_details_tab =>l_posting_details_tab
                               , p_person_id => seeker_rec.person_id )
                  );
      END IF;
      --
      hr_utility.set_location('Location:'||l_proc,60);
      exception
      when others then
        -- Catch the exception so that an error doens't cause total failure.
        hr_utility.set_location('Problem sending notification to person:'||seeker_rec.person_id,60);
        DBMS_SESSION.SET_NLS('NLS_LANGUAGE',l_dft_lang);
      end;
    END LOOP;
    DBMS_SESSION.SET_NLS('NLS_LANGUAGE',l_dft_lang);
    DBMS_SQL.CLOSE_CURSOR (c => l_cursor);--All done, so clean up!

    --
    hr_utility.set_location('Leaving'||l_proc, 80);
  EXCEPTION
  WHEN others THEN
    DBMS_SESSION.SET_NLS('NLS_LANGUAGE',l_dft_lang);
    ERRBUF  := SQLERRM||' '||fnd_message.get;
    RETCODE := 2;
  END email_suitable_vacs_to_seekers;

--
-- -------------------------------------------------------------------------
-- |-------------------< get_suitable_seekers_for_vac >--------------------|
-- -------------------------------------------------------------------------
--
  PROCEDURE get_suitable_seekers_for_vac
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
             , p_candidacy_age                IN NUMBER   DEFAULT 0
            )
  IS
    --
    l_sql     VARCHAR2(30000);
    l_cursor  NUMBER;
    l_row     NUMBER;
    l_matching_flex VARCHAR2(240);
    l_last_value VARCHAR2(240);
    l_matching_values VARCHAR2(240);
    l_attribute VARCHAR2(14);
    seeker_details_rec g_seeker_details_rec_type;
    matching_values_tbl dbms_sql.varchar2_table;

    l_recruiter_problem_tab  g_recruiter_problem_tab_type;
    --
    l_message_subject      VARCHAR2(300);
    l_amount NUMBER;
    --
    l_counter NUMBER DEFAULT 0;
    --
    l_recruiter_id PER_VACANCIES.RECRUITER_ID%type ;
    l_seeker_details_tab g_seeker_details_tab_type;
    l_id  NUMBER;
    l_index NUMBER default 0;
    l_base_url             VARCHAR2(250);
    e_no_base_url          EXCEPTION;
    l_msg_sent   NUMBER DEFAULT 0;
    l_date_registered date;
    l_internal_site  irc_all_recruiting_sites.internal%type;
    l_external_site  irc_all_recruiting_sites.external%type;
    l_proc VARCHAR2(30) default ' get_suitable_seekers_for_vac';
  BEGIN
    hr_utility.set_location('Entering'||l_proc, 10);
  --
    l_matching_flex := fnd_profile.value('IRC_SEARCH_CRITERIA_SM');
  --
  if (p_candidacy_age>0) then
    l_date_registered:=trunc(sysdate)-p_candidacy_age;
  else
    l_date_registered:=hr_api.g_sot;
  end if;
    --
    -- **************************************************************************
    -- Inner SQL to find Job Seekers for open vacancies
    -- **************************************************************************
    -- Note : a clob, such as brief_description can't be retrieved in this
    --        cursor because of the DISTINCT.

    l_sql :='     SELECT DISTINCT
             ppf.full_name
           , ppf.person_id
       FROM
            irc_search_criteria     icrit
          , per_all_people_f        ppf
          , irc_posting_contents_tl ipc_tl
          , hr_locations_all        loc
          , irc_notification_preferences inp
      WHERE   icrit.object_type =''WPREF''
        AND icrit.object_id = ppf.person_id
        AND ipc_tl.posting_content_id = :posting_content_id
        AND ipc_tl.language=userenv(''LANG'')
        AND inp.person_id=ppf.person_id
        AND inp.allow_access=''Y''
        AND inp.creation_date>=:date_registered
        AND ppf.effective_start_date>=:date_registered
        AND ( (ppf.current_employee_flag=''Y'' and :internal=''Y'')
           OR (ppf.current_employee_flag is null and :external=''Y''))
        AND trunc(sysdate)
            BETWEEN ppf.effective_start_date
                AND ppf.effective_end_date ';
    -- And has no applicant assignment for the vacancy
    l_sql := l_sql||'    AND NOT EXISTS
             (select paaf.assignment_id
                from per_all_people_f ppf1
                    ,per_all_assignments_f paaf
               where paaf.vacancy_id = :vacancy_id
                 and ppf1.party_id = ppf.party_id
                 and ppf1.person_id  = paaf.person_id
                 and trunc(sysdate) between
                 ppf1.effective_start_date and ppf1.effective_end_date) ';
    -- Employee and Contractor Match
    l_sql := l_sql||'    AND (   icrit.employee   = :employee
              OR icrit.contractor = :contractor
             ) ';
    -- travel percentage : Assume no Seeker value means they can travel and
    --                     no vac value means no travel is involved
    l_sql := l_sql||'    AND  NVL(:travel_percentage,0)
                  <= NVL(icrit.travel_percentage,100)  ';
    -- Min/Max Salary
    l_sql := l_sql||'    AND (  (:salary_currency = icrit.salary_currency
                          AND icrit.min_salary <= :max_salary
                 )
                OR (:salary_currency is null)
                OR (:max_salary is null)
                OR (icrit.salary_currency is null)
                OR (icrit.min_salary is null)
                OR (:salary_currency<>icrit.salary_currency
                   AND icrit.min_salary <=
                          irc_seeker_vac_matching_pkg.convert_vacancy_amount
                              (:salary_currency
                              ,icrit.salary_currency
                              ,:max_salary
                              ,sysdate
                              ,:business_group_id
                              ,''P''
                              )
                   )
            ) ';
    -- NOTE: ipc_tl is a multistore index - it includes most of the ipc
    --       columns, hence it can be used for both the Job Title and
    --       Department Match.
    -- Job Title Match
    l_sql := l_sql||'     AND ( icrit.job_title IS NULL
              OR contains (ipc_tl.name,nvl(icrit.job_title,''123Sys_Def321'')) > 0
             ) ';
    -- Department Match
    l_sql := l_sql||'     AND ( icrit.department IS NULL
              OR contains (ipc_tl.name, nvl(icrit.department,''123Sys_Def321''))>0
             )';
    -- Employment Category
    l_sql := l_sql||'     AND ( NVL(:employment_category,''EITHER'') = ''EITHER''
               OR icrit.employment_category = ''EITHER''
               OR :employment_category = icrit.employment_category) ';
    -- Keyword Match
    l_sql := l_sql||'     AND ( icrit.keywords IS NULL
              OR contains (ipc_tl.name, nvl(:keywords,''123Sys_Def321''))>0
             ) ';
    -- Location Keyword Match
    l_sql := l_sql||'  AND loc.location_id(+)=:location_id
      AND catsearch( loc.derived_locale(+), nvl(icrit.location,''*''), null) > 0 ';
    -- Location Distance Match
    l_sql := l_sql||' AND ( -- icrit.geometry.sdo_point.x is null OR
                            exists (select 1
                                      from hr_locations_all loc2
                                     where loc2.location_id = :location_id
                                       and icrit.geometry.sdo_point.x is not null
                                       and loc2.geometry is not null
                                       and locator_within_distance
                                         ( loc2.geometry
                                         , icrit.geometry
                                         , ''distance=''
                                          || nvl(icrit.distance_to_location,0)
                                          ||'' units=MILE''
                                         )= ''TRUE''
                                   )
                            OR (    icrit.distance_to_location IS NULL
                                AND icrit.geometry IS NULL
                                AND (
                                      (    :country IS NOT NULL
                                       AND icrit.geocode_country = :country
                                      )
                                   )
                               )
                          )';
    -- location_id match
    l_sql := l_sql||'   AND ((icrit.location_id is not null
            and icrit.location_id=:location_id)
            or (icrit.location_id is null))';
    -- derived locale exact match
    l_sql := l_sql||'   AND ((exists(select 1 from irc_location_criteria_values irc_lcv
            where irc_lcv.search_criteria_id=icrit.search_criteria_id
            and :derived_locale=irc_lcv.derived_locale))
            or (not exists (select 1 from  irc_location_criteria_values irc_lcv
                where irc_lcv.search_criteria_id=icrit.search_criteria_id ))
            or (:derived_locale is null))';
    -- This is the section that differs between the two cursors
    -- Competence Match
    l_sql := l_sql||'      AND (:match_competence = ''N''
               OR
                 irc_skills_matching_pkg.vacancy_match_percent
                   ( :vacancy_id
                   , icrit.object_id
                   ) <> ''-1''  -- This means all essential skills are matched
              )';
    -- Qualification
    l_sql := l_sql||'      AND (:match_qualification = ''N''
               OR
                exists (SELECT 1
                          FROM per_qualifications qual
                             , per_qualification_types qty
                         WHERE qual.qualification_type_id
                             = qty.qualification_type_id
                           AND qual.party_id = ppf.party_id
                           AND qty.rank
                               BETWEEN NVL(:min_qual_level,0)
                                   AND NVL(:max_qual_level,qty.rank)
                       )
              OR (:min_qual_level is null and :max_qual_level is null))';
    -- Professional Area
    l_sql := l_sql||'      AND ((exists (select 1 from irc_prof_area_criteria_values irc_pacv
                           where irc_pacv.professional_area = :professional_area
                           and irc_pacv.search_criteria_id=icrit.search_criteria_id))
                OR (not exists (select 1 from irc_prof_area_criteria_values irc_pacv
                           where irc_pacv.search_criteria_id=icrit.search_criteria_id))
                OR :professional_area IS NULL)';
    -- Work At Home Area
    l_sql := l_sql||'      AND (icrit.work_at_home = ''POSSIBLE''
                 OR :work_at_home IS NULL
                 OR icrit.work_at_home IS NULL
                 OR icrit.work_at_home = :work_at_home
              )';

        -- Dynamically add in the Flex attributes matching based on the profile.
    l_last_value := ltrim(substr(l_matching_flex,LENGTH(l_matching_flex)-1,LENGTH(l_matching_flex)),'|');
    l_matching_values := l_matching_flex;
    l_counter := 0;

    while (l_matching_values IS NOT NULL)
    LOOP
          IF (l_last_value = l_matching_values)
          THEN
        l_attribute := 'ATTRIBUTE'||l_matching_values;
            l_matching_values := NULL;
          ELSE
        l_attribute := 'ATTRIBUTE'||substr(l_matching_values,1,instr(l_matching_values, '|')-1);
         l_matching_values := ltrim(ltrim(l_matching_values,substr(l_matching_values,1,instr(l_matching_values, '|')-1)),'|');
          END IF;

      matching_values_tbl(l_counter) := l_attribute;
      l_sql:= l_sql||'   AND ((icrit.'||lower(l_attribute)||
                         ' IS NULL AND :'||l_attribute||
                                         ' IS NULL) OR lower(icrit.'||l_attribute||') = :'||lower(l_attribute)||')  ';
      l_counter := l_counter + 1;

    END LOOP;
    -- USE DBMS SQL so that we can parse the SQL once and bind in the criteria many
        -- times in the inner loop, saving parse time compared to NDS.

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE (c             => l_cursor,
                    statement     => l_sql,
                    language_flag => dbms_sql.native);


    l_base_url := fnd_profile.value('IRC_SUITABLE_SEEKERS_URL');
    IF l_base_url IS NULL THEN
      hr_utility.set_location(l_proc, 20);
      fnd_message.set_name('PER','IRC_412064_NO_EMAIL_VAC_URL');
      RAISE e_no_base_url;
    END IF;
    --
    -- ************************************************************--
    -- Loop through all the outstanding vacancies                   --
    -- ************************************************************--
    FOR available_vacancy IN csr_vacancies_needing_seekers
    LOOP
    begin
      hr_utility.set_location('search_criteria_id:'
                             ||available_vacancy.search_criteria_id, 20);
      --
      log_message ('Vacancy :'
                 ||available_vacancy.name
                 ||' (search_criteria_id:'
                 ||available_vacancy.search_criteria_id
                 ||')'
                 );
      --
      l_internal_site := null;
      l_external_site := null;
      --
      l_internal_site := get_int_rec_site(available_vacancy.vacancy_id);
      l_external_site := get_ext_rec_site(available_vacancy.vacancy_id);
      -- Clear down the table and reset the counter.
      l_seeker_details_tab.delete;
      l_counter := 0;
        -- ************************************************************ --
        -- Get a list of all the suitable seekers for the vacancy       --
        -- ************************************************************ --
        hr_utility.set_location('keywords not null', 30);
             -- define the posting_content_id column

        -- define the name column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 1,
        column      => seeker_details_rec.full_name,
        column_size => 240);

        -- define the object_id column
        DBMS_SQL.DEFINE_COLUMN (
        c           => l_cursor,
        position    => 2,
        column      => seeker_details_rec.person_id);

        -- supply binds (bind by name)
         dbms_sql.bind_variable(
         l_cursor, 'date_registered', l_date_registered);
         dbms_sql.bind_variable(
         l_cursor, 'internal', l_internal_site);
         dbms_sql.bind_variable(
         l_cursor, 'external', l_external_site);
         dbms_sql.bind_variable(
         l_cursor, 'posting_content_id', available_vacancy.primary_posting_id);
         dbms_sql.bind_variable(
         l_cursor, 'vacancy_id', available_vacancy.vacancy_id);
         dbms_sql.bind_variable(
         l_cursor, 'employee', available_vacancy.employee);
         dbms_sql.bind_variable(
         l_cursor, 'contractor', available_vacancy.contractor);
         dbms_sql.bind_variable(
         l_cursor, 'travel_percentage', available_vacancy.travel_percentage);
         dbms_sql.bind_variable(
         l_cursor, 'salary_currency', available_vacancy.salary_currency);
         dbms_sql.bind_variable(
         l_cursor, 'max_salary', available_vacancy.max_salary);
         dbms_sql.bind_variable(
         l_cursor, 'business_group_id', available_vacancy.business_group_id);
         dbms_sql.bind_variable(
         l_cursor, 'employment_category', available_vacancy.employment_category);
         if available_vacancy.keywords is null then
           dbms_sql.bind_variable(
           l_cursor, 'keywords', to_char(null));
         else
           dbms_sql.bind_variable(
           l_cursor, 'keywords', irc_query_parser_pkg.query_parser(available_vacancy.keywords));
         end if;
         dbms_sql.bind_variable(
         l_cursor, 'professional_area', available_vacancy.professional_area);
         dbms_sql.bind_variable(
         l_cursor, 'work_at_home', available_vacancy.work_at_home);
         dbms_sql.bind_variable(
         l_cursor, 'location_id', available_vacancy.location_id);
         dbms_sql.bind_variable(
         l_cursor, 'derived_locale', available_vacancy.derived_locale);
          dbms_sql.bind_variable(
         l_cursor, 'country', available_vacancy.country);
         if available_vacancy.match_qualification is null then
           dbms_sql.bind_variable(
           l_cursor, 'match_qualification', 'N');
         else
           dbms_sql.bind_variable(
           l_cursor, 'match_qualification', available_vacancy.match_qualification);
         end if;
        dbms_sql.bind_variable(
         l_cursor, 'match_competence', available_vacancy.match_competence);
        dbms_sql.bind_variable(
         l_cursor, 'min_qual_level', available_vacancy.min_qual_level);
        dbms_sql.bind_variable(
         l_cursor, 'max_qual_level', available_vacancy.max_qual_level);

         for ct in 0..matching_values_tbl.count-1 loop
           IF (matching_values_tbl(ct)= 'ATTRIBUTE1')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE1', lower(available_vacancy.attribute1));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE2')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE2', lower(available_vacancy.attribute2));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE3')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE3', lower(available_vacancy.attribute3));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE4')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE4', lower(available_vacancy.attribute4));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE5')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE5', lower(available_vacancy.attribute5));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE6')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE6', lower(available_vacancy.attribute6));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE7')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE7', lower(available_vacancy.attribute7));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE8')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE8', lower(available_vacancy.attribute8));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE9')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE9', lower(available_vacancy.attribute9));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE10')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE10', lower(available_vacancy.attribute10));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE11')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE11', lower(available_vacancy.attribute11));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE12')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE12', lower(available_vacancy.attribute12));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE13')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE13', lower(available_vacancy.attribute13));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE14')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE14', lower(available_vacancy.attribute14));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE15')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE15', lower(available_vacancy.attribute15));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE16')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE16', lower(available_vacancy.attribute16));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE17')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE17', lower(available_vacancy.attribute17));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE18')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE18', lower(available_vacancy.attribute18));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE19')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE19', lower(available_vacancy.attribute19));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE20')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE20', lower(available_vacancy.attribute20));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE21')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE21', lower(available_vacancy.attribute21));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE22')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE22', lower(available_vacancy.attribute22));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE23')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE23', lower(available_vacancy.attribute23));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE24')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE24', lower(available_vacancy.attribute24));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE25')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE25', lower(available_vacancy.attribute25));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE26')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE26', lower(available_vacancy.attribute26));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE27')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE27', lower(available_vacancy.attribute27));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE28')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE28', lower(available_vacancy.attribute28));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE29')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE29', lower(available_vacancy.attribute29));

           ELSIF (matching_values_tbl(ct)= 'ATTRIBUTE30')
             THEN dbms_sql.bind_variable(l_cursor, 'ATTRIBUTE30', lower(available_vacancy.attribute30));
           END IF;
        end loop;

        -- execute the cursor
        l_row := DBMS_SQL.EXECUTE (c => l_cursor);

             -- while there is data to fetch
        WHILE DBMS_SQL.FETCH_ROWS (c => l_cursor) <> 0
        LOOP
          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 1,
          value      => seeker_details_rec.full_name);

          DBMS_SQL.column_value (
          c           => l_cursor,
          position    => 2,
          value      => seeker_details_rec.person_id);

          log_message ('..person_id:'||seeker_details_rec.person_id);
          hr_utility.set_location
             (' loop: seeker_details_rec.person_id='
                   || seeker_details_rec.person_id, 35);
          --
          l_counter := l_counter + 1;
          --
          l_seeker_details_tab(l_counter)
              := seeker_details_rec;
          --
        END LOOP;
--dbms_output.put_line('Found '||l_counter||' seekers for '||available_vacancy.name);

        -- ************************************************************ --
        -- Send an e-mail to the vacancy creator with suitable seekers  --
        -- ************************************************************ --
      log_message ('.suitable seekers :'
                 ||l_seeker_details_tab.count);
      IF l_seeker_details_tab.count > 0 THEN
        -- Send the notification if any suitable candidates have been found
        hr_utility.set_location('stuff to send ', 50);
        --
        l_message_subject := null;

        fnd_message.set_name('PER','IRC_EMAIL_RECRUITER_SUBJECT');
        fnd_message.set_token('VACNAME',available_vacancy.name);
        l_message_subject := fnd_message.get;


        --
            l_id := irc_notification_helper_pkg.send_notification
                    ( p_person_id  => available_vacancy.recruiter_id
                    , p_subject   => l_message_subject
                    , p_html_body => get_recruiter_html_msg_body
                               ( p_seeker_details_tab =>l_seeker_details_tab )
                    , p_text_body => get_recruiter_text_msg_body
                               ( p_seeker_details_tab =>l_seeker_details_tab )
                    );
            l_msg_sent := l_msg_sent + 1;
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
--dbms_output.put_line('Problem sending '||available_vacancy.name);
        -- Build up a table of the problem vacancies/recruiters
        l_index :=l_index + 1;
        l_recruiter_problem_tab(l_index).recruiter_id := available_vacancy.recruiter_id;
        l_recruiter_problem_tab(l_index).vacancy_id
                                          := available_vacancy.vacancy_id;
        l_recruiter_problem_tab(l_index).vacancy_name:=available_vacancy.name;
        l_recruiter_problem_tab(l_index).sqlerrm      := sqlerrm;
        l_recruiter_problem_tab(l_index).message      := fnd_message.get;
        --
        END;
      --
    END LOOP;
    --
    fnd_message.set_name ('PER','IRC_412069_NUMBER_MSG_SENT');
    fnd_message.set_token ('NOMSG',l_msg_sent);
    log_message(fnd_message.get);
    --
    IF ( l_index > 0 ) THEN
      -- Maybe have an out parameter that handles these, or put them into
      -- the ERRBUF for concurrent processes.
      hr_utility.set_location('No recruiter_id ',59);
      fnd_message.set_name ('PER','IRC_412070_VACS_NO_OWNERS');
      log_message(fnd_message.get);
      for i in l_recruiter_problem_tab.first .. l_recruiter_problem_tab.last loop
        log_message(l_recruiter_problem_tab(i).vacancy_name);
        hr_utility.set_location('Exception ('||i||')', 60);
        hr_utility.set_location(' > vacancy_id:'  || l_recruiter_problem_tab(i).vacancy_id, 62);
      end loop;
    END IF;
    hr_utility.set_location('Leaving'||l_proc, 80);
  EXCEPTION
  WHEN others THEN
    ERRBUF  := SQLERRM||' '||fnd_message.get;
    RETCODE := 2;
  END get_suitable_seekers_for_vac;
--
--
-- -------------------------------------------------------------------------
-- |-------------------< email_general_notifications >---------------------|
-- -------------------------------------------------------------------------
--
  PROCEDURE email_general_notifications
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
            )
  IS
  --
    l_id  NUMBER;
    l_message_subject      VARCHAR2(240)
                 DEFAULT fnd_message.get_string('PER','IRC_SEEKER_INFO_NOTE_SUBJECT');
    l_general_body_html    VARCHAR2(32000);
    l_general_body_text    VARCHAR2(32000);
    l_proc VARCHAR2(30) default '.email_general_notifications';
  BEGIN
     hr_utility.set_location('Entering'||l_proc, 10);
    -- Loop through all the job seekers and send them
    -- a general notification.
    FOR parties_wanting_it IN csr_seekers_for_notes LOOP
      --
      -- Build the body of the email both in text and html
      --
      fnd_message.set_name ('PER','IRC_SEEKER_INFO_NOTE_HTML');
      fnd_message.set_token ('FIRST_NAME',parties_wanting_it.first_name);
      fnd_message.set_token ('LAST_NAME' ,parties_wanting_it.last_name);
      fnd_message.set_token ('EMAIL_ADDRESS' ,parties_wanting_it.email_address);
      l_general_body_html := fnd_message.get;
      l_general_body_html :='<BR/>'|| l_general_body_html  ||'<BR/><BR/><p align="center">'
                             || get_conclusion_msg(
                                 p_message_text  =>fnd_message.get_string('PER','IRC_412617_GEN_CONCL_HTML')
                                ,p_person_id     =>parties_wanting_it.person_id
                                ,p_action        =>'UG')||'</p>';
      --
      fnd_message.set_name ('PER','IRC_SEEKER_INFO_NOTE_TEXT');
      fnd_message.set_token ('FIRST_NAME',parties_wanting_it.first_name);
      fnd_message.set_token ('LAST_NAME' ,parties_wanting_it.last_name);
      fnd_message.set_token ('EMAIL_ADDRESS' ,parties_wanting_it.email_address);
      l_general_body_text := fnd_message.get;
      l_general_body_text := l_general_body_text ||'\n'
                             || get_conclusion_msg(
                                 p_message_text  =>fnd_message.get_string('PER','IRC_412618_GEN_CONCL_TEXT')
                                ,p_person_id     =>parties_wanting_it.person_id
                                ,p_action        =>'UG');
      --
      begin
        l_id :=
           irc_notification_helper_pkg.send_notification
                    ( p_person_id  => parties_wanting_it.person_id
                    , p_subject   =>  l_message_subject
                    , p_html_body => l_general_body_html
                    , p_text_body => l_general_body_text
                  );
        exception
        when others then
          -- Catch the exception so that an error doens't cause total failure.
          hr_utility.set_location('Problem sending notification to person:'||parties_wanting_it.person_id,60);
        end;
    END LOOP;
    hr_utility.set_location('Leaving'||l_proc, 80);
  END email_general_notifications;

--
 FUNCTION get_conclusion_msg(p_message_text varchar2
                            ,p_person_id    number
                            ,p_action       varchar2 ) return varchar2 as
 --
    l_apps_fwk_agent       varchar2(2000);
    l_isInternalPerson     varchar2(10);
    l_url                  varchar2(4000);
    l_funcId               number;
 --
 cursor c_func(p_function_name varchar2) is
          select function_id from fnd_form_functions
                  where function_name = p_function_name;
 --
 BEGIN
      l_isInternalPerson := irc_utilities_pkg.is_internal_person
                             (p_person_id=> p_person_id,
                              p_eff_date => trunc(sysdate)
                             );
      if (l_isInternalPerson ='TRUE') then
        l_apps_fwk_agent := fnd_profile.value_specific('APPS_FRAMEWORK_AGENT');
      else
        l_apps_fwk_agent := nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),
                                fnd_profile.value('APPS_FRAMEWORK_AGENT'));
      end if;
      --
      l_url := l_apps_fwk_agent;
      --
      if substr(l_url,-1,1)<>'/' then
         l_url:=l_url||'/';
      end if;
      --
      if fnd_profile.value('ICX_PREFIX') is not null then
         l_url:=l_url||fnd_profile.value('ICX_PREFIX')||'/OA_HTML/';
      else
         l_url:=l_url||'OA_HTML/';
      end if;
      --
      open c_func('IRC_UNSUBSCRIB_FUNC');
      fetch c_func into l_funcId;
      close c_func;
      --
      l_url:=   fnd_run_function.get_run_function_url ( p_function_id =>l_funcId,
                                p_resp_appl_id =>-1,
                                p_resp_id =>-1,
                                p_security_group_id =>0,
                                p_override_agent=>l_url,
                                p_parameters =>'personId='||p_person_id||'&action='||p_action,
                                p_encryptParameters =>true ) ;
     --
     l_url := replace(p_message_text,'&IRC_HYPERLINK',l_url);
     --
     return l_url;
 END get_conclusion_msg;
END irc_seeker_vac_matching_pkg;

/
