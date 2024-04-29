--------------------------------------------------------
--  DDL for Package HR_PERF_MGMT_PLAN_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERF_MGMT_PLAN_INTERNAL" AUTHID CURRENT_USER as
/* $Header: pepmpbsi.pkh 120.8.12010000.4 2009/07/14 06:39:01 rvagvala ship $ */
  --
  -- Package global constants.
  --
  g_NO_DEBUG     CONSTANT NUMBER := 0;
  g_PIPE         CONSTANT NUMBER := 1;
  g_FND_LOG      CONSTANT NUMBER := 2;
  --
  g_REGULAR_LOG  CONSTANT NUMBER := 1;
  g_DEBUG_LOG  CONSTANT NUMBER   := 2;
  --

  SUCCESS CONSTANT NUMBER := 0;
  WARNING CONSTANT NUMBER := 1;
  ERROR   CONSTANT NUMBER := 2;
  --
  -- Package global variables.
  --
  g_errbuf        VARCHAR2(2000);
  g_retcode       NUMBER;

/*
  function get_appraisal_config_params(p_appr_initiator_code in per_appraisal_periods.initiator_code%TYPE,
                                    p_function_id in out nocopy fnd_form_functions.function_id%TYPE,
                                    p_function_name in out nocopy fnd_form_functions.function_name%TYPE,
                                    p_func_parameters in out nocopy fnd_form_functions.parameters%TYPE,
                                   p_appraisal_sys_type in out nocopy per_appraisals.appraisal_system_status%TYPE)
  return boolean;
*/

--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_action >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to read the WPM_PLAN_ACTION attribute value.
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
procedure get_plan_action(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_method >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to read the WPM_PLAN_METHOD attribute value.
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
procedure get_plan_method(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< populate_plan_members_cache >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to populate the plan population in plsql cache.
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
procedure populate_plan_members_cache(itemtype  in varchar2,
                                      itemkey   in varchar2,
                                      actid     in number,
                                      funcmode  in varchar2,
                                      resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_plan_member >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to get first or next the plan member.
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
procedure get_plan_member(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_top_plan_member >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to get first or next the plan member from top of the
--              plan population hierarchy.
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
procedure get_top_plan_member(itemtype  in varchar2,
                              itemkey   in varchar2,
                              actid     in number,
                              funcmode  in varchar2,
                              resultout out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_non_top_plan_member >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan workflow process calls this
--              function to get first or next the plan member that is does not
--              exist in top population of the plan population hierarchy.
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
procedure get_non_top_plan_member(itemtype  in varchar2,
                                  itemkey   in varchar2,
                                  actid     in number,
                                  funcmode  in varchar2,
                                  resultout out nocopy varchar2);

--
-- ----------------------------------------------------------------------------
-- |---------------------< submit_publish_plan_cp >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: The procedure submits Publish Performance Management Plan
--              concurrent program and updated the plan status to SUBMITTED.
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
procedure submit_publish_plan_cp(p_effective_date        in     varchar2
                                ,p_plan_id               in     number
                                ,p_reverse_mode          in     varchar2
                                ,p_item_type             in     varchar2
                                ,p_wf_process            in     varchar2
                                ,p_object_version_number in out nocopy number
                                ,p_status_code           in out nocopy varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< publish_plan_cp >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: Publish Performance Management Plan concurrent program calls
--              procedure.
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
procedure publish_plan_cp
  (errbuf                      out  nocopy varchar2
  ,retcode                     out  nocopy number
  ,p_effective_date            in   varchar2
  ,p_plan_id                   in   number
  ,p_reverse_mode              in   varchar2    default 'N'
  ,p_what_if                   in   varchar2    default 'N'
  ,p_log_output                in   varchar2    default 'N'
  ,p_action_parameter_group_id in   number      default NULL
  ,p_item_type                 in   varchar2    default 'HRWPM'
  ,p_wf_process                in   varchar2    default 'HR_NOTIFY_WPM_PLAN_POP_PRC'
  );

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< publish_plan >-----------------------------|
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
procedure publish_plan
  (p_effective_date            in   date
  ,p_plan_id                   in   number
  ,p_object_version_number     in out nocopy number
  ,p_reverse_mode              in   varchar2    default 'N'
  ,p_what_if                   in   varchar2    default 'N'
  ,p_log_output                in   varchar2    default 'N'
  ,p_action_parameter_group_id in   number      default NULL
  ,p_item_type                 in   varchar2    default 'HRWPM'
  ,p_wf_process                in   varchar2    default 'HR_NOTIFY_WPM_PLAN_POP_PRC'
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< send_fyi_ntf >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure SEND_FYI_NTF
  (itemtype   in varchar2
  ,itemkey    in varchar2
  ,actid      in number
  ,funcmode   in varchar2
  ,resultout  out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< send_fyi_ntf_admin >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure SEND_FYI_NTF_ADMIN
  (itemtype   in varchar2
  ,itemkey    in varchar2
  ,actid      in number
  ,funcmode   in varchar2
  ,resultout  out nocopy varchar2);
--
procedure SEND_FYI_ADMIN
  (p_plan_rec           in  per_perf_mgmt_plans%ROWTYPE
  ,p_status             in  varchar2
  ,p_request_id         in  number
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< copy_past_objectives >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Copy objectives from previous plan to the current plan being published.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if objective(s) is created.
--
-- Post Failure:
--  An application error is raised if objective is not created.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure copy_past_objectives
  (p_effective_date            in  date
  ,p_business_group_id         in  number
  ,p_person_id                 in  number
  ,p_scorecard_id              in  number
  ,p_start_date                in  date
  ,p_end_date                  in  date
  ,p_target_date               in  date default null
  ,p_assignemnt_id             in  number
  ,p_prev_plan_id              in  number
  ,p_curr_plan_id              in  number
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< is_supervisor_in_org >----------------------|
---------------------------------------------------------------------
--{Start Of Comments}
--
-- Description:
--   return true if the person is the topmost supervisor
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  signifies that this is the top supervisor in the organization.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
 ---------------------------------------------------------------------
  FUNCTION is_supervisor_in_org

  (p_top_organization_id       in  number
  ,p_person_id                 in  number

  )RETURN NUMBER;
-- ----------------------------------------------------------------------------
-- |----------------------------< change_plan_active_status >----------------------|
---------------------------------------------------------------------
--{Start Of Comments}
--
-- Description:
--   updates the plan status and swaps the status to Inactive/published if teh current status is published/inactive
--
-- Prerequisites:
--   None.
--
-- In Arguments:
-- Plan ID
--
-- Post Success:
--  Plan status updated to Inactive/Published
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
 ---------------------------------------------------------------------

procedure change_plan_active_status

  (p_plan_id       in  number
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< backout_perf_mgmt_plan>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure backs out the Performance Management Plan that is
--   published to a given population. Deletes all the score cards, appraisals
--   that are created during the plan publish. This is an irreversible process.
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  All data that is created as part of the plan publish. The plan will be set
--  to status Draft, so that the further updates can be made to the plan and
--  the same can be republished.
--
-- Post Failure:
--  Plan data will be intact.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
  PROCEDURE backout_perf_mgmt_plan
  (errbuf                      out  nocopy varchar2
  ,retcode                     out  nocopy number
  ,p_effective_date            in   Varchar2
  ,p_plan_id                   in   number
  ,p_report_only               in   VARCHAR2 DEFAULT 'Y');
--
-- -----------------------------------------------------------------------
-- |----------< backout_perf_mgmt_plan_cp>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function submit the concurrent job that backs out the Performance
--   Management Plan that is published to a given population. Deletes all the
--   score cards, appraisals that are created during the plan publish. This is
--   an irreversible process.
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
-- Returns the request_id of the concurrent request that is submitted.
--
-- Post Failure:
--  Plan will not be backed out.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION backout_perf_mgmt_plan_cp(p_effective_date            in   date
                                  ,p_plan_id                   in   number
                                  ,p_report_only               in   VARCHAR2
DEFAULT 'Y')
                                  RETURN NUMBER ;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< plan_admin_actions_cp>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function submits the concurrent job that performs the selected
--   task on the given list of employees. This is used in the new
--   plan administration area for Performance Mgmt administrators.
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
-- Returns the request_id of the concurrent request that is submitted.
--
-- Post Failure:
--  No request will be returned and error raised
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION plan_admin_actions_cp    (p_effective_date            in   date
                                  ,p_plan_id                   in   number
                                  ,p_selected_entities_list    in   varchar2
                                  ,p_task_code                 in   varchar2)
                                  RETURN NUMBER ;
-- ----------------------------------------------------------------------------
-- |--------------------------< plan_admin_actions>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the selected task on the given list of employees.
--   This is used in the new plan administration area for Performance Mgmt
--   administrators.
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
-- Performs the requested action all the selected persons..
--
-- Post Failure:
--  No action would be performed and appropriate error message(s) logged.
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE plan_admin_actions   (
                                errbuf                      OUT nocopy VARCHAR2
                               ,retcode                     OUT nocopy  NUMBER
                               ,p_effective_date            in   varchar2
                               ,p_plan_id                   in   number
                               ,p_selected_entities_list    in   varchar2
                               ,p_task_code                 in   varchar2);

PROCEDURE send_message_notification (p_person_id in number,
p_message varchar2,
p_plan_id per_perf_mgmt_plans.plan_id%type default null,
p_full_name per_all_people_f.full_name%type
) ;

FUNCTION get_manager_id ( p_person_id in per_all_assignments_f.person_id%TYPE , p_assignment_id per_all_assignments_f.assignment_id%type)
RETURN number;

-- ----------------------------------------------------------------------------
-- |----------------------------< notify_plan_population >----------------------|
---------------------------------------------------------------------
--{Start Of Comments}
--
-- Description:
--   New procedure to notify the entire plan population (for a parallel plan)
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  notifies the plan population
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Only.
--
-- {End Of Comments}
 ---------------------------------------------------------------------
Procedure notify_plan_population(
   itemtype   in varchar2
  ,itemkey    in varchar2
  ,actid      in number
  ,funcmode   in varchar2
  ,resultout  out nocopy varchar2
  );


end HR_PERF_MGMT_PLAN_INTERNAL;




/
