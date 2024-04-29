--------------------------------------------------------
--  DDL for Package POS_VENDOR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VENDOR_UTIL_PKG" AUTHID CURRENT_USER as
-- $Header: POSVENDS.pls 120.4.12010000.2 2014/01/08 02:51:08 atjen ship $

-- This procedure will merge the related parties for
-- given vendor_id 's
PROCEDURE merge_vendor_parties
  ( p_vendor_id     IN NUMBER,       -- new VENDOR_ID
    p_dup_vendor_id IN NUMBER        -- old / disabled VENDOR_ID
    --,p_vendor_site_id IN NUMBER,   -- new VENDOR_SITE_ID
    --p_dup_vendor_site_id IN NUMBER -- old / disabled VENDOR_SITE_ID
    );

PROCEDURE merge_registration_details
  (p_vendor_id     IN NUMBER,      -- new VENDOR_ID
   p_dup_vendor_id IN NUMBER       -- old / disabled VENDOR_ID
   );

FUNCTION get_party_id_for_vendor(p_vendor_id IN NUMBER) RETURN NUMBER;

FUNCTION get_po_vendor_id_for_user(p_username IN VARCHAR2) RETURN NUMBER;

FUNCTION get_vendor_party_id_for_user(p_username IN VARCHAR2) RETURN NUMBER;

-- validate_user_setup
-- Purpose: to make sure the user has the correct vendor, site and contact setup
-- for a single supplier hierarchy
-- Return Value: returns value 'Y' or 'N' indicating respectively whether user
-- set-up is valid or not
FUNCTION validate_user_setup (p_user_id in number) RETURN VARCHAR2;

-- Return Y if p_vendor_name already exists in po_vendors
-- Note: this api does case insensitive check
FUNCTION vendor_name_exist (p_vendor_name IN VARCHAR2) RETURN VARCHAR2;

-- Return legal entity id and name based on the liability account
-- (accts_pay_code_combination_id), and the operating unit id
-- of a vendor site; return null if error
PROCEDURE get_le_by_liability_acct
  (p_accts_pay_ccid    IN  NUMBER,
   p_operating_unit_id IN  NUMBER,
   x_le_id             OUT nocopy NUMBER,
   x_le_name           OUT nocopy VARCHAR2
   );

-- Return legal entity id based on the liability account
-- (accts_pay_code_combination_id), and the operating unit id
-- of a vendor site; return null if error
FUNCTION get_le_id_by_liability_acct
  (p_accts_pay_ccid    IN NUMBER,
   p_operating_unit_id IN NUMBER
   )
  RETURN NUMBER;

-- Return legal entity id based on the liability account
-- (accts_pay_code_combination_id), and the operating unit id
-- of a vendor site; return null if error
FUNCTION get_le_name_by_liability_acct
  (p_accts_pay_ccid    IN NUMBER,
   p_operating_unit_id IN NUMBER
   )
  RETURN VARCHAR2;

-- Bug 17068732
-- Supplier Profile Business Event
PROCEDURE Raise_Supplier_Event
(   p_vendor_id        IN         NUMBER,
    p_party_id         IN         NUMBER,
    p_transaction_type IN         VARCHAR2,
    p_entity_name      IN         VARCHAR2,
    p_entity_key       IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2
);

END POS_VENDOR_UTIL_PKG;

/
