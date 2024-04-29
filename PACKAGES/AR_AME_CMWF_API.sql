--------------------------------------------------------
--  DDL for Package AR_AME_CMWF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AME_CMWF_API" AUTHID CURRENT_USER AS
/* $Header: ARAMECMS.pls 120.7.12010000.2 2008/09/01 09:48:24 naneja ship $ */



/* Added new parameter bug 7367350 for getting internal comment from request
   Procedure GetCustomerTrxInfo        */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

  c_max_number_approver CONSTANT NUMBER 	:= 200;
  c_application_id 	 CONSTANT NUMBER 	:= 222;

  c_collector_transaction_type  CONSTANT VARCHAR2(30) := 'AR_CMWF_COLLECTOR';
  c_approvals_transaction_type  CONSTANT VARCHAR2(30) := 'AR_CMWF_APPROVALS';
  c_receivable_transaction_type CONSTANT VARCHAR2(30) := 'AR_CMWF_RECEIVABLE';

  c_item_type           CONSTANT VARCHAR2(30) := 'ARAMECM';

  g_debug_mesg		VARCHAR2(240);

PROCEDURE FindTrx(p_item_type        IN  VARCHAR2,
                  p_item_key         IN  VARCHAR2,
                  p_actid            IN  NUMBER,
                  p_funcmode         IN  VARCHAR2,
                  p_result           OUT NOCOPY VARCHAR2);


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

PROCEDURE CheckFinalApprover(p_reason_code                 IN  VARCHAR2,
                             p_currency_code               IN  VARCHAR2,
                             p_amount                      IN  VARCHAR2,
                             p_approver_id                 IN  NUMBER,
                             p_result_flag                 OUT NOCOPY VARCHAR2);

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

-- Following subroutines have been added for AME integration
-- ORASHID
-- 18-Mar-2002

PROCEDURE AMEFindNonPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMEFindNextNonPrimaryApprover  (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMESetNonPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMEFindPrimaryApprover(
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid     IN  NUMBER,
    p_funcmode  IN  VARCHAR2,
    p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMECheckRule  (
   p_item_type IN  VARCHAR2,
   p_item_key  IN  VARCHAR2,
   p_actid     IN  NUMBER,
   p_funcmode  IN  VARCHAR2,
   p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMECheckPrimaryApprover(
  p_item_type        IN  VARCHAR2,
  p_item_key         IN  VARCHAR2,
  p_actid            IN  NUMBER,
  p_funcmode         IN  VARCHAR2,
  p_result           OUT NOCOPY VARCHAR2);

PROCEDURE AMEFindManager  (
   p_item_type IN  VARCHAR2,
   p_item_key  IN  VARCHAR2,
   p_actid     IN  NUMBER,
   p_funcmode  IN  VARCHAR2,
   p_result    OUT NOCOPY VARCHAR2);

PROCEDURE AMEFindReceivableApprover(
  p_item_type        IN  VARCHAR2,
  p_item_key         IN  VARCHAR2,
  p_actid            IN  NUMBER,
  p_funcmode         IN  VARCHAR2,
  p_result           OUT NOCOPY VARCHAR2);

PROCEDURE find_primary_salesrep (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2);

PROCEDURE check_first_approver (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2);

PROCEDURE inform_collector (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2);

PROCEDURE on_account_credit_memo (
    p_item_type IN  VARCHAR2,
    p_item_key  IN  VARCHAR2,
    p_actid    	IN  NUMBER,
    p_funcmode 	IN  VARCHAR2,
    p_result   	IN OUT NOCOPY VARCHAR2);

PROCEDURE callback_routine (
  p_item_type   IN VARCHAR2,
  p_item_key    IN VARCHAR2,
  p_activity_id IN NUMBER,
  p_command     IN VARCHAR2,
  p_result      IN OUT NOCOPY VARCHAR2);

PROCEDURE AMEHandleTimeout  (
   p_item_type IN  VARCHAR2,
   p_item_key  IN  VARCHAR2,
   p_actid     IN  NUMBER,
   p_funcmode  IN  VARCHAR2,
   p_result    OUT NOCOPY VARCHAR2);

PROCEDURE handle_ntf_forward (
  p_item_type IN VARCHAR2,
  p_item_key  IN VARCHAR2,
  p_actid    IN NUMBER,
  p_funcmode IN VARCHAR2,
  p_result    OUT NOCOPY VARCHAR2);

END ar_ame_cmwf_api;

/
