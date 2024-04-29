--------------------------------------------------------
--  DDL for Package PAY_ASSG_COST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASSG_COST_WF" AUTHID CURRENT_USER as
/* $Header: pyacoswf.pkh 120.0.12010000.2 2008/11/29 21:26:12 pgongada noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< CHECK_APPROVERS_EXIST >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates finds if any approvers exists and populate the out
--   parameter accrodingly.
--
-- Prerequisites:
--   The workflow must have started.
--
-- In Parameters:
-- Name            Reqd    Type     Description
-- itemtype        Yes     varchar2 Itemtype of the workflow process.
-- itemkey         Yes     varchar2 Instance of the workflow process.
-- actid           Yes     Number   The ID number of the activity that this
--                                  procedure is called from.
-- funmode         Yes     varchar2 Function mode either CANCEL or RUN.
--
-- Post Success:
--  Assign true/false to out parameter depening upon the approvers exists or not.
--
-- Out Parameters
-- resultout       Yes     varchar2 Either true/false depending on the approvers
--                                  exists or not.
-- Post Failure:
--   An exception is raised and nothing will be set to out parameter.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure check_approvers_exist(
                itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2);

-- -------------------------------------------------------------------------
-- |-------------------------< GET_NEXT_APPROVER >-------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Control comes to this procedure once the previous approver approves the
--   notification. This function set the previous approver's approval status
--   to true and then get the next approver.
--
-- Prerequisites:
--   The workflow must have started.
--
-- In Parameters:
-- Name            Reqd    Type     Description
-- itemtype        Yes     varchar2 Itemtype of the workflow process.
-- itemkey         Yes     varchar2 Instance of the workflow process.
-- actid           Yes     Number   The ID number of the activity that this
--                                  procedure is called from.
-- funmode         Yes     varchar2 Function mode either CANCEL or RUN.
--
--
-- Post Success:
--  Find out the next approver and send the same to workflow. If no approvers
--  are there then notify the workflow that there are no approvers.
--
-- Out Parameters
-- resultout : Set to 'T' if any approver and 'F' if no approver.
-- Post Failure:
--   An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
 procedure get_next_approver
              (itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funcmode    in varchar2,
                resultout   out nocopy varchar2);
-- ----------------------------------------------------------------------------
-- |----------------------------< START_WF_PROCESS >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API initialize the Assignment Costing Workflow process.
--
-- Prerequisites:
--   The workflow must have started.
--
-- In Parameters:
-- Name                     Reqd    Type     Description
-- p_person_id              Yes     Number   Person ID
-- p_assignment_id          Yes     varchar2 Assignment ID
-- p_performer_name         Yes     Number   Performer login name who is
--                                           changing costing details.
-- p_performer_display_name Yes     varchar2 Disply name of the performer.
-- p_effective_date         Yed     Date     Effective Date.
-- Post Success:
--  Initializes the Assignment Costing workflow process.
--
-- Out Parameters
-- N/A
-- Post Failure:
--   An exception is raised and no workflow starts.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure START_WF_PROCESS (  p_person_id                in number
                             ,p_assignment_id            in number
                             ,p_item_key                 in varchar2
                             ,p_performer_login_name     in varchar2
                             ,P_PERFORMER_ID             in number
                             ,P_EFFECTIVE_DATE           in date
		            );
-- ----------------------------------------------------------------------------
-- |------------------------------< APPROVE_PROCESS >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API delete the transaction, transaction steps
--   and transaction values pertaining the item type and item key.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_item_type                  Yes    varchar2  Identifies Item type
--   p_item_key                   Yes    varchar2  Identifies Item key
--   p_actid                      Yes    number    The ID number of the activity that this procedure is
--                                                  called from.
--   p_funmode                    Yes    varchar2  The mode of the function activity. Either 'RUN' or 'CANCEL'.

-- Post Success:
--   The data pertaining to item key and item type will be deleted from the
--   transaction tables completely.
--
-- Out Parameters:
--   p_result  varchar2  Gets 'SUCCESS' if the transaction successfully deleted.
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE APPROVE_PROCESS(
   itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result       out    nocopy  varchar2);
-- ----------------------------------------------------------------------------
-- |------------------------------< REJECT_PROCESS >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API delete the transaction, transaction steps
--   and transaction values pertaining the item type and item key.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                         Reqd   Type      Description
--   p_item_type                  Yes    varchar2  Identifies Item type
--   p_item_key                   Yes    varchar2  Identifies Item key
--   p_actid                      Yes    number    The ID number of the activity that this procedure is
--                                                  called from.
--   p_funmode                    Yes    varchar2  The mode of the function activity. Either 'RUN' or 'CANCEL'.

-- Post Success:
--   The data pertaining to item key and item type will be deleted from the
--   transaction tables completely.
--
-- Out Parameters:
--   p_result  varchar2  Gets 'SUCCESS' if the transaction successfully deleted.
-- Post Failure:
--   An exception is raised and nothing will be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE REJECT_PROCESS(
   itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result       out    nocopy  varchar2);

END PAY_ASSG_COST_WF;

/
