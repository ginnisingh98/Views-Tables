--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_ITEM_PVT" AS
/* $Header: ICXVPPIB.pls 120.14.12010000.12 2014/02/20 09:22:17 jaxin ship $*/

-- Constants
G_PKG_NAME                      CONSTANT VARCHAR2(30) :='ICX_CAT_POPULATE_ITEM_PVT';
gTotalRowCount                  PLS_INTEGER := 0;
TYPE g_csr_type                 IS REF CURSOR;

----------------------------------------------------
        -- Global PL/SQL Tables --
----------------------------------------------------
-- INSERT icx_cat_items_ctx_hdrs_tlp
gIHInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
gIHPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gIHReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
gIHReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
gIHOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gIHLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIHSourceTypeTbl                DBMS_SQL.VARCHAR2_TABLE;
gIHItemTypeTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIHPurchasingOrgIdTbl           DBMS_SQL.NUMBER_TABLE;
gIHOwningOrgIdTbl               DBMS_SQL.NUMBER_TABLE;
gIHIpCategoryIdTbl              DBMS_SQL.NUMBER_TABLE;
gIHIpCategoryNameTbl            DBMS_SQL.VARCHAR2_TABLE;
gIHPoCategoryIdTbl              DBMS_SQL.NUMBER_TABLE;
gIHSupplierIdTbl                DBMS_SQL.NUMBER_TABLE;
gIHSupplierPartNumTbl           DBMS_SQL.VARCHAR2_TABLE;
gIHSupplierPartAuxidTbl         DBMS_SQL.VARCHAR2_TABLE;
gIHSupplierSiteIdTbl            DBMS_SQL.NUMBER_TABLE;
gIHReqTemplatePoLineIdTbl       DBMS_SQL.NUMBER_TABLE;
gIHItemRevisionTbl              DBMS_SQL.VARCHAR2_TABLE;
gIHPoHeaderIdTbl                DBMS_SQL.NUMBER_TABLE;
gIHDocumentNumberTbl            DBMS_SQL.VARCHAR2_TABLE;
gIHLineNumTbl                   DBMS_SQL.NUMBER_TABLE;
gIHAllowPriceOverrideFlagTbl	DBMS_SQL.VARCHAR2_TABLE;
gIHNotToExceedPriceTbl          DBMS_SQL.NUMBER_TABLE;
gIHLineTypeIdTbl                DBMS_SQL.NUMBER_TABLE;
gIHUnitMeasLookupCodeTbl        DBMS_SQL.VARCHAR2_TABLE;
gIHSuggestedQuantityTbl         DBMS_SQL.NUMBER_TABLE;
gIHUnitPriceTbl                 DBMS_SQL.NUMBER_TABLE;
gIHAmountTbl                    DBMS_SQL.NUMBER_TABLE;
gIHCurrencyCodeTbl              DBMS_SQL.VARCHAR2_TABLE;
gIHRateTypeTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIHRateDateTbl                  DBMS_SQL.DATE_TABLE;
gIHRateTbl                      DBMS_SQL.NUMBER_TABLE;
gIHBuyerIdTbl                   DBMS_SQL.NUMBER_TABLE;
gIHSupplierContactIdTbl         DBMS_SQL.NUMBER_TABLE;
gIHRfqRequiredFlagTbl           DBMS_SQL.VARCHAR2_TABLE;
gIHNegotiatedByPreparerFlagTbl  DBMS_SQL.VARCHAR2_TABLE;
gIHDescriptionTbl               DBMS_SQL.VARCHAR2_TABLE;
--Bug6599217
gIHLongDescriptionTbl            ICX_CAT_POPULATE_MI_PVT.VARCHAR4_TABLE;
gIHOrganizationIdTbl            DBMS_SQL.NUMBER_TABLE;
gIHMasterOrganizationIdTbl      DBMS_SQL.NUMBER_TABLE;
gIHOrderTypeLookupCodeTbl       DBMS_SQL.VARCHAR2_TABLE;
gIHSupplierTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIHGlobalAgreementFlagTbl       DBMS_SQL.VARCHAR2_TABLE;
gIHMergedSourceTypeTbl          DBMS_SQL.VARCHAR2_TABLE;

-- 17076597 changes
gIHUnNumberTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIHHazardClassTbl               DBMS_SQL.VARCHAR2_TABLE;

-- INSERT icx_cat_items_ctx_dtls_tlp
gIDInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
gIDPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gIDReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
gIDReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
gIDOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gIDLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIDPurchasingOrgIdTbl           DBMS_SQL.NUMBER_TABLE;
gIDOwningOrgIdTbl               DBMS_SQL.NUMBER_TABLE;

-- 17076597 changes
gIDUnNumberTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIDHazardClassTbl               DBMS_SQL.VARCHAR2_TABLE;

-- UPDATE icx_cat_items_ctx_hdrs_tlp
gUHInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
gUHPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gUHReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
gUHReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
gUHOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gUHLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;
gUHSourceTypeTbl                DBMS_SQL.VARCHAR2_TABLE;
gUHItemTypeTbl                  DBMS_SQL.VARCHAR2_TABLE;
gUHPurchasingOrgIdTbl           DBMS_SQL.NUMBER_TABLE;
gUHIpCategoryIdTbl              DBMS_SQL.NUMBER_TABLE;
gUHIpCategoryNameTbl            DBMS_SQL.VARCHAR2_TABLE;
gUHPoCategoryIdTbl              DBMS_SQL.NUMBER_TABLE;
gUHSupplierIdTbl                DBMS_SQL.NUMBER_TABLE;
gUHSupplierPartNumTbl           DBMS_SQL.VARCHAR2_TABLE;
gUHSupplierPartAuxidTbl         DBMS_SQL.VARCHAR2_TABLE;
gUHSupplierSiteIdTbl            DBMS_SQL.NUMBER_TABLE;
gUHReqTemplatePoLineIdTbl       DBMS_SQL.NUMBER_TABLE;
gUHItemRevisionTbl              DBMS_SQL.VARCHAR2_TABLE;
gUHPoHeaderIdTbl                DBMS_SQL.NUMBER_TABLE;
gUHDocumentNumberTbl            DBMS_SQL.VARCHAR2_TABLE;
gUHLineNumTbl                   DBMS_SQL.NUMBER_TABLE;
gUHAllowPriceOverrideFlagTbl	DBMS_SQL.VARCHAR2_TABLE;
gUHNotToExceedPriceTbl          DBMS_SQL.NUMBER_TABLE;
gUHLineTypeIdTbl                DBMS_SQL.NUMBER_TABLE;
gUHUnitMeasLookupCodeTbl        DBMS_SQL.VARCHAR2_TABLE;
gUHSuggestedQuantityTbl         DBMS_SQL.NUMBER_TABLE;
gUHUnitPriceTbl                 DBMS_SQL.NUMBER_TABLE;
gUHAmountTbl                    DBMS_SQL.NUMBER_TABLE;
gUHCurrencyCodeTbl              DBMS_SQL.VARCHAR2_TABLE;
gUHRateTypeTbl                  DBMS_SQL.VARCHAR2_TABLE;
gUHRateDateTbl                  DBMS_SQL.DATE_TABLE;
gUHRateTbl                      DBMS_SQL.NUMBER_TABLE;
gUHBuyerIdTbl                   DBMS_SQL.NUMBER_TABLE;
gUHSupplierContactIdTbl         DBMS_SQL.NUMBER_TABLE;
gUHRfqRequiredFlagTbl           DBMS_SQL.VARCHAR2_TABLE;
gUHNegotiatedByPreparerFlagTbl  DBMS_SQL.VARCHAR2_TABLE;
gUHDescriptionTbl               DBMS_SQL.VARCHAR2_TABLE;
--Bug6599217
gUHLongDescriptionTbl        ICX_CAT_POPULATE_MI_PVT.VARCHAR4_TABLE;
gUHOrganizationIdTbl            DBMS_SQL.NUMBER_TABLE;
gUHMasterOrganizationIdTbl      DBMS_SQL.NUMBER_TABLE;

gUHOrderTypeLookupCodeTbl       DBMS_SQL.VARCHAR2_TABLE;
gUHSupplierTbl                  DBMS_SQL.VARCHAR2_TABLE;
gUHGlobalAgreementFlagTbl       DBMS_SQL.VARCHAR2_TABLE;
gUHMergedSourceTypeTbl          DBMS_SQL.VARCHAR2_TABLE;

-- 17076597 changes
gUHUnNumberTbl                  DBMS_SQL.VARCHAR2_TABLE;
gUHHazardClassTbl               DBMS_SQL.VARCHAR2_TABLE;

-- DELETE icx_cat_items_ctx_hdrs_tlp
gDHInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
gDHPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gDHReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
gDHReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
gDHOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gDHLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;

-- DELETE icx_cat_items_ctx_dtls_tlp
gDDInventoryItemIdTbl           DBMS_SQL.NUMBER_TABLE;
gDDPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gDDReqTemplateNameTbl           DBMS_SQL.VARCHAR2_TABLE;
gDDReqTemplateLineNumTbl        DBMS_SQL.NUMBER_TABLE;
gDDOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gDDLanguageTbl                  DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence 1 (Mandatory Row) in icx_cat_items_ctx_dtl_tlp
gDMDInventoryItemIdTbl          DBMS_SQL.NUMBER_TABLE;
gDMDPoLineIdTbl                 DBMS_SQL.NUMBER_TABLE;
gDMDReqTemplateNameTbl          DBMS_SQL.VARCHAR2_TABLE;
gDMDReqTemplateLineNumTbl       DBMS_SQL.NUMBER_TABLE;
gDMDOrgIdTbl                    DBMS_SQL.NUMBER_TABLE;
gDMDOwningOrgIdTbl              DBMS_SQL.NUMBER_TABLE;
gDMDLanguageTbl                 DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence 2 (Supplier) in icx_cat_items_ctx_dtl_tlp
gDSDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDSDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDSDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDSDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDSDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDSDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDSDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence 5 (ItemRevision) in icx_cat_items_ctx_dtl_tlp
gDIRDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDIRDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDIRDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDIRDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDIRDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDIRDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDIRDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence 6 (ShoppingCategory) in icx_cat_items_ctx_dtl_tlp
gDSCDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDSCDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDSCDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDSCDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDSCDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDSCDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDSCDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

-- 17076597 changes starts
-- DELETE rows with sequence 7 (UnNumber) in icx_cat_items_ctx_dtl_tlp
gDUNDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDUNDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDUNDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDUNDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDUNDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDUNDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDUNDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence 8 (HazardClass) in icx_cat_items_ctx_dtl_tlp
gDHZDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDHZDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDHZDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDHZDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDHZDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDHZDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDHZDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;
-- 17076597 changes ends

-- DELETE rows with sequence 15001 (PurchasingOrgId) in icx_cat_items_ctx_dtl_tlp
gDPODInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDPODPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDPODReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDPODReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDPODOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDPODOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDPODPurchasingOrgIdTbl         DBMS_SQL.NUMBER_TABLE;
gDPODLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

-- DELETE rows with sequence > 100 and < 10000 in icx_cat_items_ctx_dtl_tlp
-- (Regular Base and Local Attributes)
gDBLDInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gDBLDPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gDBLDReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gDBLDReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gDBLDOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gDBLDOwningOrgIdTbl             DBMS_SQL.NUMBER_TABLE;
gDBLDLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

PROCEDURE clearTables
(       p_action_mode   IN      VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (p_action_mode IN ('ALL', 'INSERT_CTX_HDRS', 'INSERT_ATTR_VALUES', 'INSERT_ATTR_VALUES_TLP')) THEN
    l_err_loc := 200;
    -- INSERT icx_cat_items_ctx_hdrs_tlp
    gIHInventoryItemIdTbl.DELETE;
    gIHPoLineIdTbl.DELETE;
    gIHReqTemplateNameTbl.DELETE;
    gIHReqTemplateLineNumTbl.DELETE;
    gIHOrgIdTbl.DELETE;
    gIHLanguageTbl.DELETE;
    gIHSourceTypeTbl.DELETE;
    gIHItemTypeTbl.DELETE;
    gIHPurchasingOrgIdTbl.DELETE;
    gIHOwningOrgIdTbl.DELETE;
    gIHIpCategoryIdTbl.DELETE;
    gIHIpCategoryNameTbl.DELETE;
    gIHPoCategoryIdTbl.DELETE;
    gIHSupplierIdTbl.DELETE;
    gIHSupplierPartNumTbl.DELETE;
    gIHSupplierPartAuxidTbl.DELETE;
    gIHSupplierSiteIdTbl.DELETE;
    gIHReqTemplatePoLineIdTbl.DELETE;
    gIHItemRevisionTbl.DELETE;
    gIHPoHeaderIdTbl.DELETE;
    gIHDocumentNumberTbl.DELETE;
    gIHLineNumTbl.DELETE;
    gIHAllowPriceOverrideFlagTbl.DELETE;
    gIHNotToExceedPriceTbl.DELETE;
    gIHLineTypeIdTbl.DELETE;
    gIHUnitMeasLookupCodeTbl.DELETE;
    gIHSuggestedQuantityTbl.DELETE;
    gIHUnitPriceTbl.DELETE;
    gIHAmountTbl.DELETE;
    gIHCurrencyCodeTbl.DELETE;
    gIHRateTypeTbl.DELETE;
    gIHRateDateTbl.DELETE;
    gIHRateTbl.DELETE;
    gIHBuyerIdTbl.DELETE;
    gIHSupplierContactIdTbl.DELETE;
    gIHRfqRequiredFlagTbl.DELETE;
    gIHNegotiatedByPreparerFlagTbl.DELETE;
    gIHDescriptionTbl.DELETE;
    gIHLongDescriptionTbl.DELETE;
    gIHOrganizationIdTbl.DELETE;
    gIHMasterOrganizationIdTbl.DELETE;
    gIHOrderTypeLookupCodeTbl.DELETE;
    gIHSupplierTbl.DELETE;
    gIHGlobalAgreementFlagTbl.DELETE;
    gIHMergedSourceTypeTbl.DELETE;

    -- 17076597 changes
    gIHUnNumberTbl.DELETE;
    gIHHazardClassTbl.DELETE;

  END IF;

  l_err_loc := 300;

  IF (p_action_mode IN ('ALL', 'INSERT_CTX_DTLS')) THEN
    l_err_loc := 400;
    -- INSERT icx_cat_items_ctx_dtl_tlp
    gIDInventoryItemIdTbl.DELETE;
    gIDPoLineIdTbl.DELETE;
    gIDReqTemplateNameTbl.DELETE;
    gIDReqTemplateLineNumTbl.DELETE;
    gIDOrgIdTbl.DELETE;
    gIDLanguageTbl.DELETE;
    gIDPurchasingOrgIdTbl.DELETE;
    gIDOwningOrgIdTbl.DELETE;

    -- 17076597 changes
    gIDUnNumberTbl.DELETE;
    gIDHazardClassTbl.DELETE;

  END IF;

  l_err_loc := 500;

  IF (p_action_mode IN ('ALL', 'UPDATE_CTX_HDRS', 'INSERT_TO_UPDATE_ATTR_VALUES', 'INSERT_TO_UPDATE_ATTR_VALUES_TLP')) THEN
    l_err_loc := 600;
    -- UPDATE icx_cat_items_ctx_hdrs_tlp
    gUHInventoryItemIdTbl.DELETE;
    gUHPoLineIdTbl.DELETE;
    gUHReqTemplateNameTbl.DELETE;
    gUHReqTemplateLineNumTbl.DELETE;
    gUHOrgIdTbl.DELETE;
    gUHLanguageTbl.DELETE;
    gUHSourceTypeTbl.DELETE;
    gUHItemTypeTbl.DELETE;
    gUHPurchasingOrgIdTbl.DELETE;
    gUHIpCategoryIdTbl.DELETE;
    gUHIpCategoryNameTbl.DELETE;
    gUHPoCategoryIdTbl.DELETE;
    gUHSupplierIdTbl.DELETE;
    gUHSupplierPartNumTbl.DELETE;
    gUHSupplierPartAuxidTbl.DELETE;
    gUHSupplierSiteIdTbl.DELETE;
    gUHReqTemplatePoLineIdTbl.DELETE;
    gUHItemRevisionTbl.DELETE;
    gUHPoHeaderIdTbl.DELETE;
    gUHDocumentNumberTbl.DELETE;
    gUHLineNumTbl.DELETE;
    gUHAllowPriceOverrideFlagTbl.DELETE;
    gUHNotToExceedPriceTbl.DELETE;
    gUHLineTypeIdTbl.DELETE;
    gUHUnitMeasLookupCodeTbl.DELETE;
    gUHSuggestedQuantityTbl.DELETE;
    gUHUnitPriceTbl.DELETE;
    gUHAmountTbl.DELETE;
    gUHCurrencyCodeTbl.DELETE;
    gUHRateTypeTbl.DELETE;
    gUHRateDateTbl.DELETE;
    gUHRateTbl.DELETE;
    gUHBuyerIdTbl.DELETE;
    gUHSupplierContactIdTbl.DELETE;
    gUHRfqRequiredFlagTbl.DELETE;
    gUHNegotiatedByPreparerFlagTbl.DELETE;
    gUHDescriptionTbl.DELETE;
    gUHLongDescriptionTbl.DELETE;
    gUHOrganizationIdTbl.DELETE;
    gUHMasterOrganizationIdTbl.DELETE;
    gUHOrderTypeLookupCodeTbl.DELETE;
    gUHSupplierTbl.DELETE;
    gUHGlobalAgreementFlagTbl.DELETE;
    gUHMergedSourceTypeTbl.DELETE;
  END IF;

  l_err_loc := 700;

  IF (p_action_mode IN ('ALL', 'DELETE_CTX_HDRS', 'DELETE_ATTR_VALUES', 'DELETE_ATTR_VALUES_TLP')) THEN
    l_err_loc := 800;
    -- DELETE icx_cat_items_ctx_hdrs_tlp
    gDHInventoryItemIdTbl.DELETE;
    gDHPoLineIdTbl.DELETE;
    gDHReqTemplateNameTbl.DELETE;
    gDHReqTemplateLineNumTbl.DELETE;
    gDHOrgIdTbl.DELETE;
    gDHLanguageTbl.DELETE;
  END IF;

  l_err_loc := 900;

  IF (p_action_mode IN ('ALL', 'DELETE_CTX_DTLS')) THEN
    l_err_loc := 1000;
    -- DELETE icx_cat_items_ctx_dtl_tlp
    gDDInventoryItemIdTbl.DELETE;
    gDDPoLineIdTbl.DELETE;
    gDDReqTemplateNameTbl.DELETE;
    gDDReqTemplateLineNumTbl.DELETE;
    gDDOrgIdTbl.DELETE;
    gDDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 1100;

  IF (p_action_mode IN ('ALL', 'DELETE_SPECIFIC_CTX_DTLS')) THEN
    l_err_loc := 1200;
    -- DELETE rows with sequence > 100 and < 10000 icx_cat_items_ctx_dtl_tlp
    gDBLDInventoryItemIdTbl.DELETE;
    gDBLDPoLineIdTbl.DELETE;
    gDBLDReqTemplateNameTbl.DELETE;
    gDBLDReqTemplateLineNumTbl.DELETE;
    gDBLDOrgIdTbl.DELETE;
    gDBLDOwningOrgIdTbl.DELETE;
    gDBLDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 1300;

  IF (p_action_mode IN ('ALL', 'DELETE_MANDATORY_ROW_CTX_DTLS')) THEN
    l_err_loc := 1400;
    -- DELETE rows with sequence = 1 in icx_cat_items_ctx_dtl_tlp
    gDMDInventoryItemIdTbl.DELETE;
    gDMDPoLineIdTbl.DELETE;
    gDMDReqTemplateNameTbl.DELETE;
    gDMDReqTemplateLineNumTbl.DELETE;
    gDMDOrgIdTbl.DELETE;
    gDMDOwningOrgIdTbl.DELETE;
    gDMDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 1500;

  IF (p_action_mode IN ('ALL', 'DELETE_SUPPLIER_ROW_CTX_DTLS')) THEN
    l_err_loc := 1600;
    -- DELETE rows with sequence = 2 in icx_cat_items_ctx_dtl_tlp
    gDSDInventoryItemIdTbl.DELETE;
    gDSDPoLineIdTbl.DELETE;
    gDSDReqTemplateNameTbl.DELETE;
    gDSDReqTemplateLineNumTbl.DELETE;
    gDSDOrgIdTbl.DELETE;
    gDSDOwningOrgIdTbl.DELETE;
    gDSDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 1700;

  IF (p_action_mode IN ('ALL', 'DELETE_ITEMREV_ROW_CTX_DTLS')) THEN
    l_err_loc := 1800;
    -- DELETE rows with sequence = 5 in icx_cat_items_ctx_dtl_tlp
    gDIRDInventoryItemIdTbl.DELETE;
    gDIRDPoLineIdTbl.DELETE;
    gDIRDReqTemplateNameTbl.DELETE;
    gDIRDReqTemplateLineNumTbl.DELETE;
    gDIRDOrgIdTbl.DELETE;
    gDIRDOwningOrgIdTbl.DELETE;
    gDIRDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 1900;

  IF (p_action_mode IN ('ALL', 'DELETE_SHOPCATG_ROW_CTX_DTLS')) THEN
    l_err_loc := 2000;
    -- DELETE rows with sequence = 6 in icx_cat_items_ctx_dtl_tlp
    gDSCDInventoryItemIdTbl.DELETE;
    gDSCDPoLineIdTbl.DELETE;
    gDSCDReqTemplateNameTbl.DELETE;
    gDSCDReqTemplateLineNumTbl.DELETE;
    gDSCDOrgIdTbl.DELETE;
    gDSCDOwningOrgIdTbl.DELETE;
    gDSCDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 2100;

  IF (p_action_mode IN ('ALL', 'DELETE_PURCHORG_ROW_CTX_DTLS')) THEN
    l_err_loc := 2200;
    -- DELETE rows with sequence =15001 in icx_cat_items_ctx_dtl_tlp
    gDPODInventoryItemIdTbl.DELETE;
    gDPODPoLineIdTbl.DELETE;
    gDPODReqTemplateNameTbl.DELETE;
    gDPODReqTemplateLineNumTbl.DELETE;
    gDPODOrgIdTbl.DELETE;
    gDPODOwningOrgIdTbl.DELETE;
    gDPODPurchasingOrgIdTbl.DELETE;
    gDPODLanguageTbl.DELETE;
  END IF;

-- 17076597 changes starts
  l_err_loc := 2210;

  IF (p_action_mode IN ('ALL', 'DELETE_UN_NUMBER_ROW_CTX_DTLS')) THEN
    l_err_loc := 2220;
    -- DELETE rows with sequence = 7 in icx_cat_items_ctx_dtl_tlp
    gDUNDInventoryItemIdTbl.DELETE;
    gDUNDPoLineIdTbl.DELETE;
    gDUNDReqTemplateNameTbl.DELETE;
    gDUNDReqTemplateLineNumTbl.DELETE;
    gDUNDOrgIdTbl.DELETE;
    gDUNDOwningOrgIdTbl.DELETE;
    gDUNDLanguageTbl.DELETE;
  END IF;

  l_err_loc := 2230;

  IF (p_action_mode IN ('ALL', 'DELETE_HAZARD_CLASS_ROW_CTX_DTLS')) THEN
    l_err_loc := 2240;
    -- DELETE rows with sequence = 8 in icx_cat_items_ctx_dtl_tlp
    gDHZDInventoryItemIdTbl.DELETE;
    gDHZDPoLineIdTbl.DELETE;
    gDHZDReqTemplateNameTbl.DELETE;
    gDHZDReqTemplateLineNumTbl.DELETE;
    gDHZDOrgIdTbl.DELETE;
    gDHZDOwningOrgIdTbl.DELETE;
    gDHZDLanguageTbl.DELETE;
  END IF;

-- 17076597 changes ends
  l_err_loc := 2300;

END clearTables;

/*
FUNCTION logPLSQLTableRow
(       p_index         IN      NUMBER  ,
        p_action_mode   IN      VARCHAR2
)
RETURN VARCHAR2 IS
  l_string VARCHAR2(4000);
BEGIN
  l_string := 'logPLSQLTableRow('||p_action_mode||')['||p_index||']--';
  IF (p_action_mode = 'INSERT_CTX_HDRS') THEN
    --INSERT icx_cat_items_ctx_hdrs_tlp
    l_string := l_string || ' gIHInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gIHReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gIHOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gIHSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSourceTypeTbl, p_index) || ', ';
    l_string := l_string || ' gIHItemTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHItemTypeTbl, p_index) || ', ';
    l_string := l_string || ' gIHPurchasingOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPurchasingOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHOwningOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHOwningOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHIpCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHIpCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHIpCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHIpCategoryNameTbl, p_index) || ', ';
    l_string := l_string || ' gIHPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPoCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierPartNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierPartNumTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierPartAuxidTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierPartAuxidTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierSiteIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHReqTemplatePoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplatePoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHItemRevisionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHItemRevisionTbl, p_index) || ', ';
    l_string := l_string || ' gIHPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPoHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHDocumentNumberTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHDocumentNumberTbl, p_index) || ', ';
    l_string := l_string || ' gIHLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gIHAllowPriceOverrideFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHAllowPriceOverrideFlagTbl, p_index) || ', ';
    l_string := l_string || ' gIHNotToExceedPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHNotToExceedPriceTbl, p_index) || ', ';
    l_string := l_string || ' gIHLineTypeIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHLineTypeIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHUnitMeasLookupCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHUnitMeasLookupCodeTbl, p_index) || ', ';
    l_string := l_string || ' gIHSuggestedQuantityTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSuggestedQuantityTbl, p_index) || ', ';
    l_string := l_string || ' gIHUnitPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHUnitPriceTbl, p_index) || ', ';
    l_string := l_string || ' gIHAmountTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHAmountTbl, p_index) || ', ';
    l_string := l_string || ' gIHCurrencyCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCurrencyCodeTbl, p_index) || ', ';
    l_string := l_string || ' gIHRateTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHRateTypeTbl, p_index) || ', ';
    l_string := l_string || ' gIHRateDateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHRateDateTbl, p_index) || ', ';
    l_string := l_string || ' gIHRateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHRateTbl, p_index) || ', ';
    l_string := l_string || ' gIHBuyerIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHBuyerIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierContactIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierContactIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHRfqRequiredFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHRfqRequiredFlagTbl, p_index) || ', ';
    l_string := l_string || ' gIHNegotiatedByPreparerFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHNegotiatedByPreparerFlagTbl, p_index) || ', ';
    l_string := l_string || ' gIHDescriptionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHDescriptionTbl, p_index) || ', ';
    l_string := l_string || ' gIHOrderTypeLookupCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHOrderTypeLookupCodeTbl, p_index) || ', ';
    l_string := l_string || ' gIHSupplierTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierTbl, p_index) || ', ';
    l_string := l_string || ' gIHGlobalAgreementFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHGlobalAgreementFlagTbl, p_index) || ', ';
    l_string := l_string || ' gIHMergedSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHMergedSourceTypeTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_CTX_DTLS') THEN
    --INSERT icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gIDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gIDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gIDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gIDPurchasingOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDPurchasingOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIDOwningOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIDOwningOrgIdTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'UPDATE_CTX_HDRS') THEN
    --UPDATE icx_cat_items_ctx_hdrs_tlp
    l_string := l_string || ' gUHInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gUHReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gUHOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gUHSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSourceTypeTbl, p_index) || ', ';
    l_string := l_string || ' gUHItemTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHItemTypeTbl, p_index) || ', ';
    l_string := l_string || ' gUHPurchasingOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHPurchasingOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHIpCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHIpCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHIpCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHIpCategoryNameTbl, p_index) || ', ';
    l_string := l_string || ' gUHPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHPoCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierPartNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierPartNumTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierPartAuxidTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierPartAuxidTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierSiteIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHReqTemplatePoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplatePoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHItemRevisionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHItemRevisionTbl, p_index) || ', ';
    l_string := l_string || ' gUHPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHPoHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHDocumentNumberTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHDocumentNumberTbl, p_index) || ', ';
    l_string := l_string || ' gUHLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gUHAllowPriceOverrideFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHAllowPriceOverrideFlagTbl, p_index) || ', ';
    l_string := l_string || ' gUHNotToExceedPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHNotToExceedPriceTbl, p_index) || ', ';
    l_string := l_string || ' gUHLineTypeIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHLineTypeIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHUnitMeasLookupCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHUnitMeasLookupCodeTbl, p_index) || ', ';
    l_string := l_string || ' gUHSuggestedQuantityTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSuggestedQuantityTbl, p_index) || ', ';
    l_string := l_string || ' gUHUnitPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHUnitPriceTbl, p_index) || ', ';
    l_string := l_string || ' gUHAmountTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHAmountTbl, p_index) || ', ';
    l_string := l_string || ' gUHCurrencyCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHCurrencyCodeTbl, p_index) || ', ';
    l_string := l_string || ' gUHRateTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHRateTypeTbl, p_index) || ', ';
    l_string := l_string || ' gUHRateDateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHRateDateTbl, p_index) || ', ';
    l_string := l_string || ' gUHRateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHRateTbl, p_index) || ', ';
    l_string := l_string || ' gUHBuyerIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHBuyerIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierContactIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierContactIdTbl, p_index) || ', ';
    l_string := l_string || ' gUHRfqRequiredFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHRfqRequiredFlagTbl, p_index) || ', ';
    l_string := l_string || ' gUHNegotiatedByPreparerFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHNegotiatedByPreparerFlagTbl, p_index) || ', ';
    l_string := l_string || ' gUHDescriptionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHDescriptionTbl, p_index) || ', ';
    l_string := l_string || ' gUHOrderTypeLookupCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHOrderTypeLookupCodeTbl, p_index) || ', ';
    l_string := l_string || ' gUHSupplierTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierTbl, p_index) || ', ';
    l_string := l_string || ' gUHGlobalAgreementFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHGlobalAgreementFlagTbl, p_index) || ', ';
    l_string := l_string || ' gUHMergedSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUHMergedSourceTypeTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_CTX_HDRS') THEN
    --DELETE icx_cat_items_ctx_hdrs_tlp
    l_string := l_string || ' gDHInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDHPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDHReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDHReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDHOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDHLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDHLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_CTX_DTLS') THEN
    --DELETE icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDDLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_MANDATORY_ROW_CTX_DTLS') THEN
    --DELETE rows with sequence = 1 in icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDMDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDMDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDMDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDMDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDMDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDMDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDMDLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_SUPPLIER_ROW_CTX_DTLS') THEN
    --DELETE rows with sequence = 2 in icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDSDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDSDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDSDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSDLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_ITEMREV_ROW_CTX_DTLS') THEN
    --DELETE rows with sequence = 5 in icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDIRDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDIRDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDIRDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDIRDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDIRDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDIRDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDIRDLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_SHOPCATG_ROW_CTX_DTLS') THEN
    --DELETE rows with sequence = 6 in icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDSCDInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSCDPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSCDReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDSCDReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDSCDOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDSCDLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDSCDLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_PURCHORG_ROW_CTX_DTLS') THEN
    --DELETE rows with sequence =15001 in icx_cat_items_ctx_dtl_tlp
    l_string := l_string || ' gDPODInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDPODPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gDPODReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gDPODReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gDPODOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDPODPurchasingOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODPurchasingOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gDPODLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDPODLanguageTbl, p_index) || ', ';
  END IF;

  RETURN l_string;

END logPLSQLTableRow;
*/

PROCEDURE logPLSQLTableRow
(       p_api_name      IN      VARCHAR2        ,
        p_log_level     IN      NUMBER          ,
        p_index         IN      NUMBER          ,
        p_action_mode   IN      VARCHAR2
)
IS
  l_log_string  VARCHAR2(4000);
  l_err_loc     PLS_INTEGER;
  l_module_name VARCHAR2(80);
BEGIN
  l_err_loc := 100;
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, p_api_name);

    l_err_loc := 220;
    l_log_string := 'logPLSQLTableRow('||p_action_mode||')['||p_index||']--';
    FND_LOG.string(p_log_level, l_module_name, l_log_string);

    l_err_loc := 240;
    IF (p_action_mode = 'INSERT_CTX_HDRS') THEN
      l_err_loc := 300;
      -- INSERT icx_cat_items_ctx_hdrs_tlp
      l_log_string := ' gIHInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSourceTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSourceTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHItemTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHItemTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHPurchasingOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHPurchasingOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHOwningOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHOwningOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHIpCategoryIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHIpCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHIpCategoryNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHIpCategoryNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHPoCategoryIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHPoCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierPartNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierPartNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierPartAuxidTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierPartAuxidTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierSiteIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierSiteIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHReqTemplatePoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHReqTemplatePoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHItemRevisionTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHItemRevisionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHPoHeaderIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHPoHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHDocumentNumberTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHDocumentNumberTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHAllowPriceOverrideFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHAllowPriceOverrideFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHNotToExceedPriceTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHNotToExceedPriceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHLineTypeIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHLineTypeIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHUnitMeasLookupCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHUnitMeasLookupCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSuggestedQuantityTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSuggestedQuantityTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHUnitPriceTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHUnitPriceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHAmountTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHAmountTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHCurrencyCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHCurrencyCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHRateTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHRateTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHRateDateTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHRateDateTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHRateTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHRateTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHBuyerIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHBuyerIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierContactIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierContactIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHRfqRequiredFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHRfqRequiredFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHNegotiatedByPreparerFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHNegotiatedByPreparerFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHDescriptionTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHDescriptionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHOrderTypeLookupCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHOrderTypeLookupCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHSupplierTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHSupplierTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHGlobalAgreementFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHGlobalAgreementFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHMergedSourceTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHMergedSourceTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      -- 17076597 changes starts
      l_log_string := ' gIHUnNumberTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHUnNumberTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHHazardClassTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIHHazardClassTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
      -- 17076597 changes ends
    END IF;

    l_err_loc := 400;

    IF (p_action_mode = 'INSERT_CTX_DTLS') THEN
      l_err_loc := 500;
      -- INSERT icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gIDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDPurchasingOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDPurchasingOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDOwningOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDOwningOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      -- 17076597 changes starts
      l_log_string := ' gIDUnNumberTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDUnNumberTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIDHazardClassTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gIDHazardClassTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
      -- 17076597 changes ends

    END IF;

    l_err_loc := 600;

    IF (p_action_mode = 'UPDATE_CTX_HDRS') THEN
      l_err_loc := 700;
      -- UPDATE icx_cat_items_ctx_hdrs_tlp
      l_log_string := ' gUHInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSourceTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSourceTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHItemTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHItemTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHPurchasingOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHPurchasingOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHIpCategoryIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHIpCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHIpCategoryNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHIpCategoryNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHPoCategoryIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHPoCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierPartNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierPartNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierPartAuxidTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierPartAuxidTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierSiteIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierSiteIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHReqTemplatePoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHReqTemplatePoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHItemRevisionTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHItemRevisionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHPoHeaderIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHPoHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHDocumentNumberTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHDocumentNumberTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHAllowPriceOverrideFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHAllowPriceOverrideFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHNotToExceedPriceTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHNotToExceedPriceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHLineTypeIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHLineTypeIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHUnitMeasLookupCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHUnitMeasLookupCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSuggestedQuantityTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSuggestedQuantityTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHUnitPriceTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHUnitPriceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHAmountTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHAmountTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHCurrencyCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHCurrencyCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHRateTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHRateTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHRateDateTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHRateDateTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHRateTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHRateTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHBuyerIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHBuyerIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierContactIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierContactIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHRfqRequiredFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHRfqRequiredFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHNegotiatedByPreparerFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHNegotiatedByPreparerFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHDescriptionTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHDescriptionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHOrderTypeLookupCodeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHOrderTypeLookupCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHSupplierTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHSupplierTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHGlobalAgreementFlagTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHGlobalAgreementFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHMergedSourceTypeTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHMergedSourceTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      -- 17076597 changes starts
      l_log_string := ' gUHUnNumberTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHUnNumberTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUHHazardClassTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gUHHazardClassTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
      -- 17076597 changes ends

    END IF;

    l_err_loc := 800;

    IF (p_action_mode = 'DELETE_CTX_HDRS') THEN
      l_err_loc := 900;
      -- DELETE icx_cat_items_ctx_hdrs_tlp
      l_log_string := ' gDHInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1000;

    IF (p_action_mode = 'DELETE_CTX_DTLS') THEN
      l_err_loc := 1100;
      -- DELETE icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1200;

    IF (p_action_mode = 'DELETE_MANDATORY_ROW_CTX_DTLS') THEN
      l_err_loc := 1300;
      -- DELETE rows with sequence = 1 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDMDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDMDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDMDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDMDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDMDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDMDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDMDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1400;

    IF (p_action_mode = 'DELETE_SUPPLIER_ROW_CTX_DTLS') THEN
      l_err_loc := 1500;
      -- DELETE rows with sequence = 2 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDSDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1600;

    IF (p_action_mode = 'DELETE_ITEMREV_ROW_CTX_DTLS') THEN
      l_err_loc := 1700;
      -- DELETE rows with sequence = 5 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDIRDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDIRDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDIRDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDIRDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDIRDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDIRDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDIRDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1800;

    IF (p_action_mode = 'DELETE_SHOPCATG_ROW_CTX_DTLS') THEN
      l_err_loc := 1900;
      -- DELETE rows with sequence = 6 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDSCDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSCDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSCDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSCDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSCDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDSCDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDSCDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 2000;

    IF (p_action_mode = 'DELETE_PURCHORG_ROW_CTX_DTLS') THEN
      l_err_loc := 2100;
      -- DELETE rows with sequence =15001 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDPODInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODPurchasingOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODPurchasingOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDPODLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDPODLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    -- 17076597 changes starts
    l_err_loc := 2110;

    IF (p_action_mode = 'DELETE_UN_NUMBER_ROW_CTX_DTLS') THEN
      l_err_loc := 2120;
      -- DELETE rows with sequence =7 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDUNDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDOwningOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDOwningOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDUNDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDUNDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;


    l_err_loc := 2110;

    IF (p_action_mode = 'DELETE_HAZARD_CLASS_ROW_CTX_DTLS') THEN
      l_err_loc := 2120;
      -- DELETE rows with sequence =8 in icx_cat_items_ctx_dtl_tlp
      l_log_string := ' gDHZDInventoryItemIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDPoLineIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDReqTemplateNameTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDReqTemplateLineNumTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDOwningOrgIdTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDOwningOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDHZDLanguageTbl['||p_index||']: ' ||
        ICX_CAT_UTIL_PVT.getTableElement(gDHZDLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;
    -- 17076597 changes ends

  END IF;

  l_err_loc := 2200;
END logPLSQLTableRow;

PROCEDURE deleteItemCtxHdrsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'deleteItemCtxHdrsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDHInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDHInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.ctx_inventory_item_id;
  gDHPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDHReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDHReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDHOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDHLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END deleteItemCtxHdrsTLP;

PROCEDURE deleteItemCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'deleteItemCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.ctx_inventory_item_id;
  gDDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END deleteItemCtxDtlsTLP;

-- Re-populate the row with sequence = 1 i.e. Mandatory row in icx_cat_items_ctx_dtls_tlp
-- This row contains concatenated string of language, source_type, supid, ipcatid, pocatid and supsiteid
PROCEDURE delMandatoryRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delMandatoryRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDMDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDMDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDMDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDMDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDMDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDMDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDMDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDMDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delMandatoryRowFromCtxDtlsTLP;

-- Re-populate the row with sequence = 2 i.e. Supplier row in icx_cat_items_ctx_dtls_tlp
PROCEDURE delSupplierRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delSupplierRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDSDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDSDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDSDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDSDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDSDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDSDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDSDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDSDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delSupplierRowFromCtxDtlsTLP;

-- Re-populate the row with sequence = 5 i.e. Item Revision row in icx_cat_items_ctx_dtls_tlp
PROCEDURE delItemRevRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delItemRevRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDIRDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDIRDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDIRDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDIRDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDIRDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDIRDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDIRDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDIRDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delItemRevRowFromCtxDtlsTLP;

-- Re-populate the row with sequence = 6 i.e. shopping_category row in icx_cat_items_ctx_dtls_tlp
PROCEDURE delShopCatgRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delShopCatgRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDSCDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDSCDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDSCDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDSCDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDSCDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDSCDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDSCDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDSCDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delShopCatgRowFromCtxDtlsTLP;

-- Re-populate the row with sequence = 15001 i.e. purchorgid in icx_cat_items_ctx_dtls_tlp
PROCEDURE delPurchOrgRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delPurchOrgRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDPODInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDPODInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDPODPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDPODReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDPODReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDPODOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDPODOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDPODLanguageTbl(l_index) := p_current_ctx_item_rec.language;
  gDPODPurchasingOrgIdTbl(l_index) := p_current_ctx_item_rec.purchasing_org_id;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delPurchOrgRowFromCtxDtlsTLP;


-- 17076597 changes starts
-- Re-populate the row with sequence = 29 i.e. unnumber in icx_cat_items_ctx_dtls_tlp
PROCEDURE delUnNumberRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delUnNumberRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN

  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDUNDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDUNDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDUNDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDUNDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDUNDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDUNDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDUNDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDUNDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delUnNumberRowFromCtxDtlsTLP;



-- Re-populate the row with sequence = 30 i.e. hazardclass in icx_cat_items_ctx_dtls_tlp
PROCEDURE delHazardClsRowFromCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delHazardClsRowFromCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN

  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDHZDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDHZDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDHZDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDHZDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDHZDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDHZDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDHZDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDHZDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delHazardClsRowFromCtxDtlsTLP;
-- 17076597 changes ends


PROCEDURE delBaseLocalAttrItemCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'delBaseLocalAttrItemCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gDBLDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gDBLDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gDBLDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gDBLDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gDBLDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gDBLDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gDBLDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gDBLDLanguageTbl(l_index) := p_current_ctx_item_rec.language;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END delBaseLocalAttrItemCtxDtlsTLP;

PROCEDURE insertItemCtxHdrsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'insertItemCtxHdrsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gIHInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gIHInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gIHPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gIHReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gIHReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gIHOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gIHLanguageTbl(l_index) := p_current_ctx_item_rec.language;
  gIHSourceTypeTbl(l_index) := p_current_ctx_item_rec.source_type;
  gIHItemTypeTbl(l_index) := p_current_ctx_item_rec.item_type;
  gIHPurchasingOrgIdTbl(l_index) := p_current_ctx_item_rec.purchasing_org_id;
  gIHOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;
  gIHIpCategoryIdTbl(l_index) := p_current_ctx_item_rec.ip_category_id;
  gIHIpCategoryNameTbl(l_index) := p_current_ctx_item_rec.ip_category_name;
  gIHPoCategoryIdTbl(l_index) := p_current_ctx_item_rec.po_category_id;
  gIHSupplierIdTbl(l_index) := p_current_ctx_item_rec.supplier_id;
  gIHSupplierPartNumTbl(l_index) := p_current_ctx_item_rec.supplier_part_num;
  gIHSupplierPartAuxidTbl(l_index) := p_current_ctx_item_rec.supplier_part_auxid;
  gIHSupplierSiteIdTbl(l_index) := p_current_ctx_item_rec.supplier_site_id;
  gIHReqTemplatePoLineIdTbl(l_index) := p_current_ctx_item_rec.req_template_po_line_id;
  gIHItemRevisionTbl(l_index) := p_current_ctx_item_rec.item_revision;
  gIHPoHeaderIdTbl(l_index) := p_current_ctx_item_rec.po_header_id;
  gIHDocumentNumberTbl(l_index) := p_current_ctx_item_rec.document_number;
  gIHLineNumTbl(l_index) := p_current_ctx_item_rec.line_num;
  gIHAllowPriceOverrideFlagTbl(l_index) := p_current_ctx_item_rec.allow_price_override_flag;
  gIHNotToExceedPriceTbl(l_index) := p_current_ctx_item_rec.not_to_exceed_price;
  gIHLineTypeIdTbl(l_index) := p_current_ctx_item_rec.line_type_id;
  gIHUnitMeasLookupCodeTbl(l_index) := p_current_ctx_item_rec.unit_meas_lookup_code;
  gIHSuggestedQuantityTbl(l_index) := p_current_ctx_item_rec.suggested_quantity;
  gIHUnitPriceTbl(l_index) := p_current_ctx_item_rec.unit_price;
  gIHAmountTbl(l_index) := p_current_ctx_item_rec.amount;
  gIHCurrencyCodeTbl(l_index) := p_current_ctx_item_rec.currency_code;
  gIHRateTypeTbl(l_index) := p_current_ctx_item_rec.rate_type;
  gIHRateDateTbl(l_index) := p_current_ctx_item_rec.rate_date;
  gIHRateTbl(l_index) := p_current_ctx_item_rec.rate;
  gIHBuyerIdTbl(l_index) := p_current_ctx_item_rec.buyer_id;
  gIHSupplierContactIdTbl(l_index) := p_current_ctx_item_rec.supplier_contact_id;
  gIHRfqRequiredFlagTbl(l_index) := p_current_ctx_item_rec.rfq_required_flag;
  gIHNegotiatedByPreparerFlagTbl(l_index) := p_current_ctx_item_rec.negotiated_by_preparer_flag;
  gIHDescriptionTbl(l_index) := p_current_ctx_item_rec.description;
  gIHLongDescriptionTbl(l_index) := p_current_ctx_item_rec.long_description;
  gIHOrganizationIdTbl(l_index) := p_current_ctx_item_rec.organization_id;
  gIHMasterOrganizationIdTbl(l_index) := p_current_ctx_item_rec.master_organization_id;
  gIHOrderTypeLookupCodeTbl(l_index) := p_current_ctx_item_rec.order_type_lookup_code;
  gIHSupplierTbl(l_index) := p_current_ctx_item_rec.supplier;
  gIHGlobalAgreementFlagTbl(l_index) := p_current_ctx_item_rec.global_agreement_flag;
  gIHMergedSourceTypeTbl(l_index) := p_current_ctx_item_rec.merged_source_type;

  -- 17076597 changes
  gIHUnNumberTbl(l_index) := p_current_ctx_item_rec.un_number;
  gIHHazardClassTbl(l_index) := p_current_ctx_item_rec.hazard_class;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertItemCtxHdrsTLP;

PROCEDURE insertItemCtxDtlsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'insertItemCtxDtlsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gIDInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gIDInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gIDPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gIDReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gIDReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gIDOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gIDLanguageTbl(l_index) := p_current_ctx_item_rec.language;
  gIDPurchasingOrgIdTbl(l_index) := p_current_ctx_item_rec.purchasing_org_id;
  gIDOwningOrgIdTbl(l_index) := p_current_ctx_item_rec.owning_org_id;

  -- 17076597 changes
  gIDUnNumberTbl(l_index) := p_current_ctx_item_rec.un_number;
  gIDHazardClassTbl(l_index) := p_current_ctx_item_rec.hazard_class;

  -- Removed the call to delPurchOrgRowFromCtxDtlsTLP,
  -- because it adds one delete script for upgrade case which is not necessary
  -- so add one more insert script for gIDInventoryItemIdTbl to insert the
  -- purchasing_org_id row i.e. row with sequence = 15001 in icx_cat_items_ctx_dtls_tlp
  -- delPurchOrgRowFromCtxDtlsTLP(p_current_ctx_item_rec);

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertItemCtxDtlsTLP;

PROCEDURE updateItemCtxHdrsTLP
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'updateItemCtxHdrsTLP';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  gTotalRowCount := gTotalRowCount + 1;
  l_index := gUHInventoryItemIdTbl.COUNT + 1;

  l_err_loc := 200;
  gUHInventoryItemIdTbl(l_index) := p_current_ctx_item_rec.inventory_item_id;
  gUHPoLineIdTbl(l_index) := p_current_ctx_item_rec.po_line_id;
  gUHReqTemplateNameTbl(l_index) := p_current_ctx_item_rec.req_template_name;
  gUHReqTemplateLineNumTbl(l_index) := p_current_ctx_item_rec.req_template_line_num;
  gUHOrgIdTbl(l_index) := p_current_ctx_item_rec.org_id;
  gUHLanguageTbl(l_index) := p_current_ctx_item_rec.language;
  gUHSourceTypeTbl(l_index) := p_current_ctx_item_rec.source_type;
  gUHItemTypeTbl(l_index) := p_current_ctx_item_rec.item_type;
  gUHPurchasingOrgIdTbl(l_index) := p_current_ctx_item_rec.purchasing_org_id;
  gUHIpCategoryIdTbl(l_index) := p_current_ctx_item_rec.ip_category_id;
  gUHIpCategoryNameTbl(l_index) := p_current_ctx_item_rec.ip_category_name;
  gUHPoCategoryIdTbl(l_index) := p_current_ctx_item_rec.po_category_id;
  gUHSupplierIdTbl(l_index) := p_current_ctx_item_rec.supplier_id;
  gUHSupplierPartNumTbl(l_index) := p_current_ctx_item_rec.supplier_part_num;
  gUHSupplierPartAuxidTbl(l_index) := p_current_ctx_item_rec.supplier_part_auxid;
  gUHSupplierSiteIdTbl(l_index) := p_current_ctx_item_rec.supplier_site_id;
  gUHReqTemplatePoLineIdTbl(l_index) := p_current_ctx_item_rec.req_template_po_line_id;
  gUHItemRevisionTbl(l_index) := p_current_ctx_item_rec.item_revision;
  gUHPoHeaderIdTbl(l_index) := p_current_ctx_item_rec.po_header_id;
  gUHDocumentNumberTbl(l_index) := p_current_ctx_item_rec.document_number;
  gUHLineNumTbl(l_index) := p_current_ctx_item_rec.line_num;
  gUHAllowPriceOverrideFlagTbl(l_index) := p_current_ctx_item_rec.allow_price_override_flag;
  gUHNotToExceedPriceTbl(l_index) := p_current_ctx_item_rec.not_to_exceed_price;
  gUHLineTypeIdTbl(l_index) := p_current_ctx_item_rec.line_type_id;
  gUHUnitMeasLookupCodeTbl(l_index) := p_current_ctx_item_rec.unit_meas_lookup_code;
  gUHSuggestedQuantityTbl(l_index) := p_current_ctx_item_rec.suggested_quantity;
  gUHUnitPriceTbl(l_index) := p_current_ctx_item_rec.unit_price;
  gUHAmountTbl(l_index) := p_current_ctx_item_rec.amount;
  gUHCurrencyCodeTbl(l_index) := p_current_ctx_item_rec.currency_code;
  gUHRateTypeTbl(l_index) := p_current_ctx_item_rec.rate_type;
  gUHRateDateTbl(l_index) := p_current_ctx_item_rec.rate_date;
  gUHRateTbl(l_index) := p_current_ctx_item_rec.rate;
  gUHBuyerIdTbl(l_index) := p_current_ctx_item_rec.buyer_id;
  gUHSupplierContactIdTbl(l_index) := p_current_ctx_item_rec.supplier_contact_id;
  gUHRfqRequiredFlagTbl(l_index) := p_current_ctx_item_rec.rfq_required_flag;
  gUHNegotiatedByPreparerFlagTbl(l_index) := p_current_ctx_item_rec.negotiated_by_preparer_flag;
  gUHDescriptionTbl(l_index) := p_current_ctx_item_rec.description;
  gUHLongDescriptionTbl(l_index) := p_current_ctx_item_rec.long_description;
  gUHOrganizationIdTbl(l_index) := p_current_ctx_item_rec.organization_id;
  gUHMasterOrganizationIdTbl(l_index) := p_current_ctx_item_rec.master_organization_id;
  gUHOrderTypeLookupCodeTbl(l_index) := p_current_ctx_item_rec.order_type_lookup_code;
  gUHSupplierTbl(l_index) := p_current_ctx_item_rec.supplier;
  gUHGlobalAgreementFlagTbl(l_index) := p_current_ctx_item_rec.global_agreement_flag;
  gUHMergedSourceTypeTbl(l_index) := p_current_ctx_item_rec.merged_source_type;

  -- 17076597 changes
  gUHUNNumberTbl(l_index) := p_current_ctx_item_rec.un_number;
  gUHHazardClassTbl(l_index) := p_current_ctx_item_rec.hazard_class;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END updateItemCtxHdrsTLP;

PROCEDURE processCurrentCtxItemRow
(       p_current_ctx_item_rec  IN      g_ctx_item_rec_type             ,
        p_current_cursor        IN      VARCHAR2      ,
        p_mode                  IN      VARCHAR2
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'processCurrentCtxItemRow';
  l_err_loc                     PLS_INTEGER;
  l_repopulate_mandatory_row    BOOLEAN := FALSE;
  l_update_item_ctx_hdr_row     BOOLEAN := FALSE;
BEGIN
  l_err_loc := 100;
  IF (p_current_ctx_item_rec.ctx_rowid IS NULL) THEN
    -- Row does not exist in item ctx tables
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'New row');
    END IF;
    l_err_loc := 200;
    insertItemCtxHdrsTLP(p_current_ctx_item_rec);
    l_err_loc := 300;
    insertItemCtxDtlsTLP(p_current_ctx_item_rec);
  ELSE
    -- Row is present in the icx_cat_item_ctx_hdrs_tlp
    -- Possible scenarios:
    -- 1. Need to update the row in both ctx_hdrs and ctx_dtls tlp tables
    -- 2. Need to update the row only in ctx_dtls tables (i.e rebuild the populate string)
    -- 3. Need to delete the row based upon status
    l_err_loc := 400;
    IF (p_current_ctx_item_rec.status = 0) THEN
      l_err_loc := 500;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Update row. p_current_cursor:' || p_current_cursor ||
            ', p_mode:' || p_mode);
      END IF;

      l_err_loc := 550;
      IF (p_current_ctx_item_rec.ctx_inventory_item_id <> p_current_ctx_item_rec.inventory_item_id)
      THEN
        -- inventory item id has changed which means in a po line or req template line,
        -- the description based item has been changed to an inventory item.
        -- For this case, just delete and recreate the item.
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Inventory item changed: for po_line_id:' || p_current_ctx_item_rec.po_line_id ||
              ', templt_name:' || p_current_ctx_item_rec.req_template_name ||
              ', template_line_num:' || p_current_ctx_item_rec.req_template_line_num ||
              ', inventory_item_id:' || p_current_ctx_item_rec.inventory_item_id ||
              ', org_id:' || p_current_ctx_item_rec.org_id ||
              ', language:' || p_current_ctx_item_rec.language);
        END IF;
        l_err_loc := 600;
        deleteItemCtxHdrsTLP(p_current_ctx_item_rec);
        l_err_loc := 700;
        deleteItemCtxDtlsTLP(p_current_ctx_item_rec);
        l_err_loc := 800;
        insertItemCtxHdrsTLP(p_current_ctx_item_rec);
        l_err_loc := 900;
        insertItemCtxDtlsTLP(p_current_ctx_item_rec);
      ELSE
        l_err_loc := 1000;
        -- Check for changes in any of the special ctx dtls rows for rebuild of that particular row only,
	-- 17076597 changes added un number and hazard class
        IF (p_current_ctx_item_rec.ctx_purchasing_org_id <> p_current_ctx_item_rec.purchasing_org_id OR
            p_current_ctx_item_rec.ctx_ip_category_id <> p_current_ctx_item_rec.ip_category_id OR
            p_current_ctx_item_rec.ctx_po_category_id <> p_current_ctx_item_rec.po_category_id OR
            p_current_ctx_item_rec.ctx_item_type <> p_current_ctx_item_rec.item_type OR
            p_current_ctx_item_rec.ctx_supplier_id <> p_current_ctx_item_rec.supplier_id OR
            p_current_ctx_item_rec.ctx_supplier_site_id <> p_current_ctx_item_rec.supplier_site_id OR
            p_current_ctx_item_rec.ctx_supplier_part_num <> p_current_ctx_item_rec.supplier_part_num OR
            p_current_ctx_item_rec.ctx_supplier_part_auxid <> p_current_ctx_item_rec.supplier_part_auxid OR
            p_current_ctx_item_rec.ctx_un_number <> p_current_ctx_item_rec.un_number OR
            p_current_ctx_item_rec.ctx_hazard_class <> p_current_ctx_item_rec.hazard_class)
        THEN
          l_err_loc := 1100;
          l_update_item_ctx_hdr_row := TRUE;

          -- re-create the intermedia ctxString in icx_cat_ctx_dtls_tlp
          -- In icx_cat_items_ctx_dtls_tlp, need to
          -- 1. remove some of the special rows depending on the changes and
          -- 2. remove the base and local attributes rows i.e. sequence > 100 and < 10000

          IF (p_current_ctx_item_rec.ctx_po_category_id <> p_current_ctx_item_rec.po_category_id  OR
              p_current_ctx_item_rec.ctx_item_type <> p_current_ctx_item_rec.item_type OR
              p_current_ctx_item_rec.ctx_supplier_site_id <> p_current_ctx_item_rec.supplier_site_id OR
              p_current_ctx_item_rec.ctx_supplier_part_num <> p_current_ctx_item_rec.supplier_part_num OR
              p_current_ctx_item_rec.ctx_supplier_part_auxid <> p_current_ctx_item_rec.supplier_part_auxid)
          THEN
            l_err_loc := 1200;
            -- Re-populate the row with sequence = 1 i.e. mandatory row
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row 1 needs to be re-populated:');
            END IF;
            l_repopulate_mandatory_row := TRUE;
          END IF;

          l_err_loc := 1300;
          IF (p_current_ctx_item_rec.ctx_supplier_id <> p_current_ctx_item_rec.supplier_id)
          THEN
            l_err_loc := 1400;
            -- Re-populate the row with sequence = 1 and 2 i.e. mandatory row and supplier row
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Supplier Row needs to be re-populated:');
            END IF;
            l_repopulate_mandatory_row := TRUE;
            delSupplierRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;

          l_err_loc := 1500;

          -- The row with sequence = 3 i.e.
          -- Internal Item Number has already been taken care in the IF Loop.

          -- Row with sequence = 4 holds the source
          -- which cannnot be changed once created, so donot need to remove the row
          -- Source for BPA/GBPA/Quotation: Agreement/Quotation <segment1>.
          -- segment1 in po_headers cannot be changed
          -- Source for req templates: express_name.
          -- express_name in po_reqexpress_headers_all cannot be changed once created.
          IF (p_current_ctx_item_rec.ctx_ip_category_id <> p_current_ctx_item_rec.ip_category_id) THEN
            l_err_loc := 1600;
            -- Re-populate the row with sequence = 1 and 6 i.e. mandatory row and shopping_category row
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Shop category Row needs to be re-populated:');
            END IF;
            l_repopulate_mandatory_row := TRUE;
            delShopCatgRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;

          l_err_loc := 1700;

          IF (p_current_ctx_item_rec.ctx_purchasing_org_id <> p_current_ctx_item_rec.purchasing_org_id) THEN
            l_err_loc := 1800;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'purchasing org_id Row needs to be re-populated:');
            END IF;
            -- Re-populate the row with sequence = 15001 i.e. purchorgid
            delPurchOrgRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;

          -- 17076597 changes starts
          l_err_loc := 1810;

          IF (p_current_ctx_item_rec.ctx_un_number <> p_current_ctx_item_rec.un_number) THEN
            l_err_loc := 1820;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'UN_NUMBER Row needs to be re-populated:');
            END IF;
            -- Re-populate the row with sequence = 29 i.e. unnumber
            delUnNumberRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;


          l_err_loc := 1830;

          IF (p_current_ctx_item_rec.ctx_hazard_class <> p_current_ctx_item_rec.hazard_class) THEN
            l_err_loc := 1840;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'HAZARD_CLASS Row needs to be re-populated:');
            END IF;
            -- Re-populate the row with sequence = 30 i.e. hazard class
            delHazardClsRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;
          -- 17076597 changes ends

          l_err_loc := 1900;

          IF (l_repopulate_mandatory_row) THEN
            l_err_loc := 2000;
            delMandatoryRowFromCtxDtlsTLP(p_current_ctx_item_rec);
          END IF;
        END IF; -- End of IF check for changes in the special attributes

        l_err_loc := 2100;

        -- re-populate for the following conditions:
        -- Upgrade, always repopulate for all except master items
        -- Online, always repopulate for req template
        -- Online, repopulate for Blankets and global blankets only if item_revision has changed
        IF ( (p_mode = 'UPGRADE' AND
              p_current_ctx_item_rec.source_type <> 'MASTER_ITEM')
             OR
             (p_mode = 'ONLINE' AND
              (p_current_ctx_item_rec.source_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE'))
              OR
              (p_current_ctx_item_rec.source_type IN ('GLOBAL_BLANKET', 'BLANKET') AND
               p_current_ctx_item_rec.item_revision <> p_current_ctx_item_rec.ctx_item_revision))
           )
        THEN
          l_err_loc := 2200;
          l_update_item_ctx_hdr_row := TRUE;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'item revision Row needs to be re-populated:' ||
                ', source_type:' || p_current_ctx_item_rec.source_type ||
                ', p_mode:' || p_mode ||
                ', item_revision:' ||  p_current_ctx_item_rec.item_revision ||
                ', ctx_item_revision:' || p_current_ctx_item_rec.ctx_item_revision);
          END IF;
          -- Re-populate the row with sequence = 5 i.e. Item Revision
          delItemRevRowFromCtxDtlsTLP(p_current_ctx_item_rec);
        END IF;

        l_err_loc := 2300;

        -- For master items the description will be in the ctx index as part of sequence between 101 and 4999.
        -- i.e. in sequence 101
        -- There will not be any category attribute row between 5001 and 9999
        -- ICX_CAT_UTIL_PVT.g_ItemCatgChange_const will be set to true only from master items
        -- category change API i.e. in ICX_CAT_POPULATE_MI_PVT.populateItemCatgChange
        -- For category change of a master item we dont want to re-populate the base and local attributes of
        -- master item.  So here we check for ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
        -- (Note: Master items will not have any local attributes populated)
        -- Local and Base attributes does not need to repopulated (for blankets and global blankets)
        -- when coming from populateOrgAssignments
        IF (NOT ICX_CAT_UTIL_PVT.g_ItemCatgChange_const
            AND NOT (p_mode = 'ONLINE' AND
                     p_current_ctx_item_rec.source_type IN ('GLOBAL_BLANKET', 'BLANKET') AND
                     p_current_cursor = 'ORG_ASSIGNMENT_CSR'))
        THEN
          l_err_loc := 2400;
          l_update_item_ctx_hdr_row := TRUE;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'base and local Row needs to be re-populated:' ||
                ', source_type:' || p_current_ctx_item_rec.source_type ||
                ', p_mode:' || p_mode ||
                ', p_current_cursor:' || p_current_cursor);
          END IF;
          delBaseLocalAttrItemCtxDtlsTLP(p_current_ctx_item_rec);
        END IF;

        l_err_loc := 2500;

        IF (l_update_item_ctx_hdr_row) THEN
          l_err_loc := 2600;
          -- Update scenario
          -- The row needs to be updated in icx_cat_items_ctx_hdrs
          -- We have to update the ctx_desc to null in hdrs table, for rebuild indexes.
          updateItemCtxHdrsTLP(p_current_ctx_item_rec);
        ELSE
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                ', l_update_item_ctx_hdr_row is false; so will not call updateItemCtxHdrsTLP');
          END IF;
        END IF;

        l_err_loc := 2700;
      END IF;
    ELSE -- status is not 0
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Delete row');
      END IF;
      -- i.e. the row is invalid and needs to be deleted
      l_err_loc := 2800;
      deleteItemCtxHdrsTLP(p_current_ctx_item_rec);
      deleteItemCtxDtlsTLP(p_current_ctx_item_rec);
    END IF;
  END IF;
  l_err_loc := 2900;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END processCurrentCtxItemRow;

/*
-- p_current_cursor
        VALUES: ICX_CAT_UTIL_PVT.g_BPACsr_const := 'BPA';
                ICX_CAT_UTIL_PVT.g_QuoteCsr_const := 'Quote';
                ICX_CAT_UTIL_PVT.g_GBPACsr_const := 'GBPA';
                ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const := 'ReqTemplate';
                ICX_CAT_UTIL_PVT.g_MasterItemCsr_const := 'MASTER_ITEM';
-- 1. Used to process the DML to icx_cat_items_ctx_dtls_tlp differently for GBPAs
-- 2. Used to call the appropriate buildCtxSqls, list of ctx sqls are different depending upon the source
-- req_templates and master items dont need to run the sql for contract_num
-- master items need to only run sql with sequence 1 and org info.
*/
PROCEDURE populateItemCtxTables
(       p_mode                  IN      VARCHAR2                        ,
        p_current_cursor        IN      VARCHAR2
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'populateItemCtxTables';
  l_err_loc                     PLS_INTEGER;
  l_action_mode                 VARCHAR2(80);
  l_special_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_ctx_sqlstring_rec           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_csr_handle                  NUMBER;
  l_status                      PLS_INTEGER;
  l_start_sequence              NUMBER;
  l_end_sequence                NUMBER;
  l_sequence                    NUMBER;
  l_ctx_sql_string              VARCHAR2(4000);

  --BUG 6599217: start1
  l_ip_category_id           NUMBER ;
  l_inventory_item_id       NUMBER;
  l_org_id                      NUMBER;
  l_description                 VARCHAR2(4000);
  l_long_description            po_attribute_values_tlp.long_description%TYPE;
  l_organization_id             NUMBER;
  l_master_organization_id      NUMBER;
  l_language                    icx_cat_items_ctx_hdrs_tlp.language%TYPE;
   --BUG 6599217: end 1
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Enter populateItemCtxTables(' || p_mode || ', ' || p_current_cursor ||
        ')gTotalRowCount: ' || gTotalRowCount);
  END IF;

  l_err_loc := 150;
  IF (p_mode = 'OUTLOOP' OR gTotalRowCount >= ICX_CAT_UTIL_PVT.g_batch_size) THEN
    l_err_loc := 200;
    gTotalRowCount := 0;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          '; Num. of rows to be inserted into hdrs:' || gIHInventoryItemIdTbl.COUNT ||
          '; Num. of rows to be inserted into dtls:' || gIDInventoryItemIdTbl.COUNT ||
          ', Total num. of rows to be updated:' || gUHInventoryItemIdTbl.COUNT ||
          ', Mandatory rows to be re-populated for:' || gDMDInventoryItemIdTbl.COUNT ||
          ', Supplier rows to be re-populated for:' || gDSDInventoryItemIdTbl.COUNT ||
          ', Item Revision rows to be re-populated for:' || gDIRDInventoryItemIdTbl.COUNT ||
          ', Shopping Category rows to be re-populated for:' || gDSCDInventoryItemIdTbl.COUNT ||
          ', Base and Local attribute rows to be re-populated for:' || gDBLDInventoryItemIdTbl.COUNT ||
          ', Num. of rows to be deleted:' || gDHInventoryItemIdTbl.COUNT);
    END IF;

    l_err_loc := 250;
    l_action_mode := 'INSERT_CTX_HDRS';
    -- 17076597 changes added un number ans hazard class to insert statement
    FORALL i in 1..gIHInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_hdrs_tlp
      (inventory_item_id, po_line_id,
       req_template_name, req_template_line_num,
       org_id, language,
       source_type, item_type, purchasing_org_id, owning_org_id,
       ip_category_id, ip_category_name, po_category_id,
       supplier_id, supplier_part_num,
       supplier_part_auxid, supplier_site_id,
       req_template_po_line_id, item_revision, po_header_id,
       document_number, line_num, allow_price_override_flag,
       not_to_exceed_price, line_type_id, unit_meas_lookup_code,
       suggested_quantity, unit_price, amount, currency_code, rate_type,
       rate_date, rate, buyer_id, supplier_contact_id,
       rfq_required_flag, negotiated_by_preparer_flag,
       description, order_type_lookup_code,
       supplier, global_agreement_flag, merged_source_type,
        un_number, hazard_class,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gIHInventoryItemIdTbl(i), gIHPoLineIdTbl(i),
       gIHReqTemplateNameTbl(i), gIHReqTemplateLineNumTbl(i),
       gIHOrgIdTbl(i), gIHLanguageTbl(i),
       gIHSourceTypeTbl(i), gIHItemTypeTbl(i), gIHPurchasingOrgIdTbl(i), gIHOwningOrgIdTbl(i),
       gIHIpCategoryIdTbl(i), gIHIpCategoryNameTbl(i), gIHPoCategoryIdTbl(i),
       gIHSupplierIdTbl(i), gIHSupplierPartNumTbl(i),
       gIHSupplierPartAuxidTbl(i), gIHSupplierSiteIdTbl(i), gIHReqTemplatePoLineIdTbl(i),
       gIHItemRevisionTbl(i), gIHPoHeaderIdTbl(i), gIHDocumentNumberTbl(i),
       gIHLineNumTbl(i), gIHAllowPriceOverrideFlagTbl(i), gIHNotToExceedPriceTbl(i),
       gIHLineTypeIdTbl(i), gIHUnitMeasLookupCodeTbl(i), gIHSuggestedQuantityTbl(i),
       gIHUnitPriceTbl(i), gIHAmountTbl(i), gIHCurrencyCodeTbl(i),  gIHRateTypeTbl(i),
       gIHRateDateTbl(i), gIHRateTbl(i), gIHBuyerIdTbl(i), gIHSupplierContactIdTbl(i),
       gIHRfqRequiredFlagTbl(i), gIHNegotiatedByPreparerFlagTbl(i), gIHDescriptionTbl(i),
       gIHOrderTypeLookupCodeTbl(i), gIHSupplierTbl(i),
       gIHGlobalAgreementFlagTbl(i), gIHMergedSourceTypeTbl(i),
       gIHUnNumberTbl(i), gIHHazardClassTbl(i),

       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       sysdate, ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    IF (gIHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into ctx_hdrs:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 310;

--BUG 6599217.start 2
    if ( p_current_cursor = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) then

    l_action_mode := 'INSERT_PO_ATTR_VALUES';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' loop count : ' ||gIHInventoryItemIdTbl.Count);
    END IF;

    FOR i IN 1..gIHInventoryItemIdTbl.Count LOOP
      -- call the po package to populate the po tables so that the
      -- merge st in this procedure will insert rows in icx tables

          l_ip_category_id      := gIHIpCategoryIdTbl(i);
          l_inventory_item_id   := gIHInventoryItemIdTbl(i);
          l_org_id              := gIHOrgIdTbl(i);
          l_description         := gIHDescriptionTbl(i);
          l_long_description    := gIHLongDescriptionTbl(i);
          l_organization_id     := gIHOrganizationIdTbl(i);
          l_master_organization_id := gIHMasterOrganizationIdTbl(i);

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Value of variable are  l_ip_category_id= ' ||l_ip_category_id|| 'l_inventory_item_id=' ||l_inventory_item_id||
            'l_org_id='||l_org_id||'l_description='||l_description);
       END IF;

       po_attribute_values_pvt.create_default_attributes_MI
        (
          p_ip_category_id      =>   l_ip_category_id,
          p_inventory_item_id   =>  l_inventory_item_id,
          p_org_id              =>  l_org_id,
          p_description         =>   l_description,
          p_organization_id     =>   l_organization_id,
          p_master_organization_id => l_master_organization_id
        );
    END LOOP;

    END IF;
      l_err_loc := 315;

    --BUG 6599217.end 2


    l_action_mode := 'INSERT_ATTR_VALUES';
    FORALL i in 1..gIHInventoryItemIdTbl.COUNT
      MERGE INTO icx_cat_attribute_values icav
      USING (SELECT *
             FROM po_attribute_values
             WHERE inventory_item_id = gIHInventoryItemIdTbl(i)
             AND   po_line_id = gIHPoLineIdTbl(i)
             AND   req_template_name = gIHReqTemplateNameTbl(i)
             AND   req_template_line_num = gIHReqTemplateLineNumTbl(i)
             AND   org_id = gIHOrgIdTbl(i)) temp
      ON (icav.inventory_item_id = temp.inventory_item_id AND
          icav.po_line_id = temp.po_line_id AND
          icav.req_template_name = temp.req_template_name AND
          icav.req_template_line_num = temp.req_template_line_num AND
          icav.org_id = temp.org_id)
      WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.manufacturer_part_num, temp.picture, temp.thumbnail_image,
          temp.supplier_url, temp.manufacturer_url, temp.attachment_url, temp.unspsc,
          temp.availability, temp.lead_time,
          temp.text_base_attribute1, temp.text_base_attribute2, temp.text_base_attribute3,
          temp.text_base_attribute4, temp.text_base_attribute5, temp.text_base_attribute6,
          temp.text_base_attribute7, temp.text_base_attribute8, temp.text_base_attribute9,
          temp.text_base_attribute10, temp.text_base_attribute11, temp.text_base_attribute12,
          temp.text_base_attribute13, temp.text_base_attribute14, temp.text_base_attribute15,
          temp.text_base_attribute16, temp.text_base_attribute17, temp.text_base_attribute18,
          temp.text_base_attribute19, temp.text_base_attribute20, temp.text_base_attribute21,
          temp.text_base_attribute22, temp.text_base_attribute23, temp.text_base_attribute24,
          temp.text_base_attribute25, temp.text_base_attribute26, temp.text_base_attribute27,
          temp.text_base_attribute28, temp.text_base_attribute29, temp.text_base_attribute30,
          temp.text_base_attribute31, temp.text_base_attribute32, temp.text_base_attribute33,
          temp.text_base_attribute34, temp.text_base_attribute35, temp.text_base_attribute36,
          temp.text_base_attribute37, temp.text_base_attribute38, temp.text_base_attribute39,
          temp.text_base_attribute40, temp.text_base_attribute41, temp.text_base_attribute42,
          temp.text_base_attribute43, temp.text_base_attribute44, temp.text_base_attribute45,
          temp.text_base_attribute46, temp.text_base_attribute47, temp.text_base_attribute48,
          temp.text_base_attribute49, temp.text_base_attribute50, temp.text_base_attribute51,
          temp.text_base_attribute52, temp.text_base_attribute53, temp.text_base_attribute54,
          temp.text_base_attribute55, temp.text_base_attribute56, temp.text_base_attribute57,
          temp.text_base_attribute58, temp.text_base_attribute59, temp.text_base_attribute60,
          temp.text_base_attribute61, temp.text_base_attribute62, temp.text_base_attribute63,
          temp.text_base_attribute64, temp.text_base_attribute65, temp.text_base_attribute66,
          temp.text_base_attribute67, temp.text_base_attribute68, temp.text_base_attribute69,
          temp.text_base_attribute70, temp.text_base_attribute71, temp.text_base_attribute72,
          temp.text_base_attribute73, temp.text_base_attribute74, temp.text_base_attribute75,
          temp.text_base_attribute76, temp.text_base_attribute77, temp.text_base_attribute78,
          temp.text_base_attribute79, temp.text_base_attribute80, temp.text_base_attribute81,
          temp.text_base_attribute82, temp.text_base_attribute83, temp.text_base_attribute84,
          temp.text_base_attribute85, temp.text_base_attribute86, temp.text_base_attribute87,
          temp.text_base_attribute88, temp.text_base_attribute89, temp.text_base_attribute90,
          temp.text_base_attribute91, temp.text_base_attribute92, temp.text_base_attribute93,
          temp.text_base_attribute94, temp.text_base_attribute95, temp.text_base_attribute96,
          temp.text_base_attribute97, temp.text_base_attribute98, temp.text_base_attribute99,
          temp.text_base_attribute100,
          temp.num_base_attribute1, temp.num_base_attribute2, temp.num_base_attribute3,
          temp.num_base_attribute4, temp.num_base_attribute5, temp.num_base_attribute6,
          temp.num_base_attribute7, temp.num_base_attribute8, temp.num_base_attribute9,
          temp.num_base_attribute10, temp.num_base_attribute11, temp.num_base_attribute12,
          temp.num_base_attribute13, temp.num_base_attribute14, temp.num_base_attribute15,
          temp.num_base_attribute16, temp.num_base_attribute17, temp.num_base_attribute18,
          temp.num_base_attribute19, temp.num_base_attribute20, temp.num_base_attribute21,
          temp.num_base_attribute22, temp.num_base_attribute23, temp.num_base_attribute24,
          temp.num_base_attribute25, temp.num_base_attribute26, temp.num_base_attribute27,
          temp.num_base_attribute28, temp.num_base_attribute29, temp.num_base_attribute30,
          temp.num_base_attribute31, temp.num_base_attribute32, temp.num_base_attribute33,
          temp.num_base_attribute34, temp.num_base_attribute35, temp.num_base_attribute36,
          temp.num_base_attribute37, temp.num_base_attribute38, temp.num_base_attribute39,
          temp.num_base_attribute40, temp.num_base_attribute41, temp.num_base_attribute42,
          temp.num_base_attribute43, temp.num_base_attribute44, temp.num_base_attribute45,
          temp.num_base_attribute46, temp.num_base_attribute47, temp.num_base_attribute48,
          temp.num_base_attribute49, temp.num_base_attribute50, temp.num_base_attribute51,
          temp.num_base_attribute52, temp.num_base_attribute53, temp.num_base_attribute54,
          temp.num_base_attribute55, temp.num_base_attribute56, temp.num_base_attribute57,
          temp.num_base_attribute58, temp.num_base_attribute59, temp.num_base_attribute60,
          temp.num_base_attribute61, temp.num_base_attribute62, temp.num_base_attribute63,
          temp.num_base_attribute64, temp.num_base_attribute65, temp.num_base_attribute66,
          temp.num_base_attribute67, temp.num_base_attribute68, temp.num_base_attribute69,
          temp.num_base_attribute70, temp.num_base_attribute71, temp.num_base_attribute72,
          temp.num_base_attribute73, temp.num_base_attribute74, temp.num_base_attribute75,
          temp.num_base_attribute76, temp.num_base_attribute77, temp.num_base_attribute78,
          temp.num_base_attribute79, temp.num_base_attribute80, temp.num_base_attribute81,
          temp.num_base_attribute82, temp.num_base_attribute83, temp.num_base_attribute84,
          temp.num_base_attribute85, temp.num_base_attribute86, temp.num_base_attribute87,
          temp.num_base_attribute88, temp.num_base_attribute89, temp.num_base_attribute90,
          temp.num_base_attribute91, temp.num_base_attribute92, temp.num_base_attribute93,
          temp.num_base_attribute94, temp.num_base_attribute95, temp.num_base_attribute96,
          temp.num_base_attribute97, temp.num_base_attribute98, temp.num_base_attribute99,
          temp.num_base_attribute100,
          temp.text_cat_attribute1, temp.text_cat_attribute2, temp.text_cat_attribute3,
          temp.text_cat_attribute4, temp.text_cat_attribute5, temp.text_cat_attribute6,
          temp.text_cat_attribute7, temp.text_cat_attribute8, temp.text_cat_attribute9,
          temp.text_cat_attribute10, temp.text_cat_attribute11, temp.text_cat_attribute12,
          temp.text_cat_attribute13, temp.text_cat_attribute14, temp.text_cat_attribute15,
          temp.text_cat_attribute16, temp.text_cat_attribute17, temp.text_cat_attribute18,
          temp.text_cat_attribute19, temp.text_cat_attribute20, temp.text_cat_attribute21,
          temp.text_cat_attribute22, temp.text_cat_attribute23, temp.text_cat_attribute24,
          temp.text_cat_attribute25, temp.text_cat_attribute26, temp.text_cat_attribute27,
          temp.text_cat_attribute28, temp.text_cat_attribute29, temp.text_cat_attribute30,
          temp.text_cat_attribute31, temp.text_cat_attribute32, temp.text_cat_attribute33,
          temp.text_cat_attribute34, temp.text_cat_attribute35, temp.text_cat_attribute36,
          temp.text_cat_attribute37, temp.text_cat_attribute38, temp.text_cat_attribute39,
          temp.text_cat_attribute40, temp.text_cat_attribute41, temp.text_cat_attribute42,
          temp.text_cat_attribute43, temp.text_cat_attribute44, temp.text_cat_attribute45,
          temp.text_cat_attribute46, temp.text_cat_attribute47, temp.text_cat_attribute48,
          temp.text_cat_attribute49, temp.text_cat_attribute50,
          temp.num_cat_attribute1, temp.num_cat_attribute2, temp.num_cat_attribute3,
          temp.num_cat_attribute4, temp.num_cat_attribute5, temp.num_cat_attribute6,
          temp.num_cat_attribute7, temp.num_cat_attribute8, temp.num_cat_attribute9,
          temp.num_cat_attribute10, temp.num_cat_attribute11, temp.num_cat_attribute12,
          temp.num_cat_attribute13, temp.num_cat_attribute14, temp.num_cat_attribute15,
          temp.num_cat_attribute16, temp.num_cat_attribute17, temp.num_cat_attribute18,
          temp.num_cat_attribute19, temp.num_cat_attribute20, temp.num_cat_attribute21,
          temp.num_cat_attribute22, temp.num_cat_attribute23, temp.num_cat_attribute24,
          temp.num_cat_attribute25, temp.num_cat_attribute26, temp.num_cat_attribute27,
          temp.num_cat_attribute28, temp.num_cat_attribute29, temp.num_cat_attribute30,
          temp.num_cat_attribute31, temp.num_cat_attribute32, temp.num_cat_attribute33,
          temp.num_cat_attribute34, temp.num_cat_attribute35, temp.num_cat_attribute36,
          temp.num_cat_attribute37, temp.num_cat_attribute38, temp.num_cat_attribute39,
          temp.num_cat_attribute40, temp.num_cat_attribute41, temp.num_cat_attribute42,
          temp.num_cat_attribute43, temp.num_cat_attribute44, temp.num_cat_attribute45,
          temp.num_cat_attribute46, temp.num_cat_attribute47, temp.num_cat_attribute48,
          temp.num_cat_attribute49, temp.num_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);

    IF (gIHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into icx_cat_attribute_values:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 330;

    -- BUG 6599217.start 3 new procedure to insert into PO_ATTRIBUTE_VALUES_TLP
    if ( p_current_cursor = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) then
    l_action_mode := 'INSERT_PO_ATTR_VALUES_TLP';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' loop count : ' ||gIHInventoryItemIdTbl.Count);
    END IF;

    FOR i IN 1..gIHInventoryItemIdTbl.Count LOOP
      -- call the po package to populate the po tables so that the
      -- merge st in this procedure will insert rows in icx tables

        l_inventory_item_id   := gIHInventoryItemIdTbl(i);
        l_org_id              := gIHOrgIdTbl(i);
        l_language            := gIHLanguageTbl(i);
        l_description         := gIHDescriptionTbl(i);
        l_ip_category_id      := gIHIpCategoryIdTbl(i);
        l_long_description    := gIHLongDescriptionTbl(i);
        l_organization_id     := gIHOrganizationIdTbl(i);
        l_master_organization_id := gIHMasterOrganizationIdTbl(i);

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Value of variable are  l_inventory_item_id=' ||l_inventory_item_id||
            'l_org_id='||l_org_id||'l_language='||l_language||' l_ip_category_id=' ||l_ip_category_id);
       END IF;

       po_attribute_values_pvt.create_attributes_tlp_MI
        (
          p_inventory_item_id   =>  l_inventory_item_id,
          p_ip_category_id       =>  l_ip_category_id ,
          p_org_id              =>  l_org_id,
          p_language         =>     l_language,
          p_description      =>     l_description,
          p_long_description => l_long_description,
          p_organization_id => l_organization_id,
          p_master_organization_id => l_master_organization_id
        );
    END LOOP;

    End if;
    --BUG 6599217.end 2


    l_err_loc := 335;


    l_action_mode := 'INSERT_ATTR_VALUES_TLP';
    FORALL i in 1..gIHInventoryItemIdTbl.COUNT
      MERGE INTO icx_cat_attribute_values_tlp icavt
      USING (SELECT *
             FROM po_attribute_values_tlp
             WHERE inventory_item_id = gIHInventoryItemIdTbl(i)
             AND   po_line_id = gIHPoLineIdTbl(i)
             AND   req_template_name = gIHReqTemplateNameTbl(i)
             AND   req_template_line_num = gIHReqTemplateLineNumTbl(i)
             AND   org_id = gIHOrgIdTbl(i)
             AND   language = gIHLanguageTbl(i)) temp
      ON (icavt.inventory_item_id = temp.inventory_item_id AND
          icavt.po_line_id = temp.po_line_id AND
          icavt.req_template_name = temp.req_template_name AND
          icavt.req_template_line_num = temp.req_template_line_num AND
          icavt.org_id = temp.org_id AND
          icavt.language = temp.language)
      WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_tlp_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.language, temp.description, temp.manufacturer,
          temp.comments, temp.alias, temp.long_description,
          temp.tl_text_base_attribute1, temp.tl_text_base_attribute2, temp.tl_text_base_attribute3,
          temp.tl_text_base_attribute4, temp.tl_text_base_attribute5, temp.tl_text_base_attribute6,
          temp.tl_text_base_attribute7, temp.tl_text_base_attribute8, temp.tl_text_base_attribute9,
          temp.tl_text_base_attribute10, temp.tl_text_base_attribute11, temp.tl_text_base_attribute12,
          temp.tl_text_base_attribute13, temp.tl_text_base_attribute14, temp.tl_text_base_attribute15,
          temp.tl_text_base_attribute16, temp.tl_text_base_attribute17, temp.tl_text_base_attribute18,
          temp.tl_text_base_attribute19, temp.tl_text_base_attribute20, temp.tl_text_base_attribute21,
          temp.tl_text_base_attribute22, temp.tl_text_base_attribute23, temp.tl_text_base_attribute24,
          temp.tl_text_base_attribute25, temp.tl_text_base_attribute26, temp.tl_text_base_attribute27,
          temp.tl_text_base_attribute28, temp.tl_text_base_attribute29, temp.tl_text_base_attribute30,
          temp.tl_text_base_attribute31, temp.tl_text_base_attribute32, temp.tl_text_base_attribute33,
          temp.tl_text_base_attribute34, temp.tl_text_base_attribute35, temp.tl_text_base_attribute36,
          temp.tl_text_base_attribute37, temp.tl_text_base_attribute38, temp.tl_text_base_attribute39,
          temp.tl_text_base_attribute40, temp.tl_text_base_attribute41, temp.tl_text_base_attribute42,
          temp.tl_text_base_attribute43, temp.tl_text_base_attribute44, temp.tl_text_base_attribute45,
          temp.tl_text_base_attribute46, temp.tl_text_base_attribute47, temp.tl_text_base_attribute48,
          temp.tl_text_base_attribute49, temp.tl_text_base_attribute50, temp.tl_text_base_attribute51,
          temp.tl_text_base_attribute52, temp.tl_text_base_attribute53, temp.tl_text_base_attribute54,
          temp.tl_text_base_attribute55, temp.tl_text_base_attribute56, temp.tl_text_base_attribute57,
          temp.tl_text_base_attribute58, temp.tl_text_base_attribute59, temp.tl_text_base_attribute60,
          temp.tl_text_base_attribute61, temp.tl_text_base_attribute62, temp.tl_text_base_attribute63,
          temp.tl_text_base_attribute64, temp.tl_text_base_attribute65, temp.tl_text_base_attribute66,
          temp.tl_text_base_attribute67, temp.tl_text_base_attribute68, temp.tl_text_base_attribute69,
          temp.tl_text_base_attribute70, temp.tl_text_base_attribute71, temp.tl_text_base_attribute72,
          temp.tl_text_base_attribute73, temp.tl_text_base_attribute74, temp.tl_text_base_attribute75,
          temp.tl_text_base_attribute76, temp.tl_text_base_attribute77, temp.tl_text_base_attribute78,
          temp.tl_text_base_attribute79, temp.tl_text_base_attribute80, temp.tl_text_base_attribute81,
          temp.tl_text_base_attribute82, temp.tl_text_base_attribute83, temp.tl_text_base_attribute84,
          temp.tl_text_base_attribute85, temp.tl_text_base_attribute86, temp.tl_text_base_attribute87,
          temp.tl_text_base_attribute88, temp.tl_text_base_attribute89, temp.tl_text_base_attribute90,
          temp.tl_text_base_attribute91, temp.tl_text_base_attribute92, temp.tl_text_base_attribute93,
          temp.tl_text_base_attribute94, temp.tl_text_base_attribute95, temp.tl_text_base_attribute96,
          temp.tl_text_base_attribute97, temp.tl_text_base_attribute98, temp.tl_text_base_attribute99,
          temp.tl_text_base_attribute100,
          temp.tl_text_cat_attribute1, temp.tl_text_cat_attribute2, temp.tl_text_cat_attribute3,
          temp.tl_text_cat_attribute4, temp.tl_text_cat_attribute5, temp.tl_text_cat_attribute6,
          temp.tl_text_cat_attribute7, temp.tl_text_cat_attribute8, temp.tl_text_cat_attribute9,
          temp.tl_text_cat_attribute10, temp.tl_text_cat_attribute11, temp.tl_text_cat_attribute12,
          temp.tl_text_cat_attribute13, temp.tl_text_cat_attribute14, temp.tl_text_cat_attribute15,
          temp.tl_text_cat_attribute16, temp.tl_text_cat_attribute17, temp.tl_text_cat_attribute18,
          temp.tl_text_cat_attribute19, temp.tl_text_cat_attribute20, temp.tl_text_cat_attribute21,
          temp.tl_text_cat_attribute22, temp.tl_text_cat_attribute23, temp.tl_text_cat_attribute24,
          temp.tl_text_cat_attribute25, temp.tl_text_cat_attribute26, temp.tl_text_cat_attribute27,
          temp.tl_text_cat_attribute28, temp.tl_text_cat_attribute29, temp.tl_text_cat_attribute30,
          temp.tl_text_cat_attribute31, temp.tl_text_cat_attribute32, temp.tl_text_cat_attribute33,
          temp.tl_text_cat_attribute34, temp.tl_text_cat_attribute35, temp.tl_text_cat_attribute36,
          temp.tl_text_cat_attribute37, temp.tl_text_cat_attribute38, temp.tl_text_cat_attribute39,
          temp.tl_text_cat_attribute40, temp.tl_text_cat_attribute41, temp.tl_text_cat_attribute42,
          temp.tl_text_cat_attribute43, temp.tl_text_cat_attribute44, temp.tl_text_cat_attribute45,
          temp.tl_text_cat_attribute46, temp.tl_text_cat_attribute47, temp.tl_text_cat_attribute48,
          temp.tl_text_cat_attribute49, temp.tl_text_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);

    IF (gIHInventoryItemIdTbl.COUNT > 0) THEN
       -- ICX_ENDECA_UTIL_PKG.incrementalUpdate('INSERT',gIHInventoryItemIdTbl,gIHPoLineIdTbl,gIHReqTemplateNameTbl,gIHReqTemplateLineNumTbl,gIHOrgIdTbl,gIHLanguageTbl);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into icx_cat_attribute_values_tlp:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 340;
    clearTables(l_action_mode);

    l_err_loc := 350;
    l_action_mode := 'UPDATE_CTX_HDRS';
     -- 17076597 changes added un number and hazard class to update stmt
    FORALL i in 1..gUHInventoryItemIdTbl.COUNT
      UPDATE icx_cat_items_ctx_hdrs_tlp
      SET ctx_desc = null,
          purchasing_org_id = gUHPurchasingOrgIdTbl(i),
          ip_category_id = gUHIpCategoryIdTbl(i),
          ip_category_name = gUHIpCategoryNameTbl(i),
          po_category_id = gUHPoCategoryIdTbl(i),
          supplier_id = gUHSupplierIdTbl(i),
          supplier_part_num = gUHSupplierPartNumTbl(i),
          supplier_part_auxid = gUHSupplierPartAuxidTbl(i),
          supplier_site_id = gUHSupplierSiteIdTbl(i),
          req_template_po_line_id = gUHReqTemplatePoLineIdTbl(i),
          item_revision = gUHItemRevisionTbl(i),
          po_header_id = gUHPoHeaderIdTbl(i),
          document_number = gUHDocumentNumberTbl(i),
          line_num = gUHLineNumTbl(i),
          allow_price_override_flag = gUHAllowPriceOverrideFlagTbl(i),
          not_to_exceed_price = gUHNotToExceedPriceTbl(i),
          line_type_id = gUHLineTypeIdTbl(i),
          unit_meas_lookup_code = gUHUnitMeasLookupCodeTbl(i),
          suggested_quantity = gUHSuggestedQuantityTbl(i),
          unit_price = gUHUnitPriceTbl(i),
          amount = gUHAmountTbl(i),
          currency_code = gUHCurrencyCodeTbl(i),
          rate_type = gUHRateTypeTbl(i),
          rate_date = gUHRateDateTbl(i),
          rate = gUHRateTbl(i),
          buyer_id = gUHBuyerIdTbl(i),
          supplier_contact_id = gUHSupplierContactIdTbl(i),
          rfq_required_flag = gUHRfqRequiredFlagTbl(i),
          negotiated_by_preparer_flag = gUHNegotiatedByPreparerFlagTbl(i),
          description = gUHDescriptionTbl(i),
          order_type_lookup_code = gUHOrderTypeLookupCodeTbl(i),
          supplier = gUHSupplierTbl(i),
          global_agreement_flag = gUHGlobalAgreementFlagTbl(i),
          merged_source_type = gUHMergedSourceTypeTbl(i),
          item_type = gUHItemTypeTbl(i),
          last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_update_date = sysdate,
          internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
          un_number =  gUHUnNumberTbl(i),
          hazard_class =  gUHHazardClassTbl(i)
      WHERE inventory_item_id = gUHInventoryItemIdTbl(i)
      AND   po_line_id = gUHPoLineIdTbl(i)
      AND   req_template_name = gUHReqTemplateNameTbl(i)
      AND   req_template_line_num = gUHReqTemplateLineNumTbl(i)
      AND   org_id = gUHOrgIdTbl(i)
      AND   language = gUHLanguageTbl(i)
      AND   source_type = gUHSourceTypeTbl(i);

    IF (gUHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows updated in ctx_hdrs:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 405;
    l_action_mode := 'DELETE_TO_UPDATE_ATTR_VALUES';

     --BUG 6599217 Start3 : Here the po_attribute tables have stale data so update
     --the po_attribute tables with new values.
    if (p_current_cursor = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) then

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'updating po attribute tables count=:' ||gUHInventoryItemIdTbl.Count);
     END IF;


    FOR i in 1..gUHInventoryItemIdTbl.Count Loop

        po_attribute_values_pvt.update_attributes_MI
        (
          p_org_id                => gUHOrgIdTbl(i),
          p_ip_category_id        => gUHIpCategoryIdTbl(i),
          p_inventory_item_id     => gUHInventoryItemIdTbl(i),
          p_language              => gUHLanguageTbl(i),
          p_item_description      => gUHDescriptionTbl(i),
          p_long_description      => gUHLongDescriptionTbl(i),
          p_organization_id       => gUHOrganizationIdTbl(i),
          p_master_organization_id => gUHMasterOrganizationIdTbl(i)
        );
     END LOOP;
    end if;
     --BUG 6599217 End 3

    FORALL i in 1..gUHInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_attribute_values
      WHERE inventory_item_id = gUHInventoryItemIdTbl(i)
      AND   po_line_id = gUHPoLineIdTbl(i)
      AND   req_template_name = gUHReqTemplateNameTbl(i)
      AND   req_template_line_num = gUHReqTemplateLineNumTbl(i)
      AND   org_id = gUHOrgIdTbl(i);

    IF (gUHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted for update from icx_cat_attribute_values:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 415;
    l_action_mode := 'INSERT_TO_UPDATE_ATTR_VALUES';
    FORALL i in 1..gUHInventoryItemIdTbl.COUNT
      MERGE INTO icx_cat_attribute_values icav
      USING (SELECT *
             FROM po_attribute_values
             WHERE inventory_item_id = gUHInventoryItemIdTbl(i)
             AND   po_line_id = gUHPoLineIdTbl(i)
             AND   req_template_name = gUHReqTemplateNameTbl(i)
             AND   req_template_line_num = gUHReqTemplateLineNumTbl(i)
             AND   org_id = gUHOrgIdTbl(i)) temp
      ON (icav.inventory_item_id = temp.inventory_item_id AND
          icav.po_line_id = temp.po_line_id AND
          icav.req_template_name = temp.req_template_name AND
          icav.req_template_line_num = temp.req_template_line_num AND
          icav.org_id = temp.org_id)
      WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.manufacturer_part_num, temp.picture, temp.thumbnail_image,
          temp.supplier_url, temp.manufacturer_url, temp.attachment_url, temp.unspsc,
          temp.availability, temp.lead_time,
          temp.text_base_attribute1, temp.text_base_attribute2, temp.text_base_attribute3,
          temp.text_base_attribute4, temp.text_base_attribute5, temp.text_base_attribute6,
          temp.text_base_attribute7, temp.text_base_attribute8, temp.text_base_attribute9,
          temp.text_base_attribute10, temp.text_base_attribute11, temp.text_base_attribute12,
          temp.text_base_attribute13, temp.text_base_attribute14, temp.text_base_attribute15,
          temp.text_base_attribute16, temp.text_base_attribute17, temp.text_base_attribute18,
          temp.text_base_attribute19, temp.text_base_attribute20, temp.text_base_attribute21,
          temp.text_base_attribute22, temp.text_base_attribute23, temp.text_base_attribute24,
          temp.text_base_attribute25, temp.text_base_attribute26, temp.text_base_attribute27,
          temp.text_base_attribute28, temp.text_base_attribute29, temp.text_base_attribute30,
          temp.text_base_attribute31, temp.text_base_attribute32, temp.text_base_attribute33,
          temp.text_base_attribute34, temp.text_base_attribute35, temp.text_base_attribute36,
          temp.text_base_attribute37, temp.text_base_attribute38, temp.text_base_attribute39,
          temp.text_base_attribute40, temp.text_base_attribute41, temp.text_base_attribute42,
          temp.text_base_attribute43, temp.text_base_attribute44, temp.text_base_attribute45,
          temp.text_base_attribute46, temp.text_base_attribute47, temp.text_base_attribute48,
          temp.text_base_attribute49, temp.text_base_attribute50, temp.text_base_attribute51,
          temp.text_base_attribute52, temp.text_base_attribute53, temp.text_base_attribute54,
          temp.text_base_attribute55, temp.text_base_attribute56, temp.text_base_attribute57,
          temp.text_base_attribute58, temp.text_base_attribute59, temp.text_base_attribute60,
          temp.text_base_attribute61, temp.text_base_attribute62, temp.text_base_attribute63,
          temp.text_base_attribute64, temp.text_base_attribute65, temp.text_base_attribute66,
          temp.text_base_attribute67, temp.text_base_attribute68, temp.text_base_attribute69,
          temp.text_base_attribute70, temp.text_base_attribute71, temp.text_base_attribute72,
          temp.text_base_attribute73, temp.text_base_attribute74, temp.text_base_attribute75,
          temp.text_base_attribute76, temp.text_base_attribute77, temp.text_base_attribute78,
          temp.text_base_attribute79, temp.text_base_attribute80, temp.text_base_attribute81,
          temp.text_base_attribute82, temp.text_base_attribute83, temp.text_base_attribute84,
          temp.text_base_attribute85, temp.text_base_attribute86, temp.text_base_attribute87,
          temp.text_base_attribute88, temp.text_base_attribute89, temp.text_base_attribute90,
          temp.text_base_attribute91, temp.text_base_attribute92, temp.text_base_attribute93,
          temp.text_base_attribute94, temp.text_base_attribute95, temp.text_base_attribute96,
          temp.text_base_attribute97, temp.text_base_attribute98, temp.text_base_attribute99,
          temp.text_base_attribute100,
          temp.num_base_attribute1, temp.num_base_attribute2, temp.num_base_attribute3,
          temp.num_base_attribute4, temp.num_base_attribute5, temp.num_base_attribute6,
          temp.num_base_attribute7, temp.num_base_attribute8, temp.num_base_attribute9,
          temp.num_base_attribute10, temp.num_base_attribute11, temp.num_base_attribute12,
          temp.num_base_attribute13, temp.num_base_attribute14, temp.num_base_attribute15,
          temp.num_base_attribute16, temp.num_base_attribute17, temp.num_base_attribute18,
          temp.num_base_attribute19, temp.num_base_attribute20, temp.num_base_attribute21,
          temp.num_base_attribute22, temp.num_base_attribute23, temp.num_base_attribute24,
          temp.num_base_attribute25, temp.num_base_attribute26, temp.num_base_attribute27,
          temp.num_base_attribute28, temp.num_base_attribute29, temp.num_base_attribute30,
          temp.num_base_attribute31, temp.num_base_attribute32, temp.num_base_attribute33,
          temp.num_base_attribute34, temp.num_base_attribute35, temp.num_base_attribute36,
          temp.num_base_attribute37, temp.num_base_attribute38, temp.num_base_attribute39,
          temp.num_base_attribute40, temp.num_base_attribute41, temp.num_base_attribute42,
          temp.num_base_attribute43, temp.num_base_attribute44, temp.num_base_attribute45,
          temp.num_base_attribute46, temp.num_base_attribute47, temp.num_base_attribute48,
          temp.num_base_attribute49, temp.num_base_attribute50, temp.num_base_attribute51,
          temp.num_base_attribute52, temp.num_base_attribute53, temp.num_base_attribute54,
          temp.num_base_attribute55, temp.num_base_attribute56, temp.num_base_attribute57,
          temp.num_base_attribute58, temp.num_base_attribute59, temp.num_base_attribute60,
          temp.num_base_attribute61, temp.num_base_attribute62, temp.num_base_attribute63,
          temp.num_base_attribute64, temp.num_base_attribute65, temp.num_base_attribute66,
          temp.num_base_attribute67, temp.num_base_attribute68, temp.num_base_attribute69,
          temp.num_base_attribute70, temp.num_base_attribute71, temp.num_base_attribute72,
          temp.num_base_attribute73, temp.num_base_attribute74, temp.num_base_attribute75,
          temp.num_base_attribute76, temp.num_base_attribute77, temp.num_base_attribute78,
          temp.num_base_attribute79, temp.num_base_attribute80, temp.num_base_attribute81,
          temp.num_base_attribute82, temp.num_base_attribute83, temp.num_base_attribute84,
          temp.num_base_attribute85, temp.num_base_attribute86, temp.num_base_attribute87,
          temp.num_base_attribute88, temp.num_base_attribute89, temp.num_base_attribute90,
          temp.num_base_attribute91, temp.num_base_attribute92, temp.num_base_attribute93,
          temp.num_base_attribute94, temp.num_base_attribute95, temp.num_base_attribute96,
          temp.num_base_attribute97, temp.num_base_attribute98, temp.num_base_attribute99,
          temp.num_base_attribute100,
          temp.text_cat_attribute1, temp.text_cat_attribute2, temp.text_cat_attribute3,
          temp.text_cat_attribute4, temp.text_cat_attribute5, temp.text_cat_attribute6,
          temp.text_cat_attribute7, temp.text_cat_attribute8, temp.text_cat_attribute9,
          temp.text_cat_attribute10, temp.text_cat_attribute11, temp.text_cat_attribute12,
          temp.text_cat_attribute13, temp.text_cat_attribute14, temp.text_cat_attribute15,
          temp.text_cat_attribute16, temp.text_cat_attribute17, temp.text_cat_attribute18,
          temp.text_cat_attribute19, temp.text_cat_attribute20, temp.text_cat_attribute21,
          temp.text_cat_attribute22, temp.text_cat_attribute23, temp.text_cat_attribute24,
          temp.text_cat_attribute25, temp.text_cat_attribute26, temp.text_cat_attribute27,
          temp.text_cat_attribute28, temp.text_cat_attribute29, temp.text_cat_attribute30,
          temp.text_cat_attribute31, temp.text_cat_attribute32, temp.text_cat_attribute33,
          temp.text_cat_attribute34, temp.text_cat_attribute35, temp.text_cat_attribute36,
          temp.text_cat_attribute37, temp.text_cat_attribute38, temp.text_cat_attribute39,
          temp.text_cat_attribute40, temp.text_cat_attribute41, temp.text_cat_attribute42,
          temp.text_cat_attribute43, temp.text_cat_attribute44, temp.text_cat_attribute45,
          temp.text_cat_attribute46, temp.text_cat_attribute47, temp.text_cat_attribute48,
          temp.text_cat_attribute49, temp.text_cat_attribute50,
          temp.num_cat_attribute1, temp.num_cat_attribute2, temp.num_cat_attribute3,
          temp.num_cat_attribute4, temp.num_cat_attribute5, temp.num_cat_attribute6,
          temp.num_cat_attribute7, temp.num_cat_attribute8, temp.num_cat_attribute9,
          temp.num_cat_attribute10, temp.num_cat_attribute11, temp.num_cat_attribute12,
          temp.num_cat_attribute13, temp.num_cat_attribute14, temp.num_cat_attribute15,
          temp.num_cat_attribute16, temp.num_cat_attribute17, temp.num_cat_attribute18,
          temp.num_cat_attribute19, temp.num_cat_attribute20, temp.num_cat_attribute21,
          temp.num_cat_attribute22, temp.num_cat_attribute23, temp.num_cat_attribute24,
          temp.num_cat_attribute25, temp.num_cat_attribute26, temp.num_cat_attribute27,
          temp.num_cat_attribute28, temp.num_cat_attribute29, temp.num_cat_attribute30,
          temp.num_cat_attribute31, temp.num_cat_attribute32, temp.num_cat_attribute33,
          temp.num_cat_attribute34, temp.num_cat_attribute35, temp.num_cat_attribute36,
          temp.num_cat_attribute37, temp.num_cat_attribute38, temp.num_cat_attribute39,
          temp.num_cat_attribute40, temp.num_cat_attribute41, temp.num_cat_attribute42,
          temp.num_cat_attribute43, temp.num_cat_attribute44, temp.num_cat_attribute45,
          temp.num_cat_attribute46, temp.num_cat_attribute47, temp.num_cat_attribute48,
          temp.num_cat_attribute49, temp.num_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);

    IF (gUHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows updated into icx_cat_attribute_values:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 425;
    l_action_mode := 'DELETE_TO_UPDATE_ATTR_VALUES_TLP';
    FORALL i in 1..gUHInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_attribute_values_tlp
      WHERE inventory_item_id = gUHInventoryItemIdTbl(i)
      AND   po_line_id = gUHPoLineIdTbl(i)
      AND   req_template_name = gUHReqTemplateNameTbl(i)
      AND   req_template_line_num = gUHReqTemplateLineNumTbl(i)
      AND   org_id = gUHOrgIdTbl(i)
      AND   language = gUHLanguageTbl(i);

    IF (gUHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted for update from icx_cat_attribute_values_tlp:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 435;
    l_action_mode := 'INSERT_TO_UPDATE_ATTR_VALUES_TLP';
    FORALL i in 1..gUHInventoryItemIdTbl.COUNT
      MERGE INTO icx_cat_attribute_values_tlp icavt
      USING (SELECT *
             FROM po_attribute_values_tlp
             WHERE inventory_item_id = gUHInventoryItemIdTbl(i)
             AND   po_line_id = gUHPoLineIdTbl(i)
             AND   req_template_name = gUHReqTemplateNameTbl(i)
             AND   req_template_line_num = gUHReqTemplateLineNumTbl(i)
             AND   org_id = gUHOrgIdTbl(i)
             AND   language = gUHLanguageTbl(i)) temp
      ON (icavt.inventory_item_id = temp.inventory_item_id AND
          icavt.po_line_id = temp.po_line_id AND
          icavt.req_template_name = temp.req_template_name AND
          icavt.req_template_line_num = temp.req_template_line_num AND
          icavt.org_id = temp.org_id AND
          icavt.language = temp.language)
      WHEN NOT MATCHED THEN INSERT VALUES (
          temp.attribute_values_tlp_id, temp.po_line_id, temp.req_template_name,
          temp.req_template_line_num, temp.ip_category_id, temp.inventory_item_id,
          temp.org_id, temp.language, temp.description, temp.manufacturer,
          temp.comments, temp.alias, temp.long_description,
          temp.tl_text_base_attribute1, temp.tl_text_base_attribute2, temp.tl_text_base_attribute3,
          temp.tl_text_base_attribute4, temp.tl_text_base_attribute5, temp.tl_text_base_attribute6,
          temp.tl_text_base_attribute7, temp.tl_text_base_attribute8, temp.tl_text_base_attribute9,
          temp.tl_text_base_attribute10, temp.tl_text_base_attribute11, temp.tl_text_base_attribute12,
          temp.tl_text_base_attribute13, temp.tl_text_base_attribute14, temp.tl_text_base_attribute15,
          temp.tl_text_base_attribute16, temp.tl_text_base_attribute17, temp.tl_text_base_attribute18,
          temp.tl_text_base_attribute19, temp.tl_text_base_attribute20, temp.tl_text_base_attribute21,
          temp.tl_text_base_attribute22, temp.tl_text_base_attribute23, temp.tl_text_base_attribute24,
          temp.tl_text_base_attribute25, temp.tl_text_base_attribute26, temp.tl_text_base_attribute27,
          temp.tl_text_base_attribute28, temp.tl_text_base_attribute29, temp.tl_text_base_attribute30,
          temp.tl_text_base_attribute31, temp.tl_text_base_attribute32, temp.tl_text_base_attribute33,
          temp.tl_text_base_attribute34, temp.tl_text_base_attribute35, temp.tl_text_base_attribute36,
          temp.tl_text_base_attribute37, temp.tl_text_base_attribute38, temp.tl_text_base_attribute39,
          temp.tl_text_base_attribute40, temp.tl_text_base_attribute41, temp.tl_text_base_attribute42,
          temp.tl_text_base_attribute43, temp.tl_text_base_attribute44, temp.tl_text_base_attribute45,
          temp.tl_text_base_attribute46, temp.tl_text_base_attribute47, temp.tl_text_base_attribute48,
          temp.tl_text_base_attribute49, temp.tl_text_base_attribute50, temp.tl_text_base_attribute51,
          temp.tl_text_base_attribute52, temp.tl_text_base_attribute53, temp.tl_text_base_attribute54,
          temp.tl_text_base_attribute55, temp.tl_text_base_attribute56, temp.tl_text_base_attribute57,
          temp.tl_text_base_attribute58, temp.tl_text_base_attribute59, temp.tl_text_base_attribute60,
          temp.tl_text_base_attribute61, temp.tl_text_base_attribute62, temp.tl_text_base_attribute63,
          temp.tl_text_base_attribute64, temp.tl_text_base_attribute65, temp.tl_text_base_attribute66,
          temp.tl_text_base_attribute67, temp.tl_text_base_attribute68, temp.tl_text_base_attribute69,
          temp.tl_text_base_attribute70, temp.tl_text_base_attribute71, temp.tl_text_base_attribute72,
          temp.tl_text_base_attribute73, temp.tl_text_base_attribute74, temp.tl_text_base_attribute75,
          temp.tl_text_base_attribute76, temp.tl_text_base_attribute77, temp.tl_text_base_attribute78,
          temp.tl_text_base_attribute79, temp.tl_text_base_attribute80, temp.tl_text_base_attribute81,
          temp.tl_text_base_attribute82, temp.tl_text_base_attribute83, temp.tl_text_base_attribute84,
          temp.tl_text_base_attribute85, temp.tl_text_base_attribute86, temp.tl_text_base_attribute87,
          temp.tl_text_base_attribute88, temp.tl_text_base_attribute89, temp.tl_text_base_attribute90,
          temp.tl_text_base_attribute91, temp.tl_text_base_attribute92, temp.tl_text_base_attribute93,
          temp.tl_text_base_attribute94, temp.tl_text_base_attribute95, temp.tl_text_base_attribute96,
          temp.tl_text_base_attribute97, temp.tl_text_base_attribute98, temp.tl_text_base_attribute99,
          temp.tl_text_base_attribute100,
          temp.tl_text_cat_attribute1, temp.tl_text_cat_attribute2, temp.tl_text_cat_attribute3,
          temp.tl_text_cat_attribute4, temp.tl_text_cat_attribute5, temp.tl_text_cat_attribute6,
          temp.tl_text_cat_attribute7, temp.tl_text_cat_attribute8, temp.tl_text_cat_attribute9,
          temp.tl_text_cat_attribute10, temp.tl_text_cat_attribute11, temp.tl_text_cat_attribute12,
          temp.tl_text_cat_attribute13, temp.tl_text_cat_attribute14, temp.tl_text_cat_attribute15,
          temp.tl_text_cat_attribute16, temp.tl_text_cat_attribute17, temp.tl_text_cat_attribute18,
          temp.tl_text_cat_attribute19, temp.tl_text_cat_attribute20, temp.tl_text_cat_attribute21,
          temp.tl_text_cat_attribute22, temp.tl_text_cat_attribute23, temp.tl_text_cat_attribute24,
          temp.tl_text_cat_attribute25, temp.tl_text_cat_attribute26, temp.tl_text_cat_attribute27,
          temp.tl_text_cat_attribute28, temp.tl_text_cat_attribute29, temp.tl_text_cat_attribute30,
          temp.tl_text_cat_attribute31, temp.tl_text_cat_attribute32, temp.tl_text_cat_attribute33,
          temp.tl_text_cat_attribute34, temp.tl_text_cat_attribute35, temp.tl_text_cat_attribute36,
          temp.tl_text_cat_attribute37, temp.tl_text_cat_attribute38, temp.tl_text_cat_attribute39,
          temp.tl_text_cat_attribute40, temp.tl_text_cat_attribute41, temp.tl_text_cat_attribute42,
          temp.tl_text_cat_attribute43, temp.tl_text_cat_attribute44, temp.tl_text_cat_attribute45,
          temp.tl_text_cat_attribute46, temp.tl_text_cat_attribute47, temp.tl_text_cat_attribute48,
          temp.tl_text_cat_attribute49, temp.tl_text_cat_attribute50,
          temp.last_update_login, temp.last_updated_by, temp.last_update_date, temp.created_by,
          temp.creation_date, temp.request_id, temp.program_application_id, temp.program_id,
          temp.program_update_date, temp.last_updated_program, temp.rebuild_search_index_flag);

    IF (gUHInventoryItemIdTbl.COUNT > 0) THEN
     -- ICX_ENDECA_UTIL_PKG.incrementalUpdate('UPDATE',gUHInventoryItemIdTbl,gUHPoLineIdTbl,gUHReqTemplateNameTbl,gUHReqTemplateLineNumTbl,gUHOrgIdTbl,gUHLanguageTbl);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows updated into icx_cat_attribute_values_tlp:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 440;
    clearTables(l_action_mode);

    l_err_loc := 450;
    l_action_mode := 'DELETE_CTX_DTLS';
    FORALL i in 1..gDDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDDInventoryItemIdTbl(i)
      AND   po_line_id = gDDPoLineIdTbl(i)
      AND   req_template_name = gDDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDDReqTemplateLineNumTbl(i)
      AND   org_id = gDDOrgIdTbl(i)
      AND   language = gDDLanguageTbl(i);

    IF (gDDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 500;
    clearTables(l_action_mode);

    l_err_loc := 550;
    l_action_mode := 'DELETE_CTX_HDRS';
    FORALL i in 1..gDHInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_hdrs_tlp
      WHERE inventory_item_id = gDHInventoryItemIdTbl(i)
      AND   po_line_id = gDHPoLineIdTbl(i)
      AND   req_template_name = gDHReqTemplateNameTbl(i)
      AND   req_template_line_num = gDHReqTemplateLineNumTbl(i)
      AND   org_id = gDHOrgIdTbl(i)
      AND   language = gDHLanguageTbl(i);

    IF (gDHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_hdrs:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 610;
    l_action_mode := 'DELETE_ATTR_VALUES';
    FORALL i in 1..gDHInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_attribute_values
      WHERE inventory_item_id = gDHInventoryItemIdTbl(i)
      AND   po_line_id = gDHPoLineIdTbl(i)
      AND   req_template_name = gDHReqTemplateNameTbl(i)
      AND   req_template_line_num = gDHReqTemplateLineNumTbl(i)
      AND   org_id = gDHOrgIdTbl(i);

    IF (gDHInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from icx_Cat_attribute_values:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 630;
    l_action_mode := 'DELETE_ATTR_VALUES_TLP';
    FORALL i in 1..gDHInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_attribute_values_tlp
      WHERE inventory_item_id = gDHInventoryItemIdTbl(i)
      AND   po_line_id = gDHPoLineIdTbl(i)
      AND   req_template_name = gDHReqTemplateNameTbl(i)
      AND   req_template_line_num = gDHReqTemplateLineNumTbl(i)
      AND   org_id = gDHOrgIdTbl(i)
      AND   language = gDHLanguageTbl(i);

    IF (gDHInventoryItemIdTbl.COUNT > 0) THEN
       IF fnd_profile.Value('FND_ENDECA_PORTAL_URL') IS NOT NULL THEN
        ICX_ENDECA_UTIL_PKG.incrementalDelete(gDHInventoryItemIdTbl,gDHPoLineIdTbl,gDHReqTemplateNameTbl,gDHReqTemplateLineNumTbl,gDHOrgIdTbl,gDHLanguageTbl);
       END IF;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from icx_Cat_attribute_values_tlp:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 640;
    clearTables(l_action_mode);

    -- For gIDInventoryItemIdTbl:    populate all rows between 1 and 15001
    -- Need to populate base, local and org attributes i.e. rows with sequence between 1 and 15001
    -- 1a. Rows with sequence between 1 and 100 (i.e. base special attributes) will be populated here.
    -- 1b. Rows with sequence between 101 and 5000 (i.e. base regular attributes) will be populated here.
    -- 2. Rows with sequence between 10000 and 15001 (i.e. org attributes)
    --    will be populated below
    -- 3. Rows with sequence between 5001 and 9999 (i.e. catg/local attributes)
    --    will be populated in the final call to ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt
    -- For gDBLDInventoryItemIdTbl:  re-populate only rows between 101 and 5000
    -- Need to re-populate only non-seeded base attributes and local attributes i.e. rows with sequence between 101 and 5000
    -- 1. Rows with sequence between 101 and 5000 (i.e. base regular attributes) will be populated here.
    -- 2. Rows with sequence between 5001 and 9999 (i.e. catg/local attributes)
    --    will be populated in the final call to ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt
    --    CategoryAttributes will be deleted for gDBLDInventoryItemIdTbl here, but will be
    --    inserted back using ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt
    -- For gDMDInventoryItemIdTbl: re-populate only the row with sequence = 1           <=> Mandatory row
    -- For gDSDInventoryItemIdTbl: re-populate only the row with sequence = 2           <=> Supplier row
    -- For gDIRDInventoryItemIdTbl: re-populate only the row with sequence = 5          <=> Item Revision row
    -- For gDSCDInventoryItemIdTbl: re-populate only the row with sequence = 6          <=> Shopping Category row
    -- For gDUNDInventoryItemIdTbl: re-populate only the row with sequence = 7          <=> un_number row
    -- For gDHZDInventoryItemIdTbl: re-populate only the row with sequence = 8          <=> hazard_class row
    -- For gDPODInventoryItemIdTbl: re-populate only the row with sequence = 15001      <=> purchasing_org_id row


    l_err_loc := 650;
    IF (gIDInventoryItemIdTbl.COUNT > 0 OR
        gDBLDInventoryItemIdTbl.COUNT > 0 OR
        gDMDInventoryItemIdTbl.COUNT > 0 OR
        gDSDInventoryItemIdTbl.COUNT > 0 OR
        gDIRDInventoryItemIdTbl.COUNT > 0 OR
        gDSCDInventoryItemIdTbl.COUNT > 0 OR
        gDPODInventoryItemIdTbl.COUNT > 0 OR
        gDUNDInventoryItemIdTbl.Count > 0 OR
        gDHZDInventoryItemIdTbl.Count > 0)
    THEN
      l_err_loc := 700;
      l_special_ctx_sql_tbl.DELETE;
      l_regular_ctx_sql_tbl.DELETE;

      IF (p_current_cursor IN (ICX_CAT_UTIL_PVT.g_BPACsr_const,
                               ICX_CAT_UTIL_PVT.g_QuoteCsr_const,
                               ICX_CAT_UTIL_PVT.g_GBPACsr_const))
      THEN
        l_err_loc := 750;
        ICX_CAT_POPULATE_PODOCS_PVT.buildCtxSqlForPODocs(l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

      ELSIF (p_current_cursor = ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const) THEN
        l_err_loc := 800;
        ICX_CAT_POPULATE_REQTMPL_PVT.buildCtxSqlForRTs(l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

      ELSIF (p_current_cursor = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN
        l_err_loc := 900;
        ICX_CAT_POPULATE_MI_PVT.buildCtxSqlForMIs(l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);
      END IF;
    END IF;

    l_err_loc := 1050;
    l_action_mode := 'DELETE_MANDATORY_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 1 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 1;
    FORALL i in 1..gDMDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDMDInventoryItemIdTbl(i)
      AND   po_line_id = gDMDPoLineIdTbl(i)
      AND   req_template_name = gDMDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDMDReqTemplateLineNumTbl(i)
      AND   org_id = gDMDOrgIdTbl(i)
      AND   language = gDMDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqMandatoryBaseRow;

    IF (gDMDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for mandatory row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1100;
    l_action_mode := 'DELETE_SUPPLIER_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 2 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 2;
    FORALL i in 1..gDSDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDSDInventoryItemIdTbl(i)
      AND   po_line_id = gDSDPoLineIdTbl(i)
      AND   req_template_name = gDSDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDSDReqTemplateLineNumTbl(i)
      AND   org_id = gDSDOrgIdTbl(i)
      AND   language = gDSDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow;

    IF (gDSDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for supplier row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1150;
    l_action_mode := 'DELETE_ITEMREV_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 5 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 5;
    FORALL i in 1..gDIRDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDIRDInventoryItemIdTbl(i)
      AND   po_line_id = gDIRDPoLineIdTbl(i)
      AND   req_template_name = gDIRDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDIRDReqTemplateLineNumTbl(i)
      AND   org_id = gDIRDOrgIdTbl(i)
      AND   language = gDIRDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForItemRevisionRow;

    IF (gDIRDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for item revision row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1200;
    l_action_mode := 'DELETE_SHOPCATG_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 6 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 6;
    FORALL i in 1..gDSCDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDSCDInventoryItemIdTbl(i)
      AND   po_line_id = gDSCDPoLineIdTbl(i)
      AND   req_template_name = gDSCDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDSCDReqTemplateLineNumTbl(i)
      AND   org_id = gDSCDOrgIdTbl(i)
      AND   language = gDSCDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow;

    IF (gDSCDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for shop category row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    -- 17076597 changes starts
    l_err_loc := 1210;
    l_action_mode := 'DELETE_UN_NUMBER_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 7 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 7;
    FORALL i in 1..gDUNDInventoryItemIdTbl.Count
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDUNDInventoryItemIdTbl(i)
      AND   po_line_id = gDUNDPoLineIdTbl(i)
      AND   req_template_name = gDUNDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDUNDReqTemplateLineNumTbl(i)
      AND   org_id = gDUNDOrgIdTbl(i)
      AND   language = gDUNDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForUnNumberRow;

    IF (gDUNDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for un number row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1220;
    l_action_mode := 'DELETE_HAZARD_CLASS_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 8 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 8;
    FORALL i in 1..gDHZDInventoryItemIdTbl.Count
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDHZDInventoryItemIdTbl(i)
      AND   po_line_id = gDHZDPoLineIdTbl(i)
      AND   req_template_name = gDHZDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDHZDReqTemplateLineNumTbl(i)
      AND   org_id = gDHZDOrgIdTbl(i)
      AND   language = gDHZDLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForHazardClassRow;

    IF (gDUNDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for hazard class row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;
    -- 17076597 changes ends

    l_err_loc := 1250;
    l_action_mode := 'DELETE_PURCHORG_ROW_CTX_DTLS';
    -- DELETE rows with sequence = 15001 in icx_cat_items_ctx_dtl_tlp
    -- l_sequence := 15001;
    FORALL i in 1..gDPODInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDPODInventoryItemIdTbl(i)
      AND   po_line_id = gDPODPoLineIdTbl(i)
      AND   req_template_name = gDPODReqTemplateNameTbl(i)
      AND   req_template_line_num = gDPODReqTemplateLineNumTbl(i)
      AND   org_id = gDPODOrgIdTbl(i)
      AND   language = gDPODLanguageTbl(i)
      AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForPurchasingOrgIdRow;

    IF (gDPODInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for purch org row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;
-- Bug 7691407 - Added logic to delete and insert the dtls ctx tables for
-- internal item number
    l_err_loc := 1300;
    l_action_mode := 'DELETE_SPECIFIC_CTX_DTLS';
    -- DELETE rows with sequence > 100 and < 10000 icx_cat_items_ctx_dtl_tlp
    l_start_sequence := 101;
    l_end_sequence := 9999;
    FORALL i in 1..gDBLDInventoryItemIdTbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
      AND   po_line_id = gDBLDPoLineIdTbl(i)
      AND   req_template_name = gDBLDReqTemplateNameTbl(i)
      AND   req_template_line_num = gDBLDReqTemplateLineNumTbl(i)
      AND   org_id = gDBLDOrgIdTbl(i)
      AND   language = gDBLDLanguageTbl(i)
      AND   ((sequence BETWEEN l_start_sequence AND l_end_sequence) OR SEQUENCE = 3);

    IF (gDBLDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_dtls for base and local row changes:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1350;
    l_action_mode := 'INSERT_CTX_DTLS';
    -- populate the org rows in ctx details
    --  sequence        ctx_desc
    --  10000           <orgid>
    --  10001           to_char(gIDOrgIdTbl(i))
    --  15000           </orgid>
    --  15001           <purchorgid> || to_char(gIDPurchasingOrgIdTbl(i)) || </purchorgid>
    --  15001           <purchorgid> || to_char(gDPODPurchasingOrgIdTbl(i)) || </purchorgid>
    FORALL i in 1..gIDInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num,
       org_id, language, sequence, ctx_desc,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gIDInventoryItemIdTbl(i), gIDPoLineIdTbl(i), gIDReqTemplateNameTbl(i), gIDReqTemplateLineNumTbl(i),
       gIDOrgIdTbl(i), gIDLanguageTbl(i), 10000, '<orgid>',
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    l_err_loc := 1400;
    FORALL i in 1..gIDInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num,
       org_id, language, sequence, ctx_desc,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gIDInventoryItemIdTbl(i), gIDPoLineIdTbl(i), gIDReqTemplateNameTbl(i), gIDReqTemplateLineNumTbl(i),
       gIDOrgIdTbl(i), gIDLanguageTbl(i), 10001, to_char(gIDOrgIdTbl(i)),
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    l_err_loc := 1450;
    FORALL i in 1..gIDInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num,
       org_id, language, sequence, ctx_desc,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gIDInventoryItemIdTbl(i), gIDPoLineIdTbl(i), gIDReqTemplateNameTbl(i), gIDReqTemplateLineNumTbl(i),
       gIDOrgIdTbl(i), gIDLanguageTbl(i), 15000, '</orgid>',
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    IF (gIDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into ctx_dtls for org row:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1460;
    -- Purchasing_org_id row needs to be populated for new rows i.e. gIDInventoryItemIdTbl and gDPODInventoryItemIdTbl
    FORALL i in 1..gIDInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num,
       org_id, language, sequence, ctx_desc,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gIDInventoryItemIdTbl(i), gIDPoLineIdTbl(i), gIDReqTemplateNameTbl(i), gIDReqTemplateLineNumTbl(i),
       gIDOrgIdTbl(i), gIDLanguageTbl(i), 15001, '<purchorgid>' || to_char(gIDPurchasingOrgIdTbl(i)) || '</purchorgid>',
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    IF (gIDInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into ctx_dtls for purch_org row:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1500;
    l_action_mode := 'DELETE_PURCHORG_ROW_CTX_DTLS';
    -- Purchasing_org_id row needs to be populated for new rows i.e. gIDInventoryItemIdTbl and gDPODInventoryItemIdTbl
    FORALL i in 1..gDPODInventoryItemIdTbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num,
       org_id, language, sequence, ctx_desc,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES(gDPODInventoryItemIdTbl(i), gDPODPoLineIdTbl(i), gDPODReqTemplateNameTbl(i), gDPODReqTemplateLineNumTbl(i),
       gDPODOrgIdTbl(i), gDPODLanguageTbl(i), 15001, '<purchorgid>' || to_char(gDPODPurchasingOrgIdTbl(i)) || '</purchorgid>',
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    IF (gDPODInventoryItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into ctx_dtls for purch_org row:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 1550;
    -- Inserting rows for special attribute rows i.e. sequence between 1 and 100
    -- 17076597 changes added un number and hazard class
    IF (gIDInventoryItemIdTbl.COUNT > 0 OR
        gDMDInventoryItemIdTbl.COUNT > 0 OR
        gDSDInventoryItemIdTbl.COUNT > 0 OR
        gDIRDInventoryItemIdTbl.COUNT > 0 OR
        gDSCDInventoryItemIdTbl.COUNT > 0 OR
        gDBLDInventoryItemIdTbl.Count > 0 OR
        gDUNDInventoryItemIdTbl.Count > 0 OR
        gDHZDInventoryItemIdTbl.Count > 0) THEN
      FOR i IN 1..l_special_ctx_sql_tbl.COUNT LOOP
        l_err_loc := 1600;
        l_ctx_sqlstring_rec := l_special_ctx_sql_tbl(i);
        l_ctx_sql_string := l_ctx_sqlstring_rec.ctx_sql_string;
        l_sequence := l_ctx_sqlstring_rec.bind_sequence;
        IF (p_current_cursor = ICX_CAT_UTIL_PVT.g_GBPACsr_const AND i > 1) THEN
          -- For GBPAs enabled org we only need to populate the row with sequence 1
          -- diffferntly than the owning org.  The other rows i.e. between sequence 2 to 9999
          -- will be exact copies of owning org
          EXIT;
        END IF;
        l_err_loc := 1650;
        l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
        l_err_loc := 1700;
        DBMS_SQL.PARSE(l_csr_handle, l_ctx_sql_string, DBMS_SQL.NATIVE);
        IF (gIDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 1750;
          l_action_mode := 'INSERT_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gIDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gIDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gIDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gIDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gIDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gIDLanguageTbl);
          l_err_loc := 1800;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS details..' ||
                '; Num. of rows in dtls plsql table:' || gIDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;

        IF (l_sequence = 1 AND gDMDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 1850;
          l_action_mode := 'DELETE_MANDATORY_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDMDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDMDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDMDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDMDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDMDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDMDLanguageTbl);
          l_err_loc := 1900;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, Mandatory Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDMDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;

        IF (l_sequence = 2 AND gDSDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 1950;
          l_action_mode := 'DELETE_SUPPLIER_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDSDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDSDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDSDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDSDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDSDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDSDLanguageTbl);
          l_err_loc := 2000;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, Supplier Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDSDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;
-- Bug 7691407 - Added logic to delete and insert the dtls ctx tables for
-- internal item number
        IF (l_sequence = 3 AND gDBLDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 2010;
          l_action_mode := 'DELETE_SPECIFIC_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDBLDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDBLDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDBLDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDBLDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDBLDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDBLDLanguageTbl);
          l_err_loc := 2020;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, Item Number details..' ||
                '; Num. of rows in dtls plsql table:' || gDBLDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;

	  -- Bug 16805850 - Update all ctx_dtls records with the same inventory_item_id for internal item number
          l_err_loc := 2030;
          IF (p_current_cursor = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN
	     FORALL i in 1..gDBLDInventoryItemIdTbl.COUNT
	        UPDATE icx_cat_items_ctx_dtls_tlp
	           SET ctx_desc = (SELECT ctx_desc
		    		     FROM icx_cat_items_ctx_dtls_tlp
			            WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
				      AND po_line_id =  gDBLDPoLineIdTbl(i)
				      AND req_template_name =  gDBLDReqTemplateNameTbl(i)
				      AND req_template_line_num =  gDBLDReqTemplateLineNumTbl(i)
				      AND org_id = gDBLDOrgIdTbl(i)
			              AND language = gDBLDLanguageTbl(i)
				      AND sequence = l_sequence
			           )
		 WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
		   AND org_id = gDBLDOrgIdTbl(i)
		   AND language = gDBLDLanguageTbl(i)
		   AND sequence = l_sequence
		   AND ctx_desc <> (SELECT ctx_desc
				      FROM icx_cat_items_ctx_dtls_tlp
				     WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
			               AND po_line_id =  gDBLDPoLineIdTbl(i)
				       AND req_template_name =  gDBLDReqTemplateNameTbl(i)
			               AND req_template_line_num =  gDBLDReqTemplateLineNumTbl(i)
			               AND org_id = gDBLDOrgIdTbl(i)
				       AND language = gDBLDLanguageTbl(i)
			               AND sequence = l_sequence
			            );

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
			ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                        'Num. of rows updated in icx_cat_items_ctx_dtls_tlp:' || SQL%ROWCOUNT ||
                        ', for seq:' || l_sequence );
	        END IF;
	        -- Update the ctx_desc to null in hdrs table, for rebuild indexes.
	        FORALL i in 1..gDBLDInventoryItemIdTbl.COUNT
	           UPDATE icx_cat_items_ctx_hdrs_tlp
		      SET ctx_desc = null
		    WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
		      AND org_id =  gDBLDOrgIdTbl(i)
		      AND language = gDBLDLanguageTbl(i)
		      AND source_type <> (SELECT source_type
					    FROM icx_cat_items_ctx_hdrs_tlp
					   WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
					     AND po_line_id =  gDBLDPoLineIdTbl(i)
					     AND req_template_name =  gDBLDReqTemplateNameTbl(i)
					     AND req_template_line_num =  gDBLDReqTemplateLineNumTbl(i)
					     AND org_id = gDBLDOrgIdTbl(i)
					     AND language = gDBLDLanguageTbl(i)
				          );

	        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
			ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                       'Num. of rows updated in icx_cat_items_ctx_hdrs_tlp:' || SQL%ROWCOUNT);
	        END IF;
	   END IF;
           -- Bug 16805850 ends
        END IF;

        IF (l_sequence = 5 AND gDIRDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 2050;
          l_action_mode := 'DELETE_ITEMREV_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDIRDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDIRDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDIRDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDIRDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDIRDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDIRDLanguageTbl);
          l_err_loc := 2100;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, ItemRev Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDIRDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;

        IF (l_sequence = 6 AND gDSCDInventoryItemIdTbl.COUNT > 0) THEN
          l_err_loc := 2150;
          l_action_mode := 'DELETE_SHOPCATG_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDSCDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDSCDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDSCDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDSCDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDSCDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDSCDLanguageTbl);
          l_err_loc := 2200;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, ShopCatg Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDSCDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;

        -- 17076597 changes starts
        IF (l_sequence = 7 AND gDUNDInventoryItemIdTbl.COUNT > 0 ) THEN
          l_err_loc := 2210;
          l_action_mode := 'DELETE_UN_NUMBER_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDUNDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDUNDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDUNDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM',gDUNDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDUNDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDUNDLanguageTbl);
          l_err_loc := 2211;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, Un Number Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDUNDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;


        IF (l_sequence = 8 AND gDHZDInventoryItemIdTbl.COUNT > 0 ) THEN
          l_err_loc := 2220;
          l_action_mode := 'DELETE_HAZARD_CLASS_ROW_CTX_DTLS';
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDHZDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDHZDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDHZDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM',gDHZDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDHZDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDHZDLanguageTbl);
          l_err_loc := 2221;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'special Ctx SQLS, Hazard Class Row details..' ||
                '; Num. of rows in dtls plsql table:' || gDHZDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_sequence || ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;
        -- 17076597 changes ends

        l_err_loc := 2250;
        DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
        l_err_loc := 10000 + i;
      END LOOP;
    END IF;

    l_err_loc :=2300;
    -- Inserting rows for base attribute rows i.e. sequence between 101 and 5000
    IF (p_current_cursor = ICX_CAT_UTIL_PVT.g_GBPACsr_const) THEN
      l_err_loc := 2400;
      l_action_mode := 'INSERT_CTX_DTLS';
      l_start_sequence := 2;
      l_end_sequence := 5000;
      -- rows with sequence between 5001 and 9999 (local attributes) will be done after the
      -- final call to ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt in
      FORALL i in 1..gIDInventoryItemIdTbl.COUNT
        INSERT INTO icx_cat_items_ctx_dtls_tlp
         (inventory_item_id, po_line_id, req_template_name,
          req_template_line_num, org_id, language,
          last_update_login, last_updated_by, last_update_date,
          created_by, creation_date, internal_request_id, request_id,
          program_application_id, program_id, program_login_id,
          sequence, ctx_desc)
        SELECT inventory_item_id, po_line_id, req_template_name,
               req_template_line_num, gIDOrgIdTbl(i), language,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
               sequence, ctx_desc
        FROM icx_cat_items_ctx_dtls_tlp
        WHERE inventory_item_id = gIDInventoryItemIdTbl(i)
        AND   po_line_id = gIDPoLineIdTbl(i)
        AND   req_template_name = gIDReqTemplateNameTbl(i)
        AND   req_template_line_num = gIDReqTemplateLineNumTbl(i)
        AND   org_id = gIDOwningOrgIdTbl(i)
        AND   language = gIDLanguageTbl(i)
        AND   sequence BETWEEN l_start_sequence AND l_end_sequence;

      IF (gIDInventoryItemIdTbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows inserted into ctx_dtls for GBPA with seq between 2 - 5000 row:' ||SQL%ROWCOUNT);
        END IF;
      END IF;
      l_err_loc := 2500;

      l_action_mode := 'DELETE_SPECIFIC_CTX_DTLS';
      l_start_sequence := 101;
      FORALL i in 1..gDBLDInventoryItemIdTbl.COUNT
        INSERT INTO icx_cat_items_ctx_dtls_tlp
         (inventory_item_id, po_line_id, req_template_name,
          req_template_line_num, org_id, language,
          last_update_login, last_updated_by, last_update_date,
          created_by, creation_date, internal_request_id, request_id,
          program_application_id, program_id, program_login_id,
          sequence, ctx_desc)
        SELECT inventory_item_id, po_line_id, req_template_name,
               req_template_line_num, gDBLDOrgIdTbl(i), language,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
               sequence, ctx_desc
        FROM icx_cat_items_ctx_dtls_tlp
        WHERE inventory_item_id = gDBLDInventoryItemIdTbl(i)
        AND   po_line_id = gDBLDPoLineIdTbl(i)
        AND   req_template_name = gDBLDReqTemplateNameTbl(i)
        AND   req_template_line_num = gDBLDReqTemplateLineNumTbl(i)
        AND   org_id = gDBLDOwningOrgIdTbl(i)
        AND   language = gDBLDLanguageTbl(i)
        AND   ((sequence BETWEEN l_start_sequence AND l_end_sequence) or
sequence =3);

      l_err_loc := 2600;
      IF (gDBLDInventoryItemIdTbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows inserted into ctx_dtls for 101 - 5000 row:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_action_mode := 'DELETE_SUPPLIER_ROW_CTX_DTLS';
      -- l_sequence := 2;
      FORALL i in 1..gDSDInventoryItemIdTbl.COUNT
        INSERT INTO icx_cat_items_ctx_dtls_tlp
         (inventory_item_id, po_line_id, req_template_name,
          req_template_line_num, org_id, language,
          last_update_login, last_updated_by, last_update_date,
          created_by, creation_date, internal_request_id, request_id,
          program_application_id, program_id, program_login_id,
          sequence, ctx_desc)
        SELECT inventory_item_id, po_line_id, req_template_name,
               req_template_line_num, gDSDOrgIdTbl(i), language,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
               sequence, ctx_desc
        FROM icx_cat_items_ctx_dtls_tlp
        WHERE inventory_item_id = gDSDInventoryItemIdTbl(i)
        AND   po_line_id = gDSDPoLineIdTbl(i)
        AND   req_template_name = gDSDReqTemplateNameTbl(i)
        AND   req_template_line_num = gDSDReqTemplateLineNumTbl(i)
        AND   org_id = gDSDOwningOrgIdTbl(i)
        AND   language = gDSDLanguageTbl(i)
        AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow;

      IF (gDSDInventoryItemIdTbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows inserted into ctx_dtls for seq 2 row:' ||SQL%ROWCOUNT);
        END IF;
      END IF;
      l_err_loc := 2700;

      l_action_mode := 'DELETE_ITEMREV_ROW_CTX_DTLS';
      -- l_sequence := 5;
      FORALL i in 1..gDIRDInventoryItemIdTbl.COUNT
        INSERT INTO icx_cat_items_ctx_dtls_tlp
         (inventory_item_id, po_line_id, req_template_name,
          req_template_line_num, org_id, language,
          last_update_login, last_updated_by, last_update_date,
          created_by, creation_date, internal_request_id, request_id,
          program_application_id, program_id, program_login_id,
          sequence, ctx_desc)
        SELECT inventory_item_id, po_line_id, req_template_name,
               req_template_line_num, gDIRDOrgIdTbl(i), language,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
               sequence, ctx_desc
        FROM icx_cat_items_ctx_dtls_tlp
        WHERE inventory_item_id = gDIRDInventoryItemIdTbl(i)
        AND   po_line_id = gDIRDPoLineIdTbl(i)
        AND   req_template_name = gDIRDReqTemplateNameTbl(i)
        AND   req_template_line_num = gDIRDReqTemplateLineNumTbl(i)
        AND   org_id = gDIRDOwningOrgIdTbl(i)
        AND   language = gDIRDLanguageTbl(i)
        AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForItemRevisionRow;

      l_err_loc := 2800;
      IF (gDIRDInventoryItemIdTbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows inserted into ctx_dtls for seq 5 row:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_action_mode := 'DELETE_SHOPCATG_ROW_CTX_DTLS';
      -- l_sequence := 6;
      FORALL i in 1..gDSCDInventoryItemIdTbl.COUNT
        INSERT INTO icx_cat_items_ctx_dtls_tlp
         (inventory_item_id, po_line_id, req_template_name,
          req_template_line_num, org_id, language,
          last_update_login, last_updated_by, last_update_date,
          created_by, creation_date, internal_request_id, request_id,
          program_application_id, program_id, program_login_id,
          sequence, ctx_desc)
        SELECT inventory_item_id, po_line_id, req_template_name,
               req_template_line_num, gDSCDOrgIdTbl(i), language,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
               ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id,
               sequence, ctx_desc
        FROM icx_cat_items_ctx_dtls_tlp
        WHERE inventory_item_id = gDSCDInventoryItemIdTbl(i)
        AND   po_line_id = gDSCDPoLineIdTbl(i)
        AND   req_template_name = gDSCDReqTemplateNameTbl(i)
        AND   req_template_line_num = gDSCDReqTemplateLineNumTbl(i)
        AND   org_id = gDSCDOwningOrgIdTbl(i)
        AND   language = gDSCDLanguageTbl(i)
        AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow;

      l_err_loc := 2900;
      IF (gDSCDInventoryItemIdTbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows inserted into ctx_dtls for seq 6 row:' ||SQL%ROWCOUNT);
        END IF;
      END IF;
    ELSE
      l_err_loc := 3000;
      FOR i IN 1..l_regular_ctx_sql_tbl.COUNT LOOP
        l_err_loc := 3100;
        l_ctx_sqlstring_rec := l_regular_ctx_sql_tbl(i);
        l_err_loc := 3200;
        l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
        l_err_loc := 3300;
        DBMS_SQL.PARSE(l_csr_handle, l_ctx_sqlstring_rec.ctx_sql_string, DBMS_SQL.NATIVE);
        IF (gIDInventoryItemIdTbl.COUNT > 0) THEN
          l_action_mode := 'INSERT_CTX_DTLS';
          l_err_loc := 3400;
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_ctx_sqlstring_rec.bind_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gIDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gIDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gIDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gIDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gIDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gIDLanguageTbl);
          l_err_loc := 3500;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'regular Ctx SQLS details..' ||
                '; Num. of rows in dtls plsql table:' || gIDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_ctx_sqlstring_rec.bind_sequence ||
                ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;
        l_err_loc := 3600;
        IF (gDBLDInventoryItemIdTbl.COUNT > 0) THEN
          l_action_mode := 'DELETE_SPECIFIC_CTX_DTLS';
          l_err_loc := 3700;
          DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_ctx_sqlstring_rec.bind_sequence);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_INVENTORY_ITEM_ID', gDBLDInventoryItemIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_PO_LINE_ID', gDBLDPoLineIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_NAME', gDBLDReqTemplateNameTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_REQ_TEMPLATE_LINE_NUM', gDBLDReqTemplateLineNumTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_ORG_ID', gDBLDOrgIdTbl);
          DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_LANGUAGE', gDBLDLanguageTbl);
          l_err_loc := 3800;
          l_status := DBMS_SQL.EXECUTE(l_csr_handle);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'regular Ctx SQLS details..' ||
                '; Num. of rows in dtls plsql table:' || gDBLDInventoryItemIdTbl.COUNT ||
                ', for seq:' || l_ctx_sqlstring_rec.bind_sequence ||
                ', Num. of rows inserted into dtls:' || l_status);
          END IF;
        END IF;
        l_err_loc := 3900;
        DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
        l_err_loc := 20000 + i;
      END LOOP;
    END IF;  -- (p_current_cursor = ICX_CAT_UTIL_PVT.g_GBPACsr_const)

    l_err_loc := 4000;
    clearTables('ALL');

    l_err_loc := 4100;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      COMMIT;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;
    l_err_loc := 4200;

  END IF; -- (p_mode = 'OUTLOOP' OR gTotalRowCount >= ICX_CAT_UTIL_PVT.g_batch_size)
  l_err_loc := 4300;
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateItemCtxTables;

PROCEDURE populateVendorNameChanges
(       p_vendor_party_id       IN              NUMBER          ,
        p_vendor_name           IN              VARCHAR2
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateVendorNameChanges';
  l_err_loc             PLS_INTEGER;
  l_searchable          NUMBER;
  l_section_tag         NUMBER;
  l_continue            BOOLEAN := TRUE;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_row_count           PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_BUILD_CTX_SQL_PVT.checkIfAttributeIsSrchble
                ('SUPPLIER', l_searchable, l_section_tag);

  l_err_loc := 200;
  -- Set the batch_size if supplier needs to be updated
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  -- Set the who columns
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  IF (l_searchable = 1) THEN

    l_err_loc := 500;
    WHILE l_continue LOOP
      l_err_loc := 600;
      l_rowid_tbl.DELETE;

      l_err_loc := 700;
      UPDATE icx_cat_items_ctx_hdrs_tlp
      SET ctx_desc = NULL,
          supplier = p_vendor_name,
          last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_update_date = sysdate,
          internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
      WHERE supplier_id IN (SELECT vendor_id
                            FROM po_vendors
                            WHERE party_id = p_vendor_party_id)
      AND internal_request_id <> ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id
      AND ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
      RETURNING ROWID BULK COLLECT INTO l_rowid_tbl;

      l_err_loc := 800;
      l_row_count := SQL%ROWCOUNT;
      IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
        l_err_loc := 900;
        l_continue := FALSE;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
               'Num of rows updated in ctx_hdrs for supplier name change:' || l_row_count);
        END IF;
      END IF;

      l_err_loc := 1000;
      FORALL i IN 1..l_rowid_tbl.COUNT
        UPDATE icx_cat_items_ctx_dtls_tlp dtls
        SET ctx_desc = '<' || l_section_tag || '>' || replace(replace(p_vendor_name, '<', ' '), '>', ' ') || '</' || l_section_tag || '>',
            last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
            last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
            last_update_date = sysdate,
            internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
            request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
            program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
            program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
            program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
        WHERE sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow
        AND EXISTS ( SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                     WHERE hdrs.po_line_id = dtls.po_line_id
                     AND hdrs.req_template_name = dtls.req_template_name
                     AND hdrs.req_template_line_num = dtls.req_template_line_num
                     AND hdrs.inventory_item_id = dtls.inventory_item_id
                     AND hdrs.org_id = dtls.org_id
                     AND hdrs.language = dtls.language
                     AND hdrs.rowid = l_rowid_tbl(i) );

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
             ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
             'Num of rows updated in ctx_dtls for supplier name change:' ||SQL%ROWCOUNT);
      END IF;

      l_err_loc := 1100;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 1200;
        COMMIT;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END LOOP;

    l_err_loc := 1300;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 1400;
      -- Call the rebuild index
      ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Rebuild indexes called.');
      END IF;
    END IF;
  ELSE

    l_err_loc := 1400;
    WHILE l_continue LOOP
      l_err_loc := 1500;
      l_rowid_tbl.DELETE;

      l_err_loc := 1600;
      UPDATE icx_cat_items_ctx_hdrs_tlp
      SET supplier = p_vendor_name,
          last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_update_date = sysdate,
          internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
      WHERE supplier_id IN (SELECT vendor_id
                            FROM po_vendors
                            WHERE party_id = p_vendor_party_id)
      AND internal_request_id <> ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id
      AND ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 1700;
      l_row_count := SQL%ROWCOUNT;
      IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
        l_err_loc := 1800;
        l_continue := FALSE;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
               'Num of rows updated in ctx_hdrs for supplier name change:' || l_row_count);
        END IF;
      END IF;

      l_err_loc := 1900;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 2000;
        COMMIT;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END LOOP;

    l_err_loc := 2100;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Only update the supplier name on the header; Supplier is not searchable l_searchable:' || l_searchable );
    END IF;
  END IF; -- IF (l_searchable = 1) THEN

  l_err_loc := 2200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateVendorNameChanges;

/*
Steps:
1. update supplier_id, supplier_site_id and ctx_desc in icx_cat_items_ctx_hdrs_tlp
2. delete and insert into icx_cat_items_ctx_dtls_tlp : sequence 1 for supid and siteid
3. Check if supplier is searchable, if yes then update icx_cat_items_ctx_dtls_tlp : sequence 2 for supplier
4. call rebuild_index.
*/
PROCEDURE populateVendorMerge
(       p_from_vendor_id        IN              NUMBER                  ,
        p_from_site_id          IN              NUMBER                  ,
        p_to_vendor_id          IN              NUMBER                  ,
        p_to_site_id            IN              NUMBER
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'populateVendorMerge';
  l_err_loc                     PLS_INTEGER;
  l_to_vendor_name              po_vendors.vendor_name%TYPE;
  l_continue                    BOOLEAN := TRUE;
  l_rowid_tbl                   DBMS_SQL.UROWID_TABLE;
  l_rows_updated                BOOLEAN := TRUE;
  l_metadataTblFormed           BOOLEAN := FALSE;
  l_special_metadata_tbl        ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_nontl_metadata_tbl  ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_tl_metadata_tbl     ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_all_ctx_sql_tbl             ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_special_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_ctx_sqlstring_rec           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_csr_handle                  NUMBER;
  l_status                      PLS_INTEGER;
  l_searchable                  VARCHAR2(1) := NULL;
  l_metadata_rec                ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_rec_type;
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  -- Set the batch_size if supplier needs to be updated
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  -- Set the who columns
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;

  SELECT vendor_name
  INTO   l_to_vendor_name
  FROM   po_vendors
  WHERE  vendor_id = p_to_vendor_id;

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'l_to_vendor_name:' || l_to_vendor_name);
  END IF;

  l_err_loc := 600;
  -- open the cursor for the dynamic sql to insert the
  -- row with sequence 1 in icx_cat_items_ctx_dtls_tlp only once
  l_csr_handle := DBMS_SQL.OPEN_CURSOR;

  l_err_loc := 700;
  WHILE l_continue LOOP
    l_err_loc := 800;
    l_rowid_tbl.DELETE;

    l_err_loc := 900;
    UPDATE icx_cat_items_ctx_hdrs_tlp
    SET ctx_desc = NULL,
        supplier_id = p_to_vendor_id,
        supplier_site_id = p_to_site_id,
        supplier = l_to_vendor_name,
        last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
        last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
        last_update_date = sysdate,
        internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
        request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
        program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
        program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
        program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
    WHERE supplier_id = p_from_vendor_id
    AND   supplier_site_id = p_from_site_id
    AND   internal_request_id <> ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id
    AND   ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
    RETURNING ROWID BULK COLLECT INTO l_rowid_tbl;

    l_err_loc := 1000;
    l_row_count := SQL%ROWCOUNT;
    IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
      l_err_loc := 1100;
      l_continue := FALSE;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
               'Num of rows updated in ctx_hdrs for vendor merge:' || l_row_count);
        END IF;
    END IF;

    l_err_loc := 1200;

    IF (l_rowid_tbl.COUNT > 0) THEN
      l_err_loc := 1300;
      -- delete the mandatory row in icx_cat_items_ctx_dtls_tlp i.e. the row with sequence = 1
      FORALL i IN 1..l_rowid_tbl.COUNT
        DELETE FROM icx_cat_items_ctx_dtls_tlp dtls
        WHERE sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqMandatoryBaseRow
        AND EXISTS ( SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                     WHERE hdrs.po_line_id = dtls.po_line_id
                     AND hdrs.req_template_name = dtls.req_template_name
                     AND hdrs.req_template_line_num = dtls.req_template_line_num
                     AND hdrs.inventory_item_id = dtls.inventory_item_id
                     AND hdrs.org_id = dtls.org_id
                     AND hdrs.language = dtls.language
                     AND hdrs.rowid = l_rowid_tbl(i) );

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
             ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
             'Num. of rows deleted from dtls for seq=1:' || SQL%ROWCOUNT);
      END IF;

      l_err_loc := 1400;

      IF (NOT l_metadataTblFormed) THEN
        l_err_loc := 1500;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
               'populateVendorMerge: about to call buildMetaDataInfo and buildCtxSql');
        END IF;

        ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
               (0, l_special_metadata_tbl, l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl);
        l_metadataTblFormed := TRUE;

        l_err_loc := 1600;

        ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
             (0, 'ALL', 'ROWID', l_special_metadata_tbl,
              l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl,
              l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

        l_err_loc := 1700;
        l_ctx_sqlstring_rec := l_special_ctx_sql_tbl(1);

        -- parse the cursor only once
        l_err_loc := 1800;
        DBMS_SQL.PARSE(l_csr_handle, l_ctx_sqlstring_rec.ctx_sql_string, DBMS_SQL.NATIVE);
      END IF;

      l_err_loc := 1900;

      -- insert the mandatory row in icx_cat_items_ctx_dtls_tlp i.e. the row with sequence = 1
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_ctx_sqlstring_rec.bind_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 2000;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
             ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
             'Num. of rows inserted into dtls for seq=1:' || l_status);
      END IF;

      l_err_loc := 2100;

      IF (l_searchable IS NULL) THEN
        l_err_loc := 2200;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
               'about to call the getAttributeDetails for supplier');
        END IF;

        ICX_CAT_BUILD_CTX_SQL_PVT.getAttributeDetails
            (l_special_metadata_tbl, 'SUPPLIER', l_searchable, l_metadata_rec);
      END IF;

      l_err_loc := 2300;
      IF (l_searchable = 'Y') THEN
        l_err_loc := 2400;
        FORALL i IN 1..l_rowid_tbl.COUNT
          UPDATE icx_cat_items_ctx_dtls_tlp dtls
          SET ctx_desc = '<' || l_metadata_rec.section_tag || '>' ||
                         replace(replace(l_to_vendor_name, '<', ' '), '>', ' ') ||
                         '</' || l_metadata_rec.section_tag || '>',
              last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
              last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
              last_update_date = sysdate,
              internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
              request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
              program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
              program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
              program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
          WHERE sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow
          AND EXISTS ( SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                       WHERE hdrs.po_line_id = dtls.po_line_id
                       AND hdrs.req_template_name = dtls.req_template_name
                       AND hdrs.req_template_line_num = dtls.req_template_line_num
                       AND hdrs.inventory_item_id = dtls.inventory_item_id
                       AND hdrs.org_id = dtls.org_id
                       AND hdrs.language = dtls.language
                       AND hdrs.rowid = l_rowid_tbl(i) );
      ELSE
        l_err_loc := 2500;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Supplier is not searchable l_searchable:' || l_searchable );
        END IF;
      END IF;

      l_err_loc := 2600;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 2700;
        COMMIT;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END IF;  -- IF (l_rowid_tbl.COUNT > 0)
  END LOOP;  -- WHILE l_continue LOOP

  l_err_loc := 2800;

  -- close the cursor for the dynamic sql to insert the
  -- row with sequence 1 in icx_cat_items_ctx_dtls_tlp only once
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'the dynamic sql is closed');
  END IF;
  DBMS_SQL.CLOSE_CURSOR(l_csr_handle);

  l_err_loc := 2900;
  IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
    l_err_loc := 3000;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

    l_err_loc := 3100;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit done.');
    END IF;
  END IF;
  l_err_loc := 3200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateVendorMerge;

PROCEDURE openInvalidCategoryCsr
(       p_invalid_category_csr          IN OUT NOCOPY           g_csr_type
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'openInvalidCategoryCsr';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_structure_id:' || ICX_CAT_UTIL_PVT.g_structure_id ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id ||
        '; g_validate_flag:' || ICX_CAT_UTIL_PVT.g_validate_flag);
  END IF;

  -- No need of joining with icx_cat_categories_tl, because
  -- 1. the ip category will exist only if the profile
  --    POR_AUTO_CREATE_SHOPPING_CAT is set to Y
  -- 2. the ip category is optional for items in iprocurement.
  -- 3. When the mtl category gets invalid we remove all the master items
  --    that belonged to the mtl category.
  l_err_loc := 150;
  IF (ICX_CAT_UTIL_PVT.g_validate_flag = 'N') THEN
    l_err_loc := 200;
    OPEN p_invalid_category_csr FOR
      SELECT mtlb.category_id
      FROM mtl_categories_b mtlb
      WHERE mtlb.structure_id = ICX_CAT_UTIL_PVT.g_structure_id
      AND (NVL(mtlb.end_date_active, SYSDATE + 1) < SYSDATE
           OR NVL(mtlb.disable_date, SYSDATE + 1) < SYSDATE)
      AND EXISTS (SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                  WHERE hdrs.po_category_id = mtlb.category_id
                  AND hdrs.source_type = 'MASTER_ITEM');
  ELSE
    l_err_loc := 300;
    OPEN p_invalid_category_csr FOR
      SELECT mtlb.category_id
      FROM mtl_categories_b mtlb,
           mtl_category_set_valid_cats mcsvc
      WHERE mtlb.structure_id = ICX_CAT_UTIL_PVT.g_structure_id
      AND (NVL(mtlb.end_date_active, SYSDATE + 1) < SYSDATE
           OR NVL(mtlb.disable_date, SYSDATE + 1) < SYSDATE)
      AND mcsvc.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
      AND mcsvc.category_id = mtlb.category_id
      AND EXISTS (SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                  WHERE hdrs.po_category_id = mtlb.category_id
                  AND hdrs.source_type = 'MASTER_ITEM');
  END IF;
  l_err_loc := 400;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openInvalidCategoryCsr;

-- Purges items in invalid/expired categories
PROCEDURE purgeInvalidCategoryItems
IS

  ----- Start of declaring columns fetched from the cursor-----
  l_po_category_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns fetched from the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'purgeInvalidCategoryItems';
  l_continue                    BOOLEAN := TRUE;
  l_invalid_category_csr        g_csr_type;
  l_err_string                  VARCHAR2(4000);
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_log_string		        VARCHAR2(2000);
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 150;
  ICX_CAT_UTIL_PVT.getPurchasingCategorySetInfo;

  l_err_loc := 200;
  openInvalidCategoryCsr(l_invalid_category_csr);

  l_err_loc := 300;
  LOOP
    BEGIN

      l_err_loc := 400;
      l_po_category_id_tbl.DELETE;

      l_err_loc := 450;
      FETCH l_invalid_category_csr
      BULK COLLECT INTO l_po_category_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 500;
      EXIT WHEN l_po_category_id_tbl.COUNT = 0;

      FOR i IN 1..l_po_category_id_tbl.COUNT LOOP
        l_err_loc := 600;
        l_continue := TRUE;
        WHILE l_continue LOOP
          l_err_loc := 700;
          l_po_line_id_tbl.DELETE;
          l_req_template_name_tbl.DELETE;
          l_req_template_line_num_tbl.DELETE;
          l_inventory_item_id_tbl.DELETE;
          l_org_id_tbl.DELETE;
          l_language_tbl.DELETE;

          l_err_loc := 800;
          DELETE FROM icx_cat_items_ctx_hdrs_tlp hdrs
          WHERE hdrs.source_type = 'MASTER_ITEM'
          AND po_category_id = l_po_category_id_tbl(i)
          AND   ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
          RETURNING po_line_id, req_template_name, req_template_line_num,
              inventory_item_id, org_id, language
          BULK COLLECT INTO l_po_line_id_tbl, l_req_template_name_tbl, l_req_template_line_num_tbl,
              l_inventory_item_id_tbl, l_org_id_tbl, l_language_tbl;

          l_err_loc := 900;
          l_row_count := SQL%ROWCOUNT;
          IF (l_row_count = 0) THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_EVENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'No rows deleted from ctx_hdrs for invalid category, so exit out of the loop;');
            END IF;
            EXIT;
          ELSIF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
            l_continue := FALSE;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Num. of rows deleted from ctx_hdrs for invalid category:' || l_row_count);
            END IF;
          END IF;

          l_err_loc := 1000;
          FORALL j IN 1..l_po_line_id_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(j)
            AND req_template_name = l_req_template_name_tbl(j)
            AND req_template_line_num = l_req_template_line_num_tbl(j)
            AND inventory_item_id = l_inventory_item_id_tbl(j)
            AND org_id = l_org_id_tbl(j)
            AND language = l_language_tbl(j);

          l_err_loc := 1100;
          IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
            l_err_loc := 1200;
            COMMIT;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Commit done inside the while loop.');
            END IF;
          ELSE
            l_err_loc := 1300;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Commit not done inside the while loop.');
            END IF;
          END IF;
        END LOOP;
      END LOOP;

      l_err_loc := 1400;
      -- When the po_category becomes invalid, No need of deleting the ip category
      -- and mapping because the po_category can still exist on a document line and
      -- bulkload should be able to update the document line.

      l_err_loc := 1500;

      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 1600;
        COMMIT;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done inside the fetch loop.');
        END IF;
      ELSE
        l_err_loc := 1700;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done inside the fetch loop.');
        END IF;
      END IF;

      l_err_loc := 1750;
      EXIT WHEN l_po_category_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_ITEM_PVT.purgeInvalidCategoryItems' ||l_err_loc;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        CLOSE l_invalid_category_csr;
        openInvalidCategoryCsr(l_invalid_category_csr);
    END;
  END LOOP;

  l_err_loc := 1800;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END purgeInvalidCategoryItems;

-- Purges invalid/expired Req Templates
-- Purges the Req templates copied from blankets that are now invalid/expired
PROCEDURE purgeInvalidReqTmpltLines
IS

  ----- Start of declaring columns returned from the delete -----
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns returned from the delete ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'purgeInvalidReqTmpltLines';
  l_continue                    BOOLEAN := TRUE;
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_log_string		        VARCHAR2(2000);
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_continue := TRUE;
  WHILE l_continue LOOP
    l_err_loc := 200;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    l_err_loc := 300;
    DELETE FROM icx_cat_items_ctx_hdrs_tlp hdrs
    WHERE hdrs.source_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE')
    AND   (
            -- Req template lines that are invalid.
            EXISTS ( SELECT 'x'
                     FROM po_reqexpress_lines_all prl, po_reqexpress_headers_all prh,
                          po_lines_all pl, po_headers_all ph
                     WHERE  hdrs.po_line_id = -2
                     AND    hdrs.inventory_item_id = nvl(prl.item_id, -2)
                     AND    hdrs.req_template_name = prl.express_name
                     AND    hdrs.req_template_line_num = prl.sequence_num
                     AND    hdrs.org_id = prl.org_id
                     AND    prl.express_name = prh.express_name
                     AND    prl.org_id = prh.org_id
                     AND    prl.po_line_id = pl.po_line_id (+)
                     AND    prl.po_header_id = pl.po_header_id (+)
                     AND    pl.po_header_id = ph.po_header_id (+)
                     AND    (NVL(prh.inactive_date, SYSDATE + 1) <= SYSDATE
                             OR (prl.po_line_id IS NOT NULL AND
                                 (ph.approved_date IS NULL
                                  OR NVL(ph.authorization_status, 'INCOMPLETE') IN ('REJECTED', 'INCOMPLETE')
                                  OR NVL(ph.cancel_flag, 'N') = 'Y'
                                  OR NVL(ph.frozen_flag, 'N') = 'Y'
                                  OR NVL(ph.closed_code, 'OPEN') IN ('CLOSED', 'FINALLY CLOSED')
                                  OR NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) <= TRUNC(SYSDATE)
                                  OR NVL(pl.cancel_flag, 'N') = 'Y'
                                  OR NVL(pl.closed_code, 'OPEN') IN ('CLOSED', 'FINALLY CLOSED')
                                  OR NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) <= TRUNC(SYSDATE)))))
            OR
            -- Req template lines that are deleted.
            NOT EXISTS ( SELECT 'x'
                         FROM po_reqexpress_lines_all prl
                         WHERE  hdrs.po_line_id = -2
                         AND    hdrs.inventory_item_id = nvl(prl.item_id, -2)
                         AND    hdrs.req_template_name = prl.express_name
                         AND    hdrs.req_template_line_num = prl.sequence_num
                         AND    hdrs.org_id = prl.org_id)
          )
    AND   ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
    RETURNING po_line_id, req_template_name, req_template_line_num,
        inventory_item_id, org_id, language
    BULK COLLECT INTO l_po_line_id_tbl, l_req_template_name_tbl, l_req_template_line_num_tbl,
        l_inventory_item_id_tbl, l_org_id_tbl, l_language_tbl;

    l_err_loc := 400;
    l_row_count := SQL%ROWCOUNT;
    IF (l_row_count = 0) THEN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'no rows deleted from ctx_hdrs for invalid req tmplts, so exit from the loop');
      END IF;
      EXIT;
    ELSIF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
      l_continue := FALSE;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_hdrs for invalid req templates:' || l_row_count);
      END IF;
    END IF;

    l_err_loc := 500;
    FORALL j IN 1..l_po_line_id_tbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE po_line_id = l_po_line_id_tbl(j)
      AND req_template_name = l_req_template_name_tbl(j)
      AND req_template_line_num = l_req_template_line_num_tbl(j)
      AND inventory_item_id = l_inventory_item_id_tbl(j)
      AND org_id = l_org_id_tbl(j)
      AND language = l_language_tbl(j);

    l_err_loc := 600;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 700;
      COMMIT;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 800;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 900;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END purgeInvalidReqTmpltLines;

-- Purges invalid quotations
-- Quotations: ICX_CAT_POPULATE_STATUS_PVT.getQuoteLineStatus returns
-- ICX_CAT_POPULATE_STATUS_PVT.INVALID_FOR_POPULATE i.e -1
PROCEDURE purgeInvalidQuoteLines
IS

  ----- Start of declaring columns returned from the delete -----
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns returned from the delete ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'purgeInvalidQuoteLines';
  l_continue                    BOOLEAN := TRUE;
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_log_string		        VARCHAR2(2000);
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 110;
  l_continue := TRUE;
  WHILE l_continue LOOP
    l_err_loc := 200;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    l_err_loc := 300;
    DELETE FROM icx_cat_items_ctx_hdrs_tlp hdrs
    WHERE hdrs.source_type = 'QUOTATION'
    AND   (
           -- Quote lines that are invalid.
           ICX_CAT_POPULATE_STATUS_PVT.getQuoteLineStatus(hdrs.po_line_id) = -1
           OR
           -- Quote lines that are deleted.
           NOT EXISTS ( SELECT 'x' FROM po_lines_all pl
                        WHERE  hdrs.po_line_id = pl.po_line_id)
          )
    AND   ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
    RETURNING po_line_id, req_template_name, req_template_line_num,
        inventory_item_id, org_id, language
    BULK COLLECT INTO l_po_line_id_tbl, l_req_template_name_tbl, l_req_template_line_num_tbl,
        l_inventory_item_id_tbl, l_org_id_tbl, l_language_tbl;

    l_err_loc := 400;
    l_row_count := SQL%ROWCOUNT;
    IF (l_row_count = 0) THEN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'no rows deleted from ctx_hdrs for invalid Quote lines, so exit from the loop');
      END IF;
      EXIT;
    ELSIF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
      l_continue := FALSE;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_hdrs for invalid Quote lines:' || l_row_count);
      END IF;
    END IF;

    l_err_loc := 500;
    FORALL j IN 1..l_po_line_id_tbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE po_line_id = l_po_line_id_tbl(j)
      AND req_template_name = l_req_template_name_tbl(j)
      AND req_template_line_num = l_req_template_line_num_tbl(j)
      AND inventory_item_id = l_inventory_item_id_tbl(j)
      AND org_id = l_org_id_tbl(j)
      AND language = l_language_tbl(j);

    l_err_loc := 600;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 700;
      COMMIT;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 800;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 900;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 1000;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END purgeInvalidQuoteLines;

-- Purges invalid/expired blankets includes global blankets also
-- Blankets:
-- Header validations:
-- Approved_date is null
-- authorization_status in 'REJECTED', 'INCOMPLETE'
-- cancel_flag = 'Y'
-- frozen_flag = 'Y'
-- closed_code in 'CLOSED', 'FINALLY CLOSED'
-- sysdate > end_date
-- Line validations:
-- cancel_flag = 'Y'
-- closed_code in 'CLOSED', 'FINALLY CLOSED'
-- sysdate > expiration_date
PROCEDURE purgeInvalidBlanketLines
IS

  ----- Start of declaring columns returned from the delete -----
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns returned from the delete ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'purgeInvalidBlanketLines';
  l_continue                    BOOLEAN := TRUE;
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 110;
  l_continue := TRUE;
  WHILE l_continue LOOP
    l_err_loc := 200;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    l_err_loc := 300;
    DELETE FROM icx_cat_items_ctx_hdrs_tlp hdrs
    WHERE hdrs.source_type IN ('BLANKET', 'GLOBAL_BLANKET')
    AND   EXISTS ( SELECT 'x' FROM po_lines_all pl, po_headers_all ph
                   WHERE  hdrs.po_line_id = pl.po_line_id
                   AND    pl.po_header_id = ph.po_header_id
                   AND    (ph.approved_date IS NULL
                           OR NVL(ph.authorization_status, 'INCOMPLETE') IN ('REJECTED', 'INCOMPLETE')
                           OR NVL(ph.cancel_flag, 'N') = 'Y'
                           OR NVL(ph.frozen_flag, 'N') = 'Y'
                           OR NVL(ph.closed_code, 'OPEN') IN ('CLOSED', 'FINALLY CLOSED')
                           OR NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) <= TRUNC(SYSDATE)
                           OR NVL(pl.cancel_flag, 'N') = 'Y'
                           OR NVL(pl.closed_code, 'OPEN') IN ('CLOSED', 'FINALLY CLOSED')
                           OR NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) <= TRUNC(SYSDATE)))
    AND   ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
    RETURNING po_line_id, req_template_name, req_template_line_num,
        inventory_item_id, org_id, language
    BULK COLLECT INTO l_po_line_id_tbl, l_req_template_name_tbl, l_req_template_line_num_tbl,
        l_inventory_item_id_tbl, l_org_id_tbl, l_language_tbl;

    l_err_loc := 400;
    l_row_count := SQL%ROWCOUNT;
    IF (l_row_count = 0) THEN
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EVENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'no rows deleted from ctx_hdrs for invalid blanket lines, so exit from the loop');
      END IF;
      EXIT;
    ELSIF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
      l_continue := FALSE;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows deleted from ctx_hdrs for invalid blanket lines:' || l_row_count);
      END IF;
    END IF;

    l_err_loc := 500;
    FORALL j IN 1..l_po_line_id_tbl.COUNT
      DELETE FROM icx_cat_items_ctx_dtls_tlp
      WHERE po_line_id = l_po_line_id_tbl(j)
      AND req_template_name = l_req_template_name_tbl(j)
      AND req_template_line_num = l_req_template_line_num_tbl(j)
      AND inventory_item_id = l_inventory_item_id_tbl(j)
      AND org_id = l_org_id_tbl(j)
      AND language = l_language_tbl(j);

    l_err_loc := 600;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 700;
      COMMIT;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 800;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 900;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 1000;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END purgeInvalidBlanketLines;

PROCEDURE purgeInvalidItems
(       x_errbuf                OUT NOCOPY      VARCHAR2                ,
        x_retcode               OUT NOCOPY      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'purgeInvalidItems';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 150;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 300;
  -- Set the batch_size if supplier needs to be updated
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 400;
  purgeInvalidBlanketLines;

  l_err_loc := 500;
  purgeInvalidQuoteLines;

  l_err_loc := 600;
  purgeInvalidReqTmpltLines;

  l_err_loc := 700;
  purgeInvalidCategoryItems;

  l_err_loc := 800;
  IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
    l_err_loc := 900;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Rebuild indexes called.');
    END IF;
  END IF;

  l_err_loc := 1000;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuf := 'Exception at ' ||
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name) ||
                '(l_err_loc:' || l_err_loc || '), ' || SQLERRM;
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END purgeInvalidItems;

PROCEDURE rebuildIPIntermediaIndex
(       x_errbuf                OUT NOCOPY      VARCHAR2                ,
        x_retcode               OUT NOCOPY      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'rebuildIPIntermediaIndex';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 200;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 300;
  -- Call the rebuild index
  ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

  l_err_loc := 400;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuf := 'Exception at ' ||
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name) ||
                '(l_err_loc:' || l_err_loc || '), ' || SQLERRM;
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END rebuildIPIntermediaIndex;

END ICX_CAT_POPULATE_ITEM_PVT;

/
