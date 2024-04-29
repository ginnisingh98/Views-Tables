--------------------------------------------------------
--  DDL for Package ARP_CMREQ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CMREQ_WF" AUTHID CURRENT_USER AS
/* $Header: ARWCMWFS.pls 120.3.12010000.2 2008/09/01 09:59:34 naneja ship $ */
-- <describe the activity here>
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of	the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT NOCOPY
--   result
--	 - COMPLETE[:<result>]
--	     activity has completed with the indicated result
--	 - WAITING
--	     activity is waiting for additional	transitions
--	 - DEFERED
--	     execution should be defered to background
--	 - NOTIFIED[:<notification_id>:<assigned_user>]
--	     activity has notified an external entity that this
--	     step must be performed.  A	call to	wf_engine.CompleteActivty
--	     will signal when this step	is complete.  Optional
--	     return of notification ID and assigned user.
--	 - ERROR[:<error_code>]
--	     function encountered an error.

-----------------------------------------------------------------------------
-- Constants definition
----------------------------------------------------------------------------
-- Max number of approver
   C_MAX_NUMBER_APPROVER CONSTANT NUMBER := 200;

-----------------------------------------------------------------------------
PROCEDURE FindTrx(p_item_type        IN  VARCHAR2,
                  p_item_key         IN  VARCHAR2,
                  p_actid            IN  NUMBER,
                  p_funcmode         IN  VARCHAR2,
                  p_result           OUT NOCOPY VARCHAR2);

/* 7367350 Passed new parameter for retrieving internal comment and inserting in Workflow attribute
   For case of not using AME */
PROCEDURE GetCustomerTrxInfo(p_item_type             IN  VARCHAR2,
                             p_item_key              IN  VARCHAR2,
                             p_workflow_document_id  OUT NOCOPY NUMBER,
                             p_customer_trx_id       OUT NOCOPY NUMBER,
                             p_amount                OUT NOCOPY NUMBER,
                             p_line_amount           OUT NOCOPY NUMBER,
                             p_tax_amount            OUT NOCOPY NUMBER,
                             p_freight_amount        OUT NOCOPY NUMBER,
			     p_reason	     	     OUT NOCOPY VARCHAR2,
                             p_reason_meaning	     OUT NOCOPY VARCHAR2,
			     p_requestor_id	     OUT NOCOPY NUMBER,
                             p_comments              OUT NOCOPY VARCHAR2,
			     p_orig_trx_number       OUT NOCOPY VARCHAR2,
			     p_tax_ex_cert_num	     OUT NOCOPY VARCHAR2,
			     p_internal_comment              OUT NOCOPY VARCHAR2);



PROCEDURE GetTrxAmount(p_item_type                IN  VARCHAR2,
                       p_item_key                 IN  VARCHAR2,
                       p_customer_trx_id          IN  NUMBER,
                       p_original_line_amount     OUT NOCOPY NUMBER,
                       p_original_tax_amount      OUT NOCOPY NUMBER,
                       p_original_freight_amount  OUT NOCOPY NUMBER,
                       p_original_total           OUT NOCOPY NUMBER,
		       p_currency_code            OUT NOCOPY VARCHAR2);

PROCEDURE FindCustomer(p_item_type        IN  VARCHAR2,
                       p_item_key         IN  VARCHAR2,
                       p_actid            IN  NUMBER,
                       p_funcmode         IN  VARCHAR2,
                       p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindCustomerInfo(p_customer_trx_id          IN  NUMBER,
                           p_bill_to_site_use_id      OUT NOCOPY NUMBER,
                           p_customer_id              OUT NOCOPY NUMBER,
                           p_bill_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_bill_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_trx_number               OUT NOCOPY VARCHAR2 );

PROCEDURE FindCollector(p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindManager  (p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2);


PROCEDURE FindCollectorInfo(p_customer_id                 IN  NUMBER,
                            p_bill_to_site_use_id         IN  NUMBER,
                            p_collector_employee_id       OUT NOCOPY NUMBER,
                            p_collector_id                OUT NOCOPY NUMBER,
                            p_collector_name              OUT NOCOPY VARCHAR2);


PROCEDURE DefaultSendTo       (p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2);

PROCEDURE CheckPrimaryApprover(p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindPrimaryApprover(p_item_type        IN  VARCHAR2,
                              p_item_key         IN  VARCHAR2,
                              p_actid            IN  NUMBER,
                              p_funcmode         IN  VARCHAR2,
                              p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindNonPrimaryApprover(p_item_type        IN  VARCHAR2,
                              p_item_key         IN  VARCHAR2,
                              p_actid            IN  NUMBER,
                              p_funcmode         IN  VARCHAR2,
                              p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindNextNonPrimaryApprover(p_item_type        IN  VARCHAR2,
                 	             p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2);

PROCEDURE SelectFirstPrimaryApproverId
                              (p_reason_code            IN  VARCHAR2,
                               p_currency_code          IN  VARCHAR2,
                               p_approver_employee_id   OUT NOCOPY NUMBER);

PROCEDURE SelectPrimaryApproverId(p_reason_code           IN  VARCHAR2,
                                  p_currency_code         IN  VARCHAR2,
                                  p_approver_count        IN  NUMBER,
                                  p_approver_employee_id  OUT NOCOPY NUMBER);

PROCEDURE GetEmployeeInfo( p_user_id           in  number,
                           p_item_type             in  varchar2,
                           p_item_key              in  varchar2,
                           p_primary_approver_flag in  varchar2);

PROCEDURE GetUserInfoFromTable(p_user_id   IN   NUMBER,
			       p_primary_approver_flag IN VARCHAR2,
                               p_user_name     OUT NOCOPY  VARCHAR2,
                               p_display_name  OUT NOCOPY  VARCHAR2);

PROCEDURE RecordCollectorAsApprover(p_item_type        IN  VARCHAR2,
                                    p_item_key         IN  VARCHAR2,
                                    p_actid            IN  NUMBER,
                                    p_funcmode         IN  VARCHAR2,
                                    p_result           OUT NOCOPY VARCHAR2);

PROCEDURE RecordCollectorAsForwardFrom(p_item_type        IN  VARCHAR2,
                                       p_item_key         IN  VARCHAR2,
                                       p_actid            IN  NUMBER,
                                       p_funcmode         IN  VARCHAR2,
                                       p_result           OUT NOCOPY VARCHAR2);


PROCEDURE RecordForwardToUserInfo(p_item_type        IN  VARCHAR2,
                                  p_item_key         IN  VARCHAR2,
                                  p_actid            IN  NUMBER,
                                  p_funcmode         IN  VARCHAR2,
                                  p_result           OUT NOCOPY VARCHAR2);

PROCEDURE CheckForwardFromUser(p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2);


PROCEDURE RecordApproverAsForwardFrom(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2);

PROCEDURE RemoveFromDispute          (p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2);


PROCEDURE FinalApprover(p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2);

PROCEDURE CheckFinalApprover(p_reason_code                 IN  VARCHAR2,
                             p_currency_code               IN  VARCHAR2,
                             p_amount                      IN  VARCHAR2,
                             p_approver_id                 IN  NUMBER,
                             p_result_flag                 OUT NOCOPY VARCHAR2);

PROCEDURE FindReceivableApprover(p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2);

PROCEDURE FindResponder         (p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertSubmissionNotes(p_item_type        IN  VARCHAR2,
                                p_item_key         IN  VARCHAR2,
                                p_actid            IN  NUMBER,
                                p_funcmode         IN  VARCHAR2,
                                p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertEscalationNotes(p_item_type        IN  VARCHAR2,
                                p_item_key         IN  VARCHAR2,
                                p_actid            IN  NUMBER,
                                p_funcmode         IN  VARCHAR2,
                                p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertRequestManualNotes  (p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertCompletedManualNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2);


PROCEDURE InsertRequestApprovalNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertApprovedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertRejectedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2);

PROCEDURE InsertSuccessfulAPINotes(p_item_type        IN  VARCHAR2,
                                   p_item_key         IN  VARCHAR2,
                                   p_actid            IN  NUMBER,
                                   p_funcmode         IN  VARCHAR2,
                                   p_result           OUT NOCOPY VARCHAR2);


PROCEDURE InsertApprovalReminderNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2);


PROCEDURE InsertNotes(p_item_type        IN  VARCHAR2,
                      p_item_key         IN  VARCHAR2,
                      p_actid            IN  NUMBER,
                      p_funcmode         IN  VARCHAR2,
                      p_result           OUT NOCOPY VARCHAR2);



PROCEDURE InsertTrxNotes(x_customer_call_id          IN  NUMBER,
                         x_customer_call_topic_id    IN  NUMBER,
                         x_action_id                 IN  NUMBER,
                         x_customer_trx_id           IN  NUMBER,
                         x_note_type                 IN  VARCHAR2,
                         x_text                      IN  VARCHAR2,
                         x_note_id                   OUT NOCOPY NUMBER);


-- Sai's procedure

PROCEDURE CallTrxApi(p_item_type        IN  VARCHAR2,
                     p_item_key         IN  VARCHAR2,
                     p_actid            IN  NUMBER,
                     p_funcmode         IN  VARCHAR2,
                     p_result           OUT NOCOPY VARCHAR2);


PROCEDURE CheckCreditMethods(p_item_type        IN  VARCHAR2,
                             p_item_key         IN  VARCHAR2,
                             p_actid            IN  NUMBER,
                             p_funcmode         IN  VARCHAR2,
                             p_result           OUT NOCOPY VARCHAR2);

PROCEDURE SetOrgContext (p_item_key IN VARCHAR2);

PROCEDURE callback_routine (
  p_item_type   IN VARCHAR2,
  p_item_key    IN VARCHAR2,
  p_activity_id IN NUMBER,
  p_command     IN VARCHAR2,
  p_result      IN OUT NOCOPY VARCHAR2);


end ARP_CMREQ_WF;

/
