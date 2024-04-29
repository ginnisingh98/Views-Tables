--------------------------------------------------------
--  DDL for Package POS_SBD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SBD_PKG" AUTHID CURRENT_USER as
/*$Header: POSSBDS.pls 120.3.12010000.2 2013/03/05 11:53:39 pneralla ship $ */

/* This procedure removes the account on buyer's request.
 * It will be directy called from the AM.
 */
PROCEDURE buyer_remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes the account on supplier's request.
 *
 */
PROCEDURE supplier_remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes the account.
 *
 */
PROCEDURE remove_account (
  p_account_request_id	   IN NUMBER
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure updates the payment preferences.
 *
 */
PROCEDURE update_payment_pref(
  p_payment_preference_id     IN NUMBER
, p_party_id                  IN NUMBER
, p_party_site_id             IN NUMBER
, p_payment_currency_code     IN VARCHAR2
, p_invoice_currency_code     IN VARCHAR2
, p_payment_method            IN VARCHAR2
, p_notification_method       IN VARCHAR2
, p_object_version_number  IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure creates an account as a supplier
 * This is called when the supplier submits the request
 * for a new Account.
 */

PROCEDURE supplier_create_account (
  p_mapping_id in NUMBER
, p_request_type in varchar2
, p_address_request_id in number
, p_party_site_id in number

-- Bank
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2

-- Branch
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2

-- Account
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_SUPPLIER in VARCHAR2
, x_account_request_id	  out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure edits an account as a supplier
 *
 */

PROCEDURE supplier_update_account (
  p_mapping_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
-- Bank
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2

-- Branch
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2

-- Account
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_SUPPLIER in VARCHAR2
, x_account_request_id	  out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure approves an account as a buyer
 *
 */

PROCEDURE buyer_approve_account (
  p_party_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
-- Bank
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2

-- Branch
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2

-- Account
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_BUYER in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure prenotes an account as a buyer
 *
 */
PROCEDURE buyer_prenote_account (
  p_party_id in NUMBER
, p_account_request_id in number
, p_object_version_number in number
, p_vendor_site_id in number
-- Bank
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NAME_ALT in varchar2
, p_BANK_NUMBER in VARCHAR2
, p_BANK_INSTITUTION in varchar2
, p_BANK_ADDRESS1 in VARCHAR2
, p_BANK_ADDRESS2 in VARCHAR2
, p_BANK_ADDRESS3 in VARCHAR2
, p_BANK_ADDRESS4 in VARCHAR2
, p_BANK_CITY in VARCHAR2
, p_BANK_COUNTY in VARCHAR2
, p_BANK_STATE VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2

-- Branch
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NAME_ALT in varchar2
, p_BRANCH_NUMBER in VARCHAR2
, p_BRANCH_TYPE in varchar2
, p_RFC_IDENTIFIER in varchar2
, p_BIC in varchar2
, p_BRANCH_ADDRESS1 in VARCHAR2
, p_BRANCH_ADDRESS2 in VARCHAR2
, p_BRANCH_ADDRESS3 in VARCHAR2
, p_BRANCH_ADDRESS4 in VARCHAR2
, p_BRANCH_CITY in VARCHAR2
, p_BRANCH_COUNTY in VARCHAR2
, p_BRANCH_STATE VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2

-- Account
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_bank_account_name_alt in varchar2
, p_check_digits in varchar2
, p_iban in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_FOREIGN_PAYMENT_USE_FLAG in varchar2
, p_bank_account_type in varchar2
, p_account_description in varchar2
, p_end_date in date
, p_start_date in date
, p_agency_location_code in varchar2
, p_account_suffix in varchar2
, p_EXCHANGE_RATE_AGREEMENT_NUM in VARCHAR2
, P_EXCHANGE_RATE_AGREEMENT_TYPE in VARCHAR2
, p_EXCHANGE_RATE in NUMBER
, p_NOTES_FROM_BUYER in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure rejects the account request
 *
 */
PROCEDURE buyer_reject_account (
  p_account_request_id in NUMBER
, p_object_version_number in number
, p_note_from_buyer in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure approves the assignment request
 *
 */

PROCEDURE buyer_approve_assignment (
  p_party_id in NUMBER
, p_assignment_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure rejects the assignment request
 *
 */
PROCEDURE buyer_reject_assignment (
  p_party_id in NUMBER
, p_assignment_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure adds an account assignment on supplier's request.
 *
 */
PROCEDURE supplier_add_account (
  p_mapping_id             IN NUMBER
, p_account_request_id	   IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure creates/update the account assignment on supplier's request.
 *
 */
PROCEDURE supplier_update_assignment (
  p_assignment_id          IN NUMBER
, p_assignment_request_id  IN NUMBER
, p_object_version_number  IN NUMBER
, p_account_request_id	   IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_request_type           IN VARCHAR2
, p_mapping_id             IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, p_priority               IN NUMBER
, p_start_date             IN DATE
, p_end_date               IN DATE
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes the account assignment request if all are current.
 *
 */
PROCEDURE supplier_reset_assignment(
  p_mapping_id             IN NUMBER
, p_party_site_id          IN NUMBER
, p_address_request_id     IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes the account assignment request if all are current.
 *
 */
PROCEDURE sbd_handle_address_apv(
  p_address_request_id     IN NUMBER
, p_party_site_id          IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure checks if any registered supplier has similar bank account.
*/

PROCEDURE checkDupSupBankAcct( p_mapping_id in NUMBER
, p_BANK_ID in NUMBER
, p_BRANCH_ID in NUMBER
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


END POS_SBD_PKG;

/
