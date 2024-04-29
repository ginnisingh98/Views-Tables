--------------------------------------------------------
--  DDL for Package POS_SBD_IBY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SBD_IBY_PKG" AUTHID CURRENT_USER as
/*$Header: POSIBYS.pls 120.1 2005/08/31 17:32:35 gdwivedi noship $ */


-- global variable for logging
g_log_module_name VARCHAR2(30) := 'POSIBYB';

/* This procedure removes the iby temp account in temp account request table.
 *
 */
PROCEDURE remove_iby_temp_account (
  p_iby_temp_ext_bank_account_id IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure creates the iby temp account in temp account request table.
 *
 */

PROCEDURE create_iby_temp_account (
  p_party_id in NUMBER
, p_status in varchar2
, p_owner_primary_flag in varchar2
, p_payment_factor_flag in varchar2
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
, p_BANK_STATE in VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
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
, p_BRANCH_STATE in VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
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
, p_NOTES in VARCHAR2
, p_NOTE_ALT in varchar2
, x_temp_ext_bank_account_id out nocopy NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure updates the iby temp account in temp account request table.
 *
 */
PROCEDURE update_iby_temp_account (
  p_temp_ext_bank_acct_id in number
, p_party_id in NUMBER
, p_status in varchar2
, p_owner_primary_flag in varchar2
, p_payment_factor_flag in varchar2
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
, p_BANK_STATE in VARCHAR2
, p_BANK_ZIP in VARCHAR2
, p_BANK_PROVINCE in VARCHAR2
, p_BANK_COUNTRY in VARCHAR2
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
, p_BRANCH_STATE in VARCHAR2
, p_BRANCH_ZIP in VARCHAR2
, p_BRANCH_PROVINCE in VARCHAR2
, p_BRANCH_COUNTRY in VARCHAR2
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
, p_NOTES in VARCHAR2
, p_NOTE_ALT in varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure updates the location.
 *
 */
PROCEDURE update_location (
  p_location_id in NUMBER
, p_ADDRESS1 in VARCHAR2
, p_ADDRESS2 in VARCHAR2
, p_ADDRESS3 in VARCHAR2
, p_ADDRESS4 in VARCHAR2
, p_CITY in VARCHAR2
, p_COUNTY in VARCHAR2
, p_STATE in VARCHAR2
, p_ZIP in VARCHAR2
, p_PROVINCE in VARCHAR2
, p_COUNTRY in VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure creates the location.
 *
 */
PROCEDURE create_location (
  p_ADDRESS1 in VARCHAR2
, p_ADDRESS2 in VARCHAR2
, p_ADDRESS3 in VARCHAR2
, p_ADDRESS4 in VARCHAR2
, p_CITY in VARCHAR2
, p_COUNTY in VARCHAR2
, p_STATE in VARCHAR2
, p_ZIP in VARCHAR2
, p_PROVINCE in VARCHAR2
, p_COUNTRY in VARCHAR2
, x_location_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure validates bank account information
 *
 */

PROCEDURE validate_account (
  p_mapping_id in NUMBER
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
, p_account_request_id in number
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
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure approves the request in iby temp account table.
 *
 */
PROCEDURE approve_iby_temp_account (
  p_temp_ext_bank_account_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure updates the requests in iby temp account table.
 * with the approved account information.
 */
PROCEDURE update_req_with_account (
  p_temp_ext_bank_account_id in number
, p_ext_bank_account_id in number
, p_account_request_id in number
, p_bank_id in number
, p_branch_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure prenotes the request in iby temp account table.
 *
 */
PROCEDURE prenote_iby_temp_account (
  p_temp_ext_bank_account_id in number
, p_vendor_site_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure prenotes the request in iby temp account table.
 *
 */
PROCEDURE assign_site_to_account (
  p_temp_ext_bank_account_id in number
, p_vendor_site_id in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


PROCEDURE check_for_duplicates (
  p_mapping_id in NUMBER
, p_BANK_ID in NUMBER
, p_BANK_NAME in VARCHAR2
, p_BANK_NUMBER in VARCHAR2
, p_BRANCH_ID in NUMBER
, p_BRANCH_NAME in VARCHAR2
, p_BRANCH_NUMBER in VARCHAR2
, p_EXT_BANK_ACCOUNT_ID in number
, p_bank_account_number in varchar2
, p_bank_account_name in varchar2
, p_currency_code in varchar2
, p_country_code in varchar2
, p_account_request_id in number
, x_need_validation out nocopy varchar2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

END POS_SBD_IBY_PKG;

 

/
