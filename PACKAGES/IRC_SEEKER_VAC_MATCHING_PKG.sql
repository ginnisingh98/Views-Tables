--------------------------------------------------------
--  DDL for Package IRC_SEEKER_VAC_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SEEKER_VAC_MATCHING_PKG" 
/* $Header: irjsmtch.pkh 120.3.12010000.3 2009/12/18 07:18:20 amikukum ship $ */
AUTHID CURRENT_USER AS
-- ----------------------------------------------------------------------------
-- RECORD AND TABLE STRUCTURES
-- ----------------------------------------------------------------------------
TYPE g_seeker_rec_type
IS RECORD ( person_id            irc_notification_preferences.person_id%TYPE
          , party_id             per_all_people_f.party_id%type
          , show_jobs_since      NUMBER
          , lang_pref            varchar2(100)
          );
TYPE g_seeker_criteria_rec_type
IS RECORD ( search_criteria_id   irc_search_criteria.search_criteria_id%TYPE
          , person_id            irc_search_criteria.object_id%TYPE
          , party_id             per_all_people_f.party_id%type
          , distance_to_location irc_search_criteria.distance_to_location%TYPE
          , location             irc_search_criteria.location%TYPE
          , employee             irc_search_criteria.employee%TYPE
          , contractor           irc_search_criteria.contractor%TYPE
          , employment_category  irc_search_criteria.employment_category%TYPE
          , keywords             irc_search_criteria.keywords%TYPE
          , travel_percentage    irc_search_criteria.travel_percentage%TYPE
          , min_salary           irc_search_criteria.min_salary%TYPE
          , salary_currency      irc_search_criteria.salary_currency%TYPE
          , salary_period        irc_search_criteria.salary_period%TYPE
          , match_competence     irc_search_criteria.match_competence%TYPE
          , match_qualification  irc_search_criteria.match_qualification%TYPE
          , job_title            irc_search_criteria.job_title%TYPE
          , department           irc_search_criteria.department%TYPE
          , professional_area    irc_search_criteria.professional_area%TYPE
          , work_at_home         irc_search_criteria.work_at_home%TYPE
          , attribute1           irc_search_criteria.attribute1%TYPE
          , attribute2           irc_search_criteria.attribute2%TYPE
          , attribute3           irc_search_criteria.attribute3%TYPE
          , attribute4           irc_search_criteria.attribute4%TYPE
          , attribute5           irc_search_criteria.attribute5%TYPE
          , attribute6           irc_search_criteria.attribute6%TYPE
          , attribute7           irc_search_criteria.attribute7%TYPE
          , attribute8           irc_search_criteria.attribute8%TYPE
          , attribute9           irc_search_criteria.attribute9%TYPE
          , attribute10          irc_search_criteria.attribute10%TYPE
          , attribute11          irc_search_criteria.attribute11%TYPE
          , attribute12          irc_search_criteria.attribute12%TYPE
          , attribute13          irc_search_criteria.attribute13%TYPE
          , attribute14          irc_search_criteria.attribute14%TYPE
          , attribute15          irc_search_criteria.attribute15%TYPE
          , attribute16          irc_search_criteria.attribute16%TYPE
          , attribute17          irc_search_criteria.attribute17%TYPE
          , attribute18          irc_search_criteria.attribute18%TYPE
          , attribute19          irc_search_criteria.attribute19%TYPE
          , attribute20          irc_search_criteria.attribute20%TYPE
          , attribute21          irc_search_criteria.attribute21%TYPE
          , attribute22          irc_search_criteria.attribute22%TYPE
          , attribute23          irc_search_criteria.attribute23%TYPE
          , attribute24          irc_search_criteria.attribute24%TYPE
          , attribute25          irc_search_criteria.attribute25%TYPE
          , attribute26          irc_search_criteria.attribute26%TYPE
          , attribute27          irc_search_criteria.attribute27%TYPE
          , attribute28          irc_search_criteria.attribute28%TYPE
          , attribute29          irc_search_criteria.attribute29%TYPE
          , attribute30          irc_search_criteria.attribute30%TYPE
          , isc_information1     irc_search_criteria.isc_information1%TYPE
          , isc_information2     irc_search_criteria.isc_information2%TYPE
          , isc_information3     irc_search_criteria.isc_information3%TYPE
          , isc_information4     irc_search_criteria.isc_information4%TYPE
          , isc_information5     irc_search_criteria.isc_information5%TYPE
          , isc_information6     irc_search_criteria.isc_information6%TYPE
          , isc_information7     irc_search_criteria.isc_information7%TYPE
          , isc_information8     irc_search_criteria.isc_information8%TYPE
          , isc_information9     irc_search_criteria.isc_information9%TYPE
          , isc_information10    irc_search_criteria.isc_information10%TYPE
          , isc_information11    irc_search_criteria.isc_information11%TYPE
          , isc_information12    irc_search_criteria.isc_information12%TYPE
          , isc_information13    irc_search_criteria.isc_information13%TYPE
          , isc_information14    irc_search_criteria.isc_information14%TYPE
          , isc_information15    irc_search_criteria.isc_information15%TYPE
          , isc_information16    irc_search_criteria.isc_information16%TYPE
          , isc_information17    irc_search_criteria.isc_information17%TYPE
          , isc_information18    irc_search_criteria.isc_information18%TYPE
          , isc_information19    irc_search_criteria.isc_information19%TYPE
          , isc_information20    irc_search_criteria.isc_information20%TYPE
          , isc_information21    irc_search_criteria.isc_information21%TYPE
          , isc_information22    irc_search_criteria.isc_information22%TYPE
          , isc_information23    irc_search_criteria.isc_information23%TYPE
          , isc_information24    irc_search_criteria.isc_information24%TYPE
          , isc_information25    irc_search_criteria.isc_information25%TYPE
          , isc_information26    irc_search_criteria.isc_information26%TYPE
          , isc_information27    irc_search_criteria.isc_information27%TYPE
          , isc_information28    irc_search_criteria.isc_information28%TYPE
          , isc_information29    irc_search_criteria.isc_information29%TYPE
          , isc_information30    irc_search_criteria.isc_information30%TYPE
          , geometry             irc_search_criteria.geometry%TYPE
          , location_id          irc_search_criteria.location_id%TYPE
          , derived_location     irc_search_criteria.derived_location%TYPE
          , show_jobs_since      NUMBER
          );
TYPE g_email_party_rec_type
IS RECORD ( search_criteria_id   irc_search_criteria.search_criteria_id%TYPE
          , vacancy_id            irc_search_criteria.object_id%TYPE
          , distance_to_location irc_search_criteria.distance_to_location%TYPE
          , location             irc_search_criteria.location%TYPE
          , employee             irc_search_criteria.employee%TYPE
          , contractor           irc_search_criteria.contractor%TYPE
          , employment_category  irc_search_criteria.employment_category%TYPE
          , keywords             irc_search_criteria.keywords%TYPE
          , travel_percentage    irc_search_criteria.travel_percentage%TYPE
          , min_salary           irc_search_criteria.min_salary%TYPE
          , salary_currency      irc_search_criteria.salary_currency%TYPE
          , salary_period        irc_search_criteria.salary_period%TYPE
          , match_competence     irc_search_criteria.match_competence%TYPE
          , match_qualification  irc_search_criteria.match_qualification%TYPE
          , min_qual_level       irc_search_criteria.min_qual_level%TYPE
          , max_qual_level       irc_search_criteria.max_qual_level%TYPE
          , job_title            irc_search_criteria.job_title%TYPE
          , department           irc_search_criteria.department%TYPE
          , professional_area    irc_search_criteria.professional_area%TYPE
          , work_at_home         irc_search_criteria.work_at_home%TYPE
          , attribute1           irc_search_criteria.attribute1%TYPE
          , attribute2           irc_search_criteria.attribute2%TYPE
          , attribute3           irc_search_criteria.attribute3%TYPE
          , attribute4           irc_search_criteria.attribute4%TYPE
          , attribute5           irc_search_criteria.attribute5%TYPE
          , attribute6           irc_search_criteria.attribute6%TYPE
          , attribute7           irc_search_criteria.attribute7%TYPE
          , attribute8           irc_search_criteria.attribute8%TYPE
          , attribute9           irc_search_criteria.attribute9%TYPE
          , attribute10          irc_search_criteria.attribute10%TYPE
          , attribute11          irc_search_criteria.attribute11%TYPE
          , attribute12          irc_search_criteria.attribute12%TYPE
          , attribute13          irc_search_criteria.attribute13%TYPE
          , attribute14          irc_search_criteria.attribute14%TYPE
          , attribute15          irc_search_criteria.attribute15%TYPE
          , attribute16          irc_search_criteria.attribute16%TYPE
          , attribute17          irc_search_criteria.attribute17%TYPE
          , attribute18          irc_search_criteria.attribute18%TYPE
          , attribute19          irc_search_criteria.attribute19%TYPE
          , attribute20          irc_search_criteria.attribute20%TYPE
          , attribute21          irc_search_criteria.attribute21%TYPE
          , attribute22          irc_search_criteria.attribute22%TYPE
          , attribute23          irc_search_criteria.attribute23%TYPE
          , attribute24          irc_search_criteria.attribute24%TYPE
          , attribute25          irc_search_criteria.attribute25%TYPE
          , attribute26          irc_search_criteria.attribute26%TYPE
          , attribute27          irc_search_criteria.attribute27%TYPE
          , attribute28          irc_search_criteria.attribute28%TYPE
          , attribute29          irc_search_criteria.attribute29%TYPE
          , attribute30          irc_search_criteria.attribute30%TYPE
          , isc_information1     irc_search_criteria.isc_information1%TYPE
          , isc_information2     irc_search_criteria.isc_information2%TYPE
          , isc_information3     irc_search_criteria.isc_information3%TYPE
          , isc_information4     irc_search_criteria.isc_information4%TYPE
          , isc_information5     irc_search_criteria.isc_information5%TYPE
          , isc_information6     irc_search_criteria.isc_information6%TYPE
          , isc_information7     irc_search_criteria.isc_information7%TYPE
          , isc_information8     irc_search_criteria.isc_information8%TYPE
          , isc_information9     irc_search_criteria.isc_information9%TYPE
          , isc_information10    irc_search_criteria.isc_information10%TYPE
          , isc_information11    irc_search_criteria.isc_information11%TYPE
          , isc_information12    irc_search_criteria.isc_information12%TYPE
          , isc_information13    irc_search_criteria.isc_information13%TYPE
          , isc_information14    irc_search_criteria.isc_information14%TYPE
          , isc_information15    irc_search_criteria.isc_information15%TYPE
          , isc_information16    irc_search_criteria.isc_information16%TYPE
          , isc_information17    irc_search_criteria.isc_information17%TYPE
          , isc_information18    irc_search_criteria.isc_information18%TYPE
          , isc_information19    irc_search_criteria.isc_information19%TYPE
          , isc_information20    irc_search_criteria.isc_information20%TYPE
          , isc_information21    irc_search_criteria.isc_information21%TYPE
          , isc_information22    irc_search_criteria.isc_information22%TYPE
          , isc_information23    irc_search_criteria.isc_information23%TYPE
          , isc_information24    irc_search_criteria.isc_information24%TYPE
          , isc_information25    irc_search_criteria.isc_information25%TYPE
          , isc_information26    irc_search_criteria.isc_information26%TYPE
          , isc_information27    irc_search_criteria.isc_information27%TYPE
          , isc_information28    irc_search_criteria.isc_information28%TYPE
          , isc_information29    irc_search_criteria.isc_information29%TYPE
          , isc_information30    irc_search_criteria.isc_information30%TYPE
          , geometry             hr_locations_all.geometry%TYPE
          , location_id          per_all_vacancies.location_id%TYPE
          , derived_locale       hr_locations_all.derived_locale%TYPE
          , posting_content_id   irc_posting_contents_tl.posting_content_id%TYPE
          , business_group_id    per_all_vacancies.business_group_id%TYPE
          , name                 per_all_vacancies.name%TYPE
          , recruiter_id         per_all_vacancies.recruiter_id%type
);

TYPE g_posting_details_rec_type
IS RECORD ( posting_content_id    irc_posting_contents.posting_content_id%TYPE
          , job_title             irc_posting_contents_tl.job_title%TYPE
          , name                  irc_posting_contents_tl.name%TYPE
          , object_id             irc_search_criteria.object_id%TYPE
          );
TYPE g_posting_details_tab_type
IS TABLE OF
         g_posting_details_rec_type
INDEX BY BINARY_INTEGER;

TYPE g_seeker_details_rec_type
IS RECORD ( full_name           per_all_people_f.full_name%TYPE
          , person_id           per_all_people_f.person_id%TYPE
          );
TYPE g_seeker_details_tab_type
IS TABLE OF
         g_seeker_details_rec_type
INDEX BY BINARY_INTEGER;

TYPE g_recruiter_problem_rec_type
IS RECORD ( recruiter_id      per_all_vacancies.recruiter_id%TYPE
          , vacancy_id        per_all_vacancies.vacancy_id%TYPE
          , vacancy_name      per_all_vacancies.name%TYPE
          , sqlerrm           varchar2(2000)
          , message           varchar2(2000)
          );

TYPE g_recruiter_problem_tab_type
IS TABLE OF g_recruiter_problem_rec_type
INDEX BY BINARY_INTEGER;
-- ----------------------------------------------------------------------------
-- CURSORS
-- ----------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------------------------------
FUNCTION get_location_match
  ( p_location_to_match   IN  varchar2,
    p_location_id         IN  hr_locations_all.LOCATION_ID%TYPE)
RETURN number;

FUNCTION convert_vacancy_amount
        (p_from_currency     IN VARCHAR2
        ,p_to_currency       IN VARCHAR2
        ,p_amount            IN NUMBER
        ,p_conversion_date   IN DATE
        ,p_business_group_id IN NUMBER
        ,p_processing_type   IN VARCHAR2)
RETURN NUMBER;

FUNCTION get_job_notification_function
  ( p_is_internal     IN varchar2)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- PROCEDURES
-- ----------------------------------------------------------------------------
  PROCEDURE log_message
           ( p_message IN VARCHAR2
           , p_type    IN VARCHAR2 DEFAULT 'B'
           );
-- ----------------------------------------------------------------------------
-- Name :
--     email_suitable_vacs_to_seekers
-- Description :
--     This procedure initially finds all the job seekers who are eligible to
--     receive a vacancy notification e-mail by checking how often they want to
--     be sent an email notification against when they last received an email.
--     For those seekers who are due to receive an email, it searches through
--     the available vacancies for those which match their search criteria
--     and which are new since the last time they were sent an email.
-- Customizations
--     Certain parts of the email message sent to the jobs seekers can be
--     altered by changing the text in the following messages:
--       IRC_EMAIL_SEEKERS_SUBJECT - the text to appear in the msg subject line
--       IRC_EMAIL_SEEKERS_INTRODUCTION - html displayed at the top of the email
--       IRC_EMAIL_SEEKERS_CONCLUSION - html displayed at the end of the email
--     The base URL which all the vacancies have is held in profile option:
--       IRC_JOB_NOTIFICATION_URL
--   Parameters :
--     errbuf   Two 'OUT' parameters are needed to pass info back to the
--              concurrent manager.errbuf is used to pass an error message back.
--     retcode  The second parameters used to pass information back to the
--              concurrent manager, retcode, passes one of the following codes
--              back : '0' or null=success; '1' = a warning; '2' = an error.
--     p_ignore_seeker_matching_freq   values : 'Y' or 'N'.
--              If 'Y', all job seekers who wish to be sent email notifications
--              will be matched and sent an email irrespective of whether they
--              are due to receive one.
--     p_ignore_job_age    values : 'Y' or 'N'.
--              If 'Y', all vacancies that match will be sent, not just the new
--              ones created since the seeker was last sent an email
--
  PROCEDURE email_suitable_vacs_to_seekers
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
             , p_ignore_seeker_matching_freq  IN VARCHAR2 DEFAULT 'N'
             , p_ignore_job_age               IN VARCHAR2 DEFAULT 'N'
            );

--     p_candidacy_age
--              If this is not 0, it will limit the suitable seekers to those
--              who have registered within this number of days
  PROCEDURE get_suitable_seekers_for_vac
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
             , p_candidacy_age                IN NUMBER   DEFAULT 0
            );
-- ----------------------------------------------------------------------------
-- Name
--   email_general_notifications
-- Description :
--     This procedure sends notifications and emails to job seekers who have
--     requested to receive them.
--
-- Customizations
--     Certain parts of the email message sent to the jobs seekers can be
--     altered by changing the text in the following messages:
--       IRC_GENERAL_NOTE_SUBJECT - the text to appear in the msg subject line
--       IRC_GENERAL_NOTE_CONTENT_TEXT - Text version of the body of the mail
--       IRC_GENERAL_NOTE_CONTENT_HTML - html version of the body of the mail
--   Parameters :
--     errbuf   Two 'OUT' parameters are needed to pass info back to the
--              concurrent manager.errbuf is used to pass an error message back.
--     retcode  The second parameters used to pass information back to the
--              concurrent manager, retcode, passes one of the following codes
--              back : '0' or null=success; '1' = a warning; '2' = an error.
--
  PROCEDURE email_general_notifications
            (  errbuf    OUT NOCOPY VARCHAR2
             , retcode   OUT NOCOPY NUMBER
            );
--
 FUNCTION get_conclusion_msg(p_message_text varchar2
                            ,p_person_id    number
                            ,p_action       varchar2 ) return varchar2 ;
--
END irc_seeker_vac_matching_pkg;

/
