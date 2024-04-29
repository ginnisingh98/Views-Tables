--------------------------------------------------------
--  DDL for Package OZF_AP_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AP_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvapis.pls 120.1 2005/08/19 03:35:25 appldev ship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    Create_ap_invoice
--
-- PURPOSE
--    Create a payabels invoice into payables open interface table.
--
-- PARAMETERS
--    p_claim_number : Will be passed as Invoice number
--    p_settled_date : Will be passed as Invoice_date
--    p_vendor_id    : Supplier id
--    p_vendor_site_id : Supplier site id
--    p_amount_settled : Will be passed as Invoive amount
--    p_currency_code  : Will be passed as Invoice currency code
--    p_exchange_rate  : Invoice exchange rate
--    p_exchange_rate_type : Invoice exchange rate type
--    p_exchange_rate_date : Invoice exchange rate date
--    p_terms_id :  Payment Term id
--    p_payment_method  : Payment method type
--    p_gl_date  : Gl date
--
-- NOTES
--    1. creates an invoice header and invoice line in payables open
--       interface table.
--    2. Passes the claim number and settled date to invoice number
--       and invoice date.
--    3. Source = 'CLAIMS'
--    4. LINE_TYPE_LOOKUP_CODE = 'MISCELLANEOUS'
---   Sahana    20-Jul-2005   R12: Support for EFT, WIRE, AP_DEFAULR
---                           and AP_DEBIT payment methods.
---                           Handling of AP document cancellation.
---------------------------------------------------------------------
PROCEDURE  Create_ap_invoice (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
);


END OZF_AP_INTERFACE_PVT;

 

/
