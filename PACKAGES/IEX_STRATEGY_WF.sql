--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_WF" AUTHID CURRENT_USER as
/* $Header: iexstrws.pls 120.6.12010000.5 2009/07/16 14:19:24 gnramasa ship $ */


--jsanju 05/30/02
-- Table Of Competence Ids.
TYPE   tab_of_comp_id is TABLE of NUMBER
INDEX BY BINARY_INTEGER;

/**
 * aborting workflow
 * ..
 **/
--procedure custom_abort_process(p_itemtype IN varchar2, p_itemkey IN varchar2);
/**
 * check to see if there are any pending
 * work items to be processed
 **/
procedure check_work_items_completed(
                                      itemtype    in   varchar2,
                                      itemkey     in   varchar2,
                                      actid       in   number,
                                      funcmode    in   varchar2,
                                      result      out NOCOPY  varchar2);

/**
 * Close all the pending work items
 * and close the strategy
 * if the update fails , go and wait
 * for the signal again
 **/

procedure close_strategy(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * Get the next work item for the strategy
 * creates the work item in strategy_work_items table
 * update the attribute work_item_id in the workflow with the
 * create workitem_id.
 **/

procedure create_next_work_item(
                             itemtype    in   varchar2,
                             itemkey     in   varchar2,
                             actid       in   number,
                             funcmode    in   varchar2,
                             result      out NOCOPY  varchar2);

/**
 * This will suspend the existing process
 **/
procedure set_notification_resources(
            p_resource_id       in number,
            itemtype            in varchar2,
            itemkey             in varchar2
           );

procedure wait_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);


procedure wait_complete_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2) ;

--get the status of the process
-- to see if the process is SUSPEND(wf_engine.eng_suspended )
PROCEDURE process_status (  p_process     in   varchar2 ,
                            p_itemtype    in   varchar2,
                            p_itemkey     in   varchar2,
                            x_status      out NOCOPY  varchar2);

/**
 * This will be called from the form or the concurrent program
 * once the work item
 * status is changed or if the strategy is closed or cancelled
 * if the work item is null ,then the strategy and the pending
 * work items are to be closed/cancelled
 * else just complete or cancel the work item only
 *03/19/02
 * --sub process addition --
 * if it is waiting for optional check or escalte check
 * then we have not reached the wait for response activity
 * or the process is not suspended so these are the things we should do
 * 1.DO NOT resume process
 * 2.Complete activity (depending on the activity label - this will be
 * either escalte_check or optional_check)
 * then the subprocess will be completed
 *04/02/2002
 * add a new parameter signal_source for custom work flow and fulfilment
 *work flow check if the agent has already changed the work item status
 *before the completion of custom or fulfillment wf's.then do nothing ,
 *else update workitem and resume process
 **/

procedure send_signal(
                         process       in   varchar2 ,
                         strategy_id   in   varchar2,
                         status        in   VARCHAR2,
                         work_item_id  in number DEFAULT NULL,
                         signal_source in varchar2 DEFAULT NULL);


/**
 * check whether the work item is optional or not
 **/
procedure OPTIONAL_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * check whether the work item should be escalated or not
 **/
procedure ESCALATE_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * check whether the work item status is on hold
 **/
procedure ONHOLD_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * check whether the fulfil_temp_id is populated for this work item
 *
 **/
procedure FULFIL_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);


procedure cal_post_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2);

procedure cal_pre_wait(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2);

/* begin bug 4141678 by ctlee 3/14/2005 - loop one when create workitem failed */
procedure wi_failed_first_time(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out nocopy  varchar2);
/* end bug 4141678 by ctlee 3/14/2005 - loop one when create workitem failed */

/**
 * check whether the to send a notification
 **/
procedure NOTIFY_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * check whether there is a custom worlflow attached
 **/
procedure CUSTOM_CHECK(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

/**
 * updatework item to Timeout
 **/
procedure UPDATE_WORK_ITEM(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);


procedure WAIT_OPTIONAL(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2) ;

procedure WAIT_ESCALATION(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);


procedure WAIT_STRATEGY(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

--get messages from server side
PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY VARCHAR2);
----------------------------------------------
--if work item creation fails ,
--and if adminstartor does not want to continue
--replies via email 'NO' then close strategy and
--complete the workflow.
--set the status attribute to 'CANCELLED'
-- when closing strategy(CLOSE_STRATEGY procedure)
-- this attribute is checked.
--05/02/02

procedure SET_STRATEGY_STATUS(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

--set user_id,responsibility_id
--and application responsibility id
--which will then used by the the an other activity
-- which comes after a deferred activitiy
--08/02/02

procedure SET_SESSION_CTX(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);




/**
 --07/31/02
 --abort the strategy workflow
 --update the work items,
 --close or cancel strategy
 --abort all the custom workflows
 --this will happen if the workflow failed before
 --being suspended, for example if notification
 -- does not have a performer.

**/
procedure  CLOSE_AND_ABORT_STRATEGY_WF(
                           l_strategy_id   in   NUMBER,
                           l_status        in  VARCHAR2 ) ;


-- Begin- Andre 07/28/2004 - Add bill to assignmnet

------------------- procedure get_billto_resource ------------------------------
/** get resource id for the given competence and bill to address
*
**/
function get_billto_resource ( p_siteuse_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER)
						 RETURN BOOLEAN;

-- End- Andre 07/28/2004 - Add bill to assignmnet

-- Begin- Kasreeni 01/07/2005 - Add account assignmnet

------------------- procedure get_billto_resource ------------------------------
/** get resource id for the given competence and account
*
**/
function get_account_resource ( p_account_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER)
						 RETURN BOOLEAN;

-- End- kasreeni 07/28/2004 - Add account assignmnet


--Begin - schekuri - 03-Dec-2005 - Bug#4506922
--to make the wf wait when the status of strategy is ONHOLD
procedure wait_on_hold_signal(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2) ;
--End - schekuri -  03-Dec-2005 - Bug#4506922


--Begin - schekuri - 06-Dec-2005 - Bug#4506922
-- procedure to update the workitem to open
procedure update_work_item_to_open(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out  NOCOPY varchar2) ;
--End - schekuri - 06-Dec-2005 - Bug#4506922

/**
 * update Escalation flag of the workitem
 **/
procedure UPDATE_ESC_FLAG(
                         itemtype    in   varchar2,
                         itemkey     in   varchar2,
                         actid       in   number,
                         funcmode    in   varchar2,
                         result      out NOCOPY  varchar2);

--Start added by gnramasa for bug 8630852 13-July-09
procedure get_resource ( p_party_id      IN NUMBER,
                         p_competence_tab IN tab_of_comp_id,
                         x_resource_id   OUT NOCOPY NUMBER);
--End added by gnramasa for bug 8630852 13-July-09

end IEX_STRATEGY_WF;

/
