--------------------------------------------------------
--  DDL for Package LNS_WORK_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_WORK_FLOW" AUTHID CURRENT_USER as
/* $Header: LNS_WORK_FLOW_S.pls 120.3.12010000.3 2009/09/03 12:49:00 avepati ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


 /*========================================================================
 | PUBLIC PROCEDURE PROCESS_LOAN_STATUS_CHANGE
 |
 | DESCRIPTION
 |      This procedure processes Loan status changes
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Standard in parameter
 |      P_FROM_STATUS               IN          Standard in parameter
 |      P_TO_STATUS                 IN          Standard in parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-Feb-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_LOAN_STATUS_CHANGE( p_loan_id               IN  NUMBER
                                     ,p_from_status           IN  VARCHAR2
                                     ,p_to_status             IN  VARCHAR2);
 /*========================================================================
 | PUBLIC PROCEDURE PROCESS_STATUS_CHANGE
 |
 | DESCRIPTION
 |      This procedure processes Loan status changes both loan_status and sec status
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Standard in parameter
 |      P_COLUMN_NAME               IN          Standard in parameter
 |      P_FROM_STATUS               IN          Standard in parameter
 |      P_TO_STATUS                 IN          Standard in parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 03-Oct-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_STATUS_CHANGE( p_loan_id               IN  NUMBER
                                ,p_column_name           IN  VARCHAR2
                                ,p_from_status           IN  VARCHAR2
                                ,p_to_status             IN  VARCHAR2);
PROCEDURE PROCESS_SEC_STATUS_CHANGE( p_loan_id               IN  NUMBER
                                    ,p_from_status           IN  VARCHAR2
                                    ,p_to_status             IN  VARCHAR2);
PROCEDURE RAISE_EVENT (    p_loan_id               IN  NUMBER
                          ,p_event_name            IN  VARCHAR2
			  ,p_from_status           IN  VARCHAR2 DEFAULT NULL );
FUNCTION  CREATE_NOTIFICATION_DETAILS (   itemtype                in  varchar2,
                                itemkey                 in  varchar2,
                                p_event_name            in  varchar2,
                                p_loan_id               in  NUMBER,
                                p_loan_class_code       in  varchar2,
                                p_loan_type             in  varchar2,
				p_loan_type_id          in  number,
				p_current_user_id       in  number)
                                RETURN VARCHAR2;
 /*========================================================================
 | PUBLIC PROCEDURE PROCESS_EVENT
 |
 | DESCRIPTION
 |      This procedure processes the event and is called from workflow.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ITEMKEY                     IN          Standard in parameter
 |      ACTID                       IN          Standard in parameter
 |      FUNCMODE                    IN          Standard in parameter
 |      RESULTOUT                   OUT         Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-Feb-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE PROCESS_EVENT(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 );

 /*========================================================================
 | PUBLIC PROCEDURE PROCESS_LOAN_APPROVAL
 |
 | DESCRIPTION
 |      This procedure insters/updates the loan Rejection Status in LNS_APPROVAL_ACTIONS table.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ITEMKEY                     IN          Standard in parameter
 |      ACTID                       IN          Standard in parameter
 |      FUNCMODE                    IN          Standard in parameter
 |      RESULTOUT                   OUT         Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-Feb-2005           GBELLARY          Created
 | 23-Aug-2009           avepati    bug 8764310 - Loan Notification Missing Approve and Reject Buttons
 |
 *=======================================================================*/
PROCEDURE PROCESS_LOAN_APPROVAL(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 );

  /*========================================================================
 | PUBLIC PROCEDURE PROCESS_LOAN_REJECTION
 |
 | DESCRIPTION
 |      This procedure insters/updates the loan Rejection Status  in LNS_APPROVAL_ACTIONS table.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ITEMKEY                     IN          Standard in parameter
 |      ACTID                       IN          Standard in parameter
 |      FUNCMODE                    IN          Standard in parameter
 |      RESULTOUT                   OUT         Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-Feb-2005           GBELLARY          Created
 | 23-Aug-2009           avepati    bug 8764310 - Loan Notification Missing Approve and Reject Buttons
 |
 *=======================================================================*/
PROCEDURE PROCESS_LOAN_REJECTION(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 );

 /*========================================================================
 | PUBLIC PROCEDURE LOG_EVENT_HISTORY
 |
 | DESCRIPTION
 |      This procedure logs the event history in LNS_EVT_ACTION_HISTORY_H table.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ITEMKEY                     IN          Standard in parameter
 |      ACTID                       IN          Standard in parameter
 |      FUNCMODE                    IN          Standard in parameter
 |      RESULTOUT                   OUT         Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-Feb-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE LOG_EVENT_HISTORY(itemtype        in  varchar2,
                                itemkey                 in  varchar2,
                                actid                   in number,
                                funcmode                in  varchar2,
                                resultout               out NOCOPY varchar2 );
 /*========================================================================
 | PUBLIC PROCEDURE SYNCH_EVENT_ACTIONS
 |
 | DESCRIPTION
 |      This procedure adds event actions for newly created user extensible
 |      Loan Types.
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      NONE.
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-Feb-2005           GBELLARY          Created
 |
 *=======================================================================*/
PROCEDURE SYNCH_EVENT_ACTIONS;

/*========================================================================
 | PUBLIC PROCEDURE DELETE_LNS_EVENT_ACTIONS
 |
 | DESCRIPTION
 |      This procedure deletes the event action records from the table
 |       lns_event_actions table for the provided loanType.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_loan_type_id              IN          Standard in parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author       Description of Changes
 | 16-Mar-2009           MBOLLI       Created
 |
 *=======================================================================*/
PROCEDURE DELETE_LNS_EVENT_ACTIONS  ( p_loan_type_id IN  NUMBER);

END LNS_WORK_FLOW;

/
