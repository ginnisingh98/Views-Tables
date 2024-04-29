--------------------------------------------------------
--  DDL for Package Body FII_EUL_UTILS_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EUL_UTILS_2" AS
/* $Header: FIIEUL2B.pls 120.0 2002/08/24 04:52:51 appldev noship $ */

FUNCTION foldersToRename(pBusAreaName VARCHAR2,
                         pFolderName  VARCHAR2)

  RETURN VARCHAR2

IS

  RETURN_VALUE VARCHAR2(100) := NULL;

BEGIN

  IF pBusAreaName = 'Revenue Intelligence Business Area' THEN

      SELECT DECODE(pfolderName,
                         'Account:Account FK' , 'Accounting Flexfield Dimension:Account' ,
                        'Company: Company FK' , 'Accounting Flexfield Dimension:Company' ,
                       'Consolidated Revenue' , 'Consolidated Revenue Fact' ,
                 'Cost Center:Cost Center FK' , 'Accounting Flexfield Dimension:Cost Center' ,
   'External Reporting:External Reporting FK' , 'Accounting Flexfield Dimension:External Reporting' ,
       'Line of Business:Line of Business FK' , 'Accounting Flexfield Dimension:Line of Business' ,
                 'Sub-Account:Sub-Account FK' , 'Accounting Flexfield Dimension:Sub-Account' ,
 'Trading Partner Dimension:Bill To Customer' , 'Bill To Customer' ,
 'Trading Partner Dimension:Ship To Customer' , 'Ship To Customer' ,
 'Trading Partner Dimension:Sold To Customer' , 'Sold To Customer' ,
 'Trading Partner Dimension:End User Address' , 'End User Address' ,
'Trading Partner Dimension:Reseller Customer' , 'Reseller Customer' ,
'Trading Partner Dimension:End User Customer' , 'End User Customer' ,
                       'Vertical:Vertical FK' , 'Accounting Flexfield Dimension:Vertical' ,
                                               pFolderName)
       INTO RETURN_VALUE
       FROM DUAL;

  END IF;

  RETURN RETURN_VALUE;

END foldersToRename;

FUNCTION  ItemsToHide(pBusAreaNameIn VARCHAR2,
                      pTableNameIn   VARCHAR2,
                      pColumnNameIn  VARCHAR2,
                      pItemNameIn    VARCHAR2)
  RETURN INTEGER

  IS
     RETURN_VALUE INTEGER := -1;
     --
  BEGIN

--     g_processName := 'itemsToHide';
      --

    IF pBusAreaNameIn IN ('Revenue Intelligence Business Area',
                          'Payables Intelligence Business Area',
                          'Project Intelligence Business Area') AND
       pTableNameIn IN (
                        'EDW_AP_PAYMENT_M'
                       ,'EDW_AP_PAY_TERM_M'
                       ,'EDW_AR_TRX_TYPE_M'
                       /*,'EDW_CURRENCY_M'*/
                       /*,'EDW_DUNS_M'*/
                       ,'EDW_GEOGRAPHY_M'
                       /*,'EDW_GL_BOOK_M'*/
                       ,'EDW_HOLD_M'
                       ,'EDW_HR_PERSON_M'
                       /*,'EDW_INSTANCE_M'*/
                       ,'EDW_INV_TYPE_M'
                       ,'EDW_ITEMS_M'
                       ,'EDW_MTL_UOM_M'
                       ,'EDW_ORGANIZATION_M'
                       ,'EDW_PROJECT_M'
                       ,'EDW_RELEASE_M'
                       ,'EDW_REV_SOURCE_M'
                       ,'EDW_SIC_CODE_M'
                       ,'EDW_TRD_PARTNER_M'
                       /*,'EDW_UNSPSC_M'*/
                       ,'abc') THEN

         IF pBusAreaNameIn = 'Revenue Intelligence Business Area' THEN

           IF (pTableNameIn = 'EDW_AR_TRX_TYPE_M' AND
               pColumnNameIn IN ('CODE_ENABLED_FLAG','TYPE_ALLOW_FRT_FLAG',',TYPE_ALLOW_OVAPP_FLAG',
                                'TYPE_CREATION_SIGN','TYPE_DEFAULT_STATUS','TYPE_DEFAULT_TERM'))
/*              OR
              (pTableNameIn = 'EDW_INSTANCE_M' AND
               pColumnNameIn IN ('INST_DESCRIPTION','INST_NAME'))
*/
              OR
              (pTableNameIn = 'EDW_TRD_PARTNER_M' AND
               SUBSTR(pColumnNameIn,1,4) IN ('PTP1','PTP2','PTP3','PTP4') AND
               pColumnNameIn NOT LIKE 'PTP__NAME')

              THEN RETURN_VALUE := 1;

           END IF;


         ELSIF pBusAreaNameIn = 'Payables Intelligence Business Area' THEN

           IF (pTableNameIn = 'EDW_HOLD_M' AND
               pColumnNameIn IN ('HHLD_POSTABLE_FLAG','HHLD_USER_RELEASEABLE_FLAG','HHLD_USER_UPDATEABLE_FLAG'))
              OR
              (pTableNameIn = 'EDW_INV_TYPE_M' AND
               pColumnNameIn IN ('IVTY_DESCRIPTION'))
              OR
              (pTableNameIn = 'EDW_AP_PAYMENT_M' AND
               pColumnNameIn IN ('PCHK_STATUS_LOOKUP_CODE'))
              OR
              (pTableNameIn = 'EDW_RELEASE_M' AND
               pColumnNameIn IN ('RLSE_USER_RELEASEABLE_FLAG','RLSE_POSTABLE_FLAG'))
/*
              OR
              (pTableNameIn = 'EDW_INSTANCE_M' AND
               pColumnNameIn IN ('INST_DESCRIPTION','INST_NAME'))
*/
              OR
              (pTableNameIn = 'EDW_TRD_PARTNER_M' AND
               SUBSTR(pColumnNameIn,1,4) IN ('PTP1','PTP2','PTP3') AND
               pColumnNameIn NOT LIKE 'PTP__NAME')

              THEN RETURN_VALUE := 1;

           END IF;


         ELSIF pBusAreaNameIn = 'Project Intelligence Business Area' THEN

           IF (pTableNameIn = 'EDW_TRD_PARTNER_M' AND
               SUBSTR(pColumnNameIn,1,4) IN ('PTP1','PTP2','PTP3','PTP4') AND
               pColumnNameIn NOT LIKE 'PTP__NAME')

             THEN RETURN_VALUE := 1;

           END IF;

         ELSE

           NULL;

         END IF;

           IF
/*
              (pTableNameIn = 'EDW_CURRENCY_M' AND
               pColumnNameIn IN ('ALL_NAME','CRNC_CURRENCY','CRNC_DATE_EFFECTIVE','CRNC_DATE_END',
                                 'CRNC_DERIVE_EFFT_DATE','CRNC_DERIVE_FACTOR','CRNC_DERIVE_TYPE',
                                 'CRNC_DESCRIPTION','CRNC_ENABLED_FLAG','CRNC_ISO_FLAG','CRNC_PRECISION'))
               OR
*/
/*
              (pTableNameIn = 'EDW_DUNS_M' AND
               pColumnNameIn IN (
                 --'ALL_NAME',
                 'DNMR_FAILURE_INDU_INCE_DFT','DNMR_FAILURE_INDU_PCNT_RANK','DNMR_FAILURE_NATL_INCE_DFT',
                 'DNMR_FAILURE_NATL_PCNT_RANK','PRNT_INSTANCE','HQTR_CITY','HQTR_STATE_PROV','HQTR_COUNTRY','DNMR_CITY',
                 'DNMR_ZIP_CODE','DNMR_LOCATION_STATUS','DNMR_LEGAL_STATUS','DNMR_LABOR_SURPLUS_FLAG','DNMR_ISO9000_REGISTRATION',
                 'DNMR_INVENTORY','DNMR_FEDERAL_TAX_ID','DNMR_IMPORT_FLAG','PRNT_ADDRESS','DOME_TELEPHONE','DOME_COUNTRY',
                 'DOME_POSTAL_CODE','DOME_STATE_PROV','DOME_CITY','DOME_ADDRESS','GLBL_STATE_PROV','GLBL_CITY','GLBL_ADDRESS',
                 'PRNT_TELEPHONE','PRNT_COUNTRY','PRNT_POSTAL_CODE','PRNT_STATE_PROV','PRNT_CITY','DNMR_DOMESTIC_ULT_CITY',
                 'DNMR_DOMESTIC_ULT_ADDRESS','DNMR_DOMESTIC_ULT_NAME','DNMR_GLOBAL_ULT_TELEPHONE','DNMR_GLOBAL_ULT_COUNTRY',
                 'DNMR_GLOBAL_ULT_POSTAL_CODE','HQTR_INSTANCE','DNMR_HQ_CITY','DNMR_HQ_ADDRESS','DNMR_HQ_FLAG','DNMR_HQ_NAME',
                 'DNMR_PARENT_TELEPHONE','DNMR_PARENT_COUNTRY','DNMR_PARENT_POSTAL_CODE','DNMR_PARENT_STATE_PROV','DNMR_GLOBAL_ULT_ADDRESS',
                 'DNMR_GLOBAL_ULT_NAME','DOME_INSTANCE','DNMR_OWNS_RENTS_IND','DNMR_SLOW_PAYMENTS','DNMR_PAYDEX_PRIOR_Q3',
                 'DNMR_PAYDEX_PRIOR_Q2','DNMR_PAYDEX_PRIOR_Q1','DNMR_PAYDEX_NORM','DNMR_PAYDEX_CURRENT','DNMR_OOB_IND','DNMR_SUITS_COUNT',
                 'DNMR_LIENS_COUNT','DNMR_JUDGMENTS_COUNT','DNMR_NEGATIVE_PAYMENTS','DNMR_HISTORY','DNMR_HIGH_RISK_IND','DNMR_HIGH_CREDIT',
                 'DNMR_FIRE_DISASTER_IND','DNMR_FAILURE_SCORE','DNMR_FAILURE_IND','DNMR_DELINQUENCY_SCORE','DNMR_DEBARMENT_FLAG',
                 'DNMR_DNB_RATING','DNMR_CRIMINAL_PROCEEDINGS_IND','DNMR_BANKRUPTCY_IND','DNMR_AVERAGE_HIGH_CREDIT','DNMR_PREV_STATEMENT_TYPE',
                 'DNMR_PREV_STATEMENT_DATE','DNMR_PREV_CURRENT_LIABILITIES','DNMR_PREV_CURRENT_ASSETS','DNMR_PREV_TOTAL_ASSETS',
                 'DNMR_PREV_NET_WORTH','DNMR_PREV_SALES','DNMR_REPORT_BASE_DATE','DNMR_CONTROL_YEAR','DNMR_CURRENT_STATEMENT_TYPE',
                 'DNMR_CURRENT_STATEMENT_DATE','DNMR_TOTAL_PAYMENTS','DNMR_ACCOUNTS_RECEIVABLES','DNMR_CURRENT_LIABILITIES',
                 'DNMR_CASH','DNMR_CURRENT_ASSETS','DNMR_TOTAL_DEBT','DNMR_TOTAL_ASSETS','DNMR_NET_WORTH','DNMR_NET_PROFIT',
                 'DNMR_SALES','DNMR_TRADE_STYLE','DNMR_GLOBAL_ULT_STATE_PROV','DNMR_GLOBAL_ULT_CITY','DNMR_INSTANCE','DNMR_HQ_TELEPHONE',
                 'DNMR_HQ_COUNTRY','DNMR_HQ_POSTAL_CODE','DNMR_HQ_STATE_PROV','DNMR_PARENT_CITY','DNMR_PARENT_ADDRESS','DNMR_PARENT_DUNS',
                 'DNMR_PARENT_NAME','DNMR_DOMESTIC_ULT_TELEPHONE','DNMR_DOMESTIC_ULT_COUNTRY','DNMR_DOMESTIC_ULT_POSTAL_CODE',
                 'DNMR_DOMESTIC_ULT_STATE_PROV','LAST_UPDATE_DATE','GLBL_INSTANCE','GLBL_TELEPHONE','GLBL_COUNTRY','GLBL_POSTAL_CODE',
                 'DNMR_EXPORT_FLAG','DNMR_CEO_TITLE','DNMR_CEO_NAME','DNMR_BUSINESS_MOVED_IND','DNMR_WOMAN_OWNED_FLAG','DNMR_SDB_ENTRANCE_DATE',
                 'DNMR_SDB_EXIT_DATE','DNMR_SMALL_BUSINESS_FLAG','DNMR_MINORITY_OWNED_TYPE','DNMR_MINORITY_OWNED_FLAG','DNMR_DISADVANTAGED_FLAG',
                 'DNMR_CONG_DIST_CODE3','DNMR_CONG_DIST_CODE2','DNMR_CONG_DIST_CODE1','DNMR_TELEPHONE','DNMR_COUNTRY','DNMR_STATE_PROV',
                 'DNMR_ADDRESS','DNMR_COMPANY_NAME','HQTR_TELEPHONE','HQTR_POSTAL_CODE','HQTR_DUNS_NUMBER','HQTR_ADDRESS'))
                OR
*/
                (pTableNameIn = 'EDW_GEOGRAPHY_M' AND
                 pColumnNameIn IN ('ARE2_NAME','REGN_NAME','SREG_NAME'))
                OR
                (pTableNameIn = 'EDW_ITEMS_M' AND
                 pColumnNameIn IN ('CCIT_CATEGORY_NAME','CCIT_DESCRIPTION',
                                   'CCAT_CATEGORY_NAME','CCAT_DESCRIPTION',
                                   'ECIT_CATEGORY_NAME','ECIT_DESCRIPTION',
                                   'ECAT_CATEGORY_NAME','ECAT_DESCRIPTION',
                                   'PLIN_NAME','PLIN_DESCRIPTION','PLIN_ENABLE_FLAG',
                                   'ICIT_CATEGORY_NAME','ICIT_DESCRIPTION',
                                   'ICAT_CATEGORY_NAME','ICAT_DESCRIPTION',
                                   'IREV_LEVEL_NAME',
                                   'ITEM_ONE_TIME_FLAG',
                                   'MCIT_CATEGORY_NAME','MCIT_DESCRIPTION',
                                   'MCAT_CATEGORY_NAME','MCAT_DESCRIPTION',
                                   'OCIT_CATEGORY_NAME','OCIT_DESCRIPTION',
                                   'OCAT_CATEGORY_NAME','OCAT_DESCRIPTION',
                                   'LCIT_CATEGORY_NAME','LCIT_DESCRIPTION',
                                   'LCAT_CATEGORY_NAME','LCAT_DESCRIPTION',
                                   'PCIT_CATEGORY_NAME','PCIT_DESCRIPTION',
                                   'PCAT_CATEGORY_NAME','PCAT_DESCRIPTION',
                                   'IORG_EFFECTIVITY_CONTROL','IORG_EXPRS_DELIVERY',
                                   'IORG_HAZARD_CLASS_ID','IORG_INSP_REQUIRED',
                                   'IORG_LOCATOR_CONTROL','IORG_LOT_CONTROL',
                                   'IORG_MRP_PLN_METHOD','IORG_MAKE_OR_BUY_FLAG',
                                   'IORG_PRC_TOLERANCE_PCT','IORG_SERIAL_CONTROL',
                                   'IORG_SHELF_LIFE_CODE','IORG_SHELF_LIFE_DAYS',
                                   'IORG_SUBSTITUTE_RCPT','IORG_UN_NUMBER_ID',
                                   'IORG_UNORDERED_RCPT',
                                   'PCTG_DESCRIPTION','PCTG_ENABLED_FLAG','PCTG_NAME',
                                   'PRDF_DESCRIPTION','PRDF_NAME','PRDF_PRODUCT_FAMILY',
                                   'PGRP_DESCRIPTION','PGRP_ENABLED_FLAG','PGRP_NAME',
                                   'SCIT_CATEGORY_NAME','SCIT_DESCRIPTION',
                                   'SCAT_CATEGORY_NAME','SCAT_DESCRIPTION',
                                   'CI11_DESCRIPTION','CI11_CATEGORY_NAME',
                                   'CI12_DESCRIPTION','CI12_CATEGORY_NAME',
                                   'CI13_DESCRIPTION','CI13_CATEGORY_NAME',
                                   'CI14_DESCRIPTION','CI14_CATEGORY_NAME',
                                   'CI15_DESCRIPTION','CI15_CATEGORY_NAME',
                                   'CI16_DESCRIPTION','CI16_CATEGORY_NAME',
                                   'CI21_DESCRIPTION','CI21_CATEGORY_NAME',
                                   'CI22_DESCRIPTION','CI22_CATEGORY_NAME',
                                   'CI23_DESCRIPTION','CI23_CATEGORY_NAME',
                                   'CI24_DESCRIPTION','CI24_CATEGORY_NAME',
                                   'CI25_DESCRIPTION','CI25_CATEGORY_NAME',
                                   'CI26_DESCRIPTION','CI26_CATEGORY_NAME',
                                   'CI31_DESCRIPTION','CI31_CATEGORY_NAME',
                                  'CI310_DESCRIPTION','CI310_CATEGORY_NAME',
                                   'CI32_DESCRIPTION','CI32_CATEGORY_NAME',
                                   'CI33_DESCRIPTION','CI33_CATEGORY_NAME',
                                   'CI34_DESCRIPTION','CI34_CATEGORY_NAME',
                                   'CI35_DESCRIPTION','CI35_CATEGORY_NAME',
                                   'CI36_DESCRIPTION','CI36_CATEGORY_NAME',
                                   'CI37_DESCRIPTION','CI37_CATEGORY_NAME',
                                   'CI38_DESCRIPTION','CI38_CATEGORY_NAME',
                                   'CI39_DESCRIPTION','CI39_CATEGORY_NAME',
                                   'CO11_DESCRIPTION','CO11_CATEGORY_NAME',
                                   'CO12_DESCRIPTION','CO12_CATEGORY_NAME',
                                   'CO13_DESCRIPTION','CO13_CATEGORY_NAME',
                                   'CO14_DESCRIPTION','CO14_CATEGORY_NAME',
                                   'CO15_DESCRIPTION','CO15_CATEGORY_NAME',
                                   'CO16_DESCRIPTION','CO16_CATEGORY_NAME'))
                 OR
                (pTableNameIn = 'EDW_ORGANIZATION_M' AND
                 pColumnNameIn IN (
                   'BGRP_DATE_TO',    'BGRP_INT_EXT_FLAG','BGRP_ORG_TYPE', 'BGRP_PRIMARY_CST_MTHD' ,'BGRP_DATE_FROM',
                   'ORGA_DATE_TO','ORGA_ORG_INT_EXT_FLAG',                'ORGA_ORG_PRIM_CST_MTHD' ,'ORGA_DATE_FROM',
                   'LGET_DATE_TO',    'LGET_INT_EXT_FLAG','LGET_ORG_TYPE', 'LGET_PRIMARY_CST_MTHD' ,'LGET_DATE_FROM','LGET_SET_OF_BOOKS',
                   'OPER_DATE_TO',    'OPER_INT_EXT_FLAG','OPER_ORG_TYPE', 'OPER_PRIMARY_CST_MTHD' ,'OPER_DATE_FROM'))
/* In OWB
                OR
                (pTableNameIn = 'EDW_GL_BOOK_M' AND
                 pColumnNameIn IN ('FABK_BOOK_TYPE_NAME','FABK_CURRENCY_CODE',
                                   'FABK_DEPRE_CALANDAR','FABK_FA_BOOK','FABK_INSTANCE',
                                   'FABK_NAME','FABK_PRORATE_CALENDAR'))
*/
                OR
                (pTableNameIn = 'EDW_MTL_UOM_M' AND
                 pColumnNameIn IN ('CREATION_DATE','LAST_UPDATE_DATE'))

                THEN RETURN_VALUE := 1;

           END IF;
      --
    END IF;

      RETURN RETURN_VALUE;

   END ItemsToHide;

END FII_EUL_UTILS_2;

/
