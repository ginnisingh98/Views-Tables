--------------------------------------------------------
--  DDL for Package AR_CM_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CM_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXVCMES.pls 120.0.12000000.1 2007/02/27 12:07:13 mpsingh noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'AR_CM_VAL_PVT';

PROCEDURE default_app_ids(
                p_cm_customer_trx_id   IN OUT NOCOPY NUMBER,
                p_cm_trx_number        IN VARCHAR2,
                p_inv_customer_trx_id  IN OUT NOCOPY NUMBER,
                p_inv_trx_number       IN VARCHAR2,
                p_inv_customer_trx_line_id  IN OUT NOCOPY NUMBER,
                p_inv_line_number      IN NUMBER,
                p_installment       IN OUT NOCOPY NUMBER,
                p_applied_payment_schedule_id   IN NUMBER,
                p_return_status     OUT NOCOPY VARCHAR2 );


PROCEDURE default_app_info(
              p_cm_customer_trx_id  IN NUMBER,
              p_inv_customer_trx_id IN  NUMBER,
              p_inv_customer_trx_line_id  IN NUMBER,
              p_show_closed_invoices  IN VARCHAR2,
              p_installment         IN OUT NOCOPY NUMBER,
              p_apply_date           IN OUT NOCOPY DATE,
              p_apply_gl_date        IN OUT NOCOPY DATE,
              p_amount_applied       IN OUT NOCOPY NUMBER,
              p_applied_payment_schedule_id IN OUT NOCOPY NUMBER,
              p_cm_gl_date          OUT NOCOPY DATE,
              p_cm_trx_date         OUT NOCOPY DATE,
              p_cm_amount_rem       OUT NOCOPY NUMBER,
              p_cm_currency_code    OUT NOCOPY VARCHAR2,
              p_inv_due_date         OUT NOCOPY DATE,
              p_inv_currency_code    OUT NOCOPY VARCHAR2,
              p_inv_amount_rem       OUT NOCOPY NUMBER,
              p_inv_trx_date         OUT NOCOPY DATE,
              p_inv_gl_date          OUT NOCOPY DATE,
              p_allow_overappln_flag OUT NOCOPY VARCHAR2,
              p_natural_appln_only_flag  OUT NOCOPY VARCHAR2,
              p_creation_sign        OUT NOCOPY VARCHAR2,
              p_cm_payment_schedule_id  OUT NOCOPY NUMBER,
              p_inv_line_amount       OUT NOCOPY NUMBER,
              p_return_status    OUT NOCOPY VARCHAR2
               );

PROCEDURE validate_app_info(
                      p_apply_date   IN DATE,
                      p_cm_trx_date  IN DATE,
                      p_inv_trx_date IN DATE,
                      p_apply_gl_date IN DATE,
                      p_cm_gl_date    IN DATE,
                      p_inv_gl_date   IN DATE,
                      p_amount_applied IN NUMBER,
                      p_applied_payment_schedule_id IN NUMBER,
                      p_customer_trx_line_id  IN NUMBER,
                      p_inv_line_amount   IN NUMBER,
                      p_creation_sign   IN VARCHAR2,
                      p_allow_overappln_flag  IN VARCHAR2,
                      p_natural_appln_only_flag  IN VARCHAR2,
                      p_cm_amount_rem    IN NUMBER,
                      p_inv_amount_rem   IN NUMBER,
                      p_cm_currency_code IN VARCHAR2,
                      p_inv_currency_code IN VARCHAR2,
                      p_return_status     OUT NOCOPY VARCHAR2
     ) ;

PROCEDURE Default_unapp_ids(
                   p_cm_trx_number                   IN VARCHAR2,
                   p_cm_customer_trx_id              IN OUT NOCOPY NUMBER,
                   p_inv_trx_number                   IN VARCHAR2,
                   p_inv_customer_trx_id              IN OUT NOCOPY NUMBER,
                   p_receivable_application_id    IN OUT NOCOPY NUMBER,
                   p_installment                  IN NUMBER,
                   p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
                   p_apply_gl_date                OUT NOCOPY DATE,
                   p_return_status                OUT NOCOPY VARCHAR2
                   );

PROCEDURE Default_unapp_info(
                        p_receivable_application_id IN NUMBER,
                        p_apply_gl_date    IN  DATE,
                        p_cm_customer_trx_id  IN  NUMBER,
                        p_reversal_gl_date IN OUT NOCOPY DATE,
                        p_cm_gl_date  OUT NOCOPY DATE
                          );

PROCEDURE Validate_unapp_info(
                      p_cm_gl_date             IN DATE,
                      p_receivable_application_id   IN NUMBER,
                      p_reversal_gl_date            IN DATE,
                      p_apply_gl_date               IN DATE,
                      p_return_status               OUT NOCOPY VARCHAR2
                      );


END AR_CM_VAL_PVT;

 

/
