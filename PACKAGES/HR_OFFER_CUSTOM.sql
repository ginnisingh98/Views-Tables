--------------------------------------------------------
--  DDL for Package HR_OFFER_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OFFER_CUSTOM" AUTHID CURRENT_USER as
/* $Header: hrcustwf.pkh 115.5 2002/12/09 19:57:27 hjonnala ship $ */
-- ----------------------------------------------------------------------------
-- This is the generic product version
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_wf_question_status >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return true if an active workflow exists using the
--   question passed in.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_proposal_question_name   -> The name of the question. This is one of the
--   questions which is hardcoded in the hr_letter program.
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure can be customized (eg. May change so validates for a
--   workflow at any time in history that uses this question. Because if
--   we allow questions to be changed then past offer letters may look strange.)
--
-- Access Status:
--   Called from hr_update_questions_web.
--
-- ----------------------------------------------------------------------------
--
function check_wf_question_status (p_proposal_question_name varchar2)
                                   return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_hr_routing1 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the HR Routing 1 person
--
-- Pre Conditions:
--   The current hiring manager must exist.
--
-- In Arguments:
--   p_person_id   -> The person_id of the hiring manager.
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from workflow/offer letter generation.
--
-- ----------------------------------------------------------------------------
function get_hr_routing1
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_hr_routing2 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the HR Routing 2 person
--
-- Pre Conditions:
--   The current hiring manager must exist.
--
-- In Arguments:
--   p_person_id   -> The person_id of the hiring manager.
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from workflow/offer letter generation.
--
-- ----------------------------------------------------------------------------
function get_hr_routing2
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_hr_routing3 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the HR Routing 3 person
--
-- Pre Conditions:
--   The current hiring manager must exist.
--
-- In Arguments:
--   p_person_id   -> The person_id of the hiring manager.
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from workflow/offer letter generation.
--
-- ----------------------------------------------------------------------------
function get_hr_routing3
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_candidate_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will return the person_id and p_candidate_disp_name
--   (first name + <space> + last name) for a given assignment_id as of the
--   system date.
--
-- Pre Conditions:
--   The assignment must exist
--
-- In Arguments:
--   p_candidate_assignment_id   -> The assignment_id of the candidate
--                                  (applicant).
--
-- Post Success:
--   If the assignment exists, the out parameters p_candidate_person_id and
--   p_candidate_disp_name will be set accordingly.
--   If the assignment does not exist, the out parameters are set to null.
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure currently works of the system date (i.e. sysdate). This is
--   intentional behaviour but in future may change to accept the effective
--   date as an in parameter.
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
procedure get_candidate_details
      (p_candidate_assignment_id in     per_assignments_f.assignment_id%type
      ,p_candidate_person_id        out nocopy per_people_f.person_id%type
      ,p_candidate_disp_name        out nocopy varchar2
      ,p_applicant_number           out nocopy per_people_f.applicant_number%type);
-- ----------------------------------------------------------------------------
-- |-------------------------< get_hr_manager_details >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the HR manager
--   for the specified hiring manager person.
--
-- Pre Conditions:
--   The current hiring manager must exist.
--
-- In Arguments:
--   p_person_id   -> The person_id of the hiring manager.
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from offer letter generation.
--
-- ----------------------------------------------------------------------------
function get_hr_manager_details
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ----------------------------------------------------------------------------
-- |---------------------< set_training_admin_person >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the Training Administrator
--
-- Pre Conditions:
--   The current training administrator must exist.
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from offer letter generation.
--
-- ----------------------------------------------------------------------------
function set_training_admin_person
         return number;
-- ----------------------------------------------------------------------------
-- |---------------------< set_supervisor_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the a persons supervisor
--
-- Pre Conditions:
--   A supervisor must exist. If not return null.
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from offer letter generation.
--
-- ----------------------------------------------------------------------------
function set_supervisor_id (p_person_id in per_all_people_f.person_id%type)
         return per_all_people_f.person_id%type ;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_next_approver >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return the person_id of the next approver/supervisor
--   for the specified person. If an approver does not exist, null is returned.
--
-- Pre Conditions:
--   The current approver p_person_id must exist.
--
-- In Arguments:
--   p_person_id   -> The person_id of the current approver.
--
-- Post Success:
--   If the current person has an approver/supervisor then the supervisor
--   person_id is returned. If a supervisor cannot be found then null is
--   returned.
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
function get_next_approver
           (p_person_id in per_people_f.person_id%type)
         return per_people_f.person_id%type;
-- ------------------------------------------------------------------------
-- |---------------------< get_url_string >----------------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--   This procedure returns the url string needed to build up urls when
--   running disconnected from the web server (such as from email for
--   workflow notifications).
-- ------------------------------------------------------------------------
function get_url_string
         return varchar2;
-- ------------------------------------------------------------------------
-- |---------------------< get_vp_name >----------------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--   This procedure obtains the name of the Vice President that the
--   candidate will report to.  It goes up the approval chain for a
--   candidate and finds the first person with a job name like '%Vice%'
--   Obviously this won't work in the police field.
--
-- Pre Conditions:
--   Insert a row into fnd_sessions for date tracked tables.
--
-- In Arguments:
-- Name                    Reqd   Type       Description
-- p_assignment_id         Yes    number     Assignment ID of the candidate.
--
--
-- Post Success:
-- Out Arguments:
-- p_vp_name                      varchar2   first_name || last_name for VP
-- p_job_name                     varchar2   vice president's job name
--
-- Post Failure:
--   If the procedure can not find a vice president, it returns null and the
--   calling module is expected to either give an error or display nothing,
--   depending upon the business need.
--
-- Developer Implementation Notes:
--
-- Access Status:
--
-- -----------------------------------------------------------------------------
procedure get_vp_name
      (p_assignment_id      in  number
      ,p_vp_name            out nocopy varchar2
      ,p_job_name           out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_final_approver >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return a varchar2(1) value. 'Y' is returned if the
--   forwarding manager is the TOP approver for the specified candidate.
--   'N' is returned if the forwarding manager is NOT the TOP approver.
--   'E' is returned if the program can not find the top approver.
--
-- Pre Conditions:
--   The candidate and forward to manager's exist.
--
-- In Arguments:
--   p_candidate_assignment_id -> The assignment_id of the candidate.
--   p_fwd_to_mgr_id      -> The person_id of the forwarding to manager (current
--                           approver).
--   p_person_id          -> The person_id of the hiring mgr.
--
-- Post Success:
--   'Y', 'N' or 'E' (for error) will be returned.
--
-- Post Failure:
--   This function should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
function check_final_approver
           (p_candidate_assignment_id in per_assignments_f.assignment_id%type
           ,p_fwd_to_mgr_id           in per_people_f.person_id%type
           ,p_person_id               in per_people_f.person_id%type)
         return varchar2;
-- ----------------------------------------------------------------------------
-- |-----------------------< check_if_in_approval_chain >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return a boolean value. TRUE is returned if the
--   person specified is in the approval chain.
--   FALSE is returned if the person is NOT in the chain.
--
-- Pre Conditions:
--   The person must exist.
--
-- In Arguments:
--   p_candidate_assignment_id -> The assignment_id of the candidate.
--   p_fwd_to_mgr_id           -> The person_id who is being checked
--
-- Post Success:
--   TRUE or FALSE will be returned.
--
-- Post Failure:
--   This function should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
function check_if_in_approval_chain
           (p_person_id               in per_people_f.person_id%type
           ,p_candidate_assignment_id in per_assignments_f.assignment_id%type)
         return boolean;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_signatories_details >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This function will return a offer letter signatories for the specified
--   hiring manager and candidate.
--
-- Pre Conditions:
--   The person and candidate must exist.
--
-- In Arguments:
--   p_candidate_assignment_id -> The assignment_id of the candidate.
--   p_person_id               -> The person_id of the hiring manager.
--
-- Post Success:
--   The OUT arguments p_signatory_id1..3 will be optionally set with the
--   person_id's and position title.
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--   This procedure can be customized.
--
-- Access Status:
--   Called from offer letter generation.
--
-- ----------------------------------------------------------------------------
procedure get_signatories_details
            (p_person_id               in  per_people_f.person_id%type
            ,p_candidate_assignment_id in  per_assignments_f.assignment_id%type
            ,p_signatory_id1           out nocopy per_people_f.person_id%type
            ,p_position_title1         out nocopy varchar2
            ,p_signatory_id2           out nocopy per_people_f.person_id%type
            ,p_position_title2         out nocopy varchar2
            ,p_signatory_id3           out nocopy per_people_f.person_id%type
            ,p_position_title3         out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_status_to_offer >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will call the hr_assignment_api.offer_apl_asg to update the
--   status on the applicant assignment to OFFER.
--
-- Pre Conditions:
--   The applicant must exist.
--
-- In Arguments:
--   p_candidate_assignment_id   -> The assignment_id of the candidate
--                                  (applicant).
-- Post Success:
--   The applicant assignment will be updated to the OFFER status.
--
-- Post Failure:
--   The API will raise an error which will be trapped and reported by
--   workflow.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
procedure set_status_to_offer
          (p_candidate_assignment_id in per_assignments_f.assignment_id%type);
-- ----------------------------------------------------------------------------
-- |--------------------------< set_status_to_sent >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure will call the hr_assignment_api.offer_apl_asg to update the
--   status on the applicant assignment to a customized Offer Sent status
--
-- Pre Conditions:
--   The applicant must exist.
--
-- In Arguments:
--   p_candidate_assignment_id   -> The assignment_id of the candidate
--                                  (applicant).
-- Post Success:
--   The applicant assignment will be updated to the OFFER status.
--
-- Post Failure:
--   The API will raise an error which will be trapped and reported by
--   workflow.
--
-- Developer Implementation Notes:
--
--
-- Access Status:
--   Called from workflow.
--
-- ----------------------------------------------------------------------------
procedure set_status_to_sent
          (p_candidate_assignment_id in per_assignments_f.assignment_id%type);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_attachment >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_attachment
     (p_attachment_text    in  long default null
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_attached_document_id  out nocopy
          fnd_attached_documents.attached_document_id%TYPE
     ,p_document_id           out nocopy fnd_documents.document_id%TYPE
     ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
     ,p_rowid                 out nocopy varchar2
     ,p_login_person_id    in  number);     -- 10/14/97 Changed

-- ----------------------------------------------------------------------------
-- |--------------------------< update_attachment >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_attachment
     (p_attachment_text    in  long default null
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_rowid              in varchar2
     ,p_login_person_id    in  number);     -- 10/14/97 Changed

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attachment >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_attachment
     (p_attachment_text    out nocopy long
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_effective_date     in varchar2
     ,p_attached_document_id  out nocopy
          fnd_attached_documents.attached_document_id%TYPE
     ,p_document_id           out nocopy fnd_documents.document_id%TYPE
     ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
     ,p_rowid                 out nocopy varchar2
     ,p_category_id           out nocopy fnd_documents.category_id%type
     ,p_seq_num               out nocopy fnd_attached_documents.seq_num%type);

-- ----------------------------------------------------------------------------
-- |--------------------------< validate_phone_format >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure validate_phone_format
     (p_phone_num_in      in   varchar2
     ,p_country_code      in   varchar2 default 'US'
     ,p_phone_num_out     out nocopy  varchar2
     ,p_phone_format_err  out nocopy varchar2);
--
--
end hr_offer_custom;

 

/
