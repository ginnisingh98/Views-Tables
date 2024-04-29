--------------------------------------------------------
--  DDL for Package XXAH_SUPP_SITE_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_SITE_UDA_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_SITE_UDA_PKG
     * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 05-Apr-2017        1.0       Sunil Thamke     Initial
     ****************************************************************************/
PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;


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


END XXAH_SUPP_SITE_UDA_PKG;

/
