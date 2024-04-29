--------------------------------------------------------
--  DDL for Package PER_CHECKLIST_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLIST_EVENTS" AUTHID CURRENT_USER as
/* $Header: pecklevt.pkh 120.4.12010000.2 2010/04/03 12:22:10 brsinha ship $ */
--g_temp_num number :=1;
--
-- ------------------------------------------------------------------------
-- |----------------------------< create_event>---------------------------|
-- ------------------------------------------------------------------------
--

procedure CREATE_EVENT
      		(p_effective_date in date,
		 P_person_id      in number,
		 P_assignment_id  in number,
		 P_ler_id         in number);

--

-- ---------------------------------------------------------------------------------
-- |------------------------------PROCESS EVENT------------------------------------|
-- ---------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API is provided to allow creation of new checklist in PER_CHECKLISTS
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     Yes  boolean  Commit or Rollback
--   p_effective_date               Yes  date     Effective date of record
--   p_name                         No   varchar2 Name of the checklist
--   p_description                  No   varchar2 Description of the checklist
--   p_life_event_reason_id         No   number   The id of the life event reason
--   p_business_group_id            No   number   The business group the person
--   p_checklist_category           No   varchar2 Checklist category
--
-- Post Success:
--   Api creates a checklist event
--
-- Post Failure:
--   The API does not create checklist event and raises an error.
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
  procedure PROCESS_EVENT
     (p_person_id in number
     ,p_assignment_id in number default null
     ,p_date in date
     ,p_ler_event_id in number);

  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< PROCESS_VOTING >--------------------------|
  -- ------------------------------------------------------------------------
  --

  procedure PROCESS_VOTING
       (itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode    in varchar2,
		resultout   out nocopy varchar2);

  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< check_approvers_exist >--------------------------|
  -- ------------------------------------------------------------------------
  --

  procedure check_approvers_exist
            (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2);
--
-- ---------------------------------------------------------------------------------
-- |------------------------------Allocate Tasks-----------------------------------|
-- ---------------------------------------------------------------------------------
--
  Procedure ALLOCATE_TASKS(errbuf  out  nocopy  varchar2
                          ,retcode out  nocopy  number
			  ,p_purge in varchar2);
  --
--
-- ---------------------------------------------------------------------------------
-- |----------------------------Allocate Person Tasks------------------------------|
-- ---------------------------------------------------------------------------------
--
  Procedure ALLOCATE_PERSON_TASKS(p_person_id in number);
  --
  --
  -- ------------------------------------------------------------------------
  -- |----------------------< Start_WF_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
  -- Description
  --
  --    Initialize the Checklist Workflow process
  --
  --
  --
  procedure START_WF_PROCESS (p_person_id                in number
                             ,p_assignment_id            in number   default null
                             ,p_checklist_name           in varchar2
                             ,p_checklist_description    in varchar2
			     ,p_task_name                in varchar2
			     ,p_task_description         in varchar2
                             ,p_performer_name           in varchar2
			     ,p_performer_display_name   in varchar2
                             ,p_target_date              in date
			     ,p_total_approvers          in number
			     ,p_current_approver_num     in number default 1
			     ,p_allocated_task_id        in number
			     ,p_task_in_checklist_id     in number);
  --
  --
  -- ------------------------------------------------------------------------
  -- |----------------------< approve_wf_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
  procedure APPROVE_WF_PROCESS
  --
               (itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode    in varchar2,
		resultout   out nocopy varchar2);
  --
  -- ------------------------------------------------------------------------
  -- |-------------------------< rejected_wf_Process>-----------------------|
  -- ------------------------------------------------------------------------
  --
  procedure REJECTED_WF_PROCESS
  --
               (itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode    in varchar2,
		resultout   out nocopy varchar2);
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< Process_fyi>--------------------------|
  -- ------------------------------------------------------------------------
  --
  procedure PROCESS_FYI
  --
               (itemtype	in varchar2,
		itemkey  	in varchar2,
		actid		in number,
		funcmode    in varchar2,
		resultout   out nocopy varchar2);
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< Copy_Tasks >--------------------------|
  -- ------------------------------------------------------------------------
  --
  PROCEDURE Copy_Tasks (p_from_ckl_id          IN NUMBER
                       ,p_to_alloc_ckl_id      IN NUMBER
                       ,p_task_owner_person_id IN NUMBER
                       );
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< get_person_id >------------------------|
  -- ------------------------------------------------------------------------
  FUNCTION get_person_id (p_transaction_id	IN varchar2)	RETURN NUMBER;
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< get_supervisor_id >------------------------|
  -- ------------------------------------------------------------------------
  FUNCTION get_supervisor_id (p_transaction_id	IN varchar2)	RETURN NUMBER;
  --
  -- ------------------------------------------------------------------------
  -- |------------------------------< get_ame_attribute_identifier >---------|
  -- ------------------------------------------------------------------------
  FUNCTION get_ame_attribute_identifier (p_transaction_id	IN varchar2)
  RETURN VARCHAR2 ;
  --

end per_checklist_events;

/
