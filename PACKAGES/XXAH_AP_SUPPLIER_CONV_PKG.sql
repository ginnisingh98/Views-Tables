--------------------------------------------------------
--  DDL for Package XXAH_AP_SUPPLIER_CONV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_AP_SUPPLIER_CONV_PKG" AUTHID CURRENT_USER
AS
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_AP_SUPPLIER_CONV_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Bank Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 21-May-2015        1.0       Sunil Thamke     Initial
   ****************************************************************************/
   PROCEDURE p_main (errbuf OUT VARCHAR2, retcode OUT NUMBER);

   PROCEDURE p_create_bank (
      p_bank_name             IN       VARCHAR2,
      p_alternate_bank_name   IN       VARCHAR2,
      p_bank_number           IN       VARCHAR2,
      p_country_code          IN       VARCHAR2,
      p_short_bank_name       IN       VARCHAR,
      p_description           IN       VARCHAR2,
      p_supplier_seq          IN       NUMBER,
      p_bank_id               OUT      NUMBER,
      p_bank_error_msg        OUT      VARCHAR2,
      p_error_flag            OUT      VARCHAR2
   );

   PROCEDURE p_create_branch (
      p_bank_id            IN       NUMBER,
      p_branch_name        IN       VARCHAR2,
      p_branch_number      IN       VARCHAR2,
      p_supplier_seq       IN       NUMBER,
      p_bic                IN       VARCHAR,
      p_branch_id          OUT      NUMBER,
      p_branch_error_msg   OUT      VARCHAR2,
      p_error_flag         OUT      VARCHAR2
   );

   PROCEDURE p_create_bank_acct (
      p_bank_id            IN       NUMBER,
      p_branch_id          IN       NUMBER,
      p_party_id           IN       NUMBER,
      p_account_name       IN       VARCHAR2,
      p_account_num        IN       VARCHAR2,--number
      p_territory_code     IN       VARCHAR,
      p_supp_site_id       IN       NUMBER,
      p_partysite_id       IN       NUMBER,
      p_account_id         OUT      NUMBER,
      p_iban               IN       VARCHAR2,
      p_check_digits       IN       VARCHAR2,
      p_ou_id              IN       NUMBER,
      p_priority           IN       NUMBER,
      p_branch_error_msg   OUT      VARCHAR2,
      p_error_flag         OUT      VARCHAR2
   );

   PROCEDURE p_uda (
      ln_party_id            IN   NUMBER,
      lv_attr_group_name     IN   VARCHAR2,
      lv_attr_display_name   IN   VARCHAR2,
      ln_attr_value_str1     IN   VARCHAR2,
      ln_attr_value_str2     IN   VARCHAR2,
      p_data_level           IN   VARCHAR2,
      p_data_level_1         IN   NUMBER,
      p_data_level_2         IN   NUMBER
   );

   PROCEDURE p_update_dff (
      l_vendor_site_id   IN   NUMBER,
      p_attribute1       IN   VARCHAR2,
      p_attribute2       IN   VARCHAR2,
      p_attribute3       IN   VARCHAR2,
      p_attribute4       IN   VARCHAR2,
      p_attribute5       IN   VARCHAR2,
      p_attribute6       IN   VARCHAR2,
      p_attribute7       IN   VARCHAR2,
      p_attribute8       IN   VARCHAR2,
      p_retainage_rate   IN   NUMBER,
      p_duns_number      IN   VARCHAR2
   );

   /*PROCEDURE p_remit_relationships (
      p_party_id                 IN   NUMBER,
      p_vendor_site_id           IN   NUMBER,
      p_rem_supplier_name        IN   VARCHAR,
      p_rem_supplier_site_name   IN   VARCHAR
   );*/

   PROCEDURE p_create_contact_point (
      p_party_site_id   IN   NUMBER,
      p_phone_number    IN   VARCHAR2
   );

   PROCEDURE p_address_purpose (
      p_party_site_id   IN   NUMBER,
      p_site_use_type   IN   VARCHAR2
   );
PROCEDURE P_CREATE_EMAIL_CONTACT_POINT( p_party_site_id IN NUMBER, p_email_address IN VARCHAR2 );
    PROCEDURE P_REPORT(l_con_req_id IN NUMBER);
    PROCEDURE p_supplier_check(p_request_id IN NUMBER);
    END xxah_ap_supplier_conv_pkg; 

/
