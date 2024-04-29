--------------------------------------------------------
--  DDL for Package OE_BULK_PROCESS_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_PROCESS_HEADER" AUTHID CURRENT_USER As
/* $Header: OEBLHDRS.pls 120.1.12010000.2 2008/11/18 03:23:18 smusanna ship $ */


-----------------------------------------------------------------
-- DATA TYPES (RECORD/TABLE TYPES)
-----------------------------------------------------------------

-- Global Table to store Sequence Types, indexed by Order Type ID
TYPE SEQ_INFO_TBL IS TABLE OF VARCHAR2(01) INDEX BY BINARY_INTEGER;

G_SEQ_INFO_TBL SEQ_INFO_TBL;


---------------------------------------------------------------------
-- PROCEDURES/FUNCTIONS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Functions for cross-attribute validations e.g. agreement - price
-- list, price list - currency, customer - sites, site - site contacts.
---------------------------------------------------------------------

FUNCTION Valid_Tax_Exempt_Reason
 (p_tax_exempt_reason_code          VARCHAR2
 )
RETURN BOOLEAN;


FUNCTION Validate_Agreement
  (p_agreement_id         IN NUMBER
  ,p_pricing_date         IN DATE
  ,p_price_list_id        IN NUMBER
  ,p_sold_to_org_id       IN NUMBER
  )
RETURN BOOLEAN;

FUNCTION Validate_Price_List
  (p_price_list_id      IN NUMBER
  ,p_curr_code          IN VARCHAR2
  ,p_pricing_date       IN DATE
  ,p_calculate_price    IN VARCHAR2 DEFAULT 'Y'
  )
RETURN BOOLEAN;

FUNCTION Validate_Bill_to(p_sold_to IN NUMBER,
                          p_bill_to IN NUMBER)
RETURN BOOLEAN;

FUNCTION Validate_Ship_to(p_sold_to IN  NUMBER,
                          p_Ship_to IN  NUMBER)
RETURN BOOLEAN;

--abghosh
FUNCTION Validate_Sold_to_site(p_sold_to IN  NUMBER,
                          p_Sold_to_site_use_id IN  NUMBER)
RETURN BOOLEAN;
--

FUNCTION Validate_Deliver_to(p_sold_to IN NUMBER,
                             p_deliver_to IN NUMBER)
RETURN BOOLEAN;

FUNCTION Validate_Site_Contact
  (p_site_use_id IN NUMBER
  ,p_contact_id IN NUMBER
  )
RETURN BOOLEAN;

FUNCTION Get_Freight_Carrier
  (p_shipping_method_code   IN VARCHAR2
  ,p_ship_from_org_id       IN VARCHAR2
  )
RETURN VARCHAR2;

-- End customer functions(Bug 5054618)
FUNCTION validate_end_customer(p_end_customer_id IN NUMBER)
   RETURN BOOLEAN;
FUNCTION validate_end_customer_contact(p_end_customer_contact_id IN NUMBER)
   RETURN BOOLEAN;
FUNCTION validate_END_CUSTOMER_SITE_USE ( p_end_customer_site_use_id IN NUMBER,
					  p_end_customer_id IN NUMBER)
   RETURN BOOLEAN;
FUNCTION validate_IB_OWNER ( p_ib_owner IN VARCHAR2 )
   RETURN BOOLEAN;
FUNCTION validate_IB_INST_LOC( p_ib_installed_at_location IN VARCHAR2 )
   RETURN BOOLEAN;
FUNCTION validate_IB_CURRENT_LOCATION ( p_ib_current_location IN VARCHAR2 )
   RETURN BOOLEAN;


---------------------------------------------------------------------
-- PROCEDURE Entity
--
-- Main processing procedure used to process headers in a batch.
-- IN parameters -
-- p_header_rec : order headers in this batch
-- p_defaulting_mode : 'Y' if fixed defaulting is needed, 'N' if
-- defaulting is to be completely bypassed
-- OUT parameters -
-- x_header_scredit_rec : sales credits for headers processed
--
-- Processing steps include:
-- 1. Restricted defaulting on p_header_rec if defaulting_mode is 'Y'
-- 2. Populate all internal fields on p_header_rec
-- 3. All entity validations
-- 4. Other misc processing like holds evaluation, sales credits.
---------------------------------------------------------------------

PROCEDURE Entity
( p_header_rec             IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
, x_header_scredit_rec     IN OUT NOCOPY OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
, p_defaulting_mode        IN VARCHAR2 DEFAULT 'N'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex     IN VARCHAR2 DEFAULT 'Y'
);

END OE_BULK_PROCESS_HEADER;

/
