--------------------------------------------------------
--  DDL for Package OZF_SETTLEMENT_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SETTLEMENT_DOCS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftcsds.pls 120.0 2005/06/01 03:22:14 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_SETTLEMENT_DOCS_PKG
-- Purpose
--
-- History
--
--    MCHANG      23-OCT-2001      Remove security_group_id.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_settlement_doc_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          px_org_id      IN OUT NOCOPY NUMBER,
          p_payment_reference_id       NUMBER,
          p_payment_reference_number   VARCHAR2,
          p_payment_status             VARCHAR2,
          p_group_claim_id             NUMBER,
          p_gl_date                    DATE,
          p_wo_rec_trx_id              NUMBER
);

PROCEDURE Update_Row(
          p_settlement_doc_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_payment_reference_id       NUMBER,
          p_payment_reference_number   VARCHAR2,
          p_payment_status             VARCHAR2,
          p_group_claim_id             NUMBER,
          p_gl_date                    DATE,
          p_wo_rec_trx_id              NUMBER
);

PROCEDURE Delete_Row(
    p_SETTLEMENT_DOC_ID  NUMBER
);

PROCEDURE Lock_Row(
          p_settlement_doc_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_update_date    DATE,
          p_program_id    NUMBER,
          p_created_from    VARCHAR2,
          p_claim_id    NUMBER,
          p_claim_line_id    NUMBER,
          p_payment_method    VARCHAR2,
          p_settlement_id    NUMBER,
          p_settlement_type    VARCHAR2,
          p_settlement_type_id    NUMBER,
          p_settlement_number    VARCHAR2,
          p_settlement_date    DATE,
          p_settlement_amount    NUMBER,
          p_settlement_acctd_amount    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER
);

END OZF_SETTLEMENT_DOCS_PKG;

 

/
