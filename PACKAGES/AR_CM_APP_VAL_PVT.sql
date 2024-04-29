--------------------------------------------------------
--  DDL for Package AR_CM_APP_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CM_APP_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXCMAVS.pls 120.2 2005/10/30 03:59:08 appldev ship $             */
--
--
-- Purpose: Briefly explain the functionality of the package
--
-- Validation package for credit memo application api.
--
-- MODIFICATION HISTORY
-- Person   Date      Comments
-- -------- --------- ------------------------------------------
-- jbeckett 27-JAN-05 Created.

PROCEDURE validate_activity_app( p_receivables_trx_id IN NUMBER,
                                 p_applied_ps_id  IN NUMBER,
                                 p_customer_trx_id IN NUMBER,
                                 p_cm_gl_date  IN DATE,
                                 p_cm_unapp_amount IN NUMBER,
                                 p_trx_date IN DATE,
                                 p_amount_applied IN NUMBER,
                                 p_apply_gl_date IN DATE,
                                 p_apply_date IN DATE,
                                 p_cm_currency_code IN VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_chk_approval_limit_flag IN VARCHAR2,
                                 p_called_from IN VARCHAR2
                                 );

PROCEDURE validate_unapp_activity(
                              p_trx_gl_date  IN DATE,
                              p_receivable_application_id  IN NUMBER,
                              p_reversal_gl_date  IN DATE,
                              p_apply_gl_date    IN DATE,
                              p_cm_unapp_amt     IN NUMBER,
                              p_return_status  OUT NOCOPY VARCHAR2
                               );

PROCEDURE validate_credit_memo (
          p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_TRUE,
          p_customer_trx_id IN NUMBER,
          p_return_status OUT NOCOPY VARCHAR2);

END AR_CM_APP_VAL_PVT;


 

/
