--------------------------------------------------------
--  DDL for Package XXAH_SUPP_SITE_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_SITE_UPDATE_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_SITE_UPDATE_PKG
     * DESCRIPTION       : PACKAGE TO Supplier update
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 25-JAN-2018         1.0       Sunil Thamke     Initial
     ****************************************************************************/
PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER,
                   p_type IN VARCHAR2,
                   p_vendor_name IN VARCHAR2) ;


PROCEDURE P_UPDATE_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
);

PROCEDURE P_CRE_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
);

END XXAH_SUPP_SITE_UPDATE_PKG;

/
