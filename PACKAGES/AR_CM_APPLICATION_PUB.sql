--------------------------------------------------------
--  DDL for Package AR_CM_APPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CM_APPLICATION_PUB" AUTHID CURRENT_USER AS
/* $Header: ARXPCMAS.pls 120.4.12010000.2 2009/03/11 12:07:44 npanchak ship $           */

--Start of comments
--API name : Credit Memo Application API
--Type     : Public.
--Function : Apply and unapply credit memos
--Pre-reqs :
--
-- Notes :
--
-- Modification History
-- Date         Name          Description
-- 26-JAN-2005  J Beckett     Created.
-- End of comments

TYPE attribute_rec_type IS RECORD(
                        attribute_category    VARCHAR2(30) DEFAULT NULL,
                        attribute1            VARCHAR2(150) DEFAULT NULL,
       					attribute2            VARCHAR2(150) DEFAULT NULL,
        				attribute3            VARCHAR2(150) DEFAULT NULL,
        				attribute4            VARCHAR2(150) DEFAULT NULL,
       					attribute5            VARCHAR2(150) DEFAULT NULL,
        				attribute6            VARCHAR2(150) DEFAULT NULL,
        				attribute7            VARCHAR2(150) DEFAULT NULL,
        				attribute8            VARCHAR2(150) DEFAULT NULL,
        				attribute9            VARCHAR2(150) DEFAULT NULL,
        				attribute10           VARCHAR2(150) DEFAULT NULL,
        				attribute11           VARCHAR2(150) DEFAULT NULL,
        				attribute12           VARCHAR2(150) DEFAULT NULL,
        				attribute13           VARCHAR2(150) DEFAULT NULL,
        				attribute14           VARCHAR2(150) DEFAULT NULL,
        				attribute15           VARCHAR2(150) DEFAULT NULL);

TYPE global_attribute_rec_type IS RECORD(
            global_attribute_category     VARCHAR2(30) default null,
            global_attribute1             VARCHAR2(150) default NULL,
            global_attribute2             VARCHAR2(150) DEFAULT NULL,
            global_attribute3             VARCHAR2(150) DEFAULT NULL,
        	global_attribute4             VARCHAR2(150) DEFAULT NULL,
        	global_attribute5             VARCHAR2(150) DEFAULT NULL,
        	global_attribute6             VARCHAR2(150) DEFAULT NULL,
        	global_attribute7             VARCHAR2(150) DEFAULT NULL,
        	global_attribute8             VARCHAR2(150) DEFAULT NULL,
        	global_attribute9             VARCHAR2(150) DEFAULT NULL,
        	global_attribute10            VARCHAR2(150) DEFAULT NULL,
        	global_attribute11            VARCHAR2(150) DEFAULT NULL,
        	global_attribute12            VARCHAR2(150) DEFAULT NULL,
        	global_attribute13            VARCHAR2(150) DEFAULT NULL,
        	global_attribute14            VARCHAR2(150) DEFAULT NULL,
        	global_attribute15            VARCHAR2(150) DEFAULT NULL,
        	global_attribute16            VARCHAR2(150) DEFAULT NULL,
        	global_attribute17            VARCHAR2(150) DEFAULT NULL,
        	global_attribute18            VARCHAR2(150) DEFAULT NULL,
        	global_attribute19            VARCHAR2(150) DEFAULT NULL,
        	global_attribute20            VARCHAR2(150) DEFAULT NULL);

TYPE global_attribute_rec_type_upd IS RECORD(
                global_attribute_category     VARCHAR2(30)  default FND_API.G_MISS_CHAR,
                global_attribute1             VARCHAR2(150) default FND_API.G_MISS_CHAR,
                global_attribute2             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute3             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute4             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute5             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute6             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute7             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute8             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute9             VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute10            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute11            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute12            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute13            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute14            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute15            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute16            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute17            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute18            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute19            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
                global_attribute20            VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR);

attribute_rec_const  attribute_rec_type;
global_attribute_rec_const global_attribute_rec_type;


PROCEDURE Activity_application(
    -- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_validation_level             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
    -- Credit Memo application parameters.
      p_customer_trx_id              IN ra_customer_trx.customer_trx_id%TYPE, --this has no default
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE, --this has no default
      p_receivables_trx_id           IN ar_receivable_applications.receivables_trx_id%TYPE, --this has no default
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code       IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec                IN attribute_rec_type DEFAULT attribute_rec_const,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN global_attribute_rec_type DEFAULT global_attribute_rec_const,
      p_comments                     IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_chk_approval_limit_flag     IN VARCHAR2 DEFAULT 'Y',
      p_application_ref_type IN OUT NOCOPY
                ar_receivable_applications.application_ref_type%TYPE,
      p_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
      p_application_ref_num IN OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_called_from		    IN VARCHAR2 DEFAULT NULL
     ,p_org_id             	IN NUMBER  DEFAULT NULL
     ,p_pay_group_lookup_code	IN  FND_LOOKUPS.lookup_code%TYPE DEFAULT NULL
     ,p_pay_alone_flag		IN  VARCHAR2 DEFAULT NULL
     ,p_payment_method_code	IN  ap_invoices.payment_method_code%TYPE DEFAULT NULL
     ,p_payment_reason_code	IN  ap_invoices.payment_reason_code%TYPE DEFAULT NULL
     ,p_payment_reason_comments	IN  ap_invoices.payment_reason_comments%TYPE DEFAULT NULL
     ,p_delivery_channel_code	IN  ap_invoices.delivery_channel_code%TYPE DEFAULT NULL
     ,p_remittance_message1	IN  ap_invoices.remittance_message1%TYPE DEFAULT NULL
     ,p_remittance_message2	IN  ap_invoices.remittance_message2%TYPE DEFAULT NULL
     ,p_remittance_message3	IN  ap_invoices.remittance_message3%TYPE DEFAULT NULL
     ,p_party_id		IN  hz_parties.party_id%TYPE DEFAULT NULL
     ,p_party_site_id		IN  hz_party_sites.party_site_id%TYPE DEFAULT NULL
     ,p_bank_account_id		IN  ar_cash_receipts.customer_bank_account_id%TYPE DEFAULT NULL
     ,p_payment_priority	IN  ap_invoices_interface.PAYMENT_PRIORITY%TYPE DEFAULT NULL  --Bug8290172
     ,p_terms_id		IN  ap_invoices_interface.TERMS_ID%TYPE DEFAULT NULL          --Bug8290172
      );

PROCEDURE Activity_unapplication(
    -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_validation_level IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
   -- *** Credit Memo Info. parameters *****
      p_customer_trx_id  IN ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL,
      p_called_from      IN VARCHAR2 DEFAULT NULL,
      p_org_id             	IN NUMBER  DEFAULT NULL
      );

END AR_CM_APPLICATION_PUB;

/
