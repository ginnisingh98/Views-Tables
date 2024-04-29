--------------------------------------------------------
--  DDL for Package ZX_TCM_VALIDATE_EXEMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_VALIDATE_EXEMPT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcvalexempts.pls 120.1 2005/12/21 02:53:51 sachandr ship $ */

PROCEDURE VALIDATE_TAX_EXEMPTIONS
        (p_tax_exempt_number       IN VARCHAR2,
         p_tax_exempt_reason_code  IN VARCHAR2,
         p_ship_to_org_id          IN NUMBER,
         p_invoice_to_org_id       IN NUMBER,
         p_bill_to_cust_account_id IN NUMBER,
         p_ship_to_party_site_id   IN NUMBER,
         p_bill_to_party_site_id   IN NUMBER,
         p_org_id                  IN NUMBER,
         p_bill_to_party_id        IN NUMBER,
         p_legal_entity_id         IN NUMBER,
         p_trx_type_id             IN NUMBER,
         p_batch_source_id         IN NUMBER,
         p_trx_date                IN DATE,
         p_exemption_status        IN VARCHAR2 default 'P',
         x_valid_flag              OUT NOCOPY VARCHAR2,
         x_return_status           OUT NOCOPY VARCHAR2,
         x_msg_count               OUT NOCOPY NUMBER ,
         x_msg_data                OUT NOCOPY VARCHAR2);

END;

 

/
