--------------------------------------------------------
--  DDL for Package AR_BUS_EVENT_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BUS_EVENT_COVER" AUTHID CURRENT_USER AS
/* $Header: ARBEPKGS.pls 120.10 2005/10/30 04:13:04 appldev noship $*/
TYPE prev_cust_old_state_rec IS RECORD
  (amount_due_remaining  NUMBER,
   amount_credited       NUMBER,
   status                varchar2(10));

TYPE prev_cust_old_state_tab IS TABLE OF prev_cust_old_state_rec
  INDEX BY BINARY_INTEGER;

PROCEDURE p_insert_trx_sum_hist
            (p_trx_sum_hist_rec IN  AR_TRX_SUMMARY_HIST%rowtype,
             p_history_id  OUT NOCOPY NUMBER,
             p_trx_type    IN VARCHAR2  DEFAULT NULL,
             p_event_type  IN VARCHAR2 DEFAULT NULL);

PROCEDURE Raise_Trx_Creation_Event
( p_doc_type  IN VARCHAR2,
  p_customer_trx_id  IN  NUMBER,
  p_prev_cust_old_state IN PREV_CUST_OLD_STATE_TAB
 );

PROCEDURE Raise_Trx_Incomplete_Event
( p_doc_type  IN VARCHAR2,
  p_customer_trx_id  IN  NUMBER,
  p_ps_id          IN NUMBER,
  p_history_id      IN NUMBER,
  p_prev_cust_old_state IN PREV_CUST_OLD_STATE_TAB
 );

--
-- This has to be raised per payment_schedule_id modified
--

PROCEDURE Raise_Trx_Modify_Event
( p_payment_schedule_id  IN NUMBER,
  p_doc_type  IN VARCHAR2,
  p_history_id      IN NUMBER
 );

PROCEDURE Raise_Rcpt_Creation_Event
 ( p_payment_schedule_id  IN  NUMBER
 );

PROCEDURE Raise_Rcpt_Reverse_Event
 (p_cash_receipt_id  IN  NUMBER,
  p_payment_schedule_id  IN  NUMBER,
  p_history_id       IN NUMBER
 );

PROCEDURE Raise_Rcpt_DMReverse_Event
 (p_cash_receipt_id  IN  NUMBER,
  p_payment_schedule_id  IN  NUMBER,
  p_history_id       IN NUMBER
 );

PROCEDURE Raise_Rcpt_Modify_Event
 ( p_cash_receipt_id  IN  NUMBER,
   p_payment_schedule_id  IN  NUMBER,
   p_history_id       IN NUMBER);

PROCEDURE Raise_Rcpt_Confirm_Event
 ( p_rec_appln_id  IN  NUMBER,
   p_cash_receipt_id  IN  NUMBER);

PROCEDURE Raise_Rcpt_UnConfirm_Event
 ( p_rec_appln_id  IN  NUMBER,
   p_cash_receipt_id  IN  NUMBER);

PROCEDURE Raise_CR_Apply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 );

PROCEDURE Raise_CR_UnApply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 );

PROCEDURE Raise_CM_Apply_Event
 (p_receivable_application_id  IN NUMBER, --pass in the rec_app_id of the APP rec
  p_app_ps_status    IN VARCHAR2  DEFAULT NULL
 );

PROCEDURE Raise_CM_UnApply_Event
 (p_receivable_application_id  IN NUMBER --pass in the rec_app_id of the APP rec
 );

PROCEDURE Raise_Adj_Create_Event
 (p_adjustment_id  IN NUMBER,
  p_app_ps_status  IN VARCHAR2  DEFAULT NULL,
  p_adj_status   IN VARCHAR2 DEFAULT NULL);

PROCEDURE Raise_Adj_Approve_Event
 (p_adjustment_id  IN NUMBER,
  p_approval_actn_hist_id IN NUMBER,
  p_app_ps_status IN VARCHAR2 DEFAULT NULL);

PROCEDURE Raise_AutoInv_Run_Event
 ( p_request_id IN   NUMBER);

PROCEDURE Raise_AutoRec_Run_Event
 ( p_request_id  IN  NUMBER,
   p_req_confirmation  IN VARCHAR2);

PROCEDURE Raise_PostBatch_Run_Event
 ( p_request_id  IN  NUMBER);

PROCEDURE Raise_AutoAdj_Run_Event
 ( p_request_id  IN  NUMBER);

PROCEDURE Raise_CopyInv_Run_Event
 ( p_request_id  IN  NUMBER);

PROCEDURE Raise_Rcpt_Deletion_Event
 ( p_payment_schedule_id  IN  NUMBER,
   p_receipt_number	  IN  ar_cash_receipts.receipt_number%type,
   p_receipt_date	  IN  ar_cash_receipts.receipt_date%type
 );

END AR_BUS_EVENT_COVER; -- Package spec

 

/
