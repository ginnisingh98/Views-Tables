--------------------------------------------------------
--  DDL for Package ARP_PROCESS_APPLICATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_APPLICATION2" AUTHID CURRENT_USER AS
/* $Header: ARCEAP2S.pls 120.2 2003/02/28 20:48:51 jbeckett ship $ */

FUNCTION revision RETURN VARCHAR2;

PROCEDURE update_application(
        p_ra_id                        IN  NUMBER,
        p_receipt_ps_id                IN  NUMBER,
        p_invoice_ps_id                IN  NUMBER,
        p_ussgl_transaction_code       IN  VARCHAR2,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL,
        p_receivable_trx_id            IN  ar_receivable_applications.receivables_trx_id%TYPE,
        p_attribute_category           IN  VARCHAR2,
        p_attribute1                   IN  VARCHAR2,
        p_attribute2                   IN  VARCHAR2,
        p_attribute3                   IN  VARCHAR2,
        p_attribute4                   IN  VARCHAR2,
        p_attribute5                   IN  VARCHAR2,
        p_attribute6                   IN  VARCHAR2,
        p_attribute7                   IN  VARCHAR2,
        p_attribute8                   IN  VARCHAR2,
        p_attribute9                   IN  VARCHAR2,
        p_attribute10                  IN  VARCHAR2,
        p_attribute11                  IN  VARCHAR2,
        p_attribute12                  IN  VARCHAR2,
        p_attribute13                  IN  VARCHAR2,
        p_attribute14                  IN  VARCHAR2,
        p_attribute15                  IN  VARCHAR2,
        p_global_attribute_category    IN  VARCHAR2,
        p_global_attribute1            IN  VARCHAR2,
        p_global_attribute2            IN  VARCHAR2,
        p_global_attribute3            IN  VARCHAR2,
        p_global_attribute4            IN  VARCHAR2,
        p_global_attribute5            IN  VARCHAR2,
        p_global_attribute6            IN  VARCHAR2,
        p_global_attribute7            IN  VARCHAR2,
        p_global_attribute8            IN  VARCHAR2,
        p_global_attribute9            IN  VARCHAR2,
        p_global_attribute10           IN  VARCHAR2,
        p_global_attribute11           IN  VARCHAR2,
        p_global_attribute12           IN  VARCHAR2,
        p_global_attribute13           IN  VARCHAR2,
        p_global_attribute14           IN  VARCHAR2,
        p_global_attribute15           IN  VARCHAR2,
        p_global_attribute16           IN  VARCHAR2,
        p_global_attribute17           IN  VARCHAR2,
        p_global_attribute18           IN  VARCHAR2,
        p_global_attribute19           IN  VARCHAR2,
        p_global_attribute20           IN  VARCHAR2,
	p_comments		       IN  VARCHAR2,  -- Added for bug 1839744
        p_gl_date                      OUT NOCOPY DATE,
        p_customer_trx_line_id         IN  NUMBER,
        p_module_name                  IN  VARCHAR2,
        p_module_version               IN  VARCHAR2,
        x_application_ref_id           OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num          OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_acctd_amount_applied_to      OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from    OUT NOCOPY NUMBER,
        p_amount_due_remaining         IN  ar_payment_schedules.amount_due_remaining%TYPE DEFAULT NULL,
        p_application_ref_reason       IN  ar_receivable_applications.application_ref_reason%TYPE DEFAULT NULL,
        p_customer_reference           IN  ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
        p_customer_reason              IN  ar_receivable_applications.customer_reason%TYPE DEFAULT NULL,
        p_applied_rec_app_id           IN  ar_receivable_applications.applied_rec_app_id%TYPE,
        x_claim_reason_name            OUT NOCOPY VARCHAR2);

PROCEDURE delete_selected_transaction(
          p_ra_id       IN NUMBER
        , p_app_ps_id   IN NUMBER);

END arp_process_application2;

 

/
