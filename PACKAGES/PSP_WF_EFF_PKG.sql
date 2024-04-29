--------------------------------------------------------
--  DDL for Package PSP_WF_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_WF_EFF_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPWFEFS.pls 115.6 2002/11/18 13:31:28 ddubey ship $ */

/**********************************************************************************
**Function INIT_WORKFLOW is called when an effort report is created. It is called**
**from package psp_efforts_pkg.crt. This creates the workflow process,populates  **
**attributes, and starts the process.						 **
***********************************************************************************/
function INIT_WORKFLOW(a_template_id IN NUMBER) return NUMBER;

/*********************************************************
**Procedure OMIT_APPROVAL_STEP checks the value of the	**
**attribute by the same name in the workflow process and**
**sends the result. This procedure is called by the 	**
**workflow activity OMIT_APPROVAL_STEP.			**
**********************************************************/
procedure OMIT_APPROVAL_STEP (itemtype in varchar2,
			      itemkey  in varchar2,
			      actid    in number,
			      funcmode in varchar2,
			      result   out NOCOPY varchar2);

/**************************************************************
**Procedure CAN_EMPLOYEE_APPROVE checks the value of the item**
**attribute CAN_EMPLOYEE_APPROVE and sends the result to     **
**workflow process. This procedure is called by the          **
**workflow activity "Can Employee Approve".		     **
***************************************************************/
procedure CAN_EMPLOYEE_APPROVE (itemtype in varchar2,
                                itemkey  in varchar2,
                                actid    in number,
                                funcmode in varchar2,
                                result   out NOCOPY varchar2);

/************************************************************
**PROCEDURE CAN_SUPERVISOR_CERTIFY checks if supervisor can**
**certify the effort report. If yes, set the certifier's   **
**display name and username.				   **
*************************************************************/
procedure CAN_SUPERVISOR_CERTIFY(itemtype in varchar2,
                                 itemkey  in varchar2,
                                 actid    in number,
                                 funcmode in varchar2,
                                 result   out NOCOPY varchar2);


/************************************************************
**Procedure VERIFY_EMPLOYEE checks if the employee username**
**exists and populates the item attriutes                  **
**APPROVER_USERNAME and APPROVER_DISPLAY_NAME with the     **
**employee's. username and display name. This procedure is **
**called by the workflow activity VERIFY_EMPLOYEE.         **
*************************************************************/
procedure VERIFY_EMPLOYEE(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          result   out NOCOPY varchar2);

/*******************************************************************************
 *Procedure VERIFY_SUPERVISOR is called by workflow activity VERIFY SUPERVISOR.*
 *It finds the supervisor for EMPLOYEE and populdate item attributes:          *
 *certifier_username and certifier_display_name. The procedure returns         *
 *COMPLETE:Found if the supervisor is found; returns COMPLETE:Not Found, if    *
 *the supervisor cannot be found.					       *
 *******************************************************************************/
procedure VERIFY_SUPERVISOR(itemtype in varchar2,
                            itemkey  in varchar2,
                            actid    in number,
                            funcmode in varchar2,
                            result   out NOCOPY varchar2);

/*****************************************************************
**PROCEDURE STATUS_APPROVED updates the status of effort	**
**report to 'A'. It is called in the workflow activity UPDATE_EF**
**FORT_REPORT_STATUS_TO_APPROVED.				**
******************************************************************/
procedure STATUS_APPROVED(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          result   out NOCOPY varchar2);

/************************************************************
**PROCEDURE STATUS_SUPERSEDED updates the status of effort **
**report to 'S'. It is called in workflow activity 	   **
**UPDATE_EFFORT_REPORT_STATUS_TO_SUPERSEDED.               **
*************************************************************/
procedure STATUS_SUPERSEDED(itemtype in varchar2,
                            itemkey  in varchar2,
                            actid    in number,
                            funcmode in varchar2,
                            result   out NOCOPY varchar2);

/**********************************************************
**PROCEDURE STATUS_CERTIFIED updates the status of effort**
**report to 'C'. It is called in workflow activity       **
**"UPDATE EFFORT REPORT STATUS TO CERTIFIED". 	         **
***********************************************************/
procedure STATUS_CERTIFIED(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           funcmode in varchar2,
                           result   out NOCOPY varchar2);

/*********************************************************
**PROCEDURE STATUS_REJECTED updates the status of effort**
**report to 'R'. It is called by a workflow activity    **
**"Update Effort Report Status to Rejected".   		**
**********************************************************/
procedure STATUS_REJECTED     (itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              funcmode in varchar2,
                              result   out NOCOPY varchar2);

/***********************************************************************
**Procedure SELECT_CERTIFIER is called by a workflow process "Select  **
**Certifier". It is invoked if user profile option "PSP:Can Supervisor**
**Certify" is set to "No". Procedure SELECT_CERTIFIER makes a call to **
**PSP_WF_CUSTOM.SELECT_CERTIFIER, where users can customize who the   **
**certifer is.                                                        **
************************************************************************/
procedure SELECT_CERTIFIER(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           funcmode in varchar2,
                           result   out NOCOPY varchar2);

/***********************************************************************
**Procedure SELECT_APPROVER is called by a workflow process "Select   **
**Approver". It is invoked if user profile option "PSP:Can Employee   **
**Approve" is set to "No". Procedure SELECT_APPROVER makes a call to  **
**PSP_WF_CUSTOM.SELECT_APPROVER, where users can customize who the    **
**approver is.                                                        **
************************************************************************/
procedure SELECT_APPROVER(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          result   out NOCOPY varchar2);

/***********************************************************************
**Procedure GET_APPROVAL_RESPONDER is called by a workflow process    **
**"Get Final Approver's Name".                                        **
************************************************************************/
procedure GET_APPROVAL_RESPONDER(itemtype in varchar2,
                                 itemkey  in varchar2,
                                 actid    in number,
                                 funcmode in varchar2,
                                 result   out NOCOPY varchar2);

/****************************************************************************
**Procedure GET_CERTIFICATION_RESPONDER is called by a workflow process    **
**"Get Final Certifier's Name".                                            **
*****************************************************************************/
procedure GET_CERTIFICATION_RESPONDER(itemtype in varchar2,
                                      itemkey  in varchar2,
                                      actid    in number,
                                      funcmode in varchar2,
                                      result   out NOCOPY varchar2);


/*********************************************************
**Procedure VERIFY_TERM_EMPLOYEEchecks the value of the	**
**current_employee_flag of a person to determine whether**
**the person is terminated or not			**
**For Enhancement Zero Work Days -skotwal		**
**********************************************************/
procedure VERIFY_TERM_EMPLOYEE(itemtype in varchar2,
			       itemkey  in varchar2,
			       actid    in number,
			       funcmode in varchar2,
			       result   out NOCOPY varchar2);



END psp_wf_eff_pkg;


 

/
