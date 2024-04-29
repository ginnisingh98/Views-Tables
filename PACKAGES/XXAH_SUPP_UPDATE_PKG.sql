--------------------------------------------------------
--  DDL for Package XXAH_SUPP_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_UPDATE_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_UPDATE_PKG
     * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 25-May-2016        1.0       Sunil Thamke     Initial
     ****************************************************************************/
   PROCEDURE p_update_supplier (errbuf OUT VARCHAR2, retcode OUT NUMBER);


   PROCEDURE P_GET_VENDOR_ID;

   PROCEDURE P_UPDATE_ADDRESS (p_rowid           IN VARCHAR2,
                               p_location_id     IN NUMBER,
                               p_address_line1   IN VARCHAR2,
                               p_address_line2   IN VARCHAR2,
                               p_address_line3   IN VARCHAR2,
                               p_address_line4   IN VARCHAR2,
                               p_city            IN VARCHAR2,
                               p_postal_code     IN VARCHAR2,
                               p_state           IN VARCHAR2,
                               p_county          IN VARCHAR2,
                               p_country         IN VARCHAR2);

   PROCEDURE P_UPDATE_DFF (p_rowid             IN VARCHAR2,
                           l_vendor_site_id   IN NUMBER,
                           p_attribute1       IN VARCHAR2,
                           p_attribute2       IN VARCHAR2,
                           p_attribute3       IN VARCHAR2,
                           p_attribute4       IN VARCHAR2,
                           p_attribute5       IN VARCHAR2,
                           p_attribute6       IN VARCHAR2,
                           p_attribute7       IN VARCHAR2,
                           p_attribute8       IN VARCHAR2);

   PROCEDURE P_UPDATE_SUPPLIER_SITE (p_row_id IN VARCHAR2,
                                    p_vendor_site_id   IN NUMBER,
                                     p_email_address    IN VARCHAR2);

   PROCEDURE P_UPDATE_VENDOR (p_row_id IN VARCHAR2,
                                    p_vendor_id IN NUMBER,
                                    p_po_match IN VARCHAR2);

   PROCEDURE P_UDA (ln_rowid               IN VARCHAR2,
                    ln_party_id            IN NUMBER,
                    lv_attr_group_name     IN VARCHAR2,
                    lv_attr_display_name   IN VARCHAR2,
                    ln_attr_value_str1     IN VARCHAR2,
                    ln_attr_value_str2     IN VARCHAR2,
                    p_data_level           IN VARCHAR2,
                    p_data_level_1         IN NUMBER,
                    p_data_level_2         IN NUMBER);

   PROCEDURE P_UPDATE_ADDRESS_NAME (p_row_id IN VARCHAR2,
                                    p_party_site_id     IN     NUMBER,
                                    p_party_site_name   IN     VARCHAR2,
                                    p_return_status        OUT VARCHAR);

   PROCEDURE P_VAT_REGISTRATION_NUM (p_row_id IN VARCHAR2,
                                    lv_PARTY_ID               IN NUMBER,
                                     lv_vat_registration_num   IN VARCHAR2);

   PROCEDURE P_SUPPLIER_UPDATE(p_supplier_name IN VARCHAR2);

   PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2);

   PROCEDURE p_report;
END XXAH_SUPP_UPDATE_PKG;

/
