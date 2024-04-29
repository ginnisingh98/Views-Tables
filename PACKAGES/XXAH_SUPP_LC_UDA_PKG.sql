--------------------------------------------------------
--  DDL for Package XXAH_SUPP_LC_UDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_SUPP_LC_UDA_PKG" 
AS
   /***************************************************************************
     *                           IDENTIFICATION
     *                           ==============
     * NAME              : XXAH_SUPP_LC_UDA_PKG
     * PACKAGE TO NFR Supplier Leaf Commodity update
     ****************************************************************************
     *                           CHANGE HISTORY
     *                           ==============
     * DATE             VERSION     DONE BY
     * 20-AUG-2018       1.0       Menaka    Initial
     ****************************************************************************/
 --  PROCEDURE P_UPDATE_VENDOR (p_rownum IN VARCHAR2,errbuf OUT VARCHAR2, retcode OUT NUMBER);
 PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER) ;

PROCEDURE P_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
   

);
PROCEDURE P_CRE_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
);
 --PROCEDURE p_write_log (p_row_id VARCHAR2, p_message IN VARCHAR2);

PROCEDURE p_report ;
END XXAH_SUPP_LC_UDA_PKG;

/
