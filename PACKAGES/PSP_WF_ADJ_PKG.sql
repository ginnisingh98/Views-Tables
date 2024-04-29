--------------------------------------------------------
--  DDL for Package PSP_WF_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_WF_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPWFAJS.pls 115.11 2003/07/24 16:58:55 spchakra ship $ */

/****************************************************************************************************************/
/*Procedure INIT_WORKFLOW is called if user profile option "PSP:Distribution Adj. Enhanced Workflow" is set to  */
/*"Yes". It is initiated when users submit the distribution adjustment batch. If the workflow process succeeds, */
/*0 will be returned; otherwise, -1 or -2 will be returned.                                                     */
/****************************************************************************************************************/
PROCEDURE init_workflow(p_batch_name 	   	IN  VARCHAR2,
		        p_person_id  	   	IN  NUMBER,
                        p_display_name     	IN  VARCHAR2,
                        p_assignment 	   	IN  VARCHAR2,
                    ---    p_earnings_element 	IN  VARCHAR2,
                        p_begin_date	   	IN  DATE,
		        p_end_date	   	IN  DATE,
		        p_currency_code	   	IN  VARCHAR2,	-- Introduced for bug fix 2916848
			p_comments	   	IN  VARCHAR2,
			p_time_out		IN  NUMBER,
	                return_code        	OUT NOCOPY NUMBER);

/*********************************************************************************************/
/*Procedure SELECT_APPROVER is called by "Select Approver" activity in the distribution adjustment workflow     */
/*process. By default, the supervisor is the approver. If customization is needed, call                         */
/*PSP_WF_CUSTOM.select_adj_approver to get the approver's person ID.                                            */
/*********************************************************************************************/
PROCEDURE select_approver(itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2);

/****************************************************************************************************************/
/*Procedure UNDO_DISTRIBUTION_ADJUSTMENT is called by "Undo Distribution Adjustment" activity in the            */
/*distribution adjustment workflow process. If the adjustment batch is cancelled by the creator or rejected by  */
/*the approver, the database will be returned to the state that is before the batch is created.                 */
/*Procedure UNDO_DISTRIBUTION_ADJUSTMENT calls a procedure called undo_adjustment().                            */
/****************************************************************************************************************/
PROCEDURE undo_distribution_adjustment(itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2);

/****************************************************************************************************************/
/*Procedure GET_APPROVAL_RESPONDER is called by workflow activity "Get Final Approver" to figure out who is the */
/*final approver in the forwarding path.                                                                        */
/****************************************************************************************************************/
PROCEDURE get_approval_responder(itemtype in varchar2,
                                 itemkey  in varchar2,
                                 actid    in number,
                                 funcmode in varchar2,
                                 result   out NOCOPY varchar2);

/****************************************************************************************************************/
/*Procedure RECORD_APPROVER is called by workflow activity "Record Approver". When the distribution adjustment  */
/*batch is approved, the approver's user ID is recorded in table PSP_ADJUSTMENT_CONTROL_TABLE.                  */
/****************************************************************************************************************/
PROCEDURE record_approver(itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2);

PROCEDURE omit_approval (itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2);
PROCEDURE record_creator(itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2);
END psp_wf_adj_pkg;

 

/
