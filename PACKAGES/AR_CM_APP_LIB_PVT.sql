--------------------------------------------------------
--  DDL for Package AR_CM_APP_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CM_APP_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXCMALS.pls 120.1 2005/07/26 15:29:51 naneja noship $    */
/* removed gscc warnings of NOCOPY hint Bug 4462243 */
PROCEDURE Default_customer_trx_id(
                          p_customer_trx_id IN OUT NOCOPY NUMBER,
                          p_trx_number  IN VARCHAR,
                          p_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Default_activity_info(
                         p_customer_trx_id  IN NUMBER,
			 p_cm_ps_id OUT NOCOPY NUMBER,
                         p_cm_currency_code OUT NOCOPY VARCHAR2,
                         p_cm_gl_date OUT NOCOPY DATE,
                         p_cm_unapp_amount OUT NOCOPY NUMBER,
			 p_cm_receipt_method_id OUT NOCOPY NUMBER,
                         p_trx_date OUT NOCOPY DATE,
                         p_amount_applied IN OUT NOCOPY NUMBER,
                         p_apply_date    IN OUT NOCOPY DATE,
                         p_apply_gl_date IN OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE Derive_activity_unapp_ids(
                         p_trx_number    IN VARCHAR2,
                         p_customer_trx_id   IN OUT NOCOPY NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date     OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE Default_unapp_activity_info(
                         p_receivable_application_id IN NUMBER,
                         p_apply_gl_date             IN DATE,
                         p_customer_trx_id           IN NUMBER,
                         p_reversal_gl_date          IN OUT NOCOPY DATE,
                         p_cm_gl_date                OUT NOCOPY DATE,
			 p_cm_ps_id                  OUT NOCOPY NUMBER,
			 p_cm_unapp_amount           OUT NOCOPY NUMBER,
			 p_return_status             OUT NOCOPY VARCHAR2);

END ar_cm_app_lib_pvt;

 

/
