--------------------------------------------------------
--  DDL for Package RCV_GAPLESS_NUMBERING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_GAPLESS_NUMBERING" AUTHID CURRENT_USER AS
/* $Header: RCVSBGNS.pls 120.1 2006/08/17 08:01:35 sgumaste noship $ */

PROCEDURE Generate_Invoice_Number (
        p_api_version            IN          NUMBER,
        p_org_id                 IN          NUMBER,     -- BugFix 5192878
        p_vendor_site_id         IN          NUMBER,     -- BugFix 5192878
--      p_buying_company_code    IN          VARCHAR2,   -- BugFix 5192878
--      p_selling_company_code   IN          VARCHAR2,   -- BugFix 5192878
        p_invoice_type           IN          VARCHAR2,
        x_invoice_num            OUT NOCOPY  VARCHAR2,
        x_return_status          OUT NOCOPY  VARCHAR2,
        x_msg_count              OUT NOCOPY  NUMBER,
        x_msg_data               OUT NOCOPY  VARCHAR2
        );
END RCV_GAPLESS_NUMBERING;

 

/
