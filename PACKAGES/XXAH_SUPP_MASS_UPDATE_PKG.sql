--------------------------------------------------------
--  DDL for Package XXAH_SUPP_MASS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_MASS_UPDATE_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_MASS_UPDATE_PKG
     * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 18-JAN-2017        1.0       Sunil Thamke     Initial
     ****************************************************************************/
PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;

PROCEDURE P_VENDOR_VALIDATE;

PROCEDURE P_UPDATE_VENDOR(p_row_id IN VARCHAR2,
                        p_vendor_id IN NUMBER,
                        p_po_match IN VARCHAR2,
                        p_sic_code IN VARCHAR2,
                        p_invoice_currency_code IN VARCHAR2,
                        p_pay_group_code IN VARCHAR2,
                        p_terms_id IN NUMBER,
                        p_end_date_active IN DATE);

PROCEDURE P_UPDATE_SUPPLIER(p_old_supplier_name IN VARCHAR2,
                            p_new_supplier_name IN VARCHAR2,
                            p_party_id IN NUMBER,
                            p_vat_registration_num IN VARCHAR2,
                            p_duns_number IN VARCHAR2);
PROCEDURE P_UPDATE_SUPPLIER_SITE(
    p_vendor_site_id             IN NUMBER,
    p_ss_vendor_site_code         IN VARCHAR2,
    p_ss_invoice_currency         IN VARCHAR2,
    p_ss_pay_group_code         IN VARCHAR2,
    p_ss_retainage_rate         IN NUMBER,
    p_ss_inactive_date            IN DATE,
    p_ss_purchasing_site_flag    IN VARCHAR2,
    p_ss_pay_site_flag            IN VARCHAR2,
    p_ss_primary_pay_site_flag    IN VARCHAR2,
    p_ss_email_address           IN VARCHAR2,
    p_attribute1                IN VARCHAR2,
    p_attribute2     IN VARCHAR2,
    p_attribute3     IN VARCHAR2,
    p_attribute4     IN VARCHAR2,
    p_attribute5     IN VARCHAR2,
    p_attribute6     IN VARCHAR2,
    p_attribute7     IN VARCHAR2,
    p_attribute8     IN VARCHAR2,
    p_attribute10    IN VARCHAR2,
    p_ss_term_id    IN NUMBER
    );

PROCEDURE P_UPDATE_ADDRESS(p_add_location_id IN NUMBER,
                            p_address_line1 IN VARCHAR2,
                            p_address_line2 IN VARCHAR2,
                            p_address_line3 IN VARCHAR2,
                            p_address_line4 IN VARCHAR2,
                            p_city IN VARCHAR2,
                            p_postal_code IN VARCHAR2,
                            p_state IN VARCHAR2,
                            p_county IN VARCHAR2,
                            p_country IN VARCHAR2,
                            p_province IN VARCHAR2) ;

PROCEDURE P_CREATE_BANK (
   p_bank_name             IN       VARCHAR2,
   p_alternate_bank_name   IN       VARCHAR2,
   p_bank_number           IN       VARCHAR2,
   p_country_code          IN       VARCHAR2,
   p_description           IN       VARCHAR2,
   p_bank_id               OUT      NUMBER
);

PROCEDURE P_CREATE_BRANCH (
   p_bank_id            IN       NUMBER,
   p_branch_name        IN       VARCHAR2,
   p_branch_number      IN       VARCHAR2,
   p_bic                IN       VARCHAR,
   p_branch_id          OUT      NUMBER);
PROCEDURE P_CREATE_BANK_ACCT (
   p_bank_id            IN       NUMBER,
   p_branch_id          IN       NUMBER,
   p_party_id           IN       NUMBER,
   p_account_name       IN       VARCHAR2,
   p_account_num        IN       VARCHAR2,
   p_territory_code     IN       VARCHAR,
   p_supp_site_id       IN       NUMBER,
   p_partysite_id       IN       NUMBER,
   p_account_id         OUT      NUMBER,
   p_iban               IN       VARCHAR2,
   p_check_digits       IN       VARCHAR2,
   p_ou_id              IN       NUMBER,
   p_priority           IN       NUMBER
);

PROCEDURE ADDRESS_STATUS(p_party_site_id IN NUMBER, p_status IN VARCHAR2);

PROCEDURE P_END_EXT_BANK_ACCOUNTS(p_ext_bank_account_id IN NUMBER, p_party_id IN NUMBER, p_end_date IN DATE, p_supplier_site_id IN NUMBER, p_party_site_id IN NUMBER)
;
PROCEDURE P_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
);

PROCEDURE P_TAX_CLASSIFICATION(    lv_PARTY_ID IN NUMBER,
                                lv_vat_registration_num    IN VARCHAR2,
                                lv_TAX_CLASSIFICATION_CODE IN VARCHAR2 );

PROCEDURE P_CREATE_EMAIL_CONTACT_POINT( p_party_site_id IN NUMBER, p_email_address IN VARCHAR2 );

PROCEDURE Val_Currency_Code(p_currency_code IN         VARCHAR2,
                            x_valid         OUT NOCOPY BOOLEAN
                            );
PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 );
PROCEDURE p_report;
END XXAH_SUPP_MASS_UPDATE_PKG;

/
