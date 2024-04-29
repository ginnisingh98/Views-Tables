--------------------------------------------------------
--  DDL for Package HR_WPM_MASS_APR_PUSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPM_MASS_APR_PUSH" AUTHID CURRENT_USER AS
/* $Header: pewpmaprpush.pkh 120.3.12010000.3 2010/02/01 08:12:37 rvagvala ship $ */
  --
  -- Package global constants.
  --
   g_no_debug      CONSTANT NUMBER          := 0;
   g_pipe          CONSTANT NUMBER          := 1;
   g_fnd_log       CONSTANT NUMBER          := 2;
   --
   g_regular_log   CONSTANT NUMBER          := 1;
   g_debug_log     CONSTANT NUMBER          := 2;
   --
   success         CONSTANT NUMBER          := 0;
   warning         CONSTANT NUMBER          := 1;
   error           CONSTANT NUMBER          := 2;
   --
   -- Package global variables.
   --
   g_errbuf                 VARCHAR2 (2000);
   g_retcode                NUMBER;

--
-- ----------------------------------------------------------------------------
-- |---------------------< submit_apprisal_cp >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan APIs and concurrent program
--              calls this procedure.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
   PROCEDURE submit_appraisal_cp (
    p_effective_date        in     date
   ,p_start_date            in     varchar2
   ,p_plan_id               in     number
   ,p_appraisal_period_id   in     number
   ,p_log_output            in     varchar2
   );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< appraisal_cp >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan APIs and concurrent program
--              calls this procedure.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
procedure appraisal_cp
  (errbuf                      out  nocopy varchar2
  ,retcode                     out  nocopy number
  ,p_effective_date            in   varchar2
  ,p_plan_id                   in   number
  ,p_appraisal_period_id       in   number
  ,p_log_output                in   varchar2    default 'N'
  ,p_delete_pending_trans      IN   VARCHAR2    DEFAULT 'N'
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< appraisal_push>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan APIs and concurrent program
--              calls this procedure.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
procedure appraisal_push
  (p_effective_date            in   date
  ,p_plan_id                   in   number
  ,p_appraisal_period_id       in   number
  ,p_log_output                in   varchar2
   );

--

   -- ----------------------------------------------------------------------------
-- |----------------------< create_appraisal_for_person >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Creates Appraisal for a given person when plan is published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if Appraisal is created.
--
-- Post Failure:
--  An application error is raised if scorecard is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_appraisal_for_person
     ( p_score_card_id per_personal_scorecards.scorecard_id%TYPE,
      p_appraisal_templ_id                          per_appraisal_templates.appraisal_template_id%TYPE,
      p_effective_date                              DATE,
      p_appraisal_start_date                        DATE,
      p_appraisal_end_date                          DATE,
      p_appraisal_status                            per_appraisals.status%TYPE DEFAULT 'PLANNED',
      p_type                                        per_appraisals.TYPE%TYPE DEFAULT NULL,
      p_appraisal_date                              per_appraisals.appraisal_date%TYPE,
--       p_appraisal_system_status per_appraisals.appraisal_system_status%TYPE,
      p_plan_id                                     NUMBER,
       p_next_appraisal_date per_appraisals.next_appraisal_date%TYPE default
null,
      p_status                                      per_appraisals.status%TYPE DEFAULT NULL,
      p_comments                                    per_appraisals.comments%TYPE DEFAULT NULL,
       p_appraisee_access per_appraisals.appraisee_access%TYPE default null,
      p_appraisal_initiator                         per_appraisal_periods.initiator_code%TYPE,
      p_appraisal_system_type       IN              per_appraisal_periods.appraisal_system_type%TYPE,
      p_participation_type          IN              per_appraisal_periods.participation_type%TYPE DEFAULT NULL,
      p_questionnaire_template_id   IN              per_appraisal_periods.questionnaire_template_id%TYPE DEFAULT NULL,
      p_return_status               OUT NOCOPY      VARCHAR2
   );



-- WPM Logging Changes code Start :

l_current_wpm_batch_action_id  per_wpm_person_actions.wpm_batch_action_id%TYPE;

-- Used for Logging the error/Warning/Eligibility Information of each assignment/scorecard/person
   TYPE g_wpm_person_actions_r IS RECORD (
      wpm_person_action_id    per_wpm_person_actions.wpm_person_action_id%TYPE,
      wpm_batch_action_id     per_wpm_person_actions.wpm_batch_action_id%TYPE,
      person_id               per_wpm_person_actions.person_id%TYPE,
      assignment_id           per_wpm_person_actions.assignment_id%TYPE,
      business_group_id       per_wpm_person_actions.business_group_id%TYPE,
      processing_status       per_wpm_person_actions.processing_status%TYPE,
      eligibility_status      per_wpm_person_actions.eligibility_status%TYPE,
      MESSAGE_TYPE            per_wpm_person_actions.MESSAGE_TYPE%TYPE,
      message_number          per_wpm_person_actions.message_number%TYPE,
      MESSAGE_TEXT            per_wpm_person_actions.MESSAGE_TEXT%TYPE,
      transaction_ref_table   per_wpm_person_actions.transaction_ref_table%TYPE,
      transaction_ref_id      per_wpm_person_actions.transaction_ref_id%TYPE,
      information_category    per_wpm_person_actions.information_category%TYPE,
      information1            per_wpm_person_actions.information1%TYPE,
      information2            per_wpm_person_actions.information2%TYPE,
      information3            per_wpm_person_actions.information3%TYPE,
      information4            per_wpm_person_actions.information4%TYPE,
      information5            per_wpm_person_actions.information5%TYPE,
      information6            per_wpm_person_actions.information6%TYPE,
      information7            per_wpm_person_actions.information7%TYPE,
      information8            per_wpm_person_actions.information8%TYPE,
      information9            per_wpm_person_actions.information9%TYPE,
      information10           per_wpm_person_actions.information10%TYPE,
      information11           per_wpm_person_actions.information11%TYPE,
      information12           per_wpm_person_actions.information12%TYPE,
      information13           per_wpm_person_actions.information13%TYPE,
      information14           per_wpm_person_actions.information14%TYPE,
      information15           per_wpm_person_actions.information15%TYPE,
      information16           per_wpm_person_actions.information16%TYPE,
      information17           per_wpm_person_actions.information17%TYPE,
      information18           per_wpm_person_actions.information18%TYPE,
      information19           per_wpm_person_actions.information19%TYPE,
      information20           per_wpm_person_actions.information20%TYPE
   );

   TYPE g_wpm_person_actions_t IS TABLE OF g_wpm_person_actions_r
      INDEX BY BINARY_INTEGER;

   g_wpm_person_actions          g_wpm_person_actions_t;

   -- log_records_index Ponts to the current record in the g_wpm_person_actions Table
   -- whose log information has to be updated
   log_records_index   NUMBER;

   PROCEDURE print_cache;


-- WPM Logging Changes code End



END hr_wpm_mass_apr_push;

/
