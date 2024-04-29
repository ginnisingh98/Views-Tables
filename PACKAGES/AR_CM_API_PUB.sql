--------------------------------------------------------
--  DDL for Package AR_CM_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CM_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARXPCMES.pls 120.0.12010000.2 2008/12/20 11:31:18 dgaurab ship $ */
/*#
 * Credit Memo APIs allow users to apply on account credit memo
 * against a debit memo or invoice using simple calls to PL/SQL functions.
  */

TYPE G_cm_app_rec_type IS RECORD(
        cm_customer_trx_id     ra_customer_trx.customer_trx_id%TYPE ,
        cm_trx_number       ra_customer_trx.trx_number%TYPE ,
        inv_customer_trx_id ra_customer_trx.customer_trx_id%TYPE ,
        inv_trx_number      ra_customer_trx.trx_number%TYPE ,
        installment         ar_payment_schedules.terms_sequence_number%TYPE ,
        applied_payment_schedule_id    ar_payment_schedules.payment_schedule_id%TYPE ,
        amount_applied ar_receivable_applications.amount_applied%TYPE ,
        inv_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%TYPE ,
        inv_line_number ra_customer_trx_lines.line_number%TYPE );

TYPE G_cm_unapp_rec_type   IS RECORD
     (cm_trx_number        ra_customer_trx.trx_number%TYPE,
      cm_customer_trx_id   ar_receivable_applications.customer_trx_id%TYPE,
      inv_trx_number        ra_customer_trx.trx_number%TYPE,
      inv_customer_trx_id   ar_receivable_applications.customer_trx_id%TYPE,
      applied_ps_id     ar_receivable_applications.applied_payment_schedule_id%TYPE,
      receivable_application_id     ar_receivable_applications.receivable_application_id%TYPE);


original_cm_app_info    G_cm_app_rec_type;
original_cm_unapp_info  G_cm_unapp_rec_type;

TYPE cm_app_rec_type IS RECORD (
        cm_customer_trx_id  ra_customer_trx.customer_trx_id%TYPE,
        cm_trx_number       ra_customer_trx.trx_number%TYPE,
        inv_customer_trx_id ra_customer_trx.customer_trx_id%TYPE,
        inv_trx_number      ra_customer_trx.trx_number%TYPE,
        installment       NUMBER(15),
        applied_payment_schedule_id    NUMBER(15),
        amount_applied ar_receivable_applications.amount_applied%TYPE,
        apply_date ar_receivable_applications.apply_date%TYPE,
        gl_date ar_receivable_applications.gl_date%TYPE,
        inv_customer_trx_line_id  ra_customer_trx_lines.customer_trx_line_id%TYPE ,
        inv_line_number ra_customer_trx_lines.line_number%TYPE ,
        show_closed_invoices  VARCHAR2(1),
        ussgl_transaction_code ar_receivable_applications.ussgl_transaction_code%TYPE ,
        attribute_category ar_receivable_applications.attribute_category%TYPE ,
        attribute1 ar_receivable_applications.attribute1%TYPE ,
        attribute2 ar_receivable_applications.attribute2%TYPE ,
        attribute3 ar_receivable_applications.attribute3%TYPE ,
        attribute4 ar_receivable_applications.attribute4%TYPE ,
        attribute5 ar_receivable_applications.attribute5%TYPE ,
        attribute6 ar_receivable_applications.attribute6%TYPE ,
        attribute7 ar_receivable_applications.attribute7%TYPE ,
        attribute8 ar_receivable_applications.attribute8%TYPE ,
        attribute9 ar_receivable_applications.attribute9%TYPE ,
        attribute10 ar_receivable_applications.attribute10%TYPE ,
        attribute11 ar_receivable_applications.attribute11%TYPE ,
        attribute12 ar_receivable_applications.attribute12%TYPE ,
        attribute13 ar_receivable_applications.attribute13%TYPE ,
        attribute14 ar_receivable_applications.attribute14%TYPE ,
        attribute15 ar_receivable_applications.attribute15%TYPE ,
        global_attribute_category ar_receivable_applications.global_attribute_category%TYPE ,
        global_attribute1 ar_receivable_applications.global_attribute1%TYPE ,
        global_attribute2 ar_receivable_applications.global_attribute2%TYPE ,
        global_attribute3 ar_receivable_applications.global_attribute3%TYPE ,
        global_attribute4 ar_receivable_applications.global_attribute4%TYPE ,
        global_attribute5 ar_receivable_applications.global_attribute5%TYPE ,
        global_attribute6 ar_receivable_applications.global_attribute6%TYPE ,
        global_attribute7 ar_receivable_applications.global_attribute7%TYPE ,
        global_attribute8 ar_receivable_applications.global_attribute8%TYPE ,
        global_attribute9 ar_receivable_applications.global_attribute9%TYPE ,
        global_attribute10 ar_receivable_applications.global_attribute10%TYPE ,
        global_attribute11 ar_receivable_applications.global_attribute11%TYPE ,
        global_attribute12 ar_receivable_applications.global_attribute12%TYPE ,
        global_attribute13 ar_receivable_applications.global_attribute13%TYPE ,
        global_attribute14 ar_receivable_applications.global_attribute14%TYPE ,
        global_attribute15 ar_receivable_applications.global_attribute15%TYPE ,
        global_attribute16 ar_receivable_applications.global_attribute16%TYPE ,
        global_attribute17 ar_receivable_applications.global_attribute17%TYPE ,
        global_attribute18 ar_receivable_applications.global_attribute18%TYPE ,
        global_attribute19 ar_receivable_applications.global_attribute19%TYPE ,
        global_attribute20 ar_receivable_applications.global_attribute20%TYPE ,
        comments ar_receivable_applications.comments%TYPE,
        called_from    VARCHAR2(20) );

TYPE cm_unapp_rec_type IS RECORD (
        cm_customer_trx_id  ra_customer_trx.customer_trx_id%TYPE,
        cm_trx_number       ra_customer_trx.trx_number%TYPE,
        inv_customer_trx_id ra_customer_trx.customer_trx_id%TYPE,
        inv_trx_number      ra_customer_trx.trx_number%TYPE,
        installment       NUMBER(15),
        applied_payment_schedule_id    NUMBER(15),
        receivable_application_id   NUMBER(15),
        reversal_gl_date  DATE,
        called_from       VARCHAR2(20));

PROCEDURE apply_on_account(
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_cm_app_rec       IN  cm_app_rec_type,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      x_out_rec_application_id        OUT NOCOPY NUMBER,
      x_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
      x_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
      p_org_id           IN   NUMBER  DEFAULT NULL);

PROCEDURE unapply_on_account(
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_cm_unapp_rec     IN  cm_unapp_rec_type,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      p_org_id           IN   NUMBER  DEFAULT NULL);

END AR_CM_API_PUB;

/
